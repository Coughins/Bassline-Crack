
///@func scr_core_cell_tier(r)
function scr_core_cell_tier(_r) {
    if (_r >= 24) return 2;
    if (_r >= 13) return 1;
    return 0;
}

///@arg flash   beat flash 0..1 — white-hot lip + core bloom
///@arg open    plate separation 0..1 along the seam normal
///@arg fringe  chromatic split in px, from speed
function scr_draw_core_cell(_x, _y, _r, _spin, _tier, _heat, _flash,
                            _seam = 0, _seam_ang = 0, _open = 0, _gather = 1,
                            _accent = undefined, _fringe = 0) {
    if (_r < 1.2) return;
    if (is_undefined(_accent)) _accent = global.avoid_col_cyan;

    _heat  = clamp(_heat, 0, 1);
    _flash = clamp(_flash, 0, 1);
    _seam  = clamp(_seam, 0, 1);
    _gather = clamp(_gather, 0, 1);

    var _core_col = merge_color(global.avoid_col_danger, global.avoid_col_hot,
                                clamp(_heat * 0.3 + _flash * 0.45, 0, 0.72));
    var _lip_col  = merge_color(global.avoid_col_danger, c_white,
                                clamp(0.18 + _flash * 0.42, 0, 0.62));
    var _plate_col = merge_color(global.avoid_col_armor_dark, global.avoid_col_armor_mid,
                                 0.35 + _heat * 0.35);

    var _push = _open * _r * 0.42;
    var _fly  = (1 - _gather) * _r * 2.2;
    var _nrm  = _seam_ang + 90;

    var _plates = (_tier == 2) ? 6 : ((_tier == 1) ? 4 : 0);

    // ---- armour plates -------------------------------------------------------------
    if (_plates > 0) {
        var _step = 360 / _plates;
        var _gap  = (_tier == 2) ? 7 : 9;
        var _r_in = _r * ((_tier == 2) ? 0.58 : 0.62);

        for (var _p = 0; _p < _plates; _p++) {
            var _a0 = _spin + _p * _step + _gap;
            var _a1 = _spin + (_p + 1) * _step - _gap;
            var _pa = (_a0 + _a1) * 0.5;

            var _side = (dcos(_pa - _nrm) >= 0) ? 1 : -1;
            var _ox = _x + lengthdir_x(_push, _nrm) * _side + lengthdir_x(_fly, _pa);
            var _oy = _y + lengthdir_y(_push, _nrm) * _side + lengthdir_y(_fly, _pa);

            draw_set_color(_plate_col);
            draw_set_alpha(0.94);
            draw_primitive_begin(pr_trianglestrip);
            for (var _s = 0; _s <= 2; _s++) {
                var _sa = lerp(_a0, _a1, _s / 2);
                draw_vertex(_ox + lengthdir_x(_r_in, _sa), _oy + lengthdir_y(_r_in, _sa));
                draw_vertex(_ox + lengthdir_x(_r, _sa),    _oy + lengthdir_y(_r, _sa));
            }
            draw_primitive_end();

            draw_set_color(merge_color(global.avoid_col_armor_edge, c_white, _flash * 0.4));
            draw_set_alpha(0.72 + _heat * 0.25);
            draw_line_width(_ox + lengthdir_x(_r, _a0), _oy + lengthdir_y(_r, _a0),
                            _ox + lengthdir_x(_r, _a1), _oy + lengthdir_y(_r, _a1),
                            max(1.2, _r * 0.075));

            draw_set_color(_lip_col);
            draw_set_alpha(0.5 + _heat * 0.45 + _flash * 0.4);
            draw_line_width(_ox + lengthdir_x(_r_in, _a0), _oy + lengthdir_y(_r_in, _a0),
                            _ox + lengthdir_x(_r_in, _a1), _oy + lengthdir_y(_r_in, _a1),
                            max(1, _r * 0.05));

            if (_tier == 2) {
                draw_set_color(global.avoid_col_armor_edge);
                draw_set_alpha(0.28);
                draw_line_width(_ox + lengthdir_x(_r_in * 1.05, _pa), _oy + lengthdir_y(_r_in * 1.05, _pa),
                                _ox + lengthdir_x(_r * 0.94, _pa),    _oy + lengthdir_y(_r * 0.94, _pa), 1);
            }
        }
    } else {
        // ---- tier 0: an armoured hex cell, two rims -------------------------------
        var _hr = _r * (1 + _push / max(_r, 1) * 0.5);
        draw_set_color(_plate_col);
        draw_set_alpha(0.94);
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(_x, _y);
        for (var _h = 0; _h <= 6; _h++) {
            var _ha = _spin + _h * 60;
            draw_vertex(_x + lengthdir_x(_hr, _ha), _y + lengthdir_y(_hr, _ha));
        }
        draw_primitive_end();

        draw_set_color(merge_color(global.avoid_col_armor_edge, c_white, _flash * 0.35));
        draw_set_alpha(0.6 + _heat * 0.25);
        var _hpx = _x + lengthdir_x(_hr, _spin), _hpy = _y + lengthdir_y(_hr, _spin);
        for (var _h2 = 1; _h2 <= 6; _h2++) {
            var _ha2 = _spin + _h2 * 60;
            var _hx2 = _x + lengthdir_x(_hr, _ha2), _hy2 = _y + lengthdir_y(_hr, _ha2);
            draw_line_width(_hpx, _hpy, _hx2, _hy2, max(1.1, _r * 0.11));
            _hpx = _hx2; _hpy = _hy2;
        }

        var _hri = _hr * 0.62;
        draw_set_color(_lip_col);
        draw_set_alpha(0.6 + _heat * 0.35);
        var _hqx = _x + lengthdir_x(_hri, _spin + 30), _hqy = _y + lengthdir_y(_hri, _spin + 30);
        for (var _h3 = 1; _h3 <= 6; _h3++) {
            var _ha3 = _spin + 30 + _h3 * 60;
            var _hx3 = _x + lengthdir_x(_hri, _ha3), _hy3 = _y + lengthdir_y(_hri, _ha3);
            draw_line_width(_hqx, _hqy, _hx3, _hy3, max(1, _r * 0.1));
            _hqx = _hx3; _hqy = _hy3;
        }
    }

    // ---- brace ring + sockets ----------------------------------------------------
    if (_tier >= 1) {
        var _br = _r * ((_tier == 2) ? 0.5 : 0.46);
        draw_set_color(_accent);
        draw_set_alpha(0.35 + _heat * 0.25);
        draw_circle(_x, _y, _br, true);

        if (_tier == 2) {
            var _bs = max(2, _r * 0.1);
            for (var _b = 0; _b < 4; _b++) {
                var _ba = _spin * 0.5 + 45 + _b * 90;
                var _bx = _x + lengthdir_x(_r * 0.78, _ba);
                var _by = _y + lengthdir_y(_r * 0.78, _ba);
                draw_set_color(global.avoid_col_armor_mid);
                draw_set_alpha(1);
                draw_rectangle(_bx - _bs, _by - _bs, _bx + _bs, _by + _bs, false);
                draw_set_color(merge_color(_accent, c_white, 0.3 + _flash * 0.5));
                draw_set_alpha(0.55 + _flash * 0.45);
                draw_rectangle(_bx - _bs * 0.42, _by - _bs * 0.42,
                               _bx + _bs * 0.42, _by + _bs * 0.42, false);
            }
        }
    }

    // ---- the caged core ----------------------------------------------------------
    var _cr = _r * ((_tier == 2) ? 0.34 : (_tier == 1 ? 0.36 : 0.34));
    draw_set_color(_core_col);
    draw_set_alpha(0.88 + _flash * 0.12);
    draw_circle(_x, _y, _cr * (1 + _flash * 0.3 + _seam * 0.2), false);

    draw_set_color(c_white);
    draw_set_alpha(0.22 + _flash * 0.5);
    draw_circle(_x, _y, _cr * (0.3 + _flash * 0.2), false);

    // ---- the rupture seam --------------------------------------------------------
    if (_seam > 0.02) {
        var _sl = _r * (1 + _open * 0.5);
        var _sw = max(1, _r * (0.05 + _seam * 0.13));
        var _snx = lengthdir_x(1, _seam_ang + 90), _sny = lengthdir_y(1, _seam_ang + 90);

        draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.25 + _seam * 0.45));
        draw_set_alpha(0.35 + _seam * 0.6);
        draw_primitive_begin(pr_trianglestrip);
        for (var _sg = 0; _sg <= 4; _sg++) {
            var _su  = _sg / 4;
            var _sd  = (_su * 2 - 1) * _sl;
            var _sww = _sw * (1 - abs(_su * 2 - 1) * 0.8);
            var _sxx = _x + lengthdir_x(_sd, _seam_ang);
            var _syy = _y + lengthdir_y(_sd, _seam_ang);
            draw_vertex(_sxx + _snx * _sww, _syy + _sny * _sww);
            draw_vertex(_sxx - _snx * _sww, _syy - _sny * _sww);
        }
        draw_primitive_end();

        if (_seam > 0.6) {
            draw_set_color(c_white);
            draw_set_alpha((_seam - 0.6) * 1.9);
            draw_line_width(_x - lengthdir_x(_sl * 0.7, _seam_ang),
                            _y - lengthdir_y(_sl * 0.7, _seam_ang),
                            _x + lengthdir_x(_sl * 0.7, _seam_ang),
                            _y + lengthdir_y(_sl * 0.7, _seam_ang),
                            max(1, _sw * 0.3));
        }
    }

    // ---- chromatic fringe on the rim, from speed --------------------------------
    if (_fringe > 0.4) {
        var _fa = clamp(_fringe / 6, 0, 1) * 0.5;
        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha(_fa);
        draw_circle(_x - _fringe, _y, _r * 0.96, true);
        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_fa);
        draw_circle(_x + _fringe, _y, _r * 0.96, true);
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_draw_core_cell_ghost(_x, _y, _r, _spin, _ang, _stretch, _alpha, _hot) {
    if (_alpha <= 0.02 || _r < 1) return;

    var _rx = _r * _stretch;
    var _col = merge_color(global.avoid_col_danger, global.avoid_col_hot, _hot * 0.5);

    draw_set_color(_col);
    draw_set_alpha(_alpha * 0.7);
    draw_primitive_begin(pr_linestrip);
    for (var _h = 0; _h <= 6; _h++) {
        var _ha = _spin + _h * 60;
        var _lx = lengthdir_x(_rx, _ha);
        var _ly = lengthdir_y(_r, _ha);
        draw_vertex(_x + _lx * dcos(_ang) - _ly * dsin(_ang),
                    _y + _lx * dsin(_ang) + _ly * dcos(_ang));
    }
    draw_primitive_end();

    draw_set_color(merge_color(_col, c_white, 0.4));
    draw_set_alpha(_alpha * 0.55);
    draw_circle(_x, _y, _r * 0.3, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
}


///@func orb_rail_point(rail, ang, r_mult)
function orb_rail_point(_rail, _ang, _rm = 1) {
    var _bx = lengthdir_x(_rail.radius * _rm, _ang);
    var _by = lengthdir_y(_rail.radius * _rm, _ang) * _rail.vs;
    return [ _rail.cx + (_bx * cos(_rail.tilt_rad) - _by * sin(_rail.tilt_rad)),
             _rail.cy + (_bx * sin(_rail.tilt_rad) + _by * cos(_rail.tilt_rad)) ];
}

///@func orb_socket_angle(rail, slot)
function orb_socket_angle(_rail, _slot) {
    return (_slot / max(1, _rail.total)) * 360 + _rail.angle;
}

///@func orb_socket_pos(rail, slot)
function orb_socket_pos(_rail, _slot) {
    return orb_rail_point(_rail, orb_socket_angle(_rail, _slot), 1);
}

///@func scr_draw_orb_rail(rail, latch)
function scr_draw_orb_rail(_rail, _latch, _power = 1) {
    if (!is_struct(_rail) || _rail.arm <= 0.01 || _power <= 0.01) return;

    var _a  = _rail.arm * _power;
    var _n  = 36;
    var _lit = _rail.total > 0 ? (_rail.locked / _rail.total) : 0;

    // --- the track: a dark band with a machined outer edge ---------------------
    var _in = 0.955, _out = 1.045;
    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_a * 0.85);
    draw_primitive_begin(pr_trianglestrip);
    for (var _s = 0; _s <= _n; _s++) {
        var _sa = (_s / _n) * 360 + _rail.angle;
        var _pi2 = orb_rail_point(_rail, _sa, _in);
        var _po2 = orb_rail_point(_rail, _sa, _out);
        draw_vertex(_pi2[0], _pi2[1]);
        draw_vertex(_po2[0], _po2[1]);
    }
    draw_primitive_end();

    var _edge = merge_color(global.avoid_col_armor_edge, c_white, _latch * 0.4);
    var _prev = orb_rail_point(_rail, _rail.angle, _out);
    for (var _s2 = 1; _s2 <= _n; _s2++) {
        var _sa2 = (_s2 / _n) * 360 + _rail.angle;
        var _cur = orb_rail_point(_rail, _sa2, _out);
        var _u = _s2 / _n;
        var _on = (_u <= _lit + 0.0001);
        draw_set_color(_on ? _edge : merge_color(global.avoid_col_armor_mid,
                                                 global.avoid_col_armor_edge, 0.45));
        draw_set_alpha(_a * (_on ? (0.55 + _latch * 0.4 + _rail.build * 0.3) : 0.42));
        draw_line_width(_prev[0], _prev[1], _cur[0], _cur[1], _on ? (1.6 + _latch * 1.2) : 1.2);
        _prev = _cur;
    }

    for (var _tk = 0; _tk < 16; _tk++) {
        var _ta = (_tk / 16) * 360 + _rail.angle;
        var _t0 = orb_rail_point(_rail, _ta, _in);
        var _t1 = orb_rail_point(_rail, _ta, _in - ((_tk mod 4 == 0) ? 0.085 : 0.045));
        draw_set_color(global.avoid_col_armor_edge);
        draw_set_alpha(_a * ((_tk mod 4 == 0) ? 0.55 : 0.3));
        draw_line_width(_t0[0], _t0[1], _t1[0], _t1[1], 1);
    }

    // --- sockets ---------------------------------------------------------------
    for (var _k = 0; _k < array_length(_rail.sockets); _k++) {
        var _sk = _rail.sockets[_k];
        var _sp = orb_socket_pos(_rail, _k);
        var _sx = _sp[0], _sy = _sp[1];
        var _sr = 5 + _sk.fill * 2.5 + _sk.flash * 3;
        var _released = (_sk.state == 2);
        var _scol = _released ? global.avoid_col_warning
                              : merge_color(global.avoid_col_armor_edge, c_white,
                                            _sk.flash * 0.7);

        if (_released) {
            var _sa_rel = orb_socket_angle(_rail, _k);
            var _ta0 = orb_rail_point(_rail, _sa_rel - 2.5 * _rail.dir, 1);
            var _ta1 = orb_rail_point(_rail, _sa_rel + 2.5 * _rail.dir, 1);
            var _tdir = point_direction(_ta0[0], _ta0[1], _ta1[0], _ta1[1]);
            var _jaw = 13 + _sk.flash * 5;
            var _jaw_n = _tdir + 90;

            draw_set_color(c_black);
            draw_set_alpha(_a * (0.42 + _sk.flash * 0.18));
            draw_line_width(_sx - lengthdir_x(_jaw, _tdir), _sy - lengthdir_y(_jaw, _tdir),
                            _sx + lengthdir_x(_jaw, _tdir), _sy + lengthdir_y(_jaw, _tdir),
                            5.5 + _sk.flash * 2);

            draw_set_color(global.avoid_col_blood);
            draw_set_alpha(_a * (0.18 + _sk.flash * 0.2));
            draw_line_width(_sx - lengthdir_x(_jaw * 0.8, _tdir), _sy - lengthdir_y(_jaw * 0.8, _tdir),
                            _sx + lengthdir_x(_jaw * 0.8, _tdir), _sy + lengthdir_y(_jaw * 0.8, _tdir),
                            2.2);

            draw_set_color(merge_color(global.avoid_col_armor_edge, global.avoid_col_cyan, 0.35));
            draw_set_alpha(_a * (0.26 + _sk.flash * 0.3));
            draw_line_width(_sx + lengthdir_x(_jaw * 0.5, _jaw_n), _sy + lengthdir_y(_jaw * 0.5, _jaw_n),
                            _sx + lengthdir_x(_jaw * 0.18, _jaw_n) + lengthdir_x(_jaw * 0.55, _tdir),
                            _sy + lengthdir_y(_jaw * 0.18, _jaw_n) + lengthdir_y(_jaw * 0.55, _tdir),
                            1.3);
            draw_line_width(_sx - lengthdir_x(_jaw * 0.5, _jaw_n), _sy - lengthdir_y(_jaw * 0.5, _jaw_n),
                            _sx - lengthdir_x(_jaw * 0.18, _jaw_n) - lengthdir_x(_jaw * 0.55, _tdir),
                            _sy - lengthdir_y(_jaw * 0.18, _jaw_n) - lengthdir_y(_jaw * 0.55, _tdir),
                            1.3);
        }

        draw_set_color(_scol);
        draw_set_alpha(_a * (0.5 + _sk.flash * 0.5) * (_released ? 0.7 : 1));
        var _gap2 = 20 - _sk.fill * 12;
        for (var _c2 = 0; _c2 < 4; _c2++) {
            var _ca = 45 + _c2 * 90;
            draw_line_width(_sx + lengthdir_x(_sr, _ca - _gap2), _sy + lengthdir_y(_sr, _ca - _gap2),
                            _sx + lengthdir_x(_sr, _ca + _gap2), _sy + lengthdir_y(_sr, _ca + _gap2),
                            1 + _sk.flash);
        }

        if (_sk.fill > 0.02 && !_released) {
            gpu_set_blendmode(bm_add);
            draw_set_color(merge_color(global.avoid_col_cyan, c_white, _sk.flash * 0.6));
            draw_set_alpha(_a * _sk.fill * (0.3 + _sk.flash * 0.6));
            draw_circle(_sx, _sy, _sr * 0.6 * _sk.fill, false);
            gpu_set_blendmode(bm_normal);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

///@func scr_draw_orb_hub(cx, cy, stage, grow, latch, rails)
function scr_draw_orb_hub(_cx, _cy, _stage, _grow, _latch, _rails, _power = 1) {
    if ((_stage <= 0 && _grow <= 0.01) || _power <= 0.01) return;

    var _r = 9 + _stage * 4 + _grow * 3;
    var _spin = current_time * 0.03;

    for (var _rr = 0; _rr < min(_stage, array_length(_rails)); _rr++) {
        var _rl = _rails[_rr];
        if (!is_struct(_rl)) continue;
        for (var _st = 0; _st < 4; _st++) {
            var _sa = _st * 90 + _rl.angle * 0.5;
            var _pe = orb_rail_point(_rl, _sa, 0.97);
            draw_set_color(global.avoid_col_armor_mid);
            draw_set_alpha((0.5 + _latch * 0.35) * _power);
            draw_line_width(_cx, _cy, _pe[0], _pe[1], 2.4);
            draw_set_color(global.avoid_col_armor_edge);
            draw_set_alpha((0.22 + _latch * 0.4) * _power);
            draw_line_width(_cx, _cy, _pe[0], _pe[1], 1);
        }
    }

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_power);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex(_cx, _cy);
    for (var _h = 0; _h <= 8; _h++) {
        var _ha = _spin + _h * 45;
        draw_vertex(_cx + lengthdir_x(_r, _ha), _cy + lengthdir_y(_r, _ha));
    }
    draw_primitive_end();

    draw_set_color(merge_color(global.avoid_col_armor_edge, c_white, _latch * 0.5));
    draw_set_alpha((0.6 + _latch * 0.4) * _power);
    var _hx = _cx + lengthdir_x(_r, _spin), _hy = _cy + lengthdir_y(_r, _spin);
    for (var _h2 = 1; _h2 <= 8; _h2++) {
        var _ha2 = _spin + _h2 * 45;
        var _nx = _cx + lengthdir_x(_r, _ha2), _ny = _cy + lengthdir_y(_r, _ha2);
        draw_line_width(_hx, _hy, _nx, _ny, 1.6);
        _hx = _nx; _hy = _ny;
    }

    var _ir = _r * (0.62 - _latch * 0.22);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha((0.45 + _latch * 0.4) * _power);
    for (var _b2 = 0; _b2 < 3; _b2++) {
        var _ba = -_spin * 1.6 + _b2 * 120;
        draw_line_width(_cx + lengthdir_x(_ir, _ba), _cy + lengthdir_y(_ir, _ba),
                        _cx + lengthdir_x(_ir, _ba + 120), _cy + lengthdir_y(_ir, _ba + 120), 1.4);
    }

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(global.avoid_col_danger, global.avoid_col_hot,
                               clamp(0.18 + _latch * 0.28 + _grow * 0.2, 0, 0.6)));
    draw_set_alpha((0.55 + _grow * 0.25) * _power);
    draw_circle(_cx, _cy, _r * (0.28 + _grow * 0.16 + _latch * 0.07), false);
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_color(c_white);
}

///@func scr_draw_orb_plate(pl)
function scr_draw_orb_plate(_pl) {
    var _p = _pl.life / _pl.life_max;
    if (_p <= 0) return;
    var _a = clamp(_p * 1.6, 0, 1);

    var _ux = lengthdir_x(_pl.len, _pl.ang), _uy = lengthdir_y(_pl.len, _pl.ang);
    var _vx = lengthdir_x(_pl.w, _pl.ang + 90), _vy = lengthdir_y(_pl.w, _pl.ang + 90);

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_a * 0.9);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex(_pl.x - _ux + _vx, _pl.y - _uy + _vy);
    draw_vertex(_pl.x - _ux - _vx, _pl.y - _uy - _vy);
    draw_vertex(_pl.x + _ux + _vx * 0.55, _pl.y + _uy + _vy * 0.55);
    draw_vertex(_pl.x + _ux - _vx * 0.55, _pl.y + _uy - _vy * 0.55);
    draw_primitive_end();

    draw_set_color(_pl.col);
    draw_set_alpha(_a * (0.5 + _pl.hot * 0.5));
    draw_line_width(_pl.x - _ux + _vx, _pl.y - _uy + _vy,
                    _pl.x + _ux + _vx * 0.55, _pl.y + _uy + _vy * 0.55, 1.4);

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_pl.col, c_white, 0.45));
    draw_set_alpha(_a * _a * _pl.hot * 0.55);
    draw_line_width(_pl.x, _pl.y,
                    _pl.x - _pl.vx * 3.2, _pl.y - _pl.vy * 3.2, max(1, _pl.w * 0.7));
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_color(c_white);
}

///@func scr_draw_orb_scar(sc)
function scr_draw_orb_scar(_sc) {
    var _p = _sc.life / _sc.life_max;
    if (_p <= 0) return;

    if (_sc.kind == 0) {
        var _np = array_length(_sc.pts) - 1;
        if (_np < 1) return;
        var _a0 = power(_p, 0.7);
        var _px0 = 0, _py0 = 0;

        for (var _pass = 0; _pass < 2; _pass++) {
            draw_set_color(_pass == 0 ? global.avoid_col_blood
                                      : merge_color(_sc.col, c_white, 0.35 + _sc.hot * 0.4));
            draw_set_alpha(_a0 * (_pass == 0 ? 0.75 : 0.55 + _sc.hot * 0.35));
            if (_pass == 1) gpu_set_blendmode(bm_add);
            for (var _i2 = 0; _i2 <= _np; _i2++) {
                var _u = _i2 / _np - 0.5;
                var _taper = 1 - abs(_u) * 2;
                var _off = _sc.pts[_i2] * _sc.len * 0.07 * _taper;
                var _x2 = _sc.x + lengthdir_x(_sc.len * _u, _sc.ang) + lengthdir_x(_off, _sc.ang + 90);
                var _y2 = _sc.y + lengthdir_y(_sc.len * _u, _sc.ang) + lengthdir_y(_off, _sc.ang + 90);
                if (_i2 > 0) {
                    draw_line_width(_px0, _py0, _x2, _y2,
                                    (_pass == 0 ? 4.5 : 1.5) * max(0.25, _taper));
                }
                _px0 = _x2; _py0 = _y2;
            }
            if (_pass == 1) gpu_set_blendmode(bm_normal);
        }
    }
    else if (_sc.kind == 1) {
        var _g = 1 - _p;
        var _rx = _sc.len * (0.15 + _g * 0.95) * _sc.aspect;
        var _ry = _sc.len * (0.15 + _g * 0.95);
        var _fa = _p * _p;

        gpu_set_blendmode(bm_add);
        for (var _lay = 0; _lay < 2; _lay++) {
            draw_set_color(_lay == 0 ? _sc.col : merge_color(_sc.col, c_white, 0.6));
            draw_set_alpha(_fa * (_lay == 0 ? 0.5 : 0.3));
            var _prevx = 0, _prevy = 0;
            var _m = _lay == 0 ? 1 : 0.88;
            for (var _e2 = 0; _e2 <= 30; _e2++) {
                var _ea = (_e2 / 30) * 360;
                var _lx = lengthdir_x(_rx * _m, _ea);
                var _ly = lengthdir_y(_ry * _m, _ea);
                var _wx = _sc.x + _lx * dcos(_sc.ang) - _ly * dsin(_sc.ang);
                var _wy = _sc.y + _lx * dsin(_sc.ang) + _ly * dcos(_sc.ang);
                if (_e2 > 0) draw_line_width(_prevx, _prevy, _wx, _wy, _lay == 0 ? 3 : 1.2);
                _prevx = _wx; _prevy = _wy;
            }
        }
        gpu_set_blendmode(bm_normal);
    }
    else {
        gpu_set_blendmode(bm_add);
        var _sa2 = _p * _p;
        draw_set_color(merge_color(global.avoid_col_hot, c_white, 0.5));
        draw_set_alpha(_sa2 * 0.9);
        var _hl = _sc.len * _p;
        draw_line_width(_sc.x - lengthdir_x(_hl, _sc.ang), _sc.y - lengthdir_y(_hl, _sc.ang),
                        _sc.x + lengthdir_x(_hl, _sc.ang), _sc.y + lengthdir_y(_hl, _sc.ang),
                        1 + _sa2 * 3);
        draw_set_alpha(_sa2 * 0.7);
        draw_circle(_sc.x, _sc.y, 3 + _sa2 * 7, false);
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_draw_orb_unwrap_machine(_hx, _hy, _sx, _sy, _p, _charge, _recoil, _power = 1, _burst = 0) {
    _p = clamp(_p, 0, 1);
    _charge = clamp(_charge, 0, 1.4);
    _recoil = clamp(_recoil, 0, 1);
    _burst = clamp(_burst, 0, 1);
    _power = clamp(_power, 0, 1);
    if (_power <= 0.01 || (_p <= 0.01 && _charge <= 0.02)) return;

    var _bus_w = variable_instance_exists(id, "_k_orb_unwrap_bus_width") ? _k_orb_unwrap_bus_width : 18;
    var _pkt_len = variable_instance_exists(id, "_k_orb_unwrap_packet_len") ? _k_orb_unwrap_packet_len : 28;
    var _flow = clamp(max(_charge, dsin(_p * 180) * 0.72 + _burst * 0.35), 0, 1.4);
    var _a = _power * clamp(0.32 + _p * 0.42 + _flow * 0.25 + _burst * 0.18, 0, 1);
    var _ang = point_direction(_hx, _hy, _sx, _sy);
    var _len = max(1, point_distance(_hx, _hy, _sx, _sy));
    var _nx = lengthdir_x(1, _ang + 90);
    var _ny = lengthdir_y(1, _ang + 90);

    var _curve = dsin(_p * 180) * 10 + _recoil * 9 - _burst * 6;
    var _px = [
        _hx,
        lerp(_hx, _sx, 0.34) + _nx * _curve,
        lerp(_hx, _sx, 0.68) - _nx * (_curve * 0.55 + _burst * 8),
        _sx
    ];
    var _py = [
        _hy,
        lerp(_hy, _sy, 0.34) + _ny * _curve,
        lerp(_hy, _sy, 0.68) - _ny * (_curve * 0.55 + _burst * 8),
        _sy
    ];

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_a * 0.74);
    for (var _bs = 1; _bs < 4; _bs++) {
        draw_line_width(_px[_bs - 1], _py[_bs - 1], _px[_bs], _py[_bs],
                        _bus_w + 8 + _recoil * 6 + _burst * 5);
    }

    draw_set_color(merge_color(global.avoid_col_armor_dark, global.avoid_col_armor_mid, 0.48));
    draw_set_alpha(_a * 0.96);
    for (var _ds = 1; _ds < 4; _ds++) {
        draw_line_width(_px[_ds - 1], _py[_ds - 1], _px[_ds], _py[_ds],
                        _bus_w * 0.72 + _recoil * 2);
    }

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_a * (0.58 + _flow * 0.12));
    var _edge_o = _bus_w * 0.34;
    for (var _es = 1; _es < 4; _es++) {
        draw_line_width(_px[_es - 1] + _nx * _edge_o, _py[_es - 1] + _ny * _edge_o,
                        _px[_es]     + _nx * _edge_o, _py[_es]     + _ny * _edge_o, 1.4);
        draw_line_width(_px[_es - 1] - _nx * _edge_o, _py[_es - 1] - _ny * _edge_o,
                        _px[_es]     - _nx * _edge_o, _py[_es]     - _ny * _edge_o, 1.4);
    }

    draw_set_color(merge_color(global.avoid_col_armor_edge, global.avoid_col_cyan, 0.42));
    draw_set_alpha(_a * (0.22 + _flow * 0.24));
    for (var _cs = 1; _cs < 4; _cs++) {
        draw_line_width(_px[_cs - 1], _py[_cs - 1], _px[_cs], _py[_cs], 1.7);
    }

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_a * (0.10 + _flow * 0.08));
    for (var _rs = 1; _rs < 4; _rs++) {
        draw_line_width(_px[_rs - 1] - _nx * (_bus_w * 0.18), _py[_rs - 1] - _ny * (_bus_w * 0.18),
                        _px[_rs]     - _nx * (_bus_w * 0.18), _py[_rs]     - _ny * (_bus_w * 0.18), 1.2);
    }

    var _clamps = 6;
    for (var _c = 0; _c < _clamps; _c++) {
        var _u = (_c + 0.5) / _clamps;
        if (_u > _p + 0.12) continue;
        var _cx = lerp(_hx, _sx, _u);
        var _cy = lerp(_hy, _sy, _u);
        var _cw = _bus_w * 0.42 + ((_c mod 2) == 0 ? 4 : 0);
        draw_set_color(global.avoid_col_armor_mid);
        draw_set_alpha(_a * (0.36 + _flow * 0.12));
        draw_line_width(_cx - _nx * _cw, _cy - _ny * _cw,
                        _cx + _nx * _cw, _cy + _ny * _cw, 2);
        draw_set_color(global.avoid_col_armor_edge);
        draw_set_alpha(_a * (0.18 + _flow * 0.08));
        draw_line_width(_cx - lengthdir_x(6, _ang), _cy - lengthdir_y(6, _ang),
                        _cx + lengthdir_x(6, _ang), _cy + lengthdir_y(6, _ang), 1);
    }

    var _hub_r = 18 + _recoil * 5 + _burst * 3;
    var _sink_r = 13 + _p * 16 + _flow * 5 + _burst * 8;
    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_a);
    draw_circle(_hx, _hy, _hub_r, false);
    draw_circle(_sx, _sy, _sink_r, false);

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_a * 0.74);
    draw_circle(_hx, _hy, _hub_r + 5, true);
    draw_circle(_sx, _sy, _sink_r + 5, true);

    draw_set_alpha(_a * (0.35 + _flow * 0.18 + _burst * 0.2));
    for (var _jaw = 0; _jaw < 6; _jaw++) {
        var _ja = _jaw * 60 + current_time * 0.035;
        draw_line_width(_sx + lengthdir_x(_sink_r * 0.72, _ja),
                        _sy + lengthdir_y(_sink_r * 0.72, _ja),
                        _sx + lengthdir_x(_sink_r * 1.26, _ja),
                        _sy + lengthdir_y(_sink_r * 1.26, _ja), 1.5 + _burst);
    }

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.28 + _flow * 0.18));
    draw_set_alpha(_a * (0.18 + _flow * 0.36));
    for (var _hs = 1; _hs < 4; _hs++) {
        draw_line_width(_px[_hs - 1], _py[_hs - 1], _px[_hs], _py[_hs],
                        2.2 + _flow * 1.2 + _burst * 1.1);
    }

    for (var _m = 0; _m < 4; _m++) {
        var _mu = frac(_p * 1.48 + _m / 4 + _flow * 0.06);
        var _mx = lerp(_hx, _sx, _mu);
        var _my = lerp(_hy, _sy, _mu);
        var _ml = _pkt_len * (0.42 + _flow * 0.22 + _burst * 0.2);
        draw_set_color(c_white);
        draw_set_alpha(_a * (0.16 + _flow * 0.34 + _burst * 0.22) * (0.55 + 0.10 * _m));
        draw_line_width(_mx - lengthdir_x(_ml, _ang), _my - lengthdir_y(_ml, _ang),
                        _mx + lengthdir_x(_ml * 0.25, _ang), _my + lengthdir_y(_ml * 0.25, _ang),
                        1.1 + _charge * 0.4);
        draw_set_color(global.avoid_col_cyan_soft);
        draw_set_alpha(_a * (0.10 + _flow * 0.22 + _burst * 0.12));
        draw_line_width(_mx - _nx * (_bus_w * 0.28), _my - _ny * (_bus_w * 0.28),
                        _mx + _nx * (_bus_w * 0.28), _my + _ny * (_bus_w * 0.28), 1.1);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

///@func scr_draw_orb_unwrap_track_mass(track)
function scr_draw_orb_unwrap_track_mass(_tr) {
    var _p = _tr.life / max(_tr.life_max, 1);
    if (_p <= 0) return;

    var _age = 1 - _p;
    var _a = clamp(_p * 1.55, 0, 1);
    var _ang = point_direction(_tr.x1, _tr.y1, _tr.x2, _tr.y2);
    var _len = max(1, point_distance(_tr.x1, _tr.y1, _tr.x2, _tr.y2));
    var _nx = lengthdir_x(1, _ang + 90);
    var _ny = lengthdir_y(1, _ang + 90);
    var _sink = variable_struct_exists(_tr, "sink") ? _tr.sink : 0;

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_a * 0.62);
    draw_line_width(_tr.x1, _tr.y1, _tr.x2, _tr.y2, 15 + _sink * 3);

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_a * 0.82);
    draw_primitive_begin(pr_trianglestrip);
    for (var _s = 0; _s <= 4; _s++) {
        var _u = _s / 4;
        var _w = lerp(8.5 + _sink * 2, 2.4 + _sink, _u) * _a;
        var _x = lerp(_tr.x1, _tr.x2, _u);
        var _y = lerp(_tr.y1, _tr.y2, _u);
        draw_vertex(_x + _nx * _w, _y + _ny * _w);
        draw_vertex(_x - _nx * _w, _y - _ny * _w);
    }
    draw_primitive_end();

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_a * 0.46);
    draw_line_width(_tr.x1 + _nx * 4, _tr.y1 + _ny * 4, _tr.x2 + _nx * 2, _tr.y2 + _ny * 2, 1.2);
    draw_line_width(_tr.x1 - _nx * 4, _tr.y1 - _ny * 4, _tr.x2 - _nx * 2, _tr.y2 - _ny * 2, 1.2);

    for (var _mk = 1; _mk <= 3; _mk++) {
        var _mu = (_mk + 0.12) / 4;
        var _mx = lerp(_tr.x1, _tr.x2, _mu);
        var _my = lerp(_tr.y1, _tr.y2, _mu);
        var _mw = lerp(7, 3, _mu) * _a;
        draw_set_color(merge_color(global.avoid_col_armor_edge, global.avoid_col_cyan, 0.22 + _sink * 0.18));
        draw_set_alpha(_a * (0.22 + _sink * 0.12));
        draw_line_width(_mx - _nx * _mw, _my - _ny * _mw,
                        _mx + _nx * _mw, _my + _ny * _mw, 1.1);
    }

    var _collar = 10 + _tr.hot * 3 + _sink * 2;
    draw_set_color(merge_color(global.avoid_col_armor_edge, global.avoid_col_cyan, 0.28));
    draw_set_alpha(_a * (0.52 + _tr.hot * 0.18));
    for (var _c = 0; _c < 4; _c++) {
        var _ca = 45 + _c * 90 + _age * 18;
        draw_line_width(_tr.x1 + lengthdir_x(_collar, _ca - 13), _tr.y1 + lengthdir_y(_collar, _ca - 13),
                        _tr.x1 + lengthdir_x(_collar, _ca + 13), _tr.y1 + lengthdir_y(_collar, _ca + 13), 1.4);
    }

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_a * 0.22 * (0.6 + _sink * 0.4));
    draw_line_width(_tr.x1, _tr.y1,
                    _tr.x1 + lengthdir_x(min(_len, 42), _ang),
                    _tr.y1 + lengthdir_y(min(_len, 42), _ang), 3);

    if (_sink > 0.38 && variable_struct_exists(_tr, "sink_x") && variable_struct_exists(_tr, "sink_y")) {
        var _slot = variable_struct_exists(_tr, "slot") ? _tr.slot : 0;
        if (((_slot + 4000) mod 4) == 0) {
            draw_set_color(c_black);
            draw_set_alpha(_a * _sink * 0.18);
            draw_line_width(_tr.x2, _tr.y2, _tr.sink_x, _tr.sink_y, 5.5);
            draw_set_color(merge_color(global.avoid_col_armor_edge, global.avoid_col_cyan, 0.35));
            draw_set_alpha(_a * _sink * 0.16);
            draw_line_width(_tr.x2, _tr.y2, _tr.sink_x, _tr.sink_y, 1.4);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

///@func scr_draw_orb_unwrap_residue(residue)
function scr_draw_orb_unwrap_residue(_rs) {
    var _p = _rs.life / max(_rs.life_max, 1);
    if (_p <= 0) return;

    var _a = power(_p, 0.72);
    var _ang = point_direction(_rs.x1, _rs.y1, _rs.x2, _rs.y2);
    var _sink = variable_struct_exists(_rs, "sink") ? _rs.sink : 0;
    var _hot = variable_struct_exists(_rs, "hot") ? _rs.hot : 0.5;

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_a * (0.24 + _sink * 0.08));
    draw_line_width(_rs.x1, _rs.y1, _rs.x2, _rs.y2, 6 + _sink * 2);

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_a * (0.14 + _hot * 0.08));
    draw_line_width(_rs.x1, _rs.y1, _rs.x2, _rs.y2, 2.4);

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.18 + _hot * 0.16));
    draw_set_alpha(_a * (0.08 + _sink * 0.14));
    draw_line_width(_rs.x1 + lengthdir_x(2, _ang + 90), _rs.y1 + lengthdir_y(2, _ang + 90),
                    _rs.x2 + lengthdir_x(2, _ang + 90), _rs.y2 + lengthdir_y(2, _ang + 90),
                    1.1);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

function scr_draw_orb_unwrap_track_bolt(_tr, _cam_x, _cam_y, _sx, _sy) {
    var _p = _tr.life / max(_tr.life_max, 1);
    if (_p <= 0) return;

    var _age = 1 - _p;
    var _x1 = (_tr.x1 - _cam_x) * _sx;
    var _y1 = (_tr.y1 - _cam_y) * _sy;
    var _x2 = (_tr.x2 - _cam_x) * _sx;
    var _y2 = (_tr.y2 - _cam_y) * _sy;
    var _sink = variable_struct_exists(_tr, "sink") ? _tr.sink : 0;
    var _a = _p * _p * (0.34 + _tr.hot * 0.36 + _sink * 0.18);
    var _w = (0.75 + _tr.hot * 1.35 + _sink * 0.65) * _sx;

    scr_draw_energy_bolt(_x1, _y1, _x2, _y2, _a,
                          merge_color(global.avoid_col_cyan, c_white, 0.18 + _tr.hot * 0.28),
                          scr_bolt_offsets(4, 3 + _tr.hot * 9), _w, 0.62);

    var _ang = point_direction(_x1, _y1, _x2, _y2);
    var _len = point_distance(_x1, _y1, _x2, _y2);
    var _nx = lengthdir_x(1, _ang + 90);
    var _ny = lengthdir_y(1, _ang + 90);
    var _ux = lengthdir_x(1, _ang);
    var _uy = lengthdir_y(1, _ang);
    var _pkt_len = variable_instance_exists(id, "_k_orb_unwrap_packet_len") ? _k_orb_unwrap_packet_len : 28;

    var _head = clamp(_age * 1.25, 0, 1);
    var _hx = _x1 + lengthdir_x(_len * _head, _ang);
    var _hy = _y1 + lengthdir_y(_len * _head, _ang);
    var _hw = (5.5 + _tr.hot * 4.5 + _sink * 2.5) * _sx;
    draw_set_color(global.avoid_col_cyan_soft);
    draw_set_alpha(_a * (0.55 + _sink * 0.28));
    draw_line_width(_hx - _ux * _pkt_len * 0.30 * _sx, _hy - _uy * _pkt_len * 0.30 * _sy,
                    _hx + _ux * _pkt_len * 0.58 * _sx, _hy + _uy * _pkt_len * 0.58 * _sy,
                    max(1, _hw * 0.42));
    draw_set_color(c_white);
    draw_set_alpha(_a * (0.45 + _sink * 0.22));
    draw_line_width(_hx - _nx * _hw * 0.52, _hy - _ny * _hw * 0.52,
                    _hx + _nx * _hw * 0.52, _hy + _ny * _hw * 0.52,
                    1.1 * _sx);

    for (var _pk = 0; _pk < 2; _pk++) {
        var _u = frac(_age * 1.15 + _pk / 2 + _tr.phase * 0.0017);
        var _px = _x1 + lengthdir_x(_len * _u, _ang);
        var _py = _y1 + lengthdir_y(_len * _u, _ang);
        var _pa = _a * 0.58 * (1 - abs(_u - 0.5) * 0.55);
        draw_set_color(c_white);
        draw_set_alpha(_pa);
        draw_line_width(_px - _nx * 3.8 * _sx, _py - _ny * 3.8 * _sy,
                        _px + _nx * 3.8 * _sx, _py + _ny * 3.8 * _sy, 1.1 * _sx);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
