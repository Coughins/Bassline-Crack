event_inherited();
t++
scr_register_glow_point(x, y);
if (is_feeder) {
   if (state == "flying_out") {
	    image_angle = direction;
	    if (x < -20 || x > room_width + 20 || y < -20 || y > room_height + 20) {
	        state = "returning";
	        image_alpha = 0.1;
	        exit_x = x;
	        exit_y = y;
	        return_timer = 0;
	        speed = 0;
	        if (instance_exists(target_big_kunai)) {
	            var _mid_x = lerp(exit_x, target_big_kunai.x, 0.5);
	            var _mid_y = lerp(exit_y, target_big_kunai.y, 0.5);
	            var _perp_dir = point_direction(exit_x, exit_y, target_big_kunai.x, target_big_kunai.y) + 90;
	            curve_ctrl_x = _mid_x + lengthdir_x(150, _perp_dir);
	            curve_ctrl_y = _mid_y + lengthdir_y(150, _perp_dir);
	        }
	    }
	} else if (state == "returning") {
	    if (!instance_exists(target_big_kunai)) {
	        instance_destroy();
	        exit;
	    }
	    return_timer++;
	    var _p = clamp(return_timer / return_duration, 0, 1);
	    var _eased = _p * _p * (3 - 2 * _p);
	    var _ax = lerp(exit_x, curve_ctrl_x, _eased);
	    var _ay = lerp(exit_y, curve_ctrl_y, _eased);
	    var _bx = lerp(curve_ctrl_x, target_big_kunai.x, _eased);
	    var _by = lerp(curve_ctrl_y, target_big_kunai.y, _eased);
	    x = lerp(_ax, _bx, _eased);
	    y = lerp(_ay, _by, _eased);
	    image_alpha = lerp(0.1, 0.6, _eased);
		image_angle = point_direction(x, y, target_big_kunai.x, target_big_kunai.y);
	    if (_p >= 1) {
	        target_big_kunai.charge += 1;

	        if (instance_exists(oAvoidanceController)) {
	            var _ax = target_big_kunai.x;
	            var _ay = target_big_kunai.y;
	            var _adir = point_direction(x, y, _ax, _ay);
	            var _acharge = clamp(target_big_kunai.charge / max(target_big_kunai.charge_needed, 1), 0, 1);

	            with (oAvoidanceController) {
	                array_push(kunai_absorb_pops, {
	                    x : _ax, y : _ay,
	                    dir : _adir,
	                    life : 14, max_life : 14,
	                    hot : 0.4 + _acharge * 0.6
	                });

	                repeat (5) {
	                    var _sa = _adir + 180 + random_range(-70, 70);
	                    var _ss = random_range(1.5, 4);
	                    array_push(arrow_ring_particles, {
	                        x : _ax, y : _ay,
	                        vx : lengthdir_x(_ss, _sa),
	                        vy : lengthdir_y(_ss, _sa),
	                        life : 15, max_life : 15,
	                        size : random_range(0.08, 0.2),
	                        grav : 0.03, drag : 0.94,
	                        hot : 0.4 + _acharge * 0.5
	                    });
	                }
	            }

	            target_big_kunai.absorb_kick = 1;

	            if (instance_exists(oCameraController)) {
	                oCameraController.shake = max(oCameraController.shake, 2 + _acharge * 3);
	            }
	        }

	        instance_destroy();
	    }
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
if (is_thrown)
{
    vsp += thrown_gravity;
    hsp *= thrown_hsp_damping;
    x += hsp;
    y += vsp;
    direction = point_direction(0, 0, hsp, vsp);

if (vsp >= 0 && y >= 0)
    {
        is_thrown = false;
        locked_direction = false;
        speed = random_range(8, 12);

        spawn_timer = 0;
        image_alpha = 0;
        image_xscale = 0.2;
        image_yscale = 0.2;
    }
}

if (dash_time > 0)
{
    x += lengthdir_x(dash_speed, dash_dir);
    y += lengthdir_y(dash_speed, dash_dir);
    direction = dash_dir;
    image_angle = direction;
    dash_speed *= 0.70;
    dash_time--;
}
else if ((!is_feeder || state == "normal") && !locked_direction)
{
    direction = 270;
    image_angle = direction;
}

if (spawn_timer < spawn_duration) {
    spawn_timer++;
    var _t = spawn_timer / spawn_duration;
    var _eased = 1 - power(1 - _t, 3);
    image_alpha = _eased;
    image_xscale = lerp(0.2, target_scale, _eased);
    image_yscale = lerp(0.2, target_scale, _eased);
}

var _current_speed = is_thrown ? sqrt(hsp * hsp + vsp * vsp) : max(speed, dash_speed);
if (_current_speed > trail_speed_threshold) {
    array_insert(trail_history, 0, {
        x: x, y: y, ang: image_angle,
        sx: image_xscale, sy: image_yscale,
        hot: clamp((_current_speed - trail_speed_threshold) / 16, 0.25, 1),
        spd: _current_speed
    });
    if (array_length(trail_history) > trail_length) {
        array_delete(trail_history, trail_length, array_length(trail_history) - trail_length);
    }
} else if (array_length(trail_history) > 0) {
    array_delete(trail_history, 0, array_length(trail_history));
}

if (!is_feeder || state == "normal") {
    image_angle = direction;
}
hit_active = image_alpha > 0.45 && abs(image_xscale) > 0.25 && abs(image_yscale) > 0.25;

if (impacts_floor && !is_thrown && instance_exists(oAvoidanceController) &&
    (y >= oAvoidanceController._k_kunai_floor_y ||
     y + lengthdir_y(speed, direction) >= oAvoidanceController._k_kunai_floor_y))
{
    var _hit_speed = max(speed, 6);

    with (oAvoidanceController)
    {
        var _fx = other.x;
        var _fy = _k_kunai_floor_y;

        if (array_length(kunai_impacts) < _k_kunai_impact_cap)
        {
            array_push(kunai_impacts, {
                x : _fx, y : _fy,
                radius : 3,
                max_radius : 26 + _hit_speed * 1.6,
                life : 16, max_life : 16,
                hot : clamp(_hit_speed / 20, 0.35, 1)
            });

            array_push(kunai_shards, {
                x : _fx, y : _fy - 5,
                ang : 270 + random_range(-14, 14),
                wobble : random_range(7, 15) * choose(-1, 1),
                phase : random(6.28),
                life : 32 + irandom(22), max_life : 54,
                scale : other.image_xscale
            });
        }

        if (array_length(rain_floor_scars) >= _k_rain_floor_scar_cap) array_delete(rain_floor_scars, 0, 1);
        var _scar_seed = frac(abs(sin(_fx * 0.061 + t * 0.137)) * 43758.5453);
        array_push(rain_floor_scars, {
            x : _fx, y : _fy - 2,
            span : 18 + _hit_speed * 1.35,
            life : 28, life_max : 28,
            heat : clamp(_hit_speed / 22, 0.35, 1),
            seed : _scar_seed
        });

        repeat (4 + irandom(3))
        {
            var _sa = choose(0, 180) + random_range(-46, 46);
            var _ss = random_range(2, 5 + _hit_speed * 0.25);
            array_push(arrow_ring_particles, {
                x : _fx, y : _fy,
                vx : lengthdir_x(_ss, _sa),
                vy : -abs(lengthdir_y(_ss, _sa)) * 0.7,
                life : 16, max_life : 16,
                size : random_range(0.07, 0.18),
                grav : 0.22, drag : 0.94,
                hot : 0.5
            });
        }

        if (irandom(2) == 0)
        {
            array_push(ring_embers, {
                x : _fx, y : _fy - 3,
                vx : random_range(-1.2, 1.2),
                vy : random_range(-2.4, -0.6),
                life : 34 + irandom(24), max_life : 58,
                size : random_range(0.07, 0.16),
                hot : 0.55 + random(0.35)
            });
        }

        if (instance_exists(oCameraController))
        {
            oCameraController.shake = max(oCameraController.shake, 1.5 + _hit_speed * 0.09);
        }
    }

    scr_add_light(x, oAvoidanceController._k_kunai_floor_y, c_red, 2.0);
    instance_destroy();
    exit;
}

scr_add_light(x, y, c_red, 1.0);
