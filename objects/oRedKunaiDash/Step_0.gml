event_inherited();
scr_register_glow_point(x, y);

if (x < -room_width || x > room_width * 2 || y < -room_height || y > room_height * 2) {
    instance_destroy();
    exit;
}

var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;

prev_x = x;
prev_y = y;

if (spawn_pop > 0) {
    spawn_pop = max(0, spawn_pop - 0.12);
    var _sp = 1 - spawn_pop;
    var _spe = 1 - power(1 - _sp, 3);
    image_alpha = _spe;
} else {
    image_alpha = 1;
}

var _coil = (_ctrl != noone) ? _ctrl.kdash_coil : 0;

var _coil_hold = 0;

if (telegraphing && picked && _coil > 0) {
    telegraph_pulse = (sin(coil_seed + _coil * 34) * 0.5 + 0.5) * _coil;

    _coil_hold = _coil * 0.82;
    hitch = lerp(hitch, _coil * 3.5, 0.35);
} else {
    telegraph_pulse = lerp(telegraph_pulse, 0, 0.25);
    hitch = lerp(hitch, 0, 0.4);
}

if (dash_time > 0) {
    is_dashing = true;
    speed = dash_speed;
    image_index = 0;
    dash_speed = lerp(dash_speed, fall_speed, 0.15);
    dash_time--;
    hot = 1;

    ghost_timer++;
    if (_ctrl != noone && ghost_timer mod 2 == 0 && array_length(_ctrl.kdash_ghosts) < _ctrl._k_kdash_ghost_cap) {
        array_push(_ctrl.kdash_ghosts, {
            x : x, y : y,
            ang : image_angle,
            sx : image_xscale,
            sy : image_yscale,
            alpha : 0.55,
            fade : 0.055,
            hot : 0.9
        });
    }

    array_push(trail_positions, { px : x, py : y, life : 1, ang : image_angle, hot : 1 });
} else {
    is_dashing = false;
    speed = fall_speed * (1 - _coil_hold);
    image_index = 5;
    ghost_timer = 0;
    hot = lerp(hot, clamp((fall_speed - 8) / 18, 0, 0.55) + telegraph_pulse * 0.5, 0.15);
}

for (var i = array_length(trail_positions) - 1; i >= 0; i--) {
    trail_positions[i].life -= 0.11;
    trail_positions[i].hot *= 0.93;
    if (trail_positions[i].life <= 0) array_delete(trail_positions, i, 1);
}

direction = 270;
image_angle = direction;

if (pop_scale != pop_target) {
    pop_scale = lerp(pop_scale, pop_target, pop_speed);
    if (pop_overshoot && abs(pop_scale - pop_target) < 0.05) {
        pop_scale = pop_target - 0.1;
        pop_target = 1;
        pop_overshoot = false;
    }
}

var _base_scale = pop_scale * lerp(0.45, 1, 1 - spawn_pop);
image_xscale = _base_scale;
image_yscale = _base_scale;

travel_len = speed;
var _stretch = clamp(travel_len / 26, 0, 1.4);
var _stretch_y_mult = is_dashing ? 1.5 : 0.5;
var _stretch_x_mult = is_dashing ? 0.28 : 0.08;
image_yscale = _base_scale * (1 + _stretch * _stretch_y_mult);
image_xscale = _base_scale * (1 - _stretch * _stretch_x_mult);

if (pop_flash > 0) {
    pop_flash -= 0.06;
    if (pop_flash < 0) pop_flash = 0;
}
hit_active = image_alpha > 0.45 && abs(image_xscale) > 0.25 && abs(image_yscale) > 0.25;

if (_ctrl != noone && _ctrl.kdash_active) {
    var _floor_y = _ctrl._k_kunai_floor_y;
    var _next_y = y + lengthdir_y(speed, direction);

    if (y >= _floor_y || _next_y >= _floor_y) {
        var _hit_speed = max(speed, 6);
        var _fx = x;

        with (_ctrl) {
            if (array_length(kdash_scars) >= _k_kdash_scar_cap) array_delete(kdash_scars, 0, 1);
            array_push(kdash_scars, {
                x : _fx,
                y : _k_kunai_floor_y,
                span : 26 + _hit_speed * 1.45,
                life : 24 + irandom(10),
                life_max : 34,
                heat : clamp(_hit_speed / 26, 0.35, 1),
                nick : random_range(-5, 5),
                seed : random(1000)
            });

            if (array_length(kdash_impacts) < _k_kdash_impact_cap) {
                array_push(kdash_impacts, {
                    x : _fx, y : _k_kunai_floor_y,
                    radius : 3,
                    max_radius : 24 + _hit_speed * 1.7,
                    life : 16, max_life : 16,
                    hot : clamp(_hit_speed / 24, 0.35, 1)
                });

                array_push(kdash_shards, {
                    x : _fx, y : _k_kunai_floor_y - 5,
                    ang : 270 + random_range(-16, 16),
                    wobble : random_range(7, 16) * choose(-1, 1),
                    phase : random(6.28),
                    life : 26 + irandom(20), max_life : 46,
                    scale : 0.5
                });
            }

            repeat (3 + irandom(3)) {
                var _sa = choose(0, 180) + random_range(-46, 46);
                var _ss = random_range(2, 5 + _hit_speed * 0.25);
                array_push(arrow_ring_particles, {
                    x : _fx, y : _k_kunai_floor_y,
                    vx : lengthdir_x(_ss, _sa),
                    vy : -abs(lengthdir_y(_ss, _sa)) * 0.7,
                    life : 15, max_life : 15,
                    size : random_range(0.06, 0.17),
                    grav : 0.22, drag : 0.94,
                    hot : 0.5
                });
            }

            if (_hit_speed > 16 && irandom(2) == 0) {
                array_push(ring_embers, {
                    x : _fx, y : _k_kunai_floor_y - 3,
                    vx : random_range(-1.2, 1.2),
                    vy : random_range(-2.6, -0.6),
                    life : 30 + irandom(22), max_life : 52,
                    size : random_range(0.06, 0.15),
                    hot : 0.55 + random(0.35)
                });
            }

            if (_hit_speed > 16) {
                scr_floor_impact(_fx, _k_kunai_floor_y, 0.2 + (_hit_speed - 16) * 0.02, 0);
            }

            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 1.2 + _hit_speed * 0.08);
            }
        }

        scr_add_light(x, _floor_y, c_red, _hit_speed > 16 ? 3 : 1.5);
        instance_destroy();
        exit;
    }
}

scr_add_light(x, y, c_red, 0.8 + hot * 1.2);
