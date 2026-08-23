// ============================================================================
// THE RISER - RENDERING
// DRAW_0 = MASS. BOLT_SURFACE = THIN HEAT.
// ============================================================================


#macro RISER_HEX_COS30 0.86602540



/// @func scr_riser_hole_half(_y)
function scr_riser_hole_half(_y) {
    if (_y > _k_riser_deck_y) {
        return max(0, _k_riser_half_deck * (1 - (_y - _k_riser_deck_y) / _k_riser_deck_reach));
    }
    if (_y < _k_riser_crown_y) return 0;
    return scr_riser_half(_y);
}


/// @func scr_riser_wall_x(_y, _side, _close)
function scr_riser_wall_x(_y, _side, _close) {
    var _far = _k_riser_cx + _side * _k_riser_far_x;
    var _on  = _k_riser_cx + _side * scr_riser_hole_half(_y);
    return lerp(_far, _on, _close);
}


function scr_riser_bar(_x1, _y1, _x2, _y2, _half, _c0, _a0, _c1, _a1) {
    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _px = lengthdir_x(_half, _d + 90);
    var _py = lengthdir_y(_half, _d + 90);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_x1 - _px, _y1 - _py, _c0, _a0);
    draw_vertex_color(_x2 - _px, _y2 - _py, _c0, _a0);
    draw_vertex_color(_x1 + _px, _y1 + _py, _c1, _a1);
    draw_vertex_color(_x2 + _px, _y2 + _py, _c1, _a1);
    draw_primitive_end();
}


function scr_riser_spill(_x, _y, _dir, _len, _half, _col, _gain) {
    if (_gain <= 0.004 || _len <= 1) return;

    var _ux = lengthdir_x(1, _dir),      _uy = lengthdir_y(1, _dir);
    var _vx = lengthdir_x(1, _dir + 90), _vy = lengthdir_y(1, _dir + 90);

    var _depth = [ 1.00, 0.42, 0.18 ];
    var _alpha = [ 0.15, 0.20, 0.30 ];
    var _white = [ 0.00, 0.35, 0.80 ];
    var _wide  = [ 1.00, 0.74, 0.48 ];

    for (var _p = 0; _p < 3; _p++) {
        var _d = _len * _depth[_p];
        var _h = _half * _wide[_p];
        var _c = merge_color(_col, c_white, _white[_p]);
        var _a = min(1, _alpha[_p] * _gain);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_x - _vx * _h, _y - _vy * _h, _c, _a);
        draw_vertex_color(_x + _vx * _h, _y + _vy * _h, _c, _a);
        draw_vertex_color(_x + _ux * _d - _vx * _h * 0.6, _y + _uy * _d - _vy * _h * 0.6, _c, 0);
        draw_vertex_color(_x + _ux * _d + _vx * _h * 0.6, _y + _uy * _d + _vy * _h * 0.6, _c, 0);
        draw_primitive_end();
    }
}


function scr_riser_seam(_x1, _y1, _x2, _y2, _half, _hot, _col, _alpha) {
    if (_alpha <= 0.004) return;

    var _d  = point_direction(_x1, _y1, _x2, _y2);
    var _px = lengthdir_x(1, _d + 90);
    var _py = lengthdir_y(1, _d + 90);

    var _sw = _half * _k_riser_seam_ratio;
    var _fr = _sw * 1.15;

    draw_set_color(c_red);
    draw_set_alpha(_alpha * (0.07 + _hot * 0.16));
    draw_line_width(_x1 - _px * _fr, _y1 - _py * _fr, _x2 - _px * _fr, _y2 - _py * _fr, 1.6);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_alpha * (0.07 + _hot * 0.16));
    draw_line_width(_x1 + _px * _fr, _y1 + _py * _fr, _x2 + _px * _fr, _y2 + _py * _fr, 1.6);

    draw_set_color(merge_color(_col, c_white, 0.18 + _hot * 0.34));
    draw_set_alpha(_alpha * (0.34 + _hot * 0.42));
    draw_line_width(_x1, _y1, _x2, _y2, _sw * 2);

    draw_set_color(c_white);
    draw_set_alpha(_alpha * (0.24 + _hot * 0.62));
    draw_line_width(_x1, _y1, _x2, _y2, max(1, _sw * 0.62));
}



/// @func scr_riser_draw_world()
function scr_riser_draw_world() {
    if (is_undefined(riser)) exit;

    var _R    = riser;
    var _fade = scr_riser_fade();
    if (_fade <= 0.004) exit;

    var _cx     = _k_riser_cx;
    var _close  = scr_riser_casing();
    var _flood  = scr_riser_flood_y();
    var _mouth  = scr_riser_mouth();
    var _hand   = scr_riser_handoff();

    var _armor  = global.avoid_col_armor_dark;
    var _armorm = global.avoid_col_armor_mid;
    var _edge   = global.avoid_col_armor_edge;
    var _danger = global.avoid_col_danger;
    var _warn   = global.avoid_col_warning;
    var _blood  = global.avoid_col_blood;
    var _ember  = global.avoid_col_ember;
    var _cyan   = global.avoid_col_cyan;
    var _cyans  = global.avoid_col_cyan_soft;

    var _cam_x = -400, _cam_y = -400, _cam_w = 1600, _cam_h = 1600;
    if (instance_exists(oCameraController) && oCameraController.current_cam_w > 1) {
        _cam_x = oCameraController.current_cam_x;
        _cam_y = oCameraController.current_cam_y;
        _cam_w = oCameraController.current_cam_w;
        _cam_h = oCameraController.current_cam_h;
    }
    var _cam_t = _cam_y - 40;
    var _cam_b = _cam_y + _cam_h + 40;

    if (_close > 0.004) {
        gpu_set_blendmode(bm_normal);

        var _plug_lo = _k_vault_cy - _k_riser_shell_out;
        var _plug_hi = _k_vault_cy + _k_riser_shell_out;
        var _rows = [
            _cam_t,
            _k_riser_crown_y - 0.01,
            _k_riser_crown_y,
            _plug_lo,
            _k_vault_cy,
            _plug_hi,
            _k_riser_deck_y,
            _k_riser_deck_y + _k_riser_deck_reach,
            _cam_b
        ];
        var _nrows = array_length(_rows);
        var _mass  = _fade;

        for (var _s = -1; _s <= 1; _s += 2) {
            var _far = _cam_x + ((_s < 0) ? -60 : _cam_w + 60);

            draw_primitive_begin(pr_trianglestrip);
            for (var _r = 0; _r < _nrows; _r++) {
                var _ry = _rows[_r];
                var _wx = scr_riser_wall_x(_ry, _s, _close);
                draw_vertex_color(_far, _ry, _armorm, _mass);
                draw_vertex_color(_wx,  _ry, merge_color(_armor, c_black, 0.6), _mass);
            }
            draw_primitive_end();
        }

        var _crown = _k_riser_crown_y;

        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx - _k_riser_crown_half, _crown, c_black, _fade * 0.92 * _close);
        draw_vertex_color(_cx + _k_riser_crown_half, _crown, c_black, _fade * 0.92 * _close);
        draw_vertex_color(_cx - _k_riser_flue_top, _cam_t, c_black, _fade * 0.55 * _close);
        draw_vertex_color(_cx + _k_riser_flue_top, _cam_t, c_black, _fade * 0.55 * _close);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);
        draw_set_color(_edge);
        draw_set_alpha(_fade * 0.14 * _close);
        for (var _fs = -1; _fs <= 1; _fs += 2) {
            draw_line_width(_cx + _fs * _k_riser_crown_half, _crown,
                            _cx + _fs * _k_riser_flue_top, _cam_t, 1.6);
        }

        var _flue_n = max(2, ceil((_crown - _cam_t) / _k_riser_flue_rib));
        for (var _fr = 1; _fr < _flue_n; _fr++) {
            var _fu = _fr / _flue_n;
            var _fy = lerp(_crown, _cam_t, _fu);
            var _fw = lerp(_k_riser_crown_half, _k_riser_flue_top, _fu);
            draw_set_alpha(_fade * 0.09 * (1 - _fu * 0.55) * _close);
            draw_line_width(_cx - _fw, _fy, _cx + _fw, _fy, 1.4);
        }

        var _vent = scr_riser_door();
        if (_vent > 0.02) {
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_cx - _k_riser_crown_half, _crown, _cyan, _fade * _vent * 0.20);
            draw_vertex_color(_cx + _k_riser_crown_half, _crown, _cyan, _fade * _vent * 0.20);
            draw_vertex_color(_cx - _k_riser_flue_top, _cam_t, _cyan, 0);
            draw_vertex_color(_cx + _k_riser_flue_top, _cam_t, _cyan, 0);
            draw_primitive_end();
        }

        gpu_set_blendmode(bm_add);

        var _seam_y = floor(_cam_t / _k_riser_panel_gap) * _k_riser_panel_gap;
        while (_seam_y < _cam_b) {
            var _lw = scr_riser_wall_x(_seam_y, -1, _close);
            var _rw = scr_riser_wall_x(_seam_y,  1, _close);

            draw_set_color(_edge);
            draw_set_alpha(_fade * 0.11);
            draw_line_width(_cam_x - 40, _seam_y, _lw - 6, _seam_y, 1);
            draw_line_width(_rw + 6, _seam_y, _cam_x + _cam_w + 40, _seam_y, 1);

            draw_set_alpha(_fade * 0.17);
            for (var _rv = 0; _rv < 5; _rv++) {
                var _lx = lerp(_cam_x + 20, _lw - 22, (_rv + 0.5) / 5);
                var _rx2 = lerp(_rw + 22, _cam_x + _cam_w - 20, (_rv + 0.5) / 5);
                draw_line_width(_lx, _seam_y - 3, _lx, _seam_y + 3, 1);
                draw_line_width(_rx2, _seam_y - 3, _rx2, _seam_y + 3, 1);
            }

            _seam_y += _k_riser_panel_gap;
        }

        for (var _pi = -1; _pi <= 1; _pi += 2) {
            var _px2 = _cx + _pi * _k_riser_conduit_x;
            var _pw2 = _k_riser_conduit_w;

            gpu_set_blendmode(bm_normal);
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_px2 - _pw2, _cam_t, _armor, _fade * _close);
            draw_vertex_color(_px2 - _pw2, _k_riser_deck_y + 10, _armor, _fade * _close);
            draw_vertex_color(_px2 + _pw2, _cam_t, _armorm, _fade * _close);
            draw_vertex_color(_px2 + _pw2, _k_riser_deck_y + 10, _armorm, _fade * _close);
            draw_primitive_end();

            gpu_set_blendmode(bm_add);

            draw_set_color(_edge);
            draw_set_alpha(_fade * 0.13 * _close);
            draw_line_width(_px2 + _pw2, _cam_t, _px2 + _pw2, _k_riser_deck_y + 10, 1.4);

            for (var _jc = _cam_t; _jc < _k_riser_deck_y; _jc += _k_riser_conduit_j) {
                draw_set_color(_edge);
                draw_set_alpha(_fade * 0.16 * _close);
                draw_line_width(_px2 - _pw2 - 3, _jc, _px2 + _pw2 + 3, _jc, 3);
                draw_set_alpha(_fade * 0.09 * _close);
                draw_line_width(_px2 - _pw2 - 3, _jc + 5, _px2 + _pw2 + 3, _jc + 5, 1.2);
            }

            var _heat = clamp(_R.slam * 0.5 + _R.beat_flash * 0.4 + 0.18, 0, 1);
            draw_set_color(merge_color(_blood, _ember, _heat));
            draw_set_alpha(_fade * (0.10 + _heat * 0.16) * _close);
            draw_line_width(_px2, max(_cam_t, _k_vault_cy), _px2, _k_riser_deck_y + 10, 3);

            draw_set_color(_edge);
            draw_set_alpha(_fade * 0.14 * _close);
            draw_line_width(_px2 - _pw2, _k_riser_deck_y + 10,
                            _cx + _pi * _k_riser_half_deck, _k_riser_deck_y + 26, 2.4);
        }

        var _chev_top   = _k_riser_top_y - 30;
        var _chev_bot   = _k_riser_deck_y + 20;
        var _chev_n     = ceil((_chev_bot - _chev_top) / _k_riser_chev_gap) + 1;
        var _chev_phase = (floor(t / _k_riser_chev_rate) mod 4) * (_k_riser_chev_gap * 0.25);

        for (var _c = 0; _c < _chev_n; _c++) {
            var _cy2 = _chev_bot - _chev_phase - _c * _k_riser_chev_gap;
            if (_cy2 < _chev_top || _cy2 > _chev_bot) continue;

            var _fadeband = clamp((_cy2 - _chev_top) / 70, 0, 1);
            var _ca = _fade * _close * (0.10 + _R.beat_flash * 0.22) * _fadeband;
            if (_ca <= 0.006) continue;

            draw_set_color(merge_color(_warn, c_white, _R.beat_flash * 0.4));
            draw_set_alpha(_ca);

            for (var _s2 = -1; _s2 <= 1; _s2 += 2) {
                var _wx2 = scr_riser_wall_x(_cy2, _s2, _close);
                var _o1  = _wx2 + _s2 * _k_riser_chev_off;
                var _o2  = _wx2 + _s2 * (_k_riser_chev_off + _k_riser_chev_w);
                draw_line_width(_o1, _cy2, _o2, _cy2 - _k_riser_chev_h, 2);
                draw_line_width(_o2, _cy2 - _k_riser_chev_h, _o1, _cy2 - _k_riser_chev_h * 2, 2);
            }
        }

        gpu_set_blendmode(bm_normal);
        for (var _s3 = -1; _s3 <= 1; _s3 += 2) {
            draw_primitive_begin(pr_trianglestrip);
            for (var _r2 = 2; _r2 <= 7; _r2++) {
                var _ry2 = _rows[_r2];
                var _wx3 = scr_riser_wall_x(_ry2, _s3, _close);
                var _in  = _wx3 - _s3 * min(_k_riser_recess, scr_riser_hole_half(_ry2) * 0.85);
                draw_vertex_color(_wx3, _ry2, c_black, _fade * _k_riser_recess_a * _close);
                draw_vertex_color(_in,  _ry2, c_black, 0);
            }
            draw_primitive_end();
        }
    }

    if (t >= _k_riser_t_deck && _flood < _k_riser_deck_y + _k_riser_deck_reach) {
        gpu_set_blendmode(bm_normal);

        var _fn   = _k_riser_surf_n;
        var _amp  = _k_riser_surf_amp * (1 + _R.slam * 1.1);
        var _base = _k_riser_deck_y + _k_riser_deck_reach;
        var _boil = t * 0.32;

        var _sx = array_create(_fn + 1, 0);
        var _sy = array_create(_fn + 1, 0);
        var _fhalf = scr_riser_half(_flood);

        for (var _i = 0; _i <= _fn; _i++) {
            var _u = _i / _fn;
            var _px2 = _cx + lerp(-_fhalf, _fhalf, _u);
            var _off = _R.surf[min(_i, array_length(_R.surf) - 1)] * _amp
                     + sin(_boil + _i * 1.7) * (2.2 + _R.slam * 3);
            var _pin = sin(_u * pi);
            _sx[_i] = _px2;
            _sy[_i] = _flood + _off * _pin;
        }

        var _hot_col  = merge_color(global.avoid_col_hot, c_white, 0.25);
        var _mid_col  = _ember;
        var _body_col = merge_color(_ember, _blood, 0.55);
        var _deep_col = merge_color(_blood, c_black, 0.62);

        draw_primitive_begin(pr_trianglestrip);
        for (var _i2 = 0; _i2 <= _fn; _i2++) {
            var _u2 = _i2 / _fn;
            draw_vertex_color(_sx[_i2], _sy[_i2], _body_col, _fade * 0.95);
            draw_vertex_color(_cx + lerp(-_k_riser_half_deck, _k_riser_half_deck, _u2),
                              _k_riser_deck_y, _deep_col, _fade);
        }
        draw_primitive_end();

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx - _k_riser_half_deck, _k_riser_deck_y, _deep_col, _fade);
        draw_vertex_color(_cx + _k_riser_half_deck, _k_riser_deck_y, _deep_col, _fade);
        draw_vertex_color(_cx, _base, c_black, _fade);
        draw_vertex_color(_cx, _base, c_black, _fade);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_ember, _blood, 0.3));
        for (var _cv2 = 0; _cv2 < 7; _cv2++) {
            var _cu = (_cv2 + 0.5) / 7;
            var _cvx = _cx + lerp(-_fhalf, _fhalf, _cu);
            var _cvp = frac(t / 90 + _cv2 * 0.37);
            var _cvy = lerp(_flood + 12, _k_riser_deck_y, _cvp);
            draw_set_alpha(_fade * (1 - _cvp) * 0.16);
            draw_line_width(_cvx, _cvy, _cvx + sin(t * 0.05 + _cv2) * 9, _cvy + 40, 3);
        }

        draw_primitive_begin(pr_trianglestrip);
        for (var _i3 = 0; _i3 <= _fn; _i3++) {
            draw_vertex_color(_sx[_i3], _sy[_i3], _hot_col, _fade * 0.42);
            draw_vertex_color(_sx[_i3], _sy[_i3] + _k_riser_flood_band, _mid_col, 0);
        }
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        var _crest_a = _fade * (0.36 + _R.slam * 0.40);
        for (var _i4 = 0; _i4 < _fn; _i4++) {
            draw_set_color(c_red);
            draw_set_alpha(_crest_a * 0.22);
            draw_line_width(_sx[_i4], _sy[_i4] - 3, _sx[_i4 + 1], _sy[_i4 + 1] - 3, 2);
            draw_set_color(_cyan);
            draw_set_alpha(_crest_a * 0.22);
            draw_line_width(_sx[_i4], _sy[_i4] + 3, _sx[_i4 + 1], _sy[_i4 + 1] + 3, 2);

            draw_set_color(merge_color(_ember, c_white, 0.4 + _R.slam * 0.4));
            draw_set_alpha(_crest_a * 0.6);
            draw_line_width(_sx[_i4], _sy[_i4], _sx[_i4 + 1], _sy[_i4 + 1], 4);
            draw_set_color(c_white);
            draw_set_alpha(_crest_a * (0.42 + _R.slam * 0.40));
            draw_line_width(_sx[_i4], _sy[_i4], _sx[_i4 + 1], _sy[_i4 + 1], 1.2);
        }

        if (_R.slam > 0.02) {
            for (var _s4 = -1; _s4 <= 1; _s4 += 2) {
                scr_riser_spill(_cx + _s4 * _fhalf, _flood, 90 + _s4 * 90,
                                _fhalf * 0.7, 22, _ember, _R.slam * _fade);
            }
        }

        var _glow_top = max(_k_riser_top_y, _flood - _k_riser_flood_lift);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx - _fhalf, _flood, _ember, _fade * 0.10);
        draw_vertex_color(_cx + _fhalf, _flood, _ember, _fade * 0.10);
        draw_vertex_color(_cx - scr_riser_half(_glow_top), _glow_top, _ember, 0);
        draw_vertex_color(_cx + scr_riser_half(_glow_top), _glow_top, _ember, 0);
        draw_primitive_end();
    }

    if (t >= _k_riser_t_deck && _flood > _k_riser_deck_y - 2) {
        var _dh = _k_riser_half_deck;

        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx - _dh, _k_riser_deck_y, _armorm, _fade);
        draw_vertex_color(_cx + _dh, _k_riser_deck_y, _armorm, _fade);
        draw_vertex_color(_cx - _dh, _k_riser_deck_y + 16, _armor, _fade);
        draw_vertex_color(_cx + _dh, _k_riser_deck_y + 16, _armor, _fade);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        draw_set_color(merge_color(_edge, c_white, 0.2 + _R.land * 0.5));
        draw_set_alpha(_fade * (0.32 + _R.land * 0.5));
        draw_line_width(_cx - _dh, _k_riser_deck_y, _cx + _dh, _k_riser_deck_y, 2.2);

        draw_set_color(_edge);
        draw_set_alpha(_fade * 0.20);
        for (var _tk = 1; _tk < 12; _tk++) {
            var _tx = lerp(_cx - _dh, _cx + _dh, _tk / 12);
            draw_line_width(_tx, _k_riser_deck_y, _tx, _k_riser_deck_y + 6, 1.2);
        }

        var _under = clamp(1 - (_flood - _k_riser_deck_y) / 26, 0, 1);
        if (_under > 0.01) {
            for (var _gr = 0; _gr < 7; _gr++) {
                var _gx = lerp(_cx - _dh * 0.86, _cx + _dh * 0.86, _gr / 6);
                var _gf = 0.55 + 0.45 * sin(t * 0.11 + _gr * 1.7);
                draw_set_color(merge_color(_ember, global.avoid_col_hot, _gf * 0.4));
                draw_set_alpha(_fade * _under * _gf * 0.42);
                draw_line_width(_gx - 9, _k_riser_deck_y + 3, _gx + 9, _k_riser_deck_y + 3, 4);
                draw_set_color(c_white);
                draw_set_alpha(_fade * _under * _gf * 0.22);
                draw_line_width(_gx - 6, _k_riser_deck_y + 3, _gx + 6, _k_riser_deck_y + 3, 1.2);
            }
        }

        if (_R.land > 0.01) {
            draw_set_color(merge_color(_ember, c_white, _R.land * 0.6));
            draw_set_alpha(_fade * _R.land * 0.7);
            draw_line_width(_cx - _dh * 0.55, _k_riser_deck_y, _cx + _dh * 0.55, _k_riser_deck_y, 5);
            scr_riser_spill(_cx, _k_riser_deck_y, 270, 90 * _R.land, _dh * 0.5, _ember, _R.land * _fade);
        }
    }

    // ====================================================================
    // ====================================================================
    for (var _p2 = 0; _p2 < array_length(_R.pending); _p2++) {
        var _pd = _R.pending[_p2];
        var _coil = _pd.coil;
        if (_coil <= 0.02) continue;

        var _th   = _k_riser_arm_th;
        var _hot2 = _coil * _coil;
        var _dir  = (_pd.side < 0) ? 0 : 180;
        var _len  = abs(_pd.tip - _pd.rx);

        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_pd.rx,  _pd.y - _th, c_black, _fade * (0.30 + _coil * 0.34));
        draw_vertex_color(_pd.tip, _pd.y - _th, c_black, _fade * (0.10 + _coil * 0.24));
        draw_vertex_color(_pd.rx,  _pd.y + _th, c_black, _fade * (0.30 + _coil * 0.34));
        draw_vertex_color(_pd.tip, _pd.y + _th, c_black, _fade * (0.10 + _coil * 0.24));
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        scr_riser_spill(_pd.rx, _pd.y, _dir, _len * (0.5 + _coil * 0.5),
                        _th * 1.15, _pd.jam ? _ember : _warn, _coil * _fade);

        if (!_pd.jam) {
            draw_set_color(merge_color(_warn, c_white, _hot2 * 0.5));
            draw_set_alpha(_fade * (0.04 + _hot2 * 0.11));
            draw_line_width(_pd.rx, _pd.y, _pd.tip, _pd.y, _th * 1.7);
            scr_riser_seam(_pd.rx, _pd.y, _pd.tip, _pd.y, _th, _hot2 * 0.55, _warn,
                           _fade * (0.10 + _hot2 * 0.28));
        }

        // Eruption's heavy beats do it.
        scr_draw_lock_bracket(_pd.rx, _pd.y - _th, _pd.tip, _pd.y + _th,
                              _pd.jam ? _ember : _warn, _coil, _fade,
                              _k_riser_tick, true, 4, 0,
                              0.38 + 0.24 * sin(current_time * 0.018),
                              _cyan);

        var _gt = current_time * 0.001;
        var _tn = 4 + floor(_coil * 12);
        draw_set_color(c_white);
        for (var _f = 0; _f < _tn; _f++) {
            var _ff = frac(_f * 0.61803 + 0.137);
            var _fx = lerp(_pd.rx, _pd.tip, _ff);
            var _flick = 0.4 + 0.6 * frac(sin(_ff * 12.9898 + _gt * 40) * 43758.5453);
            var _fh = 5 + frac(sin(_ff * 7.7 + _gt * 33) * 43758.5453) * 9;
            draw_set_alpha(_fade * _coil * _flick * 0.55);
            draw_line_width(_fx, _pd.y - _th - 2, _fx, _pd.y - _th - 2 - _fh, 1.4);
            draw_line_width(_fx, _pd.y + _th + 2, _fx, _pd.y + _th + 2 + _fh, 1.4);
        }
    }

    // ====================================================================
    // ====================================================================
    if (_hand < 0.999) {
        var _plug_a = _fade * (1 - _hand);
        var _vc = _k_riser_vault_circum;
        var _pc = _k_riser_plug_circum;
        var _mark = scr_riser_door_mark();
        var _open = scr_riser_door();
        var _lit  = clamp((t - _k_riser_t_door_open) / 12, 0, 1);

        var _shut_a = _plug_a * (1 - _lit);

        gpu_set_blendmode(bm_normal);
        scr_vault_hex_band(_cx, _k_vault_cy, 0, _vc, _k_vault_hex_rot,
                           _armorm, _shut_a,
                           merge_color(_armor, c_black, 0.35), _shut_a);

        if (_shut_a > 0.01) {
            gpu_set_blendmode(bm_add);

            draw_set_color(_edge);
            for (var _ib = 1; _ib <= 3; _ib++) {
                draw_set_alpha(_shut_a * 0.07);
                scr_vault_hex_outline(_cx, _k_vault_cy, _vc * (_ib / 4),
                                      _k_vault_hex_rot, 1.2);
            }
            draw_set_alpha(_shut_a * 0.06);
            for (var _wb = 0; _wb < 6; _wb++) {
                var _wa = _k_vault_hex_rot + _wb * 60;
                draw_line_width(_cx, _k_vault_cy,
                                _cx + lengthdir_x(_vc * 0.94, _wa),
                                _k_vault_cy + lengthdir_y(_vc * 0.94, _wa), 1.2);
            }

            draw_set_color(merge_color(_edge, _danger, 0.4));
            draw_set_alpha(_shut_a * 0.26);
            draw_circle(_cx, _k_vault_cy, 13, true);
            draw_set_alpha(_shut_a * 0.16);
            draw_circle(_cx, _k_vault_cy, 7, false);
        }

        var _gap_u = _k_riser_door_half * 2 / (_k_vault_wall_in * 2 * 0.5774);

        for (var _e = 0; _e < 6; _e++) {
            var _av = _k_vault_hex_rot + _e * 60;
            var _bv = _k_vault_hex_rot + (_e + 1) * 60;
            var _n  = _k_vault_hex_rot + 30 + _e * 60;
            var _is_door = (_e == _R.door);

            var _axi = _cx + lengthdir_x(_vc, _av), _ayi = _k_vault_cy + lengthdir_y(_vc, _av);
            var _bxi = _cx + lengthdir_x(_vc, _bv), _byi = _k_vault_cy + lengthdir_y(_vc, _bv);
            var _axo = _cx + lengthdir_x(_pc, _av), _ayo = _k_vault_cy + lengthdir_y(_pc, _av);
            var _bxo = _cx + lengthdir_x(_pc, _bv), _byo = _k_vault_cy + lengthdir_y(_pc, _bv);

            var _shut = _is_door ? (1 - _gap_u * _open) : 1;

            for (var _h = 0; _h < 2; _h++) {
                var _u0 = (_h == 0) ? 0 : 1;
                var _u1 = (_h == 0) ? (_shut * 0.5) : (1 - _shut * 0.5);
                if (abs(_u1 - _u0) < 0.004) continue;

                gpu_set_blendmode(bm_normal);
                draw_primitive_begin(pr_trianglestrip);
                draw_vertex_color(lerp(_axi, _bxi, _u0), lerp(_ayi, _byi, _u0), _armorm, _plug_a);
                draw_vertex_color(lerp(_axo, _bxo, _u0), lerp(_ayo, _byo, _u0), _armor, _plug_a);
                draw_vertex_color(lerp(_axi, _bxi, _u1), lerp(_ayi, _byi, _u1), _armorm, _plug_a);
                draw_vertex_color(lerp(_axo, _bxo, _u1), lerp(_ayo, _byo, _u1), _armor, _plug_a);
                draw_primitive_end();

                gpu_set_blendmode(bm_add);

                draw_set_color(merge_color(_edge, _cyans, _lit * 0.7));
                draw_set_alpha(_plug_a * (0.24 + _lit * 0.30));
                draw_line_width(lerp(_axi, _bxi, _u0), lerp(_ayi, _byi, _u0),
                                lerp(_axi, _bxi, _u1), lerp(_ayi, _byi, _u1), 2);

                draw_set_color(_danger);
                draw_set_alpha(_plug_a * 0.16);
                draw_line_width(lerp(_axo, _bxo, _u0), lerp(_ayo, _byo, _u0),
                                lerp(_axo, _bxo, _u1), lerp(_ayo, _byo, _u1), 2.4);

                draw_set_color(_edge);
                draw_set_alpha(_plug_a * 0.10);
                for (var _rb = 0; _rb <= 4; _rb++) {
                    var _ru = _u0 + (_u1 - _u0) * (_rb / 4);
                    draw_line_width(lerp(_axi, _bxi, _ru), lerp(_ayi, _byi, _ru),
                                    lerp(_axo, _bxo, _ru), lerp(_ayo, _byo, _ru), 1);
                }
            }

            if (_is_door && _mark > 0.02) {
                var _mid = (_k_riser_shell_in + _k_riser_shell_out) * 0.5;
                var _mx  = _cx + lengthdir_x(_mid, _n);
                var _my  = _k_vault_cy + lengthdir_y(_mid, _n);
                var _tan = _n + 90;
                var _hw  = _k_riser_door_half;
                var _hh  = (_k_riser_shell_out - _k_riser_shell_in) * 0.5 + 4;

                gpu_set_blendmode(bm_normal);
                draw_primitive_begin(pr_trianglestrip);
                for (var _s4 = -1; _s4 <= 1; _s4 += 2) {
                    draw_vertex_color(_mx + lengthdir_x(_hw * _s4, _tan) - lengthdir_x(_hh, _n),
                                      _my + lengthdir_y(_hw * _s4, _tan) - lengthdir_y(_hh, _n),
                                      c_black, _plug_a * (0.35 + _mark * 0.5));
                    draw_vertex_color(_mx + lengthdir_x(_hw * _s4, _tan) + lengthdir_x(_hh, _n),
                                      _my + lengthdir_y(_hw * _s4, _tan) + lengthdir_y(_hh, _n),
                                      c_black, _plug_a * (0.35 + _mark * 0.5));
                }
                draw_primitive_end();

                gpu_set_blendmode(bm_add);

                scr_riser_spill(_mx, _my, _n, 54 + _open * 110, _hw * 1.15,
                                merge_color(_warn, _cyan, _open),
                                (0.55 + _mark * 0.85 + _open * 0.7) * _fade);

                var _cv = (floor(t / _k_riser_chev_rate) mod 3);
                draw_set_color(merge_color(_warn, _cyans, _open));
                draw_set_alpha(_fade * (0.20 + _mark * 0.35));
                for (var _ci = 0; _ci < 3; _ci++) {
                    var _cd = 30 + ((_ci + _cv) mod 3) * 26;
                    var _cxx = _mx + lengthdir_x(_cd, _n);
                    var _cyy = _my + lengthdir_y(_cd, _n);
                    draw_line_width(_cxx + lengthdir_x(_hw * 0.6, _tan),
                                    _cyy + lengthdir_y(_hw * 0.6, _tan),
                                    _cxx - lengthdir_x(12, _n),
                                    _cyy - lengthdir_y(12, _n), 2);
                    draw_line_width(_cxx - lengthdir_x(_hw * 0.6, _tan),
                                    _cyy - lengthdir_y(_hw * 0.6, _tan),
                                    _cxx - lengthdir_x(12, _n),
                                    _cyy - lengthdir_y(12, _n), 2);
                }

                // Red frame while it is shut, cyan jambs once it is not - the
                scr_draw_lock_bracket(_mx - lengthdir_x(_hw, _tan) - lengthdir_x(_hh, _n),
                                      _my - lengthdir_y(_hw, _tan) - lengthdir_y(_hh, _n),
                                      _mx + lengthdir_x(_hw, _tan) + lengthdir_x(_hh, _n),
                                      _my + lengthdir_y(_hw, _tan) + lengthdir_y(_hh, _n),
                                      merge_color(_warn, _cyan, _open),
                                      max(_mark, _open), _fade,
                                      _k_riser_tick, false, 5, _n + 90,
                                      0.40 + 0.24 * sin(current_time * 0.018),
                                      _cyan);

                for (var _jm = -1; _jm <= 1; _jm += 2) {
                    draw_set_color(merge_color(_warn, _cyans, _open));
                    draw_set_alpha(_fade * (0.28 + _open * 0.42));
                    draw_line_width(_mx + lengthdir_x(_hw * _jm, _tan) - lengthdir_x(_hh, _n),
                                    _my + lengthdir_y(_hw * _jm, _tan) - lengthdir_y(_hh, _n),
                                    _mx + lengthdir_x(_hw * _jm, _tan) + lengthdir_x(_hh, _n),
                                    _my + lengthdir_y(_hw * _jm, _tan) + lengthdir_y(_hh, _n), 2.4);
                }
            }
        }

        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_edge, _cyans, _lit * 0.6));
        draw_set_alpha(_plug_a * (0.16 + _lit * 0.2));
        scr_vault_hex_outline(_cx, _k_vault_cy, _pc, _k_vault_hex_rot, 1.6);

        for (var _v2 = 0; _v2 < 6; _v2++) {
            var _va = _k_vault_hex_rot + _v2 * 60;
            var _vx = _cx + lengthdir_x(_pc, _va);
            var _vy = _k_vault_cy + lengthdir_y(_pc, _va);
            draw_set_color(merge_color(_edge, c_white, 0.3));
            draw_set_alpha(_plug_a * 0.30);
            draw_circle(_vx, _vy, 3.2, false);
        }
    }

    for (var _d2 = 0; _d2 < array_length(_R.debris); _d2++) {
        var _db = _R.debris[_d2];
        var _dl = clamp(_db.life / _db.life_max, 0, 1);
        var _hx = lengthdir_x(_db.len * 0.5, _db.ang);
        var _hy = lengthdir_y(_db.len * 0.5, _db.ang);

        gpu_set_blendmode(bm_normal);
        scr_riser_bar(_db.x - _hx, _db.y - _hy, _db.x + _hx, _db.y + _hy,
                      _k_riser_arm_th * 0.7,
                      _armorm, _dl * _fade, _armor, _dl * _fade);

        gpu_set_blendmode(bm_add);
        draw_set_color(scr_hot_metal_color(1 - _db.hot));
        draw_set_alpha(_dl * _db.hot * _fade * 0.7);
        draw_line_width(_db.x - _hx, _db.y - _hy, _db.x + _hx, _db.y + _hy, 3);
    }

    // ====================================================================
    // RINGS.
    // ====================================================================
    gpu_set_blendmode(bm_add);
    for (var _rg = 0; _rg < array_length(_R.rings); _rg++) {
        var _rr = _R.rings[_rg];
        var _ra = clamp(_rr.life / _rr.life_max, 0, 1);
        draw_set_color(merge_color(_danger, c_white, _rr.power * 0.5));
        draw_set_alpha(_ra * _ra * 0.30 * _rr.power * _fade);
        draw_circle(_rr.x, _rr.y, _rr.r, true);
        draw_set_color(c_white);
        draw_set_alpha(_ra * _ra * 0.22 * _rr.power * _fade);
        draw_circle(_rr.x, _rr.y, _rr.r * 0.97, true);
    }

    // ====================================================================
    // with it. Mass here, the bolt on the other surface.
    // ====================================================================
    if (_R.tether > 0.01 && instance_exists(oPlayer)) {
        var _tx = _R.fall_x, _ty = _R.fall_y;
        var _pxq = oPlayer.x, _pyq = oPlayer.y;
        var _sag = point_distance(_tx, _ty, _pxq, _pyq) * 0.16;

        gpu_set_blendmode(bm_normal);
        draw_set_color(_armorm);
        draw_set_alpha(_fade * _R.tether);
        var _lx2 = _tx, _ly2 = _ty;
        for (var _c2 = 1; _c2 <= 10; _c2++) {
            var _u2 = _c2 / 10;
            var _bx = lerp(_tx, _pxq, _u2);
            var _by = lerp(_ty, _pyq, _u2) + sin(_u2 * pi) * _sag;
            draw_line_width(_lx2, _ly2, _bx, _by, 4);
            _lx2 = _bx; _ly2 = _by;
        }

        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_danger, c_white, 0.4));
        draw_set_alpha(_fade * _R.tether * 0.7);
        draw_circle(_pxq, _pyq, 13 + sin(t * 0.7) * 3, true);
        draw_set_color(c_white);
        draw_set_alpha(_fade * _R.tether * 0.5);
        draw_circle(_pxq, _pyq, 8, true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}



/// @func scr_riser_draw_lock(_camx, _camy, _sx, _sy)
function scr_riser_draw_lock(_camx, _camy, _sx, _sy) {
    if (is_undefined(riser)) exit;
    if (t > _k_riser_t_deck + 24) exit;

    var _R = riser;
    var _fp = scr_riser_fall_progress();

    var _lk = (t < _k_riser_t_deck)
              ? max(power(_fp, 1.45), lerp(0.34, 1, power(_fp, 1.2)))
              : _R.land;
    if (_lk <= 0.02) exit;

    var _warn  = global.avoid_col_warning;
    var _cyan  = global.avoid_col_cyan;
    var _cyans = global.avoid_col_cyan_soft;

    var _cx   = (_k_riser_cx - _camx) * _sx;
    var _ly   = (_k_riser_deck_y - _camy) * _sy;
    var _ltop = _ly - _k_riser_lock_high * _sy;
    var _lh   = _k_riser_lock_half * _sx;
    var _lhot = _lk * _lk;
    var _sq   = _k_riser_lock_squash;

    gpu_set_blendmode(bm_normal);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_cx - _lh * 1.25, _ltop, c_black, 0);
    draw_vertex_color(_cx + _lh * 1.25, _ltop, c_black, 0);
    draw_vertex_color(_cx - _lh * 1.25, _ly + 34 * _sy, c_black, _lk * 0.80);
    draw_vertex_color(_cx + _lh * 1.25, _ly + 34 * _sy, c_black, _lk * 0.80);
    draw_primitive_end();

    gpu_set_blendmode(bm_add);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_cx - _lh, _ltop, _cyan, 0);
    draw_vertex_color(_cx + _lh, _ltop, _cyan, 0);
    draw_vertex_color(_cx - _lh, _ly, _cyan, 0.12 + _lhot * 0.26);
    draw_vertex_color(_cx + _lh, _ly, _cyan, 0.12 + _lhot * 0.26);
    draw_primitive_end();

    draw_set_color(merge_color(_cyans, c_white, _lhot * 0.4));
    draw_set_alpha(0.34 + _lk * 0.42);
    draw_line_width(_cx - _lh, _ltop, _cx - _lh, _ly, 3);
    draw_line_width(_cx + _lh, _ltop, _cx + _lh, _ly, 3);

    for (var _lr = 0; _lr < _k_riser_lock_rings; _lr++) {
        var _lp = clamp(_fp * 1.15 - _lr * 0.12, 0, 1);
        var _rr = lerp(_k_riser_lock_r0 + _lr * 46, _k_riser_lock_r1, power(_lp, 1.6)) * _sx;
        var _ra = _lk * (0.70 - _lr * 0.15) * (0.45 + _lp * 0.55);

        draw_set_color(merge_color(_cyans, c_white, _lhot * 0.45));
        for (var _rw2 = -1; _rw2 <= 1; _rw2++) {
            draw_set_alpha(_ra * (_rw2 == 0 ? 1 : 0.5));
            draw_ellipse(_cx - _rr + _rw2, _ly - (_rr + _rw2) * _sq,
                         _cx + _rr + _rw2, _ly + (_rr + _rw2) * _sq, true);
        }
    }

    scr_draw_lock_bracket(_cx - _lh, _ltop, _cx + _lh, _ly + 8 * _sy,
                          _cyan, _lk, 1,
                          _k_riser_tick + 8, false, 6, 0,
                          0.55 + 0.35 * sin(current_time * 0.02),
                          _warn);

    draw_set_color(merge_color(_cyans, c_white, 0.35 + _lhot * 0.5));
    draw_set_alpha(0.6 + _lhot * 0.4);
    draw_line_width(_cx - _lh, _ly, _cx + _lh, _ly, 4);

    draw_set_color(merge_color(_cyans, c_white, 0.5 + _lhot * 0.5));
    draw_set_alpha(0.75 + _lhot * 0.25);
    draw_line_width(_cx - 38, _ly, _cx - 13, _ly, 3);
    draw_line_width(_cx + 13, _ly, _cx + 38, _ly, 3);
    draw_line_width(_cx, _ly - 38, _cx, _ly - 13, 3);
    draw_set_color(c_white);
    draw_set_alpha(0.9);
    draw_circle(_cx, _ly, 4 + _lhot * 4, false);

    if (t < _k_riser_t_deck) {
        var _step = (floor(t * 0.5) mod _k_riser_lock_chev);
        for (var _lc = 0; _lc < _k_riser_lock_chev; _lc++) {
            var _cu = ((_lc + _step) mod _k_riser_lock_chev) / _k_riser_lock_chev;
            var _cy3 = lerp(_ltop, _ly, _cu);
            draw_set_color(merge_color(_cyans, c_white, _lhot * 0.5));
            draw_set_alpha(_lk * (0.30 + _cu * 0.60));
            draw_line_width(_cx - 24, _cy3 - 16, _cx, _cy3, 3);
            draw_line_width(_cx + 24, _cy3 - 16, _cx, _cy3, 3);
        }
    }

    if (_R.land > 0.02) {
        draw_set_color(c_white);
        draw_set_alpha(_R.land * 0.8);
        var _br = (1 - _R.land) * 340 * _sx + 40;
        draw_ellipse(_cx - _br, _ly - _br * _sq, _cx + _br, _ly + _br * _sq, true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}



/// @func scr_riser_draw_rails()
function scr_riser_draw_rails() {
    if (is_undefined(riser)) exit;

    var _R    = riser;
    var _fade = scr_riser_fade();
    if (_fade <= 0.004) exit;

    var _erect = scr_riser_erect();
    if (_erect <= 0.004) exit;

    var _cx    = _k_riser_cx;
    var _close = scr_riser_casing();
    var _hand  = scr_riser_handoff();
    var _flood = scr_riser_flood_y();

    var _armor  = global.avoid_col_armor_dark;
    var _armorm = global.avoid_col_armor_mid;
    var _edge   = global.avoid_col_armor_edge;
    var _danger = global.avoid_col_danger;
    var _warn   = global.avoid_col_warning;
    var _cyan   = global.avoid_col_cyan;
    var _cyans  = global.avoid_col_cyan_soft;
    var _ember  = global.avoid_col_ember;

    var _rail_top = lerp(_k_riser_deck_y, _k_riser_crown_y, _erect);

    var _rail_bot = min(_k_riser_deck_y, _flood + 10);

    var _wall_rows = [_rail_top,
                      _k_vault_cy - _k_riser_shell_out,
                      _k_vault_cy,
                      _k_vault_cy + _k_riser_shell_out,
                      _rail_bot];
    var _rw       = _k_riser_rail_w;
    var _live     = _R.rail_live;
    var _hot      = clamp(_R.rail_hot + _R.beat_flash * 0.4 + _live, 0, 1);

    // ====================================================================
    // THE WALLS
    // ====================================================================
    if (_erect > 0.004) {
        for (var _s = -1; _s <= 1; _s += 2) {
            var _tx = _cx + _s * scr_riser_half(_rail_top);
            var _bx = _cx + _s * scr_riser_half(_rail_bot);

            var _seam_col = merge_color(_danger, _cyan, power(_hand, 0.7));

            for (var _wr = 0; _wr < array_length(_wall_rows) - 1; _wr++) {
                var _wy0 = clamp(_wall_rows[_wr], _rail_top, _rail_bot);
                var _wy1 = clamp(_wall_rows[_wr + 1], _rail_top, _rail_bot);
                if (abs(_wy1 - _wy0) < 0.5) continue;

                var _wx0 = _cx + _s * scr_riser_half(_wy0);
                var _wx1 = _cx + _s * scr_riser_half(_wy1);

                gpu_set_blendmode(bm_normal);
                scr_riser_bar(_wx0, _wy0, _wx1, _wy1, _rw * 0.5,
                              (_s < 0) ? _armor : _armorm, _fade,
                              (_s < 0) ? _armorm : _armor, _fade);

                gpu_set_blendmode(bm_add);
                scr_riser_seam(_wx0, _wy0, _wx1, _wy1, _rw * 0.5,
                               _hot, _seam_col, _fade * (0.55 + _hot * 0.45));
            }

            gpu_set_blendmode(bm_add);

            draw_set_color(_edge);
            draw_set_alpha(_fade * (0.13 + _hot * 0.16));
            var _rung_n = ceil((_rail_bot - _rail_top) / _k_riser_rung_gap);
            for (var _u = 0; _u <= _rung_n; _u++) {
                var _ru = _u / max(1, _rung_n);
                var _ry = lerp(_rail_top, _rail_bot, _ru);
                if (_ry > _flood) break;
                var _rx = _cx + _s * scr_riser_half(_ry);
                draw_line_width(_rx, _ry, _rx - _s * _k_riser_rung_len, _ry, 1.4);
            }

            var _pk = _k_riser_packets;
            for (var _q = 0; _q < _pk; _q++) {
                var _qf = frac(t / _k_riser_packet_rate + _q / _pk + (_s < 0 ? 0 : 0.5));
                var _qy = lerp(_rail_bot, _rail_top, _qf);
                if (_qy > _flood) continue;
                var _qx = _cx + _s * scr_riser_half(_qy);
                var _qa = _fade * (0.30 + _hot * 0.5) * (0.35 + (1 - _qf) * 0.65);

                draw_set_color(merge_color(_seam_col, c_white, 0.55));
                draw_set_alpha(_qa);
                draw_line_width(_qx, _qy + 9, _qx, _qy - 9, max(1, _rw * _k_riser_seam_ratio * 0.9));
                draw_set_color(c_white);
                draw_set_alpha(_qa * 0.8);
                draw_line_width(_qx, _qy + 3, _qx, _qy - 3, 1.4);
            }

            for (var _l = 0; _l < _k_riser_levels; _l++) {
                if (_R.lvl_side[_l] != _s) continue;

                var _ly = scr_riser_level_y(_l);
                if (_ly > _rail_bot || _ly < _rail_top) continue;
                if (_ly > _flood + 8) continue;

                var _lx = _cx + _s * scr_riser_half(_ly);

                var _charge = 0;
                for (var _p = 0; _p < array_length(_R.pending); _p++) {
                    if (_R.pending[_p].lvl == _l) _charge = max(_charge, _R.pending[_p].coil);
                }
                var _open = 0;
                for (var _a = 0; _a < array_length(_R.arms); _a++) {
                    if (_R.arms[_a].lvl == _l) _open = max(_open, _R.arms[_a].ext);
                }

                gpu_set_blendmode(bm_normal);
                draw_primitive_begin(pr_trianglestrip);
                draw_vertex_color(_lx, _ly - _k_riser_slot_h, c_black, _fade * 0.85);
                draw_vertex_color(_lx + _s * _rw * 0.9, _ly - _k_riser_slot_h * 0.7, c_black, _fade * 0.5);
                draw_vertex_color(_lx, _ly + _k_riser_slot_h, c_black, _fade * 0.85);
                draw_vertex_color(_lx + _s * _rw * 0.9, _ly + _k_riser_slot_h * 0.7, c_black, _fade * 0.5);
                draw_primitive_end();

                gpu_set_blendmode(bm_add);

                var _jamb = merge_color(_cyan, _warn, clamp(_charge + _open, 0, 1));
                draw_set_color(_jamb);
                draw_set_alpha(_fade * (0.22 + _charge * 0.55 + _open * 0.4));
                draw_line_width(_lx, _ly - _k_riser_slot_h, _lx + _s * _rw * 0.8, _ly - _k_riser_slot_h, 1.8);
                draw_line_width(_lx, _ly + _k_riser_slot_h, _lx + _s * _rw * 0.8, _ly + _k_riser_slot_h, 1.8);

                if (_charge > 0.02) {
                    draw_set_color(merge_color(_warn, c_white, _charge * 0.6));
                    draw_set_alpha(_fade * _charge * 0.5);
                    draw_circle(_lx + _s * _rw * 0.35, _ly, 2 + _charge * 3.4, false);
                }
            }

            if (_erect > 0.2) {
                var _hy2 = _rail_top;
                var _hx2 = _cx + _s * scr_riser_half(_hy2);
                var _hcol = merge_color(_edge, _cyans, power(_hand, 0.6));
                var _hglow = 0.34 + _hot * 0.3 + _hand * 0.5;

                gpu_set_blendmode(bm_normal);
                draw_primitive_begin(pr_trianglestrip);
                draw_vertex_color(_hx2 - _s * _k_riser_head_w, _hy2, _armorm, _fade);
                draw_vertex_color(_hx2 + _s * _k_riser_head_w, _hy2, _armor, _fade);
                draw_vertex_color(_hx2 - _s * _k_riser_head_w * 0.5, _hy2 + _k_riser_head_h, _armorm, _fade);
                draw_vertex_color(_hx2 + _s * _k_riser_head_w * 0.5, _hy2 + _k_riser_head_h, _armor, _fade);
                draw_primitive_end();

                gpu_set_blendmode(bm_add);
                draw_set_color(_hcol);
                draw_set_alpha(_fade * _hglow);
                draw_line_width(_hx2 - _s * _k_riser_head_w, _hy2, _hx2 + _s * _k_riser_head_w, _hy2, 2.4);
                draw_circle(_hx2, _hy2, 3.4 + _hand * 3, false);
                draw_set_color(c_white);
                draw_set_alpha(_fade * (0.3 + _hand * 0.6));
                draw_circle(_hx2, _hy2, 1.6 + _hand * 1.4, false);

                draw_set_color(_hcol);
                draw_set_alpha(_fade * (0.24 + _hand * 0.4));
                for (var _b = -1; _b <= 1; _b += 2) {
                    draw_line_width(_hx2 + _s * _k_riser_head_w, _hy2 + _b * 9,
                                    _hx2 + _s * _k_riser_head_w, _hy2 + _b * 2, 1.6);
                    draw_line_width(_hx2 + _s * _k_riser_head_w, _hy2 + _b * 9,
                                    _hx2 + _s * (_k_riser_head_w - 8), _hy2 + _b * 9, 1.6);
                }
            }

            if (_live > 0.02) {
                var _band = _k_riser_rail_kill * _live;

                draw_primitive_begin(pr_trianglestrip);
                for (var _dr = 0; _dr < array_length(_wall_rows); _dr++) {
                    var _dy2 = clamp(_wall_rows[_dr], _rail_top, _rail_bot);
                    var _dx3 = _cx + _s * scr_riser_half(_dy2);
                    draw_vertex_color(_dx3, _dy2, _warn, _fade * _live * 0.55);
                    draw_vertex_color(_dx3 - _s * _band, _dy2, _warn, 0);
                }
                draw_primitive_end();

                draw_set_color(c_white);
                draw_set_alpha(_fade * _live * 0.85);
                for (var _dw = 0; _dw < array_length(_wall_rows) - 1; _dw++) {
                    var _by0 = clamp(_wall_rows[_dw], _rail_top, _rail_bot);
                    var _by1 = clamp(_wall_rows[_dw + 1], _rail_top, _rail_bot);
                    if (abs(_by1 - _by0) < 0.5) continue;
                    draw_line_width(_cx + _s * scr_riser_half(_by0), _by0,
                                    _cx + _s * scr_riser_half(_by1), _by1, 2 + _live * 3);
                }
            }
        }
    }

    for (var _a2 = 0; _a2 < array_length(_R.arms); _a2++) {
        var _ar = _R.arms[_a2];
        if (_ar.ext <= 0.01) continue;
        if (_ar.y > _flood + 10) continue;

        var _half = scr_riser_half(_ar.y);
        var _rx2  = _cx + _ar.side * _half;
        var _tip  = _rx2 - _ar.side * _ar.cover * _half * 2 * _ar.ext;
        var _th2  = _k_riser_arm_th;
        var _ahot = clamp(_ar.hot * 0.5 + _ar.shock, 0, 1);

        var _arm_top = merge_color(_armorm, _edge, 0.32);

        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_rx2, _ar.y - _th2, _arm_top, _fade);
        draw_vertex_color(_tip, _ar.y - _th2 * 0.86, _arm_top, _fade);
        draw_vertex_color(_rx2, _ar.y + _th2, _armor, _fade);
        draw_vertex_color(_tip, _ar.y + _th2 * 0.86, _armor, _fade);
        draw_primitive_end();

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_rx2, _ar.y - _th2 * 0.56, merge_color(global.avoid_col_blood, c_black, 0.35), _fade);
        draw_vertex_color(_tip, _ar.y - _th2 * 0.48, merge_color(global.avoid_col_blood, c_black, 0.35), _fade);
        draw_vertex_color(_rx2, _ar.y + _th2 * 0.56, merge_color(global.avoid_col_blood, c_black, 0.55), _fade);
        draw_vertex_color(_tip, _ar.y + _th2 * 0.48, merge_color(global.avoid_col_blood, c_black, 0.55), _fade);
        draw_primitive_end();

        var _hd = _k_riser_arm_head;
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_tip + _ar.side * _k_riser_head_len, _ar.y - _hd, _arm_top, _fade);
        draw_vertex_color(_tip, _ar.y - _hd * 0.7, _arm_top, _fade);
        draw_vertex_color(_tip + _ar.side * _k_riser_head_len, _ar.y + _hd, _armor, _fade);
        draw_vertex_color(_tip, _ar.y + _hd * 0.7, _armor, _fade);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        scr_riser_seam(_rx2, _ar.y, _tip, _ar.y, _th2, _ahot, _danger,
                       _fade * (0.34 + _ahot * 0.30));

        // with no shoulders is a neon tube. Same argument as the Vault's inner
        draw_set_color(_edge);
        draw_set_alpha(_fade * (0.15 + _ahot * 0.16));
        draw_line_width(_rx2, _ar.y - _th2, _tip, _ar.y - _th2 * 0.86, 1.4);
        draw_set_alpha(_fade * (0.09 + _ahot * 0.11));
        draw_line_width(_rx2, _ar.y + _th2, _tip, _ar.y + _th2 * 0.86, 1.4);

        draw_set_color(_edge);
        draw_set_alpha(_fade * (0.11 + _ahot * 0.16));
        var _rib_n = max(2, floor(abs(_tip - _rx2) / _k_riser_rib_gap));
        for (var _rb = 1; _rb < _rib_n; _rb++) {
            var _rbx = lerp(_rx2, _tip, _rb / _rib_n);
            draw_line_width(_rbx, _ar.y - _th2 * 0.9, _rbx, _ar.y + _th2 * 0.9, 1);
        }

        draw_set_color(merge_color(_danger, c_white, 0.5 + _ahot * 0.5));
        draw_set_alpha(_fade * (0.55 + _ahot * 0.45));
        draw_line_width(_tip, _ar.y - _hd * 0.72, _tip, _ar.y + _hd * 0.72, 3);
        draw_set_color(c_white);
        draw_set_alpha(_fade * (0.4 + _ahot * 0.6));
        draw_line_width(_tip, _ar.y - _hd * 0.4, _tip, _ar.y + _hd * 0.4, 1.4);

        if (_ar.y < _flood) {
            var _lit = clamp(1 - (_flood - _ar.y) / 260, 0, 1);
            draw_set_color(_ember);
            draw_set_alpha(_fade * _lit * 0.22);
            draw_line_width(_rx2, _ar.y + _th2 * 0.88, _tip, _ar.y + _th2 * 0.76, 2.4);
        }

        if (_ar.shock > 0.02) {
            scr_riser_spill(_tip, _ar.y, (_ar.side < 0) ? 0 : 180,
                            60 * _ar.shock, _hd * 1.2, _warn, _ar.shock * _fade);
            draw_set_color(c_white);
            draw_set_alpha(_fade * _ar.shock * 0.5);
            draw_circle(_tip, _ar.y, (1 - _ar.shock) * 46 + 6, true);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}



/// @func scr_riser_draw_bolts(_cx, _cy, _sx, _sy)
function scr_riser_draw_bolts(_cx, _cy, _sx, _sy) {
    if (is_undefined(riser)) exit;

    var _R    = riser;
    var _fade = scr_riser_fade();
    if (_fade <= 0.004) exit;

    var _danger = global.avoid_col_danger;
    var _warn   = global.avoid_col_warning;
    var _cyan   = global.avoid_col_cyan;
    var _ember  = global.avoid_col_ember;
    var _hand   = scr_riser_handoff();
    var _flood  = scr_riser_flood_y();

    gpu_set_blendmode(bm_add);

    scr_draw_vent_streams(_R.vents, _cx, _cy, _sx);

    for (var _s = 0; _s < array_length(_R.sparks); _s++) {
        var _sp = _R.sparks[_s];
        var _sa = clamp(_sp.life / _sp.life_max, 0, 1);
        var _gx = (_sp.x - _cx) * _sx;
        var _gy = (_sp.y - _cy) * _sy;
        var _tl = point_distance(0, 0, _sp.vx, _sp.vy) * 2.2 * _sx;
        var _dr = point_direction(0, 0, _sp.vx, _sp.vy);

        draw_set_color(_sp.col);
        draw_set_alpha(_sa * _sa * 0.6 * _sp.hot * _fade);
        draw_line_width(_gx, _gy,
                        _gx - lengthdir_x(_tl, _dr), _gy - lengthdir_y(_tl, _dr),
                        max(1, 1.8 * _sx));
        draw_set_color(c_white);
        draw_set_alpha(_sa * _sa * 0.5 * _sp.hot * _fade);
        draw_line_width(_gx, _gy,
                        _gx - lengthdir_x(_tl * 0.4, _dr), _gy - lengthdir_y(_tl * 0.4, _dr),
                        max(1, 0.9 * _sx));
    }

    for (var _a = 0; _a < array_length(_R.arms); _a++) {
        var _ar = _R.arms[_a];
        if (_ar.ext <= 0.2) continue;
        if (_ar.y > _flood + 10) continue;

        var _half = scr_riser_half(_ar.y);
        var _rx = _k_riser_cx + _ar.side * _half;
        var _tip = _rx - _ar.side * _ar.cover * _half * 2 * _ar.ext;

        var _pulse = 0.22 + _ar.hot * 0.34 + _ar.shock * 0.5;
        scr_draw_energy_bolt((_rx - _cx) * _sx, (_ar.y - _cy) * _sy,
                             (_tip - _cx) * _sx, (_ar.y - _cy) * _sy,
                             _pulse * _fade, merge_color(_danger, c_white, 0.25),
                             _ar.off, 1.2 * _sx, 0.7);

        if ((t + _ar.lvl * 5) mod 5 < 2) {
            var _st = _k_riser_stinger * (0.6 + random(0.8));
            scr_draw_energy_bolt((_tip - _cx) * _sx, (_ar.y - _cy) * _sy,
                                 (_tip - _ar.side * _st - _cx) * _sx,
                                 (_ar.y + random_range(-14, 14) - _cy) * _sy,
                                 0.55 * _fade, _warn, _ar.off, 1.2 * _sx, 0.9);
        }
    }

    for (var _p = 0; _p < array_length(_R.pending); _p++) {
        var _pd = _R.pending[_p];
        if (_pd.coil <= 0.25) continue;

        var _reach = lerp(70, 16, _pd.coil) * (0.6 + random(0.8));
        scr_draw_energy_bolt((_pd.rx - _cx) * _sx, (_pd.y - _cy) * _sy,
                             (_pd.rx - _pd.side * _reach - _cx) * _sx,
                             (_pd.y + random_range(-30, 30) - _cy) * _sy,
                             _pd.coil * 0.7 * _fade,
                             _pd.jam ? _ember : _warn, _pd.off,
                             (0.9 + _pd.coil * 1.2) * _sx, 0.85);
    }

    if (_R.rail_live > 0.02) {
        var _top = lerp(_k_riser_deck_y, _k_riser_top_y, scr_riser_erect());
        var _bot = min(_k_riser_deck_y, _flood + 10);
        for (var _s2 = -1; _s2 <= 1; _s2 += 2) {
            for (var _k = 0; _k < 2; _k++) {
                var _x1 = _k_riser_cx + _s2 * scr_riser_half(_bot);
                var _x2 = _k_riser_cx + _s2 * scr_riser_half(_top);
                scr_draw_energy_bolt((_x1 - _cx) * _sx, (_bot - _cy) * _sy,
                                     (_x2 - _cx) * _sx, (_top - _cy) * _sy,
                                     _R.rail_live * (0.9 - _k * 0.3) * _fade,
                                     merge_color(_warn, c_white, 0.55),
                                     scr_bolt_offsets(7, 12 + _k * 16),
                                     (2.2 - _k * 0.9) * _sx, 0.9);
            }
        }
    }

    if (_hand > 0.02 && _hand < 1) {
        var _run = lerp(_k_riser_top_y, _k_riser_deck_y, _hand);
        for (var _s3 = -1; _s3 <= 1; _s3 += 2) {
            var _hx = _k_riser_cx + _s3 * scr_riser_half(_k_riser_top_y);
            var _hx2 = _k_riser_cx + _s3 * scr_riser_half(_run);
            scr_draw_energy_bolt((_hx - _cx) * _sx, (_k_riser_top_y - _cy) * _sy,
                                 (_hx2 - _cx) * _sx, (_run - _cy) * _sy,
                                 (1 - _hand) * 0.9 * _fade,
                                 merge_color(_cyan, c_white, 0.4),
                                 scr_bolt_offsets(6, 9), 1.6 * _sx, 0.85);
        }
    }

    if (_R.tether > 0.01 && instance_exists(oPlayer)) {
        scr_draw_energy_bolt((_R.fall_x - _cx) * _sx, (_R.fall_y - _cy) * _sy,
                             (oPlayer.x - _cx) * _sx, (oPlayer.y - _cy) * _sy,
                             _R.tether * _fade, merge_color(_danger, c_white, 0.45),
                             scr_bolt_offsets(6, 16), 2.2 * _sx, 0.9);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}



/// @func scr_riser_draw_glow(_cx, _cy, _sx, _sy)
function scr_riser_draw_glow(_cx, _cy, _sx, _sy) {
    if (is_undefined(riser)) exit;

    var _R    = riser;
    var _fade = scr_riser_fade();
    if (_fade <= 0.004) exit;

    var _flood = scr_riser_flood_y();
    var _hand  = scr_riser_handoff();

    var _dr = color_get_red(global.avoid_col_danger)   / 255;
    var _dg = color_get_green(global.avoid_col_danger) / 255;
    var _db = color_get_blue(global.avoid_col_danger)  / 255;
    var _er = color_get_red(global.avoid_col_ember)    / 255;
    var _eg = color_get_green(global.avoid_col_ember)  / 255;
    var _eb = color_get_blue(global.avoid_col_ember)   / 255;
    var _cr = color_get_red(global.avoid_col_cyan)     / 255;
    var _cg = color_get_green(global.avoid_col_cyan)   / 255;
    var _cb = color_get_blue(global.avoid_col_cyan)    / 255;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);

    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);

    for (var _a = 0; _a < array_length(_R.arms); _a++) {
        var _ar = _R.arms[_a];
        if (_ar.ext <= 0.1) continue;
        if (_ar.y > _flood + 10) continue;

        var _half = scr_riser_half(_ar.y);
        var _rx = _k_riser_cx + _ar.side * _half;
        var _tip = _rx - _ar.side * _ar.cover * _half * 2 * _ar.ext;
        var _h2 = clamp(_ar.hot * 0.6 + _ar.shock, 0, 1);

        shader_set_uniform_f(global.u_glow_color, lerp(_dr, 1, _h2), lerp(_dg, 1, _h2), lerp(_db, 1, _h2));
        shader_set_uniform_f(global.u_glow_intensity, min(1.1, 0.42 + _h2 * 0.55) * _fade);

        var _gs = (_k_riser_arm_head * 1.15 + 4 + _h2 * 7) / 32 * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_tip - _cx) * _sx, (_ar.y - _cy) * _sy,
                        _gs, _gs, 0, c_white, 1);

        var _bl = abs(_tip - _rx) * 0.5;
        shader_set_uniform_f(global.u_glow_intensity, min(1.1, 0.4 + _h2 * 0.4) * _fade);
        var _bs = (_k_riser_arm_th * 1.1) / 32 * _sx;
        draw_sprite_ext(spr_glow_blob, 0,
                        ((_rx + _tip) * 0.5 - _cx) * _sx, (_ar.y - _cy) * _sy,
                        _bl / 32 * _sx, _bs, 0, c_white, 1);
    }

    for (var _p = 0; _p < array_length(_R.pending); _p++) {
        var _pd = _R.pending[_p];
        if (_pd.coil <= 0.1) continue;
        var _pc = _pd.coil * _pd.coil;

        shader_set_uniform_f(global.u_glow_color, 1, lerp(0.18, 0.9, _pc), lerp(0.20, 0.9, _pc));
        shader_set_uniform_f(global.u_glow_intensity, min(1.3, 0.3 + _pc) * _fade);

        var _ps = (_k_riser_slot_h * 1.4 + 3 + _pc * 6) / 32 * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_pd.rx - _cx) * _sx, (_pd.y - _cy) * _sy,
                        _ps, _ps, 0, c_white, 1);
    }

    if (t >= _k_riser_t_deck && _flood < _k_riser_deck_y + _k_riser_deck_reach) {
        var _fh = scr_riser_half(_flood);
        var _n  = _k_riser_flood_glow_n;

        shader_set_uniform_f(global.u_glow_color, lerp(_er, 1, 0.35 + _R.slam * 0.5),
                             lerp(_eg, 1, 0.35 + _R.slam * 0.5),
                             lerp(_eb, 1, 0.35 + _R.slam * 0.5));
        shader_set_uniform_f(global.u_glow_intensity, min(1.4, 0.7 + _R.slam * 0.6) * _fade);

        var _fs = (_fh * 2 / _n * 0.9 + 4) / 32 * _sx;
        for (var _i = 0; _i <= _n; _i++) {
            var _fx = _k_riser_cx + lerp(-_fh, _fh, _i / _n);
            draw_sprite_ext(spr_glow_blob, 0, (_fx - _cx) * _sx, (_flood - _cy) * _sy,
                            _fs, _fs * 0.6, 0, c_white, 1);
        }
    }

    if (scr_riser_erect() > 0.2) {
        var _top = lerp(_k_riser_deck_y, _k_riser_top_y, scr_riser_erect());
        var _hh = clamp(_R.rail_hot * 0.5 + _hand, 0, 1);

        shader_set_uniform_f(global.u_glow_color,
                             lerp(_dr, _cr, _hand), lerp(_dg, _cg, _hand), lerp(_db, _cb, _hand));
        shader_set_uniform_f(global.u_glow_intensity, min(1.4, 0.5 + _hh * 0.8) * _fade);

        var _hs = (_k_riser_head_w * 1.4 + 4 + _hand * 8) / 32 * _sx;
        for (var _s = -1; _s <= 1; _s += 2) {
            var _hx = _k_riser_cx + _s * scr_riser_half(_top);
            draw_sprite_ext(spr_glow_blob, 0, (_hx - _cx) * _sx, (_top - _cy) * _sy,
                            _hs, _hs, 0, c_white, 1);
        }
    }

    if (_R.rail_live > 0.02) {
        var _top2 = lerp(_k_riser_deck_y, _k_riser_top_y, scr_riser_erect());
        var _n2 = 10;

        shader_set_uniform_f(global.u_glow_color, 1, 0.7, 0.7);
        shader_set_uniform_f(global.u_glow_intensity, min(1.4, _R.rail_live * 1.35) * _fade);

        var _qs = (_k_riser_rail_w * 1.3 + 4) / 32 * _sx;
        for (var _s2 = -1; _s2 <= 1; _s2 += 2) {
            for (var _i2 = 0; _i2 <= _n2; _i2++) {
                var _qy = lerp(_k_riser_deck_y, _top2, _i2 / _n2);
                var _qx = _k_riser_cx + _s2 * scr_riser_half(_qy);
                draw_sprite_ext(spr_glow_blob, 0, (_qx - _cx) * _sx, (_qy - _cy) * _sy,
                                _qs * 0.7, _qs, 0, c_white, 1);
            }
        }
    }

    var _mark = scr_riser_door_mark();
    var _open = scr_riser_door();
    if (max(_mark, _open) > 0.02 && !is_undefined(_R)) {
        var _dn  = _k_vault_hex_rot + 30 + _R.door * 60;
        var _dr  = (_k_riser_shell_in + _k_riser_shell_out) * 0.5;
        var _dx2 = _k_vault_cx + lengthdir_x(_dr, _dn);
        var _dy2 = _k_vault_cy + lengthdir_y(_dr, _dn);

        shader_set_uniform_f(global.u_glow_color,
                             lerp(1, _cr, _open), lerp(0.28, _cg, _open), lerp(0.30, _cb, _open));
        shader_set_uniform_f(global.u_glow_intensity,
                             min(1.3, 0.25 + _mark * 0.5 + _open * 0.7) * _fade);

        var _ds = (_k_riser_door_half * 0.9 + 6 + _open * 10) / 32 * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_dx2 - _cx) * _sx, (_dy2 - _cy) * _sy,
                        _ds, _ds * 0.7, _dn + 90, c_white, 1);
    }

    if (_R.tether > 0.01) {
        shader_set_uniform_f(global.u_glow_color, 1, lerp(0.25, 0.9, _R.tether), lerp(0.22, 0.9, _R.tether));
        shader_set_uniform_f(global.u_glow_intensity, min(1.4, _R.tether * 1.3) * _fade);
        var _ts = 26 / 32 * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_R.fall_x - _cx) * _sx, (_R.fall_y - _cy) * _sy,
                        _ts, _ts, 0, c_white, 1);
    }

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
}
