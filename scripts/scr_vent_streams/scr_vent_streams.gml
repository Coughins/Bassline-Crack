function scr_spawn_vent_stream(_pool, _x, _y, _dir, _hot, _col_set = undefined, _cap = 64) {
    if (array_length(_pool) >= _cap) return;
    _hot = clamp(_hot, 0, 1);

    if (_col_set == undefined) {
        _col_set = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];
    }

    array_push(_pool, {
        x     : _x,
        y     : _y,
        dir   : _dir,
        len   : random_range(30, 95) * (0.7 + _hot * 0.65),
        spd   : random_range(3.0, 7.4) * (0.7 + _hot),
        w     : random_range(1.5, 4.2),
        life  : irandom_range(14, 28),
        life_max : 28,
        hot   : _hot,
        color : _col_set[irandom(array_length(_col_set) - 1)],
        seed  : random(1000)
    });
}

function scr_update_vent_streams(_pool) {
    for (var i = array_length(_pool) - 1; i >= 0; i--) {
        var _v = _pool[i];
        _v.x += lengthdir_x(_v.spd, _v.dir);
        _v.y += lengthdir_y(_v.spd, _v.dir);
        _v.spd *= 0.972;
        _v.life--;
        if (_v.life <= 0) array_delete(_pool, i, 1);
    }
}

function scr_draw_vent_streams(_pool, _camx = 0, _camy = 0, _scale = 1) {
    var _n = array_length(_pool);
    if (_n <= 0) return;

    var _phase = current_time * 0.0027;

    for (var i = 0; i < _n; i++) {
        var _v = _pool[i];
        var _a = clamp(_v.life / _v.life_max, 0, 1);
        var _gx = (_v.x - _camx) * _scale;
        var _gy = (_v.y - _camy) * _scale;
        var _len = _v.len * _scale;
        var _w = max(1, _v.w * _scale);

        var _dx = lengthdir_x(1, _v.dir);
        var _dy = lengthdir_y(1, _v.dir);
        var _px = lengthdir_x(1, _v.dir + 90);
        var _py = lengthdir_y(1, _v.dir + 90);

        var _sway = sin(_v.seed + _phase) * 8 * _scale;
        draw_set_color(_v.color);
        draw_set_alpha(_a * (0.32 + _v.hot * 0.32));
        draw_line_width(_gx, _gy,
                        _gx + _dx * _len + _px * _sway,
                        _gy + _dy * _len + _py * _sway, _w);

        draw_set_color(c_white);
        draw_set_alpha(_a * _v.hot * 0.55);
        draw_line_width(_gx + _dx * _len * 0.18, _gy + _dy * _len * 0.18,
                        _gx + _dx * _len * 0.46, _gy + _dy * _len * 0.46,
                        max(1, _w * 0.45));

        var _packets = 2 + floor(_v.hot * 3);
        for (var _pk = 0; _pk < _packets; _pk++) {
            var _pf = frac(_v.seed * 0.13 + _pk * 0.31 + _phase);
            var _cx = _gx + _dx * _len * _pf;
            var _cy = _gy + _dy * _len * _pf;
            var _pw = (3 + _v.hot * 5) * _scale;

            draw_set_color(merge_color(_v.color, c_white, 0.35 + _pf * 0.45));
            draw_set_alpha(_a * (1 - _pf * 0.35) * 0.42);
            draw_line_width(_cx - _px * _pw, _cy - _py * _pw,
                            _cx + _px * _pw, _cy + _py * _pw, max(1, 2 * _scale));
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
