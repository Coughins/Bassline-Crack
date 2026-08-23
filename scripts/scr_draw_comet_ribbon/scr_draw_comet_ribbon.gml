function scr_draw_comet_ribbon(_pts, _col, _alpha, _w_head, _w_tail = 0.6, _taper = 1.35,
                               _core_col = c_white, _core_w = 1.6) {
    var _n = array_length(_pts);
    if (_n < 2 || _alpha <= 0.002 || _w_head <= 0) return;

    var _nx = array_create(_n, 0);
    var _ny = array_create(_n, 0);
    var _hw = array_create(_n, 0);
    var _fa = array_create(_n, 0);

    for (var _i = 0; _i < _n; _i++) {
        var _a = _pts[max(0, _i - 1)];
        var _b = _pts[min(_n - 1, _i + 1)];
        var _dx = _b.px - _a.px;
        var _dy = _b.py - _a.py;
        var _l = sqrt(_dx * _dx + _dy * _dy);

        if (_l < 0.0001) { _dx = 1; _dy = 0; _l = 1; }

        _nx[_i] = -_dy / _l;
        _ny[_i] =  _dx / _l;

        var _u = clamp(_pts[_i].u, 0, 1);
        var _shape = power(_u, _taper);

        _hw[_i] = lerp(_w_tail, _w_head, _shape);
        _fa[_i] = power(_u, _taper * 0.72);
    }

    var _pass_w = [ 3.4, 1.0 ];
    var _pass_a = [ 0.11, 0.42 ];

    for (var _p = 0; _p < 2; _p++) {
        var _wm = _pass_w[_p];
        var _am = _alpha * _pass_a[_p];

        draw_primitive_begin(pr_trianglestrip);

        for (var _i = 0; _i < _n; _i++) {
            var _w = _hw[_i] * _wm;
            var _va = min(1, _am * _fa[_i]);
            var _px = _pts[_i].px;
            var _py = _pts[_i].py;

            draw_vertex_colour(_px - _nx[_i] * _w, _py - _ny[_i] * _w, _col, _va);
            draw_vertex_colour(_px + _nx[_i] * _w, _py + _ny[_i] * _w, _col, _va);
        }

        draw_primitive_end();
    }

    if (_core_w <= 0) return;

    draw_primitive_begin(pr_trianglestrip);

    for (var _i = 0; _i < _n; _i++) {
        var _w = max(0.35, _core_w * _fa[_i]);
        var _va = min(1, _alpha * 1.05 * power(_fa[_i], 1.5));
        var _px = _pts[_i].px;
        var _py = _pts[_i].py;

        draw_vertex_colour(_px - _nx[_i] * _w, _py - _ny[_i] * _w, _core_col, _va);
        draw_vertex_colour(_px + _nx[_i] * _w, _py + _ny[_i] * _w, _core_col, _va);
    }

    draw_primitive_end();

    draw_set_alpha(1);
    draw_set_color(c_white);
}

function scr_draw_comet_spine(_pts, _col, _alpha, _width = 1.4, _jitter = 5, _seed = 0, _white = 0.55) {
    var _n = array_length(_pts);
    if (_n < 2 || _alpha <= 0.002) return;

    if (instance_exists(oAvoidanceController)) {
        oAvoidanceController.lightning_bloom_boost += _alpha * 0.05;
    }

    var _hot = merge_color(_col, c_white, _white);
    var _prev_x = _pts[0].px;
    var _prev_y = _pts[0].py;

    for (var _i = 1; _i < _n; _i++) {
        var _pt = _pts[_i];
        var _u = clamp(_pt.u, 0, 1);
        var _cx = _pt.px;
        var _cy = _pt.py;

        if (_i < _n - 1) {
            var _a = _pts[_i - 1];
            var _b = _pts[_i + 1];
            var _dx = _b.px - _a.px;
            var _dy = _b.py - _a.py;
            var _l = max(0.0001, sqrt(_dx * _dx + _dy * _dy));
            var _off = sin(_seed + _i * 2.399) * _jitter * _u;

            _cx += (-_dy / _l) * _off;
            _cy += ( _dx / _l) * _off;
        }

        var _va = _alpha * power(_u, 0.9);
        var _w = _width * (0.35 + _u * 0.65);

        draw_set_color(_col);
        draw_set_alpha(_va * 0.5);
        draw_line_width(_prev_x, _prev_y, _cx, _cy, _w * 2.6);
        draw_set_color(_hot);
        draw_set_alpha(min(1, _va));
        draw_line_width(_prev_x, _prev_y, _cx, _cy, _w);

        _prev_x = _cx;
        _prev_y = _cy;
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}
