event_inherited();
scr_register_glow_point(x, y);
if (depth_grow_timer < depth_grow_duration)
{
    depth_grow_timer += 1;
    var _p = depth_grow_timer / depth_grow_duration;
    var _eased = 1 - power(1 - _p, 2);

    var _target_scale = lerp(0.6, 2.5, clamp((spawn_scale - 0.5) / 0.7, 0, 1));
    var _current_scale = lerp(spawn_scale * 0.6, _target_scale, _eased);

    image_xscale = _current_scale;
    image_yscale = _current_scale;
    image_alpha = lerp(spawn_scale, 1, _eased);
}

hit_active = image_alpha > hit_alpha_min && abs(image_xscale) > 0.25 && abs(image_yscale) > 0.25;

if (x < -50 || x > room_width + 50 || y < -50 || y > room_height + 50) {
    instance_destroy();
}

if (last_pulse_id != oHoneycombController.bass_pulse_id)
{
    last_pulse_id = oHoneycombController.bass_pulse_id;

    pulse_timer = 8;
    pulse_scale = 1.2;
}


if (pulse_timer > 0)
{
    pulse_timer--;
}
else
{
    pulse_scale = lerp(pulse_scale, 1, 0.25);
}
