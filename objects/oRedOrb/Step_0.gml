event_inherited();

scr_register_glow_point(x, y);

image_xscale = _size
image_yscale = _size

if (materialize_frames > 0) {
	materialize_timer += 1;
	var _mat_p = clamp(materialize_timer / materialize_frames, 0, 1);
	image_alpha = 1 - power(1 - _mat_p, 3);
	hit_active = _mat_p >= 0.75;
	if (_mat_p >= 1) {
		materialize_frames = 0;
		hit_active = true;
	}
}

t++

if speed_up == true {
	if speed < speed_up_max {
		speed += speed_up_amount
	}
}

if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}

if intro_circle == 1 and t == 10 {
	speed = 0
}
if shoot_out == 1 {
	for (var i = 0; i < 10; ++i) {
	    with instance_create_layer(x, y, layer, oRedOrb_2) {
			_size = 2
			direction = other.direction
			speed = i * 10
			intro_circle = 1
			circle_count = i
			trail = 1
		}
	}
	shoot_out = 0
}
if start_orbit == 1 {
	center_x = room_width / 2;
    center_y = 200;

    radius = point_distance(x, y, center_x, center_y);
    angle = point_direction(center_x, center_y, x, y);

    orbit_speed = 4;

	rotate = 1
    start_orbit = 0
}
if start_orbit == 2 {
	center_x = room_width / 2;
    center_y = 200;

    radius = point_distance(x, y, center_x, center_y);
    angle = point_direction(center_x, center_y, x, y);

    orbit_speed = -4;

	rotate = 1
    start_orbit = 0
}

if rotate == 1 {
	angle += orbit_speed;

	x = center_x + lengthdir_x(radius, angle);
	y = center_y + lengthdir_y(radius, angle);
}
if orbiting == true {
	orbit_angle += orbit_speed
	x = orbit_center_x + lengthdir_x(orbit_radius_x, orbit_angle)
	y = orbit_center_y + lengthdir_y(orbit_radius_y, orbit_angle)
}
if spawn_slowdown == 1 {
	if t < 10 {
		speed = 20
	}
	if t >= 10 {
		speed = 8
		spawn_slowdown = 0
	}
}
if spawn_shrink == 1 {
	if _size > 2.5 {
		_size -= 0.5
	}
}
if spawn_shrink == 2 {
	if _size > 0.5 {
		_size -= 0.5
	}
}
if spawn_shrink == 3 {
	if _size > 0 {
		_size -= 0.1
	}
	if _size <= 0 {
		instance_destroy()
	}
}
if (slow_near_player == 1) {
    if (instance_exists(oPlayer)) {
        var d = point_distance(x, y, oPlayer.x, oPlayer.y);

        if (d <= slow_radius) {
            speed = slow_speed;
        } else {
            speed = normal_speed;
        }
    }
}


if orb_hit == true and oAvoidanceController.t < 1572 {
	_size = 2
	image_alpha = 1
	shrink_destroy = 1
	orb_hit = false
}
if orb_hit == true and oAvoidanceController.t > 1572 and oAvoidanceController.t <= 1625 {
	_size = 1
	image_alpha = 1
	orb_hit = false
	gravity = 0.4
	gravity_direction = 180
	trail = 1
}
if orb_hit == true and oAvoidanceController.t > 1650 and t < 2250 {
	_size = 2
	spawn_shrink = 1
	image_alpha = 1
	speed = 20
	direction = 270
	orb_hit = false
	trail = 1
}
if orb_hit == true and oAvoidanceController.t > 6500 and oAvoidanceController.t < 6800 {
	_size = 2
	image_alpha = 1
	shrink_destroy = 1
	orb_hit = false
}

if shrink_destroy == 1 {
	_size -= 0.1
	if _size <= 0 {
		instance_destroy()
	}
}
if is_curving == true {
	direction += curve_amount
}
if ghost_explosion == 1 {
	with instance_create_layer(x, y, layer, oRedOrb_2) {
		image_alpha = 0.2
		_size = 3
		spawn_shrink = 3
		hit_active = false
	}
	ghost_explosion = 0
}
if (spiral_spin != 0) {
    direction += spiral_spin;
}

var glow = 3.0 + sin(current_time * 0.01) * 1.0;

scr_arena_light_add(
    x,
    y,
    1.0,
    0.05,
    0.02,
    glow
);
