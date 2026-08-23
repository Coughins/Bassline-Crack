event_inherited();
image_angle = direction;
scr_register_glow_point(x, y);
if (rewinding)
{

    var _tear = oAvoidanceController.tear_amount;
    var _rgb_offset_max_scaled = _k_rgb_offset_max * _tear;
    var _stutter_freeze_chance_scaled = clamp(_k_stutter_freeze_chance * (_tear / 1.0), 0, 0.6);

    rgb_reroll_timer -= 1;
    if (rgb_reroll_timer <= 0)
    {
        rgb_offset_x = random_range(-_rgb_offset_max_scaled, _rgb_offset_max_scaled);
        rgb_offset_y = random_range(-_rgb_offset_max_scaled, _rgb_offset_max_scaled);
        rgb_reroll_timer = _k_rgb_offset_reroll_frames;
    }

    if (array_length(position_history) > 0)
    {
        if (random(1) < _stutter_freeze_chance_scaled)
        {

            glitch_flash_alpha = 0.15;
        }
        else
        {

            var _snap_count = irandom_range(_k_stutter_snap_min, _k_stutter_snap_max);
            var _last_pos = position_history[array_length(position_history) - 1];
            for (var i = 0; i < _snap_count; i++)
            {
                if (array_length(position_history) <= 0) break;
                _last_pos = position_history[array_length(position_history) - 1];
                array_delete(position_history, array_length(position_history) - 1, 1);
            }
            x = _last_pos[0];
            y = _last_pos[1];

            glitch_flash_alpha = random_range(0.5, 1.0);
        }
    }

    image_alpha = glitch_flash_alpha;

    rewind_frames_left -= 1;
    if (rewind_frames_left <= 0)
    {
        rewinding = false;
        image_alpha = 1;
        rgb_offset_x = 0;
        rgb_offset_y = 0;
        trail_positions = [];
    }
}
else
{
    capture = 0;
    capture_target = noone;

    with (oBlackHole)
    {
        var _d = point_distance(other.x, other.y, x, y);
        if (_d < pull_radius && _d > 4)
        {
            var _dir_to_hole = point_direction(other.x, other.y, x, y);
            if (oAvoidanceController.blackhole_push_mode) {
                _dir_to_hole += 180;
            }
            var _falloff = 1 - (_d / pull_radius);
            var _turn_amount = pull_strength * _falloff * 15;
            var _diff = angle_difference(_dir_to_hole, other.direction);
            other.direction += clamp(_diff, -_turn_amount, _turn_amount);

            var _cap = clamp(1 - (_d / (pull_radius * 0.75)), 0, 1);
            if (_cap > other.capture) {
                other.capture = _cap;
                other.capture_target = id;
            }
        }
    }

    array_push(position_history, [x, y]);
    if (array_length(position_history) > 46) array_delete(position_history, 0, 1);

    array_push(trail_positions, [x, y]);
    if (array_length(trail_positions) > trail_max) array_delete(trail_positions, 0, 1);

    stretch = lerp(stretch, 1 + point_distance(prev_x, prev_y, x, y) * 0.16 + capture * 2.4, 0.35);
    prev_x = x;
    prev_y = y;

    var _pull_accel = oAvoidanceController.blackhole_push_mode ? (1 + capture * 0.4) : (1 + capture * 0.8);
    x += lengthdir_x(speed * _pull_accel, direction);
    y += lengthdir_y(speed * _pull_accel, direction);

    if (!oAvoidanceController.blackhole_push_mode && instance_exists(capture_target))
    {
        var _ct = capture_target;
        if (point_distance(x, y, _ct.x, _ct.y) <= _ct.core_radius * 1.7 * max(_ct.spawn_scale, 0.01))
        {
            var _in_angle = point_direction(_ct.x, _ct.y, x, y);

            _ct.feed_charge = min(1.4, _ct.feed_charge + 0.34);
            _ct.feed_flash = 1;
            _ct.feed_streak_angle = _in_angle;
            _ct.swallow_count += 1;

            array_push(oAvoidanceController.bh_swallow_flashes, {
                x : _ct.x, y : _ct.y,
                ang : _in_angle,
                life : 16, life_max : 16,
                color : merge_color(global.lightning_color, c_white, 0.6)
            });

            oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, 0.22);
            oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, 0.18);
            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 3.5);
            }
            scr_add_light(_ct.x, _ct.y, c_white, 6);

            instance_destroy();
            exit;
        }
    }
}

inverted_flash = max(0, inverted_flash - 0.08);

if (x < -50 || x > room_width + 50 || y < -50 || y > room_height + 50) {
    instance_destroy();
}
