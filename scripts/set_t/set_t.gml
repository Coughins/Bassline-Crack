function set_t(_new_t){
	t = max(0, _new_t - 1)

	if (!variable_global_exists("debug_restart_t")) {
		global.debug_restart_t = 0;
	}
	global.debug_restart_t = t;

	var _audio_handle = music_instance;
	if (!variable_global_exists("debug_music_instance")) {
		global.debug_music_instance = noone;
	}
	if (audio_exists(global.debug_music_instance)) {
		_audio_handle = global.debug_music_instance;
	}

	if (audio_exists(_audio_handle) && audio_is_playing(_audio_handle)) {
		audio_sound_set_track_position(_audio_handle, music_offset + t / room_speed)
	}
	if (variable_instance_exists(id, "audio_sync_prev_music_t")) {
		audio_sync_prev_music_t = t;
	}

	if (_new_t > _k_containment_shield_break_t) {
		if (_new_t < _k_cube_t_spawn &&
		    variable_instance_exists(id, "containment_shield_ensure_side_blocks")) {
			containment_shield_ensure_side_blocks();
		}
		containment_shield_destroyed = true;
		containment_shield_break_timer = 0;
		containment_shield_flash = 0;
		containment_shield_shards = [];
		containment_shield_fractures = [];
	}

	if (_new_t >= 4000) {
		with (oBlock) {
			var _is_room_floor = (abs(x) < 0.1 && abs(y - 576) < 0.1 && image_xscale >= 24);
			var _is_room_ceiling = (abs(x) < 0.1 && abs(y + 32) < 0.1 && image_xscale >= 24);
			var _is_room_left = ((abs(x + 32) < 0.1 || abs(x) < 0.1) && abs(y) < 0.1 && image_yscale >= 17);
			var _is_room_right = ((abs(x - 768) < 0.1 || abs(x - room_width) < 0.1) && abs(y) < 0.1 && image_yscale >= 17);
			if (_is_room_floor || _is_room_ceiling || _is_room_left || _is_room_right) {
				instance_destroy();
			}
		}
		layer_set_visible("Tiles_1", false);
	}

	if (variable_instance_exists(id, "_k_vault_t_survey") &&
	    _new_t >= _k_vault_t_survey && _new_t <= _k_vault_t_end) {
		with (oPlayer) {
			x = other._k_vault_cx;
			y = other._k_vault_cy;
			velocity.x = 0;
			velocity.y = 0;
		}
	}

	if (variable_instance_exists(id, "_k_riser_t_fall")) {
		if (t >= _k_riser_t_fall && t <= _k_riser_t_end) {
			scr_riser_seek(t);
		}
		else if (!is_undefined(riser)) {
			scr_riser_clear();
		}
	}

	// ------------------------------------------------------------------------
	// timeline_hit(5219), and every driver inside it is an integrator rather
	// ------------------------------------------------------------------------
	if (variable_instance_exists(id, "_k_arc_rift_t")) {
		var _duct_in = (_new_t > 5219 && _new_t < 5964);

		if (_duct_in) {
			if (!instance_exists(oHoneycombController)) {
				instance_create_layer(0, 0, layer, oHoneycombController);
			}
			scr_duct_seek(oHoneycombController, _new_t);
			scr_duct_seat_player(oHoneycombController, _new_t);
		}
		else if (instance_exists(oHoneycombController)) {
			with (oHoneycombController) instance_destroy();
		}
	}

	if (_new_t >= _k_cube_t_spawn) {
		cube_wings_collected = true;
		cube_wings_collect_t = _k_cube_t_spawn;
		jr_wing_x = _k_jr_wing_pickup_x;
		jr_wing_y = _k_jr_wing_pickup_y;
		jr_wing_collect_x = jr_wing_x;
		jr_wing_collect_y = jr_wing_y;
		jr_wing_drop_stage = _k_jr_wing_collect_stage;
		jr_wing_ready = true;
		jr_wing_collect_flash = 0;
		jr_wing_flash = 0;

		with (oPlayer) {
			airjump_number = 9999999;
			airjump_index = 0;
		}
	}
	else {
		cube_wings_collected = false;
		cube_wings_collect_t = -1;
		jr_wing_collect_flash = 0;
		jr_wing_flash = 0;

		with (oPlayer) {
			airjump_number = defaults.airjump_number;
			airjump_index = min(airjump_index, airjump_number);
		}
	}

	if (variable_instance_exists(id, "stamp_face") && _new_t >= _k_stamp_t_arm
	    && _new_t <= _k_stamp_t_clear) {
		var _sk_fired = 0;
		for (var _sk = 0; _sk < array_length(_k_stamp_beats); _sk++) {
			if (t >= _k_stamp_beats[_sk]) _sk_fired++;
		}

		stamp_dead = (t >= _k_stamp_t_blowout);
		stamp_blowout = stamp_dead ? 0.5 : 0;
		stamp_rail = 1;
		stamp_readout = 1;

		stamp_face[0] = stamp_face_at(0, _sk_fired);
		stamp_face[1] = stamp_face_at(1, _sk_fired);

		if (stamp_dead) {
			stamp_face_target[0] = _k_stamp_x0 - 30;
			stamp_face_target[1] = _k_stamp_x1 + 30;
		} else {
			stamp_face_target[0] = stamp_face_at(0, _sk_fired + 1);
			stamp_face_target[1] = stamp_face_at(1, _sk_fired + 1);
		}

		stamp_face_heat[0] = 0;
		stamp_face_heat[1] = 0;
		stamp_face_flash[0] = 0;
		stamp_face_flash[1] = 0;

		var _sk_prog = clamp((t - _k_stamp_t_arm) / max(1, _k_stamp_t_blowout - _k_stamp_t_arm), 0, 1);
		stamp_amb = 0.35 + _sk_prog * 0.85;
		stamp_heat = _sk_prog;

		var _sk_gapf = 1 - clamp((_k_stamp_safe_x0 - stamp_face[0])
		                         / max(1, _k_stamp_safe_x0 - _k_stamp_x0), 0, 1);
		stamp_safe_glow = stamp_dead ? 0.2 : (0.3 + _sk_gapf * 0.7);
		stamp_safe_seal = 0;
		stamp_was_safe = false;
		stamp_player_safe = false;

		if (stamp_grid_seed == 0) {
			stamp_grid_seed = stamp_pick_grid_seed();
		}
		stamp_build_grid(stamp_grid_seed);

		if (instance_exists(oPlayer)) {
			for (var _cl = array_length(stamp_orbs) - 1; _cl >= 0; _cl--) {
				var _cn = stamp_orbs[_cl];
				if (point_distance(_cn.x, _cn.y, oPlayer.x, oPlayer.y) < _k_stamp_spawn_clear) {
					array_delete(stamp_orbs, _cl, 1);
				}
			}

			stamp_ensure_bottom_band_quota(oPlayer.x, oPlayer.y, stamp_grid_seed);
		}

		for (var _so = 0; _so < array_length(stamp_orbs); _so++) {
			var _son = stamp_orbs[_so];

			_son.spawn = clamp((t - (_k_stamp_t_arm + _son.delay))
			                   / max(1, _k_stamp_orb_fade), 0, 1);

			if (stamp_dead ||
			    stamp_face[0] >= _son.x - _k_stamp_orb_r * 0.4 ||
			    stamp_face[1] <= _son.x + _k_stamp_orb_r * 0.4) {
				_son.crushed = true;
			}
		}

		stamp_lock_frames = [];
		stamp_vents = [];
		stamp_sparks = [];
		stamp_shards = [];
		stamp_arcs = [];
		stamp_tips = [];
	}

	var _tree_window   = (_new_t > 1856 && _new_t <= 2025);
	var _tree_missing  = (!variable_instance_exists(id, "tree_data") || is_undefined(tree_data)
	                   || !is_struct(tree_data) || !variable_struct_exists(tree_data, "nodes"));
	var _tree_ready    = (variable_instance_exists(id, "storm_orb_x")
	                   && variable_instance_exists(id, "storm_orb_y")
	                   && variable_instance_exists(id, "_k_storm_clearing_radius")
	                   && variable_instance_exists(id, "tree_ignite_start_t"));

	if (_tree_window && _tree_missing && _tree_ready)
{
    var _tree_target_x = room_width / 2;
    var _tree_target_y = room_height - 40;
    if (instance_exists(oPlayer)) {
        _tree_target_x = clamp(oPlayer.x, 40, room_width - 40);
        _tree_target_y = oPlayer.y - 30;
    }

    tree_data = scr_generate_tree(_tree_target_x, _tree_target_y);
    scr_compute_tree_ignite_delays(tree_data, 3);

    tree_spawn_mid = array_length(tree_data.nodes) div 2;
    tree_leaf_indices = scr_get_leaf_nodes(tree_data);

    var _k_tree_ignite_duration = 78;
    var _raw_max_delay = 0;
    for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
        _raw_max_delay = max(_raw_max_delay, tree_data.nodes[_tmi].ignite_delay);
    }
    if (_raw_max_delay > 0) {
        var _ignite_scale = _k_tree_ignite_duration / _raw_max_delay;
        for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
            tree_data.nodes[_tmi].ignite_delay = round(tree_data.nodes[_tmi].ignite_delay * _ignite_scale);
        }
    }

    tree_max_ignite_delay = 0;
    for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
        tree_max_ignite_delay = max(tree_max_ignite_delay, tree_data.nodes[_tmi].ignite_delay);
    }
    tree_payoff_t = tree_ignite_start_t + tree_max_ignite_delay;

    scr_spawn_tree_half(tree_data, 0, tree_spawn_mid);
    if (_new_t > 1875) {
        scr_spawn_tree_half(tree_data, tree_spawn_mid, array_length(tree_data.nodes));

        if (!instance_exists(oFruit)) {
            var _crown_sum_x = 0, _crown_sum_y = 0;
            for (var _fri = 0; _fri < array_length(tree_leaf_indices); _fri++) {
                var _node = tree_data.nodes[tree_leaf_indices[_fri]];
                var _fruit = instance_create_layer(_node.x, _node.y, layer, oFruit);
                _fruit.spawn_burst = false;
                _fruit.anchor_x = _node.x;
                _fruit.anchor_y = _node.y;
                _fruit.anchor_index = tree_leaf_indices[_fri];
                _crown_sum_x += _node.x;
                _crown_sum_y += _node.y;
            }
            if (array_length(tree_leaf_indices) > 0) {
                tree_crown_center_x = _crown_sum_x / array_length(tree_leaf_indices);
                tree_crown_center_y = _crown_sum_y / array_length(tree_leaf_indices);
            }
            with (oFruit) {
                crown_x = other.tree_crown_center_x;
                crown_y = other.tree_crown_center_y;
            }
        }
    }
}

	var _dna_spawn_ready = variable_instance_exists(id, "_k_dna_spawn_t")
	                   && variable_instance_exists(id, "_k_dna_despawn_t")
	                   && variable_instance_exists(id, "dna_spawn_fully_active");
	if (_dna_spawn_ready) {
		if (_new_t < _k_dna_spawn_t) {
			dna_active = false;
			dna_fade_active = false;
			dna_veil = 0;
			dna_spawn_cursor = 0;
			active_dna_rung_chains = 0;
			dna_rung_queue = [];
			dna_write_arcs = [];
			dna_cross_arcs = [];
			dna_chain_flash = 0;

			with (oDNATest) {
				if (dna_mode) instance_destroy();
			}

			for (var _dns = 0; _dns < array_length(dna_structures); _dns++) {
				var _dna_slots_pre = array_length(dna_structures[_dns].array);
				for (var _dni = 0; _dni < _dna_slots_pre; _dni++) {
					dna_structures[_dns].array[_dni] = -4;
				}
			}
		} else if (_new_t < _k_dna_despawn_t) {
			dna_active = true;
			dna_fade_active = (_new_t < _k_dna_spawn_t + _k_dna_fade_frames);
			dna_fade_start_t = _k_dna_spawn_t;
			dna_veil = dna_fade_active
			         ? power(clamp((_new_t - _k_dna_spawn_t) / max(_k_dna_fade_frames, 1), 0, 1), 1.35)
			         : 1;
			active_dna_rung_chains = 0;
			dna_rung_queue = [];
			dna_write_arcs = [];
			dna_cross_arcs = [];
			dna_chain_flash = 0;
			if (!instance_exists(oDNATest)) dna_spawn_cursor = 0;
			dna_spawn_fully_active();
		}
	}

	var _dna_despawn_ready = variable_instance_exists(id, "_k_dna_despawn_t")
	                      && variable_instance_exists(id, "_k_dna_despawn_duration");
	if (_dna_despawn_ready && _new_t > _k_dna_despawn_t) {
		dna_active = false;
		dna_fade_active = false;
		dna_veil = 1;
		active_dna_rung_chains = 0;
		dna_rung_queue = [];
		dna_write_arcs = [];
		dna_cross_arcs = [];

		var _dna_sweep_done_t = _k_dna_despawn_t + _k_dna_despawn_duration;
		if (_new_t >= _dna_sweep_done_t) {
			dna_despawn_active = false;
			dna_despawn_start_t = _k_dna_despawn_t;
			dna_despawn_sweep_y = _k_dna_despawn_sweep_end_y;

			with (oDNATest) {
				chain_target = noone;
				instance_destroy();
			}

			for (var _ds = 0; _ds < array_length(dna_structures); _ds++) {
				var _dna_slots = array_length(dna_structures[_ds].array);
				for (var _di = 0; _di < _dna_slots; _di++) {
					dna_structures[_ds].array[_di] = -4;
				}
			}
		} else {
			dna_despawn_active = true;
			dna_despawn_start_t = _k_dna_despawn_t;
			var _dna_progress = clamp((_new_t - _k_dna_despawn_t) / max(_k_dna_despawn_duration, 1), 0, 1);
			var _dna_eased = _dna_progress * _dna_progress * _dna_progress;
			dna_despawn_sweep_y = lerp(_k_dna_despawn_sweep_start_y, _k_dna_despawn_sweep_end_y, _dna_eased);
		}
	}

	var _mill_ready = (variable_instance_exists(id, "_k_mill_t_unfold")
	                && variable_instance_exists(id, "_k_mill_rx_out"));

	if (_mill_ready && _new_t > _k_mill_t_seed && _new_t < _k_mill_t_tear) {
		mill_torn = false;
		if (_new_t < _k_mill_t_overload) mill_scars = [];

		if (_new_t < _k_mill_t_overload && !instance_exists(oLaserOrb_Pop)) {
			var _mc_late = (_new_t > _k_mill_t_feed);
			mill_arm_base = random(360);
			mill_arm_glow = 1;

			var _mc_wave = {
				base   : mill_arm_base,
				count  : _mc_late ? 9 : 5,
				off    : _mc_late ? 20 : 0,
				sign   : _mc_late ? -1 : 1,
				twist  : _k_mill_arm_twist,
				r_in   : _k_mill_r_in,
				rx_out : _k_mill_rx_out,
				ry_out : _k_mill_ry_out,
				fill   : _k_mill_edge_fill,
				scale  : 1,
				per    : _mc_late ? 22 : 11,
				weight : 1,
				age    : _k_mill_arm_reveal,
				cols   : []
			};
			for (var _mcc = 0; _mcc < _mc_wave.count * _mc_wave.per; _mcc++) {
				array_push(_mc_wave.cols, choose(global.avoid_col_cyan,
				                                 global.avoid_col_warning,
				                                 global.avoid_col_violet));
			}
			mill_arm_waves = [ _mc_wave ];

			for (var _mca2 = 0; _mca2 < _mc_wave.count; _mca2++) {
				for (var _mcs = 0; _mcs < _mc_wave.per; _mcs++) {
					var _mcf  = (_mc_wave.per <= 1) ? 1 : (_mcs / (_mc_wave.per - 1));
					var _mcpt = scr_mill_arm_point(_mc_wave, _mca2, _mcf, _k_mill_cx, _k_mill_cy);
					with (instance_create_layer(_mcpt.x, _mcpt.y, layer, oLaserOrb_Pop)) {
						base_scale = 1;
						idle_alpha_max_override = 0.26;
						materialize_duration = 6;
					}
				}
			}
		}

		if (_new_t > _k_mill_t_unfold && _new_t < _k_mill_t_overload && !instance_exists(oLaserOrbTrigger)) {
			mill_blade_a = instance_create_layer(_k_mill_cx, _k_mill_cy, layer, oLaserOrbTrigger);
			with (mill_blade_a) { move_speed = 0; is_rotating = 1; rotate_speed = other._k_mill_spin_start; }

			if (_new_t > _k_mill_t_twin) {
				mill_blade_b = instance_create_layer(_k_mill_cx, _k_mill_cy, layer, oLaserOrbTrigger);
				with (mill_blade_b) {
					move_speed = 0; is_rotating = 1;
					rotate_speed = -other._k_mill_spin_start * 1.12;
					image_angle = 0;
				}
			}
		}

		if (_new_t > _k_mill_t_overload && array_length(mill_scars) == 0) {
			var _mcfan = random(360);
			mill_gate_cyan_first = choose(true, false);
			if (instance_exists(oPlayer) && _k_mill_scar_count > 0) {
				var _mcavoid_step = 180 / _k_mill_scar_count;
				var _mcavoid_ang = point_direction(_k_mill_cx, _k_mill_cy, oPlayer.x, oPlayer.y);
				var _mcavoid_phase = ((_mcavoid_ang - _mcfan) mod _mcavoid_step + _mcavoid_step) mod _mcavoid_step;
				var _mcavoid_shift = _mcavoid_step * 0.5 - _mcavoid_phase;
				if (_mcavoid_shift >  _mcavoid_step * 0.5) _mcavoid_shift -= _mcavoid_step;
				if (_mcavoid_shift < -_mcavoid_step * 0.5) _mcavoid_shift += _mcavoid_step;
				_mcfan += _mcavoid_shift;
			}
			for (var _mcsi = 0; _mcsi < _k_mill_scar_count; _mcsi++) {
				array_push(mill_scars, {
					ang      : _mcfan + (_mcsi / _k_mill_scar_count) * 180,
					half_len : 450 * _k_mill_extend_burst * random_range(0.86, 1.06),
					alpha    : 0.95,
					hot      : random_range(0.6, 1),
					off      : scr_bolt_offsets(5, 9),
					ignite   : 0, guide : 0, fire_in : -1, spent : false,
					throw_sign : choose(-1, 1),
					door_a : noone, door_b : noone
				});
			}

			mill_scar_queue = [];
			var _mcq_n = array_length(mill_scars);
			if (_mcq_n > 0) {
				var _mcq_start = irandom(_mcq_n - 1);
				var _mcq_dir   = choose(1, -1);
				for (var _mcq = 0; _mcq < _mcq_n; _mcq++) {
					array_push(mill_scar_queue,
					           ((_mcq_start + _mcq * _mcq_dir) mod _mcq_n + _mcq_n) mod _mcq_n);
				}
			}

			if (!instance_exists(oFallingRedOrb)) {
				var _mcall = (_new_t > _k_mill_t_seed_c);
				var _mcmid = (_k_mill_scar_beads - 1) * 0.5;
				for (var _mcs2 = 0; _mcs2 < array_length(mill_scars); _mcs2++) {
					var _mcsc = mill_scars[_mcs2];
					var _mcperp = _mcsc.ang + 90 * _mcsc.throw_sign;
					for (var _mcb = 0; _mcb < _k_mill_scar_beads; _mcb += (_mcall ? 1 : 2)) {
						var _mcpt = scr_mill_bead_slot(_mcsc, _mcb, _k_mill_scar_beads,
						                               _k_mill_r_in + 30, _k_mill_rx_out,
						                               _k_mill_ry_out, _k_mill_bead_fill);
						var _mcbf = abs(_mcb - _mcmid) / _mcmid;
						var _mcpair_slot = (_mcb div 2) * 2;
						var _mcpa = scr_mill_bead_slot(_mcsc, _mcpair_slot, _k_mill_scar_beads,
						                               _k_mill_r_in + 30, _k_mill_rx_out,
						                               _k_mill_ry_out, _k_mill_bead_fill);
						var _mcpb = scr_mill_bead_slot(_mcsc, _mcpair_slot + 1, _k_mill_scar_beads,
						                               _k_mill_r_in + 30, _k_mill_rx_out,
						                               _k_mill_ry_out, _k_mill_bead_fill);
						var _mccx = (_mcpa.x + _mcpb.x) * 0.5;
						var _mccy = (_mcpa.y + _mcpb.y) * 0.5;
						var _mcang = point_direction(_k_mill_cx, _k_mill_cy,
						                             _k_mill_cx + _mccx, _k_mill_cy + _mccy);
						var _mcrad = point_distance(0, 0, _mccx, _mccy);
						var _mcband = floor(abs(((_mcpair_slot + _mcpair_slot + 1) * 0.5) - _mcmid) / 2);
						var _mccyan = (((_mcband mod 2) == 0) == mill_gate_cyan_first);
						var _mcdir = _mccyan ? -1 : 1;
						var _mctarget_i = ((_mcs2 + _mcdir) mod array_length(mill_scars)
						                   + array_length(mill_scars)) mod array_length(mill_scars);
						var _mctarget_base = mill_scars[_mctarget_i].ang;
						var _mcspan = _mcdir * (180 / max(_k_mill_scar_count, 1));
						var _mcbest = 1000000;
						for (var _mck = -3; _mck <= 3; _mck++) {
							var _mccand = _mctarget_base + _mck * 180;
							var _mcdelta = _mccand - _mcang;
							if (_mcdir > 0 && _mcdelta > 0 && _mcdelta < _mcbest) {
								_mcbest = _mcdelta;
								_mcspan = _mcdelta;
							}
							if (_mcdir < 0 && _mcdelta < 0 && -_mcdelta < _mcbest) {
								_mcbest = -_mcdelta;
								_mcspan = _mcdelta;
							}
						}
						if (abs(_mcspan) > 72) _mcspan = _mcdir * (180 / max(_k_mill_scar_count, 1));
						with (instance_create_layer(_k_mill_cx + _mcpt.x,
						                            _k_mill_cy + _mcpt.y,
						                            layer, oFallingRedOrb)) {
							mill_orb = true;
							mill_scar_index = _mcs2;
							mill_launch_dir = _mcperp;
							mill_slot = _mcb;
							mill_along = _mcpt.dist;
							mill_bead_f = _mcbf;
							mill_orbit_angle = point_direction(other._k_mill_cx, other._k_mill_cy, x, y);
							mill_orbit_radius = point_distance(other._k_mill_cx, other._k_mill_cy, x, y);
							mill_orbit_dir = _mcdir;
							mill_gate_cyan = _mccyan;
							if (mill_gate_cyan) {
								sprite_index = sRainbowOrb;
								image_index = 0;
							} else {
								sprite_index = sRedOrb;
							}
							image_speed = 0;
							image_blend = c_white;
							image_alpha = 0.35;
						}
					}
					if (_mcall) scr_mill_link_resting_gates(_mcs2);
				}
			}
		}
	}
	else if (_mill_ready && _new_t >= _k_mill_t_tear) {
		mill_arm_waves = [];
		mill_arm_glow  = 0;
	}

	// ------------------------------------------------------------------------
	// FINALE (t6960-7291) and FINAL CUT catch-up.
	// ------------------------------------------------------------------------
	if (variable_instance_exists(id, "_k_fin_t_cut")) {
		if (_new_t >= _k_fin_t_open - 6) {
			bass_rings       = [];
			orbit_rings      = [];
			fin_shells       = [];
			fin_shell_ghosts = [];
			fin_shell_sparks = [];
			fin_shell_vents  = [];
			fin_ghosts       = [];
			fin_motes        = [];
			fin_assembly_packets = [];
			fin_assembly_pulse   = 0;
			fin_assembly_sync    = 0;
			for (var _fas = 0; _fas < array_length(fin_assembly_nodes); _fas++) {
				fin_assembly_nodes[_fas].pulse = 0;
			}
			with (oBassRingOrb) instance_destroy();

			fin_opened = (t >= _k_fin_t_open);

			fin_spear_index = 0;
			for (var _fsp = 0; _fsp < array_length(_k_fin_throw_beats); _fsp++) {
				if (t < _k_fin_throw_beats[_fsp]) break;
				fin_spear_index = _fsp + 1;
			}

			fin_shell_index = 0;
			for (var _fsh = 0; _fsh < array_length(_k_fin_shell_beats); _fsh++) {
				var _fsh_t = _k_fin_shell_beats[_fsh] - _k_fin_shell_lead
				           - _k_fin_shell_arm[_fsh] - _k_fin_shell_slam[_fsh];
				if (t < _fsh_t) break;
				fin_shell_index = _fsh + 1;
			}

			fin_breath_index = 0;
			for (var _fbr = 0; _fbr < array_length(_k_fin_breath_beats); _fbr++) {
				if (t < _k_fin_breath_beats[_fbr]) break;
				fin_breath_index = _fbr + 1;
			}

			fin_breath_active = (t >= _k_fin_t_breath && t < _k_fin_t_cut);
			fin_implode       = fin_breath_active ? 1 : 0;
			fin_roll_sign     = ((fin_shell_index mod 2) == 0) ? 1 : -1;
		}

		if (_new_t <= _k_fin_t_cut) {
			final_cut_triggered = false;
			final_cut_timer     = 0;
			song_end_handled    = false;
			fin_hush            = 0;
			fin_blade_p         = 0;
			fin_blade_glow      = 0;
			fin_cut_flash       = 0;
			fin_cut_veil        = 0;
			fin_cut_fly         = 0;
			fin_cut_scar        = 0;
			fin_cut_flare       = 0;
			fin_cut_span        = 0;
			fin_cut_kicked      = false;
			fin_cut_release     = 0;
			fin_cut_jitter      = 0;
			fin_cut_captured    = false;
			final_cut_sparks    = [];
			fin_cut_scar_pts    = [];
			slash_amount        = 0;
			intro_dim_amount    = 0;
			player_set_stopped(false);

			with (oFinalCutWarp) instance_destroy();
		}
		else if (_new_t < _k_fin_t_end) {
			final_cut_triggered = true;
			final_cut_timer     = 0;
			song_end_handled    = false;
			fin_cut_captured    = false;
			fin_cut_kicked      = true;
			fin_blade_p         = 1;
			fin_blade_glow      = 0;
			fin_cut_flash       = 0;
			fin_hush            = 0;
			fin_cut_flare       = 0;
			final_cut_sparks    = [];
			slash_amount        = 0;
			intro_dim_amount    = 0;
			fin_core            = 0;
			fin_impact          = 0;
			fin_chroma          = 0;
			if (array_length(fin_cut_scar_pts) == 0) fin_cut_roll_scar();
			player_set_stopped(true);
			if (instance_exists(oPlayer)) {
				oPlayer.invincible_timer = max(oPlayer.invincible_timer, room_speed * 12);
			}
		}
	}
}
