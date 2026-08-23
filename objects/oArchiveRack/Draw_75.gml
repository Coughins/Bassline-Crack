if (rack_rail > 0.004 || array_length(rack_vents) > 0 || array_length(rack_arcs) > 0) {
  gpu_set_blendmode(bm_add);

  var _rk75_a = clamp(rack_rail, 0, 1);
  var _rk75_dead = rack_dead ? clamp(rack_blowout, 0, 1) : 1;

  for (var _ri = -1; _ri <= 1; _ri += 2) {
    var _rh75 = clamp(rack_rail_heat[(_ri < 0) ? 0 : 1], 0, 1.6);
    var _rseam = rack_coil * rack_coil;
    var _rstr = max(max(_rh75, rack_slam_flash * 0.8), _rseam * rack_amb)
                * _rk75_a * _rk75_dead * (0.85 + rack_hb * 0.3);
    if (_rstr <= 0.015) continue;

    var _rfx = (_ri < 0) ? _k_rack_wall_l + _k_rack_rail_w * _rk75_a
                         : _k_rack_wall_r - _k_rack_rail_w * _rk75_a;
    var _rcol = merge_color(global.avoid_col_warning, c_white, clamp(_rstr, 0, 1) * 0.55);

    draw_set_color(_rcol);
    draw_set_alpha(clamp(_rstr, 0, 1) * 0.2);
    draw_line_width(_rfx, _k_rack_top_y, _rfx, _k_rack_floor_y, 7 + _rstr * 9);

    draw_set_color(c_white);
    draw_set_alpha(clamp(_rstr, 0, 1) * 0.45);
    draw_line_width(_rfx, _k_rack_top_y, _rfx, _k_rack_floor_y, 1.5);

    lightning_bloom_boost += clamp(_rstr, 0, 1) * 0.05;
  }

  for (var _ai75 = 0; _ai75 < array_length(rack_arcs); _ai75++) {
    var _ar = rack_arcs[_ai75];
    var _ara = clamp(_ar.life / _ar.life_max, 0, 1) * _rk75_dead;
    scr_draw_energy_bolt(_ar.x1, _ar.y1, _ar.x2, _ar.y2,
                         _ara * 0.85, merge_color(_ar.color, c_white, _ar.hot * 0.5),
                         _ar.off, 1 + _ar.hot * 1.6);
  }

  for (var _hi = 0; _hi < _k_rack_lanes; _hi++) {
    var _hn = rack_lanes[_hi];
    if (_hn.ext <= 0.02) continue;

    var _hh = clamp(max(_hn.heat * 0.6, _hn.flash), 0, 1) * _rk75_dead;
    if (_hh <= 0.02) continue;

    var _hcy = rack_lane_cy(_hi);
    var _hcol = merge_color(global.avoid_col_ember, c_white, _hn.flash * 0.6);

    for (var _hsd = -1; _hsd <= 1; _hsd += 2) {
      var _hroot = (_hsd < 0) ? _k_rack_wall_l : _k_rack_wall_r;
      var _htip = rack_tine_tip(_hsd, _hn.ext);

      draw_set_color(_hcol);
      draw_set_alpha(_hh * 0.22);
      draw_line_width(_hroot, _hcy, _htip, _hcy, 3 + _hn.flash * 5);

      draw_set_color(c_white);
      draw_set_alpha(_hh * 0.4);
      draw_line_width(_hroot, _hcy, _htip, _hcy, 1);
    }

    lightning_bloom_boost += _hh * 0.02;
  }

  for (var _wi = 0; _wi < _k_rack_lanes; _wi++) {
    var _wn = rack_lanes[_wi];
    if (_wn.arm <= 0.04) continue;

    var _wa = clamp(_wn.arm, 0, 1);
    var _wy0 = rack_band_y0(_wi);
    var _wy1 = rack_band_y1(_wi);
    var _wcol = merge_color(global.avoid_col_warning, c_white, _wa * 0.4);

    draw_set_color(_wcol);
    draw_set_alpha(_wa * _wa * 0.3);
    draw_line_width(_k_rack_wall_l, _wy0, _k_rack_wall_r, _wy0, 2);
    draw_line_width(_k_rack_wall_l, _wy1, _k_rack_wall_r, _wy1, 2);

    lightning_bloom_boost += _wa * 0.03;
  }

  for (var _lb = 0; _lb < array_length(rack_lock_frames); _lb++) {
    var _lbf = rack_lock_frames[_lb];
    var _lba = clamp(_lbf.life / _lbf.life_max, 0, 1);
    var _lbp = 0.65 + 0.35 * sin(_lbf.seed + t * 0.7);

    scr_draw_lock_bracket_glow(_k_rack_wall_l + 3, rack_band_y0(_lbf.lane),
                               _k_rack_wall_r - 3, rack_band_y1(_lbf.lane),
                               global.avoid_col_cyan, _lbf.hot, _lba * _rk75_dead, 0, _lbp);
  }

  scr_draw_vent_streams(rack_vents);

  if (rack_chroma > 0.02 && (rack_armed || rack_dead)) {
    var _ch = clamp(rack_chroma, 0, 1);
    var _choff = (1.5 + _ch * 5) * fx_get_mult_for("eruption", "aberration");
    var _chtop = rack_win_top(rack_win_hi);
    var _chbot = rack_win_bot(rack_win_lo);
    var _chl = _k_rack_mid_x - rack_half;
    var _chr = _k_rack_mid_x + rack_half;

    draw_set_color(global.avoid_col_warning);
    draw_set_alpha(_ch * 0.4);
    draw_line_width(_chl, _chtop - _choff, _chr, _chtop - _choff, 1.5);
    draw_line_width(_chl, _chbot - _choff, _chr, _chbot - _choff, 1.5);
    draw_line_width(_chl - _choff, _chtop, _chl - _choff, _chbot, 1.5);
    draw_line_width(_chr - _choff, _chtop, _chr - _choff, _chbot, 1.5);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_ch * 0.4);
    draw_line_width(_chl, _chtop + _choff, _chr, _chtop + _choff, 1.5);
    draw_line_width(_chl, _chbot + _choff, _chr, _chbot + _choff, 1.5);
    draw_line_width(_chl + _choff, _chtop, _chl + _choff, _chbot, 1.5);
    draw_line_width(_chr + _choff, _chtop, _chr + _choff, _chbot, 1.5);
  }

  if (rack_blowout > 0.01) {
    var _bo = clamp(rack_blowout, 0, 1);
    var _bocol = merge_color(global.avoid_col_warning, c_white, _bo * 0.6);

    for (var _bi = -1; _bi <= 1; _bi += 2) {
      var _bx = (_bi < 0) ? _k_rack_wall_l : _k_rack_wall_r;
      draw_set_color(_bocol);
      draw_set_alpha(_bo * _bo * 0.28);
      draw_line_width(_bx, _k_rack_top_y, _bx, _k_rack_floor_y, 20 + _bo * 46);
      draw_set_color(c_white);
      draw_set_alpha(_bo * _bo * 0.5);
      draw_line_width(_bx, _k_rack_top_y, _bx, _k_rack_floor_y, 3 + _bo * 6);
    }

    lightning_bloom_boost += _bo * 0.2;
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (rack_rail > 0.02) {
    var _rk_g_a = clamp(rack_rail, 0, 1);

    var _rk_wy = (rack_win_top(rack_win_hi) + rack_win_bot(rack_win_lo)) * 0.5;
    var _rk_wh = (rack_win_bot(rack_win_lo) - rack_win_top(rack_win_hi));
    var _rk_win_a = _rk_g_a * (0.34 + rack_amb * 0.22) * (rack_dead ? clamp(rack_blowout, 0, 1) : 1);

    if (_rk_win_a > 0.01) {
      shader_set_uniform_f(global.u_glow_color, 0.28, 0.84, 1);
      shader_set_uniform_f(global.u_glow_intensity, _rk_win_a * 1.15);
      shader_set_uniform_f(global.u_glow_falloff, 2.2);

      var _rk_wsc = (_rk_wh * 0.55) * _fx_gx / _fx_half;
      var _rk_wn = 9;
      var _rk_wl = _k_rack_mid_x - rack_half;
      var _rk_wspan = rack_half * 2;
      for (var _rw = 0; _rw <= _rk_wn; _rw++) {
        var _rwx = _rk_wl + (_rw / _rk_wn) * _rk_wspan;
        draw_sprite_ext(spr_glow_blob, 0, (_rwx - _fx_cx) * _fx_gx, (_rk_wy - _fx_cy) * _fx_gy,
                        _rk_wsc, _rk_wsc, 0, c_white, 1);
      }
    }

    for (var _rg = -1; _rg <= 1; _rg += 2) {
      var _rgh = clamp(rack_rail_heat[(_rg < 0) ? 0 : 1], 0, 1.6);
      if (_rgh <= 0.02) continue;

      var _rgx = ((_rg < 0) ? _k_rack_wall_l + 8 : _k_rack_wall_r - 8);
      var _rggx = (_rgx - _fx_cx) * _fx_gx;

      shader_set_uniform_f(global.u_glow_color, 1, 0.32, 0.36);
      shader_set_uniform_f(global.u_glow_intensity, _rgh * 1.5 * _rk_g_a);
      shader_set_uniform_f(global.u_glow_falloff, 1.9);

      var _rgsc = (16 + _rgh * 20) * _fx_gx / _fx_half;
      for (var _rn = 0; _rn <= _k_rack_lanes; _rn++) {
        var _rny = _k_rack_floor_y - _rn * _k_rack_pitch;
        draw_sprite_ext(spr_glow_blob, 0, _rggx, (_rny - _fx_cy) * _fx_gy,
                        _rgsc, _rgsc, 0, c_white, 1);
      }
    }

    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    for (var _gi = 0; _gi < _k_rack_lanes; _gi++) {
      var _gn = rack_lanes[_gi];
      if (_gn.ext <= 0.02) continue;

      var _gh = clamp(max(_gn.heat, _gn.flash), 0, 1);
      if (_gh <= 0.03) continue;

      var _ggy = (rack_lane_cy(_gi) - _fx_cy) * _fx_gy;
      var _gsc = (14 + _gn.flash * 26) * _fx_gx / _fx_half;

      shader_set_uniform_f(global.u_glow_color, 1, 0.46 + _gn.flash * 0.4, 0.24 + _gn.flash * 0.5);
      shader_set_uniform_f(global.u_glow_intensity, (0.5 + _gh * 1.5) * _rk_g_a);

      for (var _gsd = -1; _gsd <= 1; _gsd += 2) {
        var _gtx = rack_tine_tip(_gsd, _gn.ext);
        draw_sprite_ext(spr_glow_blob, 0, (_gtx - _fx_cx) * _fx_gx, _ggy,
                        _gsc, _gsc, 0, c_white, 1);
      }
    }
  }
