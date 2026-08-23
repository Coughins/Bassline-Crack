function scr_jump_rope_impact(_x, _y) {
    with (oAvoidanceController) {
        var _k_beat_ramp     = 0.09;
        var _k_spark_base    = 22;
        var _k_ember_base    = 9;
        var _k_dust_extra    = 2.2;

        var _bi = max(jump_rope_beat_index - 1, 0);
        var _ramp = 1 + _bi * _k_beat_ramp;
        var _hot = clamp(0.55 + _bi * 0.06, 0, 1);
        var _floor_y = _k_jr_floor_y;

        jr_crack_flash = min(1.4, 0.8 * _ramp);
        jr_coil = 0;
        jr_chroma = 1;
        jump_rope_figure_bounce = 1;
        jr_anchor_heat[0] = max(jr_anchor_heat[0], 0.7 * _ramp);
        jr_anchor_heat[1] = max(jr_anchor_heat[1], 0.7 * _ramp);

        scr_impact_pulse(0.4 * _ramp, 0.42 * _ramp, 1.1 * _ramp, _x, _floor_y);
        scr_floor_impact(_x, _floor_y, 0.72 * _ramp, 1);
        scr_floor_impact(_x - _k_jr_crack_span * 0.6, _floor_y, 0.34 * _ramp, 0);
        scr_floor_impact(_x + _k_jr_crack_span * 0.6, _floor_y, 0.34 * _ramp, 0);

        global_ripple_pulse = max(global_ripple_pulse, 0.55 * _ramp);
        tear_amount = max(tear_amount, 0.16 * _ramp);

        array_push(ring_shockwaves, {
            x : _x, y : _floor_y,
            radius : 8,
            max_radius : 260 * _ramp,
            life : 26, max_life : 26,
            width : 10 + _bi * 2,
            hot : _hot,
            vs : 1
        });

        array_push(ring_shockwaves, {
            x : _x, y : _floor_y,
            radius : 24,
            max_radius : 430 * _ramp,
            life : 16, max_life : 16,
            width : 4,
            hot : 0.9,
            vs : 1
        });

        if (array_length(jr_scorches) >= _k_jr_scorch_cap) array_delete(jr_scorches, 0, 1);
        array_push(jr_scorches, {
            x : _x,
            life : 110, life_max : 110,
            w : _k_jr_crack_span * (0.5 + _bi * 0.08),
            hot : 1
        });

        if (array_length(jr_lock_frames) >= _k_jr_lock_cap) array_delete(jr_lock_frames, 0, 1);
        array_push(jr_lock_frames, {
            x1 : max(0, _x - _k_jr_crack_span * (0.72 + _bi * 0.05)),
            x2 : min(room_width, _x + _k_jr_crack_span * (0.72 + _bi * 0.05)),
            y1 : _floor_y - 44 - _bi * 2,
            y2 : _floor_y + 12,
            life : 18,
            life_max : 18,
            hot : _hot,
            seed : random(1000)
        });

        for (var _scan = 0; _scan < 2; _scan++) {
            if (array_length(jr_scan_sweeps) >= _k_jr_scan_cap) array_delete(jr_scan_sweeps, 0, 1);
            array_push(jr_scan_sweeps, {
                x : _x,
                y : _floor_y - _scan * 10,
                w : _k_jr_crack_span * (1.2 + _ramp * 0.6 + _scan * 0.35),
                vy : -random_range(6.5, 13.5) * (0.75 + _hot * 0.35),
                life : 22 + _scan * 4,
                life_max : 22 + _scan * 4,
                hot : 0.65 + _hot * 0.35,
                color : (_scan == 0) ? _k_er_col_cyan : _k_er_col_warning,
                seed : random(1000)
            });
        }

        repeat (round(10 * _ramp)) {
            if (array_length(jr_reactor_streams) >= _k_jr_stream_cap) array_delete(jr_reactor_streams, 0, 1);
            array_push(jr_reactor_streams, {
                x : _x + random_range(-_k_jr_crack_span * 0.78, _k_jr_crack_span * 0.78),
                y : _floor_y + random_range(-4, 10),
                len : random_range(46, 150) * (0.9 + _hot * 0.55),
                vy : -random_range(5.0, 12.0) * (0.85 + _hot * 0.45),
                w : random_range(1.6, 5.4),
                life : irandom_range(18, 36),
                life_max : 36,
                hot : _hot,
                color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet, c_white),
                seed : random(1000)
            });
        }

        var _dust_count = round(_k_jr_dust_count * _k_dust_extra * _ramp);
        for (var i = 0; i < _dust_count; i++) {
            var _side = choose(-1, 1);
            array_push(jump_rope_dust, {
                x: _x + random_range(-70, 70),
                y: _floor_y - random(6),
                vx: _side * random_range(1, 5.5) * _ramp,
                vy: random_range(-4.5, -1),
                grav: 0.15,
                life: 0,
                max_life: 22 + irandom(16),
                size: random_range(2, 5.5),
                hot: 0.35 + random(0.45)
            });
        }

        if (array_length(arrow_ring_particles) < 260) {
            repeat (round(_k_spark_base * _ramp)) {
                var _sa = choose(0, 180) + random_range(-40, 40);
                var _ss = random_range(3, 10 * _ramp);
                array_push(arrow_ring_particles, {
                    x : _x + random_range(-90, 90), y : _floor_y,
                    vx : lengthdir_x(_ss, _sa),
                    vy : -abs(lengthdir_y(_ss, _sa)) * 0.8,
                    life : 18, max_life : 18,
                    size : random_range(0.07, 0.2),
                    grav : 0.24, drag : 0.94,
                    hot : _hot
                });
            }
        }

        repeat (round(_k_ember_base * _ramp)) {
            array_push(ring_embers, {
                x : _x + random_range(-140, 140), y : _floor_y - random(8),
                vx : random_range(-1.8, 1.8),
                vy : random_range(-4, -1),
                life : 46 + irandom(34), max_life : 80,
                size : random_range(0.08, 0.2),
                hot : 0.55 + random(0.4)
            });
        }

        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 7 * _ramp);
            oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.016 * _ramp);
            oCameraController.angle_kick += choose(-1, 1) * 1.1 * _ramp;
            oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.1 * _ramp);
            oCameraController.letterbox_target = 0.1;
        }

        scr_add_light(_x, _floor_y, _k_er_col_cyan, 6 * _ramp);
    }
}
