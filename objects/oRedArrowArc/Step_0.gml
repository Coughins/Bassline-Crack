event_inherited();
scr_register_glow_point(x, y);
if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}

var _charge = 0;
var _heartbeat = 0;
if (instance_exists(oAvoidanceController))
{
    _charge = oAvoidanceController.arc_charge;
    _heartbeat = oAvoidanceController.arc_heartbeat;
}

if (!visible)
{
    arrow_reveal_timer++;
    if (arrow_reveal_timer >= arrow_reveal_delay)
    {
        visible = true;
        hit_active = true;
        orb_pop_flash = 1;

        orb_pop_true_angle = image_angle;
        image_angle = orb_pop_true_angle + choose(-1, 1) * orb_pop_angle_wobble;
        orb_pop_angle_settled = false;

        arrow_home_x = x;
        arrow_home_y = y;
    }
}
else
{
    if (orb_pop_scale != orb_pop_target)
    {
        orb_pop_scale = lerp(orb_pop_scale, orb_pop_target, orb_pop_speed);

        if (orb_pop_overshoot && abs(orb_pop_scale - orb_pop_target) < 0.05)
        {
            orb_pop_scale = orb_pop_target - 0.08;
            orb_pop_target = 1;
            orb_pop_overshoot = false;
        }
        else if (!orb_pop_overshoot && abs(orb_pop_scale - orb_pop_target) < 0.01)
        {
            orb_pop_scale = orb_pop_target;
        }

        image_xscale = orb_pop_scale;
        image_yscale = orb_pop_scale;
    }

    if (!orb_pop_angle_settled)
    {
        image_angle = lerp(image_angle, orb_pop_true_angle, 0.2);
        if (abs(angle_difference(image_angle, orb_pop_true_angle)) < 1)
        {
            image_angle = orb_pop_true_angle;
            orb_pop_angle_settled = true;
        }
    }

    if (orb_pop_flash > 0)
    {
        orb_pop_flash -= 0.07;
        if (orb_pop_flash < 0) orb_pop_flash = 0;
        image_blend = merge_color(c_white, orb_pop_color, 1 - orb_pop_flash);
    }

    if (!arrow_popping)
    {
        arrow_breathe = 0.5 + 0.5 * dsin((current_time * 0.09) + arrow_seed + arrow_wave_index * 40);
        var _breathe_amp = 0.04 + _charge * 0.10;
        var _idle_scale = 1 + arrow_breathe * _breathe_amp + _heartbeat * (0.06 + _charge * 0.16);

        if (arrow_locked)
        {
            arrow_lock_timer++;
            var _lock_p = clamp(arrow_lock_timer / 20, 0, 1);
            var _shake = 0.5 + _lock_p * _lock_p * 2.2;
            arrow_vibe_x = random_range(-_shake, _shake);
            arrow_vibe_y = random_range(-_shake, _shake);

            image_xscale = _idle_scale * (1 + _lock_p * 0.35);
            image_yscale = _idle_scale * (1 + _lock_p * 0.35);
            image_angle = orb_pop_true_angle;
        }
        else if (orb_pop_angle_settled && orb_pop_scale == orb_pop_target)
        {
            arrow_drift += 0.6;
            x = arrow_home_x + dcos(arrow_drift + arrow_seed) * (1.2 + _charge * 2.2);
            y = arrow_home_y + dsin((arrow_drift + arrow_seed) * 0.7) * (0.8 + _charge * 1.6);

            arrow_vibe_x = 0;
            arrow_vibe_y = 0;
            image_xscale = _idle_scale;
            image_yscale = _idle_scale;
        }
    }
}

if (arrow_laser_mode)
{
    arrow_laser_timer++;
    if (arrow_laser_timer >= arrow_laser_max_frames)
    {
        instance_destroy();
        exit;
    }
}

if (arrow_popping)
{
	arrow_pop_timer++
	arrow_vibe_x = 0;
	arrow_vibe_y = 0;

	if (arrow_pop_timer <= arrow_pop_grow_time)
	{
		var _t = arrow_pop_timer / arrow_pop_grow_time;
		var _scale = lerp(1, arrow_pop_max_scale, _t);
		image_xscale = _scale
		image_yscale = _scale
	}
	else
	{
		var _t = (arrow_pop_timer - arrow_pop_grow_time) / arrow_pop_shrink_time;
		_t = clamp(_t, 0, 1);
		var _scale = lerp(arrow_pop_max_scale, 0, _t);
		image_xscale = _scale
		image_yscale = _scale

		if (_t >= 1)
		{
			instance_destroy()
		}
	}
}
