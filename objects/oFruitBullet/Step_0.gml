event_inherited();
scr_register_glow_point(x, y);
timer += 1;

if (post_reform) {
    var _old_x_post = x;
    var _old_y_post = y;
    var _post_spin_sign = 1;
    if (sweep_speed < 0) _post_spin_sign = -1;
    sweep_angle += max(2, abs(sweep_speed)) * _post_spin_sign;

    if (fruit_imploding) {
        var _dir_to_center = point_direction(x, y, 400, 304);
        direction = _dir_to_center;

        fruit_implosion_speed_mult = lerp(fruit_implosion_speed_mult, fruit_implosion_speed_mult_target, 0.04);

        fruit_implosion_timer += 1;
        var _fi_ramp = clamp(fruit_implosion_timer / _k_fruit_impl_ramp_frames, 0, 1);
        var _fi_accel = _k_fruit_impl_accel
                      * (_k_fruit_impl_accel_floor + (1 - _k_fruit_impl_accel_floor) * _fi_ramp * _fi_ramp);
        speed = min(speed + _fi_accel * fruit_implosion_speed_mult, _k_fruit_impl_max_speed);

        var _dist_to_center = point_distance(x, y, 400, 304);
        var _shrink = clamp((_dist_to_center - 20) / 200, 0, 1);
        var _impl_scale = max(0.1, _shrink) * 1.15;
        image_xscale = _impl_scale;
        image_yscale = _impl_scale;
        image_alpha = max(image_alpha, 0.2);
        fruit_seed_heat = 1.35;
        fruit_seed_ring_power = 1.45;

        if (_dist_to_center < 20) {
            instance_destroy();
            exit;
        }
    } else {
        if (speed_up && speed < speed_up_max) {
            speed += speed_up_amount;
        }
        if (is_curving) {
            direction += curve_amount;
        }
        image_xscale = lerp(image_xscale, 1.15, 0.12);
        image_yscale = lerp(image_yscale, 1.15, 0.12);
        fruit_seed_heat = lerp(fruit_seed_heat, 1.1, 0.08);
        fruit_seed_ring_power = lerp(fruit_seed_ring_power, 1.25, 0.08);
    }

    image_angle = direction + 90;

    var _post_moved = point_distance(_old_x_post, _old_y_post, x, y);
    if (_post_moved > 0.2) {
        array_insert(trail_history, 0, {
            x : x,
            y : y,
            ang : image_angle,
            heat : clamp(fruit_seed_heat, 0.4, 1.4)
        });

        if (array_length(trail_history) > trail_length) {
            array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
        }
    }

    if (x < -room_width || x > room_width * 2 || y < -room_height || y > room_height * 2) {
        instance_destroy();
    }

    exit;
}

sweep_angle += sweep_speed;

var _old_x = x;
var _old_y = y;

var _cos = dcos(sweep_angle);
var _sin = dsin(sweep_angle);
x = anchor_x + bar_offset * _cos;
y = anchor_y + bar_offset * _sin;

image_angle = sweep_angle + 90;

var _moved = point_distance(_old_x, _old_y, x, y);
if (_moved > 0.2) {
    array_insert(trail_history, 0, {
        x : x,
        y : y,
        ang : image_angle,
        heat : clamp(timer / max(life, 1), 0.25, 1)
    });

    if (array_length(trail_history) > trail_length) {
        array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
    }
}

if (timer == 20 && bar_offset == 0 && instance_exists(oAvoidanceController)) {
    with (oAvoidanceController) {
        array_push(fruit_bursts, { x: other.anchor_x, y: other.anchor_y, timer: 0, duration: 18 });
        array_push(fruit_shockwaves, { x: other.anchor_x, y: other.anchor_y, radius: 0, max_radius: 100, alpha: 1.0 });

        var _streak_count = 6;
        for (var s = 0; s < _streak_count; s++) {
            array_push(fruit_streaks, {
                x: other.anchor_x, y: other.anchor_y,
                angle: (360 / _streak_count) * s + random_range(-10, 10),
                len: 0, max_len: random_range(30, 50),
                timer: 0, duration: 14
            });
        }
    }
}

if (!reforming && timer >= life) {
    reforming = true;
    reform_timer = 0;
    is_center = (bar_offset == 0);
    reform_start_offset = bar_offset;
    sweep_speed_start = sweep_speed;
}

if (reforming) {
    reform_timer += 1;
    var _rp = clamp(reform_timer / reform_duration, 0, 1);
    var _eased = 1 - power(1 - _rp, 3);

    sweep_speed = lerp(sweep_speed_start, 0, _eased);

    bar_offset = lerp(reform_start_offset, 0, _eased);

    image_blend = merge_color(fruit_color, c_white, _eased * 0.8);
    var _coalesce_scale = 1 + _eased * 0.4;
    image_xscale = _coalesce_scale;
    image_yscale = _coalesce_scale;

    if (_rp >= 1) {
        if (is_center) {

            post_reform = true;
            reforming = false;
            timer = 0;
            life = 999999;
            x = anchor_x;
            y = anchor_y;
            bar_offset = 0;
            sweep_speed = 4;
            speed = 0.1;
            speed_up = true;
            speed_up_max = 14;
            speed_up_amount = 0.7;
            direction = 270;
            is_curving = true;
            curve_amount = choose(0.2, -0.2);
            image_alpha = 1;
            image_blend = fruit_color;
            image_xscale = 1.25;
            image_yscale = 1.25;
            fruit_seed_heat = 1.25;
            fruit_seed_ring_power = 1.35;

            if (instance_exists(oAvoidanceController)) {
                with (oAvoidanceController) {
                    array_push(fruit_bursts, {x : other.anchor_x, y : other.anchor_y, timer : 0, duration : 14});
                    array_push(fruit_shockwaves, {x : other.anchor_x, y : other.anchor_y, radius : 6, max_radius : 58, alpha : 0.65});

                    for (var hs = 0; hs < 4; hs++) {
                        array_push(fruit_streaks, {
                            x : other.anchor_x,
                            y : other.anchor_y,
                            angle : 270 + random_range(-18, 18),
                            len : 0,
                            max_len : random_range(42, 74),
                            timer : 0,
                            duration : 14,
                            color : merge_color(c_red, c_white, 0.25),
                            fringe : true
                        });
                    }
                }
            }
            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 3);
            }
        } else if (instance_exists(oAvoidanceController)) {

            with (oAvoidanceController) {
                array_push(fruit_shockwaves, {x : other.anchor_x, y : other.anchor_y, radius : 4, max_radius : 30, alpha : 0.5});
            }
        }
        if (!is_center) instance_destroy();
    }
}
