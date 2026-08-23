function scr_draw_cylinder_line(
    _x1, _y1, _depth1,
    _x2, _y2, _depth2
)
{
    var _depth = (_depth1 + _depth2) * 0.5;

    var _alpha = lerp(
        0.08,
        0.5,
        _depth
    );

    draw_set_alpha(_alpha);

    draw_line(
        _x1,
        _y1,
        _x2,
        _y2
    );
}