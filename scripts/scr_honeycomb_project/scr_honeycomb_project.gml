// ============================================================================
// THE SLEEVE
// RED = LETHAL GEOMETRY. CYAN = SAFE DOORWAYS.
// DRAWN POSITIONS MUST MATCH HITBOXES.
// ============================================================================

function scr_honeycomb_project(_angle, _base_height, _center_x, _center_y, _radius, _depth_offset, _scale_min, _scale_max, _alpha_min, _alpha_max) {
    var _z = sin(_angle);
    var _t = (_z + 1) * 0.5;

    var _x = _center_x + cos(_angle) * _radius;
    var _y = _center_y + _base_height + (_z * _depth_offset);

    return {
        x:     _x,
        y:     _y,
        scale: lerp(_scale_min, _scale_max, _t),
        alpha: lerp(_alpha_min, _alpha_max, _t),
        z:     _z
    };
}

function scr_honeycomb_visible_band(_center_y, _depth_offset, _margin) {
    var _view_top, _view_bottom;

    if (instance_exists(oCameraController)) {
        _view_top    = oCameraController.current_cam_y;
        _view_bottom = _view_top + oCameraController.current_cam_h;
    } else {
        _view_top    = 0;
        _view_bottom = room_height;
    }

    return {
        top:    _view_top    - _center_y - _depth_offset - _margin,
        bottom: _view_bottom - _center_y + _depth_offset + _margin
    };
}

function scr_honeycomb_update_specs() {
    hc_active_count = 0;

    var _now = instance_exists(oAvoidanceController) ? oAvoidanceController.t : _k_hc_t_spawn;
    var _hazard_live = _now >= _k_hc_t_kill;
    var _ring_count = array_length(hc_pulse_rings);
    var _has_player = instance_exists(oPlayer);
    var _player_x = 0;
    var _player_y = 0;
    if (_has_player) {
        _player_x = oPlayer.x;
        _player_y = oPlayer.y;
    }
    var _prox_radius = 190;
    var _prox_radius_sq = _prox_radius * _prox_radius;
    var _shimmer_time = current_time * 0.004;

    var _plug_h  = scr_duct_plug_h();
    var _reach   = max(1, scr_duct_light_reach());
    var _light   = duct_light;
    var _flow    = duct_flow;

    for (var _i = spec_lo; _i < spec_hi; _i++) {
        var _sp = bullet_specs[_i];
        if (!_sp.live) continue;

        hc_active_count++;

        if (_sp.blast_active) {
            _sp.hit_active = false;
            _sp.despawn_timer++;
            var _bt = clamp(_sp.despawn_timer / max(1, _sp.despawn_duration), 0, 1);

            _sp.draw_x = _sp.x + lengthdir_x(_sp.blast_speed, _sp.blast_dir);
            _sp.draw_y = _sp.y + lengthdir_y(_sp.blast_speed, _sp.blast_dir);
            _sp.x = _sp.draw_x;
            _sp.y = _sp.draw_y;

            _sp.blast_speed *= 0.965;
            _sp.blast_angle += _sp.blast_spin;
            _sp.ignite_flash = max(0, _sp.ignite_flash - 0.05);

            _sp.draw_scale = lerp(1.5, 0.05, power(_bt, 1.6)) *
                             max(_sp.honeycomb_depth * 0.5 + 0.75, 0.4);
            _sp.draw_alpha = 1 - power(_bt, 2.4);
            _sp.image_alpha = _sp.draw_alpha;

            if (_sp.despawn_timer >= _sp.despawn_duration) {
                _sp.live = false;
                _sp.draw_alpha = 0;
                hc_active_count--;
            }
            continue;
        }

        if (hc_detonated) {
            _sp.live = false;
            _sp.hit_active = false;
            _sp.draw_alpha = 0;
            hc_active_count--;
            continue;
        }

        if (!_sp.ignited) {
            if (_sp.height <= materialize_h) {
                _sp.ignited = true;
                _sp.ignite_flash = 1;
                _sp.seen = true;
            } else {
                _sp.hit_active = false;
                _sp.draw_alpha = 0;

                var _pre_angle = _sp.angle + cylinder_rotation;
                var _pre_z = sin(_pre_angle);
                _sp.draw_x = center_x + cos(_pre_angle) * radius;
                _sp.draw_y = center_y + _sp.height + _pre_z * depth_offset;
                _sp.x = _sp.draw_x;
                _sp.y = _sp.draw_y;
                _sp.honeycomb_depth = _pre_z;
                continue;
            }
        }

        _sp.ignite_flash = max(0, _sp.ignite_flash - 0.055);

        if (!_sp.spawn_complete) {
            _sp.spawn_timer++;
            var _spawn_t = _sp.spawn_timer / max(1, _sp.spawn_duration);
            _sp.image_alpha = 1 - power(1 - _spawn_t, 4);
            if (_sp.spawn_timer >= _sp.spawn_duration) {
                _sp.image_alpha = 1;
                _sp.spawn_complete = true;
            }
        }

        var _current_angle = _sp.angle + cylinder_rotation;
        var _z = sin(_current_angle);
        var _face = (_z + 1) * 0.5;

        _sp.draw_x = center_x + cos(_current_angle) * radius;
        _sp.draw_y = center_y + _sp.height + (_z * depth_offset);
        _sp.x = _sp.draw_x;
        _sp.y = _sp.draw_y;
        _sp.honeycomb_depth = _z;

        var _proj_scale = lerp(scale_min, scale_max, _face);
        var _proj_alpha = lerp(alpha_min, alpha_max, _face);

        _sp.ring_heat = 0;
        for (var _r_i = 0; _r_i < _ring_count; _r_i++) {
            var _r = hc_pulse_rings[_r_i];
            var _d = abs(_sp.height - _r.h);
            if (_d < _k_hc_pulse_width) {
                var _band = power(1 - (_d / _k_hc_pulse_width), 1.5);
                _sp.ring_heat = max(_sp.ring_heat, _band * _r.power * (_r.life / _r.life_max));
            }
        }

        var _ahead = (_plug_h - _sp.height) * _flow;
        _sp.chase_heat = power(clamp(1 - _ahead / _reach, 0, 1), 1.6) * _light;

        _sp.prox_heat = 0;
        if (_z > 0.2 && _has_player) {
            var _pdx = _sp.draw_x - _player_x;
            if (abs(_pdx) < _prox_radius) {
                var _pdy = _sp.draw_y - _player_y;
                if (abs(_pdy) < _prox_radius) {
                    var _pd_sq = _pdx * _pdx + _pdy * _pdy;
                    if (_pd_sq < _prox_radius_sq) {
                        var _pd = sqrt(_pd_sq);
                        _sp.prox_heat = power(1 - _pd / _prox_radius, 2);
                    }
                }
            }
        }

        var _heat = _sp.ring_heat + hc_wall_heat * 0.35 + _sp.prox_heat * 0.5
                  + _sp.ignite_flash;

        var _sealed = false;
        if (_sp.is_open && _sp.edge_id != -1) _sealed = (edges[_sp.edge_id].door_s == 3);

        if (_sp.is_open && !_sealed) {
            var _shimmer = 0.74 + 0.26 * sin(_shimmer_time + _sp.shimmer_phase);
            var _lane_bonus = _sp.is_lane ? (0.34 + lane_guide_pulse * 0.42) : 0;
            _sp.draw_alpha = open_alpha * _sp.image_alpha * (_shimmer + _lane_bonus) *
                             (0.30 + _face * 0.70);
            _sp.draw_scale = _proj_scale * _sp.pulse_scale * 0.55;
        } else {
            _sp.draw_alpha = _proj_alpha * _sp.image_alpha + _sp.pulse_glow * 0.35 + _heat * 0.5;
            _sp.draw_scale = _proj_scale * _sp.pulse_scale * (1 + _heat * 0.55);
        }

        _sp.hit_active = _hazard_live && (!_sp.is_open || _sealed) && !hc_detonated && _z > 0.03 &&
                         _sp.draw_alpha > 0.12 && _sp.draw_scale > 0.05;

        if (_sp.last_pulse_id != bass_pulse_id) {
            _sp.last_pulse_id = bass_pulse_id;
            _sp.pulse_scale = 1.05 + bass_escalation * 0.22;
            _sp.pulse_glow = 1;
            _sp.pulse_glow_timer = 10;
        } else {
            _sp.pulse_scale = lerp(_sp.pulse_scale, 1, 0.18);
        }

        if (_sp.pulse_glow_timer > 0) {
            _sp.pulse_glow_timer--;
        } else {
            _sp.pulse_glow = lerp(_sp.pulse_glow, 0, 0.2);
        }

        if (!_sp.is_open && _z > 0.72 && _sp.prox_heat > 0.05) {
            scr_register_glow_point(_sp.draw_x, _sp.draw_y);
        }
    }
}

function scr_honeycomb_player_meeting(_px, _py) {
    if (!instance_exists(oHoneycombController) || !instance_exists(oPlayer)) return false;
    if (instance_exists(oGameover)) return false;

    var _hc = oHoneycombController;
    if (_hc.hc_detonated) return false;

    var _now = instance_exists(oAvoidanceController) ? oAvoidanceController.t : _hc._k_hc_t_spawn;
    if (_now < _hc._k_hc_t_kill) return false;

    var _r_base = variable_instance_exists(_hc, "hc_hit_radius") ? _hc.hc_hit_radius : 5;

    for (var _i = _hc.spec_lo; _i < _hc.spec_hi; _i++) {
        var _sp = _hc.bullet_specs[_i];
        if (!_sp.live || !_sp.hit_active || _sp.already_hit_player) continue;

        var _r = max(1, _r_base * _sp.draw_scale);
        var _broad = _r + 32;
        if (abs(_px - _sp.draw_x) > _broad || abs(_py - _sp.draw_y) > _broad + 12) continue;

        if (collision_circle(_sp.draw_x, _sp.draw_y, _r, oPlayer, false, false) != noone) {
            _sp.already_hit_player = true;
            return true;
        }
    }

    return false;
}


function scr_honeycomb_band(_x1, _y1, _x2, _y2, _h1, _h2, _cin, _ain, _cout, _aout) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _dl = max(0.001, sqrt(_dx * _dx + _dy * _dy));
    var _nx = -_dy / _dl;
    var _ny =  _dx / _dl;

    var _off = [ -_h2, -_h1, _h1, _h2 ];
    var _col = [ _cout, _cin, _cin, _cout ];
    var _alp = [ _aout, _ain, _ain, _aout ];

    draw_primitive_begin(pr_trianglelist);
    for (var _b = 0; _b < 3; _b++) {
        var _o0 = _off[_b],     _o1 = _off[_b + 1];
        var _c0 = _col[_b],     _c1 = _col[_b + 1];
        var _a0 = _alp[_b],     _a1 = _alp[_b + 1];
        if (_a0 <= 0.002 && _a1 <= 0.002) continue;

        var _ax0 = _x1 + _nx * _o0, _ay0 = _y1 + _ny * _o0;
        var _ax1 = _x1 + _nx * _o1, _ay1 = _y1 + _ny * _o1;
        var _bx0 = _x2 + _nx * _o0, _by0 = _y2 + _ny * _o0;
        var _bx1 = _x2 + _nx * _o1, _by1 = _y2 + _ny * _o1;

        draw_vertex_color(_ax0, _ay0, _c0, _a0);
        draw_vertex_color(_bx0, _by0, _c0, _a0);
        draw_vertex_color(_ax1, _ay1, _c1, _a1);

        draw_vertex_color(_bx0, _by0, _c0, _a0);
        draw_vertex_color(_bx1, _by1, _c1, _a1);
        draw_vertex_color(_ax1, _ay1, _c1, _a1);
    }
    draw_primitive_end();
}


function scr_honeycomb_beam(_x1, _y1, _x2, _y2, _half, _c_lip, _c_mass, _c_core, _a) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _dl = max(0.001, sqrt(_dx * _dx + _dy * _dy));
    var _nx = -_dy / _dl;
    var _ny =  _dx / _dl;

    var _o1 = _half;
    var _o2 = _half * 0.80;
    var _o3 = _half * 0.30;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_x1 - _nx * _o1, _y1 - _ny * _o1, _c_lip,  _a);
    draw_vertex_color(_x2 - _nx * _o1, _y2 - _ny * _o1, _c_lip,  _a);
    draw_vertex_color(_x1 - _nx * _o2, _y1 - _ny * _o2, _c_mass, _a);
    draw_vertex_color(_x2 - _nx * _o2, _y2 - _ny * _o2, _c_mass, _a);
    draw_vertex_color(_x1 - _nx * _o3, _y1 - _ny * _o3, _c_mass, _a);
    draw_vertex_color(_x2 - _nx * _o3, _y2 - _ny * _o3, _c_mass, _a);
    draw_vertex_color(_x1,             _y1,             _c_core, _a);
    draw_vertex_color(_x2,             _y2,             _c_core, _a);
    draw_vertex_color(_x1 + _nx * _o3, _y1 + _ny * _o3, _c_mass, _a);
    draw_vertex_color(_x2 + _nx * _o3, _y2 + _ny * _o3, _c_mass, _a);
    draw_vertex_color(_x1 + _nx * _o2, _y1 + _ny * _o2, _c_mass, _a);
    draw_vertex_color(_x2 + _nx * _o2, _y2 + _ny * _o2, _c_mass, _a);
    draw_vertex_color(_x1 + _nx * _o1, _y1 + _ny * _o1, _c_lip,  _a);
    draw_vertex_color(_x2 + _nx * _o1, _y2 + _ny * _o1, _c_lip,  _a);
    draw_primitive_end();
}



function scr_honeycomb_draw_wire() {
    if (!instance_exists(oHoneycombController)) exit;

    with (oHoneycombController) {

        var _armor  = global.avoid_col_armor_dark;
        var _armorm = global.avoid_col_armor_mid;
        var _edge   = global.avoid_col_armor_edge;
        var _blood  = global.avoid_col_blood;
        var _danger = global.avoid_col_danger;
        var _warn   = global.avoid_col_warning;
        var _ember  = global.avoid_col_ember;
        var _hot    = global.avoid_col_hot;
        var _cyan   = global.avoid_col_cyan;
        var _cyans  = global.avoid_col_cyan_soft;

        var _now = instance_exists(oAvoidanceController) ? oAvoidanceController.t : _k_hc_t_spawn;

        var _view_top = instance_exists(oCameraController) ? oCameraController.current_cam_y : 0;
        var _view_bot = instance_exists(oCameraController)
                      ? (oCameraController.current_cam_y + oCameraController.current_cam_h)
                      : room_height;

        if (hc_detonated) {
            gpu_set_blendmode(bm_add);
            for (var _si = spec_lo; _si < spec_hi; _si++) {
                var _sh = bullet_specs[_si];
                if (!_sh.live || _sh.draw_alpha <= 0.01) continue;

                var _sa = _sh.draw_alpha;
                var _tail = 14 + _sh.draw_scale * 26;
                var _tx = _sh.draw_x - lengthdir_x(_tail, _sh.blast_dir);
                var _ty = _sh.draw_y - lengthdir_y(_tail, _sh.blast_dir);
                var _col = merge_color(merge_color(_danger, _ember, 0.35), c_white, _sh.ignite_flash * 0.5);
                var _w = max(0.4, _sh.draw_scale);

                draw_set_color(_col);
                draw_set_alpha(_sa * 0.20);
                draw_line_width(_tx, _ty, _sh.draw_x, _sh.draw_y, 8 * _w);
                draw_set_alpha(_sa * 0.80);
                draw_line_width(_tx, _ty, _sh.draw_x, _sh.draw_y, 1.8 * _w);
                draw_set_color(merge_color(_hot, c_white, 0.4));
                draw_set_alpha(_sa * 0.7);
                draw_circle(_sh.draw_x, _sh.draw_y, 1.4 + _w * 1.6, false);
            }

            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);
            draw_set_color(c_white);
            exit;
        }

        var _height_view_top = _view_top - center_y - depth_offset - 140;
        var _height_view_bot = _view_bot - center_y + depth_offset + 140;

        var _hit_r  = hc_hit_radius;
        var _plug_h = scr_duct_plug_h();
        var _reach  = max(1, scr_duct_light_reach());
        var _flow   = duct_flow;
        var _light  = duct_light;
        var _hush   = duct_hush;

        var _base_heat = hc_wall_heat * 0.25 + bass_flash * 0.18 +
                         hc_heartbeat * 0.35 + hc_coil * 0.20;

        var _edge_count = array_length(edges);
        var _cell_n = array_length(cells);
        var _inset  = _k_duct_panel_inset;
        var _cell_now = hc_cell_now;

        var _corner_x = array_create(6, 0);
        var _corner_y = array_create(6, 0);

        var _shade = [ 0.75, 0.25, 0.0, 0.25, 0.75, 1.0 ];

        var _plate_lit = merge_color(_armorm, _edge, 0.20);
        var _plate_mid = _armorm;
        var _plate_dim = _armor;

        var _rib_lip  = merge_color(_armorm, _edge, 0.66);
        var _rib_mass = merge_color(_armorm, _edge, 0.22);
        var _rib_core = merge_color(_blood, _armor,  0.42);   // the dark red material

        var _leaf_lip  = merge_color(_armorm, _edge, 0.78);
        var _leaf_mass = merge_color(_armorm, _edge, 0.30);

        gpu_set_blendmode(bm_normal);

        // -- the skin -------------------------------------------------------
        for (var _ci2 = 0; _ci2 < _cell_n; _ci2++) {
            var _cl = cells[_ci2];
            if (_cl.height < _height_view_top || _cl.height > _height_view_bot) continue;
            if (materialize_h < _cl.height) continue;

            var _cla = _cl.angle + cylinder_rotation;
            var _clz = sin(_cla);
            if (_clz < 0.10) continue;

            var _clx = center_x + cos(_cla) * radius;
            var _cly = center_y + _cl.height + _clz * depth_offset;
            if (_cly < _view_top - 150 || _cly > _view_bot + 150) continue;

            // ---- the chase state of this cell -----------------------------
            var _lock = _cl.lock;
            var _mine = (_ci2 == _cell_now);

            var _pa = (0.52 + _clz * 0.44) * (1 - _hush * 0.10);
            _pa = _pa * (1 + _lock * 0.28 + (_mine ? 0.10 : 0));

            var _face_c = merge_color(_plate_mid, _plate_lit, _mine ? 0.55 : 0.16);
            _face_c = merge_color(_face_c, _armor, _lock * 0.92);
            var _rim_c = merge_color(_plate_dim, _blood, _lock * 0.38);

            var _cb = _cl.base;
            for (var _pk2 = 0; _pk2 < 6; _pk2++) {
                var _pca = cell_ca[_cb + _pk2] + cylinder_rotation;
                _corner_x[_pk2] = center_x + cos(_pca) * radius;
                _corner_y[_pk2] = center_y + cell_ch[_cb + _pk2] + sin(_pca) * depth_offset;
            }

            draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(_clx, _cly, _face_c, _pa);
            for (var _pk3 = 0; _pk3 <= 6; _pk3++) {
                var _pi3 = _pk3 mod 6;
                draw_vertex_color(lerp(_clx, _corner_x[_pi3], _inset),
                                  lerp(_cly, _corner_y[_pi3], _inset),
                                  merge_color(_rim_c, _plate_lit, _shade[_pi3] * 0.42 * (1 - _lock * 0.7)),
                                  _pa);
            }
            draw_primitive_end();

            draw_primitive_begin(pr_linestrip);
            for (var _pk4 = 0; _pk4 <= 6; _pk4++) {
                var _pi4 = _pk4 mod 6;
                draw_vertex_color(lerp(_clx, _corner_x[_pi4], 0.58),
                                  lerp(_cly, _corner_y[_pi4], 0.58),
                                  merge_color(_plate_lit, _armor, _lock * 0.6),
                                  _pa * 0.85);
            }
            draw_primitive_end();
        }

        // -- the ribs, and the door leaves ----------------------------------
        vis_n = 0;

        for (var _e = 0; _e < _edge_count; _e++) {
            var _ed = edges[_e];

            var _p1h = _ed.ay + height_offset;
            var _p2h = _ed.by + height_offset;
            var _hmin = min(_p1h, _p2h);
            var _hmax = max(_p1h, _p2h);

            if (_hmax < _height_view_top || _hmin > _height_view_bot) continue;
            if (materialize_h < _hmin) continue;

            var _a_ang = _ed.ang_a + cylinder_rotation;
            var _b_ang = _ed.ang_b + cylinder_rotation;
            var _p1z = sin(_a_ang);
            var _p2z = sin(_b_ang);
            var _zavg = (_p1z + _p2z) * 0.5;
            if (_zavg < 0) continue;

            var _p1x = center_x + cos(_a_ang) * radius;
            var _p1y = center_y + _p1h + _p1z * depth_offset;
            var _p2x = center_x + cos(_b_ang) * radius;
            var _p2y = center_y + _p2h + _p2z * depth_offset;

            if (max(_p1y, _p2y) < _view_top - 140 || min(_p1y, _p2y) > _view_bot + 140) continue;

            var _x1 = _p1x, _y1 = _p1y, _x2 = _p2x, _y2 = _p2y;
            if (materialize_h < _hmax) {
                var _g = (_hmax == _hmin) ? 1 : clamp((materialize_h - _hmin) / (_hmax - _hmin), 0, 1);
                if (_p1h <= _p2h) { _x2 = lerp(_p1x, _p2x, _g); _y2 = lerp(_p1y, _p2y, _g); }
                else              { _x1 = lerp(_p2x, _p1x, _g); _y1 = lerp(_p2y, _p1y, _g); }
            }

            var _face = clamp((_zavg + 1) * 0.5, 0, 1);

            vis_e[vis_n]  = _e;
            vis_x1[vis_n] = _x1;
            vis_y1[vis_n] = _y1;
            vis_x2[vis_n] = _x2;
            vis_y2[vis_n] = _y2;
            vis_f[vis_n]  = _face;
            vis_n++;

            var _sc   = lerp(scale_min, scale_max, _face);
            var _half = max(3.4, _hit_r * _sc * 1.95);
            var _ma   = 0.60 + (_face - 0.5) * 2 * 0.38;

            if (_ed.open) {
                // ---- A DOOR ------------------------------------------------
                var _dp = _ed.door_p;
                if (_dp <= 0.004) continue;
                if (_ed.door_s == 3) _dp = 1 - power(_ed.door_f, 3) * 0.055;

                var _dhm  = _half * 1.32;
                var _seal = (_ed.door_s == 3);
                var _lcore = _seal ? merge_color(_rib_core, _blood, 0.45) : _leaf_mass;

                for (var _lf = 0; _lf < 2; _lf++) {
                    var _du0 = (_lf == 0) ? 0.02 : 0.98;
                    var _du1 = (_lf == 0) ? (0.02 + _dp * 0.48) : (0.98 - _dp * 0.48);
                    scr_honeycomb_beam(lerp(_x1, _x2, _du0), lerp(_y1, _y2, _du0),
                                       lerp(_x1, _x2, _du1), lerp(_y1, _y2, _du1), _dhm,
                                       _leaf_lip, _leaf_mass, _lcore, _ma);
                }
                continue;
            }

            scr_honeycomb_beam(_x1, _y1, _x2, _y2, _half,
                               _rib_lip, _rib_mass, _rib_core, _ma);
        }

        gpu_set_blendmode(bm_add);

        // -- the corridor ---------------------------------------------------
        var _cell_r = hex_radius * 0.58 * (radius / radius_base);
        for (var _cp2 = 0; _cp2 < _cell_n; _cp2++) {
            var _cq = cells[_cp2];
            var _qmine = (_cp2 == _cell_now);
            if (!_cq.is_lane && !_qmine && _cq.lock <= 0.02) continue;
            if (_cq.height < _height_view_top || _cq.height > _height_view_bot) continue;
            if (materialize_h < _cq.height) continue;

            var _cqa = _cq.angle + cylinder_rotation;
            var _cqz = sin(_cqa);
            if (_cqz < 0.16) continue;

            var _cqx = center_x + cos(_cqa) * radius;
            var _cqy = center_y + _cq.height + _cqz * depth_offset;
            if (_cqy < _view_top - 150 || _cqy > _view_bot + 150) continue;

            var _qlock = _cq.lock;

            if (_qlock > 0.02) {
                // ---- LOCKED ---------------------------------------------
                var _qs = 0.55 + 0.45 * sin(_now * 0.11 + _cp2 * 1.7);
                var _qa = _qlock * (0.30 + _qs * 0.34) * power(_cqz, 1.3)
                        * (1 + duct_lock_flash * 0.7);
                draw_set_color(_blood);
                draw_set_alpha(_qa * 0.42);
                draw_circle(_cqx, _cqy, 8 + _qs * 3, false);
                draw_set_color(merge_color(_danger, _warn, _qs));
                draw_set_alpha(_qa);
                draw_circle(_cqx, _cqy, 2.4 + _qs * 1.0, false);
                continue;
            }

            // ---- LIT ----------------------------------------------------
            var _lrx = _cell_r * max(0.10, abs(_cqz));
            var _laa = ((_qmine ? 0.13 : 0.055) + lane_guide_pulse * 0.05)
                     * power(_cqz, 1.4) * (1 - _hush * 0.4);

            draw_primitive_begin(pr_trianglefan);
            draw_vertex_color(_cqx, _cqy, _cyans, _laa * 2.1);
            for (var _hx = 0; _hx <= 6; _hx++) {
                var _ha = 90 + _hx * 60;
                draw_vertex_color(_cqx + dcos(_ha) * _lrx, _cqy - dsin(_ha) * _cell_r, _cyan, 0);
            }
            draw_primitive_end();

            var _lmp = (_qmine ? 1 : 0.5) * power(_cqz, 1.5) * (1 - _hush * 0.4);
            draw_set_color(merge_color(_cyans, c_white, 0.45));
            draw_set_alpha(_lmp * 0.55);
            for (var _lm = -1; _lm <= 1; _lm += 2) {
                draw_circle(_cqx, _cqy + _lm * _cell_r * 0.62, 1.5 + _lmp * 0.9, false);
            }
        }

        // -- the structure ---------------------------------------------------
        for (var _vi = 0; _vi < vis_n; _vi++) {
            var _e2  = vis_e[_vi];
            var _ed2 = edges[_e2];
            var _qx1 = vis_x1[_vi], _qy1 = vis_y1[_vi];
            var _qx2 = vis_x2[_vi], _qy2 = vis_y2[_vi];
            var _f   = vis_f[_vi];

            var _q1h = _ed2.ay + height_offset;
            var _q2h = _ed2.by + height_offset;
            var _ahead = (_plug_h - (_q1h + _q2h) * 0.5) * _flow;
            var _chase = power(clamp(1 - _ahead / _reach, 0, 1), 1.6) * _light;

            var _hw = max(3.4, _hit_r * lerp(scale_min, scale_max, _f) * 1.95);

            if (_ed2.open) {
                // ---- A DOOR ------------------------------------------------
                // OPEN -> WARNING -> CLOSE -> LOCKED, and every state has to
                // for a number no rib uses.
                var _jd  = point_direction(_qx1, _qy1, _qx2, _qy2) + 90;
                var _ds  = _ed2.door_s;
                var _dp2 = _ed2.door_p;
                var _df  = _ed2.door_f;
                var _lead = _ed2.door_lead;

                var _jl = (5 + _f * 10) * (_ed2.is_lane ? 1.3 : 1);
                var _ja = (0.26 + _f * 0.24) * (1 - _hush * 0.3);
                draw_set_color(merge_color(_edge, _warn, (_ds > 0) ? 0.75 : 0));
                draw_set_alpha(_ja);
                for (var _jj = 0; _jj < 2; _jj++) {
                    var _ju = (_jj == 0) ? 0.05 : 0.95;
                    var _jx = lerp(_qx1, _qx2, _ju);
                    var _jy = lerp(_qy1, _qy2, _ju);
                    draw_line_width(_jx - lengthdir_x(_jl, _jd), _jy - lengthdir_y(_jl, _jd),
                                    _jx + lengthdir_x(_jl, _jd), _jy + lengthdir_y(_jl, _jd), 2.4);
                }

                if (_ds == 0 || _ds == 1) {
                    // ---- the opening itself ------------------------------
                    var _oa = open_alpha * (0.34 + _f * 0.86) * (1 - _hush * 0.22)
                            * (_ed2.is_lane ? 1 : 0.74);
                    var _ol = _ed2.is_lane ? (1.25 + lane_guide_pulse * 0.5) : 1;
                    var _oc = _ed2.is_lane ? _cyans : _cyan;

                    if (_ds == 1) {
                        // ---- WARNING -------------------------------------
                        var _wf = ((_ed2.door_t mod 4) < 2) ? 1 : 0.35;
                        _oa *= 0.34;
                        _oc = merge_color(_oc, _warn, 0.7);

                        draw_set_color(merge_color(_warn, c_white, _wf * 0.4));
                        draw_set_alpha((0.34 + _wf * 0.45) * (0.4 + _f * 0.6));
                        draw_line_width(_qx1, _qy1, _qx2, _qy2, 2.2 + _wf * 1.6);

                        for (var _wl = 0; _wl < 2; _wl++) {
                            var _wu = (_wl == 0) ? 0.05 : 0.95;
                            var _wx = lerp(_qx1, _qx2, _wu);
                            var _wy = lerp(_qy1, _qy2, _wu);
                            draw_set_color(merge_color(_danger, c_white, _wf * 0.5));
                            draw_set_alpha(_wf * (0.45 + _f * 0.4));
                            draw_circle(_wx, _wy, 2.2 + _wf * 2.2, false);
                        }
                    }

                    if (_oa > 0.012) {
                        scr_honeycomb_band(_qx1, _qy1, _qx2, _qy2, 2.4, 7 + _f * 13,
                                           _oc, _oa * 0.30 * _ol, _oc, 0);

                        draw_set_color(_oc);
                        draw_set_alpha(min(0.70, _oa * _ol * 0.70));
                        draw_line_width(_qx1, _qy1, _qx2, _qy2, 1.6 + _ed2.is_lane * 1.0);

                        if (_ed2.is_lane && _f > 0.50 && _ds == 0) {
                            var _pf = frac(_now / 30 + _e2 * 0.11);
                            draw_set_color(c_white);
                            draw_set_alpha(_oa * 0.85);
                            draw_circle(lerp(_qx1, _qx2, _pf), lerp(_qy1, _qy2, _pf),
                                        2.2 + lane_guide_pulse * 1.6, false);
                        }
                    }
                }
                else {
                    // ---- CLOSING / LOCKED --------------------------------
                    var _sealed = (_ds == 3);
                    var _dv = _sealed ? (1 - power(_df, 3) * 0.055) : _dp2;
                    var _lha  = _hw * 1.32;

                    if (!_sealed || _df > 0.02) {
                        var _lipc = merge_color(_edge, _hot, clamp(_dv * 0.35 + _df, 0, 1));
                        draw_set_color(_lipc);
                        draw_set_alpha((0.26 + _dv * 0.20 + _df * 0.45) * (_sealed ? _df : 1));

                        for (var _dl2 = 0; _dl2 < 2; _dl2++) {
                            var _dlu = (_dl2 == 0) ? (0.02 + _dv * 0.48) : (0.98 - _dv * 0.48);
                            var _dlx = lerp(_qx1, _qx2, _dlu);
                            var _dly = lerp(_qy1, _qy2, _dlu);
                            draw_line_width(_dlx - lengthdir_x(_lha, _jd), _dly - lengthdir_y(_lha, _jd),
                                            _dlx + lengthdir_x(_lha, _jd), _dly + lengthdir_y(_lha, _jd), 2.2);
                        }
                    }

                    if (!_sealed || _df > 0.02) {
                        var _tf = _sealed ? _df : 1;
                        draw_set_color(merge_color(_edge, c_white, 0.12));
                        draw_set_alpha((0.26 + _df * 0.45) * _tf);
                        for (var _tl = 0; _tl < 2; _tl++) {
                            var _tsg = (_tl == 0) ? 1 : -1;
                            var _tu  = (_tl == 0) ? (0.02 + _dv * 0.48) : (0.98 - _dv * 0.48);
                            var _tx0 = lerp(_qx1, _qx2, _tu);
                            var _ty0 = lerp(_qy1, _qy2, _tu);
                            var _tdx = lengthdir_x(1, _jd), _tdy = lengthdir_y(1, _jd);
                            var _tex = (_qx2 - _qx1), _tey = (_qy2 - _qy1);
                            var _tel = max(0.001, sqrt(_tex * _tex + _tey * _tey));
                            _tex /= _tel; _tey /= _tel;
                            var _tth = 5 + _f * 4;

                            draw_primitive_begin(pr_linestrip);
                            for (var _tk = 0; _tk <= 6; _tk++) {
                                var _tp = (_tk / 6) * 2 - 1;
                                var _tj = ((_tk mod 2) == 0) ? 0 : _tth * _tsg;
                                draw_vertex(_tx0 + _tdx * _lha * _tp + _tex * _tj,
                                            _ty0 + _tdy * _lha * _tp + _tey * _tj);
                            }
                            draw_primitive_end();
                        }
                    }

                    if (_sealed) {
                        var _mx2 = (_qx1 + _qx2) * 0.5;
                        var _my2 = (_qy1 + _qy2) * 0.5;

                        draw_set_color(merge_color(_blood, _danger, 0.32 + _df * 0.6));
                        draw_set_alpha(0.22 + _df * 0.6);
                        draw_line_width(_mx2 - lengthdir_x(_lha, _jd), _my2 - lengthdir_y(_lha, _jd),
                                        _mx2 + lengthdir_x(_lha, _jd), _my2 + lengthdir_y(_lha, _jd), 2.0);

                        if (_df > 0.02) {
                            draw_set_color(c_white);
                            draw_set_alpha(_df * 0.75);
                            draw_line_width(_mx2 - lengthdir_x(_lha * 1.15, _jd),
                                            _my2 - lengthdir_y(_lha * 1.15, _jd),
                                            _mx2 + lengthdir_x(_lha * 1.15, _jd),
                                            _my2 + lengthdir_y(_lha * 1.15, _jd), 1.3);
                        }

                        var _lk = 0.55 + 0.45 * sin(_now * 0.14 + _e2 * 0.9);
                        draw_set_color(merge_color(_danger, _warn, _lk));
                        draw_set_alpha((_lead ? 0.72 : 0.44) * (0.35 + _f * 0.5) * (0.5 + _lk * 0.5));
                        draw_circle(_mx2, _my2, 2.0 + _lk * 1.1, false);
                    }
                }
            } else {
                // ---- A RIB ------------------------------------------------
                var _heat2 = _base_heat;
                var _espec = array_length(_ed2.specs);
                for (var _sk = 0; _sk < _espec; _sk++) {
                    var _spec_i = _ed2.specs[_sk];
                    if (_spec_i < spec_lo || _spec_i >= spec_hi) continue;
                    var _sp2 = bullet_specs[_spec_i];
                    if (!_sp2.live) continue;
                    _heat2 = max(_heat2, _sp2.ring_heat + _sp2.prox_heat * 0.6 + _sp2.ignite_flash);
                }
                _heat2 = clamp(_heat2, 0, 1.4);

                var _rc = merge_color(_danger, _ember, clamp(0.30 + _chase * 0.5, 0, 1));
                var _ra2 = (0.26 + _f * 0.26 + _heat2 * 0.34 + _chase * 0.20) * (1 - _hush * 0.30);

                draw_set_color(_rc);
                draw_set_alpha(_ra2 * 0.40);
                draw_line_width(_qx1, _qy1, _qx2, _qy2, _hw * 0.34 + _heat2 * 1.6);

                draw_set_color(merge_color(_ember, _hot, clamp(0.18 + _heat2 * 0.55, 0, 1)));
                draw_set_alpha(min(1, _ra2 * 0.80));
                draw_line_width(_qx1, _qy1, _qx2, _qy2, 0.9 + _f * 0.4 + _heat2 * 1.0);
            }
        }

        // -- the joints and the burn points ---------------------------------
        draw_set_circle_precision(8);

        for (var _i2 = spec_lo; _i2 < spec_hi; _i2++) {
            var _nd = bullet_specs[_i2];
            if (!_nd.live || _nd.draw_alpha <= 0.03) continue;
            if (_nd.honeycomb_depth < 0.02) continue;
            if (_nd.is_open && !_nd.hit_active) continue;

            var _nr = _hit_r * _nd.draw_scale;
            var _nh = clamp(_nd.ring_heat + _nd.ignite_flash + _nd.prox_heat * 0.7
                            + _nd.chase_heat * 0.5, 0, 1);
            var _na = clamp(_nd.draw_alpha, 0, 1) * (0.5 + _nh * 0.5) * (1 - _hush * 0.28);

            if (_nd.is_corner) {
                draw_set_color(merge_color(_edge, c_white, 0.15 + _nh * 0.3));
                draw_set_alpha(_na * 0.42);
                draw_circle(_nd.draw_x, _nd.draw_y, _nr * 2.3, true);
            }

            draw_set_color(merge_color(_danger, _ember, clamp(0.3 + _nd.chase_heat * 0.5, 0, 1)));
            draw_set_alpha(_na * 0.48);
            draw_circle(_nd.draw_x, _nd.draw_y, _nr, false);

            if (_nh > 0.30) {
                draw_set_color(merge_color(_warn, _hot, _nh));
                draw_set_alpha(min(1, _na * 0.85));
                draw_circle(_nd.draw_x, _nd.draw_y, _nr * 0.44, false);
            }

            if (_nd.ignite_flash > 0.02) {
                draw_set_color(c_white);
                draw_set_alpha(_nd.ignite_flash * 0.8);
                draw_circle(_nd.draw_x, _nd.draw_y, _nr * (1.4 + _nd.ignite_flash * 1.4), true);
            }
        }

        draw_set_circle_precision(24);

        // -- what the structure sheds ---------------------------------------
        if (array_length(duct_svents) > 0) scr_draw_vent_streams(duct_svents, 0, 0, 1);

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}


function scr_honeycomb_draw_glow(_cx, _cy, _sx, _sy) {
    if (!instance_exists(oHoneycombController)) exit;

    var _hcg = oHoneycombController;
    if (_hcg.hc_active_count <= 0) exit;

    // See [glow radius must scale with the object].
    var _blob_half = sprite_get_width(spr_glow_blob) * 0.5;
    var _hit_r = _hcg.hc_hit_radius;

    var _plug_cx = _hcg.center_x;
    var _plug_rin = max(1, _hcg.radius_base);
    var _plug_flow = _hcg.duct_flow;
    var _plug_face = _hcg._k_duct_axis_y + _plug_flow * _hcg.duct_gap;
    var _plug_bulge = 46 + _hcg.hc_coil * 46;

    var _k_hc_wall_r = 1.0, _k_hc_wall_g = 0.2, _k_hc_wall_b = 0.2;
    var _k_hc_door_r = 0.42, _k_hc_door_g = 0.9, _k_hc_door_b = 1.0;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_falloff, 1.0);

    // -- the burn points ---------------------------------------------------
    var _hot_pending = [];
    var _hot_n = 0;

    shader_set_uniform_f(global.u_glow_color, _k_hc_wall_r, _k_hc_wall_g, _k_hc_wall_b);
    for (var _i = _hcg.spec_lo; _i < _hcg.spec_hi; _i++) {
        var _sp = _hcg.bullet_specs[_i];
        if (!_sp.live || _sp.draw_alpha <= 0.04) continue;
        if (_sp.is_open && !_sp.hit_active) continue;

        var _hot2 = max(_sp.ignite_flash, _sp.ring_heat * 0.8);

        if (!_sp.blast_active) {
            if (_sp.honeycomb_depth < 0.10) continue;
            if (_sp.honeycomb_depth < 0.62 && _hot2 < 0.12 && _sp.prox_heat < 0.12
                && _sp.chase_heat < 0.28) continue;
            if (scr_duct_eaten(_sp.draw_x, _sp.draw_y, _plug_cx, _plug_rin,
                               _plug_face, _plug_bulge, _plug_flow)) continue;
        }

        var _gx = (_sp.draw_x - _cx) * _sx;
        var _gy = (_sp.draw_y - _cy) * _sy;
        var _beat_glow = 0.34 + _hcg.bass_flash * 0.26 * _sp.image_alpha
                              + _sp.ring_heat * 1.0
                              + _sp.prox_heat * 0.8
                              + _sp.chase_heat * 0.6
                              + _hcg.hc_heartbeat * 0.4;

        if (_sp.blast_active) _beat_glow += 1.3 * (1 - _sp.despawn_timer / max(1, _sp.despawn_duration));

        shader_set_uniform_f(global.u_glow_intensity, _beat_glow);

        var _rw = _hit_r * _sp.draw_scale
                * (_sp.blast_active ? 1.5 : (1.35 + _sp.ring_heat * 1.3 + _sp.ignite_flash * 1.9));
        var _gs = (_rw * _sx) / _blob_half;
        draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, _gs, _gs, 0, c_white,
                        min(1, max(_sp.image_alpha, _sp.draw_alpha)) * max(_sp.honeycomb_depth, 0.25));

        if (_hot2 >= 0.12) {
            _hot_pending[_hot_n] = _i;
            _hot_n++;
        }
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    for (var _i2 = 0; _i2 < _hot_n; _i2++) {
        var _sp2 = _hcg.bullet_specs[_hot_pending[_i2]];
        var _hot2b = max(_sp2.ignite_flash, _sp2.ring_heat * 0.8);

        shader_set_uniform_f(global.u_glow_intensity, _hot2b * 2.0);
        var _rw2 = _hit_r * _sp2.draw_scale * (1.2 + _hot2b * 1.8);
        var _gs2 = (_rw2 * _sx) / _blob_half;
        draw_sprite_ext(spr_glow_blob, 0, (_sp2.draw_x - _cx) * _sx, (_sp2.draw_y - _cy) * _sy,
                        _gs2, _gs2, 0, c_white, 1);
    }

    // -- the doorway lights --------------------------------------------------
    // with them. The only openings still advertising a route are the ones that
    shader_set_uniform_f(global.u_glow_color, _k_hc_door_r, _k_hc_door_g, _k_hc_door_b);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    for (var _i3 = _hcg.spec_lo; _i3 < _hcg.spec_hi; _i3++) {
        var _sp3 = _hcg.bullet_specs[_i3];
        if (!_sp3.live || !_sp3.is_open || _sp3.draw_alpha <= 0.02) continue;
        if (_sp3.honeycomb_depth < -0.05) continue;
        if (_sp3.edge_id == -1) continue;

        var _de3 = _hcg.edges[_sp3.edge_id];
        if (_de3.door_s >= 2) continue;                       // travelling or sealed
        var _open_left = (_de3.door_s == 1) ? 0.34 : 1;       // warned, about to go

        if (scr_duct_eaten(_sp3.draw_x, _sp3.draw_y, _plug_cx, _plug_rin,
                           _plug_face, _plug_bulge, _plug_flow)) continue;

        var _face3 = max(_sp3.honeycomb_depth, 0);
        var _door_i = ((_sp3.is_lane ? 0.86 : 0.46) * (0.5 + _face3 * 0.8)
                      + _hcg.lane_guide_pulse * (_sp3.is_lane ? 0.42 : 0.10)) * _open_left;
        shader_set_uniform_f(global.u_glow_intensity, _door_i);

        var _rw3 = _hit_r * (1.9 + _face3 * 2.0) * (_sp3.is_lane ? 1.25 : 1);
        var _gs3 = (_rw3 * _sx) / _blob_half;
        draw_sprite_ext(spr_glow_blob, 0, (_sp3.draw_x - _cx) * _sx, (_sp3.draw_y - _cy) * _sy,
                        _gs3, _gs3, 0, c_white, min(1, _sp3.draw_alpha * 1.8 * _open_left));
    }

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
}
