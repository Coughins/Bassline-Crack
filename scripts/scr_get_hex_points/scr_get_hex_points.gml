function scr_get_hex_points(_cell, _size)
{
    var _pts = [];

    for (var i = 0; i < 6; i++)
    {
        var _corner_angle = i * 60 + 30;


        var _local_x = lengthdir_x(_size, _corner_angle);
        var _local_y = lengthdir_y(_size, _corner_angle);


        var _world_x = _cell.grid_x + _local_x;
        var _world_y = _cell.grid_y + _local_y;


		var _wrap_width = cols * hex_radius * sqrt(3);

		var _wrapped_x = _world_x mod _wrap_width;
		if (_wrapped_x < 0) _wrapped_x += _wrap_width;

		var _surface_angle = (_wrapped_x / _wrap_width) * (2 * pi);


		array_push(_pts,
		{
		    x: 400 + cos(_surface_angle) * cylinder_radius,

		    y: 304
		      + _world_y
		      - (rows * hex_radius * 0.75)
		      + sin(_surface_angle) * 70,

		    angle: _surface_angle
		});
    }

    return _pts;
}
