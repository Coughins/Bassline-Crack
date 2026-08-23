hub_time++;
global.hub_orbit_angle += 0.72 + hub_gate_charge * 0.7 + hub_major_pulse * 1.8;

if (!hub_spawn_applied && instance_exists(oPlayer)) {
    with (oPlayer) {
        x = other.hub_spawn_x;
        y = other.hub_floor_y - sprite_origin_to_bottom(sprite_index);
        velocity.set(0, 0);
        hvelocity.set(0, 0);
        vvelocity.set(0, 0);
        airjump_number = defaults.airjump_number;
        airjump_index = 0;
    }
    player_set_gravity_direction(0, true);
    hub_spawn_applied = true;
}

hub_practice_flash = max(0, hub_practice_flash - 0.06);
hub_practice_menu_flash = max(0, hub_practice_menu_flash - 0.08);
hub_practice_near = false;

if (!hub_end_mode && !hub_warping && input_check_pressed("hitcount")) {
    global.hitcount_mode = !global.hitcount_mode;
    hub_practice_flash = 1;
    sfx_play_sound(sndBlockChange);
}

if (!hub_end_mode && !hub_warping && instance_exists(oPlayer)) {
    var _feet_y = oPlayer.y + sprite_origin_to_bottom(oPlayer.sprite_index) * abs(oPlayer.image_yscale);
    hub_practice_near = point_in_rectangle(oPlayer.x, _feet_y,
        hub_practice_x - hub_practice_rx, hub_floor_y - hub_practice_ry,
        hub_practice_x + hub_practice_rx, hub_floor_y + 18);
}

if (hub_practice_menu_open) {
    if (!hub_practice_near || hub_warping || hub_end_mode) {
        hub_practice_menu_open = false;
        if (instance_exists(oPlayer)) player_set_frozen(false);
    } else {
        if (instance_exists(oPlayer)) player_set_frozen(true);

        var _practice_count = array_length(hub_practice_markers);
        if (input_check_pressed("down") || keyboard_check_pressed(vk_down)) {
            hub_practice_selected = (hub_practice_selected + 1) mod _practice_count;
            hub_practice_menu_flash = 1;
            audio_play_sound(sMenu, 1, false);
        }
        if (input_check_pressed("up") || keyboard_check_pressed(vk_up)) {
            hub_practice_selected = (hub_practice_selected + _practice_count - 1) mod _practice_count;
            hub_practice_menu_flash = 1;
            audio_play_sound(sMenu, 1, false);
        }

        var _practice_visible = 11;
        if (hub_practice_selected < hub_practice_scroll) hub_practice_scroll = hub_practice_selected;
        if (hub_practice_selected >= hub_practice_scroll + _practice_visible) {
            hub_practice_scroll = hub_practice_selected - _practice_visible + 1;
        }
        hub_practice_scroll = clamp(hub_practice_scroll, 0, max(0, _practice_count - _practice_visible));

        if (input_check_pressed("shoot") || input_check_pressed("jump")) {
            hub_start_practice(hub_practice_markers[hub_practice_selected]);
            exit;
        }
        if (input_check_pressed("skip")) {
            hub_practice_menu_open = false;
            if (instance_exists(oPlayer)) player_set_frozen(false);
            sfx_play_sound(sndBlockChange);
        }
    }
} else if (hub_practice_near && (input_check_pressed("up") || keyboard_check_pressed(vk_up))) {
    hub_practice_menu_open = true;
    hub_practice_flash = 1;
    hub_practice_menu_flash = 1;
    if (instance_exists(oPlayer)) player_set_frozen(true);
    sfx_play_sound(sndBlockChange);
}

if ((hub_time mod 20) == 0) {
    if (!hub_collision_intact()) {
        hub_build_collision();
    }

    with (oBlock) {
        if (!variable_instance_exists(id, "hub_owned_by") || hub_owned_by != other.id) {
            instance_destroy();
        }
    }

    with (oWarp) {
        visible = false;
        x = -4096;
        y = -4096;
    }
    with (oFootball) {
        visible = false;
        x = -4096;
        y = -4096;
        if (variable_instance_exists(id, "hsp")) hsp = 0;
        if (variable_instance_exists(id, "vsp")) vsp = 0;
    }
}

hub_minor_pulse = max(0, hub_minor_pulse - 0.055);
hub_major_pulse = max(0, hub_major_pulse - 0.038);
hub_gate_pulse = max(0, hub_gate_pulse - 0.065);
hub_ripple_pulse = max(0, hub_ripple_pulse - 0.045);
hub_bloom_pulse = max(0, hub_bloom_pulse - 0.035);
hub_aberration_pulse = max(0, hub_aberration_pulse - 0.028);
hub_tear_pulse = max(0, hub_tear_pulse - 0.05);

var _beat_len = 46;
var _major_len = _beat_len * 4;

if ((hub_time mod _beat_len) == 0) {
    hub_minor_pulse = 1;
    hub_bloom_pulse = max(hub_bloom_pulse, 0.16);
    hub_ripple_pulse = max(hub_ripple_pulse, 0.12);
    hub_push_ring(hub_gate_x, hub_gate_y + 10, 24, 4.2, 34, hub_col_cyan, 0.55);

    repeat (10) {
        var _ang = random_range(205, 335);
        hub_push_spark(
            hub_gate_x + random_range(-hub_gate_rx * 0.7, hub_gate_rx * 0.7),
            hub_floor_y - random_range(4, 32),
            _ang,
            random_range(1.6, 5.2),
            irandom_range(18, 38),
            random_range(1.2, 3.2),
            choose(hub_col_cyan, hub_col_edge, hub_col_warning, hub_col_white));
    }

    repeat (4) {
        hub_push_stream(
            hub_gate_x + random_range(-hub_gate_rx, hub_gate_rx),
            hub_floor_y + random_range(-4, 8),
            random_range(30, 92),
            -random_range(2.6, 6.8),
            irandom_range(16, 30),
            random_range(1.2, 3.4),
            choose(hub_col_cyan, hub_col_warning, hub_col_violet));
    }
}

if ((hub_time mod _major_len) == 0) {
    hub_major_pulse = 1;
    hub_gate_pulse = 1;
    hub_bloom_pulse = max(hub_bloom_pulse, 0.36);
    hub_ripple_pulse = max(hub_ripple_pulse, 0.38);
    hub_aberration_pulse = max(hub_aberration_pulse, 0.14);
    hub_tear_pulse = max(hub_tear_pulse, 0.08);

    hub_push_ring(hub_gate_x, hub_gate_y + 6, 14, 6.4, 48, hub_col_white, 0.95);
    hub_push_ring(hub_gate_x, hub_floor_y - 8, 36, 7.2, 42, hub_col_warning, 0.65);

    for (var i = 0; i < array_length(hub_rail_nodes); i += 3) {
        var _n = hub_rail_nodes[i];
        hub_push_bolt(_n.x, _n.y - random_range(12, 48),
                      hub_gate_x + random_range(-hub_gate_rx * 0.55, hub_gate_rx * 0.55),
                      hub_gate_y + random_range(-hub_gate_ry * 0.55, hub_gate_ry * 0.55),
                      irandom_range(8, 16),
                      5,
                      choose(hub_col_cyan, hub_col_warning, hub_col_violet),
                      random_range(1.2, 2.4));
    }

    repeat (18) {
        hub_push_spark(hub_gate_x, hub_gate_y + random_range(-50, 60),
                       random(360), random_range(1.2, 7.5), irandom_range(20, 52),
                       random_range(1, 4.6), choose(hub_col_cyan, hub_col_warning, hub_col_white));
    }
}

if (hub_end_mode) {
    hub_end_reveal = clamp(hub_end_reveal + 0.018, 0, 1);
    hub_gate_touch_frames = 0;
    hub_warping = false;
    hub_warp_timer = 0;

    var _end_target_charge = 0.62 + hub_end_reveal * 0.22 + hub_minor_pulse * 0.06 + hub_major_pulse * 0.12;
    hub_gate_charge = lerp(hub_gate_charge, clamp(_end_target_charge, 0, 1), 0.045);
    hub_warp_flash = max(0, hub_warp_flash - 0.018);
    hub_bloom_pulse = max(hub_bloom_pulse, 0.18 + hub_end_reveal * 0.12);
    hub_ripple_pulse = max(hub_ripple_pulse, 0.08 + hub_major_pulse * 0.22);
    hub_aberration_pulse = max(hub_aberration_pulse, 0.035 + hub_minor_pulse * 0.03);

    if ((hub_time mod 7) == 0) {
        repeat (3) {
            hub_push_spark(hub_gate_x + random_range(-92, 92), hub_gate_y + random_range(-86, 86),
                           random_range(245, 295), random_range(0.8, 3.2), irandom_range(28, 54),
                           random_range(0.8, 2.4), choose(hub_col_cyan, hub_col_edge, hub_col_white));
        }
    }

    if ((hub_time mod 13) == 0) {
        hub_push_stream(hub_gate_x + random_range(-120, 120), hub_floor_y + random_range(-4, 12),
                        random_range(48, 128), -random_range(1.6, 4.8), irandom_range(28, 54),
                        random_range(0.9, 2.2), choose(hub_col_cyan, hub_col_edge, hub_col_violet));
    }

    if ((hub_time mod 31) == 0) {
        hub_push_bolt(hub_gate_x + random_range(-160, 160), hub_gate_y + random_range(-118, 78),
                      hub_gate_x + random_range(-34, 34), hub_gate_y + random_range(-32, 32),
                      irandom_range(10, 20), 6, choose(hub_col_cyan, hub_col_edge, hub_col_white), random_range(0.9, 1.8));
    }
} else {
    var _near_gate = false;
    if (instance_exists(oPlayer)) {
        var _dx = (oPlayer.x - hub_gate_x) / hub_gate_rx;
        var _dy = (oPlayer.y - (hub_gate_y + 28)) / hub_gate_ry;
        _near_gate = (_dx * _dx + _dy * _dy) <= 1;
    }

    if (_near_gate && !hub_warping) {
        hub_gate_touch_frames++;
        hub_gate_charge = clamp(hub_gate_charge + 0.052, 0, 1);
        hub_bloom_pulse = max(hub_bloom_pulse, 0.12 + hub_gate_charge * 0.26);
        hub_aberration_pulse = max(hub_aberration_pulse, hub_gate_charge * 0.12);

        if ((hub_time mod 5) == 0) {
            hub_push_bolt(hub_gate_x + random_range(-72, 72), hub_floor_y - random_range(2, 38),
                          hub_gate_x + random_range(-28, 28), hub_gate_y + random_range(-58, 58),
                          irandom_range(6, 12), 4, choose(hub_col_cyan, hub_col_warning), 1.5);
        }

        if (hub_gate_touch_frames == 1) hub_push_ring(hub_gate_x, hub_gate_y + 14, 18, 5.4, 30, hub_col_warning, 0.7);

        var _pressed_up = !hub_practice_menu_open && (input_check_pressed("up") || keyboard_check_pressed(vk_up));
        if (_pressed_up || hub_gate_touch_frames >= 26) {
            global.avoidance_practice_active = false;
            global.avoidance_practice_t = 0;
            global.avoidance_practice_name = "";
            global.debug_restart_t = 0;
            global.debug_resume_t = 0;

            hub_warping = true;
            hub_warp_timer = 0;
            hub_warp_flash = 0.12;
            hub_gate_pulse = 1;
            hub_minor_pulse = 1;
            hub_major_pulse = 1;
            hub_ripple_pulse = 0.8;
            hub_bloom_pulse = 0.9;
            hub_aberration_pulse = 0.42;
            hub_tear_pulse = 0.4;
            audio_play_sound(sConfirm, 1, false, 0.8);
            hub_push_ring(hub_gate_x, hub_gate_y, 10, 9.5, 28, hub_col_white, 1.4);
        }
    } else if (!hub_warping) {
        hub_gate_touch_frames = 0;
        hub_gate_charge = max(0, hub_gate_charge - 0.032);
    }

    if (hub_warping) {
        hub_warp_timer++;
        hub_gate_charge = 1;
        hub_warp_flash = min(1, hub_warp_flash + 0.08);
        hub_ripple_pulse = max(hub_ripple_pulse, 0.5 + hub_warp_timer * 0.025);
        hub_bloom_pulse = max(hub_bloom_pulse, 0.6 + hub_warp_timer * 0.018);
        hub_aberration_pulse = max(hub_aberration_pulse, 0.22 + hub_warp_timer * 0.012);
        hub_tear_pulse = max(hub_tear_pulse, 0.2 + hub_warp_timer * 0.012);

        if ((hub_warp_timer mod 3) == 0) {
            repeat (6) {
                hub_push_spark(hub_gate_x, hub_gate_y + random_range(-70, 82), random(360),
                               random_range(3, 10), irandom_range(16, 34),
                               random_range(1.2, 4.2), choose(hub_col_cyan, hub_col_warning, hub_col_white));
            }
        }

        if (hub_warp_timer >= 18 && instance_exists(oPlayer)) {
            warp(hub_warp_room, oPlayer, 0, 0, true);
            exit;
        }
    }
}

for (var i = 0; i < array_length(hub_motes); i++) {
    var _m = hub_motes[i];
    _m.x += _m.vx + sin(_m.seed + hub_time * 0.012) * 0.06;
    _m.y += _m.vy * (0.6 + hub_gate_charge * 0.8);

    if (_m.y < 58) {
        _m.y = hub_floor_y - random_range(60, 220);
        _m.x = random(GAME_WIDTH);
    }
    if (_m.x < -16) _m.x = GAME_WIDTH + 16;
    if (_m.x > GAME_WIDTH + 16) _m.x = -16;
}

for (var i = array_length(hub_sparks) - 1; i >= 0; i--) {
    var _s = hub_sparks[i];
    _s.x += _s.vx;
    _s.y += _s.vy;
    _s.vy += 0.12;
    _s.vx *= 0.982;
    _s.life--;
    if (_s.life <= 0 || _s.y > GAME_HEIGHT + 30) array_delete(hub_sparks, i, 1);
}

for (var i = array_length(hub_bolts) - 1; i >= 0; i--) {
    hub_bolts[i].life--;
    if (hub_bolts[i].life <= 0) array_delete(hub_bolts, i, 1);
}

for (var i = array_length(hub_rings) - 1; i >= 0; i--) {
    var _r = hub_rings[i];
    _r.radius += _r.speed;
    _r.speed *= 0.965;
    _r.life--;
    if (_r.life <= 0 || _r.radius > 520) array_delete(hub_rings, i, 1);
}

for (var i = array_length(hub_streams) - 1; i >= 0; i--) {
    var _st = hub_streams[i];
    _st.y += _st.vy;
    _st.x += sin(_st.seed + hub_time * 0.09) * 0.45;
    _st.vy *= 0.975;
    _st.life--;
    if (_st.life <= 0 || _st.y + _st.len < -40) array_delete(hub_streams, i, 1);
}

if (DEBUG &&
    variable_global_exists("bc_cli_profile_enabled") &&
    global.bc_cli_profile_enabled &&
    variable_global_exists("bc_cli_profile_room") &&
    global.bc_cli_profile_room == "hub") {
    global.bc_cli_profile_hub_frame++;

    var _bc_hub_fps = fps_real;
    if (_bc_hub_fps > 0) {
        global.bc_cli_profile_hub_samples++;
        global.bc_cli_profile_hub_fps_sum += _bc_hub_fps;
        global.bc_cli_profile_hub_fps_min = min(global.bc_cli_profile_hub_fps_min, _bc_hub_fps);
    }
    else {
        global.bc_cli_profile_hub_invalid_samples++;
    }

    if (global.bc_cli_profile_hub_frame >= global.bc_cli_profile_frames) {
        var _bc_hub_avg = global.bc_cli_profile_hub_fps_sum / max(1, global.bc_cli_profile_hub_samples);
        var _bc_hub_min = (global.bc_cli_profile_hub_samples > 0) ? global.bc_cli_profile_hub_fps_min : 0;
        var _bc_hub_surfaces_ok = surface_exists(hub_scene_surface) && surface_exists(hub_glow_surface);

        show_debug_message("[BC_PROFILE] end Hub frames=" + string(global.bc_cli_profile_hub_frame) +
            " fps_min=" + string(_bc_hub_min) +
            " fps_avg=" + string(_bc_hub_avg) +
            " fps_invalid=" + string(global.bc_cli_profile_hub_invalid_samples) +
            " surfaces_ok=" + string(_bc_hub_surfaces_ok));

        global.bc_cli_profile_enabled = false;
        if (global.bc_cli_profile_quit_on_complete)
            game_end();
    }
}
