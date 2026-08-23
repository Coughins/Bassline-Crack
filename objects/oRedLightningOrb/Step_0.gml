event_inherited();
scr_register_glow_point(x, y);
image_xscale = _size
image_yscale = _size


if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}


if (orb_hit == true && shrink_destroy == 0) {
    _size = 2
    image_alpha = 1
    shrink_destroy = 1
    orb_hit = false
}
if (shrink_destroy == 1) {
    hit_active = false;
    _size -= 0.1
    if (_size <= 0) {
        instance_destroy()
    }
}

if (active) {
    fall_speed += fall_gravity;
    y += fall_speed;
    if (!shrink_destroy) hit_active = true;
}

if (active) {
    _size = lerp(image_xscale, 1, 0.2);
}

if (!active && use_rotation) {
    rotation_timer += 1;
    var _p = clamp(rotation_timer / rotation_duration, 0, 1);
    var _eased = 1 - power(1 - _p, 3);
    var _offset = lerp(180, 0, _eased);
    var _ang = base_angle + _offset;
    x = shape_cx + lengthdir_x(base_radius, _ang);
    y = shape_cy + lengthdir_y(base_radius, _ang);
}
