// ============================================================================
// THE DUCT - SHAFT RENDERING
// MASS FIRST; HEAT AND DISTORTION STAY ON THEIR OWN PASSES.
// ============================================================================


/// @func scr_duct_band(_x0, _x1, _y0, _y1, _c0, _a0, _c1, _a1)
function scr_duct_band(_x0, _x1, _y0, _y1, _c0, _a0, _c1, _a1) {
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_x0, _y0, _c0, _a0);
    draw_vertex_color(_x1, _y0, _c0, _a0);
    draw_vertex_color(_x0, _y1, _c1, _a1);
    draw_vertex_color(_x1, _y1, _c1, _a1);
    draw_primitive_end();
}


/// @func scr_duct_hband(_x0, _x1, _y0, _y1, _c0, _a0, _c1, _a1)
function scr_duct_hband(_x0, _x1, _y0, _y1, _c0, _a0, _c1, _a1) {
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_x0, _y0, _c0, _a0);
    draw_vertex_color(_x0, _y1, _c0, _a0);
    draw_vertex_color(_x1, _y0, _c1, _a1);
    draw_vertex_color(_x1, _y1, _c1, _a1);
    draw_primitive_end();
}


function scr_duct_eaten(_x, _y, _cx, _rin, _face_y, _bulge, _flow) {
    var _u = clamp((_x - _cx) / _rin, -1, 1);
    var _fy = _face_y - _flow * _bulge * sqrt(max(0, 1 - _u * _u));
    return ((_y - _fy) * _flow > 0);
}


/// @func scr_duct_hoop(_cx, _cy, _rx, _ry, _col, _a, _rings)
function scr_duct_hoop(_cx, _cy, _rx, _ry, _col, _a, _rings) {
    for (var _i = 0; _i < _rings; _i++) {
        var _k = 1 - _i * 0.13;
        draw_set_color(_col);
        draw_set_alpha(_a * (1 - _i * 0.34));
        draw_ellipse(_cx - _rx * _k, _cy - _ry * _k, _cx + _rx * _k, _cy + _ry * _k, true);
    }
}



/// @func scr_duct_draw_shaft()
function scr_duct_draw_shaft() {
    if (!instance_exists(oHoneycombController)) exit;

    with (oHoneycombController) {
        var _vx = 0, _vy = 0, _vw = room_width, _vh = room_height;
        if (instance_exists(oCameraController)) {
            _vx = oCameraController.current_cam_x;
            _vy = oCameraController.current_cam_y;
            _vw = oCameraController.current_cam_w;
            _vh = oCameraController.current_cam_h;
        }
        var _vl = _vx - 8, _vr = _vx + _vw + 8;
        var _vt = _vy - 8, _vb = _vy + _vh + 8;

        var _armor  = global.avoid_col_armor_dark;
        var _armorm = global.avoid_col_armor_mid;
        var _edge   = global.avoid_col_armor_edge;
        var _cyan   = global.avoid_col_cyan;
        var _cyans  = global.avoid_col_cyan_soft;
        var _blood  = global.avoid_col_blood;
        var _danger = global.avoid_col_danger;
        var _warn   = global.avoid_col_warning;
        var _ember  = global.avoid_col_ember;

        var _cx   = center_x;
        var _rin  = radius_base;
        var _rdet = _rin + _k_duct_casing_gap;         // how far the detail runs
        var _flow = duct_flow;

        var _heat  = clamp(hc_wall_heat * 0.7 + bass_flash * 0.35 + hc_coil * 0.55
                           + hc_heartbeat * 0.4, 0, 1);
        var _light = duct_light;
        var _hush  = duct_hush;
        var _str   = duct_stretch;

        var _out = duct_out;
        if (_out <= 0.004) exit;

        var _str_in = 1;
        if (instance_exists(oAvoidanceController)) {
            _str_in = clamp((oAvoidanceController.t - _k_duct_stretch_t[_str]) / 10, 0, 1);
        }
        var _s1 = (_str >= 1) ? ((_str == 1) ? _str_in : 1) : 0;   // heat exchange
        var _s2 = (_str >= 2) ? ((_str == 2) ? _str_in : 1) : 0;   // scrubber deck
        var _s3 = (_str >= 3) ? ((_str == 3) ? _str_in : 1) : 0;   // overpressure

        // -- THE VOID THE DOOR PAINTS ---------------------------------------
        var _door_y = (hc_phase == "materialize") ? (center_y + materialize_h) : _vb;
        var _veil   = lerp(0.62, 1, materialize_p) * _out;
        if (_door_y > _vt) {
            gpu_set_blendmode(bm_normal);
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_vl, _vt, _armor, 0.90 * _veil);
            draw_vertex_color(_vr, _vt, _armor, 0.90 * _veil);
            draw_vertex_color(_vl, min(_door_y, _vb), _armor, 0.90 * _veil);
            draw_vertex_color(_vr, min(_door_y, _vb), _armor, 0.90 * _veil);
            draw_primitive_end();
        }

        // -- SHAFT FLANGE RINGS ---------------------------------------------
        gpu_set_blendmode(bm_add);

        var _fh0 = floor((_vt - center_y) / _k_duct_flange_step) - 1;
        var _fh1 = ceil((_vb - center_y) / _k_duct_flange_step) + 1;
        var _fry = depth_offset * 3.1 + 16;

        for (var _f = _fh0; _f <= _fh1; _f++) {
            var _fy = center_y + _f * _k_duct_flange_step;
            if (_fy < _vt - 90 || _fy > _vb + 90) continue;
            if (hc_phase == "materialize" && _fy > _door_y) continue;

            var _fa = (0.16 + _heat * 0.16 + _light * 0.06) * _out;
            scr_duct_hoop(_cx, _fy, _rdet, _fry, merge_color(_edge, _danger, _heat * 0.5), _fa, 3);

            for (var _fb = -1; _fb <= 1; _fb += 2) {
                var _fbx = _cx + _fb * (_rin + _k_duct_casing_gap * 0.55);
                draw_set_color(merge_color(_edge, _warn, _heat));
                draw_set_alpha((0.30 + _heat * 0.35) * _out);
                draw_line_width(_fbx - 13, _fy, _fbx + 13, _fy, 3);
                draw_set_color(c_white);
                draw_set_alpha((0.18 + _heat * 0.4) * _out);
                draw_circle(_fbx, _fy, 1.8, false);
            }
        }

        // -- CASING MASS ----------------------------------------------------
        gpu_set_blendmode(bm_normal);
        for (var _w = -1; _w <= 1; _w += 2) {
            var _face = _cx + _w * _rin;
            var _far  = (_w < 0) ? _vl : _vr;
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_face, _vt, _armor, 0.99 * _out);
            draw_vertex_color(_far,  _vt, _armor, 1 * _out);
            draw_vertex_color(_face, _vb, _armor, 0.99 * _out);
            draw_vertex_color(_far,  _vb, _armor, 1 * _out);
            draw_primitive_end();
        }

        for (var _sh = -1; _sh <= 1; _sh += 2) {
            var _sf = _cx + _sh * _rin;
            var _si = _cx + _sh * (_rin - 78);
            scr_duct_hband(_sf, _si, _vt, _vb, _armor, 0.80 * _out, _armor, 0);
        }

        gpu_set_blendmode(bm_add);

        // -- CASING DETAIL --------------------------------------------------
        var _rh0 = floor((_vt - center_y) / _k_duct_rung_step) - 1;
        var _rh1 = ceil((_vb - center_y) / _k_duct_rung_step) + 1;
        var _rung_col = merge_color(_edge, _danger, _heat * 0.55 + _s3 * 0.3);

        for (var _r = _rh0; _r <= _rh1; _r++) {
            var _h  = _r * _k_duct_rung_step;
            var _ry = center_y + _h;
            if (_ry < _vt - 20 || _ry > _vb + 20) continue;
            if (hc_phase == "materialize" && _ry > _door_y) continue;

            var _ahead = (scr_duct_plug_h() - _h) * _flow;
            var _chase = power(clamp(1 - _ahead / max(1, scr_duct_light_reach()), 0, 1), 1.6) * _light;

            var _marker = ((_r * _k_duct_rung_step) mod _k_duct_marker_step == 0);
            var _bank   = (abs(_h - duct_lamp_h) < 110) ? duct_lamp : 0;

            var _heavy = (((_r mod 3) + 3) mod 3 == 0);
            var _ra = (0.20 + _chase * 0.30 + _heat * 0.12 + _bank * 0.4)
                    * (_heavy ? 1 : 0.55) * (1 - _hush * 0.45) * _out;
            var _rw = (_heavy ? 2.6 : 1.5) + _chase * 1.6 + _bank * 2;
            var _rc = merge_color(_rung_col, _ember, _chase * 0.75);

            for (var _w2 = -1; _w2 <= 1; _w2 += 2) {
                var _x0 = _cx + _w2 * _rin;
                var _x1 = _cx + _w2 * _rdet;
                draw_set_color(_rc);
                draw_set_alpha(_ra);
                draw_line_width(_x0, _ry, _x1, _ry, _rw);

                draw_set_color(merge_color(_cyans, _warn, _chase * 0.8));
                draw_set_alpha((0.22 + _bank * 0.6) * (1 - _hush * 0.4) * _out);
                draw_line_width(_x0, _ry, _x0 + _w2 * 15, _ry, max(1, _rw * 0.7));
            }
        }

        for (var _js = -1; _js <= 1; _js += 2) {
            for (var _jn = 0; _jn < 2; _jn++) {
                var _jx = _cx + _js * (_rin + ((_jn == 0) ? 22 : _k_duct_casing_gap * 0.74));
                draw_set_color(merge_color(_edge, _danger, _heat * 0.6));
                draw_set_alpha((0.10 + _heat * 0.10) * _out * (1 - _hush * 0.3));
                draw_line_width(_jx, _vt, _jx, _vb, 5);
                draw_set_color(merge_color(_edge, c_white, 0.3));
                draw_set_alpha((0.20 + _heat * 0.16) * _out * (1 - _hush * 0.3));
                draw_line_width(_jx, _vt, _jx, _vb, 1.4);
            }
        }

        // -- BULKHEAD SEGMENT PLATES ----------------------------------------
        var _mh0 = floor((_vt - center_y) / _k_duct_marker_step) - 1;
        var _mh1 = ceil((_vb - center_y) / _k_duct_marker_step) + 1;

        for (var _m = _mh0; _m <= _mh1; _m++) {
            var _mh = _m * _k_duct_marker_step;
            var _my = center_y + _mh;
            if (_my < _vt - 40 || _my > _vb + 40) continue;
            if (hc_phase == "materialize" && _my > _door_y) continue;

            var _mbank = (abs(_mh - duct_lamp_h) < 200) ? duct_lamp : 0;
            var _ma = (0.34 + _mbank * 0.55 + _heat * 0.18) * (1 - _hush * 0.35) * _out;
            var _mc = merge_color(_cyan, _warn, clamp(_heat * 0.5 + _s3 * 0.5, 0, 1));

            for (var _w3 = -1; _w3 <= 1; _w3 += 2) {
                var _x0 = _cx + _w3 * _rin;
                var _x1 = _cx + _w3 * _rdet;

                draw_set_color(_mc);
                draw_set_alpha(_ma * 0.30);
                draw_line_width(_x0, _my, _x1, _my, 12);
                draw_set_alpha(_ma);
                draw_line_width(_x0, _my, _x1, _my, 2.4);

                for (var _tk = -1; _tk <= 1; _tk += 2) {
                    draw_set_alpha(_ma * 0.8);
                    draw_line_width(_x0 + _w3 * 20, _my, _x0 + _w3 * 20, _my + _tk * 13, 2);
                    draw_line_width(_x1 - _w3 * 20, _my, _x1 - _w3 * 20, _my + _tk * 13, 2);
                }

                var _code = ((_m mod 4) + 4) mod 4;
                draw_set_color(c_white);
                draw_set_alpha(_ma * (0.4 + _mbank * 0.5));
                for (var _bcd = 0; _bcd <= _code; _bcd++) {
                    var _bx = _x0 + _w3 * (46 + _bcd * 11);
                    draw_line_width(_bx, _my - 9, _bx, _my - 3, 2);
                }
            }
        }

        // -- RUNNING LIGHTS -------------------------------------------------
        var _run_dir = (_hush > 0.02) ? _flow : -_flow;
        var _run_spd = lerp(0.010, 0.026, bass_escalation) + _hush * 0.02;
        var _run_t   = instance_exists(oAvoidanceController) ? oAvoidanceController.t : 0;
        var _lamp_step = _k_duct_rung_step * 2;
        var _lh0 = floor((_vt - center_y) / _lamp_step) - 1;
        var _lh1 = ceil((_vb - center_y) / _lamp_step) + 1;

        for (var _lp = _lh0; _lp <= _lh1; _lp++) {
            var _lh = _lp * _lamp_step;
            var _ly = center_y + _lh;
            if (_ly < _vt || _ly > _vb) continue;
            if (hc_phase == "materialize" && _ly > _door_y) continue;

            var _wave = frac(_lh / 620 - _run_dir * _run_t * _run_spd);
            var _lit  = power(max(0, 1 - abs(_wave - 0.5) * 3.4), 2);
            var _lc   = merge_color(_cyan, _warn, clamp(_heat * 0.6 + _s3 * 0.4, 0, 1));
            var _la   = (0.16 + _lit * 0.62 + _hush * _lit * 0.3) * _out;

            for (var _w4 = -1; _w4 <= 1; _w4 += 2) {
                var _lx = _cx + _w4 * (_rin + 8);
                draw_set_color(_lc);
                draw_set_alpha(_la * 0.34);
                draw_circle(_lx, _ly, 5 + _lit * 5, false);
                draw_set_color(merge_color(_lc, c_white, 0.5 + _lit * 0.5));
                draw_set_alpha(_la);
                draw_circle(_lx, _ly, 1.6 + _lit * 1.6, false);
            }
        }

        // -- STRETCH HARDWARE -----------------------------------------------

        if (_s1 > 0.01) {
            var _vh0 = floor((_vt - center_y) / (_k_duct_rung_step * 3)) - 1;
            var _vh1 = ceil((_vb - center_y) / (_k_duct_rung_step * 3)) + 1;
            for (var _vn = _vh0; _vn <= _vh1; _vn++) {
                var _vhh = _vn * _k_duct_rung_step * 3;
                var _vyy = center_y + _vhh;
                if (_vyy < _vt || _vyy > _vb) continue;
                if (hc_phase == "materialize" && _vyy > _door_y) continue;

                var _vahead = (scr_duct_plug_h() - _vhh) * _flow;
                var _vch = power(clamp(1 - _vahead / max(1, scr_duct_light_reach()), 0, 1), 1.6);
                var _va = _s1 * (0.34 + _vch * 0.55 + _heat * 0.24) * (1 - _hush * 0.4) * _out;

                for (var _w5 = -1; _w5 <= 1; _w5 += 2) {
                    var _sx0 = _cx + _w5 * (_rin + 26);
                    var _sx1 = _cx + _w5 * (_rin + 96);
                    scr_duct_hband(_sx0, _sx1, _vyy - 10, _vyy + 10,
                                   merge_color(_danger, _ember, _vch), _va, _blood, 0);
                    draw_set_color(merge_color(_warn, c_white, _vch * 0.6));
                    draw_set_alpha(_va * 1.1);
                    for (var _lv = 0; _lv < 4; _lv++) {
                        var _lvx = lerp(_sx0, _sx1, (_lv + 0.5) / 4);
                        draw_line_width(_lvx, _vyy - 8, _lvx, _vyy + 8, 2);
                    }
                    draw_set_color(merge_color(_edge, _warn, _vch));
                    draw_set_alpha(_va * 1.3);
                    draw_line_width(_sx0, _vyy - 10, _sx0, _vyy + 10, 2.4);
                }
            }
        }

        if (_s2 > 0.01) {
            for (var _w6 = -1; _w6 <= 1; _w6 += 2) {
                for (var _cd = 0; _cd < 3; _cd++) {
                    var _cdx = _cx + _w6 * (_rin + 34 + _cd * 26);
                    draw_set_color(merge_color(_armorm, _edge, 0.75));
                    draw_set_alpha(_s2 * 0.55 * _out * (1 - _hush * 0.3));
                    draw_line_width(_cdx, _vt, _cdx, _vb, 4);

                    for (var _pk = 0; _pk < 3; _pk++) {
                        var _pf = frac(_run_t * (0.012 + _cd * 0.004) * _flow
                                       + _pk / 3 + _cd * 0.21 + _w6 * 0.13);
                        var _py2 = lerp(_vt, _vb, _pf);
                        draw_set_color(merge_color(_cyans, _warn, _heat * 0.7));
                        draw_set_alpha(_s2 * (0.5 + _heat * 0.4) * _out);
                        draw_line_width(_cdx, _py2 - 14, _cdx, _py2 + 14, 3);
                        draw_set_color(c_white);
                        draw_set_alpha(_s2 * 0.5 * _out);
                        draw_line_width(_cdx, _py2 - 5, _cdx, _py2 + 5, 1.6);
                    }
                }
            }
        }

        if (_s3 > 0.01) {
            var _bh0 = floor((_vt - center_y) / 190) - 1;
            var _bh1 = ceil((_vb - center_y) / 190) + 1;
            for (var _bk = _bh0; _bk <= _bh1; _bk++) {
                var _bhh = _bk * 190;
                var _by = center_y + _bhh;
                if (_by < _vt || _by > _vb) continue;

                var _off = ((_bk mod 2 == 0) ? 1 : -1) * _s3 * (5 + _heat * 9);
                for (var _w7 = -1; _w7 <= 1; _w7 += 2) {
                    var _bx0 = _cx + _w7 * (_rin - 2) + _off * _w7;
                    draw_set_color(merge_color(_warn, _ember, 0.4));
                    draw_set_alpha(_s3 * (0.24 + _heat * 0.4) * _out);
                    draw_line_width(_bx0, _by, _bx0, _by + 190, 4);
                    draw_set_color(c_white);
                    draw_set_alpha(_s3 * (0.16 + _heat * 0.42) * _out);
                    draw_line_width(_bx0, _by, _bx0, _by + 190, 1.2);
                }
            }
        }

        // -- what the casing sheds ------------------------------------------
        if (array_length(duct_vents) > 0) scr_draw_vent_streams(duct_vents, 0, 0, 1);

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}





/// @func scr_duct_draw_plug()
function scr_duct_draw_plug() {
    if (!instance_exists(oHoneycombController)) exit;

    with (oHoneycombController) {
        var _vx = 0, _vy = 0, _vw = room_width, _vh = room_height;
        if (instance_exists(oCameraController)) {
            _vx = oCameraController.current_cam_x;
            _vy = oCameraController.current_cam_y;
            _vw = oCameraController.current_cam_w;
            _vh = oCameraController.current_cam_h;
        }
        var _vl = _vx - 8, _vr = _vx + _vw + 8;
        var _vt = _vy - 8, _vb = _vy + _vh + 8;

        var _armor  = global.avoid_col_armor_dark;
        var _armorm = global.avoid_col_armor_mid;
        var _edge   = global.avoid_col_armor_edge;
        var _blood  = global.avoid_col_blood;
        var _danger = global.avoid_col_danger;
        var _warn   = global.avoid_col_warning;
        var _ember  = global.avoid_col_ember;
        var _hot    = global.avoid_col_hot;

        var _cx   = center_x;
        var _rin  = radius_base;
        var _flow = duct_flow;
        var _py   = scr_duct_plug_y();
        var _light = duct_light;
        var _lurch = duct_lurch;
        var _out   = duct_out;
        if (_out <= 0.004) exit;

        gpu_set_blendmode(bm_add);

        // -- THE LIGHT ------------------------------------------------------
        var _reach = scr_duct_light_reach();
        var _hotcol = merge_color(_danger, _ember, 0.5);
        for (var _lb = 0; _lb < 2; _lb++) {
            var _lr = (_lb == 0) ? _reach : _reach * 0.34;
            var _la2 = ((_lb == 0) ? 0.17 : 0.30) * _light * _out * (1 - hc_coil * 0.40);
            var _fy = _py - _flow * _lr;
            scr_duct_band(_vl, _vr,
                          (_flow > 0) ? _fy : _py, (_flow > 0) ? _py : _fy,
                          (_flow > 0) ? _blood : _hotcol,
                          (_flow > 0) ? 0 : _la2,
                          (_flow > 0) ? _hotcol : _blood,
                          (_flow > 0) ? _la2 : 0);
        }

        // -- GRIT -----------------------------------------------------------
        for (var _g = 0; _g < array_length(duct_grit); _g++) {
            var _gr = duct_grit[_g];
            var _ga = clamp(_gr.life / _gr.life_max, 0, 1);
            var _gx2 = _gr.x - _gr.vx * 2;
            var _gy2 = _gr.y - _gr.vy * (_gr.len / max(1, abs(_gr.vy)));
            draw_set_color(_gr.col);
            draw_set_alpha(_ga * 0.34 * _out);
            draw_line_width(_gx2, _gy2, _gr.x, _gr.y, _gr.w * 2.6);
            draw_set_color(merge_color(_gr.col, c_white, 0.5));
            draw_set_alpha(_ga * 0.8 * _out);
            draw_line_width(_gx2, _gy2, _gr.x, _gr.y, _gr.w);
        }

        var _visible = (_flow > 0) ? (_py - 120 < _vb) : (_py + 120 > _vt);
        if (!_visible) {
            gpu_set_blendmode(bm_normal);
            draw_set_alpha(1);
            draw_set_color(c_white);
            exit;
        }

        var _bulge = 46 + hc_coil * 46 + _lurch * 12;
        var _far   = (_flow > 0) ? _vb + 60 : _vt - 60;
        var _cols  = 24;

        // -- MASS -----------------------------------------------------------
        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        for (var _c = 0; _c <= _cols; _c++) {
            var _u  = (_c / _cols) * 2 - 1;
            var _px = _cx + _u * _rin;
            var _fy2 = _py - _flow * _bulge * sqrt(max(0, 1 - _u * _u));
            draw_vertex_color(_px, _fy2, _armorm, 0.99 * _out);
            draw_vertex_color(_px, _far,  _armor,  1 * _out);
        }
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        // -- THE RIM --------------------------------------------------------
        var _rim_c = merge_color(_danger, _hot, clamp(_lurch * 0.7 + hc_coil * 0.4, 0, 1));
        var _rim_a = (0.45 + _lurch * 0.45 + hc_coil * 0.3) * _out;
        var _prev_x = 0, _prev_y = 0;

        for (var _c2 = 0; _c2 <= _cols; _c2++) {
            var _u2  = (_c2 / _cols) * 2 - 1;
            var _px2 = _cx + _u2 * _rin;
            var _fy3 = _py - _flow * _bulge * sqrt(max(0, 1 - _u2 * _u2));
            if (_c2 > 0) {
                draw_set_color(_rim_c);
                draw_set_alpha(_rim_a * 0.26);
                draw_line_width(_prev_x, _prev_y, _px2, _fy3, 13);
                draw_set_color(merge_color(_rim_c, c_white, 0.5));
                draw_set_alpha(_rim_a);
                draw_line_width(_prev_x, _prev_y, _px2, _fy3, 2.4);
            }
            _prev_x = _px2;
            _prev_y = _fy3;
        }

        var _p2x = 0, _p2y = 0;
        for (var _c3 = 0; _c3 <= _cols; _c3++) {
            var _u3  = (_c3 / _cols) * 2 - 1;
            var _px3 = _cx + _u3 * _rin * 0.93;
            var _fy4 = _py - _flow * (_bulge * 0.66 * sqrt(max(0, 1 - _u3 * _u3)) - 16);
            if (_c3 > 0) {
                draw_set_color(merge_color(_blood, _danger, 0.55));
                draw_set_alpha(_rim_a * 0.45);
                draw_line_width(_p2x, _p2y, _px3, _fy4, 2);
            }
            _p2x = _px3;
            _p2y = _fy4;
        }

        // -- TEETH ----------------------------------------------------------
        var _teeth = 22;
        var _spin  = -cylinder_rotation * 1.7;
        for (var _tt = 0; _tt < _teeth; _tt++) {
            var _ta = (_tt / _teeth) * 2 * pi + _spin;
            var _tu = cos(_ta);
            var _tz = sin(_ta);
            if (_tz < -0.2) continue;

            var _tx = _cx + _tu * _rin * 0.985;
            var _ty = _py - _flow * _bulge * sqrt(max(0, 1 - _tu * _tu)) + _tz * 5;
            var _tl = (12 + _tz * 16) * (0.6 + hc_coil * 0.8);

            draw_set_color(merge_color(_edge, _warn, clamp(_light * 0.6 + _lurch, 0, 1)));
            draw_set_alpha((0.40 + _tz * 0.45) * (0.55 + _lurch * 0.45) * _out);
            draw_line_width(_tx, _ty, _tx, _ty - _flow * _tl, 5);
            draw_set_color(c_white);
            draw_set_alpha((0.24 + _tz * 0.40) * (0.4 + _lurch * 0.6) * _out);
            draw_line_width(_tx, _ty - _flow * _tl * 0.35, _tx, _ty - _flow * _tl, 2);
            draw_set_color(merge_color(_hot, c_white, 0.4));
            draw_set_alpha((0.30 + _tz * 0.45) * _out);
            draw_circle(_tx, _ty - _flow * _tl, 1.6 + _tz * 1.4, false);
        }

        // -- THE DRUM -------------------------------------------------------
        for (var _dr = 1; _dr <= 3; _dr++) {
            var _dy = _py + _flow * _dr * (26 + hc_coil * 12);
            scr_duct_hoop(_cx, _dy, _rin * (1 - _dr * 0.05), _bulge * (1 - _dr * 0.12),
                          merge_color(_blood, _danger, 0.5 + _lurch * 0.4),
                          ((0.22 - _dr * 0.045) + _lurch * 0.16) * _out, 2);
        }

        // -- THE HEADLIGHT --------------------------------------------------
        var _hl_y = _py - _flow * (_bulge + 6);
        var _hl   = (0.35 + _lurch * 0.5 + hc_coil * 0.4) * _out;
        var _hl_r = _reach * 0.62;

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx - 40, _hl_y, _hot, _hl * 0.30);
        draw_vertex_color(_cx + 40, _hl_y, _hot, _hl * 0.30);
        draw_vertex_color(_cx - _rin * 0.92, _hl_y - _flow * _hl_r, _ember, 0);
        draw_vertex_color(_cx + _rin * 0.92, _hl_y - _flow * _hl_r, _ember, 0);
        draw_primitive_end();

        draw_set_color(merge_color(_hot, c_white, 0.5));
        draw_set_alpha(_hl * 0.9);
        draw_circle(_cx, _hl_y, 4 + _hl * 5, false);
        draw_set_color(_warn);
        draw_set_alpha(_hl * 0.35);
        draw_circle(_cx, _hl_y, 11 + _hl * 13, false);

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}



/// @func scr_duct_draw_rails()
function scr_duct_draw_rails() {
    if (!instance_exists(oHoneycombController)) exit;

    with (oHoneycombController) {
        var _vy = 0, _vh = room_height;
        if (instance_exists(oCameraController)) {
            _vy = oCameraController.current_cam_y;
            _vh = oCameraController.current_cam_h;
        }
        var _vt = _vy - 8, _vb = _vy + _vh + 8;

        var _cyan  = global.avoid_col_cyan;
        var _cyans = global.avoid_col_cyan_soft;
        var _edge  = global.avoid_col_armor_edge;
        var _warn  = global.avoid_col_warning;
        var _danger = global.avoid_col_danger;
        var _blood  = global.avoid_col_blood;

        var _cx  = center_x;
        var _rin = radius_base;
        var _heat = clamp(hc_wall_heat * 0.6 + bass_flash * 0.3 + hc_coil * 0.6
                          + hc_heartbeat * 0.4 + duct_slam * 0.35, 0, 1);
        var _print = duct_out * ((hc_phase == "materialize")
                   ? clamp(materialize_p * 1.6, 0, 1) : 1);
        if (_print <= 0.01) exit;

        gpu_set_blendmode(bm_add);

        // -- THE RAILS ------------------------------------------------------
        var _rc = merge_color(_cyan, _warn, _heat);
        for (var _w = -1; _w <= 1; _w += 2) {
            var _x = _cx + _w * _rin;

            draw_set_color(_rc);
            draw_set_alpha(_print * (0.13 + _heat * 0.18));
            draw_line_width(_x, _vt, _x, _vb, 15);
            draw_set_color(merge_color(_rc, c_white, 0.45 + _heat * 0.4));
            draw_set_alpha(_print * (0.55 + _heat * 0.4));
            draw_line_width(_x, _vt, _x, _vb, 2.2);

            var _t0 = floor((_vt - center_y) / _k_duct_rung_step) - 1;
            var _t1 = ceil((_vb - center_y) / _k_duct_rung_step) + 1;
            for (var _tk = _t0; _tk <= _t1; _tk++) {
                var _ty = center_y + _tk * _k_duct_rung_step;
                if (_ty < _vt || _ty > _vb) continue;
                var _big = (((_tk mod 4) + 4) mod 4 == 0);
                draw_set_color(_big ? merge_color(_cyans, c_white, 0.4) : _edge);
                draw_set_alpha(_print * (_big ? 0.55 : 0.26) * (1 - duct_hush * 0.3));
                draw_line_width(_x, _ty, _x - _w * (_big ? 15 : 8), _ty, _big ? 2.4 : 1.6);
            }
        }

        // -- THE SEAM -------------------------------------------------------
        if (duct_seam > 0.01 && array_length(duct_seam_pts) > 1) {
            var _sa = power(duct_seam, 1.6);
            var _n = array_length(duct_seam_pts);
            var _jit = duct_seam * 2.4;

            for (var _p = 1; _p < _n; _p++) {
                var _a1 = duct_seam_pts[_p - 1];
                var _a2 = duct_seam_pts[_p];
                var _j1 = _a1.jag * _jit;
                var _j2 = _a2.jag * _jit;

                draw_set_color(merge_color(_blood, _danger, _sa));
                draw_set_alpha(_sa * 0.55);
                draw_line_width(_a1.x, _a1.y + _j1, _a2.x, _a2.y + _j2, 13 * _sa + 3);
                draw_set_color(merge_color(_danger, _warn, _sa));
                draw_set_alpha(_sa * 0.85);
                draw_line_width(_a1.x, _a1.y + _j1, _a2.x, _a2.y + _j2, 3.4);
                draw_set_color(c_white);
                draw_set_alpha(_sa * _sa * 0.9);
                draw_line_width(_a1.x, _a1.y + _j1, _a2.x, _a2.y + _j2, 1.2);
            }
        }

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}



/// @func scr_duct_draw_bolts(_camx, _camy, _sx, _sy)
function scr_duct_draw_bolts(_camx, _camy, _sx, _sy) {
    if (!instance_exists(oHoneycombController)) exit;

    with (oHoneycombController) {
        var _cx = center_x;
        var _rin = radius_base;
        var _flow = duct_flow;

        if (duct_seam > 0.15 && array_length(duct_seam_pts) > 3) {
            var _n = array_length(duct_seam_pts);
            var _step = max(1, (_n - 1) div 5);
            for (var _p = 0; _p + _step < _n; _p += _step) {
                var _a1 = duct_seam_pts[_p];
                var _a2 = duct_seam_pts[_p + _step];
                scr_draw_energy_bolt((_a1.x - _camx) * _sx, (_a1.y - _camy) * _sy,
                                     (_a2.x - _camx) * _sx, (_a2.y - _camy) * _sy,
                                     duct_seam * 0.55,
                                     merge_color(global.avoid_col_warning, c_white, 0.3),
                                     scr_bolt_offsets(4, 9), 1.3 * _sx, 0.8);
            }
        }

        if (duct_lurch > 0.25) {
            var _py = scr_duct_plug_y();
            var _bulge = 34 + hc_coil * 34;
            for (var _a = 0; _a < 3; _a++) {
                var _u1 = random_range(-0.9, 0.9);
                var _u2 = clamp(_u1 + random_range(-0.5, 0.5), -0.95, 0.95);
                var _x1 = _cx + _u1 * _rin;
                var _x2 = _cx + _u2 * _rin;
                var _y1 = _py - _flow * _bulge * sqrt(max(0, 1 - _u1 * _u1));
                var _y2 = _py - _flow * _bulge * sqrt(max(0, 1 - _u2 * _u2));
                scr_draw_energy_bolt((_x1 - _camx) * _sx, (_y1 - _camy) * _sy,
                                     (_x2 - _camx) * _sx, (_y2 - _camy) * _sy,
                                     duct_lurch * 0.8,
                                     merge_color(global.avoid_col_ember, c_white, 0.35),
                                     scr_bolt_offsets(4, 12), 1.5 * _sx, 0.85);
            }
        }
    }
}
