function scr_draw_energy_bolt(_x1, _y1, _x2, _y2, _alpha, _color, _offsets, _width = 1, _white = 0.75) {
    if (_alpha <= 0) return;

    if (instance_exists(oAvoidanceController)) {
        oAvoidanceController.lightning_bloom_boost += _alpha * 0.03;
    }

    var _joints = array_length(_offsets);
    var _segments = _joints + 1;
    var _perp = point_direction(_x1, _y1, _x2, _y2) + 90;
    var _core_col = merge_color(_color, c_white, _white);

    var _px = _x1;
    var _py = _y1;

    for (var _s = 1; _s <= _segments; _s++) {
        var _f = _s / _segments;
        var _bx = lerp(_x1, _x2, _f);
        var _by = lerp(_y1, _y2, _f);

        var _tap = dsin(_f * 180);

        if (_s <= _joints) {
            _bx += lengthdir_x(_offsets[_s - 1] * _tap, _perp);
            _by += lengthdir_y(_offsets[_s - 1] * _tap, _perp);
        }

        var _w = _width * (0.3 + _tap * 0.7);

        draw_set_color(_color);
        draw_set_alpha(_alpha * 0.10);
        draw_line_width(_px, _py, _bx, _by, _w * 9);
        draw_set_alpha(_alpha * 0.26);
        draw_line_width(_px, _py, _bx, _by, _w * 4);
        draw_set_alpha(_alpha * 0.70);
        draw_line_width(_px, _py, _bx, _by, _w * 1.7);

        draw_set_color(_core_col);
        draw_set_alpha(_alpha);
        draw_line_width(_px, _py, _bx, _by, _w * 0.7);

        _px = _bx;
        _py = _by;
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_bolt_offsets(_joints, _jitter) {
    var _o = array_create(_joints, 0);
    for (var _i = 0; _i < _joints; _i++) {
        _o[_i] = random_range(-_jitter, _jitter);
    }
    return _o;
}
