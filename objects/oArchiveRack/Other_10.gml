function archive_rack_set_t_catchup(_new_t) {

	if (variable_instance_exists(id, "rack_lanes") && _new_t >= _k_rack_t_arm
	    && _new_t <= _k_rack_t_clear) {
		var _rk_fired = 0;
		for (var _rk = 0; _rk < array_length(_k_rack_beats); _rk++) {
			if (t >= _k_rack_beats[_rk]) _rk_fired++;
		}

		var _rk_lo = 0;
		var _rk_hi = _k_rack_lanes - 1;
		if (_rk_fired > 0) {
			_rk_lo = _k_rack_plan[_rk_fired - 1].lo;
			_rk_hi = _k_rack_plan[_rk_fired - 1].hi;
		}

		rack_win_lo = _rk_lo;
		rack_win_hi = _rk_hi;
		rack_half = rack_corridor_at(t);
		rack_half_ext = rack_corridor_ext(rack_half);
		rack_rail = 1;
		rack_dead = (t >= _k_rack_t_blowout);
		rack_blowout = rack_dead ? 0.5 : 0;
		rack_amb = 0.35 + clamp((t - _k_rack_t_arm) / max(1, _k_rack_t_blowout - _k_rack_t_arm), 0, 1) * 0.85;
		rack_heat = clamp((t - _k_rack_t_arm) / max(1, _k_rack_t_blowout - _k_rack_t_arm), 0, 1);
		rack_readout = 1;

		for (var _rl = 0; _rl < _k_rack_lanes; _rl++) {
			var _barred = (_rl < _rk_lo || _rl > _rk_hi) && !rack_dead;
			var _rk_ext = rack_dead ? 0 : (_barred ? 1 : rack_half_ext);
			rack_lanes[_rl].ext = _rk_ext;
			rack_lanes[_rl].target = _rk_ext;
			rack_lanes[_rl].heat = _barred ? 0.5 : 0;
			rack_lanes[_rl].flash = 0;
			rack_lanes[_rl].arm = 0;
		}

		rack_lock_frames = [];
		rack_vents = [];
		rack_sparks = [];
		rack_shards = [];
		rack_arcs = [];
		rack_tips = [];
	}
}

function archive_rack_mote_feed(_mo) {
    switch (_mo.feed) {
        case "rack": rack_rail = min(1, rack_rail + 0.03);
                     rack_rail_heat[0] = min(1.6, rack_rail_heat[0] + 0.02);
                     rack_rail_heat[1] = min(1.6, rack_rail_heat[1] + 0.02);
                     break;
    }
}
