event_inherited();

if (laser_spawn_delay > 0) {
    laser_spawn_delay--;
    image_alpha = 0;
    image_xscale = 0;
    image_yscale = 0;
    hit_active = false;
    exit;
}

scr_register_glow_point(x, y);

if (spawn_flash_timer < spawn_flash_duration) {
    spawn_flash_timer++;
}

if (laser_seed_drift_active && !is_popped) {
    laser_seed_drift_timer++;
    var _drift_p = clamp(laser_seed_drift_timer / max(1, laser_seed_drift_duration), 0, 1);
    var _drift_ease = 1 - power(1 - _drift_p, 3);
    x = lerp(laser_seed_drift_start_x, laser_seed_drift_target_x, _drift_ease);

    if (_drift_p >= 1) {
        x = laser_seed_drift_target_x;
        spawn_x = x;
        laser_seed_drift_active = false;
    }
}

if (!is_popped) {
	if (materialize_timer < materialize_duration) {
        materialize_timer++;
        var _p = materialize_timer / materialize_duration;
        var _eased = 1 - power(1 - _p, 3);
        image_xscale = _eased * base_scale;
        image_yscale = _eased * base_scale;
        if (idle_alpha_max_override >= 0.5) {
            image_alpha = lerp(0.5, idle_alpha_max_override, _eased);
        } else {
            image_alpha = lerp(0, idle_alpha_max_override, _eased);
        }
    } else {
		idle_pulse_phase += _k_idle_pulse_speed;
        image_alpha = lerp(idle_alpha_min_override, idle_alpha_max_override, (sin(idle_pulse_phase) + 1) * 0.5);
        y = spawn_y + sin(idle_pulse_phase * (_k_idle_bob_speed / _k_idle_pulse_speed)) * _k_idle_bob_amount;
    }
} else {
    pop_timer++;
    if (pop_timer == 1) {
        pop_flash_timer = 1;
        image_blend = c_white;
        shockwave_active = true;
        shockwave_radius = 0;
        shockwave_max_radius = _k_shockwave_radius_base * base_scale;
        shockwave_alpha = _k_shockwave_alpha_start;
    }
	if (pop_flash_timer > 0 && pop_flash_timer < _k_pop_flash_duration) {
        pop_flash_timer++;
    }

    var _scale_mult = 1;
    var _settle_done = false;

    if (pop_timer <= _k_pop_grow_frames) {
        var _p = pop_timer / _k_pop_grow_frames;
        _scale_mult = lerp(1, _k_pop_overshoot_scale, _p);
    } else if (pop_timer <= _k_pop_grow_frames + _k_pop_settle_frames) {
        var _p2 = (pop_timer - _k_pop_grow_frames) / _k_pop_settle_frames;
        _scale_mult = lerp(_k_pop_overshoot_scale, 1, _p2);
    } else {
        _settle_done = true;
    }

    image_alpha = 1;
    image_xscale = _scale_mult * base_scale;
    image_yscale = _scale_mult * base_scale;

    if (_settle_done) {
        if (pop_persist) {
            if (gravity_activated) {
                array_push(trail_positions, [x, y]);
                if (array_length(trail_positions) > 10) array_delete(trail_positions, 0, 1);
            }
            var _k_destroy_margin_x = room_width * 2;
            var _k_destroy_margin_y = room_height * 2;
            if (
                x < -_k_destroy_margin_x || x > room_width + _k_destroy_margin_x ||
                y < -_k_destroy_margin_y || y > room_height + _k_destroy_margin_y
            ) {
                instance_destroy();
            }
        } else {
            shrink_timer++;
            var _p3 = clamp(shrink_timer / _k_pop_shrink_frames, 0, 1);
            var _s3 = lerp(1, 0, _p3) * base_scale;
            image_xscale = _s3; image_yscale = _s3;
            image_alpha = 1 - _p3;
            if (_p3 >= 1) instance_destroy();
        }
    }
}

hit_active = image_alpha > 0.25 && abs(image_xscale) > 0.25 && abs(image_yscale) > 0.25;
if (!is_popped && (idle_alpha_max_override < 0.25 || !deadly_while_idle)) hit_active = false;

if is_popped {
	scr_add_light(x, y, c_red, 1);
}
