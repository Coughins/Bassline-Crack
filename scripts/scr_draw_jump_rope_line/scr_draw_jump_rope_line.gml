function scr_jump_rope_sample() {
    if (jr_curve_t == t) return jr_curve_pts;

    var _k_span_steps = 3;

    var _bn = array_length(jump_rope_bullets);
    if (_bn < 2) { jr_curve_pts = []; jr_curve_t = t; return jr_curve_pts; }

    var _cp = [];
    array_push(_cp, { x : jump_rope_anchor_left_x, y : jump_rope_anchor_left_y, r : 1 });

    for (var i = 0; i < _bn; i++) {
        var _b = jump_rope_bullets[i];
        if (!instance_exists(_b)) continue;
        array_push(_cp, { x : _b.x, y : _b.y, r : _b.weave_reveal });
    }

    array_push(_cp, { x : jump_rope_anchor_right_x, y : jump_rope_anchor_right_y, r : 1 });

    var _cn = array_length(_cp);
    if (_cn < 4) { jr_curve_pts = []; jr_curve_t = t; return jr_curve_pts; }

    var _pts = [];
    for (var i = 0; i < _cn - 1; i++) {
        var _p0 = _cp[max(i - 1, 0)];
        var _p1 = _cp[i];
        var _p2 = _cp[i + 1];
        var _p3 = _cp[min(i + 2, _cn - 1)];

        for (var j = 0; j < _k_span_steps; j++) {
            var _f = j / _k_span_steps;
            array_push(_pts, {
                x : catmull_rom(_p0.x, _p1.x, _p2.x, _p3.x, _f),
                y : catmull_rom(_p0.y, _p1.y, _p2.y, _p3.y, _f),
                r : lerp(_p1.r, _p2.r, _f)
            });
        }
    }
    array_push(_pts, { x : _cp[_cn - 1].x, y : _cp[_cn - 1].y, r : _cp[_cn - 1].r });

    jr_curve_pts = _pts;
    jr_curve_t = t;
    return _pts;
}

function scr_draw_jump_rope_line(_shadow_only = false) {
    if (jump_rope_alpha <= 0.01) return;

    var _pts = scr_jump_rope_sample();
    var _n = array_length(_pts);
    if (_n < 4) return;

    var _k_shadow_alpha = 0.4;
    var _k_shadow_spread = 16;

    var _depth01 = (jump_rope_depth + 1) / 2;
    var _hot = clamp(jr_coil * 0.7 + jr_crack_flash + jr_taut_flash, 0, 1);

    if (_shadow_only) {
        gpu_set_blendmode(bm_normal);
        draw_set_color(c_black);

        for (var i = 0; i < _n - 1; i++) {
            var _a1 = _pts[i], _a2 = _pts[i + 1];
            if (_a1.r <= 0.05) continue;

            var _h = clamp((_k_jr_floor_y - _a1.y) / _k_jr_amp_y, 0, 1);
            draw_set_alpha(_k_shadow_alpha * (1 - _h * 0.75) * jump_rope_alpha * _a1.r);
            draw_line_width(_a1.x, _k_jr_floor_y, _a2.x, _k_jr_floor_y, 2 + _h * _k_shadow_spread);
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        return;
    }

    var _base_col = merge_color(_k_er_col_armor_dark, _k_er_col_armor_edge, 0.48 + _depth01 * 0.26);
    var _warn_mix = clamp(jr_heartbeat * 0.45 + jr_coil * 0.45 + jr_crack_flash * 0.7, 0, 1);
    var _danger_col = merge_color(_k_er_col_warning, _k_er_col_white,
                                  clamp(_hot * 0.56 + jr_crack_flash * 0.35, 0, 1));
    var _line_col = merge_color(_base_col, _danger_col,
                                clamp(0.16 + _depth01 * 0.34 + _warn_mix * 0.52, 0, 1));
    var _core_w = lerp(5.5, 9.5, _depth01) * (1 + _hot * 0.5);
    var _twist = _k_jr_twist_amp * lerp(0.38, 0.82, _depth01);
    var _scroll = t * 0.09;

    var _fringe = clamp(jr_chroma * power(_depth01, 2), 0, 1) * 3.5 * fx_get_mult_for("jumprope", "aberration");

    if (_fringe > 0.2) {
        gpu_set_blendmode(bm_add);

        for (var _side = 0; _side < 2; _side++) {
            draw_set_color((_side == 0) ? _k_er_col_warning : _k_er_col_cyan);
            var _dirn = (_side == 0) ? 1 : -1;

            for (var i = 0; i < _n - 1; i++) {
                var _c1 = _pts[i], _c2 = _pts[i + 1];
                var _cr = min(_c1.r, _c2.r);
                if (_cr <= 0.05) continue;

                var _perp = point_direction(_c1.x, _c1.y, _c2.x, _c2.y) + 90;
                var _ox = lengthdir_x(_fringe * _dirn, _perp);
                var _oy = lengthdir_y(_fringe * _dirn, _perp);

                draw_set_alpha(jump_rope_alpha * _cr * ((_side == 0) ? 0.45 : 0.35));
                draw_line_width(_c1.x + _ox, _c1.y + _oy, _c2.x + _ox, _c2.y + _oy, _core_w * 0.7);
            }
        }

        gpu_set_blendmode(bm_normal);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_color(merge_color(_k_er_col_armor_dark, _base_col, 0.28));
    for (var i = 0; i < _n - 1; i++) {
        var _u1 = _pts[i], _u2 = _pts[i + 1];
        var _ur = min(_u1.r, _u2.r);
        if (_ur <= 0.05) continue;
        draw_set_alpha(jump_rope_alpha * _ur * 0.85);
        draw_line_width(_u1.x, _u1.y, _u2.x, _u2.y, _core_w * 1.75);
    }

    draw_set_color(_line_col);
    for (var i = 0; i < _n - 1; i++) {
        var _b1 = _pts[i], _b2 = _pts[i + 1];
        var _br = min(_b1.r, _b2.r);
        if (_br <= 0.05) continue;
        draw_set_alpha(jump_rope_alpha * _br * 0.92);
        draw_line_width(_b1.x, _b1.y, _b2.x, _b2.y, _core_w * 1.08);
    }

    draw_set_color(c_black);
    for (var i = 0; i < _n - 1; i++) {
        var _r1 = _pts[i], _r2 = _pts[i + 1];
        var _rr = min(_r1.r, _r2.r);
        if (_rr <= 0.05) continue;
        draw_set_alpha(jump_rope_alpha * _rr * (0.16 + _depth01 * 0.22) * (1 - _hot * 0.35));
        draw_line_width(_r1.x, _r1.y, _r2.x, _r2.y, max(1, _core_w * 0.22));
    }

    for (var _strand = 0; _strand < 2; _strand++) {
        var _phase_off = _strand * pi;
        draw_set_color(merge_color(_line_col, (_strand == 0) ? _k_er_col_warning : _k_er_col_cyan,
                                   0.14 + _strand * 0.1));

        var _has_prev = false;
        var _px = 0, _py = 0, _pw = 0, _prev_a = 0;

        for (var i = 0; i < _n; i++) {
            var _s1 = _pts[i];
            if (_s1.r <= 0.05) { _has_prev = false; continue; }

            var _u = i / (_n - 1);
            var _wind = _u * _k_jr_twist_freq * 2 * pi + _phase_off + _scroll;
            var _ia = max(i - 1, 0), _ib = min(i + 1, _n - 1);
            var _perp2 = point_direction(_pts[_ia].x, _pts[_ia].y, _pts[_ib].x, _pts[_ib].y) + 90;

            var _off = sin(_wind) * _twist;
            var _sx = _s1.x + lengthdir_x(_off, _perp2);
            var _sy = _s1.y + lengthdir_y(_off, _perp2);
            var _face = (cos(_wind) + 1) * 0.5;
            var _sw = _core_w * lerp(0.22, 0.68, _face);
            var _sa = jump_rope_alpha * _s1.r * lerp(0.22, 0.82, _face);

            if (_has_prev) {
                draw_set_alpha((_prev_a + _sa) * 0.5);
                draw_line_width(_px, _py, _sx, _sy, (_pw + _sw) * 0.5);
            }

            _px = _sx;
            _py = _sy;
            _pw = _sw;
            _prev_a = _sa;
            _has_prev = true;
        }
    }

    if (_hot > 0.03 || _depth01 > 0.5) {
        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_k_er_col_warning, _k_er_col_white, 0.58 + _hot * 0.42));

        for (var i = 0; i < _n - 1; i++) {
            var _h1 = _pts[i], _h2 = _pts[i + 1];
            var _hr = min(_h1.r, _h2.r);
            if (_hr <= 0.05) continue;
            draw_set_alpha(jump_rope_alpha * _hr * (0.18 + _hot * 0.7) * _depth01);
            draw_line_width(_h1.x, _h1.y, _h2.x, _h2.y, max(1, _core_w * 0.45));
        }

        gpu_set_blendmode(bm_normal);
    }

    var _detail = clamp(_depth01 * 1.35 + _hot + jr_coil * 0.8, 0, 1);
    if (_detail > 0.06) {
        gpu_set_blendmode(bm_add);
        var _packet_count = 5 + floor(jr_escalation * 5) + floor(jr_coil * 4);
        for (var _pk = 0; _pk < _packet_count; _pk++) {
            var _pu = frac(t * (0.018 + jr_coil * 0.022) + _pk / max(1, _packet_count));
            var _pi = clamp(floor(_pu * (_n - 1)), 0, _n - 1);
            var _pp = _pts[_pi];
            if (_pp.r <= 0.05) continue;

            var _pfade = 0.55 + 0.45 * sin(_pu * pi);
            var _pcol = (_pk mod 3 == 0) ? _k_er_col_warning : ((_pk mod 3 == 1) ? _k_er_col_cyan : _k_er_col_violet);
            var _pw2 = (3 + _hot * 5 + jr_coil * 4) * lerp(0.7, 1.2, _depth01);
            var _pa = max(_pi - 1, 0);
            var _pb = min(_pi + 1, _n - 1);
            var _pdir = point_direction(_pts[_pa].x, _pts[_pa].y, _pts[_pb].x, _pts[_pb].y);
            var _px1 = _pp.x - lengthdir_x(_pw2, _pdir);
            var _py1 = _pp.y - lengthdir_y(_pw2, _pdir);
            var _px2 = _pp.x + lengthdir_x(_pw2, _pdir);
            var _py2 = _pp.y + lengthdir_y(_pw2, _pdir);
            var _pwidth = max(1, 2.2 * lerp(0.8, 1.15, _depth01));

            draw_set_color(merge_color(_pcol, c_white, _hot * 0.35));
            draw_set_alpha(jump_rope_alpha * _pp.r * _pfade * _detail * (0.16 + _hot * 0.22 + jr_coil * 0.18));
            draw_line_width(_px1, _py1, _px2, _py2, _pwidth);
        }
        gpu_set_blendmode(bm_normal);
    }

    var _shine_u = (sin(t * _k_jr_shine_speed) + 1) / 2;
    var _shine_i = floor(_shine_u * (_n - 1));

    if (_detail > 0.06) {
        gpu_set_blendmode(bm_add);
        for (var _k = 0; _k < 7; _k++) {
            var _si = clamp(_shine_i - _k, 0, _n - 1);
            var _sp = _pts[_si];
            if (_sp.r <= 0.05) continue;

            var _sf = 1 - _k / 7;
            draw_set_color(merge_color(_k_er_col_white, _line_col, 1 - _sf));
            draw_set_alpha(jump_rope_alpha * _detail * _sf * _sf * 0.5);
            draw_circle(_sp.x, _sp.y, (1.5 + _sf * 3) * lerp(0.6, 1.1, _depth01), false);
        }
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
