event_inherited();

var _move_len = point_distance(prev_x, prev_y, x, y);
if (_move_len > 0.05) travel_dir = point_direction(prev_x, prev_y, x, y);
travel_speed = lerp(travel_speed, _move_len, 0.35);
stretch = lerp(stretch, 1 + travel_speed * 0.05 + max(0, ring_tier - 1) * 0.08, 0.28);
prev_x = x;
prev_y = y;
birth_heat = max(0, birth_heat - 0.055);

var _pulse = oAvoidanceController.ring_pulse_mult;
image_xscale = _size * _pulse;
image_yscale = _size * _pulse;

if (spawn_pop_timer < spawn_pop_duration) {
    spawn_pop_timer++;
    var _t = spawn_pop_timer / spawn_pop_duration;
    _t = 1 - power(1 - _t, 3);
    _size = lerp(pop_size, base_size, _t);
}

if (spiral_ease_timer < spiral_ease_duration) {
    spiral_ease_timer++;
    var _s = spiral_ease_timer / spiral_ease_duration;
    spiral_spin = lerp(0, spiral_spin_target, _s);
}
if (spiral_spin != 0) {
    direction += spiral_spin;
}

if (use_dash) {
    dash_timer++;
    if (dash_state == 0) {
        speed = dash_travel_speed;
        if (dash_timer >= dash_travel_duration) {
            dash_state = 1;
            dash_timer = 0;
        }
	} else if (dash_state == 1) {
	    speed = 0;
	    if (dash_timer >= dash_wait_duration) {
	        dash_state = 2;
	        dash_timer = 0;
	        has_trail = true;
	        speed = dash_speed;
	    }
	}
}

if (has_trail) {
    array_push(trail_history, { x: x, y: y, size: _size, stretch: stretch, dir: travel_dir, heat: birth_heat });
    if (array_length(trail_history) > trail_max_length) array_delete(trail_history, 0, 1);
}

if (slow_near_player == 1) {
    if (instance_exists(oPlayer)) {
        var d = point_distance(x, y, oPlayer.x, oPlayer.y);
        speed = (d <= slow_radius) ? slow_speed : normal_speed;
    }
}

if (x < -room_width || x > room_width * 2 || y < -room_height || y > room_height * 2) {
    instance_destroy();
}

scr_add_light(x, y, ring_color, 0.8 + birth_heat * 0.7 + max(0, ring_tier - 1) * 0.12);
