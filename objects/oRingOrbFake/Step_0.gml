image_xscale = _size;
image_yscale = _size;

var _move_len = point_distance(prev_x, prev_y, x, y);
if (_move_len > 0.05) travel_dir = point_direction(prev_x, prev_y, x, y);
travel_speed = lerp(travel_speed, _move_len, 0.35);
prev_x = x;
prev_y = y;
birth_heat = max(0, birth_heat - 0.075);

if (_size > base_size) {
    _size -= spawn_pop_rate;
    if (_size < base_size) _size = base_size;
}

if (spiral_ease_timer < spiral_ease_duration) {
    spiral_ease_timer++;
    spiral_spin = lerp(0, spiral_spin_target, spiral_ease_timer / spiral_ease_duration);
}
if (spiral_spin != 0) direction += spiral_spin;

life--;
if (life <= 6) image_alpha = life / 6;
if (life <= 0) instance_destroy();

if (x < -room_width || x > room_width * 2 || y < -room_height || y > room_height * 2) {
    instance_destroy();
}

scr_add_light(x, y, ring_color, 0.55 + birth_heat * 0.45 + max(0, ring_tier - 1) * 0.08);
