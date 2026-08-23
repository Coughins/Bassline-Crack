
_k_rack_lanes = 9;
_k_rack_top_y = 0;
_k_rack_floor_y = 576;
_k_rack_wall_l = 32;
_k_rack_wall_r = 768;
_k_rack_tine_inset = 7;
_k_rack_rail_w = 26;

_k_rack_pitch = (_k_rack_floor_y - _k_rack_top_y) / _k_rack_lanes;
_k_rack_reach = (_k_rack_wall_r - _k_rack_wall_l) * 0.5;
_k_rack_mid_x = (_k_rack_wall_l + _k_rack_wall_r) * 0.5;

_k_rack_corridor_start = 368;
_k_rack_corridor_end = 150;
_k_rack_corridor_ease = 1.25;

_k_rack_close_rate = 0.34;
_k_rack_open_rate = 0.15;
_k_rack_lethal_ext = 0.05;
_k_rack_snap = 0.55;

_k_rack_read_floor = 0.17;
_k_rack_coil_ease = 1.45;
_k_rack_lock_life = 22;
_k_rack_lock_tick_heavy = 14;
_k_rack_lock_tick_fast = 9;

_k_rack_vent_cols = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];
_k_rack_col_heavy = global.avoid_col_warning;
_k_rack_col_fast = global.avoid_col_cyan;
_k_rack_col_rail = global.avoid_col_armor_mid;
_k_rack_col_rail_edge = global.avoid_col_armor_edge;
_k_rack_col_body = global.avoid_col_armor_dark;

_k_rack_shake_heavy = 7;
_k_rack_zoom_heavy = 0.045;
_k_rack_flash_heavy = 0.09;
_k_rack_shake_blowout = 16;
_k_rack_letterbox = 0.45;
_k_rack_vent_cap = 88;
_k_rack_spark_cap = 150;
_k_rack_shard_cap = 90;

_k_rack_beats = [ 1036, 1052, 1070, 1080, 1095, 1111, 1122, 1135, 1150, 1162 ];
_k_rack_plan = [
  { lo : 0, hi : 1, fast : false },
  { lo : 1, hi : 2, fast : false },
  { lo : 2, hi : 3, fast : false },
  { lo : 2, hi : 3, fast : true  },
  { lo : 3, hi : 4, fast : false },
  { lo : 4, hi : 5, fast : false },
  { lo : 4, hi : 5, fast : true  },
  { lo : 4, hi : 5, fast : true  },
  { lo : 5, hi : 6, fast : false },
  { lo : 5, hi : 6, fast : true  }
];

_k_rack_t_arm = 995;
_k_rack_t_blowout = 1172;
_k_rack_t_clear = 1213;

_k_rack_long_gap = 15;
_k_rack_climb_rate = 5.0;
_k_rack_run_rate = 3.0;

if (array_length(_k_rack_beats) != array_length(_k_rack_plan)) {
  show_debug_message("RACK: _k_rack_beats has " + string(array_length(_k_rack_beats))
                   + " entries but _k_rack_plan has " + string(array_length(_k_rack_plan)));
}

for (var _rp = 1; _rp < array_length(_k_rack_plan); _rp++) {
  var _rp_a = _k_rack_plan[_rp - 1];
  var _rp_b = _k_rack_plan[_rp];
  var _rp_gap = _k_rack_beats[_rp] - _k_rack_beats[_rp - 1];
  var _rp_tag = " (step " + string(_rp) + ", t" + string(_k_rack_beats[_rp]) + ")";

  if (min(_rp_a.hi, _rp_b.hi) < max(_rp_a.lo, _rp_b.lo)) {
    show_debug_message("RACK: no lane in common with the window before it" + _rp_tag);
  }
  if (_rp_b.hi < _rp_a.hi) {
    show_debug_message("RACK: window top FALLS — forces a descent" + _rp_tag);
  }
  if (_rp_b.lo != _rp_a.lo && _rp_gap < _k_rack_long_gap) {
    show_debug_message("RACK: window moves on a " + string(_rp_gap)
                     + "-frame gap, which buys only "
                     + string(_rp_gap * _k_rack_climb_rate) + "px of climb against "
                     + string(_k_rack_pitch) + "px owed" + _rp_tag);
  }
}

var _rk_worst_close = 0;
for (var _rc = _k_rack_beats[0]; _rc < _k_rack_t_blowout; _rc++) {
  var _rc_p0 = clamp((_rc - _k_rack_beats[0]) / (_k_rack_t_blowout - _k_rack_beats[0]), 0, 1);
  var _rc_p1 = clamp((_rc + 1 - _k_rack_beats[0]) / (_k_rack_t_blowout - _k_rack_beats[0]), 0, 1);
  var _rc_h0 = lerp(_k_rack_corridor_start, _k_rack_corridor_end, power(_rc_p0, _k_rack_corridor_ease));
  var _rc_h1 = lerp(_k_rack_corridor_start, _k_rack_corridor_end, power(_rc_p1, _k_rack_corridor_ease));
  _rk_worst_close = max(_rk_worst_close, _rc_h0 - _rc_h1);
}
if (_rk_worst_close >= _k_rack_run_rate * 0.85) {
  show_debug_message("RACK: corridor closes at " + string(_rk_worst_close)
                   + " px/frame per side against a " + string(_k_rack_run_rate)
                   + " px/frame run — the squeeze is unoutrunnable");
}

rack_lane_y0 = function(_i) { return _k_rack_floor_y - (_i + 1) * _k_rack_pitch; };
rack_lane_y1 = function(_i) { return _k_rack_floor_y - _i * _k_rack_pitch; };
rack_lane_cy = function(_i) { return _k_rack_floor_y - (_i + 0.5) * _k_rack_pitch; };

rack_band_y0 = function(_i) { return rack_lane_y0(_i) + _k_rack_tine_inset; };
rack_band_y1 = function(_i) { return rack_lane_y1(_i) - _k_rack_tine_inset; };

rack_win_top = function(_hi) {
  return (_hi >= _k_rack_lanes - 1) ? _k_rack_top_y : rack_band_y1(_hi + 1);
};
rack_win_bot = function(_lo) {
  return (_lo <= 0) ? _k_rack_floor_y : rack_band_y0(_lo - 1);
};

rack_corridor_at = function(_t) {
  if (_t <= _k_rack_beats[0]) return _k_rack_corridor_start;
  var _p = clamp((_t - _k_rack_beats[0]) / (_k_rack_t_blowout - _k_rack_beats[0]), 0, 1);
  return lerp(_k_rack_corridor_start, _k_rack_corridor_end, power(_p, _k_rack_corridor_ease));
};
rack_corridor_ext = function(_half) {
  return clamp(1 - _half / _k_rack_reach, 0, 1);
};

rack_tine_tip = function(_side, _ext) {
  return (_side < 0) ? _k_rack_wall_l + _k_rack_reach * _ext
                     : _k_rack_wall_r - _k_rack_reach * _ext;
};

rack_live = false;
rack_armed = false;
rack_dead = false;
rack_win_lo = 0;
rack_win_hi = 1;
rack_half = 368;
rack_half_ext = 0;

rack_rail = 0;
rack_amb = 0;
rack_coil = 0;
rack_heat = 0;
rack_readout = 0;
rack_slam_flash = 0;
rack_beat_flash = 0;
rack_blowout = 0;
rack_chroma = 0;
rack_hb = 0;
rack_hb_phase = 0;

rack_rail_heat = [ 0, 0 ];

rack_lanes = [];
for (var _rl = 0; _rl < _k_rack_lanes; _rl++) {
  array_push(rack_lanes, {
    ext : 0,
    target : 0,
    heat : 0,
    flash : 0,
    arm : 0,
    seed : random(1000)
  });
}

rack_lock_frames = [];
rack_vents = [];
rack_sparks = [];
rack_shards = [];
rack_scars = [];
rack_arcs = [];
rack_tips = [];
