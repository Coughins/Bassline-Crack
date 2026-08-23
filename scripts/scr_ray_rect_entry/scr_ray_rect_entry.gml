function scr_ray_rect_entry(_ox, _oy, _dir, _x0, _y0, _x1, _y1) {
    var _dx = lengthdir_x(1, _dir);
    var _dy = lengthdir_y(1, _dir);

    var _best_t = infinity;
    var _best_x = clamp(_ox, _x0, _x1);
    var _best_y = clamp(_oy, _y0, _y1);
    var _found = false;

    if (abs(_dx) > 0.0001) {
        var _txs = [ _x0, _x1 ];
        for (var _i = 0; _i < 2; _i++) {
            var _t = (_txs[_i] - _ox) / _dx;
            if (_t <= 0) continue;
            var _iy = _oy + _dy * _t;
            if (_iy >= _y0 - 0.01 && _iy <= _y1 + 0.01 && _t < _best_t) {
                _best_t = _t;
                _best_x = _txs[_i];
                _best_y = clamp(_iy, _y0, _y1);
                _found = true;
            }
        }
    }

    if (abs(_dy) > 0.0001) {
        var _tys = [ _y0, _y1 ];
        for (var _j = 0; _j < 2; _j++) {
            var _t2 = (_tys[_j] - _oy) / _dy;
            if (_t2 <= 0) continue;
            var _ix = _ox + _dx * _t2;
            if (_ix >= _x0 - 0.01 && _ix <= _x1 + 0.01 && _t2 < _best_t) {
                _best_t = _t2;
                _best_x = clamp(_ix, _x0, _x1);
                _best_y = _tys[_j];
                _found = true;
            }
        }
    }

    if (!_found) {
        return { x : clamp(_ox, _x0, _x1), y : clamp(_oy, _y0, _y1) };
    }

    return { x : _best_x, y : _best_y };
}
