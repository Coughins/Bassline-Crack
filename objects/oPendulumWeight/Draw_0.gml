gpu_set_blendmode(bm_add);


for (var i = 0; i < array_length(sphere_points); i++)
{
    var p = sphere_points[i];
    var _row = floor(i / cols);



    var _rx =
    p._x * cos(sphere_rotation)
    -
    (p._z + visual_z) * sin(sphere_rotation);


    var _rz =
    p._x * sin(sphere_rotation)
    +
    (p._z + visual_z) * cos(sphere_rotation);




    var _ry1 =
    p._y * cos(sphere_vertical_rotation)
    -
    _rz * sin(sphere_vertical_rotation);


    var _rz1 =
    p._y * sin(sphere_vertical_rotation)
    +
    _rz * cos(sphere_vertical_rotation);




    var _dynamic_tilt = sphere_tilt;


    var _ry =
    _ry1 * cos(_dynamic_tilt)
    -
    _rz1 * sin(_dynamic_tilt);


    var _rz2 =
    _ry1 * sin(_dynamic_tilt)
    +
    _rz1 * cos(_dynamic_tilt);




    var _depth = (_rz2 / sphere_radius + 1) * 0.5;


    _depth = clamp(_depth,0,1);


    var _perspective_scale = 1.0 - (visual_z / 1500);
    _perspective_scale = clamp(_perspective_scale, 0.3, 2.0);

    var _scale = lerp(0.25, 1.8, _depth) * _perspective_scale;

    var _alpha = lerp(0.05, 1, _depth);




    var _final_x = visual_x + (_rx * _perspective_scale);
    var _final_y = visual_y + (_ry * _perspective_scale);

    draw_sprite_ext(
        sprite_index,
        0,
		_final_x,
		_final_y,
        _scale,
        _scale,
        0,
        c_white,
        _alpha
    );
}


gpu_set_blendmode(bm_normal);
