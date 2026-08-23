sphere_points = [];
sphere_radius = 360;

sphere_rotation = 0;
sphere_vertical_rotation = 0;

sphere_spin_velocity = 0;
sphere_vertical_velocity = 0;
sphere_spin_angle = 0;

visual_x = x;
visual_y = y;
visual_z = 0;
target_visual_z = 0;

sphere_wobble = 0;
sphere_spin_speed = 0.001;
sphere_tilt = degtorad(35);


rows = 12;
cols = 22;


for (var _y = 0; _y < rows; _y++)
{
    var lat = pi * (_y/(rows-1));

    for (var _x = 0; _x < cols; _x++)
    {
        var lon = 2*pi*(_x/cols);

        var px = sin(lat) * cos(lon);
        var py = cos(lat);
        var pz = sin(lat) * sin(lon);


		array_push(
		    sphere_points,
		    {
		        _x: px * sphere_radius,
		        _y: py * sphere_radius,
		        _z: pz * sphere_radius,
		        _row: _y
		    }
		);
    }
}

trail = [];
trail_length = 12;
trail_timer = 0;
