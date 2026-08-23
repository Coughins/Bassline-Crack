if (rack_rail > 0.004 || array_length(rack_shards) > 0 || array_length(rack_scars) > 0 ||
    array_length(rack_sparks) > 0) {

  var _rk_open_top = rack_win_top(rack_win_hi);
  var _rk_open_bot = rack_win_bot(rack_win_lo);
  var _rk_rail_a = clamp(rack_rail, 0, 1);
  var _rk_dead_fade = rack_dead ? clamp(rack_blowout, 0, 1) : 1;

  var _rk_rw = _k_rack_rail_w * _rk_rail_a;
  if (_rk_rw > 0.5) {
    for (var _rr = -1; _rr <= 1; _rr += 2) {
      var _rx0 = (_rr < 0) ? _k_rack_wall_l : _k_rack_wall_r - _rk_rw;
      var _rx1 = _rx0 + _rk_rw;
      var _rh = rack_rail_heat[(_rr < 0) ? 0 : 1];

      draw_set_alpha(_rk_rail_a * 0.92);
      draw_set_color(_k_rack_col_body);
      draw_rectangle(_rx0, _k_rack_top_y, _rx1, _k_rack_floor_y, false);

      var _rk_face_x = (_rr < 0) ? _rx1 : _rx0;
      draw_set_alpha(_rk_rail_a * (0.35 + _rh * 0.45 + rack_beat_flash * 0.35));
      draw_set_color(merge_color(_k_rack_col_rail, c_white,
                                 clamp(_rh + rack_slam_flash * 0.5, 0, 1) * 0.5));
      draw_line_width(_rk_face_x, _k_rack_top_y, _rk_face_x, _k_rack_floor_y, 2);

      draw_set_alpha(_rk_rail_a * 0.4);
      draw_set_color(_k_rack_col_rail);
      for (var _rs = 0; _rs <= _k_rack_lanes; _rs++) {
        var _rsy = _k_rack_floor_y - _rs * _k_rack_pitch;
        draw_line_width(_rx0, _rsy, _rx1, _rsy, 1);
      }
    }
  }

  for (var _li = 0; _li < _k_rack_lanes; _li++) {
    var _ln = rack_lanes[_li];
    if (_ln.ext <= 0.002) continue;

    var _by0 = rack_band_y0(_li);
    var _by1 = rack_band_y1(_li);
    var _lheat = clamp(_ln.heat, 0, 1);
    var _lflash = clamp(_ln.flash, 0, 1);

    for (var _sd = -1; _sd <= 1; _sd += 2) {
      var _tip = rack_tine_tip(_sd, _ln.ext);
      var _root = (_sd < 0) ? _k_rack_wall_l : _k_rack_wall_r;
      var _x0 = min(_root, _tip);
      var _x1 = max(_root, _tip);
      if (_x1 - _x0 < 1) continue;

      draw_set_alpha(_rk_dead_fade * 0.95);
      draw_set_color(_k_rack_col_body);
      draw_rectangle(_x0, _by0, _x1, _by1, false);

      draw_set_alpha(_rk_dead_fade * (0.42 + _lheat * 0.35 + _lflash * 0.4));
      draw_set_color(merge_color(_k_rack_col_rail_edge, c_white, _lheat * 0.4 + _lflash * 0.5));
      draw_line_width(_x0, _by0, _x1, _by0, 1.5);
      draw_line_width(_x0, _by1, _x1, _by1, 1.5);

      draw_set_alpha(_rk_dead_fade * (0.14 + _lheat * 0.16));
      draw_set_color(_k_rack_col_rail);
      var _rib_step = 46;
      var _rib_n = floor((_x1 - _x0) / _rib_step);
      for (var _rb = 1; _rb <= _rib_n; _rb++) {
        var _rbx = (_sd < 0) ? _x0 + _rb * _rib_step : _x1 - _rb * _rib_step;
        draw_line_width(_rbx, _by0 + 3, _rbx, _by1 - 3, 1);
      }

      gpu_set_blendmode(bm_add);

      var _edge_col = merge_color(global.avoid_col_ember, c_white,
                                  0.25 + max(_lflash, rack_slam_flash * 0.5) * 0.6);
      draw_set_color(_edge_col);
      draw_set_alpha(_rk_dead_fade * (0.3 + _lheat * 0.4 + _lflash * 0.5));
      draw_line_width(_tip, _by0 + 1, _tip, _by1 - 1, 3 + _lflash * 4);

      draw_set_color(c_white);
      draw_set_alpha(_rk_dead_fade * (0.35 + _lflash * 0.6) * (0.4 + _lheat * 0.6));
      draw_line_width(_tip, _by0 + 2, _tip, _by1 - 2, 1);

      var _grad = 26 + _lflash * 40;
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(_tip, _by0, _edge_col, _rk_dead_fade * (0.2 + _lflash * 0.35));
      draw_vertex_colour(_tip, _by1, _edge_col, _rk_dead_fade * (0.2 + _lflash * 0.35));
      draw_vertex_colour(_tip + _sd * _grad, _by0, _edge_col, 0);
      draw_vertex_colour(_tip + _sd * _grad, _by1, _edge_col, 0);
      draw_primitive_end();

      gpu_set_blendmode(bm_normal);
    }
  }

  gpu_set_blendmode(bm_add);

  for (var _ai = 0; _ai < _k_rack_lanes; _ai++) {
    var _an = rack_lanes[_ai];
    if (_an.arm <= 0.02) continue;

    var _ay0 = rack_band_y0(_ai);
    var _ay1 = rack_band_y1(_ai);
    var _aa = clamp(_an.arm, 0, 1);
    var _acol = global.avoid_col_warning;

    draw_set_color(_acol);
    for (var _asd = -1; _asd <= 1; _asd += 2) {
      var _aroot = (_asd < 0) ? _k_rack_wall_l : _k_rack_wall_r;
      var _hn = 7;
      for (var _h = 0; _h < _hn; _h++) {
        var _hf = _h / _hn;
        var _hx = _aroot + _asd * (_hf * _k_rack_reach + frac(_an.seed + t * 0.02) * 24);
        draw_set_alpha(_aa * 0.2 * (1 - _hf));
        draw_line_width(_hx, _ay0 + 4, _hx, _ay1 - 4, 2);
      }
    }

    draw_set_alpha(_aa * _aa * 0.11);
    draw_rectangle(_k_rack_wall_l, _ay0, _k_rack_wall_r, _ay1, false);
  }

  for (var _lf = 0; _lf < array_length(rack_lock_frames); _lf++) {
    var _lk = rack_lock_frames[_lf];
    var _lka = clamp(_lk.life / _lk.life_max, 0, 1);
    var _lk_pulse = 0.6 + 0.4 * sin(_lk.seed + current_time * 0.019);
    var _lky0 = rack_band_y0(_lk.lane);
    var _lky1 = rack_band_y1(_lk.lane);

    scr_draw_lock_bracket(_k_rack_wall_l + 3, _lky0, _k_rack_wall_r - 3, _lky1,
                          _lk.fast ? _k_rack_col_fast : _k_rack_col_heavy,
                          _lk.hot, _lka,
                          _lk.fast ? _k_rack_lock_tick_fast : _k_rack_lock_tick_heavy,
                          false, 5, 0, _lk_pulse, global.avoid_col_cyan);
  }

  if (rack_armed || rack_dead) {
    var _bx_a = _rk_rail_a * (0.5 + rack_amb * 0.3) * _rk_dead_fade;
    var _bx_col = global.avoid_col_cyan;
    var _bx_hot = merge_color(_bx_col, c_white, 0.55);
    var _bx_l = _k_rack_mid_x - rack_half;
    var _bx_r = _k_rack_mid_x + rack_half;

    var _bx_body = _bx_a * (0.075 + rack_hb * 0.075);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_bx_l, _rk_open_top, _bx_col, _bx_body);
    draw_vertex_colour(_bx_r, _rk_open_top, _bx_col, _bx_body);
    draw_vertex_colour(_bx_l, _rk_open_bot, _bx_col, _bx_body);
    draw_vertex_colour(_bx_r, _rk_open_bot, _bx_col, _bx_body);
    draw_primitive_end();

    draw_set_color(_bx_col);
    draw_set_alpha(_bx_a * 0.5);
    draw_line_width(_bx_l, _rk_open_top, _bx_r, _rk_open_top, 2);
    draw_line_width(_bx_l, _rk_open_bot, _bx_r, _rk_open_bot, 2);
    draw_line_width(_bx_l, _rk_open_top, _bx_l, _rk_open_bot, 2);
    draw_line_width(_bx_r, _rk_open_top, _bx_r, _rk_open_bot, 2);

    draw_set_color(_bx_hot);
    draw_set_alpha(_bx_a * 0.8);
    draw_line_width(_bx_l, _rk_open_top, _bx_r, _rk_open_top, 1);
    draw_line_width(_bx_l, _rk_open_bot, _bx_r, _rk_open_bot, 1);
    draw_line_width(_bx_l, _rk_open_top, _bx_l, _rk_open_bot, 1);
    draw_line_width(_bx_r, _rk_open_top, _bx_r, _rk_open_bot, 1);

    var _bx_t = 10;
    draw_set_alpha(_bx_a);
    for (var _bxi = 0; _bxi < 4; _bxi++) {
      var _bcx = (_bxi mod 2 == 0) ? _bx_l : _bx_r;
      var _bcy = (_bxi < 2) ? _rk_open_top : _rk_open_bot;
      var _bsx = (_bxi mod 2 == 0) ? 1 : -1;
      var _bsy = (_bxi < 2) ? 1 : -1;
      draw_line_width(_bcx, _bcy, _bcx + _bsx * _bx_t, _bcy, 2);
      draw_line_width(_bcx, _bcy, _bcx, _bcy + _bsy * _bx_t, 2);
    }

    if (!rack_dead) {
      var _cf_a = _bx_a * 0.55;
      draw_set_color(_bx_col);
      draw_set_alpha(_cf_a * 0.3);
      draw_line_width(_bx_l, _k_rack_floor_y - 3, _bx_r, _k_rack_floor_y - 3, 3);
      draw_set_color(_bx_hot);
      draw_set_alpha(_cf_a);
      for (var _cfs = -1; _cfs <= 1; _cfs += 2) {
        var _cfx = _k_rack_mid_x + _cfs * rack_half;
        draw_line_width(_cfx, _k_rack_floor_y - 16, _cfx, _k_rack_floor_y - 1, 2);
        draw_line_width(_cfx, _k_rack_floor_y - 9,
                        _cfx - _cfs * 9, _k_rack_floor_y - 9, 1);
      }
    }
  }

  if (rack_readout > 0.02) {
    var _ro_a = clamp(rack_readout, 0, 1) * _rk_rail_a * _rk_dead_fade;

    var _ro_fired = 0;
    for (var _rf = 0; _rf < array_length(_k_rack_beats); _rf++) {
      if (t >= _k_rack_beats[_rf]) _ro_fired++;
    }

    var _ro_n1_lo = -1, _ro_n1_hi = -1, _ro_n1_fast = false;
    if (_ro_fired < array_length(_k_rack_plan)) {
      _ro_n1_lo = _k_rack_plan[_ro_fired].lo;
      _ro_n1_hi = _k_rack_plan[_ro_fired].hi;
      _ro_n1_fast = _k_rack_plan[_ro_fired].fast;
    }
    var _ro_n2_lo = -1, _ro_n2_hi = -1;
    if (_ro_fired + 1 < array_length(_k_rack_plan)) {
      _ro_n2_lo = _k_rack_plan[_ro_fired + 1].lo;
      _ro_n2_hi = _k_rack_plan[_ro_fired + 1].hi;
    }

    var _ro_w = _k_rack_rail_w - 10;
    var _ro_pad = 5;

    for (var _rd = -1; _rd <= 1; _rd += 2) {
      var _rox0 = (_rd < 0) ? _k_rack_wall_l + 5 : _k_rack_wall_r - 5 - _ro_w;
      var _rox1 = _rox0 + _ro_w;

      for (var _rc = 0; _rc < _k_rack_lanes; _rc++) {
        var _rcy0 = rack_lane_y0(_rc) + _ro_pad;
        var _rcy1 = rack_lane_y1(_rc) - _ro_pad;
        var _open_now = (_rc >= rack_win_lo && _rc <= rack_win_hi);
        var _open_n1 = (_ro_n1_lo >= 0 && _rc >= _ro_n1_lo && _rc <= _ro_n1_hi);
        var _open_n2 = (_ro_n2_lo >= 0 && _rc >= _ro_n2_lo && _rc <= _ro_n2_hi);

        if (_open_now) {
          draw_set_color(global.avoid_col_cyan);
          draw_set_alpha(_ro_a * 0.34);
          draw_rectangle(_rox0, _rcy0, _rox1, _rcy1, false);
          draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.5));
          draw_set_alpha(_ro_a * 0.7);
          draw_rectangle(_rox0, _rcy0, _rox1, _rcy1, true);
        } else {
          draw_set_color(_k_rack_col_rail);
          draw_set_alpha(_ro_a * 0.3);
          draw_rectangle(_rox0, _rcy0, _rox1, _rcy1, true);
        }

        if (_open_now && !_open_n1) {
          var _rc_pulse = 0.45 + 0.55 * sin(current_time * 0.021 + _rc);
          draw_set_color(_ro_n1_fast ? _k_rack_col_fast : _k_rack_col_heavy);
          draw_set_alpha(_ro_a * (0.5 + rack_coil * 0.5) * _rc_pulse);
          draw_rectangle(_rox0 - 2, _rcy0 - 2, _rox1 + 2, _rcy1 + 2, true);
        }

        if (_open_n2) {
          var _pipx = (_rd < 0) ? _rox1 + 4 : _rox0 - 4;
          draw_set_color(global.avoid_col_cyan_soft);
          draw_set_alpha(_ro_a * 0.55);
          draw_line_width(_pipx, (_rcy0 + _rcy1) * 0.5 - 4,
                          _pipx, (_rcy0 + _rcy1) * 0.5 + 4, 2);
        }
      }
    }
  }

  for (var _tf = 0; _tf < array_length(rack_tips); _tf++) {
    var _tp = rack_tips[_tf];
    var _tpa = clamp(_tp.life / _tp.life_max, 0, 1);
    var _tps = (1 - _tpa) * 46 + 8;

    draw_set_color(merge_color(_tp.color, c_white, 0.4 + _tpa * 0.4));
    draw_set_alpha(_tpa * _tpa * 0.5 * _tp.hot);
    draw_line_width(_tp.x, _tp.y - _tps, _tp.x, _tp.y + _tps, 2 + _tpa * 4);

    draw_set_color(c_white);
    draw_set_alpha(_tpa * _tpa * 0.7 * _tp.hot);
    draw_line_width(_tp.x, _tp.y - _tps * 0.4, _tp.x, _tp.y + _tps * 0.4, 1);
  }

  for (var _si = 0; _si < array_length(rack_sparks); _si++) {
    var _sk = rack_sparks[_si];
    var _ska = clamp(_sk.life / _sk.life_max, 0, 1);
    var _sklen = 2 + point_distance(0, 0, _sk.vx, _sk.vy) * 0.9;
    var _skdir = point_direction(0, 0, _sk.vx, _sk.vy);

    draw_set_color(merge_color(_sk.color, c_white, _sk.hot * 0.5));
    draw_set_alpha(_ska * 0.75);
    draw_line_width(_sk.x, _sk.y,
                    _sk.x - lengthdir_x(_sklen, _skdir), _sk.y - lengthdir_y(_sklen, _skdir),
                    max(1, _sk.size * _ska));
  }

  gpu_set_blendmode(bm_normal);

  for (var _di = 0; _di < array_length(rack_shards); _di++) {
    var _sh = rack_shards[_di];
    var _sha = clamp(_sh.life / _sh.life_max, 0, 1);
    var _shs = _sh.size * (0.5 + _sha * 0.5);
    var _shc = merge_color(_sh.color, c_white, _sh.hot * _sha * 0.6);

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_sh.x, _sh.y, _shc, _sha * 0.85);
    draw_vertex_colour(_sh.x + lengthdir_x(_shs, _sh.rot),
                       _sh.y + lengthdir_y(_shs, _sh.rot), _k_rack_col_body, _sha * 0.8);
    draw_vertex_colour(_sh.x + lengthdir_x(_shs * 0.7, _sh.rot + 122),
                       _sh.y + lengthdir_y(_shs * 0.7, _sh.rot + 122), _shc, _sha * 0.75);
    draw_vertex_colour(_sh.x + lengthdir_x(_shs * 0.92, _sh.rot + 241),
                       _sh.y + lengthdir_y(_shs * 0.92, _sh.rot + 241), _k_rack_col_rail, _sha * 0.75);
    draw_vertex_colour(_sh.x + lengthdir_x(_shs, _sh.rot),
                       _sh.y + lengthdir_y(_shs, _sh.rot), _k_rack_col_body, _sha * 0.8);
    draw_primitive_end();
  }

  gpu_set_blendmode(bm_add);

  for (var _sci = 0; _sci < array_length(rack_scars); _sci++) {
    var _sc = rack_scars[_sci];
    var _sca = clamp(_sc.life / _sc.life_max, 0, 1);
    var _scw = 6 + _sca * 12;
    var _scx = _sc.x + _sc.side * _scw * 0.5;

    draw_set_color(merge_color(_sc.color, global.avoid_col_blood, 1 - _sca));
    draw_set_alpha(_sca * _sca * 0.35);
    draw_line_width(_scx, _sc.y - _sc.h * 0.5, _scx, _sc.y + _sc.h * 0.5, _scw);

    draw_set_color(merge_color(_sc.color, c_white, _sca * 0.5));
    draw_set_alpha(_sca * _sca * 0.5);
    draw_line_width(_scx, _sc.y - _sc.h * 0.32, _scx, _sc.y + _sc.h * 0.32, 2);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}
