x += lengthdir_x(move_speed, move_dir);
y += lengthdir_y(move_speed, move_dir);

if (muzzle_flash_timer < _k_muzzle_flash_duration) {
    muzzle_flash_timer++;
}

beam_heat = max(0, beam_heat - _k_beam_heat_decay);

beam_phase++;
beam_born++;

if (instance_exists(oAvoidanceController)) {
    with (oAvoidanceController) {
        other._k_beam_w_bloom = laser_beam_w_bloom;
        other._k_beam_w_halo  = laser_beam_w_halo;
        other._k_beam_w_glow  = laser_beam_w_glow;
        other._k_beam_w_core  = laser_beam_w_core;

        other._k_beam_a_bloom = laser_beam_a_bloom;
        other._k_beam_a_halo  = laser_beam_a_halo;
        other._k_beam_a_glow  = laser_beam_a_glow;
        other._k_beam_a_core  = laser_beam_a_core;

        other._k_beam_ripple_freq  = laser_beam_bead_freq;
        other._k_beam_ripple_speed = laser_beam_bead_speed;
        other._k_beam_ripple_depth = laser_beam_bead_depth;

        other._k_beam_fil_frac = laser_beam_fil_frac;
        other._k_beam_fil_wave = laser_beam_fil_wave;
        other._k_beam_fil_w    = laser_beam_fil_w;

        other._k_beam_packet_gap   = laser_beam_packet_gap;
        other._k_beam_packet_speed = laser_beam_packet_speed;
        other._k_beam_packet_len   = laser_beam_packet_len;
        other._k_beam_packet_a     = laser_beam_packet_a;
        other._k_beam_tick_a       = laser_beam_tick_a;

        other._k_beam_lead_squash  = laser_beam_lead_squash;
        other._k_beam_wake_stretch = laser_beam_wake_stretch;
        other._k_beam_rim_a        = laser_beam_rim_a;

        other._k_beam_trail_len = laser_beam_trail_len;
        other._k_beam_trail_a   = laser_beam_trail_a;
        other._k_beam_blade_arc = laser_beam_blade_arc;
        other._k_beam_split     = laser_beam_split;
        other._k_beam_gain      = laser_beam_gain;
    }
}

var _arc_rate = _k_beam_arc_chance * (0.5 + beam_heat * 1.6);
var _arc_n = floor(_arc_rate);
if (random(1) < frac(_arc_rate)) _arc_n++;

var _arc_span = _k_beam_draw_half * (is_rotating ? extend : 1) * 0.92;
for (var _as = 0; _as < _arc_n; _as++) {
    if (array_length(beam_arcs) >= _k_beam_arc_max) break;
    array_push(beam_arcs, {
        d        : random_range(-_arc_span, _arc_span),
        side     : choose(-1, 1),
        reach    : random_range(_k_beam_arc_reach * 0.35, _k_beam_arc_reach) * (0.7 + beam_heat * 0.5),
        skew     : random_range(-30, 30),
        life     : _k_beam_arc_life,
        max_life : _k_beam_arc_life,
        offs     : scr_bolt_offsets(3, 7)
    });
}
for (var _ai = array_length(beam_arcs) - 1; _ai >= 0; _ai--) {
    beam_arcs[_ai].life--;
    if (beam_arcs[_ai].life <= 0) array_delete(beam_arcs, _ai, 1);
}

var _fb_half = _k_beam_draw_half * (is_rotating ? extend : 1);
if (_fb_half >= 2) {
    var _fb_ax = image_angle - 90;
    var _fb_col = merge_color(beam_col_outer, beam_col_core, 0.25 + beam_heat * 0.2);
    var _fb_pow = _k_beam_light_power * (1 + beam_heat * 0.5);

    for (var _li = 0; _li <= _k_beam_light_samples; _li++) {
        var _lf = (_li / _k_beam_light_samples) * 2 - 1;
        var _lx = x + lengthdir_x(_fb_half * _lf, _fb_ax);
        var _ly = y + lengthdir_y(_fb_half * _lf, _fb_ax);
        if (_lx < -60 || _lx > room_width + 60) continue;
        if (_ly < -60 || _ly > room_height + 60) continue;

        scr_add_light(_lx, _ly, _fb_col, _fb_pow);
        scr_register_glow_point(_lx, _ly);
    }
}

array_push(trail_positions, [x, y]);
while (array_length(trail_positions) > _k_beam_trail_len) array_delete(trail_positions, 0, 1);

if (is_rotating) {
    image_angle += rotate_speed;

    motion_speed = abs(degtorad(rotate_speed)) * _k_beam_half_length * extend;
    motion_dir = (image_angle - 90) + 90 * sign(rotate_speed);

    _k_blade_trail_len = clamp(ceil(_k_beam_blade_arc / max(abs(rotate_speed), 0.15)), 3, 30);

    array_push(trail_angles, image_angle);
    while (array_length(trail_angles) > _k_blade_trail_len) array_delete(trail_angles, 0, 1);

    image_yscale = extend;
} else {
    motion_speed = abs(move_speed);
    motion_dir = move_dir + ((move_speed < 0) ? 180 : 0);
}

var _beam_axis = image_angle - 90;
if (instance_exists(oAvoidanceController)) {
    var _spark_rate = _k_cut_spark_rate * (0.5 + beam_heat * 1.4);
    var _spark_n = floor(_spark_rate);
    if (random(1) < frac(_spark_rate)) _spark_n++;

    var _deployed = _k_beam_half_length * extend;

    for (var _cs = 0; _cs < _spark_n; _cs++) {
        var _along = random_range(-1, 1) * _deployed * _k_cut_spark_spread;
        var _sx = x + lengthdir_x(_along, _beam_axis);
        var _sy = y + lengthdir_y(_along, _beam_axis);

        var _sang, _sspd;
        if (is_rotating) {
            var _side = (_along >= 0) ? 1 : -1;
            _sang = _beam_axis - 90 * sign(rotate_speed) * _side + random_range(-40, 40);
            var _radial = (_deployed > 1) ? abs(_along) / _deployed : 0;
            _sspd = random_range(1, 2.5 + beam_heat * 3) * (0.4 + _radial * 1.8);
        } else {
            _sang = move_dir + 180 + random_range(-70, 70);
            _sspd = random_range(1, 2.5 + beam_heat * 3);
        }

        array_push(oAvoidanceController.arrow_ring_particles, {
            x : _sx, y : _sy,
            vx : lengthdir_x(_sspd, _sang), vy : lengthdir_y(_sspd, _sang),
            life : 8 + irandom(12), max_life : 20,
            size : random_range(0.05, 0.09 + beam_heat * 0.08),
            grav : 0.11, drag : 0.93, hot : random_range(0.82, 1)
        });
    }
}

if (!exit_done && instance_exists(oAvoidanceController)) {
    var _past = (x < -_k_exit_margin) || (x > room_width + _k_exit_margin) ||
                (y < -_k_exit_margin) || (y > room_height + _k_exit_margin);
    if (_past) {
        exit_done = true;

        var _ix = clamp(x, 0, room_width);
        var _iy = clamp(y, 0, room_height);
        var _kc = kill_count;
        var _iang = image_angle - 90;
        var _ihalf = _k_beam_half_length;
        var _icol = beam_col_outer;

        with (oAvoidanceController) {
            array_push(ring_shockwaves, {
                x : _ix, y : _iy,
                radius : 10, max_radius : 200 + _kc * 12,
                life : 20, max_life : 20,
                width : 20, hot : 0.7, vs : 1
            });

            if (array_length(laser_beam_scars) >= _k_laser_scar_max) array_delete(laser_beam_scars, 0, 1);
            array_push(laser_beam_scars, {
                x : _ix, y : _iy,
                ang : _iang,
                half_len : _ihalf,
                alpha : 0.85,
                col : _icol
            });
        }

        scr_impact_pulse(0.16, 0.3, 0.28, _ix, _iy);
        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 5);
        }
    }
}

if (
    x < -room_width || x > room_width * 2 ||
    y < -room_height || y > room_height * 2
) {
    instance_destroy();
}

var half_len = _k_beam_half_length * extend;

var _sweep_n = 1;
if (is_rotating && half_len > 1 && rotate_speed != 0) {
    var _tip_arc = abs(degtorad(rotate_speed)) * half_len;
    _sweep_n = clamp(ceil(_tip_arc / _k_orb_sweep_step), 1, _k_orb_sweep_max);
}

var _perp_step = (_sweep_n > 1) ? 10 : 4;

for (var _ss = 1; _ss <= _sweep_n; _ss++) {
    var hit_angle = (is_rotating ? (image_angle - rotate_speed * (1 - _ss / _sweep_n))
                                 : image_angle) - 90;

    for (var i = -_k_orb_check_width * 0.5; i <= _k_orb_check_width * 0.5; i += _perp_step) {
	var ox = lengthdir_x(i, hit_angle + 90);
	var oy = lengthdir_y(i, hit_angle + 90);
    var sx = x + ox - lengthdir_x(half_len, hit_angle);
    var sy = y + oy - lengthdir_y(half_len, hit_angle);
    var ex = x + ox + lengthdir_x(half_len, hit_angle);
    var ey = y + oy + lengthdir_y(half_len, hit_angle);

    var list = ds_list_create();
    collision_line_list(sx, sy, ex, ey, oLaserOrb_Pop, false, true, list, false);
	for (var j = 0; j < ds_list_size(list); ++j) {
	        with (list[| j]) {
	            if (!is_popped && laser_pop_enabled) {
	                scr_pop_laser_orb(id);
	                if (other.apply_gravity_on_pop) {
	                    gravity_activated = true;
	                    gravity_direction = other.gravity_dir_to_apply;
	                    gravity = other._k_gravity_strength;
	                }

	                other.beam_heat = min(other.beam_heat + other._k_beam_heat_per_kill, other._k_beam_heat_max);
	                other.kill_count++;

	                if (instance_exists(oAvoidanceController)) {
	                    var _kill_axis = other.image_angle - 90;
	                    for (var _ks = 0; _ks < 5; _ks++) {
	                        var _kang = _kill_axis + choose(0, 180) + random_range(-38, 38);
	                        var _kspd = random_range(2, 6);
	                        array_push(oAvoidanceController.arrow_ring_particles, {
	                            x : x, y : y,
	                            vx : lengthdir_x(_kspd, _kang), vy : lengthdir_y(_kspd, _kang),
	                            life : 9 + irandom(11), max_life : 20,
	                            size : random_range(0.06, 0.15),
	                            grav : 0.15, drag : 0.92, hot : random_range(0.85, 1)
	                        });
	                    }
	                }
	            }
	        }
	    }
    ds_list_destroy(list);
    }
}
