function scr_draw_lightning_arc(_cx, _cy, _radius, _angle_start, _angle_end, _life, _life_max, _color = global.lightning_color, _manage_blend = true) {
    if (_life <= 0) return;

    var _alpha = _life / _life_max;
    var _segments = 8;
    var _pulse = 1.0 + sin(current_time * 0.15 + _cx * 0.1) * 0.35;

    var _prev_x = _cx + lengthdir_x(_radius, _angle_start);
    var _prev_y = _cy + lengthdir_y(_radius, _angle_start);

    if (_manage_blend) gpu_set_blendmode(bm_add);
    for (var s = 1; s <= _segments; s++) {
        var _t = s / _segments;
        var _ang = lerp(_angle_start, _angle_end, _t);
        var _r = _radius + random_range(-6, 6);
        var _tx = _cx + lengthdir_x(_r, _ang);
        var _ty = _cy + lengthdir_y(_r, _ang);

        draw_set_color(_color);
        draw_set_alpha(_alpha * 0.4);
        draw_line_width(_prev_x, _prev_y, _tx, _ty, 4 * _pulse);
        draw_set_alpha(_alpha);
        draw_line_width(_prev_x, _prev_y, _tx, _ty, 1.5 * _pulse);

        _prev_x = _tx;
        _prev_y = _ty;
    }
    if (_manage_blend) gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}