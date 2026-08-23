// ============================================================================
// THE DUCT (T5219-T5964)
// HONEYCOMB CHASE; DEBUG SEEKS MUST SEAT THE PLAYER IN-LANE.
// ============================================================================


/// @func scr_duct_beats_done(_time)
function scr_duct_beats_done(_time) {
    var _n = 0;
    for (var _i = 0; _i < array_length(bass_times); _i++) {
        if (bass_times[_i] >= _k_hc_t_detonate) break;
        if (_time >= bass_times[_i]) _n++;
    }
    return _n;
}


/// @func scr_duct_stretch_for(_time)
function scr_duct_stretch_for(_time) {
    var _s = 0;
    for (var _i = 0; _i < array_length(_k_duct_stretch_t); _i++) {
        if (_time >= _k_duct_stretch_t[_i]) _s = _i;
    }
    return _s;
}


/// @func scr_duct_gap_at_beat(_n)
function scr_duct_gap_at_beat(_n) {
    var _p = clamp(_n / max(1, bass_beat_total), 0, 1);
    return lerp(_k_duct_chase_start, _k_duct_chase_beat_end, power(_p, 1.15));
}


/// @func scr_duct_gap(_time)
function scr_duct_gap(_time) {
    if (_time >= _k_hc_t_detonate) {
        return lerp(_k_duct_chase_coil_end, _k_duct_chase_hit,
                    clamp((_time - _k_hc_t_detonate) / 9, 0, 1));
    }

    if (_time >= _k_hc_t_coil) {
        var _c = clamp((_time - _k_hc_t_coil) / max(1, _k_hc_t_detonate - _k_hc_t_coil), 0, 1);
        return lerp(_k_duct_chase_rest_end, _k_duct_chase_coil_end, power(_c, 1.35));
    }

    var _at_last = scr_duct_gap_at_beat(scr_duct_beats_done(_time));

    if (_time >= _k_duct_t_rest) {
        var _r = clamp((_time - _k_duct_t_rest) / max(1, _k_hc_t_coil - _k_duct_t_rest), 0, 1);
        return lerp(_at_last, _k_duct_chase_rest_end, power(_r, 0.85));
    }

    return _at_last;
}


/// @func scr_duct_hush(_time)
function scr_duct_hush(_time) {
    if (_time < _k_duct_t_rest) return 0;
    if (_time >= _k_hc_t_coil) return max(0, 1 - (_time - _k_hc_t_coil) / 12);
    return clamp((_time - _k_duct_t_rest) / max(1, _k_hc_t_coil - _k_duct_t_rest), 0, 1);
}


/// @func scr_duct_plug_y()
function scr_duct_plug_y() {
    return _k_duct_axis_y + duct_flow * duct_gap;
}


/// @func scr_duct_plug_h()
function scr_duct_plug_h() {
    return scr_duct_plug_y() - center_y;
}


/// @func scr_duct_light_reach()
function scr_duct_light_reach() {
    return lerp(_k_duct_light_reach_min, _k_duct_light_reach_max,
                clamp(bass_escalation * 0.85 + hc_coil * 0.4, 0, 1));
}


// ---------------------------------------------------------------------------
// THE CELL DOORS
// ---------------------------------------------------------------------------

/// @func scr_duct_cell_at(_px, _py)
function scr_duct_cell_at(_px, _py) {
    var _u  = clamp((_px - center_x) / max(1, radius), -1, 1);
    var _th = arccos(_u);                                   // 0..pi, front face
    var _fy = (_py - center_y - sin(_th) * depth_offset) - height_offset;

    var _fx = ((_th - cylinder_rotation) / (2 * pi)) * total_width;
    _fx = ((_fx mod total_width) + total_width) mod total_width;

    var _R  = hex_radius;
    var _aq = (0.5773503 * _fx - _fy / 3) / _R;
    var _ar = (_fy * 2 / 3) / _R;

    var _qx = _aq, _qz = _ar, _qy = -_aq - _ar;
    var _rx = round(_qx), _ry = round(_qy), _rz = round(_qz);
    var _dx = abs(_rx - _qx), _dy = abs(_ry - _qy), _dz = abs(_rz - _qz);
    if (_dx > _dy && _dx > _dz)  _rx = -_ry - _rz;
    else if (_dy > _dz)          _ry = -_rx - _rz;
    else                         _rz = -_rx - _ry;

    var _row = _rz;
    if (_row < 0 || _row >= rows) return -1;

    var _col = _rx + (_rz - (((_rz mod 2) + 2) mod 2)) / 2;
    _col = ((_col mod cols) + cols) mod cols;

    var _ci = _row * cols + _col;
    var _cl = cells[_ci];

    var _ddx = _fx - _cl.flat_x;
    _ddx -= total_width * round(_ddx / total_width);
    var _ddy = _fy - _cl.flat_y;
    var _grip = _k_duct_cell_grip * _R;
    if (_ddx * _ddx + _ddy * _ddy > _grip * _grip) return -1;

    return _ci;
}


/// @func scr_duct_edge_ends(_e)
function scr_duct_edge_ends(_e) {
    var _a1 = _e.ang_a + cylinder_rotation;
    var _a2 = _e.ang_b + cylinder_rotation;
    return {
        x1 : center_x + cos(_a1) * radius,
        y1 : center_y + (_e.ay + height_offset) + sin(_a1) * depth_offset,
        x2 : center_x + cos(_a2) * radius,
        y2 : center_y + (_e.by + height_offset) + sin(_a2) * depth_offset
    };
}


/// @func scr_duct_edge_dist_sq(_e, _px, _py)
function scr_duct_edge_dist_sq(_e, _px, _py) {
    var _p  = scr_duct_edge_ends(_e);
    var _vx = _p.x2 - _p.x1;
    var _vy = _p.y2 - _p.y1;
    var _l2 = _vx * _vx + _vy * _vy;
    var _tt = (_l2 <= 0.0001) ? 0
            : clamp(((_px - _p.x1) * _vx + (_py - _p.y1) * _vy) / _l2, 0, 1);
    var _dx = _px - (_p.x1 + _vx * _tt);
    var _dy = _py - (_p.y1 + _vy * _tt);
    return _dx * _dx + _dy * _dy;
}


/// @func scr_duct_seal_cell(_ci, _to)
function scr_duct_seal_cell(_ci, _to) {
    if (_ci < 0 || _ci >= array_length(cells)) exit;

    var _cl = cells[_ci];
    if (_cl.locking || _cl.lock >= 1) exit;

    var _base  = _ci * 6;
    var _armed = 0;

    for (var _d = 0; _d < 6; _d++) {
        var _eid = cell_eid[_base + _d];
        if (_eid < 0) continue;

        var _e = edges[_eid];
        if (!_e.open || _e.door_s != 0) continue;
        if (array_length(duct_doors) >= _k_duct_door_max) break;

        _e.door_s    = 1;
        _e.door_t    = 0;
        _e.door_p    = 0;
        _e.door_f    = 0;
        _e.door_lead = (_e.ca == _to || _e.cb == _to);
        array_push(duct_doors, _eid);
        _armed++;
    }

    _cl.locking = true;
    _cl.lock    = max(_cl.lock, 0.001);
    array_push(duct_locks, _ci);

    if (_armed > 0) duct_lock_flash = 1;
}


/// @func scr_duct_door_seat(_e)
function scr_duct_door_seat(_e) {
    _e.door_s = 3;
    _e.door_p = 1;
    _e.door_f = 1;
    _e.door_t = 0;

    duct_slam = 1;

    var _p   = scr_duct_edge_ends(_e);
    var _mx  = (_p.x1 + _p.x2) * 0.5;
    var _my  = (_p.y1 + _p.y2) * 0.5;
    var _dir = point_direction(_p.x1, _p.y1, _p.x2, _p.y2);

    for (var _v = 0; _v < 2; _v++) {
        scr_spawn_vent_stream(duct_svents, _mx, _my,
                              _dir + 90 + _v * 180 + random_range(-26, 26),
                              0.35 + bass_escalation * 0.35,
                              [ global.avoid_col_ember,
                                global.avoid_col_warning,
                                global.avoid_col_hot ],
                              _k_duct_svent_max);
    }

    if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 2.2 + bass_escalation * 2.2);
    }
    if (instance_exists(oAvoidanceController)) {
        oAvoidanceController.aberration_pulse =
            max(oAvoidanceController.aberration_pulse, 0.30 + bass_escalation * 0.20);
    }
}


/// @func scr_duct_doors_update()
function scr_duct_doors_update() {
    duct_slam       = max(0, duct_slam - 0.10);
    duct_lock_flash = max(0, duct_lock_flash - 0.075);

    var _has_p = instance_exists(oPlayer) && !instance_exists(oGameover);
    var _px = _has_p ? oPlayer.x : 0;
    var _py = _has_p ? oPlayer.y : 0;
    var _clear_sq = _k_duct_door_clear * _k_duct_door_clear;

    for (var _i = array_length(duct_doors) - 1; _i >= 0; _i--) {
        var _e = edges[duct_doors[_i]];

        if (_e.door_s == 1) {
            _e.door_t++;
            if (_e.door_t >= _k_duct_door_warn) {
                if (!_has_p || scr_duct_edge_dist_sq(_e, _px, _py) > _clear_sq) {
                    _e.door_s = 2;
                    _e.door_t = 0;
                } else {
                    _e.door_t = _k_duct_door_warn;
                }
            }
        }
        else if (_e.door_s == 2) {
            _e.door_t++;
            _e.door_p = power(clamp(_e.door_t / _k_duct_door_shut, 0, 1), 1.35);
            if (_e.door_t >= _k_duct_door_shut) scr_duct_door_seat(_e);
        }
        else if (_e.door_s == 3) {
            _e.door_f = max(0, _e.door_f - 0.085);
            if (_e.door_f <= 0) array_delete(duct_doors, _i, 1);
        }
        else {
            array_delete(duct_doors, _i, 1);
        }
    }

    for (var _l = array_length(duct_locks) - 1; _l >= 0; _l--) {
        var _lci = duct_locks[_l];
        var _cl  = cells[_lci];
        _cl.lock = min(1, _cl.lock + 1 / _k_duct_door_lock);
        if (_cl.lock >= 1) {
            _cl.locking = false;
            array_delete(duct_locks, _l, 1);
            array_push(duct_sealed, _lci);
        }
    }

    // ---- the back face releases ------------------------------------------
    for (var _s = array_length(duct_sealed) - 1; _s >= 0; _s--) {
        var _sci = duct_sealed[_s];
        var _sc  = cells[_sci];
        if (sin(_sc.angle + cylinder_rotation) > -0.25) continue;

        var _sbase = _sci * 6;
        for (var _sd = 0; _sd < 6; _sd++) {
            var _seid = cell_eid[_sbase + _sd];
            if (_seid < 0) continue;
            var _se = edges[_seid];
            if (_se.door_s != 3) continue;

            var _other = (_se.ca == _sci) ? _se.cb : _se.ca;
            if (_other >= 0 && cells[_other].lock > 0) continue;

            _se.door_s = 0;
            _se.door_p = 0;
            _se.door_t = 0;
            _se.door_f = 0;
        }

        _sc.lock    = 0;
        _sc.locking = false;
        array_delete(duct_sealed, _s, 1);
    }
}


/// @func scr_duct_cells_update()
function scr_duct_cells_update() {
    scr_duct_doors_update();

    if (hc_detonated || hc_phase == "materialize") exit;
    if (!instance_exists(oPlayer) || instance_exists(oGameover)) exit;

    var _c = scr_duct_cell_at(oPlayer.x, oPlayer.y);
    if (_c < 0 || _c == hc_cell_now) exit;

    if (hc_cell_now >= 0) {
        hc_cell_prev = hc_cell_now;
        scr_duct_seal_cell(hc_cell_now, _c);
        hc_cell_seen++;
    }
    hc_cell_now = _c;
}



/// @func scr_duct_beat(_index)
function scr_duct_beat(_index) {
    var _stretch = duct_stretch;
    var _esc     = bass_escalation;

    duct_lurch = 1;
    duct_lamp  = 1;

    var _new_stretch = false;
    for (var _st = 0; _st < array_length(_k_duct_stretch_t); _st++) {
        if (bass_times[max(0, _index - 1)] == _k_duct_stretch_t[_st]) _new_stretch = true;
    }

    if (_new_stretch) {
        hc_wall_heat = 1;
        duct_lamp_h  = _k_duct_axis_y - center_y;

        for (var _ns = -1; _ns <= 1; _ns += 2) {
            var _nx = center_x + _ns * (radius + _k_duct_casing_gap * 0.30);
            for (var _nv = 0; _nv < 5; _nv++) {
                scr_spawn_vent_stream(duct_vents, _nx,
                                      _k_duct_axis_y + random_range(-360, 360),
                                      (_ns > 0) ? 180 : 0, 0.85,
                                      [ global.avoid_col_cyan,
                                        global.avoid_col_warning,
                                        global.avoid_col_ember ],
                                      _k_duct_vent_max);
            }
        }

        scr_impact_pulse(0.26, 0.9, 0.22, center_x, _k_duct_axis_y);
        if (instance_exists(oCameraController)) {
            oCameraController.shake              = max(oCameraController.shake, 7 + _esc * 5);
            oCameraController.screen_flash_alpha  = max(oCameraController.screen_flash_alpha, 0.12);
        }
        return;
    }

    duct_lamp_h = _k_duct_axis_y - center_y;
    if (instance_exists(oPlayer)) duct_lamp_h = oPlayer.y - center_y;

    var _sides = (_stretch >= 2) ? 2 : 1;
    var _first = (_stretch >= 2) ? -1 : ((_index mod 2 == 0) ? -1 : 1);

    for (var _s = 0; _s < _sides; _s++) {
        var _side = (_s == 0) ? _first : -_first;
        var _vx   = center_x + _side * (radius + _k_duct_casing_gap * 0.30);
        for (var _v = 0; _v < 2 + _stretch; _v++) {
            var _vy = _k_duct_axis_y + random_range(-280, 280);
            scr_spawn_vent_stream(duct_vents, _vx, _vy,
                                  (_side > 0) ? 180 : 0,
                                  0.30 + _esc * 0.6,
                                  [ global.avoid_col_ember,
                                    global.avoid_col_warning,
                                    global.avoid_col_cyan ],
                                  _k_duct_vent_max);
        }
    }

    if (instance_exists(oPlayer)) {
        for (var _rv = 0; _rv < 2 + _stretch; _rv++) {
            var _rva = random(2 * pi);
            var _rvz = sin(_rva);
            if (_rvz < 0.3) continue;
            scr_spawn_vent_stream(duct_svents,
                                  center_x + cos(_rva) * radius,
                                  oPlayer.y + random_range(-200, 200),
                                  90 - 90 * duct_flow + random_range(-40, 40),
                                  0.35 + _esc * 0.55,
                                  [ global.avoid_col_cyan,
                                    global.avoid_col_warning,
                                    global.avoid_col_violet ],
                                  _k_duct_svent_max);
        }
    }

    if (_stretch >= 2) {
        var _py = scr_duct_plug_y();
        for (var _g = 0; _g < 3 + _stretch * 2; _g++) {
            scr_duct_push_grit(_py, _esc);
        }
    }
}


/// @func scr_duct_push_grit(_from_y, _hot)
function scr_duct_push_grit(_from_y, _hot) {
    if (array_length(duct_grit) >= _k_duct_grit_max) array_delete(duct_grit, 0, 1);

    array_push(duct_grit, {
        x    : center_x + random_range(-0.97, 0.97) * radius,
        y    : _from_y + duct_flow * random_range(-40, 90),
        vy   : -duct_flow * random_range(5.5, 15) * (0.6 + _hot),
        vx   : random_range(-1.4, 1.4),
        len  : random_range(16, 62) * (0.7 + _hot * 0.7),
        w    : random_range(1, 2.6),
        life : irandom_range(22, 46),
        life_max : 46,
        hot  : _hot,
        col  : choose(global.avoid_col_ember, global.avoid_col_warning, global.avoid_col_armor_edge)
    });
}


// ---------------------------------------------------------------------------
// Per-frame
// ---------------------------------------------------------------------------

/// @func scr_duct_update(_time)
function scr_duct_update(_time) {
    duct_stretch = scr_duct_stretch_for(_time);
    duct_hush    = scr_duct_hush(_time);
    duct_gap     = scr_duct_gap(_time);

    duct_light = clamp(0.20 + bass_escalation * 0.62 + hc_coil * 0.5
                            + duct_lurch * 0.28 - duct_hush * 0.30, 0, 1.4);

    duct_lurch = max(0, duct_lurch - 0.11);
    duct_lamp  = max(0, duct_lamp  - 0.055);


    var _seam_t0 = _k_hc_t_coil + 40;
    duct_seam = clamp((_time - _seam_t0) / max(1, _k_duct_seam_t - _seam_t0), 0, 1);
    if (_time >= _k_hc_t_detonate) duct_seam = max(0, 1 - (_time - _k_hc_t_detonate) / 20);

    duct_out = (_time >= _k_hc_t_detonate)
             ? clamp(1 - (_time - _k_hc_t_detonate) / 26, 0, 1) : 1;

    if (instance_exists(oAvoidanceController)) {
        oAvoidanceController.dna_veil = 1 - duct_out;
    }

    scr_update_vent_streams(duct_vents);
    scr_update_vent_streams(duct_svents);

    for (var _g = array_length(duct_grit) - 1; _g >= 0; _g--) {
        var _gr = duct_grit[_g];
        _gr.x += _gr.vx;
        _gr.y += _gr.vy;
        _gr.vy *= 0.985;
        _gr.life--;
        if (_gr.life <= 0) array_delete(duct_grit, _g, 1);
    }
}



/// @func scr_duct_seek(_hc, _target_t)
function scr_duct_seek(_hc, _target_t) {
    with (_hc) {
        var _tt = clamp(_target_t, _k_hc_t_spawn, _k_hc_t_detonate - 1);

        // -- beats ----------------------------------------------------------
        bass_index = 0;
        for (var _b = 0; _b < array_length(bass_times); _b++) {
            if (_tt < bass_times[_b]) break;
            bass_index = _b + 1;
        }
        bass_pulse_id    = bass_index;
        bass_escalation  = clamp((bass_index - 1) / max(1, bass_beat_total - 1), 0, 1);
        bass_flash       = 0;
        hc_wall_heat     = 0;
        hc_rotation_kick = 0;

        // -- the two integrators --------------------------------------------
        cylinder_rotation = home_rotation_offset;
        rotation_ease     = 0;
        scroll_ease       = 0;
        center_y          = _k_duct_axis_y;
        rotation_speed    = _k_hc_rotation_speed_base;
        hc_rotation_kick  = 0;

        var _bi = 0;
        for (var _f = _k_hc_t_spawn; _f < _tt; _f++) {
            if (_bi < array_length(bass_times) && _f >= bass_times[_bi]) {
                if (bass_times[_bi] < _k_hc_t_detonate) {
                    var _esc_seek = clamp(_bi / max(1, bass_beat_total - 1), 0, 1);
                    rotation_speed += _k_hc_rotation_speed_gain;
                    hc_rotation_kick = max(hc_rotation_kick,
                                           lerp(_k_hc_rotation_kick_min,
                                                _k_hc_rotation_kick_max,
                                                _esc_seek));
                }
                _bi++;
            }

            hc_rotation_kick *= 0.86;
            if (hc_rotation_kick < 0.0002) hc_rotation_kick = 0;

            if (_f < _k_hc_t_live) continue;

            rotation_ease = min(1, rotation_ease + 1 / _k_hc_rotation_ease_frames);
            scroll_ease   = min(1, scroll_ease   + 1 / _k_hc_scroll_ease_frames);
            cylinder_rotation += (rotation_speed + hc_rotation_kick) * rotation_ease;
            center_y += (move_dir == 1) ? scroll_ease : -scroll_ease;
        }

        // -- phase ----------------------------------------------------------
        if (_tt >= _k_hc_t_live) {
            hc_phase      = "travel";
            materialize_h = 100000;
            materialize_p = 1;

            for (var _s = 0; _s < spec_count; _s++) {
                bullet_specs[_s].seen         = true;
                bullet_specs[_s].ignited      = true;
                bullet_specs[_s].ignite_flash = 0;
            }
        } else {
            hc_phase      = "materialize";
            materialize_p = clamp((_tt - _k_hc_t_spawn) / max(1, _k_hc_t_live - _k_hc_t_spawn), 0, 1);
            materialize_h = lerp(home_height, home_height + 900, power(materialize_p, 0.85));
        }

        hc_detonated      = false;
        hc_detonate_flash = 0;
        hc_heartbeat      = 0;
        hc_heartbeat_phase = 0;

        if (_tt >= _k_hc_t_coil) {
            hc_phase = "coil";
            hc_coil  = power(clamp((_tt - _k_hc_t_coil) / (_k_hc_t_detonate - _k_hc_t_coil), 0, 1), 1.6);
            radius       = radius_base * lerp(1, 0.87, hc_coil);
            depth_offset = depth_offset_base * lerp(1, 2.0, hc_coil);
            open_alpha   = lerp(_k_duct_open_alpha, _k_duct_open_alpha_coil, hc_coil);
        } else {
            hc_coil      = 0;
            radius       = radius_base;
            depth_offset = depth_offset_base;
            open_alpha   = _k_duct_open_alpha;
        }

        hc_pulse_rings   = [];
        hc_scan_arcs     = [];
        hc_coil_arcs     = [];
        hc_shock_rings   = [];
        duct_vents       = [];
        duct_svents      = [];
        duct_grit        = [];
        lane_guide_pulse = 0;

        for (var _dd = 0; _dd < array_length(edges); _dd++) {
            var _de = edges[_dd];
            _de.door_s = 0;
            _de.door_p = 0;
            _de.door_t = 0;
            _de.door_f = 0;
        }
        for (var _dl = 0; _dl < array_length(cells); _dl++) {
            cells[_dl].lock    = 0;
            cells[_dl].locking = false;
        }
        duct_doors      = [];
        duct_locks      = [];
        duct_sealed     = [];
        duct_slam       = 0;
        duct_lock_flash = 0;
        hc_cell_now     = -1;
        hc_cell_prev    = -1;
        hc_cell_seen    = 0;

        scr_duct_update(_tt);

        for (var _s2 = spec_lo; _s2 < spec_hi; _s2++) {
            bullet_specs[_s2].live       = false;
            bullet_specs[_s2].hit_active = false;
            bullet_specs[_s2].draw_alpha = 0;
        }
        spec_lo = 0;
        spec_hi = 0;
        window_initialised = false;
        live_bullet_count  = 0;
        hc_active_count    = 0;
    }
}


/// @func scr_duct_seat_player(_hc, _target_t)
function scr_duct_seat_player(_hc, _target_t) {
    if (!instance_exists(oPlayer)) exit;

    var _px = 0;
    var _py = 0;

    with (_hc) {
        _px = _k_duct_axis_x;
        _py = _k_duct_axis_y + 25;

        if (_target_t >= _k_hc_t_live && array_length(lane_nodes) > 0) {
            var _best = -1;
            var _best_score = 1000000;

            for (var _i = 0; _i < array_length(lane_nodes); _i++) {
                var _ln = lane_nodes[_i];
                var _la = _ln.angle + cylinder_rotation;
                var _lz = sin(_la);
                if (_lz < 0.55) continue;

                var _ly = center_y + _ln.height + _lz * depth_offset;
                var _score = abs(_ly - _k_duct_axis_y) + (1 - _lz) * 260;
                if (_score < _best_score) { _best_score = _score; _best = _i; }
            }

            if (_best >= 0) {
                var _bn = lane_nodes[_best];
                var _ba = _bn.angle + cylinder_rotation;
                _px = center_x + cos(_ba) * radius;
                _py = center_y + _bn.height + sin(_ba) * depth_offset;
            }
        } else {
            _px = center_x;
            _py = center_y + home_height;
        }
    }

    with (oPlayer) {
        x = clamp(_px, 60, 740);
        y = clamp(_py, 40, 570);
        velocity.x = 0;
        velocity.y = 0;
    }

    with (_hc) {
        hc_cell_now  = scr_duct_cell_at(oPlayer.x, oPlayer.y);
        hc_cell_prev = -1;
    }
}
