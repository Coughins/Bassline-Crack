event_inherited();
scr_register_glow_point(x, y);
glow_timer++;

var _moved = point_distance(prev_x, prev_y, x, y);
if (_moved > 0.01) motion_dir = point_direction(prev_x, prev_y, x, y);
motion_speed = max(speed, _moved);
prev_x = x;
prev_y = y;

draw_stretch = 1 + clamp(motion_speed / _k_stretch_ref_speed, 0, 1) * _k_stretch_max;

if (pop_spawn_active) {
    pop_spawn_timer++;
    var _prog = clamp(pop_spawn_timer / pop_spawn_duration, 0, 1);
    var _eased;
    if (_prog < 0.4) {
        _eased = lerp(0, pop_spawn_overshoot_scale, _prog / 0.4);
    } else {
        _eased = lerp(pop_spawn_overshoot_scale, pop_spawn_base_scale, (_prog - 0.4) / 0.6);
    }
    image_xscale = _eased;
    image_yscale = _eased;
    if (_prog >= 1) {
        pop_spawn_active = false;
        image_xscale = pop_spawn_base_scale;
        image_yscale = pop_spawn_base_scale;
    }
}


if (spawn_pop)
{
    image_xscale = lerp(image_xscale, 1, 0.2);
    image_yscale = image_xscale;

    if (abs(image_xscale - 1) < 0.05)
    {
        image_xscale = 1;
        image_yscale = 1;
        spawn_pop = false;
    }
}



t++;


if (pulsing == 1)
{
    var c = oAvoidanceController;

    if (instance_exists(c) && c.t >= 2682)
    {
        var pulse_t = (c.t - 2682) mod 20;
        var f = pulse_t / 20;

        image_xscale = 1 + sqr(1 - f);
        image_yscale = image_xscale;
    }
    else
    {
        image_xscale = 1;
        image_yscale = 1;
    }
}


if (shrink == 1)
{
    if (image_xscale > 1)
    {
        image_xscale -= 0.2;
        image_yscale -= 0.2;
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


if (ring_pulse > 0) ring_pulse--;
if (ring_flash > 0) ring_flash = max(0, ring_flash - 0.14);

if (arrow_ring)
{
    var _charge = ring_pulse / max(ring_pulse_duration, 1);

    var _pop = 1 + power(_charge, 0.6) * 0.55;

    var _s = spawn_scale * _pop;

    image_xscale = _s;
    image_yscale = _s;

    if (instance_exists(oAvoidanceController)) {
        image_blend = merge_color(oAvoidanceController.ring_color, c_white, clamp(ring_flash, 0, 1) * 0.6);
    }

    chroma_amount = max(clamp(ring_flash, 0, 1), clamp((motion_speed - 2) / 10, 0, 1) * 0.7);
}
else
{
    chroma_amount = clamp((motion_speed - 3) / 12, 0, 1);
}

scr_add_light(x, y, c_white, 1.0);
