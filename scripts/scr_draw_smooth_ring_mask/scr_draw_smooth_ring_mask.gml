function scr_draw_smooth_ring_mask(_cx, _cy, _radius, _alpha, _band, _color = c_white) {
    var _segments = 48;
    var _inner = max(0, _radius - _band);
    var _outer = _radius + _band;

    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i <= _segments; i++)
    {
        var _ang = (360 / _segments) * i;
        var _ix = _cx + lengthdir_x(_inner, _ang);
        var _iy = _cy + lengthdir_y(_inner, _ang);
        var _px = _cx + lengthdir_x(_radius, _ang);
        var _py = _cy + lengthdir_y(_radius, _ang);

        draw_vertex_color(_ix, _iy, _color, 0);
        draw_vertex_color(_px, _py, _color, _alpha);
    }
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i <= _segments; i++)
    {
        var _ang = (360 / _segments) * i;
        var _px = _cx + lengthdir_x(_radius, _ang);
        var _py = _cy + lengthdir_y(_radius, _ang);
        var _ox = _cx + lengthdir_x(_outer, _ang);
        var _oy = _cy + lengthdir_y(_outer, _ang);

        draw_vertex_color(_px, _py, _color, _alpha);
        draw_vertex_color(_ox, _oy, _color, 0);
    }
    draw_primitive_end();
}
