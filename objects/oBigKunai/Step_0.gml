scr_register_glow_point(x, y);

if (absorb_kick > 0) {
    absorb_scale_vel += absorb_kick * 0.85;
    absorb_flash = max(absorb_flash, absorb_kick);
    absorb_kick = 0;
}
absorb_scale_vel += (0 - absorb_scale) * 0.25;
absorb_scale_vel *= 0.80;
absorb_scale += absorb_scale_vel;
absorb_flash = max(0, absorb_flash - 0.08);

if (!built) {
	var _progress = clamp(charge / charge_needed, 0, 1);
    image_alpha = 0.1 + _progress * 0.9;
    var _scale = lerp(1, 5, _progress);
    image_xscale = _scale + absorb_scale;
    image_yscale = _scale + absorb_scale;

} else {
    var _spark_source_dir = current_tangent_dir;
    var _spark_intensity = last_boost;

    if (!deorbiting) {
        var _prev_x = x;
        var _prev_y = y;

        orbit_angle = base_orbit_offset + oAvoidanceController.shared_orbit_angle;

		last_boost = clamp(
		            (oAvoidanceController.orbit_speed_current - oAvoidanceController.orbit_speed_min_ever)
		            / (oAvoidanceController.orbit_speed_max_ever - oAvoidanceController.orbit_speed_min_ever),
		        0, 1);

        x = orbit_center_x + dcos(orbit_angle) * orbit_radius_x;
        y = orbit_center_y + dsin(orbit_angle) * orbit_radius_y;
        image_angle = point_direction(orbit_center_x, orbit_center_y, x, y);
        
		current_tangent_dir = point_direction(_prev_x, _prev_y, x, y); 
		current_tangent_speed = point_distance(_prev_x, _prev_y, x, y);
		_spark_source_dir = current_tangent_dir;
		_spark_intensity = last_boost;

        array_insert(trail_history, 0, { x: x, y: y, ang: image_angle });
        if (array_length(trail_history) > trail_length) {
            array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
        }

        kunai_emit_timer--;
        if (kunai_emit_timer <= 0) {
            var _k_kunai_interval_min = 8;
            var _k_kunai_interval_max = 5;
            var _k_kunai_count_min = 1;
            var _k_kunai_count_max = 3;
            var _k_kunai_speed_min = 6;
            var _k_kunai_speed_max = 10;
            var _k_kunai_speed_boost_mult = 1.8;
            var _k_kunai_spread_deg = 40;
            var _k_kunai_scale_min = 0.8;
            var _k_kunai_scale_max = 2.5;

            var _kcount = round(lerp(_k_kunai_count_min, _k_kunai_count_max, last_boost));
            var _kbase_speed = random_range(_k_kunai_speed_min, _k_kunai_speed_max);
            var _kspeed = _kbase_speed * lerp(1, _k_kunai_speed_boost_mult, last_boost);
            var _kscale = lerp(_k_kunai_scale_min, _k_kunai_scale_max, last_boost);
            var _ktangent_dir = current_tangent_dir;

            for (var ki = 0; ki < _kcount; ki++) {
                var _kdir = _ktangent_dir + random_range(-_k_kunai_spread_deg / 2, _k_kunai_spread_deg / 2);
                var _kspd = _kspeed * random_range(0.85, 1.15);

                with instance_create_layer(x, y, layer, oRedKunai) {
                    is_feeder = false;
                    state = "normal";
                    direction = _kdir;
                    speed = _kspd;
                    locked_direction = true;
                    target_scale = _kscale;
                }
            }

            kunai_emit_timer = round(lerp(_k_kunai_interval_max, _k_kunai_interval_min, last_boost));
        }
} else {
	    _spark_source_dir = deorbit_start_dir;
	    _spark_intensity = 1;
	    deorbit_timer++;
	    var _p = clamp(deorbit_timer / deorbit_ease_duration, 0, 1);
	    var _speed_ease = 1 - power(1 - _p, 3);
		var _fling_speed = lerp(deorbit_start_speed, deorbit_end_speed, _speed_ease);

	    x += lengthdir_x(_fling_speed, deorbit_start_dir);
	    y += lengthdir_y(_fling_speed, deorbit_start_dir);
	    image_angle = deorbit_start_dir;

	    array_insert(trail_history, 0, { x: x, y: y, ang: image_angle });
	    if (array_length(trail_history) > trail_length) {
	        array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
	    }

if (x < -1000 || x > room_width + 1000 || y < -1000 || y > room_height + 100) {
	        instance_destroy();
	    }
	}

	var _k_life_multiplier = 2;
    var _k_streak_chance_min = 0.7;
    var _k_streak_chance_max = 1.0;
    var _k_streak_count_min = 1;
    var _k_streak_count_max = 7;
    var _k_streak_speed_min = 1;
    var _k_streak_speed_max = 10;
    var _k_streak_speed_boost_mult = 3.2;
    var _k_streak_life_min = 4 * _k_life_multiplier;
    var _k_streak_life_max = 9 * _k_life_multiplier;
    var _k_streak_width_min = 1.2;
    var _k_streak_width_max = 2.4;

    var _k_ember_chance_min = 0.6;
    var _k_ember_chance_max = 1.0;
    var _k_ember_count_max = 2;
    var _k_ember_speed_min = 1;
    var _k_ember_speed_max = 20;
    var _k_ember_life_min = 16 * _k_life_multiplier;
    var _k_ember_life_max = 30 * _k_life_multiplier;
    var _k_ember_width = 1.6;

    var _k_spark_spread_deg = 75;

    var _streak_chance = lerp(_k_streak_chance_min, _k_streak_chance_max, _spark_intensity);
    if (random(1) < _streak_chance) {
        var _streak_n = max(1, round(lerp(_k_streak_count_min, _k_streak_count_max, _spark_intensity)));
        repeat (_streak_n) {
            var _s_dir = _spark_source_dir + 180 + random_range(-_k_spark_spread_deg / 2, _k_spark_spread_deg / 2);
            var _s_spd = random_range(_k_streak_speed_min, _k_streak_speed_max) * lerp(1, _k_streak_speed_boost_mult, _spark_intensity);
            var _s_life = irandom_range(_k_streak_life_min, _k_streak_life_max);
            var _s_accent_roll = random(1);
            var _s_accent_col = (_s_accent_roll < 0.82) ? undefined
                              : ((_s_accent_roll < 0.95) ? global.avoid_col_cyan : global.avoid_col_violet);
            array_push(spark_particles, {
                type: "streak",
                x: x, y: y,
                vx: lengthdir_x(_s_spd, _s_dir),
                vy: lengthdir_y(_s_spd, _s_dir),
                life: _s_life,
                max_life: _s_life,
                width: random_range(_k_streak_width_min, _k_streak_width_max),
                accent_col: _s_accent_col
            });
        }
    }

    var _ember_chance = lerp(_k_ember_chance_min, _k_ember_chance_max, _spark_intensity);
    if (random(1) < _ember_chance) {
        var _ember_n = max(1, round(lerp(0, _k_ember_count_max, _spark_intensity)));
        repeat (_ember_n) {
            var _e_dir = _spark_source_dir + 180 + random_range(-_k_spark_spread_deg / 2, _k_spark_spread_deg / 2);
            var _e_spd = random_range(_k_ember_speed_min, _k_ember_speed_max) * lerp(1, 1.6, _spark_intensity);
            var _e_life = irandom_range(_k_ember_life_min, _k_ember_life_max);
            array_push(spark_particles, {
                type: "ember",
                x: x, y: y,
                vx: lengthdir_x(_e_spd, _e_dir),
                vy: lengthdir_y(_e_spd, _e_dir),
                life: _e_life,
                max_life: _e_life,
                width: _k_ember_width
            });
        }
    }

    for (var si = array_length(spark_particles) - 1; si >= 0; si--) {
        var _sp = spark_particles[si];
        var _is_streak = (_sp.type == "streak");

        var _jitter = _is_streak ? 0.15 : 0.5;
        var _perp_dir = point_direction(0, 0, _sp.vx, _sp.vy) + 90;
        _sp.vx += lengthdir_x(_jitter, _perp_dir) * random_range(-1, 1);
        _sp.vy += lengthdir_y(_jitter, _perp_dir) * random_range(-1, 1);

        _sp.vx *= _is_streak ? 0.88 : 0.94;
        _sp.vy *= _is_streak ? 0.88 : 0.94;
        _sp.vy += _is_streak ? 0.25 : 0.45;
        _sp.x += _sp.vx;
        _sp.y += _sp.vy;
        _sp.life--;
        if (_sp.life <= 0) {
            array_delete(spark_particles, si, 1);
        }
    }
}
