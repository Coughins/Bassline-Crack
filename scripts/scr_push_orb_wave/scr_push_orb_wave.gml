function scr_push_orb_wave() {
    with (oAvoidanceController) {
        push_orb_beat_index++;
        var _shove = _k_push_orb_shove_base + _k_push_orb_shove_growth * push_orb_beat_index;
        var _ramp = 1 + push_orb_beat_index * 0.08;

        if (array_length(push_waves) >= _k_push_wave_cap) array_delete(push_waves, 0, 1);
        array_push(push_waves, {
            y : _k_jr_floor_y,
            prev_y : _k_jr_floor_y,
            speed : -_k_push_wave_speed * _ramp,
            life : _k_push_wave_life,
            max_life : _k_push_wave_life,
            hot : clamp(0.5 + push_orb_beat_index * 0.06, 0, 1),
            thickness : 14 + push_orb_beat_index * 1.5,
            color : (push_orb_beat_index mod 2 == 0) ? _k_er_col_cyan : _k_er_col_warning,
            seed : random(1000)
        });

        with (oPushOrb) {
            vspeed_target = _shove;
            squash_timer = 1;
            hot = 1;
            shove_dir = choose(-1, 1);
            spin_kick = random_range(6, 16) * shove_dir;
        }

        var _gap_x = irandom_range(60, room_width - 60);
        var _spawned = 0;
        var _attempts = 0;
        while (_spawned < _k_push_orb_wave_count && _attempts < 40) {
            var _x = irandom_range(30, room_width - 30);
            _attempts++;
            if (abs(_x - _gap_x) < _k_push_orb_safe_gap) continue;

            var _inst = instance_create_layer(_x, irandom_range(-60, -10), "Instances", oPushOrb);
            _inst.vspeed_current = _shove;
            _inst.vspeed_target = _shove;
            _inst.spawn_pop = 1;
            _inst.hot = 1;
            _inst.reactor_phase = random(1000);
            array_push(push_orb_field, _inst);
            _spawned++;
        }

        push_orb_gap_x = _gap_x;
        push_orb_gap_flash = 1;
    }
}
