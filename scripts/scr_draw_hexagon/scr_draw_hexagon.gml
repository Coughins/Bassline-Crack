function scr_draw_hexagon(_x, _y, _size, _alpha)
{
    draw_set_alpha(_alpha);

    var _prev_x = 0;
    var _prev_y = 0;

    for (var i = 0; i <= 6; i++)
    {
        var _angle = i * 60 + 30;

        var _px = _x + lengthdir_x(_size, _angle);
        var _py = _y + lengthdir_y(_size, _angle);

        if (i > 0)
        {
            draw_line(
                _prev_x,
                _prev_y,
                _px,
                _py
            );
        }

        _prev_x = _px;
        _prev_y = _py;
    }
}