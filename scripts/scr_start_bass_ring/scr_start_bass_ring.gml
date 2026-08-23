function scr_start_bass_ring(_idx)
{
    var _ring = undefined;

    with (oAvoidanceController)
    {
        var _px = instance_exists(oPlayer) ? oPlayer.x : _k_fin_cx;
        var _py = instance_exists(oPlayer) ? oPlayer.y : _k_fin_cy;

        fin_ensure_cage_layout();

        var _gap_base = _k_fin_gap_base + _idx * _k_fin_gap_step;
        var _rot_start = 0;
        if (_idx < array_length(fin_cage_layout) && is_struct(fin_cage_layout[_idx])) {
            _gap_base = fin_cage_layout[_idx].gap;
            _rot_start = fin_cage_layout[_idx].rot;
        }
        var _gap_delta = _gap_base - (_k_fin_gap_base + _idx * _k_fin_gap_step);

        _ring = {
            idx      : _idx,
            state    : "closing",
            timer    : 0,
            age      : 0,
            orbs     : [],
            angles   : [],
            anchor_x : _px,
            anchor_y : _py,
            center_x : _px,
            center_y : _py,
            lock_x   : _px,
            lock_y   : _py,
            radius   : _k_fin_r_spawn[_idx],
            gap_home : _gap_base,
            gap_now  : _gap_base + _rot_start,
            rot_start : _rot_start,
            rot_now   : _rot_start,
            rot_f     : _k_fin_rot_settle[_idx],
            close_f  : _k_fin_close_frames[_idx],
            coil_f   : _k_fin_coil_frames[_idx],
            conv_f   : _k_fin_converge_frames[_idx],
            conv_total    : 0,
            strike_radius : _k_fin_r_lock[_idx],
            ghost_timer   : 0,
            detonated     : false,
            spikes_done   : 0,
            spikes_total  : 0
        };

        var _layers    = _k_fin_layers[_idx];
        var _per_layer = _k_fin_orb_count[_idx];
        var _gap_count = _k_fin_gap_count[_idx];
        var _half_gap  = _k_fin_gap_width[_idx] / 2;

        var _spike_mode  = _k_fin_spike_mode[_idx];
        var _spike_start = _k_fin_spike_start[_idx] + _gap_delta;

        for (var _ly = 0; _ly < _layers; _ly++)
        {
            var _mult  = (_ly == 0) ? 1 : 0.66;
            var _twist = (_ly == 0) ? 0 : (180 / _per_layer);

            var _slot_step = 360 / _per_layer;

            for (var _i = 0; _i < _per_layer; _i++)
            {
                var _ang = _i * _slot_step + _twist;
                var _spawn_ang = _ang + _ring.rot_now;

                var _in_gap = false;
                var _is_edge = false;
                for (var _g = 0; _g < _gap_count; _g++)
                {
                    var _ga  = _ring.gap_home + _g * (360 / _gap_count);
                    var _off = abs(angle_difference(_ang, _ga));
                    if (_off < _half_gap) { _in_gap = true; break; }

                    if (_off - _slot_step < _half_gap) _is_edge = true;
                }
                if (_in_gap) continue;

                var _fx = _px + lengthdir_x(_k_fin_comet_r, _spawn_ang);
                var _fy = _py + lengthdir_y(_k_fin_comet_r, _spawn_ang);

                var _b = instance_create_layer(_fx, _fy, "Instances", oBassRingOrb);
                _b.ring_home_angle = _ang;
                _b.ring_angle  = _spawn_ang;
                _b.layer_mult  = _mult;
                _b.gap_edge    = _is_edge;
                _b.fly_x       = _fx;
                _b.fly_y       = _fy;
                _b.fly_delay   = floor((_i / max(_per_layer - 1, 1))
                                       * max(_k_fin_close_frames[_idx] - _k_fin_comet_frames, 0));
                _b.arrived     = false;
                _b.spear_trail = [];

                _b.spike_rel = (_spike_mode == 0)
                             ? ((((_ang - _spike_start) mod 360) + 360) mod 360)
                             : abs(angle_difference(_ang, _spike_start));

                array_push(_ring.orbs, _b);
                if (_ly == 0) array_push(_ring.angles, _ang);
            }
        }

        array_push(bass_rings, _ring);

        fin_charge   = max(fin_charge, 0.3);
        fin_gap_glow = max(fin_gap_glow, 0.4);
        array_push(bass_ring_pierce_flashes, {
            x : _px, y : _py, life : 12, max_life : 12, size : 0.8, hot : 0.7
        });
        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 4 + _idx);
        }
    }

    return _ring;
}
