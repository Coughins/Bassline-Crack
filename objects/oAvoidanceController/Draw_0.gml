if (ring_telegraph_alpha > 0) {
  var _ta = ring_telegraph_alpha;
  var _tcx = _k_ring_home_x;
  var _tcy = _k_ring_home_y;
  var _tvs = arrow_ring_vertical_scale;
  var _lead = 1 - _ta;

  gpu_set_blendmode(bm_add);

  for (var _ti = 0; _ti < 3; _ti++) {
    var _tr = arrow_ring_radius * (1 + _lead * (0.5 + _ti * 0.55));
    var _tw = _ta * (0.4 - _ti * 0.1);
    if (_tw <= 0) continue;

    var _tcol = merge_color(ring_color, c_white, 0.35);
    draw_set_alpha(_tw);
    draw_set_color(_tcol);
    draw_ellipse_color(_tcx - _tr, _tcy - _tr * _tvs, _tcx + _tr, _tcy + _tr * _tvs, _tcol, _tcol, true);
  }

  var _breach_alpha = clamp(_ta * 0.85 + intro_heartbeat_pulse * 0.65, 0, 1);
  if (_breach_alpha > 0.02) {
    var _scar_ang = -18 + sin(t * 0.17) * 2.5;
    var _scar_len = lerp(26, arrow_ring_radius * 0.7, _ta);
    var _scar_gap = 3 + intro_heartbeat_pulse * 5;
    var _scar_px = _scar_ang + 90;
    var _sx1 = _tcx - lengthdir_x(_scar_len, _scar_ang);
    var _sy1 = _tcy - lengthdir_y(_scar_len * _tvs, _scar_ang);
    var _sx2 = _tcx + lengthdir_x(_scar_len, _scar_ang);
    var _sy2 = _tcy + lengthdir_y(_scar_len * _tvs, _scar_ang);

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_breach_alpha * 0.22);
    draw_line_width(_sx1, _sy1, _sx2, _sy2, 14);

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_breach_alpha * 0.5);
    draw_line_width(_sx1 + lengthdir_x(_scar_gap, _scar_px), _sy1 + lengthdir_y(_scar_gap, _scar_px),
                    _sx2 + lengthdir_x(_scar_gap, _scar_px), _sy2 + lengthdir_y(_scar_gap, _scar_px), 4);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_breach_alpha * 0.36);
    draw_line_width(_sx1 - lengthdir_x(_scar_gap, _scar_px), _sy1 - lengthdir_y(_scar_gap, _scar_px),
                    _sx2 - lengthdir_x(_scar_gap, _scar_px), _sy2 - lengthdir_y(_scar_gap, _scar_px), 3);

    draw_set_color(c_white);
    draw_set_alpha(_breach_alpha * 0.65);
    draw_line_width(_sx1, _sy1, _sx2, _sy2, 1.4);
  }

  for (var _ti = 0; _ti < arrow_ring_count; _ti++) {
    var _reveal = clamp(_ta * arrow_ring_count - _ti, 0, 1);
    if (_reveal <= 0) continue;

    var _tang = _ti * (360 / arrow_ring_count);
    var _tx = _tcx + lengthdir_x(arrow_ring_radius, _tang);
    var _ty = _tcy + lengthdir_y(arrow_ring_radius * _tvs, _tang);
    var _perp = _tang + 90;

    draw_set_color(c_white);
    draw_set_alpha(_reveal * 0.85);
    draw_line_width(_tx + lengthdir_x(8, _perp), _ty + lengthdir_y(8 * _tvs, _perp),
                    _tx - lengthdir_x(8, _perp), _ty - lengthdir_y(8 * _tvs, _perp), 1.5);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (crosshair_release_flash_timer > 0) {
  var _k_release_flare_duration = 20 * crosshair_release_flash_scale;
  var _k_release_flare_max_radius = 60 * crosshair_release_flash_scale;
  var _k_release_core_max_radius = 22 * crosshair_release_flash_scale;

  var _prog = crosshair_release_flash_timer / _k_release_flare_duration;
  var _alpha = (1 - _prog) * fx_get_mult_for("introshapes", "flash");

  gpu_set_blendmode(bm_add);

  var _outer_scale = lerp(4, _k_release_flare_max_radius, _prog) /
                     (sprite_get_width(spr_glow_blob) * 0.5);
  draw_set_alpha(_alpha * 0.5);
  draw_sprite_ext(spr_glow_blob, 0, crosshair_release_x, crosshair_release_y,
                  _outer_scale, _outer_scale, 0, global.lightning_color, 1);

  var _core_scale = lerp(4, _k_release_core_max_radius, min(1, _prog * 1.8)) /
                    (sprite_get_width(spr_glow_blob) * 0.5);
  draw_set_alpha(_alpha);
  draw_sprite_ext(spr_glow_blob, 0, crosshair_release_x, crosshair_release_y,
                  _core_scale, _core_scale, 0, c_white, 1);

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(shapes_telegraphs) > 0) {
  gpu_set_blendmode(bm_add);

  var _tel_col = merge_color(global.lightning_color, c_white, 0.35);
  var _tel_arms = [ 0, 90, 180, 270 ];

  for (var _ti = 0; _ti < array_length(shapes_telegraphs); _ti++) {
    var _tg = shapes_telegraphs[_ti];
    var _tp = clamp(_tg.timer / _tg.duration, 0, 1);
    var _ta = power(_tp, 0.7);
    var _tlead = 1 - _tp;

    draw_set_color(_tel_col);

    if (_tg.shape == 0) {
      for (var _tr = 0; _tr < 3; _tr++) {
        draw_set_alpha(_ta * (0.45 - _tr * 0.12));
        draw_circle(intro_cx, intro_cy, 180 * (1 + _tlead * (0.35 + _tr * 0.45)), true);
      }
    } else if (_tg.shape == 1) {
      for (var _tr = 0; _tr < 3; _tr++) {
        var _th = 220 * (1 + _tlead * (0.35 + _tr * 0.45));
        draw_set_alpha(_ta * (0.45 - _tr * 0.12));
        draw_rectangle(intro_cx - _th, intro_cy - _th, intro_cx + _th, intro_cy + _th, true);
      }
    } else {
      for (var _td = 0; _td < 4; _td++) {
        var _tl = 200 * _ta;
        var _tex = intro_cx + lengthdir_x(_tl, _tel_arms[_td]);
        var _tey = intro_cy + lengthdir_y(_tl, _tel_arms[_td]);
        draw_set_alpha(_ta * 0.45);
        draw_line_width(intro_cx, intro_cy, _tex, _tey, 7);
        draw_set_alpha(_ta * 0.9);
        draw_line_width(intro_cx, intro_cy, _tex, _tey, 1.5);
      }
    }

    var _tick_n = (_tg.shape == 1) ? 24 : ((_tg.shape == 2) ? 4 : 20);

    for (var _tk = 0; _tk < _tick_n; _tk++) {
      var _reveal = clamp(_ta * _tick_n - _tk, 0, 1);
      if (_reveal <= 0) continue;

      var _pang, _prad;
      if (_tg.shape == 1) {
        _pang = (360 / 24) * _tk + 7.5;
        _prad = 220 / max(abs(dcos(_pang)), abs(dsin(_pang)));
      } else if (_tg.shape == 2) {
        _pang = _tk * 90;
        _prad = 200;
      } else {
        _pang = (360 / 20) * _tk;
        _prad = 180;
      }

      var _px = intro_cx + lengthdir_x(_prad, _pang);
      var _py = intro_cy + lengthdir_y(_prad, _pang);
      var _perp = _pang + 90;

      draw_set_color(c_white);
      draw_set_alpha(_reveal * 0.85);
      draw_line_width(_px + lengthdir_x(8, _perp), _py + lengthdir_y(8, _perp), _px - lengthdir_x(8, _perp),
                      _py - lengthdir_y(8, _perp), 1.5);
      draw_set_color(_tel_col);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

var _shape_glyph_live = array_length(shapes_telegraphs) + array_length(intro_ring_bullets) + array_length(intro_x_bullets);
var _shape_glyph = clamp((_shape_glyph_live > 0 ? 0.18 : 0) + shapes_core_charge * 0.75 + shapes_coil * 0.85 +
                         shapes_heartbeat * 0.55 + shapes_launch_flash * 0.9, 0, 1);
if (_shape_glyph > 0.02) {
  var _glyph_hot = clamp(shapes_coil + shapes_launch_flash + shapes_core_flash / 18, 0, 1);
  var _glyph_r = 16 + _shape_glyph * 28 + shapes_coil * 22;
  var _glyph_phase = shapes_heartbeat_phase * 36 + t * (0.35 + shapes_coil * 1.4);
  var _glyph_red = merge_color(global.avoid_col_blood, global.avoid_col_danger, 0.45 + _glyph_hot * 0.35);
  var _glyph_core = merge_color(global.avoid_col_hot, c_white, 0.25 + _glyph_hot * 0.55);

  gpu_set_blendmode(bm_add);

  draw_set_color(global.avoid_col_blood);
  draw_set_alpha(_shape_glyph * 0.16);
  draw_circle(intro_cx, intro_cy, _glyph_r * 0.72, false);

  draw_set_color(_glyph_red);
  draw_set_alpha(_shape_glyph * 0.55);
  draw_circle(intro_cx, intro_cy, _glyph_r, true);
  draw_set_color(global.avoid_col_cyan);
  draw_set_alpha(_shape_glyph * 0.28);
  draw_circle(intro_cx, intro_cy, _glyph_r * 1.18, true);

  for (var _ga = 0; _ga < 8; _ga++) {
    var _gang = _glyph_phase + _ga * 45;
    var _spoke_a = _shape_glyph * (0.24 + ((_ga mod 2) * 0.2)) * (0.7 + _glyph_hot * 0.5);
    var _inner = _glyph_r * lerp(0.34, 0.16, _glyph_hot);
    var _outer = _glyph_r * lerp(1.1, 1.45, shapes_coil);
    var _ix = intro_cx + lengthdir_x(_inner, _gang);
    var _iy = intro_cy + lengthdir_y(_inner, _gang);
    var _ox = intro_cx + lengthdir_x(_outer, _gang);
    var _oy = intro_cy + lengthdir_y(_outer, _gang);

    draw_set_color((_ga mod 2 == 0) ? _glyph_red : global.avoid_col_cyan);
    draw_set_alpha(_spoke_a);
    draw_line_width(_ix, _iy, _ox, _oy, 5);
    draw_set_color(c_white);
    draw_set_alpha(_spoke_a * 0.6);
    draw_line_width(_ix, _iy, _ox, _oy, 1.2);
  }

  draw_set_color(_glyph_core);
  draw_set_alpha(_shape_glyph * (0.42 + _glyph_hot * 0.35));
  draw_circle(intro_cx, intro_cy, 7 + _glyph_hot * 10, false);

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

scr_draw_intro_traces();

if (array_length(shapes_ghosts) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _gi = 0; _gi < array_length(shapes_ghosts); _gi++) {
    var _gh = shapes_ghosts[_gi];
    var _gp = _gh.pts;
    var _gn = array_length(_gp);
    if (_gn < 2) continue;

    var _gcol = merge_color(global.lightning_color, c_white, _gh.hot);
    var _gsegs = _gh.closed ? _gn : (_gn - 1);

    draw_set_color(_gcol);
    draw_set_alpha(_gh.alpha * 0.18);
    for (var _gs = 0; _gs < _gsegs; _gs++) {
      var _g1 = _gp[_gs];
      var _g2 = _gp[(_gs + 1) mod _gn];
      draw_line_width(_g1.x, _g1.y, _g2.x, _g2.y, _gh.width * 3);
    }

    draw_set_color(merge_color(_gcol, c_white, 0.4));
    draw_set_alpha(_gh.alpha * 0.7);
    for (var _gs = 0; _gs < _gsegs; _gs++) {
      var _g1 = _gp[_gs];
      var _g2 = _gp[(_gs + 1) mod _gn];
      draw_line_width(_g1.x, _g1.y, _g2.x, _g2.y, _gh.width);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

scr_riser_draw_world();

scr_vault_draw_world();

if (array_length(converge_motes) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _mi = 0; _mi < array_length(converge_motes); _mi++) {
    var _mo = converge_motes[_mi];

    var _mx = _mo.cx + lengthdir_x(_mo.dist, _mo.ang);
    var _my = _mo.cy + lengthdir_y(_mo.dist, _mo.ang);
    var _mtail = _mo.speed * 2.2;
    var _mtx = _mo.cx + lengthdir_x(_mo.dist + _mtail, _mo.ang);
    var _mty = _mo.cy + lengthdir_y(_mo.dist + _mtail, _mo.ang);

    var _ma = clamp(1 - (_mo.dist - _mo.dest) / 260, 0, 1);

    draw_set_color(merge_color(global.lightning_color, c_white, _mo.hot));
    draw_set_alpha(_ma * 0.8);
    draw_line_width(_mtx, _mty, _mx, _my, 1 + _mo.size * 4);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (quarter_telegraph_active || quarter_core_charge > 0.01 || array_length(quarter_circles) > 0 ||
    array_length(quarter_ghosts) > 0 || array_length(quarter_scars) > 0 ||
    array_length(quarter_lock_frames) > 0) {
  gpu_set_blendmode(bm_add);

  var _q_spans = [ 0, 180 ];
  var _q_segs = 12;

  if (quarter_telegraph_active) {
    var _qt = clamp(quarter_telegraph_timer / _k_quarter_telegraph_duration, 0, 1);
    var _qt_lead = 1 - _qt;
    var _qt_radii = [ 140, 70 ];

    for (var _qr = 0; _qr < 2; _qr++) {
      var _qtc = (_qr == 0) ? global.avoid_col_danger : global.avoid_col_cyan_soft;
      draw_set_color(_qtc);

      for (var _qc2 = 0; _qc2 < 3; _qc2++) {
        var _qrr = _qt_radii[_qr] * (1 + _qt_lead * (0.45 + _qc2 * 0.55));
        draw_set_alpha(_qt * (0.55 - _qc2 * 0.15));

        for (var _qs = 0; _qs < 2; _qs++) {
          var _qa0 = _q_spans[_qs];
          var _qpx = 400 + lengthdir_x(_qrr, _qa0);
          var _qpy = 304 + lengthdir_y(_qrr, _qa0);

          for (var _qk = 1; _qk <= _q_segs; _qk++) {
            var _qaa = _qa0 + (_qk / _q_segs) * 90;
            var _qnx = 400 + lengthdir_x(_qrr, _qaa);
            var _qny = 304 + lengthdir_y(_qrr, _qaa);
            draw_line_width(_qpx, _qpy, _qnx, _qny, 2);
            _qpx = _qnx;
            _qpy = _qny;
          }
        }
      }

      var _qn = 6;
      for (var _qs = 0; _qs < 2; _qs++) {
        for (var _qk = 0; _qk < _qn; _qk++) {
          var _reveal = clamp(_qt * _qn - _qk, 0, 1);
          if (_reveal <= 0) continue;

          var _qaa = _q_spans[_qs] + (_qk / (_qn - 1)) * 90;
          var _qtx = 400 + lengthdir_x(_qt_radii[_qr], _qaa);
          var _qty = 304 + lengthdir_y(_qt_radii[_qr], _qaa);
          var _qperp = _qaa + 90;

          draw_set_color(c_white);
          draw_set_alpha(_reveal * 0.85);
          draw_line_width(_qtx + lengthdir_x(7, _qperp), _qty + lengthdir_y(7, _qperp),
                          _qtx - lengthdir_x(7, _qperp), _qty - lengthdir_y(7, _qperp), 1.5);
          draw_set_color(_qtc);
        }
      }
    }
  }

  var _qreactor = max(quarter_core_charge, quarter_coil * 0.95);
  _qreactor = max(_qreactor, quarter_lock_flash * 0.9);
  _qreactor = max(_qreactor, quarter_beat_flash * 0.55);
  if (quarter_telegraph_active) {
    _qreactor = max(_qreactor, clamp(quarter_telegraph_timer / _k_quarter_telegraph_duration, 0, 1) * 0.45);
  }

  if (_qreactor > 0.01) {
    var _qhot = clamp(_qreactor, 0, 2.4);
    var _qcore_r = 8 + _qhot * 7 + qamb_hb * 4;
    var _qring_r = 22 + _qhot * 11 + quarter_coil * 12;
    var _qspin = t * (1.4 + quarter_coil * 3.6);
    var _qwound_col = merge_color(global.avoid_col_blood, global.avoid_col_danger, 0.58);
    var _qwhite = merge_color(global.avoid_col_hot, c_white, clamp(_qhot * 0.35, 0, 1));

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(0.12 + clamp(_qhot, 0, 1) * 0.08);
    draw_circle(400, 304, _qring_r * 0.55, false);
    gpu_set_blendmode(bm_add);

    draw_set_color(_qwound_col);
    draw_set_alpha(0.32 + clamp(_qhot, 0, 1) * 0.34);
    draw_circle(400, 304, _qring_r, true);
    draw_set_alpha(0.14 + clamp(_qhot, 0, 1) * 0.20);
    draw_circle(400, 304, _qring_r * 1.55, true);

    for (var _qc = 0; _qc < 8; _qc++) {
      var _qa = _qspin + _qc * 45;
      var _inner = _qcore_r * 0.75;
      var _outer = _qring_r * (0.86 + ((_qc mod 2) * 0.14));
      draw_set_color((_qc mod 2 == 0) ? _qwound_col : global.avoid_col_cyan);
      draw_set_alpha((0.22 + _qhot * 0.10) * (1 - (_qc mod 2) * 0.28));
      draw_line_width(400 + lengthdir_x(_inner, _qa), 304 + lengthdir_y(_inner, _qa),
                      400 + lengthdir_x(_outer, _qa), 304 + lengthdir_y(_outer, _qa),
                      1.4 + _qhot * 0.8);
    }

    draw_set_color(_qwhite);
    draw_set_alpha(0.58 + clamp(_qhot, 0, 1) * 0.30);
    draw_circle(400, 304, _qcore_r, false);
    draw_set_color(c_white);
    draw_set_alpha(0.42 + clamp(_qhot, 0, 1) * 0.32);
    draw_circle(400, 304, max(3, _qcore_r * 0.38), false);
  }

  for (var _pass = 0; _pass < 2; _pass++) {
    var _list = (_pass == 0) ? quarter_ghosts : quarter_scars;
    var _gsegs = (_pass == 0) ? 8 : _q_segs;

    for (var _gi = 0; _gi < array_length(_list); _gi++) {
      var _g = _list[_gi];
      var _gcol = merge_color(global.avoid_col_danger, c_white, _g.hot);
      var _gw = (_pass == 0) ? (1 + _g.alpha * 2) : (1.5 + _g.alpha * 4);

      for (var _qs = 0; _qs < 2; _qs++) {
        var _ga0 = _g.ang + _q_spans[_qs];
        var _gpx = _g.cx + lengthdir_x(_g.radius, _ga0);
        var _gpy = _g.cy + lengthdir_y(_g.radius, _ga0);

        for (var _lay = 0; _lay < 2; _lay++) {
          draw_set_color((_lay == 0) ? _gcol : merge_color(_gcol, c_white, 0.5));
          draw_set_alpha(_g.alpha * ((_lay == 0) ? 0.25 : 0.75));

          var _lx = _gpx;
          var _ly = _gpy;
          for (var _qk = 1; _qk <= _gsegs; _qk++) {
            var _gaa = _ga0 + (_qk / _gsegs) * 90;
            var _gnx = _g.cx + lengthdir_x(_g.radius, _gaa);
            var _gny = _g.cy + lengthdir_y(_g.radius, _gaa);
            draw_line_width(_lx, _ly, _gnx, _gny, _gw * ((_lay == 0) ? 3 : 1));
            _lx = _gnx;
            _ly = _gny;
          }
        }
      }
    }
  }

  for (var _qi = 0; _qi < array_length(quarter_circles); _qi++) {
    var _qc3 = quarter_circles[_qi];
    var _qheat = 0.25 + quarter_beat_flash * 0.5 + quarter_coil * 0.6 + quarter_lock_flash * 0.5;
    var _qbase = (_qc3.radius > 100) ? global.avoid_col_danger : global.avoid_col_cyan_soft;
    var _qcol2 = merge_color(_qbase, c_white, clamp(_qheat, 0, 1) * 0.7);
    var _qrad = _qc3.radius_current;

    var _qspawn = _qc3.spawned ? 1 : clamp(_qc3.spawn_timer / _qc3.spawn_duration, 0, 1);

    for (var _qs = 0; _qs < 2; _qs++) {
      var _qa0 = _qc3.base_angle + _qc3.despawn_wobble + _q_spans[_qs];
      var _qex = _qc3.cx + lengthdir_x(_qrad, _qa0);
      var _qey = _qc3.cy + lengthdir_y(_qrad, _qa0);
      var _qpx = _qex;
      var _qpy = _qey;

      draw_set_color(_qcol2);
      draw_set_alpha(clamp(0.2 + _qheat * 0.5, 0, 0.9) * _qspawn);

      for (var _qk = 1; _qk <= _q_segs; _qk++) {
        var _qaa = _qa0 + (_qk / _q_segs) * 90;
        var _qnx = _qc3.cx + lengthdir_x(_qrad, _qaa);
        var _qny = _qc3.cy + lengthdir_y(_qrad, _qaa);
        draw_line_width(_qpx, _qpy, _qnx, _qny, 1.5 + _qheat * 2.5);
        _qpx = _qnx;
        _qpy = _qny;
      }

      draw_set_alpha(clamp(0.08 + _qheat * 0.3, 0, 0.6));
      draw_line_width(_qex, _qey, _qpx, _qpy, 1);
    }
  }

  if (array_length(quarter_lock_frames) > 0) {
    for (var _qlf = 0; _qlf < array_length(quarter_lock_frames); _qlf++) {
      var _ql = quarter_lock_frames[_qlf];
      var _ql_a = clamp(_ql.life / _ql.life_max, 0, 1);
      var _ql_pulse = 0.55 + 0.45 * sin(_ql.seed + current_time * 0.018);
      var _ql_col = (_ql.cid == 0) ? global.avoid_col_warning : global.avoid_col_cyan;
      var _ql_r = _ql.r + ((_ql.cid == 0) ? 26 : 16);

      scr_draw_lock_bracket(_ql.cx - _ql_r, _ql.cy - _ql_r,
                            _ql.cx + _ql_r, _ql.cy + _ql_r,
                            _ql_col, _ql.hot, _ql_a * _ql_pulse,
                            (_ql.cid == 0) ? 14 : 9, false);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (quarter_readout > 0.01 || array_length(quarter_tracers) > 0 ||
    array_length(quarter_craters) > 0 || array_length(quarter_stuck) > 0) {
  gpu_set_blendmode(bm_add);

  var _qa_cx = 400;
  var _qa_cy = 304;

  var _qa_xmin = _k_qamb_pad;
  var _qa_xmax = room_width - _k_qamb_pad;
  var _qa_ymin = _k_qamb_pad;
  var _qa_ymax = _k_qamb_floor_y;

  var _q_red = make_color_rgb(255, 52, 44);
  var _q_cyan = global.avoid_col_cyan;

  if (quarter_readout > 0.02 && qamb > 0.02) {
    var _qr_mult = fx_get_mult_for("quartercircles", "readout");
    var _qs_e = quarter_safe_slide * quarter_safe_slide * (3 - 2 * quarter_safe_slide);
    var _qs_ang = quarter_safe_ang_prev +
                  angle_difference(quarter_safe_ang, quarter_safe_ang_prev) * _qs_e;
    var _qs_w = quarter_safe_w * 0.88;
    var _qs_open = clamp(quarter_safe_w / _k_q_pinch_w, 0, 1);

    var _qs_eta = clamp(1 - quarter_pinch_eta / 26, 0, 1);
    var _qs_flick = 1 + _qs_eta * 0.5 * (0.5 + 0.5 * sin(t * (0.45 + _qs_eta * 1.5)));

    var _qs_col = merge_color(make_color_rgb(225, 62, 40), make_color_rgb(155, 236, 255), _qs_open);
    var _qs_a = quarter_readout * qamb *
                (0.085 + quarter_safe_flash * 0.11 + qamb_hb * 0.06) * _qr_mult * _qs_flick;

    var _qs_r_in = max(46, qamb_rad[0] * 1.15 + 16);

    var _k_qs_steps = 8;
    var _k_qs_bands = 10;

    var _qs_corners = [
      point_direction(_qa_cx, _qa_cy, _qa_xmax, _qa_ymin),
      point_direction(_qa_cx, _qa_cy, _qa_xmin, _qa_ymin),
      point_direction(_qa_cx, _qa_cy, _qa_xmin, _qa_ymax),
      point_direction(_qa_cx, _qa_cy, _qa_xmax, _qa_ymax)
    ];

    for (var _qw = 0; _qw < 2; _qw++) {
      if (_qs_w <= 1.5) break;

      var _qs_c = _qs_ang + _qw * 180;
      var _qs_hw = _qs_w * 0.5;
      var _qs_wa = _qs_a * ((_qw == 0) ? 1 : 0.55);
      var _qs_a0 = _qs_c - _qs_hw;

      var _qs_offs = [];

      for (var _qi3 = 0; _qi3 <= _k_qs_steps; _qi3++) {
        array_push(_qs_offs, _qs_w * (_qi3 / _k_qs_steps));
      }

      for (var _qcn = 0; _qcn < 4; _qcn++) {
        var _qs_co = ((_qs_corners[_qcn] - _qs_a0) mod 360 + 360) mod 360;
        if (_qs_co > 0.5 && _qs_co < _qs_w - 0.5) array_push(_qs_offs, _qs_co);
      }

      array_sort(_qs_offs, true);

      var _qs_n = array_length(_qs_offs);
      var _qs_d = array_create(_qs_n, 0);
      var _qs_ax = array_create(_qs_n, 0);
      var _qs_ay = array_create(_qs_n, 0);

      for (var _qi3 = 0; _qi3 < _qs_n; _qi3++) {
        var _qsa2 = _qs_a0 + _qs_offs[_qi3];
        var _qsdx = dcos(_qsa2);
        var _qsdy = -dsin(_qsa2);
        var _qstx = 100000;
        var _qsty = 100000;

        if (_qsdx > 0.0001) _qstx = (_qa_xmax - _qa_cx) / _qsdx;
        else if (_qsdx < -0.0001) _qstx = (_qa_xmin - _qa_cx) / _qsdx;

        if (_qsdy > 0.0001) _qsty = (_qa_ymax - _qa_cy) / _qsdy;
        else if (_qsdy < -0.0001) _qsty = (_qa_ymin - _qa_cy) / _qsdy;

        _qs_d[_qi3] = max(_qs_r_in + 1, min(_qstx, _qsty));
        _qs_ax[_qi3] = _qsdx;
        _qs_ay[_qi3] = _qsdy;
      }

      for (var _qb = 0; _qb < _k_qs_bands; _qb++) {
        var _qbt0 = _qb / _k_qs_bands;
        var _qbt1 = (_qb + 1) / _k_qs_bands;
        var _qba0 = _qs_wa * clamp(_qbt0 * 11, 0, 1) * (0.06 + power(1 - _qbt0, 1.7) * 0.94);
        var _qba1 = _qs_wa * clamp(_qbt1 * 11, 0, 1) * (0.06 + power(1 - _qbt1, 1.7) * 0.94);

        draw_primitive_begin(pr_trianglestrip);

        for (var _qi3 = 0; _qi3 < _qs_n; _qi3++) {
          var _qr0 = _qs_r_in + (_qs_d[_qi3] - _qs_r_in) * _qbt0;
          var _qr1 = _qs_r_in + (_qs_d[_qi3] - _qs_r_in) * _qbt1;

          draw_vertex_colour(_qa_cx + _qs_ax[_qi3] * _qr0, _qa_cy + _qs_ay[_qi3] * _qr0, _qs_col, _qba0);
          draw_vertex_colour(_qa_cx + _qs_ax[_qi3] * _qr1, _qa_cy + _qs_ay[_qi3] * _qr1, _qs_col, _qba1);
        }

        draw_primitive_end();
      }

      var _qs_rail_col = merge_color(_qs_col, c_white, 0.5);
      var _k_qs_rsegs = 7;

      for (var _qe = 0; _qe < 2; _qe++) {
        var _qei = (_qe == 0) ? 0 : (_qs_n - 1);
        var _qedx = _qs_ax[_qei];
        var _qedy = _qs_ay[_qei];
        var _qenx = -_qedy;
        var _qeny = _qedx;

        for (var _qlay = 0; _qlay < 2; _qlay++) {
          var _qe_hw = (_qlay == 0) ? 3.2 : 1;
          var _qe_amp = _qs_wa * ((_qlay == 0) ? (0.8 + quarter_safe_flash * 1.6)
                                               : (2.1 + quarter_safe_flash * 3));

          draw_primitive_begin(pr_trianglestrip);

          for (var _qrs = 0; _qrs <= _k_qs_rsegs; _qrs++) {
            var _qru = _qrs / _k_qs_rsegs;
            var _qrr = _qs_r_in + (_qs_d[_qei] - _qs_r_in) * _qru;
            var _qra = min(1, _qe_amp * (0.08 + power(1 - _qru, 1.25) * 0.92));
            var _qrx = _qa_cx + _qedx * _qrr;
            var _qry = _qa_cy + _qedy * _qrr;

            draw_vertex_colour(_qrx - _qenx * _qe_hw, _qry - _qeny * _qe_hw, _qs_rail_col, _qra);
            draw_vertex_colour(_qrx + _qenx * _qe_hw, _qry + _qeny * _qe_hw, _qs_rail_col, _qra);
          }

          draw_primitive_end();
        }

        var _qs_lx = _qa_cx + _qedx * _qs_d[_qei];
        var _qs_ly = _qa_cy + _qedy * _qs_d[_qei];
        var _qs_tin = (_qe == 0) ? 1 : -1;
        var _qs_tx = _qs_lx + _qenx * 11 * _qs_tin;
        var _qs_ty = _qs_ly + _qeny * 11 * _qs_tin;

        draw_set_color(_qs_rail_col);
        draw_set_alpha(min(1, _qs_wa * (1.5 + quarter_safe_flash * 3)));
        draw_line_width(_qs_lx, _qs_ly, _qs_tx, _qs_ty, 2.5);
      }
    }

    if (quarter_pinch > 0.3 && quarter_alt_w > 0.5) {
      var _qp_a = quarter_readout * qamb * quarter_pinch * 0.5 * _qr_mult;
      var _qp_col = make_color_rgb(255, 168, 40);
      var _qp_hw = quarter_alt_w * 0.34;
      var _qp_r0 = _qs_r_in;

      draw_set_color(_qp_col);

      for (var _qp = 0; _qp < 2; _qp++) {
        var _qpa2 = quarter_alt_ang_draw + ((_qp == 0) ? -_qp_hw : _qp_hw);
        var _qpdx = dcos(_qpa2);
        var _qpdy = -dsin(_qpa2);
        var _qptx = 100000;
        var _qpty = 100000;

        if (_qpdx > 0.0001) _qptx = (_qa_xmax - _qa_cx) / _qpdx;
        else if (_qpdx < -0.0001) _qptx = (_qa_xmin - _qa_cx) / _qpdx;

        if (_qpdy > 0.0001) _qpty = (_qa_ymax - _qa_cy) / _qpdy;
        else if (_qpdy < -0.0001) _qpty = (_qa_ymin - _qa_cy) / _qpdy;

        var _qp_d = max(1, min(_qptx, _qpty));

        var _qp_ticks = 9;

        for (var _qk2 = 0; _qk2 < _qp_ticks; _qk2++) {
          var _qkt0 = _qp_r0 + (_qp_d - _qp_r0) * (_qk2 / _qp_ticks);
          var _qkt1 = _qp_r0 + (_qp_d - _qp_r0) * ((_qk2 + 0.45) / _qp_ticks);

          draw_set_alpha(min(1, _qp_a * 2.4));
          draw_line_width(_qa_cx + _qpdx * _qkt0, _qa_cy + _qpdy * _qkt0,
                          _qa_cx + _qpdx * _qkt1, _qa_cy + _qpdy * _qkt1, 2);
        }

        var _qp_lx = _qa_cx + _qpdx * _qp_d;
        var _qp_ly = _qa_cy + _qpdy * _qp_d;
        var _qp_in = (_qp == 0) ? 1 : -1;
        var _qp_ux = dcos(quarter_alt_ang_draw + 90) * 9 * _qp_in;
        var _qp_uy = -dsin(quarter_alt_ang_draw + 90) * 9 * _qp_in;

        draw_set_alpha(min(1, _qp_a * 3.2));
        draw_line_width(_qp_lx, _qp_ly, _qp_lx + _qp_ux, _qp_ly + _qp_uy, 3);
      }
    }
  }

  if (array_length(quarter_tracers) > 0) {
    for (var _qti = 0; _qti < array_length(quarter_tracers); _qti++) {
      var _qtr2 = quarter_tracers[_qti];
      if (_qtr2.fired) continue;

      var _qtp = clamp(1 - (_qtr2.life / max(_qtr2.max_life, 1)), 0, 1);
      var _qta = (0.26 + _qtp * 0.6) * (0.45 + qamb * 0.7);
      var _qtcol = merge_color((_qtr2.cid == 0) ? _q_red : _q_cyan, c_white, _qtp * 0.75);

      draw_set_color(_qtcol);

      var _qt_reach = lerp(0.3, 1, _qtp);
      var _qt_ex = _qtr2.ox + (_qtr2.lx - _qtr2.ox) * _qt_reach;
      var _qt_ey = _qtr2.oy + (_qtr2.ly - _qtr2.oy) * _qt_reach;

      var _qt_j = sin(_qtr2.seed + _qtr2.life * 0.8) * 1.5 * (1 - _qtp);
      var _qt_jx = lengthdir_x(_qt_j, _qtr2.ang + 90);
      var _qt_jy = lengthdir_y(_qt_j, _qtr2.ang + 90);

      draw_set_alpha(_qta * 0.2);
      draw_line_width(_qtr2.ox + _qt_jx, _qtr2.oy + _qt_jy, _qt_ex, _qt_ey, 8);
      draw_set_alpha(_qta * 0.75);
      draw_line_width(_qtr2.ox + _qt_jx, _qtr2.oy + _qt_jy, _qt_ex, _qt_ey, 1.5);

      var _qt_fr = 1.2 + _qtp * 2.6;
      var _qt_fx = lengthdir_x(_qt_fr, _qtr2.ang + 90);
      var _qt_fy = lengthdir_y(_qt_fr, _qtr2.ang + 90);

      draw_set_alpha(_qta * (0.10 + _qtp * 0.24));
      draw_set_color(c_red);
      draw_line_width(_qtr2.ox + _qt_jx - _qt_fx, _qtr2.oy + _qt_jy - _qt_fy,
                      _qt_ex - _qt_fx, _qt_ey - _qt_fy, 1);
      draw_set_color(global.avoid_col_cyan);
      draw_line_width(_qtr2.ox + _qt_jx + _qt_fx, _qtr2.oy + _qt_jy + _qt_fy,
                      _qt_ex + _qt_fx, _qt_ey + _qt_fy, 1);
      draw_set_color(_qtcol);

      var _qt_r = lerp(26, 10, _qtp);
      var _qt_edge = _qtr2.vertical ? 90 : 0;
      var _qt_ux = lengthdir_x(1, _qt_edge);
      var _qt_uy = lengthdir_y(1, _qt_edge);
      var _qt_vx = lengthdir_x(1, _qt_edge + 90);
      var _qt_vy = lengthdir_y(1, _qt_edge + 90);
      var _qt_jaw = 6 + _qtp * 4;

      draw_set_alpha(_qta);

      for (var _qtb = 0; _qtb < 2; _qtb++) {
        var _qt_sgn = (_qtb == 0) ? -1 : 1;
        var _qt_bx = _qtr2.lx + _qt_ux * _qt_r * _qt_sgn;
        var _qt_by = _qtr2.ly + _qt_uy * _qt_r * _qt_sgn;

        draw_line_width(_qt_bx - _qt_vx * _qt_jaw, _qt_by - _qt_vy * _qt_jaw,
                        _qt_bx + _qt_vx * _qt_jaw, _qt_by + _qt_vy * _qt_jaw, 2.5);

        var _qt_inx = _qt_ux * 5 * -_qt_sgn;
        var _qt_iny = _qt_uy * 5 * -_qt_sgn;
        draw_line_width(_qt_bx - _qt_vx * _qt_jaw, _qt_by - _qt_vy * _qt_jaw,
                        _qt_bx - _qt_vx * _qt_jaw + _qt_inx, _qt_by - _qt_vy * _qt_jaw + _qt_iny, 2.5);
        draw_line_width(_qt_bx + _qt_vx * _qt_jaw, _qt_by + _qt_vy * _qt_jaw,
                        _qt_bx + _qt_vx * _qt_jaw + _qt_inx, _qt_by + _qt_vy * _qt_jaw + _qt_iny, 2.5);
      }

      draw_set_alpha(_qta * _qtp * 0.9);
      draw_line_width(_qtr2.lx - _qt_vx * 4, _qtr2.ly - _qt_vy * 4,
                      _qtr2.lx + _qt_vx * 4, _qtr2.ly + _qt_vy * 4, 2);
    }
  }

  if (array_length(quarter_craters) > 0) {
    var _k_qc_segs = 12;

    for (var _qci = 0; _qci < array_length(quarter_craters); _qci++) {
      var _qcr2 = quarter_craters[_qci];
      var _qca = _qcr2.life / _qcr2.max_life;
      var _qccol = merge_color((_qcr2.cid == 0) ? _q_red : _q_cyan, c_white, _qcr2.hot * 0.7);

      var _qcux = lengthdir_x(1, _qcr2.edge);
      var _qcuy = lengthdir_y(1, _qcr2.edge);
      var _qcvx = lengthdir_x(1, _qcr2.edge + 90);
      var _qcvy = lengthdir_y(1, _qcr2.edge + 90);

      draw_set_color(_qccol);

      for (var _qlay2 = 0; _qlay2 < 2; _qlay2++) {
        var _qcw = (_qlay2 == 0) ? 5 : 1.6;
        var _qc_amp = (_qlay2 == 0) ? 0.3 : 0.95;
        var _qc_px = 0;
        var _qc_py = 0;

        for (var _qcs = 0; _qcs <= _k_qc_segs; _qcs++) {
          var _qcang = _qcs * (360 / _k_qc_segs);
          var _qcu = dcos(_qcang) * _qcr2.radius;
          var _qcv = dsin(_qcang) * _qcr2.radius * 0.35;
          var _qc_nx = _qcr2.x + _qcux * _qcu + _qcvx * _qcv;
          var _qc_ny = _qcr2.y + _qcuy * _qcu + _qcvy * _qcv;

          if (_qcs > 0) {
            draw_set_alpha(_qca * _qca * _qc_amp);
            draw_line_width(_qc_px, _qc_py, _qc_nx, _qc_ny, _qcw);
          }

          _qc_px = _qc_nx;
          _qc_py = _qc_ny;
        }
      }

      draw_set_alpha(_qca * 0.34);
      draw_line_width(_qcr2.x - _qcux * _qcr2.radius * 1.5, _qcr2.y - _qcuy * _qcr2.radius * 1.5,
                      _qcr2.x + _qcux * _qcr2.radius * 1.5, _qcr2.y + _qcuy * _qcr2.radius * 1.5, 3);
    }
  }

  if (array_length(quarter_stuck) > 0) {
    for (var _qsi = 0; _qsi < array_length(quarter_stuck); _qsi++) {
      var _qst2 = quarter_stuck[_qsi];
      var _qsta = clamp(_qst2.life / _qst2.max_life, 0, 1);
      var _qs_scale = _qst2.scale * (0.6 + _qsta * 0.4);
      var _qs_ring = sin(_qst2.phase + _qst2.life * 0.55) * _qst2.wobble;
      var _qs_base = (_qst2.cid == 0) ? _q_red : _q_cyan;

      draw_sprite_ext((_qst2.cid == 0) ? sRedOrb : sBlueOrb, 0, _qst2.x, _qst2.y,
                      _qs_scale * 1.25, _qs_scale * 0.5, _qst2.edge + _qs_ring * 0.35,
                      merge_color(_qs_base, c_white, _qsta * 0.4), _qsta * 0.7);

      var _qs_sx = _qst2.x - lengthdir_x(7 + _qsta * 5, _qst2.ang);
      var _qs_sy = _qst2.y - lengthdir_y(7 + _qsta * 5, _qst2.ang);

      draw_set_color(_qs_base);
      draw_set_alpha(_qsta * 0.22);
      draw_line_width(_qs_sx, _qs_sy, _qst2.x, _qst2.y, 6);
      draw_set_alpha(_qsta * 0.6);
      draw_line_width(_qs_sx, _qs_sy, _qst2.x, _qst2.y, 2);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (stamp_rail > 0.004 || array_length(stamp_shards) > 0 || array_length(stamp_scars) > 0 ||
    array_length(stamp_sparks) > 0) {

  var _sk_a = clamp(stamp_rail, 0, 1);
  var _sk_dead = stamp_dead ? clamp(stamp_blowout, 0, 1) : 1;

  if (stamp_armed && !stamp_dead && stamp_readout > 0.02) {
    var _lead_a = clamp(stamp_readout, 0, 1) * _sk_a;

    gpu_set_blendmode(bm_add);

    for (var _li = 0; _li < 2; _li++) {
      var _lf = stamp_face[_li];
      var _lt = stamp_face_target[_li];
      var _lw = abs(_lt - _lf);
      if (_lw < 1) continue;

      var _lx0 = min(_lf, _lt);
      var _lx1 = max(_lf, _lt);

      var _fill = (_k_stamp_lead_fill + stamp_coil * _k_stamp_coil_fill) * _lead_a;
      draw_set_color(_k_stamp_col_press);
      draw_set_alpha(_fill);
      draw_rectangle(_lx0, _k_stamp_ceil_y, _lx1, _k_stamp_floor_y, false);

      var _dir = (_li == 0) ? 1 : -1;
      var _hn = 9;
      draw_set_color(_k_stamp_col_press);
      for (var _h = 0; _h < _hn; _h++) {
        var _hf = _h / _hn;
        var _hx = _lf + _dir * (_hf * _lw + frac(t * 0.02) * (_lw / _hn));
        if (_hx < _lx0 || _hx > _lx1) continue;
        draw_set_alpha(_lead_a * (0.1 + stamp_coil * 0.16) * (1 - _hf * 0.5));
        draw_line_width(_hx, _k_stamp_ceil_y, _hx, _k_stamp_floor_y, 2);
      }

      draw_set_color(merge_color(_k_stamp_col_press, c_white, 0.4 + stamp_coil * 0.4));
      draw_set_alpha(_lead_a * _k_stamp_lead_alpha);
      draw_line_width(_lt, _k_stamp_ceil_y, _lt, _k_stamp_floor_y, 2);

      draw_set_color(c_white);
      draw_set_alpha(_lead_a * _k_stamp_lead_alpha * (0.3 + stamp_coil * 0.5));
      draw_line_width(_lt, _k_stamp_ceil_y, _lt, _k_stamp_floor_y, 1);

      draw_set_alpha(_lead_a * _k_stamp_lead_alpha * 0.8);
      draw_set_color(_k_stamp_col_edge);
      for (var _tk = 0; _tk <= 6; _tk++) {
        var _tky = _k_stamp_ceil_y + (_tk / 6) * (_k_stamp_floor_y - _k_stamp_ceil_y);
        draw_line_width(_lt - _dir * 7, _tky, _lt, _tky, 2);
      }
    }

    gpu_set_blendmode(bm_normal);
  }

  if (array_length(stamp_lock_frames) > 0) {
    gpu_set_blendmode(bm_add);

    for (var _fi = 0; _fi < array_length(stamp_lock_frames); _fi++) {
      var _lb = stamp_lock_frames[_fi];
      var _lba = clamp(_lb.life / _lb.life_max, 0, 1);

      scr_draw_lock_bracket(_lb.x0, _k_stamp_ceil_y + 12, _lb.x1, _k_stamp_floor_y - 6,
                            _k_stamp_col_press,
                            _lb.hot,
                            _k_stamp_lead_bracket * (0.45 + _lba * 0.55) * _sk_a,
                            _k_stamp_lock_tick, false, 4, 0,
                            0.8 + 0.2 * _lba,
                            global.avoid_col_cyan);
    }

    gpu_set_blendmode(bm_normal);
  }

  for (var _pi = 0; _pi < 2; _pi++) {
    var _pf = stamp_face[_pi];
    var _pdir = (_pi == 0) ? 1 : -1;
    var _proot = (_pi == 0) ? _k_stamp_x0 - 60 : _k_stamp_x1 + 60;
    var _px0 = min(_proot, _pf);
    var _px1 = max(_proot, _pf);
    if (_px1 - _px0 < 1) continue;

    var _ph = clamp(stamp_face_heat[_pi], 0, 1);
    var _pfl = clamp(stamp_face_flash[_pi], 0, 1);

    draw_set_alpha(_sk_a * 0.96 * _sk_dead);
    draw_set_color(_k_stamp_col_body);
    draw_rectangle(_px0, _k_stamp_ceil_y - 40, _px1, _k_stamp_floor_y, false);

    var _jaw = min(_k_stamp_jaw_depth, _px1 - _px0);
    var _jx0 = (_pdir > 0) ? _pf - _jaw : _pf;
    var _jx1 = (_pdir > 0) ? _pf : _pf + _jaw;
    draw_set_color(_k_stamp_col_frame);
    draw_set_alpha(_sk_a * 0.9 * _sk_dead);
    draw_rectangle(_jx0, _k_stamp_ceil_y - 40, _jx1, _k_stamp_floor_y, false);

    draw_set_alpha(_sk_a * (0.2 + _ph * 0.22) * _sk_dead);
    draw_set_color(_k_stamp_col_body);
    var _rib_n = 11;
    for (var _rb = 1; _rb < _rib_n; _rb++) {
      var _rby = _k_stamp_ceil_y + (_rb / _rib_n) * (_k_stamp_floor_y - _k_stamp_ceil_y);
      draw_line_width(_jx0 + 2, _rby, _jx1 - 2, _rby, 2);
    }

    draw_set_alpha(_sk_a * 0.3 * _sk_dead);
    draw_set_color(_k_stamp_col_frame);
    var _seam = 0;
    for (var _sm = 0; _sm < array_length(_k_stamp_advance); _sm++) {
      _seam += _k_stamp_advance[_sm];
      var _smx = (_pi == 0) ? _k_stamp_x0 + _seam : _k_stamp_x1 - _seam;
      if ((_pi == 0 && _smx > _pf) || (_pi == 1 && _smx < _pf)) break;
      draw_line_width(_smx, _k_stamp_ceil_y - 20, _smx, _k_stamp_floor_y, 1);
    }

    gpu_set_blendmode(bm_add);

    var _ecol = merge_color(global.avoid_col_ember, c_white,
                            0.25 + max(_pfl, stamp_slam_flash * 0.5) * 0.6);
    draw_set_color(_ecol);
    draw_set_alpha(_sk_dead * (0.3 + _ph * 0.4 + _pfl * 0.5));
    draw_line_width(_pf, _k_stamp_ceil_y, _pf, _k_stamp_floor_y, 3 + _pfl * 5);

    draw_set_color(c_white);
    draw_set_alpha(_sk_dead * (0.35 + _pfl * 0.6) * (0.4 + _ph * 0.6));
    draw_line_width(_pf, _k_stamp_ceil_y, _pf, _k_stamp_floor_y, 1);

    var _grad = min(_px1 - _px0, 26 + _pfl * 44);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_pf, _k_stamp_ceil_y, _ecol, _sk_dead * (0.2 + _pfl * 0.35));
    draw_vertex_colour(_pf, _k_stamp_floor_y, _ecol, _sk_dead * (0.2 + _pfl * 0.35));
    draw_vertex_colour(_pf - _pdir * _grad, _k_stamp_ceil_y, _ecol, 0);
    draw_vertex_colour(_pf - _pdir * _grad, _k_stamp_floor_y, _ecol, 0);
    draw_primitive_end();

    gpu_set_blendmode(bm_normal);
  }

  if (array_length(stamp_orbs) > 0) {
    var _orb_a = _sk_a * _sk_dead;

    for (var _oi = 0; _oi < array_length(stamp_orbs); _oi++) {
      var _on = stamp_orbs[_oi];
      if (_on.crushed) continue;

      var _ofl = clamp(_on.flare, 0, 1);
      var _opu = clamp(_on.pulse, 0, 1);
      var _osp = clamp(_on.spawn, 0, 1);
      var _orot = _on.seed * 0.4 + t * _on.spin * 0.35;
      var _orr = _k_stamp_orb_r * (1 + _opu * 0.12);

      if (_osp < 1) {
        var _mr = _k_stamp_orb_r + (1 - _osp) * 26;
        var _ma = _orb_a * (0.25 + _osp * 0.6);

        gpu_set_blendmode(bm_add);

        draw_set_color(merge_color(global.avoid_col_cyan, global.avoid_col_ember, _osp));
        draw_set_alpha(_ma);
        for (var _mc = 0; _mc < 4; _mc++) {
          var _mang = 45 + _mc * 90;
          var _mx = _on.x + lengthdir_x(_mr, _mang);
          var _my = _on.y + lengthdir_y(_mr, _mang);
          var _mt = 4 + (1 - _osp) * 5;
          draw_line_width(_mx, _my, _mx - lengthdir_x(_mt, _mang), _my, 1.5);
          draw_line_width(_mx, _my, _mx, _my - lengthdir_y(_mt, _mang), 1.5);
        }

        draw_set_color(merge_color(global.avoid_col_cyan, _k_stamp_col_edge, _osp));
        draw_set_alpha(_ma * (0.4 + _osp * 0.6));
        for (var _mv = 0; _mv < 8; _mv++) {
          var _m0 = _orot + _mv * 45;
          var _m1 = _orot + (_mv + 1) * 45;
          draw_line_width(_on.x + lengthdir_x(_orr, _m0), _on.y + lengthdir_y(_orr, _m0),
                          _on.x + lengthdir_x(_orr, _m1), _on.y + lengthdir_y(_orr, _m1),
                          1 + _osp);
        }

        gpu_set_blendmode(bm_normal);
        continue;
      }

      draw_primitive_begin(pr_trianglefan);
      draw_vertex_colour(_on.x, _on.y, _k_stamp_col_body, _orb_a * 0.95);
      for (var _v = 0; _v <= 8; _v++) {
        var _va = _orot + _v * 45;
        draw_vertex_colour(_on.x + lengthdir_x(_orr, _va),
                           _on.y + lengthdir_y(_orr, _va),
                           _k_stamp_col_body, _orb_a * 0.95);
      }
      draw_primitive_end();

      var _rimcol = merge_color(_k_stamp_col_edge, global.avoid_col_ember, _ofl);
      draw_set_color(merge_color(_rimcol, c_white, _opu * 0.4));
      draw_set_alpha(_orb_a * (0.45 + _ofl * 0.4 + _opu * 0.3));
      for (var _v2 = 0; _v2 < 8; _v2++) {
        var _a0 = _orot + _v2 * 45;
        var _a1 = _orot + (_v2 + 1) * 45;
        draw_line_width(_on.x + lengthdir_x(_orr, _a0), _on.y + lengthdir_y(_orr, _a0),
                        _on.x + lengthdir_x(_orr, _a1), _on.y + lengthdir_y(_orr, _a1),
                        1.5 + _ofl * 1.5);
      }

      gpu_set_blendmode(bm_add);
      draw_set_color(merge_color(global.avoid_col_ember, c_white, 0.4 + _ofl * 0.5));
      draw_set_alpha(_orb_a * (0.35 + _opu * 0.5 + _ofl * 0.4));
      draw_circle(_on.x, _on.y, 2 + _opu * 1.6 + _ofl * 1.4, false);
      gpu_set_blendmode(bm_normal);
    }
  }

  if (stamp_safe_glow > 0.01) {
    var _sg = clamp(stamp_safe_glow, 0, 1);
    var _sgi = _sg * (0.6 + stamp_hb * 0.4) * _sk_a;
    var _seal = clamp(stamp_safe_seal, 0, 1);

    gpu_set_blendmode(bm_add);

    var _strip = 30 + stamp_hb * 14 + _seal * 26;
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_k_stamp_safe_x0, _k_stamp_floor_y, _k_stamp_col_safe, _sgi * 0.42);
    draw_vertex_colour(_k_stamp_safe_x1, _k_stamp_floor_y, _k_stamp_col_safe, _sgi * 0.42);
    draw_vertex_colour(_k_stamp_safe_x0, _k_stamp_floor_y - _strip, _k_stamp_col_safe, 0);
    draw_vertex_colour(_k_stamp_safe_x1, _k_stamp_floor_y - _strip, _k_stamp_col_safe, 0);
    draw_primitive_end();

    draw_set_color(merge_color(global.avoid_col_cyan_soft, c_white, 0.3 + stamp_hb * 0.3));
    draw_set_alpha(_sgi * 0.9);
    draw_line_width(_k_stamp_safe_x0 + 1, _k_stamp_floor_y - 1,
                    _k_stamp_safe_x1 - 1, _k_stamp_floor_y - 1, 2);

    for (var _si = 0; _si < 2; _si++) {
      var _sx = (_si == 0) ? _k_stamp_safe_x0 : _k_stamp_safe_x1;
      var _brace = 1 - clamp(abs(stamp_face[_si] - _sx) / 180, 0, 1);

      draw_set_color(_k_stamp_col_safe);
      draw_set_alpha(_sgi * (0.34 + _brace * 0.3));
      draw_line_width(_sx, _k_stamp_ceil_y, _sx, _k_stamp_floor_y, 2 + _brace * 3);

      draw_set_color(merge_color(global.avoid_col_cyan_soft, c_white, 0.5));
      draw_set_alpha(_sgi * (0.5 + _seal * 0.5));
      draw_line_width(_sx, _k_stamp_floor_y - 40 - _brace * 40, _sx, _k_stamp_floor_y, 2);

      draw_set_color(merge_color(_k_stamp_col_safe, c_white, 0.55));
      draw_set_alpha(_sgi);
      draw_line_width(_sx, _k_stamp_floor_y - 18, _sx, _k_stamp_floor_y, 2.5);
      var _in = (_si == 0) ? 1 : -1;
      draw_line_width(_sx, _k_stamp_floor_y - 1, _sx + _in * 18, _k_stamp_floor_y - 1, 2.5);
    }

    if (_seal > 0.01) {
      draw_set_color(merge_color(_k_stamp_col_safe, c_white, 0.6));
      draw_set_alpha(_seal * _seal * 0.5);
      var _sh2 = (1 - _seal) * 260;
      draw_line_width(_k_stamp_safe_x0, _k_stamp_floor_y - _sh2,
                      _k_stamp_safe_x1, _k_stamp_floor_y - _sh2, 3 + _seal * 5);
    }

    gpu_set_blendmode(bm_normal);
  }

  for (var _si2 = 0; _si2 < array_length(stamp_shards); _si2++) {
    var _sh3 = stamp_shards[_si2];
    var _sha = clamp(_sh3.life / _sh3.life_max, 0, 1);
    var _shs = _sh3.size * (0.5 + _sha * 0.5);

    draw_set_alpha(_sha * 0.85);
    draw_primitive_begin(pr_trianglelist);
    for (var _sv = 0; _sv < 3; _sv++) {
      var _sva = _sh3.rot + _sv * 120;
      draw_vertex_colour(_sh3.x + lengthdir_x(_shs, _sva),
                         _sh3.y + lengthdir_y(_shs, _sva),
                         _sh3.color, _sha * 0.9);
    }
    draw_primitive_end();

    if (_sha > 0.6) {
      gpu_set_blendmode(bm_add);
      draw_set_color(merge_color(_sh3.color, c_white, _sh3.hot * 0.6));
      draw_set_alpha((_sha - 0.6) * 1.4 * _sh3.hot * 0.5);
      draw_circle(_sh3.x, _sh3.y, _shs * 0.5, true);
      gpu_set_blendmode(bm_normal);
    }
  }

  gpu_set_blendmode(bm_add);

  for (var _sci = 0; _sci < array_length(stamp_scars); _sci++) {
    var _sc = stamp_scars[_sci];
    var _sca = clamp(_sc.life / _sc.life_max, 0, 1);
    var _sch = 5 + _sca * 9;

    draw_set_color(merge_color(_sc.color, global.avoid_col_blood, 1 - _sca));
    draw_set_alpha(_sca * _sca * 0.32);
    draw_rectangle(_sc.x - _sc.w, _k_stamp_floor_y - _sch,
                   _sc.x + _sc.w * 0.15, _k_stamp_floor_y, false);

    draw_set_color(merge_color(_sc.color, c_white, _sca * 0.5));
    draw_set_alpha(_sca * _sca * 0.45);
    draw_line_width(_sc.x - _sc.w * 0.8, _k_stamp_floor_y - 1,
                    _sc.x, _k_stamp_floor_y - 1, 2);
  }

  for (var _ti = 0; _ti < array_length(stamp_tips); _ti++) {
    var _tp = stamp_tips[_ti];
    var _tpa = clamp(_tp.life / _tp.life_max, 0, 1);

    draw_set_color(merge_color(_tp.color, c_white, 0.4 + _tpa * 0.4));
    draw_set_alpha(_tpa * _tpa * _tp.hot * 0.7);
    draw_line_width(_tp.x, _k_stamp_ceil_y, _tp.x, _k_stamp_floor_y, 2 + _tpa * 7);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_bursts) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(ring_bursts); ++i) {
    var _b = ring_bursts[i];
    if (_b.shockwave_alpha > 0) {
      var _bcol = variable_struct_exists(_b, "color") ? merge_color(_b.color, c_white, 0.45) : c_white;
      var _btier = variable_struct_exists(_b, "tier") ? _b.tier : 1;
      var _btear = clamp((_btier - 1) / 3, 0, 1) * 3.5;
      if (_btear > 0.1) {
        scr_draw_smooth_ring_mask(_b.x, _b.y, _b.shockwave_radius - _btear,
                                  _b.shockwave_alpha * 0.26, 12 + _btier, _k_er_col_warning);
        scr_draw_smooth_ring_mask(_b.x, _b.y, _b.shockwave_radius + _btear,
                                  _b.shockwave_alpha * 0.26, 12 + _btier, _k_er_col_cyan);
      }
      scr_draw_smooth_ring_mask(_b.x, _b.y, _b.shockwave_radius, _b.shockwave_alpha, 14 + _btier * 2, _bcol);
    }
  }
  gpu_set_blendmode(bm_normal);
}

if (t377_flash_timer > 0) {
  var _k_flash_duration = 4;
  var _flash_alpha = (1 - (t377_flash_timer / _k_flash_duration)) * 0.6 * fx_get_mult("flash");

  draw_set_alpha(_flash_alpha);
  draw_set_color(c_white);
  draw_rectangle(0, 0, room_width, room_height, false);
  draw_set_alpha(1);

  t377_flash_timer++;
  if (t377_flash_timer > _k_flash_duration) t377_flash_timer = 0;
}

if (lorb_readout > 0.01 || lorb_storm > 0.01 || array_length(lorb_floor_hits) > 0 ||
    array_length(lorb_scorch) > 0 || array_length(lorb_col_marks) > 0 ||
    array_length(lorb_sky_rifts) > 0 || array_length(lorb_seam_pulses) > 0 ||
    array_length(lorb_head_sparks) > 0 || array_length(lorb_lead_bursts) > 0 ||
    array_length(lorb_scars) > 0 || array_length(lorb_wall_hits) > 0 ||
    array_length(lorb_drips) > 0 || array_length(lorb_strikes) > 0 ||
    lorb_front_live || lorb_lead_spawn > 0.01 || lorb_lead_despawn > 0.01) {
  gpu_set_blendmode(bm_add);

  var _lo_fy = _k_lorb_floor_y;
  var _lo_xmin = _k_lorb_pad;
  var _lo_xmax = room_width - _k_lorb_pad;
  var _lo_base = global.lightning_color;
  var _lo_read_mult = fx_get_mult_for("lightningorbs", "readout");
  var _lo_floor_mult = fx_get_mult_for("lightningorbs", "floor");

  if (lorb_storm > 0.01) {
    var _storm_a = clamp(lorb_storm, 0, 1.3);
    var _storm_h = 48 + _storm_a * 86;
    var _storm_col = merge_color(_lo_base, c_white, 0.18 + lorb_countdown * 0.42);

    for (var _sb = 0; _sb < 9; _sb++) {
      var _su = _sb / 9;
      var _sa = _storm_a * (0.055 + lorb_amb_hb * 0.025 + lorb_strike_flash * 0.075) *
                power(1 - _su, 1.3);
      draw_set_color(_storm_col);
      draw_set_alpha(_sa);
      draw_rectangle(0, _su * _storm_h, room_width, ((_sb + 1) / 9) * _storm_h, false);
    }

    draw_set_color(merge_color(_storm_col, c_white, 0.65));
    draw_set_alpha(_storm_a * (0.24 + lorb_amb_tick * 0.18));
    draw_line_width(0, _storm_h, room_width, _storm_h, 1.5 + lorb_beat_flash * 3);

    var _hub_r = 28 + lorb_countdown * 64 + lorb_amb_hb * 12;
    draw_set_alpha(_storm_a * (0.08 + lorb_beat_flash * 0.08));
    draw_ellipse(400 - _hub_r * 2.0, 112 - _hub_r * 0.55,
                 400 + _hub_r * 2.0, 112 + _hub_r * 0.55, true);
  }

  if (array_length(lorb_sky_rifts) > 0) {
    for (var _ri = 0; _ri < array_length(lorb_sky_rifts); _ri++) {
      var _rf = lorb_sky_rifts[_ri];
      var _rfa = (_rf.life / max(_rf.life_max, 1)) * (0.24 + _rf.hot * 0.36);
      var _rfcol = merge_color(_lo_base, c_white, 0.2 + _rf.hot * 0.5);

      draw_set_color(_rfcol);
      draw_set_alpha(_rfa * 0.18);
      draw_line_width(_rf.x1, _rf.y1, _rf.x2, _rf.y2, 12 + _rf.hot * 10);
      draw_set_alpha(_rfa * 0.56);
      draw_line_width(_rf.x1, _rf.y1, _rf.x2, _rf.y2, 2 + _rf.hot * 2);
      draw_set_color(c_white);
      draw_set_alpha(_rfa * 0.72);
      draw_line_width(_rf.x1, _rf.y1, _rf.x2, _rf.y2, 0.8 + _rf.hot);
    }
  }

  // --------------------------------------------------------------------------
  // THE CONDUCTOR
  // --------------------------------------------------------------------------
  var _lo_hub_x = _k_lorb_hub_x;
  var _lo_hub_y = _k_lorb_hub_y;

  // --- strokes of the sweeps already finished, cooling ----------------------
  for (var _lsi = 0; _lsi < array_length(lorb_scars); _lsi++) {
    var _sc = lorb_scars[_lsi];
    var _sca = power(_sc.life / _sc.life_max, 1.5) * (0.34 + _sc.hot * 0.36) *
               (0.55 + lorb_amb * 0.5) * _lo_read_mult;
    if (_sca <= 0.008) continue;

    var _scp = lorb_path_points(_sc.f0, _sc.f1, _sc.lane, _k_lorb_scar_step, 0, 0, true);
    var _scn = array_length(_scp);
    if (_scn < 2) continue;

    for (var _sp = 0; _sp < _scn; _sp++) _scp[_sp].u = 0.42 + _scp[_sp].u * 0.58;

    scr_draw_comet_ribbon(_scp, _lo_base, _sca, 3.6 + _sc.hot * 3.4, 1.4, 0.5,
                          merge_color(_lo_base, c_white, 0.55), 1.0);
  }

  // --- the head, and the strobe of where it just was ------------------------
  if (lorb_front_live) {
    var _lead_hot_now = clamp(0.48 + lorb_countdown * 0.42 + lorb_beat_flash * 0.35 +
                              lorb_lead_flash * 0.42 + ((lorb_front_beat >= 4) ? 0.22 : 0), 0, 1.55);
    var _head_flash = lorb_lead_flash * lorb_lead_flash;
    var _hold = _k_lorb_stamp_frames[lorb_front_beat];
    var _park_ring = lorb_front_parked ? lorb_park : 0;
    var _lead_prev_x = 0;
    var _lead_prev_y = 0;

    for (var _ldi = 0; _ldi < lorb_front_n; _ldi++) {
      var _sf = lorb_stamp_f(t, _ldi);
      var _age = lorb_stamp_age(t, _ldi);

      var _pulse = lorb_front_parked
                 ? (0.35 + lorb_park * 0.85 + random(0.25))
                 : power(1 - _age, 1.8);

      var _here = lorb_head_at(_sf, _ldi);
      var _was = lorb_head_at(_sf - _hold, _ldi);
      var _ldx = _here.x;
      var _ldy = _here.y;

      var _jx = _ldx - _was.x;
      var _jy = _ldy - _was.y;
      var _jl = max(0.0001, point_distance(0, 0, _jx, _jy));
      var _fwx = _jx / _jl;
      var _fwy = _jy / _jl;
      var _sdx = -_fwy;
      var _sdy = _fwx;

      var _ldr = (13 + _lead_hot_now * 6 + lorb_amb_hb * 6 + _head_flash * 9) * (0.78 + _pulse * 0.42);
      var _lda = clamp((0.36 + _lead_hot_now * 0.28) * (0.75 + lorb_amb * 0.25) *
                       (0.55 + _pulse * 0.6), 0, 1);
      var _ldcol = merge_color(_lo_base, c_white, 0.18 + _lead_hot_now * 0.22);
      var _hl = _ldr * 1.15;
      var _hw = _ldr * 0.58;

      // --- the afterimages, oldest first so the live head lands on top ------
      for (var _gh = _k_lorb_ghosts; _gh >= 1; _gh--) {
        var _gf = _sf - _gh * _hold;
        if (_gf < _k_lorb_beats[lorb_front_beat]) continue;

        var _gp = lorb_head_at(_gf, _ldi);
        var _ga = _lda * power(1 - _gh / (_k_lorb_ghosts + 1), 2.1) * 0.85;
        if (_ga <= 0.012) continue;

        var _gr = _ldr * (1 - _gh * 0.12);
        var _gq = lorb_head_at(_gf - _hold, _ldi);
        var _gjx = _gp.x - _gq.x;
        var _gjy = _gp.y - _gq.y;
        var _gjl = max(0.0001, point_distance(0, 0, _gjx, _gjy));

        draw_set_color(_ldcol);
        draw_set_alpha(_ga * 0.5);
        draw_ellipse(_gp.x - _gr * 0.85, _gp.y - _gr * 0.85,
                     _gp.x + _gr * 0.85, _gp.y + _gr * 0.85, false);

        draw_set_color(merge_color(_ldcol, c_white, 0.4));
        draw_set_alpha(_ga * 0.85);
        draw_line_width(_gp.x - (_gjx / _gjl) * _gr * 0.7, _gp.y - (_gjy / _gjl) * _gr * 0.7,
                        _gp.x + (_gjx / _gjl) * _gr * 0.7, _gp.y + (_gjy / _gjl) * _gr * 0.7, 1.6);
      }

      // --- the live head ----------------------------------------------------
      draw_set_color(_lo_base);
      draw_set_alpha(_lda * 0.15);
      draw_ellipse(_ldx - _ldr * 2.2, _ldy - _ldr * 2.2, _ldx + _ldr * 2.2, _ldy + _ldr * 2.2, false);
      draw_set_color(_ldcol);
      draw_set_alpha(_lda * 0.30);
      draw_ellipse(_ldx - _ldr * 0.95, _ldy - _ldr * 0.95, _ldx + _ldr * 0.95, _ldy + _ldr * 0.95, false);

      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(_ldx - _fwx * _hl * 2.4 - _sdx * _hw * 0.22,
                         _ldy - _fwy * _hl * 2.4 - _sdy * _hw * 0.22, _ldcol, 0);
      draw_vertex_colour(_ldx - _fwx * _hl * 0.45 - _sdx * _hw,
                         _ldy - _fwy * _hl * 0.45 - _sdy * _hw, _ldcol, _lda * 0.36);
      draw_vertex_colour(_ldx + _fwx * _hl * 1.55, _ldy + _fwy * _hl * 1.55, c_white,
                         min(1, _lda * 0.95));
      draw_vertex_colour(_ldx - _fwx * _hl * 0.45 + _sdx * _hw,
                         _ldy - _fwy * _hl * 0.45 + _sdy * _hw, _ldcol, _lda * 0.36);
      draw_vertex_colour(_ldx - _fwx * _hl * 2.4 + _sdx * _hw * 0.22,
                         _ldy - _fwy * _hl * 2.4 + _sdy * _hw * 0.22, _ldcol, 0);
      draw_primitive_end();

      var _spikes = 5 + irandom(3);

      draw_set_color(merge_color(_ldcol, c_white, 0.45));

      for (var _spk = 0; _spk < _spikes; _spk++) {
        var _spa = random(360);
        var _spl = _ldr * random_range(0.8, 2.4) * (0.6 + _pulse + _head_flash);

        draw_set_alpha(_lda * random_range(0.18, 0.46));
        draw_line_width(_ldx, _ldy, _ldx + lengthdir_x(_spl, _spa), _ldy + lengthdir_y(_spl, _spa),
                        random_range(1, 2.6));
      }

      if (_park_ring > 0.01) {
        draw_set_color(merge_color(_lo_base, c_white, 0.35));
        draw_set_alpha(_lda * (0.2 + _park_ring * 0.35));
        draw_ellipse(_ldx - _ldr * (3.4 - _park_ring * 2.1), _ldy - _ldr * (3.4 - _park_ring * 2.1),
                     _ldx + _ldr * (3.4 - _park_ring * 2.1), _ldy + _ldr * (3.4 - _park_ring * 2.1),
                     true);
      }

      draw_set_color(c_white);
      draw_set_alpha(min(1, _lda * 1.3));
      draw_line_width(_ldx - _fwx * _hl * 0.8, _ldy - _fwy * _hl * 0.8,
                      _ldx + _fwx * _hl * 1.35, _ldy + _fwy * _hl * 1.35,
                      1.5 + _pulse * 2 + _head_flash * 2.4);
      draw_line_width(_ldx - _sdx * _ldr * 0.62, _ldy - _sdy * _ldr * 0.62,
                      _ldx + _sdx * _ldr * 0.62, _ldy + _sdy * _ldr * 0.62, 1.1);

      if (_ldi > 0) {
        draw_set_color(merge_color(_ldcol, c_white, 0.45));
        draw_set_alpha(_lda * (0.20 + _head_flash * 0.24));
        draw_line_width(_lead_prev_x, _lead_prev_y, _ldx, _ldy, 6 + _head_flash * 8);
        draw_set_color(c_white);
        draw_set_alpha(_lda * (0.52 + _head_flash * 0.28));
        draw_line_width(_lead_prev_x, _lead_prev_y, _ldx, _ldy, 1.2 + _head_flash * 2);
      }

      _lead_prev_x = _ldx;
      _lead_prev_y = _ldy;
    }
  }

  // --- THE STRIKE CHAIN ------------------------------------------------------
  for (var _sti = 0; _sti < array_length(lorb_strikes); _sti++) {
    var _stk = lorb_strikes[_sti];
    var _sta = power(_stk.life / _stk.life_max, 1.4) * (0.5 + _stk.hot * 0.5);
    if (_sta <= 0.01) continue;

    scr_draw_energy_bolt(_stk.x1, _stk.y1, _stk.x2, _stk.y2, _sta, _stk.col, _stk.off,
                         _stk.width, _stk.wide ? 0.5 : 0.3);

    for (var _stf = 0; _stf < array_length(_stk.forks); _stf++) {
      var _fk = _stk.forks[_stf];

      scr_draw_energy_bolt(_fk.x1, _fk.y1, _fk.x2, _fk.y2, _sta * 0.58,
                           _fk.col, _fk.off, _fk.w, 0.25);
    }
  }

  // --- strands where orbs actually left the streak ---------------------------
  for (var _dri = 0; _dri < array_length(lorb_drips); _dri++) {
    var _dp = lorb_drips[_dri];
    var _dpl = _dp.life / _dp.life_max;
    var _dpa = _dpl * (0.34 + _dp.hot * 0.4) * (0.6 + lorb_amb * 0.5);
    if (_dpa <= 0.01) continue;

    var _dpr = _dp.reach * (1 - _dpl * 0.55);
    var _dpw = sin(_dp.seed + _dpl * 5) * 4 * (1 - _dpl);

    draw_set_color(merge_color(_lo_base, c_white, 0.3 + _dp.hot * 0.3));
    draw_set_alpha(_dpa * 0.22);
    draw_line_width(_dp.x, _dp.y, _dp.x + _dpw, _dp.y + _dpr, 7);
    draw_set_color(c_white);
    draw_set_alpha(_dpa * 0.7);
    draw_line_width(_dp.x, _dp.y, _dp.x + _dpw, _dp.y + _dpr, 1.2);
  }

  // --- the wall the head just hit -------------------------------------------
  for (var _whi = 0; _whi < array_length(lorb_wall_hits); _whi++) {
    var _wh = lorb_wall_hits[_whi];
    var _wha = power(_wh.life / _wh.life_max, 1.2) * (0.55 + _wh.hot * 0.45) * _lo_read_mult;
    if (_wha <= 0.01) continue;

    var _whcol = merge_color(_lo_base, c_white, 0.3 + _wh.hot * 0.5);
    var _whr = _wh.radius;

    var _k_wh_rows = 9;
    var _wh_h = 150 + _wh.hot * 140;

    draw_primitive_begin(pr_trianglestrip);

    for (var _whr2 = 0; _whr2 <= _k_wh_rows; _whr2++) {
      var _whu = _whr2 / _k_wh_rows;
      var _why = _wh.y - _wh_h * 0.5 + _wh_h * _whu;
      var _whw = (14 + _wh.hot * 26) * power(sin(pi * _whu), 0.7) * (0.35 + _wha);
      var _whva = _wha * 0.34 * power(sin(pi * _whu), 0.9);

      draw_vertex_colour(_wh.x, _why, _whcol, _whva);
      draw_vertex_colour(_wh.x + _wh.dir * _whw, _why, _whcol, 0);
    }

    draw_primitive_end();

    var _k_wh_segs = 14;
    var _wh_px = 0;
    var _wh_py = 0;

    draw_set_color(_whcol);

    for (var _whs = 0; _whs <= _k_wh_segs; _whs++) {
      var _wha2 = -90 + _whs * (180 / _k_wh_segs);
      var _whnx = _wh.x + dcos(_wha2) * _whr * _wh.dir * 0.55;
      var _whny = _wh.y + dsin(_wha2) * _whr;

      if (_whs > 0) {
        draw_set_alpha(_wha * _wha * 0.7);
        draw_line_width(_wh_px, _wh_py, _whnx, _whny, 2 + _wh.hot * 2);
      }

      _wh_px = _whnx;
      _wh_py = _whny;
    }

    draw_set_color(c_white);
    draw_set_alpha(_wha * 0.8);
    draw_line_width(_wh.x, _wh.y, _wh.x + _wh.dir * (26 + _whr * 0.9), _wh.y, 2 + _wh.hot * 2);
    draw_line_width(_wh.x, _wh.y - 16 - _wh.hot * 14, _wh.x, _wh.y + 16 + _wh.hot * 14, 1.6);
  }

  // --- grit thrown off the head ---------------------------------------------
  for (var _hsi = 0; _hsi < array_length(lorb_head_sparks); _hsi++) {
    var _hs = lorb_head_sparks[_hsi];
    var _hsa = power(_hs.life / _hs.life_max, 1.3) * (0.4 + _hs.hot * 0.5);
    if (_hsa <= 0.01) continue;

    draw_set_color(merge_color(_lo_base, c_white, 0.2 + _hs.hot * 0.45));
    draw_set_alpha(_hsa * 0.45);
    draw_line_width(_hs.px, _hs.py, _hs.x, _hs.y, max(1, _hs.size * 2.1));
    draw_set_color(c_white);
    draw_set_alpha(_hsa * _hsa * 0.85);
    draw_line_width(_hs.px, _hs.py, _hs.x, _hs.y, max(0.6, _hs.size * 0.5));
  }

  // --- fired out of the hub -------------------------------------------------
  if (lorb_lead_spawn > 0.01) {
    var _lgate_left = clamp(lorb_lead_spawn, 0, 1);
    var _lgate_p = 1 - _lgate_left;
    var _lgate_e = _lgate_p * _lgate_p * (3 - 2 * _lgate_p);
    var _lgate_h = lorb_head_at(lorb_front_live ? t : _k_lorb_start_t + 1, 0);
    var _lgate_r = lerp(96, 18, _lgate_e) + lorb_amb_hb * 12;
    var _lgate_col = merge_color(_lo_base, c_white, 0.48);

    draw_set_color(_lgate_col);
    draw_set_alpha(_lgate_left * 0.18);
    draw_line_width(_lo_hub_x, _lo_hub_y, _lgate_h.x, _lgate_h.y, 30 - _lgate_e * 16);
    draw_set_alpha(_lgate_left * 0.48);
    draw_line_width(_lo_hub_x, _lo_hub_y, _lgate_h.x, _lgate_h.y, 4 + lorb_lead_flash * 3);

    draw_set_alpha(_lgate_left * 0.20);
    draw_ellipse(_lgate_h.x - _lgate_r * 1.9, _lgate_h.y - _lgate_r * 0.75,
                 _lgate_h.x + _lgate_r * 1.9, _lgate_h.y + _lgate_r * 0.75, false);
    draw_set_color(c_white);
    draw_set_alpha(_lgate_left * 0.68);
    draw_ellipse(_lgate_h.x - _lgate_r * 0.55, _lgate_h.y - _lgate_r * 0.55,
                 _lgate_h.x + _lgate_r * 0.55, _lgate_h.y + _lgate_r * 0.55, false);
  }

  if (lorb_lead_despawn > 0.01) {
    var _ldie_left = clamp(lorb_lead_despawn, 0, 1);
    var _ldie_p = 1 - _ldie_left;
    var _ldie_e = _ldie_p * _ldie_p * (3 - 2 * _ldie_p);
    var _ldie_r = lerp(128, 10, _ldie_e);
    var _ldie_col = merge_color(_lo_base, c_white, 0.6);

    draw_set_color(_ldie_col);
    draw_set_alpha(_ldie_left * 0.22);
    draw_ellipse(lorb_lead_exit_x - _ldie_r * 1.7, lorb_lead_exit_y - _ldie_r * 0.7,
                 lorb_lead_exit_x + _ldie_r * 1.7, lorb_lead_exit_y + _ldie_r * 0.7, false);

    draw_set_alpha(_ldie_left * 0.52);
    draw_line_width(lorb_lead_exit_x - _ldie_r, lorb_lead_exit_y, lorb_lead_exit_x + _ldie_r, lorb_lead_exit_y,
                    3 + _ldie_left * 4);
    draw_line_width(lorb_lead_exit_x, lorb_lead_exit_y - _ldie_r * 0.65,
                    lorb_lead_exit_x, lorb_lead_exit_y + _ldie_r * 0.65, 2 + _ldie_left * 3);
    draw_set_color(c_white);
    draw_set_alpha(_ldie_left * 0.8);
    draw_ellipse(lorb_lead_exit_x - 6 - _ldie_p * 8, lorb_lead_exit_y - 6 - _ldie_p * 8,
                 lorb_lead_exit_x + 6 + _ldie_p * 8, lorb_lead_exit_y + 6 + _ldie_p * 8, false);
  }

  if (array_length(lorb_scorch) > 0) {
    for (var _ls = 0; _ls < array_length(lorb_scorch); _ls++) {
      var _lsc = lorb_scorch[_ls];
      var _lsa = clamp(_lsc.alpha, 0, 1) * _lo_floor_mult;
      if (_lsa <= 0.01) continue;

      var _lscol = merge_color(_lo_base, c_white, _lsc.hot * 0.4);
      var _lsw = _lsc.w;

      draw_set_color(_lscol);

      draw_set_alpha(_lsa * 0.16);
      draw_line_width(_lsc.x - _lsw, _lo_fy, _lsc.x + _lsw, _lo_fy, 7);
      draw_set_alpha(_lsa * 0.3);
      draw_line_width(_lsc.x - _lsw * 0.62, _lo_fy, _lsc.x + _lsw * 0.62, _lo_fy, 3.5);

      draw_set_color(merge_color(_lscol, c_white, 0.45));
      draw_set_alpha(_lsa * 0.4);
      draw_line_width(_lsc.x, _lo_fy - 5 - _lsc.hot * 4, _lsc.x, _lo_fy + 2, 2);
    }
  }

  if (array_length(lorb_floor_hits) > 0) {
    var _k_lo_segs = 12;

    for (var _lh = 0; _lh < array_length(lorb_floor_hits); _lh++) {
      var _lhi = lorb_floor_hits[_lh];
      var _lha = (_lhi.life / _lhi.max_life) * _lo_floor_mult;
      var _lhcol = merge_color(_lo_base, c_white, _lhi.hot * 0.75);

      draw_set_color(_lhcol);

      for (var _llay = 0; _llay < 2; _llay++) {
        var _lhw = (_llay == 0) ? 5 : 1.6;
        var _lamp = (_llay == 0) ? 0.28 : 0.9;
        var _lpx = 0;
        var _lpy = 0;

        for (var _lcs = 0; _lcs <= _k_lo_segs; _lcs++) {
          var _lang = _lcs * (360 / _k_lo_segs);
          var _lnx = _lhi.x + dcos(_lang) * _lhi.radius;
          var _lny = _lo_fy + dsin(_lang) * _lhi.radius * 0.32;

          if (_lcs > 0) {
            draw_set_alpha(_lha * _lha * _lamp);
            draw_line_width(_lpx, _lpy, _lnx, _lny, _lhw);
          }

          _lpx = _lnx;
          _lpy = _lny;
        }
      }

      draw_set_alpha(_lha * 0.34);
      draw_line_width(_lhi.x - _lhi.radius * 1.6, _lo_fy, _lhi.x + _lhi.radius * 1.6, _lo_fy, 3);

      var _lsp = 1 - (_lhi.life / _lhi.max_life);
      draw_set_color(c_white);
      draw_set_alpha(_lha * _lha * 0.55);
      draw_line_width(_lhi.x, _lo_fy, _lhi.x, _lo_fy - (10 + _lhi.hot * 26) * (1 - _lsp * 0.5), 2);
    }
  }

  if (lorb_readout > 0.02 && (array_length(lorb_columns) > 0 || lorb_front_live)) {
    var _lo_ra = lorb_readout * _lo_read_mult;

    for (var _lci = 0; _lci < array_length(lorb_columns); _lci++) {
      var _lc = lorb_columns[_lci];
      var _lfill = clamp((t - _lc.spawn_t) / max(_lc.fall, 1), 0, 1);
      var _llate = clamp((t - _lc.land_t) / 8, 0, 1);
      var _lland = _lc.landed ? (1 - _llate) : 0;

      var _lw8 = power(_lfill, 2.2);
      var _lca = _lo_ra * (0.1 + _lw8 * 0.62 + _lland * 0.5) * (0.55 + lorb_amb * 0.6);
      if (_lca <= 0.012) continue;

      var _lcol = merge_color(_lo_base, c_white, 0.25 + _lw8 * 0.6);
      var _lcx = clamp(_lc.sx, _lo_xmin, _lo_xmax);

      var _lch = 20 + _lw8 * 40 + _lland * 26;
      var _ltime = max(0, t - _lc.spawn_t);
      var _fall_y = clamp(_lc.y0 + 0.5 * _lc.g * _ltime * _ltime, 0, _lo_fy);
      var _tail = (38 + _lw8 * 104) * _lc.slice;

      if (!_lc.landed && _lfill > 0.05) {
        var _needle_a = _lo_ra * (0.12 + _lw8 * 0.38) * (0.65 + lorb_amb * 0.45);
        draw_set_color(merge_color(_lcol, c_white, 0.35));
        draw_set_alpha(_needle_a * 0.18);
        draw_line_width(_lcx, max(0, _fall_y - _tail), _lcx, min(_lo_fy, _fall_y + 14), 12);
        draw_set_alpha(_needle_a * 0.68);
        draw_line_width(_lcx, max(0, _fall_y - _tail * 0.55), _lcx, min(_lo_fy, _fall_y + 8), 2.2);

        draw_set_color(c_white);
        draw_set_alpha(_needle_a * 0.95);
        draw_line_width(_lcx - 7, _fall_y, _lcx + 7, _fall_y, 1.6);
        draw_line_width(_lcx, _fall_y - 7, _lcx, _fall_y + 7, 1.6);
      }

      for (var _llay2 = 0; _llay2 < 2; _llay2++) {
        var _lhw2 = (_llay2 == 0) ? 4 : 1.2;
        var _lamp2 = _lca * ((_llay2 == 0) ? 1.1 : 2.6);
        var _k_lo_pseg = 6;

        draw_primitive_begin(pr_trianglestrip);

        for (var _lps = 0; _lps <= _k_lo_pseg; _lps++) {
          var _lpu = _lps / _k_lo_pseg;
          var _lpy2 = _lo_fy - _lch * _lpu;
          var _lpa = min(1, _lamp2 * power(1 - _lpu, 1.6));

          draw_vertex_colour(_lcx - _lhw2, _lpy2, _lcol, _lpa);
          draw_vertex_colour(_lcx + _lhw2, _lpy2, _lcol, _lpa);
        }

        draw_primitive_end();
      }

      if (_lc.banded && _lc.band > 1) {
        var _lbl = clamp(_lc.sx - _lc.band, _lo_xmin, _lo_xmax);
        var _lbr = clamp(_lc.sx + _lc.band, _lo_xmin, _lo_xmax);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_lbl, _lo_fy - 7, _lcol, 0);
        draw_vertex_colour(_lbl, _lo_fy + 1, _lcol, _lca * 0.5);
        draw_vertex_colour(_lc.sx, _lo_fy - 9, _lcol, _lca * 0.34);
        draw_vertex_colour(_lc.sx, _lo_fy + 1, _lcol, _lca * 0.9);
        draw_vertex_colour(_lbr, _lo_fy - 7, _lcol, 0);
        draw_vertex_colour(_lbr, _lo_fy + 1, _lcol, _lca * 0.5);
        draw_primitive_end();

        draw_set_color(merge_color(_lcol, c_white, 0.4));
        draw_set_alpha(min(1, _lca * 1.5));
        draw_line_width(_lbl, _lo_fy - 8, _lbl, _lo_fy + 2, 2);
        draw_line_width(_lbr, _lo_fy - 8, _lbr, _lo_fy + 2, 2);
      }

      if (_lw8 > 0.12) {
        var _lbr2 = lerp(30, 9, _lw8);

        draw_set_color(merge_color(_lcol, c_white, 0.5));
        draw_set_alpha(min(1, _lca * 1.7));
        draw_line_width(_lcx - _lbr2, _lo_fy, _lcx - _lbr2 + 6, _lo_fy, 2.5);
        draw_line_width(_lcx + _lbr2 - 6, _lo_fy, _lcx + _lbr2, _lo_fy, 2.5);
        draw_line_width(_lcx - _lbr2, _lo_fy - 6, _lcx - _lbr2, _lo_fy + 6, 2.5);
        draw_line_width(_lcx + _lbr2, _lo_fy - 6, _lcx + _lbr2, _lo_fy + 6, 2.5);
      }
    }

    var _lp_first = t + ((_k_lorb_col_every - (t mod _k_lorb_col_every)) mod _k_lorb_col_every);
    if (_lp_first <= t) _lp_first += _k_lorb_col_every;

    for (var _lpi = 0; _lpi < _k_lorb_predict; _lpi++) {
      var _lpf = _lp_first + _lpi * _k_lorb_col_every;
      var _lpfr = lorb_front_at(_lpf);
      if (_lpfr.n <= 0) continue;

      var _lpa2 = _lo_ra * (0.3 - _lpi * 0.08) * (0.5 + lorb_amb * 0.5);
      if (_lpa2 <= 0.01) continue;

      draw_set_color(merge_color(_lo_base, c_white, 0.15));

      for (var _lpw = 0; _lpw < _lpfr.n; _lpw++) {
        var _lpx2 = clamp((_lpw == 0) ? _lpfr.a : _lpfr.b, _lo_xmin, _lo_xmax);

        for (var _lpd = 0; _lpd < 4; _lpd++) {
          var _lpy3 = _lo_fy - _lpd * 7;
          draw_set_alpha(min(1, _lpa2 * (1.4 - _lpd * 0.28)));
          draw_line_width(_lpx2 - 4, _lpy3, _lpx2 + 4, _lpy3, 2);
        }
      }
    }

    if (lorb_gap_w > 46) {
      var _lg_hw = min(lorb_gap_w * 0.36, 120);
      var _lg_x = clamp(lorb_gap_x_draw, _lo_xmin + 8, _lo_xmax - 8);
      var _lg_a = _lo_ra * (0.16 + lorb_gap_flash * 0.16 + lorb_amb_hb * 0.1);
      var _lg_col = merge_color(_lo_base, make_color_rgb(190, 245, 255), 0.7);

      var _k_lg_steps = 10;

      draw_primitive_begin(pr_trianglestrip);

      for (var _lgs = 0; _lgs <= _k_lg_steps; _lgs++) {
        var _lgu = _lgs / _k_lg_steps;
        var _lgx2 = _lg_x - _lg_hw + _lg_hw * 2 * _lgu;
        var _lga2 = _lg_a * power(sin(pi * _lgu), 0.8);

        draw_vertex_colour(_lgx2, _lo_fy - 26, _lg_col, 0);
        draw_vertex_colour(_lgx2, _lo_fy + 2, _lg_col, _lga2);
      }

      draw_primitive_end();

      draw_set_color(merge_color(_lg_col, c_white, 0.4));
      draw_set_alpha(min(1, _lg_a * 3.4));

      for (var _lgc = 0; _lgc < 2; _lgc++) {
        var _lgs2 = (_lgc == 0) ? -1 : 1;
        var _lgcx = _lg_x + _lg_hw * _lgs2;

        draw_line_width(_lgcx, _lo_fy - 12, _lgcx - 9 * _lgs2, _lo_fy - 3, 2.5);
        draw_line_width(_lgcx, _lo_fy + 6, _lgcx - 9 * _lgs2, _lo_fy - 3, 2.5);
      }
    }
  }

  if (array_length(lorb_col_marks) > 0) {
    for (var _lmi = 0; _lmi < array_length(lorb_col_marks); _lmi++) {
      var _lm2 = lorb_col_marks[_lmi];
      var _lmp = clamp(1 - (_lm2.life / max(_lm2.max_life, 1)), 0, 1);
      var _lma = (0.22 + _lmp * 0.55) * (0.45 + lorb_amb * 0.7) * _lo_read_mult;
      var _lmcol = merge_color(_lo_base, c_white, _lmp * 0.8);

      draw_set_color(_lmcol);

      for (var _lmw = 0; _lmw < 2; _lmw++) {
        var _lmx = (_lmw == 0) ? _lm2.sx : _lm2.sx2;
        if (_lmx < 0) continue;

        var _lmj = sin(_lm2.seed + _lm2.life * 0.9) * 2 * (1 - _lmp);
        var _lmr = lerp(60, _k_lorb_spawn_band, _lmp);

        draw_set_alpha(_lma * 0.18);
        draw_line_width(_lmx + _lmj, 0, _lmx, _lmr, 8);
        draw_set_alpha(_lma * 0.7);
        draw_line_width(_lmx + _lmj, 0, _lmx, _lmr, 1.5);

        var _lmjw = lerp(22, 8, _lmp);

        draw_set_alpha(_lma * 0.9);
        draw_line_width(_lmx - _lmjw, _lmr, _lmx - _lmjw + 5, _lmr, 2);
        draw_line_width(_lmx + _lmjw - 5, _lmr, _lmx + _lmjw, _lmr, 2);
        draw_line_width(_lmx - _lmjw, _lmr - 5, _lmx - _lmjw, _lmr + 5, 2);
        draw_line_width(_lmx + _lmjw, _lmr - 5, _lmx + _lmjw, _lmr + 5, 2);

        if (_lm2.banded && _lm2.band > 1) {
          draw_set_alpha(_lma * 0.45);
          draw_line_width(_lmx - _lm2.band, _lmr - 3, _lmx - _lm2.band, _lmr + 3, 1.5);
          draw_line_width(_lmx + _lm2.band, _lmr - 3, _lmx + _lm2.band, _lmr + 3, 1.5);
        }
      }
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (DEBUG && _k_lorb_debug_counts && t >= _k_lorb_telegraph_t && t < 1340) {
  draw_set_alpha(1);
  draw_set_color(c_white);
  draw_text(12, 300, "t " + string(t) + "  eta " + string(lorb_eta) +
                     "\ncols " + string(array_length(lorb_columns)) +
                     "  marks " + string(array_length(lorb_col_marks)) +
                     "\nhits " + string(array_length(lorb_floor_hits)) +
                     "  scorch " + string(array_length(lorb_scorch)) +
                     "\namb " + string(lorb_amb) + "  read " + string(lorb_readout) +
                     "\nfront n" + string(lorb_front_n) + " a" + string(lorb_front_a) +
                     "  gap " + string(lorb_gap_w) + " @ " + string(lorb_gap_x_draw));
}

if (t >= _k_rain_start - 24 && t < 720) {
  var _rain_clear = clamp(1 - max(0, t - 682) / 8, 0, 1);
  var _rain_vis = max(rain_intensity, big_kunai_telegraph * 0.45);
  _rain_vis = max(_rain_vis, min(orbit_ribbon_heat * 0.2, 0.35)) * _rain_clear;

  if (_rain_vis > 0.01 || array_length(rain_source_slots) > 0 || instance_number(oKunaiWarning) > 0) {
    gpu_set_blendmode(bm_normal);

    var _rail_a = clamp(_rain_vis * 0.72 + rain_heartbeat * 0.35, 0, 0.7);
    var _rail_y = _k_rain_source_y;
    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_rail_a * 0.68);
    draw_rectangle(22, _rail_y - 13, room_width - 22, _rail_y + 5, false);

    draw_set_color(global.avoid_col_armor_mid);
    draw_set_alpha(_rail_a * 0.48);
    draw_line_width(30, _rail_y + 5, room_width - 30, _rail_y + 5, 2);
    draw_line_width(32, _rail_y - 11, room_width - 32, _rail_y - 11, 1);

    var _port_n = 10;
    for (var _rp = 0; _rp < _port_n; _rp++) {
      var _px = lerp(42, room_width - 42, (_rp + 0.5) / _port_n);
      var _tick = 0.45 + 0.55 * frac(abs(sin(_rp * 19.91 + 2.7)) * 31.13);
      draw_set_color(global.avoid_col_armor_edge);
      draw_set_alpha(_rail_a * (0.17 + _tick * 0.12));
      draw_line_width(_px - 9, _rail_y - 7, _px + 9, _rail_y - 7, 1);
      draw_line_width(_px - 13, _rail_y + 2, _px - 6, _rail_y + 2, 1);
      draw_line_width(_px + 6, _rail_y + 2, _px + 13, _rail_y + 2, 1);
    }

    for (var _rs = 0; _rs < array_length(rain_source_slots); _rs++) {
      var _slot = rain_source_slots[_rs];
      var _age_f = _slot.max_life - _slot.life;
      var _slot_fade = clamp(_slot.life / 10, 0, 1) * _rain_clear;
      var _fire = 1 - clamp(abs(_age_f - _slot.fire_at) / 9, 0, 1);
      var _warm = clamp(_slot.hot * 0.55 + _fire * 0.85 + rain_heartbeat * 0.45, 0, 1.2);
      var _sx = _slot.x;
      var _sy = _slot.y + sin(_slot.seed * 19.0 + _age_f * 0.5) * _fire * 1.2;
      var _sw = _k_rain_source_w + _warm * 8;
      var _sh = _k_rain_source_h + _warm * 4;
      var _sa = _slot_fade * (0.52 + _warm * 0.22);

      if (_sa <= 0.01) continue;

      draw_set_color(global.avoid_col_armor_dark);
      draw_set_alpha(_sa);
      draw_rectangle(_sx - _sw * 0.5, _sy - _sh, _sx + _sw * 0.5, _sy + _sh * 0.18, false);

      draw_set_color(merge_color(global.avoid_col_armor_mid, global.avoid_col_armor_edge, 0.28));
      draw_set_alpha(_sa * 0.82);
      draw_line_width(_sx - _sw * 0.5, _sy + 1, _sx + _sw * 0.5, _sy + 1, 1.4);
      draw_line_width(_sx - _sw * 0.44, _sy + 1, _sx - _sw * 0.23, _sy + 8 + _fire * 3, 1.8);
      draw_line_width(_sx + _sw * 0.44, _sy + 1, _sx + _sw * 0.23, _sy + 8 + _fire * 3, 1.8);

      draw_set_color(global.avoid_col_blood);
      draw_set_alpha(_sa * (0.26 + _warm * 0.18));
      draw_triangle(_sx, _sy + 12 + _fire * 4,
                    _sx - 4 - _fire * 2, _sy + 2,
                    _sx + 4 + _fire * 2, _sy + 2, false);
    }

    for (var _fs = 0; _fs < array_length(rain_floor_scars); _fs++) {
      var _scar = rain_floor_scars[_fs];
      var _sf = clamp(_scar.life / _scar.life_max, 0, 1) * _rain_clear;
      if (_sf <= 0.01) continue;

      var _swid = _scar.span * lerp(0.45, 1, 1 - _sf);
      var _j = sin(_scar.seed * 27.0 + _scar.life * 0.34) * 2.0;

      draw_set_color(c_black);
      draw_set_alpha(_sf * 0.22);
      draw_ellipse(_scar.x - _swid * 0.55, _scar.y - 4,
                   _scar.x + _swid * 0.55, _scar.y + 2, false);

      draw_set_color(global.avoid_col_blood);
      draw_set_alpha(_sf * 0.24);
      draw_line_width(_scar.x - _swid * 0.5, _scar.y + _j * 0.16,
                      _scar.x + _swid * 0.5, _scar.y - _j * 0.16, 2.2);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
  }

  gpu_set_blendmode(bm_add);

  if (rain_intensity > 0.02) {
    var _slide_e = rain_safe_slide * rain_safe_slide * (3 - 2 * rain_safe_slide);
    var _lane_x = lerp(rain_safe_x_prev, rain_safe_x, _slide_e);
    var _lane_hw = rain_safe_width * 0.5;
    var _lane_a = rain_intensity * (0.05 + rain_lane_flash * 0.09 + rain_heartbeat * 0.05);

    var _lane_bands = 12;
    draw_set_color(merge_color(global.lightning_color, c_white, 0.5));
    for (var _lb = 0; _lb < _lane_bands; _lb++) {
      var _lbt = _lb / _lane_bands;
      draw_set_alpha(_lane_a * (1 - _lbt * 0.8));
      draw_rectangle(_lane_x - _lane_hw, _lbt * _k_kunai_floor_y, _lane_x + _lane_hw,
                     ((_lb + 1) / _lane_bands) * _k_kunai_floor_y, false);
    }

    draw_set_color(c_white);
    draw_set_alpha(rain_intensity * (0.2 + rain_lane_flash * 0.5));
    draw_line_width(_lane_x - _lane_hw, 0, _lane_x - _lane_hw, _k_kunai_floor_y, 1.5);
    draw_line_width(_lane_x + _lane_hw, 0, _lane_x + _lane_hw, _k_kunai_floor_y, 1.5);
  }

  with (oKunaiWarning) {
    var _wp = 1 - (life / max(max_life, 1));
    var _wa = (0.32 + _wp * 0.62) * _rain_clear;
    var _wcol = merge_color(global.avoid_col_warning, global.avoid_col_hot, _wp * 0.55);
    var _wreach = lerp(other._k_rain_source_y + 52, impact_y, _wp);

    var _wj = sin(seed + life * 0.8) * 1.4 * (1 - _wp);
    var _seg_n = 6;
    var _seg_gap = lerp(6, 3, _wp);
    var _top_y = other._k_rain_source_y + 8;

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_wa * 0.16);
    draw_line_width(x + _wj, _top_y, x, _wreach, 6);

    for (var _ws = 0; _ws < _seg_n; _ws++) {
      var _sf = (_ws + 0.5) / _seg_n;
      var _sy0 = lerp(_top_y, _wreach, _sf) - _seg_gap;
      var _sy1 = lerp(_top_y, _wreach, _sf) + _seg_gap * lerp(0.6, 1.45, _wp);
      var _sa = _wa * (0.24 + _wp * 0.45) * (1 - _sf * 0.45);
      var _sxj = sin(seed * 2.0 + _ws * 1.7 + life * 0.45) * (1.2 + _wp * 1.4);

      draw_set_color(_wcol);
      draw_set_alpha(_sa);
      draw_line_width(x + _sxj, _sy0, x - _sxj * 0.35, _sy1, 1.4 + _wp * 0.8);

      if (_wp > 0.45 && _ws mod 2 == 0) {
        draw_set_color(global.avoid_col_hot);
        draw_set_alpha(_sa * (_wp - 0.35));
        draw_line_width(x + _sxj * 0.25, _sy1 - 2, x - _sxj * 0.15, _sy1 + 3, 1);
      }
    }

    draw_set_color(merge_color(_wcol, c_white, _wp * 0.35));
    draw_set_alpha(_wa * 0.78);
    draw_line_width(x + _wj, _top_y, x, min(_wreach, _top_y + 34 + _wp * 36), 1.2 + _wp);

    var _wr = lerp(25, 9, _wp);
    draw_set_alpha(_wa * 0.86);
    draw_line_width(x - _wr, impact_y, x + _wr, impact_y, 1.2);
    draw_line_width(x - _wr, impact_y - 5, x - _wr * 0.55, impact_y + 4, 1.2);
    draw_line_width(x + _wr, impact_y - 5, x + _wr * 0.55, impact_y + 4, 1.2);

    draw_set_color(c_white);
    draw_set_alpha(_wa * _wp * _wp * 0.55);
    draw_line_width(x, other._k_rain_source_y + 4, x, other._k_rain_source_y + 14, 1);
  }

  for (var _rs2 = 0; _rs2 < array_length(rain_source_slots); _rs2++) {
    var _slot2 = rain_source_slots[_rs2];
    var _age2 = _slot2.max_life - _slot2.life;
    var _fade2 = clamp(_slot2.life / 10, 0, 1) * _rain_clear;
    var _fire2 = 1 - clamp(abs(_age2 - _slot2.fire_at) / 8, 0, 1);
    var _warm2 = clamp(_slot2.hot * 0.45 + _fire2 + rain_heartbeat * 0.55, 0, 1.2);
    if (_fade2 <= 0.01 || _warm2 <= 0.03) continue;

    var _sx2 = _slot2.x;
    var _sy2 = _slot2.y;
    var _sw2 = _k_rain_source_w + _warm2 * 8;
    var _scol2 = merge_color(global.avoid_col_warning, global.avoid_col_hot, _warm2 * 0.42);

    draw_set_color(_scol2);
    draw_set_alpha(_fade2 * (0.16 + _warm2 * 0.4));
    draw_line_width(_sx2 - _sw2 * 0.24, _sy2 + 2, _sx2 + _sw2 * 0.24, _sy2 + 2,
                    1.2 + _warm2 * 1.8);

    draw_set_color(c_white);
    draw_set_alpha(_fade2 * _fire2 * _fire2 * 0.55);
    draw_circle(_sx2, _sy2 + 3, 1.2 + _fire2 * 2.8, false);
  }

  for (var _fs2 = 0; _fs2 < array_length(rain_floor_scars); _fs2++) {
    var _scar2 = rain_floor_scars[_fs2];
    var _sf2 = clamp(_scar2.life / _scar2.life_max, 0, 1) * _rain_clear;
    if (_sf2 <= 0.01) continue;

    var _swid2 = _scar2.span * lerp(0.55, 1, 1 - _sf2);
    var _scar_col = merge_color(global.avoid_col_warning, global.avoid_col_hot, _scar2.heat * 0.5);
    draw_set_color(_scar_col);
    draw_set_alpha(_sf2 * _scar2.heat * 0.38);
    draw_line_width(_scar2.x - _swid2 * 0.45, _scar2.y - 1,
                    _scar2.x + _swid2 * 0.45, _scar2.y - 1, 1.2 + _scar2.heat);
  }

  for (var _ki = 0; _ki < array_length(kunai_impacts); _ki++) {
    var _im = kunai_impacts[_ki];
    var _ia = _im.life / _im.max_life;
    var _icol = merge_color(c_red, c_white, _im.hot);

    draw_set_color(_icol);
    draw_set_alpha(_ia * _ia * 0.8);
    draw_ellipse_color(_im.x - _im.radius, _im.y - _im.radius * 0.35, _im.x + _im.radius,
                       _im.y + _im.radius * 0.35, _icol, _icol, true);

    draw_set_alpha(_ia * 0.3);
    draw_line_width(_im.x - _im.radius * 1.5, _im.y, _im.x + _im.radius * 1.5, _im.y, 3);
  }

  for (var _ksi = 0; _ksi < array_length(kunai_shards); _ksi++) {
    var _sh = kunai_shards[_ksi];
    var _sa = clamp(_sh.life / _sh.max_life, 0, 1);
    var _sang = _sh.ang + sin(_sh.phase + _sh.life * 0.55) * _sh.wobble;

    draw_sprite_ext(Sprite82, 0, _sh.x, _sh.y, _sh.scale, _sh.scale, _sang, merge_color(c_red, c_white, _sa * 0.4),
                    _sa * 0.85);
  }

  if (big_kunai_telegraph > 0.01) {
    var _bt = big_kunai_telegraph;
    var _btlead = 1 - _bt;
    var _btcol = merge_color(global.lightning_color, c_white, 0.35);

    draw_set_color(_btcol);
    for (var _br = 0; _br < 3; _br++) {
      var _bm = 1 + _btlead * (0.4 + _br * 0.5);
      draw_set_alpha(_bt * (0.45 - _br * 0.12));
      draw_ellipse(_k_orbit_cx - _k_orbit_rx * _bm, _k_orbit_cy - _k_orbit_ry * _bm,
                   _k_orbit_cx + _k_orbit_rx * _bm, _k_orbit_cy + _k_orbit_ry * _bm, true);
    }

    for (var _bp = 0; _bp < 2; _bp++) {
      var _bang = _bp * 180;
      var _bx = _k_orbit_cx + dcos(_bang) * _k_orbit_rx;
      var _by = _k_orbit_cy + dsin(_bang) * _k_orbit_ry;
      draw_set_color(c_white);
      draw_set_alpha(_bt * 0.9);
      draw_line_width(_bx, _by - 12, _bx, _by + 12, 1.5);
      draw_line_width(_bx - 12, _by, _bx + 12, _by, 1.5);
    }
  }

  if (orbit_ribbon_heat > 0.02) {
    var _oh = clamp(orbit_ribbon_heat, 0, 1.4);
    var _ocol = merge_color(global.lightning_color, c_white, clamp(_oh * 0.6, 0, 1));

    draw_set_color(_ocol);
    draw_set_alpha(_oh * 0.12);
    draw_ellipse(_k_orbit_cx - _k_orbit_rx, _k_orbit_cy - _k_orbit_ry, _k_orbit_cx + _k_orbit_rx,
                 _k_orbit_cy + _k_orbit_ry, true);

    draw_set_color(merge_color(_ocol, c_white, 0.5));
    draw_set_alpha(clamp(_oh * 0.5, 0, 1));

    var _osegs = 48;
    var _opx = _k_orbit_cx + _k_orbit_rx;
    var _opy = _k_orbit_cy;
    for (var _os = 1; _os <= _osegs; _os++) {
      var _oa = _os * (360 / _osegs);
      var _onx = _k_orbit_cx + dcos(_oa) * _k_orbit_rx;
      var _ony = _k_orbit_cy + dsin(_oa) * _k_orbit_ry;
      draw_line_width(_opx, _opy, _onx, _ony, 1 + _oh * 2);
      _opx = _onx;
      _opy = _ony;
    }
  }

  for (var _og = 0; _og < array_length(orbit_path_ghosts); _og++) {
    var _gp2 = orbit_path_ghosts[_og];
    var _gcol2 = merge_color(c_red, c_white, _gp2.hot);
    draw_set_color(_gcol2);
    draw_set_alpha(_gp2.alpha * 0.5);
    draw_line_width(_gp2.x + lengthdir_x(11 * _gp2.scale, _gp2.ang),
                    _gp2.y + lengthdir_y(11 * _gp2.scale, _gp2.ang),
                    _gp2.x - lengthdir_x(11 * _gp2.scale, _gp2.ang),
                    _gp2.y - lengthdir_y(11 * _gp2.scale, _gp2.ang), 2 + _gp2.scale * 2);
  }

  for (var _ap = 0; _ap < array_length(kunai_absorb_pops); _ap++) {
    var _pop = kunai_absorb_pops[_ap];
    var _popa = _pop.life / _pop.max_life;
    var _popr = lerp(46, 6, 1 - _popa);
    var _popcol = merge_color(c_red, c_white, _pop.hot);

    draw_set_color(_popcol);
    draw_set_alpha((1 - _popa) * 0.9);
    draw_circle(_pop.x, _pop.y, _popr, true);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(tree_shockwaves) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(tree_shockwaves); i++) {
    var _sw = tree_shockwaves[i];
    var _sw_color = (variable_struct_exists(_sw, "color")) ? _sw.color : c_white;
    scr_draw_smooth_ring_mask(_sw.x, _sw.y, _sw.radius, _sw.alpha * 0.8, 16, _sw_color);

    var _core_p = clamp(_sw.radius / 40, 0, 1);
    if (_core_p < 1) {
      draw_set_color(c_white);
      draw_set_alpha((1 - _core_p) * _sw.alpha);
      draw_circle(_sw.x, _sw.y, lerp(24, 0, _core_p), false);
    }
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(tree_crown_pulses) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _tcpi = 0; _tcpi < array_length(tree_crown_pulses); _tcpi++) {
    var _tcp0 = tree_crown_pulses[_tcpi];
    var _tcp_prog = clamp(_tcp0.timer / max(_tcp0.duration, 1), 0, 1);
    var _tcp_ease = 1 - power(1 - _tcp_prog, 2.6);
    var _tcp_fade = 1 - _tcp_prog;
    var _tcp_r = lerp(10, _tcp0.radius, _tcp_ease);
    var _tcp_w = lerp(_tcp0.width * 1.2, max(2, _tcp0.width * 0.25), _tcp_prog);
    var _tcp_col = variable_struct_exists(_tcp0, "color") ? _tcp0.color : global.tree_fire_color;
    var _tcp_hot = variable_struct_exists(_tcp0, "hot") ? _tcp0.hot : 0.5;
    var _tcp_a = _tcp_fade * _tcp_fade * (0.45 + _tcp_hot * 0.35);

    scr_draw_smooth_ring_mask(_tcp0.x, _tcp0.y, _tcp_r, _tcp_a, _tcp_w, _tcp_col);
    scr_draw_smooth_ring_mask(_tcp0.x, _tcp0.y, _tcp_r * 0.72, _tcp_a * 0.28, _tcp_w * 0.45,
                              merge_color(_tcp_col, c_white, 0.55));

    var _tcp_rot = current_time * (0.03 + _tcp_hot * 0.018) + _tcpi * 37;
    for (var _tcps = 0; _tcps < 6; _tcps++) {
      var _ang = _tcp_rot + _tcps * 60;
      var _r0 = _tcp_r * (0.72 + 0.05 * sin(current_time * 0.012 + _tcps));
      var _r1 = _tcp_r * (1.08 + 0.04 * _tcp_hot);
      draw_set_color(merge_color(_tcp_col, c_white, 0.35));
      draw_set_alpha(_tcp_a * 0.55);
      draw_line_width(_tcp0.x + lengthdir_x(_r0, _ang),
                      _tcp0.y + lengthdir_y(_r0, _ang),
                      _tcp0.x + lengthdir_x(_r1, _ang),
                      _tcp0.y + lengthdir_y(_r1, _ang), max(1, _tcp_w * 0.16));
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (t >= 1900 && t < 2025 && tree_crown_charge > 0.015) {
  var _cap = tree_crown_charge;
  var _cap_e = power(_cap, 1.65);
  var _cap_pulse = 0.5 + 0.5 * sin(current_time * lerp(0.018, 0.06, _cap));
  var _cap_r_outer = lerp(170, 42, _cap_e) + _cap_pulse * lerp(8, 2, _cap);
  var _cap_r_inner = max(12, _cap_r_outer * lerp(0.52, 0.32, _cap));
  var _cap_col = merge_color(global.avoid_col_cyan, global.tree_fire_color, clamp(_cap * 1.25, 0, 1));

  gpu_set_blendmode(bm_add);
  scr_draw_smooth_ring_mask(tree_crown_center_x, tree_crown_center_y, _cap_r_outer,
                            (0.10 + _cap * 0.32) * (0.75 + _cap_pulse * 0.25),
                            lerp(8, 18, _cap), _cap_col);
  scr_draw_smooth_ring_mask(tree_crown_center_x, tree_crown_center_y, _cap_r_inner,
                            0.08 + _cap * 0.26, lerp(4, 9, _cap),
                            merge_color(_cap_col, c_white, 0.55));

  var _tooth_count = 10;
  var _rot = current_time * lerp(0.018, 0.075, _cap);
  for (var _ct = 0; _ct < _tooth_count; _ct++) {
    var _ang = _rot + (_ct / _tooth_count) * 360;
    var _r0 = lerp(_cap_r_inner, _cap_r_outer, 0.58);
    var _r1 = _cap_r_outer + lerp(12, 28, _cap) * (0.65 + 0.35 * sin(current_time * 0.02 + _ct));
    draw_set_color((_ct mod 2 == 0) ? _cap_col : global.avoid_col_cyan);
    draw_set_alpha((0.13 + _cap * 0.32) * (1 - _ct / (_tooth_count * 1.8)));
    draw_line_width(tree_crown_center_x + lengthdir_x(_r0, _ang),
                    tree_crown_center_y + lengthdir_y(_r0, _ang),
                    tree_crown_center_x + lengthdir_x(_r1, _ang),
                    tree_crown_center_y + lengthdir_y(_r1, _ang),
                    lerp(1.2, 3.5, _cap));
  }

  draw_set_color(global.tree_fire_color);
  draw_set_alpha((0.12 + _cap * 0.35) * (0.65 + _cap_pulse * 0.35));
  draw_circle(tree_crown_center_x, tree_crown_center_y, lerp(18, 36, _cap), false);
  draw_set_color(c_white);
  draw_set_alpha(_cap * _cap * 0.42);
  draw_circle(tree_crown_center_x, tree_crown_center_y, lerp(5, 13, _cap), false);

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (t >= 1856
&& variable_instance_exists(id, "tree_data")
&& !is_undefined(tree_data)
&& is_struct(tree_data)
&& variable_struct_exists(tree_data, "nodes"))
{
    gpu_set_blendmode(bm_add);

    for (var tni = 0; tni < array_length(tree_data.nodes); tni++)
    {
        var _tn = tree_data.nodes[tni];

        if (!variable_struct_exists(_tn, "inst") || !instance_exists(_tn.inst))
            continue;

        var _par = _tn.parent;
        if (_par == -1)
            continue;

        var _par_node = tree_data.nodes[_par];

        if (!variable_struct_exists(_par_node, "inst") || !instance_exists(_par_node.inst))
            continue;

        var _child_inst = _tn.inst;
        var _par_inst = _par_node.inst;

        var _ax = _child_inst.x;
        var _ay = _child_inst.y;
        var _bx = _par_inst.x;
        var _by = _par_inst.y;

        var _conduit_alpha = min(_child_inst.image_alpha, _par_inst.image_alpha) * 0.3;

        if (_conduit_alpha > 0.01)
        {
            draw_set_color(merge_color(_child_inst.image_blend, _par_inst.image_blend, 0.5));
            draw_set_alpha(_conduit_alpha);
            draw_line_width(_ax, _ay, _bx, _by, 2);
        }

        if (_child_inst.state != 1)
            continue;

        var _amx = lerp(_ax, _bx, 0.5) + random_range(-4, 4);
        var _amy = lerp(_ay, _by, 0.5) + random_range(-4, 4);

        draw_set_color(merge_color(global.tree_fire_color, c_white, 0.35));
        draw_set_alpha(0.45);
        draw_line_width(_ax, _ay, _amx, _amy, 3);
        draw_line_width(_amx, _amy, _bx, _by, 3);

        draw_set_color(c_white);
        draw_set_alpha(0.8);
        draw_line_width(_ax, _ay, _amx, _amy, 1);
        draw_line_width(_amx, _amy, _bx, _by, 1);
    }

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (array_length(tree_branch_sparks) > 0
&& variable_instance_exists(id, "tree_data")
&& !is_undefined(tree_data)
&& is_struct(tree_data)
&& variable_struct_exists(tree_data, "nodes"))
{
  gpu_set_blendmode(bm_add);

  var _spark_node_count = array_length(tree_data.nodes);
  for (var _tbsi = 0; _tbsi < array_length(tree_branch_sparks); _tbsi++) {
    var _tbs0 = tree_branch_sparks[_tbsi];
    var _spark_node_i = _tbs0.node;
    if (_spark_node_i < 0 || _spark_node_i >= _spark_node_count) continue;

    var _spark_node = tree_data.nodes[_spark_node_i];
    var _spark_parent_i = _spark_node.parent;
    if (_spark_parent_i < 0 || _spark_parent_i >= _spark_node_count) continue;

    var _spark_parent = tree_data.nodes[_spark_parent_i];
    var _sx0 = _spark_parent.x;
    var _sy0 = _spark_parent.y;
    var _sx1 = _spark_node.x;
    var _sy1 = _spark_node.y;

    if (variable_struct_exists(_spark_parent, "inst") && instance_exists(_spark_parent.inst)) {
      _sx0 = _spark_parent.inst.x;
      _sy0 = _spark_parent.inst.y;
    }
    if (variable_struct_exists(_spark_node, "inst") && instance_exists(_spark_node.inst)) {
      _sx1 = _spark_node.inst.x;
      _sy1 = _spark_node.inst.y;
    }

    var _spark_life = clamp(_tbs0.life / max(_tbs0.life_max, 1), 0, 1);
    var _spark_prog = clamp(_tbs0.timer / max(_tbs0.life_max, 1), 0, 1);
    var _spark_head = clamp(_spark_prog * 1.18, 0, 1);
    var _spark_tail = clamp(_spark_head - (0.14 + _tbs0.hot * 0.12), 0, 1);
    var _spark_a = _spark_life * _spark_life * (0.45 + _tbs0.hot * 0.45);
    var _spark_col = merge_color(global.tree_fire_color, c_white, 0.22 + _tbs0.hot * 0.28);
    if (_tbs0.cyan) {
      _spark_col = merge_color(global.avoid_col_cyan, c_white, 0.25 + _tbs0.hot * 0.2);
    }

    var _tx0 = lerp(_sx0, _sx1, _spark_tail);
    var _ty0 = lerp(_sy0, _sy1, _spark_tail);
    var _tx1 = lerp(_sx0, _sx1, _spark_head);
    var _ty1 = lerp(_sy0, _sy1, _spark_head);
    var _spark_w = 1.6 + _tbs0.hot * 4.4;

    draw_set_color(_spark_col);
    draw_set_alpha(_spark_a * 0.38);
    draw_line_width(_tx0, _ty0, _tx1, _ty1, _spark_w * 2.2);
    draw_set_alpha(_spark_a * 0.78);
    draw_line_width(_tx0, _ty0, _tx1, _ty1, _spark_w);
    draw_set_color(c_white);
    draw_set_alpha(_spark_a);
    draw_line_width(_tx0, _ty0, _tx1, _ty1, max(0.8, _spark_w * 0.28));
    draw_circle(_tx1, _ty1, max(1.2, _spark_w * 0.55), false);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (t >= 1875 && t < tree_ignite_start_t) {
  var _pulse_reach = lerp(0, 14, clamp((t - 1875) / 20, 0, 1));
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _sap_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _sap_uvs[0], _sap_uvs[1], _sap_uvs[2], _sap_uvs[3]);
  for (var sni = 0; sni < array_length(tree_data.nodes); sni++) {
    var _sn = tree_data.nodes[sni];
    if (!variable_struct_exists(_sn, "inst") || !instance_exists(_sn.inst)) continue;
    var _sd = variable_struct_exists(_sn, "spawn_delay") ? _sn.spawn_delay : 0;
    var _band = abs(_sd - _pulse_reach);
    if (_band > 1.2) continue;
    var _wave_alpha = 1 - (_band / 1.2);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _wave_alpha * 1.5);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, _sn.inst.x, _sn.inst.y, 0.4, 0.4, 0, c_white, 1);
  }
  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

var _ember_k_color = make_color_rgb(255, 90, 40);
var _ember_k_hot = make_color_rgb(255, 190, 110);
var _ember_cx = 400, _ember_cy = 304;
var _seed_cocoon_count = 0;
var _seed_cocoon_radius = 0;
var _seed_cocoon_flash = 0;
var _seed_cocoon_release = 0;
var _seed_cocoon_objects = instance_number(oRedOrb_2);
for (var _sci = 0; _sci < _seed_cocoon_objects; _sci++) {
  var _seed_orb = instance_find(oRedOrb_2, _sci);
  if (!instance_exists(_seed_orb)) continue;
  if (!variable_instance_exists(_seed_orb, "fruit_seed_contained")) continue;
  if (!_seed_orb.fruit_seed_visual || !_seed_orb.ember_glow_core) continue;
  if (!_seed_orb.fruit_seed_contained || _seed_orb.ember_ring_launched) continue;

  _seed_cocoon_count += 1;
  _seed_cocoon_radius += point_distance(_ember_cx, _ember_cy, _seed_orb.x, _seed_orb.y);
  _seed_cocoon_flash = max(_seed_cocoon_flash, _seed_orb.fruit_seed_containment_flash);
  _seed_cocoon_release = max(_seed_cocoon_release, _seed_orb.fruit_seed_release_flash);
}

if (_seed_cocoon_count > 0) {
  var _seed_cocoon_r = _seed_cocoon_radius / _seed_cocoon_count;
  var _seed_cocoon_pulse = 0.5 + 0.5 * sin(current_time * 0.024);
  var _seed_cocoon_a = clamp(0.52 + _seed_cocoon_flash * 0.24 + _seed_cocoon_release * 0.28, 0, 1);
  var _seed_cocoon_col = merge_color(global.avoid_col_cyan_soft, c_white, 0.18 + _seed_cocoon_release * 0.16);
  var _seed_cocoon_deep = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, 0.74);

  gpu_set_blendmode(bm_add);
  draw_set_color(_seed_cocoon_deep);
  draw_set_alpha(_seed_cocoon_a * 0.16);
  draw_circle_color(_ember_cx, _ember_cy, _seed_cocoon_r + 34 + _seed_cocoon_pulse * 5,
                    _seed_cocoon_col, _seed_cocoon_deep, false);

  scr_draw_smooth_ring_mask(_ember_cx, _ember_cy, _seed_cocoon_r + 6 + _seed_cocoon_pulse * 2,
                            _seed_cocoon_a * 0.48, 18, _seed_cocoon_col);
  scr_draw_smooth_ring_mask(_ember_cx, _ember_cy, max(18, _seed_cocoon_r - 20),
                            _seed_cocoon_a * 0.28, 10, global.avoid_col_cyan);

  for (var _scri = 0; _scri < 8; _scri++) {
    var _sca = current_time * 0.012 + _scri * 45;
    var _sr0 = max(18, _seed_cocoon_r * 0.28);
    var _sr1 = _seed_cocoon_r + 18 + sin(current_time * 0.018 + _scri) * 5;
    draw_set_color(_seed_cocoon_col);
    draw_set_alpha(_seed_cocoon_a * 0.16);
    draw_line_width(_ember_cx + lengthdir_x(_sr0, _sca),
                    _ember_cy + lengthdir_y(_sr0, _sca),
                    _ember_cx + lengthdir_x(_sr1, _sca + 9),
                    _ember_cy + lengthdir_y(_sr1, _sca + 9), 1.6);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ember_coil_pulses) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _cpi = 0; _cpi < array_length(ember_coil_pulses); _cpi++) {
    var _cp = ember_coil_pulses[_cpi];
    var _cp_prog = 1 - (_cp.life / _cp.life_max);
    var _cp_r = lerp(4, _cp.radius, _cp_prog);
    var _cp_a = _cp.alpha * (_cp.life / _cp.life_max);
    scr_draw_smooth_ring_mask(_ember_cx, _ember_cy, _cp_r, _cp_a, 6, _ember_k_color);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(ember_crush_rings) > 0 || ember_crush_heat > 0.01) {
  gpu_set_blendmode(bm_add);

  for (var _cri = 0; _cri < array_length(ember_crush_rings); _cri++) {
    var _cr2 = ember_crush_rings[_cri];
    scr_draw_smooth_ring_mask(_ember_cx, _ember_cy, _cr2.radius, _cr2.alpha, _cr2.band,
                              merge_color(_ember_k_color, c_white, 0.35));
  }

  if (ember_crush_heat > 0.01) {
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _crush_uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _crush_uvs[0], _crush_uvs[1], _crush_uvs[2], _crush_uvs[3]);

    var _crush_beat = 0.75 + 0.25 * sin(current_time * (0.012 + ember_crush_heat * 0.02));
    shader_set_uniform_f(global.u_glow_color, 1, color_get_green(_ember_k_color) / 255,
                         color_get_blue(_ember_k_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, ember_crush_heat * 1.5 * _crush_beat);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _ember_cx, _ember_cy, 0.7 + ember_crush_heat * 1.1,
                    0.7 + ember_crush_heat * 1.1, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, ember_crush_heat * 2.0 * _crush_beat);
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    draw_sprite_ext(spr_glow_blob, 0, _ember_cx, _ember_cy, 0.2 + ember_crush_heat * 0.35,
                    0.2 + ember_crush_heat * 0.35, 0, c_white, 1);

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
  }

  gpu_set_blendmode(bm_normal);
}

if (ember_burst_flash > 0) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _ember_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _ember_uvs[0], _ember_uvs[1], _ember_uvs[2], _ember_uvs[3]);

  shader_set_uniform_f(global.u_glow_color, 1, color_get_green(_ember_k_hot) / 255, color_get_blue(_ember_k_hot) / 255);
  shader_set_uniform_f(global.u_glow_intensity, ember_burst_flash * 2.6);
  shader_set_uniform_f(global.u_glow_falloff, 1.3);
  draw_sprite_ext(spr_glow_blob, 0, _ember_cx, _ember_cy, 1.6 + (1 - ember_burst_flash) * 2.2,
                  1.6 + (1 - ember_burst_flash) * 2.2, 0, c_white, 1);

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, ember_burst_flash * 3.2);
  shader_set_uniform_f(global.u_glow_falloff, 2.4);
  draw_sprite_ext(spr_glow_blob, 0, _ember_cx, _ember_cy, 0.6 + (1 - ember_burst_flash) * 0.6,
                  0.6 + (1 - ember_burst_flash) * 0.6, 0, c_white, 1);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ember_burst_rings) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _bri = 0; _bri < array_length(ember_burst_rings); _bri++) {
    var _br2 = ember_burst_rings[_bri];
    if (_br2.delay > 0) continue;
    var _br2_color = variable_struct_exists(_br2, "color") ? _br2.color : merge_color(_ember_k_color, c_white, 0.3);
    if (variable_struct_exists(_br2, "hc_front") && _br2.hc_front) {
      var _hc_ring_phase = variable_struct_exists(_br2, "phase") ? _br2.phase : 0;
      var _hc_ring_start = _hc_ring_phase * 90 - (_k_hc_front_arc_span - 180) * 0.5;
      var _hc_ring_n = 24;
      for (var _hc_rs = 0; _hc_rs < _hc_ring_n; _hc_rs++) {
        var _hc_rh = frac(sin((_hc_ring_phase + 1) * 29.17 + _hc_rs * 12.41) * 43758.5453);
        if (_hc_rh < 0.20) continue;
        var _hc_rf0 = _hc_rs / _hc_ring_n;
        var _hc_rf1 = min(1, (_hc_rs + 0.62 + _hc_rh * 0.18) / _hc_ring_n);
        var _hc_ra0 = _hc_ring_start + _k_hc_front_arc_span * _hc_rf0;
        var _hc_ra1 = _hc_ring_start + _k_hc_front_arc_span * _hc_rf1;
        var _hc_rr0 = _br2.radius + (_hc_rh - 0.5) * 7;
        var _hc_rr1 = _br2.radius + (frac(sin((_hc_ring_phase + 3) * 47.2 + _hc_rs * 18.8) * 43758.5453) - 0.5) * 7;

        draw_set_color(merge_color(_br2_color, c_white, 0.16 + _hc_rh * 0.12));
        draw_set_alpha(_br2.alpha * 0.18 * (0.55 + _hc_rh * 0.45));
        draw_line_width(_ember_cx + lengthdir_x(_hc_rr0, _hc_ra0),
                        _ember_cy + lengthdir_y(_hc_rr0, _hc_ra0),
                        _ember_cx + lengthdir_x(_hc_rr1, _hc_ra1),
                        _ember_cy + lengthdir_y(_hc_rr1, _hc_ra1),
                        max(2, _br2.band * 0.18));
      }
    } else {
      scr_draw_smooth_ring_mask(_ember_cx, _ember_cy, _br2.radius, _br2.alpha, _br2.band, _br2_color);
    }
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(ember_drip_particles) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _dpi = 0; _dpi < array_length(ember_drip_particles); _dpi++) {
    var _dp2 = ember_drip_particles[_dpi];
    var _dp_a = clamp(_dp2.life / _dp2.life_max, 0, 1);
    var _dp_col = variable_struct_exists(_dp2, "color") ? _dp2.color : _ember_k_color;
    var _dp_hot_col = variable_struct_exists(_dp2, "hot_color") ? _dp2.hot_color : _ember_k_hot;
    draw_set_color(merge_color(_dp_col, _dp_hot_col, _dp_a));
    draw_set_alpha(_dp_a * 0.9);
    draw_circle(_dp2.x, _dp2.y, _dp2.size * _dp_a, false);
    draw_set_color(c_white);
    draw_set_alpha(_dp_a * 0.6);
    draw_circle(_dp2.x, _dp2.y, _dp2.size * 0.4 * _dp_a, false);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ember_edge_glows) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _wi = 0; _wi < array_length(ember_edge_glows); _wi++) {
    var _wg = ember_edge_glows[_wi];
    if (!instance_exists(_wg.bullet_id)) continue;

    var _wfade = _wg.fading ? clamp(_wg.life / 12, 0, 1) : 1;
    var _wrange = (_wg.start_dist > 0) ? _wg.start_dist : _k_incoming_warn_range;
    var _wraw = clamp(1 - (_wg.mark_dist / _wrange), 0, 1);
    var _whot = max(power(_wraw, 1.6),
                    lerp(_k_incoming_warn_floor, 1, power(_wraw, 1.15)));
    var _wa = _whot * _wfade;
    if (_wa <= 0.01) continue;

    var _wx = _wg.mark_x;
    var _wy = _wg.mark_y;
    var _wdir = _wg.mark_dir;
    var _wpulse = 0.62 + 0.38 * sin(current_time * 0.02 + _wi * 1.7);

    var _wr = lerp(_k_incoming_warn_box_far, _k_incoming_warn_box_near, _whot);
    scr_draw_lock_bracket(_wx - _wr, _wy - _wr, _wx + _wr, _wy + _wr,
                          global.avoid_col_warning, _whot, _wa,
                          _k_incoming_warn_tick, false, 2, _wdir, _wpulse,
                          global.avoid_col_cyan);

    var _wchevrons = 1 + round(_wraw * (_k_incoming_warn_chevrons_max - 1));

    var _wcol = merge_color(global.avoid_col_warning, c_white, _whot * 0.55);
    var _wspacing = lerp(28, 14, _whot);
    for (var _wc = 0; _wc < _wchevrons; _wc++) {
      var _wcd = _wr + 9 + _wc * _wspacing;
      var _wcx = _wx + lengthdir_x(_wcd, _wdir);
      var _wcy = _wy + lengthdir_y(_wcd, _wdir);
      var _wcs = 9 + _whot * 7;
      draw_set_color(_wcol);
      draw_set_alpha(_wa * (1 - _wc / _wchevrons) * 0.9);
      draw_line_width(_wcx + lengthdir_x(_wcs, _wdir + 138), _wcy + lengthdir_y(_wcs, _wdir + 138),
                      _wcx, _wcy, 3);
      draw_line_width(_wcx, _wcy,
                      _wcx + lengthdir_x(_wcs, _wdir - 138), _wcy + lengthdir_y(_wcs, _wdir - 138), 3);
    }

    var _wfr = 1.5 + _whot * 4;
    draw_set_alpha(_wa * (0.18 + _whot * 0.32));
    draw_set_color(c_red);
    draw_circle(_wx + lengthdir_x(_wfr, _wdir + 90), _wy + lengthdir_y(_wfr, _wdir + 90),
                2 + _whot * 3, false);
    draw_set_color(global.avoid_col_cyan);
    draw_circle(_wx - lengthdir_x(_wfr, _wdir + 90), _wy - lengthdir_y(_wfr, _wdir + 90),
                2 + _whot * 3, false);

    draw_set_color(c_white);
    draw_set_alpha(_wa * (0.5 + _whot * 0.5) * _wpulse);
    draw_circle(_wx, _wy, 2 + _whot * 4, false);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

var _fin_col = finale_lightning_col;
var _fin_hot = finale_lightning_hot;

if (array_length(finale_motes) > 0) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _mote_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _mote_uvs[0], _mote_uvs[1], _mote_uvs[2], _mote_uvs[3]);
  for (var _fmi = 0; _fmi < array_length(finale_motes); _fmi++) {
    var _fm = finale_motes[_fmi];
    var _fm_p = clamp(_fm.life / _fm.life_max, 0, 1);
    var _fm_eased = _fm_p * _fm_p;
    var _fm_x = lerp(_fm.x, 400, _fm_eased);
    var _fm_y = lerp(_fm.y, 304, _fm_eased);
    shader_set_uniform_f(global.u_glow_color, color_get_red(_fin_col) / 255, color_get_green(_fin_col) / 255,
                         color_get_blue(_fin_col) / 255);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.5, 1.6, _fm_eased));
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, _fm_x, _fm_y, 0.22, 0.22, 0, c_white, 1);
  }
  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (finale_seed_alpha > 0) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _seed_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _seed_uvs[0], _seed_uvs[1], _seed_uvs[2], _seed_uvs[3]);

  shader_set_uniform_f(global.u_glow_color, color_get_red(_fin_col) / 255, color_get_green(_fin_col) / 255,
                       color_get_blue(_fin_col) / 255);
  shader_set_uniform_f(global.u_glow_intensity, 1.2 * finale_seed_alpha);
  shader_set_uniform_f(global.u_glow_falloff, 1.6);
  draw_sprite_ext(spr_glow_blob, 0, 400, 304, 0.5 + finale_seed_alpha * 0.6, 0.5 + finale_seed_alpha * 0.6, 0, c_white, 1);

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, 1.6 * finale_seed_alpha);
  shader_set_uniform_f(global.u_glow_falloff, 2.2);
  draw_sprite_ext(spr_glow_blob, 0, 400, 304, 0.2 + finale_seed_alpha * 0.3, 0.2 + finale_seed_alpha * 0.3, 0, c_white, 1);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);

  finale_seed_alpha = max(0, finale_seed_alpha - 0.03);
}

if (array_length(finale_coil_pulses) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _fpi = 0; _fpi < array_length(finale_coil_pulses); _fpi++) {
    var _fp = finale_coil_pulses[_fpi];
    var _fp_prog = 1 - (_fp.life / _fp.life_max);
    var _fp_r = lerp(4, _fp.radius, _fp_prog);
    var _fp_a = _fp.alpha * (_fp.life / _fp.life_max);
    scr_draw_smooth_ring_mask(400, 304, _fp_r, _fp_a, 6, _fin_col);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(finale_impact_cracks) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _fci = 0; _fci < array_length(finale_impact_cracks); _fci++) {
    var _fc = finale_impact_cracks[_fci];
    var _fc_a = clamp(_fc.life / _fc.life_max, 0, 1);
    var _fc_grow = 1 - power(1 - clamp(1 - _fc_a, 0, 1), 3);
    var _fc_len = _fc.len * _fc_grow;

    var _fc_mid_x = _fc.x + lengthdir_x(_fc_len * 0.55, _fc.ang);
    var _fc_mid_y = _fc.y + lengthdir_y(_fc_len * 0.55, _fc.ang);
    var _fc_mid_x2 = _fc_mid_x + lengthdir_x(_fc_len * 0.12, _fc.ang + 90);
    var _fc_mid_y2 = _fc_mid_y + lengthdir_y(_fc_len * 0.12, _fc.ang + 90);
    var _fc_end_x = _fc.x + lengthdir_x(_fc_len, _fc.ang);
    var _fc_end_y = _fc.y + lengthdir_y(_fc_len, _fc.ang);

    draw_set_color(_fin_col);
    draw_set_alpha(_fc_a * 0.5);
    draw_line_width(_fc.x, _fc.y, _fc_mid_x2, _fc_mid_y2, 5);
    draw_line_width(_fc_mid_x2, _fc_mid_y2, _fc_end_x, _fc_end_y, 3.5);
    draw_set_color(c_white);
    draw_set_alpha(_fc_a * 0.85);
    draw_line_width(_fc.x, _fc.y, _fc_mid_x2, _fc_mid_y2, 2);
    draw_line_width(_fc_mid_x2, _fc_mid_y2, _fc_end_x, _fc_end_y, 1.4);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(finale_drip_particles) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _fdi = 0; _fdi < array_length(finale_drip_particles); _fdi++) {
    var _fd2 = finale_drip_particles[_fdi];
    var _fd_a = clamp(_fd2.life / _fd2.life_max, 0, 1);
    draw_set_color(merge_color(_fin_col, _fin_hot, _fd_a));
    draw_set_alpha(_fd_a * 0.9);
    draw_circle(_fd2.x, _fd2.y, _fd2.size * _fd_a, false);
    draw_set_color(c_white);
    draw_set_alpha(_fd_a * 0.6);
    draw_circle(_fd2.x, _fd2.y, _fd2.size * 0.4 * _fd_a, false);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(finale_ground_strikes) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _gsi = 0; _gsi < array_length(finale_ground_strikes); _gsi++) {
    var _gs2 = finale_ground_strikes[_gsi];
    if (!_gs2.struck) {
      var _gs_p = 1 - (_gs2.timer / _gs2.duration);
      var _gs_r = lerp(_gs2.radius * 1.6, _gs2.radius, _gs_p);
      var _gs_pulse = 0.7 + 0.3 * sin(current_time * 0.03 * (1 + _gs_p * 2));
      var _gs_col = merge_color(_fin_col, c_white, _gs_p);
      scr_draw_smooth_ring_mask(_gs2.x, _gs2.y, _gs_r, (0.4 + _gs_p * 0.5) * _gs_pulse, 4, _gs_col);
      for (var _tk = 0; _tk < 4; _tk++) {
        var _tk_ang = _tk * 90 + 45;
        var _tk_x1 = _gs2.x + lengthdir_x(_gs_r + 4, _tk_ang);
        var _tk_y1 = _gs2.y + lengthdir_y(_gs_r + 4, _tk_ang);
        var _tk_x2 = _gs2.x + lengthdir_x(_gs_r + 14, _tk_ang);
        var _tk_y2 = _gs2.y + lengthdir_y(_gs_r + 14, _tk_ang);
        draw_set_color(_gs_col);
        draw_set_alpha((0.5 + _gs_p * 0.5) * _gs_pulse);
        draw_line_width(_tk_x1, _tk_y1, _tk_x2, _tk_y2, 2);
      }

      var _k_rain_count = 5;
      for (var _ri = 0; _ri < _k_rain_count; _ri++) {
        var _rain_speed = lerp(0.008, 0.025, _gs_p);
        var _rain_t = frac(current_time * _rain_speed + _ri * 0.21);
        var _rain_x = _gs2.x + (_ri - (_k_rain_count - 1) * 0.5) * (_gs_r * 0.35 + 6);
        var _rain_y2 = (_gs2.y - _gs_r - 30) + _rain_t * (_gs_r + 30);
        var _rain_y1 = _rain_y2 - 16;
        draw_set_color(_gs_col);
        draw_set_alpha((0.25 + _gs_p * 0.45) * _gs_pulse * (1 - _rain_t * 0.6));
        draw_line_width(_rain_x, _rain_y1, _rain_x, _rain_y2, 2);
      }
    } else {
      var _gs_fade = 1 - (_gs2.struck_timer / 14);
      draw_set_color(c_white);
      draw_set_alpha(_gs_fade * 0.7);
      draw_circle(_gs2.x, _gs2.y, _gs2.radius * (1 + (1 - _gs_fade) * 0.3), false);
    }
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(finale_railgun_beams) > 0) {
  for (var _rgi2 = 0; _rgi2 < array_length(finale_railgun_beams); _rgi2++) {
    var _rg2 = finale_railgun_beams[_rgi2];
    var _rg_dir = point_direction(_rg2.x1, _rg2.y1, _rg2.x2, _rg2.y2);

    if (_rg2.state == 0) {
      var _rg_p = 1 - (_rg2.timer / _rg2.warn_duration);
      var _rg_pulse = 0.7 + 0.3 * sin(current_time * (0.03 + _rg_p * 0.15));
      var _rg_alpha = (0.2 + _rg_p * 0.5) * _rg_pulse;

      gpu_set_blendmode(bm_add);
      draw_set_color(_fin_col);
      draw_set_alpha(_rg_alpha);
      draw_line_width(_rg2.x1, _rg2.y1, _rg2.x2, _rg2.y2, 1.5 + _rg_p * 1.5);

      var _rg_perp = _rg_dir + 90;
      var _k_ticks = 14;
      for (var _tki = 1; _tki < _k_ticks; _tki++) {
        var _tk_x = lerp(_rg2.x1, _rg2.x2, _tki / _k_ticks);
        var _tk_y = lerp(_rg2.y1, _rg2.y2, _tki / _k_ticks);
        draw_set_alpha(_rg_alpha * 0.6);
        draw_line_width(_tk_x - lengthdir_x(4, _rg_perp), _tk_y - lengthdir_y(4, _rg_perp),
                        _tk_x + lengthdir_x(4, _rg_perp), _tk_y + lengthdir_y(4, _rg_perp), 1.5);
      }

      var _scan_t = frac(current_time * lerp(0.006, 0.02, _rg_p) + _rgi2 * 0.37);
      var _scan_x = lerp(_rg2.x1, _rg2.x2, _scan_t);
      var _scan_y = lerp(_rg2.y1, _rg2.y2, _scan_t);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      var _rg_uvs2 = sprite_get_uvs(spr_glow_blob, 0);
      shader_set_uniform_f(global.u_glow_uvrect, _rg_uvs2[0], _rg_uvs2[1], _rg_uvs2[2], _rg_uvs2[3]);
      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, (0.8 + _rg_p * 1.2) * _rg_pulse);
      shader_set_uniform_f(global.u_glow_falloff, 2.0);
      draw_sprite_ext(spr_glow_blob, 0, _scan_x, _scan_y, 0.25 + _rg_p * 0.2, 0.25 + _rg_p * 0.2, 0, c_white, 1);
      shader_reset();
      gpu_set_blendequation(bm_eq_add);
      gpu_set_blendmode(bm_normal);
    } else {
      var _rg_fp = _rg2.timer / _rg2.fire_duration;

      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      var _rg_uvs3 = sprite_get_uvs(spr_glow_blob, 0);
      shader_set_uniform_f(global.u_glow_uvrect, _rg_uvs3[0], _rg_uvs3[1], _rg_uvs3[2], _rg_uvs3[3]);
      shader_set_uniform_f(global.u_glow_color, color_get_red(_fin_col) / 255, color_get_green(_fin_col) / 255,
                           color_get_blue(_fin_col) / 255);
      shader_set_uniform_f(global.u_glow_intensity, 0.9 + _rg_fp * 0.8);
      shader_set_uniform_f(global.u_glow_falloff, 1.5);
      var _k_beam_samples = 16;
      for (var _bsi = 0; _bsi <= _k_beam_samples; _bsi++) {
        var _bs_x = lerp(_rg2.x1, _rg2.x2, _bsi / _k_beam_samples);
        var _bs_y = lerp(_rg2.y1, _rg2.y2, _bsi / _k_beam_samples);
        draw_sprite_ext(spr_glow_blob, 0, _bs_x, _bs_y, 0.5, 0.5, 0, c_white, 1);
      }
      shader_reset();
      gpu_set_blendequation(bm_eq_add);
      gpu_set_blendmode(bm_normal);

      gpu_set_blendmode(bm_add);
      var _rg_perp2 = _rg_dir + 90;
      var _rg_off2 = 4;
      draw_set_color(global.avoid_col_danger);
      draw_set_alpha(0.35);
      draw_line_width(_rg2.x1 + lengthdir_x(_rg_off2, _rg_perp2), _rg2.y1 + lengthdir_y(_rg_off2, _rg_perp2),
                      _rg2.x2 + lengthdir_x(_rg_off2, _rg_perp2), _rg2.y2 + lengthdir_y(_rg_off2, _rg_perp2),
                      _rg2.width * 0.4);
      draw_set_color(global.avoid_col_cyan);
      draw_line_width(_rg2.x1 - lengthdir_x(_rg_off2, _rg_perp2), _rg2.y1 - lengthdir_y(_rg_off2, _rg_perp2),
                      _rg2.x2 - lengthdir_x(_rg_off2, _rg_perp2), _rg2.y2 - lengthdir_y(_rg_off2, _rg_perp2),
                      _rg2.width * 0.4);

      draw_set_color(_fin_col);
      draw_set_alpha(0.5 * _rg_fp + 0.2);
      draw_line_width(_rg2.x1, _rg2.y1, _rg2.x2, _rg2.y2, _rg2.width * 1.6);
      draw_set_color(c_white);
      draw_set_alpha(0.9);
      draw_line_width(_rg2.x1, _rg2.y1, _rg2.x2, _rg2.y2, _rg2.width * 0.5);
      draw_set_alpha(1);
      draw_set_color(c_white);
      gpu_set_blendmode(bm_normal);
    }
  }
}

var _shield_break_age = t - _k_containment_shield_break_t;
var _shield_break_active = (_shield_break_age >= 0 && _shield_break_age < _k_containment_shield_cut_life);
var _shield_break_p = (_shield_break_age >= 0) ? clamp(_shield_break_age / max(_k_containment_shield_cut_life, 1), 0, 1) : 0;
var _shield_a = 0;
if (t < _k_containment_shield_break_t) {
  _shield_a = 1;
} else if (_shield_break_active) {
  var _shield_fail_flicker = 0.35 + 0.65 * power(0.5 + 0.5 * sin(t * 1.7), 2);
  _shield_a = max(0, 1 - _shield_break_age / 14) * _shield_fail_flicker;
}

var _shield_draw_active = (_shield_a > 0.02) || _shield_break_active ||
                          array_length(containment_shield_shards) > 0 ||
                          array_length(containment_shield_fractures) > 0 ||
                          containment_shield_flash > 0.01;

if (_shield_draw_active) {
  var _sh_l = _k_ring_arena_pad;
  var _sh_r = room_width - _k_ring_arena_pad;
  var _sh_t = _k_ring_arena_pad;
  var _sh_b = _k_ring_floor_y;
  var _sh_time = t / max(room_speed, 1);
  var _sh_ring_window = clamp(1 - max(0, t - (_k_ring_cleanup_t + 45)) / 170, 0, 1);
  var _sh_lift_wake = clamp((t - (_k_er_lift_charge_t - 230)) / 230, 0, 1);
  var _sh_ring_heat = clamp(ring_ambient * 0.9 + ring_sector_flash * 0.34 + ring_heartbeat * 0.24 +
                            ring_coil_amount * 0.38 + ring_wound * 0.22 + ring_lock_flash * 0.06, 0, 1.35);
  var _sh_hum = clamp(0.12 + bass_visual * 0.08 + floor_beat * 0.08 + _sh_lift_wake * 0.18 +
                      _sh_ring_heat * (0.42 + _sh_ring_window * 0.44), 0, 1.25);
  var _sh_alpha = _shield_a * (0.45 + _sh_hum * 0.34);
  var _sh_col = merge_color(_k_er_col_cyan, c_white, 0.18 + _sh_ring_heat * 0.22);
  var _sh_hot = merge_color(_k_er_col_warning, c_white, 0.18 + _sh_ring_heat * 0.18);
  var _sh_edge_col = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.22 + _sh_hum * 0.24);
  var _sh_core_col = merge_color(_k_er_col_cyan, c_white, 0.56);

  var _sh_support_pad_x = 270;
  var _sh_support_pad_y = 210;
  if (instance_exists(oCameraController) && oCameraController.current_cam_w > 0) {
    _sh_support_pad_x = max(_sh_support_pad_x, (oCameraController.current_cam_w - room_width) * 0.5 + 120);
    _sh_support_pad_y = max(_sh_support_pad_y, (oCameraController.current_cam_h - room_height) * 0.5 + 120);
  }

  var _sh_world_l = -_sh_support_pad_x;
  var _sh_world_r = room_width + _sh_support_pad_x;
  var _sh_world_t = -_sh_support_pad_y;
  var _sh_anchor_b = _sh_b + 132;
  var _sh_support_a = _shield_a * (0.42 + _sh_hum * 0.16);
  var _sh_support_dark = merge_color(c_black, _k_er_col_armor_dark, 0.48);
  var _sh_support_mid = merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.56);
  var _sh_support_hi = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.28 + _sh_hum * 0.08);

  if (false) {
  draw_set_color(_sh_support_dark);
  draw_set_alpha(_sh_support_a * 0.72);
  draw_rectangle(_sh_world_l, _sh_t - 76, _sh_l - 34, _sh_anchor_b, false);
  draw_rectangle(_sh_r + 34, _sh_t - 76, _sh_world_r, _sh_anchor_b, false);
  draw_rectangle(_sh_l - 92, _sh_world_t + 54, _sh_r + 92, _sh_t - 16, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_world_l, _sh_t - 76, _sh_support_mid, _sh_support_a * 0.52);
  draw_vertex_colour(_sh_l - 34, _sh_t - 76, _sh_support_dark, _sh_support_a * 0.68);
  draw_vertex_colour(_sh_world_l, _sh_anchor_b, merge_color(c_black, _k_er_col_armor_dark, 0.30), _sh_support_a * 0.72);
  draw_vertex_colour(_sh_l - 34, _sh_anchor_b, _sh_support_dark, _sh_support_a * 0.78);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_r + 34, _sh_t - 76, _sh_support_dark, _sh_support_a * 0.68);
  draw_vertex_colour(_sh_world_r, _sh_t - 76, _sh_support_mid, _sh_support_a * 0.52);
  draw_vertex_colour(_sh_r + 34, _sh_anchor_b, _sh_support_dark, _sh_support_a * 0.78);
  draw_vertex_colour(_sh_world_r, _sh_anchor_b, merge_color(c_black, _k_er_col_armor_dark, 0.30), _sh_support_a * 0.72);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_l - 92, _sh_world_t + 54, merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.20), _sh_support_a * 0.58);
  draw_vertex_colour(_sh_r + 92, _sh_world_t + 54, merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.20), _sh_support_a * 0.58);
  draw_vertex_colour(_sh_l - 62, _sh_t - 16, _sh_support_dark, _sh_support_a * 0.82);
  draw_vertex_colour(_sh_r + 62, _sh_t - 16, _sh_support_dark, _sh_support_a * 0.82);
  draw_primitive_end();

  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.22));
  draw_set_alpha(_shield_a * 0.62);
  for (var _bay_side = 0; _bay_side < 2; _bay_side++) {
    var _bay_l = (_bay_side == 0) ? _sh_world_l + 18 : _sh_r + 54;
    var _bay_r = (_bay_side == 0) ? _sh_l - 54 : _sh_world_r - 18;
    if (_bay_r <= _bay_l) continue;

    var _bay_w = _bay_r - _bay_l;
    var _bay_count = max(2, ceil(_bay_w / 86));
    for (var _bay = 0; _bay < _bay_count; _bay++) {
      var _bf = (_bay + 0.5) / _bay_count;
      var _bx0 = lerp(_bay_l, _bay_r, _bf);
      var _bh = frac(sin(_bay * 52.73 + _bay_side * 91.4) * 43758.5453);
      var _bw = min(58, _bay_w / max(1, _bay_count) * 0.66);
      var _by0 = _sh_t - 38 + ((_bay + _bay_side) mod 3) * 28;
      var _by1 = min(_sh_anchor_b - 24, _by0 + 78 + _bh * 86);

      draw_set_color(merge_color(_sh_support_dark, _sh_support_mid, 0.20 + _bh * 0.18));
      draw_set_alpha(_shield_a * (0.26 + _bh * 0.12));
      draw_rectangle(_bx0 - _bw * 0.5, _by0, _bx0 + _bw * 0.5, _by1, false);
      draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.35));
      draw_set_alpha(_shield_a * (0.06 + _sh_hum * 0.035));
      draw_line_width(_bx0 - _bw * 0.36, _by0 + 4, _bx0 + _bw * 0.36, _by0 + 4, 1);
      draw_line_width(_bx0 - _bw * 0.36, _by1 - 4, _bx0 + _bw * 0.36, _by1 - 4, 1);
    }
  }

  for (var _pylon_side = 0; _pylon_side < 2; _pylon_side++) {
    var _ps = (_pylon_side == 0) ? -1 : 1;
    var _px = (_pylon_side == 0) ? _sh_l - 44 : _sh_r + 44;
    var _px_outer = _px + _ps * 42;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_px - 16, _sh_t - 56, _sh_support_hi, _shield_a * 0.72);
    draw_vertex_colour(_px + 16, _sh_t - 56, _sh_support_dark, _shield_a * 0.82);
    draw_vertex_colour(_px - 20, _sh_anchor_b, _sh_support_dark, _shield_a * 0.88);
    draw_vertex_colour(_px + 20, _sh_anchor_b, merge_color(c_black, _k_er_col_armor_dark, 0.36), _shield_a * 0.90);
    draw_primitive_end();

    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_shield_a * 0.85);
    draw_line_width(_px + _ps * 18, _sh_t - 48, _px + _ps * 18, _sh_anchor_b, 4);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.08));
    draw_set_alpha(_shield_a * (0.18 + _sh_hum * 0.06));
    draw_line_width(_px - _ps * 11, _sh_t - 48, _px - _ps * 14, _sh_anchor_b - 10, 1.5);

    for (var _rib = 0; _rib < 7; _rib++) {
      var _rf = _rib / 6;
      var _ry = lerp(_sh_t - 18, _sh_anchor_b - 34, _rf);
      var _tilt = 18 + ((_rib mod 2) * 16);
      draw_set_color(_sh_support_mid);
      draw_set_alpha(_shield_a * 0.58);
      draw_line_width(_px - _ps * 18, _ry, _px_outer, _ry + _tilt, 5);
      draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.18));
      draw_set_alpha(_shield_a * (0.08 + _sh_hum * 0.05));
      draw_line_width(_px - _ps * 18, _ry - 1, _px_outer, _ry + _tilt - 1, 1);
    }
  }

  for (var _side_strut = 0; _side_strut < 2; _side_strut++) {
    var _ss = (_side_strut == 0) ? -1 : 1;
    var _inner_x = (_side_strut == 0) ? _sh_l - 10 : _sh_r + 10;
    var _outer_x = (_side_strut == 0) ? _sh_world_l + 74 : _sh_world_r - 74;
    var _top_anchor_y = _sh_t + 20;
    var _mid_anchor_y = _sh_t + 205;
    var _bot_anchor_y = _sh_b + 32;
    var _deck_anchor_y = _sh_anchor_b - 10;

    draw_set_color(_sh_support_mid);
    draw_set_alpha(_shield_a * 0.62);
    draw_line_width(_outer_x, _mid_anchor_y, _inner_x, _top_anchor_y, 10);
    draw_line_width(_outer_x, _mid_anchor_y + 70, _inner_x, _bot_anchor_y, 12);
    draw_line_width(_outer_x + _ss * 42, _deck_anchor_y, _inner_x, _sh_t + 92, 7);

    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.14));
    draw_set_alpha(_shield_a * 0.50);
    draw_line_width(_outer_x + _ss * 5, _mid_anchor_y + 7, _inner_x + _ss * 5, _top_anchor_y + 7, 4);
    draw_line_width(_outer_x + _ss * 5, _mid_anchor_y + 77, _inner_x + _ss * 5, _bot_anchor_y + 7, 5);

    gpu_set_blendmode(bm_add);
    draw_set_color((_side_strut == 0) ? _sh_col : _sh_hot);
    draw_set_alpha(_shield_a * (0.045 + _sh_hum * 0.055));
    draw_line_width(_outer_x, _mid_anchor_y, _inner_x, _top_anchor_y, 2);
    draw_line_width(_outer_x, _mid_anchor_y + 70, _inner_x, _bot_anchor_y, 2);
    draw_set_color(c_white);
    draw_set_alpha(_shield_a * _sh_hum * 0.035);
    draw_line_width(_outer_x + _ss * 42, _deck_anchor_y, _inner_x, _sh_t + 92, 1);
    gpu_set_blendmode(bm_normal);
  }

  var _gantry_y = _sh_t - 48;
  draw_set_color(_sh_support_dark);
  draw_set_alpha(_shield_a * 0.86);
  draw_rectangle(_sh_l - 112, _gantry_y - 16, _sh_r + 112, _gantry_y + 18, false);
  draw_set_color(_sh_support_hi);
  draw_set_alpha(_shield_a * 0.52);
  draw_line_width(_sh_l - 118, _gantry_y - 16, _sh_r + 118, _gantry_y - 16, 2);
  draw_set_color(_k_er_col_armor_dark);
  draw_set_alpha(_shield_a * 0.78);
  draw_line_width(_sh_l - 112, _gantry_y + 19, _sh_r + 112, _gantry_y + 19, 4);

  for (var _gt = 0; _gt <= 13; _gt++) {
    var _gf = _gt / 13;
    var _gx0 = lerp(_sh_l - 96, _sh_r + 96, _gf);
    var _gdir = (_gt mod 2 == 0) ? 1 : -1;
    var _glen = 26 + ((_gt mod 3) * 8);
    draw_set_color(_sh_support_mid);
    draw_set_alpha(_shield_a * 0.46);
    draw_line_width(_gx0, _gantry_y - 12, _gx0 + _gdir * _glen, _gantry_y + 16, 4);

    if (_gt mod 3 == 0) {
      gpu_set_blendmode(bm_add);
      var _node_p = 0.55 + 0.45 * sin(_sh_time * 5.8 + _gt * 1.6);
      draw_set_color((_gt mod 6 == 0) ? _sh_hot : _sh_col);
      draw_set_alpha(_shield_a * (0.045 + _sh_hum * 0.10) * _node_p);
      draw_line_width(_gx0 - 8, _gantry_y + 2, _gx0 + 8, _gantry_y + 2, 2);
      draw_set_color(c_white);
      draw_set_alpha(_shield_a * _sh_hum * 0.045 * _node_p);
      draw_circle(_gx0, _gantry_y + 2, 1.4, false);
      gpu_set_blendmode(bm_normal);
    }
  }

  for (var _corner = 0; _corner < 4; _corner++) {
    var _cx = (_corner < 2) ? _sh_l : _sh_r;
    var _cy = ((_corner mod 2) == 0) ? _sh_t : _sh_b;
    var _cx_dir = (_cx < room_width * 0.5) ? -1 : 1;
    var _cy_dir = (_cy < room_height * 0.5) ? -1 : 1;

    draw_set_color(_sh_support_dark);
    draw_set_alpha(_shield_a * 0.90);
    draw_rectangle(_cx - 28, _cy - 18, _cx + 28, _cy + 18, false);
    draw_set_color(_sh_support_hi);
    draw_set_alpha(_shield_a * 0.56);
    draw_line_width(_cx - 24, _cy - 18, _cx + 24, _cy - 18, 2);
    draw_line_width(_cx + _cx_dir * 28, _cy - 14, _cx + _cx_dir * 58, _cy + _cy_dir * 18, 4);

    gpu_set_blendmode(bm_add);
    var _clamp_p = 0.55 + 0.45 * sin(_sh_time * 6.4 + _corner * 1.33);
    draw_set_color((_corner mod 2 == 0) ? _sh_col : _sh_hot);
    draw_set_alpha(_shield_a * (0.10 + _sh_hum * 0.12) * _clamp_p);
    draw_circle(_cx, _cy, 3.2, false);
    draw_set_color(c_white);
    draw_set_alpha(_shield_a * _sh_hum * 0.08 * _clamp_p);
    draw_circle(_cx, _cy, 1.3, false);
    gpu_set_blendmode(bm_normal);
  }

  gpu_set_blendmode(bm_add);
  for (var _rail = 0; _rail < 5; _rail++) {
    var _rail_f = (_rail + 0.5) / 5;
    var _rail_y = lerp(_sh_t + 26, _sh_b - 52, _rail_f);
    var _rail_a = _shield_a * (0.025 + _sh_hum * 0.055)
                * (0.65 + 0.35 * sin(_sh_time * 4.1 + _rail * 1.7));
    draw_set_color((_rail mod 2 == 0) ? _sh_col : _sh_hot);
    draw_set_alpha(_rail_a);
    draw_line_width(_sh_world_l + 44, _rail_y + sin(_rail * 1.2) * 10,
                    _sh_l - 18, _rail_y, 2);
    draw_line_width(_sh_r + 18, _rail_y,
                    _sh_world_r - 44, _rail_y - sin(_rail * 1.2) * 10, 2);
  }
  gpu_set_blendmode(bm_normal);

  draw_set_alpha(_shield_a);
  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.68));
  draw_rectangle(0, _sh_t - 25, _sh_l - 9, _sh_b + 9, false);
  draw_rectangle(_sh_r + 9, _sh_t - 25, room_width, _sh_b + 9, false);
  draw_rectangle(_sh_l - 24, 0, _sh_r + 24, _sh_t - 9, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_l - 17, _sh_t - 20, merge_color(_k_er_col_armor_hi, c_white, 0.05), _shield_a * 0.74);
  draw_vertex_colour(_sh_l - 7, _sh_t - 20, _k_er_col_armor_dark, _shield_a * 0.82);
  draw_vertex_colour(_sh_l - 17, _sh_b + 10, _k_er_col_armor_dark, _shield_a * 0.82);
  draw_vertex_colour(_sh_l - 7, _sh_b + 10, merge_color(c_black, _k_er_col_armor_dark, 0.45), _shield_a * 0.88);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_r + 7, _sh_t - 20, _k_er_col_armor_dark, _shield_a * 0.82);
  draw_vertex_colour(_sh_r + 17, _sh_t - 20, merge_color(_k_er_col_armor_hi, c_white, 0.05), _shield_a * 0.74);
  draw_vertex_colour(_sh_r + 7, _sh_b + 10, merge_color(c_black, _k_er_col_armor_dark, 0.45), _shield_a * 0.88);
  draw_vertex_colour(_sh_r + 17, _sh_b + 10, _k_er_col_armor_dark, _shield_a * 0.82);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_l - 22, _sh_t - 18, merge_color(_k_er_col_armor_hi, c_white, 0.04), _shield_a * 0.72);
  draw_vertex_colour(_sh_r + 22, _sh_t - 18, merge_color(_k_er_col_armor_hi, c_white, 0.04), _shield_a * 0.72);
  draw_vertex_colour(_sh_l - 10, _sh_t - 7, _k_er_col_armor_dark, _shield_a * 0.88);
  draw_vertex_colour(_sh_r + 10, _sh_t - 7, _k_er_col_armor_dark, _shield_a * 0.88);
  draw_primitive_end();

  draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.22));
  draw_set_alpha(_shield_a * 0.86);
  draw_line_width(_sh_l - 7, _sh_t - 18, _sh_l - 7, _sh_b + 8, 3);
  draw_line_width(_sh_r + 7, _sh_t - 18, _sh_r + 7, _sh_b + 8, 3);
  draw_line_width(_sh_l - 20, _sh_t - 7, _sh_r + 20, _sh_t - 7, 3);

  gpu_set_blendmode(bm_add);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_l - 1, _sh_t, _sh_col, _sh_alpha * (0.26 + _sh_hum * 0.10));
  draw_vertex_colour(_sh_l + 42, _sh_t, _sh_col, _sh_alpha * 0.024);
  draw_vertex_colour(_sh_l - 1, _sh_b, _sh_col, _sh_alpha * (0.24 + _sh_hum * 0.09));
  draw_vertex_colour(_sh_l + 42, _sh_b, _sh_col, _sh_alpha * 0.020);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_r - 42, _sh_t, _sh_col, _sh_alpha * 0.024);
  draw_vertex_colour(_sh_r + 1, _sh_t, _sh_col, _sh_alpha * (0.26 + _sh_hum * 0.10));
  draw_vertex_colour(_sh_r - 42, _sh_b, _sh_col, _sh_alpha * 0.020);
  draw_vertex_colour(_sh_r + 1, _sh_b, _sh_col, _sh_alpha * (0.24 + _sh_hum * 0.09));
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_sh_l, _sh_t - 1, _sh_col, _sh_alpha * (0.23 + _sh_hum * 0.10));
  draw_vertex_colour(_sh_r, _sh_t - 1, _sh_col, _sh_alpha * (0.23 + _sh_hum * 0.10));
  draw_vertex_colour(_sh_l, _sh_t + 34, _sh_col, _sh_alpha * 0.018);
  draw_vertex_colour(_sh_r, _sh_t + 34, _sh_col, _sh_alpha * 0.018);
  draw_primitive_end();

  draw_set_color(_sh_col);
  draw_set_alpha(_sh_alpha * (0.24 + _sh_hum * 0.15));
  draw_line_width(_sh_l, _sh_t, _sh_l, _sh_b, 7);
  draw_line_width(_sh_r, _sh_t, _sh_r, _sh_b, 7);
  draw_line_width(_sh_l, _sh_t, _sh_r, _sh_t, 7);

  draw_set_color(_sh_core_col);
  draw_set_alpha(_sh_alpha * (0.38 + _sh_hum * 0.20));
  draw_line_width(_sh_l, _sh_t, _sh_l, _sh_b, 2);
  draw_line_width(_sh_r, _sh_t, _sh_r, _sh_b, 2);
  draw_line_width(_sh_l, _sh_t, _sh_r, _sh_t, 2);

  draw_set_color(c_white);
  draw_set_alpha(_shield_a * _sh_ring_heat * _sh_ring_window * 0.18);
  draw_line_width(_sh_l, _sh_t, _sh_l, _sh_b, 1);
  draw_line_width(_sh_r, _sh_t, _sh_r, _sh_b, 1);
  draw_line_width(_sh_l, _sh_t, _sh_r, _sh_t, 1);

  var _scan_step = 28;
  var _scan_off = frac(_sh_time * (10 + _sh_hum * 10)) * _scan_step;
  for (var _gy = _sh_t + 10 - _scan_off; _gy < _sh_b; _gy += _scan_step) {
    if (_gy < _sh_t + 6) continue;
    var _gphase = 0.55 + 0.45 * sin(_sh_time * 6.2 + _gy * 0.037);
    var _ga = _shield_a * (0.025 + _sh_hum * 0.08) * _gphase;

    draw_set_color((_gy mod (_scan_step * 3) < _scan_step) ? _sh_hot : _sh_col);
    draw_set_alpha(_ga);
    draw_line_width(_sh_l + 3, _gy, _sh_l + 31, _gy + sin(_gy * 0.09 + _sh_time) * 2, 1);
    draw_line_width(_sh_r - 31, _gy + sin(_gy * 0.08 - _sh_time) * 2, _sh_r - 3, _gy, 1);

    draw_set_alpha(_ga * 0.5);
    draw_line_width(_sh_l + 8, _gy + 9, _sh_l + 28, _gy + 18, 1);
    draw_line_width(_sh_r - 28, _gy + 18, _sh_r - 8, _gy + 9, 1);
  }

  var _top_step = 42;
  var _top_off = frac(_sh_time * (6 + _sh_hum * 5)) * _top_step;
  for (var _gx = _sh_l + 12 - _top_off; _gx < _sh_r; _gx += _top_step) {
    if (_gx < _sh_l + 8) continue;
    var _tphase = 0.55 + 0.45 * sin(_sh_time * 5.1 + _gx * 0.04);
    var _ta2 = _shield_a * (0.022 + _sh_hum * 0.075) * _tphase;

    draw_set_color((_gx mod (_top_step * 4) < _top_step) ? _sh_hot : _sh_col);
    draw_set_alpha(_ta2);
    draw_line_width(_gx, _sh_t + 3, _gx + sin(_gx * 0.06 + _sh_time) * 5, _sh_t + 27, 1);
    draw_line_width(_gx - 12, _sh_t + 14, _gx + 12, _sh_t + 22, 1);
  }

  var _sh_node_count = 9;
  for (var _sn = 0; _sn <= _sh_node_count; _sn++) {
    var _sh_nf = _sn / max(1, _sh_node_count);
    var _ny = lerp(_sh_t + 20, _sh_b - 24, _sh_nf);
    var _np = 0.55 + 0.45 * sin(_sh_time * 4.8 + _sn * 1.41);
    var _na = _shield_a * (0.08 + _sh_hum * 0.14) * _np;
    var _node_col = ((_sn mod 3) == 0) ? _sh_hot : _sh_col;

    draw_set_color(_node_col);
    draw_set_alpha(_na * 0.58);
    draw_line_width(_sh_l - 9, _ny, _sh_l + 18, _ny, 2);
    draw_line_width(_sh_r - 18, _ny, _sh_r + 9, _ny, 2);
    draw_set_color(c_white);
    draw_set_alpha(_na * 0.35);
    draw_circle(_sh_l, _ny, 1.5, false);
    draw_circle(_sh_r, _ny, 1.5, false);
  }

  var _sh_top_nodes = 13;
  for (var _tn = 0; _tn <= _sh_top_nodes; _tn++) {
    var _sh_tf = _tn / max(1, _sh_top_nodes);
    var _sh_nx = lerp(_sh_l + 18, _sh_r - 18, _sh_tf);
    var _np2 = 0.55 + 0.45 * sin(_sh_time * 4.1 + _tn * 1.17);
    var _na2 = _shield_a * (0.05 + _sh_hum * 0.11) * _np2;
    draw_set_color(((_tn mod 4) == 0) ? _sh_hot : _sh_col);
    draw_set_alpha(_na2);
    draw_line_width(_sh_nx, _sh_t - 9, _sh_nx, _sh_t + 17, 1.5);
    draw_set_color(c_white);
    draw_set_alpha(_na2 * 0.32);
    draw_circle(_sh_nx, _sh_t, 1.2, false);
  }

  draw_set_color(_sh_edge_col);
  draw_set_alpha(_shield_a * (0.08 + _sh_hum * 0.12));
  for (var _str = 0; _str < 6; _str++) {
    var _sf = _str / 6;
    var _y0 = lerp(_sh_t + 30, _sh_b - 70, _sf);
    var _y1 = min(_sh_b - 12, _y0 + 62);
    draw_line_width(_sh_l + 1, _y0, _sh_l + 28, _y1, 1);
    draw_line_width(_sh_r - 1, _y0, _sh_r - 28, _y1, 1);
    draw_line_width(lerp(_sh_l + 34, _sh_r - 34, _sf), _sh_t + 1,
                    lerp(_sh_l + 94, _sh_r - 94, _sf), _sh_t + 25, 1);
  }
  }

  gpu_set_blendmode(bm_add);

  if (array_length(ring_tracers) > 0) {
    for (var _hti = 0; _hti < array_length(ring_tracers); _hti++) {
      var _hr = ring_tracers[_hti];
      if (_hr.fired) continue;

      var _hp = clamp(1 - (_hr.life / max(_hr.max_life, 1)), 0, 1);
      var _ha = _shield_a * power(_hp, 1.65) * (0.10 + _hr.hot * 0.22) * (0.65 + _sh_ring_window * 0.55);
      if (_ha <= 0.006) continue;

      var _hedge = _hr.vertical ? 90 : 0;
      var _hux = lengthdir_x(1, _hedge);
      var _huy = lengthdir_y(1, _hedge);
      var _hvx = lengthdir_x(1, _hedge + 90);
      var _hvy = lengthdir_y(1, _hedge + 90);
      var _hlen = 16 + _hp * 25;
      var _hpush = 5 + _hp * 11;
      var _hcol = merge_color(_sh_col, c_white, _hr.hot * 0.45);

      draw_set_color(_hcol);
      draw_set_alpha(_ha * 0.95);
      draw_line_width(_hr.lx - _hux * _hlen, _hr.ly - _huy * _hlen,
                      _hr.lx + _hux * _hlen, _hr.ly + _huy * _hlen, 3);
      draw_set_color(c_white);
      draw_set_alpha(_ha * 0.50);
      draw_line_width(_hr.lx - _hux * (_hlen * 0.42), _hr.ly - _huy * (_hlen * 0.42),
                      _hr.lx + _hux * (_hlen * 0.42), _hr.ly + _huy * (_hlen * 0.42), 1);

      draw_set_color((_hr.hot > 0.65) ? _sh_hot : _sh_col);
      draw_set_alpha(_ha * 0.68);
      draw_line_width(_hr.lx - _hvx * 4, _hr.ly - _hvy * 4,
                      _hr.lx + _hvx * _hpush, _hr.ly + _hvy * _hpush, 2);
      draw_set_alpha(_ha * 0.30);
      draw_line_width(_hr.lx - _hux * _hlen - _hvx * 7, _hr.ly - _huy * _hlen - _hvy * 7,
                      _hr.lx + _hux * _hlen - _hvx * 7, _hr.ly + _huy * _hlen - _hvy * 7, 1);
    }
  }

  if (array_length(ring_craters) > 0) {
    for (var _shi = 0; _shi < array_length(ring_craters); _shi++) {
      var _icr = ring_craters[_shi];
      var _ica = clamp(_icr.life / max(_icr.max_life, 1), 0, 1);
      var _ip = 1 - _ica;
      var _ia = _shield_a * _ica * _ica * (0.12 + _icr.hot * 0.28) * (0.74 + _sh_ring_window * 0.36);
      if (_ia <= 0.006) continue;

      var _iux = lengthdir_x(1, _icr.edge);
      var _iuy = lengthdir_y(1, _icr.edge);
      var _ivx = lengthdir_x(1, _icr.edge + 90);
      var _ivy = lengthdir_y(1, _icr.edge + 90);
      var _ir = _icr.radius * (2.2 + _icr.hot * 0.8);
      var _ident = 7 + _ip * 18 + _icr.hot * 8;
      var _icol = merge_color(_sh_col, _sh_hot, _icr.hot * 0.55);

      draw_set_color(_icol);
      draw_set_alpha(_ia * 0.72);
      draw_line_width(_icr.x - _iux * _ir, _icr.y - _iuy * _ir,
                      _icr.x + _iux * _ir, _icr.y + _iuy * _ir, 5);

      draw_set_color(c_white);
      draw_set_alpha(_ia * 0.42);
      draw_line_width(_icr.x - _iux * (_ir * 0.32), _icr.y - _iuy * (_ir * 0.32),
                      _icr.x + _iux * (_ir * 0.32), _icr.y + _iuy * (_ir * 0.32), 1.5);

      draw_set_color(_icol);
      draw_set_alpha(_ia * 0.35);
      for (var _spk = 0; _spk < 3; _spk++) {
        var _seed = frac(sin((_icr.x + 17) * (_spk + 1.7) + (_icr.y + 5) * 0.071) * 43758.5453);
        var _side = (_spk == 1) ? -1 : 1;
        var _s0 = lerp(5, _ir * 0.75, _seed);
        var _s1 = _s0 + lerp(8, 22, frac(_seed * 3.17));
        var _nudge = (_ident * (0.45 + _seed * 0.55)) * _side;
        draw_line_width(_icr.x + _iux * _s0 - _ivx * 3, _icr.y + _iuy * _s0 - _ivy * 3,
                        _icr.x + _iux * _s1 + _ivx * _nudge, _icr.y + _iuy * _s1 + _ivy * _nudge, 1);
        draw_line_width(_icr.x - _iux * _s0 - _ivx * 3, _icr.y - _iuy * _s0 - _ivy * 3,
                        _icr.x - _iux * _s1 + _ivx * _nudge, _icr.y - _iuy * _s1 + _ivy * _nudge, 1);
      }
    }
  }

  if (array_length(ring_stuck_arrows) > 0) {
    for (var _ssi = 0; _ssi < array_length(ring_stuck_arrows); _ssi++) {
      var _stuck = ring_stuck_arrows[_ssi];
      var _sta2 = clamp(_stuck.life / max(_stuck.max_life, 1), 0, 1);
      var _sdx = min(abs(_stuck.x - _sh_l), abs(_stuck.x - _sh_r));
      var _sdy = min(abs(_stuck.y - _sh_t), abs(_stuck.y - _sh_b));
      var _sedg = (_sdx < _sdy) ? 90 : 0;
      var _sux = lengthdir_x(1, _sedg);
      var _suy = lengthdir_y(1, _sedg);
      var _svx = lengthdir_x(1, _sedg + 90);
      var _svy = lengthdir_y(1, _sedg + 90);
      var _stuck_a = _shield_a * _sta2 * _sta2 * (0.045 + _stuck.hot * 0.10);

      draw_set_color(merge_color(_sh_col, c_white, _stuck.hot * 0.35));
      draw_set_alpha(_stuck_a);
      draw_line_width(_stuck.x - _sux * 11, _stuck.y - _suy * 11,
                      _stuck.x + _sux * 11, _stuck.y + _suy * 11, 2);
      draw_set_alpha(_stuck_a * 0.55);
      draw_line_width(_stuck.x - _svx * 3, _stuck.y - _svy * 3,
                      _stuck.x + _svx * (9 + _stuck.hot * 8), _stuck.y + _svy * (9 + _stuck.hot * 8), 1);
    }
  }

  if (array_length(ring_rim_crackle) > 0) {
    for (var _rci = 0; _rci < array_length(ring_rim_crackle); _rci++) {
      var _rc = ring_rim_crackle[_rci];
      var _rhit = ring_arena_hit(arrow_ring_x, arrow_ring_y, _rc.ang);
      var _ra = _shield_a * clamp(_rc.life / max(_rc.life_max, 1), 0, 1) * (0.16 + _sh_ring_heat * 0.12);
      if (_ra <= 0.006) continue;

      var _redge = _rhit.vertical ? 90 : 0;
      var _rux = lengthdir_x(1, _redge);
      var _ruy = lengthdir_y(1, _redge);
      var _rvx = lengthdir_x(1, _redge + 90);
      var _rvy = lengthdir_y(1, _redge + 90);
      var _rlen = _rc.len * (0.55 + _sh_hum * 0.45);
      var _rz = sin(_sh_time * 23 + _rc.ang * 0.11) * 5;

      draw_set_color(merge_color(_sh_col, c_white, 0.50));
      draw_set_alpha(_ra);
      draw_line_width(_rhit.x - _rux * _rlen * 0.50, _rhit.y - _ruy * _rlen * 0.50,
                      _rhit.x - _rux * _rlen * 0.18 + _rvx * _rz, _rhit.y - _ruy * _rlen * 0.18 + _rvy * _rz, 1);
      draw_line_width(_rhit.x - _rux * _rlen * 0.18 + _rvx * _rz, _rhit.y - _ruy * _rlen * 0.18 + _rvy * _rz,
                      _rhit.x + _rux * _rlen * 0.18 - _rvx * _rz * 0.7, _rhit.y + _ruy * _rlen * 0.18 - _rvy * _rz * 0.7, 1.5);
      draw_line_width(_rhit.x + _rux * _rlen * 0.18 - _rvx * _rz * 0.7, _rhit.y + _ruy * _rlen * 0.18 - _rvy * _rz * 0.7,
                      _rhit.x + _rux * _rlen * 0.50, _rhit.y + _ruy * _rlen * 0.50, 1);
    }
  }

  if (_shield_break_active || containment_shield_flash > 0.01) {
    var _break_a = max(containment_shield_flash * 0.55, power(max(0, 1 - _shield_break_p), 0.8));
    var _cut_ang = point_direction(0, 0, room_width, -room_height);
    var _cut_perp = _cut_ang + 90;
    var _cut_cx = room_width * 0.5;
    var _cut_cy = room_height * 0.5;
    var _cut_len = point_distance(0, 0, room_width, room_height) * 0.72;
    var _cut_x1 = _cut_cx - lengthdir_x(_cut_len, _cut_ang);
    var _cut_y1 = _cut_cy - lengthdir_y(_cut_len, _cut_ang);
    var _cut_x2 = _cut_cx + lengthdir_x(_cut_len, _cut_ang);
    var _cut_y2 = _cut_cy + lengthdir_y(_cut_len, _cut_ang);

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_break_a * 0.26);
    draw_line_width(_cut_x1 + lengthdir_x(5, _cut_perp), _cut_y1 + lengthdir_y(5, _cut_perp),
                    _cut_x2 + lengthdir_x(5, _cut_perp), _cut_y2 + lengthdir_y(5, _cut_perp), 10);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_cut_x1 - lengthdir_x(5, _cut_perp), _cut_y1 - lengthdir_y(5, _cut_perp),
                    _cut_x2 - lengthdir_x(5, _cut_perp), _cut_y2 - lengthdir_y(5, _cut_perp), 10);
    draw_set_color(c_white);
    draw_set_alpha(_break_a * 0.75);
    draw_line_width(_cut_x1, _cut_y1, _cut_x2, _cut_y2, 3 + containment_shield_flash * 5);

    var _hit_ax = _sh_l + 8;
    var _hit_ay = _sh_b;
    var _hit_bx = _sh_r - 10;
    var _hit_by = _sh_t;
    for (var _hb = 0; _hb < 2; _hb++) {
      var _hx = (_hb == 0) ? _hit_ax : _hit_bx;
      var _hy = (_hb == 0) ? _hit_ay : _hit_by;
      var _hr = 18 + _shield_break_p * 95 + containment_shield_flash * 45;
      scr_draw_smooth_ring_mask(_hx, _hy, _hr, _break_a * 0.42, 9 + containment_shield_flash * 12, _sh_hot);
      draw_set_color(c_white);
      draw_set_alpha(_break_a * 0.55);
      draw_circle(_hx, _hy, 3 + containment_shield_flash * 7, false);

      draw_set_color(make_color_rgb(255, 58, 68));
      draw_set_alpha(_break_a * 0.38);
      draw_line_width(_hx - lengthdir_x(58, _cut_ang), _hy - lengthdir_y(58, _cut_ang),
                      _hx + lengthdir_x(72, _cut_ang), _hy + lengthdir_y(72, _cut_ang), 5);
      draw_set_color(make_color_rgb(82, 235, 255));
      draw_set_alpha(_break_a * 0.26);
      draw_line_width(_hx - lengthdir_x(46, _cut_ang + 6), _hy - lengthdir_y(46, _cut_ang + 6),
                      _hx + lengthdir_x(64, _cut_ang + 6), _hy + lengthdir_y(64, _cut_ang + 6), 3);
    }
  }

  if (array_length(containment_shield_fractures) > 0) {
    for (var _cfi = 0; _cfi < array_length(containment_shield_fractures); _cfi++) {
      var _cf2 = containment_shield_fractures[_cfi];
      if (_cf2.delay > 0) continue;

      var _fa = clamp(_cf2.life / max(_cf2.max_life, 1), 0, 1);
      var _fgrow = 1 - power(_fa, 2.2);
      var _fflick = 0.52 + 0.48 * sin(_cf2.seed + t * 0.78);
      var _fx = _cf2.x;
      var _fy = _cf2.y;
      var _edge_ux = lengthdir_x(1, _cf2.edge_ang);
      var _edge_uy = lengthdir_y(1, _cf2.edge_ang);
      var _inside_ang = (_fy <= _sh_t + 6) ? 90 : ((_fx < room_width * 0.5) ? 0 : 180);
      var _inside_x = lengthdir_x(1, _inside_ang);
      var _inside_y = lengthdir_y(1, _inside_ang);
      var _tip_x = _fx + _edge_ux * _cf2.len * _cf2.side * 0.42 * _fgrow + _inside_x * _cf2.spread * _fgrow;
      var _tip_y = _fy + _edge_uy * _cf2.len * _cf2.side * 0.42 * _fgrow + _inside_y * _cf2.spread * _fgrow;
      var _fa2 = _fa * (0.30 + _cf2.hot * 0.55) * _fflick;

      draw_set_color(merge_color(_sh_col, c_white, _cf2.hot * 0.45));
      draw_set_alpha(_fa2);
      draw_line_width(_fx, _fy, _tip_x, _tip_y, 2.5);
      draw_set_color(c_white);
      draw_set_alpha(_fa2 * 0.45);
      draw_line_width(_fx, _fy, lerp(_fx, _tip_x, 0.55), lerp(_fy, _tip_y, 0.55), 1);

      var _branch_x = lerp(_fx, _tip_x, 0.55);
      var _branch_y = lerp(_fy, _tip_y, 0.55);
      var _branch_side = ((_cfi mod 2) == 0) ? -1 : 1;
      draw_set_color(make_color_rgb(255, 58, 68));
      draw_set_alpha(_fa2 * 0.34);
      draw_line_width(_branch_x, _branch_y,
                      _branch_x + _edge_ux * _cf2.len * 0.22 * _branch_side * _fgrow + _inside_x * _cf2.spread * 0.58,
                      _branch_y + _edge_uy * _cf2.len * 0.22 * _branch_side * _fgrow + _inside_y * _cf2.spread * 0.58, 1);
    }
  }

  if (array_length(containment_shield_shards) > 0) {
    for (var _csi = 0; _csi < array_length(containment_shield_shards); _csi++) {
      var _cs2 = containment_shield_shards[_csi];
      if (_cs2.delay > 0) {
        draw_set_color(c_white);
        draw_set_alpha(0.10 + _cs2.hot * 0.18);
        draw_circle(_cs2.x, _cs2.y, 1.6 + _cs2.hot * 2, false);
        continue;
      }

      var _sa = clamp(_cs2.life / max(_cs2.max_life, 1), 0, 1);
      var _su = lengthdir_x(1, _cs2.ang);
      var _sv = lengthdir_y(1, _cs2.ang);
      var _snx = lengthdir_x(1, _cs2.ang + 90);
      var _sny = lengthdir_y(1, _cs2.ang + 90);
      var _slen = _cs2.len * (0.75 + _sa * 0.45);
      var _swid = _cs2.width * (0.70 + _sa * 0.65);
      var _tail = point_distance(0, 0, _cs2.vx, _cs2.vy) * 2.3;
      var _tdir = point_direction(0, 0, _cs2.vx, _cs2.vy);
      var _sa2 = power(_sa, 1.35);
      var _x0 = _cs2.x - _su * (_slen * 0.5);
      var _y0 = _cs2.y - _sv * (_slen * 0.5);
      var _x1 = _cs2.x + _su * (_slen * 0.5);
      var _y1 = _cs2.y + _sv * (_slen * 0.5);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _cs2.hot * 0.45));
      draw_set_alpha(_sa2 * (0.28 + _cs2.hot * 0.34));
      draw_line_width(_x0, _y0, _x1, _y1, _swid + 1.2);
      draw_set_color(make_color_rgb(255, 58, 68));
      draw_set_alpha(_sa2 * 0.22 * _cs2.hot);
      draw_line_width(_x0 + _snx * 3, _y0 + _sny * 3, _x1 + _snx * 3, _y1 + _sny * 3, max(1, _swid));
      draw_set_color(make_color_rgb(82, 235, 255));
      draw_line_width(_x0 - _snx * 3, _y0 - _sny * 3, _x1 - _snx * 3, _y1 - _sny * 3, max(1, _swid));
      draw_set_color(c_white);
      draw_set_alpha(_sa2 * 0.42);
      draw_line_width(_x0, _y0, lerp(_x0, _x1, 0.46), lerp(_y0, _y1, 0.46), max(1, _swid * 0.55));

      draw_set_color(_sh_hot);
      draw_set_alpha(_sa2 * 0.18 * _cs2.hot);
      draw_line_width(_cs2.x - lengthdir_x(_tail, _tdir), _cs2.y - lengthdir_y(_tail, _tdir),
                      _cs2.x, _cs2.y, max(1, _swid * 0.65));
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

var _predeck_a = 0;
if (t < _k_er_lift_charge_t) {
  _predeck_a = 1;
} else if (t < _k_er_lift_beats[0]) {
  _predeck_a = 1 - clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_beats[0] - _k_er_lift_charge_t, 1), 0, 1);
}

if (false && _predeck_a > 0.02) {
  var _deck_y = _k_er_floor_base_y;
  var _deck_pad_x = 390;
  var _deck_pad_y = 360;
  if (instance_exists(oCameraController) && oCameraController.current_cam_w > 0) {
    _deck_pad_x = max(_deck_pad_x, (oCameraController.current_cam_w - room_width) * 0.5 + 90);
    _deck_pad_y = max(_deck_pad_y, (oCameraController.current_cam_h - room_height) * 0.5 + 130);
  }
  var _deck_l = -_deck_pad_x;
  var _deck_r = room_width + _deck_pad_x;
  var _deck_bot = room_height + _deck_pad_y;
  var _deck_w = _deck_r - _deck_l;
  var _deck_core_l = -_k_er_lift_overhang;
  var _deck_core_r = room_width + _k_er_lift_overhang;
  var _deck_core_bot = room_height + 34;
  var _deck_core_w = _deck_core_r - _deck_core_l;
  var _wake = clamp((t - (_k_er_lift_charge_t - 190)) / 190, 0, 1);
  var _hum = clamp(floor_beat * 0.55 + bass_visual * 0.22 + floor_charge * 0.18 + _wake * 0.16, 0, 1);
  var _deck_alpha = _predeck_a;
  var _tsec = t / room_speed;

  draw_set_alpha(_deck_alpha);
  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.64));
  draw_rectangle(_deck_l, _deck_y + 2, _deck_r, _deck_bot, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_l, _deck_y - 7, merge_color(_k_er_col_armor_hi, c_white, 0.08 + _hum * 0.10), _deck_alpha);
  draw_vertex_colour(_deck_r, _deck_y - 7, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.34 + _hum * 0.12), _deck_alpha);
  draw_vertex_colour(_deck_l, _deck_bot, _k_er_col_armor_dark, _deck_alpha);
  draw_vertex_colour(_deck_r, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.42), _deck_alpha);
  draw_primitive_end();

  var _under_y = _deck_y + 45;
  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.42));
  draw_set_alpha(_deck_alpha * 0.86);
  draw_rectangle(_deck_l, _under_y, _deck_r, _deck_bot, false);

  for (var _side = 0; _side < 2; _side++) {
    var _sx_outer = (_side == 0) ? _deck_l : room_width - 92;
    var _sx_inner = (_side == 0) ? 92 : _deck_r;
    var _sx_near = (_side == 0) ? 0 : room_width;
    var _side_w = abs(_sx_inner - _sx_outer);

    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.34));
    draw_set_alpha(_deck_alpha * 0.68);
    draw_rectangle(_sx_outer, _deck_y + 18, _sx_inner, _deck_y + 146, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sx_outer, _deck_y + 18, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.12 + _hum * 0.06), _deck_alpha * 0.62);
    draw_vertex_colour(_sx_inner, _deck_y + 15, _k_er_col_armor_mid, _deck_alpha * 0.70);
    draw_vertex_colour(_sx_outer, _deck_y + 146, merge_color(c_black, _k_er_col_armor_dark, 0.40), _deck_alpha * 0.84);
    draw_vertex_colour(_sx_inner, _deck_y + 135, _k_er_col_armor_dark, _deck_alpha * 0.88);
    draw_primitive_end();

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.08 + _hum * 0.12));
    draw_set_alpha(_deck_alpha * (0.16 + _hum * 0.10));
    draw_line_width(_sx_near, _deck_y + 10, _sx_near, _deck_bot, 2);
    draw_line_width(_sx_outer, _deck_y + 35, _sx_inner, _deck_y + 28, 2);
    draw_line_width(_sx_outer, _deck_y + 96, _sx_inner, _deck_y + 82, 2);

    var _bay_count = max(3, ceil(_side_w / 86));
    for (var _bay = 0; _bay < _bay_count; _bay++) {
      var _bf = (_bay + 0.5) / _bay_count;
      var _bx = lerp(min(_sx_outer, _sx_inner) + 22, max(_sx_outer, _sx_inner) - 22, _bf);
      var _bhash = frac(sin(_bay * 73.41 + _side * 19.77) * 43758.5453);
      var _bw = 34 + _bhash * 24;
      var _by = _deck_y + 34 + (_bay mod 3) * 17;

      draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.08 + _bhash * 0.12));
      draw_set_alpha(_deck_alpha * 0.42);
      draw_rectangle(_bx - _bw * 0.5, _by, _bx + _bw * 0.5, _by + 18 + _bhash * 12, false);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.12 + _hum * 0.20));
      draw_set_alpha(_deck_alpha * (0.08 + _hum * 0.10));
      draw_line_width(_bx - _bw * 0.38, _by + 3, _bx + _bw * 0.38, _by + 3, 1);

      if ((_bay + _side) mod 3 == 0) {
        gpu_set_blendmode(bm_add);
        var _bay_col = ((_bay + _side) mod 6 == 0) ? _k_er_col_warning : _k_er_col_cyan;
        var _bay_a = _deck_alpha * (0.08 + _hum * 0.18) * (0.55 + 0.45 * sin(_tsec * 5.2 + _bay * 1.9));
        draw_set_color(_bay_col);
        draw_set_alpha(_bay_a);
        draw_line_width(_bx - _bw * 0.32, _by + 11, _bx + _bw * 0.32, _by + 11, 1.5);
        draw_set_color(c_white);
        draw_set_alpha(_bay_a * 0.28);
        draw_line_width(_bx - _bw * 0.12, _by + 11, _bx + _bw * 0.12, _by + 11, 1);
        gpu_set_blendmode(bm_normal);
      }
    }
  }

  for (var _cap = 0; _cap < 2; _cap++) {
    var _cap_l = (_cap == 0) ? _deck_l : _deck_core_r - 10;
    var _cap_r = (_cap == 0) ? _deck_core_l + 10 : _deck_r;
    if (_cap_r <= _cap_l) continue;

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.14 + _hum * 0.08));
    draw_set_alpha(_deck_alpha * 0.78);
    draw_rectangle(_cap_l, _deck_y - 5, _cap_r, _deck_y + 12, false);

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.12 + _hum * 0.16));
    draw_set_alpha(_deck_alpha * (0.24 + _hum * 0.12));
    draw_line_width(_cap_l, _deck_y - 5, _cap_r, _deck_y - 5, 2);
    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_deck_alpha * 0.58);
    draw_line_width(_cap_l, _deck_y + 13, _cap_r, _deck_y + 13, 3);
  }

  for (var _join = 0; _join < 2; _join++) {
    var _jx = (_join == 0) ? 0 : room_width;
    var _jdir = (_join == 0) ? -1 : 1;
    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.20));
    draw_set_alpha(_deck_alpha * 0.66);
    draw_rectangle(_jx - 76, _deck_y + 10, _jx + 76, _deck_y + 38, false);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.20 + _hum * 0.14));
    draw_set_alpha(_deck_alpha * (0.12 + _hum * 0.08));
    draw_line_width(_jx - _jdir * 70, _deck_y + 15, _jx + _jdir * 22, _deck_y + 15, 1.5);
    draw_line_width(_jx - _jdir * 56, _deck_y + 30, _jx + _jdir * 52, _deck_y + 30, 1);
  }

  draw_set_alpha(_deck_alpha);
  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.64));
  draw_rectangle(_deck_core_l, _deck_y + 2, _deck_core_r, _deck_core_bot, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_core_l, _deck_y - 7, merge_color(_k_er_col_armor_hi, c_white, 0.08 + _hum * 0.10), _deck_alpha);
  draw_vertex_colour(_deck_core_r, _deck_y - 7, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.34 + _hum * 0.12), _deck_alpha);
  draw_vertex_colour(_deck_core_l, _deck_core_bot, _k_er_col_armor_dark, _deck_alpha);
  draw_vertex_colour(_deck_core_r, _deck_core_bot, merge_color(c_black, _k_er_col_armor_dark, 0.42), _deck_alpha);
  draw_primitive_end();

  var _band_h = 15;
  for (var _row = 0; _row < 3; _row++) {
    var _ry1 = _deck_y + 3 + _row * _band_h;
    var _ry2 = min(_ry1 + _band_h - 3, _deck_core_bot);
    var _row_alpha = _deck_alpha * (0.64 - _row * 0.11);
    var _seg_w = 58;
    var _seg_count = ceil((_deck_core_r - _deck_core_l) / _seg_w) + 1;

    for (var _seg = 0; _seg < _seg_count; _seg++) {
      var _hash = frac(sin(_seg * 97.17 + _row * 41.9) * 43758.5453);
      var _sx1 = _deck_core_l + _seg * _seg_w + 4 + ((_row mod 2) * 18);
      var _sx2 = min(_sx1 + _seg_w - 9 - _hash * 7, _deck_core_r - 3);
      if (_sx1 >= _deck_core_r || _sx2 <= _deck_core_l) continue;

      var _panel_col = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.08 + _hash * 0.12 + _hum * 0.08);
      draw_set_color(_panel_col);
      draw_set_alpha(_row_alpha);
      draw_rectangle(_sx1, _ry1, _sx2, _ry2, false);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.08 + _hum * 0.18));
      draw_set_alpha(_deck_alpha * (0.06 + _hum * 0.06));
      draw_line_width(_sx1 + 2, _ry1 + 1, _sx2 - 2, _ry1 + 1, 1);

      if ((_seg + _row) mod 4 == 0) {
        gpu_set_blendmode(bm_add);
        var _led_col = ((_seg + _row) mod 8 == 0) ? _k_er_col_warning : _k_er_col_cyan;
        var _led_a = _deck_alpha * (0.12 + _hum * 0.26) * (0.65 + 0.35 * sin(_tsec * 7.0 + _seg));
        draw_set_color(_led_col);
        draw_set_alpha(_led_a);
        draw_rectangle(_sx1 + 7, _ry1 + 3, _sx1 + 13, _ry1 + 5, false);
        draw_set_color(c_white);
        draw_set_alpha(_led_a * 0.38);
        draw_rectangle(_sx1 + 9, _ry1 + 3, _sx1 + 11, _ry1 + 5, false);
        gpu_set_blendmode(bm_normal);
      }
    }
  }

  var _lower_row_h = 34;
  var _lower_rows = ceil(max(1, _deck_bot - (_deck_y + 52)) / _lower_row_h);
  for (var _lr = 0; _lr < _lower_rows; _lr++) {
    var _ly1 = _deck_y + 54 + _lr * _lower_row_h;
    var _ly2 = min(_ly1 + _lower_row_h - 5, _deck_bot - 8);
    if (_ly2 <= _ly1) continue;

    var _row_hash = frac(sin(_lr * 53.9 + 12.4) * 43758.5453);
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.18 + _row_hash * 0.10));
    draw_set_alpha(_deck_alpha * (0.28 - min(_lr, 6) * 0.018));
    draw_rectangle(_deck_l + 8, _ly1, _deck_core_l - 8, _ly2, false);
    draw_rectangle(_deck_core_r + 8, _ly1, _deck_r - 8, _ly2, false);

    draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.38));
    draw_set_alpha(_deck_alpha * (0.11 + _hum * 0.035));
    draw_line_width(_deck_l + 22, _ly1 + 2, _deck_core_l - 22, _ly1 + 2, 1);
    draw_line_width(_deck_core_r + 22, _ly1 + 2, _deck_r - 22, _ly1 + 2, 1);

    if (_lr mod 2 == 0) {
      draw_set_color(_k_er_col_cyan);
      draw_set_alpha(_deck_alpha * (0.018 + _hum * 0.045) * (0.6 + 0.4 * sin(_tsec * 4.0 + _lr)));
      draw_line_width(_deck_l + 38, _ly1 + 10, _deck_core_l - 38, _ly1 + 10, 1);
      draw_line_width(_deck_core_r + 38, _ly1 + 10, _deck_r - 38, _ly1 + 10, 1);
    }
  }

  var _rib_step = 64;
  var _rib_count = ceil(_deck_w / _rib_step) + 1;
  for (var _rib = 0; _rib < _rib_count; _rib++) {
    var _rx = _deck_l + _rib * _rib_step + ((_rib mod 2) * 10);
    if (_rx > _deck_core_l - 12 && _rx < _deck_core_r + 12) continue;
    var _rh = frac(sin(_rib * 31.13) * 43758.5453);
    var _lean = 14 + _rh * 22;
    var _rib_a = _deck_alpha * (0.22 + _hum * 0.08) * (0.75 + _rh * 0.25);

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.08 + _hum * 0.06));
    draw_set_alpha(_rib_a);
    draw_line_width(_rx, _deck_y + 43, _rx + _lean, _deck_bot - 18, 3);
    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.35));
    draw_set_alpha(_deck_alpha * 0.36);
    draw_line_width(_rx + 8, _deck_y + 48, _rx + _lean + 8, _deck_bot - 20, 5);
  }

  var _fin_step = 46;
  var _fin_count = ceil(_deck_w / _fin_step) + 1;
  for (var _fn = 0; _fn < _fin_count; _fn++) {
    var _fx = _deck_l + _fn * _fin_step;
    if (_fx > _deck_core_l - 12 && _fx < _deck_core_r + 12) continue;
    var _fh = 24 + 18 * frac(sin(_fn * 18.81 + 9.5) * 43758.5453);
    var _fy = _deck_y + 84 + ((_fn mod 4) * 7);
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.22));
    draw_set_alpha(_deck_alpha * 0.55);
    draw_line_width(_fx, _fy, _fx + 18, min(_deck_bot - 10, _fy + _fh), 4);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.08));
    draw_set_alpha(_deck_alpha * 0.075);
    draw_line_width(_fx + 2, _fy, _fx + 16, min(_deck_bot - 10, _fy + _fh), 1);
  }

  gpu_set_blendmode(bm_add);
  for (var _pipe = 0; _pipe < 7; _pipe++) {
    var _py = _deck_y + 62 + _pipe * 22;
    var _pipe_sag = 6 + _pipe * 1.6;
    var _pipe_a = _deck_alpha * (0.035 + _hum * 0.085) * (0.65 + 0.35 * sin(_tsec * 3.4 + _pipe * 1.3));
    var _pipe_col = (_pipe mod 3 == 0) ? _k_er_col_warning : _k_er_col_cyan;

    draw_set_color(_pipe_col);
    draw_set_alpha(_pipe_a);
    draw_line_width(_deck_l + 36, _py, _deck_l + _deck_pad_x * 0.54, _py + _pipe_sag, 2);
    draw_line_width(_deck_r - 36, _py, _deck_r - _deck_pad_x * 0.54, _py + _pipe_sag, 2);
    draw_set_color(c_white);
    draw_set_alpha(_pipe_a * 0.25);
    draw_line_width(_deck_l + 38, _py, _deck_l + _deck_pad_x * 0.34, _py + _pipe_sag * 0.7, 1);
    draw_line_width(_deck_r - 38, _py, _deck_r - _deck_pad_x * 0.34, _py + _pipe_sag * 0.7, 1);
  }
  gpu_set_blendmode(bm_normal);

  draw_set_alpha(_deck_alpha * 0.88);
  draw_set_color(_k_er_col_armor_dark);
  draw_line_width(_deck_l, _deck_y + 35, _deck_r, _deck_y + 35, 4);

  draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.16 + _hum * 0.28));
  draw_set_alpha(_deck_alpha * (0.52 + _hum * 0.28));
  draw_line_width(_deck_l, _deck_y, _deck_r, _deck_y, 2.5);
  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_deck_alpha * (0.12 + _hum * 0.22));
  draw_line_width(_deck_l + 12, _deck_y + 8, _deck_r - 12, _deck_y + 8, 1.5);

  gpu_set_blendmode(bm_add);
  var _node_count = ceil(_deck_core_w / 64);
  for (var _n = 0; _n <= _node_count; _n++) {
    var _nf = _n / max(1, _node_count);
    var _nx = lerp(_deck_core_l + 18, _deck_core_r - 18, _nf);
    var _pulse = 0.55 + 0.45 * sin(_tsec * 4.4 + _n * 1.71);
    var _node_a = _deck_alpha * (0.05 + _hum * 0.16) * _pulse;
    draw_set_color((_n mod 5 == 0) ? _k_er_col_warning : _k_er_col_cyan);
    draw_set_alpha(_node_a);
    draw_line_width(_nx, _deck_y + 2, _nx + sin(_n * 2.1) * 5, _deck_y + 28, 1);
    draw_circle(_nx, _deck_y + 8, 1.7, false);
  }
  gpu_set_blendmode(bm_normal);

  var _skin_top = _deck_y - 8;
  var _skin_lip = _deck_y + 42;
  var _skin_body = _deck_y + 74;

  draw_set_alpha(_deck_alpha);
  draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.52));
  draw_rectangle(_deck_l, _skin_top, _deck_r, _deck_bot, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_l, _skin_top, merge_color(_k_er_col_armor_hi, c_white, 0.10 + _hum * 0.08), _deck_alpha);
  draw_vertex_colour(_deck_r, _skin_top, merge_color(_k_er_col_armor_hi, c_white, 0.08 + _hum * 0.06), _deck_alpha);
  draw_vertex_colour(_deck_l, _skin_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.22 + _hum * 0.10), _deck_alpha);
  draw_vertex_colour(_deck_r, _skin_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.18 + _hum * 0.08), _deck_alpha);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_l, _skin_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.10), _deck_alpha * 0.92);
  draw_vertex_colour(_deck_r, _skin_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.08), _deck_alpha * 0.92);
  draw_vertex_colour(_deck_l, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.36), _deck_alpha);
  draw_vertex_colour(_deck_r, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.32), _deck_alpha);
  draw_primitive_end();

  var _skin_panel_w = 58;
  var _skin_panel_count = ceil(_deck_w / _skin_panel_w) + 1;
  for (var _spn = 0; _spn < _skin_panel_count; _spn++) {
    var _ph = frac(sin(_spn * 97.17 + 41.9) * 43758.5453);
    var _px1 = _deck_l + _spn * _skin_panel_w + 4;
    var _px2 = min(_px1 + _skin_panel_w - 8 - _ph * 7, _deck_r - 4);
    if (_px2 <= _px1) continue;

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.06 + _ph * 0.14 + _hum * 0.08));
    draw_set_alpha(_deck_alpha * 0.70);
    draw_rectangle(_px1, _deck_y + 2, _px2, _deck_y + 16, false);

    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.24 + _ph * 0.08));
    draw_set_alpha(_deck_alpha * 0.58);
    draw_rectangle(_px1 + 7, _deck_y + 20, _px2 - 4, _deck_y + 34, false);

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.12 + _hum * 0.14));
    draw_set_alpha(_deck_alpha * (0.08 + _hum * 0.05));
    draw_line_width(_px1 + 2, _deck_y + 3, _px2 - 2, _deck_y + 3, 1);
  }

  var _skin_row_h = 38;
  var _skin_row_count = ceil(max(1, _deck_bot - _skin_body) / _skin_row_h);
  for (var _sr = 0; _sr < _skin_row_count; _sr++) {
    var _sy1 = _skin_body + _sr * _skin_row_h;
    var _sy2 = min(_sy1 + _skin_row_h - 6, _deck_bot - 8);
    if (_sy2 <= _sy1) continue;

    var _shade = frac(sin(_sr * 53.9 + 12.4) * 43758.5453);
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.12 + _shade * 0.10));
    draw_set_alpha(_deck_alpha * (0.50 - min(_sr, 8) * 0.025));
    draw_rectangle(_deck_l + 8, _sy1, _deck_r - 8, _sy2, false);

    draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.42));
    draw_set_alpha(_deck_alpha * (0.10 + _hum * 0.035));
    draw_line_width(_deck_l + 20, _sy1 + 2, _deck_r - 20, _sy1 + 2, 1);
  }

  var _skin_rib_step = 72;
  var _skin_rib_count = ceil(_deck_w / _skin_rib_step) + 1;
  for (var _skrib = 0; _skrib < _skin_rib_count; _skrib++) {
    var _rrx = _deck_l + _skrib * _skin_rib_step;
    var _rrh = frac(sin(_skrib * 31.13) * 43758.5453);
    var _rlean = 10 + _rrh * 18;

    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.20));
    draw_set_alpha(_deck_alpha * 0.42);
    draw_line_width(_rrx + 8, _skin_lip + 6, _rrx + _rlean + 8, _deck_bot - 18, 6);
    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.10 + _hum * 0.06));
    draw_set_alpha(_deck_alpha * (0.18 + _hum * 0.06));
    draw_line_width(_rrx, _skin_lip + 4, _rrx + _rlean, _deck_bot - 18, 2);
  }

  draw_set_color(_k_er_col_armor_dark);
  draw_set_alpha(_deck_alpha * 0.92);
  draw_line_width(_deck_l, _deck_y + 38, _deck_r, _deck_y + 38, 5);
  draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.16 + _hum * 0.28));
  draw_set_alpha(_deck_alpha * (0.60 + _hum * 0.24));
  draw_line_width(_deck_l, _deck_y, _deck_r, _deck_y, 2.5);
  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_deck_alpha * (0.16 + _hum * 0.22));
  draw_line_width(_deck_l + 12, _deck_y + 8, _deck_r - 12, _deck_y + 8, 1.5);

  gpu_set_blendmode(bm_add);
  for (var _sn2 = 0; _sn2 <= _skin_panel_count; _sn2 += 2) {
    var _nf2 = _sn2 / max(1, _skin_panel_count);
    var _nx2 = lerp(_deck_l + 24, _deck_r - 24, _nf2);
    var _na3 = _deck_alpha * (0.035 + _hum * 0.12) * (0.55 + 0.45 * sin(_tsec * 4.2 + _sn2 * 1.21));
    draw_set_color((_sn2 mod 10 == 0) ? _k_er_col_warning : _k_er_col_cyan);
    draw_set_alpha(_na3);
    draw_line_width(_nx2, _deck_y + 2, _nx2 + sin(_sn2 * 1.7) * 5, _deck_y + 28, 1);
    draw_circle(_nx2, _deck_y + 8, 1.5, false);
  }

  for (var _side2 = 0; _side2 < 2; _side2++) {
    var _wing_l = (_side2 == 0) ? _deck_l : room_width + 12;
    var _wing_r = (_side2 == 0) ? -12 : _deck_r;
    if (_wing_r <= _wing_l) continue;

    for (var _pipe2 = 0; _pipe2 < 5; _pipe2++) {
      var _py2 = _skin_body + 18 + _pipe2 * 25;
      var _pa2 = _deck_alpha * (0.04 + _hum * 0.10) * (0.65 + 0.35 * sin(_tsec * 3.1 + _pipe2 * 1.6));
      draw_set_color((_pipe2 mod 3 == 0) ? _k_er_col_warning : _k_er_col_cyan);
      draw_set_alpha(_pa2);
      draw_line_width(_wing_l + 28, _py2, _wing_r - 28, _py2 + sin(_pipe2 * 1.4) * 8, 2);
    }

    var _vent_count = max(3, ceil(abs(_wing_r - _wing_l) / 90));
    for (var _vent = 0; _vent < _vent_count; _vent++) {
      var _vf = (_vent + 0.5) / _vent_count;
      var _vx3 = lerp(_wing_l + 32, _wing_r - 32, _vf);
      var _va3 = _deck_alpha * (0.055 + _hum * 0.08) * (0.5 + 0.5 * sin(_tsec * 5.6 + _vent));
      draw_set_color(_k_er_col_cyan);
      draw_set_alpha(_va3);
      draw_rectangle(_vx3 - 13, _deck_y + 52, _vx3 + 13, _deck_y + 55, false);
      draw_set_color(c_white);
      draw_set_alpha(_va3 * 0.25);
      draw_rectangle(_vx3 - 4, _deck_y + 52, _vx3 + 4, _deck_y + 55, false);
    }
  }
  gpu_set_blendmode(bm_normal);

  var _seal_top = _deck_y - 10;
  var _seal_lip = _deck_y + 40;
  var _seal_body = _deck_y + 43;
  var _seal_deep = merge_color(c_black, _k_er_col_armor_dark, 0.58);
  var _seal_body_col = merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.35);
  var _seal_mid = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.24 + _hum * 0.10);
  var _seal_hi = merge_color(_k_er_col_armor_hi, c_white, 0.10 + _hum * 0.08);

  draw_set_alpha(_deck_alpha);
  draw_set_color(_seal_deep);
  draw_rectangle(_deck_l, _seal_top, _deck_r, _deck_bot, false);

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_l, _seal_top, _seal_hi, _deck_alpha);
  draw_vertex_colour(_deck_r, _seal_top, merge_color(_seal_hi, _k_er_col_cyan, 0.06), _deck_alpha);
  draw_vertex_colour(_deck_l, _seal_lip, _seal_mid, _deck_alpha);
  draw_vertex_colour(_deck_r, _seal_lip, merge_color(_seal_mid, c_black, 0.10), _deck_alpha);
  draw_primitive_end();

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_deck_l, _seal_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.16), _deck_alpha);
  draw_vertex_colour(_deck_r, _seal_lip, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.12), _deck_alpha);
  draw_vertex_colour(_deck_l, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.42), _deck_alpha);
  draw_vertex_colour(_deck_r, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.38), _deck_alpha);
  draw_primitive_end();

  var _seal_row_h = 30;
  var _seal_rows = ceil(max(1, _deck_bot - _seal_body) / _seal_row_h);
  for (var _seal_row = 0; _seal_row < _seal_rows; _seal_row++) {
    var _seal_y1 = _seal_body + _seal_row * _seal_row_h;
    var _seal_y2 = min(_seal_y1 + _seal_row_h - 4, _deck_bot - 8);
    if (_seal_y2 <= _seal_y1) continue;

    var _seal_row_hash = frac(sin(_seal_row * 61.37 + 8.91) * 43758.5453);
    var _seal_row_col = merge_color(_seal_body_col, _k_er_col_armor_hi,
                                    0.08 + _seal_row_hash * 0.08 + _hum * 0.06);
    var _seal_row_a = _deck_alpha * (0.82 - min(_seal_row, 10) * 0.035);
    draw_set_color(_seal_row_col);
    draw_set_alpha(max(_deck_alpha * 0.36, _seal_row_a));
    draw_rectangle(_deck_l + 8, _seal_y1, _deck_r - 8, _seal_y2, false);

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.05 + _hum * 0.10));
    draw_set_alpha(_deck_alpha * (0.12 + _hum * 0.05));
    draw_line_width(_deck_l + 18, _seal_y1 + 1, _deck_r - 18, _seal_y1 + 1, 1);
  }

  var _seal_cell_w = 64;
  var _seal_cell_cols = ceil(_deck_w / _seal_cell_w) + 2;
  for (var _seal_row2 = 0; _seal_row2 < 5; _seal_row2++) {
    var _seal_py1 = _deck_y + 4 + _seal_row2 * 16;
    var _seal_py2 = _seal_py1 + ((_seal_row2 == 0) ? 10 : 12);
    var _seal_shift = ((_seal_row2 mod 2) == 0) ? 0 : _seal_cell_w * 0.42;
    for (var _seal_col = 0; _seal_col < _seal_cell_cols; _seal_col++) {
      var _seal_h = frac(sin(_seal_col * 89.71 + _seal_row2 * 37.33) * 43758.5453);
      var _seal_x1 = _deck_l + _seal_col * _seal_cell_w + 5 + _seal_shift;
      var _seal_x2 = min(_seal_x1 + _seal_cell_w - 10 - _seal_h * 8, _deck_r - 5);
      if (_seal_x2 <= _seal_x1 || _seal_x1 >= _deck_r) continue;

      draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi,
                                 0.16 + _seal_h * 0.12 + _hum * 0.10));
      draw_set_alpha(_deck_alpha * (0.64 - _seal_row2 * 0.055));
      draw_rectangle(_seal_x1, _seal_py1, _seal_x2, _seal_py2, false);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.10 + _hum * 0.15));
      draw_set_alpha(_deck_alpha * (0.08 + _hum * 0.05));
      draw_line_width(_seal_x1 + 2, _seal_py1 + 1, _seal_x2 - 2, _seal_py1 + 1, 1);
    }
  }

  var _seal_brace_step = 74;
  var _seal_braces = ceil(_deck_w / _seal_brace_step) + 1;
  for (var _seal_b = 0; _seal_b < _seal_braces; _seal_b++) {
    var _seal_bx = _deck_l + _seal_b * _seal_brace_step;
    var _seal_bh = frac(sin(_seal_b * 29.53 + 3.1) * 43758.5453);
    var _seal_lean = 8 + _seal_bh * 18;

    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.18));
    draw_set_alpha(_deck_alpha * 0.48);
    draw_line_width(_seal_bx + 10, _seal_lip + 4,
                    _seal_bx + _seal_lean + 10, _deck_bot - 18, 6);
    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.14 + _hum * 0.07));
    draw_set_alpha(_deck_alpha * (0.20 + _hum * 0.06));
    draw_line_width(_seal_bx, _seal_lip + 3, _seal_bx + _seal_lean, _deck_bot - 18, 2);
  }

  draw_set_color(_k_er_col_armor_dark);
  draw_set_alpha(_deck_alpha * 0.95);
  draw_line_width(_deck_l, _deck_y + 38, _deck_r, _deck_y + 38, 5);
  draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.18 + _hum * 0.26));
  draw_set_alpha(_deck_alpha * (0.68 + _hum * 0.20));
  draw_line_width(_deck_l, _deck_y, _deck_r, _deck_y, 2.6);
  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_deck_alpha * (0.18 + _hum * 0.22));
  draw_line_width(_deck_l + 12, _deck_y + 8, _deck_r - 12, _deck_y + 8, 1.5);

  gpu_set_blendmode(bm_add);
  for (var _seal_node = 0; _seal_node <= _seal_cell_cols; _seal_node += 2) {
    var _seal_nf = _seal_node / max(1, _seal_cell_cols);
    var _seal_nx = lerp(_deck_l + 24, _deck_r - 24, _seal_nf);
    var _seal_np = 0.55 + 0.45 * sin(_tsec * 4.5 + _seal_node * 1.37);
    var _seal_na = _deck_alpha * (0.04 + _hum * 0.13) * _seal_np;
    draw_set_color((_seal_node mod 10 == 0) ? _k_er_col_warning : _k_er_col_cyan);
    draw_set_alpha(_seal_na);
    draw_line_width(_seal_nx, _deck_y + 2,
                    _seal_nx + sin(_seal_node * 1.7) * 5, _deck_y + 30, 1);
    draw_circle(_seal_nx, _deck_y + 8, 1.5, false);
  }

  for (var _seal_side = 0; _seal_side < 2; _seal_side++) {
    var _seal_wing_l = (_seal_side == 0) ? _deck_l : room_width + 12;
    var _seal_wing_r = (_seal_side == 0) ? -12 : _deck_r;
    if (_seal_wing_r <= _seal_wing_l) continue;

    for (var _seal_pipe = 0; _seal_pipe < 5; _seal_pipe++) {
      var _seal_pipe_y = _seal_body + 18 + _seal_pipe * 26;
      var _seal_pipe_a = _deck_alpha * (0.04 + _hum * 0.11)
                       * (0.65 + 0.35 * sin(_tsec * 3.2 + _seal_pipe * 1.5));
      draw_set_color((_seal_pipe mod 3 == 0) ? _k_er_col_warning : _k_er_col_cyan);
      draw_set_alpha(_seal_pipe_a);
      draw_line_width(_seal_wing_l + 28, _seal_pipe_y,
                      _seal_wing_r - 28, _seal_pipe_y + sin(_seal_pipe * 1.35) * 8, 2);
      draw_set_color(c_white);
      draw_set_alpha(_seal_pipe_a * 0.22);
      draw_line_width(_seal_wing_l + 34, _seal_pipe_y,
                      _seal_wing_r - 52, _seal_pipe_y + sin(_seal_pipe * 1.35) * 5, 1);
    }

    var _seal_vents = max(3, ceil(abs(_seal_wing_r - _seal_wing_l) / 94));
    for (var _seal_v = 0; _seal_v < _seal_vents; _seal_v++) {
      var _seal_vf = (_seal_v + 0.5) / _seal_vents;
      var _seal_vx = lerp(_seal_wing_l + 34, _seal_wing_r - 34, _seal_vf);
      var _seal_va = _deck_alpha * (0.055 + _hum * 0.09)
                   * (0.5 + 0.5 * sin(_tsec * 5.7 + _seal_v));
      draw_set_color(_k_er_col_cyan);
      draw_set_alpha(_seal_va);
      draw_rectangle(_seal_vx - 14, _deck_y + 53, _seal_vx + 14, _deck_y + 56, false);
      draw_set_color(c_white);
      draw_set_alpha(_seal_va * 0.25);
      draw_rectangle(_seal_vx - 4, _deck_y + 53, _seal_vx + 4, _deck_y + 56, false);
    }
  }
  gpu_set_blendmode(bm_normal);

  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (er_lift_active || array_length(er_lift_chunks) > 0 || array_length(er_lift_vents) > 0) {
  var _ml_top = er_lift_top_y;
  var _ml_bot = _ml_top + _k_er_lift_body_h;
  var _ml_heat = clamp(er_lift_heat + er_lift_hit_flash * 0.35 + er_lift_lock_flash * 0.45, 0, 1);
  var _lip_n = array_length(er_lift_lip);

  if (t >= _k_er_lift_charge_t && t < _k_er_lift_beats[0]) {
    var _charge_p = clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_beats[0] - _k_er_lift_charge_t, 1), 0, 1);
    var _mouth_h = lerp(10, _k_er_lift_warning_h, _charge_p);
    draw_set_color(c_black);
    draw_set_alpha(0.9);
    draw_rectangle(0, _k_er_floor_base_y - 2, room_width, _k_er_floor_base_y + _mouth_h, false);
    draw_set_color(_k_er_col_armor_edge);
    draw_set_alpha(0.45 + _charge_p * 0.35);
    draw_line_width(0, _k_er_floor_base_y, room_width, _k_er_floor_base_y, 3 + _charge_p * 4);
  }

  if (_lip_n > 1) {
    var _ml_shell_a = er_lift_despawning
                    ? max(0.18, power(1 - clamp(er_lift_despawn_timer / _k_er_lift_despawn_duration, 0, 1), 0.55))
                    : 1;
    draw_primitive_begin(pr_trianglestrip);
    for (var _li = 0; _li < _lip_n; _li++) {
      var _lip = er_lift_lip[_li];
      var _top_j = _ml_top + _lip.top * (0.4 + _ml_heat * 0.6);
      var _bot_j = _ml_bot + _lip.under + sin(er_lift_seed + _li * 1.7 + t * 0.03) * 2;
      draw_vertex_colour(_lip.x, _top_j, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.18 + _ml_heat * 0.18), _ml_shell_a);
      draw_vertex_colour(_lip.x, _bot_j, _k_er_col_armor_dark, _ml_shell_a);
    }
    draw_primitive_end();

    var _deck_l = -_k_er_lift_overhang;
    var _deck_r = room_width + _k_er_lift_overhang;
    var _deck_top = _ml_top;
    var _deck_bot = _ml_bot + 14;
    var _deck_h = max(1, _deck_bot - _deck_top);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_deck_l, _deck_top, merge_color(_k_er_col_armor_hi, c_white, 0.08 + _ml_heat * 0.12), _ml_shell_a);
    draw_vertex_colour(_deck_r, _deck_top, merge_color(_k_er_col_armor_hi, c_white, 0.04 + _ml_heat * 0.08), _ml_shell_a);
    draw_vertex_colour(_deck_l, _deck_bot, _k_er_col_armor_dark, _ml_shell_a);
    draw_vertex_colour(_deck_r, _deck_bot, merge_color(c_black, _k_er_col_armor_dark, 0.45), _ml_shell_a);
    draw_primitive_end();

    var _deck_rows = 3;
    for (var _dr = 0; _dr < _deck_rows; _dr++) {
      var _ry1 = _deck_top + 5 + _dr * (_deck_h - 10) / _deck_rows;
      var _ry2 = _deck_top + 5 + (_dr + 1) * (_deck_h - 10) / _deck_rows - 3;
      var _row_a = 0.78 - _dr * 0.13;
      for (var _dc2 = 0; _dc2 < 12; _dc2++) {
        var _seg_w = (_deck_r - _deck_l) / 12;
        var _sx1 = _deck_l + _dc2 * _seg_w + 4 + ((_dr mod 2) * _seg_w * 0.32);
        var _sx2 = _sx1 + _seg_w * 0.72;
        if (_sx1 > _deck_r) _sx1 -= (_deck_r - _deck_l);
        if (_sx2 > _deck_r) _sx2 -= (_deck_r - _deck_l);
        if (_sx2 > _sx1) {
          var _scol = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi,
                                  0.08 + 0.08 * frac(sin(_dc2 * 19.1 + _dr * 3.7) * 43758.5453));
          draw_set_color(_scol);
          draw_set_alpha(_row_a * _ml_shell_a);
          draw_rectangle(_sx1, _ry1, _sx2, _ry2, false);
          draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.15));
          draw_set_alpha((0.10 + _ml_heat * 0.08) * _ml_shell_a);
          draw_line_width(_sx1 + 2, _ry1 + 1, _sx2 - 2, _ry1 + 1, 1);
        }
      }
    }

    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(0.85 * _ml_shell_a);
    draw_line_width(_deck_l, _deck_bot, _deck_r, _deck_bot, 5);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.2 + _ml_heat * 0.25));
    draw_set_alpha((0.45 + _ml_heat * 0.28) * _ml_shell_a);
    draw_line_width(_deck_l, _deck_top, _deck_r, _deck_top, 2.5);
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha((0.16 + er_lift_rail_alpha * 0.32 + er_lift_lock_flash * 0.18) * _ml_shell_a);
    draw_line_width(_deck_l + 18, _deck_top + 9, _deck_r - 18, _deck_top + 9, 1.5);

    var _brace_n = 14;
    for (var _br = 0; _br < _brace_n; _br++) {
      var _bf = _br / max(1, _brace_n - 1);
      var _bx = lerp(_deck_l + 18, _deck_r - 18, _bf);
      var _dir = (_br mod 2 == 0) ? 1 : -1;
      var _bx2 = _bx + _dir * 34;
      draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.28));
      draw_set_alpha((0.50 + _ml_heat * 0.12) * _ml_shell_a);
      draw_line_width(_bx, _deck_top + 18, _bx2, _deck_bot - 5, 2);

      if (_br mod 3 == 0) {
        gpu_set_blendmode(bm_add);
        draw_set_color(_k_er_col_cyan);
        draw_set_alpha((0.14 + er_lift_rail_alpha * 0.22) * _ml_shell_a);
        draw_circle(_bx, _deck_top + 18, 2.2, false);
        draw_set_color(c_white);
        draw_set_alpha(er_lift_hit_flash * 0.24 * _ml_shell_a);
        draw_circle(_bx, _deck_top + 18, 0.9, false);
        gpu_set_blendmode(bm_normal);
      }
    }

    for (var _li2 = 1; _li2 < _lip_n - 1; _li2++) {
      var _lip2 = er_lift_lip[_li2];
      if (_lip2.vein < 0.42 && _ml_heat > 0.05) {
        var _vx = _lip2.x + sin(_lip2.seed + t * 0.05) * 3;
        draw_set_color(merge_color(_k_er_col_cyan, c_white, _ml_heat * 0.45));
        draw_set_alpha((0.12 + _ml_heat * 0.28) * (0.7 + 0.3 * sin(_lip2.seed + t * 0.2)));
        draw_line_width(_vx, _ml_top + 5 + _lip2.chip,
                        _vx + sin(_lip2.seed) * 9, _ml_bot + _lip2.under * 0.6,
                        1.5 + _ml_heat * 2.5);
      }
    }

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.25 + _ml_heat * 0.45));
    draw_set_alpha((0.45 + _ml_heat * 0.45) * _ml_shell_a);
    draw_line_width(0, _ml_top, room_width, _ml_top, 2 + _ml_heat * 2);
    draw_set_color(c_white);
    draw_set_alpha((er_lift_hit_flash + er_lift_lock_flash) * 0.55);
    draw_line_width(0, _ml_top - 1, room_width, _ml_top - 1, 2);

    for (var _pg = -_k_er_lift_overhang; _pg <= room_width + _k_er_lift_overhang; _pg += _k_er_lift_segment_w) {
      var _panel_a = 0.28 + _ml_heat * 0.24;
      draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.35 + _ml_heat * 0.18));
      draw_set_alpha(_panel_a * _ml_shell_a);
      draw_line_width(_pg, _ml_top + 3, _pg + sin(_pg * 0.07 + er_lift_seed) * 2,
                      _ml_bot + 10, 1);

      var _pg_idx = floor((_pg + _k_er_lift_overhang) / _k_er_lift_segment_w);
      if ((_pg_idx + er_lift_beat_index) mod 4 == 0) {
        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_k_er_col_cyan, c_white, er_lift_lock_flash * 0.45));
        draw_set_alpha((0.18 + _ml_heat * 0.22 + er_lift_rail_alpha * 0.2) * _ml_shell_a);
        draw_rectangle(_pg + 5, _ml_top + 5, _pg + _k_er_lift_segment_w - 7, _ml_top + 8, false);
        draw_set_color(c_white);
        draw_set_alpha((er_lift_hit_flash + er_lift_lock_flash) * 0.34);
        draw_rectangle(_pg + 8, _ml_top + 4, _pg + 13, _ml_top + 9, false);
        gpu_set_blendmode(bm_normal);
      }
    }

    draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.35));
    draw_set_alpha((0.18 + er_lift_rail_alpha * 0.34) * _ml_shell_a);
    draw_line_width(0, _ml_top + 12, room_width, _ml_top + 12, 1);
    draw_set_color(_k_er_col_warning);
    draw_set_alpha((0.12 + er_lift_hit_flash * 0.28) * _ml_shell_a);
    draw_line_width(0, _ml_top + 20, room_width, _ml_top + 20, 1);
    draw_set_alpha(1);

    for (var _ti = 0; _ti < _lip_n - 1; _ti++) {
      var _a = er_lift_lip[_ti];
      var _b = er_lift_lip[_ti + 1];
      if ((_ti + er_lift_beat_index) mod 3 == 0) {
        var _tx = (_a.x + _b.x) * 0.5;
        var _tw = max(8, (_b.x - _a.x) * 0.45);
        var _th = 5 + _a.chip;
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_tx - _tw * 0.5, _ml_top + 1, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_tx, _ml_top + _th, merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.4), 1);
        draw_vertex_colour(_tx + _tw * 0.5, _ml_top + 1, _k_er_col_armor_dark, 1);
        draw_primitive_end();
      }
    }
  }

  if (er_lift_despawning || array_length(er_lift_despawn_cracks) > 0) {
    var _dp_lift = er_lift_despawning
                 ? clamp(er_lift_despawn_timer / _k_er_lift_despawn_duration, 0, 1)
                 : 1;
    var _tear_a = power(1 - _dp_lift, 0.6);
    var _sink_shadow = 10 + _dp_lift * 44;

    draw_set_color(c_black);
    draw_set_alpha(0.35 + _tear_a * 0.35);
    draw_rectangle(-_k_er_lift_overhang, _ml_bot - 4,
                   room_width + _k_er_lift_overhang, _ml_bot + _sink_shadow, false);

    for (var _dc = 0; _dc < array_length(er_lift_despawn_cracks); _dc++) {
      var _cr = er_lift_despawn_cracks[_dc];
      if (_cr.delay <= 0) {
        var _ca = clamp(_cr.life / _cr.life_max, 0, 1);
        var _cw = _cr.w * (0.7 + (1 - _ca) * 0.8);
        var _x1 = _cr.x - _cw * 0.5;
        var _x2 = _cr.x + _cw * 0.5;
        var _y = _ml_top + 2 + sin(_cr.seed + t * 0.08) * 2;

        draw_primitive_begin(pr_trianglestrip);
        for (var _cs = 0; _cs <= 4; _cs++) {
          var _cf = _cs / 4;
          var _cx = lerp(_x1, _x2, _cf);
          var _j = sin(_cr.seed + _cs * 2.4) * (4 + _dp_lift * 10);
          draw_vertex_colour(_cx, _y + _j * 0.15, c_black, _ca * 0.95);
          draw_vertex_colour(_cx, _y + 8 + _j, c_black, _ca * 0.55);
        }
        draw_primitive_end();
      }
    }
  }

  for (var _vi = 0; _vi < array_length(er_lift_vents); _vi++) {
    var _ve = er_lift_vents[_vi];
    var _va = clamp(_ve.life / _ve.life_max, 0, 1);
    var _vw = _ve.w * (0.65 + (1 - _va) * 0.35);
    var _x1 = _ve.x - _vw * 0.5;
    var _x2 = _ve.x + _vw * 0.5;
    draw_set_color(c_black);
    draw_set_alpha(0.75 * _va);
    draw_rectangle(_x1, _ml_top - 1, _x2, _ml_top + 8 + _ve.hot * 10, false);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, _ve.hot));
    draw_set_alpha(_va * (0.35 + _ve.hot * 0.45));
    draw_line_width(_x1 + 2, _ml_top + 1, _x2 - 2, _ml_top + 1, 2 + _ve.hot * 3);
  }

  for (var _ri = 0; _ri < array_length(er_lift_ridges); _ri++) {
    var _rg = er_lift_ridges[_ri];
    var _ra = clamp(_rg.life / _rg.life_max, 0, 1);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, _rg.hot));
    draw_set_alpha(_ra * 0.45);
    draw_line_width(_rg.x, _ml_top + 2, _rg.x + _rg.dir * _rg.dist, _ml_top + random_range(-2, 4), 2);
  }

  for (var _ci = 0; _ci < array_length(er_lift_chunks); _ci++) {
    var _ck = er_lift_chunks[_ci];
    var _ca = clamp(_ck.life / _ck.life_max, 0, 1);
    var _sz = _ck.size * (0.6 + _ca * 0.4);
    var _ang1 = _ck.rot;
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_ck.x, _ck.y, merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.32), _ca);
    draw_vertex_colour(_ck.x + lengthdir_x(_sz, _ang1), _ck.y + lengthdir_y(_sz, _ang1), _k_er_col_armor_dark, _ca);
    draw_vertex_colour(_ck.x + lengthdir_x(_sz * 0.8, _ang1 + 115), _ck.y + lengthdir_y(_sz * 0.8, _ang1 + 115), _k_er_col_armor_mid, _ca);
    draw_vertex_colour(_ck.x + lengthdir_x(_sz * 0.9, _ang1 + 230), _ck.y + lengthdir_y(_sz * 0.9, _ang1 + 230), _k_er_col_armor_edge, _ca);
    draw_vertex_colour(_ck.x + lengthdir_x(_sz, _ang1), _ck.y + lengthdir_y(_sz, _ang1), _k_er_col_armor_dark, _ca);
    draw_primitive_end();
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
}


var _hc_window_live = (t >= _k_er_lift_beats[0] - _k_hc_front_telegraph)
                   && (t <= _k_er_lift_beats[3] + _k_hc_front_scar_life);
if (_hc_window_live) {
  var _hc_deck_y = er_lift_top_y;
  var _hc_cx = _k_hc_front_cx;
  var _hc_cy = _k_hc_front_cy;
  var _hc_phase_count = array_length(_k_er_lift_beats);

  gpu_set_blendmode(bm_normal);

  for (var _hc_phase = 0; _hc_phase < _hc_phase_count; _hc_phase++) {
    var _hc_beat = _k_er_lift_beats[_hc_phase];
    var _hc_age = t - _hc_beat;
    var _hc_pre = clamp((t - (_hc_beat - _k_hc_front_telegraph)) / max(_k_hc_front_telegraph, 1), 0, 1);
    var _hc_scar_p = (_hc_age >= 0)
                   ? clamp(_hc_age / max(_k_hc_front_scar_life, 1), 0, 1)
                   : 0;
    var _hc_source_a = max((_hc_age < 0) ? power(_hc_pre, 2) * 0.46 : 0,
                           (_hc_age >= 0 && _hc_age < _k_hc_front_scar_life)
                           ? power(1 - _hc_scar_p, 0.76) * (0.42 + _hc_phase * 0.06)
                           : 0);

    if (_hc_source_a > 0.02) {
      for (var _hc_socket = 0; _hc_socket < _k_hc_front_socket_count; _hc_socket++) {
        var _hc_sf = (_hc_socket + 0.5) / _k_hc_front_socket_count;
        var _hc_sx = lerp(76, room_width - 76, _hc_sf);
        var _hc_seed = frac(sin((_hc_phase + 1) * 37.31 + _hc_socket * 11.73) * 43758.5453);
        var _hc_socket_a = _hc_source_a * (0.62 + _hc_seed * 0.24)
                         * (0.82 + 0.18 * sin(t * 0.15 + _hc_socket * 1.9 + _hc_phase));
        var _hc_sw = 34 + _hc_seed * 18;

        draw_set_color(c_black);
        draw_set_alpha(0.58 * _hc_socket_a);
        draw_rectangle(_hc_sx - _hc_sw * 0.5, _hc_deck_y + 1,
                       _hc_sx + _hc_sw * 0.5, _hc_deck_y + 12 + _hc_seed * 6, false);

        draw_set_color(merge_color(global.avoid_col_armor_mid, global.avoid_col_armor_edge, 0.34));
        draw_set_alpha(0.48 * _hc_socket_a);
        draw_line_width(_hc_sx - _hc_sw * 0.46, _hc_deck_y + 2,
                        _hc_sx + _hc_sw * 0.46, _hc_deck_y + 2, 2);
        draw_line_width(_hc_sx - _hc_sw * 0.34, _hc_deck_y + 10,
                        _hc_sx + _hc_sw * 0.30, _hc_deck_y + 15, 1);

        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.20 + _hc_phase * 0.09));
        draw_set_alpha(0.20 * _hc_socket_a);
        draw_line_width(_hc_sx - _hc_sw * 0.38, _hc_deck_y + 1,
                        _hc_sx + _hc_sw * 0.38, _hc_deck_y + 1, 2.5);
        draw_set_color(merge_color(global.avoid_col_ember, c_white, 0.16 + _hc_phase * 0.07));
        draw_set_alpha(0.12 * _hc_socket_a);
        draw_line_width(_hc_sx - _hc_sw * 0.25, _hc_deck_y + 5,
                        _hc_sx + _hc_sw * 0.22, _hc_deck_y + 5, 1.5);
        gpu_set_blendmode(bm_normal);
      }
    }

    if (_hc_age >= 0 && _hc_age < _k_hc_front_scar_life) {
      var _hc_scar_a = power(1 - _hc_scar_p, 0.82) * (0.25 + _hc_phase * 0.05);
      var _hc_spread = lerp(116, 334, clamp(_hc_age / 32, 0, 1));
      var _hc_scar_count = 5 + _hc_phase;
      for (var _hc_sc = 0; _hc_sc < _hc_scar_count; _hc_sc++) {
        var _hc_cf = (_hc_sc + 0.5) / _hc_scar_count;
        var _hc_seed2 = frac(sin((_hc_phase + 2) * 48.13 + _hc_sc * 9.19) * 43758.5453);
        var _hc_scar_x = _hc_cx + (_hc_cf * 2 - 1) * _hc_spread + (_hc_seed2 - 0.5) * 24;
        var _hc_tail = 28 + _hc_phase * 5 + _hc_seed2 * 24;
        var _hc_y = _hc_deck_y + 3 + (_hc_sc mod 2) * 4;

        draw_set_color(c_black);
        draw_set_alpha(0.50 * _hc_scar_a);
        draw_line_width(_hc_scar_x - _hc_tail * 0.5, _hc_y + 2,
                        _hc_scar_x + _hc_tail * 0.5, _hc_y + 1 + (_hc_seed2 - 0.5) * 5, 4);
        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(global.avoid_col_ember, c_white, 0.22 + _hc_phase * 0.08));
        draw_set_alpha(0.23 * _hc_scar_a);
        draw_line_width(_hc_scar_x - _hc_tail * 0.42, _hc_y,
                        _hc_scar_x + _hc_tail * 0.38, _hc_y + (_hc_seed2 - 0.5) * 4, 1.5);
        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(0.08 * _hc_scar_a);
        draw_line_width(_hc_scar_x - _hc_tail * 0.18, _hc_y - 1,
                        _hc_scar_x + _hc_tail * 0.16, _hc_y - 1, 1);
        gpu_set_blendmode(bm_normal);
      }
    }
  }

  for (var _hc_front_phase = 0; _hc_front_phase < _hc_phase_count; _hc_front_phase++) {
    var _hc_front_beat = _k_er_lift_beats[_hc_front_phase];
    var _hc_front_age = t - _hc_front_beat;
    var _hc_front_pre = clamp((t - (_hc_front_beat - _k_hc_front_telegraph)) / max(_k_hc_front_telegraph, 1), 0, 1);
    var _hc_is_telegraph = (_hc_front_age < 0 && _hc_front_pre > 0);
    var _hc_is_active = (_hc_front_age >= 0 && _hc_front_age < _k_hc_front_life);
    if (!_hc_is_telegraph && !_hc_is_active) continue;

    var _hc_front_p = _hc_is_active ? clamp(_hc_front_age / max(_k_hc_front_life, 1), 0, 1) : 0;
    var _hc_ease = 1 - power(1 - _hc_front_p, 2.2);
    var _hc_max_r = _k_hc_front_radius1[min(_hc_front_phase, array_length(_k_hc_front_radius1) - 1)];
    var _hc_radius = _hc_is_active
                   ? lerp(_k_hc_front_radius0, _hc_max_r, _hc_ease)
                   : _k_hc_front_radius0 * (0.80 + _hc_front_pre * 0.18);
    var _hc_front_fade = _hc_is_active
                       ? power(1 - _hc_front_p, 0.54)
                       : _hc_front_pre * 0.42;
    var _hc_heat = _hc_is_active
                 ? clamp(1 - abs(_hc_front_p - 0.23) / 0.48, 0, 1)
                 : 0;
    var _hc_band_w = _k_hc_front_width[min(_hc_front_phase, array_length(_k_hc_front_width) - 1)];
    var _hc_start_ang = _hc_front_phase * 90 - (_k_hc_front_arc_span - 180) * 0.5;
    var _hc_seq = _hc_is_active
                ? _hc_front_p * (_k_hc_front_segments + 8)
                : _hc_front_pre * (_k_hc_front_segments * 0.75);

    var _hc_link_a = _hc_is_active
                   ? _hc_front_fade * (0.14 + _hc_heat * 0.14)
                   : _hc_front_pre * 0.12;
    if (_hc_link_a > 0.015) {
      gpu_set_blendmode(bm_normal);
      for (var _hc_link = 0; _hc_link < 3; _hc_link++) {
        var _hc_lf = (_hc_link + 1) / 4;
        var _hc_lslot = clamp(round(_hc_lf * (_k_hc_front_socket_count - 1)), 0, _k_hc_front_socket_count - 1);
        var _hc_lsrc_x = lerp(76, room_width - 76, (_hc_lslot + 0.5) / _k_hc_front_socket_count);
        var _hc_lsrc_y = _hc_deck_y + 2;
        var _hc_lang = _hc_start_ang + _k_hc_front_arc_span * _hc_lf;
        var _hc_lr = max(_k_hc_front_radius0, _hc_radius - _hc_band_w * 0.28);
        var _hc_lrim_x = _hc_cx + lengthdir_x(_hc_lr, _hc_lang);
        var _hc_lrim_y = _hc_cy + lengthdir_y(_hc_lr, _hc_lang);

        draw_set_color(c_black);
        draw_set_alpha(_hc_link_a * 0.34);
        draw_line_width(_hc_lsrc_x, _hc_lsrc_y, _hc_lrim_x, _hc_lrim_y, 4);
        draw_set_color(merge_color(global.avoid_col_armor_mid, global.avoid_col_armor_edge, 0.38));
        draw_set_alpha(_hc_link_a * 0.26);
        draw_line_width(_hc_lsrc_x, _hc_lsrc_y, _hc_lrim_x, _hc_lrim_y, 1.5);
      }

      gpu_set_blendmode(bm_add);
      for (var _hc_link_hot = 0; _hc_link_hot < 3; _hc_link_hot++) {
        var _hc_lhf = (_hc_link_hot + 1) / 4;
        var _hc_lhslot = clamp(round(_hc_lhf * (_k_hc_front_socket_count - 1)), 0, _k_hc_front_socket_count - 1);
        var _hc_lhx0 = lerp(76, room_width - 76, (_hc_lhslot + 0.5) / _k_hc_front_socket_count);
        var _hc_lhy0 = _hc_deck_y + 1;
        var _hc_lha = _hc_start_ang + _k_hc_front_arc_span * _hc_lhf;
        var _hc_lhr = max(_k_hc_front_radius0, _hc_radius - _hc_band_w * 0.28);
        var _hc_lhx1 = _hc_cx + lengthdir_x(_hc_lhr, _hc_lha);
        var _hc_lhy1 = _hc_cy + lengthdir_y(_hc_lhr, _hc_lha);

        draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.22 + _hc_heat * 0.24));
        draw_set_alpha(_hc_link_a * (0.055 + _hc_heat * 0.035));
        draw_line_width(_hc_lhx0, _hc_lhy0, _hc_lhx1, _hc_lhy1, 1);
      }
      gpu_set_blendmode(bm_normal);
    }

    gpu_set_blendmode(bm_normal);
    for (var _hc_seg = 0; _hc_seg < _k_hc_front_segments; _hc_seg++) {
      var _hc_gap_hash = frac(sin((_hc_front_phase + 1) * 61.23 + _hc_seg * 17.11) * 43758.5453);
      var _hc_engage = clamp((_hc_seq - _hc_seg) / 4.5, 0, 1);
      if (_hc_is_telegraph) _hc_engage = max(_hc_engage, 0.20 * _hc_front_pre);
      if (_hc_engage <= 0.01) continue;

      var _hc_f0 = _hc_seg / _k_hc_front_segments;
      var _hc_f1 = min(1, (_hc_seg + 0.78 + _hc_gap_hash * 0.18) / _k_hc_front_segments);
      var _hc_a0 = _hc_start_ang + _k_hc_front_arc_span * _hc_f0;
      var _hc_a1 = _hc_start_ang + _k_hc_front_arc_span * _hc_f1;
      var _hc_j0 = (_hc_gap_hash - 0.5) * 8 * (0.25 + _hc_front_p);
      var _hc_j1 = (frac(sin((_hc_front_phase + 3) * 42.71 + _hc_seg * 23.29) * 43758.5453) - 0.5) * 8 * (0.25 + _hc_front_p);
      var _hc_x0 = _hc_cx + lengthdir_x(_hc_radius + _hc_j0, _hc_a0);
      var _hc_y0 = _hc_cy + lengthdir_y(_hc_radius + _hc_j0, _hc_a0);
      var _hc_x1 = _hc_cx + lengthdir_x(_hc_radius + _hc_j1, _hc_a1);
      var _hc_y1 = _hc_cy + lengthdir_y(_hc_radius + _hc_j1, _hc_a1);
      var _hc_seg_a = _hc_front_fade * _hc_engage * (0.74 + _hc_gap_hash * 0.26);
      var _hc_plate_break = (_hc_gap_hash < 0.13 && _hc_is_active);

      draw_set_color(merge_color(global.avoid_col_armor_dark, global.avoid_col_armor_mid, 0.34 + _hc_heat * 0.18));
      draw_set_alpha(_hc_seg_a * (_hc_plate_break ? 0.36 : 0.76));
      draw_line_width(_hc_x0, _hc_y0, _hc_x1, _hc_y1, _hc_band_w * (0.95 + _hc_heat * 0.20));

      draw_set_color(merge_color(global.avoid_col_armor_mid, global.avoid_col_armor_edge, 0.36 + _hc_heat * 0.24));
      draw_set_alpha(_hc_seg_a * (_hc_plate_break ? 0.24 : 0.58));
      draw_line_width(_hc_x0, _hc_y0, _hc_x1, _hc_y1, max(3, _hc_band_w * 0.38));

      if (_hc_is_active && _hc_gap_hash > 0.72) {
        var _hc_clamp_a = (_hc_a0 + _hc_a1) * 0.5;
        var _hc_clamp_r = _hc_radius + (_hc_gap_hash - 0.5) * 5;
        var _hc_clamp_x0 = _hc_cx + lengthdir_x(_hc_clamp_r - _hc_band_w * 0.55, _hc_clamp_a);
        var _hc_clamp_y0 = _hc_cy + lengthdir_y(_hc_clamp_r - _hc_band_w * 0.55, _hc_clamp_a);
        var _hc_clamp_x1 = _hc_cx + lengthdir_x(_hc_clamp_r + _hc_band_w * 0.18, _hc_clamp_a);
        var _hc_clamp_y1 = _hc_cy + lengthdir_y(_hc_clamp_r + _hc_band_w * 0.18, _hc_clamp_a);
        draw_set_color(merge_color(global.avoid_col_armor_edge, c_white, 0.12 + _hc_heat * 0.16));
        draw_set_alpha(_hc_seg_a * 0.56);
        draw_line_width(_hc_clamp_x0, _hc_clamp_y0, _hc_clamp_x1, _hc_clamp_y1, max(2, _hc_band_w * 0.16));
      }
    }

    gpu_set_blendmode(bm_add);
    for (var _hc_hot_seg = 0; _hc_hot_seg < _k_hc_front_segments; _hc_hot_seg++) {
      var _hc_hot_hash = frac(sin((_hc_front_phase + 5) * 71.77 + _hc_hot_seg * 15.07) * 43758.5453);
      if (_hc_hot_hash < 0.10 && _hc_is_active) continue;
      var _hc_hot_engage = clamp((_hc_seq - _hc_hot_seg) / 3.8, 0, 1);
      if (_hc_is_telegraph) _hc_hot_engage *= 0.32;
      if (_hc_hot_engage <= 0.01) continue;

      var _hc_hf0 = _hc_hot_seg / _k_hc_front_segments;
      var _hc_hf1 = min(1, (_hc_hot_seg + 0.68 + _hc_hot_hash * 0.16) / _k_hc_front_segments);
      var _hc_ha0 = _hc_start_ang + _k_hc_front_arc_span * _hc_hf0;
      var _hc_ha1 = _hc_start_ang + _k_hc_front_arc_span * _hc_hf1;
      var _hc_hr0 = _hc_radius + (_hc_hot_hash - 0.5) * 6 * (0.35 + _hc_front_p);
      var _hc_hr1 = _hc_radius + (frac(sin((_hc_front_phase + 7) * 54.3 + _hc_hot_seg * 19.6) * 43758.5453) - 0.5) * 6 * (0.35 + _hc_front_p);
      var _hc_hx0 = _hc_cx + lengthdir_x(_hc_hr0, _hc_ha0);
      var _hc_hy0 = _hc_cy + lengthdir_y(_hc_hr0, _hc_ha0);
      var _hc_hx1 = _hc_cx + lengthdir_x(_hc_hr1, _hc_ha1);
      var _hc_hy1 = _hc_cy + lengthdir_y(_hc_hr1, _hc_ha1);
      var _hc_hot_a = _hc_front_fade * _hc_hot_engage;

      draw_set_color(merge_color(global.avoid_col_warning, global.avoid_col_hot, 0.38 + _hc_heat * 0.42));
      draw_set_alpha(_hc_hot_a * (0.27 + _hc_heat * 0.30));
      draw_line_width(_hc_hx0, _hc_hy0, _hc_hx1, _hc_hy1, max(2, _hc_band_w * 0.18));

      draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.24 + _hc_heat * 0.35));
      draw_set_alpha(_hc_hot_a * (0.13 + _hc_heat * 0.17));
      draw_line_width(_hc_hx0, _hc_hy0, _hc_hx1, _hc_hy1, 1.3 + _hc_heat * 1.4);

      if (_hc_heat > 0.18 && _hc_hot_hash > 0.78) {
        var _hc_hot_clamp_a = (_hc_ha0 + _hc_ha1) * 0.5;
        var _hc_hot_clamp_r = _hc_radius + (_hc_hot_hash - 0.5) * 4;
        draw_set_color(merge_color(global.avoid_col_hot, c_white, 0.38));
        draw_set_alpha(_hc_hot_a * _hc_heat * 0.18);
        draw_line_width(_hc_cx + lengthdir_x(_hc_hot_clamp_r - _hc_band_w * 0.42, _hc_hot_clamp_a),
                        _hc_cy + lengthdir_y(_hc_hot_clamp_r - _hc_band_w * 0.42, _hc_hot_clamp_a),
                        _hc_cx + lengthdir_x(_hc_hot_clamp_r + _hc_band_w * 0.12, _hc_hot_clamp_a),
                        _hc_cy + lengthdir_y(_hc_hot_clamp_r + _hc_band_w * 0.12, _hc_hot_clamp_a),
                        max(1, _hc_band_w * 0.09));
      }

      if (_hc_heat > 0.22 && _hc_hot_hash > 0.70) {
        draw_set_color(c_white);
        draw_set_alpha(_hc_hot_a * _hc_heat * 0.14);
        draw_line_width(_hc_hx0, _hc_hy0, _hc_hx1, _hc_hy1, 1);
      }
    }
    gpu_set_blendmode(bm_normal);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}


var _er_env_live = (t >= _k_er_lift_charge_t && t <= erupt_active_until)
                || er_lift_active
                || erupt_collapsing || erupt_despawn_active
                || array_length(erupt_lane_residue) > 0;
var _er_env_a = 0;
if (_er_env_live) {
  var _er_env_lift_a = clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_lock_t - _k_er_lift_charge_t, 1), 0, 1);
  var _er_env_mat_a  = clamp((t - _k_er_materialize_t) / max(_k_er_materialize_dur, 1), 0, 1);
  _er_env_a = max(_er_env_lift_a, _er_env_mat_a);
  if (erupt_collapsing) {
    _er_env_a *= 1 - clamp(erupt_collapse_timer / max(_k_er_collapse_duration, 1), 0, 1) * 0.35;
  }
  if (erupt_despawn_active) {
    _er_env_a *= power(1 - clamp(erupt_despawn_timer / max(_k_er_despawn_duration, 1), 0, 1), 0.65);
  }
}

if (_er_env_a > 0.02) {
  var _er_env_heat = clamp(erupt_floor_heat + erupt_pressure * 0.18
                         + erupt_coil * 0.35 + erupt_flash * 0.18, 0, 1);
  var _er_lift_carrying = er_lift_active && er_lift_top_y < _k_er_lift_start_top_y + 20;
  var _er_env_top = _k_er_floor_y - 188;
  if (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 12) {
    _er_env_top = er_lift_top_y + _k_er_lift_body_h + 8;
  }
  var _er_env_bot = _k_er_floor_y - 8;
  var _er_env_col_a = _er_env_a * (0.18 + _er_env_heat * 0.10);
  var _er_env_lip_a = _er_env_a * (0.16 + _er_env_heat * 0.14);

  draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.16));
  draw_set_alpha(_er_env_col_a);
  draw_rectangle(-24, _er_env_bot + 14, room_width + 24, _er_env_bot + 54, false);

  var _er_env_panel_n = 12;
  for (var _ep = 0; _ep < _er_env_panel_n; _ep++) {
    var _ep_w = room_width / _er_env_panel_n;
    var _ep_x1 = _ep * _ep_w + 3;
    var _ep_x2 = _ep_x1 + _ep_w * 0.72;
    var _ep_hash = frac(sin(_ep * 17.37 + 4.1) * 43758.5453);
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.12 + _ep_hash * 0.20));
    draw_set_alpha(_er_env_a * (0.13 + _er_env_heat * 0.06));
    draw_rectangle(_ep_x1, _er_env_bot + 19, _ep_x2, _er_env_bot + 36, false);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.12));
    draw_set_alpha(_er_env_a * (0.06 + _er_env_heat * 0.05));
    draw_line_width(_ep_x1 + 2, _er_env_bot + 20, _ep_x2 - 2, _er_env_bot + 20, 1);
  }

  var _er_support_n = 6;
  var _er_support_head_y = _er_lift_carrying
                         ? (er_lift_top_y + _k_er_lift_body_h + 9)
                         : (_k_er_floor_y - 14);
  var _er_support_sleeve_top = max(_er_support_head_y + 42,
                                   _k_er_floor_base_y + 22 - _er_env_heat * 10);
  var _er_support_bot = room_height + 22;
  for (var _sup = 0; _sup < _er_support_n; _sup++) {
    var _sf = _sup / max(1, _er_support_n - 1);
    var _sx = lerp(58, room_width - 58, _sf);
    var _phase = sin(t * 0.035 + _sup * 1.73);
    var _load = clamp(0.45 + erupt_pressure * 0.28 + erupt_coil * 0.32
                    + max(0, _phase) * 0.12, 0, 1);
    var _outer_w = 34 + ((_sup mod 2 == 0) ? 5 : 0);
    var _inner_w = _outer_w * 0.34;
    var _cap_w = 58;
    var _top_cap_y = _er_support_head_y + _phase * 1.2;
    var _sleeve_top = _er_support_sleeve_top + ((_sup mod 2) * 10);
    var _boot_w = _outer_w * 1.34;

    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.36));
    draw_set_alpha(_er_env_a * (0.58 + _load * 0.18));
    draw_rectangle(_sx - _outer_w * 0.5, _sleeve_top,
                   _sx + _outer_w * 0.5, _er_support_bot, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sx - _outer_w * 0.5, _sleeve_top,
                       merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.32), _er_env_a * 0.62);
    draw_vertex_colour(_sx + _outer_w * 0.5, _sleeve_top,
                       merge_color(c_black, _k_er_col_armor_dark, 0.20), _er_env_a * 0.62);
    draw_vertex_colour(_sx - _outer_w * 0.5, _er_support_bot,
                       c_black, _er_env_a * 0.72);
    draw_vertex_colour(_sx + _outer_w * 0.5, _er_support_bot,
                       _k_er_col_armor_dark, _er_env_a * 0.72);
    draw_primitive_end();

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.20 + _load * 0.12));
    draw_set_alpha(_er_env_a * (0.44 + _load * 0.16));
    draw_rectangle(_sx - _inner_w * 0.5, _top_cap_y + 9,
                   _sx + _inner_w * 0.5, _sleeve_top + 16, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sx - _boot_w * 0.5, _sleeve_top - 9,
                       _k_er_col_armor_dark, _er_env_a * 0.78);
    draw_vertex_colour(_sx + _boot_w * 0.5, _sleeve_top - 9,
                       merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.20), _er_env_a * 0.78);
    draw_vertex_colour(_sx - _outer_w * 0.5, _sleeve_top + 7,
                       c_black, _er_env_a * 0.82);
    draw_vertex_colour(_sx + _outer_w * 0.5, _sleeve_top + 7,
                       _k_er_col_armor_dark, _er_env_a * 0.82);
    draw_primitive_end();

    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_er_env_a * 0.78);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_sx, _top_cap_y + 7,
                       merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.20 + _load * 0.12), _er_env_a * 0.9);
    draw_vertex_colour(_sx - _cap_w * 0.5, _top_cap_y + 2, _k_er_col_armor_dark, _er_env_a * 0.9);
    draw_vertex_colour(_sx - _cap_w * 0.34, _top_cap_y - 8, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.24), _er_env_a * 0.9);
    draw_vertex_colour(_sx + _cap_w * 0.34, _top_cap_y - 8, merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.18), _er_env_a * 0.9);
    draw_vertex_colour(_sx + _cap_w * 0.5, _top_cap_y + 2, _k_er_col_armor_dark, _er_env_a * 0.9);
    draw_vertex_colour(_sx + _cap_w * 0.38, _top_cap_y + 16, merge_color(c_black, _k_er_col_armor_dark, 0.24), _er_env_a * 0.9);
    draw_vertex_colour(_sx - _cap_w * 0.38, _top_cap_y + 16, _k_er_col_armor_dark, _er_env_a * 0.9);
    draw_vertex_colour(_sx - _cap_w * 0.5, _top_cap_y + 2, _k_er_col_armor_dark, _er_env_a * 0.9);
    draw_primitive_end();
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.10 + _load * 0.16));
    draw_set_alpha(_er_env_a * (0.34 + _load * 0.22));
    draw_line_width(_sx - _cap_w * 0.34, _top_cap_y - 7,
                    _sx + _cap_w * 0.34, _top_cap_y - 7, 1.5);
    draw_line_width(_sx - _cap_w * 0.43, _top_cap_y + 15,
                    _sx + _cap_w * 0.43, _top_cap_y + 15, 1);

    if (_er_lift_carrying) {
      draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_edge, 0.28));
      draw_set_alpha(_er_env_a * (0.58 + _load * 0.16));
      draw_line_width(_sx - _cap_w * 0.42, _top_cap_y - 9,
                      _sx + _cap_w * 0.42, _top_cap_y - 9, 3);
    }

    var _collar_n = 3;
    for (var _colr = 0; _colr < _collar_n; _colr++) {
      var _cy = lerp(_sleeve_top + 22, _er_support_bot - 24, (_colr + 0.5) / _collar_n);
      draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.24));
      draw_set_alpha(_er_env_a * (0.28 + _load * 0.08));
      draw_rectangle(_sx - _outer_w * 0.58, _cy - 3,
                     _sx + _outer_w * 0.58, _cy + 3, false);
    }

    for (var _side = -1; _side <= 1; _side += 2) {
      draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.28));
      draw_set_alpha(_er_env_a * (0.22 + _load * 0.08));
      draw_line_width(_sx + _side * (_outer_w * 0.56), _sleeve_top + 5,
                      _sx + _side * (_outer_w * 1.20), _er_support_bot - 20, 2);
    }
  }

  var _er_env_rail_n = 7;
  for (var _er = 0; _er < _er_env_rail_n; _er++) {
    var _rf = _er / max(1, _er_env_rail_n - 1);
    var _rx = lerp(54, room_width - 54, _rf);
    var _lean = sin(_er * 2.31 + t * 0.015) * 1.5;
    var _rw = (_er mod 2 == 0) ? 8 : 6;

    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.35));
    draw_set_alpha(_er_env_a * (0.34 + _er_env_heat * 0.10));
    draw_rectangle(_rx - _rw * 0.5, _er_env_top, _rx + _rw * 0.5, _er_env_bot, false);

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.18));
    draw_set_alpha(_er_env_lip_a);
    draw_line_width(_rx - _rw * 0.5, _er_env_top + 3, _rx - _rw * 0.5 + _lean, _er_env_bot - 3, 1);
    draw_line_width(_rx + _rw * 0.5, _er_env_top + 3, _rx + _rw * 0.5 + _lean, _er_env_bot - 3, 1);

    if (_er < _er_env_rail_n - 1) {
      var _nx = lerp(54, room_width - 54, (_er + 1) / max(1, _er_env_rail_n - 1));
      var _bay_a = _er_env_a * (0.07 + _er_env_heat * 0.03);
      for (var _brace = 0; _brace < 3; _brace++) {
        var _by1 = lerp(_er_env_top + 10, _er_env_bot - 34, _brace / 3);
        var _by2 = _by1 + 30;
        var _flip = ((_brace + _er) mod 2 == 0);
        draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.22));
        draw_set_alpha(_bay_a);
        if (_flip) {
          draw_line_width(_rx + 8, _by1, _nx - 8, _by2, 1);
        } else {
          draw_line_width(_nx - 8, _by1, _rx + 8, _by2, 1);
        }
      }
    }
  }

  if (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 12) {
    var _er_manifold_y = er_lift_top_y + _k_er_lift_body_h + 6;
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.24));
    draw_set_alpha(_er_env_a * (0.28 + _er_env_heat * 0.10));
    draw_rectangle(-18, _er_manifold_y - 6, room_width + 18, _er_manifold_y + 8, false);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.10 + _er_env_heat * 0.08));
    draw_set_alpha(_er_env_a * (0.16 + _er_env_heat * 0.10));
    draw_line_width(0, _er_manifold_y - 5, room_width, _er_manifold_y - 5, 1.5);

    for (var _mv = 0; _mv < 10; _mv++) {
      var _mx = lerp(30, room_width - 30, _mv / 9);
      var _slot_w = 18 + 6 * frac(sin(_mv * 11.9) * 43758.5453);
      draw_set_color(c_black);
      draw_set_alpha(_er_env_a * 0.42);
      draw_rectangle(_mx - _slot_w * 0.5, _er_manifold_y - 3,
                     _mx + _slot_w * 0.5, _er_manifold_y + 4, false);
    }
  }

  for (var _lr = 0; _lr < array_length(erupt_lane_residue); _lr++) {
    var _res = erupt_lane_residue[_lr];
    var _ra = clamp(_res.life / max(_res.life_max, 1), 0, 1);
    var _cool = power(_ra, 0.55);
    var _lw = _res.w;
    var _x1r = _res.cx - _lw * 0.5;
    var _x2r = _res.cx + _lw * 0.5;
    var _lr_a = _er_env_a * _cool * (0.16 + _res.hot * 0.08);

    draw_set_color(c_black);
    draw_set_alpha(_lr_a * 0.65);
    draw_rectangle(_x1r - 5, _er_env_bot - 3, _x2r + 5, _er_env_bot + 18, false);

    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.18 + _res.hot * 0.12));
    draw_set_alpha(_lr_a);
    draw_line_width(_x1r, _er_env_top + 8, _x1r, _er_env_bot, _res.fast ? 1.5 : 2);
    draw_line_width(_x2r, _er_env_top + 8, _x2r, _er_env_bot, _res.fast ? 1.5 : 2);

    var _rib_n = _res.fast ? 1 : 2;
    for (var _rb = 0; _rb < _rib_n; _rb++) {
      var _rf2 = (_rb + 1) / (_rib_n + 1);
      var _rx2 = lerp(_x1r, _x2r, _rf2);
      draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_armor_mid, 0.36));
      draw_set_alpha(_lr_a * 0.65);
      draw_line_width(_rx2, _er_env_bot - 46, _rx2, _er_env_bot + 8, 1);
    }
  }

  if (erupt_coil > 0.01 && array_length(erupt_armed_cols) > 0) {
    for (var _al = 0; _al < array_length(erupt_armed_cols); _al++) {
      var _ac_env = erupt_armed_cols[_al];
      var _x1a = _ac_env.cx - _ac_env.w * 0.5;
      var _x2a = _ac_env.cx + _ac_env.w * 0.5;
      var _aa_env = _er_env_a * (0.20 + erupt_coil * 0.26);

      draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.22));
      draw_set_alpha(_aa_env * 0.72);
      draw_rectangle(_x1a - 4, _er_env_top + 4, _x1a + 3, _er_env_bot, false);
      draw_rectangle(_x2a - 3, _er_env_top + 4, _x2a + 4, _er_env_bot, false);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, erupt_coil * 0.22));
      draw_set_alpha(_aa_env);
      draw_line_width(_x1a, _er_env_top + 4, _x1a, _er_env_bot + 2, 1.5);
      draw_line_width(_x2a, _er_env_top + 4, _x2a, _er_env_bot + 2, 1.5);
      draw_line_width(_x1a, _er_env_top + 7, _x2a, _er_env_top + 7, 1);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

var _er_grid_a = clamp((t - _k_er_materialize_t) / _k_er_materialize_dur, 0, 1);
if (t >= _k_cube_t_spawn) _er_grid_a = 0;
if (erupt_collapsing) _er_grid_a *= 1 - clamp(erupt_collapse_timer / _k_er_collapse_duration, 0, 1);
if (erupt_despawn_active) _er_grid_a *= 1 - clamp(erupt_despawn_timer / _k_er_despawn_duration, 0, 1);
if (_er_grid_a > 0.02) {
  var _plate_w = _k_er_grid_plate_w;
  var _nplates = floor(room_width / _plate_w);
  var _grid_y = _k_er_floor_y - 4;
  var _gt = current_time * 0.001;

  draw_set_color(_k_er_col_armor_dark);
  draw_set_alpha(_er_grid_a * 0.28);
  draw_rectangle(-18, _grid_y + 1, room_width + 18, _grid_y + 42, false);
  draw_set_color(merge_color(_k_er_col_armor_hi, _k_er_col_cyan, 0.30));
  draw_set_alpha(_er_grid_a * 0.22);
  for (var _rail = 0; _rail < 4; _rail++) {
    draw_line_width(0, _grid_y + 7 + _rail * 9, room_width, _grid_y + 7 + _rail * 9, 1);
  }
  draw_set_alpha(1);

  gpu_set_blendmode(bm_add);

  for (var p = 0; p <= _nplates; p++) {
    var _px = p * _plate_w;
    var _hash = frac(sin(p * 127.1 + 311.7) * 43758.5453);
    var _gcol = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.35 + _hash * 0.4);
    var _ga = _er_grid_a * _k_er_grid_trace_a * (0.5 + _hash * 0.5);

    draw_set_color(_gcol);
    draw_set_alpha(_ga);
    draw_line_width(_px, _grid_y + 8 * _hash, _px, _grid_y - 1, 1);
    draw_circle(_px, _grid_y - 2, 1.6, false);
    draw_set_color(merge_color(_gcol, c_white, 0.5));
    draw_set_alpha(_ga * 0.8);
    draw_circle(_px, _grid_y - 2, 0.7, false);

    if (p < _nplates) {
      var _px2 = _px + _plate_w;
      var _sag = 2 + sin(_hash * 6.28 + _gt) * 2;
      draw_line_width(_px, _grid_y - 1, _px + _plate_w * 0.5, _grid_y + _sag, 1);
      draw_line_width(_px + _plate_w * 0.5, _grid_y + _sag, _px2, _grid_y - 1, 1);
      if (p mod 2 == 0) {
        draw_set_alpha(_ga * 0.45);
        draw_line_width(_px + 6, _grid_y - 14, _px2 - 6, _grid_y - 14, 1);
      }
    }
  }

  if (erupt_coil > 0.01 && array_length(erupt_armed_cols) > 0) {
    for (var i = 0; i < array_length(erupt_armed_cols); i++) {
      var _ac = erupt_armed_cols[i];
      var _x1 = _ac.cx - _ac.w * 0.5;
      var _x2 = _ac.cx + _ac.w * 0.5;

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, erupt_coil));
      draw_set_alpha(erupt_coil * 0.5);
      draw_line_width(_x1, _grid_y, _x2, _grid_y, 2);

      var _tick_n = 2 + floor(erupt_coil * 5);
      for (var s = 0; s < _tick_n; s++) {
        var _tx = lerp(_x1 + 4, _x2 - 4, frac(_hash * 3.7 + s * 0.37));
        var _flick = 0.4 + 0.6 * frac(sin(_tx * 12.9898 + _gt * 40) * 43758.5453);
        draw_set_color(c_white);
        draw_set_alpha(erupt_coil * _flick * 0.8);
        draw_line_width(_tx, _grid_y - 8 - frac(sin(_tx * 7.7 + _gt * 33) * 43758.5453) * 12,
                        _tx, _grid_y - 1, 1.5);
      }
    }
    draw_set_color(c_white);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(erupt_scars) > 0) {
  for (var i = 0; i < array_length(erupt_scars); i++) {
    var _sc = erupt_scars[i];
    var _sa = clamp(_sc.life / _sc.life_max, 0, 1);
    var _depth = 4 + _sc.hot * 7;
    var _x1 = _sc.cx - _sc.w * 0.5;
    var _x2 = _sc.cx + _sc.w * 0.5;

    var _segs = max(3, round(_sc.w / 26));
    draw_primitive_begin(pr_trianglestrip);
    for (var s = 0; s <= _segs; s++) {
      var _sx = lerp(_x1, _x2, s / _segs);
      var _lip = _k_er_floor_y + sin(_sc.seed + s * 2.3) * 2;
      draw_vertex_colour(_sx, _lip, c_black, _sa * 0.85);
      draw_vertex_colour(_sx, _lip + _depth + sin(_sc.seed * 0.7 + s * 1.1) * 3, c_black, _sa * 0.5);
    }
    draw_primitive_end();

    var _sflick = 0.5 + 0.5 * sin(_sc.seed * 9 + current_time * 0.006);
    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.4 + _sc.hot * 0.5));
    draw_set_alpha(_sa * _sflick * (0.28 + _sc.hot * 0.3));
    draw_line_width(_x1 - 2, _k_er_floor_y - 2, _x2 + 2, _k_er_floor_y - 2, 2);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.7));
    draw_set_alpha(_sa * _sflick * (0.3 + _sc.hot * 0.35));
    for (var s2 = 0; s2 < 3; s2++) {
      var _s2x = lerp(_x1 + 6, _x2 - 6, frac(sin(_sc.seed * 13.7 + s2 * 0.37) * 43758.5453));
      draw_line_width(_s2x, _k_er_floor_y - 1, _s2x - 3 + s2 * 2, _k_er_floor_y - 5 - s2, 1.5);
    }
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
  }
}

if (erupt_coil > 0.01 && array_length(erupt_armed_cols) > 0) {
  var _seam_open = erupt_coil;
  for (var i = 0; i < array_length(erupt_armed_cols); i++) {
    var _ac = erupt_armed_cols[i];
    var _x1 = _ac.cx - _ac.w * 0.5;
    var _x2 = _ac.cx + _ac.w * 0.5;
    var _slot = 3 + _seam_open * (erupt_armed_fast ? 12 : 22);

    var _segs = max(2, round(_ac.w / 24));
    draw_primitive_begin(pr_trianglestrip);
    for (var s = 0; s <= _segs; s++) {
      var _sx = lerp(_x1, _x2, s / _segs);
      var _crumble = sin(_ac.cx * 0.05 + s * 1.9) * _seam_open * 4;
      draw_vertex_colour(_sx, _k_er_floor_y - 1 + _crumble, c_black, 0.95);
      draw_vertex_colour(_sx, _k_er_floor_y + _slot, c_black, 0.35);
    }
    draw_primitive_end();

    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(0.22 + _seam_open * 0.5);
    draw_line_width(_x1 + 1, _k_er_floor_y + _slot - 1, _x2 - 1, _k_er_floor_y + _slot - 1, 1.5);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _seam_open));
    draw_set_alpha(0.18 + _seam_open * 0.4);
    draw_line_width(_x1 + 1, _k_er_floor_y + _slot - 3, _x2 - 1, _k_er_floor_y + _slot - 3, 2.5);

    var _sflick2 = 0.5 + 0.5 * frac(sin(_ac.cx * 12.9898 + current_time * 0.005) * 43758.5453);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.6));
    draw_set_alpha(_seam_open * (0.35 + _sflick2 * 0.45));
    for (var sgn = -1; sgn <= 1; sgn += 2) {
      var _ex = (sgn < 0) ? _x1 : _x2;
      draw_line_width(_ex, _k_er_floor_y - 4, _ex + sgn * 8, _k_er_floor_y - 2, 1.5);
      draw_line_width(_ex, _k_er_floor_y - 4, _ex + sgn * 2, _k_er_floor_y - 8 - _sflick2 * 4, 1.5);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
  }
}

var _side_warn_p = clamp((t - (_k_er_side_burst_t - _k_er_side_burst_warn_lead))
                       / max(_k_er_side_burst_warn_lead, 1), 0, 1);
if (t >= _k_er_side_burst_t - _k_er_side_burst_warn_lead && t < _k_er_side_burst_t &&
    er_lift_active) {
  var _wy_new      = er_lift_top_y + _k_er_side_burst_y_off;
  var _wr_new      = _k_er_side_warn_lane_r;
  var _coil_new    = max(_side_warn_p, _k_er_side_warn_read_floor);
  var _hot_new     = _coil_new * _coil_new;
  var _gate_w_new  = _k_er_side_warn_gate_w;
  var _head_l_new  = lerp(_gate_w_new * 0.72, room_width * 0.5 - 10, power(_side_warn_p, 0.78));
  var _head_r_new  = room_width - _head_l_new;
  var _col_new     = merge_color(_k_er_col_warning, make_color_rgb(246, 254, 255), _hot_new * 0.55);
  var _cyan_new    = merge_color(_k_er_col_cyan, c_white, _hot_new * 0.42);
  var _strobe_new  = clamp((_side_warn_p - 0.75) / 0.25, 0, 1);
  var _pulse_new   = lerp(0.72 + 0.28 * sin(t * 0.85),
                          0.32 + 0.68 * abs(sin(t * 1.9)), _strobe_new);

  var _slot_r_new = _wr_new * 2.4;
  var _hold_new   = _wr_new * (1.03 + _coil_new * 0.12);
  var _slot_a_new = _k_er_side_warn_slot_a[0]
                  + (_k_er_side_warn_slot_a[1] - _k_er_side_warn_slot_a[0]) * _coil_new;

  draw_set_color(c_black);
  draw_set_alpha(_slot_a_new);
  draw_rectangle(0, _wy_new - _hold_new, room_width, _wy_new + _hold_new, false);

  for (var _sgn_new = -1; _sgn_new <= 1; _sgn_new += 2) {
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(0,          _wy_new + _sgn_new * _hold_new,   c_black, _slot_a_new);
    draw_vertex_colour(room_width, _wy_new + _sgn_new * _hold_new,   c_black, _slot_a_new);
    draw_vertex_colour(0,          _wy_new + _sgn_new * _slot_r_new, c_black, 0);
    draw_vertex_colour(room_width, _wy_new + _sgn_new * _slot_r_new, c_black, 0);
    draw_primitive_end();
  }

  var _cell_w_new = 52;
  var _cell_n_new = ceil(room_width / _cell_w_new);
  for (var _ci_new = 0; _ci_new < _cell_n_new; _ci_new++) {
    var _hsh_new = frac(sin(_ci_new * 39.71 + 4.2) * 43758.5453);
    var _cx0_new = _ci_new * _cell_w_new + 3 + _hsh_new * 8;
    var _cx1_new = min(room_width, _cx0_new + _cell_w_new * (0.56 + _hsh_new * 0.22));
    if (_cx1_new <= _cx0_new) continue;

    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.18 + _hsh_new * 0.24));
    draw_set_alpha((0.28 + _hot_new * 0.10) * _slot_a_new);
    draw_rectangle(_cx0_new, _wy_new - _wr_new * 0.72, _cx1_new, _wy_new + _wr_new * 0.72, false);
  }

  gpu_set_blendmode(bm_add);

  draw_set_color(_cyan_new);
  draw_set_alpha((0.10 + _hot_new * 0.16) * _pulse_new);
  draw_line_width(0, _wy_new, room_width, _wy_new, 2 + _coil_new * 5);

  var _deep_new = 16 + _hot_new * _k_er_side_warn_spill * 0.72;
  var _spills_new = [
    [ 1.00, 0.09 + _hot_new * 0.10, 0.00 ],
    [ 0.38, 0.12 + _hot_new * 0.14, 0.38 ],
    [ 0.14, 0.16 + _hot_new * 0.22, 0.82 ]
  ];

  for (var _sp_new = 0; _sp_new < 3; _sp_new++) {
    var _pass_new = _spills_new[_sp_new];
    var _pdep_new = _deep_new * _pass_new[0];
    var _pcol_new = merge_color(_col_new, c_white, _pass_new[2]);
    var _pa_new   = min(1, _pass_new[1]);

    for (var _sg2_new = -1; _sg2_new <= 1; _sg2_new += 2) {
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(0,          _wy_new, _pcol_new, _pa_new);
      draw_vertex_colour(room_width, _wy_new, _pcol_new, _pa_new);
      draw_vertex_colour(0,          _wy_new + _sg2_new * _pdep_new, _pcol_new, 0);
      draw_vertex_colour(room_width, _wy_new + _sg2_new * _pdep_new, _pcol_new, 0);
      draw_primitive_end();
    }
  }

  var _fringe_new = 2 + _hot_new * 6;
  for (var _lip_sgn_new = -1; _lip_sgn_new <= 1; _lip_sgn_new += 2) {
    var _lip_y_new = _wy_new + _lip_sgn_new * _wr_new;

    draw_set_color(_col_new);
    draw_set_alpha(0.22 + _hot_new * 0.48);
    draw_line_width(0, _lip_y_new, room_width, _lip_y_new, 2.5 + _coil_new * 3.5);

    draw_set_color(c_white);
    draw_set_alpha(0.22 + _hot_new * 0.56);
    draw_line_width(0, _lip_y_new, room_width, _lip_y_new, 1 + _coil_new * 2);

    draw_set_color(_k_er_col_warning);
    draw_set_alpha(0.10 + _hot_new * 0.28);
    draw_line_width(0, _lip_y_new - _lip_sgn_new * _fringe_new,
                    room_width, _lip_y_new - _lip_sgn_new * _fringe_new, 2.5);
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(0.10 + _hot_new * 0.28);
    draw_line_width(0, _lip_y_new + _lip_sgn_new * _fringe_new,
                    room_width, _lip_y_new + _lip_sgn_new * _fringe_new, 2.5);
  }

  for (var _side_new = 0; _side_new < 2; _side_new++) {
    var _mx_new   = (_side_new == 0) ? 0 : room_width;
    var _dir_new  = (_side_new == 0) ? 1 : -1;
    var _gx0_new  = (_side_new == 0) ? 0 : room_width - _gate_w_new;
    var _gx1_new  = (_side_new == 0) ? _gate_w_new : room_width;
    var _head_new = (_side_new == 0) ? _head_l_new : _head_r_new;

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(0.42 + _hot_new * 0.28);
    draw_rectangle(_gx0_new, _wy_new - _wr_new * 1.75,
                   _gx1_new, _wy_new + _wr_new * 1.75, false);
    gpu_set_blendmode(bm_add);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_mx_new, _wy_new - _wr_new * 2.3, c_white, 0.20 + _hot_new * 0.58);
    draw_vertex_colour(_mx_new, _wy_new + _wr_new * 2.3, c_white, 0.20 + _hot_new * 0.58);
    draw_vertex_colour(_mx_new + _dir_new * (44 + _hot_new * 112), _wy_new - _wr_new * 0.55, _col_new, 0);
    draw_vertex_colour(_mx_new + _dir_new * (44 + _hot_new * 112), _wy_new + _wr_new * 0.55, _col_new, 0);
    draw_primitive_end();

    scr_draw_lock_bracket(_gx0_new + 4, _wy_new - _wr_new * 1.62,
                          _gx1_new - 4, _wy_new + _wr_new * 1.62,
                          _k_er_col_warning, _coil_new, 1,
                          14, false, 4, 0, _pulse_new, _k_er_col_cyan);

    draw_set_color(c_white);
    draw_set_alpha((0.35 + _hot_new * 0.50) * _pulse_new);
    draw_line_width(_head_new, _wy_new - _wr_new * 1.45,
                    _head_new, _wy_new + _wr_new * 1.45, 2 + _coil_new * 2);
    draw_set_color(_k_er_col_warning);
    draw_set_alpha((0.25 + _hot_new * 0.45) * _pulse_new);
    draw_line_width(_head_new, _wy_new - _wr_new * 2.4,
                    _head_new, _wy_new + _wr_new * 2.4, 1.5);

    for (var _pk_new = 0; _pk_new < _k_er_side_warn_packet_n; _pk_new++) {
      var _pf_new = frac(_pk_new / _k_er_side_warn_packet_n
                         + current_time * 0.0014 * (0.8 + _coil_new));
      var _px_new = (_side_new == 0) ? lerp(_mx_new + 10, _head_new, _pf_new)
                                     : lerp(_mx_new - 10, _head_new, _pf_new);
      var _pa2_new = sin(_pf_new * pi) * (0.22 + _hot_new * 0.52);
      var _cw_new = 6 + _coil_new * 6;
      var _pk_col_new = ((_pk_new mod 3) == 0) ? _k_er_col_cyan
                       : (((_pk_new mod 3) == 1) ? _k_er_col_warning : _k_er_col_violet);

      draw_set_color(merge_color(_pk_col_new, c_white, 0.28 + _hot_new * 0.42));
      draw_set_alpha(_pa2_new);
      draw_line_width(_px_new - _dir_new * (18 + _coil_new * 18), _wy_new,
                      _px_new + _dir_new * (4 + _coil_new * 6), _wy_new, 2.5);

      draw_set_color(c_white);
      draw_set_alpha(_pa2_new * 0.58);
      draw_line_width(_px_new - _dir_new * _cw_new, _wy_new - _cw_new,
                      _px_new, _wy_new, 1.5);
      draw_line_width(_px_new - _dir_new * _cw_new, _wy_new + _cw_new,
                      _px_new, _wy_new, 1.5);
    }
  }

  scr_draw_lock_bracket(18, _wy_new - _wr_new, room_width - 18, _wy_new + _wr_new,
                        _k_er_col_warning, _coil_new, 0.95,
                        14, false, 0, 0, _pulse_new, _k_er_col_cyan);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}
if (false && t >= _k_er_side_burst_t - _k_er_side_burst_warn_lead && t < _k_er_side_burst_t &&
    er_lift_active) {
  var _wy   = er_lift_top_y + _k_er_side_burst_y_off;
  var _wr   = _k_er_side_warn_lane_r;
  var _coil = max(_side_warn_p, _k_er_side_warn_read_floor);
  var _hot  = _coil * _coil;
  var _reach = lerp(room_width * 0.225, room_width * 0.5 + 24, power(_side_warn_p, 0.7));
  var _lx = _reach;
  var _rx = room_width - _reach;
  var _col = merge_color(_k_er_col_warning, make_color_rgb(246, 254, 255), _hot * 0.55);

  var _strobe_p = clamp((_side_warn_p - 0.75) / 0.25, 0, 1);
  var _pulse = lerp(0.72 + 0.28 * sin(t * 0.85), 0.32 + 0.68 * abs(sin(t * 1.9)), _strobe_p);

  var _slot_r = _wr * 2.4;
  var _hold   = _wr * 1.3;
  var _slot_a = _k_er_side_warn_slot_a[0]
              + (_k_er_side_warn_slot_a[1] - _k_er_side_warn_slot_a[0]) * _coil;

  for (var _sh = 0; _sh < 2; _sh++) {
    var _sx0 = (_sh == 0) ? 0 : _rx;
    var _sx1 = (_sh == 0) ? _lx : room_width;

    draw_set_color(c_black);
    draw_set_alpha(_slot_a);
    draw_rectangle(_sx0, _wy - _hold, _sx1, _wy + _hold, false);

    for (var _sg = -1; _sg <= 1; _sg += 2) {
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(_sx0, _wy + _sg * _hold,   c_black, _slot_a);
      draw_vertex_colour(_sx1, _wy + _sg * _hold,   c_black, _slot_a);
      draw_vertex_colour(_sx0, _wy + _sg * _slot_r, c_black, 0);
      draw_vertex_colour(_sx1, _wy + _sg * _slot_r, c_black, 0);
      draw_primitive_end();
    }
  }

  gpu_set_blendmode(bm_add);

  var _deep = 20 + _hot * _k_er_side_warn_spill;
  var _p1 = [ 1.00,       0.16 + _hot * 0.16,   0.00 ];
  var _p2 = [ 0.40,       0.18 + _hot * 0.20,   0.35 ];
  var _p3 = [ 0.17,       0.22 + _hot * 0.34,   0.80 ];
  var _spill_passes = [ _p1, _p2, _p3 ];

  for (var _sh = 0; _sh < 2; _sh++) {
    var _sx0 = (_sh == 0) ? 0 : _rx;
    var _sx1 = (_sh == 0) ? _lx : room_width;

    for (var _p = 0; _p < 3; _p++) {
      var _pass = _spill_passes[_p];
      var _pdep = _deep * _pass[0];
      var _pcol = merge_color(_col, c_white, _pass[2]);
      var _pa   = min(1, _pass[1]);

      for (var _sg = -1; _sg <= 1; _sg += 2) {
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_sx0, _wy, _pcol, _pa);
        draw_vertex_colour(_sx1, _wy, _pcol, _pa);
        draw_vertex_colour(_sx0, _wy + _sg * _pdep, _pcol, 0);
        draw_vertex_colour(_sx1, _wy + _sg * _pdep, _pcol, 0);
        draw_primitive_end();
      }
    }
  }

  var _fringe = 2 + _hot * 6;
  for (var _sh = 0; _sh < 2; _sh++) {
    var _sx0 = (_sh == 0) ? 0 : _rx;
    var _sx1 = (_sh == 0) ? _lx : room_width;

    for (var _sg = -1; _sg <= 1; _sg += 2) {
      var _ly = _wy + _sg * _wr;

      draw_set_color(_col);
      draw_set_alpha(0.25 + _hot * 0.55);
      draw_line_width(_sx0, _ly, _sx1, _ly, 3 + _coil * 4);

      draw_set_color(c_white);
      draw_set_alpha(0.30 + _hot * 0.62);
      draw_line_width(_sx0, _ly, _sx1, _ly, 1.5 + _coil * 2.5);

      draw_set_color(c_red);
      draw_set_alpha(0.10 + _hot * 0.30);
      draw_line_width(_sx0, _ly - _fringe, _sx1, _ly - _fringe, 3);
      draw_set_color(_k_er_col_cyan);
      draw_set_alpha(0.10 + _hot * 0.30);
      draw_line_width(_sx0, _ly + _fringe, _sx1, _ly + _fringe, 3);
    }
  }

  for (var _sh = 0; _sh < 2; _sh++) {
    var _mx   = (_sh == 0) ? 0 : room_width;
    var _head = (_sh == 0) ? _lx : _rx;
    var _dir  = (_sh == 0) ? 1 : -1;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_mx, _wy - _wr * 2.2, c_white, 0.20 + _hot * 0.55);
    draw_vertex_colour(_mx, _wy + _wr * 2.2, c_white, 0.20 + _hot * 0.55);
    draw_vertex_colour(_mx + _dir * (30 + _hot * 90), _wy - _wr * 0.7, _col, 0);
    draw_vertex_colour(_mx + _dir * (30 + _hot * 90), _wy + _wr * 0.7, _col, 0);
    draw_primitive_end();

    draw_set_color(c_white);
    draw_set_alpha((0.35 + _hot * 0.5) * _pulse);
    draw_line_width(_head, _wy - _wr * 1.5, _head, _wy + _wr * 1.5, 2 + _coil * 2);
    draw_set_color(_k_er_col_warning);
    draw_set_alpha((0.25 + _hot * 0.45) * _pulse);
    draw_line_width(_head, _wy - _wr * 2.4, _head, _wy + _wr * 2.4, 1.5);

    var _chev_n = 5;
    for (var _cv = 0; _cv < _chev_n; _cv++) {
      var _cf = frac(_cv / _chev_n + current_time * 0.0011);
      var _cx2 = lerp(_mx, _head, _cf);
      var _ca  = sin(_cf * pi) * (0.30 + _hot * 0.5);
      var _cw2 = 7 + _coil * 5;
      draw_set_color(merge_color(_k_er_col_warning, c_white, 0.4 + _hot * 0.4));
      draw_set_alpha(_ca);
      draw_line_width(_cx2 - _dir * _cw2, _wy - _cw2, _cx2, _wy, 2);
      draw_line_width(_cx2 - _dir * _cw2, _wy + _cw2, _cx2, _wy, 2);
    }
  }

  scr_draw_lock_bracket(0, _wy - _wr, _lx, _wy + _wr,
                        _k_er_col_warning, _coil, 1,
                        16, false, 5, 0, _pulse, _k_er_col_cyan);
  scr_draw_lock_bracket(_rx, _wy - _wr, room_width, _wy + _wr,
                        _k_er_col_warning, _coil, 1,
                        16, false, 5, 0, _pulse, _k_er_col_cyan);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}
if (array_length(erupt_side_bursts) > 0) {
  for (var i = 0; i < array_length(erupt_side_bursts); i++) {
    var _sb = erupt_side_bursts[i];
    var _age = _sb.life_max - _sb.life;
    var _sp = clamp(_age / max(_sb.life_max - 1, 1), 0, 1);
    var _sweep = 1 - power(1 - clamp(_sp * 1.45, 0, 1), 3);
    var _x0 = (_sb.dir > 0) ? 0 : room_width;
    var _x1 = _x0 + _sb.dir * room_width * _sweep;
    var _x_min = min(_x0, _x1);
    var _x_max = max(_x0, _x1);
    var _fade = power(clamp(_sb.life / _sb.life_max, 0, 1), 0.7);
    var _hh = _k_er_side_burst_hit_r + 4;
    draw_set_color(_k_er_col_rock);
    draw_set_alpha(0.92 * _fade);
    draw_rectangle(_x_min, _sb.y - _hh, _x_max, _sb.y + _hh, false);
    draw_set_color(merge_color(_k_er_col_rim, _sb.col, 0.65));
    draw_set_alpha(0.75 * _fade);
    draw_line_width(_x_min, _sb.y - _hh, _x_max, _sb.y - _hh, 2);
    draw_line_width(_x_min, _sb.y + _hh, _x_max, _sb.y + _hh, 2);
    draw_set_alpha(1);
  }
  draw_set_color(c_white);
}

if (array_length(erupt_lock_frames) > 0) {
  for (var i = 0; i < array_length(erupt_lock_frames); i++) {
    var _lf = erupt_lock_frames[i];
    var _la = clamp(_lf.life / _lf.life_max, 0, 1);
    var _hot = _lf.hot;
    var _x1 = _lf.cx - _lf.w * 0.5;
    var _x2 = _lf.cx + _lf.w * 0.5;
    var _y1 = _k_er_floor_y - (_lf.fast ? 42 : 62) - (1 - _la) * 10;
    var _y2 = _k_er_floor_y + 10;
    var _tick = _lf.fast ? 9 : 14;
    var _pulse = 0.55 + 0.45 * sin(_lf.seed + current_time * 0.018);

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, _hot * 0.45));
    draw_set_alpha(_la * (0.16 + _hot * 0.18) * _pulse);
    draw_rectangle(_x1 - 5, _y1, _x2 + 5, _y2, true);

    draw_set_color(_lf.fast ? _k_er_col_cyan : _k_er_col_warning);
    draw_set_alpha(_la * (0.45 + _hot * 0.22));
    draw_line_width(_x1, _y1, _x1 + _tick, _y1, 2);
    draw_line_width(_x1, _y1, _x1, _y1 + _tick, 2);
    draw_line_width(_x2, _y1, _x2 - _tick, _y1, 2);
    draw_line_width(_x2, _y1, _x2, _y1 + _tick, 2);
    draw_line_width(_x1, _y2, _x1 + _tick, _y2, 2);
    draw_line_width(_x1, _y2, _x1, _y2 - _tick, 2);
    draw_line_width(_x2, _y2, _x2 - _tick, _y2, 2);
    draw_line_width(_x2, _y2, _x2, _y2 - _tick, 2);

    draw_set_color(c_white);
    draw_set_alpha(_la * _hot * 0.55);
    draw_line_width(_lf.cx, _y1 + 3, _lf.cx, _y2 - 3, 1);
    draw_line_width(_x1 + 7, _k_er_floor_y - 3, _x2 - 7, _k_er_floor_y - 3, 1);
    gpu_set_blendmode(bm_normal);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(erupt_pillars) > 0) {
  for (var i = 0; i < array_length(erupt_pillars); i++) {
    var _p = erupt_pillars[i];
    var _l = _p.cx - _p.w * 0.5;
    var _r = _p.cx + _p.w * 0.5;
    var _pad = variable_struct_exists(_p, "visual_pad") ? _p.visual_pad : 0;
    var _top = _p.y - _pad;
    var _bot = _p.y + _p.h + _pad;
    var _bot_vis = min(_bot, _k_er_floor_y);

    if (_bot >= -40 && _top <= _k_er_floor_y) {
      var _body_top = _top;
      var _face_col = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.16 + _p.heat * 0.18);
      var _shadow_col = merge_color(c_black, _k_er_col_armor_dark, 0.55);
      var _edge_hot = merge_color(_k_er_col_armor_edge, c_white, 0.18 + _p.heat * 0.36);
      var _warn_col = merge_color(_k_er_col_warning, c_white, 0.10 + _p.heat * 0.18);
      var _visible_h = max(1, _bot_vis - _body_top);
      var _panel_pad = _p.fast ? 3 : 6;
      var _inner_l = _l + _panel_pad;
      var _inner_r = _r - _panel_pad;
      var _inner_w = max(1, _inner_r - _inner_l);

      draw_set_color(_shadow_col);
      draw_set_alpha(1);
      draw_rectangle(_l, _body_top, _r, _bot_vis, false);

      if (_p.fast) {
        var _core_w = max(5, _p.w * 0.22);
        var _rail_w = max(2, _p.w * 0.11);
        var _blade_l = _p.cx - _core_w * 0.5;
        var _blade_r = _p.cx + _core_w * 0.5;

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_l, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_r, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_l + 4, _bot_vis, _k_er_col_armor_mid, 1);
        draw_vertex_colour(_r - 4, _bot_vis, _k_er_col_armor_mid, 1);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);
        draw_set_color(_k_er_col_cyan);
        draw_set_alpha(0.26 + _p.heat * 0.25);
        draw_line_width(_blade_l, _body_top, _blade_l, _bot_vis, _rail_w);
        draw_line_width(_blade_r, _body_top, _blade_r, _bot_vis, _rail_w);
        draw_set_color(c_white);
        draw_set_alpha(0.35 + _p.heat * 0.38);
        draw_line_width(_p.cx, _body_top, _p.cx, _bot_vis, max(1, _core_w * 0.22));
        gpu_set_blendmode(bm_normal);

        draw_set_color(_edge_hot);
        draw_set_alpha(0.45 + _p.heat * 0.25);
        draw_line_width(_l, _body_top, _l, _bot_vis, 1.5);
        draw_line_width(_r, _body_top, _r, _bot_vis, 1.5);
      } else {
        var _row_h = 22;
        var _rows = max(3, ceil(_visible_h / _row_h));
        var _col_n = clamp(floor(_p.w / 32), 2, 5);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_l, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_r, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_l, _bot_vis, _face_col, 1);
        draw_vertex_colour(_r, _bot_vis, merge_color(_face_col, c_black, 0.16), 1);
        draw_primitive_end();

        for (var _row = 0; _row < _rows; _row++) {
          var _y1 = _body_top + _row * (_visible_h / _rows);
          var _y2 = _body_top + (_row + 1) * (_visible_h / _rows);
          if (_y1 >= _bot_vis) continue;
          _y2 = min(_y2, _bot_vis);

          var _row_hash = frac(sin(_p.seed * 1.71 + _row * 41.23) * 43758.5453);
          var _row_shift = (_row mod 2 == 0) ? 0 : _inner_w / (_col_n * 2);
          var _row_col = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi,
                                     0.10 + _row_hash * 0.16 + _p.heat * 0.10);

          for (var _col_i = 0; _col_i < _col_n; _col_i++) {
            var _cx1 = _inner_l + _inner_w * (_col_i / _col_n) + _row_shift;
            var _cx2 = _inner_l + _inner_w * ((_col_i + 1) / _col_n) + _row_shift - 3;
            if (_cx1 > _inner_r) _cx1 -= _inner_w;
            if (_cx2 > _inner_r) _cx2 -= _inner_w;

            if (_cx2 > _cx1) {
              var _bevel = min(5, (_cx2 - _cx1) * 0.18, (_y2 - _y1) * 0.32);
              draw_primitive_begin(pr_trianglefan);
              draw_vertex_colour((_cx1 + _cx2) * 0.5, (_y1 + _y2) * 0.5, _row_col, 1);
              draw_vertex_colour(_cx1 + _bevel, _y1 + 1, merge_color(_row_col, c_white, 0.08), 1);
              draw_vertex_colour(_cx2 - _bevel, _y1 + 1, merge_color(_row_col, c_white, 0.05), 1);
              draw_vertex_colour(_cx2, _y1 + _bevel, merge_color(_row_col, c_black, 0.10), 1);
              draw_vertex_colour(_cx2 - _bevel, _y2 - 1, merge_color(_row_col, c_black, 0.18), 1);
              draw_vertex_colour(_cx1 + _bevel, _y2 - 1, merge_color(_row_col, c_black, 0.08), 1);
              draw_vertex_colour(_cx1, _y1 + _bevel, merge_color(_row_col, c_white, 0.04), 1);
              draw_vertex_colour(_cx1 + _bevel, _y1 + 1, merge_color(_row_col, c_white, 0.08), 1);
              draw_primitive_end();

              draw_set_color(merge_color(_k_er_col_armor_edge, _row_col, 0.45));
              draw_set_alpha(0.12 + _p.heat * 0.06);
              draw_line_width(_cx1 + _bevel, _y1 + 1, _cx2 - _bevel, _y1 + 1, 1);
            }
          }
        }

        draw_set_alpha(1);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_l, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_l + 8, _body_top, _k_er_col_armor_mid, 1);
        draw_vertex_colour(_l, _bot_vis, c_black, 1);
        draw_vertex_colour(_l + 8, _bot_vis, _k_er_col_armor_mid, 1);
        draw_primitive_end();
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_r - 8, _body_top, _k_er_col_armor_mid, 1);
        draw_vertex_colour(_r, _body_top, _k_er_col_armor_dark, 1);
        draw_vertex_colour(_r - 8, _bot_vis, _k_er_col_armor_mid, 1);
        draw_vertex_colour(_r, _bot_vis, c_black, 1);
        draw_primitive_end();

        var _spine_x = _p.cx + sin(_p.seed * 0.4) * min(6, _p.w * 0.08);
        draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.12 + _p.heat * 0.22));
        draw_set_alpha(0.32 + _p.heat * 0.24);
        draw_line_width(_spine_x, _body_top + 6, _spine_x, _bot_vis - 6, 2);
        draw_set_color(_warn_col);
        draw_set_alpha(0.34 + _p.heat * 0.24);
        var _port_n = 2 + floor(_p.esc * 4);
        for (var _port = 0; _port < _port_n; _port++) {
          var _pf2 = (_port + 0.5) / _port_n;
          var _py2 = lerp(_body_top + 14, _bot_vis - 12, _pf2);
          var _side = (_port mod 2 == 0) ? -1 : 1;
          var _px2 = _spine_x + _side * min(_p.w * 0.22, 18);
          draw_rectangle(_px2 - 3, _py2 - 2, _px2 + 3, _py2 + 2, false);
        }

        var _brace_rows = max(1, floor(_visible_h / 36));
        draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_armor_mid, 0.45));
        draw_set_alpha(0.16 + _p.heat * 0.08);
        for (var _br2 = 0; _br2 < _brace_rows; _br2++) {
          var _by1 = _body_top + 10 + _br2 * (_visible_h / _brace_rows);
          var _by2 = min(_body_top + (_br2 + 1) * (_visible_h / _brace_rows) - 8, _bot_vis - 6);
          if (_by2 > _by1 + 8) {
            draw_line_width(_l + 12, _by1, _r - 12, _by2, 1);
            draw_line_width(_r - 12, _by1, _l + 12, _by2, 1);
          }
        }
      }

      var _cap_h = _p.fast ? 8 : 14;
      var _cap_y2 = min(_body_top + _cap_h, _bot_vis);
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(_l, _body_top, merge_color(_k_er_col_armor_edge, c_white, 0.16 + _p.heat * 0.24), 1);
      draw_vertex_colour(_r, _body_top, merge_color(_k_er_col_armor_edge, c_white, 0.08 + _p.heat * 0.18), 1);
      draw_vertex_colour(_l + 4, _cap_y2, _k_er_col_armor_mid, 1);
      draw_vertex_colour(_r - 4, _cap_y2, _k_er_col_armor_dark, 1);
      draw_primitive_end();

      var _cap_segments = _p.fast ? 2 : max(2, floor(_p.w / 24));
      for (var _cap = 1; _cap < _cap_segments; _cap++) {
        var _cxcap = lerp(_l + 6, _r - 6, _cap / _cap_segments);
        draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_edge, 0.35));
        draw_set_alpha(0.55);
        draw_line_width(_cxcap, _body_top + 1, _cxcap + sin(_p.seed + _cap) * 2, _cap_y2 - 1, 1);
      }

      var _rim_a = 0.35 + _p.heat * 0.5;
      draw_set_color(_edge_hot);
      draw_set_alpha(_rim_a);
      draw_line_width(_l, _top, _l, _bot_vis, 2);
      draw_line_width(_r, _top, _r, _bot_vis, 2);
      if (_bot < _k_er_floor_y) draw_line_width(_l, _bot, _r, _bot, 2);

      gpu_set_blendmode(bm_add);
      var _vein_n2 = 2 + floor(_p.esc * 1.5);
      for (var v = 0; v < _vein_n2; v++) {
        var _vx = lerp(_l + 6, _r - 6, (v + 1) / (_vein_n2 + 1));
        var _pulse = 0.35 + 0.65 * abs(sin(_p.seed * 3.7 + v * 2.1 + current_time * 0.004));
        var _vtop = lerp(_bot_vis - 22, _top + 10,
                         0.55 + 0.45 * sin(_p.seed + v * 2.7 + current_time * 0.003));
        draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.35 + _p.heat * 0.45));
        draw_set_alpha((0.18 + _p.heat * 0.26) * _pulse);
        draw_line_width(_vx, _vtop, _vx, _bot_vis - 6, 2 * ((_p.fast) ? 2 : 1));
        draw_set_color(c_white);
        draw_set_alpha((0.35 + _p.heat * 0.4) * _pulse);
        draw_circle(_vx, _vtop, 1.8 * ((_p.fast) ? 1.6 : 1), false);
      }

      gpu_set_blendmode(bm_add);
      draw_set_color(_edge_hot);
      draw_set_alpha(0.28 + _p.heat * 0.22);
      draw_line_width(_l + 3, _body_top + 1, _r - 3, _body_top + 1, 1.5);
      draw_set_color(c_white);
      draw_set_alpha(_p.heat * 0.32);
      draw_line_width(_l + 10, _body_top + 3, _r - 10, _body_top + 3, 1);
      gpu_set_blendmode(bm_normal);

      draw_set_alpha(0.14 + _p.heat * 0.2);
      draw_set_color(c_red);
      draw_line_width(_l - 2, _top, _l - 2, _bot_vis, 1.5);
      draw_set_color(_k_er_col_cyan);
      draw_line_width(_r + 2, _top, _r + 2, _bot_vis, 1.5);

      draw_set_alpha(1);
      draw_set_color(c_white);
      gpu_set_blendmode(bm_normal);
    }
  }
  draw_set_color(c_white);
}

if (array_length(erupt_shards) > 0) {
  for (var i = 0; i < array_length(erupt_shards); i++) {
    var _sh = erupt_shards[i];
    var _sa = clamp(_sh.life / _sh.life_max, 0, 1);
    var _sz = _sh.size * (0.35 + _sa * 0.65);

    var _a0 = _sh.rot;
    var _lead_ang = _a0;
    var _lead_rad = 0;
    draw_primitive_begin(pr_trianglestrip);
    for (var v = 0; v <= 4; v++) {
      var _vv = v mod 4;
      var _ang = _a0 + _vv * 90 + sin(_sh.seed + _vv * 1.7) * 22;
      var _rad = _sz * (0.6 + abs(sin(_sh.seed * 0.5 + _vv)) * 0.7);
      if (_rad >= _lead_rad) {
        _lead_rad = _rad;
        _lead_ang = _ang;
      }
      draw_vertex_colour(_sh.x + lengthdir_x(_rad, _ang), _sh.y + lengthdir_y(_rad, _ang),
                         _k_er_col_armor_dark, 1);
      draw_vertex_colour(_sh.x, _sh.y, merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, _sa), 1);
    }
    draw_primitive_end();

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _sa));
    draw_set_alpha(_sa * 0.7);
    draw_line_width(_sh.x + lengthdir_x(_lead_rad * 0.35, _lead_ang),
                    _sh.y + lengthdir_y(_lead_rad * 0.35, _lead_ang),
                    _sh.x + lengthdir_x(_lead_rad, _lead_ang),
                    _sh.y + lengthdir_y(_lead_rad, _lead_ang), 1.5);
    draw_set_alpha(0.5 + _sa * 0.4);
    draw_circle(_sh.x, _sh.y, max(1, _sz * 0.25), false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
  }
}

if (array_length(erupt_gravel) > 0) {
  draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.35));
  for (var i = 0; i < array_length(erupt_gravel); i++) {
    var _gv = erupt_gravel[i];
    var _ga2 = clamp(_gv.life / _gv.life_max, 0, 1);
    var _gs = _gv.size * (0.65 + _ga2 * 0.35);
    var _ang = _gv.x * 0.7 + _gv.y * 0.13 + t * 5;
    draw_set_alpha(_ga2 * 0.9);
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_gv.x, _gv.y, merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.22), _ga2);
    draw_vertex_colour(_gv.x + lengthdir_x(_gs, _ang), _gv.y + lengthdir_y(_gs, _ang), _k_er_col_armor_dark, _ga2);
    draw_vertex_colour(_gv.x + lengthdir_x(_gs * 0.75, _ang + 100), _gv.y + lengthdir_y(_gs * 0.75, _ang + 100), _k_er_col_armor_hi, _ga2);
    draw_vertex_colour(_gv.x + lengthdir_x(_gs, _ang + 210), _gv.y + lengthdir_y(_gs, _ang + 210), _k_er_col_armor_dark, _ga2);
    draw_vertex_colour(_gv.x + lengthdir_x(_gs, _ang), _gv.y + lengthdir_y(_gs, _ang), _k_er_col_armor_dark, _ga2);
    draw_primitive_end();
    if (_gv.size > 2.2) {
      draw_set_color(_k_er_col_cyan);
      draw_set_alpha(_ga2 * 0.42);
      draw_line_width(_gv.x - _gs * 0.55, _gv.y, _gv.x + _gs * 0.55, _gv.y, 1);
      draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.35));
    }
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
}
if (erupt_despawn_active || array_length(erupt_despawn_plates) > 0 ||
    array_length(erupt_despawn_sweeps) > 0) {
  var _ddp = erupt_despawn_active
           ? clamp(erupt_despawn_timer / _k_er_despawn_duration, 0, 1)
           : 1;
  var _sink = erupt_despawn_sink;
  var _floor_y = _k_er_floor_y + _sink;
  var _lip_a = power(1 - _ddp, 0.65);

  if (_lip_a > 0.02) {
    var _seg_n = array_length(erupt_despawn_lip) - 1;
    draw_primitive_begin(pr_trianglestrip);
    for (var s = 0; s <= _seg_n; s++) {
      var _f = s / _seg_n;
      var _x = lerp(-20, room_width + 20, _f);
      var _lip = erupt_despawn_lip[s] * (2 + _ddp * 9)
               + sin(s * 1.7 + _ddp * 8) * (1 + _ddp * 6);
      var _drop = 8 + _sink * (0.45 + abs(sin(s * 0.9)) * 0.35);
      draw_vertex_colour(_x, _k_er_floor_y + _lip, _k_er_col_armor_dark, _lip_a * 0.95);
      draw_vertex_colour(_x, _floor_y + _drop, c_black, _lip_a * 0.72);
    }
    draw_primitive_end();

    draw_set_color(c_black);
    draw_set_alpha(_lip_a * 0.55);
    draw_rectangle(-30, _floor_y + 8, room_width + 30, _floor_y + 70, false);
    draw_set_alpha(1);
  }

  for (var i = 0; i < array_length(erupt_despawn_sweeps); i++) {
    var _sw = erupt_despawn_sweeps[i];
    if (_sw.delay <= 0) {
      var _sa = clamp(_sw.life / _sw.life_max, 0, 1);
      var _x1 = _sw.x - _sw.w * 0.5;
      var _x2 = _sw.x + _sw.w * 0.5;
      var _y = _sw.y + _sink * (1 - _sa * 0.4);
      var _chip = 4 + _sw.hot * 10;

      draw_primitive_begin(pr_trianglestrip);
      for (var s = 0; s <= 5; s++) {
        var _sf = s / 5;
        var _x = lerp(_x1, _x2, _sf);
        var _j = sin(_sw.seed + s * 2.1 + _ddp * 5) * _chip;
        draw_vertex_colour(_x, _y + _j * 0.2, _k_er_col_armor_dark, _sa * 0.9);
        draw_vertex_colour(_x, _y + 14 + _j, c_black, _sa * 0.62);
      }
      draw_primitive_end();
    }
  }

  for (var i = 0; i < array_length(erupt_despawn_plates); i++) {
    var _pl = erupt_despawn_plates[i];
    var _pa = clamp(_pl.life / _pl.life_max, 0, 1);
    var _w = _pl.w * (0.35 + _pa * 0.65);
    var _h = _pl.h * (0.35 + _pa * 0.65);
    var _c = merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, _pl.hot * _pa);

    var _a = _pl.rot;
    var _x0 = _pl.x + lengthdir_x(_w, _a + 180) + lengthdir_x(_h, _a + 270);
    var _y0 = _pl.y + lengthdir_y(_w, _a + 180) + lengthdir_y(_h, _a + 270);
    var _x1 = _pl.x + lengthdir_x(_w, _a) + lengthdir_x(_h, _a + 270);
    var _y1 = _pl.y + lengthdir_y(_w, _a) + lengthdir_y(_h, _a + 270);
    var _x2 = _pl.x + lengthdir_x(_w, _a + 180) + lengthdir_x(_h, _a + 90);
    var _y2 = _pl.y + lengthdir_y(_w, _a + 180) + lengthdir_y(_h, _a + 90);
    var _x3 = _pl.x + lengthdir_x(_w, _a) + lengthdir_x(_h, _a + 90);
    var _y3 = _pl.y + lengthdir_y(_w, _a) + lengthdir_y(_h, _a + 90);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x0, _y0, c_black, _pa);
    draw_vertex_colour(_x1, _y1, _c, _pa);
    draw_vertex_colour(_x2, _y2, _k_er_col_armor_dark, _pa);
    draw_vertex_colour(_x3, _y3, _c, _pa);
    draw_primitive_end();
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(sky_strikes) > 0) {
  gpu_set_blendmode(bm_add);
  for (var ski = 0; ski < array_length(sky_strikes); ski++) {
    var _sk = sky_strikes[ski];
    var _sk_alpha = _sk.life / _sk.life_max;
    var _sk_color = variable_struct_exists(_sk, "color") ? _sk.color : global.lightning_color;
    var _sk_segments = 9;
    var _sk_dx = (_sk.tx - _sk.ox) / _sk_segments;
    var _sk_dy = (_sk.ty - _sk.oy) / _sk_segments;
    var _sk_perp = point_direction(_sk.ox, _sk.oy, _sk.tx, _sk.ty) + 90;

    var _sk_points = [[_sk.ox, _sk.oy]];
    for (var s = 1; s <= _sk_segments; s++) {
      var _sk_tx = _sk.ox + _sk_dx * s;
      var _sk_ty = _sk.oy + _sk_dy * s;
      if (s < _sk_segments) {
        var _sk_j = random_range(-14, 14);
        _sk_tx += lengthdir_x(_sk_j, _sk_perp);
        _sk_ty += lengthdir_y(_sk_j, _sk_perp);
      }
      array_push(_sk_points, [_sk_tx, _sk_ty]);
    }

    if (!variable_struct_exists(_sk, "imprinted")) {
      _sk.imprinted = true;
      var _sk_imp_pts = [];
      for (var s = 0; s < array_length(_sk_points); s++) {
        var _sk_imp_w = lerp(2.4, 0.6, s / max(array_length(_sk_points) - 1, 1));
        array_push(_sk_imp_pts, {ix : _sk_points[s][0], iy : _sk_points[s][1], w : _sk_imp_w});
      }
      if (array_length(lightning_imprints) >= 30) array_delete(lightning_imprints, 0, 1);
      array_push(lightning_imprints, {
        points : _sk_imp_pts,
        life : 50, life_max : 50,
        col : _sk_color
      });
    }

    for (var s = 1; s < array_length(_sk_points); s++) {
      var _pa = _sk_points[s - 1];
      var _pb = _sk_points[s];
      draw_set_color(_sk_color);
      draw_set_alpha(_sk_alpha * 0.15);
      draw_line_width(_pa[0], _pa[1], _pb[0], _pb[1], 18);
      draw_set_alpha(_sk_alpha * 0.45);
      draw_line_width(_pa[0], _pa[1], _pb[0], _pb[1], 7);

      var _sk_off = 2.5;
      draw_set_color(global.avoid_col_danger);
      draw_set_alpha(_sk_alpha * 0.3);
      draw_line_width(_pa[0] + lengthdir_x(_sk_off, _sk_perp), _pa[1] + lengthdir_y(_sk_off, _sk_perp),
                      _pb[0] + lengthdir_x(_sk_off, _sk_perp), _pb[1] + lengthdir_y(_sk_off, _sk_perp), 2.5);
      draw_set_color(global.avoid_col_cyan);
      draw_line_width(_pa[0] - lengthdir_x(_sk_off, _sk_perp), _pa[1] - lengthdir_y(_sk_off, _sk_perp),
                      _pb[0] - lengthdir_x(_sk_off, _sk_perp), _pb[1] - lengthdir_y(_sk_off, _sk_perp), 2.5);

      draw_set_color(c_white);
      draw_set_alpha(_sk_alpha * 0.9);
      draw_line_width(_pa[0], _pa[1], _pb[0], _pb[1], 2);
    }

    var _sk_impact_p = 1 - _sk_alpha;
    if (_sk_impact_p < 0.4) {
      draw_set_color(c_white);
      draw_set_alpha((1 - _sk_impact_p / 0.4) * 0.9);
      draw_circle(_sk.tx, _sk.ty, 20 * (1 + _sk_impact_p), false);
    }
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

var _vs = arrow_ring_vertical_scale;
var _coil = ring_coil_amount;


if (array_length(ring_splatter) > 0) {
  gpu_set_blendmode(bm_add);

  for (var i = 0; i < array_length(ring_splatter); i++) {
    var _sp = ring_splatter[i];
    var _spa = _sp.alpha * _sp.alpha;

    var _tail_x = _sp.x - lengthdir_x(_sp.drag_len, _sp.drag_ang);
    var _tail_y = _sp.y - lengthdir_y(_sp.drag_len, _sp.drag_ang);

    draw_set_color(make_color_rgb(110, 0, 0));
    draw_set_alpha(_spa * 0.5);
    draw_line_width(_tail_x, _tail_y, _sp.x, _sp.y, max(1, _sp.size * 0.7));

    draw_set_alpha(_spa * 0.6);
    draw_circle(_sp.x, _sp.y, _sp.size * 1.8, false);

    draw_set_color(merge_color(make_color_rgb(200, 10, 10), c_white, _sp.hot * 0.35));
    draw_set_alpha(_spa);
    draw_circle(_sp.x, _sp.y, _sp.size, false);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_rim_afterglow) > 0) {
  gpu_set_blendmode(bm_add);

  for (var g = 0; g < array_length(ring_rim_afterglow); g++) {
    var _ag = ring_rim_afterglow[g];
    var _apts = _ag.pts;
    var _an = array_length(_apts);
    if (_an < 2) continue;

    draw_set_color(merge_color(ring_color, c_white, _ag.hot));
    draw_set_alpha(_ag.alpha * 0.35);

    for (var _pi = 0; _pi < _an; _pi++) {
      var _p1 = _apts[_pi];
      var _p2 = _apts[(_pi + 1) mod _an];
      draw_line_width(_p1.x, _p1.y, _p2.x, _p2.y, 1 + _ag.alpha * 3);
    }
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (ring_band_ignited && ring_ambient > 0.02 && ring_safe_arc > 1) {
  var _sec_e = ring_safe_slide * ring_safe_slide * (3 - 2 * ring_safe_slide);
  var _sec_ang = ring_safe_ang_prev + angle_difference(ring_safe_ang, ring_safe_ang_prev) * _sec_e;
  var _sec_hw = ring_safe_arc * 0.5;
  var _sec_mult = fx_get_mult_for("arrowring", "sector");
  var _sec_a = ring_ambient * (0.085 + ring_sector_flash * 0.13 + ring_heartbeat * 0.075) * _sec_mult;
  var _sec_col = merge_color(global.lightning_color, c_white, 0.5);
  var _sec_r_in = max(12, arrow_ring_current_radius * 0.8);

  var _k_sec_steps = 8;
  var _k_sec_bands = 12;

  var _sec_d = array_create(_k_sec_steps + 1, 0);
  var _sec_ax = array_create(_k_sec_steps + 1, 0);
  var _sec_ay = array_create(_k_sec_steps + 1, 0);

  for (var _ss = 0; _ss <= _k_sec_steps; _ss++) {
    var _ssa = _sec_ang - _sec_hw + _sec_hw * 2 * (_ss / _k_sec_steps);
    _sec_d[_ss] = ring_arena_hit(arrow_ring_x, arrow_ring_y, _ssa).dist;
    _sec_ax[_ss] = dcos(_ssa);
    _sec_ay[_ss] = -dsin(_ssa);
  }

  gpu_set_blendmode(bm_add);

  for (var _sb = 0; _sb < _k_sec_bands; _sb++) {
    var _sbt0 = _sb / _k_sec_bands;
    var _sbt1 = (_sb + 1) / _k_sec_bands;
    var _sba = _sec_a * (0.18 + power(1 - _sbt0, 1.7) * 0.82);

    draw_primitive_begin(pr_trianglestrip);

    for (var _ss = 0; _ss <= _k_sec_steps; _ss++) {
      var _sr0 = _sec_r_in + (_sec_d[_ss] - _sec_r_in) * _sbt0;
      var _sr1 = _sec_r_in + (_sec_d[_ss] - _sec_r_in) * _sbt1;

      draw_vertex_colour(arrow_ring_x + _sec_ax[_ss] * _sr0, arrow_ring_y + _sec_ay[_ss] * _sr0, _sec_col, _sba);
      draw_vertex_colour(arrow_ring_x + _sec_ax[_ss] * _sr1, arrow_ring_y + _sec_ay[_ss] * _sr1, _sec_col, _sba);
    }

    draw_primitive_end();
  }

  gpu_set_blendmode(bm_normal);

  var _sec_line_col = merge_color(global.avoid_col_cyan, c_white, 0.4);
  var _sec_edge_a = clamp(0.3 + ring_ambient * 0.2 + ring_sector_flash * 0.45, 0, 1) * _sec_mult;

  for (var _se = 0; _se < 2; _se++) {
    var _sei = (_se == 0) ? 0 : _k_sec_steps;
    var _sx0 = arrow_ring_x + _sec_ax[_sei] * _sec_r_in;
    var _sy0 = arrow_ring_y + _sec_ay[_sei] * _sec_r_in;
    var _sx1 = arrow_ring_x + _sec_ax[_sei] * _sec_d[_sei];
    var _sy1 = arrow_ring_y + _sec_ay[_sei] * _sec_d[_sei];

    draw_set_color(c_black);
    draw_set_alpha(_sec_edge_a * 0.55);
    draw_line_width(_sx0, _sy0, _sx1, _sy1, 5);
    draw_set_color(_sec_line_col);
    draw_set_alpha(_sec_edge_a);
    draw_line_width(_sx0, _sy0, _sx1, _sy1, 2);
  }

  var _sec_px = arrow_ring_x + _sec_ax[0] * _sec_d[0];
  var _sec_py = arrow_ring_y + _sec_ay[0] * _sec_d[0];

  for (var _ss = 1; _ss <= _k_sec_steps; _ss++) {
    var _sec_nx = arrow_ring_x + _sec_ax[_ss] * _sec_d[_ss];
    var _sec_ny = arrow_ring_y + _sec_ay[_ss] * _sec_d[_ss];

    draw_set_color(c_black);
    draw_set_alpha(_sec_edge_a * 0.6);
    draw_line_width(_sec_px, _sec_py, _sec_nx, _sec_ny, 5);
    draw_set_color(_sec_line_col);
    draw_set_alpha(_sec_edge_a);
    draw_line_width(_sec_px, _sec_py, _sec_nx, _sec_ny, 2.2);

    _sec_px = _sec_nx;
    _sec_py = _sec_ny;
  }

  draw_set_alpha(1);
}

if (array_length(ring_tracers) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _tri = 0; _tri < array_length(ring_tracers); _tri++) {
    var _tr = ring_tracers[_tri];

    if (_tr.fired) continue;

    var _twp = clamp(1 - (_tr.life / max(_tr.max_life, 1)), 0, 1);
    var _tal = (0.3 + _twp * 0.65) * (0.5 + ring_ambient * 0.7);
    var _tcol = merge_color(c_red, c_white, _twp);

    draw_set_color(_tcol);

    var _treach = lerp(0.28, 1, _twp);
    var _tex = _tr.ox + (_tr.lx - _tr.ox) * _treach;
    var _tey = _tr.oy + (_tr.ly - _tr.oy) * _treach;

    var _tj = sin(_tr.seed + _tr.life * 0.8) * 1.6 * (1 - _twp);
    var _tjx = lengthdir_x(_tj, _tr.ang + 90);
    var _tjy = lengthdir_y(_tj, _tr.ang + 90);

    draw_set_alpha(_tal * 0.22);
    draw_line_width(_tr.ox + _tjx, _tr.oy + _tjy, _tex, _tey, 8);
    draw_set_alpha(_tal * 0.8);
    draw_line_width(_tr.ox + _tjx, _tr.oy + _tjy, _tex, _tey, 1.5);

    var _trr = lerp(30, 11, _twp);
    var _tedge = _tr.vertical ? 90 : 0;
    var _tux = lengthdir_x(1, _tedge);
    var _tuy = lengthdir_y(1, _tedge);
    var _tvx = lengthdir_x(1, _tedge + 90);
    var _tvy = lengthdir_y(1, _tedge + 90);
    var _tjaw = 7 + _twp * 4;

    draw_set_alpha(_tal);

    for (var _tb = 0; _tb < 2; _tb++) {
      var _tsgn = (_tb == 0) ? -1 : 1;
      var _tbx = _tr.lx + _tux * _trr * _tsgn;
      var _tby = _tr.ly + _tuy * _trr * _tsgn;

      draw_line_width(_tbx - _tvx * _tjaw, _tby - _tvy * _tjaw, _tbx + _tvx * _tjaw, _tby + _tvy * _tjaw, 2.5);

      var _tin = _tux * 6 * -_tsgn;
      var _tiny = _tuy * 6 * -_tsgn;
      draw_line_width(_tbx - _tvx * _tjaw, _tby - _tvy * _tjaw,
                      _tbx - _tvx * _tjaw + _tin, _tby - _tvy * _tjaw + _tiny, 2.5);
      draw_line_width(_tbx + _tvx * _tjaw, _tby + _tvy * _tjaw,
                      _tbx + _tvx * _tjaw + _tin, _tby + _tvy * _tjaw + _tiny, 2.5);
    }

    draw_set_alpha(_tal * _twp * 0.9);
    draw_line_width(_tr.lx - _tvx * 4, _tr.ly - _tvy * 4, _tr.lx + _tvx * 4, _tr.ly + _tvy * 4, 2);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_craters) > 0) {
  gpu_set_blendmode(bm_add);

  var _k_crater_segs = 14;

  for (var _ci = 0; _ci < array_length(ring_craters); _ci++) {
    var _cr = ring_craters[_ci];
    var _ca = _cr.life / _cr.max_life;
    var _ccol = merge_color(c_red, c_white, _cr.hot);

    var _cux = lengthdir_x(1, _cr.edge);
    var _cuy = lengthdir_y(1, _cr.edge);
    var _cvx = lengthdir_x(1, _cr.edge + 90);
    var _cvy = lengthdir_y(1, _cr.edge + 90);

    draw_set_color(_ccol);

    draw_primitive_begin(pr_linestrip);

    for (var _cs = 0; _cs <= _k_crater_segs; _cs++) {
      var _cang = _cs * (360 / _k_crater_segs);
      var _cu = dcos(_cang) * _cr.radius;
      var _cv = dsin(_cang) * _cr.radius * 0.35;

      draw_vertex_colour(_cr.x + _cux * _cu + _cvx * _cv, _cr.y + _cuy * _cu + _cvy * _cv,
                         _ccol, _ca * _ca * 0.8);
    }

    draw_primitive_end();

    draw_set_alpha(_ca * 0.3);
    draw_line_width(_cr.x - _cux * _cr.radius * 1.5, _cr.y - _cuy * _cr.radius * 1.5,
                    _cr.x + _cux * _cr.radius * 1.5, _cr.y + _cuy * _cr.radius * 1.5, 3);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_stuck_arrows) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _sti = 0; _sti < array_length(ring_stuck_arrows); _sti++) {
    var _st = ring_stuck_arrows[_sti];
    var _sta = clamp(_st.life / _st.max_life, 0, 1);
    var _stang = _st.ang + sin(_st.phase + _st.life * 0.55) * _st.wobble;

    draw_sprite_ext(sRedArrow, 0, _st.x, _st.y, _st.scale, _st.scale, _stang,
                    merge_color(c_red, c_white, _sta * 0.4), _sta * 0.85);
  }

  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_shockwaves) > 0) {
  gpu_set_blendmode(bm_add);

  for (var s = 0; s < array_length(ring_shockwaves); s++) {
    var _sw = ring_shockwaves[s];
    var _swa = _sw.life / _sw.max_life;
    if (_swa <= 0) continue;

    var _swvs = variable_struct_exists(_sw, "vs") ? _sw.vs : _vs;

    var _swbase = (variable_struct_exists(_sw, "col") && !is_undefined(_sw.col)) ? _sw.col : ring_color;
    var _swcol = merge_color(_swbase, c_white, _sw.hot);
    draw_set_color(_swcol);
    draw_set_alpha(_swa * _swa * 0.7);
    draw_ellipse_color(_sw.x - _sw.radius, _sw.y - _sw.radius * _swvs,
                       _sw.x + _sw.radius, _sw.y + _sw.radius * _swvs, _swcol, _swcol, true);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_ripples) > 0) {
  gpu_set_blendmode(bm_add);

  for (var i = 0; i < array_length(ring_ripples); i++) {
    var r = ring_ripples[i];
    draw_set_color(ring_color);
    draw_set_alpha(r.alpha * 0.8);
    draw_ellipse_color(r.x - r.radius, r.y - r.radius * _vs,
                       r.x + r.radius, r.y + r.radius * _vs, ring_color, ring_color, true);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_charge_motes) > 0) {
  gpu_set_blendmode(bm_add);

  for (var m = 0; m < array_length(ring_charge_motes); m++) {
    var _mo = ring_charge_motes[m];

    var _mx = arrow_ring_x + lengthdir_x(_mo.dist, _mo.ang);
    var _my = arrow_ring_y + lengthdir_y(_mo.dist * _vs, _mo.ang);

    var _tail = _mo.speed * 2.2;
    var _tx = arrow_ring_x + lengthdir_x(_mo.dist + _tail, _mo.ang);
    var _ty = arrow_ring_y + lengthdir_y((_mo.dist + _tail) * _vs, _mo.ang);

    var _ma = clamp(1 - _mo.dist / (arrow_ring_radius * 2.4), 0, 1);

    draw_set_color(merge_color(ring_color, c_white, _mo.hot));
    draw_set_alpha(_ma * 0.85);
    draw_line_width(_tx, _ty, _mx, _my, 1 + _mo.size * 4);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_streaks) > 0) {
  gpu_set_blendmode(bm_add);

  for (var i = 0; i < array_length(ring_streaks); i++) {
    var s = ring_streaks[i];
    var _alpha = s.life / s.max_life;

    var _sox = variable_struct_exists(s, "cx") ? s.cx : arrow_ring_x;
    var _soy = variable_struct_exists(s, "cy") ? s.cy : arrow_ring_y;
    var _svs = variable_struct_exists(s, "vs") ? s.vs : _vs;

    var _x1 = _sox + lengthdir_x(s.dist, s.ang);
    var _y1 = _soy + lengthdir_y(s.dist * _svs, s.ang);
    var _x2 = _sox + lengthdir_x(s.dist + s.len, s.ang);
    var _y2 = _soy + lengthdir_y((s.dist + s.len) * _svs, s.ang);

    var _stbase = (variable_struct_exists(s, "col") && !is_undefined(s.col)) ? s.col : ring_color;
    draw_set_color(merge_color(_stbase, c_white, s.hot));
    draw_set_alpha(_alpha * 0.35);
    draw_line_width(_x1, _y1, _x2, _y2, s.width * 3);

    draw_set_color(c_white);
    draw_set_alpha(_alpha * 0.9);
    draw_line_width(_x1, _y1, _x2, _y2, s.width);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_missile_reticles) > 0 || array_length(ring_missiles) > 0 ||
    array_length(ring_missile_bursts) > 0 || array_length(ring_missile_shards) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _ri = 0; _ri < array_length(ring_missile_reticles); _ri++) {
    var _rt = ring_missile_reticles[_ri];
    var _rp = clamp(_rt.life / max(_rt.max_life, 1), 0, 1);
    var _rc = 1 - _rp;
    var _rcol = merge_color(global.avoid_col_cyan, c_white, 0.35 + _rt.hit_index * 0.08);
    var _rr = lerp(60 + _rt.hit_index * 6, 20 + _rt.hit_index * 2, power(_rc, 0.65));
    var _pulse = 0.78 + 0.22 * sin(current_time * 0.026 + _rt.seed);

    scr_draw_smooth_ring_mask(_rt.x, _rt.y, _rr, (0.55 + _rc * 0.35) * _pulse, 3 + _rc * 3, _rcol);
    scr_draw_smooth_ring_mask(_rt.x, _rt.y, _rr * 0.54, (0.32 + _rc * 0.28) * _pulse, 2, c_white);

    draw_set_color(_rcol);
    draw_set_alpha((0.6 + _rc * 0.4) * _pulse);
    var _jaw = 10 + _rt.hit_index * 2;
    draw_line_width(_rt.x - _rr - _jaw, _rt.y, _rt.x - _rr + _jaw, _rt.y, 2.5);
    draw_line_width(_rt.x + _rr - _jaw, _rt.y, _rt.x + _rr + _jaw, _rt.y, 2.5);
    draw_line_width(_rt.x, _rt.y - _rr - _jaw, _rt.x, _rt.y - _rr + _jaw, 2.5);
    draw_line_width(_rt.x, _rt.y + _rr - _jaw, _rt.x, _rt.y + _rr + _jaw, 2.5);

    draw_set_alpha(0.55 + _rc * 0.35);
    draw_line_width(_rt.x - 8, _rt.y, _rt.x + 8, _rt.y, 1.5);
    draw_line_width(_rt.x, _rt.y - 8, _rt.x, _rt.y + 8, 1.5);
  }

  for (var _mi = 0; _mi < array_length(ring_missiles); _mi++) {
    var _m = ring_missiles[_mi];
    var _mp = clamp(_m.timer / max(_m.fuse, 1), 0, 1);
    var _mcol = merge_color(global.avoid_col_cyan, c_white, 0.4 + _m.hot * 0.3);
    var _mang = point_direction(_m.px, _m.py, _m.x, _m.y);

    draw_set_color(_mcol);
    draw_set_alpha(0.24 + _mp * 0.4);
    draw_line_width(_m.ox, _m.oy, _m.tx, _m.ty, 1.5 + _mp * 2.5);

    var _trail_n = array_length(_m.trail);
    var _last_x = _m.x;
    var _last_y = _m.y;
    for (var _ti = 0; _ti < _trail_n; _ti++) {
      var _tp = _m.trail[_ti];
      var _ta = (1 - _ti / max(_trail_n, 1)) * (0.32 + _mp * 0.4);
      draw_set_alpha(_ta);
      draw_line_width(_last_x, _last_y, _tp.x, _tp.y, 7 - _ti * 0.45);
      _last_x = _tp.x;
      _last_y = _tp.y;
    }

    scr_draw_smooth_ring_mask(_m.x, _m.y, 12 + _m.hot * 5, 0.55 + _mp * 0.3, 3, _mcol);

    draw_set_alpha(0.9);
    draw_sprite_ext(sRedArrow, 0, _m.x, _m.y, 2.6 + _m.hot * 0.4, 1.6, _mang, _mcol, 0.95);
    draw_set_color(c_white);
    draw_set_alpha(0.8);
    draw_sprite_ext(sRedArrow, 0, _m.x, _m.y, 1.5, 0.9, _mang, c_white, 0.9);
  }

  for (var _bi = 0; _bi < array_length(ring_missile_bursts); _bi++) {
    var _bu = ring_missile_bursts[_bi];
    var _ba = clamp(_bu.life / max(_bu.max_life, 1), 0, 1);
    var _bcol = merge_color(c_red, c_white, _bu.hot);
    scr_draw_smooth_ring_mask(_bu.x, _bu.y, _bu.radius, _ba * _ba * 0.82, 7 + _bu.hot * 6, _bcol);
    if (_bu.danger_life > 0) {
      scr_draw_smooth_ring_mask(_bu.x, _bu.y, _bu.hit_radius, 0.45 + _ba * 0.35, 3, c_white);
    }
  }

  for (var _si = 0; _si < array_length(ring_missile_shards); _si++) {
    var _sh = ring_missile_shards[_si];
    if (_sh.delay > 0) continue;

    var _sa = clamp(_sh.life / max(_sh.max_life, 1), 0, 1);
    var _scol = merge_color(c_red, c_white, 0.18 + _sh.hot * 0.45);

    draw_set_color(_scol);
    draw_set_alpha(_sa * 0.34);
    draw_line_width(_sh.px, _sh.py, _sh.x, _sh.y, 8 * _sh.scale);

    draw_set_alpha(_sa);
    draw_sprite_ext(sRedArrow, 0, _sh.x, _sh.y, _sh.scale * 1.35, _sh.scale * 0.78, _sh.ang, _scol, _sa);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (arrow_ring_created) {
  gpu_set_blendmode(bm_add);

  var _ghost_radius = arrow_ring_current_radius * (1.18 + _coil * 0.25);
  var _ghost_angle_offset = arrow_ring_angle * 0.35;

  draw_set_color(ring_color);
  draw_set_alpha(0.18 + _coil * 0.3);

  for (var i = 0; i < arrow_ring_count; i++) {
    var _a1 = _ghost_angle_offset + i * (360 / arrow_ring_count);
    var _a2 = _ghost_angle_offset + (i + 1) * (360 / arrow_ring_count);

    draw_line_width(arrow_ring_x + lengthdir_x(_ghost_radius, _a1),
                    arrow_ring_y + lengthdir_y(_ghost_radius * _vs, _a1),
                    arrow_ring_x + lengthdir_x(_ghost_radius, _a2),
                    arrow_ring_y + lengthdir_y(_ghost_radius * _vs, _a2), 2);
  }

  draw_set_color(c_white);
  draw_set_alpha(0.25 + _coil * 0.4);

  for (var i = 0; i < arrow_ring_count; i++) {
    var _ang = _ghost_angle_offset + i * (360 / arrow_ring_count);
    draw_circle(arrow_ring_x + lengthdir_x(_ghost_radius, _ang),
                arrow_ring_y + lengthdir_y(_ghost_radius * _vs, _ang), 2, false);
  }

  draw_set_alpha(0.025 + _coil * 0.09 + ring_heartbeat * 0.03);
  draw_set_color(ring_color);

  var _fill_radius = arrow_ring_current_radius * 0.98;

  draw_primitive_begin(pr_trianglefan);
  draw_vertex(arrow_ring_x, arrow_ring_y);

  for (var i = 0; i <= arrow_ring_count; i++) {
    var _ang = arrow_ring_angle + i * (360 / arrow_ring_count);
    draw_vertex(arrow_ring_x + lengthdir_x(_fill_radius, _ang),
                arrow_ring_y + lengthdir_y(_fill_radius * _vs, _ang));
  }

  draw_primitive_end();

  for (var i = 0; i < arrow_ring_count; i++) {
    var a = arrow_ring[i];
    if (!instance_exists(a)) continue;

    draw_set_color(ring_color);
    draw_set_alpha(0.08 + arrow_core_flash / 12 * 0.5 + _coil * 0.35);
    draw_line_width(arrow_ring_x, arrow_ring_y, a.x, a.y, 2 + _coil * 2);

    var _flow = (_coil > 0.02) ? (1 - arrow_energy_flow) : arrow_energy_flow;

    var _px = lerp(arrow_ring_x, a.x, _flow);
    var _py = lerp(arrow_ring_y, a.y, _flow);

    draw_set_color(ring_color);
    draw_set_alpha(0.2 + _coil * 0.3);
    draw_circle(_px, _py, 8 + _coil * 6, false);

    draw_set_color(c_white);
    draw_set_alpha(0.9);
    draw_circle(_px, _py, 2 + _coil * 2, false);
  }

  var _lw = 2 + (ring_outline_pulse / 12) * 4 + _coil * 2;
  var _chroma_mult = ring_chroma * fx_get_mult_for("arrowring", "aberration");
  var _chroma_px = _chroma_mult * 3.5;

  for (var i = 0; i < arrow_ring_count; i++) {
    var a1 = arrow_ring[i];
    var a2 = arrow_ring[(i + 1) mod arrow_ring_count];
    if (!instance_exists(a1) || !instance_exists(a2)) continue;

    var _seg_progress = min(a1.arrow_spawn_progress, a2.arrow_spawn_progress);
    if (_seg_progress <= 0) continue;

    if (_chroma_px > 0.2) {
      var _perp = point_direction(a1.x, a1.y, a2.x, a2.y) + 90;
      var _cox = lengthdir_x(_chroma_px, _perp);
      var _coy = lengthdir_y(_chroma_px, _perp);

      draw_set_alpha(_chroma_mult * 0.5 * _seg_progress);
      draw_set_color(c_red);
      draw_line_width(a1.x + _cox, a1.y + _coy, a2.x + _cox, a2.y + _coy, _lw * 0.8);
      draw_set_color(c_aqua);
      draw_line_width(a1.x - _cox, a1.y - _coy, a2.x - _cox, a2.y - _coy, _lw * 0.8);
    }

    draw_set_color(ring_color);
    draw_set_alpha((0.35 + (ring_outline_pulse / 12) * 0.45 + _coil * 0.35) * _seg_progress);
    draw_line_width(a1.x, a1.y, a2.x, a2.y, _lw);

    draw_set_color(c_white);
    draw_set_alpha((0.55 + (ring_outline_pulse / 12) * 0.3 + _coil * 0.4) * _seg_progress);
    draw_line_width(a1.x, a1.y, a2.x, a2.y, 1 + _coil);

    if (_seg_progress < 1) continue;

    var _flow_speed = 0.004 * (1 + _coil * 4);
    var _rim_flow = (current_time * _flow_speed + i * 0.18) mod 1;

    var _fx = lerp(a1.x, a2.x, _rim_flow);
    var _fy = lerp(a1.y, a2.y, _rim_flow);

    draw_set_color(ring_color);
    draw_set_alpha(0.5);
    draw_circle(_fx, _fy, 6, false);

    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_circle(_fx, _fy, 2, false);
  }

  if (ring_wound > 0) {
    var _wounded = ceil(ring_wound * arrow_ring_count);

    for (var i = 0; i < _wounded; i++) {
      var a = arrow_ring[i];
      if (!instance_exists(a)) continue;

      var _flicker = 0.35 + 0.65 * frac(sin(i * 12.9898 + current_time * 0.004) * 43758.5453);

      for (var c = 0; c < 3; c++) {
        var _seed = frac(sin((i * 3 + c) * 78.233) * 43758.5453);
        var _cang = _seed * 360;
        var _clen = 6 + _seed * 16 * (0.5 + ring_wound);

        var _mx = a.x + lengthdir_x(_clen * 0.5, _cang);
        var _my = a.y + lengthdir_y(_clen * 0.5 * _vs, _cang);
        var _ex = a.x + lengthdir_x(_clen, _cang + (_seed - 0.5) * 70);
        var _ey = a.y + lengthdir_y(_clen * _vs, _cang + (_seed - 0.5) * 70);

        draw_set_color(merge_color(c_red, c_white, 0.15));
        draw_set_alpha(_flicker * ring_wound * 0.85);
        draw_line_width(a.x, a.y, _mx, _my, 2);
        draw_line_width(_mx, _my, _ex, _ey, 1.5);
      }
    }
  }

  var _inner_radius = arrow_ring_current_radius * (0.35 - _coil * 0.1);

  draw_set_color(ring_color);
  draw_set_alpha(0.35 + _coil * 0.35);

  draw_primitive_begin(pr_linestrip);
  for (var i = 0; i <= arrow_ring_count; i++) {
    var _ang = -arrow_ring_angle * (1 + _coil * 3) + i * (360 / arrow_ring_count);
    draw_vertex(arrow_ring_x + lengthdir_x(_inner_radius, _ang),
                arrow_ring_y + lengthdir_y(_inner_radius * _vs, _ang));
  }
  draw_primitive_end();

  var _inner_radius_2 = arrow_ring_current_radius * (0.18 - _coil * 0.05);

  draw_set_alpha(0.2 + _coil * 0.35);

  draw_primitive_begin(pr_linestrip);
  for (var i = 0; i <= arrow_ring_count; i++) {
    var _ang = arrow_ring_angle * (1 + _coil * 4) + i * (360 / arrow_ring_count);
    draw_vertex(arrow_ring_x + lengthdir_x(_inner_radius_2, _ang),
                arrow_ring_y + lengthdir_y(_inner_radius_2 * _vs, _ang));
  }
  draw_primitive_end();

  var _scan_lock = clamp(ring_missile_hand_flash + ring_coil_amount * 0.35, 0, 1);
  var _scan_length = arrow_ring_current_radius * (1.05 + _scan_lock * 0.18);
  var _scan_width = 25 + _scan_lock * 12;
  var _scan_ang = arrow_scan_angle;

  if (_scan_lock > 0.01) {
    _scan_ang = ring_missile_hand_angle;
    _scan_length = max(_scan_length, point_distance(arrow_ring_x, arrow_ring_y, ring_missile_focus_x, ring_missile_focus_y));
  }

  var _tip_x = arrow_ring_x + lengthdir_x(_scan_length, _scan_ang);
  var _tip_y = arrow_ring_y + lengthdir_y(_scan_length * _vs, _scan_ang);

  if (_scan_lock > 0.01) {
    _tip_x = lerp(_tip_x, ring_missile_focus_x, _scan_lock);
    _tip_y = lerp(_tip_y, ring_missile_focus_y, _scan_lock);
  }

  var _left_x = arrow_ring_x + lengthdir_x(_scan_length * 0.45, _scan_ang - _scan_width);
  var _left_y = arrow_ring_y + lengthdir_y(_scan_length * 0.45 * _vs, _scan_ang - _scan_width);

  var _right_x = arrow_ring_x + lengthdir_x(_scan_length * 0.45, _scan_ang + _scan_width);
  var _right_y = arrow_ring_y + lengthdir_y(_scan_length * 0.45 * _vs, _scan_ang + _scan_width);

  draw_set_color(ring_color);
  draw_set_alpha(0.1 + arrow_scan_flash / 12 * 0.32 + _coil * 0.16 + _scan_lock * 0.13);

  draw_primitive_begin(pr_trianglefan);
  draw_vertex(arrow_ring_x, arrow_ring_y);
  draw_vertex(_left_x, _left_y);
  draw_vertex(_tip_x, _tip_y);
  draw_vertex(_right_x, _right_y);
  draw_primitive_end();

  draw_set_color(c_white);
  draw_set_alpha(0.5 + _scan_lock * 0.35);
  draw_line_width(arrow_ring_x, arrow_ring_y, _tip_x, _tip_y, 2 + _scan_lock * 3);
  draw_line_width(arrow_ring_x, arrow_ring_y, _left_x, _left_y, 1);
  draw_line_width(arrow_ring_x, arrow_ring_y, _right_x, _right_y, 1);

  if (_scan_lock > 0.01) {
    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.55));
    draw_set_alpha(_scan_lock * 0.72);
    draw_line_width(arrow_ring_x, arrow_ring_y, ring_missile_focus_x, ring_missile_focus_y, 1.5 + _scan_lock * 2);
    scr_draw_smooth_ring_mask(ring_missile_focus_x, ring_missile_focus_y,
                              lerp(42, 18, _scan_lock), _scan_lock * 0.6, 3 + _scan_lock * 3,
                              merge_color(global.avoid_col_cyan, c_white, 0.45));
  }

  var _pulse = (sin(arrow_core_pulse) + 1) * 0.5;
  var _core_radius = 8 + _pulse * 4 + ring_core_charge * 6 + ring_heartbeat * 5;
  if (arrow_core_flash > 0) _core_radius += arrow_core_flash * 0.8;

  draw_set_color(ring_color);
  draw_set_alpha(0.6 + _coil * 0.3);

  for (var i = 0; i < 4; i++) {
    var _ang = arrow_core_rotation + i * 90;
    draw_line_width(arrow_ring_x + lengthdir_x(_core_radius * 2, _ang),
                    arrow_ring_y + lengthdir_y(_core_radius * 2 * _vs, _ang),
                    arrow_ring_x + lengthdir_x(_core_radius * 2, _ang + 45),
                    arrow_ring_y + lengthdir_y(_core_radius * 2 * _vs, _ang + 45), 2);
  }

  draw_set_color(c_white);
  draw_set_alpha(0.7 + arrow_core_flash / 20);
  draw_circle(arrow_ring_x, arrow_ring_y, _core_radius, false);

  for (var i = 0; i < arrow_ring_count; i++) {
    var _hist = arrow_ring_history[i];
    var _hn = array_length(_hist);

    for (var h = 0; h < _hn; h++) {
      var _ghost = _hist[h];
      var _ghost_alpha = 0.3 * (1 - h / _hn) * _ghost.alpha;
      if (_ghost_alpha <= 0.01) continue;

      draw_sprite_ext(sRedArrow, 0,
                      arrow_ring_x + lengthdir_x(_ghost.radius, _ghost.ang),
                      arrow_ring_y + lengthdir_y(_ghost.radius * _vs, _ghost.ang),
                      _ghost.xscale, _ghost.yscale, _ghost.ang,
                      merge_color(ring_color, c_white, 0.5), _ghost_alpha);
    }
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}


var _cube_shell_col = global.avoid_col_cyan;
var _cube_danger_col = global.avoid_col_danger;
var _cube_hot_col = global.avoid_col_hot;

if (array_length(cube_scars) > 0) {
  gpu_set_blendmode(bm_add);
  for (var s = 0; s < array_length(cube_scars); s++) {
    var _sc = cube_scars[s];
    var _sc_verts = _sc.verts;
    if (array_length(_sc_verts) < 8) continue;

    var _sc_col = merge_color(_cube_danger_col, _cube_hot_col, _sc.hot * 0.55);

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _sce = cube_edges[e];
      var _sa = _sc_verts[_sce[0]];
      var _sb = _sc_verts[_sce[1]];

      var _sax = lerp(cube_center_x, _sa.x, _sc.extend);
      var _say = lerp(cube_center_y, _sa.y, _sc.extend);
      var _sbx = lerp(cube_center_x, _sb.x, _sc.extend);
      var _sby = lerp(cube_center_y, _sb.y, _sc.extend);

      draw_set_color(_sc_col);
      draw_set_alpha(_sc.alpha * 0.10);
      draw_line_width(_sax, _say, _sbx, _sby, 9);
      draw_set_alpha(_sc.alpha * 0.22);
      draw_line_width(_sax, _say, _sbx, _sby, 2.5);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(cube_ghosts) > 0) {
  gpu_set_blendmode(bm_add);
  for (var g = 0; g < array_length(cube_ghosts); g++) {
    var _gh = cube_ghosts[g];
    var _gh_verts = _gh.verts;
    if (array_length(_gh_verts) < 8) continue;

    var _gh_col = merge_color(_cube_shell_col, _cube_danger_col, clamp(0.18 + _gh.hot * 0.42, 0, 0.85));

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _ge = cube_edges[e];
      var _ga = _gh_verts[_ge[0]];
      var _gb = _gh_verts[_ge[1]];

      draw_set_color(_gh_col);
      draw_set_alpha(_gh.alpha * 0.30);
      draw_line_width(lerp(cube_center_x, _ga.x, _gh.extend), lerp(cube_center_y, _ga.y, _gh.extend),
                      lerp(cube_center_x, _gb.x, _gh.extend), lerp(cube_center_y, _gb.y, _gh.extend), 1.6);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(cube_echo_snapshots) > 0) {
  gpu_set_blendmode(bm_add);
  for (var s = 0; s < array_length(cube_echo_snapshots); s++) {
    var _snap = cube_echo_snapshots[s];
    var _snap_verts = _snap.verts;
    if (array_length(_snap_verts) < 8) continue;

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _se = cube_edges[e];
      var _sv1 = _snap_verts[_se[0]];
      var _sv2 = _snap_verts[_se[1]];
      draw_set_color(ring_color);
      draw_set_alpha(_snap.alpha * 0.15);
      draw_line_width(_sv1.x, _sv1.y, _sv2.x, _sv2.y, 1.5);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (cube_seed_flash_timer > 0) {
  var _sf = cube_seed_flash_timer / cube_seed_flash_duration;
  gpu_set_blendmode(bm_add);
  draw_set_color(c_white);
  draw_set_alpha(_sf);
  draw_circle(cube_center_x, cube_center_y, 8 + (1 - _sf) * 20, false);
  draw_set_alpha(_sf * 0.5);
  draw_circle(cube_center_x, cube_center_y, 20 + (1 - _sf) * 40, false);

  var _spikes = 10;
  draw_set_color(merge_color(_cube_shell_col, c_white, 0.6));
  for (var k = 0; k < _spikes; k++) {
    var _ka = k * (360 / _spikes) + (1 - _sf) * 30;
    var _kl = 40 + (1 - _sf) * 220;
    draw_set_alpha(_sf * 0.7);
    draw_line_width(cube_center_x, cube_center_y,
                    cube_center_x + lengthdir_x(_kl, _ka), cube_center_y + lengthdir_y(_kl, _ka),
                    1 + _sf * 3);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (cube_active && array_length(big_cube_projected) >= 8) {
  gpu_set_blendmode(bm_add);

  var _cv = array_create(8);
  for (var i = 0; i < 8; i++) {
    var _raw = big_cube_projected[i];
    _cv[i] = {
      x : lerp(cube_center_x, _raw.x, cube_extend),
      y : lerp(cube_center_y, _raw.y, cube_extend),
      scale : _raw.scale
    };
  }
  cube_cv_frame = _cv;

  var _heat_all = cube_edge_surge + cube_heartbeat * 0.5 + cube_lock_flash * 0.6 +
                  cube_core_flash * 0.4 + cube_overload * 0.5;
  var _cube_alarm = clamp(cube_overload * 0.65 + cube_lock_flash * 0.35 +
                          cube_core_flash * 0.25 + cube_edge_surge * 0.20, 0, 1);
  var _cube_face_col = merge_color(_cube_shell_col, _cube_danger_col, _cube_alarm);

  if (!cube_spawn_active && !cube_despawn_active) {
    var _faces = scr_cube_get_faces();
    var _best_face_check = -1;
    var _best_scale_check = -1;
    for (var f = 0; f < array_length(_faces); f++) {
      var _face_check = _faces[f];
      var _avg_check = (big_cube_projected[_face_check[0]].scale +
                        big_cube_projected[_face_check[1]].scale +
                        big_cube_projected[_face_check[2]].scale +
                        big_cube_projected[_face_check[3]].scale) /
                       4;
      if (_avg_check > _best_scale_check) {
        _best_scale_check = _avg_check;
        _best_face_check = f;
      }
    }

    if (_best_face_check != cube_face_current) {
      cube_face_previous = cube_face_current;
      cube_face_current = _best_face_check;
      cube_face_fade_timer = 0;
    } else {
      cube_face_fade_timer =
          min(cube_face_fade_timer + 1, cube_face_fade_duration);
    }

    var _face_fade_in = cube_face_fade_timer / cube_face_fade_duration;

    if (cube_face_previous != -1) {
      scr_draw_face_by_index(_cv, _cube_face_col, cube_face_previous,
                             (1 - _face_fade_in) * cube_extend);
    }
    if (cube_face_current != -1) {
      scr_draw_face_by_index(_cv, _cube_face_col, cube_face_current,
                             _face_fade_in * cube_extend * (1 + _heat_all * 0.8));
    }
  } else if (cube_despawn_active) {
    var _charge_p = clamp(cube_despawn_timer / cube_despawn_duration, 0, 1);
    var _charge_boost = 1 + _charge_p * _charge_p * 4;

    if (cube_face_current != -1) {
      scr_draw_face_by_index(_cv, _cube_face_col, cube_face_current,
                             cube_extend * _charge_boost);
    }
  }

  for (var f = 0; f < 6; f++) {
    var _fh = cube_face_heat[f] + cube_face_flash[f] * 1.6;
    if (_fh <= 0.01) continue;
    scr_draw_face_by_index(_cv, merge_color(_cube_danger_col, c_white, min(0.7, _fh * 0.5)),
                           f, _fh * 2.2 * cube_extend);
  }

  var _cycle_phase = (sin(cube_edge_phase) + 1) * 0.5;
  var _edge_alarm = clamp(_cycle_phase * 0.28 + _heat_all * 0.22, 0, 1);
  var _edge_color = merge_color(_cube_shell_col, _cube_danger_col, _edge_alarm);
  var _hot_color = merge_color(_edge_color, _cube_hot_col, clamp(0.4 + _heat_all * 0.4, 0, 0.95));

  var _fringe = clamp(_heat_all * 2.6, 0, 7) * cube_extend * fx_get_mult_for("cube", "aberration");

  for (var e = 0; e < array_length(cube_edges); e++) {
    var _edge = cube_edges[e];
    var _v1 = _cv[_edge[0]];
    var _v2 = _cv[_edge[1]];

    var _avg_scale = (_v1.scale + _v2.scale) * 0.5;
    var _depth_alpha = clamp(_avg_scale, 0.15, 1.0);
    var _edge_hot = _depth_alpha * (1 + _heat_all * 0.9);

    var _blur_amount = clamp(1 - _avg_scale, 0, 1);
    if (_blur_amount > 0.15) {
      var _blur_passes = 3;
      for (var b = 1; b <= _blur_passes; b++) {
        var _off = b * _blur_amount * 1.5;
        draw_set_color(_edge_color);
        draw_set_alpha(_depth_alpha * 0.08);
        draw_line_width(_v1.x - _off, _v1.y, _v2.x - _off, _v2.y, 3);
        draw_line_width(_v1.x + _off, _v1.y, _v2.x + _off, _v2.y, 3);
      }
    }

    if (_fringe > 0.4) {
      var _perp = point_direction(_v1.x, _v1.y, _v2.x, _v2.y) + 90;
      var _fx = lengthdir_x(_fringe, _perp);
      var _fy = lengthdir_y(_fringe, _perp);

      draw_set_color(_cube_danger_col);
      draw_set_alpha(_depth_alpha * 0.35);
      draw_line_width(_v1.x + _fx, _v1.y + _fy, _v2.x + _fx, _v2.y + _fy, 2);

      draw_set_color(_cube_shell_col);
      draw_set_alpha(_depth_alpha * 0.35);
      draw_line_width(_v1.x - _fx, _v1.y - _fy, _v2.x - _fx, _v2.y - _fy, 2);
    }

    draw_set_color(_edge_color);
    draw_set_alpha(_depth_alpha * (0.25 + _heat_all * 0.2));
    draw_line_width(_v1.x, _v1.y, _v2.x, _v2.y, 6 + _heat_all * 5);

    draw_set_color(_hot_color);
    draw_set_alpha(min(1, _edge_hot * 0.9));
    draw_line_width(_v1.x, _v1.y, _v2.x, _v2.y, 1.5 + _heat_all * 1.6);

    var _pulse_pos = (current_time * 0.0008 + e * 0.15) mod 1;
    var _px = lerp(_v1.x, _v2.x, _pulse_pos);
    var _py = lerp(_v1.y, _v2.y, _pulse_pos);
    draw_set_color(c_white);
    draw_set_alpha(_depth_alpha * 0.8);
    draw_circle(_px, _py, 3 * _avg_scale, false);
  }

  for (var p = 0; p < array_length(cube_edge_pulses); p++) {
    var _pl = cube_edge_pulses[p];
    var _pe = cube_edges[_pl.edge];
    var _pa = _pl.from_a ? _cv[_pe[0]] : _cv[_pe[1]];
    var _pb = _pl.from_a ? _cv[_pe[1]] : _cv[_pe[0]];

    var _plife = _pl.life / _pl.life_max;
    var _ppos = clamp(_pl.pos, 0, 1);
    var _ptail = clamp(_pl.pos - 0.14, 0, 1);

    var _hx = lerp(_pa.x, _pb.x, _ppos);
    var _hy = lerp(_pa.y, _pb.y, _ppos);
    var _tx = lerp(_pa.x, _pb.x, _ptail);
    var _ty = lerp(_pa.y, _pb.y, _ptail);

    var _pc = merge_color(_cube_danger_col, c_white, 0.35 + _pl.hot * 0.5);
    draw_set_color(_pc);
    draw_set_alpha(_plife * 0.35);
    draw_line_width(_tx, _ty, _hx, _hy, _pl.width * 2.4);
    draw_set_alpha(_plife * 0.95);
    draw_line_width(_tx, _ty, _hx, _hy, _pl.width * 0.8);
    draw_set_color(c_white);
    draw_set_alpha(_plife);
    draw_circle(_hx, _hy, _pl.width * 0.9, false);
  }

  for (var c = 0; c < array_length(cube_cracks); c++) {
    var _ck = cube_cracks[c];
    var _cka = clamp(_ck.life / _ck.life_max, 0, 1);
    if (_cka <= 0.02) continue;

    var _p1 = scr_face_uv_to_point(_cv, _ck.face, _ck.u1, _ck.w1);
    var _p2 = scr_face_uv_to_point(_cv, _ck.face,
                                   lerp(_ck.u1, _ck.u2, _ck.grow),
                                   lerp(_ck.w1, _ck.w2, _ck.grow));

    var _joints = array_length(_ck.off);
    var _cperp = point_direction(_p1.x, _p1.y, _p2.x, _p2.y) + 90;
    var _prevx = _p1.x;
    var _prevy = _p1.y;

    for (var j = 1; j <= _joints + 1; j++) {
      var _jf = j / (_joints + 1);
      var _jx = lerp(_p1.x, _p2.x, _jf);
      var _jy = lerp(_p1.y, _p2.y, _jf);
      if (j <= _joints) {
        var _jt = dsin(_jf * 180);
        _jx += lengthdir_x(_ck.off[j - 1] * _jt, _cperp);
        _jy += lengthdir_y(_ck.off[j - 1] * _jt, _cperp);
      }

      draw_set_color(merge_color(_cube_danger_col, c_white, 0.2));
      draw_set_alpha(_cka * 0.4 * _ck.hot);
      draw_line_width(_prevx, _prevy, _jx, _jy, 4);
      draw_set_color(c_white);
      draw_set_alpha(_cka * 0.9 * _ck.hot);
      draw_line_width(_prevx, _prevy, _jx, _jy, 1.2);

      _prevx = _jx;
      _prevy = _jy;
    }
  }

  for (var m = 0; m < array_length(cube_muzzles); m++) {
    var _mz = cube_muzzles[m];
    var _mza = _mz.life / _mz.life_max;
    if (_mza <= 0.02) continue;

    var _mc = scr_face_uv_to_point(_cv, _mz.face, 0.5, 0.5);
    var _spread = (1 - _mza) * 0.55;
    var _spikes2 = 8;

    draw_set_color(merge_color(_cube_danger_col, c_white, 0.55));
    for (var k = 0; k < _spikes2; k++) {
      var _ma = _mz.spin + k * (360 / _spikes2);
      var _mu = clamp(0.5 + lengthdir_x(_spread, _ma), 0, 1);
      var _mw = clamp(0.5 + lengthdir_y(_spread, _ma), 0, 1);
      var _mp = scr_face_uv_to_point(_cv, _mz.face, _mu, _mw);

      draw_set_alpha(_mza * _mza * 0.75 * _mz.hot);
      draw_line_width(_mc.x, _mc.y, _mp.x, _mp.y, 1 + _mza * 3.5);
    }

    draw_set_color(c_white);
    draw_set_alpha(_mza * _mza * _mz.hot);
    draw_circle(_mc.x, _mc.y, 4 + _mza * 16 * _mz.hot, false);
  }

  for (var i = 0; i < 8; i++) {
    var _v = _cv[i];
    var _va = clamp(_v.scale, 0.15, 1.0);
    var _vh = cube_vertex_heat[i];

    draw_set_color(merge_color(_edge_color, c_white, 0.5 + _vh * 0.4));
    draw_set_alpha(_va * (0.5 + _vh * 0.4) * cube_extend);
    draw_circle(_v.x, _v.y, (5 + _vh * 9) * _va, false);
    draw_set_color(c_white);
    draw_set_alpha(min(1, _va * (0.9 + _vh)) * cube_extend);
    draw_circle(_v.x, _v.y, (2 + _vh * 3) * _va, false);
  }

  if (cube_core_extend > 0.02 && array_length(small_cube_projected) >= 8) {
    var _core_a = cube_core_extend * cube_core_fade * (0.5 + cube_charge * 0.35);
    var _core_col = merge_color(_cube_danger_col, c_white,
                                clamp(0.3 + cube_core_flash * 0.5, 0, 0.95));

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _ce = cube_edges[e];
      var _c1 = small_cube_projected[_ce[0]];
      var _c2 = small_cube_projected[_ce[1]];
      var _cdepth = clamp((_c1.scale + _c2.scale) * 0.5, 0.2, 1.2);

      draw_set_color(_core_col);
      draw_set_alpha(min(1, _core_a * _cdepth * 0.30));
      draw_line_width(_c1.x, _c1.y, _c2.x, _c2.y, 4.5);
      draw_set_color(c_white);
      draw_set_alpha(min(1, _core_a * _cdepth * 0.85));
      draw_line_width(_c1.x, _c1.y, _c2.x, _c2.y, 1.1);
    }

    for (var i = 0; i < 8; i++) {
      var _cvx = small_cube_projected[i];
      draw_set_color(c_white);
      draw_set_alpha(min(1, _core_a * clamp(_cvx.scale, 0.2, 1.2) * 0.9));
      draw_circle(_cvx.x, _cvx.y, 2.2 * clamp(_cvx.scale, 0.3, 1.3), false);
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (instance_number(oCubeFaceBullet) > 0) {
  gpu_set_blendmode(bm_normal);

  with (oCubeFaceBullet) {
    if (bullet_mode != "grid" || image_alpha <= 0.02) continue;
    draw_sprite_ext(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_angle, image_blend, image_alpha);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (laser_jump_warn_active && laser_jump_warn_coil > 0.01) {
  var _ljp = clamp(laser_jump_warn_t / max(laser_jump_warn_len, 1), 0, 1);
  var _ljy = _k_laser_jump_y;
  var _ljr = _k_laser_jump_warn_lane_r;
  var _ljc = max(laser_jump_warn_coil, _k_laser_jump_warn_read_floor);
  var _ljhot = _ljc * _ljc;
  var _ljgate_w = _k_laser_jump_warn_gate_w;
  var _ljhead_l = lerp(_ljgate_w * 0.72, room_width * 0.5 - 10, power(_ljp, 0.78));
  var _ljhead_r = room_width - _ljhead_l;
  var _ljcol = merge_color(_k_er_col_warning, make_color_rgb(246, 254, 255), _ljhot * 0.55);
  var _ljcyan = merge_color(_k_er_col_cyan, c_white, _ljhot * 0.42);
  var _ljstrobe = clamp((_ljp - 0.75) / 0.25, 0, 1);
  var _ljpulse = lerp(0.72 + 0.28 * sin(t * 0.85),
                      0.32 + 0.68 * abs(sin(t * 1.9)), _ljstrobe);

  var _ljslot_r = _ljr * 2.4;
  var _ljhold = _ljr * (1.03 + _ljc * 0.12);
  var _ljslot_a = _k_laser_jump_warn_slot_a[0]
                + (_k_laser_jump_warn_slot_a[1] - _k_laser_jump_warn_slot_a[0]) * _ljc;

  draw_set_color(c_black);
  draw_set_alpha(_ljslot_a);
  draw_rectangle(0, _ljy - _ljhold, room_width, _ljy + _ljhold, false);

  for (var _ljsgn = -1; _ljsgn <= 1; _ljsgn += 2) {
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(0,          _ljy + _ljsgn * _ljhold,   c_black, _ljslot_a);
    draw_vertex_colour(room_width, _ljy + _ljsgn * _ljhold,   c_black, _ljslot_a);
    draw_vertex_colour(0,          _ljy + _ljsgn * _ljslot_r, c_black, 0);
    draw_vertex_colour(room_width, _ljy + _ljsgn * _ljslot_r, c_black, 0);
    draw_primitive_end();
  }

  gpu_set_blendmode(bm_add);

  draw_set_color(_ljcyan);
  draw_set_alpha((0.10 + _ljhot * 0.16) * _ljpulse);
  draw_line_width(0, _ljy, room_width, _ljy, 2 + _ljc * 5);

  var _ljdeep = 16 + _ljhot * _k_laser_jump_warn_spill * 0.72;
  var _ljspills = [
    [ 1.00, 0.09 + _ljhot * 0.10, 0.00 ],
    [ 0.38, 0.12 + _ljhot * 0.14, 0.38 ],
    [ 0.14, 0.16 + _ljhot * 0.22, 0.82 ]
  ];

  for (var _ljsp = 0; _ljsp < 3; _ljsp++) {
    var _ljpass = _ljspills[_ljsp];
    var _ljdep = _ljdeep * _ljpass[0];
    var _ljpcol = merge_color(_ljcol, c_white, _ljpass[2]);
    var _ljpa = min(1, _ljpass[1]);

    for (var _ljsg2 = -1; _ljsg2 <= 1; _ljsg2 += 2) {
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(0,          _ljy, _ljpcol, _ljpa);
      draw_vertex_colour(room_width, _ljy, _ljpcol, _ljpa);
      draw_vertex_colour(0,          _ljy + _ljsg2 * _ljdep, _ljpcol, 0);
      draw_vertex_colour(room_width, _ljy + _ljsg2 * _ljdep, _ljpcol, 0);
      draw_primitive_end();
    }
  }

  var _ljfringe = 2 + _ljhot * 6;
  for (var _ljlip_sgn = -1; _ljlip_sgn <= 1; _ljlip_sgn += 2) {
    var _ljlip_y = _ljy + _ljlip_sgn * _ljr;

    draw_set_color(_ljcol);
    draw_set_alpha(0.22 + _ljhot * 0.48);
    draw_line_width(0, _ljlip_y, room_width, _ljlip_y, 2.5 + _ljc * 3.5);

    draw_set_color(c_white);
    draw_set_alpha(0.22 + _ljhot * 0.56);
    draw_line_width(0, _ljlip_y, room_width, _ljlip_y, 1 + _ljc * 2);

    draw_set_color(_k_er_col_warning);
    draw_set_alpha(0.10 + _ljhot * 0.28);
    draw_line_width(0, _ljlip_y - _ljlip_sgn * _ljfringe,
                    room_width, _ljlip_y - _ljlip_sgn * _ljfringe, 2.5);
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(0.10 + _ljhot * 0.28);
    draw_line_width(0, _ljlip_y + _ljlip_sgn * _ljfringe,
                    room_width, _ljlip_y + _ljlip_sgn * _ljfringe, 2.5);
  }

  for (var _ljside = 0; _ljside < 2; _ljside++) {
    var _ljmx = (_ljside == 0) ? 0 : room_width;
    var _ljdir = (_ljside == 0) ? 1 : -1;
    var _ljgx0 = (_ljside == 0) ? 0 : room_width - _ljgate_w;
    var _ljgx1 = (_ljside == 0) ? _ljgate_w : room_width;
    var _ljhead = (_ljside == 0) ? _ljhead_l : _ljhead_r;

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(0.42 + _ljhot * 0.28);
    draw_rectangle(_ljgx0, _ljy - _ljr * 1.75,
                   _ljgx1, _ljy + _ljr * 1.75, false);
    gpu_set_blendmode(bm_add);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_ljmx, _ljy - _ljr * 2.3, c_white, 0.20 + _ljhot * 0.58);
    draw_vertex_colour(_ljmx, _ljy + _ljr * 2.3, c_white, 0.20 + _ljhot * 0.58);
    draw_vertex_colour(_ljmx + _ljdir * (44 + _ljhot * 112), _ljy - _ljr * 0.55, _ljcol, 0);
    draw_vertex_colour(_ljmx + _ljdir * (44 + _ljhot * 112), _ljy + _ljr * 0.55, _ljcol, 0);
    draw_primitive_end();

    scr_draw_lock_bracket(_ljgx0 + 4, _ljy - _ljr * 1.62,
                          _ljgx1 - 4, _ljy + _ljr * 1.62,
                          _k_er_col_warning, _ljc, 1,
                          14, false, 4, 0, _ljpulse, _k_er_col_cyan);

    draw_set_color(c_white);
    draw_set_alpha((0.35 + _ljhot * 0.50) * _ljpulse);
    draw_line_width(_ljhead, _ljy - _ljr * 1.45,
                    _ljhead, _ljy + _ljr * 1.45, 2 + _ljc * 2);
    draw_set_color(_k_er_col_warning);
    draw_set_alpha((0.25 + _ljhot * 0.45) * _ljpulse);
    draw_line_width(_ljhead, _ljy - _ljr * 2.4,
                    _ljhead, _ljy + _ljr * 2.4, 1.5);

    for (var _ljpk = 0; _ljpk < _k_laser_jump_warn_packet_n; _ljpk++) {
      var _ljpf = frac(_ljpk / _k_laser_jump_warn_packet_n
                       + current_time * 0.0014 * (0.8 + _ljc));
      var _ljpx = (_ljside == 0) ? lerp(_ljmx + 10, _ljhead, _ljpf)
                                 : lerp(_ljmx - 10, _ljhead, _ljpf);
      var _ljpa2 = sin(_ljpf * pi) * (0.22 + _ljhot * 0.52);
      var _ljcw = 6 + _ljc * 6;
      var _ljpk_col = ((_ljpk mod 3) == 0) ? _k_er_col_cyan
                    : (((_ljpk mod 3) == 1) ? _k_er_col_warning : _k_er_col_violet);

      draw_set_color(merge_color(_ljpk_col, c_white, 0.28 + _ljhot * 0.42));
      draw_set_alpha(_ljpa2);
      draw_line_width(_ljpx - _ljdir * (18 + _ljc * 18), _ljy,
                      _ljpx + _ljdir * (4 + _ljc * 6), _ljy, 2.5);

      draw_set_color(c_white);
      draw_set_alpha(_ljpa2 * 0.58);
      draw_line_width(_ljpx - _ljdir * _ljcw, _ljy - _ljcw,
                      _ljpx, _ljy, 1.5);
      draw_line_width(_ljpx - _ljdir * _ljcw, _ljy + _ljcw,
                      _ljpx, _ljy, 1.5);
    }
  }

  scr_draw_lock_bracket(18, _ljy - _ljr, room_width - 18, _ljy + _ljr,
                        _k_er_col_warning, _ljc, 0.95,
                        14, false, 0, 0, _ljpulse, _k_er_col_cyan);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(laser_jump_bursts) > 0) {
  for (var _ljbi = 0; _ljbi < array_length(laser_jump_bursts); _ljbi++) {
    var _ljsb = laser_jump_bursts[_ljbi];
    var _ljage = _ljsb.life_max - _ljsb.life;
    var _ljsp = clamp(_ljage / max(_ljsb.life_max - 1, 1), 0, 1);
    var _ljsweep = 1 - power(1 - clamp(_ljsp * 1.45, 0, 1), 3);
    var _ljx0 = (_ljsb.dir > 0) ? 0 : room_width;
    var _ljx1 = _ljx0 + _ljsb.dir * room_width * _ljsweep;
    var _ljx_min = min(_ljx0, _ljx1);
    var _ljx_max = max(_ljx0, _ljx1);
    var _ljfade = power(clamp(_ljsb.life / _ljsb.life_max, 0, 1), 0.7);
    var _ljhh = _k_laser_jump_burst_hit_r + 4;
    draw_set_color(_k_er_col_rock);
    draw_set_alpha(0.92 * _ljfade);
    draw_rectangle(_ljx_min, _ljsb.y - _ljhh, _ljx_max, _ljsb.y + _ljhh, false);
    draw_set_color(merge_color(_k_er_col_rim, _ljsb.col, 0.65));
    draw_set_alpha(0.75 * _ljfade);
    draw_line_width(_ljx_min, _ljsb.y - _ljhh, _ljx_max, _ljsb.y - _ljhh, 2);
    draw_line_width(_ljx_min, _ljsb.y + _ljhh, _ljx_max, _ljsb.y + _ljhh, 2);
    draw_set_alpha(1);
  }
  draw_set_color(c_white);
}

if (array_length(laser_x_marks) > 0 || array_length(laser_chain_spawn_flashes) > 0) {
  gpu_set_blendmode(bm_normal);
  for (var g = 0; g < array_length(laser_x_marks); g++) {
    var _mark = laser_x_marks[g];
    var _born = 1 - (_mark.life / max(_mark.life_max, 1));
    var _in = clamp(_born / 0.16, 0, 1);
    var _fade = clamp(_mark.life / 18, 0, 1);
    var _a = _in * _fade;
    if (_a <= 0.01) continue;

    var _active = variable_struct_exists(_mark, "active") && _mark.active;
    var _active_p = _active ? clamp(_mark.life / max(_mark.active_life, 1), 0, 1) : 1;
    var _shrink = _active ? lerp(0.3, 1, power(_active_p, 0.7)) : 1;
    var _strike = variable_struct_exists(_mark, "strike") ? _mark.strike : 0;
    var _hot = _active ? clamp(0.82 + _mark.hot * 0.16 + _strike * 0.2, 0, 1)
                       : clamp(_mark.hot + _mark.ring * 0.2, 0, 1);
    var _xcol = merge_color(global.avoid_col_cyan, global.avoid_col_warning, _hot);
    var _xwhite = merge_color(_xcol, c_white, 0.35 + _hot * 0.3);
    var _len = _mark.arm_len * (0.82 + _in * 0.18 + _mark.hot * 0.08) * _shrink * (1 + _strike * 0.12);
    var _w = _mark.arm_width * (0.85 + _mark.hot * 0.22) * (_active ? lerp(0.62, 1, _active_p) : 1);

    for (var _axis = 0; _axis < 2; _axis++) {
      var _ang = _mark.ang + _axis * 90;
      var _x1 = _mark.x + lengthdir_x(_len, _ang);
      var _y1 = _mark.y + lengthdir_y(_len, _ang);
      var _x2 = _mark.x - lengthdir_x(_len, _ang);
      var _y2 = _mark.y - lengthdir_y(_len, _ang);
      var _nx = lengthdir_x(1, _ang + 90);
      var _ny = lengthdir_y(1, _ang + 90);

      draw_set_color(global.avoid_col_armor_dark);
      draw_set_alpha(0.58 * _a);
      draw_line_width(_x1, _y1, _x2, _y2, _w * 1.45);

      draw_set_color(merge_color(global.avoid_col_armor_mid, global.avoid_col_armor_edge, 0.34 + _hot * 0.16));
      draw_set_alpha(0.72 * _a);
      draw_line_width(_x1, _y1, _x2, _y2, _w * 0.78);

      draw_set_color(merge_color(global.avoid_col_armor_dark, _xcol, 0.32 + _hot * 0.35));
      draw_set_alpha(0.72 * _a);
      draw_line_width(_x1, _y1, _x2, _y2, _w * 0.26);

      if (_active) {
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha((0.28 + _strike * 0.28) * _a);
        draw_line_width(_x1, _y1, _x2, _y2, _w * 0.58);
        draw_set_color(global.avoid_col_hot);
        draw_set_alpha((0.14 + _strike * 0.26) * _a);
        draw_line_width(_x1, _y1, _x2, _y2, max(2, _w * 0.14));
      }

      draw_set_color(_xwhite);
      draw_set_alpha((0.26 + _hot * 0.28) * _a);
      draw_line_width(_x1 + _nx * _w * 0.31, _y1 + _ny * _w * 0.31,
                      _x2 + _nx * _w * 0.31, _y2 + _ny * _w * 0.31, 1);
      draw_line_width(_x1 - _nx * _w * 0.31, _y1 - _ny * _w * 0.31,
                      _x2 - _nx * _w * 0.31, _y2 - _ny * _w * 0.31, 1);

      for (var _sgn = -1; _sgn <= 1; _sgn += 2) {
        var _ex = _mark.x + lengthdir_x(_len * _sgn, _ang);
        var _ey = _mark.y + lengthdir_y(_len * _sgn, _ang);
        var _cap = _mark.cap * (0.9 + _hot * 0.35);

        draw_set_color(global.avoid_col_armor_dark);
        draw_set_alpha(0.82 * _a);
        draw_circle(_ex, _ey, _cap * 2.0, false);
        draw_set_color(_xcol);
        draw_set_alpha((0.38 + _hot * 0.24) * _a);
        draw_circle(_ex, _ey, _cap * 1.35, true);
        draw_set_color(c_white);
        draw_set_alpha((0.16 + _hot * 0.42) * _a);
        draw_circle(_ex, _ey, _cap * 0.42, false);
      }

      for (var _tk = 0; _tk < 5; _tk++) {
        var _tu = 0.24 + _tk * 0.14;
        var _side = ((_tk mod 2) == 0) ? -1 : 1;
        var _tx = _mark.x + lengthdir_x(_len * _tu * _side, _ang);
        var _ty = _mark.y + lengthdir_y(_len * _tu * _side, _ang);
        var _tw = (4 + _hot * 5) * (0.75 + 0.25 * sin(_mark.phase + _mark.tick_seed + _tk));

        draw_set_color((_tk mod 3 == 0) ? global.avoid_col_warning : global.avoid_col_cyan);
        draw_set_alpha((0.24 + _hot * 0.32) * _a);
        draw_line_width(_tx - _nx * _tw, _ty - _ny * _tw,
                        _tx + _nx * _tw, _ty + _ny * _tw, 1);
      }
    }

    if (_strike > 0.01) {
      var _strike_ang = variable_struct_exists(_mark, "trigger_ang") ? _mark.trigger_ang : _mark.ang;
      draw_set_color(global.avoid_col_hot);
      draw_set_alpha(_strike * 0.48 * _a);
      draw_line_width(_mark.x + lengthdir_x(_mark.arm_len * 1.08, _strike_ang),
                      _mark.y + lengthdir_y(_mark.arm_len * 1.08, _strike_ang),
                      _mark.x - lengthdir_x(_mark.arm_len * 1.08, _strike_ang),
                      _mark.y - lengthdir_y(_mark.arm_len * 1.08, _strike_ang), 3);
      draw_set_color(c_white);
      draw_set_alpha(_strike * 0.65 * _a);
      draw_circle(_mark.x, _mark.y, 8 + _strike * 10, false);
    }

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(0.92 * _a);
    draw_circle(_mark.x, _mark.y, 14 + _hot * 4, false);
    draw_set_color(_xcol);
    draw_set_alpha((0.5 + _hot * 0.24) * _a);
    scr_draw_smooth_ring_mask(_mark.x, _mark.y, 12 + _hot * 9, 0.48 * _a, 3, _xcol);
    draw_set_color(c_white);
    draw_set_alpha((0.18 + _hot * 0.5) * _a);
    draw_circle(_mark.x, _mark.y, 3 + _hot * 2, false);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);

  gpu_set_blendmode(bm_add);
  for (var sf = 0; sf < array_length(laser_chain_spawn_flashes); sf++) {
    var _flash = laser_chain_spawn_flashes[sf];
    var _fp = 1 - (_flash.life / _flash.life_max);
    var _fcol = merge_color(global.avoid_col_cyan, global.avoid_col_warning, _fp);
    scr_draw_smooth_ring_mask(_flash.x, _flash.y, _fp * _k_laser_chain_spawn_flash_radius,
                              (1 - _fp) * 0.7, 14, _fcol);
    draw_set_color(c_white);
    draw_set_alpha((1 - _fp) * 0.8);
    draw_circle(_flash.x, _flash.y, 6 * (1 - _fp * 0.6), false);
  }

  for (var _mx = 0; _mx < array_length(laser_x_marks); _mx++) {
    var _m = laser_x_marks[_mx];
    var _born2 = 1 - (_m.life / max(_m.life_max, 1));
    var _in2 = clamp(_born2 / 0.16, 0, 1);
    var _fade2 = clamp(_m.life / 18, 0, 1);
    var _a2 = _in2 * _fade2;
    if (_a2 <= 0.01) continue;

    var _active2 = variable_struct_exists(_m, "active") && _m.active;
    var _hot2 = _active2 ? clamp(0.86 + _m.hot * 0.12, 0, 1)
                         : clamp(_m.hot + _m.ring * 0.35, 0, 1);
    var _col2 = merge_color(global.avoid_col_cyan, global.avoid_col_warning, _hot2);
    var _pulse_r = (28 + (1 - _m.ring) * 38) * (0.85 + _hot2 * 0.25);
    if (_m.ring > 0.01) {
      scr_draw_smooth_ring_mask(_m.x, _m.y, _pulse_r, _m.ring * 0.34 * _a2, 5, _col2);
    }
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (orb_volley_lock_on_timer > 0) {
  var _lp = orb_volley_lock_on_timer / _k_orb_volley_lock_on_frames;
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(orb_volley_lock_on_targets); i++) {
    var _tgt = orb_volley_lock_on_targets[i];
    draw_set_color(_k_orb_volley_color);
    draw_set_alpha(0.25 * _lp);
    draw_line_width(orb_volley_lock_on_origin_x, orb_volley_lock_on_origin_y, _tgt[0], _tgt[1], 1);
    draw_set_color(c_white);
    draw_set_alpha(0.6 * _lp);
    draw_circle(_tgt[0], _tgt[1], 4 * _lp, false);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(orb_volley_shards) > 0 || array_length(orb_volley_bursts) > 0) {
  gpu_set_blendmode(bm_add);

  for (var bi = 0; bi < array_length(orb_volley_bursts); bi++) {
    var _b = orb_volley_bursts[bi];
    var _bp = 1 - (_b.life / _b.life_max);
    scr_draw_smooth_ring_mask(_b.x, _b.y, _bp * _b.max_radius, (1 - _bp) * 0.8, 14, _k_orb_volley_color);
  }

  for (var si = 0; si < array_length(orb_volley_shards); si++) {
    var _s = orb_volley_shards[si];
    if (_s.delay > 0) {
      var _hp = 0.5 + 0.5 * sin(current_time * 0.05 + si);
      draw_set_color(c_white);
      draw_set_alpha(0.5 * _hp);
      draw_circle(_s.x, _s.y, 5 + 3 * _hp, false);
      continue;
    }

    var _tn = array_length(_s.trail);
    for (var ti = 0; ti < _tn; ti++) {
      var _tp = _s.trail[ti];
      var _age = ti / max(_tn - 1, 1);
      draw_set_color(_k_orb_volley_color);
      draw_set_alpha(_age * 0.35);
      draw_circle(_tp.x, _tp.y, lerp(1, 5, _age), false);
    }

    var _dir = point_direction(_s.ox, _s.oy, _s.tx, _s.ty);
    var _len = 16, _wid = 6;
    var _tip_x = _s.x + lengthdir_x(_len, _dir);
    var _tip_y = _s.y + lengthdir_y(_len, _dir);
    var _bl_x = _s.x + lengthdir_x(_wid, _dir + 130);
    var _bl_y = _s.y + lengthdir_y(_wid, _dir + 130);
    var _br_x = _s.x + lengthdir_x(_wid, _dir - 130);
    var _br_y = _s.y + lengthdir_y(_wid, _dir - 130);

    draw_set_color(merge_color(_k_orb_volley_color, c_white, 0.3));
    draw_set_alpha(0.9);
    draw_triangle(_tip_x, _tip_y, _bl_x, _bl_y, _br_x, _br_y, false);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_circle(_tip_x, _tip_y, 2.5, false);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (laser_warn_band_coil > 0.01) {
  scr_draw_erupt_warn_band(laser_warn_band_edge, laser_warn_band_coil);
}

if (laser_coil_active || laser_coil_flash > 0.01) {
  var _lcp = laser_coil_active ? clamp(laser_coil_t / laser_coil_len, 0, 1) : 1;
  var _lcpow = laser_coil_power;
  var _lcf = laser_coil_flash;
  var _lccol = merge_color(global.avoid_col_warning, c_white, 0.25 + _lcp * 0.5 + _lcf * 0.25);

  gpu_set_blendmode(bm_add);

  for (var _lcp2 = 0; _lcp2 < array_length(laser_coil_pulses); _lcp2++) {
    var _lcpu = laser_coil_pulses[_lcp2];
    scr_draw_smooth_ring_mask(laser_coil_x, laser_coil_y, _lcpu.radius * _lcpow,
                              _lcpu.alpha * 0.8, 7, _lccol);
  }

  if (laser_coil_active) {
    var _lcr = lerp(_k_laser_coil_ring_start, _k_laser_coil_ring_end, _lcp) * _lcpow;
    var _lcseg = 26;
    var _lcprev_x = 0, _lcprev_y = 0;
    draw_set_color(_lccol);
    for (var _lcs = 0; _lcs <= _lcseg; _lcs++) {
      var _lca2 = _lcs * (360 / _lcseg);
      var _lcjit = random_range(-1, 1) * (1 + _lcp * 5);
      var _lcx2 = laser_coil_x + lengthdir_x(_lcr + _lcjit, _lca2);
      var _lcy2 = laser_coil_y + lengthdir_y(_lcr + _lcjit, _lca2);

      if (_lcs > 0) {
        draw_set_alpha((0.25 + _lcp * 0.35) * _lcpow);
        draw_line_width(_lcprev_x, _lcprev_y, _lcx2, _lcy2, 5);
        draw_set_alpha((0.6 + _lcp * 0.4) * _lcpow);
        draw_line_width(_lcprev_x, _lcprev_y, _lcx2, _lcy2, 1.4);
      }
      _lcprev_x = _lcx2;
      _lcprev_y = _lcy2;
    }

    var _fl_len = (40 + _lcp * 150) * _lcpow;
    var _fl_wid = (5 + _lcp * 16) * _lcpow;
    var _fl_d = laser_coil_dir;
    for (var _fs = -1; _fs <= 1; _fs += 2) {
      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_color(laser_coil_x, laser_coil_y, _lccol, 0.75 * _lcp);
      draw_vertex_color(laser_coil_x + lengthdir_x(_fl_wid, _fl_d + 90 * _fs),
                        laser_coil_y + lengthdir_y(_fl_wid, _fl_d + 90 * _fs), _lccol, 0);
      draw_vertex_color(laser_coil_x + lengthdir_x(_fl_len, _fl_d),
                        laser_coil_y + lengthdir_y(_fl_len, _fl_d), _lccol, 0);
      draw_primitive_end();
    }

    if (laser_lock_len > 8) {
      var _lb_hot = max(power(_lcp, 1.45),
                        lerp(_k_laser_lock_read_floor, 1, power(_lcp, 1.2)));
      var _lb_pulse = 0.62 + 0.38 * sin(current_time * 0.018);

      var _lb_alpha = laser_coil_centered ? 1.6 : 1;

      scr_draw_lock_bracket(laser_lock_cx - laser_lock_len, laser_lock_cy - laser_lock_wid,
                            laser_lock_cx + laser_lock_len, laser_lock_cy + laser_lock_wid,
                            global.avoid_col_warning, _lb_hot, _lb_alpha,
                            _k_laser_lock_tick, true, _k_laser_lock_pad_box,
                            laser_lock_ang, _lb_pulse, global.avoid_col_cyan);
    }
  }

  draw_set_color(c_white);
  draw_set_alpha(clamp(0.35 + _lcp * 0.55 + _lcf, 0, 1));
  draw_circle(laser_coil_x, laser_coil_y, (3 + _lcp * 9 + _lcf * 26) * _lcpow, false);
  draw_set_color(_lccol);
  draw_set_alpha(clamp(0.25 + _lcp * 0.4 + _lcf * 0.7, 0, 1));
  draw_circle(laser_coil_x, laser_coil_y, (7 + _lcp * 20 + _lcf * 52) * _lcpow, false);

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(laser_beam_scars) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _bs = 0; _bs < array_length(laser_beam_scars); _bs++) {
    var _sc = laser_beam_scars[_bs];
    var _x1 = _sc.x - lengthdir_x(_sc.half_len, _sc.ang);
    var _y1 = _sc.y - lengthdir_y(_sc.half_len, _sc.ang);
    var _x2 = _sc.x + lengthdir_x(_sc.half_len, _sc.ang);
    var _y2 = _sc.y + lengthdir_y(_sc.half_len, _sc.ang);

    var _sc_col = variable_struct_exists(_sc, "col") ? _sc.col : c_red;

    draw_set_color(merge_color(_sc_col, c_black, 0.55));
    draw_set_alpha(_sc.alpha * 0.22);
    draw_line_width(_x1, _y1, _x2, _y2, 10);

    draw_set_color(merge_color(_sc_col, c_white, _sc.alpha * 0.6));
    draw_set_alpha(_sc.alpha * _sc.alpha * 0.8);
    draw_line_width(_x1, _y1, _x2, _y2, 1 + _sc.alpha * 2);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (laser_finale_charge > 0.01 || array_length(laser_finale_pulses) > 0) {
  var _fcx = room_width / 2;
  var _fcy = room_height / 2;
  var _fchg = laser_finale_charge;
  var _fflash = laser_finale_flash;

  gpu_set_blendmode(bm_add);

  for (var _fp = 0; _fp < array_length(laser_finale_pulses); _fp++) {
    var _fpu = laser_finale_pulses[_fp];
    scr_draw_smooth_ring_mask(_fcx, _fcy, _fpu.radius, _fpu.alpha * 0.8,
                              6 + _fpu.hot * 14, merge_color(c_red, c_white, _fpu.hot * 0.5));
  }

  if (_fchg > 0.01) {
    var _fring_r = lerp(300, 120, _fchg) - _fflash * 30;
    scr_draw_smooth_ring_mask(_fcx, _fcy, _fring_r, (0.18 + _fchg * 0.3 + _fflash * 0.4),
                              3 + _fchg * 9, merge_color(c_red, c_white, 0.3 + _fflash * 0.5));

    draw_set_color(c_white);
    draw_set_alpha((0.2 + _fflash * 0.7) * _fchg);
    draw_circle(_fcx, _fcy, 4 + _fchg * 10 + _fflash * 22, false);
    draw_set_alpha(1);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_color(c_white);
}

if (storm_intensity > 0.001 && array_length(storm_rain_streaks) > 0) {
  gpu_set_blendmode(bm_add);

  if (storm_sky_flash > 0.01) {
    var _sky_h = 220;
    var _sky_steps = 10;
    for (var _syi = 0; _syi < _sky_steps; _syi++) {
      var _sy_t = _syi / _sky_steps;
      draw_set_color(merge_color(c_red, c_white, 0.35 + storm_sky_flash * 0.3));
      draw_set_alpha(storm_sky_flash * 0.10 * (1 - _sy_t));
      draw_rectangle(0, _sy_t * _sky_h, room_width, (_sy_t + 1 / _sky_steps) * _sky_h, false);
    }
  }

  for (var _sbi2 = 0; _sbi2 < array_length(storm_sky_bolts); _sbi2++) {
    var _sb = storm_sky_bolts[_sbi2];
    var _sb_a = _sb.life / _sb.life_max;
    var _sb_px = _sb.x, _sb_py = -20;
    var _sb_segs = 7;
    draw_set_color(merge_color(c_red, c_white, 0.6));
    for (var _sbs = 1; _sbs <= _sb_segs; _sbs++) {
      var _sb_t = _sbs / _sb_segs;
      var _sb_nx = _sb.x + sin(_sb.seed + _sbs * 2.3) * 26 * _sb_t;
      var _sb_ny = lerp(-20, _sb.y, _sb_t);
      draw_set_alpha(_sb_a * 0.5);
      draw_line_width(_sb_px, _sb_py, _sb_nx, _sb_ny, _sb.w);
      draw_set_alpha(_sb_a * 0.85);
      draw_line_width(_sb_px, _sb_py, _sb_nx, _sb_ny, _sb.w * 0.35);
      _sb_px = _sb_nx;
      _sb_py = _sb_ny;
    }
  }

  for (var _rdi = 0; _rdi < array_length(storm_rain_streaks); _rdi++) {
    var _rd = storm_rain_streaks[_rdi];
    var _band_t = _rd.band / max(_k_storm_rain_bands - 1, 1);
    var _rd_alpha = _k_storm_rain_alpha * lerp(0.35, 1, _band_t) * storm_intensity;
    var _rd_lean = storm_wind * (0.5 + _band_t * 0.5) * 1.6;

    draw_set_color(merge_color(make_color_rgb(150, 30, 34), c_white, _band_t * 0.35));
    draw_set_alpha(_rd_alpha);
    draw_line_width(_rd.x, _rd.y, _rd.x - _rd_lean, _rd.y - _rd.len, lerp(0.8, 1.8, _band_t));
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (storm_sweep_active) {
  var _sw_y = lerp(room_height + 40, -60, storm_sweep);
  var _sw_fade = sin(storm_sweep * pi);
  var _sw_h = 90;

  gpu_set_blendmode(bm_add);
  var _sw_steps = 8;
  for (var _swi = 0; _swi < _sw_steps; _swi++) {
    var _sw_t = _swi / _sw_steps;
    draw_set_color(merge_color(c_red, c_white, 0.3 + _sw_t * 0.4));
    draw_set_alpha(_sw_fade * 0.13 * (1 - _sw_t));
    draw_rectangle(0, _sw_y - _sw_h * (1 - _sw_t), room_width, _sw_y + _sw_h * (1 - _sw_t) * 0.35, false);
  }
  draw_set_color(c_white);
  draw_set_alpha(_sw_fade * 0.55);
  draw_rectangle(0, _sw_y - 2, room_width, _sw_y + 2, false);

  var _k_sw_fil = 14;
  for (var _swf = 0; _swf < _k_sw_fil; _swf++) {
    var _swf_x = (_swf + 0.5) * (room_width / _k_sw_fil) + sin(_swf * 3.7) * 18;
    var _swf_len = 40 + abs(sin(_swf * 2.1)) * 70;
    draw_set_color(merge_color(c_red, c_white, 0.5));
    draw_set_alpha(_sw_fade * 0.45);
    draw_line_width(_swf_x, _sw_y, _swf_x, _sw_y + _swf_len, 2);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (orb_ceiling_built && storm_intensity > 0.001) {
  var _ceil_n   = array_length(orb_ceiling_pts);
  var _ceil_hot = clamp(orb_ceiling_heat, 0, 1);
  var _ceil_a   = clamp(storm_intensity * 1.1, 0, 1);
  var _fin      = clamp(orb_finale, 0, 1);
  var _snap     = clamp(orb_rain_flash, 0, 1);

  var _sy = array_create(_ceil_n, 0);
  var _sxp = array_create(_ceil_n, 0);
  for (var _sc0 = 0; _sc0 < _ceil_n; _sc0++) {
    _sxp[_sc0] = orb_ceiling_pts[_sc0].x;
    _sy[_sc0]  = orbrain_seam_y(_sxp[_sc0]);
  }

  // ---- 1. the mass: an absence of sky, not a glow ----
  gpu_set_blendmode(bm_normal);
  draw_set_color(make_color_rgb(6, 4, 10));
  draw_set_alpha(_ceil_a * (0.72 + _ceil_hot * 0.2));
  draw_primitive_begin(pr_trianglestrip);
  for (var _cb = 0; _cb < _ceil_n; _cb++) {
    draw_vertex(_sxp[_cb], -40);
    draw_vertex(_sxp[_cb], _sy[_cb]);
  }
  draw_primitive_end();

  // ---- 1b. compact emitter ports tucked into the cracked ceiling ----
  var _port_n = max(1, _k_orbrain_ceiling_ports);
  for (var _po = 0; _po < _port_n; _po++) {
    var _pf = (_po + 0.5) / _port_n;
    var _px0 = _pf * room_width + sin(_po * 4.7 + 0.6) * 8;
    var _py0 = orbrain_seam_y(_px0);
    var _pd = abs(_px0 - orb_ceiling_epi);
    var _pbeat = exp(-(_pd * _pd) / (2 * 170 * 170));
    var _pheat = clamp(_ceil_hot * 0.55 + _snap * _pbeat + _fin * 0.7, 0, 1);
    var _pw = 22 + _pheat * 12;
    var _ph = 7 + _pheat * 3;

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_ceil_a * (0.44 + _pheat * 0.18));
    draw_rectangle(_px0 - _pw * 0.5, _py0 - _ph, _px0 + _pw * 0.5, _py0 + _ph * 0.2, false);

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_ceil_a * (0.32 + _pheat * 0.2));
    draw_line_width(_px0 - _pw * 0.5, _py0 + 1, _px0 + _pw * 0.5, _py0 + 1, 1.4);
    draw_line_width(_px0 - _pw * 0.36, _py0 - _ph, _px0 - _pw * 0.15, _py0 - _ph, 1);
    draw_line_width(_px0 + _pw * 0.15, _py0 - _ph, _px0 + _pw * 0.36, _py0 - _ph, 1);

    if (_pheat > 0.04) {
      draw_set_color(merge_color(global.avoid_col_warning, c_white, _pheat * 0.45));
      draw_set_alpha(_ceil_a * (0.14 + _pheat * 0.32));
      draw_line_width(_px0 - _pw * 0.22, _py0 + 2.4, _px0 + _pw * 0.22, _py0 + 2.4,
                      1.2 + _pheat * 1.5);
    }
  }

  gpu_set_blendmode(bm_add);

  // ---- 2. the lip: white-hot line along the underside, with chromatic fringe ----
  var _lip_fringe = (1.1 + _ceil_hot * 2.6 + _snap * 1.8 + _fin * 3) * fx_get_mult("aberration");

  for (var _lp = 0; _lp < 3; _lp++) {
    var _lp_col = c_white;
    var _lp_off = 0;
    if (_lp == 0) {
      _lp_col = global.avoid_col_danger;
      _lp_off = _lip_fringe;
    } else if (_lp == 1) {
      _lp_col = global.avoid_col_cyan;
      _lp_off = -_lip_fringe;
    }
    var _lp_w   = (_lp == 2) ? (1.2 + _ceil_hot * 1.6 + _snap * 2.4) : (2.2 + _ceil_hot * 2);
    var _lp_a   = (_lp == 2) ? (0.5 + _ceil_hot * 0.5) : (0.28 + _ceil_hot * 0.34);

    draw_set_color(_lp_col);
    draw_set_alpha(_ceil_a * _lp_a);
    for (var _lc = 0; _lc < _ceil_n - 1; _lc++) {
      draw_line_width(_sxp[_lc], _sy[_lc] + _lp_off,
                      _sxp[_lc + 1], _sy[_lc + 1] + _lp_off, _lp_w);
    }
  }

  // ---- 3. heat bleeding down off the seam on a hit ----
  if (_ceil_hot > 0.02 || _fin > 0.01) {
    var _bleed = 26 + _ceil_hot * 40 + _fin * 70;
    var _bleed_steps = 5;
    for (var _bs = 0; _bs < _bleed_steps; _bs++) {
      var _bf = _bs / _bleed_steps;
      draw_set_color(merge_color(global.avoid_col_blood, global.avoid_col_warning, 0.4 + _ceil_hot * 0.4));
      draw_set_alpha(_ceil_a * (_ceil_hot * 0.1 + _fin * 0.12) * (1 - _bf));
      draw_primitive_begin(pr_trianglestrip);
      for (var _bc = 0; _bc < _ceil_n; _bc++) {
        draw_vertex(_sxp[_bc], _sy[_bc] + _bleed * _bf);
        draw_vertex(_sxp[_bc], _sy[_bc] + _bleed * (_bf + 1 / _bleed_steps));
      }
      draw_primitive_end();
    }
  }

  // ---- 4. cracks racing out along the seam ----
  for (var _ci2 = 0; _ci2 < array_length(orb_cracks); _ci2++) {
    var _ck2 = orb_cracks[_ci2];
    var _ck_a = clamp(_ck2.life / max(_ck2.life_max, 1), 0, 1);
    var _ck_end = _ck2.x + _ck2.dir * _ck2.reach;
    var _ck_steps = 16;

    var _cpx = _ck2.x;
    var _cpy = orbrain_seam_y(_cpx);

    for (var _cs = 1; _cs <= _ck_steps; _cs++) {
      var _cf = _cs / _ck_steps;
      var _cnx = lerp(_ck2.x, _ck_end, _cf);
      if (_cnx < -20 || _cnx > room_width + 20) break;

      var _cjit = sin(_ck2.seed + _cs * 2.7) * (5 + _ck2.w * 1.6) * (1 - _cf * 0.4);
      var _cny = orbrain_seam_y(_cnx) + abs(_cjit) * 0.8;

      var _cedge = power(_cf, 2.2);
      var _cw = _ck2.w * (0.5 + _cedge * 1.1);

      draw_set_color(global.avoid_col_warning);
      draw_set_alpha(_ck_a * (0.3 + _cedge * 0.5));
      draw_line_width(_cpx, _cpy, _cnx, _cny, _cw);

      draw_set_color(c_white);
      draw_set_alpha(_ck_a * (0.2 + _cedge * 0.75));
      draw_line_width(_cpx, _cpy, _cnx, _cny, _cw * 0.36);

      if (_cs mod 4 == 0) {
        var _cfl = (7 + _ck2.w * 3) * _cedge;
        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_ck_a * _cedge * 0.5);
        draw_line_width(_cnx, _cny, _cnx + _ck2.dir * _cfl * 0.5, _cny + _cfl, 1.4);
      }

      _cpx = _cnx;
      _cpy = _cny;
    }

    if (_ck2.reach > 4 && _ck_end > -20 && _ck_end < room_width + 20) {
      var _head_y = orbrain_seam_y(_ck_end);
      draw_set_color(c_white);
      draw_set_alpha(_ck_a * 0.8);
      draw_line_width(_ck_end, _head_y - 7 - _ck2.w, _ck_end, _head_y + 9 + _ck2.w, 2);
      scr_draw_smooth_ring_mask(_ck_end, _head_y, 5 + _ck2.w * 1.8, _ck_a * 0.5, 3,
                                global.avoid_col_warning);
    }
  }

  // ---- 4b. THE PRESSURE FRONT — the thing that hits the orbs ----
  for (var _fri = 0; _fri < array_length(orb_fronts); _fri++) {
    var _frd = orb_fronts[_fri];
    var _fr_a = clamp(_frd.life / max(_frd.life_max, 1), 0, 1);
    var _fr_hot = _frd.hot;
    var _fr_denom2 = 2 * _k_orbrain_front_sigma * _k_orbrain_front_sigma;
    var _fr_steps = 40;
    var _fr_band = _k_orbrain_front_band * (0.7 + _fr_hot * 0.6);

    var _fx = array_create(_fr_steps + 1, 0);
    var _fy = array_create(_fr_steps + 1, 0);
    var _any_on = false;
    for (var _fq = 0; _fq <= _fr_steps; _fq++) {
      var _fxx = (_fq / _fr_steps) * room_width;
      var _fdx = _fxx - _frd.epi;
      var _flead = (1 - _k_orbrain_front_lead)
                 + _k_orbrain_front_lead * exp(-(_fdx * _fdx) / _fr_denom2);
      _fx[_fq] = _fxx;
      _fy[_fq] = orbrain_seam_y(_fxx) + _frd.depth * _flead;
      if (_fy[_fq] < room_height + 60) _any_on = true;
    }
    if (!_any_on) continue;

    var _fr_layers = 4;
    for (var _fl2 = 0; _fl2 < _fr_layers; _fl2++) {
      var _flf = _fl2 / _fr_layers;
      draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.2 + _flf * 0.4));
      draw_set_alpha(_fr_a * (0.16 + _fr_hot * 0.16) * (1 - _flf) * 0.8);
      draw_primitive_begin(pr_trianglestrip);
      for (var _fq2 = 0; _fq2 <= _fr_steps; _fq2++) {
        draw_vertex(_fx[_fq2], _fy[_fq2] - _fr_band * (_flf + 1 / _fr_layers));
        draw_vertex(_fx[_fq2], _fy[_fq2] - _fr_band * _flf);
      }
      draw_primitive_end();
    }

    var _fr_fringe = (1.6 + _fr_hot * 3) * fx_get_mult("aberration");
    for (var _fe = 0; _fe < 3; _fe++) {
      var _fe_col = c_white;
      var _fe_off = 0;
      if (_fe == 0) { _fe_col = global.avoid_col_danger;  _fe_off =  _fr_fringe; }
      else if (_fe == 1) { _fe_col = global.avoid_col_cyan; _fe_off = -_fr_fringe; }

      var _fe_w = (_fe == 2) ? (1.6 + _fr_hot * 2.2) : (2.6 + _fr_hot * 2.4);
      var _fe_a = (_fe == 2) ? (0.72 + _fr_hot * 0.28) : (0.34 + _fr_hot * 0.3);

      draw_set_color(_fe_col);
      draw_set_alpha(_fr_a * _fe_a);
      for (var _fq3 = 0; _fq3 < _fr_steps; _fq3++) {
        draw_line_width(_fx[_fq3], _fy[_fq3] + _fe_off,
                        _fx[_fq3 + 1], _fy[_fq3 + 1] + _fe_off, _fe_w);
      }
    }

    var _fr_str = 22;
    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.5));
    draw_set_alpha(_fr_a * (0.2 + _fr_hot * 0.25));
    for (var _fs2 = 0; _fs2 < _fr_str; _fs2++) {
      var _fsf = (_fs2 + 0.5) / _fr_str;
      var _fsi = clamp(floor(_fsf * _fr_steps), 0, _fr_steps - 1);
      var _fsl = (10 + abs(sin(_frd.seed + _fs2 * 2.3)) * 26) * (0.5 + _fr_hot * 0.8);
      draw_line_width(_fx[_fsi], _fy[_fsi] - _fsl, _fx[_fsi], _fy[_fsi], 1.6);
    }

    var _fn_i = clamp(round((_frd.epi / max(room_width, 1)) * _fr_steps), 0, _fr_steps);
    scr_draw_smooth_ring_mask(_fx[_fn_i], _fy[_fn_i], 7 + _fr_hot * 11,
                              _fr_a * 0.5, 4, merge_color(global.avoid_col_cyan, c_white, 0.6));
  }

  // ---- 5. torn sockets left on the seam ----
  for (var _so2 = 0; _so2 < array_length(orb_sockets); _so2++) {
    var _sc = orb_sockets[_so2];
    var _sc_a = clamp(_sc.life / max(_sc.life_max, 1), 0, 1);
    var _sc_col = _sc.heavy ? global.avoid_col_warning : global.avoid_col_cyan;
    var _sc_y = orbrain_seam_y(_sc.x);

    draw_set_color(_sc_col);
    draw_set_alpha(_sc_a * _sc_a * 0.55);
    for (var _sn = 0; _sn < 4; _sn++) {
      var _sna = 250 + _sn * 27 + sin(_sc.seed + _sn) * 14;
      var _snl = (5 + _sn) * (0.6 + _sc_a * 0.7);
      draw_line_width(_sc.x, _sc_y,
                      _sc.x + lengthdir_x(_snl, _sna), _sc_y - lengthdir_y(_snl, _sna), 1.6);
    }

    draw_set_color(c_white);
    draw_set_alpha(_sc_a * _sc_a * 0.7);
    draw_circle(_sc.x, _sc_y, 1.4 + _sc_a * 2.2, false);
  }

  // ---- 5b. live source collars: where each armed orb is being generated ----
  gpu_set_blendmode(bm_normal);
  with (oFallingRedOrb) {
    if (!rain_orb || dissolving || tether_state >= 3) continue;

    var _sx0 = tether_ax;
    var _sy0 = tether_ay;
    var _armed0 = tether_state >= 1;
    var _charge0 = clamp(tether_charge + arm_flash * 0.55 + socket_heat * 0.65, 0, 1.25);
    var _slot_w0 = other._k_orbrain_socket_w + _charge0 * 6;
    var _slot_h0 = other._k_orbrain_socket_h + _charge0 * 4;
    var _slot_a0 = other.storm_intensity * (_armed0 ? (0.58 + _charge0 * 0.2) : 0.28);

    draw_set_color(global.avoid_col_armor_dark);
    draw_set_alpha(_slot_a0 * 0.95);
    draw_rectangle(_sx0 - _slot_w0 * 0.5, _sy0 - _slot_h0,
                   _sx0 + _slot_w0 * 0.5, _sy0 + _slot_h0 * 0.25, false);

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_slot_a0 * (0.48 + _charge0 * 0.18));
    draw_line_width(_sx0 - _slot_w0 * 0.5, _sy0 + 1,
                    _sx0 + _slot_w0 * 0.5, _sy0 + 1, 1.3 + _charge0);
    draw_line_width(_sx0 - _slot_w0 * 0.5, _sy0 + 1,
                    _sx0 - _slot_w0 * 0.32, _sy0 - _slot_h0, 1.1);
    draw_line_width(_sx0 + _slot_w0 * 0.5, _sy0 + 1,
                    _sx0 + _slot_w0 * 0.32, _sy0 - _slot_h0, 1.1);

    if (_armed0) {
      var _jaw0 = other._k_orbrain_socket_jaw + _charge0 * 5;
      draw_set_color(global.avoid_col_armor_mid);
      draw_set_alpha(_slot_a0 * 0.72);
      draw_line_width(_sx0 - _jaw0, _sy0 + 4,
                      _sx0 - _jaw0 * 0.36, _sy0 + 9 + _charge0 * 3, 2.2);
      draw_line_width(_sx0 + _jaw0, _sy0 + 4,
                      _sx0 + _jaw0 * 0.36, _sy0 + 9 + _charge0 * 3, 2.2);
    }
  }

  gpu_set_blendmode(bm_add);
  with (oFallingRedOrb) {
    if (!rain_orb || dissolving || tether_state >= 3) continue;

    var _sx1 = tether_ax;
    var _sy1 = tether_ay;
    var _charge1 = clamp(tether_charge + arm_flash * 0.55 + socket_heat * 0.65, 0, 1.25);
    var _socket_col1 = tether_heavy ? global.avoid_col_warning : global.avoid_col_danger;
    var _jaw1 = other._k_orbrain_socket_jaw + _charge1 * 5;

    if (_charge1 > 0.04) {
      draw_set_color(merge_color(_socket_col1, c_white, _charge1 * 0.42));
      draw_set_alpha(other.storm_intensity * (0.13 + _charge1 * 0.52));
      draw_line_width(_sx1 - _jaw1 * 0.58, _sy1 + 2.6,
                      _sx1 + _jaw1 * 0.58, _sy1 + 2.6, 1.2 + _charge1 * 2.1);
      draw_set_color(c_white);
      draw_set_alpha(other.storm_intensity * _charge1 * _charge1 * 0.48);
      draw_circle(_sx1, _sy1 + 2.8, 1.2 + _charge1 * 2.2, false);
    }

    if (tether_state == 2) {
      draw_set_color(global.avoid_col_warning);
      draw_set_alpha(other.storm_intensity * tether_charge * 0.42);
      draw_line_width(_sx1, _sy1 + 4,
                      _sx1 + lengthdir_x(other._k_orbrain_socket_tick + tether_charge * 10, 90),
                      _sy1 + 4 + lengthdir_y(other._k_orbrain_socket_tick + tether_charge * 10, 90),
                      1.8);
    }
  }

  // ---- 6. the tethers ----
  with (oFallingRedOrb) {
    if (!rain_orb || dissolving || tether_state >= 3) continue;

    var _tax = tether_ax;
    var _tay = tether_ay;
    var _tox = x;
    var _toy = y;
    var _tlen = point_distance(_tax, _tay, _tox, _toy);
    if (_tlen < 2) continue;

    var _armed = (tether_state >= 1);
    var _cut   = (tether_state == 2);
    var _tcol  = tether_heavy ? global.avoid_col_warning : global.avoid_col_cyan;

    var _tension = _armed ? 1 : 0;
    var _sag = (1 - _tension) * (7 + _tlen * 0.06);
    var _lean = other.storm_wind * (1 - _tension) * 1.4;

    var _tsteps = _armed ? 8 : 3;
    var _tw = _armed ? (1.7 + arm_flash * 1.2) : 1;
    var _ta = other.storm_intensity * (_armed ? (0.5 + arm_flash * 0.4) : 0.13);

    var _cut_f = _cut ? tether_charge : 0;

    var _tpx = _tax;
    var _tpy = _tay;

    for (var _ts = 1; _ts <= _tsteps; _ts++) {
      var _tf = _ts / _tsteps;
      var _tnx = lerp(_tax, _tox, _tf) + _lean * sin(_tf * pi) + sin(tether_seed + _tf * 5.2) * (1 - _tension) * 2.5;
      var _tny = lerp(_tay, _toy, _tf) + _sag * sin(_tf * pi);

      var _seg_mid = _tf - (0.5 / _tsteps);

      if (_seg_mid >= _cut_f) {
        var _seg_hot = _cut ? clamp(1 - (_seg_mid - _cut_f) * 3.5, 0, 1) : 0;

        draw_set_color(merge_color(_tcol, c_white, _seg_hot * 0.6));
        draw_set_alpha(_ta * (0.7 + _seg_hot * 0.3));
        draw_line_width(_tpx, _tpy, _tnx, _tny, _tw + _seg_hot * 2.6);

        if (_armed) {
          draw_set_color(c_white);
          draw_set_alpha(_ta * (0.3 + _seg_hot * 0.7));
          draw_line_width(_tpx, _tpy, _tnx, _tny, (_tw + _seg_hot * 2.2) * 0.35);
        }
      }

      _tpx = _tnx;
      _tpy = _tny;
    }

    if (_armed && !_cut) {
      for (var _pk2 = 0; _pk2 < 3; _pk2++) {
        var _pkf = frac(tether_seed * 0.17 + _pk2 * 0.333 + other.t * 0.045);
        var _pkx = lerp(_tax, _tox, _pkf) + _lean * sin(_pkf * pi);
        var _pky = lerp(_tay, _toy, _pkf) + _sag * sin(_pkf * pi);
        draw_set_color(merge_color(_tcol, c_white, 0.5));
        draw_set_alpha(_ta * 0.85 * (1 - _pkf * 0.4));
        draw_circle(_pkx, _pky, 1.6 + arm_flash, false);
      }
    }

    if (_cut) {
      var _cnx2 = lerp(_tax, _tox, _cut_f);
      var _cny2 = lerp(_tay, _toy, _cut_f) + _sag * sin(_cut_f * pi);
      draw_set_color(c_white);
      draw_set_alpha(0.9);
      draw_circle(_cnx2, _cny2, 2.4, false);
      scr_draw_smooth_ring_mask(_cnx2, _cny2, 5 + tether_charge * 7, 0.55, 3, _tcol);
    }

    if (_armed) {
      var _br = 13 + arm_flash * 5;
      var _bhot = _cut ? (0.55 + tether_charge * 0.45) : (0.25 + arm_flash * 0.4);
      var _ba2 = other.storm_intensity * (_cut ? 0.95 : (0.5 + arm_flash * 0.45));
      scr_draw_lock_bracket(_tox - _br, _toy - _br, _tox + _br, _toy + _br,
                            _tcol, _bhot, _ba2, tether_heavy ? 14 : 9, false, 4);
    }
  }

  // ---- 7. snapped tethers whipping back up ----
  for (var _wi2 = 0; _wi2 < array_length(orb_whips); _wi2++) {
    var _wp2 = orb_whips[_wi2];
    var _wa = clamp(_wp2.life / max(_wp2.life_max, 1), 0, 1);
    var _wcol = _wp2.heavy ? global.avoid_col_warning : global.avoid_col_cyan;
    var _wsteps = 6;

    var _wpx = _wp2.ax;
    var _wpy = _wp2.ay;

    for (var _ws = 1; _ws <= _wsteps; _ws++) {
      var _wf = _ws / _wsteps;
      var _wcurl = sin(_wp2.seed + _wf * 7 + (1 - _wa) * 9) * 22 * _wf * _wa;
      var _wnx = lerp(_wp2.ax, _wp2.x, _wf) + _wcurl;
      var _wny = lerp(_wp2.ay, _wp2.y, _wf) + _wcurl * 0.35;

      draw_set_color(_wcol);
      draw_set_alpha(_wa * _wa * 0.7);
      draw_line_width(_wpx, _wpy, _wnx, _wny, 2.2 * _wa);
      draw_set_color(c_white);
      draw_set_alpha(_wa * _wa * 0.45);
      draw_line_width(_wpx, _wpy, _wnx, _wny, 0.9 * _wa);

      _wpx = _wnx;
      _wpy = _wny;
    }
  }

  // ---- 8. concussion rings off the hit ----
  for (var _sh2 = 0; _sh2 < array_length(orb_shocks); _sh2++) {
    var _sk2 = orb_shocks[_sh2];
    var _sk_a = clamp(_sk2.life / max(_sk2.life_max, 1), 0, 1);
    var _sk_r = _sk2.radius;
    var _sk_seg = 30;
    var _sk_col = merge_color(global.avoid_col_warning, c_white, _sk2.hot * 0.5);

    draw_set_color(_sk_col);
    draw_set_alpha(_sk_a * _sk_a * (0.3 + _sk2.hot * 0.4));
    draw_primitive_begin(pr_linestrip);
    for (var _sg = 0; _sg <= _sk_seg; _sg++) {
      var _sga = (_sg / _sk_seg) * 180;
      draw_vertex(_sk2.x + lengthdir_x(_sk_r, _sga),
                  _sk2.y + lengthdir_y(_sk_r * 0.34, _sga) * -1);
    }
    draw_primitive_end();
  }

  // ---- 9. break debris, one rolled hue per mote ----
  for (var _mi2 = 0; _mi2 < array_length(orb_snap_motes); _mi2++) {
    var _mt2 = orb_snap_motes[_mi2];
    var _mt_a = clamp(_mt2.life / max(_mt2.max_life, 1), 0, 1);
    draw_set_color(_mt2.col);
    draw_set_alpha(_mt_a * 0.75);
    draw_circle(_mt2.x, _mt2.y, _mt2.size * _mt_a, false);
    draw_set_color(c_white);
    draw_set_alpha(_mt_a * _mt_a * 0.6);
    draw_circle(_mt2.x, _mt2.y, _mt2.size * _mt_a * 0.4, false);
  }

  // ---- 10. vents climbing off the struck seam ----
  scr_draw_vent_streams(orb_rain_vents);

  // ---- 11. finale: the ceiling gives way ----
  if (_fin > 0.01) {
    var _fin_fade = sin(_fin * pi);

    draw_set_color(c_white);
    draw_set_alpha(_fin_fade * 0.5);
    for (var _fl = 0; _fl < _ceil_n - 1; _fl++) {
      draw_line_width(_sxp[_fl], _sy[_fl], _sxp[_fl + 1], _sy[_fl + 1],
                      2 + _fin_fade * 5);
    }

    var _fbn = 9;
    for (var _fb = 0; _fb < _fbn; _fb++) {
      var _fbx = (_fb + 0.5) * (room_width / _fbn) + sin(_fb * 4.1 + orb_finale * 6) * 26;
      var _fby = orbrain_seam_y(_fbx);
      var _fbpx = _fbx;
      var _fbpy = _fby;
      var _fbsteps = 5;
      for (var _fbs = 1; _fbs <= _fbsteps; _fbs++) {
        var _fbf = _fbs / _fbsteps;
        var _fbnx = _fbx + sin(_fb * 3.3 + _fbs * 2.1) * 30 * _fbf;
        var _fbny = _fby + _fbf * (110 + _fin * 150);
        draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.5));
        draw_set_alpha(_fin_fade * 0.5 * (1 - _fbf * 0.5));
        draw_line_width(_fbpx, _fbpy, _fbnx, _fbny, 3 * (1 - _fbf * 0.6));
        draw_set_color(c_white);
        draw_set_alpha(_fin_fade * 0.6 * (1 - _fbf * 0.6));
        draw_line_width(_fbpx, _fbpy, _fbnx, _fbny, 1.1 * (1 - _fbf * 0.5));
        _fbpx = _fbnx;
        _fbpy = _fbny;
      }
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (tree_scar_alpha > 0.002 && array_length(tree_scar_segments) > 0) {
  var _scar_burn = 1 - tree_scar_alpha;
  var _scar_master = tree_scar_alpha * tree_scar_alpha;
  var _scar_ember = make_color_rgb(120, 16, 8);
  var _scar_time = current_time * 0.011;

  gpu_set_blendmode(bm_add);
  for (var _tsc = 0; _tsc < array_length(tree_scar_segments); _tsc++) {
    var _tsg = tree_scar_segments[_tsc];
    if (_tsg.dead) continue;

    var _heat = clamp((_tsg.burn_at - _scar_burn) / max(_tsg.burn_at, 0.001), 0, 1);

    var _flick = 1 - (1 - _heat) * 0.55 * (0.5 + 0.5 * sin(_scar_time * 1.7 + _tsg.seed));

    var _col;
    if (_heat > 0.75) {
      _col = merge_color(global.tree_fire_color, c_white, (_heat - 0.75) * 4);
    } else {
      _col = merge_color(_scar_ember, global.tree_fire_color, _heat / 0.75);
    }

    var _sag = (1 - _heat) * _tsg.thin01 * _k_scar_sag;
    var _ax = _tsg.ax, _ay = _tsg.ay + _sag;
    var _bx = _tsg.bx, _by = _tsg.by + _sag * 0.35;

    var _a = _scar_master * _flick;
    var _w = _tsg.w;

    draw_set_color(_col);
    draw_set_alpha(_a * 0.16);
    draw_line_width(_ax, _ay, _bx, _by, _w * 2.2);
    draw_set_alpha(_a * 0.42);
    draw_line_width(_ax, _ay, _bx, _by, _w);

    if (_heat > 0.25) {
      draw_set_color(merge_color(_col, c_white, 0.75));
      draw_set_alpha(_a * (_heat - 0.25) * 1.1);
      draw_line_width(_ax, _ay, _bx, _by, max(_w * 0.32, 0.8));
    }

    if (_heat < 0.18) {
      draw_set_color(c_white);
      draw_set_alpha(_scar_master * (1 - _heat / 0.18) * 0.8);
      draw_line_width(_ax, _ay, _bx, _by, max(_w * 0.5, 1));
    }
  }

  if (tree_scar_flash > 0.01) {
    draw_set_color(c_white);
    for (var _tsf = 0; _tsf < array_length(tree_scar_segments); _tsf++) {
      var _tgf = tree_scar_segments[_tsf];
      draw_set_alpha(tree_scar_flash * 0.85);
      draw_line_width(_tgf.ax, _tgf.ay, _tgf.bx, _tgf.by, _tgf.w * (1 + tree_scar_flash * 1.6));
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

scr_draw_tree_root_rakes_mass();

if (array_length(tree_root_fissures) > 0 || array_length(tree_pre_pulses) > 0 || array_length(tree_root_spines) > 0
|| tree_telegraph_heat > 0.01 || (t >= 1856 && t < 1900)) {
  gpu_set_blendmode(bm_add);

  var _root_floor_heat = max(tree_telegraph_heat, (t >= 1856 && t < 1900) ? clamp(1 - (t - 1856) / 44, 0, 1) : 0);
  if (_root_floor_heat > 0.01) {
    for (var _rbi = 0; _rbi < array_length(tree_root_base_xs); _rbi++) {
      var _rbx0 = tree_root_base_xs[_rbi];
      var _rb_pulse = 0.55 + 0.45 * sin(current_time * 0.018 + _rbi * 2.3);
      var _plate_w = lerp(80, 170, _root_floor_heat) * (0.92 + _rb_pulse * 0.12);
      var _plate_h = lerp(5, 17, _root_floor_heat);
      var _plate_col = merge_color(global.avoid_col_blood, global.tree_fire_color, _root_floor_heat);

      draw_set_color(_plate_col);
      draw_set_alpha((0.10 + _root_floor_heat * 0.22) * _rb_pulse);
      draw_rectangle(_rbx0 - _plate_w * 0.5, tree_root_base_y - _plate_h,
                     _rbx0 + _plate_w * 0.5, tree_root_base_y + _plate_h * 0.28, false);

      draw_set_color(c_white);
      draw_set_alpha(_root_floor_heat * _root_floor_heat * 0.38 * _rb_pulse);
      draw_line_width(_rbx0 - _plate_w * 0.38, tree_root_base_y - 1,
                      _rbx0 + _plate_w * 0.38, tree_root_base_y - 1, 2);

      for (var _rr = 0; _rr < 4; _rr++) {
        var _crack_side = (_rr < 2) ? -1 : 1;
        var _crack_ang = (_crack_side < 0) ? 200 + _rr * 12 : 328 + (_rr - 2) * 14;
        var _crack_len = _plate_w * lerp(0.22, 0.5, frac(abs(sin(_rbi * 41.3 + _rr * 9.1) * 913.2)));
        draw_set_color((_rr mod 2 == 0) ? global.avoid_col_cyan : _plate_col);
        draw_set_alpha(_root_floor_heat * 0.26 * (0.7 + _rb_pulse * 0.3));
        draw_line_width(_rbx0, tree_root_base_y,
                        _rbx0 + lengthdir_x(_crack_len, _crack_ang),
                        tree_root_base_y + lengthdir_y(_crack_len, _crack_ang) * 0.22,
                        1.4 + _root_floor_heat * 1.3);
      }
    }
  }

  for (var _tfi = 0; _tfi < array_length(tree_root_fissures); _tfi++) {
    var _tf2 = tree_root_fissures[_tfi];
    var _tf_a = clamp(_tf2.life / _tf2.life_max, 0, 1);
    var _tf_len = _tf2.len * _tf2.grow;

    var _tf_mx = _tf2.x + lengthdir_x(_tf_len * 0.55, _tf2.ang);
    var _tf_my = _tf2.y + lengthdir_y(_tf_len * 0.55, _tf2.ang) * 0.35;
    var _tf_ex = _tf2.x + lengthdir_x(_tf_len, _tf2.ang + 18);
    var _tf_ey = _tf2.y + lengthdir_y(_tf_len, _tf2.ang + 18) * 0.35;

    draw_set_color(global.tree_fire_color);
    draw_set_alpha(_tf_a * 0.55);
    draw_line_width(_tf2.x, _tf2.y, _tf_mx, _tf_my, 5);
    draw_line_width(_tf_mx, _tf_my, _tf_ex, _tf_ey, 3.5);
    draw_set_color(c_white);
    draw_set_alpha(_tf_a * 0.8);
    draw_line_width(_tf2.x, _tf2.y, _tf_mx, _tf_my, 1.8);
    draw_line_width(_tf_mx, _tf_my, _tf_ex, _tf_ey, 1.2);
  }

  for (var _trsi = 0; _trsi < array_length(tree_root_spines); _trsi++) {
    var _trs2 = tree_root_spines[_trsi];
    var _trs_p = 1 - clamp(_trs2.life / max(_trs2.life_max, 1), 0, 1);
    var _trs_grow = clamp(_trs_p * 2.7, 0, 1);
    var _trs_fade = 1 - _trs_p;
    var _trs_len = _trs2.len * _trs_grow;
    var _trs_w = _trs2.w * (0.45 + _trs_fade * 0.55);
    var _trs_ang0 = _trs2.ang + sin(_trs2.seed + current_time * 0.018) * 5;
    var _trs_ang1 = _trs2.ang + sin(_trs2.seed * 1.7 + current_time * 0.022) * 12;
    var _trs_mx = _trs2.x + lengthdir_x(_trs_len * 0.48, _trs_ang0);
    var _trs_my = _trs2.y + lengthdir_y(_trs_len * 0.48, _trs_ang0);
    var _trs_ex = _trs2.x + lengthdir_x(_trs_len, _trs_ang1);
    var _trs_ey = _trs2.y + lengthdir_y(_trs_len, _trs_ang1);
    var _trs_col = merge_color(global.avoid_col_blood, global.tree_fire_color, _trs2.hot);
    var _trs_a = _trs_fade * clamp(_trs_grow * 1.8, 0, 1);

    draw_set_color(_trs_col);
    draw_set_alpha(_trs_a * 0.42);
    draw_line_width(_trs2.x, _trs2.y, _trs_mx, _trs_my, _trs_w * 1.9);
    draw_line_width(_trs_mx, _trs_my, _trs_ex, _trs_ey, _trs_w * 1.2);
    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.35));
    draw_set_alpha(_trs_a * (0.18 + _trs2.hot * 0.16));
    draw_line_width(_trs2.x + 1, _trs2.y, _trs_mx + 1, _trs_my, max(0.8, _trs_w * 0.34));
    draw_set_color(c_white);
    draw_set_alpha(_trs_a * (0.42 + _trs2.hot * 0.35));
    draw_line_width(_trs_mx, _trs_my, _trs_ex, _trs_ey, max(0.8, _trs_w * 0.2));
  }

  for (var _tpi = 0; _tpi < array_length(tree_pre_pulses); _tpi++) {
    var _tp2 = tree_pre_pulses[_tpi];
    var _tp_prog = 1 - (_tp2.life / _tp2.life_max);
    var _tp_r = lerp(6, _tp2.radius, _tp_prog);
    var _tp_a = _tp2.alpha * (_tp2.life / _tp2.life_max);
    scr_draw_smooth_ring_mask(_tp2.x, _tp2.y, _tp_r, _tp_a, 8,
                              merge_color(global.tree_fire_color, c_white, 0.25));
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(rain_splashes) > 0) {
  gpu_set_blendmode(bm_normal);
  for (var rsc = 0; rsc < array_length(rain_splashes); rsc++) {
    var _sc = rain_splashes[rsc];
    var _scp = 1 - (_sc.life / _sc.life_max);
    var _scfade = _sc.life / _sc.life_max;
    var _scr_w = _sc.max_radius * lerp(0.34, 0.72, _scp);
    var _scr_h = (_sc.hailstone ? 10 : 5) * (0.55 + _scp * 0.45);
    var _scr_seed = _sc.x * 0.073 + _sc.max_radius * 1.17;

    draw_set_color(c_black);
    draw_set_alpha(_scfade * (_sc.hailstone ? 0.28 : 0.16));
    draw_ellipse(_sc.x - _scr_w * 0.5, _sc.y - _scr_h,
                 _sc.x + _scr_w * 0.5, _sc.y + _scr_h * 0.28, false);

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_scfade * (_sc.hailstone ? 0.20 : 0.12));
    draw_ellipse(_sc.x - _scr_w * 0.42, _sc.y - _scr_h * 0.7,
                 _sc.x + _scr_w * 0.42, _sc.y + _scr_h * 0.18, false);

    var _crack_n = _sc.hailstone ? 5 : 3;
    for (var _cr = 0; _cr < _crack_n; _cr++) {
      var _ca = 205 + (_cr / max(_crack_n - 1, 1)) * 130 + sin(_scr_seed + _cr * 2.4) * 11;
      var _clen = _scr_w * (0.18 + 0.16 * frac(abs(sin(_scr_seed + _cr * 4.1)) * 37.1));
      draw_set_color((_cr mod 2 == 0) ? global.avoid_col_blood : global.avoid_col_armor_edge);
      draw_set_alpha(_scfade * (_sc.hailstone ? 0.30 : 0.17));
      draw_line_width(_sc.x, _sc.y - 1,
                      _sc.x + lengthdir_x(_clen, _ca),
                      _sc.y - 1 + lengthdir_y(_clen, _ca) * 0.18,
                      _sc.hailstone ? 1.4 : 1);
    }
  }
  draw_set_alpha(1);
  draw_set_color(c_white);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _spl_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _spl_uvs[0], _spl_uvs[1], _spl_uvs[2], _spl_uvs[3]);
  for (var ri = 0; ri < array_length(rain_splashes); ri++) {
    var _spg = rain_splashes[ri];
    var _spg_p = 1 - (_spg.life / _spg.life_max);
    var _spg_fade = 1 - _spg_p;
    var _spg_hot = _spg.hailstone ? 1.9 : 0.8;

    shader_set_uniform_f(global.u_glow_color, 1, 0.25, 0.2);
    shader_set_uniform_f(global.u_glow_intensity, _spg_fade * _spg_hot);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    var _spg_w = (_spg.max_radius / 32) * (0.6 + _spg_p * 1.4);
    draw_sprite_ext(spr_glow_blob, 0, _spg.x, _spg.y, _spg_w, _spg_w * 0.4, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _spg_fade * _spg_fade * _spg_hot * 1.4);
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    draw_sprite_ext(spr_glow_blob, 0, _spg.x, _spg.y, _spg_w * 0.35, _spg_w * 0.16, 0, c_white, 1);
  }
  shader_reset();
  gpu_set_blendequation(bm_eq_add);

  for (var ri = 0; ri < array_length(rain_splashes); ri++) {
    var _sp = rain_splashes[ri];
    var _sprog = 1 - (_sp.life / _sp.life_max);
    var _sp_color = _sp.hailstone ? merge_color(c_red, c_white, 0.5) : c_red;

    scr_draw_smooth_ring_mask(_sp.x, _sp.y, _sprog * _sp.max_radius, (1 - _sprog) * 0.7, 12, _sp_color);

    var _drop_count = _sp.hailstone ? 8 : 4;
    for (var di = 0; di < _drop_count; di++) {
      var _dang = 200 + (di / _drop_count) * 140;
      var _ddist = _sprog * _sp.max_radius * 0.7;
      var _dx = _sp.x + lengthdir_x(_ddist, _dang);
      var _dy = _sp.y + lengthdir_y(_ddist, _dang) - (_sprog * (1 - _sprog)) * 20;
      draw_set_color(c_white);
      draw_set_alpha((1 - _sprog) * 0.7);
      draw_circle(_dx, _dy, 2, false);
    }
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(reentry_shards) > 0 || array_length(reentry_touchdowns) > 0 || array_length(reentry_embers) > 0) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _re_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _re_uvs[0], _re_uvs[1], _re_uvs[2], _re_uvs[3]);

  for (var si = 0; si < array_length(reentry_shards); si++) {
    var _s = reentry_shards[si];
    if (_s.delay > 0) continue;

    var _tn = array_length(_s.trail);
    var _bright = _s.is_bolide;
    shader_set_uniform_f(global.u_glow_falloff, _bright ? 1.5 : 1.9);
    for (var pti = 0; pti < _tn; pti++) {
      var _tp2 = _s.trail[pti];
      var _age = pti / max(_tn - 1, 1);
      shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 1, _age), lerp(0.15, 1, _age));
      shader_set_uniform_f(global.u_glow_intensity, _age * _age * (_bright ? 1.7 : 0.9));
      draw_sprite_ext(spr_glow_blob, 0, _tp2.x, _tp2.y, lerp(0.15, _bright ? 0.75 : 0.42, _age),
                      lerp(0.15, _bright ? 0.75 : 0.42, _age), 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _bright ? 2.0 : 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, _s.x, _s.y, _bright ? 0.45 : 0.24, _bright ? 0.45 : 0.24, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);

  for (var si = 0; si < array_length(reentry_shards); si++) {
    var _sf = reentry_shards[si];
    if (_sf.delay > 0) continue;
    var _sfn = array_length(_sf.trail);
    if (_sfn < 2) continue;

    var _sf_prev = _sf.trail[max(_sfn - 4, 0)];
    var _sf_dir = point_direction(_sf_prev.x, _sf_prev.y, _sf.x, _sf.y);
    var _sf_len = min(point_distance(_sf_prev.x, _sf_prev.y, _sf.x, _sf.y) * 2.4, _sf.is_bolide ? 70 : 42);
    var _sf_tx = _sf.x - lengthdir_x(_sf_len, _sf_dir);
    var _sf_ty = _sf.y - lengthdir_y(_sf_len, _sf_dir);
    var _sf_perp = _sf_dir + 90;
    var _sf_off = _sf.is_bolide ? 3.5 : 2;
    var _sf_w = _sf.is_bolide ? 6 : 3;

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_sf.is_bolide ? 0.45 : 0.3);
    draw_line_width(_sf_tx + lengthdir_x(_sf_off, _sf_perp), _sf_ty + lengthdir_y(_sf_off, _sf_perp),
                    _sf.x + lengthdir_x(_sf_off, _sf_perp), _sf.y + lengthdir_y(_sf_off, _sf_perp), _sf_w);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_sf_tx - lengthdir_x(_sf_off, _sf_perp), _sf_ty - lengthdir_y(_sf_off, _sf_perp),
                    _sf.x - lengthdir_x(_sf_off, _sf_perp), _sf.y - lengthdir_y(_sf_off, _sf_perp), _sf_w);
    draw_set_color(c_white);
    draw_set_alpha(_sf.is_bolide ? 0.8 : 0.55);
    draw_line_width(_sf_tx, _sf_ty, _sf.x, _sf.y, _sf_w * 0.35);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);

  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  shader_set_uniform_f(global.u_glow_uvrect, _re_uvs[0], _re_uvs[1], _re_uvs[2], _re_uvs[3]);

  for (var ei = 0; ei < array_length(reentry_embers); ei++) {
    var _em = reentry_embers[ei];
    shader_set_uniform_f(global.u_glow_color, 1, _em.bolide ? 0.7 : 0.35, _em.bolide ? 0.6 : 0.25);
    shader_set_uniform_f(global.u_glow_intensity, _em.alpha * (_em.bolide ? 1.3 : 0.8));
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    draw_sprite_ext(spr_glow_blob, 0, _em.x, _em.y, _em.bolide ? 0.16 : 0.1, _em.bolide ? 0.16 : 0.1, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);

  gpu_set_blendmode(bm_add);

  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  shader_set_uniform_f(global.u_glow_uvrect, _re_uvs[0], _re_uvs[1], _re_uvs[2], _re_uvs[3]);
  for (var ti = 0; ti < array_length(reentry_touchdowns); ti++) {
    var _tdg = reentry_touchdowns[ti];
    var _tdg_p = 1 - (_tdg.life / _tdg.life_max);
    var _tdg_fade = 1 - _tdg_p;
    var _tdg_w = (_tdg.bolide ? 1.6 : 0.75) * (0.5 + _tdg_p * 1.3);
    shader_set_uniform_f(global.u_glow_color, 1, 0.3, 0.22);
    shader_set_uniform_f(global.u_glow_intensity, _tdg_fade * (_tdg.bolide ? 2.1 : 1.1));
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _tdg.x, _tdg.y, _tdg_w, _tdg_w * 0.45, 0, c_white, 1);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _tdg_fade * _tdg_fade * (_tdg.bolide ? 2.4 : 1.3));
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    draw_sprite_ext(spr_glow_blob, 0, _tdg.x, _tdg.y, _tdg_w * 0.32, _tdg_w * 0.18, 0, c_white, 1);
  }
  shader_reset();
  gpu_set_blendequation(bm_eq_add);

  for (var ti = 0; ti < array_length(reentry_touchdowns); ti++) {
    var _td = reentry_touchdowns[ti];
    var _tp3 = 1 - (_td.life / _td.life_max);
    var _td_color = _td.bolide ? merge_color(c_red, c_white, 0.5) : c_red;
    scr_draw_smooth_ring_mask(_td.x, _td.y, _tp3 * (_td.bolide ? 46 : 20), (1 - _tp3) * 0.7, 10, _td_color);
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (kdash_rift > 0.01 || kdash_strike_flash > 0.01 || array_length(kdash_impacts) > 0 ||
    array_length(kdash_ghosts) > 0 || array_length(kdash_slashes) > 0 ||
    array_length(kdash_lanes) > 0 || array_length(kdash_shards) > 0 ||
    array_length(kdash_sockets) > 0 || array_length(kdash_scars) > 0) {

  var _kd_vis = clamp(max(max(kdash_rift, kdash_strike_flash * 0.65), kdash_escalation * 0.75 + kdash_heartbeat), 0, 1.6);
  var _kd_hot_x = lerp(kdash_rift_x_prev, kdash_rift_x, kdash_rift_slide);

  gpu_set_blendmode(bm_normal);

  if (_kd_vis > 0.01) {
    var _rail_a = clamp(0.12 + _kd_vis * 0.18, 0, 0.42);
    draw_set_color(c_black);
    draw_set_alpha(_rail_a * 0.62);
    draw_rectangle(0, 0, room_width, 18 + _kd_vis * 4, false);

    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_rail_a);
    draw_rectangle(0, 0, room_width, 11, false);

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.35));
    draw_set_alpha(0.35 + _kd_vis * 0.12);
    draw_line_width(0, 17, room_width, 17, 2);

    for (var _krib = 0; _krib < 15; _krib++) {
      var _rx = (_krib + 0.5) * (room_width / 15);
      var _ra = 0.12 + 0.08 * sin(_krib * 1.7 + t * 0.07);
      draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.4));
      draw_set_alpha(_ra * _kd_vis);
      draw_line_width(_rx - 12, 11, _rx + 12, 11, 1.4);
      draw_line_width(_rx, 4, _rx, 17, 1.1);
    }
  }

  for (var _ksc0 = 0; _ksc0 < array_length(kdash_scars); _ksc0++) {
    var _sc0 = kdash_scars[_ksc0];
    var _sca0 = clamp(_sc0.life / _sc0.life_max, 0, 1);
    var _span0 = _sc0.span * (0.55 + (1 - _sca0) * 0.35);
    draw_set_color(c_black);
    draw_set_alpha(_sca0 * 0.62);
    draw_ellipse(_sc0.x - _span0 * 0.55, _sc0.y - 4,
                 _sc0.x + _span0 * 0.55, _sc0.y + 3, false);
    draw_set_color(merge_color(global.avoid_col_blood, c_black, 0.4));
    draw_set_alpha(_sca0 * 0.58);
    draw_line_width(_sc0.x - _span0, _sc0.y + _sc0.nick,
                    _sc0.x + _span0, _sc0.y - _sc0.nick, 2.4);
  }

  for (var _kln0 = 0; _kln0 < array_length(kdash_lanes); _kln0++) {
    var _ln0 = kdash_lanes[_kln0];
    var _lp0 = 1 - (_ln0.life / max(_ln0.life_max, 1));
    var _reach0 = lerp(_ln0.y0 + 36, _ln0.y1, _lp0);
    var _lhw0 = _k_kdash_lane_half_w * (0.75 + _lp0 * 0.28);
    draw_set_color(merge_color(_k_er_col_armor_dark, c_black, 0.24));
    draw_set_alpha((0.10 + _lp0 * 0.22) * clamp(_ln0.life / max(_ln0.life_max, 1), 0, 1));
    for (var _lseg0 = 0; _lseg0 < _k_kdash_lane_segments; _lseg0++) {
      var _su0 = (_lseg0 + 0.08) / _k_kdash_lane_segments;
      var _su1 = min(1, (_lseg0 + 0.68) / _k_kdash_lane_segments);
      var _sy0 = lerp(_ln0.y0, _reach0, _su0);
      var _sy1 = lerp(_ln0.y0, _reach0, _su1);
      draw_line_width(_ln0.x - _lhw0, _sy0, _ln0.x - _lhw0 * 0.62, _sy1, 2.2);
      draw_line_width(_ln0.x + _lhw0, _sy0, _ln0.x + _lhw0 * 0.62, _sy1, 2.2);
    }
  }

  for (var _soc0 = 0; _soc0 < array_length(kdash_sockets); _soc0++) {
    var _soc = kdash_sockets[_soc0];
    var _soa = clamp(_soc.life / max(_soc.life_max, 1), 0, 1);
    var _sw = _k_kdash_socket_w * (0.82 + _soc.charge * 0.26);
    var _sh = _k_kdash_socket_h;
    var _sy = _k_kdash_socket_y - _soc.recoil * 4;

    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_soa * 0.72);
    draw_rectangle(_soc.x - _sw * 0.5, 0, _soc.x + _sw * 0.5, _sy + _sh, false);

    draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.28 + _soc.hot * 0.22));
    draw_set_alpha(_soa * (0.45 + _soc.hot * 0.16));
    draw_line_width(_soc.x - _sw * 0.5, _sy + _sh, _soc.x - _sw * 0.16, _sy + _sh, 2);
    draw_line_width(_soc.x + _sw * 0.16, _sy + _sh, _soc.x + _sw * 0.5, _sy + _sh, 2);
    draw_line_width(_soc.x - _sw * 0.35, _sy + 2, _soc.x - _sw * 0.35, _sy + _sh + 2, 1.4);
    draw_line_width(_soc.x + _sw * 0.35, _sy + 2, _soc.x + _sw * 0.35, _sy + _sh + 2, 1.4);
  }

  gpu_set_blendmode(bm_add);

  if (kdash_strike_flash > 0.01) {
    var _ksf = clamp(kdash_strike_flash, 0, 1.3) * fx_get_mult_for("dashingkunai", "tear");
    var _ksf_y = room_height * 0.42;
    var _ksf_h = 6 + (1 - min(_ksf, 1)) * 90;
    var _ksf_heat = clamp(_ksf, 0, 1);
    var _ksf_warn = merge_color(_k_er_col_warning, _k_er_col_white, 0.18 + _ksf_heat * 0.18);
    var _ksf_edge = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.55);
    var _ksf_core = merge_color(_k_er_col_warning, _k_er_col_white, 0.68);

    draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_warning, 0.52));
    draw_set_alpha(_ksf * 0.08);
    draw_rectangle(0, _ksf_y - _ksf_h, room_width, _ksf_y + _ksf_h, false);

    draw_set_color(_ksf_warn);
    draw_set_alpha(_ksf * 0.16);
    draw_rectangle(0, _ksf_y - _ksf_h * 0.42, room_width, _ksf_y + _ksf_h * 0.42, false);

    draw_set_color(_ksf_edge);
    draw_set_alpha(_ksf * 0.18);
    draw_rectangle(0, _ksf_y - 5.5, room_width, _ksf_y - 3.5, false);
    draw_rectangle(0, _ksf_y + 3.5, room_width, _ksf_y + 5.5, false);

    draw_set_color(_ksf_core);
    draw_set_alpha(_ksf * 0.32);
    draw_rectangle(0, _ksf_y - 1.2, room_width, _ksf_y + 1.2, false);

    for (var _ks_tick = 0; _ks_tick < 18; _ks_tick++) {
      var _ks_x = (_ks_tick + 0.5) * (room_width / 18);
      var _ks_j = sin(_ks_tick * 1.9 + t * 0.34) * 2.5;
      draw_set_color((_ks_tick mod 3 == 0) ? _k_er_col_warning : _ksf_edge);
      draw_set_alpha(_ksf * (0.10 + _ksf_heat * 0.09));
      draw_line_width(_ks_x - 8, _ksf_y + _ks_j, _ks_x + 8, _ksf_y - _ks_j, 1.2);
    }
  }

  if (kdash_rift > 0.01) {
    var _kr = clamp(kdash_rift, 0, 1.6);
    var _kr_warn = merge_color(_k_er_col_warning, _k_er_col_white, 0.24 + clamp(_kr, 0, 1) * 0.18);
    var _kr_edge = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.55);

    var _kr_px = 0;
    var _kr_py = 14;
    for (var _kj = 1; _kj <= 26; _kj++) {
      var _kjx = room_width * (_kj / 26);
      var _kjy = 14 + abs(sin(_kj * 1.7 + t * 0.12)) * (2 + _kr * 5);
      draw_set_color(_kr_edge);
      draw_set_alpha(_kr * 0.10);
      draw_line_width(_kr_px, _kr_py, _kjx, _kjy, 4);
      draw_set_color(_kr_warn);
      draw_set_alpha(_kr * 0.36);
      draw_line_width(_kr_px, _kr_py, _kjx, _kjy, 1.7);
      draw_set_color(_k_er_col_white);
      draw_set_alpha(_kr * 0.12);
      draw_line_width(_kr_px, _kr_py, _kjx, _kjy, 1);
      _kr_px = _kjx;
      _kr_py = _kjy;
    }

    for (var _kh = 0; _kh < 5; _kh++) {
      var _khw = _k_kdash_rift_width * (0.28 + _kh * 0.16);
      var _khy = 6 + _kh * 4;
      draw_set_color((_kh mod 2 == 0) ? _kr_warn : _kr_edge);
      draw_set_alpha(_kr * (0.22 - _kh * 0.028));
      draw_line_width(_kd_hot_x - _khw, _khy, _kd_hot_x - _khw * 0.42, _khy + 7, 1.6);
      draw_line_width(_kd_hot_x + _khw, _khy, _kd_hot_x + _khw * 0.42, _khy + 7, 1.6);
    }

    for (var _kp = 0; _kp < 6; _kp++) {
      var _kpu = frac(t * 0.035 + _kp * 0.17);
      var _kpx = _kd_hot_x + sin(_kp * 2.1 + t * 0.09) * _k_kdash_rift_width * 0.62;
      var _kpy0 = 3 + _kpu * 24;
      draw_set_color((_kp mod 3 == 0) ? _k_er_col_cyan : _kr_warn);
      draw_set_alpha(_kr * (0.18 + _kpu * 0.18));
      draw_line_width(_kpx - 5, _kpy0, _kpx + 5, _kpy0 + 5, 1.2);
    }
  }

  for (var _soc1 = 0; _soc1 < array_length(kdash_sockets); _soc1++) {
    var _soca = kdash_sockets[_soc1];
    var _soa1 = clamp(_soca.life / max(_soca.life_max, 1), 0, 1);
    var _sw1 = _k_kdash_socket_w * (0.82 + _soca.charge * 0.26);
    var _sy1 = _k_kdash_socket_y - _soca.recoil * 4;
    var _spulse1 = 0.65 + 0.35 * sin(_soca.seed + t * 0.48);

    draw_set_color(merge_color(_k_er_col_warning, _k_er_col_hot, _soca.hot * 0.45));
    draw_set_alpha(_soa1 * _spulse1 * (0.20 + _soca.charge * 0.32));
    draw_line_width(_soca.x - _sw1 * 0.34, _sy1 + _k_kdash_socket_h + 2,
                    _soca.x + _sw1 * 0.34, _sy1 + _k_kdash_socket_h + 2, 1.5);
    draw_line_width(_soca.x, _sy1 + 4,
                    _soca.x, _sy1 + _k_kdash_socket_h + 8 + _soca.charge * 10, 1.1);

    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(_soa1 * _spulse1 * _soca.charge * 0.16);
    draw_line_width(_soca.x - _sw1 * 0.48, _sy1 + 3,
                    _soca.x - _sw1 * 0.18, _sy1 + 8, 1);
    draw_line_width(_soca.x + _sw1 * 0.18, _sy1 + 8,
                    _soca.x + _sw1 * 0.48, _sy1 + 3, 1);
  }

  for (var _kl = 0; _kl < array_length(kdash_lanes); _kl++) {
    var _lane = kdash_lanes[_kl];
    var _lp = 1 - (_lane.life / max(_lane.life_max, 1));
    var _lane_hot = variable_struct_exists(_lane, "hot") ? _lane.hot : 0.55;
    var _lane_seed = variable_struct_exists(_lane, "seed") ? _lane.seed : 0;
    var _life_a = clamp(_lane.life / max(_lane.life_max, 1), 0, 1);
    var _la = (0.14 + _lp * _lp * 0.48) * _life_a;
    var _lcol = merge_color(_k_er_col_warning, _k_er_col_hot, _lp * 0.45 + _lane_hot * 0.2);

    var _lreach = lerp(_lane.y0 + 40, _lane.y1, _lp);
    var _lhw = _k_kdash_lane_half_w * (0.82 + _lane_hot * 0.28);

    for (var _lseg = 0; _lseg < _k_kdash_lane_segments; _lseg++) {
      var _su0 = (_lseg + 0.10) / _k_kdash_lane_segments;
      var _su1 = min(1, (_lseg + 0.72) / _k_kdash_lane_segments);
      var _sy0 = lerp(_lane.y0, _lreach, _su0);
      var _sy1 = lerp(_lane.y0, _lreach, _su1);
      var _seg_pulse = 0.72 + 0.28 * sin(_lane_seed + _lseg * 1.4 + t * 0.38);
      var _seg_a = _la * _seg_pulse * (0.65 + _su1 * 0.35);

      draw_set_color(merge_color(_k_er_col_armor_edge, _lcol, 0.5));
      draw_set_alpha(_seg_a * 0.42);
      draw_line_width(_lane.x - _lhw, _sy0, _lane.x - _lhw * 0.62, _sy1, 1.9);
      draw_line_width(_lane.x + _lhw, _sy0, _lane.x + _lhw * 0.62, _sy1, 1.9);

      draw_set_color(_lcol);
      draw_set_alpha(_seg_a * 0.35);
      draw_line_width(_lane.x, _sy0 + 2, _lane.x, _sy1 - 2, 2.2 + _lane_hot * 1.2);

      draw_set_color(_k_er_col_white);
      draw_set_alpha(_seg_a * _lp * 0.6);
      draw_line_width(_lane.x, lerp(_sy0, _sy1, 0.25),
                      _lane.x, lerp(_sy0, _sy1, 0.62), 1);
    }

    for (var _lpk = 0; _lpk < 3; _lpk++) {
      var _pu = frac(t * (0.052 + _lp * 0.03) + _lane_seed * 0.001 + _lpk * 0.34);
      var _py = lerp(_lane.y0 + 8, _lreach, _pu);
      var _pw = _lhw * lerp(1.2, 0.42, _pu);
      draw_set_color((_lpk == 1) ? _k_er_col_cyan : _k_er_col_warning);
      draw_set_alpha(_la * (0.22 + _pu * 0.38));
      draw_line_width(_lane.x - _pw, _py, _lane.x + _pw, _py + 3, 1.2);
    }

    var _lr = lerp(24, 8, _lp);
    scr_draw_lock_bracket(_lane.x - _lr, _lane.y1 - 10, _lane.x + _lr, _lane.y1 + 8,
                          _k_er_col_warning, _lp, _la * 0.9, 8, false, 2);
  }

  for (var _kg2 = 0; _kg2 < array_length(kdash_ghosts); _kg2++) {
    var _gh = kdash_ghosts[_kg2];
    var _gux = lengthdir_x(1, _gh.ang);
    var _guy = lengthdir_y(1, _gh.ang);
    var _gvx = lengthdir_x(1, _gh.ang + 90);
    var _gvy = lengthdir_y(1, _gh.ang + 90);
    var _glen = max(12, 18 * abs(_gh.sy));
    var _gw = max(2, 5 * abs(_gh.sx));
    var _ga = _gh.alpha;

    draw_set_color(_k_er_col_warning);
    draw_set_alpha(_ga * 0.28);
    draw_line_width(_gh.x - _gux * _glen - _gvx * _gw, _gh.y - _guy * _glen - _gvy * _gw,
                    _gh.x + _gux * _glen * 0.25 - _gvx * (_gw * 0.25),
                    _gh.y + _guy * _glen * 0.25 - _gvy * (_gw * 0.25), max(1, _gw * 0.55));
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(_ga * 0.16);
    draw_line_width(_gh.x - _gux * _glen + _gvx * _gw, _gh.y - _guy * _glen + _gvy * _gw,
                    _gh.x + _gux * _glen * 0.25 + _gvx * (_gw * 0.25),
                    _gh.y + _guy * _glen * 0.25 + _gvy * (_gw * 0.25), max(1, _gw * 0.38));
    draw_set_color(merge_color(_k_er_col_hot, _k_er_col_white, _gh.hot * 0.55));
    draw_set_alpha(_ga * 0.52);
    draw_line_width(_gh.x - _gux * _glen, _gh.y - _guy * _glen,
                    _gh.x + _gux * _glen * 0.3, _gh.y + _guy * _glen * 0.3, 1.1);
  }

  var _kdash_spread_mult = fx_get_mult_for("dashingkunai", "aberration");
  for (var _ks = 0; _ks < array_length(kdash_slashes); _ks++) {
    var _sl = kdash_slashes[_ks];
    var _sa2 = _sl.life / _sl.life_max;
    var _sl_spread = _sl.spread * _kdash_spread_mult;
    var _sseed = variable_struct_exists(_sl, "seed") ? _sl.seed : 0;
    var _slen = point_distance(_sl.x1, _sl.y1, _sl.x2, _sl.y2);
    var _sdir = point_direction(_sl.x1, _sl.y1, _sl.x2, _sl.y2);
    var _spx = lengthdir_x(1, _sdir + 90);
    var _spy = lengthdir_y(1, _sdir + 90);

    draw_set_color(_k_er_col_warning);
    draw_set_alpha(_sa2 * 0.34);
    draw_line_width(_sl.x1 - _spx * _sl_spread, _sl.y1 - _spy * _sl_spread,
                    _sl.x2 - _spx * (_sl_spread * 0.35), _sl.y2 - _spy * (_sl_spread * 0.35),
                    2.2 + _sl.hot * 1.4);
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(_sa2 * 0.24);
    draw_line_width(_sl.x1 + _spx * _sl_spread, _sl.y1 + _spy * _sl_spread,
                    _sl.x2 + _spx * (_sl_spread * 0.35), _sl.y2 + _spy * (_sl_spread * 0.35),
                    1.6 + _sl.hot);

    draw_set_color(_k_er_col_white);
    draw_set_alpha(_sa2 * _sa2 * 0.82);
    draw_line_width(_sl.x1, _sl.y1, _sl.x2, _sl.y2, 1 + _sl.hot * 1.2);

    for (var _st = 0; _st < 4; _st++) {
      var _tu = (_st + 0.25 + frac(_sseed * 0.013)) / 4.5;
      var _tx = lerp(_sl.x1, _sl.x2, _tu);
      var _ty = lerp(_sl.y1, _sl.y2, _tu);
      var _tw = lerp(12, 4, _tu) * _sa2;
      draw_set_color((_st mod 2 == 0) ? _k_er_col_warning : _k_er_col_cyan);
      draw_set_alpha(_sa2 * (0.18 + _sl.hot * 0.12));
      draw_line_width(_tx - _spx * _tw, _ty - _spy * _tw,
                      _tx + _spx * _tw, _ty + _spy * _tw, 1.1);
    }
  }

  for (var _ki2 = 0; _ki2 < array_length(kdash_impacts); _ki2++) {
    var _im3 = kdash_impacts[_ki2];
    var _ia3 = _im3.life / _im3.max_life;
    var _icol2 = merge_color(_k_er_col_warning, _k_er_col_white, _im3.hot);

    draw_set_color(_icol2);
    draw_set_alpha(_ia3 * _ia3 * 0.8);
    draw_ellipse_color(_im3.x - _im3.radius, _im3.y - _im3.radius * 0.35,
                       _im3.x + _im3.radius, _im3.y + _im3.radius * 0.35, _icol2, _icol2, true);

    draw_set_alpha(_ia3 * 0.3);
    draw_line_width(_im3.x - _im3.radius * 1.5, _im3.y, _im3.x + _im3.radius * 1.5, _im3.y, 3);
  }

  for (var _ksc1 = 0; _ksc1 < array_length(kdash_scars); _ksc1++) {
    var _sc1 = kdash_scars[_ksc1];
    var _sca1 = clamp(_sc1.life / max(_sc1.life_max, 1), 0, 1);
    var _span1 = _sc1.span * (0.52 + (1 - _sca1) * 0.38);
    var _scol1 = merge_color(_k_er_col_warning, _k_er_col_hot, _sc1.heat * 0.42);

    draw_set_color(_scol1);
    draw_set_alpha(_sca1 * _sca1 * (0.22 + _sc1.heat * 0.36));
    draw_line_width(_sc1.x - _span1, _sc1.y + _sc1.nick,
                    _sc1.x + _span1, _sc1.y - _sc1.nick, 1.4 + _sc1.heat);

    draw_set_color(_k_er_col_white);
    draw_set_alpha(_sca1 * _sc1.heat * 0.22);
    draw_line_width(_sc1.x - _span1 * 0.26, _sc1.y,
                    _sc1.x + _span1 * 0.26, _sc1.y, 1);
  }

  for (var _ksh = 0; _ksh < array_length(kdash_shards); _ksh++) {
    var _sh3 = kdash_shards[_ksh];
    var _sa3 = clamp(_sh3.life / _sh3.max_life, 0, 1);
    var _sang2 = _sh3.ang + sin(_sh3.phase + _sh3.life * 0.55) * _sh3.wobble;
    var _svx = lengthdir_x(1, _sang2 + 90);
    var _svy = lengthdir_y(1, _sang2 + 90);
    var _sux = lengthdir_x(1, _sang2);
    var _suy = lengthdir_y(1, _sang2);
    var _slen3 = 8 + _sh3.scale * 12;
    var _sw3 = 1.6 + _sh3.scale * 2.2;

    draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_warning, 0.34));
    draw_set_alpha(_sa3 * 0.55);
    draw_line_width(_sh3.x - _sux * _slen3 * 0.45, _sh3.y - _suy * _slen3 * 0.45,
                    _sh3.x + _sux * _slen3 * 0.55, _sh3.y + _suy * _slen3 * 0.55, _sw3);
    draw_set_color(_k_er_col_white);
    draw_set_alpha(_sa3 * _sa3 * 0.34);
    draw_line_width(_sh3.x - _svx * _sw3, _sh3.y - _svy * _sw3,
                    _sh3.x + _svx * _sw3, _sh3.y + _svy * _sw3, 1);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

var _jr_in_front = (jump_rope_depth > 0);

if (array_length(jr_ghosts) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _gi = 0; _gi < array_length(jr_ghosts); _gi++) {
    var _jg2 = jr_ghosts[_gi];
    var _gpts = _jg2.pts;
    var _gpn = array_length(_gpts);
    if (_gpn < 2) continue;

    draw_set_color(merge_color(jump_rope_color_far, c_white, _jg2.hot));
    draw_set_alpha(_jg2.alpha);
    for (var _gs = 0; _gs < _gpn - 1; _gs++) {
      draw_line_width(_gpts[_gs].x, _gpts[_gs].y, _gpts[_gs + 1].x, _gpts[_gs + 1].y, _jg2.width);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (jump_rope_telegraph_prog > 0.01) {
  var _jrt = jump_rope_telegraph_prog;
  var _jr_pulse = 0.55 + 0.45 * sin(t * (0.9 + _jrt * 1.6));
  var _jr_l = lerp(_k_jr_anchor_left_x, jump_rope_mid_x, _jrt * 0.14);
  var _jr_r = lerp(_k_jr_anchor_right_x, jump_rope_mid_x, _jrt * 0.14);
  var _jr_slot = 3 + _jrt * 22;
  var _jr_segs = 16;

  draw_primitive_begin(pr_trianglestrip);
  for (var _js = 0; _js <= _jr_segs; _js++) {
    var _jf = _js / _jr_segs;
    var _jx = lerp(_jr_l, _jr_r, _jf);
    var _jcrumble = sin(_js * 1.7 + t * 0.18) * _jrt * 3;
    draw_vertex_colour(_jx, _k_jr_floor_y - 1 + _jcrumble, c_black, 0.92);
    draw_vertex_colour(_jx, _k_jr_floor_y + _jr_slot, c_black, 0.38);
  }
  draw_primitive_end();

  gpu_set_blendmode(bm_add);
  draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _jrt));
  draw_set_alpha((0.18 + _jrt * 0.44) * _jr_pulse);
  draw_line_width(_jr_l + 3, _k_jr_floor_y + _jr_slot - 3,
                  _jr_r - 3, _k_jr_floor_y + _jr_slot - 3, 2.4);
  draw_set_color(c_white);
  draw_set_alpha((0.18 + _jrt * 0.42) * _jr_pulse);
  draw_line_width(_jr_l + 4, _k_jr_floor_y + _jr_slot - 1,
                  _jr_r - 4, _k_jr_floor_y + _jr_slot - 1, 1.3);

  draw_set_color(_k_er_col_warning);
  draw_set_alpha(_jrt * (0.22 + _jrt * 0.42) * _jr_pulse);
  draw_line_width(_jr_l + 8, _k_jr_floor_y + 1, _jr_r - 8, _k_jr_floor_y + 1, 3 + _jrt * 3);
  draw_set_color(c_white);
  draw_set_alpha(_jrt * _jrt * 0.34 * _jr_pulse);
  draw_line_width(_jr_l + 14, _k_jr_floor_y - 1, _jr_r - 14, _k_jr_floor_y - 1, 1.2);

  draw_set_color(_k_er_col_warning);
  draw_set_alpha(_jrt * 0.38);
  for (var _cut = 0; _cut <= 10; _cut++) {
    var _cu = _cut / 10;
    var _cx = lerp(_jr_l + 24, _jr_r - 24, _cu);
    var _wig = sin(t * 0.17 + _cut * 2.4) * _jrt * 3;
    draw_line_width(_cx - 5, _k_jr_floor_y + 5, _cx + 4 + _wig,
                    _k_jr_floor_y - 9 - _jrt * 8, 1.1);
  }

  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_jrt * 0.55);
  for (var _stub = 0; _stub <= 12; _stub++) {
    var _sx = lerp(_jr_l + 10, _jr_r - 10, _stub / 12);
    var _tick = frac(sin(_sx * 12.9898 + t * 0.31) * 43758.5453);
    draw_line_width(_sx, _k_jr_floor_y - 2, _sx + (_tick - 0.5) * 8,
                    _k_jr_floor_y - 7 - _tick * 9, 1.2);
  }

  draw_set_color(_k_er_col_warning);
  draw_set_alpha(_jrt * 0.46);
  draw_line_width(_jr_l, _k_jr_floor_y - 46, _jr_l + 22, _k_jr_floor_y - 46, 2);
  draw_line_width(_jr_l, _k_jr_floor_y - 46, _jr_l, _k_jr_floor_y + 8, 2);
  draw_line_width(_jr_r, _k_jr_floor_y - 46, _jr_r - 22, _k_jr_floor_y - 46, 2);
  draw_line_width(_jr_r, _k_jr_floor_y - 46, _jr_r, _k_jr_floor_y + 8, 2);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

scr_draw_jump_rope_line(true);

if (!_jr_in_front) scr_draw_jump_rope_line(false);

if (jump_rope_alpha > 0) {
  var _fig_bounce = jump_rope_figure_bounce;

  var _fig_lit = clamp(max(jr_anchor_heat[0], jr_anchor_heat[1]) * 0.6 + jr_coil * 0.4 +
                       jr_crack_flash * 0.8 + jr_heartbeat * 0.3, 0, 1);

  var _figure_color = merge_color(_k_er_col_armor_mid,
                                  merge_color(_k_er_col_warning, _k_er_col_white, _fig_lit * 0.45),
                                  (jump_rope_depth + 1) / 2 * 0.12 + _fig_lit * 0.55);

  var _figure_base_x_left = _k_jr_anchor_left_x - _k_jr_figure_stand_offset;
  var _figure_base_x_right = _k_jr_anchor_right_x + _k_jr_figure_stand_offset;

  var _crank_l = jr_handle_spin;
  var _crank_r = -jr_handle_spin;

  if (jr_crack_flash > 0.05 || jr_detonate_flash > 0.05) {
    var _fg = max(jr_crack_flash, jr_detonate_flash);
    var _fg_a = jump_rope_alpha * _fg * 0.4;
    scr_draw_jump_rope_figure(_figure_base_x_left, jump_rope_anchor_left_x,
                              jump_rope_anchor_left_y, 1, _k_jr_floor_y,
                              _fig_bounce * 1.4, jump_rope_phase, sRedOrb,
                              c_white, _k_jr_figure_scale * (1 + _fg * 0.06), _fg_a,
                              jr_coil, 1, _crank_l, true);
    scr_draw_jump_rope_figure(_figure_base_x_right, jump_rope_anchor_right_x,
                              jump_rope_anchor_right_y, -1, _k_jr_floor_y,
                              _fig_bounce * 1.4, jump_rope_phase, sRedOrb,
                              c_white, _k_jr_figure_scale * (1 + _fg * 0.06), _fg_a,
                              jr_coil, 1, _crank_r, true);
  }

  scr_draw_jump_rope_figure(_figure_base_x_left, jump_rope_anchor_left_x,
                            jump_rope_anchor_left_y, 1, _k_jr_floor_y,
                            _fig_bounce, jump_rope_phase, sRedOrb,
                            _figure_color, _k_jr_figure_scale, jump_rope_alpha,
                            jr_coil, _fig_lit, _crank_l);
  scr_draw_jump_rope_figure(_figure_base_x_right, jump_rope_anchor_right_x,
                            jump_rope_anchor_right_y, -1, _k_jr_floor_y,
                            _fig_bounce, jump_rope_phase, sRedOrb,
                            _figure_color, _k_jr_figure_scale, jump_rope_alpha,
                            jr_coil, _fig_lit, _crank_r);

  draw_set_alpha(1);
}

if (_jr_in_front) scr_draw_jump_rope_line(false);

if (array_length(jr_scorches) > 0) {
  for (var _sc = 0; _sc < array_length(jr_scorches); _sc++) {
    var _sco = jr_scorches[_sc];
    var _scl = _sco.life / _sco.life_max;
    var _sc_col = merge_color(_k_er_col_armor_dark, _k_er_col_armor_edge, _sco.hot);

    draw_set_color(_sc_col);
    draw_set_alpha(_scl * (0.35 + _sco.hot * 0.5));
    draw_line_width(_sco.x - _sco.w, _k_jr_floor_y, _sco.x + _sco.w, _k_jr_floor_y, 2 + _sco.hot * 3);

    if (_sco.hot > 0.08) {
      gpu_set_blendmode(bm_add);
      draw_set_color(merge_color(_k_er_col_cyan, c_white, _sco.hot * 0.5));
      draw_set_alpha(_scl * _sco.hot * 0.8);
      for (var _sct = 0; _sct < 7; _sct++) {
        var _sctu = (_sct / 6) * 2 - 1;
        var _sctx = _sco.x + _sctu * _sco.w;
        var _scth = (1 - abs(_sctu)) * 12 * _sco.hot;
        draw_line_width(_sctx, _k_jr_floor_y, _sctx + _sctu * 8, _k_jr_floor_y - _scth, 1.5);
      }
      gpu_set_blendmode(bm_normal);
    }
  }
  draw_set_alpha(1);
}

if (array_length(push_waves) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _wi = 0; _wi < array_length(push_waves); _wi++) {
    var _pw2 = push_waves[_wi];
    var _wa2 = _pw2.life / _pw2.max_life;
    var _wbase2 = variable_struct_exists(_pw2, "color") ? _pw2.color : _k_er_col_cyan;
    var _wcol2 = merge_color(_wbase2, c_white, _pw2.hot * 0.6);

    var _wdir = sign(_pw2.speed);
    var _wbands = 8;
    draw_set_color(_wcol2);
    for (var _wb = 0; _wb < _wbands; _wb++) {
      var _wbt = _wb / _wbands;
      draw_set_alpha(_wa2 * _wa2 * 0.13 * (1 - _wbt));
      var _wy0 = _pw2.y - _wdir * _wbt * _pw2.thickness * 3;
      var _wy1 = _pw2.y - _wdir * (_wbt + 1 / _wbands) * _pw2.thickness * 3;
      draw_rectangle(0, min(_wy0, _wy1), room_width, max(_wy0, _wy1), false);
    }

    draw_set_color(c_white);
    draw_set_alpha(_wa2 * (0.35 + _pw2.hot * 0.4));
    var _wpx = 0, _wpy = _pw2.y;
    for (var _wj = 1; _wj <= 20; _wj++) {
      var _wjx = room_width * (_wj / 20);
      var _wjy = _pw2.y + sin(_wj * 2.1 + t * 0.4) * (1 + _pw2.hot * 3);
      draw_line_width(_wpx, _wpy, _wjx, _wjy, 2);
      _wpx = _wjx;
      _wpy = _wjy;
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (push_orb_arrival_flash > 0.01) {
  gpu_set_blendmode(bm_add);
  var _pa = push_orb_arrival_flash;
  for (var _pb = 0; _pb < 7; _pb++) {
    var _pbt = _pb / 7;
    draw_set_color((_pb mod 2 == 0) ? _k_er_col_cyan : _k_er_col_warning);
    draw_set_alpha(_pa * 0.14 * (1 - _pbt) * (1 - _pbt));
    draw_rectangle(0, _pbt * 60, room_width, (_pb + 1) / 7 * 60, false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (push_orb_gap_flash > 0.01) {
  gpu_set_blendmode(bm_add);
  var _gf = push_orb_gap_flash;
  var _ghw = _k_push_orb_safe_gap * 0.75;

  draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.5));
  for (var _gb = 0; _gb < 6; _gb++) {
    var _gbt = _gb / 6;
    draw_set_alpha(_gf * 0.05 * (1 - _gbt));
    draw_rectangle(push_orb_gap_x - _ghw, _gbt * _k_jr_floor_y,
                   push_orb_gap_x + _ghw, (_gb + 1) / 6 * _k_jr_floor_y, false);
  }

  draw_set_color(c_white);
  draw_set_alpha(_gf * 0.28);
  draw_line_width(push_orb_gap_x - _ghw, 0, push_orb_gap_x - _ghw, _k_jr_floor_y, 1.5);
  draw_line_width(push_orb_gap_x + _ghw, 0, push_orb_gap_x + _ghw, _k_jr_floor_y, 1.5);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

var _jr_wing_draw = (t >= jump_rope_spawn_t && t < transition_reveal_t && !cube_wings_collected) ||
                    jr_wing_collect_flash > 0.01;
if (_jr_wing_draw) {
  var _wwx = cube_wings_collected ? jr_wing_collect_x : jr_wing_x;
  var _wwy = cube_wings_collected ? jr_wing_collect_y : jr_wing_y;
  var _wready = jr_wing_ready || cube_wings_collected;
  var _wstage_p = clamp(jr_wing_drop_stage / max(_k_jr_wing_collect_stage, 1), 0, 1);
  var _wslam = jr_wing_slam;
  var _wflash = max(jr_wing_flash, jr_wing_collect_flash);
  var _wopen = clamp(_wstage_p * 0.85 + _wflash * 0.25 + (_wready ? 0.25 : 0), 0, 1);
  var _wbob = sin(t * 0.09) * (1.5 + _wstage_p * 1.5) + _wslam * 8;
  var _wy = _wwy + _wbob;
  var _wtarget_y = _k_jr_wing_pickup_y;
  var _rail_top = -12;
  var _rail_a = cube_wings_collected ? jr_wing_collect_flash : 1;

  gpu_set_blendmode(bm_add);
  var _spot_pulse = 0.55 + 0.45 * sin(t * 0.19);
  var _spot_heat = clamp(0.30 + _wstage_p * 0.62 + _wflash * 0.38 + (_wready ? 0.28 : 0), 0, 1.35);
  var _beam_col = merge_color(_k_er_col_cyan, c_white, clamp(0.42 + _spot_pulse * 0.25 + (_wready ? 0.22 : 0), 0, 1));
  for (var _lamp_side = -1; _lamp_side <= 1; _lamp_side += 2) {
    var _lamp_x = _wwx + _lamp_side * (118 - _wstage_p * 22 + sin(t * 0.031 + _lamp_side * 2.7) * 9);
    var _lamp_y = 28 + cos(t * 0.026 + _lamp_side) * 4;
    var _focus_x = _wwx + _lamp_side * sin(t * 0.047 + _lamp_side) * (7 + _wstage_p * 4);
    var _focus_y = lerp(_wy, _wtarget_y, _wready ? 0.86 : 0.34);
    var _cone_w = 36 + _spot_heat * 24 + _spot_pulse * 7;
    var _beam_a = (0.035 + _spot_heat * 0.075 + _wflash * 0.045) * _rail_a;

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_lamp_x, _lamp_y, c_white, _beam_a);
    draw_vertex_colour(_focus_x - _cone_w, _focus_y + 48, _beam_col, 0);
    draw_vertex_colour(_focus_x, _focus_y, c_white, _beam_a * 0.48);
    draw_vertex_colour(_focus_x + _cone_w, _focus_y + 48, _beam_col, 0);
    draw_vertex_colour(_focus_x - _cone_w, _focus_y + 48, _beam_col, 0);
    draw_primitive_end();

    draw_set_color(c_white);
    draw_set_alpha((0.15 + _spot_heat * 0.16 + _wflash * 0.12) * _rail_a);
    draw_circle(_lamp_x, _lamp_y, 5 + _spot_heat * 2.5, false);
    draw_set_color(_beam_col);
    draw_set_alpha((0.16 + _spot_heat * 0.14) * _rail_a);
    draw_line_width(_lamp_x - 13, _lamp_y + 4, _lamp_x + 13, _lamp_y + 4, 2);
    draw_line_width(_lamp_x, _lamp_y + 7, _focus_x, _focus_y, 0.8 + _spot_heat * 0.7);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_color(c_black);
  draw_set_alpha(0.46 * _rail_a);
  draw_rectangle(_wwx - 24, _rail_top, _wwx - 16, _wy - 18, false);
  draw_rectangle(_wwx + 16, _rail_top, _wwx + 24, _wy - 18, false);
  draw_rectangle(_wwx - 37, _wy - 25, _wwx + 37, _wy + 21, false);

  draw_set_color(_k_er_col_armor_dark);
  draw_set_alpha(0.86 * _rail_a);
  draw_rectangle(_wwx - 32, _wy - 20, _wwx + 32, _wy + 18, false);

  gpu_set_blendmode(bm_add);
  draw_set_color(merge_color(_k_er_col_warning, c_white, 0.45 + _wflash * 0.35));
  draw_set_alpha((0.14 + _wstage_p * 0.22 + _wflash * 0.26) * _rail_a);
  draw_line_width(_wwx - 20, _rail_top, _wwx - 20, _wy - 18, 1.4 + _wflash * 2);
  draw_line_width(_wwx + 20, _rail_top, _wwx + 20, _wy - 18, 1.4 + _wflash * 2);
  draw_line_width(_wwx - 42, _wy - 22, _wwx + 42, _wy - 22, 1.4 + _wflash * 1.4);
  draw_line_width(_wwx - 36, _wy + 20, _wwx + 36, _wy + 20, 1.2);

  for (var _side = -1; _side <= 1; _side += 2) {
    var _hinge_x = _wwx + _side * 9;
    var _hinge_y = _wy + 1;
    var _spread = 24 + _wopen * 34;
    var _lift = 7 + _wopen * 22;

    for (var _blade = 0; _blade < 5; _blade++) {
      var _bf = _blade / 4;
      var _tip_x = _hinge_x + _side * (_spread + _bf * (15 + _wopen * 9));
      var _tip_y = _hinge_y - _lift + _bf * 11 + sin(t * 0.11 + _blade * 1.3) * (1 + _wopen * 2)
                 + _wslam * (5 - _bf * 7);
      var _root_x = _hinge_x + _side * (3 + _bf * 5);
      var _root_y = _hinge_y - 5 + _bf * 6;
      var _tail_x = _tip_x - _side * (8 + _bf * 3);
      var _tail_y = _tip_y + 7 + _bf * 2;
      var _pane_a = (0.17 + _wopen * 0.16 + _wflash * 0.1) * (1 - _bf * 0.09) * _rail_a;

      draw_primitive_begin(pr_trianglefan);
      draw_vertex_colour(_root_x, _root_y, _k_er_col_armor_dark, _pane_a);
      draw_vertex_colour(_tip_x, _tip_y, c_white, _pane_a * 0.6);
      draw_vertex_colour(_tail_x, _tail_y, _k_er_col_armor_edge, _pane_a * 0.82);
      draw_vertex_colour(_root_x - _side * 2, _root_y + 6, c_black, _pane_a);
      draw_vertex_colour(_root_x, _root_y, _k_er_col_armor_dark, _pane_a);
      draw_primitive_end();

      draw_set_color(c_white);
      draw_set_alpha((0.08 + _wflash * 0.08 + _wready * 0.08) * (1 - _bf * 0.08) * _rail_a);
      draw_line_width(_root_x, _root_y - 1, _tip_x, _tip_y, 0.8);
    }
  }

  draw_set_color(c_white);
  draw_set_alpha((0.20 + _wflash * 0.32 + _wready * 0.2) * _rail_a);
  draw_circle(_wwx, _wy, 7 + _wflash * 3, false);
  scr_draw_smooth_ring_mask(_wwx, _wy, 18 + _wstage_p * 8 + _wflash * 12,
                            (0.20 + _wflash * 0.35) * _rail_a, 2.1 + _wflash * 2,
                            merge_color(_k_er_col_warning, c_white, _wflash * 0.45));

  if (_wready && !cube_wings_collected) {
    var _pickup_pulse = 0.55 + 0.45 * sin(t * 0.24);
    var _pickup_y = _wtarget_y;
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(0.18 + _pickup_pulse * 0.11);
    draw_line_width(_wwx - 18, _wy + 19, _wwx - 32, _pickup_y, 1.1);
    draw_line_width(_wwx + 18, _wy + 19, _wwx + 32, _pickup_y, 1.1);

    scr_draw_smooth_ring_mask(_wwx, _pickup_y, 34 + _pickup_pulse * 6,
                              0.34 + _pickup_pulse * 0.14, 3.0,
                              merge_color(_k_er_col_cyan, c_white, 0.68));
    scr_draw_smooth_ring_mask(_wwx, _pickup_y, 50 + _pickup_pulse * 9,
                              0.18 + _pickup_pulse * 0.10, 2.2,
                              merge_color(_k_er_col_warning, c_white, 0.35));

    for (var _mark = 0; _mark < 8; _mark++) {
      var _ma = _mark * 45 + t * 0.7;
      var _r0 = 47 + _pickup_pulse * 4;
      var _r1 = 61 + _pickup_pulse * 6;
      draw_set_color((_mark mod 2 == 0) ? c_white : _k_er_col_cyan);
      draw_set_alpha(0.20 + _pickup_pulse * 0.12);
      draw_line_width(_wwx + lengthdir_x(_r0, _ma), _pickup_y + lengthdir_y(_r0, _ma),
                      _wwx + lengthdir_x(_r1, _ma), _pickup_y + lengthdir_y(_r1, _ma),
                      1.15);
    }

    var _cw = _k_jr_wing_collect_w;
    var _ch = _k_jr_wing_collect_h;
    draw_set_color(c_white);
    draw_set_alpha(0.15 + _pickup_pulse * 0.10);
    draw_line_width(_wwx - _cw, _pickup_y - _ch, _wwx - _cw + 16, _pickup_y - _ch, 1);
    draw_line_width(_wwx - _cw, _pickup_y - _ch, _wwx - _cw, _pickup_y - _ch + 16, 1);
    draw_line_width(_wwx + _cw, _pickup_y - _ch, _wwx + _cw - 16, _pickup_y - _ch, 1);
    draw_line_width(_wwx + _cw, _pickup_y - _ch, _wwx + _cw, _pickup_y - _ch + 16, 1);
    draw_line_width(_wwx - _cw, _pickup_y + _ch, _wwx - _cw + 16, _pickup_y + _ch, 1);
    draw_line_width(_wwx - _cw, _pickup_y + _ch, _wwx - _cw, _pickup_y + _ch - 16, 1);
    draw_line_width(_wwx + _cw, _pickup_y + _ch, _wwx + _cw - 16, _pickup_y + _ch, 1);
    draw_line_width(_wwx + _cw, _pickup_y + _ch, _wwx + _cw, _pickup_y + _ch - 16, 1);
  }

  if (jr_wing_collect_flash > 0.01 && instance_exists(oPlayer)) {
    draw_set_color(c_white);
    draw_set_alpha(jr_wing_collect_flash * 0.34);
    draw_line_width(jr_wing_collect_x, jr_wing_collect_y, oPlayer.x, oPlayer.y, 3);
    draw_set_color(_k_er_col_warning);
    draw_set_alpha(jr_wing_collect_flash * 0.28);
    draw_line_width(jr_wing_collect_x - 10, jr_wing_collect_y + 4, oPlayer.x, oPlayer.y, 1.6);
    draw_line_width(jr_wing_collect_x + 10, jr_wing_collect_y - 4, oPlayer.x, oPlayer.y, 1.6);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (jr_wing_prompt_timer > 0 && instance_exists(oPlayer)) {
  var _prompt_life = jr_wing_prompt_max;
  var _prompt_age = _prompt_life - jr_wing_prompt_timer;
  var _prompt_in = clamp(_prompt_age / 8, 0, 1);
  var _prompt_out = clamp(jr_wing_prompt_timer / 24, 0, 1);
  var _prompt_a = _prompt_in * _prompt_out;
  var _prompt_pop = clamp(1 - _prompt_age / 16, 0, 1);
  var _prompt_x = clamp(oPlayer.x, 130, room_width - 130);
  var _prompt_y = clamp(oPlayer.y - 76 - _prompt_pop * 10, 60, _k_jr_floor_y - 104);
  var _prompt_jit = jr_wing_collect_flash * 2.5;
  var _prompt_text = "INFINITE JUMP";
  var _prompt_sub = "KEEP TAPPING JUMP";
  var _prompt_scale = 0.58 + _prompt_pop * 0.10;
  var _prompt_sub_scale = 0.34;

  draw_set_font(fMenu);
  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);

  gpu_set_blendmode(bm_add);
  draw_sprite_ext(spr_glow_blob, 0, _prompt_x, _prompt_y,
                  (220 + _prompt_pop * 70) / 64, (42 + _prompt_pop * 18) / 64,
                  0, _k_er_col_cyan, _prompt_a * (0.20 + _prompt_pop * 0.18));
  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_prompt_a * 0.36);
  draw_line_width(_prompt_x - 102, _prompt_y - 23, _prompt_x - 48, _prompt_y - 23, 1.6);
  draw_line_width(_prompt_x + 48, _prompt_y - 23, _prompt_x + 102, _prompt_y - 23, 1.6);
  draw_line_width(_prompt_x - 102, _prompt_y + 26, _prompt_x - 48, _prompt_y + 26, 1.2);
  draw_line_width(_prompt_x + 48, _prompt_y + 26, _prompt_x + 102, _prompt_y + 26, 1.2);

  gpu_set_blendmode(bm_normal);
  draw_set_color(c_black);
  draw_set_alpha(_prompt_a * 0.62);
  draw_text_transformed(_prompt_x + 3, _prompt_y + 3, _prompt_text, _prompt_scale, _prompt_scale, 0);
  draw_set_color(_k_er_col_warning);
  draw_set_alpha(_prompt_a * 0.36);
  draw_text_transformed(_prompt_x - _prompt_jit, _prompt_y, _prompt_text, _prompt_scale, _prompt_scale, 0);
  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_prompt_a * 0.34);
  draw_text_transformed(_prompt_x + _prompt_jit, _prompt_y, _prompt_text, _prompt_scale, _prompt_scale, 0);
  draw_set_color(c_white);
  draw_set_alpha(_prompt_a);
  draw_text_transformed(_prompt_x, _prompt_y, _prompt_text, _prompt_scale, _prompt_scale, 0);

  draw_set_color(_k_er_col_cyan);
  draw_set_alpha(_prompt_a * 0.78);
  draw_text_transformed(_prompt_x, _prompt_y + 29, _prompt_sub, _prompt_sub_scale, _prompt_sub_scale, 0);

  gpu_set_blendmode(bm_normal);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(jr_shards) > 0) {
  gpu_set_blendmode(bm_add);
  for (var _di = 0; _di < array_length(jr_shards); _di++) {
    var _jsh2 = jr_shards[_di];
    var _dsa = clamp(_jsh2.life / _jsh2.life_max, 0, 1);
    draw_sprite_ext(sRedOrb, 0, _jsh2.x, _jsh2.y,
                    _jsh2.size * (0.5 + _dsa * 0.6), _jsh2.size * (0.5 + _dsa * 0.6),
                    _jsh2.ang, merge_color(_k_er_col_armor_edge, c_white, _jsh2.hot * _dsa),
                    _dsa * 0.9);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(jump_rope_dust) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(jump_rope_dust); i++) {
    var _d = jump_rope_dust[i];
    var _dl = 1 - _d.life / _d.max_life;
    var _dsize = variable_struct_exists(_d, "size") ? _d.size : 3;
    var _dhot = variable_struct_exists(_d, "hot") ? _d.hot : 0.4;

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _dhot * _dl));
    draw_set_alpha(_dl * _dl * 0.75);
    draw_circle(_d.x, _d.y, _dsize * (0.6 + (1 - _dl) * 1.4), false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (t >= _k_arc_rift_t - 8 && t <= _k_arc_window_end) {

  if (t <= _k_arc_fire_t + 40) {
    var _arc_hot = clamp(arc_charge * 0.75 + arc_heartbeat * 0.25
                         + arc_fire_flash * 0.6 + arc_lock_flash * 0.3, 0, 1);
    var _arc_lockp = (t >= _k_arc_lock_t)
                   ? clamp((t - _k_arc_lock_t) / max(1, _k_arc_fire_t - _k_arc_lock_t), 0, 1)
                   : 0;
    var _arc_bot = arc_view_bottom();

    scr_draw_arc_rift(_arc_hot, arc_ceiling_live);

    if (t < _k_arc_fire_t) {
      var _rail_p = clamp(arc_charge * 0.55 + _arc_lockp * 0.95, 0, 1);
      var _rail_reach = clamp(arc_charge / _k_arc_rail_full_at, 0, 1);
      var _rail_len = lerp(70, _k_arc_beam_len, power(_rail_reach, 1.6));

      for (var _ri2 = 0; _ri2 < array_length(arc_blades); _ri2++) {
        var _rb = arc_blades[_ri2];
        if (!_rb.live || _rb.fired) continue;
        scr_draw_arc_rail(_rb.x, _rb.y, _rb.aim, _rail_len, _rail_p, _rb.seed);
      }
    }

    for (var _lc = 0; _lc < array_length(arc_lances); _lc++) {
      var _lnc = arc_lances[_lc];
      var _lp  = _lnc.timer / _k_arc_lance_fade;
      var _lw  = lerp(_k_arc_lance_hit_half * 0.85, 0, power(_lp, 0.55));
      var _la2 = 1 - power(_lp, 1.6);
      scr_draw_arc_lance(_lnc.x1, _lnc.y1, _lnc.x2, _lnc.y2, _lw, _la2, 1 - _lp * 0.6);
    }

    for (var _bd = 0; _bd < array_length(arc_blades); _bd++) {
      var _bl2 = arc_blades[_bd];
      if (!_bl2.live) continue;
      var _bscale = _bl2.fired ? _bl2.fade : (1 + _bl2.forge * 0.55 + arc_heartbeat * 0.10);
      scr_draw_arc_blade(_bl2.x, _bl2.y, _bl2.ang, _bscale,
                         _bl2.forge, _arc_hot, _arc_lockp, _bl2.fade);
    }

    if (array_length(arc_shards) > 0) {
      gpu_set_blendmode(bm_add);
      for (var _sd = 0; _sd < array_length(arc_shards); _sd++) {
        var _shd = arc_shards[_sd];
        var _sa  = _shd.life / _shd.life_max;
        var _sl  = 7 * _shd.scale * 2.4;
        var _sx1 = _shd.x + lengthdir_x(_sl, _shd.ang);
        var _sy1 = _shd.y + lengthdir_y(_sl, _shd.ang);
        var _sx2 = _shd.x - lengthdir_x(_sl, _shd.ang);
        var _sy2 = _shd.y - lengthdir_y(_sl, _shd.ang);

        draw_set_color(_shd.col);
        draw_set_alpha(_sa * 0.75);
        draw_line_width(_sx1, _sy1, _sx2, _sy2, 3 * _shd.scale + 1);
        draw_set_color(c_white);
        draw_set_alpha(_sa);
        draw_line_width(_sx1, _sy1, _sx2, _sy2, 1);
      }
      draw_set_alpha(1);
      draw_set_color(c_white);
      gpu_set_blendmode(bm_normal);
    }

    if (array_length(arc_forge_pops) > 0) {
      gpu_set_blendmode(bm_add);
      for (var _fq = 0; _fq < array_length(arc_forge_pops); _fq++) {
        var _fpp = arc_forge_pops[_fq];
        var _fa  = _fpp.life / _fpp.life_max;
        var _fr2 = lerp(4, 34, 1 - _fa) * (0.6 + _fpp.hot);

        draw_set_color(merge_color(_k_arc_color, c_white, 0.5));
        draw_set_alpha(_fa * _fa * 0.5);
        draw_circle(_fpp.x, _fpp.y, _fr2, false);
        draw_set_color(c_white);
        draw_set_alpha(_fa * _fa * 0.8);
        draw_circle(_fpp.x, _fpp.y, _fr2 * 0.34, false);
      }
      draw_set_alpha(1);
      draw_set_color(c_white);
      gpu_set_blendmode(bm_normal);
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);

  if (t >= _k_orb_unwrap_start - 8 || array_length(orb_unwrap_tracks) > 0 || orb_unwrap_sink_charge > 0.02) {
    var _uw_p = clamp((t - _k_orb_unwrap_start) / max(1, _k_arc_window_end - _k_orb_unwrap_start), 0, 1);
    var _uw_machine_floor = (t >= _k_orb_unwrap_start && t <= _k_arc_window_end)
                            ? (_k_orb_unwrap_machine_floor + dsin(_uw_p * 180) * _k_orb_unwrap_machine_pulse)
                            : 0;
    scr_draw_orb_unwrap_machine(_k_orb_rail_cx, _k_orb_rail_cy,
                                _k_mill_cx, _k_mill_cy,
                                _uw_p, orb_unwrap_sink_charge,
                                orb_unwrap_recoil, max(orb_power, orb_unwrap_sink_charge * 0.45, _uw_machine_floor),
                                orb_final_burst);
  }

  for (var _urs = 0; _urs < array_length(orb_unwrap_residue); _urs++) {
    scr_draw_orb_unwrap_residue(orb_unwrap_residue[_urs]);
  }

  for (var _sd2 = 0; _sd2 < array_length(orb_scars); _sd2++) {
    scr_draw_orb_scar(orb_scars[_sd2]);
  }

  for (var _rd2 = 0; _rd2 < array_length(orb_rails); _rd2++) {
    if (is_struct(orb_rails[_rd2])) scr_draw_orb_rail(orb_rails[_rd2], orb_latch, orb_power);
  }

  scr_draw_orb_hub(_k_orb_rail_cx, _k_orb_rail_cy, orb_hub, orb_hub_grow,
                   orb_latch, orb_rails, orb_power);

  for (var _utd = 0; _utd < array_length(orb_unwrap_tracks); _utd++) {
    scr_draw_orb_unwrap_track_mass(orb_unwrap_tracks[_utd]);
  }

  for (var _pd2 = 0; _pd2 < array_length(orb_plates); _pd2++) {
    scr_draw_orb_plate(orb_plates[_pd2]);
  }

  if (array_length(orb_bridges) > 0) {
    gpu_set_blendmode(bm_add);
    for (var _bd2 = 0; _bd2 < array_length(orb_bridges); _bd2++) {
      var _bg = orb_bridges[_bd2];
      var _bp = _bg.life / _bg.life_max;
      var _bdx = _bg.bx - _bg.ax, _bdy = _bg.by - _bg.ay;
      var _blen = max(1, point_distance(0, 0, _bdx, _bdy));
      var _bnx = -_bdy / _blen, _bny = _bdx / _blen;

      draw_set_color(merge_color(global.avoid_col_danger, c_white, 0.3 + (1 - _bp) * 0.45));
      draw_set_alpha(0.35 + _bp * 0.5);
      draw_primitive_begin(pr_trianglestrip);
      for (var _bs = 0; _bs <= 6; _bs++) {
        var _bu = _bs / 6;
        var _bw = _bg.width * (0.3 + abs(_bu * 2 - 1) * 0.9) * (0.25 + _bp * 0.75);
        var _bx2 = _bg.ax + _bdx * _bu;
        var _by2 = _bg.ay + _bdy * _bu;
        draw_vertex(_bx2 + _bnx * _bw, _by2 + _bny * _bw);
        draw_vertex(_bx2 - _bnx * _bw, _by2 - _bny * _bw);
      }
      draw_primitive_end();

      draw_set_color(c_white);
      draw_set_alpha(_bp * 0.55);
      draw_line_width(_bg.ax, _bg.ay, _bg.bx, _bg.by, max(1, _bg.width * 0.28 * _bp));

      draw_set_color(global.avoid_col_cyan);
      draw_set_alpha(_bp * 0.6);
      draw_circle(_bg.ax, _bg.ay, _bg.width * 1.4, true);
      draw_circle(_bg.bx, _bg.by, _bg.width * 1.4, true);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
  }

  if (orb_latch > 0.02 && orb_assembly_r > 0) {
    var _lbr = orb_assembly_r * 1.14;
    scr_draw_lock_bracket(_k_orb_rail_cx - _lbr, _k_orb_rail_cy - _lbr * 0.6,
                          _k_orb_rail_cx + _lbr, _k_orb_rail_cy + _lbr * 0.6,
                          global.avoid_col_warning, orb_latch,
                          clamp(orb_latch * 1.4, 0, 1), 16, false, 10);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (!is_undefined(lat)) {
  gpu_set_blendmode(bm_add);
  scr_lattice_draw_wire();
  gpu_set_blendmode(bm_normal);
}

if (instance_exists(oHoneycombController)) {
  scr_duct_draw_shaft();
  scr_honeycomb_draw_wire();
  scr_duct_draw_plug();
  gpu_set_blendmode(bm_normal);
}

if (t >= _k_mill_t_seed - 4 && t <= _k_mill_window_end) {
  var _ml_col = merge_color(_k_arc_color, c_white, 0.05 + mill_field_heat * 0.35);
  var _ml_hot = _k_arc_hot_color;
  var _mcore_swap0 = clamp((t - _k_mill_t_overload) / max(_k_mill_t_seed_c - _k_mill_t_overload, 1), 0, 1);
  var _mcore_arm0 = (t < _k_mill_t_unfold)
                    ? clamp((t - _k_mill_t_coil) / max(_k_mill_t_unfold - _k_mill_t_coil, 1), 0, 1)
                    : clamp((t - _k_mill_t_unfold) / max(_k_mill_core_arm, 1), 0, 1);
  var _mcore_r0 = lerp(_k_mill_core_r_a, _k_mill_core_r_b, _mcore_swap0) * lerp(0.38, 1, _mcore_arm0);
  var _mcore_vis0 = (t >= _k_mill_t_clear)
                    ? (1 - clamp((t - _k_mill_t_clear) / max(_k_mill_core_despawn, 1), 0, 1))
                    : 1;
  var _mcore_shrink0 = lerp(0.18, 1, _mcore_vis0);
  _mcore_r0 *= _mcore_shrink0;
  var _mcore_hot0 = clamp(_mcore_arm0 * 0.55 + mill_heartbeat * 0.3 + mill_blade_flash * 0.45
                          + mill_overload * 0.9 + mill_collapse * 0.35, 0, 1.6);

  gpu_set_blendmode(bm_normal);
  draw_set_color(c_black);
  draw_set_alpha((0.62 + clamp(_mcore_hot0, 0, 1) * 0.25) * _mcore_vis0);
  draw_circle(_k_mill_cx, _k_mill_cy, _mcore_r0 + 5, false);

  gpu_set_blendmode(bm_add);
  draw_set_color(merge_color(_ml_col, _ml_hot, 0.55 + clamp(mill_collapse, 0, 1) * 0.35));
  draw_set_alpha((0.34 + _mcore_hot0 * 0.34) * _mcore_vis0);
  draw_circle(_k_mill_cx, _k_mill_cy, _mcore_r0, true);
  draw_set_color(c_white);
  draw_set_alpha((0.18 + clamp(_mcore_hot0, 0, 1) * 0.32) * _mcore_vis0);
  draw_circle(_k_mill_cx, _k_mill_cy, max(4, _mcore_r0 * 0.32), true);
  draw_set_color(_ml_hot);
  draw_set_alpha((0.14 + clamp(_mcore_hot0, 0, 1) * 0.18) * _mcore_vis0);
  for (var _mctick = 0; _mctick < 12; _mctick++) {
    var _mca0 = (_mctick / 12) * 360 + mill_vortex * 1.4;
    draw_line_width(_k_mill_cx + lengthdir_x(_mcore_r0 * 0.82, _mca0),
                    _k_mill_cy + lengthdir_y(_mcore_r0 * 0.82, _mca0),
                    _k_mill_cx + lengthdir_x(_mcore_r0 * 1.08, _mca0),
                    _k_mill_cy + lengthdir_y(_mcore_r0 * 1.08, _mca0), 1.4);
  }

  if (_mcore_vis0 < 1 && _mcore_vis0 > 0.02) {
    var _mcore_pop0 = 1 - _mcore_vis0;
    draw_set_color(c_white);
    draw_set_alpha(_mcore_vis0 * _mcore_pop0 * 0.7);
    draw_circle(_k_mill_cx, _k_mill_cy, lerp(_k_mill_core_r_b * 1.25, 12, _mcore_pop0), true);
    draw_set_color(_ml_hot);
    draw_set_alpha(_mcore_vis0 * 0.38);
    draw_circle(_k_mill_cx, _k_mill_cy, lerp(_k_mill_core_r_b * 1.55, 22, _mcore_pop0), true);
  }

  var _ml_nw = array_length(mill_arm_waves);
  var _ml_arms_live = (!mill_torn && _ml_nw > 0);
  var _ml_lines = [];

  if (_ml_arms_live) {
    for (var _mw = 0; _mw < _ml_nw; _mw++) {
      var _mwv = mill_arm_waves[_mw];
      var _mrev = clamp(_mwv.age / _k_mill_arm_reveal, 0, 1);

      var _mgl = _mwv.weight * (1 - clamp((_mwv.age - _k_mill_arm_reveal - _k_mill_arm_hold)
                                          / _k_mill_arm_fade, 0, 1))
               * (0.72 + mill_arm_glow * 0.28);
      if (_mgl < 0.01) continue;

      for (var _mai = 0; _mai < _mwv.count; _mai++) {
        var _mpx = array_create(_k_mill_arm_segs + 1, 0);
        var _mpy = array_create(_k_mill_arm_segs + 1, 0);
        for (var _mas = 0; _mas <= _k_mill_arm_segs; _mas++) {
          var _mpt = scr_mill_arm_point(_mwv, _mai, (_mas / _k_mill_arm_segs) * _mrev,
                                        _k_mill_cx, _k_mill_cy);
          _mpx[_mas] = _mpt.x;
          _mpy[_mas] = _mpt.y;
        }
        array_push(_ml_lines, { px : _mpx, py : _mpy, glow : _mgl, wave : _mwv,
                                rev : _mrev, arm : _mai });
      }
    }

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    for (var _mli = 0; _mli < array_length(_ml_lines); _mli++) {
      var _mln = _ml_lines[_mli];
      draw_set_alpha(_mln.glow * 0.5);
      for (var _mas = 1; _mas <= _k_mill_arm_segs; _mas++) {
        draw_line_width(_mln.px[_mas - 1], _mln.py[_mas - 1], _mln.px[_mas], _mln.py[_mas],
                        _k_mill_arm_w * 2.6);
      }
    }
  }

  gpu_set_blendmode(bm_add);

  if (_ml_arms_live) {
    for (var _mli = 0; _mli < array_length(_ml_lines); _mli++) {
      var _mln  = _ml_lines[_mli];
      var _mlg  = _mln.glow;
      var _mlh  = _mlg * (0.72 + mill_heartbeat * 0.42);
      var _mlw  = _k_mill_arm_w;

      for (var _mas = 1; _mas <= _k_mill_arm_segs; _mas++) {
        var _mtf = (_mas - 0.5) / _k_mill_arm_segs;
        if (frac(_mtf * _k_mill_arm_dashes) > _k_mill_arm_dash_on) continue;

        var _x1 = _mln.px[_mas - 1], _y1 = _mln.py[_mas - 1];
        var _x2 = _mln.px[_mas],     _y2 = _mln.py[_mas];

        var _mte = 1 - clamp((_mtf - 0.88) / 0.12, 0, 1) * 0.55;

        draw_set_color(_ml_col);
        draw_set_alpha(min(1, (0.16 + _mlh * 0.2) * _mte));
        draw_line_width(_x1, _y1, _x2, _y2, _mlw);

        draw_set_color(_ml_hot);
        draw_set_alpha(min(1, (0.12 + _mlh * 0.26) * _mte));
        draw_line_width(_x1, _y1, _x2, _y2, _mlw * 0.4);
      }

      if (_mln.rev < 1) {
        var _mhx = _mln.px[_k_mill_arm_segs], _mhy = _mln.py[_k_mill_arm_segs];
        draw_set_color(_ml_hot);
        draw_set_alpha(_mlg * 0.45);
        draw_circle(_mhx, _mhy, 6 + mill_heartbeat * 3, false);
        draw_set_color(c_white);
        draw_set_alpha(_mlg * 0.8);
        draw_circle(_mhx, _mhy, 2.2, false);
      }

      var _mwv2 = _mln.wave;
      if (_mwv2.per > 1 && _mln.rev > 0) {
        for (var _mb = 0; _mb < _mwv2.per; _mb++) {
          var _mbp = _mb / (_mwv2.per - 1);
          if (_mbp > _mln.rev) break;

          var _mbi = clamp(round((_mbp / _mln.rev) * _k_mill_arm_segs), 0, _k_mill_arm_segs);
          var _mkx = _mln.px[_mbi], _mky = _mln.py[_mbi];

          var _mbj = min(_mbi + 1, _k_mill_arm_segs);
          var _mdx = _mln.px[_mbj] - _mln.px[max(_mbi - 1, 0)];
          var _mdy = _mln.py[_mbj] - _mln.py[max(_mbi - 1, 0)];
          var _mdl = point_distance(0, 0, _mdx, _mdy);
          if (_mdl < 0.001) continue;

          var _mnx = -_mdy / _mdl * _k_mill_arm_mark;
          var _mny =  _mdx / _mdl * _k_mill_arm_mark;
          var _mkc = _mwv2.cols[(_mln.arm * _mwv2.per + _mb) mod array_length(_mwv2.cols)];

          draw_set_color(_mkc);
          draw_set_alpha(min(1, _mlg * (0.5 + mill_heartbeat * 0.35)));
          draw_line_width(_mkx - _mnx, _mky - _mny, _mkx + _mnx, _mky + _mny, 2);

          draw_set_color(c_white);
          draw_set_alpha(min(1, _mlg * (0.35 + mill_heartbeat * 0.4)));
          draw_line_width(_mkx - _mnx * 0.45, _mky - _mny * 0.45,
                          _mkx + _mnx * 0.45, _mky + _mny * 0.45, 1);
        }
      }
    }
  }

  if (mill_rim > 2) {
    var _mrv = _k_mill_ry_out / _k_mill_rx_out;
    var _mrsegs = 56;
    var _mrpx = 0, _mrpy = 0;
    draw_set_color(merge_color(_ml_col, c_white, mill_charge * 0.5));
    for (var _mrs = 0; _mrs <= _mrsegs; _mrs++) {
      var _mrang = (_mrs / _mrsegs) * 360 + mill_vortex * 0.6;
      var _mrx = _k_mill_cx + lengthdir_x(mill_rim, _mrang);
      var _mry = _k_mill_cy + lengthdir_y(mill_rim * _mrv, _mrang);
      if (_mrs > 0 && (_mrs mod 2 == 0)) {
        draw_set_alpha((0.25 + mill_charge * 0.55) * (0.7 + mill_heartbeat * 0.5));
        draw_line_width(_mrpx, _mrpy, _mrx, _mry, 1.5 + mill_charge * 2);
      }
      _mrpx = _mrx;
      _mrpy = _mry;
    }
  }

  with (oLaserOrbTrigger) {
    if (!is_rotating) continue;
    var _mbax = image_angle - 90;
    var _mbrh = _k_beam_half_length * extend;
    if (_mbrh < 2) continue;

    var _mb1x = x - lengthdir_x(_mbrh, _mbax);
    var _mb1y = y - lengthdir_y(_mbrh, _mbax);
    var _mb2x = x + lengthdir_x(_mbrh, _mbax);
    var _mb2y = y + lengthdir_y(_mbrh, _mbax);

    draw_set_color(c_white);
    draw_set_alpha(0.5 + beam_heat * 0.25);
    draw_line_width(_mb1x, _mb1y, _mb2x, _mb2y, 1.5);

    draw_set_alpha(0.7 + beam_heat * 0.2);
    var _mbperp = _mbax + 90;
    draw_line_width(_mb2x + lengthdir_x(7, _mbperp), _mb2y + lengthdir_y(7, _mbperp),
                    _mb2x - lengthdir_x(7, _mbperp), _mb2y - lengthdir_y(7, _mbperp), 2);
    draw_line_width(_mb1x + lengthdir_x(7, _mbperp), _mb1y + lengthdir_y(7, _mbperp),
                    _mb1x - lengthdir_x(7, _mbperp), _mb1y - lengthdir_y(7, _mbperp), 2);
  }

  var _mgate_read_phase = (t >= _k_mill_t_seed_c && t < _k_mill_t_tear);
  for (var _msi2 = 0; _msi2 < array_length(mill_scars); _msi2++) {
    var _msc2 = mill_scars[_msi2];
    var _msa = _msc2.alpha;
    var _msig = max(_msc2.ignite, _msc2.guide);

    var _ms1x = _k_mill_cx - lengthdir_x(_msc2.half_len, _msc2.ang);
    var _ms1y = _k_mill_cy - lengthdir_y(_msc2.half_len, _msc2.ang);
    var _ms2x = _k_mill_cx + lengthdir_x(_msc2.half_len, _msc2.ang);
    var _ms2y = _k_mill_cy + lengthdir_y(_msc2.half_len, _msc2.ang);

    draw_set_color(merge_color(_ml_col, c_white, 0.3 * _msc2.hot + _msig * 0.6));
    draw_set_alpha(_msa * (_mgate_read_phase ? 0.10 : 0.35) + _msig * (_mgate_read_phase ? 0.42 : 0.6));
    draw_line_width(_ms1x, _ms1y, _ms2x, _ms2y,
                    1 + _msa * (_mgate_read_phase ? 0.9 : 2) + _msig * (_mgate_read_phase ? 2.2 : 4));

    if (_msig > 0.25 && !_mgate_read_phase) {
      var _msperp = _msc2.ang + 90;
      draw_set_color(_ml_hot);
      draw_set_alpha((_msig - 0.25) * 0.8);
      for (var _msh = -4; _msh <= 4; _msh++) {
        var _mshd = (_msh / 4) * _msc2.half_len * 0.9;
        var _mshx = _k_mill_cx + lengthdir_x(_mshd, _msc2.ang);
        var _mshy = _k_mill_cy + lengthdir_y(_mshd, _msc2.ang);
        var _mshl = 10 + _msig * 22;
        draw_line_width(_mshx, _mshy, _mshx + lengthdir_x(_mshl, _msperp),
                        _mshy + lengthdir_y(_mshl, _msperp), 1.5);
        draw_line_width(_mshx, _mshy, _mshx - lengthdir_x(_mshl, _msperp),
                        _mshy - lengthdir_y(_mshl, _msperp), 1.5);
      }
    }
  }

  with (oFallingRedOrb) {
    if (!mill_orb || !telegraphing || dissolving) continue;
    var _mtp = 1 - (telegraph_timer / max(telegraph_duration, 1));
    var _mfuse = clamp((telegraph_duration - telegraph_timer - mill_fuse_delay)
                       / max(mill_fuse_span, 1), 0, 1);
    var _mtcol = mill_gate_cyan ? global.avoid_col_cyan : _ml_hot;

    draw_set_color(merge_color(_ml_col, _mtcol, _mfuse));
    draw_set_alpha(0.12 + _mtp * 0.18 + _mfuse * 0.52);
    var _mtick = 18 + _mtp * 18 + _mfuse * 30;
    draw_line_width(x - lengthdir_x(_mtick * 0.35, mill_launch_dir),
                    y - lengthdir_y(_mtick * 0.35, mill_launch_dir),
                    x + lengthdir_x(_mtick, mill_launch_dir),
                    y + lengthdir_y(_mtick, mill_launch_dir), 0.8 + _mfuse * 1.8);

    var _mtr = lerp(19, 7, max(_mtp, _mfuse));
    draw_set_alpha(0.18 + _mtp * 0.24 + _mfuse * 0.52);
    draw_circle(x, y, _mtr, true);

    if (_mfuse > 0) {
      draw_set_color(_mtcol);
      draw_set_alpha(_mfuse * (0.35 + random(0.25)));
      var _mfa = mill_launch_dir + 90;
      draw_line_width(x + lengthdir_x(5, _mfa), y + lengthdir_y(5, _mfa),
                      x - lengthdir_x(5, _mfa), y - lengthdir_y(5, _mfa),
                      1 + _mfuse * 2);
    }
  }

  with (oFallingRedOrb) {
    if (!mill_orb || dissolving || mill_link_to == noone) continue;
    if (!instance_exists(mill_link_to)) continue;

    var _wo = mill_link_to;
    if (_wo.dissolving) continue;

    var _wlive = (mill_wired && _wo.mill_wired);
    var _wrest = (!_wlive && !telegraphing && waiting_to_fall == 1 && _wo.waiting_to_fall == 1);
    if (!_wlive && !telegraphing && !_wrest) continue;

    var _wfuse = 1;
    if (_wrest) {
      _wfuse = 0;
    } else if (!_wlive) {
      var _wfa = clamp((telegraph_duration - telegraph_timer - mill_fuse_delay)
                       / max(mill_fuse_span, 1), 0, 1);
      var _wfb = clamp((_wo.telegraph_duration - _wo.telegraph_timer - _wo.mill_fuse_delay)
                       / max(_wo.mill_fuse_span, 1), 0, 1);
      _wfuse = min(_wfa, _wfb);
      if (_wfuse <= 0) continue;
    }

    var _wa   = _wlive ? 0.85 : (_wrest ? 0.58 : (0.12 + _wfuse * 0.34 + random(0.16) * _wfuse));
    var _wwid = _wlive ? 2.4 : (_wrest ? 1.35 : (0.7 + _wfuse * 0.7));

    var _wcol = mill_gate_cyan ? global.avoid_col_cyan : _ml_hot;

    draw_set_color(merge_color(_wcol, c_white, _wlive ? 0.35 : (_wrest ? 0.2 : 0.12)));
    draw_set_alpha(_wa * 0.45);
    draw_line_width(x, y, _wo.x, _wo.y, _wwid * 3.2);

    draw_set_color(_wcol);
    draw_set_alpha(_wa);
    draw_line_width(x, y, _wo.x, _wo.y, _wwid);
  }

  for (var _mdi = 0; _mdi < array_length(mill_scars); _mdi++) {
    var _mdc = mill_scars[_mdi];
    if (_mdc.door_a == noone || _mdc.door_b == noone) continue;
    if (!instance_exists(_mdc.door_a) || !instance_exists(_mdc.door_b)) continue;

    var _mda = _mdc.door_a;
    var _mdb = _mdc.door_b;
    if (_mda.dissolving || _mdb.dissolving) continue;
    if (!_mda.mill_wired && !_mda.telegraphing) continue;

    var _mdx   = (_mda.x + _mdb.x) * 0.5;
    var _mdy   = (_mda.y + _mdb.y) * 0.5;
    var _mdh   = point_distance(_mda.x, _mda.y, _mdb.x, _mdb.y) * 0.5;
    var _mdang = point_direction(_mda.x, _mda.y, _mdb.x, _mdb.y);
    var _mdhot = _mda.telegraphing
                 ? (1 - _mda.telegraph_timer / max(_mda.telegraph_duration, 1))
                 : 1;

    scr_draw_lock_bracket(_mdx - _mdh, _mdy - 22, _mdx + _mdh, _mdy + 22,
                          global.avoid_col_cyan, _mdhot, 0.45 + _mdhot * 0.4,
                          9, false, 4, _mdang);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (t >= _k_fin_t_open - 6 && t <= _k_fin_t_cut + 60) {
  gpu_set_blendmode(bm_add);

  var _fn_col = merge_color(_k_fin_orb_color, c_white, 0.18 + fin_impact * 0.3);
  var _fn_hot = _k_fin_orb_hot;

  var _fa_vis = fin_assembly_visibility();
  if (_fa_vis > 0.01) {
    var _fa_heat = clamp(fin_assembly_pulse + fin_assembly_sync * 0.65 + fin_charge * 0.22
                         + fin_lock_flash * 0.18, 0, 1.6);
    var _fa_build = clamp((t - _k_fin_assembly_t_start)
                          / max(_k_fin_assembly_t_fade - _k_fin_assembly_t_start, 1), 0, 1);
    var _fa_scar = _fa_vis * (1 - clamp((t - _k_fin_assembly_t_ready) / 92, 0, 1));
    var _fa_pull = clamp((t - _k_fin_t_breath) / max(_k_fin_t_cut - _k_fin_t_breath, 1), 0, 1);

    gpu_set_blendmode(bm_normal);

    if (_fa_scar > 0.015) {
      draw_set_color(c_black);
      for (var _fsc = 0; _fsc < array_length(fin_assembly_scars); _fsc++) {
        var _fsr = fin_assembly_scars[_fsc];
        var _srp = clamp((_fa_build - _fsr.delay) / max(1 - _fsr.delay, 0.001), 0, 1);
        if (_srp <= 0) continue;

        draw_set_alpha(_fa_scar * _srp * 0.34);
        var _spx = _k_fin_cx - lengthdir_x(_fsr.len_a, _fsr.ang);
        var _spy = _k_fin_cy - lengthdir_y(_fsr.len_a, _fsr.ang);
        for (var _sss = 1; _sss <= 9; _sss++) {
          var _sf = _sss / 9;
          var _sd = lerp(-_fsr.len_a, _fsr.len_b, _sf);
          var _sw = _fsr.off + sin(_sf * pi * 3 + _fsr.delay * 7 + t * 0.018) * _fsr.wave;
          var _snx = _k_fin_cx + lengthdir_x(_sd, _fsr.ang) + lengthdir_x(_sw, _fsr.ang + 90);
          var _sny = _k_fin_cy + lengthdir_y(_sd, _fsr.ang) + lengthdir_y(_sw, _fsr.ang + 90);
          draw_line_width(_spx, _spy, _snx, _sny, 5.8);
          _spx = _snx;
          _spy = _sny;
        }
      }
    }

    draw_set_color(c_black);
    for (var _fri = 0; _fri < array_length(_k_fin_assembly_ring_r); _fri++) {
      var _frp = fin_assembly_ring_progress(_k_fin_assembly_ring_delay[_fri]);
      if (_frp <= 0.01) continue;

      var _frad = _k_fin_assembly_ring_r[_fri] - fin_assembly_pulse * (2.5 + _fri)
                + sin(t * 0.018 + _fri * 1.7) * (1.2 + _frp * 1.8);
      var _fsegs = _k_fin_assembly_ring_segs[_fri];
      var _fseg_step = 360 / _fsegs;
      var _fduty = 0.35 + _frp * 0.24;
      var _frot = _k_fin_assembly_ring_offset[_fri]
                + (1 - _frp) * ((_fri mod 2) ? -26 : 26)
                + fin_section_p * ((_fri mod 2) ? -8 : 8);
      var _falpha = _fa_vis * _frp * (0.24 + _fri * 0.018);

      draw_set_alpha(_falpha);
      for (var _fsi = 0; _fsi < _fsegs; _fsi++) {
        if (((_fsi + _fri) mod 5) == 2 && _frp < 0.86) continue;
        var _fa0 = _frot + _fsi * _fseg_step;
        var _fa1 = _fa0 + _fseg_step * _fduty;
        var _fx0 = _k_fin_cx + lengthdir_x(_frad, _fa0);
        var _fy0 = _k_fin_cy + lengthdir_y(_frad, _fa0);
        var _fx1 = _k_fin_cx + lengthdir_x(_frad, _fa1);
        var _fy1 = _k_fin_cy + lengthdir_y(_frad, _fa1);
        draw_line_width(_fx0, _fy0, _fx1, _fy1, 5.0 + _fri * 0.45);
      }
    }

    for (var _fni = 0; _fni < array_length(fin_assembly_nodes); _fni++) {
      var _fnd = fin_assembly_nodes[_fni];
      var _fnp = fin_assembly_ring_progress(_fnd.delay);
      if (_fnp <= 0.02) continue;

      var _fpul = _fnd.pulse;
      var _nr = _fnd.r - fin_assembly_pulse * (2 + _fnd.ring);
      var _na = _fnd.ang + fin_section_p * ((_fnd.ring mod 2) ? -8 : 8);
      var _nx = _k_fin_cx + lengthdir_x(_nr, _na);
      var _ny = _k_fin_cy + lengthdir_y(_nr, _na);
      var _ta = _na + 90;
      var _sock = (6.5 + _fnd.ring * 0.45 + _fpul * 2.8) * _fnp;

      draw_set_color(c_black);
      draw_set_alpha(_fa_vis * _fnp * (0.42 + _fpul * 0.18));
      draw_circle(_nx, _ny, _sock + 5, false);
      draw_line_width(_nx - lengthdir_x(_sock + 7, _ta), _ny - lengthdir_y(_sock + 7, _ta),
                      _nx + lengthdir_x(_sock + 7, _ta), _ny + lengthdir_y(_sock + 7, _ta),
                      4 + _fnd.ring * 0.4);

      if (_fnd.ring > 0 && ((_fni + _fnd.seed) mod 2) == 0) {
        draw_set_alpha(_fa_vis * _fnp * 0.12);
        var _br0 = max(34, _nr - 78);
        draw_line_width(_k_fin_cx + lengthdir_x(_br0, _na), _k_fin_cy + lengthdir_y(_br0, _na),
                        _nx, _ny, 3.4);
      }
    }

    var _core_shell = 16 + _fa_vis * 7 + _fa_heat * 3;
    draw_set_color(c_black);
    draw_set_alpha(_fa_vis * 0.58);
    draw_circle(_k_fin_cx, _k_fin_cy, _core_shell + 9, false);
    draw_set_alpha(_fa_vis * 0.30);
    draw_circle(_k_fin_cx, _k_fin_cy, _core_shell + 15, true);

    gpu_set_blendmode(bm_add);

    if (_fa_scar > 0.015) {
      for (var _fsc2 = 0; _fsc2 < array_length(fin_assembly_scars); _fsc2++) {
        var _fsr2 = fin_assembly_scars[_fsc2];
        var _srp2 = clamp((_fa_build - _fsr2.delay) / max(1 - _fsr2.delay, 0.001), 0, 1);
        if (_srp2 <= 0) continue;

        draw_set_color(merge_color(global.avoid_col_blood, global.avoid_col_warning,
                                   0.18 + _fa_heat * 0.12));
        draw_set_alpha(_fa_scar * _srp2 * (0.18 + _fa_heat * 0.08));
        var _spx2 = _k_fin_cx - lengthdir_x(_fsr2.len_a, _fsr2.ang);
        var _spy2 = _k_fin_cy - lengthdir_y(_fsr2.len_a, _fsr2.ang);
        for (var _sss2 = 1; _sss2 <= 9; _sss2++) {
          var _sf2 = _sss2 / 9;
          var _sd2 = lerp(-_fsr2.len_a, _fsr2.len_b, _sf2);
          var _sw2 = _fsr2.off + sin(_sf2 * pi * 3 + _fsr2.delay * 7 + t * 0.018) * _fsr2.wave;
          var _snx2 = _k_fin_cx + lengthdir_x(_sd2, _fsr2.ang) + lengthdir_x(_sw2, _fsr2.ang + 90);
          var _sny2 = _k_fin_cy + lengthdir_y(_sd2, _fsr2.ang) + lengthdir_y(_sw2, _fsr2.ang + 90);
          draw_line_width(_spx2, _spy2, _snx2, _sny2, 1.3 + _fa_heat * 0.7);
          _spx2 = _snx2;
          _spy2 = _sny2;
        }
      }
    }

    for (var _fri2 = 0; _fri2 < array_length(_k_fin_assembly_ring_r); _fri2++) {
      var _frp2 = fin_assembly_ring_progress(_k_fin_assembly_ring_delay[_fri2]);
      if (_frp2 <= 0.01) continue;

      var _frad2 = _k_fin_assembly_ring_r[_fri2] - fin_assembly_pulse * (2.5 + _fri2)
                 + sin(t * 0.018 + _fri2 * 1.7) * (1.2 + _frp2 * 1.8);
      var _fsegs2 = _k_fin_assembly_ring_segs[_fri2];
      var _fseg_step2 = 360 / _fsegs2;
      var _fduty2 = 0.35 + _frp2 * 0.24;
      var _frot2 = _k_fin_assembly_ring_offset[_fri2]
                 + (1 - _frp2) * ((_fri2 mod 2) ? -26 : 26)
                 + fin_section_p * ((_fri2 mod 2) ? -8 : 8);
      var _fcol = (_fri2 mod 2) ? global.avoid_col_cyan : global.avoid_col_warning;
      var _falpha2 = _fa_vis * _frp2 * (0.24 + _fa_heat * 0.16);

      draw_set_color(merge_color(_fcol, c_white, 0.12 + _fa_heat * 0.10));
      for (var _fsi2 = 0; _fsi2 < _fsegs2; _fsi2++) {
        if (((_fsi2 + _fri2) mod 5) == 2 && _frp2 < 0.86) continue;
        var _fbump = (((_fsi2 + floor(t / 2)) mod 6) == 0) ? fin_assembly_sync * 0.24 : 0;
        draw_set_alpha(_falpha2 + _fbump * _fa_vis);
        var _fa02 = _frot2 + _fsi2 * _fseg_step2;
        var _fa12 = _fa02 + _fseg_step2 * _fduty2;
        draw_line_width(_k_fin_cx + lengthdir_x(_frad2, _fa02),
                        _k_fin_cy + lengthdir_y(_frad2, _fa02),
                        _k_fin_cx + lengthdir_x(_frad2, _fa12),
                        _k_fin_cy + lengthdir_y(_frad2, _fa12),
                        1.2 + _frp2 * 1.1 + _fbump * 1.4);
      }
    }

    for (var _fni2 = 0; _fni2 < array_length(fin_assembly_nodes); _fni2++) {
      var _fnd2 = fin_assembly_nodes[_fni2];
      var _fnp2 = fin_assembly_ring_progress(_fnd2.delay);
      if (_fnp2 <= 0.02) continue;

      var _fpul2 = _fnd2.pulse;
      var _ncol = (_fnd2.ring mod 2) ? global.avoid_col_cyan : global.avoid_col_warning;
      var _nr2 = _fnd2.r - fin_assembly_pulse * (2 + _fnd2.ring);
      var _na2 = _fnd2.ang + fin_section_p * ((_fnd2.ring mod 2) ? -8 : 8);
      var _nx2 = _k_fin_cx + lengthdir_x(_nr2, _na2);
      var _ny2 = _k_fin_cy + lengthdir_y(_nr2, _na2);
      var _ta2 = _na2 + 90;
      var _sock2 = (6.5 + _fnd2.ring * 0.45 + _fpul2 * 2.8) * _fnp2;

      draw_set_color(merge_color(_ncol, c_white, 0.18 + _fpul2 * 0.28));
      draw_set_alpha(_fa_vis * _fnp2 * (0.28 + _fpul2 * 0.48));
      draw_circle(_nx2, _ny2, _sock2 + _fpul2 * 4, true);
      draw_line_width(_nx2 - lengthdir_x(_sock2 + 8, _ta2), _ny2 - lengthdir_y(_sock2 + 8, _ta2),
                      _nx2 + lengthdir_x(_sock2 + 8, _ta2), _ny2 + lengthdir_y(_sock2 + 8, _ta2),
                      1.3 + _fpul2 * 1.7);
      draw_set_alpha(_fa_vis * _fnp2 * (0.16 + _fpul2 * 0.32));
      draw_circle(_nx2, _ny2, max(1.2, (2.2 + _fnd2.ring * 0.22) * _fnp2 + _fpul2 * 2.2), false);

      if (_fnd2.ring > 0 && ((_fni2 + _fnd2.seed) mod 2) == 0) {
        draw_set_alpha(_fa_vis * _fnp2 * (0.075 + _fpul2 * 0.18));
        var _br02 = max(34, _nr2 - 78);
        draw_line_width(_k_fin_cx + lengthdir_x(_br02, _na2), _k_fin_cy + lengthdir_y(_br02, _na2),
                        _nx2, _ny2, 1.2 + _fpul2);
      }
    }

    for (var _fpkd = 0; _fpkd < array_length(fin_assembly_packets); _fpkd++) {
      var _fpk = fin_assembly_packets[_fpkd];
      var _fku = 1 - _fpk.life / max(_fpk.max_life, 1);
      var _fke = 1 - power(1 - _fku, 3);
      var _fkr = lerp(_fpk.r0, _fpk.r1, _fke);
      var _fkr0 = lerp(_fpk.r0, _fpk.r1, max(0, _fke - 0.08));
      var _fka = _fpk.ang + _fa_pull * angle_difference(fin_cut_axis().ang, _fpk.ang) * 0.16;
      var _fpx = _k_fin_cx + lengthdir_x(_fkr, _fka);
      var _fpy = _k_fin_cy + lengthdir_y(_fkr, _fka);
      var _ftx = _k_fin_cx + lengthdir_x(_fkr0, _fka);
      var _fty = _k_fin_cy + lengthdir_y(_fkr0, _fka);
      var _fpa = sin(_fku * pi) * _fa_vis;

      draw_set_color(merge_color(global.avoid_col_warning, c_white, _fpk.hot * 0.28));
      draw_set_alpha(_fpa * (0.30 + _fpk.hot * 0.24));
      draw_line_width(_ftx, _fty, _fpx, _fpy, _fpk.width * (1.4 + _fpk.hot));
      draw_set_color(c_white);
      draw_set_alpha(_fpa * _fpk.hot * 0.42);
      draw_line_width(lerp(_ftx, _fpx, 0.45), lerp(_fty, _fpy, 0.45), _fpx, _fpy,
                      max(0.8, _fpk.width * 0.6));
    }

    draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.10 + _fa_heat * 0.22));
    draw_set_alpha(_fa_vis * (0.20 + _fa_heat * 0.24));
    draw_circle(_k_fin_cx, _k_fin_cy, _core_shell, true);
    draw_circle(_k_fin_cx, _k_fin_cy, _core_shell * 0.54, true);

    for (var _fct = 0; _fct < 16; _fct++) {
      var _fca = _fct * 22.5 + fin_section_p * 42;
      var _tick0 = _core_shell + 6;
      var _tick1 = _core_shell + 15 + fin_assembly_pulse * 4;
      draw_set_alpha(_fa_vis * (0.15 + _fa_heat * 0.22));
      draw_line_width(_k_fin_cx + lengthdir_x(_tick0, _fca),
                      _k_fin_cy + lengthdir_y(_tick0, _fca),
                      _k_fin_cx + lengthdir_x(_tick1, _fca),
                      _k_fin_cy + lengthdir_y(_tick1, _fca),
                      1.2 + fin_assembly_pulse * 0.6);
    }
  }

  for (var _fq = 0; _fq < array_length(fin_ghosts); _fq++) {
    var _fqg = fin_ghosts[_fq];
    var _fqn = array_length(_fqg.pts);
    if (_fqn < 3) continue;

    draw_set_color(merge_color(_k_fin_orb_color, c_white, _fqg.hot * 0.5));
    draw_set_alpha(_fqg.alpha * 0.3);
    for (var _fqi = 0; _fqi < _fqn; _fqi++) {
      var _fqa = _fqg.pts[_fqi];
      var _fqb = _fqg.pts[(_fqi + 1) mod _fqn];
      draw_line_width(_fqa.x, _fqa.y, _fqb.x, _fqb.y, _fqg.width * _fqg.alpha);
    }
  }

  var _n_shells = array_length(fin_shells);

  if (_n_shells > 0) {
    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);

    for (var _gs = 0; _gs < _n_shells; _gs++) {
      var _gsh   = fin_shells[_gs];
      var _gsol  = fin_shell_solidity(_gsh);
      if (_gsol <= 0.02) continue;

      draw_set_alpha(_gsol * _gsh.burn * 0.9);
      var _gw = _gsh.wall_w * _gsol + _k_fin_shell_groove_w * 2;

      for (var _gi = 0; _gi < _gsh.sides; _gi++) {
        var _gwl = fin_shell_wall(_gsh, _gi);
        var _gsp = fin_shell_gap_span(_gsh, _gwl);
        for (var _gk = 0; _gk < 2; _gk++) {
          var _gf0 = (_gk == 0) ? 0 : _gsp[1];
          var _gf1 = (_gk == 0) ? _gsp[0] : 1;
          if (_gf1 - _gf0 < 0.001) continue;
          draw_line_width(lerp(_gwl.x1, _gwl.x2, _gf0), lerp(_gwl.y1, _gwl.y2, _gf0),
                          lerp(_gwl.x1, _gwl.x2, _gf1), lerp(_gwl.y1, _gwl.y2, _gf1), _gw);
        }
      }
    }

    gpu_set_blendmode(bm_add);
  }

  for (var _sg = 0; _sg < array_length(fin_shell_ghosts); _sg++) {
    var _sgh = fin_shell_ghosts[_sg];
    var _sga = _sgh.alpha;

    draw_set_color(merge_color(_sgh.col, c_white, _sgh.hot * 0.4));
    draw_set_alpha(_sga * _sga * 0.5);

    for (var _sgi = 0; _sgi < array_length(_sgh.segs); _sgi++) {
      var _sgs = _sgh.segs[_sgi];
      draw_line_width(_sgs.x1, _sgs.y1, _sgs.x2, _sgs.y2, _sgh.width * _sga);
    }
  }

  for (var _sq = 0; _sq < _n_shells; _sq++) {
    var _sh   = fin_shells[_sq];
    var _sol  = fin_shell_solidity(_sh);
    var _shb  = _sh.burn;
    var _lf   = _sh.land_flash;
    var _rg   = _sh.ring;
    var _heat = clamp(_sh.hot * 0.5 + _lf * 0.6 + _rg * 0.3, 0, 1);

    var _tgt = { sides : _sh.sides, radius : _sh.r_lock, rot : _sh.rot_to, span : _sh.span };

    if (_sol < 0.999 && _shb > 0.01) {
      var _lane_a = (1 - _sol) * 0.5 + 0.25;
      for (var _le = -1; _le <= 1; _le += 2) {
        var _lea = _sh.gap.ang + _le * _sh.gap.w * 0.5;
        draw_set_color(merge_color(_sh.col, c_white, 0.45));
        draw_set_alpha(_lane_a * 0.5);
        draw_line_width(_k_fin_cx + lengthdir_x(60, _lea), _k_fin_cy + lengthdir_y(60, _lea),
                        _k_fin_cx + lengthdir_x(900, _lea), _k_fin_cy + lengthdir_y(900, _lea),
                        2.2);
      }

      draw_set_color(c_white);
      draw_set_alpha(_lane_a * 0.75);
      draw_line_width(_sh.gap.lane - _k_fin_gap_band_px * 0.5, _k_fin_gap_band_y,
                      _sh.gap.lane + _k_fin_gap_band_px * 0.5, _k_fin_gap_band_y, 2.6);
    }
    var _body = merge_color(_sh.col, c_white, 0.14 + _heat * 0.5);
    var _chr  = clamp(fin_chroma, 0, 1.4) * (1.4 + _lf * 2.2);

    for (var _wi = 0; _wi < _sh.sides; _wi++) {
      var _w   = fin_shell_wall(_sh, _wi);
      var _px  = lengthdir_x(1, _w.ang);
      var _py  = lengthdir_y(1, _w.ang);
      var _bw  = _sh.wall_w * (0.35 + _sol * 0.65) * (1 + _lf * 0.5);

      if (_sol < 0.999) {
        var _tw  = fin_shell_wall(_tgt, _wi);
        var _thr = 1 - _sol;
        var _duty = _k_fin_shell_dash_on + _sol * (1 - _k_fin_shell_dash_on);

        draw_set_color(merge_color(_sh.col, c_white, 0.25 + _sh.arm_p * 0.3));
        var _tsp = fin_shell_gap_span(_sh, _tw);
        for (var _dd = 0; _dd < _k_fin_shell_dashes; _dd++) {
          var _d0 = _dd / _k_fin_shell_dashes;
          var _d1 = _d0 + (_duty / _k_fin_shell_dashes);
          if ((_d0 + _d1) * 0.5 > _tsp[0] && (_d0 + _d1) * 0.5 < _tsp[1]) continue;
          draw_set_alpha(_thr * (0.34 + _sh.arm_p * 0.5) * _shb);
          draw_line_width(lerp(_tw.x1, _tw.x2, _d0), lerp(_tw.y1, _tw.y2, _d0),
                          lerp(_tw.x1, _tw.x2, _d1), lerp(_tw.y1, _tw.y2, _d1),
                          1.6 + _sh.arm_p * 1.6);
        }

        scr_draw_lock_bracket(_tw.cx - _tw.hl, _tw.cy - 19,
                              _tw.cx + _tw.hl, _tw.cy + 19,
                              _sh.col, 0.4 + _sh.arm_p * 0.5,
                              _thr * (0.4 + _sh.arm_p * 0.55) * _shb,
                              14, false, 4, _tw.ang + 90);
      }

      if (_sol > 0.02) {
        var _bsp = fin_shell_gap_span(_sh, _w);
        for (var _bk = 0; _bk < 2; _bk++) {
          var _bf0 = (_bk == 0) ? 0 : _bsp[1];
          var _bf1 = (_bk == 0) ? _bsp[0] : 1;
          if (_bf1 - _bf0 < 0.001) continue;

          var _ax = lerp(_w.x1, _w.x2, _bf0), _ay = lerp(_w.y1, _w.y2, _bf0);
          var _bx = lerp(_w.x1, _w.x2, _bf1), _by = lerp(_w.y1, _w.y2, _bf1);

          draw_set_color(_body);
          draw_set_alpha(_sol * _shb * (0.5 + _heat * 0.42));
          draw_line_width(_ax, _ay, _bx, _by, _bw);

          if (_chr > 0.05) {
            draw_set_color(global.avoid_col_warning);
            draw_set_alpha(_sol * _shb * 0.30);
            draw_line_width(_ax + _px * _chr, _ay + _py * _chr,
                            _bx + _px * _chr, _by + _py * _chr, _bw * 0.5);

            draw_set_color(global.avoid_col_cyan);
            draw_set_alpha(_sol * _shb * 0.30);
            draw_line_width(_ax - _px * _chr, _ay - _py * _chr,
                            _bx - _px * _chr, _by - _py * _chr, _bw * 0.5);
          }

          draw_set_color(c_white);
          draw_set_alpha(_sol * _shb * (0.55 + _heat * 0.45));
          draw_line_width(_ax - _px * _bw * 0.4, _ay - _py * _bw * 0.4,
                          _bx - _px * _bw * 0.4, _by - _py * _bw * 0.4,
                          1.1 + _heat * 1.5);
        }
      }

      var _cap = 4 + _heat * 7 + _sol * 3;
      draw_set_color(merge_color(_sh.col, c_white, 0.5 + _heat * 0.5));
      draw_set_alpha(_shb * (0.4 + _heat * 0.5));
      draw_line_width(_w.x1 - _px * _cap, _w.y1 - _py * _cap,
                      _w.x1 + _px * _cap, _w.y1 + _py * _cap, 1.8);
      draw_line_width(_w.x2 - _px * _cap, _w.y2 - _py * _cap,
                      _w.x2 + _px * _cap, _w.y2 + _py * _cap, 1.8);

      var _bra = _lf * 0.85 + _rg * 0.4;
      if (_bra > 0.01) {
        scr_draw_lock_bracket(_w.cx - _w.hl, _w.cy - 19,
                              _w.cx + _w.hl, _w.cy + 19,
                              _sh.col, 0.4 + _heat * 0.6, min(_bra, 1) * _shb,
                              14, false, 4, _w.ang + 90);
      }

      var _tna = (_sol * 0.55 + _lf * 0.6) * _shb * _k_fin_shell_tendon_max
                 * (0.35 + fin_charge * 0.9);
      if (_tna > 0.012) {
        draw_set_color(merge_color(_sh.col, c_white, 0.3 + _heat * 0.4));
        draw_set_alpha(_tna);
        draw_line_width(_w.cx, _w.cy, _k_fin_cx, _k_fin_cy, 1 + _lf * 1.6);

        for (var _tb = 1; _tb <= 3; _tb++) {
          var _tf = frac(_tb / 4 + _sh.age * 0.014 + _sh.seed * 0.01);
          var _tbx = lerp(_w.cx, _k_fin_cx, _tf);
          var _tby = lerp(_w.cy, _k_fin_cy, _tf);
          draw_set_alpha(_tna * 1.6 * (1 - _tf * 0.5));
          draw_circle(_tbx, _tby, 1.4 + _lf * 1.8, false);
        }
      }
    }
  }

  for (var _kp = 0; _kp < array_length(fin_shell_sparks); _kp++) {
    var _spk = fin_shell_sparks[_kp];
    var _spa = clamp(_spk.life / _spk.max_life, 0, 1);
    var _sln = 2 + point_distance(0, 0, _spk.vx, _spk.vy) * 1.6;
    var _sdr = point_direction(0, 0, _spk.vx, _spk.vy);

    draw_set_color(_spk.col);
    draw_set_alpha(_spa * 0.62);
    draw_line_width(_spk.x, _spk.y,
                    _spk.x - lengthdir_x(_sln, _sdr), _spk.y - lengthdir_y(_sln, _sdr),
                    1.5 + _spk.hot);

    draw_set_color(c_white);
    draw_set_alpha(_spa * _spa * 0.75);
    draw_line_width(_spk.x, _spk.y,
                    _spk.x - lengthdir_x(_sln * 0.35, _sdr),
                    _spk.y - lengthdir_y(_sln * 0.35, _sdr), 1);
  }

  for (var _fc = 0; _fc < array_length(bass_rings); _fc++) {
    var _fcr = bass_rings[_fc];
    var _fck = _fcr.idx;
    var _striking = (_fcr.state == "strike");

    if (!_striking) {
      var _step_out = 360 / _k_fin_orb_count[_fck];

      draw_set_color(_fn_col);
      draw_set_alpha(0.28 + fin_charge * 0.32 + fin_lock_flash * 0.3);

      for (var _fci = 0; _fci < array_length(_fcr.orbs) - 1; _fci++) {
        var _o1 = _fcr.orbs[_fci];
        var _o2 = _fcr.orbs[_fci + 1];
        if (!instance_exists(_o1) || !instance_exists(_o2)) continue;
        if (_o1.layer_mult != _o2.layer_mult) continue;
        if (abs(angle_difference(_o2.ring_angle, _o1.ring_angle)) > _step_out * 1.6) continue;
        draw_line_width(_o1.x, _o1.y, _o2.x, _o2.y, 1 + fin_charge * 1.6);
      }

      var _gapn = _k_fin_gap_count[_fck];
      var _gapw = _k_fin_gap_width[_fck];
      var _gapa = 0.35 + fin_gap_glow * 0.5;

      var _gsc = clamp(_fcr.radius / 150, 1, 2.2);

      for (var _fg2 = 0; _fg2 < _gapn; _fg2++) {
        var _gb = _fcr.gap_now + _fg2 * (360 / _gapn);

        for (var _side = -1; _side <= 1; _side += 2) {
          var _ea = _gb + _side * _gapw * 0.5;
          var _ex = _fcr.center_x + lengthdir_x(_fcr.radius, _ea);
          var _ey = _fcr.center_y + lengthdir_y(_fcr.radius, _ea);
          var _eo = _ea + _side * 90;

          draw_set_color(_fn_hot);
          draw_set_alpha(_gapa);
          draw_line_width(_ex, _ey,
                          _ex + lengthdir_x((16 + fin_gap_glow * 12) * _gsc, _eo),
                          _ey + lengthdir_y((16 + fin_gap_glow * 12) * _gsc, _eo), 2 * _gsc);
          draw_line_width(_ex - lengthdir_x(11 * _gsc, _ea), _ey - lengthdir_y(11 * _gsc, _ea),
                          _ex + lengthdir_x(11 * _gsc, _ea), _ey + lengthdir_y(11 * _gsc, _ea), 1.5 * _gsc);
        }

        draw_set_color(_fn_hot);
        for (var _ld = 0; _ld < 7; _ld++) {
          var _l0 = _fcr.radius * (0.42 + _ld * 0.115);
          var _l1 = _l0 + _fcr.radius * 0.06;
          draw_set_alpha(_gapa * 0.4 * (1 - _ld / 8));
          draw_line_width(_fcr.center_x + lengthdir_x(_l0, _gb), _fcr.center_y + lengthdir_y(_l0, _gb),
                          _fcr.center_x + lengthdir_x(_l1, _gb), _fcr.center_y + lengthdir_y(_l1, _gb), 2);
        }
      }
    }

    if (_fcr.state != "closing") {
      var _lr = 6 + fin_charge * 7;
      draw_set_color(_fn_hot);
      draw_set_alpha(0.3 + fin_charge * 0.4);
      draw_circle(_fcr.center_x, _fcr.center_y, _lr, true);
      draw_line_width(_fcr.center_x - _lr * 2, _fcr.center_y, _fcr.center_x - _lr, _fcr.center_y, 1.5);
      draw_line_width(_fcr.center_x + _lr, _fcr.center_y, _fcr.center_x + _lr * 2, _fcr.center_y, 1.5);
      draw_line_width(_fcr.center_x, _fcr.center_y - _lr * 2, _fcr.center_x, _fcr.center_y - _lr, 1.5);
      draw_line_width(_fcr.center_x, _fcr.center_y + _lr, _fcr.center_x, _fcr.center_y + _lr * 2, 1.5);
    }
  }

  for (var _bp = 0; _bp < 2; _bp++) {
    var _bsrc = (_bp == 0) ? bass_rings : orbit_rings;

    for (var _bq = 0; _bq < array_length(_bsrc); _bq++) {
      var _brg = _bsrc[_bq];

      for (var _bo = 0; _bo < array_length(_brg.orbs); _bo++) {
        var _bb = _brg.orbs[_bo];
        if (!instance_exists(_bb)) continue;

        var _bn = array_length(_bb.spear_trail);
        var _bcol = merge_color(_bb.image_blend, c_white, _bb.flash * 0.5);

        if (_bn > 1) {
          var _ppx = _bb.spear_trail[0].x;
          var _ppy = _bb.spear_trail[0].y;

          for (var _bi = 1; _bi < _bn; _bi++) {
            var _bpt = _bb.spear_trail[_bi];
            var _bf = _bi / max(_bn - 1, 1);
            var _bw = (0.6 + _bpt.w * 1.5) * _bf;

            draw_set_color(_bcol);
            draw_set_alpha(_bf * _bf * 0.45);
            draw_line_width(_ppx, _ppy, _bpt.x, _bpt.y, _bw * 2.4);

            draw_set_color(c_white);
            draw_set_alpha(_bf * _bf * 0.75);
            draw_line_width(_ppx, _ppy, _bpt.x, _bpt.y, _bw * 0.8);

            _ppx = _bpt.x;
            _ppy = _bpt.y;
          }

          draw_set_color(c_white);
          draw_set_alpha(0.85);
          draw_line_width(_ppx, _ppy, _bb.x, _bb.y, 1.6 + _bb.heat * 1.4);
        }

        var _hl = 3 + _bb.image_xscale * 1.6;
        var _ha = _bb.image_angle;
        draw_set_color(merge_color(_bb.gap_edge ? _k_fin_orb_hot : _k_fin_orb_color, c_white,
                                   0.35 + _bb.flash * 0.5));
        draw_set_alpha(0.55 + _bb.heat * 0.35);
        draw_line_width(_bb.x - lengthdir_x(_hl, _ha), _bb.y - lengthdir_y(_hl, _ha),
                        _bb.x + lengthdir_x(_hl * 0.5, _ha), _bb.y + lengthdir_y(_hl * 0.5, _ha),
                        3.2 + _bb.heat * 1.4);

        draw_set_color(c_white);
        draw_set_alpha(0.75 + _bb.flash * 0.25);
        draw_line_width(_bb.x - lengthdir_x(_hl * 0.6, _ha), _bb.y - lengthdir_y(_hl * 0.6, _ha),
                        _bb.x + lengthdir_x(_hl * 0.4, _ha), _bb.y + lengthdir_y(_hl * 0.4, _ha),
                        1.4 + _bb.heat * 0.8);
      }
    }
  }

  if (fin_implode > 0.01) {
    var _ir = lerp(300, 26, fin_implode) + fin_heartbeat * 26;

    draw_set_color(merge_color(_k_fin_orb_color, c_white, 0.3 + fin_heartbeat * 0.5));
    draw_set_alpha(fin_implode * (0.25 + fin_heartbeat * 0.5));
    draw_circle(_k_fin_cx, _k_fin_cy, _ir, true);
    draw_circle(_k_fin_cx, _k_fin_cy, _ir * 0.62, true);

    draw_set_color(_fn_hot);
    for (var _it = 0; _it < 16; _it++) {
      var _ita = _it * 22.5 + fin_implode * 40;
      var _it0 = _ir * 1.35;
      var _it1 = _ir * 1.05;
      draw_set_alpha(fin_implode * 0.4);
      draw_line_width(_k_fin_cx + lengthdir_x(_it0, _ita), _k_fin_cy + lengthdir_y(_it0, _ita),
                      _k_fin_cx + lengthdir_x(_it1, _ita), _k_fin_cy + lengthdir_y(_it1, _ita), 1.8);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

// ============================================================================
// FINAL CUT — THE STROKE
// ----------------------------------------------------------------------------
// ============================================================================
if (fin_blade_p > 0 && (fin_blade_p < 1 || fin_blade_glow > 0.01)) {
  var _bl    = fin_cut_axis();
  var _bang  = _bl.ang;
  var _bhalf = _bl.half;

  var _bx0 = _k_fin_cx - lengthdir_x(_bhalf, _bang);
  var _by0 = _k_fin_cy - lengthdir_y(_bhalf, _bang);
  var _bx1 = _k_fin_cx + lengthdir_x(_bhalf, _bang);
  var _by1 = _k_fin_cy + lengthdir_y(_bhalf, _bang);

  var _bhx = lerp(_bx0, _bx1, fin_blade_p);
  var _bhy = lerp(_by0, _by1, fin_blade_p);

  var _blanded = (fin_blade_p >= 1);
  var _bmain   = _blanded ? fin_blade_glow : 1;
  var _bwide   = _blanded ? power(fin_blade_glow, 0.7) * 0.55 : 1;

  var _bpx  = lengthdir_x(1, _bang + 90);
  var _bpy  = lengthdir_y(1, _bang + 90);
  var _bchr = 2.2 + fin_chroma * 2.6;

  gpu_set_blendmode(bm_add);

  var _bseg = 12;
  for (var _bi = 0; _bi < _bseg; _bi++) {
    var _bf0 = _bi / _bseg;
    var _bf1 = (_bi + 1) / _bseg;

    var _bax = lerp(_bx0, _bhx, _bf0), _bay = lerp(_by0, _bhy, _bf0);
    var _bbx = lerp(_bx0, _bhx, _bf1), _bby = lerp(_by0, _bhy, _bf1);

    // while it is travelling the stroke fades out behind the head, so it reads
    var _bt = _blanded ? 1 : (0.12 + power(_bf1, 1.6) * 0.88);
    var _ba = _bt * _bmain;
    if (_ba <= 0.012) continue;

    draw_set_color(global.avoid_col_blood);
    draw_set_alpha(_ba * 0.30 * _bwide);
    draw_line_width(_bax, _bay, _bbx, _bby, 26 * _bwide);

    draw_set_color(global.avoid_col_warning);
    draw_set_alpha(_ba * 0.44);
    draw_line_width(_bax, _bay, _bbx, _bby, 8.5 * _bwide);

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_ba * 0.30);
    draw_line_width(_bax + _bpx * _bchr, _bay + _bpy * _bchr,
                    _bbx + _bpx * _bchr, _bby + _bpy * _bchr, 2.6);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_ba * 0.30);
    draw_line_width(_bax - _bpx * _bchr, _bay - _bpy * _bchr,
                    _bbx - _bpx * _bchr, _bby - _bpy * _bchr, 2.6);

    draw_set_color(c_white);
    draw_set_alpha(_ba * 0.95);
    draw_line_width(_bax, _bay, _bbx, _bby, 1.8 + _bt * 1.4);
  }

  if (!_blanded) {
    draw_set_color(global.avoid_col_hot);
    draw_set_alpha(0.50);
    draw_circle(_bhx, _bhy, 15, false);
    draw_set_color(c_white);
    draw_set_alpha(0.95);
    draw_circle(_bhx, _bhy, 5.5, false);

    for (var _bs = 0; _bs < 4; _bs++) {
      var _bsa = _bang + choose(-1, 1) * random_range(6, 34);
      var _bsl = random_range(40, 150);
      draw_set_color(merge_color(global.avoid_col_hot, c_white, random(1)));
      draw_set_alpha(random_range(0.30, 0.75));
      draw_line_width(_bhx, _bhy,
                      _bhx + lengthdir_x(_bsl, _bsa), _bhy + lengthdir_y(_bsl, _bsa),
                      random_range(1, 2.6));
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}
