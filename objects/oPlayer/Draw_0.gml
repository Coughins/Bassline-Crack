var _draw_cube_wings = false;
var _cube_wing_power = 0;
var _cube_wing_heat = 0;
var _cube_wing_since = -1;

if (!dead && room == rAvoidance && instance_exists(oAvoidanceController)) {
	var _cube_ctrl = instance_find(oAvoidanceController, 0);
	var _cube_spawn_t = variable_instance_exists(_cube_ctrl, "_k_cube_t_spawn") ? _cube_ctrl._k_cube_t_spawn : 4000;
	var _cube_wing_owned = false;
	var _cube_wing_origin_t = _cube_spawn_t;

	if (variable_instance_exists(_cube_ctrl, "cube_wings_collected")) {
		_cube_wing_owned = _cube_ctrl.cube_wings_collected;
		if (_cube_wing_owned && variable_instance_exists(_cube_ctrl, "cube_wings_collect_t")) {
			_cube_wing_origin_t = _cube_ctrl.cube_wings_collect_t;
		}
	} else if (_cube_ctrl.t >= _cube_spawn_t) {
		_cube_wing_owned = true;
	}

	if (_cube_wing_owned) {
		_draw_cube_wings = true;
		_cube_wing_since = max(0, _cube_ctrl.t - _cube_wing_origin_t);
		var _cube_wing_ramp = clamp(_cube_wing_since / 18, 0, 1);
		_cube_wing_power = _cube_wing_ramp * _cube_wing_ramp * (3 - 2 * _cube_wing_ramp);

		if (variable_instance_exists(_cube_ctrl, "jr_wing_collect_flash")) {
			_cube_wing_heat += clamp(_cube_ctrl.jr_wing_collect_flash * 0.55, 0, 0.80);
		}
		if (variable_instance_exists(_cube_ctrl, "cube_charge")) {
			_cube_wing_heat += clamp(_cube_ctrl.cube_charge * 0.24, 0, 0.62);
		}
		if (variable_instance_exists(_cube_ctrl, "cube_heartbeat")) {
			_cube_wing_heat += clamp(_cube_ctrl.cube_heartbeat * 0.30, 0, 0.50);
		}
		if (variable_instance_exists(_cube_ctrl, "cube_core_flash")) {
			_cube_wing_heat += clamp(_cube_ctrl.cube_core_flash * 0.18, 0, 0.45);
		}
		if (variable_instance_exists(_cube_ctrl, "cube_detonation_flash")) {
			_cube_wing_heat += clamp(_cube_ctrl.cube_detonation_flash * 0.20, 0, 0.60);
		}
	}
} else if (!dead && room == rEnd) {
	_draw_cube_wings = true;
	_cube_wing_power = 1;
	_cube_wing_since = 9999;
	_cube_wing_heat = 0.24;

	if (instance_exists(oHubController)) {
		var _hub_ctrl = instance_find(oHubController, 0);
		_cube_wing_heat += clamp(_hub_ctrl.hub_minor_pulse * 0.08 + _hub_ctrl.hub_major_pulse * 0.20
								+ _hub_ctrl.hub_gate_charge * 0.18 + _hub_ctrl.hub_bloom_pulse * 0.10, 0, 0.72);
	}
}

if (_draw_cube_wings) {
	var _wing_black = make_color_rgb(3, 3, 3);
	var _wing_shell = make_color_rgb(13, 13, 13);
	var _wing_graphite = make_color_rgb(31, 31, 31);
	var _wing_silver = make_color_rgb(176, 176, 176);
	var _wing_light = make_color_rgb(248, 248, 248);
	var _wing_time = current_time * 0.001;
	var _wing_face = sign(facing);
	if (_wing_face == 0) _wing_face = 1;

	var _wing_base_x = floor(x) - _wing_face * 3;
	var _wing_base_y = floor(y) - 3;

	if (!variable_instance_exists(id, "cube_wing_sway_x")) {
		cube_wing_sway_x = 0;
		cube_wing_sway_y = 0;
		cube_wing_speed_smooth = 0;
		cube_wing_turn_snap = 0;
		cube_wing_lift_snap = 0;
		cube_wing_move_dir = 0;
		cube_wing_phase = random(6.28318);
		cube_wing_last_since = -1;
	}

	if (_cube_wing_since < cube_wing_last_since) {
		cube_wing_sway_x = 0;
		cube_wing_sway_y = 0;
		cube_wing_speed_smooth = 0;
		cube_wing_turn_snap = 0;
		cube_wing_lift_snap = 0;
		cube_wing_move_dir = 0;
	}
	cube_wing_last_since = _cube_wing_since;

	var _wing_dx = x - xprevious;
	var _wing_dy = y - yprevious;
	var _wing_speed = point_distance(0, 0, _wing_dx, _wing_dy);
	var _wing_speed_p = clamp(_wing_speed / 8, 0, 1);
	var _wing_move_dir = sign(_wing_dx);
	if (_wing_move_dir != 0) {
		if (cube_wing_move_dir != 0 && _wing_move_dir != cube_wing_move_dir) {
			cube_wing_turn_snap = max(cube_wing_turn_snap, clamp(0.40 + _wing_speed_p * 0.65, 0, 1));
		}
		cube_wing_move_dir = _wing_move_dir;
	}
	if (_wing_dy < -1.5) {
		cube_wing_lift_snap = max(cube_wing_lift_snap, clamp(0.18 + (-_wing_dy / 9), 0, 1));
	}

	var _wing_trail_x = -_wing_face;
	var _wing_trail_y = 0;
	if (_wing_speed > 0.05) {
		_wing_trail_x = -_wing_dx / _wing_speed;
		_wing_trail_y = -_wing_dy / _wing_speed;
	}

	cube_wing_speed_smooth = lerp(cube_wing_speed_smooth, _wing_speed_p, 0.20 + _wing_speed_p * 0.08);
	cube_wing_turn_snap = max(0, cube_wing_turn_snap * 0.83 - 0.006);
	cube_wing_lift_snap = max(0, cube_wing_lift_snap * 0.86 - 0.006);

	var _wing_target_drag_x = clamp(-_wing_dx * 0.72, -5.8, 5.8);
	var _wing_target_drag_y = clamp(-_wing_dy * 0.54, -6.4, 6.4);
	cube_wing_sway_x = lerp(cube_wing_sway_x, _wing_target_drag_x, 0.24 + _wing_speed_p * 0.08);
	cube_wing_sway_y = lerp(cube_wing_sway_y, _wing_target_drag_y, 0.24 + _wing_speed_p * 0.08);

	var _wing_deploy_p = clamp(_cube_wing_since / 18, 0, 1);
	var _wing_deploy_ease = 1 - power(1 - _wing_deploy_p, 3);
	var _wing_deploy_tuck = power(1 - _wing_deploy_ease, 2);
	var _wing_deploy_flash = clamp(1 - abs(_cube_wing_since - 6) / 11, 0, 1) * clamp(_cube_wing_since / 3, 0, 1);
	var _wing_deploy_streak = clamp(1 - (_cube_wing_since - 4) / 20, 0, 1) * clamp(_cube_wing_since / 4, 0, 1);
	var _wing_motion_p = clamp(max(_wing_speed_p, cube_wing_speed_smooth * 0.86), 0, 1);
	var _wing_snap = clamp(max(cube_wing_turn_snap, cube_wing_lift_snap) * _cube_wing_power + _wing_deploy_flash * 0.72, 0, 1);
	var _wing_streak_p = clamp(max(max(_wing_speed_p, _wing_deploy_streak), max(cube_wing_speed_smooth * 0.74, _wing_snap * 0.55)), 0, 1);
	var _wing_snap_jolt = sin(_wing_time * 25 + cube_wing_phase) * cube_wing_turn_snap;
	var _wing_drag_x = cube_wing_sway_x + _wing_snap_jolt * 1.9;
	var _wing_drag_y = cube_wing_sway_y - cube_wing_lift_snap * 1.7 + abs(_wing_snap_jolt) * 0.35;
	var _wing_lift = clamp(-_wing_dy * 0.42 + cube_wing_lift_snap * 3.2, -4.6, 6.2);
	var _wing_accel = clamp(_wing_motion_p + max(0, -_wing_dy) / 10 + _wing_snap * 0.35 + _wing_deploy_flash * 0.45, 0, 1.5);
	var _wing_heat = clamp(_cube_wing_heat + _cube_wing_power * 0.34, 0, 1.65);
	var _wing_flash = clamp(_cube_wing_power * (0.70 + _wing_heat * 0.16 + _wing_motion_p * 0.18 + _wing_snap * 0.16) + _wing_deploy_flash * 0.42, 0, 1);
	var _wing_beat = 0.5 + 0.5 * sin(_wing_time * 11.5);
	var _wing_open = _cube_wing_power * (0.94 + _wing_heat * 0.09 + _wing_accel * 0.12) * (1 - _wing_deploy_tuck * 0.42);
	var _wing_breath = sin(_wing_time * (4.8 + _wing_motion_p * 1.6)) * (0.35 + _wing_heat * 0.16 + _wing_motion_p * 0.24);
	var _wing_core_x = _wing_base_x + _wing_drag_x * 0.10;
	var _wing_core_y = _wing_base_y + _wing_breath + _wing_drag_y * 0.08;

	gpu_set_blendmode(bm_add);
	draw_sprite_ext(spr_glow_blob, 0, _wing_core_x, _wing_core_y,
					(34 + _wing_heat * 14) / 64,
					(24 + _wing_heat * 8) / 64,
					0, _wing_light, image_alpha * (0.075 + _wing_heat * 0.045) * _cube_wing_power);
	draw_sprite_ext(spr_glow_blob, 0, _wing_core_x, _wing_core_y,
					(12 + _wing_heat * 5) / 64,
					(10 + _wing_heat * 4) / 64,
					0, c_white, image_alpha * (0.10 + _wing_heat * 0.05) * _cube_wing_power);

	if (_wing_deploy_streak > 0.01) {
		draw_sprite_ext(spr_glow_blob, 0, _wing_core_x, _wing_core_y,
						(42 + _wing_deploy_flash * 24) / 64,
						(30 + _wing_deploy_flash * 18) / 64,
						0, _wing_light, image_alpha * _wing_deploy_streak * 0.18);

		for (var _deploy_side = -1; _deploy_side <= 1; _deploy_side += 2) {
			var _deploy_a = image_alpha * _wing_deploy_streak;
			var _deploy_x0 = _wing_core_x + _deploy_side * 3;
			var _deploy_y0 = _wing_core_y + 1;
			var _deploy_up_x = _wing_core_x + _deploy_side * (46 + _wing_deploy_flash * 18);
			var _deploy_up_y = _wing_core_y - 22 - _wing_deploy_flash * 8;
			var _deploy_lo_x = _wing_core_x + _deploy_side * (39 + _wing_deploy_flash * 16);
			var _deploy_lo_y = _wing_core_y + 17 + _wing_deploy_flash * 7;
			var _deploy_back_x = _wing_core_x - _wing_trail_x * (18 + _wing_deploy_flash * 12);
			var _deploy_back_y = _wing_core_y - _wing_trail_y * (18 + _wing_deploy_flash * 12);

			draw_set_color(c_white);
			draw_set_alpha(_deploy_a * 0.22);
			draw_line_width(_deploy_x0, _deploy_y0, _deploy_up_x, _deploy_up_y, 1.45);
			draw_line_width(_deploy_x0, _deploy_y0, _deploy_lo_x, _deploy_lo_y, 1.35);
			draw_set_color(_wing_silver);
			draw_set_alpha(_deploy_a * 0.12);
			draw_line_width(_deploy_x0, _deploy_y0 + 1, _deploy_back_x + _deploy_side * 10, _deploy_back_y + 4, 1.0);

			draw_primitive_begin(pr_trianglestrip);
			draw_vertex_colour(_deploy_up_x, _deploy_up_y, _wing_light, _deploy_a * 0.14);
			draw_vertex_colour(_deploy_lo_x, _deploy_lo_y, _wing_light, _deploy_a * 0.10);
			draw_vertex_colour(_deploy_up_x + _wing_trail_x * 28, _deploy_up_y + _wing_trail_y * 28, _wing_light, 0);
			draw_vertex_colour(_deploy_lo_x + _wing_trail_x * 24, _deploy_lo_y + _wing_trail_y * 24, _wing_light, 0);
			draw_primitive_end();
		}
	}

	if (_wing_snap > 0.03) {
		for (var _snap_side = -1; _snap_side <= 1; _snap_side += 2) {
			var _snap_x1 = _wing_core_x + _snap_side * 7 * _wing_open;
			var _snap_y1 = _wing_core_y + 2;
			var _snap_x2 = _wing_core_x + _snap_side * (26 + _wing_snap * 12) * _wing_open + _wing_drag_x * 0.65;
			var _snap_y2 = _wing_core_y + 10 + _wing_snap * 8 + _wing_drag_y * 0.25;
			var _snap_x3 = _wing_core_x + _snap_side * (34 + _wing_snap * 16) * _wing_open + _wing_drag_x * 0.85;
			var _snap_y3 = _wing_core_y - 16 - _wing_snap * 6 + _wing_drag_y * 0.18;

			draw_set_color(c_white);
			draw_set_alpha(image_alpha * _wing_snap * 0.13);
			draw_line_width(_snap_x1, _snap_y1, _snap_x2, _snap_y2, 1.25);
			draw_set_alpha(image_alpha * _wing_snap * 0.09);
			draw_line_width(_snap_x1, _snap_y1 - 1, _snap_x3, _snap_y3, 0.85);
		}
	}

	for (var _glow_side = -1; _glow_side <= 1; _glow_side += 2) {
		for (var _glow_blade = 0; _glow_blade < 6; _glow_blade++) {
			var _gbf = _glow_blade / 5;
			var _gphase = _wing_time * (4.1 + _glow_blade * 0.58) + _glow_side * 1.4 + _glow_blade * 0.71;
			var _gflutter = sin(_gphase) * (0.55 + _wing_heat * 0.40 + _wing_motion_p * 0.35 + _wing_snap * 0.28);
			var _gdrag = 0.18 + _gbf * 0.68;
			var _groot_x = _wing_core_x + _glow_side * (4 + _gbf * 7) * _wing_open + _wing_drag_x * 0.08;
			var _groot_y = _wing_core_y - 3 + _gbf * 5 + _wing_drag_y * 0.06;
			var _gspan = 32 + _gbf * 17 + _wing_heat * 3.4 + _wing_accel * 5;
			var _gtip_x = _wing_core_x + _glow_side * _gspan * _wing_open + _wing_drag_x * _gdrag;
			var _gtip_y = _wing_core_y - 31 + _gbf * 8.4 + _gflutter + _wing_drag_y * _gdrag - _wing_lift * (0.20 + _gbf * 0.25) + _wing_deploy_tuck * (20 - _gbf * 7);
			var _gmid_x = lerp(_groot_x, _gtip_x, 0.62);
			var _gmid_y = lerp(_groot_y, _gtip_y, 0.62) - 2;
			var _ga = image_alpha * _cube_wing_power * (0.055 + _wing_heat * 0.032 - _gbf * 0.010);

			draw_set_color(_wing_light);
			draw_set_alpha(_ga);
			draw_line_width(_groot_x, _groot_y, _gmid_x, _gmid_y, 1.1 + _wing_heat * 0.20);
			draw_line_width(_gmid_x, _gmid_y, _gtip_x, _gtip_y, 0.85 + _wing_heat * 0.14);

			draw_sprite_ext(spr_glow_blob, 0, _gtip_x, _gtip_y,
							(6.5 + _wing_heat * 2.5 - _gbf) / 64,
							(6.5 + _wing_heat * 2.5 - _gbf) / 64,
							0, _wing_light, image_alpha * _cube_wing_power * (0.060 + _wing_heat * 0.030));
		}

		for (var _glow_keel = 0; _glow_keel < 3; _glow_keel++) {
			var _gkf = _glow_keel / 2;
			var _gkphase = _wing_time * (4.7 + _glow_keel * 0.34) + _glow_side * 1.9;
			var _gkdrag = 0.22 + _gkf * 0.62;
			var _gkroot_x = _wing_core_x + _glow_side * (5 + _gkf * 9.5) * _wing_open + _wing_drag_x * 0.06;
			var _gkroot_y = _wing_core_y + 2.5 + _gkf * 2.8 + _wing_drag_y * 0.05;
			var _gktip_x = _wing_core_x + _glow_side * (19 + _gkf * 18 + _wing_heat * 2.4 + _wing_accel * 4.5) * _wing_open + _wing_drag_x * _gkdrag;
			var _gktip_y = _wing_core_y + 7 + _gkf * 8.2 + sin(_gkphase) * (0.35 + _wing_heat * 0.24 + _wing_motion_p * 0.22 + _wing_snap * 0.22) + _wing_drag_y * _gkdrag + _wing_lift * (0.16 + _gkf * 0.30) - _wing_deploy_tuck * (9 + _gkf * 4);
			var _gkmid_x = lerp(_gkroot_x, _gktip_x, 0.58);
			var _gkmid_y = lerp(_gkroot_y, _gktip_y, 0.58) + 1.2;
			var _gka = image_alpha * _cube_wing_power * (0.045 + _wing_heat * 0.024 - _gkf * 0.006);

			draw_set_color(_wing_light);
			draw_set_alpha(_gka);
			draw_line_width(_gkroot_x, _gkroot_y, _gkmid_x, _gkmid_y, 0.95 + _wing_heat * 0.16);
			draw_line_width(_gkmid_x, _gkmid_y, _gktip_x, _gktip_y, 0.80 + _wing_heat * 0.10);

			draw_sprite_ext(spr_glow_blob, 0, _gktip_x, _gktip_y,
							(5.4 + _wing_heat * 2.0 - _gkf) / 64,
							(5.4 + _wing_heat * 2.0 - _gkf) / 64,
							0, _wing_light, image_alpha * _cube_wing_power * (0.045 + _wing_heat * 0.022));
		}
	}

	if (_wing_streak_p > 0.07) {
		var _trail_len = (9 + _wing_speed * 3.6 + _wing_accel * 7) * _cube_wing_power;
		var _trail_alpha = image_alpha * _cube_wing_power * _wing_streak_p;
		var _trail_norm_x = -_wing_trail_y;
		var _trail_norm_y = _wing_trail_x;

		for (var _trail_side = -1; _trail_side <= 1; _trail_side += 2) {
			for (var _trail_i = 0; _trail_i < 5; _trail_i++) {
				var _tf = _trail_i / 4;
				var _twobble = sin(_wing_time * (6.2 + _trail_i * 0.55) + _trail_side * 1.3) * (0.7 + _wing_streak_p * 0.8 + _wing_snap * 0.35);
				var _tsx = _wing_core_x + _trail_side * (18 + _tf * 29) * _wing_open + _wing_drag_x * (0.16 + _tf * 0.42);
				var _tsy = _wing_core_y - 23 + _tf * 33 + _twobble + _wing_drag_y * (0.10 + _tf * 0.34);
				var _trail_scale = 0.72 + _tf * 0.36;
				var _tex = _tsx + _wing_trail_x * _trail_len * _trail_scale;
				var _tey = _tsy + _wing_trail_y * _trail_len * _trail_scale;
				var _thw = (1.15 - _tf * 0.12) * _cube_wing_power;
				var _ta = _trail_alpha * (0.13 - _tf * 0.012);

				draw_primitive_begin(pr_trianglestrip);
				draw_vertex_colour(_tsx + _trail_norm_x * _thw, _tsy + _trail_norm_y * _thw, _wing_light, _ta);
				draw_vertex_colour(_tsx - _trail_norm_x * _thw, _tsy - _trail_norm_y * _thw, _wing_light, _ta * 0.62);
				draw_vertex_colour(_tex + _trail_norm_x * 0.12, _tey + _trail_norm_y * 0.12, _wing_light, 0);
				draw_vertex_colour(_tex - _trail_norm_x * 0.12, _tey - _trail_norm_y * 0.12, _wing_light, 0);
				draw_primitive_end();

				draw_set_color(_wing_silver);
				draw_set_alpha(_ta * 0.36);
				draw_line_width(_tsx, _tsy, _tex, _tey, 0.55);
			}
		}
	}
	gpu_set_blendmode(bm_normal);

	draw_set_color(_wing_black);
	draw_set_alpha(image_alpha * (0.38 + _wing_heat * 0.05) * _cube_wing_power);
	draw_ellipse(_wing_core_x - 8, _wing_core_y - 8, _wing_core_x + 8, _wing_core_y + 9, false);
	draw_set_color(_wing_graphite);
	draw_set_alpha(image_alpha * (0.74 + _wing_heat * 0.05) * _cube_wing_power);
	draw_circle(_wing_core_x, _wing_core_y, 5.2 + _wing_heat * 0.4, false);
	draw_set_color(_wing_light);
	draw_set_alpha(image_alpha * _wing_flash * 0.34);
	scr_draw_smooth_ring_mask(_wing_core_x, _wing_core_y, 7.2 + _wing_heat * 1.1,
							  image_alpha * _wing_flash * 0.58, 0.95, _wing_light);

	for (var _wing_side = -1; _wing_side <= 1; _wing_side += 2) {
		var _wing_shoulder_x = _wing_core_x + _wing_side * (5 + _wing_beat * 0.8) * _wing_open + _wing_drag_x * 0.08;
		var _wing_shoulder_y = _wing_core_y + 1.5 + _wing_drag_y * 0.04;
		var _wing_mid_x = _wing_core_x + _wing_side * (19 + _wing_heat * 2.0 + _wing_accel * 2.5) * _wing_open + _wing_drag_x * 0.34;
		var _wing_mid_y = _wing_core_y - 13 + sin(_wing_time * 5.7 + _wing_side) * (0.7 + _wing_motion_p * 0.4 + _wing_snap * 0.26) + _wing_drag_y * 0.24 - _wing_lift * 0.15 + _wing_deploy_tuck * 7;
		var _wing_outer_x = _wing_core_x + _wing_side * (39 + _wing_heat * 3.4 + _wing_accel * 4.8) * _wing_open + _wing_drag_x * 0.55;
		var _wing_outer_y = _wing_core_y - 4 + sin(_wing_time * 6.8 + _wing_side) * (0.8 + _wing_motion_p * 0.45 + _wing_snap * 0.32) + _wing_drag_y * 0.38 - _wing_lift * 0.22 + _wing_deploy_tuck * 13;

		draw_set_color(_wing_black);
		draw_set_alpha(image_alpha * (0.76 + _wing_heat * 0.04) * _cube_wing_power);
		draw_line_width(_wing_shoulder_x, _wing_shoulder_y, _wing_mid_x, _wing_mid_y, 4.0);
		draw_line_width(_wing_mid_x, _wing_mid_y, _wing_outer_x, _wing_outer_y, 3.2);
		draw_set_color(_wing_silver);
		draw_set_alpha(image_alpha * (0.26 + _wing_heat * 0.05) * _cube_wing_power);
		draw_line_width(_wing_shoulder_x, _wing_shoulder_y - 0.8, _wing_mid_x, _wing_mid_y - 0.8, 1.0);
		draw_line_width(_wing_mid_x, _wing_mid_y - 0.8, _wing_outer_x, _wing_outer_y - 0.8, 0.85);

		for (var _wing_blade = 0; _wing_blade < 6; _wing_blade++) {
			var _blade_f = _wing_blade / 5;
			var _blade_phase = _wing_time * (4.0 + _wing_blade * 0.58) + _wing_side * 1.4 + _wing_blade * 0.71;
			var _blade_flutter = sin(_blade_phase) * (0.62 + _wing_heat * 0.46 + _wing_motion_p * 0.36 + _wing_snap * 0.34);
			var _blade_drag = 0.18 + _blade_f * 0.68;
			var _hinge_x = _wing_core_x + _wing_side * (4 + _blade_f * 7) * _wing_open + _wing_drag_x * 0.08;
			var _hinge_y = _wing_core_y - 3 + _blade_f * 5 + _wing_drag_y * 0.06;
			var _span = 32 + _blade_f * 17 + _wing_heat * 3.4 + _wing_accel * 5;
			var _nose_x = _wing_core_x + _wing_side * _span * _wing_open + _wing_drag_x * _blade_drag;
			var _nose_y = _wing_core_y - 31 + _blade_f * 8.4 + _blade_flutter + _wing_drag_y * _blade_drag - _wing_lift * (0.20 + _blade_f * 0.25) + _wing_deploy_tuck * (20 - _blade_f * 7);
			var _tail_x = _nose_x - _wing_side * (6.5 + _blade_f * 2.4);
			var _tail_y = _nose_y + 5.2 + _blade_f * 2.3;
			var _root_back_x = _hinge_x + _wing_side * (3.2 + _blade_f * 1.2);
			var _root_back_y = _hinge_y + 3.4;
			var _pane_alpha = image_alpha * _cube_wing_power * (0.13 + _wing_heat * 0.026 - _blade_f * 0.010);
			var _edge_alpha = image_alpha * _wing_flash * (0.19 + _wing_heat * 0.045 - _blade_f * 0.012);

			draw_primitive_begin(pr_trianglefan);
			draw_vertex_colour(_hinge_x, _hinge_y, _wing_graphite, _pane_alpha * 0.90);
			draw_vertex_colour(_nose_x, _nose_y, _wing_silver, _pane_alpha * 0.55);
			draw_vertex_colour(_tail_x, _tail_y, _wing_shell, _pane_alpha * 0.84);
			draw_vertex_colour(_root_back_x, _root_back_y, _wing_black, _pane_alpha * 0.96);
			draw_vertex_colour(_hinge_x, _hinge_y, _wing_graphite, _pane_alpha * 0.90);
			draw_primitive_end();

			draw_set_color(_wing_black);
			draw_set_alpha(image_alpha * (0.50 - _blade_f * 0.055) * _cube_wing_power);
			draw_line_width(_hinge_x, _hinge_y, _tail_x, _tail_y, 2.0 - _blade_f * 0.14);
			draw_line_width(_root_back_x, _root_back_y, _nose_x, _nose_y, 1.2);

			draw_set_color(_wing_light);
			draw_set_alpha(_edge_alpha);
			draw_line_width(_hinge_x, _hinge_y - 0.8, _nose_x, _nose_y, 0.78 + _wing_heat * 0.12);
			draw_set_color(_wing_silver);
			draw_set_alpha(_edge_alpha * 0.56);
			draw_line_width(_tail_x, _tail_y, _nose_x, _nose_y, 0.72);

			var _slit_x1 = lerp(_hinge_x, _nose_x, 0.32);
			var _slit_y1 = lerp(_hinge_y, _nose_y, 0.32) + 1.2;
			var _slit_x2 = lerp(_root_back_x, _tail_x, 0.74);
			var _slit_y2 = lerp(_root_back_y, _tail_y, 0.74);
			draw_set_color(_wing_black);
			draw_set_alpha(image_alpha * (0.24 + _wing_heat * 0.025) * _cube_wing_power);
			draw_line_width(_slit_x1, _slit_y1, _slit_x2, _slit_y2, 0.95);

			if ((_wing_blade mod 2) == 0) {
				var _notch_x = lerp(_hinge_x, _nose_x, 0.62);
				var _notch_y = lerp(_hinge_y, _nose_y, 0.62);
				draw_set_color(c_white);
				draw_set_alpha(image_alpha * _wing_flash * (0.055 + _wing_heat * 0.028));
				draw_line_width(_notch_x - _wing_side * 2.2, _notch_y + 2,
								_notch_x + _wing_side * 3.8, _notch_y - 1.5, 0.8);
			}
		}

		for (var _wing_keel = 0; _wing_keel < 3; _wing_keel++) {
			var _keel_f = _wing_keel / 2;
			var _keel_phase = _wing_time * (4.5 + _wing_keel * 0.35) + _wing_side * 1.9;
			var _keel_drag = 0.22 + _keel_f * 0.62;
			var _keel_root_x = _wing_core_x + _wing_side * (5 + _keel_f * 9.5) * _wing_open + _wing_drag_x * 0.06;
			var _keel_root_y = _wing_core_y + 2.5 + _keel_f * 2.8 + _wing_drag_y * 0.05;
			var _keel_tip_x = _wing_core_x + _wing_side * (19 + _keel_f * 18 + _wing_heat * 2.4 + _wing_accel * 4.5) * _wing_open + _wing_drag_x * _keel_drag;
			var _keel_tip_y = _wing_core_y + 7 + _keel_f * 8.2 + sin(_keel_phase) * (0.38 + _wing_heat * 0.26 + _wing_motion_p * 0.24 + _wing_snap * 0.28) + _wing_drag_y * _keel_drag + _wing_lift * (0.16 + _keel_f * 0.30) - _wing_deploy_tuck * (9 + _keel_f * 4);
			var _keel_tail_x = _keel_tip_x - _wing_side * (6.2 + _keel_f * 2.4);
			var _keel_tail_y = _keel_tip_y + 4.2 + _keel_f * 1.2;
			var _keel_back_x = _keel_root_x - _wing_side * (2.2 + _keel_f * 1.1);
			var _keel_back_y = _keel_root_y - 2.2;
			var _keel_pane_a = image_alpha * _cube_wing_power * (0.12 + _wing_heat * 0.022 - _keel_f * 0.012);
			var _keel_edge_a = image_alpha * _wing_flash * (0.17 + _wing_heat * 0.036 - _keel_f * 0.014);

			draw_primitive_begin(pr_trianglefan);
			draw_vertex_colour(_keel_root_x, _keel_root_y, _wing_graphite, _keel_pane_a * 0.88);
			draw_vertex_colour(_keel_tip_x, _keel_tip_y, _wing_silver, _keel_pane_a * 0.50);
			draw_vertex_colour(_keel_tail_x, _keel_tail_y, _wing_shell, _keel_pane_a * 0.82);
			draw_vertex_colour(_keel_back_x, _keel_back_y, _wing_black, _keel_pane_a * 0.94);
			draw_vertex_colour(_keel_root_x, _keel_root_y, _wing_graphite, _keel_pane_a * 0.88);
			draw_primitive_end();

			draw_set_color(_wing_black);
			draw_set_alpha(image_alpha * (0.45 - _keel_f * 0.052) * _cube_wing_power);
			draw_line_width(_keel_back_x, _keel_back_y, _keel_tail_x, _keel_tail_y, 1.55 - _keel_f * 0.12);
			draw_line_width(_keel_root_x, _keel_root_y, _keel_tail_x, _keel_tail_y, 1.9 - _keel_f * 0.14);

			draw_set_color(_wing_light);
			draw_set_alpha(_keel_edge_a);
			draw_line_width(_keel_root_x, _keel_root_y, _keel_tip_x, _keel_tip_y, 0.74 + _wing_heat * 0.10);
			draw_set_color(_wing_silver);
			draw_set_alpha(_keel_edge_a * 0.50);
			draw_line_width(_keel_tail_x, _keel_tail_y, _keel_tip_x, _keel_tip_y, 0.66);
		}

		for (var _wing_pin = 0; _wing_pin < 3; _wing_pin++) {
			var _pin_f = _wing_pin / 2;
			var _pin_x = lerp(_wing_shoulder_x, _wing_outer_x, 0.18 + _pin_f * 0.34);
			var _pin_y = lerp(_wing_shoulder_y, _wing_outer_y, 0.18 + _pin_f * 0.34) - _pin_f * 4;
			draw_set_color(_wing_black);
			draw_set_alpha(image_alpha * 0.62 * _cube_wing_power);
			draw_circle(_pin_x, _pin_y, 1.9 - _pin_f * 0.25, false);
			draw_set_color(_wing_light);
			draw_set_alpha(image_alpha * _wing_flash * (0.12 - _pin_f * 0.018));
			draw_circle(_pin_x, _pin_y, 0.85, false);
		}
	}

	gpu_set_blendmode(bm_add);
	scr_draw_smooth_ring_mask(_wing_core_x, _wing_core_y, 7.4 + _wing_heat * 1.3,
							  image_alpha * _wing_flash * 0.25, 1.0, _wing_light);
	draw_set_color(c_white);
	draw_set_alpha(image_alpha * _wing_flash * 0.18);
	draw_circle(_wing_core_x, _wing_core_y, 2.1 + _wing_heat * 0.55, false);
	gpu_set_blendmode(bm_normal);

	draw_set_alpha(1);
	draw_set_color(c_white);
}

draw_sprite_ext(
	sprite_index,
	image_index,
	floor(x),
	floor(y),
	image_xscale * facing,
	image_yscale,
	image_angle,
	image_blend,
	image_alpha)

if (show_parry_range)
{
    draw_set_alpha(0.4);
    draw_set_color(c_aqua);

    draw_circle(x, y, 20, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
}
