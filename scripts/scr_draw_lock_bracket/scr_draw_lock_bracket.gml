function scr_draw_lock_bracket(_x1, _y1, _x2, _y2, _col, _hot, _alpha, _tick = 14, _spine = true, _pad = 5, _ang = 0, _box_pulse = 1, _box_col = undefined) {
    if (is_undefined(_box_col)) _box_col = _col;
    if (_alpha <= 0.004) return;
    _hot = clamp(_hot, 0, 1);

    var _cx = (_x1 + _x2) * 0.5;
    var _cy = (_y1 + _y2) * 0.5;
    var _hw = abs(_x2 - _x1) * 0.5 + _pad;
    var _hh = abs(_y2 - _y1) * 0.5;

    var _tick_u = max(2, min(_tick, _hw * 0.34));
    var _tick_v = max(2, min(_tick, _hh * 0.34));

    var _ux = lengthdir_x(1, _ang);
    var _uy = lengthdir_y(1, _ang);
    var _vx = lengthdir_x(1, _ang + 90);
    var _vy = lengthdir_y(1, _ang + 90);

    var _sx = [ -1, 1, 1, -1 ];
    var _sy = [ -1, -1, 1, 1 ];
    var _px = array_create(4, 0);
    var _py = array_create(4, 0);

    for (var _c = 0; _c < 4; _c++) {
        _px[_c] = _cx + _ux * _sx[_c] * _hw + _vx * _sy[_c] * _hh;
        _py[_c] = _cy + _uy * _sx[_c] * _hw + _vy * _sy[_c] * _hh;
    }

    draw_set_color(merge_color(_box_col, c_white, _hot * 0.45));
    draw_set_alpha(_alpha * (0.16 + _hot * 0.18) * _box_pulse);
    for (var _e = 0; _e < 4; _e++) {
        var _e2 = (_e + 1) mod 4;
        draw_line_width(_px[_e], _py[_e], _px[_e2], _py[_e2], 1);
    }

    draw_set_color(_col);
    draw_set_alpha(_alpha * (0.45 + _hot * 0.22));
    for (var _c = 0; _c < 4; _c++) {
        var _tux = -_sx[_c] * _tick_u * _ux;
        var _tuy = -_sx[_c] * _tick_u * _uy;
        var _tvx = -_sy[_c] * _tick_v * _vx;
        var _tvy = -_sy[_c] * _tick_v * _vy;

        draw_line_width(_px[_c], _py[_c], _px[_c] + _tux, _py[_c] + _tuy, 2);
        draw_line_width(_px[_c], _py[_c], _px[_c] + _tvx, _py[_c] + _tvy, 2);
    }

    if (_spine) {
        var _sp = max(0, _hh - 3);
        draw_set_color(c_white);
        draw_set_alpha(_alpha * _hot * 0.55);
        draw_line_width(_cx - _vx * _sp, _cy - _vy * _sp,
                        _cx + _vx * _sp, _cy + _vy * _sp, 1);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_draw_lock_bracket_glow(_x1, _y1, _x2, _y2, _col, _hot, _alpha, _ang = 0, _pulse = 1) {
    if (_alpha <= 0.004) return;
    _hot = clamp(_hot, 0, 1);

    var _cx = (_x1 + _x2) * 0.5;
    var _cy = (_y1 + _y2) * 0.5;
    var _hw = abs(_x2 - _x1) * 0.5;
    var _hh = abs(_y2 - _y1) * 0.5;

    var _ux = lengthdir_x(1, _ang);
    var _uy = lengthdir_y(1, _ang);
    var _vx = lengthdir_x(1, _ang + 90);
    var _vy = lengthdir_y(1, _ang + 90);

    var _fa = _alpha * _alpha * (0.16 + _hot * 0.18) * _pulse;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_cx - _ux * _hw - _vx * _hh, _cy - _uy * _hw - _vy * _hh, _col, _fa);
    draw_vertex_colour(_cx + _ux * _hw - _vx * _hh, _cy + _uy * _hw - _vy * _hh, _col, _fa);
    draw_vertex_colour(_cx - _ux * _hw + _vx * _hh, _cy - _uy * _hw + _vy * _hh, _col, _fa);
    draw_vertex_colour(_cx + _ux * _hw + _vx * _hh, _cy + _uy * _hw + _vy * _hh, _col, _fa);
    draw_primitive_end();

    draw_set_color(c_white);
    draw_set_alpha(_alpha * _hot * 0.35);
    draw_line_width(_cx - _vx * _hh, _cy - _vy * _hh, _cx + _vx * _hh, _cy + _vy * _hh, 2);

    draw_set_alpha(1);
    draw_set_color(c_white);
}
