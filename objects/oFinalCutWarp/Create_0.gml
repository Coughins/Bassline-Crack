// ============================================================================
// FINAL CUT WARP
// PERSISTENT GUI HANDOFF BETWEEN ROOMS.
// ============================================================================

depth = -15000;

fw_ph          = 0;   // frames RENDERED, advanced by Draw GUI End
fw_steps       = 0;   // frames STEPPED, purely a watchdog for the line above
fw_warped      = false;
fw_target_room = room;
fw_source_room = room;

fw_span0     = 0.13;
fw_scar_pts  = [];
fw_sparks    = [];

_k_fw_seal = 12;   // frames to go from the bar to a sealed frame
_k_fw_hold = 3;    // frames held fully opaque across the room change
_k_fw_open = 26;   // frames the light takes to slide off and reveal
_k_fw_tail = 28;   // frames of scar and wash on the victory room

_k_fw_life = _k_fw_seal + _k_fw_hold + _k_fw_open + _k_fw_tail;

_k_fw_seal_ease = 0.95;
_k_fw_open_ease = 1.30;

_k_fw_edge_max  = 96;
_k_fw_edge_min  = 16;
_k_fw_edge_blur = 1.25; // front softness per px/frame of speed: motion blur, so
_k_fw_taper     = 0.72;
_k_fw_spark_max = 240;

fw_axis = function(_gw, _gh) {
  var _diag = point_distance(0, 0, _gw, _gh);
  return {
    cx   : _gw * 0.5,
    cy   : _gh * 0.5,
    ux   :  _gw / _diag,
    uy   : -_gh / _diag,
    nx   :  _gh / _diag,
    ny   :  _gw / _diag,
    diag : _diag,
    rmax : (_gw * _gh) / _diag
  };
};

fw_front_out = function(_p, _ax, _gs) {
  var _seal = _ax.rmax + (_k_fw_edge_max + 40) * _gs;
  if (_p <= _k_fw_seal) {
    return lerp(5 * _gs, _seal, power(clamp(_p / _k_fw_seal, 0, 1), _k_fw_seal_ease));
  }
  return _seal + (_p - _k_fw_seal) * 30 * _gs;
};

fw_front_in = function(_p, _ax, _gs) {
  var _from = _k_fw_seal + _k_fw_hold;
  if (_p <= _from) return 0;
  var _q = clamp((_p - _from) / _k_fw_open, 0, 1);
  return (_ax.rmax + (_k_fw_edge_max + 60) * _gs) * power(_q, _k_fw_open_ease);
};

fw_draw_band = function(_stops, _ax, _len, _alpha) {
  var _n = array_length(_stops);
  if (_n < 2 || _alpha <= 0.002) return;

  for (var _i = 1; _i < _n; _i++) {
    if (_stops[_i].d < _stops[_i - 1].d) _stops[_i].d = _stops[_i - 1].d;
  }

  var _cu = [-_len, -_len * _k_fw_taper, _len * _k_fw_taper, _len];
  var _cw = [0, 1, 1, 0];

  draw_primitive_begin(pr_trianglelist);
  for (var _r = 0; _r < _n - 1; _r++) {
    for (var _c = 0; _c < 3; _c++) {
      var _q = [[_c, _r], [_c + 1, _r], [_c + 1, _r + 1],
                [_c, _r], [_c + 1, _r + 1], [_c, _r + 1]];
      for (var _v = 0; _v < 6; _v++) {
        var _ci = _q[_v][0], _ri = _q[_v][1];
        var _st = _stops[_ri];
        draw_vertex_colour(_ax.cx + _ax.ux * _cu[_ci] + _ax.nx * _st.d,
                           _ax.cy + _ax.uy * _cu[_ci] + _ax.ny * _st.d,
                           _st.col, _st.a * _cw[_ci] * _alpha);
      }
    }
  }
  draw_primitive_end();
};

fw_draw_front = function(_ax, _d, _len, _speed, _gs, _power) {
  if (_power <= 0.01) return;
  if (abs(_d) > _ax.rmax + 130 * _gs) return;

  var _x0 = _ax.cx + _ax.ux * -_len + _ax.nx * _d;
  var _y0 = _ax.cy + _ax.uy * -_len + _ax.ny * _d;
  var _x1 = _ax.cx + _ax.ux *  _len + _ax.nx * _d;
  var _y1 = _ax.cy + _ax.uy *  _len + _ax.ny * _d;
  var _ch = clamp(_speed * 0.22, 1.5 * _gs, 15 * _gs);

  draw_set_color(global.avoid_col_cyan);
  draw_set_alpha(_power * 0.16);
  draw_line_width(_x0, _y0, _x1, _y1, (26 + _speed * 0.9) * _gs);

  draw_set_color(global.avoid_col_warning);
  draw_set_alpha(_power * 0.22);
  draw_line_width(_x0 + _ax.nx * _ch, _y0 + _ax.ny * _ch,
                  _x1 + _ax.nx * _ch, _y1 + _ax.ny * _ch, 3.0 * _gs);

  draw_set_color(global.avoid_col_cyan_soft);
  draw_set_alpha(_power * 0.30);
  draw_line_width(_x0 - _ax.nx * _ch, _y0 - _ax.ny * _ch,
                  _x1 - _ax.nx * _ch, _y1 - _ax.ny * _ch, 3.0 * _gs);

  draw_set_color(c_white);
  draw_set_alpha(_power * 0.72);
  draw_line_width(_x0, _y0, _x1, _y1, 1.8 * _gs);
};

fw_push_sparks = function(_n, _power) {
  var _ax = GAME_WIDTH, _ay = -GAME_HEIGHT;
  var _al = point_distance(0, 0, _ax, _ay);
  var _ux = _ax / _al, _uy = _ay / _al;
  var _px = -_uy,      _py = _ux;

  for (var _i = 0; _i < _n; _i++) {
    if (array_length(fw_sparks) >= _k_fw_spark_max) return;

    var _f  = random_range(-1, 1);
    var _s  = choose(-1, 1);
    var _va = random_range(4, 26) * _power * choose(-1, 1);
    var _vp = random_range(0.4, 6.0) * _power * _s;
    var _l  = 34 + irandom(44);

    array_push(fw_sparks, {
      x  : GAME_WIDTH  * 0.5 + _ux * _al * 0.5 * _f,
      y  : GAME_HEIGHT * 0.5 + _uy * _al * 0.5 * _f,
      vx : _ux * _va + _px * _vp,
      vy : _uy * _va + _py * _vp,
      life : _l, life_max : _l,
      size : random_range(0.7, 2.0),
      hot  : random_range(0.55, 1),
      col  : choose(global.avoid_col_cyan, global.avoid_col_cyan_soft,
                    global.avoid_col_cyan, c_white)
    });
  }
};

fw_adopt_sparks = function(_src) {
  for (var _i = 0; _i < array_length(_src); _i++) {
    if (array_length(fw_sparks) >= _k_fw_spark_max) return;
    var _s = _src[_i];
    array_push(fw_sparks, {
      x : _s.x, y : _s.y, vx : _s.vx, vy : _s.vy,
      life : _s.life, life_max : _s.life_max,
      size : _s.size, hot : _s.hot, col : _s.col
    });
  }
};

fw_do_warp = function() {
  global.fin_cut_arrival = true;

  player_set_stopped(false);

  if (instance_exists(oPlayer)) {
    oPlayer.invincible_timer = min(oPlayer.invincible_timer, room_speed);
    warp(fw_target_room, oPlayer);
  } else {
    room_goto(fw_target_room);
  }
};
