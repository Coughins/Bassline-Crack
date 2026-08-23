event_inherited();

if (intro_rotate_mode)
{
    intro_angle += intro_rotate_speed;
}

if (intro_locked)
{
    var _r = intro_radius * radius_scale;
    x = intro_cx + lengthdir_x(_r, intro_angle);
    y = intro_cy + lengthdir_y(_r, intro_angle);

    if (jitter_amount > 0)
    {
        x += random_range(-jitter_amount, jitter_amount);
        y += random_range(-jitter_amount, jitter_amount);
    }
}

if (!revealed)
{
    if (reveal_delay > 0)
    {
        reveal_delay--;
    }
    else
    {
        revealed = true;
        image_alpha = 1;
        hit_active = true;
		image_blend = global.lightning_color;
        pop_scale = 2.5;
        pop_target = 1;
        pop_overshoot = true;
        pop_flash = 1;
        scr_register_glow_point(x, y);
    }
}

if (pop_scale != pop_target)
{
    pop_scale = lerp(pop_scale, pop_target, pop_speed);
    if (pop_overshoot && abs(pop_scale - pop_target) < 0.05)
    {
        pop_scale = pop_target - 0.12;
        pop_target = 1;
        pop_overshoot = false;
    }
    image_xscale = pop_scale;
    image_yscale = pop_scale;
}
if (pop_flash > 0)
{
    pop_flash -= 0.06;
    if (pop_flash < 0) pop_flash = 0;
}

var _moved = point_distance(prev_x, prev_y, x, y);
motion_speed = max(speed, _moved);
prev_x = x;
prev_y = y;

draw_stretch = 1 + clamp(motion_speed / _k_stretch_ref_speed, 0, 1) * _k_stretch_max;

chroma_amount = max(chroma_amount - 0.05, clamp((motion_speed - 4) / 12, 0, 1) * 0.8);

if (trail_enabled && motion_speed > 6)
{
    array_insert(trail_history, 0, { x: x, y: y, ang: image_angle, sc: image_xscale });
    if (array_length(trail_history) > trail_length)
    {
        array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
    }
}
else if (array_length(trail_history) > 0)
{
    array_delete(trail_history, array_length(trail_history) - 1, 1);
}

scr_add_light(x, y, global.lightning_color, 1.0);
