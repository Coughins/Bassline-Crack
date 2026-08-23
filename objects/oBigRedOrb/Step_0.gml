event_inherited();
scr_register_glow_point(x, y);
if (transitioning)
{
    trans_timer++;
    orbit_angle += orbit_speed * orbit_dir;

    var _base_x = lengthdir_x(orbit_radius, orbit_angle);
    var _base_y = lengthdir_y(orbit_radius, orbit_angle) * orbit_squash;
    var _target_x = orbit_center_x + (_base_x * cos(orbit_tilt_rad) - _base_y * sin(orbit_tilt_rad));
    var _target_y = orbit_center_y + (_base_x * sin(orbit_tilt_rad) + _base_y * cos(orbit_tilt_rad));

    var _t = clamp(trans_timer / trans_duration, 0, 1);
    var _eased = 1 - power(1 - _t, 3);

    x = lerp(trans_start_x, _target_x, _eased);
    y = lerp(trans_start_y, _target_y, _eased);
    speed = 0;

    if (_t >= 1)
    {
        transitioning = false;
        orbiting = true;
    }
}
else if (orbiting)
{
    orbit_angle += orbit_speed * orbit_dir;

    var _base_x = lengthdir_x(orbit_radius, orbit_angle);
    var _base_y = lengthdir_y(orbit_radius, orbit_angle) * orbit_squash;

    x = orbit_center_x + (_base_x * cos(orbit_tilt_rad) - _base_y * sin(orbit_tilt_rad));
    y = orbit_center_y + (_base_x * sin(orbit_tilt_rad) + _base_y * cos(orbit_tilt_rad));

    speed = 0;
}

if (pop_scale != pop_target)
{
    var _was_shrinking_toward_target = (pop_target < pop_scale);
    pop_scale = lerp(pop_scale, pop_target, pop_speed);

    if (abs(pop_scale - pop_target) < 0.05)
    {
        pop_scale = pop_target;
    }

    if (_was_shrinking_toward_target && !pop_shrinking)
    {
        pop_shrinking = true;
        squash_x = 1.25;
        squash_y = 0.8;
        pop_trail_active = true;
    }

    image_xscale = pop_scale * squash_x;
    image_yscale = pop_scale * squash_y;

    squash_x = lerp(squash_x, 1, 0.15);
    squash_y = lerp(squash_y, 1, 0.15);
}
else
{
    pop_shrinking = false;
    pop_trail_active = false;
    image_xscale = pop_scale * squash_x;
    image_yscale = pop_scale * squash_y;
}


if (dash_time > 0)
{
    is_dashing = true;
    x += lengthdir_x(dash_speed, dash_dir);
    y += lengthdir_y(dash_speed, dash_dir);
    dash_speed *= 0.85;
    dash_time--;
}
else
{
    is_dashing = false;
}

if (telegraph_timer > 0) telegraph_timer--;

vel_x = x - prev_x;
vel_y = y - prev_y;
vel_mag = point_distance(0, 0, vel_x, vel_y);
if (vel_mag > 0.01) vel_dir = point_direction(0, 0, vel_x, vel_y);
prev_x = x;
prev_y = y;

if (is_dashing || pop_trail_active || vel_mag > 2.5)
{
    var _samples = 1 + min(3, floor(vel_mag / 16));
    var _stretch = 1 + clamp(vel_mag / 9, 0, 1) * 2.6;
    var _from_x = x - vel_x;
    var _from_y = y - vel_y;

    for (var _sm = 1; _sm <= _samples; _sm++)
    {
        if (array_length(trail_positions) >= _k_orb_trail_max) array_delete(trail_positions, 0, 1);
        var _u = _sm / _samples;
        array_push(trail_positions, {
            px : lerp(_from_x, x, _u), py : lerp(_from_y, y, _u),
            life : 1 - (1 - _u) * 0.12,
            stretch : _stretch,
            ang : vel_dir,
            sc : image_xscale
        });
    }
}

for (var i = array_length(trail_positions) - 1; i >= 0; i--)
{
    trail_positions[i].life -= 0.1;
    if (trail_positions[i].life <= 0)
    {
        array_delete(trail_positions, i, 1);
    }
}

cell_spin += cell_spin_speed * (1 + clamp(vel_mag / 6, 0, 2.2));
if (gather < 1) gather = min(1, gather + 0.085);
seam_charge = max(0, seam_charge - 0.05);
shell_open  = max(0, shell_open - 0.09);
lock_pulse  = max(0, lock_pulse - 0.1);

if (released && abs(released_curl) > 0.02) {
    direction += released_curl;
    image_angle = direction;
    released_curl *= 0.9;
}

beat_flash = max(0, beat_flash - 0.06);
birth_flash = max(0, birth_flash - 0.08);

if (shockwave_timer >= 0)
{
    shockwave_timer++;
    if (shockwave_timer > shockwave_max_frames) shockwave_timer = -1;
}
