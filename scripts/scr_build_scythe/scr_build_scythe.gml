function scr_build_scythe(_x,_y,_dir,_scale)
{
    var _points = [];

    var _blade_radius = 120 * _scale;
    var _blade_steps = 32;
    var _handle_length = 100 * _scale;

    for (var h = 0; h < _handle_length; h += 6)
    {
        var _hx = -h;
        var _hy = h * 0.15;

        array_push(
            _points,
            {
                x: _hx,
                y: _hy,
                color: c_blue,
                type: "handle",
                delay: h * 0.4,
				spawn_scale: 0,
				glow: 0, 
				rotation: 0,
				rot_speed: 0,
				life: 1,
				alpha: 1
				
            }
        );
    }


    for (var b = 0; b < _blade_steps; b++)
    {
        var _t = b / (_blade_steps-1);

        var _angle = lerp(
            -80,
            110,
            _t
        );

        var _radius = _blade_radius;

        if (_t > 0.65)
        {
            _radius *= lerp(
                1,
                0.45,
                (_t-0.65)/0.35
            );
        }


        var _bx = lengthdir_x(_radius,_angle);
        var _by = lengthdir_y(_radius,_angle);


        array_push(
            _points,
            {
                x:_bx,
                y:_by,
                color:c_red,
                type:"blade",
                delay:b*2,
				spawn_scale: 0,
				glow: 0, 
				rotation: 0,
				rot_speed: 0,
				life: 1,
				alpha: 1
            }
        );
    }


    for (var e = 0; e < 18; e++)
    {
        var _t = e / 17;

        var _angle = lerp(
            -35,
            125,
            _t
        );

        var _radius = _blade_radius - 18 * _scale;

        array_push(
            _points,
            {
                x:lengthdir_x(_radius,_angle),
                y:lengthdir_y(_radius,_angle),
                color:c_red,
                type:"blade_inner",
                delay:40 + e*2,
				spawn_scale: 0,
				glow: 0, 
				rotation: 0,
				rot_speed: 0,
				life: 1,
				alpha: 1
            }
        );
    }


    for (var i = 0; i < array_length(_points); i++)
    {
        var _p = _points[i];

        var _old_x = _p.x;
        var _old_y = _p.y;

        _p.x = lengthdir_x(
            point_distance(0,0,_old_x,_old_y),
            point_direction(0,0,_old_x,_old_y)+_dir
        );

        _p.y = lengthdir_y(
            point_distance(0,0,_old_x,_old_y),
            point_direction(0,0,_old_x,_old_y)+_dir
        );

        _p.scale = 0.4;
    }


    return _points;
}