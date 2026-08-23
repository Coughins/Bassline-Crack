scr_apply_game_viewport();

var _app_surface_w = surface_get_width(application_surface);
var _app_surface_h = surface_get_height(application_surface);

scene_snapshot = surface_ensure(scene_snapshot, _app_surface_w, _app_surface_h);
surface_copy(scene_snapshot, 0, 0, application_surface);

bolt_surface = surface_ensure(bolt_surface, _app_surface_w, _app_surface_h);

surface_set_target(bolt_surface);
draw_clear_alpha(0, 0);

lightning_bloom_boost = 0;

for (var i = 0; i < array_length(ember_edge_glows); i++) {
  var _eg = ember_edge_glows[i];
  if (!instance_exists(_eg.bullet_id)) continue;

  var _fade = _eg.fading ? clamp(_eg.life / 12, 0, 1) : 1;
  var _range = (_eg.start_dist > 0) ? _eg.start_dist : _k_incoming_warn_range;
  var _raw = clamp(1 - (_eg.mark_dist / _range), 0, 1);
  var _strength = max(power(_raw, 1.6), lerp(_k_incoming_warn_floor, 1, power(_raw, 1.15))) * _fade;
  if (_strength <= 0.01) continue;

  var _draw_x = _eg.mark_x;
  var _draw_y = _eg.mark_y;
  var _pulse = 0.85 + 0.15 * sin(current_time * 0.02 + _draw_x + _draw_y);
  var _warn_col = merge_color(make_color_rgb(255, 90, 40), c_white, _strength * 0.7);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _warn_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _warn_uvs[0], _warn_uvs[1], _warn_uvs[2], _warn_uvs[3]);

  shader_set_uniform_f(global.u_glow_color, color_get_red(_warn_col) / 255, color_get_green(_warn_col) / 255,
                       color_get_blue(_warn_col) / 255);
  shader_set_uniform_f(global.u_glow_intensity, (0.7 + _strength * 1.5) * _pulse);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);
  draw_sprite_ext(spr_glow_blob, 0, _draw_x, _draw_y, 0.3 + _strength * 0.5, 0.3 + _strength * 0.5, 0, c_white, 1);

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, _strength * 1.8 * _pulse);
  shader_set_uniform_f(global.u_glow_falloff, 2.4);
  draw_sprite_ext(spr_glow_blob, 0, _draw_x, _draw_y, 0.1 + _strength * 0.14, 0.1 + _strength * 0.14, 0, c_white, 1);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
var _k_ember_arc_color = make_color_rgb(255, 90, 40);
var _k_ember_hot_color = make_color_rgb(255, 190, 110);
var _ember_center_x = 400, _ember_center_y = 304;

if (t >= 2085 && t < 2106) {
  var _coil_p_draw = clamp((t - 2085) / (2106 - 2085), 0, 1);
  var _coil_ring_color = merge_color(_k_ember_arc_color, c_white, _coil_p_draw * 0.5);

  var _coil_ring_r = lerp(230, 55, _coil_p_draw);
  scr_draw_lightning_arc(_ember_center_x, _ember_center_y, _coil_ring_r, 0, 360, 1, 1, _coil_ring_color, false);
  scr_draw_lightning_arc(_ember_center_x, _ember_center_y, _coil_ring_r * 0.7, 180, 540, 1, 1, _coil_ring_color, false);
}

if (array_length(ember_coil_arcs) > 0) {
  var _coil_orig_x = x, _coil_orig_y = y;
  var _coil_p_draw2 = clamp((t - 2085) / (2106 - 2085), 0, 1);
  var _coil_reach = lerp(260, 90, _coil_p_draw2);
  for (var _cai = 0; _cai < array_length(ember_coil_arcs); _cai++) {
    var _ca = ember_coil_arcs[_cai];
    var _ca_reach = variable_struct_exists(_ca, "reach") ? _ca.reach : _coil_reach;
    x = _ember_center_x + lengthdir_x(_ca_reach, _ca.ang);
    y = _ember_center_y + lengthdir_y(_ca_reach, _ca.ang);
    scr_draw_lightning_bolt(_ember_center_x, _ember_center_y, _ca.life, _ca.life_max, 5, false,
                            _k_ember_arc_color, 0.05, 5, _ca.bolt_id, 1, false);
  }
  x = _coil_orig_x;
  y = _coil_orig_y;
}

if (array_length(ember_burst_arcs) > 0) {
  var _burst_orig_x = x, _burst_orig_y = y;
  x = _ember_center_x;
  y = _ember_center_y;
  for (var _bai = 0; _bai < array_length(ember_burst_arcs); _bai++) {
    var _ba = ember_burst_arcs[_bai];
    var _btx = _ember_center_x + lengthdir_x(280, _ba.ang);
    var _bty = _ember_center_y + lengthdir_y(280, _ba.ang);
    scr_draw_lightning_bolt(_btx, _bty, _ba.life, _ba.life_max, 6, true,
                            _k_ember_hot_color, 0.08, 6, _ba.bolt_id, 1, false);
  }
  x = _burst_orig_x;
  y = _burst_orig_y;
}

if (array_length(storm_discharge_arcs) > 0) {
  var _sd_orig_x = x, _sd_orig_y = y;
  x = storm_orb_x;
  y = storm_orb_y;
  for (var _sdi = 0; _sdi < array_length(storm_discharge_arcs); _sdi++) {
    var _sd2 = storm_discharge_arcs[_sdi];
    scr_draw_lightning_bolt(_sd2.tx, _sd2.ty, _sd2.life, _sd2.life_max, 7, true,
                            merge_color(global.lightning_color, c_white, 0.35), 0.09, 7,
                            _sd2.bolt_id, 1, false);
  }
  x = _sd_orig_x;
  y = _sd_orig_y;
}

if (t >= 2252 && t < 2270) {
  var _fin_p = clamp((t - 2252) / (2270 - 2252), 0, 1);
  var _fin_ring_color = merge_color(finale_lightning_col, c_white, _fin_p * 0.6);

  var _fin_ring_r = lerp(240, 50, _fin_p);
  scr_draw_lightning_arc(400, 304, _fin_ring_r, 0, 360, 1, 1, _fin_ring_color, false);
  scr_draw_lightning_arc(400, 304, _fin_ring_r * 0.68, 180, 540, 1, 1, _fin_ring_color, false);
}

if (array_length(finale_coil_arcs) > 0) {
  var _fin_orig_x = x, _fin_orig_y = y;
  var _fin_p2 = clamp((t - 2252) / (2270 - 2252), 0, 1);
  var _fin_reach = lerp(270, 80, _fin_p2);
  for (var _fai = 0; _fai < array_length(finale_coil_arcs); _fai++) {
    var _fa = finale_coil_arcs[_fai];
    x = 400 + lengthdir_x(_fin_reach, _fa.ang);
    y = 304 + lengthdir_y(_fin_reach, _fa.ang);
    scr_draw_lightning_bolt(400, 304, _fa.life, _fa.life_max, 5, false,
                            finale_lightning_col, 0.08, 5, _fa.bolt_id, 1, false);
  }
  x = _fin_orig_x;
  y = _fin_orig_y;
}

if (er_lift_active || array_length(er_lift_sparks) > 0 || array_length(er_lift_lavafalls) > 0 ||
    array_length(er_lift_bolts) > 0 || array_length(er_lift_shockwaves) > 0) {
  var _ml_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _ml_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _ml_cx = oCameraController.current_cam_x;
  var _ml_cy = oCameraController.current_cam_y;
  var _ml_top_g = (er_lift_top_y - _ml_cy) * _ml_sy;
  var _ml_bot_g = (er_lift_top_y + _k_er_lift_body_h - _ml_cy) * _ml_sy;
  var _ml_heat = clamp(er_lift_heat + er_lift_hit_flash * 0.55 + er_lift_lock_flash * 0.8, 0, 1);
  var _ml_despawn_p = er_lift_despawning
                    ? clamp(er_lift_despawn_timer / _k_er_lift_despawn_duration, 0, 1)
                    : 0;
  var _ml_despawn_a = er_lift_despawning ? power(1 - _ml_despawn_p, 0.65) : 0;
  var _ml_col = merge_color(_k_er_col_cyan, _k_er_col_white, _ml_heat * 0.65);

  gpu_set_blendmode(bm_add);

  if (t >= _k_er_lift_charge_t && t < _k_er_lift_beats[0]) {
    var _charge_p2 = clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_beats[0] - _k_er_lift_charge_t, 1), 0, 1);
    var _base_y_g = (_k_er_floor_base_y - _ml_cy) * _ml_sy;
    draw_set_color(merge_color(_k_er_col_cyan, c_white, _charge_p2 * 0.45));
    for (var _wb = 0; _wb < 3; _wb++) {
      draw_set_alpha((0.012 + _charge_p2 * 0.035) * (1 - _wb / 3));
      draw_rectangle(0, _base_y_g - (1 + _wb * 2) * _ml_sy,
                     oCameraController.base_view_w, _base_y_g + (3 + _wb * 4) * _ml_sy, false);
    }
    draw_set_alpha(0.10 + _charge_p2 * 0.18);
    draw_line_width(0, _base_y_g, oCameraController.base_view_w, _base_y_g, (2 + _charge_p2 * 4) * _ml_sy);
  }

  draw_set_color(_ml_col);
  for (var _gl = 0; _gl < 3; _gl++) {
    var _ga = (0.010 + _ml_heat * 0.018) * (1 - _gl / 3);
    draw_set_alpha(_ga);
    draw_rectangle(0, _ml_top_g - (1 + _gl * 2) * _ml_sy,
                   oCameraController.base_view_w, _ml_top_g + (5 + _gl * 5) * _ml_sy, false);
  }
  draw_set_color(c_white);
  draw_set_alpha((er_lift_hit_flash + er_lift_lock_flash) * 0.20);
  draw_line_width(0, _ml_top_g - 1 * _ml_sy, oCameraController.base_view_w, _ml_top_g - 1 * _ml_sy, 2 * _ml_sy);

  if (er_lift_active) {
    var _rail_phase = er_lift_charge + er_lift_phase_pulse * 0.35;
    for (var _lr = 0; _lr < 8; _lr++) {
      var _fx = (_lr + 0.5) / 8;
      var _gx = _fx * oCameraController.base_view_w + sin(er_lift_seed + _lr * 1.8 + t * 0.08) * 8 * _ml_sx;
      var _rail_col = (_lr mod 2 == 0) ? _k_er_col_cyan : _k_er_col_warning;
      draw_set_color(_rail_col);
      draw_set_alpha((0.012 + _ml_heat * 0.025 + er_lift_rail_alpha * 0.035) * (0.8 + _rail_phase * 0.5));
      draw_line_width(_gx, _ml_top_g - (30 + _rail_phase * 60) * _ml_sy,
                      _gx, _ml_bot_g + (24 + _rail_phase * 36) * _ml_sy,
                      (2 + _rail_phase * 3.5) * _ml_sx);
      draw_set_color(c_white);
      draw_set_alpha((er_lift_hit_flash + er_lift_lock_flash) * 0.07);
      draw_line_width(_gx, _ml_top_g - 18 * _ml_sy, _gx, _ml_top_g + 16 * _ml_sy,
                      max(1, 1.4 * _ml_sx));
    }
  }

  if (er_lift_despawning || array_length(er_lift_despawn_cracks) > 0) {
    draw_set_color(merge_color(_k_er_col_hot, c_white, 0.45 + er_lift_despawn_flash * 0.4));
    draw_set_alpha(0.10 * _ml_despawn_a + er_lift_despawn_flash * 0.14);
    draw_line_width(0, _ml_top_g, oCameraController.base_view_w, _ml_top_g,
                    (5 + _ml_despawn_a * 10) * _ml_sy);

    draw_set_color(_k_er_col_cyan);
    for (var _dg = 0; _dg < 3; _dg++) {
      var _fade = (1 - _dg / 3) * _ml_despawn_a;
      draw_set_alpha(_fade * 0.025);
      draw_rectangle(0, _ml_top_g + _dg * 5 * _ml_sy,
                     oCameraController.base_view_w,
                     _ml_top_g + (18 + _dg * 8) * _ml_sy, false);
    }

    for (var _dc = 0; _dc < array_length(er_lift_despawn_cracks); _dc++) {
      var _cr = er_lift_despawn_cracks[_dc];
      if (_cr.delay <= 0) {
        var _ca = clamp(_cr.life / _cr.life_max, 0, 1);
        var _gx = (_cr.x - _ml_cx) * _ml_sx;
        var _gy = (er_lift_top_y + 3 + sin(_cr.seed + t * 0.08) * 2 - _ml_cy) * _ml_sy;
        var _tail = _cr.w * (0.55 + (1 - _ca) * 0.7) * _ml_sx;
        var _col = merge_color(_k_er_col_hot, c_white, _cr.hot * 0.6);

        draw_set_color(_col);
        draw_set_alpha(_ca * _ca * (0.09 + _cr.hot * 0.12));
        draw_line_width(_gx - _tail * 0.5, _gy, _gx + _tail * 0.5, _gy,
                        (2 + _cr.hot * 3) * _ml_sy);

        draw_primitive_begin(pr_trianglestrip);
        for (var _cs = 0; _cs <= 4; _cs++) {
          var _cf = _cs / 4;
          var _x = lerp(_gx - _tail * 0.5, _gx + _tail * 0.5, _cf);
          var _tap = sin(_cf * pi);
          draw_vertex_colour(_x, _gy, _col, _ca * 0.09 * _tap);
          draw_vertex_colour(_x, _gy + (16 + _ml_despawn_p * 34) * _ml_sy * _tap, _col, 0);
        }
        draw_primitive_end();
      }
    }
  }

  for (var _vi = 0; _vi < array_length(er_lift_vents); _vi++) {
    var _ve = er_lift_vents[_vi];
    var _va = clamp(_ve.life / _ve.life_max, 0, 1);
    var _gx1 = (_ve.x - _ve.w * 0.5 - _ml_cx) * _ml_sx;
    var _gx2 = (_ve.x + _ve.w * 0.5 - _ml_cx) * _ml_sx;
    var _spill = (16 + _ve.hot * 34) * _ml_sy;
    var _vcol = merge_color(_k_er_col_cyan, c_white, _ve.hot);
    draw_set_color(_vcol);
    draw_set_alpha(_va * (0.10 + _ve.hot * 0.18));
    draw_line_width(_gx1, _ml_top_g + 2 * _ml_sy, _gx2, _ml_top_g + 2 * _ml_sy, (3 + _ve.hot * 5) * _ml_sy);
    draw_primitive_begin(pr_trianglestrip);
    for (var _vs = 0; _vs <= 5; _vs++) {
      var _vf = _vs / 5;
      var _vx = lerp(_gx1, _gx2, _vf);
      var _tap = sin(_vf * pi);
      draw_vertex_colour(_vx, _ml_top_g, _vcol, _va * 0.14 * _tap);
      draw_vertex_colour(_vx, _ml_top_g - _spill * (0.35 + _tap * 0.65), _vcol, 0);
    }
    draw_primitive_end();

  }

  for (var _wi = 0; _wi < array_length(er_lift_shockwaves); _wi++) {
    var _lw = er_lift_shockwaves[_wi];
    var _wy = (_lw.y - _ml_cy) * _ml_sy;
    var _wa = clamp(_lw.alpha, 0, 1);
    draw_set_color(_lw.col);
    draw_set_alpha(_wa * 0.18);
    var _wr = _lw.radius * _ml_sx;
    var _wc = oCameraController.base_view_w * 0.5;
    draw_ellipse(_wc - _wr, _wy - _wr * 0.08,
                 _wc + _wr, _wy + _wr * 0.08, true);
    draw_set_color(c_white);
    draw_set_alpha(_wa * 0.08);
    draw_ellipse(_wc - _wr * 0.7, _wy - _wr * 0.04,
                 _wc + _wr * 0.7, _wy + _wr * 0.04, true);
  }

  for (var _fi = 0; _fi < array_length(er_lift_lavafalls); _fi++) {
    var _lf = er_lift_lavafalls[_fi];
    var _fa = clamp(_lf.life / _lf.life_max, 0, 1);
    var _fx = (_lf.x - _ml_cx) * _ml_sx;
    var _fy = (_lf.y - _ml_cy) * _ml_sy;
    var _fbase = (frac(sin(_lf.seed * 7.1) * 43758.5453) < 0.5) ? _k_er_col_cyan : _k_er_col_warning;
    var _fcol = merge_color(_fbase, c_white, _lf.hot * 0.7);
    draw_set_color(_fcol);
    draw_set_alpha(_fa * (0.16 + _lf.hot * 0.18));
    draw_line_width(_fx, _fy, _fx + sin(_lf.seed + t * 0.08) * 7 * _ml_sx,
                    _fy + _lf.len * _ml_sy, _lf.w * _ml_sx);
    draw_set_color((_fbase == _k_er_col_cyan) ? _k_er_col_warning : _k_er_col_cyan);
    draw_set_alpha(_fa * 0.10);
    draw_line_width(_fx + 2 * _ml_sx, _fy, _fx + 2 * _ml_sx + sin(_lf.seed + t * 0.08) * 5 * _ml_sx,
                    _fy + _lf.len * 0.78 * _ml_sy, max(1, _lf.w * 0.38) * _ml_sx);
    draw_set_color(c_white);
    draw_set_alpha(_fa * 0.14);
    draw_line_width(_fx, _fy, _fx, _fy + _lf.len * 0.35 * _ml_sy, max(1, _lf.w * 0.35) * _ml_sx);

    var _packet_count = 2 + floor(_lf.hot * 3);
    for (var _pkt = 0; _pkt < _packet_count; _pkt++) {
      var _pf = frac(_lf.seed * 0.11 + _pkt * 0.29 + t * 0.035);
      var _py = _fy + _lf.len * _pf * _ml_sy;
      var _pw = (2.5 + _lf.hot * 5) * _ml_sx;
      draw_set_color(merge_color(_fcol, c_white, _pf));
      draw_set_alpha(_fa * (1 - _pf * 0.4) * 0.18);
      draw_rectangle(_fx - _pw, _py - 1 * _ml_sy, _fx + _pw, _py + 1 * _ml_sy, false);
    }
  }

  for (var _si = 0; _si < array_length(er_lift_sparks); _si++) {
    var _sp = er_lift_sparks[_si];
    var _sa = clamp(_sp.life / _sp.life_max, 0, 1);
    draw_set_color(_sp.col);
    draw_set_alpha(_sa);
    draw_circle((_sp.x - _ml_cx) * _ml_sx, (_sp.y - _ml_cy) * _ml_sy, _sp.size * _sa * _ml_sx, false);
  }
  for (var _pi = 0; _pi < array_length(er_lift_plumes); _pi++) {
    var _pl = er_lift_plumes[_pi];
    var _pa = clamp(_pl.life / _pl.life_max, 0, 1);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, _pl.hot * 0.5));
    draw_set_alpha(_pa * 0.12);
    draw_circle((_pl.x - _ml_cx) * _ml_sx, (_pl.y - _ml_cy) * _ml_sy, _pl.size * (1 + (1 - _pa) * 2) * _ml_sx, false);
  }

  for (var _bi = 0; _bi < array_length(er_lift_bolts); _bi++) {
    var _bo = er_lift_bolts[_bi];
    var _ba = clamp(_bo.life / _bo.life_max, 0, 1);
    scr_draw_energy_bolt((_bo.x1 - _ml_cx) * _ml_sx, (_bo.y1 - _ml_cy) * _ml_sy,
                         (_bo.x2 - _ml_cx) * _ml_sx, (_bo.y2 - _ml_cy) * _ml_sy,
                         _ba * (0.35 + _bo.hot * 0.55),
                         merge_color(finale_lightning_col, _k_er_col_white, _bo.hot),
                         scr_bolt_offsets(5, 5 + _bo.hot * 10),
                         1.0 + _bo.hot,
                         0.7);
  }

  for (var _ei = 0; _ei < array_length(er_lift_edge_flares); _ei++) {
    var _ef = er_lift_edge_flares[_ei];
    var _ea = clamp(_ef.life / _ef.life_max, 0, 1);
    var _ex = (_ef.x - _ml_cx) * _ml_sx;
    draw_set_color(merge_color(_k_er_col_hot, c_white, _ef.hot));
    draw_set_alpha(_ea * 0.22);
    draw_line_width(_ex, _ml_top_g - 32 * _ml_sy, _ex, _ml_bot_g + 54 * _ml_sy, (8 + _ef.hot * 12) * _ml_sx);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (t >= _k_er_lift_beats[0] - _k_hc_front_telegraph &&
    t <= _k_er_lift_beats[3] + _k_hc_front_life) {
  var _hc_gsx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _hc_gsy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _hc_gcx = oCameraController.current_cam_x;
  var _hc_gcy = oCameraController.current_cam_y;
  var _hc_cxg = (_k_hc_front_cx - _hc_gcx) * _hc_gsx;
  var _hc_cyg = (_k_hc_front_cy - _hc_gcy) * _hc_gsy;
  var _hc_deck_g = (er_lift_top_y - _hc_gcy) * _hc_gsy;
  var _hc_fronts = array_length(_k_er_lift_beats);

  gpu_set_blendmode(bm_add);

  for (var _hc_gp = 0; _hc_gp < _hc_fronts; _hc_gp++) {
    var _hc_gbeat = _k_er_lift_beats[_hc_gp];
    var _hc_gage = t - _hc_gbeat;
    var _hc_gpre = clamp((t - (_hc_gbeat - _k_hc_front_telegraph)) / max(_k_hc_front_telegraph, 1), 0, 1);
    var _hc_gtele = (_hc_gage < 0 && _hc_gpre > 0);
    var _hc_gactive = (_hc_gage >= 0 && _hc_gage < _k_hc_front_life);
    if (!_hc_gtele && !_hc_gactive) continue;

    var _hc_gpct = _hc_gactive ? clamp(_hc_gage / max(_k_hc_front_life, 1), 0, 1) : 0;
    var _hc_gease = 1 - power(1 - _hc_gpct, 2.2);
    var _hc_grmax = _k_hc_front_radius1[min(_hc_gp, array_length(_k_hc_front_radius1) - 1)];
    var _hc_gr = _hc_gactive
               ? lerp(_k_hc_front_radius0, _hc_grmax, _hc_gease)
               : _k_hc_front_radius0 * (0.80 + _hc_gpre * 0.18);
    var _hc_gfade = _hc_gactive ? power(1 - _hc_gpct, 0.58) : _hc_gpre * 0.34;
    var _hc_gheat = _hc_gactive ? clamp(1 - abs(_hc_gpct - 0.24) / 0.45, 0, 1) : 0;
    var _hc_gstart = _hc_gp * 90 - (_k_hc_front_arc_span - 180) * 0.5;
    var _hc_gseq = _hc_gactive
                 ? _hc_gpct * (_k_hc_front_segments + 8)
                 : _hc_gpre * (_k_hc_front_segments * 0.75);
    var _hc_gw = _k_hc_front_width[min(_hc_gp, array_length(_k_hc_front_width) - 1)] * _hc_gsx;

    for (var _hc_gs = 0; _hc_gs < _k_hc_front_segments; _hc_gs++) {
      var _hc_gh = frac(sin((_hc_gp + 9) * 31.73 + _hc_gs * 13.17) * 43758.5453);
      if (_hc_gh < 0.14 && _hc_gactive) continue;
      var _hc_ge = clamp((_hc_gseq - _hc_gs) / 3.7, 0, 1);
      if (_hc_gtele) _hc_ge *= 0.34;
      if (_hc_ge <= 0.01) continue;

      var _hc_gf0 = _hc_gs / _k_hc_front_segments;
      var _hc_gf1 = min(1, (_hc_gs + 0.70 + _hc_gh * 0.16) / _k_hc_front_segments);
      var _hc_ga0 = _hc_gstart + _k_hc_front_arc_span * _hc_gf0;
      var _hc_ga1 = _hc_gstart + _k_hc_front_arc_span * _hc_gf1;
      var _hc_gr0 = (_hc_gr + (_hc_gh - 0.5) * 6 * (0.3 + _hc_gpct)) * _hc_gsx;
      var _hc_gr1 = (_hc_gr + (frac(sin((_hc_gp + 10) * 57.1 + _hc_gs * 18.2) * 43758.5453) - 0.5) * 6 * (0.3 + _hc_gpct)) * _hc_gsx;
      var _hc_x0 = _hc_cxg + lengthdir_x(_hc_gr0, _hc_ga0);
      var _hc_y0 = _hc_cyg + lengthdir_y(_hc_gr0, _hc_ga0);
      var _hc_x1 = _hc_cxg + lengthdir_x(_hc_gr1, _hc_ga1);
      var _hc_y1 = _hc_cyg + lengthdir_y(_hc_gr1, _hc_ga1);
      var _hc_ga = _hc_gfade * _hc_ge;

      draw_set_color(merge_color(global.avoid_col_warning, global.avoid_col_hot, 0.36 + _hc_gheat * 0.42));
      draw_set_alpha(_hc_ga * (0.18 + _hc_gheat * 0.22));
      draw_line_width(_hc_x0, _hc_y0, _hc_x1, _hc_y1, max(1.5, _hc_gw * 0.16));
      draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.30 + _hc_gheat * 0.32));
      draw_set_alpha(_hc_ga * (0.08 + _hc_gheat * 0.14));
      draw_line_width(_hc_x0, _hc_y0, _hc_x1, _hc_y1, max(1, _hc_gsx * (1.0 + _hc_gheat)));
    }

    var _hc_source_after = (_hc_gage >= 0)
                         ? power(1 - clamp(_hc_gage / max(_k_hc_front_scar_life, 1), 0, 1), 0.8)
                         : 0;
    var _hc_source = max((_hc_gage < 0) ? power(_hc_gpre, 2) * 0.45 : 0, _hc_source_after * 0.34);
    if (_hc_source > 0.02) {
      for (var _hc_sl = 0; _hc_sl < _k_hc_front_socket_count; _hc_sl++) {
        var _hc_slf = (_hc_sl + 0.5) / _k_hc_front_socket_count;
        var _hc_slgx = (lerp(76, room_width - 76, _hc_slf) - _hc_gcx) * _hc_gsx;
        var _hc_sla = _hc_source * (0.68 + 0.32 * sin(t * 0.16 + _hc_sl * 1.9 + _hc_gp));
        draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.18 + _hc_gp * 0.08));
        draw_set_alpha(0.065 * _hc_sla);
        draw_line_width(_hc_slgx - 20 * _hc_gsx, _hc_deck_g,
                        _hc_slgx + 20 * _hc_gsx, _hc_deck_g,
                        max(1, 3 * _hc_gsy));
        draw_set_color(global.avoid_col_ember);
        draw_set_alpha(0.035 * _hc_sla);
        draw_line_width(_hc_slgx, _hc_deck_g - 18 * _hc_gsy,
                        _hc_slgx, _hc_deck_g + 16 * _hc_gsy,
                        max(1, 2 * _hc_gsx));
      }
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

gpu_set_blendmode(bm_normal);

if (array_length(kdash_arcs) > 0 || array_length(jr_arcs) > 0 ||
    array_length(jr_reactor_streams) > 0 || array_length(jr_scan_sweeps) > 0 ||
    array_length(jr_lock_frames) > 0 ||
    jump_rope_telegraph_prog > 0 || jr_crack_flash > 0.02 || jr_detonate_flash > 0.02) {

  var _kj_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _kj_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _kj_cx = oCameraController.current_cam_x;
  var _kj_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);

  for (var _ka = 0; _ka < array_length(kdash_arcs); _ka++) {
    var _arc = kdash_arcs[_ka];
    var _arc_a = _arc.life / _arc.life_max;

    scr_draw_energy_bolt(
        (_arc.x1 - _kj_cx) * _kj_gx, (_arc.y1 - _kj_cy) * _kj_gy,
        (_arc.x2 - _kj_cx) * _kj_gx, (_arc.y2 - _kj_cy) * _kj_gy,
        _arc_a * (0.35 + _arc.hot * 0.5),
        merge_color(c_red, global.lightning_color, 0.3),
        scr_bolt_offsets(4, 5 + _arc.hot * 7),
        0.8 + _arc.hot * 0.8,
        0.65);
  }

  for (var _jlf = 0; _jlf < array_length(jr_lock_frames); _jlf++) {
    var _lf = jr_lock_frames[_jlf];
    var _la = clamp(_lf.life / _lf.life_max, 0, 1);
    var _gx1 = (_lf.x1 - _kj_cx) * _kj_gx;
    var _gx2 = (_lf.x2 - _kj_cx) * _kj_gx;
    var _gy1 = (_lf.y1 - _kj_cy) * _kj_gy;
    var _gy2 = (_lf.y2 - _kj_cy) * _kj_gy;
    var _pulse = 0.65 + 0.35 * sin(_lf.seed + t * 0.7);

    draw_set_color(merge_color(_k_er_col_cyan, _k_er_col_warning, 0.35 + _lf.hot * 0.2));
    draw_set_alpha(_la * _la * (0.12 + _lf.hot * 0.18) * _pulse);
    draw_rectangle(_gx1, _gy1, _gx2, _gy2, false);
    draw_set_color(c_white);
    draw_set_alpha(_la * _lf.hot * 0.34);
    draw_line_width((_gx1 + _gx2) * 0.5, _gy1, (_gx1 + _gx2) * 0.5, _gy2,
                    max(1, 2 * _kj_gx));
  }

  for (var _jss_i = 0; _jss_i < array_length(jr_scan_sweeps); _jss_i++) {
    var _ss = jr_scan_sweeps[_jss_i];
    var _sa = clamp(_ss.life / _ss.life_max, 0, 1);
    var _gx1 = (_ss.x - _ss.w * 0.5 - _kj_cx) * _kj_gx;
    var _gx2 = (_ss.x + _ss.w * 0.5 - _kj_cx) * _kj_gx;
    var _gy = (_ss.y - _kj_cy) * _kj_gy;
    var _bar_h = (2 + _ss.hot * 4) * _kj_gy;

    draw_set_color(_ss.color);
    draw_set_alpha(_sa * _sa * (0.10 + _ss.hot * 0.24));
    draw_rectangle(_gx1, _gy - _bar_h, _gx2, _gy + _bar_h, false);
    draw_set_color(c_white);
    draw_set_alpha(_sa * _ss.hot * 0.48);
    draw_line_width(_gx1, _gy, _gx2, _gy, max(1, 1.4 * _kj_gy));

    for (var _sl = 0; _sl < 3; _sl++) {
      var _off = (7 + _sl * 9) * _kj_gy;
      draw_set_color(_ss.color);
      draw_set_alpha(_sa * (0.08 + _ss.hot * 0.08) * (1 - _sl / 3));
      draw_line_width(_gx1 + _sl * 10 * _kj_gx, _gy + _off,
                      _gx2 - _sl * 10 * _kj_gx, _gy + _off,
                      max(1, 1 * _kj_gy));
    }
  }

  for (var _ja = 0; _ja < array_length(jr_arcs); _ja++) {
    var _jarc = jr_arcs[_ja];
    var _jarc_a = _jarc.life / _jarc.life_max;

    scr_draw_energy_bolt(
        (_jarc.x1 - _kj_cx) * _kj_gx, (_jarc.y1 - _kj_cy) * _kj_gy,
        (_jarc.x2 - _kj_cx) * _kj_gx, (_jarc.y2 - _kj_cy) * _kj_gy,
        _jarc_a * (0.3 + _jarc.hot * 0.55),
        merge_color(_k_er_col_cyan, _k_er_col_warning, 0.32),
        scr_bolt_offsets(4, 4 + _jarc.hot * 8),
        0.7 + _jarc.hot * 0.9,
        0.6);
  }

  for (var _jrs_i = 0; _jrs_i < array_length(jr_reactor_streams); _jrs_i++) {
    var _ds = jr_reactor_streams[_jrs_i];
    var _da = clamp(_ds.life / _ds.life_max, 0, 1);
    var _gx = (_ds.x - _kj_cx) * _kj_gx;
    var _gy = (_ds.y - _kj_cy) * _kj_gy;
    var _len = _ds.len * _kj_gy;
    var _w = max(1, _ds.w * _kj_gx);

    draw_set_color(_ds.color);
    draw_set_alpha(_da * (0.26 + _ds.hot * 0.34));
    draw_line_width(_gx, _gy, _gx + sin(_ds.seed + t * 0.2) * 8 * _kj_gx,
                    _gy - _len, _w);
    draw_set_color(c_white);
    draw_set_alpha(_da * _ds.hot * 0.55);
    draw_line_width(_gx, _gy - _len * 0.18, _gx, _gy - _len * 0.48, max(1, _w * 0.45));

    var _packet_n = 2 + floor(_ds.hot * 3);
    for (var _pk = 0; _pk < _packet_n; _pk++) {
      var _pf = frac(_ds.seed * 0.13 + _pk * 0.31 + t * 0.05);
      var _py = _gy - _len * _pf;
      var _pw = (3 + _ds.hot * 5) * _kj_gx;
      draw_set_color(merge_color(_ds.color, c_white, 0.35 + _pf * 0.45));
      draw_set_alpha(_da * (1 - _pf * 0.35) * 0.42);
      draw_rectangle(_gx - _pw, _py - 1 * _kj_gy, _gx + _pw, _py + 1 * _kj_gy, false);
    }
  }

  var _split = max(jr_crack_flash, jr_detonate_flash * 1.5);
  if (_split > 0.02) {
    var _split_y = (_k_jr_floor_y - _kj_cy) * _kj_gy;
    var _split_cx = (jump_rope_mid_x - _kj_cx) * _kj_gx;
    var _split_reach = _k_jr_crack_span * _kj_gx * (0.6 + _split * 0.9);

    for (var _sd = -1; _sd <= 1; _sd += 2) {
      scr_draw_energy_bolt(
          _split_cx, _split_y,
          _split_cx + _sd * _split_reach, _split_y + random_range(-5, 5),
          _split * 0.85,
          merge_color(_k_er_col_cyan, c_white, 0.25 + _split * 0.25),
          scr_bolt_offsets(7, 4 + _split * 9),
          1.4 + _split * 1.6,
          0.7);
    }
  }

  if (jump_rope_telegraph_prog > 0.01) {
    var _pulse = 0.55 + 0.45 * sin(t * (0.9 + jump_rope_telegraph_prog * 1.6));
    var _ta = jump_rope_telegraph_prog * _pulse;
    var _tl = (_k_jr_anchor_left_x - _kj_cx) * _kj_gx;
    var _tr = (_k_jr_anchor_right_x - _kj_cx) * _kj_gx;
    var _ty2 = (_k_jr_floor_y - _kj_cy) * _kj_gy;

    var _tmid = (jump_rope_mid_x - _kj_cx) * _kj_gx;
    _tl = lerp(_tl, _tmid, jump_rope_telegraph_prog * 0.45);
    _tr = lerp(_tr, _tmid, jump_rope_telegraph_prog * 0.45);

    draw_set_color(merge_color(_k_er_col_cyan, c_white, jump_rope_telegraph_prog * 0.5));
    for (var _tb = 0; _tb < 5; _tb++) {
      var _tbh = (2 + _tb * 5) * _kj_gy;
      draw_set_alpha(_ta * 0.16 * (1 - _tb / 5));
      draw_rectangle(_tl, _ty2 - _tbh, _tr, _ty2 + _tbh, false);
    }

    draw_set_color(c_white);
    draw_set_alpha(_ta * 0.5);
    draw_rectangle(_tl, _ty2 - 1.5 * _kj_gy, _tr, _ty2 + 1.5 * _kj_gy, false);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (dna_despawn_active) {
  var _orbit_owns_sweep =
    variable_instance_exists(id, "_k_orb_unwrap_start") &&
    t >= _k_orb_unwrap_start - 8 &&
    t <= _k_arc_window_end;
  var _k_dna_sweep_band_half_height = _orbit_owns_sweep ? 12 : 24;
  var _k_dna_sweep_band_strips = _orbit_owns_sweep ? 6 : 12;
  var _k_dna_sweep_band_alpha = _orbit_owns_sweep ? _k_orb_unwrap_sweep_alpha : 0.5;
  var _band_color = global.lightning_color;

  if (_orbit_owns_sweep) {
    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(0.20);
    draw_rectangle(0, dna_despawn_sweep_y - 7, room_width, dna_despawn_sweep_y + 7, false);
  }

  gpu_set_blendmode(_orbit_owns_sweep ? bm_add : bm_normal);
  for (var i = 0; i < _k_dna_sweep_band_strips; i++) {
    var _prog = i / _k_dna_sweep_band_strips;
    var _dist = _prog * _k_dna_sweep_band_half_height;
    var _alpha = _k_dna_sweep_band_alpha * (1 - _prog);
    draw_set_alpha(_alpha);
    draw_set_color(_band_color);
    draw_rectangle(0, dna_despawn_sweep_y - _dist - 1, room_width, dna_despawn_sweep_y - _dist + 1, false);
    draw_rectangle(0, dna_despawn_sweep_y + _dist - 1, room_width, dna_despawn_sweep_y + _dist + 1, false);
  }

  if (_orbit_owns_sweep) {
    var _sweep_p = clamp((t - _k_orb_unwrap_start) / max(1, _k_arc_window_end - _k_orb_unwrap_start), 0, 1);
    var _seg_count = 12;
    var _seg_stride = room_width / _seg_count;
    for (var _seg = 0; _seg < _seg_count; _seg++) {
      var _sx0 = _seg * _seg_stride + 6;
      var _sx1 = _sx0 + _seg_stride * lerp(0.42, 0.62, ((_seg + floor(_sweep_p * 6)) mod 3) / 2);
      var _seg_hot = ((_seg + floor(_sweep_p * 9)) mod 4) == 0;
      draw_set_color(_seg_hot ? merge_color(_band_color, c_white, 0.45) : _band_color);
      draw_set_alpha(_k_dna_sweep_band_alpha * (_seg_hot ? 1.15 : 0.65));
      draw_line_width(_sx0, dna_despawn_sweep_y, _sx1, dna_despawn_sweep_y, _seg_hot ? 2.0 : 1.2);
      draw_set_alpha(_k_dna_sweep_band_alpha * 0.55);
      draw_line_width(_sx1, dna_despawn_sweep_y - 5, _sx1, dna_despawn_sweep_y + 5, 1.1);
    }
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);

  global_ripple_pulse = max(global_ripple_pulse, 0.3);
}

var _k_distort_scale = 1.0;
var _k_distort_intensity = 0.6;

if (instance_exists(oHalfCircleBurst)) {
  gpu_set_blendmode(bm_add);

  with(oHalfCircleBurst) {
    var _gx = (x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gy = (y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, _k_distort_scale, _k_distort_scale, 0, c_white, _k_distort_intensity);
  }

  gpu_set_blendmode(bm_normal);
}

with(oQuarterExplodeShockwave) { scr_draw_smooth_ring_mask(x, y, radius, alpha * 0.7, 12); }
if (array_length(quarter_shockwaves) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(quarter_shockwaves); i++) {
    var sw = quarter_shockwaves[i];
    var _sw_a = clamp(sw.alpha, 0, 1);
    var _sw_col = merge_color(make_color_rgb(255, 45, 45), c_white, _sw_a * 0.6);

    scr_draw_smooth_ring_mask(sw.x, sw.y, sw.radius, _sw_a * 0.55, 14, _sw_col);
    scr_draw_smooth_ring_mask(sw.x, sw.y, sw.radius * 0.82, _sw_a * 0.22, 22, _sw_col);

    draw_set_alpha(_sw_a * 0.9);
    draw_set_color(merge_color(_sw_col, c_white, 0.5));
    draw_circle(sw.x, sw.y, sw.radius, true);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (instance_exists(oRedLaser)) {
  var _rl_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _rl_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _rl_cx = oCameraController.current_cam_x;
  var _rl_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  with(oRedLaser) {
    draw_sprite_ext(sprite_index, image_index,
                    (x - _rl_cx) * _rl_sx, (y - _rl_cy) * _rl_sy,
                    image_xscale * _rl_sx, image_yscale * _rl_sy,
                    image_angle, c_red, image_alpha * 0.5);
  }
  gpu_set_blendmode(bm_normal);
}

for (var i = 0; i < array_length(fruit_shockwaves); i++) {
  var _sw2 = fruit_shockwaves[i];
  var _sgx = (_sw2.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _sgy = (_sw2.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _sw2_col = variable_struct_exists(_sw2, "color") ? _sw2.color : global.tree_fire_color;
  draw_set_color(_sw2_col);
  draw_set_alpha(_sw2.alpha);
  draw_circle(_sgx, _sgy, _sw2.radius, true);
}
for (var i = 0; i < array_length(fruit_streaks); i++) {
  var _st2 = fruit_streaks[i];
  var _stgx = (_st2.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _stgy = (_st2.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _stp = 1 - (_st2.timer / _st2.duration);
  var _ex3 = _stgx + lengthdir_x(_st2.len, _st2.angle);
  var _ey3 = _stgy + lengthdir_y(_st2.len, _st2.angle);
  var _st_color = variable_struct_exists(_st2, "color") ? _st2.color : global.tree_fire_color;

  if (variable_struct_exists(_st2, "fringe") && _st2.fringe) {
    var _perp3 = _st2.angle + 90;
    var _foff = 2.5 * fx_get_mult_for("tree", "aberration");
    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_stp * 0.5);
    draw_line_width(_stgx + lengthdir_x(_foff, _perp3), _stgy + lengthdir_y(_foff, _perp3),
                    _ex3 + lengthdir_x(_foff, _perp3), _ey3 + lengthdir_y(_foff, _perp3), 2);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_stgx - lengthdir_x(_foff, _perp3), _stgy - lengthdir_y(_foff, _perp3),
                    _ex3 - lengthdir_x(_foff, _perp3), _ey3 - lengthdir_y(_foff, _perp3), 2);
  }

  draw_set_color(_st_color);
  draw_set_alpha(_stp * 0.7);
  draw_line_width(_stgx, _stgy, _ex3, _ey3, 2);
}
draw_set_alpha(1);
with(oLaserOrb_Pop) {
  if (shockwave_active) {
    var gui_x = (x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    gpu_set_blendmode(bm_add);
    draw_set_alpha(shockwave_alpha);
    draw_set_color(_k_shockwave_color);
    draw_circle(gui_x, gui_y, shockwave_radius, true);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
  }
}

var _cam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;
var _er_camx = oCameraController.current_cam_x;
var _er_camy = oCameraController.current_cam_y;

var _er_shake_fx = erupt_shudder * fx_get_mult_for("eruption", "shake");
var _er_fy = _k_er_floor_y + ((_er_shake_fx > 0) ? random_range(-_er_shake_fx, _er_shake_fx) : 0);
var _er_gfy = (_er_fy - _er_camy) * _cam_scale;

var _er_env_glow_live = (t >= _k_er_lift_charge_t && t <= erupt_active_until)
                     || er_lift_active
                     || erupt_collapsing || erupt_despawn_active
                     || array_length(erupt_lane_residue) > 0;
var _er_env_glow_a = 0;
if (_er_env_glow_live) {
  var _er_env_lift_glow_a = clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_lock_t - _k_er_lift_charge_t, 1), 0, 1);
  var _er_env_mat_glow_a  = clamp((t - _k_er_materialize_t) / max(_k_er_materialize_dur, 1), 0, 1);
  _er_env_glow_a = max(_er_env_lift_glow_a, _er_env_mat_glow_a);
  if (erupt_collapsing) {
    _er_env_glow_a *= 1 - clamp(erupt_collapse_timer / max(_k_er_collapse_duration, 1), 0, 1) * 0.35;
  }
  if (erupt_despawn_active) {
    _er_env_glow_a *= power(1 - clamp(erupt_despawn_timer / max(_k_er_despawn_duration, 1), 0, 1), 0.65);
  }
}

if (_er_env_glow_a > 0.02) {
  var _er_env_glow_heat = clamp(erupt_floor_heat + erupt_pressure * 0.18
                              + erupt_coil * 0.35 + erupt_flash * 0.18, 0, 1);
  var _er_env_top_g = (_k_er_floor_y - 188 - _er_camy) * _cam_scale;
  if (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 12) {
    _er_env_top_g = (er_lift_top_y + _k_er_lift_body_h + 8 - _er_camy) * _cam_scale;
  }
  var _er_env_bot_g = (_k_er_floor_y - 8 - _er_camy) * _cam_scale;
  var _er_env_col = merge_color(_k_er_col_cyan, _k_er_col_white, _er_env_glow_heat * 0.45);
  var _er_lift_carrying_g = er_lift_active && er_lift_top_y < _k_er_lift_start_top_y + 20;

  gpu_set_blendmode(bm_add);

  var _er_support_n_g = 6;
  var _er_support_head_y_g = _er_lift_carrying_g
                           ? (er_lift_top_y + _k_er_lift_body_h + 9)
                           : (_k_er_floor_y - 14);
  var _er_support_sleeve_top_g = max(_er_support_head_y_g + 42,
                                     _k_er_floor_base_y + 22 - _er_env_glow_heat * 10);
  var _er_support_bot_g2 = (room_height + 22 - _er_camy) * _cam_scale;
  for (var _supg = 0; _supg < _er_support_n_g; _supg++) {
    var _sf_sup = _supg / max(1, _er_support_n_g - 1);
    var _sx_sup = (lerp(58, room_width - 58, _sf_sup) - _er_camx) * _cam_scale;
    var _pulse_sup = 0.55 + 0.45 * max(0, sin(t * 0.035 + _supg * 1.73));
    var _load_sup = clamp(0.45 + erupt_pressure * 0.28 + erupt_coil * 0.32
                        + _pulse_sup * 0.12, 0, 1);
    var _sup_col = (_supg mod 2 == 0) ? _k_er_col_cyan : _k_er_col_warning;
    var _head_g = (_er_support_head_y_g + sin(t * 0.035 + _supg * 1.73) * 1.2 - _er_camy) * _cam_scale;
    var _sleeve_g = (_er_support_sleeve_top_g + ((_supg mod 2) * 10) - _er_camy) * _cam_scale;

    draw_set_color(_sup_col);
    draw_set_alpha(_er_env_glow_a * (0.045 + _load_sup * 0.055) * _pulse_sup);
    draw_line_width(_sx_sup, _head_g + 10 * _cam_scale,
                    _sx_sup, _sleeve_g + 16 * _cam_scale, max(1, 2.2 * _cam_scale));

    draw_set_alpha(_er_env_glow_a * (0.018 + _load_sup * 0.030) * _pulse_sup);
    draw_line_width(_sx_sup, _sleeve_g + 18 * _cam_scale,
                    _sx_sup, _er_support_bot_g2, max(1, 2.2 * _cam_scale));

    draw_set_color(c_white);
    draw_set_alpha(_er_env_glow_a * _load_sup * 0.08 * _pulse_sup);
    draw_line_width(_sx_sup, _head_g + 12 * _cam_scale,
                    _sx_sup, _sleeve_g + 8 * _cam_scale, max(1, 1 * _cam_scale));

    draw_set_color(merge_color(_sup_col, c_white, 0.55));
    draw_set_alpha(_er_env_glow_a * _load_sup * 0.10 * _pulse_sup);
    draw_line_width(_sx_sup - 18 * _cam_scale, _head_g - 7 * _cam_scale,
                    _sx_sup + 18 * _cam_scale, _head_g - 7 * _cam_scale,
                    max(1, 1.4 * _cam_scale));
  }

  var _er_env_rail_n_g = 7;
  for (var _erg = 0; _erg < _er_env_rail_n_g; _erg++) {
    var _rf_g = _erg / max(1, _er_env_rail_n_g - 1);
    var _gx_g = (lerp(54, room_width - 54, _rf_g) - _er_camx) * _cam_scale;
    var _pulse_g = 0.65 + 0.35 * sin(t * 0.045 + _erg * 1.9);
    var _rail_col_g = (_erg mod 3 == 0) ? _k_er_col_warning : _er_env_col;

    draw_set_color(_rail_col_g);
    draw_set_alpha(_er_env_glow_a * (0.018 + _er_env_glow_heat * 0.030) * _pulse_g);
    draw_line_width(_gx_g, _er_env_top_g, _gx_g, _er_env_bot_g, max(1, 2 * _cam_scale));
  }

  if (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 12) {
    var _man_g = (er_lift_top_y + _k_er_lift_body_h + 1 - _er_camy) * _cam_scale;
    draw_set_color(_er_env_col);
    draw_set_alpha(_er_env_glow_a * (0.05 + _er_env_glow_heat * 0.06));
    draw_line_width(0, _man_g, oCameraController.base_view_w, _man_g, max(1, 2.2 * _cam_scale));

    for (var _pktg = 0; _pktg < 8; _pktg++) {
      var _pf_g = frac(_pktg / 8 + current_time * 0.0009 * (0.65 + _er_env_glow_heat));
      var _px_g = lerp(32, room_width - 32, _pf_g);
      var _pgx = (_px_g - _er_camx) * _cam_scale;
      draw_set_color((_pktg mod 2 == 0) ? _k_er_col_cyan : _k_er_col_warning);
      draw_set_alpha(_er_env_glow_a * (0.045 + _er_env_glow_heat * 0.055) * sin(_pf_g * pi));
      draw_line_width(_pgx - 8 * _cam_scale, _man_g, _pgx + 10 * _cam_scale, _man_g,
                      max(1, 1.5 * _cam_scale));
    }
  }

  for (var _lrg = 0; _lrg < array_length(erupt_lane_residue); _lrg++) {
    var _resg = erupt_lane_residue[_lrg];
    var _rag = clamp(_resg.life / max(_resg.life_max, 1), 0, 1);
    var _coolg = power(_rag, 0.8);
    var _gx1g = (_resg.cx - _resg.w * 0.5 - _er_camx) * _cam_scale;
    var _gx2g = (_resg.cx + _resg.w * 0.5 - _er_camx) * _cam_scale;
    var _gcol_res = merge_color(_resg.color, _k_er_col_cyan, _resg.fast ? 0.55 : 0.25);

    draw_set_color(_gcol_res);
    draw_set_alpha(_er_env_glow_a * _coolg * (0.055 + _resg.hot * 0.055));
    draw_line_width(_gx1g, _er_env_top_g + 8 * _cam_scale, _gx1g, _er_env_bot_g, max(1, 1.5 * _cam_scale));
    draw_line_width(_gx2g, _er_env_top_g + 8 * _cam_scale, _gx2g, _er_env_bot_g, max(1, 1.5 * _cam_scale));

    draw_set_color(c_white);
    draw_set_alpha(_er_env_glow_a * _coolg * _resg.hot * 0.09);
    draw_line_width(_gx1g + 3 * _cam_scale, _er_gfy - 2 * _cam_scale,
                    _gx2g - 3 * _cam_scale, _er_gfy - 2 * _cam_scale,
                    max(1, 1.2 * _cam_scale));
  }

  if (erupt_coil > 0.01 && array_length(erupt_armed_cols) > 0) {
    var _active_col = merge_color(_k_er_col_armor_edge, _k_er_col_white, erupt_coil * erupt_coil * 0.8);
    for (var _aeg = 0; _aeg < array_length(erupt_armed_cols); _aeg++) {
      var _aceg = erupt_armed_cols[_aeg];
      var _gxl = (_aceg.cx - _aceg.w * 0.5 - _er_camx) * _cam_scale;
      var _gxr = (_aceg.cx + _aceg.w * 0.5 - _er_camx) * _cam_scale;
      var _act_a = _er_env_glow_a * (0.08 + erupt_coil * 0.14);

      draw_set_color(_active_col);
      draw_set_alpha(_act_a);
      draw_line_width(_gxl, _er_env_top_g + 4 * _cam_scale, _gxl, _er_env_bot_g, max(1, 2 * _cam_scale));
      draw_line_width(_gxr, _er_env_top_g + 4 * _cam_scale, _gxr, _er_env_bot_g, max(1, 2 * _cam_scale));
      draw_set_color(c_white);
      draw_set_alpha(_act_a * 0.55);
      draw_line_width((_gxl + _gxr) * 0.5, _er_env_top_g + 8 * _cam_scale,
                      (_gxl + _gxr) * 0.5, _er_gfy, max(1, 1.2 * _cam_scale));
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(erupt_scan_sweeps) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_scan_sweeps); i++) {
    var _ss = erupt_scan_sweeps[i];
    var _sa = clamp(_ss.life / _ss.life_max, 0, 1);
    var _gx1 = (_ss.x - _ss.w * 0.5 - _er_camx) * _cam_scale;
    var _gx2 = (_ss.x + _ss.w * 0.5 - _er_camx) * _cam_scale;
    var _gy = (_ss.y - _er_camy) * _cam_scale;
    var _bar_h = (2 + _ss.hot * 4) * _cam_scale;

    draw_set_color(_ss.color);
    draw_set_alpha(_sa * _sa * (0.12 + _ss.hot * 0.22));
    draw_rectangle(_gx1, _gy - _bar_h, _gx2, _gy + _bar_h, false);
    draw_set_color(c_white);
    draw_set_alpha(_sa * _ss.hot * 0.55);
    draw_line_width(_gx1, _gy, _gx2, _gy, max(1, 1.5 * _cam_scale));

    for (var _sl = 0; _sl < 3; _sl++) {
      var _off = (6 + _sl * 9) * _cam_scale;
      draw_set_color(_ss.color);
      draw_set_alpha(_sa * (0.08 + _ss.hot * 0.08) * (1 - _sl / 3));
      draw_line_width(_gx1 + _sl * 8 * _cam_scale, _gy + _off,
                      _gx2 - _sl * 8 * _cam_scale, _gy + _off,
                      max(1, 1 * _cam_scale));
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_panel_afterimages) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_panel_afterimages); i++) {
    var _pa = erupt_panel_afterimages[i];
    var _aa = clamp(_pa.life / _pa.life_max, 0, 1);
    var _gl = (_pa.cx - _pa.w * 0.5 - _er_camx) * _cam_scale;
    var _gr = (_pa.cx + _pa.w * 0.5 - _er_camx) * _cam_scale;
    var _gt = (_pa.y - _pa.h - _er_camy) * _cam_scale;
    var _gb = (min(_pa.y + 8, _k_er_floor_y) - _er_camy) * _cam_scale;
    var _mid = (_pa.cx - _er_camx) * _cam_scale;
    var _col = merge_color(_pa.color, _k_er_col_cyan, _pa.fast ? 0.55 : 0.25);

    draw_set_color(_col);
    draw_set_alpha(_aa * _aa * (0.10 + _pa.hot * 0.18));
    draw_rectangle(_gl, _gt, _gr, _gb, false);
    draw_set_color(c_white);
    draw_set_alpha(_aa * _pa.hot * 0.45);
    draw_line_width(_mid, _gt, _mid, _gb, (_pa.fast ? 2.5 : 1.5) * _cam_scale);

    for (var _rf = -1; _rf <= 1; _rf += 2) {
      draw_set_color((_rf < 0) ? _k_er_col_warning : _k_er_col_cyan);
      draw_set_alpha(_aa * 0.24);
      draw_line_width(_mid + _rf * _pa.w * 0.38 * _cam_scale, _gt,
                      _mid + _rf * _pa.w * 0.18 * _cam_scale, _gb,
                      max(1, 1.4 * _cam_scale));
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_reactor_rings) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_reactor_rings); i++) {
    var _rr = erupt_reactor_rings[i];
    var _ra = clamp(_rr.life / _rr.life_max, 0, 1);
    var _rp = 1 - _ra;
    var _rx = lerp(_rr.rx, _rr.rx_max, 1 - power(1 - _rp, 2));
    var _ry = lerp(_rr.ry, _rr.ry_max, _rp);
    var _gx = (_rr.cx - _er_camx) * _cam_scale;
    var _gy = (_rr.cy - _er_camy) * _cam_scale;

    draw_set_color(_rr.color);
    draw_set_alpha(_ra * _ra * (0.28 + _rr.hot * 0.26));
    draw_ellipse(_gx - _rx * _cam_scale, _gy - _ry * _cam_scale,
                 _gx + _rx * _cam_scale, _gy + _ry * _cam_scale, true);
    draw_set_color(c_white);
    draw_set_alpha(_ra * _rr.hot * 0.35);
    draw_ellipse(_gx - _rx * 0.72 * _cam_scale, _gy - _ry * 0.45 * _cam_scale,
                 _gx + _rx * 0.72 * _cam_scale, _gy + _ry * 0.45 * _cam_scale, true);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_scars) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_scars); i++) {
    var _sc = erupt_scars[i];
    var _sa = clamp(_sc.life / _sc.life_max, 0, 1);
    var _cool = _sa * _sa;
    var _col = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, _cool);
    var _gx1 = (_sc.cx - _sc.w * 0.5 - _er_camx) * _cam_scale;
    var _gx2 = (_sc.cx + _sc.w * 0.5 - _er_camx) * _cam_scale;

    draw_set_color(_col);
    draw_set_alpha(_cool * 0.45 * _sc.hot);
    draw_line_width(_gx1, _er_gfy, _gx2, _er_gfy, 7 * _cam_scale);
    draw_set_color(merge_color(_col, c_white, 0.5));
    draw_set_alpha(_cool * 0.6 * _sc.hot);
    draw_line_width(_gx1 + 3, _er_gfy, _gx2 - 3, _er_gfy, 2 * _cam_scale);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (erupt_coil > 0.01 && array_length(erupt_armed_cols) > 0) {
  var _seam_hot = erupt_coil * erupt_coil;
  var _seam_col = merge_color(_k_er_col_armor_edge, _k_er_col_white, _seam_hot * 0.8);

  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_armed_cols); i++) {
    var _ac = erupt_armed_cols[i];
    var _gx1 = (_ac.cx - _ac.w * 0.5 - _er_camx) * _cam_scale;
    var _gx2 = (_ac.cx + _ac.w * 0.5 - _er_camx) * _cam_scale;

    draw_set_color(_seam_col);
    draw_set_alpha(0.25 + _seam_hot * 0.55);
    draw_line_width(_gx1, _er_gfy + 2 * _cam_scale, _gx2, _er_gfy + 2 * _cam_scale,
                    (4 + erupt_coil * 14) * _cam_scale);

    draw_set_color(c_white);
    draw_set_alpha(_seam_hot * 0.85);
    draw_line_width(_gx1 + 2, _er_gfy + 2 * _cam_scale, _gx2 - 2, _er_gfy + 2 * _cam_scale,
                    (1 + erupt_coil * 4) * _cam_scale);

    var _fringe = (2 + _seam_hot * 6) * _cam_scale;
    draw_set_color(c_red);
    draw_set_alpha(0.10 + _seam_hot * 0.3);
    draw_line_width(_gx1 - _fringe, _er_gfy, _gx2 - _fringe, _er_gfy, max(1, 3 * _cam_scale));
    draw_set_color(_k_er_col_cyan);
    draw_set_alpha(0.10 + _seam_hot * 0.3);
    draw_line_width(_gx1 + _fringe, _er_gfy, _gx2 + _fringe, _er_gfy, max(1, 3 * _cam_scale));

    var _spill_h = (14 + _seam_hot * 60) * _cam_scale;
    draw_primitive_begin(pr_trianglestrip);
    var _spill_segs = 6;
    for (var s = 0; s <= _spill_segs; s++) {
      var _f = s / _spill_segs;
      var _sx = lerp(_gx1, _gx2, _f);
      var _taper = sin(_f * pi) * 0.6 + 0.4;
      draw_vertex_colour(_sx, _er_gfy, _seam_col, (0.1 + _seam_hot * 0.4) * _taper);
      draw_vertex_colour(_sx, _er_gfy - _spill_h * _taper, _seam_col, 0);
    }
    draw_primitive_end();

    if (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 24) {
      var _stage_gfy = (er_lift_top_y - _er_camy) * _cam_scale;
      var _beam_a = (0.07 + _seam_hot * 0.22) * erupt_coil;
      draw_set_color(_seam_col);
      draw_set_alpha(_beam_a);
      draw_rectangle(_gx1, _stage_gfy, _gx2, _er_gfy, false);
      draw_set_color(c_white);
      draw_set_alpha(_beam_a * 0.45);
      draw_line_width((_gx1 + _gx2) * 0.5, _stage_gfy,
                      (_gx1 + _gx2) * 0.5, _er_gfy, max(1, _ac.w * 0.08) * _cam_scale);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}
var _side_warn_p2 = clamp((t - (_k_er_side_burst_t - _k_er_side_burst_warn_lead))
                        / max(_k_er_side_burst_warn_lead, 1), 0, 1);
if (t >= _k_er_side_burst_t - _k_er_side_burst_warn_lead && t < _k_er_side_burst_t &&
    er_lift_active) {
  var _wy2n = er_lift_top_y + _k_er_side_burst_y_off;
  var _gywn = (_wy2n - _er_camy) * _cam_scale;
  var _wr2n = _k_er_side_warn_lane_r * _cam_scale;
  var _hot2n = max(_side_warn_p2, _k_er_side_warn_read_floor);
  var _head_l2n = lerp(_k_er_side_warn_gate_w * 0.72,
                       room_width * 0.5 - 10,
                       power(_side_warn_p2, 0.78));
  var _head_r2n = room_width - _head_l2n;
  var _strobe2n = clamp((_side_warn_p2 - 0.75) / 0.25, 0, 1);
  var _pulse2n = lerp(0.72 + 0.28 * sin(t * 0.85),
                      0.32 + 0.68 * abs(sin(t * 1.9)), _strobe2n);

  gpu_set_blendmode(bm_add);

  for (var _side2n = 0; _side2n < 2; _side2n++) {
    var _dir2n = (_side2n == 0) ? 1 : -1;
    var _gx0n = (((_side2n == 0) ? 0 : room_width - _k_er_side_warn_gate_w) - _er_camx) * _cam_scale;
    var _gx1n = (((_side2n == 0) ? _k_er_side_warn_gate_w : room_width) - _er_camx) * _cam_scale;
    var _head2n = (((_side2n == 0) ? _head_l2n : _head_r2n) - _er_camx) * _cam_scale;

    scr_draw_lock_bracket_glow(_gx0n + 4 * _cam_scale, _gywn - _wr2n * 1.62,
                               _gx1n - 4 * _cam_scale, _gywn + _wr2n * 1.62,
                               _k_er_col_cyan, _hot2n, 0.95, 0, _pulse2n);

    draw_set_color(c_white);
    draw_set_alpha((0.16 + _hot2n * 0.34) * _pulse2n);
    draw_line_width(_head2n, _gywn - _wr2n * 1.5,
                    _head2n, _gywn + _wr2n * 1.5, max(1, (2 + _hot2n * 3) * _cam_scale));

    for (var _pk2n = 0; _pk2n < _k_er_side_warn_packet_n; _pk2n++) {
      var _pf2n = frac(_pk2n / _k_er_side_warn_packet_n
                       + current_time * 0.0014 * (0.8 + _hot2n));
      var _mx2n = (_side2n == 0) ? (10 - _er_camx) * _cam_scale
                                 : (room_width - 10 - _er_camx) * _cam_scale;
      var _px2n = lerp(_mx2n, _head2n, _pf2n);
      var _pa2n = sin(_pf2n * pi) * (0.12 + _hot2n * 0.24);
      var _pk_col2n = ((_pk2n mod 3) == 0) ? _k_er_col_cyan
                      : (((_pk2n mod 3) == 1) ? _k_er_col_warning : _k_er_col_violet);

      draw_set_color(merge_color(_pk_col2n, c_white, 0.45));
      draw_set_alpha(_pa2n);
      draw_line_width(_px2n - _dir2n * (18 + _hot2n * 22) * _cam_scale, _gywn,
                      _px2n + _dir2n * (4 + _hot2n * 8) * _cam_scale, _gywn,
                      max(1, 2.5 * _cam_scale));
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}
if (false && t >= _k_er_side_burst_t - _k_er_side_burst_warn_lead && t < _k_er_side_burst_t &&
    er_lift_active) {
  var _wy2 = er_lift_top_y + _k_er_side_burst_y_off;
  var _gyw = (_wy2 - _er_camy) * _cam_scale;
  var _wr2 = _k_er_side_warn_lane_r * _cam_scale;
  var _reach2 = lerp(room_width * 0.225, room_width * 0.5 + 24, power(_side_warn_p2, 0.7));
  var _gx_l0 = (0 - _er_camx) * _cam_scale;
  var _gx_l1 = (_reach2 - _er_camx) * _cam_scale;
  var _gx_r0 = (room_width - _reach2 - _er_camx) * _cam_scale;
  var _gx_r1 = (room_width - _er_camx) * _cam_scale;
  var _warn_hot2 = max(_side_warn_p2, _k_er_side_warn_read_floor);
  var _strobe_p2 = clamp((_side_warn_p2 - 0.75) / 0.25, 0, 1);
  var _warn_pulse2 = lerp(0.72 + 0.28 * sin(t * 0.85), 0.32 + 0.68 * abs(sin(t * 1.9)), _strobe_p2);
  gpu_set_blendmode(bm_add);
  scr_draw_lock_bracket_glow(_gx_l0, _gyw - _wr2, _gx_l1, _gyw + _wr2,
                             _k_er_col_cyan, _warn_hot2, 1, 0, _warn_pulse2);
  scr_draw_lock_bracket_glow(_gx_r0, _gyw - _wr2, _gx_r1, _gyw + _wr2,
                             _k_er_col_cyan, _warn_hot2, 1, 0, _warn_pulse2);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_side_warn_vents) > 0) {
  gpu_set_blendmode(bm_add);
  scr_draw_vent_streams(erupt_side_warn_vents, _er_camx, _er_camy, _cam_scale);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}
if (array_length(erupt_side_bursts) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_side_bursts); i++) {
    var _sb = erupt_side_bursts[i];
    var _age = _sb.life_max - _sb.life;
    var _sp = clamp(_age / max(_sb.life_max - 1, 1), 0, 1);
    var _sweep = 1 - power(1 - clamp(_sp * 1.45, 0, 1), 3);
    var _x0 = (_sb.dir > 0) ? 0 : room_width;
    var _x1 = _x0 + _sb.dir * room_width * _sweep;
    var _fade = power(clamp(_sb.life / _sb.life_max, 0, 1), 0.65);
    var _gx0 = (_x0 - _er_camx) * _cam_scale;
    var _gx1 = (_x1 - _er_camx) * _cam_scale;
    var _gy = (_sb.y - _er_camy) * _cam_scale;
    draw_set_color(_sb.col);
    draw_set_alpha(_fade * 0.62);
    draw_line_width(_gx0, _gy, _gx1, _gy, (12 + _fade * 18) * _cam_scale);
    draw_set_color(c_white);
    draw_set_alpha(_fade * 0.85);
    draw_line_width(_gx0, _gy, _gx1, _gy, (3 + _fade * 4) * _cam_scale);
    draw_set_color(merge_color(_k_er_col_molten, c_white, 0.35));
    draw_set_alpha(_fade * 0.24);
    draw_line_width(_gx0, _gy + 8 * _cam_scale, _gx1, _gy + 8 * _cam_scale,
                    (7 + _fade * 10) * _cam_scale);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}
if (array_length(erupt_haze) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_haze); i++) {
    var _hz = erupt_haze[i];
    var _ha = clamp(_hz.life / _hz.life_max, 0, 1);
    var _rise = _hz.prog * 90 * _cam_scale;
    var _gx = (_hz.cx - _er_camx) * _cam_scale;
    var _gw = _hz.w * 0.5 * _cam_scale * (0.5 + _hz.prog * 0.6);

    draw_set_color(merge_color(_k_er_col_cyan, _k_er_col_white, _hz.hot * 0.7));
    draw_set_alpha(_ha * _ha * 0.16 * _hz.hot);
    var _wob = sin(_hz.prog * 7 + _hz.cx * 0.03) * 6 * _cam_scale;
    draw_rectangle(_gx - _gw + _wob, _er_gfy - _rise - 22 * _cam_scale,
                   _gx + _gw + _wob, _er_gfy - _rise, false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_lock_frames) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_lock_frames); i++) {
    var _lf2 = erupt_lock_frames[i];
    var _la2 = clamp(_lf2.life / _lf2.life_max, 0, 1);
    var _gx1 = (_lf2.cx - _lf2.w * 0.5 - _er_camx) * _cam_scale;
    var _gx2 = (_lf2.cx + _lf2.w * 0.5 - _er_camx) * _cam_scale;
    var _gy1 = (_k_er_floor_y - (_lf2.fast ? 42 : 62) - _er_camy) * _cam_scale;
    var _gy2 = (_k_er_floor_y + 10 - _er_camy) * _cam_scale;
    var _pulse = 0.65 + 0.35 * sin(_lf2.seed + t * 0.7);

    draw_set_color(_lf2.fast ? _k_er_col_cyan : _k_er_col_warning);
    draw_set_alpha(_la2 * _la2 * (0.16 + _lf2.hot * 0.18) * _pulse);
    draw_rectangle(_gx1, _gy1, _gx2, _gy2, false);
    draw_set_color(c_white);
    draw_set_alpha(_la2 * _lf2.hot * 0.35);
    draw_line_width((_gx1 + _gx2) * 0.5, _gy1, (_gx1 + _gx2) * 0.5, _gy2,
                    max(1, 2 * _cam_scale));
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_charge_arcs) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_charge_arcs); i++) {
    var _ea = erupt_charge_arcs[i];
    var _aa2 = clamp(_ea.life / _ea.life_max, 0, 1);
    scr_draw_energy_bolt((_ea.x1 - _er_camx) * _cam_scale, (_ea.y1 - _er_camy) * _cam_scale,
                         (_ea.x2 - _er_camx) * _cam_scale, (_ea.y2 - _er_camy) * _cam_scale,
                         _aa2 * (0.35 + _ea.hot * 0.55),
                         _ea.color, _ea.off,
                         (0.9 + _ea.hot * 1.6) * _cam_scale,
                         0.82);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_code_streams) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_code_streams); i++) {
    var _ds = erupt_code_streams[i];
    var _da = clamp(_ds.life / _ds.life_max, 0, 1);
    var _gx = (_ds.x - _er_camx) * _cam_scale;
    var _gy = (_ds.y - _er_camy) * _cam_scale;
    var _len = _ds.len * _cam_scale;
    var _w = max(1, _ds.w * _cam_scale);
    var _col = _ds.color;

    draw_set_color(_col);
    draw_set_alpha(_da * (0.32 + _ds.hot * 0.32));
    draw_line_width(_gx, _gy, _gx + sin(_ds.seed + t * 0.18) * 8 * _cam_scale,
                    _gy - _len, _w);
    draw_set_color(c_white);
    draw_set_alpha(_da * _ds.hot * 0.55);
    draw_line_width(_gx, _gy - _len * 0.18, _gx, _gy - _len * 0.46, max(1, _w * 0.45));

    var _packet_n = 2 + floor(_ds.hot * 3);
    for (var _pk = 0; _pk < _packet_n; _pk++) {
      var _pf = frac(_ds.seed * 0.13 + _pk * 0.31 + t * 0.045);
      var _py = _gy - _len * _pf;
      var _pw = (3 + _ds.hot * 5) * _cam_scale;
      draw_set_color(merge_color(_col, c_white, 0.35 + _pf * 0.45));
      draw_set_alpha(_da * (1 - _pf * 0.35) * 0.42);
      draw_rectangle(_gx - _pw, _py - 1 * _cam_scale, _gx + _pw, _py + 1 * _cam_scale, false);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_ridges) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_ridges); i++) {
    var _rg = erupt_ridges[i];
    var _ra = clamp(_rg.life / _rg.life_max, 0, 1);
    var _gx = (_rg.x + _rg.dir * _rg.dist - _er_camx) * _cam_scale;
    var _tail = 46 * _cam_scale;

    draw_set_color(_rg.color);
    draw_set_alpha(_ra * 0.5);
    draw_line_width(_gx - _rg.dir * _tail, _er_gfy, _gx, _er_gfy, (2 + _ra * 7) * _cam_scale);

    draw_set_color(merge_color(_rg.color, c_white, 0.6));
    draw_set_alpha(_ra * 0.8);
    var _crest = (6 + _ra * 20) * _cam_scale;
    draw_line_width(_gx, _er_gfy, _gx, _er_gfy - _crest, 2 * _cam_scale);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_pillars) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_pillars); i++) {
    var _p = erupt_pillars[i];

    if (_p.y + _p.h >= -40) {
      var _gl = (_p.cx - _p.w * 0.5 - _er_camx) * _cam_scale;
      var _gr = (_p.cx + _p.w * 0.5 - _er_camx) * _cam_scale;
      var _pad = variable_struct_exists(_p, "visual_pad") ? _p.visual_pad : 0;
      var _gt = (_p.y - _pad - _er_camy) * _cam_scale;
      var _gb = (min(_p.y + _p.h + _pad, _k_er_floor_y) - _er_camy) * _cam_scale;
      var _gcx = (_p.cx - _er_camx) * _cam_scale;

      var _hot = merge_color(_k_er_col_cyan, c_white, 0.28 + _p.heat * 0.48);
      var _warn_hot = merge_color(_k_er_col_warning, c_white, 0.15 + _p.heat * 0.25);

      if (_p.fast) {
        draw_set_color(_k_er_col_cyan);
        draw_set_alpha(0.30 + _p.heat * 0.35);
        draw_line_width(_gcx, _gt, _gcx, _gb, 8 * _cam_scale);
        draw_set_color(c_white);
        draw_set_alpha(0.5 + _p.heat * 0.5);
        draw_line_width(_gcx, _gt, _gcx, _gb, 3 * _cam_scale);
      } else {
        var _vein_n = 2 + floor(_p.esc * 2);
        for (var v = 0; v < _vein_n; v++) {
          var _vx = lerp(_gl + 8 * _cam_scale, _gr - 8 * _cam_scale, (v + 0.5) / _vein_n);
          scr_draw_energy_bolt(_vx, _gb, _vx + random_range(-10, 10) * _cam_scale, _gt,
                               (0.20 + _p.heat * 0.42), _hot,
                               scr_bolt_offsets(4, (5 + _p.esc * 8) * _cam_scale),
                               1.4 * _cam_scale, 0.82);
        }

        draw_set_color(_k_er_col_cyan);
        draw_set_alpha(0.12 + _p.heat * 0.20);
        draw_line_width(_gl + 7 * _cam_scale, _gt, _gl + 7 * _cam_scale, _gb, 3 * _cam_scale);
        draw_line_width(_gr - 7 * _cam_scale, _gt, _gr - 7 * _cam_scale, _gb, 3 * _cam_scale);
        draw_set_color(_warn_hot);
        draw_set_alpha(0.08 + _p.heat * 0.13);
        draw_line_width(_gcx, _gt + 6 * _cam_scale, _gcx, _gb - 6 * _cam_scale, 2 * _cam_scale);
      }

      var _flare = (0.3 + _p.heat * 0.9) * (0.6 + erupt_flash * 0.6);
      draw_set_color(_hot);
      draw_set_alpha(_flare * 0.34);
      draw_line_width(_gl, _gb, _gr, _gb, (5 + _p.heat * 12) * _cam_scale);
      draw_set_color(c_white);
      draw_set_alpha(_flare * 0.58);
      draw_line_width(_gl + 3, _gb, _gr - 3, _gb, (1.5 + _p.heat * 4) * _cam_scale);

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.2 + _p.heat * 0.35));
      draw_set_alpha(0.18 + _p.heat * 0.22);
      draw_line_width(_gl, _gt, _gr, _gt, 2.5 * _cam_scale);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_sparks) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_sparks); i++) {
    var _sk = erupt_sparks[i];
    var _sa = clamp(_sk.life / _sk.life_max, 0, 1);
    var _gx = (_sk.x - _er_camx) * _cam_scale;
    var _gy = (_sk.y - _er_camy) * _cam_scale;

    draw_set_color(_sk.color);
    draw_set_alpha(_sa * 0.7);
    draw_line_width(_gx - _sk.xspeed * 2.2 * _cam_scale, _gy - _sk.yspeed * 2.2 * _cam_scale,
                    _gx, _gy, max(1, _sk.size * _cam_scale));
    draw_set_color(merge_color(_sk.color, c_white, 0.7));
    draw_set_alpha(_sa * 0.9);
    draw_circle(_gx, _gy, max(0.5, _sk.size * 0.45 * _sa * _cam_scale), false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_gravel) > 0 && erupt_floor_heat > 0.02) {
  gpu_set_blendmode(bm_add);
  draw_set_color(merge_color(_k_er_col_armor_edge, c_white, erupt_pressure * 0.6));
  for (var i = 0; i < array_length(erupt_gravel); i++) {
    var _gv = erupt_gravel[i];
    var _ga = clamp(_gv.life / _gv.life_max, 0, 1);
    draw_set_alpha(_ga * 0.5 * erupt_floor_heat);
    draw_circle((_gv.x - _er_camx) * _cam_scale, (_gv.y - _er_camy) * _cam_scale,
                max(0.5, _gv.size * 1.4 * _cam_scale), false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_shards) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_shards); i++) {
    var _sh = erupt_shards[i];
    var _sa = clamp(_sh.life / _sh.life_max, 0, 1);
    var _gx = (_sh.x - _er_camx) * _cam_scale;
    var _gy = (_sh.y - _er_camy) * _cam_scale;

    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _sa));
    draw_set_alpha(_sa * _sa * 0.6);
    draw_circle(_gx, _gy, _sh.size * 0.9 * _sa * _cam_scale, false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(ember_spray) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(ember_spray); i++) {
    var _em = ember_spray[i];
    var _ea = clamp(_em.life / _em.life_max, 0, 1);
    var _gx = (_em.x - _er_camx) * _cam_scale;
    var _gy = (_em.y - _er_camy) * _cam_scale;

    draw_set_color(_em.color);
    draw_set_alpha(_ea * 0.55);
    draw_line_width(_gx - _em.xspeed * 2.4 * _cam_scale, _gy - _em.yspeed * 2.4 * _cam_scale,
                    _gx, _gy, _em.size * 1.6 * _cam_scale);
    draw_set_color(merge_color(_em.color, c_white, 0.6));
    draw_set_alpha(_ea * 0.9);
    draw_circle(_gx, _gy, max(0.5, _em.size * 0.5 * _ea * _cam_scale), false);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_collapse_beams) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_collapse_beams); i++) {
    var _bm = erupt_collapse_beams[i];
    var _prog_b = clamp(_bm.prog, 0, 1);
    if (_prog_b > 0) {
      var _ba = clamp(_bm.life / _bm.life_max, 0, 1);
      var _perp_b = point_direction(_bm.sx, _bm.sy, _bm.tx, _bm.ty) + 90;
      var _bow_b = sin(_prog_b * pi) * (_bm.bow + sin(_bm.sx * 0.17 + t * 0.22) * 20);
      var _hx = lerp(_bm.sx, _bm.tx, _prog_b) + lengthdir_x(_bow_b, _perp_b);
      var _hy = lerp(_bm.sy, _bm.ty, _prog_b) + lengthdir_y(_bow_b, _perp_b);

      scr_draw_energy_bolt((_bm.sx - _er_camx) * _cam_scale, (_bm.sy - _er_camy) * _cam_scale,
                           (_hx - _er_camx) * _cam_scale, (_hy - _er_camy) * _cam_scale,
                           _ba * (0.45 + _bm.hot * 0.55),
                           _bm.color, _bm.off,
                           _bm.w * _cam_scale,
                           0.9);

      draw_set_color(c_white);
      draw_set_alpha(_ba * _bm.hot * 0.6);
      draw_circle((_hx - _er_camx) * _cam_scale, (_hy - _er_camy) * _cam_scale,
                  max(1, _bm.w * 1.3 * _cam_scale), false);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(erupt_seed_streams) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(erupt_seed_streams); i++) {
    var _cs = erupt_seed_streams[i];
    var _prog = clamp(_cs.prog, 0, 1);
    if (_prog > 0) {
      var _ca = clamp(_cs.life / _cs.life_max, 0, 1) * (1 - _prog * 0.35);
      var _perp = point_direction(_cs.sx, _cs.sy, _cs.tx, _cs.ty) + 90;

      var _segs = 8;
      var _px = 0, _py = 0;
      for (var s = 0; s <= _segs; s++) {
        var _f = _prog * (s / _segs);
        var _bx = lerp(_cs.sx, _cs.tx, _f) + lengthdir_x(sin(_f * pi) * _cs.bow, _perp);
        var _by = lerp(_cs.sy, _cs.ty, _f) + lengthdir_y(sin(_f * pi) * _cs.bow, _perp);
        var _gx = (_bx - _er_camx) * _cam_scale;
        var _gy = (_by - _er_camy) * _cam_scale;
        if (s > 0) {
          var _headness = s / _segs;
          draw_set_color(merge_color(_k_er_col_cyan, c_white, _headness));
          draw_set_alpha(_ca * _headness * 0.8);
          draw_line_width(_px, _py, _gx, _gy, _cs.w * (0.4 + _headness * 0.8) * _cam_scale);
        }
        _px = _gx;
        _py = _gy;
      }
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (erupt_collapsing) {
  var _dp = clamp(erupt_collapse_timer / _k_er_collapse_duration, 0, 1);
  var _drain = 1 - _dp;

  gpu_set_blendmode(bm_add);
  draw_set_color(c_white);
  draw_set_alpha(_drain * 0.5);
  draw_line_width((0 - _er_camx) * _cam_scale, _er_gfy, (room_width - _er_camx) * _cam_scale, _er_gfy,
                  (6 + _drain * 26) * _cam_scale);

  var _col_n = 16;
  draw_set_color(merge_color(_k_er_col_cyan, c_white, 0.6));
  for (var i = 0; i < _col_n; i++) {
    var _cx2 = (i + 0.5) * (room_width / _col_n);
    var _gx = (_cx2 - _er_camx) * _cam_scale;
    var _h = (30 + _drain * 220 + sin(i * 2.1 + _dp * 9) * 40) * _cam_scale;
    draw_set_alpha(_drain * _drain * 0.28);
    draw_line_width(_gx, _er_gfy, _gx, _er_gfy - _h, (3 + _drain * 8) * _cam_scale);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (erupt_despawn_active || array_length(erupt_despawn_threads) > 0 ||
    array_length(erupt_despawn_motes) > 0 || array_length(erupt_despawn_sweeps) > 0) {
  var _edp2 = erupt_despawn_active
            ? clamp(erupt_despawn_timer / _k_er_despawn_duration, 0, 1)
            : 1;
  var _eda = power(1 - _edp2, 0.75);
  var _floor_gy = (_k_er_floor_y + erupt_despawn_sink - _er_camy) * _cam_scale;

  gpu_set_blendmode(bm_add);

  if (_eda > 0.02) {
    var _pulse = 0.65 + sin(_edp2 * 10) * 0.12;
    draw_set_color(merge_color(_k_er_col_armor_edge, c_white, erupt_despawn_flash * 0.7));
    draw_set_alpha(_eda * 0.42 * _pulse);
    draw_line_width((0 - _er_camx) * _cam_scale, _floor_gy,
                    (room_width - _er_camx) * _cam_scale, _floor_gy,
                    (10 + _eda * 30) * _cam_scale);
    draw_set_color(c_white);
    draw_set_alpha(erupt_despawn_flash * 0.55);
    draw_line_width((0 - _er_camx) * _cam_scale, _floor_gy - 2 * _cam_scale,
                    (room_width - _er_camx) * _cam_scale, _floor_gy - 2 * _cam_scale,
                    (2 + erupt_despawn_flash * 5) * _cam_scale);
  }

  for (var i = 0; i < array_length(erupt_despawn_sweeps); i++) {
    var _sw = erupt_despawn_sweeps[i];
    if (_sw.delay <= 0) {
      var _sa = clamp(_sw.life / _sw.life_max, 0, 1);
      var _gx = (_sw.x - _er_camx) * _cam_scale;
      var _gy = (_sw.y + erupt_despawn_sink * 0.7 - _er_camy) * _cam_scale;
      var _tail = _sw.w * (0.5 + _sa) * _cam_scale;
      var _dir = _sw.dir;

      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, _sw.hot * 0.45));
      draw_set_alpha(_sa * _sa * 0.35);
      draw_line_width(_gx - _dir * _tail, _gy, _gx, _gy,
                      (3 + _sw.hot * 7) * _cam_scale);
      draw_set_color(c_white);
      draw_set_alpha(_sa * 0.45);
      draw_line_width(_gx, _gy - 10 * _cam_scale, _gx, _gy + 6 * _cam_scale,
                      max(1, 2 * _cam_scale));
    }
  }

  for (var i = 0; i < array_length(erupt_despawn_threads); i++) {
    var _dt = erupt_despawn_threads[i];
    var _prog = clamp(_dt.prog, 0, 1);
    if (_prog > 0) {
      var _ta = clamp(_dt.life / _dt.life_max, 0, 1) * (1 - _prog * 0.28);
      var _perp = point_direction(_dt.sx, _dt.sy, _dt.tx, _dt.ty) + 90;
      var _segs = 9;
      var _px = 0, _py = 0;

      for (var s = 0; s <= _segs; s++) {
        var _f = max(0, _prog - 0.34 + 0.34 * (s / _segs));
        var _ease = 1 - power(1 - _f, 2);
        var _bow = sin(_ease * pi) * (_dt.bow + sin(_dt.seed + _edp2 * 12) * 18);
        var _wx = lerp(_dt.sx, _dt.tx, _ease) + lengthdir_x(_bow, _perp);
        var _wy = lerp(_dt.sy, _dt.ty, _ease) + lengthdir_y(_bow, _perp);
        var _gx2 = (_wx - _er_camx) * _cam_scale;
        var _gy2 = (_wy - _er_camy) * _cam_scale;

        if (s > 0) {
          var _head = s / _segs;
          draw_set_color(merge_color(_dt.color, c_white, _head * 0.6));
          draw_set_alpha(_ta * _head * (0.18 + _prog * 0.55));
          draw_line_width(_px, _py, _gx2, _gy2,
                          max(1, _dt.w * (0.5 + _head * 0.9) * _cam_scale));
        }
        _px = _gx2;
        _py = _gy2;
      }
    }
  }

  for (var i = 0; i < array_length(erupt_despawn_plates); i++) {
    var _pl = erupt_despawn_plates[i];
    var _pa = clamp(_pl.life / _pl.life_max, 0, 1);
    var _gx3 = (_pl.x - _er_camx) * _cam_scale;
    var _gy3 = (_pl.y - _er_camy) * _cam_scale;
    draw_set_color(merge_color(_k_er_col_armor_dark, _k_er_col_armor_edge, _pl.hot));
    draw_set_alpha(_pa * _pa * 0.32 * _pl.hot);
    draw_circle(_gx3, _gy3, max(1, _pl.w * 0.38 * _pa * _cam_scale), false);
  }

  for (var i = 0; i < array_length(erupt_despawn_motes); i++) {
    var _dm = erupt_despawn_motes[i];
    var _ma = clamp(_dm.life / _dm.life_max, 0, 1);
    var _gx4 = (_dm.x - _er_camx) * _cam_scale;
    var _gy4 = (_dm.y - _er_camy) * _cam_scale;
    draw_set_color(_dm.color);
    draw_set_alpha(_ma * 0.48);
    draw_line_width(_gx4 - _dm.xspeed * 2.4 * _cam_scale,
                    _gy4 - _dm.yspeed * 2.4 * _cam_scale,
                    _gx4, _gy4, max(1, _dm.size * 1.5 * _cam_scale));
    draw_set_color(c_white);
    draw_set_alpha(_ma * _ma * 0.55);
    draw_circle(_gx4, _gy4, max(0.5, _dm.size * 0.45 * _cam_scale), false);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

with(oRedLightningOrb) { scr_draw_lightning_bolt(line_target_x, line_target_y, line_life, line_life_max, 6, true); }
with(oRedOrb_2) {
  if (chain_line_life > 0 && instance_exists(chain_prev_orb)) {
    var _cl_dist = point_distance(x, y, chain_prev_orb.x, chain_prev_orb.y);
    var _cl_seg = clamp(chain_jag + round(_cl_dist / 90), 4, 8);
    var _cl_jit = clamp(8 + _cl_dist * 0.06, 8, 40);
    scr_draw_lightning_bolt(chain_prev_orb.x, chain_prev_orb.y, chain_line_life, chain_line_life_max, _cl_seg, true,
                            chain_color, 0.1, _cl_jit, "chain_" + string(id), 2);
  }
  scr_draw_lightning_bolt(line_target_x, line_target_y, line_life, line_life_max, 4, false);
}

with (oLaserOrbTrigger) {
  other.lightning_bloom_boost += 0.02 + (beam_heat / _k_beam_heat_max) * 0.05;
}

if (cube_active || array_length(cube_arcs) > 0 || array_length(cube_leaks) > 0) {
  var _cb_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _cb_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _cb_cx = oCameraController.current_cam_x;
  var _cb_cy = oCameraController.current_cam_y;

  var _cb_gcx = (cube_center_x - _cb_cx) * _cb_sx;
  var _cb_gcy = (cube_center_y - _cb_cy) * _cb_sy;

  gpu_set_blendmode(bm_add);

  if (array_length(big_cube_projected) >= 8) {
    draw_set_color(c_white);
    for (var e = 0; e < array_length(cube_edges); e++) {
      var _edge = cube_edges[e];
      var _bv1 = big_cube_projected[_edge[0]];
      var _bv2 = big_cube_projected[_edge[1]];

      var _b1x = (lerp(cube_center_x, _bv1.x, cube_extend) - _cb_cx) * _cb_sx;
      var _b1y = (lerp(cube_center_y, _bv1.y, cube_extend) - _cb_cy) * _cb_sy;
      var _b2x = (lerp(cube_center_x, _bv2.x, cube_extend) - _cb_cx) * _cb_sx;
      var _b2y = (lerp(cube_center_y, _bv2.y, cube_extend) - _cb_cy) * _cb_sy;

      draw_set_alpha(0.08 + cube_edge_surge * 0.10 + cube_heartbeat * 0.06);
      draw_line_width(_b1x, _b1y, _b2x, _b2y, (3 + cube_edge_surge * 5) * _cb_sx);
    }
    draw_set_alpha(1);
  }

  if (array_length(big_cube_projected) >= 8) {
    for (var a = 0; a < array_length(cube_arcs); a++) {
      var _ac = cube_arcs[a];
      var _aa = _ac.life / _ac.life_max;
      if (_aa <= 0) continue;

      var _av = big_cube_projected[_ac.a];
      var _ax1 = (lerp(cube_center_x, _av.x, cube_extend) - _cb_cx) * _cb_sx;
      var _ay1 = (lerp(cube_center_y, _av.y, cube_extend) - _cb_cy) * _cb_sy;

      var _ax2, _ay2;
      if (_ac.inner && array_length(small_cube_projected) >= 8) {
        var _iv = small_cube_projected[_ac.b];
        _ax2 = (_iv.x - _cb_cx) * _cb_sx;
        _ay2 = (_iv.y - _cb_cy) * _cb_sy;
      } else {
        var _bv = big_cube_projected[_ac.b];
        _ax2 = (lerp(cube_center_x, _bv.x, cube_extend) - _cb_cx) * _cb_sx;
        _ay2 = (lerp(cube_center_y, _bv.y, cube_extend) - _cb_cy) * _cb_sy;
      }

      scr_draw_energy_bolt(_ax1, _ay1, _ax2, _ay2, _aa * 0.95,
                           merge_color(global.lightning_color, c_white, _ac.hot),
                           _ac.off, _ac.width * _cb_sx, 0.8);
    }
  }

  if (array_length(big_cube_projected) >= 8) {
    for (var l = 0; l < array_length(cube_leaks); l++) {
      var _lk = cube_leaks[l];
      var _la = _lk.life / _lk.life_max;
      if (_la <= 0) continue;

      var _lv = big_cube_projected[_lk.vert];
      var _lx1 = lerp(cube_center_x, _lv.x, cube_extend);
      var _ly1 = lerp(cube_center_y, _lv.y, cube_extend);
      var _lreach = _lk.reach * (1.15 - _la * 0.45);
      var _lx2 = _lx1 + lengthdir_x(_lreach, _lk.ang);
      var _ly2 = _ly1 + lengthdir_y(_lreach, _lk.ang);

      scr_draw_energy_bolt((_lx1 - _cb_cx) * _cb_sx, (_ly1 - _cb_cy) * _cb_sy,
                           (_lx2 - _cb_cx) * _cb_sx, (_ly2 - _cb_cy) * _cb_sy,
                           _la * 0.85, merge_color(global.lightning_color, c_white, 0.55),
                           _lk.off, 1.3 * _cb_sx, 0.85);
    }
  }

  if (cube_core_flash > 0.35 && array_length(big_cube_projected) >= 8) {
    var _disch = round(clamp(cube_core_flash * 4, 1, 6));
    for (var d = 0; d < _disch; d++) {
      var _dv = big_cube_projected[(d * 3) mod 8];
      scr_draw_energy_bolt(_cb_gcx, _cb_gcy,
                           (lerp(cube_center_x, _dv.x, cube_extend) - _cb_cx) * _cb_sx,
                           (lerp(cube_center_y, _dv.y, cube_extend) - _cb_cy) * _cb_sy,
                           clamp(cube_core_flash, 0, 1) * 0.7,
                           merge_color(global.lightning_color, c_white, 0.75),
                           scr_bolt_offsets(5, 10 + cube_core_flash * 14),
                           (1.2 + cube_core_flash) * _cb_sx, 0.85);
    }
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (instance_number(oCubeFaceBullet) > 0) {
  var _fb_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _fb_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _fb_cx = oCameraController.current_cam_x;
  var _fb_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);

  with (oCubeFaceBullet) {
    if (bullet_mode == "grid") continue;
    if (speed_now < 0.4 || image_alpha < 0.08) continue;

    var _bd = point_direction(0, 0, vel_x, vel_y);
    var _blen = clamp(speed_now * 5.5, 6, 90) * image_xscale;
    var _bw = (1.0 + image_xscale * 1.4) * _fb_sx;

    var _hx = (x - _fb_cx) * _fb_sx;
    var _hy = (y - _fb_cy) * _fb_sy;
    var _tx = ((x - lengthdir_x(_blen, _bd)) - _fb_cx) * _fb_sx;
    var _ty = ((y - lengthdir_y(_blen, _bd)) - _fb_cy) * _fb_sy;

    var _ba = image_alpha * (0.5 + heat * 0.5);
    var _bcol = merge_color(global.avoid_col_danger, c_white, 0.35 + heat * 0.4);

    var _bp = _bd + 90;
    var _bfr = clamp(speed_now * 0.5, 0.5, 4) * _fb_sx;

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(_ba * 0.4);
    draw_line_width(_tx + lengthdir_x(_bfr, _bp), _ty + lengthdir_y(_bfr, _bp),
                    _hx + lengthdir_x(_bfr, _bp), _hy + lengthdir_y(_bfr, _bp), _bw * 1.1);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_ba * 0.4);
    draw_line_width(_tx - lengthdir_x(_bfr, _bp), _ty - lengthdir_y(_bfr, _bp),
                    _hx - lengthdir_x(_bfr, _bp), _hy - lengthdir_y(_bfr, _bp), _bw * 1.1);

    draw_set_color(_bcol);
    draw_set_alpha(_ba * 0.35);
    draw_line_width(_tx, _ty, _hx, _hy, _bw * 3.5);
    draw_set_color(merge_color(_bcol, c_white, 0.6));
    draw_set_alpha(_ba);
    draw_line_width(_tx, _ty, _hx, _hy, _bw);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (cube_active) {
  var _k_boundary_ring_points = 40;
  var _k_boundary_ring_base_intensity = 0.25;
  var _k_boundary_ring_push_intensity = 1.0;

  var gui_cx =
      (cube_center_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var gui_cy =
      (cube_center_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _gui_radius = (cube_size_base * 0.9) * (oCameraController.base_view_w / oCameraController.current_cam_w);

  _gui_radius *= (1 + cube_heartbeat * 0.03 - cube_coil * 0.05);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

  var _cube_bound_col = merge_color(global.avoid_col_cyan, global.avoid_col_danger,
                                    clamp(cube_overload * 0.65 + cube_boundary_push_amount * 0.25, 0, 0.85));
  shader_set_uniform_f(global.u_glow_color, color_get_red(_cube_bound_col) / 255,
                       color_get_green(_cube_bound_col) / 255, color_get_blue(_cube_bound_col) / 255);
  shader_set_uniform_f(global.u_glow_intensity,
                       lerp(_k_boundary_ring_base_intensity, _k_boundary_ring_push_intensity, cube_boundary_push_amount) +
                       cube_heartbeat * 0.25 + cube_overload * 0.35);
  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var i = 0; i < _k_boundary_ring_points; i++) {
    var _ang = i * (360 / _k_boundary_ring_points);
    var _px = gui_cx + lengthdir_x(_gui_radius, _ang);
    var _py = gui_cy + lengthdir_y(_gui_radius, _ang);
    draw_sprite_ext(spr_glow_blob, 0, _px, _py, 0.35, 0.35, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

with(oBlackHole) {
  draw_set_color(c_white);
  draw_set_alpha(0.12 * spawn_scale);
  draw_circle(x, y, ring_radius * 0.9 * spawn_scale, false);
  draw_set_alpha(1);
  scr_draw_smooth_ring_mask(x, y, core_radius * 0.5 * spawn_scale, 0.35 * spawn_scale, core_radius * 1.5 * spawn_scale);

  for (var i = 0; i < array_length(pulse_waves); i++) {
    var _radius = pulse_waves[i][0];
    var _alpha = pulse_waves[i][1];
    scr_draw_smooth_ring_mask(x, y, _radius, _alpha * 0.9, 14);
  }

  for (var i = 0; i < array_length(storm_bolts); i++) {
    var _b = storm_bolts[i];
    scr_draw_lightning_arc(x, y, _b[2], _b[0], _b[1], _b[3], _b[4],
                           oAvoidanceController.blackhole_push_mode ? c_white : global.lightning_color);
  }
}
with(oBlackHoleTelegraph) { scr_draw_smooth_ring_mask(x, y, 20 + seam_length * 0.25, current_alpha * 0.4, 20); }


if (array_length(bh_infall_streaks) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_infall_streaks); i++) {
    var _is = bh_infall_streaks[i];
    var _isa = clamp(1 - (_is.dist / 700), 0, 1);
    var _hx2 = _is.tx + lengthdir_x(_is.dist, _is.ang);
    var _hy2 = _is.ty + lengthdir_y(_is.dist, _is.ang);
    var _tx3 = _is.tx + lengthdir_x(_is.dist + _is.len, _is.ang);
    var _ty3 = _is.ty + lengthdir_y(_is.dist + _is.len, _is.ang);

    draw_set_color(global.lightning_color);
    draw_set_alpha(_isa * 0.45);
    draw_line_width(_tx3, _ty3, _hx2, _hy2, 3.5);
    draw_set_color(c_white);
    draw_set_alpha(_isa * 0.8);
    draw_line_width(_tx3, _ty3, _hx2, _hy2, 1.2);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

var _forge_vis = max(max(bh_forge_charge, bh_forge_flash), bh_forge_pulse);
if (_forge_vis > 0.01) {
  gpu_set_blendmode(bm_add);

  var _forge_dim = _k_bh_forge_draw_mult;
  var _fcx = _k_bh_forge_center_x;
  var _fcy = _k_bh_forge_center_y;
  var _fheat = clamp(bh_forge_charge + bh_forge_flash * 0.65 + bh_forge_pulse * 0.35, 0, 1.6);
  var _fcol = merge_color(global.lightning_color, c_white, clamp(0.35 + _fheat * 0.36, 0, 1));
  var _fhot = merge_color(make_color_rgb(255, 48, 38), c_white, clamp(0.35 + _fheat * 0.4, 0, 1));
  var _spin = current_time * 0.035;

  for (var _r = 0; _r < 3; _r++) {
    var _rr = 28 + _r * 34 + bh_forge_pulse * (26 + _r * 10);
    scr_draw_smooth_ring_mask(_fcx, _fcy, _rr, (0.18 + bh_forge_flash * 0.28 + bh_forge_pulse * 0.22) * (1 - _r * 0.22) * _forge_dim,
                              5 + _r * 3, (_r == 0) ? c_white : _fcol);
  }

  for (var _sp = 0; _sp < 12; _sp++) {
    var _ang = _spin + _sp * 30 + sin(current_time * 0.006 + _sp) * (4 + _fheat * 5);
    var _r0 = 14 + sin(current_time * 0.01 + _sp) * 4;
    var _major_spoke = ((_sp mod 3) == 0);
    var _r1 = 58 + bh_forge_charge * 78 + (_major_spoke ? 36 : 0);
    var _sx = _fcx + lengthdir_x(_r0, _ang);
    var _sy = _fcy + lengthdir_y(_r0, _ang);
    var _ex = _fcx + lengthdir_x(_r1, _ang);
    var _ey = _fcy + lengthdir_y(_r1, _ang);

    draw_set_color(_fhot);
    draw_set_alpha((0.1 + bh_forge_charge * 0.18 + bh_forge_pulse * 0.28) * (_major_spoke ? 1.5 : 1) * _forge_dim);
    draw_line_width(_sx, _sy, _ex, _ey, 3.5 + bh_forge_flash * 5);
    draw_set_color(c_white);
    draw_set_alpha((0.12 + bh_forge_flash * 0.35 + bh_forge_pulse * 0.25) * (1 - (_sp mod 2) * 0.35) * _forge_dim);
    draw_line_width(_sx, _sy, _ex, _ey, 1 + bh_forge_flash * 1.4);
  }

  draw_set_color(c_white);
  draw_set_alpha((0.25 + bh_forge_flash * 0.6 + bh_forge_pulse * 0.3) * _forge_dim);
  draw_line_width(_fcx, _fcy - (44 + bh_forge_charge * 92), _fcx, _fcy + (44 + bh_forge_charge * 92),
                  1.6 + bh_forge_flash * 4);
  draw_set_color(_fhot);
  draw_set_alpha((0.18 + bh_forge_charge * 0.26 + bh_forge_flash * 0.36) * _forge_dim);
  draw_line_width(_fcx - 130 * bh_forge_charge, _fcy, _fcx + 130 * bh_forge_charge, _fcy,
                  3 + bh_forge_flash * 6);

  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _fg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _fg_uvs[0], _fg_uvs[1], _fg_uvs[2], _fg_uvs[3]);
  shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 1, bh_forge_charge), lerp(0.18, 1, bh_forge_charge));
  shader_set_uniform_f(global.u_glow_intensity, (0.55 + _fheat * 0.75) * _forge_dim);
  shader_set_uniform_f(global.u_glow_falloff, 1.35);
  draw_sprite_ext(spr_glow_blob, 0, _fcx, _fcy, 0.55 + _fheat * 0.55, 0.55 + _fheat * 0.55, 0, c_white, 1);
  shader_reset();
  gpu_set_blendequation(bm_eq_add);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_forge_arcs) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_forge_arcs); i++) {
    var _fa = bh_forge_arcs[i];
    var _faa = _fa.life / _fa.life_max;
    scr_draw_energy_bolt(_fa.x1, _fa.y1, _fa.x2, _fa.y2, _faa * _faa * 0.9 * _k_bh_forge_draw_mult,
                         _fa.color, _fa.off, max(1, _fa.width * 0.72), 0.42);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_forge_motes) > 0) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _fm_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _fm_uvs[0], _fm_uvs[1], _fm_uvs[2], _fm_uvs[3]);
  for (var i = 0; i < array_length(bh_forge_motes); i++) {
    var _fm2 = bh_forge_motes[i];
    var _fma = _fm2.life / _fm2.life_max;
    var _fm_col = merge_color(make_color_rgb(255, 50, 42), c_white, 0.28 + _fm2.hot * 0.62);
    shader_set_uniform_f(global.u_glow_color, color_get_red(_fm_col) / 255, color_get_green(_fm_col) / 255,
                         color_get_blue(_fm_col) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _fma * (0.55 + _fm2.hot * 0.65) * _k_bh_forge_draw_mult);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, _fm2.x, _fm2.y, _fm2.size * 0.12, _fm2.size * 0.12, 0, c_white, 1);
  }
  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_forge_slashes) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_forge_slashes); i++) {
    var _fs = bh_forge_slashes[i];
    var _fsa = _fs.life / _fs.life_max;
    var _fsp = 1 - _fsa;
    var _reach = 1 - power(1 - min(1, _fsp * 2.4), 3);
    var _half = _fs.len * 0.5 * _reach;
    var _x1 = _fs.x - lengthdir_x(_half, _fs.ang);
    var _y1 = _fs.y - lengthdir_y(_half, _fs.ang);
    var _x2 = _fs.x + lengthdir_x(_half, _fs.ang);
    var _y2 = _fs.y + lengthdir_y(_half, _fs.ang);
    var _perp = _fs.ang + 90;
    var _coff = 2.5 + _fs.hot * 4;

    draw_set_color(c_red);
    draw_set_alpha(_fsa * 0.35 * _k_bh_forge_draw_mult);
    draw_line_width(_x1 + lengthdir_x(_coff, _perp), _y1 + lengthdir_y(_coff, _perp),
                    _x2 + lengthdir_x(_coff, _perp), _y2 + lengthdir_y(_coff, _perp), _fs.width * 1.2);
    draw_set_color(c_aqua);
    draw_set_alpha(_fsa * 0.28 * _k_bh_forge_draw_mult);
    draw_line_width(_x1 - lengthdir_x(_coff, _perp), _y1 - lengthdir_y(_coff, _perp),
                    _x2 - lengthdir_x(_coff, _perp), _y2 - lengthdir_y(_coff, _perp), _fs.width * 0.9);

    draw_set_color(_fs.color);
    draw_set_alpha(_fsa * _fsa * 0.65 * _k_bh_forge_draw_mult);
    draw_line_width(_x1, _y1, _x2, _y2, _fs.width * (1.6 + bh_forge_flash * 0.4));
    draw_set_color(c_white);
    draw_set_alpha(_fsa * _fsa * 0.85 * _k_bh_forge_draw_mult);
    draw_line_width(_x1, _y1, _x2, _y2, max(1.2, _fs.width * 0.32));

    var _drip_n = 3 + floor(_fs.hot * 4);
    for (var _dr = 0; _dr < _drip_n; _dr++) {
      var _dt = (_dr + 0.5) / _drip_n;
      var _dx = lerp(_x1, _x2, _dt) + sin(_fs.seed + _dr * 2.1) * 8;
      var _dy = lerp(_y1, _y2, _dt) + cos(_fs.seed + _dr * 1.7) * 5;
      var _dl = (1 - _fsa) * (12 + _fs.hot * 20) * (0.35 + frac(abs(sin(_fs.seed + _dr)) * 43758.5453));
      draw_set_color(merge_color(make_color_rgb(255, 45, 35), c_white, 0.22 + _fs.hot * 0.35));
      draw_set_alpha(_fsa * 0.42 * _k_bh_forge_draw_mult);
      draw_line_width(_dx, _dy, _dx + lengthdir_x(_dl, _fs.ang + 90), _dy + lengthdir_y(_dl, _fs.ang + 90),
                      max(1, _fs.width * 0.18));
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

var _wave_gate_vis = max(bh_wave_gate_charge, bh_wave_gate_flash);
if (array_length(bh_wave_conduits) > 0 || array_length(bh_wave_sparks) > 0 || _wave_gate_vis > 0.01) {
  gpu_set_blendmode(bm_add);
  var _gate_dim = _k_bh_forge_draw_mult;
  var _gate_y = room_height + 24;
  var _gate_col = merge_color(make_color_rgb(255, 50, 38), c_white, clamp(0.2 + _wave_gate_vis * 0.55, 0, 1));
  var _gate_hot = merge_color(_gate_col, c_white, 0.75);

  for (var i = 0; i < array_length(bh_wave_conduits); i++) {
    var _wc = bh_wave_conduits[i];
    var _wca = _wc.life / _wc.life_max;
    var _wcp = 1 - _wca;
    var _open = 1 - power(1 - min(1, _wcp * 2.2), 3);
    var _lx2 = lerp(_wc.x1, _wc.x2, _open);
    var _ly2 = lerp(_wc.y1, _wc.y2, _open);
    var _pulse = 0.72 + 0.28 * sin(current_time * 0.02 + _wc.pulse);

    scr_draw_energy_bolt(_wc.x1, _wc.y1, _lx2, _ly2, _wca * _wca * 0.78 * _pulse * _gate_dim,
                         _wc.color, _wc.off, max(1, _wc.width), 0.45);

    draw_set_color(merge_color(make_color_rgb(255, 36, 30), _wc.color, 0.35));
    draw_set_alpha(_wca * 0.28 * _pulse * _gate_dim);
    draw_line_width(_wc.x1, _wc.y1, _lx2, _ly2, _wc.width * 3.4);

    var _packet_t = frac(_wcp * 1.8 + _wc.pulse);
    var _px = lerp(_wc.x1, _wc.x2, _packet_t);
    var _py = lerp(_wc.y1, _wc.y2, _packet_t);
    draw_set_color(c_white);
    draw_set_alpha(_wca * 0.7 * _gate_dim);
    draw_circle(_px, _py, 3 + _wc.width * 0.7, false);
  }

  if (array_length(bh_wave_sparks) > 0) {
    for (var i = 0; i < array_length(bh_wave_sparks); i++) {
      var _spk = bh_wave_sparks[i];
      var _ska = _spk.life / _spk.life_max;
      var _scol = merge_color(make_color_rgb(255, 48, 38), c_white, 0.28 + _spk.hot * 0.58);

      draw_set_color(_scol);
      draw_set_alpha(_ska * 0.42 * _gate_dim);
      draw_line_width(_spk.x - _spk.vx * 4, _spk.y - _spk.vy * 4, _spk.x, _spk.y, max(1, _spk.size * 0.7));
    }

    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _wuv = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _wuv[0], _wuv[1], _wuv[2], _wuv[3]);
    for (var i = 0; i < array_length(bh_wave_sparks); i++) {
      var _spk = bh_wave_sparks[i];
      var _ska = _spk.life / _spk.life_max;
      var _scol = merge_color(make_color_rgb(255, 48, 38), c_white, 0.28 + _spk.hot * 0.58);

      shader_set_uniform_f(global.u_glow_color, color_get_red(_scol) / 255, color_get_green(_scol) / 255,
                           color_get_blue(_scol) / 255);
      shader_set_uniform_f(global.u_glow_intensity, _ska * (0.55 + _spk.hot * 0.8) * _gate_dim);
      shader_set_uniform_f(global.u_glow_falloff, 1.45);
      draw_sprite_ext(spr_glow_blob, 0, _spk.x, _spk.y, _spk.size * 0.11, _spk.size * 0.11, 0, c_white, 1);
    }
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
  }

  if (_wave_gate_vis > 0.01) {
    var _gate_a = clamp(_wave_gate_vis, 0, 1.35);
    var _gate_open = 1 - power(1 - clamp(bh_wave_gate_charge, 0, 1), 3);
    var _gate_half = lerp(90, room_width * 0.58, _gate_open);
    var _gate_wobble = sin(current_time * 0.025) * (4 + _wave_gate_vis * 10);

    draw_set_color(merge_color(make_color_rgb(120, 0, 0), _gate_col, 0.55));
    draw_set_alpha(_gate_a * 0.25 * _gate_dim);
    draw_line_width(room_width / 2 - _gate_half, _gate_y + _gate_wobble,
                    room_width / 2 + _gate_half, _gate_y - _gate_wobble,
                    20 + bh_wave_gate_flash * 20);
    draw_set_color(_gate_col);
    draw_set_alpha(_gate_a * 0.55 * _gate_dim);
    draw_line_width(room_width / 2 - _gate_half, _gate_y,
                    room_width / 2 + _gate_half, _gate_y,
                    7 + bh_wave_gate_flash * 12);
    draw_set_color(c_white);
    draw_set_alpha(_gate_a * _gate_a * 0.75 * _gate_dim);
    draw_line_width(room_width / 2 - _gate_half * 0.94, _gate_y,
                    room_width / 2 + _gate_half * 0.94, _gate_y,
                    1.8 + bh_wave_gate_flash * 3);

    var _tooth_n = 22;
    for (var _gt = 0; _gt < _tooth_n; _gt++) {
      var _tt = (_gt + 0.5) / _tooth_n;
      var _tx = room_width / 2 - _gate_half + _gate_half * 2 * _tt;
      var _th = (12 + sin(current_time * 0.015 + _gt * 1.7) * 6 + bh_wave_gate_flash * 28) * _gate_open;
      if (_th <= 1) continue;
      draw_set_color(_gate_col);
      draw_set_alpha(_gate_a * 0.32 * _gate_dim);
      draw_line_width(_tx, _gate_y, _tx + sin(_gt * 2.1) * 5, _gate_y - _th, 3);
      draw_set_color(c_white);
      draw_set_alpha(_gate_a * 0.4 * _gate_dim);
      draw_line_width(_tx, _gate_y, _tx + sin(_gt * 2.1) * 5, _gate_y - _th * 0.7, 1);
    }

    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _guv = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _guv[0], _guv[1], _guv[2], _guv[3]);
    shader_set_uniform_f(global.u_glow_color, 1, 0.35 + _wave_gate_vis * 0.35, 0.28 + _wave_gate_vis * 0.35);
    shader_set_uniform_f(global.u_glow_intensity, (0.7 + bh_wave_gate_flash * 1.8 + bh_wave_gate_charge * 0.8) * _gate_dim);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, room_width / 2, _gate_y, 3.8 + _gate_open * 5.2, 0.42 + _gate_a * 0.45, 0, c_white, 1);
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_edge_waves) > 0) {
  gpu_set_blendmode(bm_add);
  var _edge_wave_dim = kunai_edge_wave_mult * _k_bh_finale_edge_draw_mult;
  for (var i = 0; i < array_length(bh_edge_waves); i++) {
    var _w2 = bh_edge_waves[i];
    var _wl = _w2.life / _w2.life_max;
    var _wcol = merge_color(make_color_rgb(255, 62, 45), c_white, 0.3 + _w2.hue * 0.5);
    var _whot = merge_color(_wcol, c_white, 0.7);

    var _band_a = clamp(_w2.age / 5, 0, 1) * _wl * _wl * _w2.power;
    if (_band_a > 0.01) {
      var _band_d = (54 + _w2.hue * 46) * (0.5 + _wl * 0.5);
      var _bseg = 26;
      draw_primitive_begin(pr_trianglestrip);
      for (var b = 0; b <= _bseg; b++) {
        var _bx = (b / _bseg) * room_width;
        var _falloff = 1 - clamp(abs(_bx - _w2.origin_x) / (room_width * 0.75), 0, 1) * 0.55;
        draw_vertex_color(_bx, _w2.edge_y, _whot, _band_a * 0.9 * _falloff * _edge_wave_dim);
        draw_vertex_color(_bx, _w2.edge_y + _w2.dir * _band_d * _falloff, _wcol, 0);
      }
      draw_primitive_end();
    }

    for (var c = 0; c < array_length(_w2.columns); c++) {
      var _cc = _w2.columns[c];
      var _cp = _w2.age - _cc.delay;
      if (_cp <= 0) continue;

      var _rise = 1 - power(1 - clamp(_cp / 9, 0, 1), 3);
      var _fade = clamp(1 - (_cp - 9) / 34, 0, 1) * _w2.power;
      if (_fade <= 0.01) continue;

      var _h = _cc.height * _rise;
      var _steps = 6;

      draw_primitive_begin(pr_trianglestrip);
      for (var st = 0; st <= _steps; st++) {
        var _t3 = st / _steps;
        var _yy = _w2.edge_y + _w2.dir * _h * _t3;
        var _hw = _cc.width * (1 - _t3 * 0.88) * 0.5;
        var _sway = sin(_t3 * 3.1 + _cc.seed) * _cc.jag * _t3 * _t3;
        var _a2 = (1 - _t3 * 0.72) * _fade;
        draw_vertex_color(_cc.x - _hw + _sway, _yy, _wcol, _a2 * 0.75 * _edge_wave_dim);
        draw_vertex_color(_cc.x + _hw + _sway, _yy, _wcol, _a2 * 0.75 * _edge_wave_dim);
      }
      draw_primitive_end();

      var _tip_sway = sin(3.1 + _cc.seed) * _cc.jag;
      draw_set_color(_whot);
      draw_set_alpha(_fade * 0.9 * _edge_wave_dim);
      draw_line_width(_cc.x, _w2.edge_y, _cc.x + _tip_sway, _w2.edge_y + _w2.dir * _h,
                      max(1, _cc.width * 0.22));

      draw_set_color(c_white);
      draw_set_alpha(_fade * _rise * 0.8 * _edge_wave_dim);
      draw_circle(_cc.x, _w2.edge_y, _cc.width * 0.5 * _rise, false);
    }

    var _shock_d = _w2.age * 34;
    if (_shock_d < room_width && _wl > 0.15) {
      var _sa2 = _wl * _wl * 0.9 * _w2.power * _edge_wave_dim;
      for (var sgn = -1; sgn <= 1; sgn += 2) {
        var _sx3 = _w2.origin_x + sgn * _shock_d;
        if (_sx3 < -40 || _sx3 > room_width + 40) continue;
        draw_set_color(c_white);
        draw_set_alpha(_sa2);
        draw_line_width(_sx3, _w2.edge_y, _sx3, _w2.edge_y + _w2.dir * (34 + _w2.hue * 26), 4);
        draw_set_color(_wcol);
        draw_set_alpha(_sa2 * 0.5);
        draw_line_width(_sx3, _w2.edge_y, _sx3, _w2.edge_y + _w2.dir * (70 + _w2.hue * 50), 12);
      }
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_kunai_bursts) > 0) {
  gpu_set_blendmode(bm_add);
  var _burst_dim = kunai_burst_flash_mult * _k_bh_finale_burst_draw_mult;
  for (var i = 0; i < array_length(bh_kunai_bursts); i++) {
    var _kb = bh_kunai_bursts[i];
    var _ka = _kb.life / _kb.life_max;
    var _kp = 1 - _ka;
    var _kcol = merge_color(make_color_rgb(255, 60, 45), c_white, 0.35 + _kb.hue * 0.55);

    if (_kb.band > 0) {
      var _bh2 = _kb.band;
      var _run = (1 - _ka) * 300;

      draw_set_color(_kcol);
      draw_set_alpha(_ka * _ka * 0.7 * _kb.power * _burst_dim);
      draw_line_width(_kb.x, _kb.y - _bh2, _kb.x, _kb.y + _bh2, 10 + _ka * 14);
      draw_set_color(c_white);
      draw_set_alpha(_ka * _ka * 0.95 * _kb.power * _burst_dim);
      draw_line_width(_kb.x, _kb.y - _bh2, _kb.x, _kb.y + _bh2, 2.5 + _ka * 4);

      for (var sgn2 = -1; sgn2 <= 1; sgn2 += 2) {
        var _fx2 = _kb.x + sgn2 * _run;
        draw_set_color(_kcol);
        draw_set_alpha(_ka * 0.5 * _kb.power * _burst_dim);
        draw_line_width(_kb.x, _kb.y, _fx2, _kb.y, _bh2 * 1.5 * _ka);
        draw_set_color(c_white);
        draw_set_alpha(_ka * _ka * 0.8 * _kb.power * _burst_dim);
        draw_line_width(_kb.x, _kb.y, _fx2, _kb.y, 3 * _ka);
      }

      draw_set_color(c_white);
      draw_set_alpha(_ka * _ka * 0.5 * _burst_dim);
      draw_line_width(_kb.x - _run * 1.3, _kb.y, _kb.x + _run * 1.3, _kb.y, 1.5);

      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      var _buv = sprite_get_uvs(spr_glow_blob, 0);
      shader_set_uniform_f(global.u_glow_uvrect, _buv[0], _buv[1], _buv[2], _buv[3]);
      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, _ka * _ka * 1.8 * _kb.power * _burst_dim);
      shader_set_uniform_f(global.u_glow_falloff, 1.4);
      draw_sprite_ext(spr_glow_blob, 0, _kb.x, _kb.y, 1.1 + _ka * 1.6, (_bh2 / 64) * 2.6, 0, c_white, 1);
      shader_reset();
      gpu_set_blendequation(bm_eq_add);

      continue;
    }

    var _reach = 1 - power(1 - min(1, _kp * 2.2), 3);
    for (var sp = 0; sp < array_length(_kb.spikes); sp++) {
      var _s = _kb.spikes[sp];
      var _len = _s.len * _reach;
      var _ex = _kb.x + lengthdir_x(_len, _s.ang);
      var _ey = _kb.y + lengthdir_y(_len, _s.ang);
      var _bx = _kb.x + lengthdir_x(_len * 0.15, _s.ang);
      var _by = _kb.y + lengthdir_y(_len * 0.15, _s.ang);

      draw_set_color(_kcol);
      draw_set_alpha(_ka * _ka * 0.5 * _kb.power * _burst_dim);
      draw_line_width(_bx, _by, _ex, _ey, _s.w * 2.2);
      draw_set_color(c_white);
      draw_set_alpha(_ka * _ka * 0.85 * _kb.power * _burst_dim);
      draw_line_width(_bx, _by, _ex, _ey, _s.w * 0.8);
    }

    var _edge_burst = (_kb.edge != 0);
    var _kr = 20 + _kp * (170 + _kb.hue * 190) * (_edge_burst ? 2.1 : 1);
    scr_draw_smooth_ring_mask(_kb.x, _kb.y, _kr, _ka * 0.5 * _kb.power * _burst_dim, 10 + _kb.hue * 8, _kcol);
    draw_set_color(c_white);
    draw_set_alpha(_ka * _ka * 0.7 * _burst_dim);
    draw_circle(_kb.x, _kb.y, _kr, true);

    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _kuv = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _kuv[0], _kuv[1], _kuv[2], _kuv[3]);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _ka * _ka * 2.2 * _kb.power * (_edge_burst ? 1.35 : 1) * _burst_dim);
    shader_set_uniform_f(global.u_glow_falloff, 1.3);
    var _kgs = (1.2 + _kb.hue * 1.1) * (0.5 + _ka * 0.9);
    draw_sprite_ext(spr_glow_blob, 0, _kb.x, _kb.y, _kgs * (_edge_burst ? 2.4 : 1), _kgs, 0, c_white, 1);
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_inversion_rings) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_inversion_rings); i++) {
    var _ir = bh_inversion_rings[i];
    var _ia2 = _ir.life / _ir.life_max;
    var _irdim = variable_struct_exists(_ir, "dim") ? _ir.dim : 1;
    scr_draw_smooth_ring_mask(_ir.x, _ir.y, max(1, _ir.radius), _ia2 * 0.6 * _irdim, _ir.width, _ir.color);
    draw_set_color(merge_color(_ir.color, c_white, _ir.hot));
    draw_set_alpha(_ia2 * _ia2 * 0.9 * _irdim);
    draw_circle(_ir.x, _ir.y, max(1, _ir.radius), true);
    draw_set_alpha(_ia2 * _ia2 * 0.55 * _irdim);
    draw_circle(_ir.x, _ir.y, max(1, _ir.radius - 2), true);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_horizon_cracks) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_horizon_cracks); i++) {
    var _hc = bh_horizon_cracks[i];
    var _hca = _hc.life / _hc.life_max;
    var _hsegs = 5;
    var _px = _hc.x, _py = _hc.y;
    for (var s = 1; s <= _hsegs; s++) {
      var _ht = s / _hsegs;
      var _jit = (s == _hsegs) ? 0 : sin(_hc.seed + s * 1.9) * 8 * _ht;
      var _nx = _hc.x + lengthdir_x(_hc.len * _ht, _hc.ang) + lengthdir_x(_jit, _hc.ang + 90);
      var _ny = _hc.y + lengthdir_y(_hc.len * _ht, _hc.ang) + lengthdir_y(_jit, _hc.ang + 90);
      draw_set_color(blackhole_push_mode ? c_white : global.lightning_color);
      draw_set_alpha(_hca * 0.5 * (1 - _ht * 0.65));
      draw_line_width(_px, _py, _nx, _ny, 5);
      draw_set_color(c_white);
      draw_set_alpha(_hca * 0.85 * (1 - _ht * 0.65));
      draw_line_width(_px, _py, _nx, _ny, 1.6);
      _px = _nx;
      _py = _ny;
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_swallow_flashes) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(bh_swallow_flashes); i++) {
    var _sf = bh_swallow_flashes[i];
    var _sfa = _sf.life / _sf.life_max;
    var _sfe = _sfa * _sfa;

    var _spokes = 5;
    for (var k = 0; k < _spokes; k++) {
      var _sa2 = _sf.ang + (k - (_spokes - 1) * 0.5) * 17;
      var _slen = (1 - _sfa) * 46 + 8;
      draw_set_color(_sf.color);
      draw_set_alpha(_sfe * 0.5);
      draw_line_width(_sf.x + lengthdir_x(6, _sa2), _sf.y + lengthdir_y(6, _sa2),
                      _sf.x + lengthdir_x(_slen, _sa2), _sf.y + lengthdir_y(_slen, _sa2), 3);
    }
    scr_draw_smooth_ring_mask(_sf.x, _sf.y, 10 + (1 - _sfa) * 34, _sfe * 0.5, 7, _sf.color);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(bh_ambient_arcs) > 0) {
  gpu_set_blendmode(bm_add);
  var _aa_count = instance_number(oBlackHole);
  if (_aa_count >= 2) {
    var _aah1 = instance_find(oBlackHole, 0);
    var _aah2 = instance_find(oBlackHole, 1);
    for (var i = 0; i < array_length(bh_ambient_arcs); i++) {
      var _ab = bh_ambient_arcs[i];
      scr_draw_energy_bolt(_aah1.x, _aah1.y, _aah2.x, _aah2.y, (_ab.life / _ab.life_max) * 0.8, _ab.color, _ab.off, 2.4,
                           0.7);
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (instance_number(oBlackHole) >= 2)
{
  var _bh1 = instance_find(oBlackHole, 0);
  var _bh2 = instance_find(oBlackHole, 1);

  var _tp1 = clamp(_bh1.spawn_scale, 0, 1) * clamp(_bh1.despawn_scale, 0, 1);
  var _tp2 = clamp(_bh2.spawn_scale, 0, 1) * clamp(_bh2.despawn_scale, 0, 1);

  var _td = point_distance(_bh1.x, _bh1.y, _bh2.x, _bh2.y);
  var _tether_range = 100;

  if (_td < _tether_range && _tp1 > 0 && _tp2 > 0)
  {
    var _tstrength = 1 - (_td / _tether_range);
    var _tpulse = 10.7 + 0.3 * sin(current_time * 0.006);
    var _tsegs = 10;
    var _perp = point_direction(_bh1.x, _bh1.y, _bh2.x, _bh2.y) + 90;

    var _gui_x1 = (_bh1.x - oCameraController.current_cam_x) *
                  (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gui_y1 = (_bh1.y - oCameraController.current_cam_y) *
                  (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _gui_x2 = (_bh2.x - oCameraController.current_cam_x) *
                  (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gui_y2 = (_bh2.y - oCameraController.current_cam_y) *
                  (oCameraController.base_view_h / oCameraController.current_cam_h);

    var _cam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

    var _prev_x = _gui_x1, _prev_y = _gui_y1;

    draw_set_color(global.lightning_color);

    for (var s = 1; s <= _tsegs; s++)
    {
      var _t = s / _tsegs;

      var _bx = lerp(_gui_x1, _gui_x2, _t);
      var _by = lerp(_gui_y1, _gui_y2, _t);

      var _jitter = (s == _tsegs) ? 0 : (sin(_t * 40 + current_time * 0.02) * 6 * _tstrength * _cam_scale);

      var _px = _bx + lengthdir_x(_jitter, _perp);
      var _py = _by + lengthdir_y(_jitter, _perp);

      draw_set_alpha(_tstrength * _tpulse * 0.7 * _tp1 * _tp2);
      draw_line_width(_prev_x, _prev_y, _px, _py, (2 + _tstrength * 2) * _cam_scale);

      _prev_x = _px;
      _prev_y = _py;
    }
  }
}

if (array_length(tidal_streams) > 0) {
  gpu_set_blendmode(bm_add);
  draw_set_color(c_white);

  for (var i = 0; i < array_length(tidal_streams); i++) {
    var _s = tidal_streams[i];

    if (!instance_exists(_s.target_id)) continue;

    var _wx1 = _s.target_id.x + lengthdir_x(_s.dist, _s.angle);
    var _wy1 = _s.target_id.y + lengthdir_y(_s.dist, _s.angle);

    var _tail_dist = _s.dist + _s.length;

    var _wx2 = _s.target_id.x + lengthdir_x(_tail_dist, _s.angle);
    var _wy2 = _s.target_id.y + lengthdir_y(_tail_dist, _s.angle);

    var _cam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

    var _gui_x1 = (_wx1 - oCameraController.current_cam_x) * _cam_scale;
    var _gui_y1 = (_wy1 - oCameraController.current_cam_y) * _cam_scale;

    var _gui_x2 = (_wx2 - oCameraController.current_cam_x) * _cam_scale;
    var _gui_y2 = (_wy2 - oCameraController.current_cam_y) * _cam_scale;

    var _fade = clamp(1 - (_s.dist / point_distance(0, _s.target_id.y, room_width, _s.target_id.y)), 0, 1);

    draw_set_alpha(0.6 * _fade);

    draw_line_width(_gui_x1, _gui_y1, _gui_x2, _gui_y2, 2 * _cam_scale);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(tidal_dust) > 0) {
  gpu_set_blendmode(bm_add);

  draw_set_color(merge_color(make_color_rgb(90, 90, 100), global.lightning_color, 0.35));

  _cam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

  for (var i = 0; i < array_length(tidal_dust); i++) {
    var _d = tidal_dust[i];

    draw_set_alpha((_d.life / _d.max_life) * 0.22);

    draw_circle((_d.x - oCameraController.current_cam_x) * _cam_scale, (_d.y - oCameraController.current_cam_y) * _cam_scale,
                _d.size * _cam_scale, false);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

var _min_inset = -10;
var _max_inset = 250;

var _duration_progress = clamp((t - 2657) / (3320 - 2657), 0, 1);

_duration_progress = _duration_progress * _duration_progress * (3 - 2 * _duration_progress);

var _combined_escalation = max(tidal_wall_escalation, _duration_progress);

var _inset_range = lerp(_min_inset, _max_inset, _combined_escalation);

var _retreat = 0;
for (var _ri = 0; _ri < array_length(bh_finale_beats); _ri++) {
  if (t >= bh_finale_beats[_ri]) _retreat = (_ri + 1) / array_length(bh_finale_beats);
}

var _rock_lights = [];
var _bh_n = instance_number(oBlackHole);
for (var _li = 0; _li < _bh_n; _li++) {
  var _lh = instance_find(oBlackHole, _li);
  var _lp = clamp(_lh.spawn_scale, 0, 1) * clamp(_lh.despawn_scale, 0, 1);
  if (_lp <= 0.01) continue;
  array_push(_rock_lights, {
    x : (_lh.x - oCameraController.current_cam_x) * _cam_scale,
    y : (_lh.y - oCameraController.current_cam_y) * _cam_scale,
    power : _lp * (blackhole_push_mode ? 1.9 : 0.85) * (1 + _lh.feed_charge * 0.7 + _lh.invert_shock * 1.5),
    col : blackhole_push_mode ? merge_color(global.lightning_color, c_white, 0.75) : global.lightning_color
  });
}

var _rock_flash = max(bh_drop_flash * 0.8, 0);
for (var _fi = 0; _fi < array_length(bh_inversion_rings); _fi++) {
  var _fr = bh_inversion_rings[_fi];
  var _frdim = variable_struct_exists(_fr, "dim") ? _fr.dim : 1;
  if (_fr.hot >= 0.95) _rock_flash = max(_rock_flash, (_fr.life / _fr.life_max) * 0.7 * _frdim);
}
var _rock_heat = bh_phase_charge * 0.45;

for (var i = 0; i < array_length(tidal_wall_back_left); i++) {
  var _c = tidal_wall_back_left[i];

  var _appear = clamp((tidal_wall_progress - _c.spawn_delay) / (1 - _c.spawn_delay), 0, 1);
  _appear = _appear * _appear * (3 - 2 * _appear);

  var _breathe = (sin(degtorad(_c.phase)) + 1) * 0.5;

  var _p = tidal_wall_progress;
  _p = _p * _p * (3 - 2 * _p);

  _p *= (1 - _retreat);

  var _back_target = lerp(40, _inset_range * (0.65 + _breathe * 0.55), _combined_escalation);

  var _wx = lerp(-50, _back_target, _p);
  var _wy = _c.base_y;

  var _gui_x = (_wx - oCameraController.current_cam_x) * _cam_scale;
  var _gui_y = (_wy - oCameraController.current_cam_y) * _cam_scale;

  draw_set_alpha(0.35 * _appear * (1 - _retreat));

  scr_draw_asteroid(_gui_x, _gui_y, _c, _cam_scale, make_color_rgb(50, 50, 60), _rock_lights, _rock_heat * 0.5,
                    _rock_flash * 0.5);
}

for (var i = 0; i < array_length(tidal_wall_back_right); i++) {
  var _c = tidal_wall_back_right[i];

  var _appear = clamp((tidal_wall_progress - _c.spawn_delay) / (1 - _c.spawn_delay), 0, 1);
  _appear = _appear * _appear * (3 - 2 * _appear);

  var _p = tidal_wall_progress;
  _p = _p * _p * (3 - 2 * _p);

  _p *= (1 - _retreat);

  var _breathe = (sin(degtorad(_c.phase)) + 1) * 0.5;

  var _back_target = lerp(room_width - 40, room_width - (_inset_range * (0.65 + _breathe * 0.55)), _combined_escalation);

  var _wx = lerp(room_width + 50, _back_target, _p);
  var _wy = _c.base_y;

  var _gui_x = (_wx - oCameraController.current_cam_x) * _cam_scale;
  var _gui_y = (_wy - oCameraController.current_cam_y) * _cam_scale;

  draw_set_alpha(0.35 * _appear * (1 - _retreat));

  scr_draw_asteroid(_gui_x, _gui_y, _c, _cam_scale, make_color_rgb(50, 50, 60), _rock_lights, _rock_heat * 0.5,
                    _rock_flash * 0.5);
}

for (var i = 0; i < array_length(tidal_wall_left); i++) {
  var _c = tidal_wall_left[i];

  var _appear = clamp((tidal_wall_progress - _c.spawn_delay) / (1 - _c.spawn_delay), 0, 1);
  _appear = _appear * _appear * (3 - 2 * _appear);

  var _breathe = (sin(degtorad(_c.phase)) + 1) * 0.5;

  var _inset = lerp(_min_inset, _inset_range, _breathe);

  var _p = tidal_wall_progress;
  _p = _p * _p * (3 - 2 * _p);

  _p *= (1 - _retreat);

  var _close = _combined_escalation;

  var _target_x = lerp(_min_inset, _inset_range, _breathe);

  var _wx = lerp(-50, _target_x, _p);
  var _wy = _c.base_y;

  var _gui_x = (_wx - oCameraController.current_cam_x) * _cam_scale;
  var _gui_y = (_wy - oCameraController.current_cam_y) * _cam_scale;

  draw_set_alpha(0.75 * _appear * (1 - _retreat));

  var _col = merge_color(make_color_rgb(70, 70, 75), global.lightning_color, _breathe * 0.25);

  scr_draw_asteroid(_gui_x, _gui_y, _c, _cam_scale, _col, _rock_lights, _rock_heat, _rock_flash);
}

for (var i = 0; i < array_length(tidal_wall_right); i++) {
  var _c = tidal_wall_right[i];

  var _appear = clamp((tidal_wall_progress - _c.spawn_delay) / (1 - _c.spawn_delay), 0, 1);
  _appear = _appear * _appear * (3 - 2 * _appear);

  var _breathe = (sin(degtorad(_c.phase)) + 1) * 0.5;

  var _inset = lerp(_min_inset, _inset_range, _breathe);

  var _p = tidal_wall_progress;
  _p = _p * _p * (3 - 2 * _p);

  _p *= (1 - _retreat);

  var _close = _combined_escalation;

  var _target_x = lerp(_min_inset, _inset_range, _breathe);

  var _wx = lerp(room_width + 50, room_width - _target_x, _p);
  var _wy = _c.base_y;

  var _gui_x = (_wx - oCameraController.current_cam_x) * _cam_scale;
  var _gui_y = (_wy - oCameraController.current_cam_y) * _cam_scale;

  draw_set_alpha(0.75 * _appear * (1 - _retreat));

  var _col = merge_color(make_color_rgb(70, 70, 75), global.lightning_color, _breathe * 0.25);

  scr_draw_asteroid(_gui_x, _gui_y, _c, _cam_scale, _col, _rock_lights, _rock_heat, _rock_flash);
}

draw_set_alpha(1);

for (var i = 0; i < array_length(tidal_debris); i++) {
  var _d = tidal_debris[i];
  var _dl = _d.life / _d.max_life;
  var _dgx = (_d.x - oCameraController.current_cam_x) * _cam_scale;
  var _dgy = (_d.y - oCameraController.current_cam_y) * _cam_scale;

  var _dtail = _d.speed * 2.6 * _cam_scale;
  var _dtx = _dgx - lengthdir_x(_dtail, _d.angle);
  var _dty = _dgy - lengthdir_y(_dtail, _d.angle);

  var _dcol = merge_color(make_color_rgb(100, 100, 110),
                          blackhole_push_mode ? c_white : global.lightning_color,
                          0.25 + bh_phase_charge * 0.6);

  gpu_set_blendmode(bm_add);
  draw_set_color(_dcol);
  draw_set_alpha(_dl * 0.55);
  draw_line_width(_dtx, _dty, _dgx, _dgy, _d.size * 1.4 * _cam_scale);
  draw_set_color(merge_color(_dcol, c_white, 0.6));
  draw_set_alpha(_dl);
  draw_circle(_dgx, _dgy, max(0.5, _d.size * _cam_scale * 0.7), false);
  gpu_set_blendmode(bm_normal);
}

draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

if (warning_flash_timer > 0) {
  var _fade = warning_flash_timer / _k_warning_flash_duration;
  var _pulse = 0.85 + 0.15 * sin(warning_flash_timer * _k_warning_pulse_speed);
  var _alpha_mult = _fade * _pulse;
  scr_draw_warning_edge(warning_edge, _alpha_mult);
}

scr_draw_center_laser_warning();

if (laser_warn_band_coil > 0.01 || array_length(laser_warn_band_vents) > 0
    || array_length(laser_warn_band_arcs) > 0 || array_length(laser_warn_band_haze) > 0
    || array_length(laser_warn_band_sweeps) > 0) {
  var _lwb_s   = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _lwb_camx = oCameraController.current_cam_x;
  var _lwb_camy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  for (var _lwa = 0; _lwa < array_length(laser_warn_band_arcs); _lwa++) {
    var _lwaa = laser_warn_band_arcs[_lwa];
    var _lwal = _lwaa.life / _lwaa.life_max;
    scr_draw_energy_bolt((_lwaa.x1 - _lwb_camx) * _lwb_s, (_lwaa.y1 - _lwb_camy) * _lwb_s,
                         (_lwaa.x2 - _lwb_camx) * _lwb_s, (_lwaa.y2 - _lwb_camy) * _lwb_s,
                         _lwal * (0.35 + _lwaa.hot * 0.55),
                         _lwaa.color, _lwaa.off,
                         (0.9 + _lwaa.hot * 1.6) * _lwb_s, 0.82);
  }
  gpu_set_blendmode(bm_normal);

  gpu_set_blendmode(bm_add);
  scr_draw_vent_streams(laser_warn_band_vents, _lwb_camx, _lwb_camy, _lwb_s);
  gpu_set_blendmode(bm_normal);
}

if (lorb_storm > 0.001) {
  var _lo_col = merge_color(global.lightning_color, c_white, lorb_storm * 0.5);
  var _lo_h = 60 + lorb_storm * 90;
  var _lo_bands = 18;

  gpu_set_blendmode(bm_add);
  draw_set_color(_lo_col);

  for (var i = 0; i < _lo_bands; i++) {
    var _lo_f = power(1 - (i / _lo_bands), 1.5);
    draw_set_alpha(lorb_storm * 0.16 * _lo_f * (0.75 + lorb_beat_flash * 0.6));
    draw_rectangle(0, (i / _lo_bands) * _lo_h, room_width, ((i + 1) / _lo_bands) * _lo_h, false);
  }

  draw_set_color(merge_color(_lo_col, c_white, 0.6));
  draw_set_alpha(lorb_storm * (0.35 + lorb_beat_flash * 0.5));
  draw_line_width(0, _lo_h, room_width, _lo_h, 1 + lorb_storm * 2);

  var _lo_eye = clamp(lorb_storm * (0.25 + lorb_countdown * 0.75), 0, 1.3);
  var _lo_eye_r = 40 + lorb_countdown * 72 + lorb_amb_hb * 18;
  scr_draw_smooth_ring_mask(400, 110, _lo_eye_r, _lo_eye * 0.28,
                            7 + lorb_beat_flash * 10, merge_color(_lo_col, c_white, 0.45));
  scr_draw_smooth_ring_mask(400, 110, _lo_eye_r * 0.55, _lo_eye * 0.18,
                            18, global.avoid_col_cyan_soft);

  for (var _lfn = 0; _lfn < 5; _lfn++) {
    var _fx = 400 + (_lfn - 2) * (56 + lorb_countdown * 24);
    var _fa = lorb_storm * (0.08 + lorb_amb_hb * 0.07) * (1 - abs(_lfn - 2) * 0.14);
    draw_set_color((_lfn mod 2 == 0) ? global.avoid_col_cyan : global.avoid_col_cyan_soft);
    draw_set_alpha(_fa);
    draw_line_width(_fx, 0, _fx + sin(t * 0.12 + _lfn) * 12, _lo_h + 36, 2);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(lorb_sky_rifts) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _ri75 = 0; _ri75 < array_length(lorb_sky_rifts); _ri75++) {
    var _rf75 = lorb_sky_rifts[_ri75];
    var _ra75 = (_rf75.life / max(_rf75.life_max, 1)) * (0.55 + _rf75.hot * 0.5);
    var _rc75 = merge_color(global.lightning_color, c_white, 0.25 + _rf75.hot * 0.55);

    scr_draw_energy_bolt(_rf75.x1, _rf75.y1, _rf75.x2, _rf75.y2, _ra75,
                         _rc75, _rf75.off, _rf75.width, 0.9);

    draw_set_color(global.avoid_col_cyan_soft);
    draw_set_alpha(_ra75 * 0.18);
    draw_line_width(_rf75.x1 - 28, max(0, _rf75.y1 + 2),
                    _rf75.x1 + 28, max(0, _rf75.y1 + 2), 5 + _rf75.hot * 7);
    draw_set_color(c_white);
    draw_set_alpha(_ra75 * 0.55);
    draw_line_width(_rf75.x1 - 14, max(0, _rf75.y1 + 2),
                    _rf75.x1 + 14, max(0, _rf75.y1 + 2), 1.2 + _rf75.hot);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(lorb_head_sparks) > 0 || array_length(lorb_lead_bursts) > 0 || lorb_front_live ||
    array_length(lorb_wall_hits) > 0 || array_length(lorb_drips) > 0 ||
    array_length(lorb_strikes) > 0 ||
    lorb_lead_spawn > 0.01 || lorb_lead_despawn > 0.01) {
  gpu_set_blendmode(bm_add);

  var _lo75_col = merge_color(global.lightning_color, c_white, 0.4);

  for (var _st75 = 0; _st75 < array_length(lorb_strikes); _st75++) {
    var _sk75 = lorb_strikes[_st75];
    var _sa75 = power(_sk75.life / _sk75.life_max, 1.4) * (0.5 + _sk75.hot * 0.5);
    if (_sa75 <= 0.01) continue;

    scr_draw_energy_bolt(_sk75.x1, _sk75.y1, _sk75.x2, _sk75.y2, _sa75 * 0.85,
                         _sk75.col, _sk75.off, _sk75.width * 0.55, 0.55);

    for (var _fk75 = 0; _fk75 < array_length(_sk75.forks); _fk75++) {
      var _f75 = _sk75.forks[_fk75];

      scr_draw_energy_bolt(_f75.x1, _f75.y1, _f75.x2, _f75.y2, _sa75 * 0.45,
                           _f75.col, _f75.off, _f75.w * 0.6, 0.35);
    }
  }

  if (lorb_lead_spawn > 0.01) {
    var _lsg_left = clamp(lorb_lead_spawn, 0, 1);
    var _lsg_p = 1 - _lsg_left;
    var _lsg_e = _lsg_p * _lsg_p * (3 - 2 * _lsg_p);
    var _lsg_h = lorb_head_at(lorb_front_live ? t : _k_lorb_start_t + 1, 0);
    var _lsg_r = lerp(126, 24, _lsg_e);
    var _lsg_col = merge_color(global.lightning_color, c_white, 0.5);

    scr_draw_smooth_ring_mask(_lsg_h.x, _lsg_h.y, _lsg_r, _lsg_left * 0.5, 5, _lsg_col);
    scr_draw_smooth_ring_mask(_lsg_h.x, _lsg_h.y, _lsg_r * 0.48, _lsg_left * 0.32, 8,
                              global.avoid_col_cyan_soft);

    draw_set_color(_lsg_col);
    draw_set_alpha(_lsg_left * 0.44);
    draw_line_width(_k_lorb_hub_x, _k_lorb_hub_y, _lsg_h.x, _lsg_h.y, 3);
    draw_set_color(c_white);
    draw_set_alpha(_lsg_left * 0.85);
    draw_line_width(_k_lorb_hub_x, _k_lorb_hub_y, _lsg_h.x, _lsg_h.y, 1.4 + lorb_lead_flash * 1.8);

    for (var _lsg_i = 0; _lsg_i < 4; _lsg_i++) {
      var _lsg_a = _lsg_i * 90 + 45 + lorb_lead_phase * 9;
      draw_set_color((_lsg_i mod 2 == 0) ? _lsg_col : global.avoid_col_cyan_soft);
      draw_set_alpha(_lsg_left * 0.28);
      draw_line_width(_lsg_h.x + lengthdir_x(_lsg_r * 0.35, _lsg_a),
                      _lsg_h.y + lengthdir_y(_lsg_r * 0.18, _lsg_a),
                      _lsg_h.x + lengthdir_x(_lsg_r * 1.3, _lsg_a),
                      _lsg_h.y + lengthdir_y(_lsg_r * 0.55, _lsg_a), 3);
    }
  }

  for (var _lbi = 0; _lbi < array_length(lorb_lead_bursts); _lbi++) {
    var _lb = lorb_lead_bursts[_lbi];
    var _lbp = 1 - (_lb.life / max(_lb.life_max, 1));
    var _lba = (_lb.life / max(_lb.life_max, 1)) * (0.55 + _lb.hot * 0.35);
    var _lbcol = merge_color(global.lightning_color, c_white, 0.35 + _lb.hot * 0.42);

    scr_draw_smooth_ring_mask(_lb.x, _lb.y, _lb.radius, _lba * 0.55,
                              max(3, _lb.width * 0.42 * (1 - _lbp * 0.35)), _lbcol);
    scr_draw_smooth_ring_mask(_lb.x, _lb.y, max(4, _lb.radius * 0.42), _lba * 0.28, 7,
                              global.avoid_col_cyan_soft);

    scr_draw_energy_bolt(_lb.x - _lb.dir * (34 + _lbp * 66), _lb.y - 4,
                         _lb.x + _lb.dir * (42 + _lbp * 86), _lb.y + sin(_lb.seed + _lbp * pi) * 18,
                         _lba * 0.9, _lbcol, _lb.off, 1.4 + _lb.hot * 1.3, 0.9);

    draw_set_color(c_white);
    draw_set_alpha(_lba * 0.48);
    draw_line_width(_lb.x, max(0, _lb.y - 70), _lb.x, _lb.y + 70 + _lbp * 80, 1.2 + _lb.hot * 1.4);
  }

  // --- the crackle riding the streak ----------------------------------------
  if (lorb_front_live) {
    var _lead_hot75 = clamp(0.54 + lorb_countdown * 0.44 + lorb_beat_flash * 0.44 +
                            lorb_lead_flash * 0.52 + ((lorb_front_beat >= 4) ? 0.22 : 0), 0, 1.65);
    var _flash75 = lorb_lead_flash * lorb_lead_flash;
    var _trail75 = lorb_trail_frames(lorb_front_speed);
    var _prev_lx75 = 0;
    var _prev_ly75 = 0;

    for (var _ldi75 = 0; _ldi75 < lorb_front_n; _ldi75++) {
      var _pts75 = lorb_path_points(t - _trail75, t, _ldi75, _k_lorb_trail_step * 2,
                                    _k_lorb_fray * (0.5 + lorb_countdown * 0.9),
                                    t * 1.7 + _ldi75 * 31);
      var _pn75 = array_length(_pts75);
      if (_pn75 < 2) continue;

      var _ldx75 = _pts75[_pn75 - 1].px;
      var _ldy75 = _pts75[_pn75 - 1].py;
      var _tv75x = _ldx75 - _pts75[_pn75 - 2].px;
      var _tv75y = _ldy75 - _pts75[_pn75 - 2].py;
      var _tv75l = max(0.0001, point_distance(0, 0, _tv75x, _tv75y));
      var _fw75x = _tv75x / _tv75l;
      var _fw75y = _tv75y / _tv75l;
      var _sd75x = -_fw75y;
      var _sd75y = _fw75x;

      var _ldr75 = (20 + _lead_hot75 * 9 + lorb_amb_hb * 9 + _flash75 * 10) *
                   (0.8 + (lorb_front_parked ? (0.3 + lorb_park * 0.7)
                                             : power(1 - lorb_stamp_age(t, _ldi75), 1.8)) * 0.4);
      var _lda75 = clamp((0.40 + _lead_hot75 * 0.28) * (0.76 + lorb_amb * 0.28), 0, 1);
      var _ldcol75 = merge_color(global.lightning_color, c_white, 0.36 + _lead_hot75 * 0.38);

      scr_draw_comet_spine(_pts75, _ldcol75, _lda75 * 0.95, 1.7 + _flash75 * 1.4,
                           4 + _lead_hot75 * 6, t * 0.7 + _ldi75 * 13, 0.5);
      scr_draw_comet_spine(_pts75, global.avoid_col_cyan_soft, _lda75 * 0.5, 1.1,
                           7 + _lead_hot75 * 9, t * 1.31 + 5 + _ldi75 * 13, 0.35);

      scr_draw_smooth_ring_mask(_ldx75, _ldy75, _ldr75 * (1.1 + _flash75 * 0.5),
                                _lda75 * 0.44, 4 + _flash75 * 5, _ldcol75);

      for (var _wk = 0; _wk < 3; _wk++) {
        var _wks = (_wk == 1) ? 0 : ((_wk == 0) ? -1 : 1);
        var _wkl = (18 + _lead_hot75 * 22) * random_range(0.6, 1.25);
        var _wkx = _ldx75 + _fw75x * _ldr75 * 0.4;
        var _wky = _ldy75 + _fw75y * _ldr75 * 0.4;

        draw_set_color((_wk mod 2 == 0) ? _ldcol75 : global.avoid_col_cyan_soft);
        draw_set_alpha(_lda75 * 0.4);
        draw_line_width(_wkx, _wky,
                        _wkx + _sd75x * _wks * _wkl + _fw75x * _wkl * 0.35,
                        _wky + _sd75y * _wks * _wkl + _fw75y * _wkl * 0.35, 1.6);
      }

      draw_set_color(c_white);
      draw_set_alpha(_lda75 * 0.76);
      draw_line_width(_ldx75 - _fw75x * _ldr75 * 0.5, _ldy75 - _fw75y * _ldr75 * 0.5,
                      _ldx75 + _fw75x * _ldr75 * 1.5, _ldy75 + _fw75y * _ldr75 * 1.5,
                      1.2 + _flash75 * 1.6);

      if (_ldi75 > 0) {
        var _mid_x75 = (_prev_lx75 + _ldx75) * 0.5;
        var _mid_y75 = (_prev_ly75 + _ldy75) * 0.5;

        draw_set_color(c_white);
        draw_set_alpha(_lda75 * (0.6 + _flash75 * 0.3));
        draw_line_width(_prev_lx75, _prev_ly75, _ldx75, _ldy75, 1.5 + _flash75 * 2.4);

        scr_draw_smooth_ring_mask(_mid_x75, _mid_y75, 34 + _flash75 * 54,
                                  _lda75 * (0.26 + _flash75 * 0.28), 5 + _flash75 * 6,
                                  merge_color(_ldcol75, c_white, 0.48));
      }

      _prev_lx75 = _ldx75;
      _prev_ly75 = _ldy75;
    }
  }

  // --- the wall strike, as heat ---------------------------------------------
  for (var _wh75 = 0; _wh75 < array_length(lorb_wall_hits); _wh75++) {
    var _w75 = lorb_wall_hits[_wh75];
    var _w75a = power(_w75.life / _w75.life_max, 1.2) * (0.55 + _w75.hot * 0.45);
    if (_w75a <= 0.01) continue;

    var _w75c = merge_color(global.lightning_color, c_white, 0.3 + _w75.hot * 0.5);

    scr_draw_energy_bolt(_w75.x, _w75.y, _w75.x, _w75.y - 70 - _w75.hot * 80,
                         _w75a * 0.8, _w75c, _w75.off, 1.2 + _w75.hot, 0.85);
    scr_draw_energy_bolt(_w75.x, _w75.y, _w75.x, _w75.y + 70 + _w75.hot * 80,
                         _w75a * 0.8, global.avoid_col_cyan_soft, _w75.off, 1.0 + _w75.hot, 0.7);

    scr_draw_smooth_ring_mask(_w75.x, _w75.y, _w75.radius, _w75a * 0.5, 4 + _w75.hot * 4, _w75c);

    draw_set_color(c_white);
    draw_set_alpha(_w75a * 0.7);
    draw_line_width(_w75.x, _w75.y, _w75.x + _w75.dir * (30 + _w75.radius), _w75.y,
                    1.4 + _w75.hot * 1.6);
  }

  // --- the strands the rain comes off ---------------------------------------
  for (var _dr75 = 0; _dr75 < array_length(lorb_drips); _dr75++) {
    var _d75 = lorb_drips[_dr75];
    var _d75a = (_d75.life / _d75.life_max) * (0.4 + _d75.hot * 0.4);
    if (_d75a <= 0.01) continue;

    var _d75r = _d75.reach * (1 - (_d75.life / _d75.life_max) * 0.55);

    draw_set_color(c_white);
    draw_set_alpha(_d75a * 0.55);
    draw_line_width(_d75.x, _d75.y, _d75.x + sin(_d75.seed + t * 0.4) * 5, _d75.y + _d75r, 1);
  }

  if (lorb_lead_despawn > 0.01) {
    var _ldc_left = clamp(lorb_lead_despawn, 0, 1);
    var _ldc_p = 1 - _ldc_left;
    var _ldc_e = _ldc_p * _ldc_p * (3 - 2 * _ldc_p);
    var _ldc_r = lerp(170, 8, _ldc_e);
    var _ldc_col = merge_color(global.lightning_color, c_white, 0.62);

    scr_draw_smooth_ring_mask(lorb_lead_exit_x, lorb_lead_exit_y, _ldc_r, _ldc_left * 0.68,
                              6 + _ldc_left * 6, _ldc_col);
    scr_draw_smooth_ring_mask(lorb_lead_exit_x, lorb_lead_exit_y, lerp(28, 155, _ldc_e),
                              _ldc_left * 0.24, 5, global.avoid_col_cyan_soft);

    draw_set_color(_ldc_col);
    draw_set_alpha(_ldc_left * 0.42);
    draw_line_width(lorb_lead_exit_x - _ldc_r, lorb_lead_exit_y,
                    lorb_lead_exit_x + _ldc_r, lorb_lead_exit_y, 4 + _ldc_left * 4);
    draw_set_color(c_white);
    draw_set_alpha(_ldc_left * 0.86);
    draw_line_width(lorb_lead_exit_x - _ldc_r * 0.55, lorb_lead_exit_y,
                    lorb_lead_exit_x + _ldc_r * 0.55, lorb_lead_exit_y, 1.5 + _ldc_left * 2);
    draw_line_width(lorb_lead_exit_x, lorb_lead_exit_y - _ldc_r * 0.45,
                    lorb_lead_exit_x, lorb_lead_exit_y + _ldc_r * 0.45, 1.2 + _ldc_left * 2);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(lorb_arcs) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(lorb_arcs); i++) {
    var _la = lorb_arcs[i];
    var _la_a = _la.life / _la.max_life;
    scr_draw_energy_bolt(_la.x1, _la.y1, _la.x2, _la.y2, _la_a * 0.9,
                         merge_color(global.lightning_color, c_white, _la.hot), _la.off, _la.width);
  }
  gpu_set_blendmode(bm_normal);
}

if (lorb_readout > 0.02 && array_length(lorb_columns) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _lc75i = 0; _lc75i < array_length(lorb_columns); _lc75i++) {
    var _lc75 = lorb_columns[_lc75i];
    if (_lc75.landed) continue;

    var _lcf75 = clamp((t - _lc75.spawn_t) / max(_lc75.fall, 1), 0, 1);
    if (_lcf75 <= 0.03) continue;

    var _lt75 = max(0, t - _lc75.spawn_t);
    var _ly75 = clamp(_lc75.y0 + 0.5 * _lc75.g * _lt75 * _lt75, 0, _k_lorb_floor_y);
    var _lx75 = clamp(_lc75.sx, _k_lorb_pad, room_width - _k_lorb_pad);
    var _la75 = lorb_readout * (0.18 + power(_lcf75, 1.8) * 0.55) * (0.75 + lorb_amb * 0.4);
    var _lc_col75 = merge_color(global.lightning_color, c_white, 0.25 + _lc75.hot * 0.45);
    var _tail75 = (54 + _lcf75 * 150) * _lc75.slice;

    draw_set_color(_lc_col75);
    draw_set_alpha(_la75 * 0.10);
    draw_line_width(_lx75, max(0, _ly75 - _tail75), _lx75, min(_k_lorb_floor_y, _ly75 + 22), 22);
    draw_set_alpha(_la75 * 0.32);
    draw_line_width(_lx75, max(0, _ly75 - _tail75 * 0.72), _lx75, min(_k_lorb_floor_y, _ly75 + 14), 7);
    draw_set_color(c_white);
    draw_set_alpha(_la75 * 0.72);
    draw_line_width(_lx75, max(0, _ly75 - _tail75 * 0.46), _lx75, min(_k_lorb_floor_y, _ly75 + 8), 1.4);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(lorb_floor_crack) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _fc = 0; _fc < array_length(lorb_floor_crack); _fc++) {
    var _fcr = lorb_floor_crack[_fc];
    var _fca = (_fcr.life / _fcr.life_max) * clamp(lorb_amb, 0, 1.2);
    if (_fca <= 0.01) continue;

    var _k_fc_segs = 6;
    var _fc_step = (_fcr.len / _k_fc_segs) * _fcr.dir;

    lightning_bloom_boost += _fca * 0.1;

    var _fc_px = _fcr.x;
    var _fc_py = _k_lorb_floor_y - 3;

    for (var _fs = 1; _fs <= _k_fc_segs; _fs++) {
      var _fc_jag = (_fs < _k_fc_segs) ? -random(11) : 0;
      var _fc_nx = _fcr.x + _fc_step * _fs;
      var _fc_ny = _k_lorb_floor_y - 3 + _fc_jag;

      draw_set_color(global.lightning_color);
      draw_set_alpha(_fca * 0.18);
      draw_line_width(_fc_px, _fc_py, _fc_nx, _fc_ny, 14);
      draw_set_alpha(_fca * 0.5);
      draw_line_width(_fc_px, _fc_py, _fc_nx, _fc_ny, 5);
      draw_set_color(c_white);
      draw_set_alpha(_fca * 0.85);
      draw_line_width(_fc_px, _fc_py, _fc_nx, _fc_ny, 1.5);

      _fc_px = _fc_nx;
      _fc_py = _fc_ny;
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(lorb_impact_sparks) > 0) {
  gpu_set_blendmode(bm_add);

  for (var _spi = 0; _spi < array_length(lorb_impact_sparks); _spi++) {
    var _spk = lorb_impact_sparks[_spi];
    var _spa = (_spk.life / max(_spk.life_max, 1)) * (0.45 + _spk.hot * 0.55);
    var _spc = merge_color(global.lightning_color, c_white, 0.25 + _spk.hot * 0.55);

    draw_set_color(_spc);
    draw_set_alpha(_spa * 0.45);
    draw_line_width(_spk.px, _spk.py, _spk.x, _spk.y, max(1, _spk.size * 2.2));
    draw_set_color(c_white);
    draw_set_alpha(_spa * _spa * 0.8);
    draw_line_width(_spk.px, _spk.py, _spk.x, _spk.y, max(0.6, _spk.size * 0.55));
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (lorb_seam > 0.01 || array_length(lorb_seam_pulses) > 0) {
  gpu_set_blendmode(bm_add);
  var _seam_col = merge_color(global.lightning_color, c_white, 0.5 + lorb_seam_flash * 0.5);
  var _seam_bot = 260 + lorb_seam_flash * 260;

  draw_set_color(_seam_col);
  draw_set_alpha(clamp(lorb_seam, 0, 1) * 0.14);
  draw_line_width(400, 0, 400, _seam_bot, 26 + lorb_seam_flash * 40);
  draw_set_alpha(clamp(lorb_seam, 0, 1) * 0.3);
  draw_line_width(400, 0, 400, _seam_bot, 9 + lorb_seam_flash * 14);
  draw_set_color(c_white);
  draw_set_alpha(clamp(lorb_seam, 0, 1) * 0.75);
  draw_line_width(400, 0, 400, _seam_bot, 1.5 + lorb_seam_flash * 4);

  for (var _spi75 = 0; _spi75 < array_length(lorb_seam_pulses); _spi75++) {
    var _sep = lorb_seam_pulses[_spi75];
    var _sea = (_sep.life / max(_sep.life_max, 1)) * (0.5 + _sep.hot * 0.4);
    var _sr = max(1, _sep.radius);

    scr_draw_smooth_ring_mask(400, _sep.y, _sr, _sea * 0.48, _sep.width,
                              merge_color(global.lightning_color, c_white, 0.45 + _sep.hot * 0.35));

    draw_set_color(c_white);
    draw_set_alpha(_sea * 0.36);
    draw_line_width(400 - _sr * 0.18, _sep.y, 400 + _sr * 0.18, _sep.y, 1.2 + _sep.hot * 2.2);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

for (var qi = 0; qi < array_length(quarter_circles); ++qi) {
  var qc = quarter_circles[qi];
  var _beat_frac = (qc.beat_timer > 0) ? (qc.beat_timer / qc.beat_duration) : 0;
  var _guide_heat = max(_beat_frac, quarter_coil * 0.85 + quarter_lock_flash * 0.6);

  var _base_color = (qc.radius > 100) ? make_color_rgb(255, 25, 25) : make_color_rgb(255, 115, 30);
  var _ring_color = merge_color(_base_color, c_white, clamp(_guide_heat, 0, 1) * 0.75);
  var _ring_alpha = lerp(0.3, 0.85, clamp(_guide_heat, 0, 1)) * (0.7 + quarter_heat * 0.5);
  var _ring_width = lerp(3, 60, clamp(_guide_heat, 0, 1)) * (1 + quarter_coil * 0.8);

  gpu_set_blendmode(bm_add);
  scr_draw_smooth_ring_mask(qc.cx, qc.cy, qc.radius_current, _ring_alpha, _ring_width, _ring_color);

  if (quarter_heat > 0.3) {
    scr_draw_smooth_ring_mask(qc.cx, qc.cy, qc.radius_current, (quarter_heat - 0.3) * 0.5, 3,
                              merge_color(_ring_color, c_white, 0.6));
  }
  gpu_set_blendmode(bm_normal);
}
draw_set_color(c_white);

if (array_length(quarter_arcs) > 0) {
  gpu_set_blendmode(bm_add);
  for (var i = 0; i < array_length(quarter_arcs); i++) {
    var _qa2 = quarter_arcs[i];
    var _qa_a = _qa2.life / _qa2.max_life;
    scr_draw_energy_bolt(_qa2.ax, _qa2.ay, _qa2.bx, _qa2.by, _qa_a * 0.95,
                         merge_color(make_color_rgb(255, 60, 40), c_white, _qa2.hot), _qa2.off, _qa2.width);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(quarter_lock_frames) > 0 || array_length(quarter_vents) > 0) {
  gpu_set_blendmode(bm_add);

  for (var i = 0; i < array_length(quarter_lock_frames); i++) {
    var _ql2 = quarter_lock_frames[i];
    var _ql2_a = clamp(_ql2.life / _ql2.life_max, 0, 1);
    var _ql2_col = (_ql2.cid == 0) ? global.avoid_col_warning : global.avoid_col_cyan;
    var _ql2_r = _ql2.r + ((_ql2.cid == 0) ? 26 : 16);

    scr_draw_lock_bracket_glow(_ql2.cx - _ql2_r, _ql2.cy - _ql2_r,
                               _ql2.cx + _ql2_r, _ql2.cy + _ql2_r,
                               _ql2_col, _ql2.hot, _ql2_a);
  }

  scr_draw_vent_streams(quarter_vents);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(quarter_rim_crackle) > 0) {
  var _qk_mult = fx_get_mult_for("quartercircles", "rim");
  var _qk_xmin = _k_qamb_pad;
  var _qk_xmax = room_width - _k_qamb_pad;
  var _qk_ymin = _k_qamb_pad;
  var _qk_ymax = _k_qamb_floor_y;

  gpu_set_blendmode(bm_add);

  for (var _qkc = 0; _qkc < array_length(quarter_rim_crackle); _qkc++) {
    var _qcrk = quarter_rim_crackle[_qkc];
    var _qcrka = (_qcrk.life / _qcrk.life_max) * clamp(qamb, 0, 1.2) * _qk_mult;
    if (_qcrka <= 0.01) continue;

    var _qkdx = dcos(_qcrk.ang);
    var _qkdy = -dsin(_qcrk.ang);
    var _qktx = 100000;
    var _qkty = 100000;

    if (_qkdx > 0.0001) _qktx = (_qk_xmax - 400) / _qkdx;
    else if (_qkdx < -0.0001) _qktx = (_qk_xmin - 400) / _qkdx;

    if (_qkdy > 0.0001) _qkty = (_qk_ymax - 304) / _qkdy;
    else if (_qkdy < -0.0001) _qkty = (_qk_ymin - 304) / _qkdy;

    var _qkt = max(1, min(_qktx, _qkty));
    var _qk_vert = (_qktx <= _qkty);
    var _qk_hx = 400 + _qkdx * _qkt;
    var _qk_hy = 304 + _qkdy * _qkt;

    var _qk_ux = lengthdir_x(1, _qk_vert ? 90 : 0);
    var _qk_uy = lengthdir_y(1, _qk_vert ? 90 : 0);
    var _qk_vx = lengthdir_x(1, _qk_vert ? 0 : 90);
    var _qk_vy = lengthdir_y(1, _qk_vert ? 0 : 90);

    var _qk_in = ((_qk_hx - 400) * _qk_vx + (_qk_hy - 304) * _qk_vy > 0) ? -1 : 1;

    var _k_qk_segs = 5;
    var _qk_step = _qcrk.len / _k_qk_segs;
    var _qk_col = (_qcrk.cid == 0) ? make_color_rgb(255, 52, 44) : make_color_rgb(96, 176, 255);

    lightning_bloom_boost += _qcrka * 0.09;

    var _qk_px = _qk_hx + _qk_vx * _qk_in * 4;
    var _qk_py = _qk_hy + _qk_vy * _qk_in * 4;

    for (var _qks = 1; _qks <= _k_qk_segs; _qks++) {
      var _qk_jag = (_qks < _k_qk_segs) ? random_range(-8, 8) : 0;
      var _qk_nx = _qk_hx + _qk_ux * _qk_step * _qks + _qk_vx * (_qk_in * 4 + _qk_jag);
      var _qk_ny = _qk_hy + _qk_uy * _qk_step * _qks + _qk_vy * (_qk_in * 4 + _qk_jag);

      draw_set_color(_qk_col);
      draw_set_alpha(_qcrka * 0.16);
      draw_line_width(_qk_px, _qk_py, _qk_nx, _qk_ny, 13);
      draw_set_alpha(_qcrka * 0.45);
      draw_line_width(_qk_px, _qk_py, _qk_nx, _qk_ny, 5);
      draw_set_color(c_white);
      draw_set_alpha(_qcrka * 0.8);
      draw_line_width(_qk_px, _qk_py, _qk_nx, _qk_ny, 1.5);

      _qk_px = _qk_nx;
      _qk_py = _qk_ny;
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (stamp_rail > 0.004 || array_length(stamp_vents) > 0 || array_length(stamp_arcs) > 0) {
  gpu_set_blendmode(bm_add);

  var _sk75_a = clamp(stamp_rail, 0, 1);
  var _sk75_dead = stamp_dead ? clamp(stamp_blowout, 0, 1) : 1;

  for (var _fi = 0; _fi < 2; _fi++) {
    var _fh = clamp(stamp_face_heat[_fi], 0, 1.6);
    var _fstr = max(max(_fh, stamp_slam_flash * 0.8), stamp_coil * stamp_amb * 0.7)
                * _sk75_a * _sk75_dead * (0.85 + stamp_hb * 0.3);
    if (_fstr <= 0.015) continue;

    var _fx = stamp_face[_fi];
    var _fcol = merge_color(global.avoid_col_warning, c_white, clamp(_fstr, 0, 1) * 0.55);

    draw_set_color(_fcol);
    draw_set_alpha(clamp(_fstr, 0, 1) * 0.2);
    draw_line_width(_fx, _k_stamp_ceil_y, _fx, _k_stamp_floor_y, 7 + _fstr * 10);

    draw_set_color(c_white);
    draw_set_alpha(clamp(_fstr, 0, 1) * 0.45);
    draw_line_width(_fx, _k_stamp_ceil_y, _fx, _k_stamp_floor_y, 1.5);

    lightning_bloom_boost += clamp(_fstr, 0, 1) * 0.05;
  }

  if (stamp_armed && !stamp_dead) {
    for (var _ti = 0; _ti < 2; _ti++) {
      var _tt = stamp_face_target[_ti];
      if (abs(_tt - stamp_face[_ti]) < 1) continue;

      var _tstr = (0.28 + stamp_coil * 0.5) * _sk75_a * clamp(stamp_readout, 0, 1);

      draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.35));
      draw_set_alpha(_tstr * 0.22);
      draw_line_width(_tt, _k_stamp_ceil_y, _tt, _k_stamp_floor_y, 4 + stamp_coil * 8);

      draw_set_color(c_white);
      draw_set_alpha(_tstr * 0.3);
      draw_line_width(_tt, _k_stamp_ceil_y, _tt, _k_stamp_floor_y, 1);

      lightning_bloom_boost += _tstr * 0.02;
    }
  }

  for (var _ai75 = 0; _ai75 < array_length(stamp_arcs); _ai75++) {
    var _ar = stamp_arcs[_ai75];
    var _ara = clamp(_ar.life / _ar.life_max, 0, 1) * _sk75_dead;
    scr_draw_energy_bolt(_ar.x1, _ar.y1, _ar.x2, _ar.y2,
                         _ara * 0.85, merge_color(_ar.color, c_white, _ar.hot * 0.5),
                         _ar.off, 1 + _ar.hot * 2);
  }

  for (var _lb = 0; _lb < array_length(stamp_lock_frames); _lb++) {
    var _lbf = stamp_lock_frames[_lb];
    var _lba = clamp(_lbf.life / _lbf.life_max, 0, 1);
    var _lbp = 0.65 + 0.35 * sin(_lbf.seed + t * 0.7);

    scr_draw_lock_bracket_glow(_lbf.x0, _k_stamp_ceil_y + 12,
                               _lbf.x1, _k_stamp_floor_y - 6,
                               global.avoid_col_cyan, _lbf.hot,
                               _lba * _sk75_dead * 0.8, 0, _lbp);
  }

  for (var _oi = 0; _oi < array_length(stamp_orbs); _oi++) {
    var _on = stamp_orbs[_oi];
    if (_on.crushed) continue;
    if (_on.spawn < 1) continue;

    var _ofl = clamp(_on.flare, 0, 1);
    var _opu = clamp(_on.pulse, 0, 1);
    var _ostr = (0.25 + _opu * 0.45 + _ofl * 0.6) * _sk75_a * _sk75_dead;
    if (_ostr <= 0.02) continue;

    draw_set_color(merge_color(global.avoid_col_ember, c_white, _ofl * 0.5 + _opu * 0.3));
    draw_set_alpha(_ostr * 0.3);
    draw_circle(_on.x, _on.y, _k_stamp_orb_r + 1 + _ofl * 3, true);

    if (_ofl > 0.35) {
      draw_set_color(c_white);
      draw_set_alpha((_ofl - 0.35) * 0.7);
      draw_circle(_on.x, _on.y, _k_stamp_orb_r * 0.5, false);
      lightning_bloom_boost += (_ofl - 0.35) * 0.012;
    }
  }

  if (stamp_safe_glow > 0.02) {
    var _sgv = clamp(stamp_safe_glow, 0, 1) * _sk75_a;
    var _seal = clamp(stamp_safe_seal, 0, 1);

    for (var _si = 0; _si < 2; _si++) {
      var _sx = (_si == 0) ? _k_stamp_safe_x0 : _k_stamp_safe_x1;
      var _brace = 1 - clamp(abs(stamp_face[_si] - _sx) / 180, 0, 1);
      var _sstr = _sgv * (0.3 + _brace * 0.55 + _seal * 0.4);

      draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.25 + _brace * 0.4));
      draw_set_alpha(_sstr * 0.2);
      draw_line_width(_sx, _k_stamp_ceil_y, _sx, _k_stamp_floor_y, 5 + _brace * 12);

      draw_set_color(c_white);
      draw_set_alpha(_sstr * 0.3);
      draw_line_width(_sx, _k_stamp_ceil_y, _sx, _k_stamp_floor_y, 1);

      lightning_bloom_boost += _sstr * 0.03;
    }
  }

  scr_draw_vent_streams(stamp_vents);

  for (var _pi75 = 0; _pi75 < array_length(stamp_sparks); _pi75++) {
    var _sp = stamp_sparks[_pi75];
    var _spa = clamp(_sp.life / _sp.life_max, 0, 1);
    var _spd = point_distance(0, 0, _sp.vx, _sp.vy);
    var _sptr = min(11, _spd * 2.1);

    draw_set_color(merge_color(_sp.color, c_white, _sp.hot * 0.6));
    draw_set_alpha(_spa * _spa * (0.4 + _sp.hot * 0.5) * _sk75_dead);
    draw_line_width(_sp.x, _sp.y,
                    _sp.x - _sp.vx / max(0.01, _spd) * _sptr,
                    _sp.y - _sp.vy / max(0.01, _spd) * _sptr,
                    _sp.size);

    if (_sp.hot > 0.7 && _spa > 0.4) {
      draw_set_color(c_white);
      draw_set_alpha((_spa - 0.4) * 1.2 * _sk75_dead);
      draw_line_width(_sp.x, _sp.y, _sp.x - _sp.vx * 0.5, _sp.y - _sp.vy * 0.5,
                      max(1, _sp.size * 0.5));
    }
  }

  var _sk_ch = clamp(stamp_chroma, 0, 1.3) * _sk75_a;
  if (_sk_ch > 0.02) {
    var _off = 2 + _sk_ch * 6 + stamp_heat * 3;

    for (var _ci = 0; _ci < 2; _ci++) {
      var _cfx = stamp_face[_ci];

      draw_set_color(global.avoid_col_warning);
      draw_set_alpha(_sk_ch * 0.4 * _sk75_dead);
      draw_line_width(_cfx - _off, _k_stamp_ceil_y, _cfx - _off, _k_stamp_floor_y, 2);

      draw_set_color(global.avoid_col_cyan);
      draw_set_alpha(_sk_ch * 0.4 * _sk75_dead);
      draw_line_width(_cfx + _off, _k_stamp_ceil_y, _cfx + _off, _k_stamp_floor_y, 2);
    }

    if (stamp_safe_glow > 0.02) {
      for (var _cs = 0; _cs < 2; _cs++) {
        var _csx = (_cs == 0) ? _k_stamp_safe_x0 : _k_stamp_safe_x1;

        draw_set_color(global.avoid_col_warning);
        draw_set_alpha(_sk_ch * 0.3 * _sk75_dead);
        draw_line_width(_csx - _off, _k_stamp_ceil_y, _csx - _off, _k_stamp_floor_y, 1.5);

        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_sk_ch * 0.3 * _sk75_dead);
        draw_line_width(_csx + _off, _k_stamp_ceil_y, _csx + _off, _k_stamp_floor_y, 1.5);
      }
    }

    lightning_bloom_boost += _sk_ch * 0.05;
  }

  if (stamp_blowout > 0.01) {
    var _bo = clamp(stamp_blowout, 0, 1);
    var _bocol = merge_color(global.avoid_col_warning, c_white, _bo * 0.6);

    for (var _bi = 0; _bi < 10; _bi++) {
      var _by = _k_stamp_ceil_y + (_bi / 9) * (_k_stamp_floor_y - _k_stamp_ceil_y);
      draw_set_color(_bocol);
      draw_set_alpha(_bo * _bo * 0.24);
      draw_line_width(_k_stamp_x0, _by, _k_stamp_x1, _by, 12 + _bo * 30);
      draw_set_color(c_white);
      draw_set_alpha(_bo * _bo * 0.4);
      draw_line_width(_k_stamp_x0, _by, _k_stamp_x1, _by, 2 + _bo * 4);
    }

    draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.5));
    draw_set_alpha(_bo * _bo * 0.35);
    draw_line_width(_k_stamp_mid_x, _k_stamp_ceil_y, _k_stamp_mid_x, _k_stamp_floor_y,
                    14 + _bo * 40);

    lightning_bloom_boost += _bo * 0.22;
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (warning_band_ignited and t < 626) {
  var _t_since_ignite = t - warning_band_ignite_t;
  var _fade_frames = 10;
  var _fade_in = clamp(_t_since_ignite / _fade_frames, 0, 1);
  var _fade_out = clamp((626 - t) / _fade_frames, 0, 1);
  var _envelope = min(_fade_in, _fade_out);

  var _k_ignite_flare_duration = 8;
  var _ignite_flare = 0;
  if (_t_since_ignite < _k_ignite_flare_duration) {
    var _flare_p = 1 - (_t_since_ignite / _k_ignite_flare_duration);
    _ignite_flare = _flare_p * _flare_p;
  }

  var _pulse = 0.2 + rain_heartbeat * 0.5;
  var _base_alpha = (_pulse * _envelope * (0.45 + rain_intensity * 0.75)) + (_ignite_flare * 0.5);
  var _edge_height = 70 + rain_intensity * 34 + rain_heartbeat * 26;
  var _strips = 20;
  var _strip_h = _edge_height / _strips;

  var _has_gap = (rain_intensity > 0.02);
  var _gap_l = 0;
  var _gap_r = 0;

  if (_has_gap) {
    var _slide_e2 = rain_safe_slide * rain_safe_slide * (3 - 2 * rain_safe_slide);
    var _hole_x = lerp(rain_safe_x_prev, rain_safe_x, _slide_e2);
    var _hole_hw = rain_safe_width * 0.5;
    _gap_l = clamp(_hole_x - _hole_hw, 0, room_width);
    _gap_r = clamp(_hole_x + _hole_hw, 0, room_width);
  }

  gpu_set_blendmode(bm_add);
  draw_set_color(c_red);

  for (var s = 0; s < _strips; s++) {
    var _falloff = power(1 - (s / _strips), 1.4);
    draw_set_alpha(_base_alpha * _falloff);

    var _sy0 = s * _strip_h;
    var _sy1 = (s + 1) * _strip_h;

    if (_has_gap) {
      if (_gap_l > 0) draw_rectangle(0, _sy0, _gap_l, _sy1, false);
      if (_gap_r < room_width) draw_rectangle(_gap_r, _sy0, room_width, _sy1, false);
    } else {
      draw_rectangle(0, _sy0, room_width, _sy1, false);
    }
  }

  if (_has_gap) {
    draw_set_color(merge_color(c_red, c_white, 0.6));
    draw_set_alpha(_base_alpha * (1.4 + rain_lane_flash * 1.6));
    draw_line_width(_gap_l, 0, _gap_l, _edge_height * 0.8, 2.5);
    draw_line_width(_gap_r, 0, _gap_r, _edge_height * 0.8, 2.5);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}
swirl_strength += (swirl_target - swirl_strength) * 0.08;

var _swirl_centers = array_create(8, 0.0);
var _swirl_radii = array_create(4, 0.0);
var _swirl_strengths = array_create(4, 0.0);
var _swirl_count = 0;

if (swirl_strength > 0.001) {
  var _gui_x =
      (swirl_center_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _gui_y =
      (swirl_center_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  _swirl_centers[0] = _gui_x / oCameraController.base_view_w;
  _swirl_centers[1] = _gui_y / oCameraController.base_view_h;
  _swirl_radii[0] = swirl_radius_px / oCameraController.current_cam_w;
  _swirl_strengths[0] = swirl_strength;
  _swirl_count += 1;
}

if (slash_lens_strength > 0.002 && _swirl_count < 4) {
  var _sl_gui_x =
      (slash_lens_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _sl_gui_y =
      (slash_lens_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  _swirl_centers[_swirl_count * 2] = _sl_gui_x / oCameraController.base_view_w;
  _swirl_centers[_swirl_count * 2 + 1] = _sl_gui_y / oCameraController.base_view_h;
  _swirl_radii[_swirl_count] = slash_lens_radius / oCameraController.current_cam_w;
  _swirl_strengths[_swirl_count] = slash_lens_strength;
  _swirl_count += 1;
}

var _k_lens_strength = 0.3;
var _k_lens_radius_px_mult = 2.2;

var _bh_count = instance_number(oBlackHole);
for (var bi = 0; bi < _bh_count; bi++) {
  if (_swirl_count >= 4) break;

  var _bh = instance_find(oBlackHole, bi);
  var _p = clamp(_bh.spawn_scale, 0, 1) * clamp(_bh.despawn_scale, 0, 1);
  var _strength = _k_lens_strength * _p;

  var _gui_x = (_bh.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _gui_y = (_bh.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  _swirl_centers[_swirl_count * 2] = _gui_x / oCameraController.base_view_w;
  _swirl_centers[_swirl_count * 2 + 1] = _gui_y / oCameraController.base_view_h;
  _swirl_radii[_swirl_count] = (_bh.ring_radius * _k_lens_radius_px_mult) / oCameraController.current_cam_w;
  _swirl_strengths[_swirl_count] = _strength;
  _swirl_count += 1;
}

gpu_set_blendmode(bm_add);
if (arrow_ring_created) {
  for (var la = 0; la < array_length(salvo_lightning_arcs); la++) {
    var _arc = salvo_lightning_arcs[la];
    var _b1 = arrow_ring[_arc.seg];
    var _b2 = arrow_ring[(_arc.seg + 1) mod arrow_ring_count];

    if (instance_exists(_b1) && instance_exists(_b2)) {
      var _tx = _b2.x;
      var _ty = _b2.y;

      with (_b1) {
        scr_draw_lightning_bolt(_tx, _ty, _arc.life, _arc.life_max, other._k_arc_segments, false,
                                global.lightning_color, 0.08, other._k_arc_jitter, _arc.bolt_id, 3, false);
      }
    }
  }

  for (var la = 0; la < array_length(ring_inward_arcs); la++) {
    var _arc = ring_inward_arcs[la];
    var _b1 = arrow_ring[_arc.seg];

    if (instance_exists(_b1)) {
      var _tx = arrow_ring_x;
      var _ty = arrow_ring_y;

      with (_b1) {
        scr_draw_lightning_bolt(_tx, _ty, _arc.life, _arc.life_max, 7, false,
                                merge_color(global.lightning_color, c_white, 0.4), 0.15, 9, _arc.bolt_id, 2, false);
      }
    }
  }

  for (var la = 0; la < array_length(ring_leak_arcs); la++) {
    var _arc = ring_leak_arcs[la];
    var _b1 = arrow_ring[_arc.seg];

    if (instance_exists(_b1)) {
      var _tx = _b1.x + lengthdir_x(_arc.len, _arc.ang);
      var _ty = _b1.y + lengthdir_y(_arc.len * arrow_ring_vertical_scale, _arc.ang);

      with (_b1) {
        scr_draw_lightning_bolt(_tx, _ty, _arc.life, _arc.life_max, 5, true, c_red, 0.2, 10, _arc.bolt_id, 1, false);
      }
    }
  }
}

if (array_length(ring_rim_crackle) > 0) {

  for (var _rc = 0; _rc < array_length(ring_rim_crackle); _rc++) {
    var _crk = ring_rim_crackle[_rc];
    var _crka = (_crk.life / _crk.life_max) * clamp(ring_ambient, 0, 1.2);
    if (_crka <= 0.01) continue;

    var _crk_hit = ring_arena_hit(arrow_ring_x, arrow_ring_y, _crk.ang);

    var _crk_ux = lengthdir_x(1, _crk_hit.vertical ? 90 : 0);
    var _crk_uy = lengthdir_y(1, _crk_hit.vertical ? 90 : 0);
    var _crk_vx = lengthdir_x(1, _crk_hit.vertical ? 0 : 90);
    var _crk_vy = lengthdir_y(1, _crk_hit.vertical ? 0 : 90);

    var _crk_in = ((_crk_hit.x - arrow_ring_x) * _crk_vx + (_crk_hit.y - arrow_ring_y) * _crk_vy > 0) ? -1 : 1;

    var _k_crk_segs = 6;
    var _crk_step = _crk.len / _k_crk_segs;

    lightning_bloom_boost += _crka * 0.12;

    var _crk_px = _crk_hit.x + _crk_vx * _crk_in * 5;
    var _crk_py = _crk_hit.y + _crk_vy * _crk_in * 5;

    for (var _cs = 1; _cs <= _k_crk_segs; _cs++) {
      var _crk_jag = (_cs < _k_crk_segs) ? random_range(-9, 9) : 0;
      var _crk_nx = _crk_hit.x + _crk_ux * _crk_step * _cs + _crk_vx * (_crk_in * 5 + _crk_jag);
      var _crk_ny = _crk_hit.y + _crk_uy * _crk_step * _cs + _crk_vy * (_crk_in * 5 + _crk_jag);

      draw_set_color(c_red);
      draw_set_alpha(_crka * 0.18);
      draw_line_width(_crk_px, _crk_py, _crk_nx, _crk_ny, 14);
      draw_set_alpha(_crka * 0.5);
      draw_line_width(_crk_px, _crk_py, _crk_nx, _crk_ny, 5);
      draw_set_color(c_white);
      draw_set_alpha(_crka * 0.85);
      draw_line_width(_crk_px, _crk_py, _crk_nx, _crk_ny, 1.5);

      _crk_px = _crk_nx;
      _crk_py = _crk_ny;
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (array_length(shapes_arcs) > 0) {
  for (var _sa = 0; _sa < array_length(shapes_arcs); _sa++) {
    var _arc = shapes_arcs[_sa];
    if (_arc.delay > 0) continue;

    var _pool = (_arc.arr == 0) ? intro_ring_bullets : intro_x_bullets;
    var _pn = array_length(_pool);
    if (_arc.i1 < 0 || _arc.i1 >= _pn) continue;

    var _b1 = _pool[_arc.i1];
    if (!instance_exists(_b1) || !_b1.revealed) continue;

    var _atx, _aty;

    if (_arc.i2 == -1) {
      _atx = intro_cx;
      _aty = intro_cy;
    } else {
      var _next = _arc.i1 + 1;
      if (_next >= _pn || !instance_exists(_pool[_next]) || _pool[_next].shape_id != _b1.shape_id) {
        var _first = _arc.i1;
        while (_first > 0 && instance_exists(_pool[_first - 1]) && _pool[_first - 1].shape_id == _b1.shape_id) _first--;
        _next = _first;
      }
      if (_next == _arc.i1) continue;

      var _b2 = _pool[_next];
      if (!instance_exists(_b2) || !_b2.revealed) continue;
      _atx = _b2.x;
      _aty = _b2.y;
    }

    with (_b1) {
      scr_draw_lightning_bolt(_atx, _aty, _arc.life, _arc.life_max, other._k_shapes_arc_segments, false,
                              merge_color(global.lightning_color, c_white, 0.3), 0.1, other._k_shapes_arc_jitter,
                              _arc.bolt_id, 2, false);
    }
  }
}

if (t >= _k_rain_start && t < 720) {
  if (array_length(rain_band_crackle) > 0) {

    for (var _bc = 0; _bc < array_length(rain_band_crackle); _bc++) {
      var _cr = rain_band_crackle[_bc];
      var _cra = _cr.life / _cr.life_max;
      var _crsegs = 6;
      var _crdx = _cr.len / _crsegs;

      lightning_bloom_boost += _cra * 0.15;

      var _crpx = _cr.x;
      var _crpy = 6;

      for (var _cs = 1; _cs <= _crsegs; _cs++) {
        var _crnx = _cr.x + _crdx * _cs;
        var _crny = 6 + ((_cs < _crsegs) ? random_range(-9, 9) : 0);

        draw_set_color(c_red);
        draw_set_alpha(_cra * 0.18);
        draw_line_width(_crpx, _crpy, _crnx, _crny, 14);
        draw_set_alpha(_cra * 0.5);
        draw_line_width(_crpx, _crpy, _crnx, _crny, 5);
        draw_set_color(c_white);
        draw_set_alpha(_cra * 0.85);
        draw_line_width(_crpx, _crpy, _crnx, _crny, 1.5);

        _crpx = _crnx;
        _crpy = _crny;
      }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
  }

  if (instance_exists(kunai_pair[0]) && instance_exists(kunai_pair[1])) {
    var _tether_strength = big_kunai_locked ? (0.3 + orbit_ribbon_heat * 0.5) : (0.25 + big_kunai_build * 0.9);

    if (_tether_strength > 0.2 && (t mod max(2, 5 - round(_tether_strength * 3)) == 0)) {
      var _ttx = kunai_pair[1].x;
      var _tty = kunai_pair[1].y;

      with (kunai_pair[0]) {
        scr_draw_lightning_bolt(_ttx, _tty, 3, 5, 9, false, merge_color(c_red, c_white, _tether_strength * 0.5), 0.12,
                                12 + _tether_strength * 14, "kunai_tether", 1, false);
      }
    }
  }

  if (big_kunai_locked && orbit_ribbon_heat > 0.5) {
    for (var _kd = 0; _kd < 2; _kd++) {
      if (!instance_exists(kunai_pair[_kd]) || !kunai_pair[_kd].built) continue;
      if (irandom(max(2, 7 - round(orbit_ribbon_heat * 4))) != 0) continue;

      var _kdir = kunai_pair[_kd].current_tangent_dir + 180 + random_range(-40, 40);
      var _klen = random_range(40, 50 + orbit_ribbon_heat * 70);
      var _kdx = kunai_pair[_kd].x + lengthdir_x(_klen, _kdir);
      var _kdy = kunai_pair[_kd].y + lengthdir_y(_klen, _kdir);

      with (kunai_pair[_kd]) {
        scr_draw_lightning_bolt(_kdx, _kdy, 4, 4, 4, true, c_red, 0.2, 10, "kunai_leak_" + string(_kd), 1, false);
      }
    }
  }
}
gpu_set_blendmode(bm_normal);

if (array_length(bass_text_arcs) > 0) {
  var _bta_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _bta_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _bta_cx = oCameraController.current_cam_x;
  var _bta_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  for (var _bta = 0; _bta < array_length(bass_text_arcs); _bta++) {
    var _arc = bass_text_arcs[_bta];
    var _aa = _arc.life / _arc.life_max;

    scr_draw_energy_bolt((_arc.ax - _bta_cx) * _bta_s, (_arc.ay - _bta_cy) * _bta_sy,
                         (_arc.bx - _bta_cx) * _bta_s, (_arc.by - _bta_cy) * _bta_sy,
                         _aa * 0.95, merge_color(c_red, c_white, _arc.hot),
                         _arc.off, _arc.width * _bta_s, 0.8);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(laser_chain_breaks) > 0) {
  var _cbk_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _cbk_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _cbk_cx = oCameraController.current_cam_x;
  var _cbk_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  for (var _cbk = 0; _cbk < array_length(laser_chain_breaks); _cbk++) {
    var _brk = laser_chain_breaks[_cbk];
    var _ba = _brk.life / _brk.life_max;

    scr_draw_energy_bolt((_brk.x1 - _cbk_cx) * _cbk_s, (_brk.y1 - _cbk_cy) * _cbk_sy,
                         (_brk.x2 - _cbk_cx) * _cbk_s, (_brk.y2 - _cbk_cy) * _cbk_sy,
                         _ba * _ba, merge_color(_k_laser_chain_glow_color, c_white, 0.5),
                         _brk.off, (1 + _ba * 2) * _cbk_s, 0.85);
  }
  gpu_set_blendmode(bm_normal);
}

if (laser_jump_warn_active && laser_jump_warn_coil > 0.01) {
  var _ljg_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _ljg_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _ljg_camx = oCameraController.current_cam_x;
  var _ljg_camy = oCameraController.current_cam_y;
  var _ljg_p = clamp(laser_jump_warn_t / max(laser_jump_warn_len, 1), 0, 1);
  var _ljg_gy = (_k_laser_jump_y - _ljg_camy) * _ljg_sy;
  var _ljg_r = _k_laser_jump_warn_lane_r * _ljg_sy;
  var _ljg_hot = max(laser_jump_warn_coil, _k_laser_jump_warn_read_floor);
  var _ljg_head_l = lerp(_k_laser_jump_warn_gate_w * 0.72,
                         room_width * 0.5 - 10,
                         power(_ljg_p, 0.78));
  var _ljg_head_r = room_width - _ljg_head_l;
  var _ljg_strobe = clamp((_ljg_p - 0.75) / 0.25, 0, 1);
  var _ljg_pulse = lerp(0.72 + 0.28 * sin(t * 0.85),
                        0.32 + 0.68 * abs(sin(t * 1.9)), _ljg_strobe);

  gpu_set_blendmode(bm_add);
  for (var _ljg_side = 0; _ljg_side < 2; _ljg_side++) {
    var _ljg_dir = (_ljg_side == 0) ? 1 : -1;
    var _ljg_gx0 = (((_ljg_side == 0) ? 0 : room_width - _k_laser_jump_warn_gate_w) - _ljg_camx) * _ljg_s;
    var _ljg_gx1 = (((_ljg_side == 0) ? _k_laser_jump_warn_gate_w : room_width) - _ljg_camx) * _ljg_s;
    var _ljg_head = (((_ljg_side == 0) ? _ljg_head_l : _ljg_head_r) - _ljg_camx) * _ljg_s;

    scr_draw_lock_bracket_glow(_ljg_gx0 + 4 * _ljg_s, _ljg_gy - _ljg_r * 1.62,
                               _ljg_gx1 - 4 * _ljg_s, _ljg_gy + _ljg_r * 1.62,
                               _k_er_col_cyan, _ljg_hot, 0.95, 0, _ljg_pulse);

    draw_set_color(c_white);
    draw_set_alpha((0.16 + _ljg_hot * 0.34) * _ljg_pulse);
    draw_line_width(_ljg_head, _ljg_gy - _ljg_r * 1.5,
                    _ljg_head, _ljg_gy + _ljg_r * 1.5,
                    max(1, (2 + _ljg_hot * 3) * _ljg_s));

    for (var _ljg_pk = 0; _ljg_pk < _k_laser_jump_warn_packet_n; _ljg_pk++) {
      var _ljg_pf = frac(_ljg_pk / _k_laser_jump_warn_packet_n
                         + current_time * 0.0014 * (0.8 + _ljg_hot));
      var _ljg_mx = (_ljg_side == 0) ? (10 - _ljg_camx) * _ljg_s
                                     : (room_width - 10 - _ljg_camx) * _ljg_s;
      var _ljg_px = lerp(_ljg_mx, _ljg_head, _ljg_pf);
      var _ljg_pa = sin(_ljg_pf * pi) * (0.12 + _ljg_hot * 0.24);
      var _ljg_pk_col = ((_ljg_pk mod 3) == 0) ? _k_er_col_cyan
                     : (((_ljg_pk mod 3) == 1) ? _k_er_col_warning : _k_er_col_violet);

      draw_set_color(merge_color(_ljg_pk_col, c_white, 0.45));
      draw_set_alpha(_ljg_pa);
      draw_line_width(_ljg_px - _ljg_dir * (18 + _ljg_hot * 22) * _ljg_s, _ljg_gy,
                      _ljg_px + _ljg_dir * (4 + _ljg_hot * 8) * _ljg_s, _ljg_gy,
                      max(1, 2.5 * _ljg_s));
    }
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(laser_jump_warn_vents) > 0) {
  var _ljv_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _ljv_camx = oCameraController.current_cam_x;
  var _ljv_camy = oCameraController.current_cam_y;
  gpu_set_blendmode(bm_add);
  scr_draw_vent_streams(laser_jump_warn_vents, _ljv_camx, _ljv_camy, _ljv_s);
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(laser_jump_warn_arcs) > 0) {
  var _lja_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _lja_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _lja_camx = oCameraController.current_cam_x;
  var _lja_camy = oCameraController.current_cam_y;
  gpu_set_blendmode(bm_add);
  for (var _lja = 0; _lja < array_length(laser_jump_warn_arcs); _lja++) {
    var _ea = laser_jump_warn_arcs[_lja];
    var _aa = clamp(_ea.life / _ea.life_max, 0, 1);
    scr_draw_energy_bolt((_ea.x1 - _lja_camx) * _lja_s, (_ea.y1 - _lja_camy) * _lja_sy,
                         (_ea.x2 - _lja_camx) * _lja_s, (_ea.y2 - _lja_camy) * _lja_sy,
                         _aa * (0.35 + _ea.hot * 0.55),
                         _ea.color, _ea.off,
                         (1.5 + _ea.hot * 2.5) * _lja_s, 0.85);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(laser_jump_bursts) > 0) {
  var _ljb_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _ljb_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _ljb_camx = oCameraController.current_cam_x;
  var _ljb_camy = oCameraController.current_cam_y;
  gpu_set_blendmode(bm_add);
  for (var _ljb = 0; _ljb < array_length(laser_jump_bursts); _ljb++) {
    var _sb = laser_jump_bursts[_ljb];
    var _age = _sb.life_max - _sb.life;
    var _sp = clamp(_age / max(_sb.life_max - 1, 1), 0, 1);
    var _sweep = 1 - power(1 - clamp(_sp * 1.45, 0, 1), 3);
    var _x0 = (_sb.dir > 0) ? 0 : room_width;
    var _x1 = _x0 + _sb.dir * room_width * _sweep;
    var _fade = power(clamp(_sb.life / _sb.life_max, 0, 1), 0.65);
    var _gx0 = (_x0 - _ljb_camx) * _ljb_s;
    var _gx1 = (_x1 - _ljb_camx) * _ljb_s;
    var _gy = (_sb.y - _ljb_camy) * _ljb_sy;
    draw_set_color(_sb.col);
    draw_set_alpha(_fade * 0.62);
    draw_line_width(_gx0, _gy, _gx1, _gy, (12 + _fade * 18) * _ljb_s);
    draw_set_color(c_white);
    draw_set_alpha(_fade * 0.85);
    draw_line_width(_gx0, _gy, _gx1, _gy, (3 + _fade * 4) * _ljb_s);
    draw_set_color(merge_color(_k_er_col_molten, c_white, 0.35));
    draw_set_alpha(_fade * 0.24);
    draw_line_width(_gx0, _gy + 8 * _ljb_sy, _gx1, _gy + 8 * _ljb_sy,
                    (7 + _fade * 10) * _ljb_s);
  }
  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
}

if (array_length(laser_x_marks) > 0) {
  var _lxm_s = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _lxm_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _lxm_cx = oCameraController.current_cam_x;
  var _lxm_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  for (var _lxm = 0; _lxm < array_length(laser_x_marks); _lxm++) {
    var _m = laser_x_marks[_lxm];
    var _born = 1 - (_m.life / max(_m.life_max, 1));
    var _in = clamp(_born / 0.16, 0, 1);
    var _fade = clamp(_m.life / 18, 0, 1);
    var _a = _in * _fade;
    if (_a <= 0.01) continue;

    var _active = variable_struct_exists(_m, "active") && _m.active;
    var _active_p = _active ? clamp(_m.life / max(_m.active_life, 1), 0, 1) : 1;
    var _shrink = _active ? lerp(0.3, 1, power(_active_p, 0.7)) : 1;
    var _strike = variable_struct_exists(_m, "strike") ? _m.strike : 0;
    var _hot = _active ? clamp(0.86 + _m.hot * 0.12 + _strike * 0.18, 0, 1)
                       : clamp(_m.hot + _m.ring * 0.45, 0, 1);
    var _col = merge_color(global.avoid_col_cyan, global.avoid_col_warning, _hot);
    var _gcol = merge_color(_col, c_white, 0.24 + _hot * 0.3);
    var _cx = (_m.x - _lxm_cx) * _lxm_s;
    var _cy = (_m.y - _lxm_cy) * _lxm_sy;
    var _len = _m.arm_len * (0.84 + _in * 0.16 + _m.hot * 0.1) * _shrink * (1 + _strike * 0.14);

    scr_draw_smooth_ring_mask(_cx, _cy, (20 + _hot * 26) * _lxm_s,
                              (0.16 + _hot * 0.24 + _m.ring * 0.22) * _a,
                              6, _gcol);

    if (_strike > 0.01) {
      var _strike_ang = variable_struct_exists(_m, "trigger_ang") ? _m.trigger_ang : _m.ang;
      var _sx1 = (_m.x + lengthdir_x(_m.arm_len * 1.2, _strike_ang) - _lxm_cx) * _lxm_s;
      var _sy1 = (_m.y + lengthdir_y(_m.arm_len * 1.2, _strike_ang) - _lxm_cy) * _lxm_sy;
      var _sx2 = (_m.x - lengthdir_x(_m.arm_len * 1.2, _strike_ang) - _lxm_cx) * _lxm_s;
      var _sy2 = (_m.y - lengthdir_y(_m.arm_len * 1.2, _strike_ang) - _lxm_cy) * _lxm_sy;
      draw_set_color(global.avoid_col_hot);
      draw_set_alpha(_strike * 0.28 * _a);
      draw_line_width(_sx1, _sy1, _sx2, _sy2, 14 * _lxm_s);
      scr_draw_energy_bolt(_sx1, _sy1, _sx2, _sy2,
                           _strike * 0.9 * _a,
                           merge_color(global.avoid_col_hot, c_white, 0.25),
                           _m.off_a, (3.2 + _strike * 2.2) * _lxm_s, 0.92);
    }

    for (var _axis = 0; _axis < 2; _axis++) {
      var _ang = _m.ang + _axis * 90;
      var _x1 = (_m.x + lengthdir_x(_len, _ang) - _lxm_cx) * _lxm_s;
      var _y1 = (_m.y + lengthdir_y(_len, _ang) - _lxm_cy) * _lxm_sy;
      var _x2 = (_m.x - lengthdir_x(_len, _ang) - _lxm_cx) * _lxm_s;
      var _y2 = (_m.y - lengthdir_y(_len, _ang) - _lxm_cy) * _lxm_sy;
      var _off = (_axis == 0) ? _m.off_a : _m.off_b;

      draw_set_color(_col);
      draw_set_alpha((0.08 + _hot * 0.12) * _a);
      draw_line_width(_x1, _y1, _x2, _y2, (13 + _hot * 10) * _lxm_s);

      scr_draw_energy_bolt(_x1, _y1, _x2, _y2,
                           (0.28 + _hot * 0.58) * _a,
                           _gcol, _off, (1.4 + _hot * 2.4) * _lxm_s, 0.78);
    }
  }
  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

if (array_length(slash_bolts) > 0) {
  var _sbs = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _sbsy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _sbcx = oCameraController.current_cam_x;
  var _sbcy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  for (var _sb = 0; _sb < array_length(slash_bolts); _sb++) {
    var _sbb = slash_bolts[_sb];
    var _sba = _sbb.life / _sbb.life_max;

    var _sbcol = (variable_struct_exists(_sbb, "col") && !is_undefined(_sbb.col))
               ? _sbb.col
               : make_color_rgb(255, 60, 50);

    scr_draw_energy_bolt((_sbb.x1 - _sbcx) * _sbs, (_sbb.y1 - _sbcy) * _sbsy,
                         (_sbb.x2 - _sbcx) * _sbs, (_sbb.y2 - _sbcy) * _sbsy,
                         _sba, merge_color(_sbcol, c_white, _sbb.hot),
                         _sbb.off, _sbb.width * _sbs, 0.8);
  }
  gpu_set_blendmode(bm_normal);
}

if (array_length(bass_text_leaks) > 0 || array_length(laser_finale_leaks) > 0 ||
    array_length(laser_coil_leaks) > 0 || array_length(laser_coil_arcs) > 0 ||
    array_length(laser_vents) > 0) {
  var _lks = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _lksy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _lkcx = oCameraController.current_cam_x;
  var _lkcy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);

  for (var _lk = 0; _lk < array_length(bass_text_leaks); _lk++) {
    var _lkk = bass_text_leaks[_lk];
    var _lka = _lkk.life / _lkk.life_max;
    var _lkx2 = _lkk.x1 + lengthdir_x(_lkk.reach * (1 - _lka * 0.4), _lkk.ang);
    var _lky2 = _lkk.y1 + lengthdir_y(_lkk.reach * (1 - _lka * 0.4), _lkk.ang);

    scr_draw_energy_bolt((_lkk.x1 - _lkcx) * _lks, (_lkk.y1 - _lkcy) * _lksy,
                         (_lkx2 - _lkcx) * _lks, (_lky2 - _lkcy) * _lksy,
                         _lka * 0.9, merge_color(c_red, c_white, 0.35), _lkk.off, 1.4 * _lks, 0.85);
  }

  for (var _flk = 0; _flk < array_length(laser_finale_leaks); _flk++) {
    var _flkk = laser_finale_leaks[_flk];
    var _flka = _flkk.life / _flkk.life_max;

    scr_draw_energy_bolt((_flkk.x1 - _lkcx) * _lks, (_flkk.y1 - _lkcy) * _lksy,
                         (_flkk.x2 - _lkcx) * _lks, (_flkk.y2 - _lkcy) * _lksy,
                         _flka * 0.9, merge_color(c_red, c_white, 0.4), _flkk.off, 1.6 * _lks, 0.85);
  }

  if (laser_coil_active) {
    var _lc_p2 = clamp(laser_coil_t / laser_coil_len, 0, 1);
    var _lc_r2 = lerp(_k_laser_coil_ring_start, _k_laser_coil_ring_end, _lc_p2) * laser_coil_power;

    for (var _lcl = 0; _lcl < array_length(laser_coil_leaks); _lcl++) {
      var _lcll = laser_coil_leaks[_lcl];
      var _lcla = _lcll.life / _lcll.life_max;
      var _lc1x = laser_coil_x + lengthdir_x(_lc_r2, _lcll.ang);
      var _lc1y = laser_coil_y + lengthdir_y(_lc_r2, _lcll.ang);
      var _lc2x = laser_coil_x + lengthdir_x(_k_laser_coil_leak_reach, _lcll.ang);
      var _lc2y = laser_coil_y + lengthdir_y(_k_laser_coil_leak_reach, _lcll.ang);

      scr_draw_energy_bolt((_lc1x - _lkcx) * _lks, (_lc1y - _lkcy) * _lksy,
                           (_lc2x - _lkcx) * _lks, (_lc2y - _lkcy) * _lksy,
                           _lcla * 0.9, merge_color(c_red, c_white, 0.45), _lcll.off, 1.4 * _lks, 0.85);
    }

    for (var _lca = 0; _lca < array_length(laser_coil_arcs); _lca++) {
      var _lcaa = laser_coil_arcs[_lca];
      var _lcaal = _lcaa.life / _lcaa.life_max;
      var _lcax = laser_coil_x + lengthdir_x(_k_laser_coil_arc_outer, _lcaa.ang);
      var _lcay = laser_coil_y + lengthdir_y(_k_laser_coil_arc_outer, _lcaa.ang);

      scr_draw_energy_bolt((_lcax - _lkcx) * _lks, (_lcay - _lkcy) * _lksy,
                           (laser_coil_x - _lkcx) * _lks, (laser_coil_y - _lkcy) * _lksy,
                           _lcaal * 0.95, merge_color(c_red, c_white, 0.3 + _lc_p2 * 0.5),
                           _lcaa.off, (1 + _lc_p2 * 1.5) * _lks, 0.8);
    }

    if (laser_lock_len > 8) {
      var _lbg_heavy = (laser_coil_power >= _k_laser_lock_heavy_power);
      var _lbg_hot = max(power(_lc_p2, 1.45),
                         lerp(_k_laser_lock_read_floor, 1, power(_lc_p2, 1.2)));
      var _lbg_gx = (laser_lock_cx - _lkcx) * _lks;
      var _lbg_gy = (laser_lock_cy - _lkcy) * _lksy;
      var _lbg_a = _lc_p2 * (_lbg_heavy ? 1 : _k_laser_lock_light_bloom);
      if (laser_coil_centered) _lbg_a *= 1.6;

      scr_draw_lock_bracket_glow(_lbg_gx - laser_lock_len * _lks, _lbg_gy - laser_lock_wid * _lksy,
                                 _lbg_gx + laser_lock_len * _lks, _lbg_gy + laser_lock_wid * _lksy,
                                 global.avoid_col_warning, _lbg_hot, _lbg_a, laser_lock_ang,
                                 0.65 + 0.35 * sin(t * 0.7));
    }
  }

  scr_draw_vent_streams(laser_vents, _lkcx, _lkcy, _lks);

  gpu_set_blendmode(bm_normal);
}

if (!is_undefined(riser)) {
  scr_riser_draw_bolts(oCameraController.current_cam_x, oCameraController.current_cam_y,
                       oCameraController.base_view_w / oCameraController.current_cam_w,
                       oCameraController.base_view_h / oCameraController.current_cam_h);
}

if (!is_undefined(vault)) {
  scr_vault_draw_bolts(oCameraController.current_cam_x, oCameraController.current_cam_y,
                       oCameraController.base_view_w / oCameraController.current_cam_w,
                       oCameraController.base_view_h / oCameraController.current_cam_h);
}

if (dna_veil > 0.06 &&
    (array_length(dna_write_arcs) > 0 || array_length(dna_cross_arcs) > 0 || !is_undefined(lat))) {

  var _dg_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _dg_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _dg_cx = oCameraController.current_cam_x;
  var _dg_cy = oCameraController.current_cam_y;
  var _dg_col = global.avoid_col_danger;
  var _dg_write_col = global.avoid_col_cyan;

  gpu_set_blendmode(bm_add);

  for (var _dw = 0; _dw < array_length(dna_write_arcs); _dw++) {
    var _dwa = dna_write_arcs[_dw];
    var _dwal = _dwa.life / _dwa.life_max;
    scr_draw_energy_bolt((_dwa.sx - _dg_cx) * _dg_sx, (_dwa.sy - _dg_cy) * _dg_sy,
                         (_dwa.ex - _dg_cx) * _dg_sx, (_dwa.ey - _dg_cy) * _dg_sy,
                         _dwal * 0.95, merge_color(_dg_write_col, c_white, 0.4), _dwa.off, 1.3 * _dg_sx, 0.85);
  }

  for (var _dc = 0; _dc < array_length(dna_cross_arcs); _dc++) {
    var _dca = dna_cross_arcs[_dc];
    if (!instance_exists(_dca.a) || !instance_exists(_dca.b)) continue;
    var _dcal = _dca.life / _dca.life_max;
    scr_draw_energy_bolt((_dca.a.x - _dg_cx) * _dg_sx, (_dca.a.y - _dg_cy) * _dg_sy,
                         (_dca.b.x - _dg_cx) * _dg_sx, (_dca.b.y - _dg_cy) * _dg_sy,
                         _dcal * 0.9, merge_color(_dg_col, c_white, 0.55), _dca.off, 2.0 * _dg_sx, 0.9);
  }

  scr_lattice_draw_bolts(_dg_cx, _dg_cy, _dg_sx, _dg_sy);

  gpu_set_blendmode(bm_normal);
}

if (instance_exists(oHoneycombController)) {
  var _hb = oHoneycombController;

  if (array_length(_hb.hc_scan_arcs) > 0 || array_length(_hb.hc_coil_arcs) > 0 ||
      _hb.hc_detonate_flash > 0.02 || _hb.duct_seam > 0.15 || _hb.duct_lurch > 0.25) {
    var _hb_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
    var _hb_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
    var _hb_cx = oCameraController.current_cam_x;
    var _hb_cy = oCameraController.current_cam_y;
    var _hb_col = merge_color(make_color_rgb(255, 70, 55), c_white, 0.25);

    gpu_set_blendmode(bm_add);

    for (var _hs = 0; _hs < array_length(_hb.hc_scan_arcs); _hs++) {
      var _sc = _hb.hc_scan_arcs[_hs];
      var _sca = _sc.life / _sc.life_max;
      var _sx1 = _hb.center_x + cos(_sc.a1) * _hb.radius;
      var _sy1 = _hb.center_y + _sc.h + sin(_sc.a1) * _hb.depth_offset;
      var _sx2 = _hb.center_x + cos(_sc.a2) * _hb.radius;
      var _sy2 = _hb.center_y + _sc.h + sin(_sc.a2) * _hb.depth_offset;

      scr_draw_energy_bolt((_sx1 - _hb_cx) * _hb_sx, (_sy1 - _hb_cy) * _hb_sy,
                           (_sx2 - _hb_cx) * _hb_sx, (_sy2 - _hb_cy) * _hb_sy,
                           _sca * 0.9, _hb_col, _sc.off, 1.5 * _hb_sx, 0.8);
    }

    for (var _hca = 0; _hca < array_length(_hb.hc_coil_arcs); _hca++) {
      var _ca = _hb.hc_coil_arcs[_hca];
      var _caa = _ca.life / _ca.life_max;
      var _cax = _hb.center_x + lengthdir_x(_ca.reach, _ca.ang);
      var _cay = _hb.center_y + _ca.h + lengthdir_y(_ca.reach * 0.55, _ca.ang);
      var _ctx = _hb.center_x + lengthdir_x(_hb.radius * 0.35, _ca.ang);
      var _cty = _hb.center_y + _ca.h * 0.6;

      scr_draw_energy_bolt((_cax - _hb_cx) * _hb_sx, (_cay - _hb_cy) * _hb_sy,
                           (_ctx - _hb_cx) * _hb_sx, (_cty - _hb_cy) * _hb_sy,
                           _caa * 0.95, merge_color(_hb_col, c_white, _hb.hc_coil * 0.5),
                           _ca.off, (1 + _hb.hc_coil * 1.8) * _hb_sx, 0.8);
    }

    if (_hb.hc_detonate_flash > 0.02) {
      var _det_n = 14;
      var _det_reach = lerp(90, 720, 1 - _hb.hc_detonate_flash);
      for (var _dt = 0; _dt < _det_n; _dt++) {
        var _dang = (360 / _det_n) * _dt + _hb.hc_detonate_flash * 40;
        var _dx2 = _hb.center_x + lengthdir_x(_det_reach, _dang);
        var _dy2 = _hb.center_y + lengthdir_y(_det_reach * 0.5, _dang);
        scr_draw_energy_bolt((_hb.center_x - _hb_cx) * _hb_sx, (_hb.center_y - _hb_cy) * _hb_sy,
                             (_dx2 - _hb_cx) * _hb_sx, (_dy2 - _hb_cy) * _hb_sy,
                             _hb.hc_detonate_flash * 0.95, merge_color(_hb_col, c_white, 0.5),
                             scr_bolt_offsets(5, 26), 2.4 * _hb_sx, 0.85);
      }
    }

    scr_duct_draw_bolts(_hb_cx, _hb_cy, _hb_sx, _hb_sy);

    gpu_set_blendmode(bm_normal);
  }
}

if (t >= _k_arc_rift_t - 8 && t <= _k_arc_window_end) {
  var _aa_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _aa_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _aa_cx = oCameraController.current_cam_x;
  var _aa_cy = oCameraController.current_cam_y;
  var _aa_col = _k_arc_color;
  var _aa_hot = _k_arc_hot_color;

  gpu_set_blendmode(bm_add);

  if (arc_rift > 0.02 && array_length(arc_rift_pts) > 1) {
    var _rn = array_length(arc_rift_pts);
    var _rlit = arc_rift_open * (_rn - 1);
    var _rcol = merge_color(_aa_col, c_white, 0.2 + arc_rift * 0.4 + arc_fire_flash * 0.4);

    for (var _ri = 0; _ri < _rn - 1; _ri++) {
      if (_ri > _rlit) break;

      var _p1 = arc_rift_pts[_ri];
      var _p2 = arc_rift_pts[_ri + 1];

      var _edge = 1 - clamp(_rlit - _ri, 0, 1) * 0.55;
      var _ra = arc_rift * (0.5 + _edge * 0.5) * (0.6 + arc_charge * 0.5);

      scr_draw_energy_bolt((_p1.x - _aa_cx) * _aa_sx, (_p1.y + _p1.jag - _aa_cy) * _aa_sy,
                           (_p2.x - _aa_cx) * _aa_sx, (_p2.y + _p2.jag - _aa_cy) * _aa_sy,
                           _ra, _rcol, scr_bolt_offsets(3, 4 + arc_charge * 9),
                           (1.4 + arc_rift * 2.2 + arc_fire_flash * 3) * _aa_sx, 0.6);
    }
  }

  for (var _wi2 = 0; _wi2 < array_length(arc_welds); _wi2++) {
    var _wd = arc_welds[_wi2];
    var _wa = _wd.life / _wd.life_max;
    scr_draw_energy_bolt((_wd.x1 - _aa_cx) * _aa_sx, (_wd.y1 - _aa_cy) * _aa_sy,
                         (_wd.x2 - _aa_cx) * _aa_sx, (_wd.y2 - _aa_cy) * _aa_sy,
                         _wa * 0.95, merge_color(_aa_col, c_white, 0.35),
                         _wd.off, _wd.width * _aa_sx, 0.75);
  }

  for (var _si3 = 0; _si3 < array_length(arc_stitch); _si3++) {
    var _st2 = arc_stitch[_si3];
    var _sa2 = _st2.life / _st2.life_max;
    scr_draw_energy_bolt((_st2.x1 - _aa_cx) * _aa_sx, (_st2.y1 - _aa_cy) * _aa_sy,
                         (_st2.x2 - _aa_cx) * _aa_sx, (_st2.y2 - _aa_cy) * _aa_sy,
                         _sa2 * 0.7, _aa_col, _st2.off, _st2.width * _aa_sx, 0.5);
  }

  for (var _mi2 = 0; _mi2 < array_length(arc_muzzles); _mi2++) {
    var _mz = arc_muzzles[_mi2];
    var _mza = _mz.life / _mz.life_max;
    var _mgx = (_mz.x - _aa_cx) * _aa_sx;
    var _mgy = (_mz.y - _aa_cy) * _aa_sy;

    for (var _mb = 0; _mb < 3; _mb++) {
      var _mang = _mz.dir + random_range(-28, 28);
      var _mlen = (30 + random(70)) * (0.4 + _mza);
      scr_draw_energy_bolt(_mgx, _mgy,
                           _mgx + lengthdir_x(_mlen * _aa_sx, _mang),
                           _mgy + lengthdir_y(_mlen * _aa_sy, _mang),
                           _mza * 0.9, merge_color(_aa_hot, c_white, 0.4),
                           scr_bolt_offsets(4, 12), 1.8 * _aa_sx, 0.85);
    }
  }

  for (var _bt = 0; _bt < array_length(arc_blades); _bt++) {
    var _btb = arc_blades[_bt];
    if (!_btb.live || _btb.fired) continue;

    var _bt_seam = arc_rift_y_at(_btb.x);
    var _bt_hot  = 0.45 + arc_charge * 0.4 + _btb.forge * 0.6;

    scr_draw_energy_bolt((_btb.x - _aa_cx) * _aa_sx, (_bt_seam - _aa_cy) * _aa_sy,
                         (_btb.x - _aa_cx) * _aa_sx, (_btb.y - _aa_cy) * _aa_sy,
                         _bt_hot, merge_color(_aa_col, c_white, 0.3 + _btb.forge * 0.5),
                         scr_bolt_offsets(4, 3 + arc_charge * 7),
                         (0.9 + arc_charge * 1.2) * _aa_sx, 0.7);
  }

  scr_draw_vent_streams(arc_vents, _aa_cx, _aa_cy, _aa_sx);

  if (arc_fire_ripple > 0.01) {
    lightning_bloom_boost = max(lightning_bloom_boost, arc_fire_ripple * 0.5);
  }

  for (var _li2 = 0; _li2 < array_length(orb_leaks); _li2++) {
    var _lk2 = orb_leaks[_li2];
    if (!instance_exists(_lk2.inst)) continue;
    var _lka = _lk2.life / _lk2.life_max;
    var _lgx = (_lk2.inst.x - _aa_cx) * _aa_sx;
    var _lgy = (_lk2.inst.y - _aa_cy) * _aa_sy;

    scr_draw_energy_bolt(_lgx, _lgy,
                         _lgx + lengthdir_x(_lk2.reach * _lka * _aa_sx, _lk2.ang),
                         _lgy + lengthdir_y(_lk2.reach * _lka * _aa_sy, _lk2.ang),
                         _lka * 0.85, _aa_col, _lk2.off, _lk2.width * _aa_sx, 0.65);
  }

  for (var _ti2 = 0; _ti2 < array_length(orb_bridges); _ti2++) {
    var _tr2 = orb_bridges[_ti2];
    var _tra = _tr2.life / _tr2.life_max;
    scr_draw_energy_bolt((_tr2.ax - _aa_cx) * _aa_sx, (_tr2.ay - _aa_cy) * _aa_sy,
                         (_tr2.bx - _aa_cx) * _aa_sx, (_tr2.by - _aa_cy) * _aa_sy,
                         _tra * 0.95, merge_color(_aa_col, c_white, _tr2.hot * 0.5),
                         _tr2.off, _tr2.width * _tra * 0.5 * _aa_sx, 0.7);
  }

  with (oBigRedOrb) {
    if (lock_pulse <= 0.03 || ring_id < 0 || socket_slot < 0) continue;
    if (ring_id >= array_length(other.orb_rails)) continue;
    var _lkr = other.orb_rails[ring_id];
    if (!is_struct(_lkr) || socket_slot >= array_length(_lkr.sockets)) continue;
    var _lkp = orb_socket_pos(_lkr, socket_slot);
    if (point_distance(x, y, _lkp[0], _lkp[1]) > 150) continue;
    scr_draw_energy_bolt((_lkp[0] - _aa_cx) * _aa_sx, (_lkp[1] - _aa_cy) * _aa_sy,
                         (x - _aa_cx) * _aa_sx, (y - _aa_cy) * _aa_sy,
                         lock_pulse * 0.9, global.avoid_col_cyan_soft,
                         scr_bolt_offsets(3, 3 + lock_pulse * 7),
                          (0.9 + lock_pulse * 1.4) * _aa_sx, 0.8);
  }

  for (var _utb = 0; _utb < array_length(orb_unwrap_tracks); _utb++) {
    scr_draw_orb_unwrap_track_bolt(orb_unwrap_tracks[_utb], _aa_cx, _aa_cy, _aa_sx, _aa_sy);
  }

  gpu_set_blendmode(bm_normal);
}

if (t >= _k_mill_t_seed - 4 && t <= _k_mill_window_end) {
  var _mb_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _mb_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _mb_cx = oCameraController.current_cam_x;
  var _mb_cy = oCameraController.current_cam_y;
  var _mb_col = _k_arc_color;
  var _mb_hot = _k_arc_hot_color;

  var _mb_px = (_k_mill_cx - _mb_cx) * _mb_sx;
  var _mb_py = (_k_mill_cy - _mb_cy) * _mb_sy;

  gpu_set_blendmode(bm_add);

  if (mill_charge > 0.02 && mill_rim > 4) {
    var _mb_arcs = 2 + floor(mill_charge * 7);
    for (var _mca = 0; _mca < _mb_arcs; _mca++) {
      var _mcang = random(360);
      var _mcr = mill_rim * random_range(0.85, 1.25);
      var _mcx = (_k_mill_cx + lengthdir_x(_mcr, _mcang) - _mb_cx) * _mb_sx;
      var _mcy = (_k_mill_cy + lengthdir_y(_mcr * (_k_mill_ry_out / _k_mill_rx_out), _mcang) - _mb_cy) * _mb_sy;

      scr_draw_energy_bolt(_mcx, _mcy, _mb_px, _mb_py,
                           (0.35 + mill_charge * 0.55) * random_range(0.7, 1),
                           _mb_col, scr_bolt_offsets(4, 6 + mill_charge * 16),
                           (1 + mill_charge * 2.4) * _mb_sx, 0.55);
    }

    if (random(1) < 0.25 + mill_charge * 0.4) {
      var _mlang = random(360);
      var _mllen = (80 + random(190)) * (0.4 + mill_charge);
      scr_draw_energy_bolt(_mb_px, _mb_py,
                           _mb_px + lengthdir_x(_mllen, _mlang) * _mb_sx,
                           _mb_py + lengthdir_y(_mllen, _mlang) * _mb_sy,
                           0.3 + mill_charge * 0.4, _mb_hot,
                           scr_bolt_offsets(5, 14), 1.6 * _mb_sx, 0.8);
    }
  }

  with (oLaserOrbTrigger) {
    if (!is_rotating) continue;
    var _mkr = _k_beam_half_length * extend;
    if (_mkr < 4) continue;

    var _mkax = image_angle - 90;
    var _mk1x = (x - lengthdir_x(_mkr, _mkax) - _mb_cx) * _mb_sx;
    var _mk1y = (y - lengthdir_y(_mkr, _mkax) - _mb_cy) * _mb_sy;
    var _mk2x = (x + lengthdir_x(_mkr, _mkax) - _mb_cx) * _mb_sx;
    var _mk2y = (y + lengthdir_y(_mkr, _mkax) - _mb_cy) * _mb_sy;

    var _mkheat = beam_heat / _k_beam_heat_max;
    scr_draw_energy_bolt(_mk1x, _mk1y, _mk2x, _mk2y,
                         0.5 + _mkheat * 0.5 + other.mill_blade_flash * 0.5,
                         beam_col_outer,
                         scr_bolt_offsets(7, 5 + _mkheat * 22 + other.mill_blade_flash * 26),
                         (1.6 + _mkheat * 3.4) * _mb_sx, 0.7);
  }

  if (mill_field_heat > 0.05 && !mill_torn && array_length(mill_arm_waves) > 0) {
    var _mac = 1 + floor(mill_field_heat * 3);
    for (var _mai2 = 0; _mai2 < _mac; _mai2++) {
      var _mawv = mill_arm_waves[irandom(array_length(mill_arm_waves) - 1)];
      if (_mawv.count < 2) continue;

      var _maf2 = random_range(0.25, 1);
      var _mak  = irandom(_mawv.count - 1);
      var _map1 = scr_mill_arm_point(_mawv, _mak, _maf2, _k_mill_cx, _k_mill_cy);
      var _map2 = scr_mill_arm_point(_mawv, (_mak + 1) mod _mawv.count, _maf2,
                                     _k_mill_cx, _k_mill_cy);

      scr_draw_energy_bolt(
        (_map1.x - _mb_cx) * _mb_sx, (_map1.y - _mb_cy) * _mb_sy,
        (_map2.x - _mb_cx) * _mb_sx, (_map2.y - _mb_cy) * _mb_sy,
        mill_field_heat * 0.5, _mb_col, scr_bolt_offsets(4, 16), 1.3 * _mb_sx, 0.5);
    }
  }

  var _mb_gate_read_phase = (t >= _k_mill_t_seed_c && t < _k_mill_t_tear);
  for (var _msf = 0; _msf < array_length(mill_scars); _msf++) {
    var _msc3 = mill_scars[_msf];
    var _msig3 = max(_msc3.ignite, _msc3.guide);
    var _msoff3 = (_msig3 > 0.2) ? scr_bolt_offsets(5, 6 + _msig3 * 26) : _msc3.off;

    var _msbolt_a = _msc3.alpha * (0.55 + mill_overload * 0.45) + _msig3 * 0.7;
    var _msbolt_w = (1.4 + _msc3.alpha * 3.4 + mill_overload * 4 + _msig3 * 5) * _mb_sx;
    if (_mb_gate_read_phase) {
      _msbolt_a = (_msig3 > 0.02) ? _msig3 * 0.22 : 0;
      _msbolt_w = (0.8 + _msig3 * 1.4) * _mb_sx;
    }

    if (_msbolt_a > 0.02) {
      scr_draw_energy_bolt(
        (_k_mill_cx - lengthdir_x(_msc3.half_len, _msc3.ang) - _mb_cx) * _mb_sx,
        (_k_mill_cy - lengthdir_y(_msc3.half_len, _msc3.ang) - _mb_cy) * _mb_sy,
        (_k_mill_cx + lengthdir_x(_msc3.half_len, _msc3.ang) - _mb_cx) * _mb_sx,
        (_k_mill_cy + lengthdir_y(_msc3.half_len, _msc3.ang) - _mb_cy) * _mb_sy,
        _msbolt_a,
        merge_color(_mb_col, _mb_hot, _msc3.hot * 0.5 + _msig3 * 0.5),
        _msoff3, _msbolt_w, 0.7);
    }

    if (_msig3 > 0.35 && !_mb_gate_read_phase) {
      var _msn3 = 1 + floor(_msig3 * 3);
      for (var _msa3 = 0; _msa3 < _msn3; _msa3++) {
        var _msalong = random_range(-1, 1) * _msc3.half_len * 0.92;
        var _msox = _k_mill_cx + lengthdir_x(_msalong, _msc3.ang);
        var _msoy = _k_mill_cy + lengthdir_y(_msalong, _msc3.ang);
        var _msdir = _msc3.ang + 90 * choose(-1, 1);
        var _mslen = (40 + random(120)) * _msig3;
        scr_draw_energy_bolt((_msox - _mb_cx) * _mb_sx, (_msoy - _mb_cy) * _mb_sy,
                             (_msox + lengthdir_x(_mslen, _msdir) - _mb_cx) * _mb_sx,
                             (_msoy + lengthdir_y(_mslen, _msdir) - _mb_cy) * _mb_sy,
                             _msig3 * 0.6, _mb_hot, scr_bolt_offsets(3, 10), 1.4 * _mb_sx, 0.8);
      }
    }
  }

  with (oFallingRedOrb) {
    if (!mill_orb || dissolving || mill_link_to == noone) continue;
    if (!instance_exists(mill_link_to)) continue;

    var _wbo = mill_link_to;
    if (_wbo.dissolving) continue;

    var _wblive = (mill_wired && _wbo.mill_wired);
    var _wbrest = (!_wblive && !telegraphing && waiting_to_fall == 1 && _wbo.waiting_to_fall == 1);
    if (!_wblive && !telegraphing && !_wbrest) continue;

    var _wbfuse = 1;
    if (_wbrest) {
      _wbfuse = 0;
    } else if (!_wblive) {
      var _wbfa = clamp((telegraph_duration - telegraph_timer - mill_fuse_delay)
                        / max(mill_fuse_span, 1), 0, 1);
      var _wbfb = clamp((_wbo.telegraph_duration - _wbo.telegraph_timer - _wbo.mill_fuse_delay)
                        / max(_wbo.mill_fuse_span, 1), 0, 1);
      _wbfuse = min(_wbfa, _wbfb);
      if (_wbfuse <= 0) continue;
    }

    var _wbcol = mill_gate_cyan ? global.avoid_col_cyan : _mb_hot;

    scr_draw_energy_bolt((x - _mb_cx) * _mb_sx, (y - _mb_cy) * _mb_sy,
                         (_wbo.x - _mb_cx) * _mb_sx, (_wbo.y - _mb_cy) * _mb_sy,
                         _wblive ? 0.8 : (_wbrest ? 0.26 : (0.16 + _wbfuse * 0.3)),
                         _wblive ? _wbcol : merge_color(_wbcol, _mb_col, _wbrest ? 0.18 : 0.35),
                         scr_bolt_offsets(4, _wblive ? 9 : (_wbrest ? 4 : 3 + _wbfuse * 5)),
                         (_wblive ? 2.2 : (_wbrest ? 1.1 : 0.8 + _wbfuse * 0.7)) * _mb_sx,
                         _wblive ? 0.75 : (_wbrest ? 0.45 : 0.5 + _wbfuse * 0.18));
  }

  for (var _dbi = 0; _dbi < array_length(mill_scars); _dbi++) {
    var _dbc = mill_scars[_dbi];
    if (_dbc.door_a == noone || _dbc.door_b == noone) continue;
    if (!instance_exists(_dbc.door_a) || !instance_exists(_dbc.door_b)) continue;

    var _dba = _dbc.door_a;
    var _dbb = _dbc.door_b;
    if (_dba.dissolving || _dbb.dissolving) continue;
    if (!_dba.mill_wired && !_dba.telegraphing) continue;

    for (var _dbe = 0; _dbe < 2; _dbe++) {
      var _dbs = (_dbe == 0) ? _dba : _dbb;
      var _dbt = (_dbe == 0) ? _dbb : _dba;
      var _dbf = 0.20 + random(0.16);

      scr_draw_energy_bolt((_dbs.x - _mb_cx) * _mb_sx, (_dbs.y - _mb_cy) * _mb_sy,
                           (lerp(_dbs.x, _dbt.x, _dbf) - _mb_cx) * _mb_sx,
                           (lerp(_dbs.y, _dbt.y, _dbf) - _mb_cy) * _mb_sy,
                           0.5, _mb_hot, scr_bolt_offsets(3, 7), 1.5 * _mb_sx, 0.8);
    }
  }

  if (mill_overload > 0.03) {
    var _mon = 4 + floor(mill_overload * 10);
    for (var _moi = 0; _moi < _mon; _moi++) {
      var _moang = random(360);
      var _molen = (200 + random(520)) * mill_overload;
      scr_draw_energy_bolt(_mb_px, _mb_py,
                           _mb_px + lengthdir_x(_molen, _moang) * _mb_sx,
                           _mb_py + lengthdir_y(_molen, _moang) * _mb_sy,
                           mill_overload * 0.9, _mb_hot,
                           scr_bolt_offsets(6, 10 + mill_overload * 30),
                           (1.8 + mill_overload * 4) * _mb_sx, 0.85);
    }
  }

  gpu_set_blendmode(bm_normal);
}

var _ring_centers = array_create(8, 0.0);
var _ring_radii = array_create(4, 0.0);
var _ring_strengths = array_create(4, 0.0);
var _ring_count = 0;

for (var _sw = 0; _sw < array_length(slash_warps); _sw++) {
  if (_ring_count >= 4) break;
  var _swp = slash_warps[_sw];
  var _swa = _swp.life / _swp.life_max;
  if (_swa <= 0) continue;

  var _sw_gui_x = (_swp.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _sw_gui_y = (_swp.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  _ring_centers[_ring_count * 2] = _sw_gui_x / oCameraController.base_view_w;
  _ring_centers[_ring_count * 2 + 1] = _sw_gui_y / oCameraController.base_view_h;
  _ring_radii[_ring_count] = _swp.radius / oCameraController.current_cam_w;
  _ring_strengths[_ring_count] = _swp.strength * _swa * _swa * fx_get_mult("ripple");
  _ring_count++;
}

for (var i = 0; i < array_length(ring_bursts); ++i) {
  if (_ring_count >= 4) break;
  var _b = ring_bursts[i];
  if (_b.shockwave_alpha <= 0) continue;

  var _gui_x = (_b.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _gui_y = (_b.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  _ring_centers[_ring_count * 2] = _gui_x / oCameraController.base_view_w;
  _ring_centers[_ring_count * 2 + 1] = _gui_y / oCameraController.base_view_h;
  _ring_radii[_ring_count] = _b.shockwave_radius / oCameraController.current_cam_w;
  _ring_strengths[_ring_count] = _b.shockwave_alpha * 2;
  _ring_count++;
}

if (instance_exists(oHoneycombController)) {
  var _hcw = oHoneycombController;
  for (var _hr = 0; _hr < array_length(_hcw.hc_shock_rings); _hr++) {
    if (_ring_count >= 4) break;
    var _hrr = _hcw.hc_shock_rings[_hr];
    var _hr_gui_x = (_hcw.center_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _hr_gui_y = (_hcw.center_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    _ring_centers[_ring_count * 2] = _hr_gui_x / oCameraController.base_view_w;
    _ring_centers[_ring_count * 2 + 1] = _hr_gui_y / oCameraController.base_view_h;
    _ring_radii[_ring_count] = _hrr.r / oCameraController.current_cam_w;
    _ring_strengths[_ring_count] = power(_hrr.life / _hrr.life_max, 1.4) * 1.6;
    _ring_count++;
  }
}

surface_reset_target();

var _slash_gui_x =
    (slash_center_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
var _slash_gui_y =
    (slash_center_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
var _slash_u = _slash_gui_x / surface_get_width(application_surface);
var _slash_v = _slash_gui_y / surface_get_height(application_surface);

shader_set(shd_lightning_distort);
texture_set_stage(u_baseTex_handle, surface_get_texture(scene_snapshot));
shader_set_uniform_f(u_time_handle2, current_time / 1000);
var _distort_strength = 1.0;
if (er_lift_active && t >= _k_er_lift_charge_t && t < _k_er_materialize_t) _distort_strength = 0.22;
if (t >= _k_mill_volley_beats[0] - _k_mill_scar_lead && t < _k_mill_t_tear) {
  _distort_strength = min(_distort_strength, 0.16);
}
shader_set_uniform_f(u_strength_handle, _distort_strength);
shader_set_uniform_f(u_texel_handle2, 1 / surface_get_width(application_surface), 1 / surface_get_height(application_surface));
var _k_vignette_ceiling   = 0.62;
var _k_aberration_ceiling = 0.50;
var _k_tear_ceiling       = 0.52;
var _k_bolt_bloom_ceiling = 0.55;
var _k_bloom_pulse_mult   = 0.75;
var _k_ripple_mult        = 0.60;
var _k_ripple_ceiling     = 0.62;

shader_set_uniform_f(u_vignette_handle, min(vignette_pulse * fx_get_mult("vignette"), _k_vignette_ceiling));
shader_set_uniform_f(u_aberration_handle, min(aberration_pulse * fx_get_mult("aberration"), _k_aberration_ceiling));
shader_set_uniform_f(u_bloom_handle, bloom_base + bloom_pulse * fx_get_mult("bloom") * _k_bloom_pulse_mult + clamp(lightning_bloom_boost, 0, _k_bolt_bloom_ceiling));
shader_set_uniform_f(u_tear_handle, min(tear_amount * fx_get_mult("tear"), _k_tear_ceiling));
shader_set_uniform_f(u_ripple_handle, min(global_ripple_pulse * fx_get_mult("ripple") * _k_ripple_mult, _k_ripple_ceiling));
shader_set_uniform_f_array(u_ring_centers_handle, _ring_centers);
shader_set_uniform_f_array(u_ring_radii_handle, _ring_radii);
shader_set_uniform_f_array(u_ring_strengths_handle, _ring_strengths);
shader_set_uniform_i(u_ring_count_handle, _ring_count);
shader_set_uniform_f_array(u_swirl_centers_handle, _swirl_centers);
shader_set_uniform_f_array(u_swirl_radii_handle, _swirl_radii);
shader_set_uniform_f_array(u_swirl_strengths_handle, _swirl_strengths);
shader_set_uniform_i(u_swirl_count_handle, _swirl_count);
shader_set_uniform_f(u_intro_dim_h, intro_dim_amount);
shader_set_uniform_f(u_slash_amount_handle, slash_amount);
shader_set_uniform_f(u_slash_center_handle, _slash_u, _slash_v);
draw_surface(bolt_surface, 0, 0);
shader_reset();

glow_surface = surface_ensure(glow_surface, _app_surface_w, _app_surface_h);
surface_set_target(glow_surface);
draw_clear_alpha(0, 0);

scr_draw_avoidance_falling_red_orb_glow();

var player_pos = shader_get_uniform(shd_hex_2, "u_player_pos");

if (instance_exists(oPlayer)) {
  shader_set_uniform_f(player_pos, oPlayer.x / room_width, oPlayer.y / room_height);
}

scr_draw_avoidance_red_arrow_glow();
scr_draw_avoidance_red_bullet_intro_glow();

if (t >= _k_fin_t_open - 6 && t <= _k_fin_t_cut + 60) {
  var _fsx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _fsy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _fvx = oCameraController.current_cam_x;
  var _fvy = oCameraController.current_cam_y;
  var _fbh = sprite_get_width(spr_glow_blob) * 0.5;

  var _fr = color_get_red(_k_fin_orb_color) / 255;
  var _fg = color_get_green(_k_fin_orb_color) / 255;
  var _fb = color_get_blue(_k_fin_orb_color) / 255;

  var _fchroma = clamp(fin_chroma, 0, 1.6) * fx_get_mult("aberration");

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _fuv = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _fuv[0], _fuv[1], _fuv[2], _fuv[3]);

  var _fcore = fin_core * 0.85 + fin_heartbeat * (0.35 + fin_implode * 0.8)
             + fin_impact * 1.1 + fin_charge * 0.3 + fin_lock_flash * 0.4;
  if (_fcore > 0.02) {
    var _fpx = (_k_fin_cx - _fvx) * _fsx;
    var _fpy = (_k_fin_cy - _fvy) * _fsy;
    var _fcc = clamp(_fcore, 0, 1);

    var _wash = ((34 + _fcore * 120 + fin_impact * 180) * _fsx) / _fbh;
    shader_set_uniform_f(global.u_glow_color, _fr, _fg * 0.5, _fb * 0.45);
    shader_set_uniform_f(global.u_glow_intensity, 0.4 + _fcore * 0.75);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    draw_sprite_ext(spr_glow_blob, 0, _fpx, _fpy, _wash, _wash * 0.82, 0, c_white, 1);

    var _mid = ((14 + _fcore * 40 + fin_impact * 62) * _fsx) / _fbh;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 0.92, _fcc), lerp(0.26, 0.86, _fcc));
    shader_set_uniform_f(global.u_glow_intensity, 0.9 + _fcore * 0.9);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _fpx, _fpy, _mid, _mid, 0, c_white, 1);

    var _hot = ((4 + _fcore * 16 + fin_impact * 26) * _fsx) / _fbh;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.3 + _fcore * 1.3);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    draw_sprite_ext(spr_glow_blob, 0, _fpx, _fpy, _hot, _hot, 0, c_white, 1);
  }

  var _fag_vis = fin_assembly_visibility();
  if (_fag_vis > 0.01) {
    var _fag_heat = clamp(fin_assembly_pulse + fin_assembly_sync * 0.7 + fin_charge * 0.25
                          + fin_lock_flash * 0.18, 0, 1.6);
    var _fag_pull = clamp((t - _k_fin_t_breath) / max(_k_fin_t_cut - _k_fin_t_breath, 1), 0, 1);

    shader_set_uniform_f(global.u_glow_falloff, 1.75);

    var _core_s = ((14 + _fag_vis * 24 + _fag_heat * 18) * _fsx) / _fbh;
    shader_set_uniform_f(global.u_glow_color, 1, 0.32 + _fag_heat * 0.24, 0.28 + _fag_heat * 0.22);
    shader_set_uniform_f(global.u_glow_intensity, _fag_vis * (0.28 + _fag_heat * 0.36));
    draw_sprite_ext(spr_glow_blob, 0, (_k_fin_cx - _fvx) * _fsx, (_k_fin_cy - _fvy) * _fsy,
                    _core_s, _core_s * 0.9, 0, c_white, 1);

    var _core_hot = ((4 + _fag_heat * 8) * _fsx) / _fbh;
    shader_set_uniform_f(global.u_glow_color, 1, 0.88, 0.78);
    shader_set_uniform_f(global.u_glow_intensity, _fag_vis * (0.48 + _fag_heat * 0.54));
    draw_sprite_ext(spr_glow_blob, 0, (_k_fin_cx - _fvx) * _fsx, (_k_fin_cy - _fvy) * _fsy,
                    _core_hot, _core_hot, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_falloff, 1.95);
    for (var _fagr = 0; _fagr < array_length(_k_fin_assembly_ring_r); _fagr++) {
      var _grp = fin_assembly_ring_progress(_k_fin_assembly_ring_delay[_fagr]);
      if (_grp <= 0.04) continue;

      var _grcol = (_fagr mod 2) ? global.avoid_col_cyan : global.avoid_col_warning;
      shader_set_uniform_f(global.u_glow_color,
                           color_get_red(_grcol) / 255,
                           color_get_green(_grcol) / 255,
                           color_get_blue(_grcol) / 255);
      shader_set_uniform_f(global.u_glow_intensity,
                           _fag_vis * _grp * (0.10 + _fag_heat * 0.06 + fin_assembly_sync * 0.05));

      var _grd = _k_fin_assembly_ring_r[_fagr] - fin_assembly_pulse * (2.5 + _fagr)
               + sin(t * 0.018 + _fagr * 1.7) * (1.2 + _grp * 1.8);
      var _gsegs = _k_fin_assembly_ring_segs[_fagr];
      var _gstep = 360 / _gsegs;
      var _gduty = 0.35 + _grp * 0.24;
      var _grot = _k_fin_assembly_ring_offset[_fagr]
                + (1 - _grp) * ((_fagr mod 2) ? -26 : 26)
                + fin_section_p * ((_fagr mod 2) ? -8 : 8);
      var _glen = degtorad(_gstep * _gduty) * _grd;
      var _gsx = max(0.05, (_glen * 0.24 * _fsx) / _fbh);
      var _gsy = ((2.8 + _fagr * 0.25 + _fag_heat * 1.1) * _fsx) / _fbh;

      for (var _gsi = 0; _gsi < _gsegs; _gsi++) {
        if (((_gsi + _fagr) mod 5) == 2 && _grp < 0.86) continue;
        var _ga = _grot + _gsi * _gstep + _gstep * _gduty * 0.5;
        draw_sprite_ext(spr_glow_blob, 0,
                        (_k_fin_cx + lengthdir_x(_grd, _ga) - _fvx) * _fsx,
                        (_k_fin_cy + lengthdir_y(_grd, _ga) - _fvy) * _fsy,
                        _gsx, _gsy, _ga + 90, c_white, 1);
      }
    }

    for (var _fagn = 0; _fagn < array_length(fin_assembly_nodes); _fagn++) {
      var _gnd = fin_assembly_nodes[_fagn];
      var _gnp = fin_assembly_ring_progress(_gnd.delay);
      if (_gnp <= 0.02) continue;

      var _gcol = (_gnd.ring mod 2) ? global.avoid_col_cyan : global.avoid_col_warning;
      var _ngr = _gnd.r - fin_assembly_pulse * (2 + _gnd.ring);
      var _nga = _gnd.ang + fin_section_p * ((_gnd.ring mod 2) ? -8 : 8);
      var _ngx = (_k_fin_cx + lengthdir_x(_ngr, _nga) - _fvx) * _fsx;
      var _ngy = (_k_fin_cy + lengthdir_y(_ngr, _nga) - _fvy) * _fsy;
      var _npulse = _gnd.pulse;
      var _ns = ((7 + _gnd.ring * 1.4 + _npulse * 18 + fin_assembly_sync * 4) * _fsx) / _fbh;

      shader_set_uniform_f(global.u_glow_color,
                           color_get_red(_gcol) / 255,
                           color_get_green(_gcol) / 255,
                           color_get_blue(_gcol) / 255);
      shader_set_uniform_f(global.u_glow_intensity,
                           _fag_vis * _gnp * (0.24 + _npulse * 0.64 + fin_assembly_sync * 0.12));
      draw_sprite_ext(spr_glow_blob, 0, _ngx, _ngy, _ns, _ns, 0, c_white, 1);

      if (_npulse > 0.12) {
        var _nh = ((2.5 + _npulse * 7) * _fsx) / _fbh;
        shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, _fag_vis * _gnp * _npulse * 0.65);
        draw_sprite_ext(spr_glow_blob, 0, _ngx, _ngy, _nh, _nh, 0, c_white, 1);
      }
    }

    for (var _fagp = 0; _fagp < array_length(fin_assembly_packets); _fagp++) {
      var _gpk = fin_assembly_packets[_fagp];
      var _gku = 1 - _gpk.life / max(_gpk.max_life, 1);
      var _gke = 1 - power(1 - _gku, 3);
      var _gkr = lerp(_gpk.r0, _gpk.r1, _gke);
      var _gka = _gpk.ang + _fag_pull * angle_difference(fin_cut_axis().ang, _gpk.ang) * 0.16;
      var _gkx = (_k_fin_cx + lengthdir_x(_gkr, _gka) - _fvx) * _fsx;
      var _gky = (_k_fin_cy + lengthdir_y(_gkr, _gka) - _fvy) * _fsy;
      var _gpa = sin(_gku * pi) * _fag_vis;
      var _gps = ((5 + _gpk.hot * 12) * _fsx) / _fbh;

      shader_set_uniform_f(global.u_glow_color, 1, 0.45 + _gpk.hot * 0.36, 0.40 + _gpk.hot * 0.30);
      shader_set_uniform_f(global.u_glow_intensity, _gpa * (0.34 + _gpk.hot * 0.42));
      shader_set_uniform_f(global.u_glow_falloff, 1.55);
      draw_sprite_ext(spr_glow_blob, 0, _gkx, _gky, _gps * (1 + _gpk.width * 0.2), _gps,
                      _gka, c_white, 1);
    }
  }

  if (array_length(fin_motes) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.9);
    for (var _fm = 0; _fm < array_length(fin_motes); _fm++) {
      var _fmo = fin_motes[_fm];
      var _mx = (_k_fin_cx + lengthdir_x(_fmo.dist, _fmo.ang) - _fvx) * _fsx;
      var _my = (_k_fin_cy + lengthdir_y(_fmo.dist, _fmo.ang) - _fvy) * _fsy;
      var _ma = clamp(1 - _fmo.dist / 720, 0, 1);
      var _ms = _fmo.size * (0.5 + _ma * 0.9) * _fsx * 2;

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_fg, 1, _fmo.hot), lerp(_fb, 1, _fmo.hot));
      shader_set_uniform_f(global.u_glow_intensity, _ma * (0.6 + fin_implode * 0.8));
      draw_sprite_ext(spr_glow_blob, 0, _mx, _my, _ms * (1 + _fmo.speed * 0.3), _ms, _fmo.ang + 180, c_white, 1);
    }
  }

  if (array_length(fin_shells) > 0 || array_length(fin_shell_sparks) > 0) {
    var _stamps = 10;

    shader_set_uniform_f(global.u_glow_falloff, 1.5);

    for (var _qs = 0; _qs < array_length(fin_shells); _qs++) {
      var _sh   = fin_shells[_qs];
      var _sol  = fin_shell_solidity(_sh);
      var _shb  = _sh.burn;
      var _lf   = _sh.land_flash;
      var _heat = clamp(_sh.hot * 0.5 + _lf * 0.6 + _sh.ring * 0.3, 0, 1);
      var _amp  = _shb * (0.22 + _sol * 0.62 + _lf * 0.9 + _sh.ring * 0.3);
      if (_amp <= 0.02) continue;

      var _glow_src = _sh;
      if (_sol < 0.5) {
        _glow_src = { sides : _sh.sides, radius : _sh.r_lock,
                      rot : _sh.rot_to, span : _sh.span };
      }

      var _cr = color_get_red(_sh.col)   / 255;
      var _cg = color_get_green(_sh.col) / 255;
      var _cb = color_get_blue(_sh.col)  / 255;

      for (var _qw = 0; _qw < _sh.sides; _qw++) {
        var _w  = fin_shell_wall(_glow_src, _qw);
        var _wa = _w.ang + 90;

        shader_set_uniform_f(global.u_glow_color, lerp(_cr, 1, 0.16), lerp(_cg, 1, 0.18),
                                                  lerp(_cb, 1, 0.18));
        shader_set_uniform_f(global.u_glow_intensity, _amp * (0.42 + _heat * 0.5));

        var _bt = ((_sh.wall_w * (1.6 + _sol * 2.4 + _lf * 3.2)) * _fsx) / _fbh;
        var _bl = (((_w.hl * 2 / _stamps) * 1.5) * _fsx) / _fbh;

        var _qsp = fin_shell_gap_span(_sh, _w);
        for (var _qi = 0; _qi < _stamps; _qi++) {
          var _qf = (_qi + 0.5) / _stamps;
          if (_qf > _qsp[0] && _qf < _qsp[1]) continue;
          draw_sprite_ext(spr_glow_blob, 0,
                          (lerp(_w.x1, _w.x2, _qf) - _fvx) * _fsx,
                          (lerp(_w.y1, _w.y2, _qf) - _fvy) * _fsy,
                          _bl, _bt, _wa, c_white, 1);
        }

        var _vf = ((7 + _heat * 16 + _lf * 22) * _fsx) / _fbh;
        shader_set_uniform_f(global.u_glow_color, 1, lerp(_cg, 1, 0.55), lerp(_cb, 1, 0.5));
        shader_set_uniform_f(global.u_glow_intensity, _amp * (0.75 + _heat * 0.8));
        draw_sprite_ext(spr_glow_blob, 0, (_w.x1 - _fvx) * _fsx, (_w.y1 - _fvy) * _fsy,
                        _vf, _vf, 0, c_white, 1);
        draw_sprite_ext(spr_glow_blob, 0, (_w.x2 - _fvx) * _fsx, (_w.y2 - _fvy) * _fsy,
                        _vf, _vf, 0, c_white, 1);

        var _tg = _amp * _k_fin_shell_tendon_max * (0.3 + fin_charge * 0.8);
        if (_tg > 0.02) {
          shader_set_uniform_f(global.u_glow_color, lerp(_cr, 1, 0.3), lerp(_cg, 1, 0.3),
                                                    lerp(_cb, 1, 0.3));
          shader_set_uniform_f(global.u_glow_intensity, _tg * 0.7);
          var _td = point_direction(_w.cx, _w.cy, _k_fin_cx, _k_fin_cy);
          var _tl = point_distance(_w.cx, _w.cy, _k_fin_cx, _k_fin_cy) / 6;
          var _ts = ((_tl * 1.4) * _fsx) / _fbh;
          var _tt = ((2.5 + _lf * 5) * _fsx) / _fbh;
          for (var _tq = 0; _tq < 6; _tq++) {
            var _tf2 = (_tq + 0.5) / 6;
            draw_sprite_ext(spr_glow_blob, 0,
                            (lerp(_w.cx, _k_fin_cx, _tf2) - _fvx) * _fsx,
                            (lerp(_w.cy, _k_fin_cy, _tf2) - _fvy) * _fsy,
                            _ts, _tt, _td, c_white, 1);
          }
        }
      }
    }

    if (array_length(fin_shell_sparks) > 0) {
      shader_set_uniform_f(global.u_glow_falloff, 1.9);
      for (var _qk = 0; _qk < array_length(fin_shell_sparks); _qk++) {
        var _spk = fin_shell_sparks[_qk];
        var _spa = clamp(_spk.life / _spk.max_life, 0, 1);
        var _sdr = point_direction(0, 0, _spk.vx, _spk.vy);
        var _ssz = _spk.size * (0.6 + _spa * 0.8) * _fsx * 2;

        shader_set_uniform_f(global.u_glow_color,
                             color_get_red(_spk.col) / 255,
                             color_get_green(_spk.col) / 255,
                             color_get_blue(_spk.col) / 255);
        shader_set_uniform_f(global.u_glow_intensity, _spa * (0.5 + _spk.hot * 0.55));
        draw_sprite_ext(spr_glow_blob, 0,
                        (_spk.x - _fvx) * _fsx, (_spk.y - _fvy) * _fsy,
                        _ssz * (1 + point_distance(0, 0, _spk.vx, _spk.vy) * 0.22), _ssz,
                        _sdr, c_white, 1);
      }
    }
  }

  if (array_length(fin_shell_vents) > 0) {
    shader_reset();
    scr_draw_vent_streams(fin_shell_vents, _fvx, _fvy, _fsx);
    shader_set(shd_bullet_glow);
    shader_set_uniform_f(global.u_glow_uvrect, _fuv[0], _fuv[1], _fuv[2], _fuv[3]);
  }

  if (fin_gap_glow > 0.02) {
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    shader_set_uniform_f(global.u_glow_color, 1, _fg * 0.6 + 0.3, _fb * 0.5 + 0.25);
    shader_set_uniform_f(global.u_glow_intensity, fin_gap_glow * 0.55);

    for (var _gi = 0; _gi < array_length(bass_rings); _gi++) {
      var _gr = bass_rings[_gi];
      if (_gr.state != "strike") {
        var _gk = _gr.idx;
        var _gc = _k_fin_gap_count[_gk];
        var _gw = _k_fin_gap_width[_gk];
        var _gs = ((5 + fin_gap_glow * 9) * _fsx) / _fbh;

        for (var _gg = 0; _gg < _gc; _gg++) {
          var _gbase = _gr.gap_now + _gg * (360 / _gc);
          for (var _gn = 0; _gn <= 9; _gn++) {
            var _gang = _gbase + ((_gn / 9) - 0.5) * _gw;
            var _gx = (_gr.center_x + lengthdir_x(_gr.radius, _gang) - _fvx) * _fsx;
            var _gy = (_gr.center_y + lengthdir_y(_gr.radius, _gang) - _fvy) * _fsy;
            draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, _gs, _gs, 0, c_white, 1);
          }
        }
      }
    }
  }

  if (array_length(fin_ghosts) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 2.4);
    for (var _gh = 0; _gh < array_length(fin_ghosts); _gh++) {
      var _ghg = fin_ghosts[_gh];
      var _ghs = ((3 + _ghg.alpha * 5) * _fsx) / _fbh;
      shader_set_uniform_f(global.u_glow_color, 1, _fg * 0.4 + _ghg.hot * 0.4, _fb * 0.4 + _ghg.hot * 0.4);
      shader_set_uniform_f(global.u_glow_intensity, _ghg.alpha * 0.45);

      for (var _gp = 0; _gp < array_length(_ghg.pts); _gp++) {
        var _ghp = _ghg.pts[_gp];
        var _ghx = (_ghp.x - _fvx) * _fsx;
        var _ghy = (_ghp.y - _fvy) * _fsy;
        draw_sprite_ext(spr_glow_blob, 0, _ghx, _ghy, _ghs, _ghs, 0, c_white, 1);
      }
    }
  }

  for (var _sr = 0; _sr < 2; _sr++) {
    var _srcs = (_sr == 0) ? bass_rings : orbit_rings;

    for (var _sq = 0; _sq < array_length(_srcs); _sq++) {
      var _sring = _srcs[_sq];

      for (var _so = 0; _so < array_length(_sring.orbs); _so++) {
        var _sb = _sring.orbs[_so];
        if (!instance_exists(_sb)) continue;

        var _tn = array_length(_sb.spear_trail);
        var _heat = _sb.heat;

        shader_set_uniform_f(global.u_glow_falloff, 1.7);
        shader_set_uniform_f(global.u_glow_color, color_get_red(_sb.image_blend) / 255,
                             color_get_green(_sb.image_blend) / 255,
                             color_get_blue(_sb.image_blend) / 255);

        for (var _ti = 0; _ti < _tn; _ti++) {
          var _tp = _sb.spear_trail[_ti];
          var _tf = _ti / max(_tn - 1, 1);
          var _ts = ((2 + _tp.w * 3.4) * _tf * _fsx) / _fbh;
          var _tx = (_tp.x - _fvx) * _fsx;
          var _ty = (_tp.y - _fvy) * _fsy;
          shader_set_uniform_f(global.u_glow_intensity, _tf * _tf * (0.5 + _heat * 0.75));
          draw_sprite_ext(spr_glow_blob, 0, _tx, _ty, _ts, _ts, 0, c_white, 1);
        }

        if (_fchroma > 0.06 && _tn > 3) {
          var _perp = _sb.image_angle + 90;
          var _offx = lengthdir_x(_fchroma * 4.2 * _fsx, _perp);
          var _offy = lengthdir_y(_fchroma * 4.2 * _fsx, _perp);
          shader_set_uniform_f(global.u_glow_falloff, 2.6);

          for (var _ci = 1; _ci < _tn; _ci += 2) {
            var _cp = _sb.spear_trail[_ci];
            var _cf = _ci / max(_tn - 1, 1);
            var _cx0 = (_cp.x - _fvx) * _fsx;
            var _cy0 = (_cp.y - _fvy) * _fsy;
            var _cs = ((1.5 + _cp.w * 1.9) * _cf * _fsx) / _fbh;

            shader_set_uniform_f(global.u_glow_color, 1, 0.05, 0.05);
            shader_set_uniform_f(global.u_glow_intensity, _cf * _fchroma * 0.7);
            draw_sprite_ext(spr_glow_blob, 0, _cx0 + _offx, _cy0 + _offy, _cs, _cs, 0, c_white, 1);

            shader_set_uniform_f(global.u_glow_color, 0.15, 0.85, 1);
            shader_set_uniform_f(global.u_glow_intensity, _cf * _fchroma * 0.55);
            draw_sprite_ext(spr_glow_blob, 0, _cx0 - _offx, _cy0 - _offy, _cs, _cs, 0, c_white, 1);
          }
        }

        var _hx = (_sb.x - _fvx) * _fsx;
        var _hy = (_sb.y - _fvy) * _fsy;
        var _hstr = 1 + (_sb.image_xscale - 1) * 0.55;
        var _hs = ((7 + _heat * 5 + _sb.flash * 16) * _k_fin_orb_glow_scale * _fsx) / _fbh;

        shader_set_uniform_f(global.u_glow_falloff, 1.6);
        shader_set_uniform_f(global.u_glow_color, 1, _fg * 0.7 + _sb.flash * 0.3, _fb * 0.6 + _sb.flash * 0.3);
        shader_set_uniform_f(global.u_glow_intensity, 0.55 + _heat * 0.6 + _sb.flash * 0.9);
        draw_sprite_ext(spr_glow_blob, 0, _hx, _hy, _hs * _hstr, _hs, _sb.image_angle, c_white, 1);

        var _hc = ((2.6 + _heat * 2.4 + _sb.flash * 7) * _fsx) / _fbh;
        shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, 0.9 + _heat * 0.7 + _sb.flash * 1.2);
        shader_set_uniform_f(global.u_glow_falloff, 2.5);
        draw_sprite_ext(spr_glow_blob, 0, _hx, _hy, _hc * _hstr, _hc, _sb.image_angle, c_white, 1);
      }
    }
  }

  for (var _pf = 0; _pf < array_length(bass_ring_pierce_flashes); _pf++) {
    var _pff = bass_ring_pierce_flashes[_pf];
    var _pp = _pff.life / _pff.max_life;
    var _px2 = (_pff.x - _fvx) * _fsx;
    var _py2 = (_pff.y - _fvy) * _fsy;
    var _pgrow = 1.4 - _pp;
    var _ps = ((16 + _pff.size * 52) * _pgrow * _fsx) / _fbh;
    var _pc = ((5 + _pff.size * 16) * _fsx) / _fbh;

    shader_set_uniform_f(global.u_glow_color, 1, 0.55 + _pff.hot * 0.45, 0.5 + _pff.hot * 0.5);
    shader_set_uniform_f(global.u_glow_intensity, _pp * (0.7 + _pff.hot * 0.9));
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _px2, _py2, _ps, _ps * 0.9, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _pp * _pp * (1 + _pff.hot));
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    draw_sprite_ext(spr_glow_blob, 0, _px2, _py2, _pc, _pc, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

with(oLaserOrb_Pop) {
  var _spawning = (spawn_flash_timer < spawn_flash_duration);
  if (_spawning || is_popped) {
    var gui_x = (x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

    if (_spawning) {
      var _spawn_prog = spawn_flash_timer / spawn_flash_duration;
      var _spawn_intensity = lerp(_k_spawn_flash_peak_intensity, 0, _spawn_prog);
      var _spawn_scale = lerp(0.6, _k_spawn_flash_peak_scale, _spawn_prog) * base_scale;
      shader_set_uniform_f(global.u_glow_color, color_get_red(_k_spawn_flash_color) / 255,
                           color_get_green(_k_spawn_flash_color) / 255, color_get_blue(_k_spawn_flash_color) / 255);
      shader_set_uniform_f(global.u_glow_intensity, _spawn_intensity);
      shader_set_uniform_f(global.u_glow_falloff, 1.5);
      draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _spawn_scale, _spawn_scale, 0, c_white, 1);
    }

    if (is_popped) {
      var _flash_prog = clamp(pop_flash_timer / _k_pop_flash_duration, 0, 1);
      var _intensity = lerp(_k_pop_flash_intensity_mult, _k_glow_intensity_base, _flash_prog);
      var _scale = lerp(_k_pop_flash_peak_scale, 1.2, _flash_prog) * base_scale;

      shader_set_uniform_f(global.u_glow_color, color_get_red(_k_sustained_glow_color) / 255,
                           color_get_green(_k_sustained_glow_color) / 255, color_get_blue(_k_sustained_glow_color) / 255);
      shader_set_uniform_f(global.u_glow_intensity, _intensity * image_alpha);
      shader_set_uniform_f(global.u_glow_falloff, 1.3);
      draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _scale, _scale, 0, c_white, 1);

      if (_flash_prog < 0.66) {
        var _core_prog = _flash_prog / 0.66;
        shader_set_uniform_f(global.u_glow_color, color_get_red(_k_core_flash_color) / 255,
                             color_get_green(_k_core_flash_color) / 255, color_get_blue(_k_core_flash_color) / 255);
        shader_set_uniform_f(global.u_glow_intensity, lerp(_k_core_peak_intensity, 0, _core_prog) * image_alpha);
        shader_set_uniform_f(global.u_glow_falloff, 1.6);
        var _core_scale = lerp(0.6, _k_core_peak_scale, _core_prog) * base_scale;
        draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _core_scale, _core_scale, 0, c_white, 1);
      }
    }
    if (pop_persist && gravity_activated) {
      var _offscreen = (gui_x < 0 || gui_x > oCameraController.base_view_w || gui_y < 0 || gui_y > oCameraController.base_view_h);

      if (_offscreen) {
        has_left_screen = true;
      } else if (has_left_screen) {
        warning_suppressed = true;
      }

      if (_offscreen && !warning_suppressed) {
        var _edge_x = clamp(gui_x, _k_edge_glow_margin, oCameraController.base_view_w - _k_edge_glow_margin);
        var _edge_y = clamp(gui_y, _k_edge_glow_margin, oCameraController.base_view_h - _k_edge_glow_margin);
        edge_glow_phase += _k_edge_glow_pulse_speed;
        var _edge_pulse = (sin(edge_glow_phase) + 1) * 0.5;

        var _dir = 0;
        if (gui_x < 0) {
          _dir = 0;
        } else if (gui_x > oCameraController.base_view_w) {
          _dir = 180;
        } else if (gui_y < 0) {
          _dir = 270;
        } else {
          _dir = 90;
        }

        var _dist_beyond_edge = 0;
        if (_dir == 0) {
          _dist_beyond_edge = -gui_x;
        } else if (_dir == 180) {
          _dist_beyond_edge = gui_x - oCameraController.base_view_w;
        } else if (_dir == 270) {
          _dist_beyond_edge = -gui_y;
        } else {
          _dist_beyond_edge = gui_y - oCameraController.base_view_h;
        }
        var _dist_alpha = lerp(_k_edge_dist_alpha_max, _k_edge_dist_alpha_min, clamp(_dist_beyond_edge / _k_edge_dist_max, 0, 1));
        var _dist_scale = lerp(_k_edge_dist_scale_max, _k_edge_dist_scale_min, clamp(_dist_beyond_edge / _k_edge_dist_max, 0, 1));

        var _edge_intensity = _k_edge_glow_intensity * 0.5 * lerp(0.6, 1, _edge_pulse) * _dist_alpha;
        shader_set_uniform_f(global.u_glow_color, color_get_red(_k_edge_glow_color) / 255,
                             color_get_green(_k_edge_glow_color) / 255, color_get_blue(_k_edge_glow_color) / 255);
        shader_set_uniform_f(global.u_glow_intensity, _edge_intensity);
        shader_set_uniform_f(global.u_glow_falloff, 1.4);
        var _halo_scale = _k_edge_glow_scale * 0.7 * _dist_scale;
        draw_sprite_ext(spr_glow_blob, 0, _edge_x, _edge_y, _halo_scale, _halo_scale, 0, c_white, 1);
        shader_reset();

        var _chevron_scale = lerp(_k_edge_chevron_pulse_min, _k_edge_chevron_pulse_max, _edge_pulse) * _dist_scale;
        var _halo_layers = 4;
        for (var _i = _halo_layers; _i >= 0; _i--) {
          var _layer_mult = 1 + (_i * _k_edge_chevron_halo_growth);
          var _layer_alpha = ((_i == 0) ? 1 : lerp(_k_edge_chevron_halo_alpha, 0, _i / _halo_layers)) * _dist_alpha;
          var _len = _k_edge_chevron_length * _chevron_scale * _layer_mult;
          var _wid = _k_edge_chevron_width * _chevron_scale * _layer_mult;
          var _tip_x = _edge_x + lengthdir_x(_len * 0.5, _dir);
          var _tip_y = _edge_y + lengthdir_y(_len * 0.5, _dir);
          var _base_cx = _edge_x - lengthdir_x(_len * 0.5, _dir);
          var _base_cy = _edge_y - lengthdir_y(_len * 0.5, _dir);
          var _perp = _dir + 90;
          var _base1_x = _base_cx + lengthdir_x(_wid * 0.5, _perp);
          var _base1_y = _base_cy + lengthdir_y(_wid * 0.5, _perp);
          var _base2_x = _base_cx - lengthdir_x(_wid * 0.5, _perp);
          var _base2_y = _base_cy - lengthdir_y(_wid * 0.5, _perp);
          var _col =
              (_i == 0) ? merge_color(_k_edge_chevron_base_color, _k_edge_chevron_tip_color, 0.7) : _k_edge_chevron_base_color;
          draw_set_alpha(_layer_alpha);
          draw_triangle_color(_tip_x, _tip_y, _base1_x, _base1_y, _base2_x, _base2_y, _col, _k_edge_chevron_base_color,
                              _k_edge_chevron_base_color, false);
        }
        draw_set_alpha(1);

        shader_set(shd_bullet_glow);
        var _uvs2 = sprite_get_uvs(spr_glow_blob, 0);
        shader_set_uniform_f(global.u_glow_uvrect, _uvs2[0], _uvs2[1], _uvs2[2], _uvs2[3]);
      }
    }
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

var _glow_base_intensity = 1;
var _glow_radius = 100;
var _glow_falloff = 0.5;
var _glow_point_step = 1;
var _k_imprint_life = 150;
var _k_imprint_alpha = 0.7;
var _k_imprint_line_out = 5;
var _k_imprint_line_mid = 1.8;
var _k_imprint_line_core = 0.7;
if (array_length(lightning_imprints) > 0) {
var _imp_n = array_length(lightning_imprints);
gpu_set_blendmode(bm_add);
gpu_set_blendequation(bm_eq_max);

var _imp_csx = oCameraController.base_view_w / oCameraController.current_cam_w;
var _imp_csy = oCameraController.base_view_h / oCameraController.current_cam_h;
var _imp_ccx = oCameraController.current_cam_x;
var _imp_ccy = oCameraController.current_cam_y;
var _imp_sw = sprite_get_width(spr_glow_blob);
var _imp_sh = sprite_get_height(spr_glow_blob);
var _uv = sprite_get_uvs(spr_glow_blob, 0);

shader_set(shd_bullet_glow);
shader_set_uniform_f(u_glow_uvrect_handle, _uv[0], _uv[1], _uv[2], _uv[3]);
shader_set_uniform_f(u_glow_falloff_handle, _glow_falloff);

for (var i = 0; i < _imp_n; i++) {
  var _imp = lightning_imprints[i];
  var _imp_alpha = (_imp.life / _imp.life_max) * _k_imprint_alpha;
  var _imp_width_mult = clamp(_imp.life / _imp.life_max, 0.3, 1);
  var _pts = _imp.points;
  var _pn = array_length(_pts);

  shader_set_uniform_f(u_glow_color_handle, color_get_red(_imp.col) / 255,
                       color_get_green(_imp.col) / 255, color_get_blue(_imp.col) / 255);
  shader_set_uniform_f(u_glow_intensity_handle, _glow_base_intensity * _imp_alpha * _imp_width_mult);

  var _gscale_x = (_glow_radius * _imp_width_mult) / _imp_sw;
  var _gscale_y = (_glow_radius * _imp_width_mult) / _imp_sh;

  for (var p = 0; p < _pn; p += _glow_point_step) {
    var _pt = _pts[p];
    draw_sprite_ext(spr_glow_blob, 0, (_pt.ix - _imp_ccx) * _imp_csx, (_pt.iy - _imp_ccy) * _imp_csy,
                    _gscale_x, _gscale_y, 0, c_white, 1);
  }
}
shader_reset();

for (var i = 0; i < _imp_n; i++) {
  var _imp = lightning_imprints[i];
  var _imp_alpha = (_imp.life / _imp.life_max) * _k_imprint_alpha;
  var _imp_width_mult = clamp(_imp.life / _imp.life_max, 0.3, 1);
  var _pts = _imp.points;
  var _pn = array_length(_pts);

  var _core_col = merge_color(_imp.col, c_white, 0.5);
  var _prev_gui_x = 0, _prev_gui_y = 0;
  for (var p = 0; p < _pn; p++) {
    var _pt = _pts[p];
    var _gui_x = (_pt.ix - _imp_ccx) * _imp_csx;
    var _gui_y = (_pt.iy - _imp_ccy) * _imp_csy;
    if (p > 0) {
      var _seg_taper = (_pt.w + _pts[p - 1].w) * 0.5;
      draw_set_color(_imp.col);
      draw_set_alpha(_imp_alpha * 0.3);
      draw_line_width(_prev_gui_x, _prev_gui_y, _gui_x, _gui_y,
                      _k_imprint_line_out * _imp_width_mult * _seg_taper);
      draw_set_alpha(_imp_alpha * 0.6);
      draw_line_width(_prev_gui_x, _prev_gui_y, _gui_x, _gui_y,
                      _k_imprint_line_mid * _imp_width_mult * _seg_taper);
      draw_set_color(_core_col);
      draw_set_alpha(_imp_alpha);
      draw_line_width(_prev_gui_x, _prev_gui_y, _gui_x, _gui_y,
                      _k_imprint_line_core * _imp_width_mult * _seg_taper);
    }
    _prev_gui_x = _gui_x;
    _prev_gui_y = _gui_y;
  }
}
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendequation(bm_eq_add);
gpu_set_blendmode(bm_normal);
}

scr_draw_avoidance_energized_killer_glow();

with(oKiller) {
  if (graze_bolt_life > 0 && instance_exists(oPlayer)) {
    scr_draw_lightning_bolt(oPlayer.x, oPlayer.y, graze_bolt_life, graze_bolt_max, 4, false);
  }
}

with(oKiller) {
  if (energized && array_length(crackle_points) > 0) {
    var _line_col = global.avoid_col_cyan;
    draw_set_alpha(0.4);

    for (var i = 0; i < array_length(crackle_points); i++) {
      var _p = crackle_points[i];
      draw_line_width_color(x + _p.sx, y + _p.sy, x + _p.mx, y + _p.my, 2, _line_col, _line_col);
      draw_line_width_color(x + _p.mx, y + _p.my, x + _p.ex, y + _p.ey, 2, _line_col, _line_col);
    }
    draw_set_alpha(1);
  }
}
with(oKiller) {
  if (energized) {
    var _base_radius = sprite_width * 0.55;

    for (var i = 0; i < array_length(orbit_bolts); i++) {
      var _b = orbit_bolts[i];
      var _r = _base_radius * _b.radius_mult;

      var _bx = x + lengthdir_x(_r, _b.angle);
      var _by = y + lengthdir_y(_r, _b.angle) * _b.tilt;

      var _front = (dcos(_b.angle) > 0);
      var _alpha = _front ? 0.5 : 0.15;
      var _width = _front ? 2 : 1.0;

      var _tangent_angle = _b.angle + 90;
      var _seg_len = 10 + random_range(-2, 2);
      var _jag_x = lengthdir_x(_seg_len, _tangent_angle) + random_range(-3, 3);
      var _jag_y = lengthdir_y(_seg_len, _tangent_angle) * _b.tilt + random_range(-3, 3);

      var _col = global.avoid_col_cyan;
      draw_set_alpha(_alpha);
      draw_line_width_color(_bx - _jag_x, _by - _jag_y, _bx + _jag_x, _by + _jag_y, _width, _col, _col);
    }
    draw_set_alpha(1);
  }
}

if (convergence_flash_active) {
  convergence_flash_timer += 1;
  var _cf_t = convergence_flash_timer / convergence_flash_duration;

  if (_cf_t < 1) {
    var _cf_gs = oCameraController.base_view_w / oCameraController.current_cam_w;
    var _cf_gs_y = oCameraController.base_view_h / oCameraController.current_cam_h;
    var _cf_x = (400 - oCameraController.current_cam_x) * _cf_gs;
    var _cf_y = (125 - oCameraController.current_cam_y) * _cf_gs_y;
    var _cf_half = sprite_get_width(spr_glow_blob) * 0.5;

    var _cf_outer = (1 - _cf_t) * 0.9;
    var _cf_core_t = clamp(_cf_t / 0.33, 0, 1);
    var _cf_core = (1 - _cf_core_t);

    var _lr2 = color_get_red(global.lightning_color) / 255;
    var _lg2 = color_get_green(global.lightning_color) / 255;
    var _lb2 = color_get_blue(global.lightning_color) / 255;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);

    var _cf_uv = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _cf_uv[0], _cf_uv[1], _cf_uv[2], _cf_uv[3]);

    shader_set_uniform_f(global.u_glow_color, _lr2, _lg2, _lb2);
    shader_set_uniform_f(global.u_glow_intensity, 2.0 * _cf_outer);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    var _cf_ws = (150 * (1 + _cf_t * 1.8)) * _cf_gs / _cf_half;
    draw_sprite_ext(spr_glow_blob, 0, _cf_x, _cf_y, _cf_ws, _cf_ws, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_lg2, 1, 0.6), lerp(_lb2, 1, 0.6));
    shader_set_uniform_f(global.u_glow_intensity, 1.8 * _cf_outer);
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    var _cf_bar = (40 + _cf_t * 90) * _cf_gs / _cf_half;
    for (var _cfi = 0; _cfi <= 10; _cfi++) {
      var _cfy2 = (_cfi / 10) * (250 + _cf_t * 300);
      draw_sprite_ext(spr_glow_blob, 0, _cf_x, (_cfy2 - oCameraController.current_cam_y) * _cf_gs_y, _cf_bar * 0.35,
                      _cf_bar, 0, c_white, 1);
    }

    if (_cf_core > 0) {
      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, 3.0 * _cf_core);
      shader_set_uniform_f(global.u_glow_falloff, 1.1);
      var _cf_cs = (70 * (1 - _cf_core_t * 0.55)) * _cf_gs / _cf_half;
      draw_sprite_ext(spr_glow_blob, 0, _cf_x, _cf_y, _cf_cs, _cf_cs, 0, c_white, 1);
    }

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  } else {
    convergence_flash_active = false;
  }
}
scr_draw_avoidance_cube_basic_glow();

with (oBassSlashOrb)
{
    var gui_x = (x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _cam_scale_slash = oCameraController.base_view_w / oCameraController.current_cam_w;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);

    draw_set_color(c_red);
    for (var ri = 0; ri < array_length(materialize_rings); ri++)
    {
        var _r = materialize_rings[ri];
        draw_set_alpha(_r.alpha);
        draw_circle(gui_x, gui_y, _r.radius * _cam_scale_slash, true);
    }
    draw_set_alpha(1);

    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

    for (var si = 0; si < array_length(materialize_sparks); si++)
    {
        var _s = materialize_sparks[si];
        var _spark_gui_x = (_s.x - oCameraController.current_cam_x) * _cam_scale_slash;
        var _spark_gui_y = (_s.y - oCameraController.current_cam_y) * _cam_scale_slash;
        shader_set_uniform_f(global.u_glow_color, _k_orb_glow_color[0], _k_orb_glow_color[1], _k_orb_glow_color[2]);
        shader_set_uniform_f(global.u_glow_intensity, _s.alpha);
        shader_set_uniform_f(global.u_glow_falloff, 2.2);
        draw_sprite_ext(spr_glow_blob, 0, _spark_gui_x, _spark_gui_y, 0.3, 0.3, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, _k_orb_glow_color[0], _k_orb_glow_color[1], _k_orb_glow_color[2]);
    shader_set_uniform_f(global.u_glow_intensity, alpha * 1.4);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, 1.6 * scale, 1.6 * scale, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1.0, 1.0, 1.0);
    shader_set_uniform_f(global.u_glow_intensity, alpha * 0.8);
    shader_set_uniform_f(global.u_glow_falloff, 3.0);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, 0.8 * scale, 0.8 * scale, 0, c_white, 1);

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
}

if (instance_exists(oHoneycombController)) {
  var _hcg = oHoneycombController;
  var _hcg_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _hcg_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _hcg_cx = oCameraController.current_cam_x;
  var _hcg_cy = oCameraController.current_cam_y;

  scr_honeycomb_draw_glow(_hcg_cx, _hcg_cy, _hcg_sx, _hcg_sy);


  if (_hcg.hc_phase == "materialize" && _hcg.materialize_p > 0 && _hcg.materialize_p < 1) {
    var _scan_y = (_hcg.center_y + _hcg.materialize_h - _hcg_cy) * _hcg_sy;
    var _scan_x = (_hcg.center_x - _hcg_cx) * _hcg_sx;
    var _scan_rx = _hcg.radius * _hcg_sx;
    var _scan_ry = _hcg.depth_offset * _hcg_sy;
    var _scan_a = 0.85 * (0.4 + 0.6 * sin(_hcg.materialize_p * pi));
    var _scan_cas = (_hcg.radius_base + _hcg._k_duct_casing_gap) * _hcg_sx;

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(make_color_rgb(255, 60, 50), c_white, 0.55));
    for (var _sl = 0; _sl < 3; _sl++) {
      draw_set_alpha(_scan_a * (0.5 - _sl * 0.14));
      draw_ellipse(_scan_x - _scan_rx, _scan_y - _scan_ry - _sl * 5,
                   _scan_x + _scan_rx, _scan_y + _scan_ry + _sl * 5, true);
    }

    draw_set_color(global.avoid_col_armor_edge);
    draw_set_alpha(_scan_a * 0.45);
    draw_line_width(_scan_x - _scan_cas, _scan_y, _scan_x - _scan_rx, _scan_y, 3);
    draw_line_width(_scan_x + _scan_rx, _scan_y, _scan_x + _scan_cas, _scan_y, 3);
    for (var _sb = -1; _sb <= 1; _sb += 2) {
      var _sbx = _scan_x + _sb * _scan_rx;
      draw_set_color(merge_color(global.avoid_col_cyan, c_white, 0.4));
      draw_set_alpha(_scan_a * 0.8);
      draw_line_width(_sbx, _scan_y - 13, _sbx, _scan_y + 13, 2.4);
      draw_line_width(_sbx, _scan_y - 13, _sbx - _sb * 13, _scan_y - 13, 2);
      draw_line_width(_sbx, _scan_y + 13, _sbx - _sb * 13, _scan_y + 13, 2);
    }

    var _sd_n = 20;
    for (var _sd = 0; _sd < _sd_n; _sd++) {
      var _sda = (_sd / _sd_n) * 2 * pi + _hcg.cylinder_rotation * 2.2;
      var _sdz = sin(_sda);
      if (_sdz < 0) continue;
      var _sdx = _scan_x + cos(_sda) * _scan_rx;
      var _sdy = _scan_y + _sdz * _scan_ry;
      draw_set_color(merge_color(global.avoid_col_warning, c_white, _sdz * 0.5));
      draw_set_alpha(_scan_a * (0.25 + _sdz * 0.5));
      draw_line_width(_sdx, _sdy, _sdx, _sdy - 6 - _sdz * 7, 2.4);
    }

    draw_set_color(c_white);
    draw_set_alpha(_scan_a);
    draw_ellipse(_scan_x - _scan_rx, _scan_y - _scan_ry, _scan_x + _scan_rx, _scan_y + _scan_ry, true);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
  }

  if (array_length(_hcg.hc_shock_rings) > 0) {
    var _sh_x = (_hcg.center_x - _hcg_cx) * _hcg_sx;
    var _sh_y = (_hcg.center_y - _hcg_cy) * _hcg_sy;

    gpu_set_blendmode(bm_add);
    for (var _si = 0; _si < array_length(_hcg.hc_shock_rings); _si++) {
      var _sr = _hcg.hc_shock_rings[_si];
      var _sa = power(_sr.life / _sr.life_max, 1.5);
      var _srx = _sr.r * _hcg_sx;
      var _sry = _sr.r * 0.42 * _hcg_sy;
      scr_draw_smooth_ring_mask(_sh_x, _sh_y, _srx, _sa * 0.5, _sr.width, merge_color(make_color_rgb(255, 70, 50), c_white, _sa * 0.6));
      draw_set_color(merge_color(make_color_rgb(255, 120, 70), c_white, 0.4));
      draw_set_alpha(_sa * 0.55);
      draw_ellipse(_sh_x - _srx, _sh_y - _sry, _sh_x + _srx, _sh_y + _sry, true);
      draw_set_alpha(1);
    }
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
  }
}

if (t >= _k_arc_rift_t - 8 && t <= _k_arc_window_end) {
  var _ag_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _ag_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _ag_cx = oCameraController.current_cam_x;
  var _ag_cy = oCameraController.current_cam_y;
  var _ag_blob_half = sprite_get_width(spr_glow_blob) * 0.5;

  var _ag_r = color_get_red(_k_arc_color) / 255;
  var _ag_g = color_get_green(_k_arc_color) / 255;
  var _ag_b = color_get_blue(_k_arc_color) / 255;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _ag_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _ag_uvs[0], _ag_uvs[1], _ag_uvs[2], _ag_uvs[3]);

  if (arc_rift > 0.02 && array_length(arc_rift_pts) > 1) {
    var _agn = array_length(arc_rift_pts);
    var _aglit = arc_rift_open * (_agn - 1);

    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    for (var _rgi2 = 0; _rgi2 < _agn; _rgi2++) {
      if (_rgi2 > _aglit) break;
      var _rpt = arc_rift_pts[_rgi2];
      var _redge = 1 - clamp(_aglit - _rgi2, 0, 1) * 0.5;
      var _rint = arc_rift * (0.5 + _redge * 0.7 + arc_heartbeat * 0.4 + arc_fire_flash * 0.8);

      shader_set_uniform_f(global.u_glow_color, 1, _ag_g * 0.6 + _redge * 0.3, _ag_b * 0.5 + _redge * 0.25);
      shader_set_uniform_f(global.u_glow_intensity, _rint);

      var _rsc = ((14 + arc_charge * 16 + arc_fire_flash * 40) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_rpt.x - _ag_cx) * _ag_sx, (_rpt.y + _rpt.jag - _ag_cy) * _ag_sy,
                      _rsc * 1.5, _rsc * 0.55, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    for (var _rgi3 = 0; _rgi3 < _agn; _rgi3++) {
      if (_rgi3 > _aglit) break;
      var _rpt2 = arc_rift_pts[_rgi3];
      shader_set_uniform_f(global.u_glow_intensity, arc_rift * (0.5 + arc_charge * 0.8 + arc_fire_flash));
      var _rsc2 = ((3.5 + arc_charge * 4 + arc_fire_flash * 12) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_rpt2.x - _ag_cx) * _ag_sx, (_rpt2.y + _rpt2.jag - _ag_cy) * _ag_sy,
                      _rsc2 * 2.2, _rsc2, 0, c_white, 1);
    }
  }

  // --- blade bodies feed the bloom ----------------------------------------------
  if (array_length(arc_blades) > 0) {
    var _ag_lockp = (t >= _k_arc_lock_t)
                  ? clamp((t - _k_arc_lock_t) / max(1, _k_arc_fire_t - _k_arc_lock_t), 0, 1)
                  : 0;

    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    shader_set_uniform_f(global.u_glow_color, 1, _ag_g * 0.5, _ag_b * 0.45);

    for (var _ab = 0; _ab < array_length(arc_blades); _ab++) {
      var _abb = arc_blades[_ab];
      if (!_abb.live) continue;

      var _aheat = (0.4 + arc_charge * 0.7 + arc_heartbeat * 0.5
                        + _abb.forge * 1.2 + _ag_lockp * 1.4) * _abb.fade;

      shader_set_uniform_f(global.u_glow_intensity, _aheat);
      var _asc = ((13 + _aheat * 14) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_abb.x - _ag_cx) * _ag_sx, (_abb.y - _ag_cy) * _ag_sy,
                      _asc, _asc, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    for (var _ab2 = 0; _ab2 < array_length(arc_blades); _ab2++) {
      var _abc = arc_blades[_ab2];
      if (!_abc.live) continue;
      var _acore = (_abc.forge * 1.4 + _ag_lockp * 1.6 + arc_heartbeat * 0.5) * _abc.fade;
      if (_acore < 0.06) continue;

      shader_set_uniform_f(global.u_glow_intensity, _acore * 1.6);
      var _acsc = ((3 + _acore * 7) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_abc.x - _ag_cx) * _ag_sx, (_abc.y - _ag_cy) * _ag_sy,
                      _acsc, _acsc, 0, c_white, 1);
    }
  }

  // --- lances contribute BLOOM ONLY, never geometry ------------------------------
  if (array_length(arc_lances) > 0) {
    var _al_boost = 0;
    for (var _al = 0; _al < array_length(arc_lances); _al++) {
      var _alp = arc_lances[_al].timer / _k_arc_lance_fade;
      _al_boost = max(_al_boost, 1 - _alp);
    }
    lightning_bloom_boost = max(lightning_bloom_boost, _al_boost * 0.42);
  }

  if (instance_exists(oBigRedOrb)) {
    shader_set_uniform_f(global.u_glow_color, 1, _ag_g * 0.4, _ag_b * 0.35);
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    with (oBigRedOrb) {
      var _ocr = 9 * abs(image_xscale);
      var _ospeed = clamp(vel_mag / 10, 0, 1);
      var _oheat = clamp(0.45 + beat_flash * 1.1 + birth_flash * 1.4
                          + other.orb_heartbeat * 0.4, 0, 1.3);
      shader_set_uniform_f(global.u_glow_intensity, _oheat * 0.55);
      var _owsc = ((_ocr * 1.25 + 5 + _oheat * 6) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (x - _ag_cx) * _ag_sx, (y - _ag_cy) * _ag_sy,
                      _owsc * (1 + _ospeed * 1.4), _owsc, _ospeed > 0.08 ? vel_dir : 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 0.35, 0.3);
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    with (oBigRedOrb) {
      var _ocr2 = 9 * abs(image_xscale);
      var _ospeed2 = clamp(vel_mag / 10, 0, 1);
      var _oheat2 = clamp(0.7 + beat_flash * 1.3 + birth_flash * 1.6
                           + other.orb_heartbeat * 0.5, 0, 1.4);
      shader_set_uniform_f(global.u_glow_intensity, _oheat2 * 0.5);
      var _omsc = ((_ocr2 * 0.85 + 2.5 + _oheat2 * 3.5) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (x - _ag_cx) * _ag_sx, (y - _ag_cy) * _ag_sy,
                      _omsc * (1 + _ospeed2 * 1.1), _omsc, _ospeed2 > 0.08 ? vel_dir : 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    with (oBigRedOrb) {
      var _ocore = clamp(beat_flash * 1.4 + birth_flash * 1.4 + lock_pulse * 1.1, 0, 1);
      if (_ocore < 0.14) continue;
      shader_set_uniform_f(global.u_glow_intensity, 0.4 + _ocore * 0.5);
      var _ocsc = ((9 * abs(image_xscale) * 0.26 + 1 + _ocore * 2.4) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (x - _ag_cx) * _ag_sx, (y - _ag_cy) * _ag_sy,
                      _ocsc, _ocsc, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, _ag_g * 0.45, _ag_b * 0.4);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    with (oBigRedOrb) {
      for (var _tp2 = 0; _tp2 < array_length(trail_positions); _tp2++) {
        var _tpt = trail_positions[_tp2];
        var _tpa = _tpt.life * _tpt.life;
        if (_tpa < 0.05) continue;
        var _tstr = variable_struct_exists(_tpt, "stretch") ? _tpt.stretch : 1;
        var _tang = variable_struct_exists(_tpt, "ang") ? _tpt.ang : 0;
        var _tsc2 = variable_struct_exists(_tpt, "sc") ? _tpt.sc : 1;

        shader_set_uniform_f(global.u_glow_intensity, _tpa * 0.55);
        var _tgsc = ((9 * abs(_tsc2) * 0.75 + 2) * _ag_sx) / _ag_blob_half;
        draw_sprite_ext(spr_glow_blob, 0, (_tpt.px - _ag_cx) * _ag_sx, (_tpt.py - _ag_cy) * _ag_sy,
                        _tgsc * _tstr, _tgsc, _tang, c_white, 1);
      }
    }
  }

  if (orb_hub > 0 || orb_hub_grow > 0.02) {
    shader_set_uniform_f(global.u_glow_color, 1, 0.46, 0.36);
    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    shader_set_uniform_f(global.u_glow_intensity,
                         clamp(0.3 + orb_hub_grow * 0.7 + orb_latch * 0.45, 0, 1) * orb_power);
    var _hbsc = ((13 + orb_hub * 5 + orb_hub_grow * 13 + orb_latch * 7) * _ag_sx) / _ag_blob_half;
    draw_sprite_ext(spr_glow_blob, 0, (_k_orb_rail_cx - _ag_cx) * _ag_sx,
                    (_k_orb_rail_cy - _ag_cy) * _ag_sy, _hbsc, _hbsc, 0, c_white, 1);
  }

  if (orb_latch > 0.02) {
    shader_set_uniform_f(global.u_glow_color, 0.42, 0.86, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    for (var _rg3 = 0; _rg3 < array_length(orb_rails); _rg3++) {
      if (!is_struct(orb_rails[_rg3])) continue;
      var _rl3 = orb_rails[_rg3];
      for (var _rs3 = 0; _rs3 < 10; _rs3++) {
        var _rp3 = orb_rail_point(_rl3, (_rs3 / 10) * 360 + _rl3.angle, 1);
        shader_set_uniform_f(global.u_glow_intensity, orb_latch * 0.55);
        var _rsc3 = (13 * _ag_sx) / _ag_blob_half;
        draw_sprite_ext(spr_glow_blob, 0, (_rp3[0] - _ag_cx) * _ag_sx,
                        (_rp3[1] - _ag_cy) * _ag_sy, _rsc3, _rsc3, 0, c_white, 1);
      }
    }
  }

  if (t >= _k_orb_unwrap_start - 8 || array_length(orb_unwrap_tracks) > 0 || orb_unwrap_sink_charge > 0.02) {
    var _uwg_p = clamp((t - _k_orb_unwrap_start) / max(1, _k_arc_window_end - _k_orb_unwrap_start), 0, 1);
    var _uwg_floor = (t >= _k_orb_unwrap_start && t <= _k_arc_window_end)
                     ? (_k_orb_unwrap_machine_floor + dsin(_uwg_p * 180) * _k_orb_unwrap_machine_pulse)
                     : 0;
    var _uwg_i = clamp(0.10 + _uwg_p * 0.16 + orb_unwrap_sink_charge * 0.58 + _uwg_floor * 0.55, 0, 1.05);

    shader_set_uniform_f(global.u_glow_color, 0.42, 0.86, 1);
    shader_set_uniform_f(global.u_glow_falloff, 1.9);
    shader_set_uniform_f(global.u_glow_intensity, _uwg_i * 0.72);
    var _uwg_hsc = ((18 + _uwg_p * 9) * _ag_sx) / _ag_blob_half;
    draw_sprite_ext(spr_glow_blob, 0, (_k_orb_rail_cx - _ag_cx) * _ag_sx,
                    (_k_orb_rail_cy - _ag_cy) * _ag_sy, _uwg_hsc, _uwg_hsc, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_intensity, _uwg_i);
    var _uwg_ssc = ((22 + _uwg_p * 24 + orb_unwrap_recoil * 16) * _ag_sx) / _ag_blob_half;
    draw_sprite_ext(spr_glow_blob, 0, (_k_mill_cx - _ag_cx) * _ag_sx,
                    (_k_mill_cy - _ag_cy) * _ag_sy, _uwg_ssc, _uwg_ssc * 0.82, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    for (var _utg = 0; _utg < array_length(orb_unwrap_tracks); _utg++) {
      var _uwt = orb_unwrap_tracks[_utg];
      var _uwta = power(_uwt.life / max(_uwt.life_max, 1), 1.5);
      if (_uwta < 0.04) continue;
      shader_set_uniform_f(global.u_glow_intensity, _uwta * (0.36 + _uwt.hot * 0.38));
      var _uwtsc = ((8 + _uwt.hot * 5) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_uwt.x1 - _ag_cx) * _ag_sx,
                      (_uwt.y1 - _ag_cy) * _ag_sy, _uwtsc, _uwtsc, 0, c_white, 1);
      shader_set_uniform_f(global.u_glow_intensity, _uwta * (0.24 + _uwt.sink * 0.32));
      draw_sprite_ext(spr_glow_blob, 0, (_uwt.x2 - _ag_cx) * _ag_sx,
                      (_uwt.y2 - _ag_cy) * _ag_sy, _uwtsc * 1.2, _uwtsc * 0.72, _uwt.dir, c_white, 1);
    }
  }

  if (array_length(orb_ghosts) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    for (var _ghi = 0; _ghi < array_length(orb_ghosts); _ghi++) {
      var _gh = orb_ghosts[_ghi];
      shader_set_uniform_f(global.u_glow_color, 1, lerp(_ag_g, 1, _gh.hot * 0.4), lerp(_ag_b, 1, _gh.hot * 0.4));
      shader_set_uniform_f(global.u_glow_intensity, _gh.alpha * 1.1);
      var _ghsc = ((9 + _gh.scale * 4) * _ag_sx) / _ag_blob_half;
      draw_sprite_ext(spr_glow_blob, 0, (_gh.x - _ag_cx) * _ag_sx, (_gh.y - _ag_cy) * _ag_sy,
                      _ghsc * (1 + (1 - _gh.alpha) * 2.5), _ghsc * _gh.alpha, _gh.ang, c_white, 1);
    }
  }

  if (arc_fire_flash > 0.02) {
    shader_set_uniform_f(global.u_glow_color, 1, 0.55, 0.45);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    shader_set_uniform_f(global.u_glow_intensity, arc_fire_flash * 2.2);
    var _ffsc = ((160 + arc_fire_flash * 260) * _ag_sx) / _ag_blob_half;
    draw_sprite_ext(spr_glow_blob, 0, (room_width / 2 - _ag_cx) * _ag_sx,
                    (_k_arc_bottom_y - _ag_cy) * _ag_sy, _ffsc * 1.8, _ffsc * 0.7, 0, c_white, 1);
  }

  if (orb_final_burst > 0.02) {
    shader_set_uniform_f(global.u_glow_color, 1, 0.55, 0.45);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    shader_set_uniform_f(global.u_glow_intensity, orb_final_burst * 2.4);
    var _fbsc = ((180 + orb_final_burst * 320) * _ag_sx) / _ag_blob_half;
    draw_sprite_ext(spr_glow_blob, 0, (room_width / 2 - _ag_cx) * _ag_sx, (200 - _ag_cy) * _ag_sy,
                    _fbsc * 1.4, _fbsc, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (t >= tree_telegraph_start_t && t < tree_telegraph_end_t) {
  scr_draw_avoidance_tree_root_telegraph();
}
scr_draw_tree_root_rakes_glow();

if (t >= tree_ignite_start_t && t <= tree_payoff_t + 20) {
  scr_draw_avoidance_tree_ignition_spark();
}

if (tree_payoff_triggered && tree_payoff_flash_timer < 20) {
  scr_draw_avoidance_tree_payoff_flash();
}

if (array_length(global.tree_embers) > 0) {
  scr_draw_avoidance_tree_embers();
}

if (instance_exists(oTree)) {
  scr_draw_avoidance_tree_node_glow();
}

scr_draw_avoidance_fruit_idle_glow();

if (t >= 1900 && t < 2025) {
  scr_draw_avoidance_fruit_charge_arcs();
}

if (storm_sphere_visibility > 0.001) {
  scr_draw_avoidance_storm_charge_orb();
}

if (array_length(fruit_bursts) > 0) {
  scr_draw_avoidance_fruit_burst_flash();
}

if (instance_exists(oDNATest)) {
  scr_draw_avoidance_dna_test_glow();
}

scr_draw_avoidance_big_red_orb_glow();

if (instance_exists(oRedOrbSquares)) {
  scr_draw_avoidance_red_orb_squares_glow();
}

scr_draw_avoidance_red_orb_square_trail_glow();
scr_draw_avoidance_half_circle_burst_glow();
scr_draw_avoidance_kunai_warning_glow();
scr_draw_avoidance_red_kunai_glow();
scr_draw_avoidance_ring_orb_basic_glow();
scr_draw_avoidance_red_orb2_glow();

if (bass_text_crack_flash > 0.002) {
  gpu_set_blendmode(bm_add);
  draw_set_color(merge_color(c_white, c_red, 0.25));
  draw_set_alpha(bass_text_crack_flash * 0.5);
  draw_rectangle(0, 0, surface_get_width(application_surface), surface_get_height(application_surface), false);
  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(bass_text_cracks) > 0) {
  gpu_set_blendmode(bm_add);

  var _crack_scale = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _crack_cx = (room_width / 2 - oCameraController.current_cam_x) * _crack_scale;
  var _crack_cy = (room_height / 2 - oCameraController.current_cam_y) * _crack_scale;

  for (var crack_i = 0; crack_i < array_length(bass_text_cracks); crack_i++) {
    var _c = bass_text_cracks[crack_i];

    var _main_len = _c.growth * _crack_scale;
    var _kn = array_length(_c.kinks);
    var _perp = _c.angle + 90;

    var _px = _crack_cx;
    var _py = _crack_cy;
    var _wide = max(2, _c.width * _crack_scale);

    for (var _seg = 1; _seg <= _kn + 1; _seg++) {
      var _f = _seg / (_kn + 1);
      var _sxp = _crack_cx + lengthdir_x(_main_len * _f, _c.angle);
      var _syp = _crack_cy + lengthdir_y(_main_len * _f, _c.angle);

      if (_seg <= _kn) {
        var _ko = _c.kinks[_seg - 1] * _crack_scale * (_c.growth / _c.length);
        _sxp += lengthdir_x(_ko, _perp);
        _syp += lengthdir_y(_ko, _perp);
      }

      var _taper = 1 - _f * 0.7;

      draw_set_color(c_red);
      draw_set_alpha(_c.alpha);
      draw_line_width(_px, _py, _sxp, _syp, _wide * _taper);

      draw_set_color(c_white);
      draw_set_alpha(_c.alpha);
      draw_line_width(_px, _py, _sxp, _syp, max(1, _crack_scale) * _taper);

      _px = _sxp;
      _py = _syp;
    }

    for (var branch_i = 0; branch_i < array_length(_c.branches); branch_i++) {
      var _b = _c.branches[branch_i];

      if (_c.growth <= 20) continue;

      var _branch_start = min(_c.growth - 20, _c.length * 0.7);

      var _bx1 = _crack_cx + lengthdir_x(_branch_start * _crack_scale, _c.angle);
      var _by1 = _crack_cy + lengthdir_y(_branch_start * _crack_scale, _c.angle);

      var _branch_angle = _c.angle + _b.offset;

      var _branch_len = min(_b.growth, _b.length) * _crack_scale;

      var _bx2 = _bx1 + lengthdir_x(_branch_len, _branch_angle);
      var _by2 = _by1 + lengthdir_y(_branch_len, _branch_angle);

      draw_set_color(c_red);
      draw_set_alpha(_c.alpha * 0.6);

      draw_line_width(_bx1, _by1, _bx2, _by2, _b.width);

      draw_set_color(c_white);
      draw_set_alpha(_c.alpha);

      draw_line_width(_bx1, _by1, _bx2, _by2, 1);
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

if (array_length(bass_text_crack_embers) > 0) {
  var _ce_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

  gpu_set_blendmode(bm_add);
  shader_set(shd_bullet_glow);
  var _ce_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _ce_uvs[0], _ce_uvs[1], _ce_uvs[2], _ce_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var ce_draw_i = 0; ce_draw_i < array_length(bass_text_crack_embers); ce_draw_i++) {
    var _ce = bass_text_crack_embers[ce_draw_i];
    var _ce_gui_x = (_ce.x - oCameraController.current_cam_x) * _ce_scale;
    var _ce_gui_y = (_ce.y - oCameraController.current_cam_y) * _ce_scale;

    shader_set_uniform_f(global.u_glow_color, 1, 0.2, 0.15);
    shader_set_uniform_f(global.u_glow_intensity, _ce.alpha * 1.3);
    draw_sprite_ext(spr_glow_blob, 0, _ce_gui_x, _ce_gui_y, 0.2 * _ce_scale, 0.2 * _ce_scale, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendmode(bm_normal);
}

if (array_length(bass_text_splatter) > 0) {
  var _splat_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

  var _splat_ang = point_direction(0, 0, room_width, -room_height);

  gpu_set_blendmode(bm_add);
  for (var splat_draw_i = 0; splat_draw_i < array_length(bass_text_splatter); splat_draw_i++) {
    var _sp = bass_text_splatter[splat_draw_i];

    var _sp_gui_x = (_sp.x - oCameraController.current_cam_x) * _splat_scale;
    var _sp_gui_y = (_sp.y - oCameraController.current_cam_y) * _splat_scale;

    var _sp_len = _sp.size * 2.2 * _splat_scale;
    var _sp_x1 = _sp_gui_x - lengthdir_x(_sp_len, _splat_ang);
    var _sp_y1 = _sp_gui_y - lengthdir_y(_sp_len, _splat_ang);
    var _sp_x2 = _sp_gui_x + lengthdir_x(_sp_len, _splat_ang);
    var _sp_y2 = _sp_gui_y + lengthdir_y(_sp_len, _splat_ang);

    draw_set_color(make_color_rgb(110, 0, 0));
    draw_set_alpha(_sp.alpha * 0.6);
    draw_line_width(_sp_x1, _sp_y1, _sp_x2, _sp_y2, _sp.size * 1.8 * _splat_scale);

    draw_set_color(make_color_rgb(200, 10, 10));
    draw_set_alpha(_sp.alpha);
    draw_line_width(_sp_x1, _sp_y1, _sp_x2, _sp_y2, _sp.size * _splat_scale);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);

  shader_set(shd_bullet_glow);
  var _splat_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _splat_uvs[0], _splat_uvs[1], _splat_uvs[2], _splat_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.9);

  for (var splat_glow_i = 0; splat_glow_i < array_length(bass_text_splatter); splat_glow_i++) {
    var _spg = bass_text_splatter[splat_glow_i];
    shader_set_uniform_f(global.u_glow_color, 1, 0.14, 0.11);
    shader_set_uniform_f(global.u_glow_intensity, _spg.alpha * 0.85);
    var _spg_s = _spg.size * 0.05 * _splat_scale;
    draw_sprite_ext(spr_glow_blob, 0,
                    (_spg.x - oCameraController.current_cam_x) * _splat_scale,
                    (_spg.y - oCameraController.current_cam_y) * _splat_scale,
                    _spg_s * 2.4, _spg_s, _splat_ang, c_white, 1);
  }
  shader_reset();

  gpu_set_blendmode(bm_normal);
}

if (array_length(bass_text_tears) > 0) {
  var _tear_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

  gpu_set_blendmode(bm_add);
  draw_set_color(make_color_rgb(160, 5, 5));
  for (var tear_draw_i = 0; tear_draw_i < array_length(bass_text_tears); tear_draw_i++) {
    var _tr = bass_text_tears[tear_draw_i];

    var _tr_gui_x = (_tr.x - oCameraController.current_cam_x) * _tear_scale;
    var _tr_gui_y1 = (_tr.start_y - oCameraController.current_cam_y) * _tear_scale;
    var _tr_gui_y2 = (_tr.y - oCameraController.current_cam_y) * _tear_scale;

    draw_set_alpha(_tr.alpha * 0.35);
    draw_line_width(_tr_gui_x, _tr_gui_y1, _tr_gui_x, _tr_gui_y2, 3 * _tear_scale);
    draw_set_alpha(_tr.alpha * 0.7);
    draw_line_width(_tr_gui_x, lerp(_tr_gui_y1, _tr_gui_y2, 0.4), _tr_gui_x, _tr_gui_y2, 1.6 * _tear_scale);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);

  shader_set(shd_bullet_glow);
  var _tear_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _tear_uvs[0], _tear_uvs[1], _tear_uvs[2], _tear_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var tear_glow_i = 0; tear_glow_i < array_length(bass_text_tears); tear_glow_i++) {
    var _trg = bass_text_tears[tear_glow_i];
    shader_set_uniform_f(global.u_glow_color, 1, 0.1, 0.08);
    shader_set_uniform_f(global.u_glow_intensity, _trg.alpha * 1.1);
    draw_sprite_ext(spr_glow_blob, 0,
                    (_trg.x - oCameraController.current_cam_x) * _tear_scale,
                    (_trg.y - oCameraController.current_cam_y) * _tear_scale,
                    0.1 * _tear_scale, 0.16 * _tear_scale, 0, c_white, 1);
  }
  shader_reset();

  gpu_set_blendmode(bm_normal);
}

if (array_length(slash_seam_embers) > 0) {
  var _seam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;

  gpu_set_blendmode(bm_add);
  shader_set(shd_bullet_glow);
  var _seam_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _seam_uvs[0], _seam_uvs[1], _seam_uvs[2], _seam_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  for (var se_draw_i = 0; se_draw_i < array_length(slash_seam_embers); se_draw_i++) {
    var _se = slash_seam_embers[se_draw_i];
    var _se_gui_x = (_se.x - oCameraController.current_cam_x) * _seam_scale;
    var _se_gui_y = (_se.y - oCameraController.current_cam_y) * _seam_scale;

    shader_set_uniform_f(global.u_glow_color, 1, 0.28, 0.22);
    shader_set_uniform_f(global.u_glow_intensity, _se.alpha * 1.3);
    draw_sprite_ext(spr_glow_blob, 0, _se_gui_x, _se_gui_y, 0.24 * _seam_scale, 0.24 * _seam_scale, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendmode(bm_normal);
}

if (bassline_text_created && (array_length(bassline_text_points) > 0 || array_length(bass_text_scar) > 0)) {
  var _k_text_glow_scale_white = 0.5;
  var _k_text_glow_scale_lit = 1.0;
  var _k_text_glow_intensity_white = 0.3;
  var _k_text_glow_intensity_lit = 1.0;
  var _k_text_glow_falloff = 2.6;
  var _k_smear_stretch_mult = bassline_text_exploding ? 0.22 : 0.08;
  var _k_smear_stretch_max = bassline_text_exploding ? 11 : 4.5;

  var _txs = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _tys = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _tcx = oCameraController.current_cam_x;
  var _tcy = oCameraController.current_cam_y;
  var _blob_half_t = sprite_get_width(spr_glow_blob) * 0.5;

  var _word_gx = (bass_text_word_cx - _tcx) * _txs;
  var _word_gy = (bass_text_word_cy - _tcy) * _tys;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);

  for (var ring_i = 0; ring_i < array_length(bass_text_rings); ring_i++) {
    var r = bass_text_rings[ring_i];
    var _rhot = variable_struct_exists(r, "hot") ? r.hot : 0.4;
    var _rw = variable_struct_exists(r, "width") ? r.width : 1;

    draw_set_color(merge_color(c_red, c_white, _rhot * 0.55));
    draw_set_alpha(r.alpha * 0.75);
    draw_circle(_word_gx, _word_gy, r.radius * _txs, true);

    if (_rw > 1.4) {
      draw_set_alpha(r.alpha * 0.3);
      draw_circle(_word_gx, _word_gy, (r.radius - _rw) * _txs, true);
    }
  }
  draw_set_alpha(1);

  shader_set(shd_bullet_glow);
  var _mote_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _mote_uvs[0], _mote_uvs[1], _mote_uvs[2], _mote_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  for (var part_i = 0; part_i < array_length(bass_text_particles); part_i++) {
    var p = bass_text_particles[part_i];
    if (p.alpha <= 0.01) continue;

    var _mgx = (p.x - _tcx) * _txs;
    var _mgy = (p.y - _tcy) * _tys;

    var _mspd = point_distance(p.prev_x, p.prev_y, p.x, p.y);
    var _mdir = (_mspd > 0.01) ? point_direction(p.prev_x, p.prev_y, p.x, p.y) : 0;
    var _mstretch = 1 + clamp(_mspd * 0.5, 0, 5);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.22, 1, p.hot), lerp(0.18, 1, p.hot));
    shader_set_uniform_f(global.u_glow_intensity, p.alpha * 1.1);

    var _msc = p.size * 0.16 * _txs;
    draw_sprite_ext(spr_glow_blob, 0, _mgx, _mgy, _msc * _mstretch, _msc, _mdir, c_white, 1);
  }
  shader_reset();

  for (var seam_i = 0; seam_i < array_length(bass_text_seams); seam_i++) {
    var _sm = bass_text_seams[seam_i];
    if (_sm.grow <= 0) continue;

    var _sm_gx = (_sm.x - _tcx) * _txs;
    var _sm_gy = (_sm.y - _tcy) * _tys;
    var _sm_len = _sm.span * _sm.grow * _txs;
    var _sm_perp = _sm.ang + 90;
    var _sm_kn = array_length(_sm.kinks);

    for (var _dirn = -1; _dirn <= 1; _dirn += 2) {
      var _spx = _sm_gx;
      var _spy = _sm_gy;

      for (var _sg = 1; _sg <= _sm_kn + 1; _sg++) {
        var _sf = _sg / (_sm_kn + 1);
        var _snx = _sm_gx + lengthdir_x(_sm_len * _sf * _dirn, _sm.ang);
        var _sny = _sm_gy + lengthdir_y(_sm_len * _sf * _dirn, _sm.ang);

        if (_sg <= _sm_kn) {
          var _sko = _sm.kinks[_sg - 1] * _txs * _sm.grow;
          _snx += lengthdir_x(_sko, _sm_perp);
          _sny += lengthdir_y(_sko, _sm_perp);
        }

        var _staper = 1 - _sf * 0.65;

        draw_set_color(make_color_rgb(190, 10, 10));
        draw_set_alpha(0.5 * _sm.grow * _staper);
        draw_line_width(_spx, _spy, _snx, _sny, max(1, 3.5 * _txs) * _staper);

        draw_set_color(c_white);
        draw_set_alpha(0.85 * _sm.grow * _staper);
        draw_line_width(_spx, _spy, _snx, _sny, max(1, 1 * _txs) * _staper);

        _spx = _snx;
        _spy = _sny;
      }
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);

  if (bassline_text_exploding) {
    gpu_set_blendmode(bm_add);
    draw_set_color(make_color_rgb(150, 0, 0));
    for (var drag_i = 0; drag_i < array_length(bassline_text_points); drag_i++) {
      var _dp = bassline_text_points[drag_i];
      if (_dp.alpha <= 0 || !_dp.explode_triggered) continue;

      var _drag_gui_x1 = (_dp.prev_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
      var _drag_gui_y1 = (_dp.prev_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
      var _drag_gui_x2 = (_dp.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
      var _drag_gui_y2 = (_dp.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

      draw_set_alpha(_dp.alpha * 0.55);
      draw_line_width(_drag_gui_x1, _drag_gui_y1, _drag_gui_x2, _drag_gui_y2, lerp(2, 9, _dp.draw_scale));
    }
    draw_set_alpha(1);
  }

  shader_set(shd_bullet_glow);
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

  var _tfringe = _k_bass_text_chroma_max * max(bass_text_heat * bass_text_heat, bass_text_freeze) * fx_get_mult_for("basslinetext", "aberration");
  if (bassline_text_exploding) _tfringe = _k_bass_text_chroma_max * 0.7 * fx_get_mult_for("basslinetext", "aberration");

  for (var text_i = 0; text_i < array_length(bassline_text_points); text_i++) {
    var _p = bassline_text_points[text_i];
    if (_p.alpha <= 0) continue;

    var _psh = bass_text_shards[_p.shard];
    var _draw_x = _p.x + (bassline_text_exploding ? 0 : _psh.cx_off);
    var _draw_y = _p.y + (bassline_text_exploding ? 0 : _psh.cy_off);

    var _suck = _p.suck_amount;
    _draw_x = lerp(_draw_x, room_width / 2, _suck * 0.15);
    _draw_y = lerp(_draw_y, room_height / 2, _suck * 0.15);

    var gui_x = (_draw_x - _tcx) * _txs;
    var gui_y = (_draw_y - _tcy) * _tys;

    var _point_color = bassline_text_exploding ? merge_color(c_red, make_color_rgb(110, 0, 0), 0.5)
                                                : merge_color(c_white, c_red, _p.color_progress);
    if (bass_text_freeze > 0.01) _point_color = merge_color(_point_color, c_white, bass_text_freeze);

    var _glow_scale = lerp(_k_text_glow_scale_white, _k_text_glow_scale_lit, _p.color_progress);
    var _glow_intensity = lerp(_k_text_glow_intensity_white, _k_text_glow_intensity_lit, _p.color_progress);

    var _speed = point_distance(0, 0, _p.vx, _p.vy);
    var _stretch_len = 1 + min(_speed * _k_smear_stretch_mult, _k_smear_stretch_max);
    var _stretch_dir = (_speed > 0.01) ? point_direction(0, 0, _p.vx, _p.vy) : _p.rotation;

    var _sw = _glow_scale * _p.draw_scale * _stretch_len;
    var _sh_ = _glow_scale * _p.draw_scale;

    if (_tfringe > 0.05) {
      var _fdir = _stretch_dir + 90;
      var _fx = lengthdir_x(_tfringe * _txs, _fdir);
      var _fy = lengthdir_y(_tfringe * _txs, _fdir);
      var _fa = _p.alpha * 0.55;

      shader_set_uniform_f(global.u_glow_falloff, 2.8);
      shader_set_uniform_f(global.u_glow_color, 1, 0.05, 0.1);
      shader_set_uniform_f(global.u_glow_intensity, _fa);
      draw_sprite_ext(spr_glow_blob, 0, gui_x + _fx, gui_y + _fy, _sw, _sh_, _stretch_dir, c_white, 1);

      shader_set_uniform_f(global.u_glow_color, 0.25, 0.85, 1);
      shader_set_uniform_f(global.u_glow_intensity, _fa);
      draw_sprite_ext(spr_glow_blob, 0, gui_x - _fx, gui_y - _fy, _sw, _sh_, _stretch_dir, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, color_get_red(_point_color) / 255, color_get_green(_point_color) / 255,
                         color_get_blue(_point_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _p.alpha);
    shader_set_uniform_f(global.u_glow_falloff, 3.5);

    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _sw, _sh_, _stretch_dir, c_white, 1);

    shader_set_uniform_f(global.u_glow_intensity, _glow_intensity * _p.glow_intensity * _p.alpha);
    shader_set_uniform_f(global.u_glow_falloff, _k_text_glow_falloff);

    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _sw, _sh_, _stretch_dir, c_white, 1);
  }

  var _core_charge = bass_text_core_charge + bass_text_freeze * 1.6;
  if (_core_charge > 0.02) {
    var _cc_col = clamp(_core_charge, 0, 1);

    var _cwash = (30 + _core_charge * 105) * _txs;
    shader_set_uniform_f(global.u_glow_color, 1, 0.2 + _cc_col * 0.35, 0.16 + _cc_col * 0.34);
    shader_set_uniform_f(global.u_glow_intensity, 0.35 + _core_charge * 0.6);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, _word_gx, _word_gy, _cwash / _blob_half_t, _cwash / _blob_half_t * 0.62, 0,
                    c_white, 1);

    var _cmid = (13 + _core_charge * 38) * _txs;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 0.9, _cc_col), lerp(0.25, 0.85, _cc_col));
    shader_set_uniform_f(global.u_glow_intensity, 0.8 + _core_charge * 0.8);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _word_gx, _word_gy, _cmid / _blob_half_t, _cmid / _blob_half_t, 0, c_white, 1);

    var _chot = (4 + _core_charge * 15) * _txs;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 0.7 + _core_charge * 1.1);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    draw_sprite_ext(spr_glow_blob, 0, _word_gx, _word_gy, _chot / _blob_half_t, _chot / _blob_half_t, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 2.4);
  for (var scar_i = 0; scar_i < array_length(bass_text_scar); scar_i++) {
    var _sc = bass_text_scar[scar_i];
    var _sca = _sc.alpha;

    shader_set_uniform_f(global.u_glow_color, 1, _sca * _sca * 0.55, _sca * _sca * 0.45);
    shader_set_uniform_f(global.u_glow_intensity, _sca * _sca * 0.45);
    draw_sprite_ext(spr_glow_blob, 0, (_sc.x - _tcx) * _txs, (_sc.y - _tcy) * _tys,
                    0.34 * _txs, 0.34 * _txs, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}
if (ring_ambient > 0.012) {
  var _pb_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _pb_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _pb_cx = oCameraController.current_cam_x;
  var _pb_cy = oCameraController.current_cam_y;

  var _pb_amb = clamp(ring_ambient, 0, 1.3);

  var _pb_flare = 0;

  if (ring_band_ignited) {
    var _k_pb_flare_frames = 10;
    var _pb_since = t - ring_band_ignite_t;

    if (_pb_since >= 0 && _pb_since < _k_pb_flare_frames) {
      var _pb_fp = 1 - (_pb_since / _k_pb_flare_frames);
      _pb_flare = _pb_fp * _pb_fp;
    }
  }

  var _pb_pulse = 0.28 + ring_heartbeat * 0.55 + intro_heartbeat_pulse * 0.5;
  var _pb_alpha = min(1, (_pb_pulse * (0.5 + _pb_amb * 0.9) + _pb_flare * 0.45) *
                        fx_get_mult_for("arrowring", "band"));
  var _pb_depth = 96 + _pb_amb * 54 + ring_heartbeat * 34 + ring_coil_amount * 30;

  var _pb_lip = 26 + _pb_amb * 12;
  var _pb_col = merge_color(c_red, c_white, min(0.5, _pb_flare * 0.6 + ring_coil_amount * 0.3));

  var _pb_ox = arrow_ring_x;
  var _pb_oy = arrow_ring_y;

  var _pb_xmin = 0;
  var _pb_xmax = room_width;
  var _pb_ymin = 0;
  var _pb_ymax = room_height;

  var _pb_e = ring_safe_slide * ring_safe_slide * (3 - 2 * ring_safe_slide);
  var _pb_hole_ang = ring_safe_ang_prev + angle_difference(ring_safe_ang, ring_safe_ang_prev) * _pb_e;
  var _pb_hole_hw = ring_safe_arc * 0.5;
  var _pb_has_hole = (ring_band_ignited && ring_ambient > 0.02 && ring_safe_arc > 1);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_add);

  var _k_pb_step = 8;

  var _pb_edges = [
    [_pb_xmin, _pb_ymin, _pb_xmax, _pb_ymin],
    [_pb_xmax, _pb_ymin, _pb_xmax, _pb_ymax],
    [_pb_xmax, _pb_ymax, _pb_xmin, _pb_ymax],
    [_pb_xmin, _pb_ymax, _pb_xmin, _pb_ymin]
  ];

  var _pb_dmax = min(_pb_xmax - _pb_xmin, _pb_ymax - _pb_ymin) * 0.5 - 1;

  for (var _pp = 0; _pp < 2; _pp++) {
    var _pb_d0 = (_pp == 0) ? 0 : _pb_lip;
    var _pb_d1 = (_pp == 0) ? _pb_lip : _pb_depth;
    var _pb_a0 = (_pp == 0) ? _pb_alpha : _pb_alpha * 0.5;
    var _pb_a1 = (_pp == 0) ? _pb_alpha * 0.5 : 0;
    var _pb_open = false;

    for (var _pe = 0; _pe < 4; _pe++) {
      var _ed = _pb_edges[_pe];
      var _ehoriz = (_pe == 0 || _pe == 2);
      var _elen = _ehoriz ? (_pb_xmax - _pb_xmin) : (_pb_ymax - _pb_ymin);
      var _esteps = max(2, ceil(_elen / _k_pb_step));

      for (var _es = 0; _es <= _esteps; _es++) {
        var _et = _es / _esteps;
        var _px = lerp(_ed[0], _ed[2], _et);
        var _py = lerp(_ed[1], _ed[3], _et);
        var _pa = point_direction(_pb_ox, _pb_oy, _px, _py);

        if (_pb_has_hole && abs(angle_difference(_pa, _pb_hole_ang)) < _pb_hole_hw) {
          if (_pb_open) {
            draw_primitive_end();
            _pb_open = false;
          }
          continue;
        }

        var _pbre = 0.78 + 0.22 * dsin(_pa * 3 + t * 1.6);
        var _pd0 = min(_pb_d0 * _pbre, _pb_dmax);
        var _pd1 = min(_pb_d1 * _pbre, _pb_dmax);

        var _ix0, _iy0, _ix1, _iy1;

        if (_ehoriz) {
          var _iey = (_pe == 0) ? 1 : -1;
          _ix0 = clamp(_px, _pb_xmin + _pd0, _pb_xmax - _pd0);
          _iy0 = _py + _iey * _pd0;
          _ix1 = clamp(_px, _pb_xmin + _pd1, _pb_xmax - _pd1);
          _iy1 = _py + _iey * _pd1;
        } else {
          var _iex = (_pe == 3) ? 1 : -1;
          _ix0 = _px + _iex * _pd0;
          _iy0 = clamp(_py, _pb_ymin + _pd0, _pb_ymax - _pd0);
          _ix1 = _px + _iex * _pd1;
          _iy1 = clamp(_py, _pb_ymin + _pd1, _pb_ymax - _pd1);
        }

        if (!_pb_open) {
          draw_primitive_begin(pr_trianglestrip);
          _pb_open = true;
        }

        draw_vertex_colour((_ix0 - _pb_cx) * _pb_gx, (_iy0 - _pb_cy) * _pb_gy, _pb_col, _pb_a0);
        draw_vertex_colour((_ix1 - _pb_cx) * _pb_gx, (_iy1 - _pb_cy) * _pb_gy, _pb_col, _pb_a1);
      }
    }

    if (_pb_open) draw_primitive_end();
  }

  if (_pb_has_hole) {
    draw_set_color(merge_color(c_red, c_white, 0.6));
    draw_set_alpha(min(1, _pb_alpha * (1.1 + ring_sector_flash * 1.3)));

    for (var _pl = 0; _pl < 2; _pl++) {
      var _pla = _pb_hole_ang + ((_pl == 0) ? -_pb_hole_hw : _pb_hole_hw);

      var _pldx = dcos(_pla);
      var _pldy = -dsin(_pla);
      var _pltx = 100000;
      var _plty = 100000;

      if (_pldx > 0.0001) _pltx = (_pb_xmax - _pb_ox) / _pldx;
      else if (_pldx < -0.0001) _pltx = (_pb_xmin - _pb_ox) / _pldx;

      if (_pldy > 0.0001) _plty = (_pb_ymax - _pb_oy) / _pldy;
      else if (_pldy < -0.0001) _plty = (_pb_ymin - _pb_oy) / _pldy;

      var _plt = max(1, min(_pltx, _plty));
      var _plvert = (_pltx <= _plty);
      var _plx = _pb_ox + _pldx * _plt;
      var _ply = _pb_oy + _pldy * _plt;
      var _plnx = _plvert ? ((_pldx > 0) ? -1 : 1) : 0;
      var _plny = _plvert ? 0 : ((_pldy > 0) ? -1 : 1);

      draw_line_width((_plx - _pb_cx) * _pb_gx, (_ply - _pb_cy) * _pb_gy,
                      (_plx + _plnx * _pb_depth * 0.7 - _pb_cx) * _pb_gx,
                      (_ply + _plny * _pb_depth * 0.7 - _pb_cy) * _pb_gy, 2.5);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
  }

  gpu_set_blendmode(bm_normal);
}

if (arrow_ring_created || ring_lock_flash > 0 || ring_telegraph_alpha > 0 || intro_heartbeat_pulse > 0 ||
    array_length(arrow_ring_particles) > 0 || array_length(ring_embers) > 0 ||
    array_length(ring_shockwaves) > 0 || array_length(ring_charge_motes) > 0 ||
    array_length(ring_streaks) > 0 || array_length(ring_rim_afterglow) > 0 ||
    array_length(ring_missile_reticles) > 0 || array_length(ring_missiles) > 0 ||
    array_length(ring_missile_bursts) > 0 || array_length(ring_missile_shards) > 0) {
  var _gx_scale = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _gy_scale = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _cam_x = oCameraController.current_cam_x;
  var _cam_y = oCameraController.current_cam_y;

  var _blob_half = sprite_get_width(spr_glow_blob) * 0.5;
  var _vs = arrow_ring_vertical_scale;
  var _coil = ring_coil_amount;

  var _rr = color_get_red(ring_color) / 255;
  var _rg = color_get_green(ring_color) / 255;
  var _rb = color_get_blue(ring_color) / 255;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

  if (arrow_ring_created || ring_lock_flash > 0 || ring_telegraph_alpha > 0 || intro_heartbeat_pulse > 0) {
    var _core_gx = (arrow_ring_x - _cam_x) * _gx_scale;
    var _core_gy = (arrow_ring_y - _cam_y) * _gy_scale;

    var _charge = ring_core_charge + ring_heartbeat * 0.6 + _coil * 0.8 + ring_lock_flash +
                  intro_heartbeat_pulse * 0.8 + ring_telegraph_alpha * 0.3;
    var _flash = clamp(arrow_core_flash / 20, 0, 1.5);
    var _charge_col = clamp(_charge, 0, 1);

    var _wash_r = (46 + _charge * 90 + _flash * 60) * _gx_scale;
    shader_set_uniform_f(global.u_glow_color, _rr, _rg * 0.55, _rb * 0.5);
    shader_set_uniform_f(global.u_glow_intensity, 0.55 + _charge * 0.7);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    draw_sprite_ext(spr_glow_blob, 0, _core_gx, _core_gy, _wash_r / _blob_half, _wash_r / _blob_half * 0.75, 0,
                    c_white, 1);

    var _mid_r = (20 + _charge * 34 + _flash * 26) * _gx_scale;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.35, 0.9, _charge_col), lerp(0.3, 0.85, _charge_col));
    shader_set_uniform_f(global.u_glow_intensity, 1.0 + _charge * 0.9);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _core_gx, _core_gy, _mid_r / _blob_half, _mid_r / _blob_half, 0, c_white, 1);

    var _hot_r = (7 + _charge * 13 + _flash * 14) * _gx_scale;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.4 + _charge * 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    draw_sprite_ext(spr_glow_blob, 0, _core_gx, _core_gy, _hot_r / _blob_half, _hot_r / _blob_half, 0, c_white, 1);
  }

  if (arrow_ring_created) {
    var _rim_heat = 0.25 + (ring_outline_pulse / 12) * 0.5 + _coil * 0.6 + ring_lock_flash * 0.6;
    var _k_rim_samples = 7;

    shader_set_uniform_f(global.u_glow_falloff, 1.9);

    for (var i = 0; i < arrow_ring_count; i++) {
      var a1 = arrow_ring[i];
      var a2 = arrow_ring[(i + 1) mod arrow_ring_count];
      if (!instance_exists(a1) || !instance_exists(a2)) continue;

      var _seg_p = min(a1.arrow_spawn_progress, a2.arrow_spawn_progress);
      if (_seg_p <= 0) continue;

      var _seg_wound = (i < ceil(ring_wound * arrow_ring_count)) ? ring_wound : 0;
      var _seg_heat = _rim_heat * (1 - _seg_wound * 0.35);

      shader_set_uniform_f(global.u_glow_color, _rr, _rg * (1 - _seg_wound * 0.4), _rb * (1 - _seg_wound * 0.4));
      shader_set_uniform_f(global.u_glow_intensity, _seg_heat * _seg_p);

      var _rim_scale = (5 + _seg_heat * 7) * _gx_scale / _blob_half;

      for (var s = 0; s < _k_rim_samples; s++) {
        var _f = s / (_k_rim_samples - 1);
        var _sx = lerp(a1.x, a2.x, _f);
        var _sy = lerp(a1.y, a2.y, _f);
        draw_sprite_ext(spr_glow_blob, 0, (_sx - _cam_x) * _gx_scale, (_sy - _cam_y) * _gy_scale, _rim_scale,
                        _rim_scale, 0, c_white, 1);
      }
    }

    var _spoke_heat = 0.1 + _coil * 0.75 + (arrow_core_flash / 20) * 0.3;

    if (_spoke_heat > 0.05) {
      var _k_spoke_samples = 5;
      var _spoke_scale = (4 + _spoke_heat * 7) * _gx_scale / _blob_half;

      shader_set_uniform_f(global.u_glow_color, _rr, lerp(_rg, 1, _coil * 0.5), lerp(_rb, 1, _coil * 0.5));
      shader_set_uniform_f(global.u_glow_intensity, _spoke_heat);

      for (var i = 0; i < arrow_ring_count; i++) {
        var a = arrow_ring[i];
        if (!instance_exists(a)) continue;

        for (var s = 1; s <= _k_spoke_samples; s++) {
          var _f = s / (_k_spoke_samples + 1);
          var _sx = lerp(arrow_ring_x, a.x, _f);
          var _sy = lerp(arrow_ring_y, a.y, _f);
          draw_sprite_ext(spr_glow_blob, 0, (_sx - _cam_x) * _gx_scale, (_sy - _cam_y) * _gy_scale, _spoke_scale,
                          _spoke_scale, 0, c_white, 1);
        }
      }
    }
  }

  var _k_wave_samples = 26;

  for (var w = 0; w < array_length(ring_shockwaves); w++) {
    var _sw = ring_shockwaves[w];
    var _swa = _sw.life / _sw.max_life;
    if (_swa <= 0.02) continue;

    var _wave_i = _swa * _swa * (0.7 + _sw.hot * 0.9);
    var _wave_scale = (_sw.width * _swa) * _gx_scale / _blob_half;
    if (_wave_scale <= 0) continue;

    var _swvs = variable_struct_exists(_sw, "vs") ? _sw.vs : _vs;

    var _swbase = (variable_struct_exists(_sw, "col") && !is_undefined(_sw.col)) ? _sw.col : ring_color;
    var _swr = color_get_red(_swbase) / 255;
    var _swg = color_get_green(_swbase) / 255;
    var _swb = color_get_blue(_swbase) / 255;
    shader_set_uniform_f(global.u_glow_color, lerp(_swr, 1, _sw.hot), lerp(_swg, 1, _sw.hot), lerp(_swb, 1, _sw.hot));
    shader_set_uniform_f(global.u_glow_intensity, _wave_i);
    shader_set_uniform_f(global.u_glow_falloff, 1.7);

    for (var s = 0; s < _k_wave_samples; s++) {
      var _ang = s * (360 / _k_wave_samples);
      var _sx = _sw.x + lengthdir_x(_sw.radius, _ang);
      var _sy = _sw.y + lengthdir_y(_sw.radius * _swvs, _ang);
      draw_sprite_ext(spr_glow_blob, 0, (_sx - _cam_x) * _gx_scale, (_sy - _cam_y) * _gy_scale, _wave_scale,
                      _wave_scale, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var p = 0; p < array_length(arrow_ring_particles); p++) {
    var _pt = arrow_ring_particles[p];
    var _pa = _pt.life / _pt.max_life;

    var _pspd = point_distance(0, 0, _pt.vx, _pt.vy);
    var _pdir = (_pspd > 0.01) ? point_direction(0, 0, _pt.vx, _pt.vy) : 0;
    var _pstretch = 1 + clamp(_pspd / 7, 0, 1) * 2.2;

    var _pt_has_col = variable_struct_exists(_pt, "col") && !is_undefined(_pt.col);
    var _ptr = _pt_has_col ? color_get_red(_pt.col) / 255 : 1;
    var _ptg = _pt_has_col ? color_get_green(_pt.col) / 255 : _rg;
    var _ptb = _pt_has_col ? color_get_blue(_pt.col) / 255 : _rb;
    shader_set_uniform_f(global.u_glow_color, lerp(_ptr, 1, _pt.hot), lerp(_ptg, 1, _pt.hot), lerp(_ptb, 1, _pt.hot));
    shader_set_uniform_f(global.u_glow_intensity, _pa * (0.8 + _pt.hot * 0.9));

    var _psc = _pt.size * _pa;
    draw_sprite_ext(spr_glow_blob, 0, (_pt.x - _cam_x) * _gx_scale, (_pt.y - _cam_y) * _gy_scale,
                    _psc * _pstretch, _psc, _pdir, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  for (var e = 0; e < array_length(ring_embers); e++) {
    var _em = ring_embers[e];
    var _ea = clamp(_em.life / _em.max_life, 0, 1);

    var _espd = point_distance(0, 0, _em.vx, _em.vy);
    var _edir = (_espd > 0.01) ? point_direction(0, 0, _em.vx, _em.vy) : 0;
    var _estretch = 1 + clamp(_espd / 5, 0, 1) * 3.4;

    var _cool = 1 - _ea;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(_em.hot, 0.12, _cool), lerp(_em.hot * 0.7, 0.08, _cool));
    shader_set_uniform_f(global.u_glow_intensity, _ea * 1.3);

    var _esc = _em.size * (0.5 + _ea * 0.5);
    draw_sprite_ext(spr_glow_blob, 0, (_em.x - _cam_x) * _gx_scale, (_em.y - _cam_y) * _gy_scale,
                    _esc * _estretch, _esc, _edir, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var m = 0; m < array_length(ring_charge_motes); m++) {
    var _mo = ring_charge_motes[m];

    var _mx = arrow_ring_x + lengthdir_x(_mo.dist, _mo.ang);
    var _my = arrow_ring_y + lengthdir_y(_mo.dist * _vs, _mo.ang);
    var _ma = clamp(1 - _mo.dist / (arrow_ring_radius * 2.4), 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_rg, 1, _mo.hot), lerp(_rb, 1, _mo.hot));
    shader_set_uniform_f(global.u_glow_intensity, _ma * 1.2);

    var _msc = _mo.size * (0.6 + _ma * 0.6);
    draw_sprite_ext(spr_glow_blob, 0, (_mx - _cam_x) * _gx_scale, (_my - _cam_y) * _gy_scale,
                    _msc * (1 + _mo.speed * 0.22), _msc, _mo.ang + 180, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  var _k_streak_samples = 5;

  for (var i = 0; i < array_length(ring_streaks); i++) {
    var _st = ring_streaks[i];
    var _sta = _st.life / _st.max_life;
    if (_sta <= 0.02) continue;

    var _sox = variable_struct_exists(_st, "cx") ? _st.cx : arrow_ring_x;
    var _soy = variable_struct_exists(_st, "cy") ? _st.cy : arrow_ring_y;
    var _svs = variable_struct_exists(_st, "vs") ? _st.vs : _vs;

    var _stbase = (variable_struct_exists(_st, "col") && !is_undefined(_st.col)) ? _st.col : ring_color;
    var _str = color_get_red(_stbase) / 255;
    var _stg = color_get_green(_stbase) / 255;
    var _stb = color_get_blue(_stbase) / 255;
    shader_set_uniform_f(global.u_glow_color, lerp(_str, 1, _st.hot), lerp(_stg, 1, _st.hot), lerp(_stb, 1, _st.hot));
    shader_set_uniform_f(global.u_glow_intensity, _sta * (0.6 + _st.hot * 0.7));

    var _st_scale = (_st.width * 2.6) * _gx_scale / _blob_half;

    for (var s = 0; s < _k_streak_samples; s++) {
      var _sd = _st.dist + _st.len * (s / (_k_streak_samples - 1));
      var _sx = _sox + lengthdir_x(_sd, _st.ang);
      var _sy = _soy + lengthdir_y(_sd * _svs, _st.ang);
      draw_sprite_ext(spr_glow_blob, 0, (_sx - _cam_x) * _gx_scale, (_sy - _cam_y) * _gy_scale, _st_scale,
                      _st_scale, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  for (var _rt_i = 0; _rt_i < array_length(ring_missile_reticles); _rt_i++) {
    var _rt = ring_missile_reticles[_rt_i];
    var _rp = clamp(_rt.life / max(_rt.max_life, 1), 0, 1);
    var _rc = 1 - _rp;
    var _ri = (0.42 + _rc * 0.95) * (0.8 + _rt.hit_index * 0.16);
    var _rs = (22 + _rt.hit_index * 6 + _rc * 20) * _gx_scale / _blob_half;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.18, 0.9, _rc), lerp(0.14, 0.85, _rc));
    shader_set_uniform_f(global.u_glow_intensity, _ri);
    draw_sprite_ext(spr_glow_blob, 0, (_rt.x - _cam_x) * _gx_scale, (_rt.y - _cam_y) * _gy_scale,
                    _rs, _rs, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.35);

  for (var _m_i = 0; _m_i < array_length(ring_missiles); _m_i++) {
    var _m = ring_missiles[_m_i];
    var _mp = clamp(_m.timer / max(_m.fuse, 1), 0, 1);
    var _ms = (12 + _m.hot * 10 + _mp * 10) * _gx_scale / _blob_half;
    var _mx = (_m.x - _cam_x) * _gx_scale;
    var _my = (_m.y - _cam_y) * _gy_scale;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.25, 1, _m.hot), lerp(0.18, 0.95, _m.hot));
    shader_set_uniform_f(global.u_glow_intensity, 1.0 + _mp * 1.2);
    draw_sprite_ext(spr_glow_blob, 0, _mx, _my, _ms * 1.8, _ms, point_direction(_m.px, _m.py, _m.x, _m.y),
                    c_white, 1);

    var _trail_n = array_length(_m.trail);
    for (var _ti = 0; _ti < _trail_n; _ti++) {
      var _tp = _m.trail[_ti];
      var _ta = (1 - _ti / max(_trail_n, 1)) * (0.55 + _mp * 0.45);
      var _ts = (8 + _ta * 9) * _gx_scale / _blob_half;
      shader_set_uniform_f(global.u_glow_intensity, _ta * 0.85);
      draw_sprite_ext(spr_glow_blob, 0, (_tp.x - _cam_x) * _gx_scale, (_tp.y - _cam_y) * _gy_scale,
                      _ts * 1.8, _ts, point_direction(_m.ox, _m.oy, _m.tx, _m.ty), c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.55);

  for (var _bu_i = 0; _bu_i < array_length(ring_missile_bursts); _bu_i++) {
    var _bu = ring_missile_bursts[_bu_i];
    var _ba = clamp(_bu.life / max(_bu.max_life, 1), 0, 1);
    var _bs = (_bu.radius * (1.0 + _bu.hot * 0.5)) * _gx_scale / _blob_half;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.25, 1, _bu.hot), lerp(0.18, 0.95, _bu.hot));
    shader_set_uniform_f(global.u_glow_intensity, _ba * _ba * (1.3 + _bu.hot));
    draw_sprite_ext(spr_glow_blob, 0, (_bu.x - _cam_x) * _gx_scale, (_bu.y - _cam_y) * _gy_scale,
                    _bs, _bs, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.45);

  for (var _sh_i = 0; _sh_i < array_length(ring_missile_shards); _sh_i++) {
    var _sh = ring_missile_shards[_sh_i];
    if (_sh.delay > 0) continue;

    var _sa = clamp(_sh.life / max(_sh.max_life, 1), 0, 1);
    var _ss = (6 + _sh.scale * 8) * _sa * _gx_scale / _blob_half;
    if (_ss <= 0) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 0.95, _sh.hot), lerp(0.16, 0.9, _sh.hot));
    shader_set_uniform_f(global.u_glow_intensity, _sa * (0.9 + _sh.hot));
    draw_sprite_ext(spr_glow_blob, 0, (_sh.x - _cam_x) * _gx_scale, (_sh.y - _cam_y) * _gy_scale,
                    _ss * 2.0, _ss, _sh.ang, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 2.2);

  var _k_ghost_samples = 5;

  for (var g = 0; g < array_length(ring_rim_afterglow); g++) {
    var _ag = ring_rim_afterglow[g];
    var _apts = _ag.pts;
    var _an = array_length(_apts);
    if (_an < 2 || _ag.alpha <= 0.02) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_rg, 1, _ag.hot), lerp(_rb, 1, _ag.hot));
    shader_set_uniform_f(global.u_glow_intensity, _ag.alpha * _ag.alpha * 0.7);

    var _ag_scale = (5 + _ag.alpha * 9) * _gx_scale / _blob_half;

    for (var _pi = 0; _pi < _an; _pi++) {
      var _p1 = _apts[_pi];
      var _p2 = _apts[(_pi + 1) mod _an];

      for (var s = 0; s < _k_ghost_samples; s++) {
        var _f = s / _k_ghost_samples;
        draw_sprite_ext(spr_glow_blob, 0, (lerp(_p1.x, _p2.x, _f) - _cam_x) * _gx_scale,
                        (lerp(_p1.y, _p2.y, _f) - _cam_y) * _gy_scale, _ag_scale, _ag_scale, 0, c_white, 1);
      }
    }
  }

  if (arrow_ring_created) {
    for (var i = 0; i < arrow_ring_count; i++) {
      var _hist = arrow_ring_history[i];
      var _hn = array_length(_hist);

      for (var h = 0; h < _hn; h++) {
        var _gh = _hist[h];
        var _gha = (1 - h / _hn) * _gh.alpha;
        if (_gha <= 0.02) continue;

        var _ghx = (arrow_ring_x + lengthdir_x(_gh.radius, _gh.ang) - _cam_x) * _gx_scale;
        var _ghy = (arrow_ring_y + lengthdir_y(_gh.radius * _vs, _gh.ang) - _cam_y) * _gy_scale;

        var _gh_scale = (10 + _gha * 10) * _gx_scale / _blob_half;

        shader_set_uniform_f(global.u_glow_color, _rr, _rg, _rb);
        shader_set_uniform_f(global.u_glow_intensity, _gha * 0.7);
        shader_set_uniform_f(global.u_glow_falloff, 1.9);
        draw_sprite_ext(spr_glow_blob, 0, _ghx, _ghy, _gh_scale, _gh_scale, 0, c_white, 1);

        shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, _gha * 0.5);
        shader_set_uniform_f(global.u_glow_falloff, 1.3);
        draw_sprite_ext(spr_glow_blob, 0, _ghx, _ghy, _gh_scale * 0.45, _gh_scale * 0.45, 0, c_white, 1);
      }
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (array_length(ring_craters) > 0 || array_length(ring_stuck_arrows) > 0 || array_length(ring_tracers) > 0) {
  var _af_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _af_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _af_cx = oCameraController.current_cam_x;
  var _af_cy = oCameraController.current_cam_y;
  var _af_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _af_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _af_uvs[0], _af_uvs[1], _af_uvs[2], _af_uvs[3]);

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  for (var _ac = 0; _ac < array_length(ring_craters); _ac++) {
    var _acr = ring_craters[_ac];
    var _aca = _acr.life / _acr.max_life;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.18, 1, _acr.hot * _aca), lerp(0.15, 0.95, _acr.hot * _aca));
    shader_set_uniform_f(global.u_glow_intensity, _aca * _aca * (0.9 + _acr.hot));

    var _acs = (_acr.radius * 1.6) * _af_gx / _af_half;
    draw_sprite_ext(spr_glow_blob, 0, (_acr.x - _af_cx) * _af_gx, (_acr.y - _af_cy) * _af_gy, _acs, _acs * 0.5,
                    _acr.edge, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var _as = 0; _as < array_length(ring_stuck_arrows); _as++) {
    var _ast = ring_stuck_arrows[_as];
    var _asa = clamp(_ast.life / _ast.max_life, 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.1, 0.8, _asa), lerp(0.08, 0.7, _asa));
    shader_set_uniform_f(global.u_glow_intensity, _asa * 0.9);

    var _ass = (7 + _ast.scale * 4) * (0.5 + _asa * 0.5) * _af_gx / _af_half;
    draw_sprite_ext(spr_glow_blob, 0, (_ast.x - _af_cx) * _af_gx, (_ast.y - _af_cy) * _af_gy, _ass * 1.6, _ass,
                    _ast.ang, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var _at = 0; _at < array_length(ring_tracers); _at++) {
    var _atr = ring_tracers[_at];
    var _atp = _atr.fired ? clamp(_atr.travel / max(_atr.dist, 1), 0, 1)
                          : clamp(1 - (_atr.life / max(_atr.max_life, 1)), 0, 1);
    var _ati = _atp * _atp * (0.35 + ring_ambient * 0.5);
    if (_ati <= 0.02) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 0.85, _atp), lerp(0.18, 0.8, _atp));
    shader_set_uniform_f(global.u_glow_intensity, _ati);

    var _ats = (7 + _atp * 16) * _af_gx / _af_half;
    draw_sprite_ext(spr_glow_blob, 0, (_atr.lx - _af_cx) * _af_gx, (_atr.ly - _af_cy) * _af_gy, _ats, _ats, 0,
                    c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (tree_scar_alpha > 0.002 && array_length(tree_scar_segments) > 0) {
  var _sc_burn = 1 - tree_scar_alpha;
  var _sc_master = tree_scar_alpha * tree_scar_alpha;
  var _sc_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _sc_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _sc_cx = oCameraController.current_cam_x;
  var _sc_cy = oCameraController.current_cam_y;
  var _sc_n = array_length(tree_scar_segments);
  var _sc_step = max(1, ceil(_sc_n / _k_scar_glow_budget));
  var _sc_boost = _sc_step;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _sc_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _sc_uvs[0], _sc_uvs[1], _sc_uvs[2], _sc_uvs[3]);

  for (var _sci = 0; _sci < _sc_n; _sci += _sc_step) {
    var _scg = tree_scar_segments[_sci];
    if (_scg.dead) continue;

    var _sc_heat = clamp((_scg.burn_at - _sc_burn) / max(_scg.burn_at, 0.001), 0, 1);
    var _sc_sag = (1 - _sc_heat) * _scg.thin01 * _k_scar_sag;

    var _sc_r = 1;
    var _sc_g = lerp(0.10, 1, _sc_heat);
    var _sc_b = lerp(0.05, 0.85, _sc_heat * _sc_heat);

    var _sc_samples = clamp(round(_scg.len / 14), 1, 5);
    var _sc_size = (_scg.w / 26) * (0.45 + _sc_heat * 0.9);

    shader_set_uniform_f(global.u_glow_color, _sc_r, _sc_g, _sc_b);
    shader_set_uniform_f(global.u_glow_intensity,
                         _sc_master * _sc_heat * 1.35 * min(_sc_boost, 2.2));
    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    for (var _scs = 0; _scs < _sc_samples; _scs++) {
      var _sc_t = (_sc_samples == 1) ? 0.5 : (_scs / (_sc_samples - 1));
      var _sc_px = lerp(_scg.ax, _scg.bx, _sc_t);
      var _sc_py = lerp(_scg.ay, _scg.by, _sc_t) + _sc_sag * (1 - _sc_t * 0.65);
      draw_sprite_ext(spr_glow_blob, 0, (_sc_px - _sc_cx) * _sc_gx, (_sc_py - _sc_cy) * _sc_gy,
                      _sc_size, _sc_size, 0, c_white, 1);
    }
  }

  if (tree_scar_flash > 0.01) {
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, tree_scar_flash * 2.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    var _sc_fx = (tree_crown_center_x - _sc_cx) * _sc_gx;
    var _sc_fy = (tree_crown_center_y - _sc_cy) * _sc_gy;
    var _sc_fs = 2.2 + (1 - tree_scar_flash) * 3.4;
    draw_sprite_ext(spr_glow_blob, 0, _sc_fx, _sc_fy, _sc_fs, _sc_fs, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (array_length(tree_scar_motes) > 0) {
  var _smg_x = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _smg_y = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _smg_cx = oCameraController.current_cam_x;
  var _smg_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _smg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _smg_uvs[0], _smg_uvs[1], _smg_uvs[2], _smg_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 2.0);

  for (var _smi = 0; _smi < array_length(tree_scar_motes); _smi++) {
    var _sm2 = tree_scar_motes[_smi];
    var _sm_a = clamp(_sm2.life / _sm2.life_max, 0, 1);
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.12, 0.75, _sm_a), lerp(0.06, 0.45, _sm_a));
    shader_set_uniform_f(global.u_glow_intensity, _sm_a * 1.1);
    var _sm_s = _sm2.size * (0.4 + _sm_a * 0.6);
    draw_sprite_ext(spr_glow_blob, 0, (_sm2.x - _smg_cx) * _smg_x, (_sm2.y - _smg_cy) * _smg_y,
                    _sm_s, _sm_s, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (array_length(converge_motes) > 0) {
  var _cm_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _cm_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _cm_cx = oCameraController.current_cam_x;
  var _cm_cy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _cm_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _cm_uvs[0], _cm_uvs[1], _cm_uvs[2], _cm_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var _cm = 0; _cm < array_length(converge_motes); _cm++) {
    var _mo2 = converge_motes[_cm];

    var _mx2 = _mo2.cx + lengthdir_x(_mo2.dist, _mo2.ang);
    var _my2 = _mo2.cy + lengthdir_y(_mo2.dist, _mo2.ang);
    var _ma2 = clamp(1 - (_mo2.dist - _mo2.dest) / 260, 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.25, 1, _mo2.hot), lerp(0.22, 1, _mo2.hot));
    shader_set_uniform_f(global.u_glow_intensity, _ma2 * 1.2);

    var _msc2 = _mo2.size * (0.6 + _ma2 * 0.6);
    draw_sprite_ext(spr_glow_blob, 0, (_mx2 - _cm_cx) * _cm_gx, (_my2 - _cm_cy) * _cm_gy,
                    _msc2 * (1 + _mo2.speed * 0.22), _msc2, _mo2.ang + 180, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (!is_undefined(lat)) {
  scr_lattice_draw_glow(oCameraController.current_cam_x,
                        oCameraController.current_cam_y,
                        oCameraController.base_view_w / oCameraController.current_cam_w,
                        oCameraController.base_view_h / oCameraController.current_cam_h);
}

if (!is_undefined(riser)) {
  scr_riser_draw_glow(oCameraController.current_cam_x,
                      oCameraController.current_cam_y,
                      oCameraController.base_view_w / oCameraController.current_cam_w,
                      oCameraController.base_view_h / oCameraController.current_cam_h);
}

if (cube_active || cube_detonation_flash > 0 || array_length(cube_scars) > 0 ||
    array_length(cube_ghosts) > 0) {
  var _qx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _qy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _qcx = oCameraController.current_cam_x;
  var _qcy = oCameraController.current_cam_y;
  var _qhalf = sprite_get_width(spr_glow_blob) * 0.5;

  var _q_col = merge_color(global.avoid_col_cyan, global.avoid_col_danger,
                           clamp(cube_overload * 0.6 + cube_detonation_flash * 0.7 +
                                 cube_core_flash * 0.2, 0, 1));
  var _qr = color_get_red(_q_col) / 255;
  var _qg = color_get_green(_q_col) / 255;
  var _qb = color_get_blue(_q_col) / 255;

  var _q_gcx = (cube_center_x - _qcx) * _qx;
  var _q_gcy = (cube_center_y - _qcy) * _qy;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _quvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _quvs[0], _quvs[1], _quvs[2], _quvs[3]);

  if (cube_active || cube_detonation_flash > 0) {
    var _q_charge = clamp(cube_charge, 0, 1.8);
    var _q_flash = cube_core_flash + cube_ignite_flash * 0.8 + cube_detonation_flash * 2.2 +
                   cube_lock_flash * 0.5;

    var _wash = (34 + _q_charge * 46 + _q_flash * 90) * _qx * cube_core_extend * cube_core_fade;
    if (cube_detonation_flash > 0) _wash = (60 + cube_detonation_flash * 420) * _qx;
    if (_wash > 1) {
      shader_set_uniform_f(global.u_glow_color, _qr, _qg * 0.6, _qb * 0.55);
      shader_set_uniform_f(global.u_glow_intensity, 0.45 + _q_charge * 0.5 + _q_flash * 0.6);
      shader_set_uniform_f(global.u_glow_falloff, 2.1);
      draw_sprite_ext(spr_glow_blob, 0, _q_gcx, _q_gcy, _wash / _qhalf, _wash / _qhalf, 0, c_white, 1);

      var _mid = _wash * 0.45;
      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, 0.35), lerp(_qb, 1, 0.3));
      shader_set_uniform_f(global.u_glow_intensity, 0.7 + _q_charge * 0.6 + _q_flash * 0.9);
      shader_set_uniform_f(global.u_glow_falloff, 1.7);
      draw_sprite_ext(spr_glow_blob, 0, _q_gcx, _q_gcy, _mid / _qhalf, _mid / _qhalf, 0, c_white, 1);

      var _hot = _wash * 0.16 * (1 + _q_flash * 0.8);
      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, 0.8 + _q_flash * 1.6);
      shader_set_uniform_f(global.u_glow_falloff, 2.6);
      draw_sprite_ext(spr_glow_blob, 0, _q_gcx, _q_gcy, _hot / _qhalf, _hot / _qhalf, 0, c_white, 1);
    }
  }

  if (cube_active && array_length(big_cube_projected) >= 8) {
    var _q_heat = cube_edge_surge + cube_heartbeat * 0.5 + cube_lock_flash * 0.5 +
                  cube_overload * 0.6 + cube_coil * 0.3;

    shader_set_uniform_f(global.u_glow_falloff, 1.7);

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _qe = cube_edges[e];
      var _qv1 = cube_cv_frame[_qe[0]];
      var _qv2 = cube_cv_frame[_qe[1]];

      var _q1x = (_qv1.x - _qcx) * _qx;
      var _q1y = (_qv1.y - _qcy) * _qy;
      var _q2x = (_qv2.x - _qcx) * _qx;
      var _q2y = (_qv2.y - _qcy) * _qy;

      var _qdepth = clamp((_qv1.scale + _qv2.scale) * 0.5, 0.15, 1.2);
      var _qlen = point_distance(_q1x, _q1y, _q2x, _q2y);
      var _qsteps = clamp(round(_qlen / 22), 2, 16);

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, clamp(_q_heat * 0.6, 0, 1)),
                           lerp(_qb, 1, clamp(_q_heat * 0.5, 0, 1)));
      shader_set_uniform_f(global.u_glow_intensity, _qdepth * (0.35 + _q_heat * 0.7));

      var _qsc = (5 + _q_heat * 9) * _qdepth * _qx / _qhalf;

      for (var k = 0; k <= _qsteps; k++) {
        var _kf = k / _qsteps;
        draw_sprite_ext(spr_glow_blob, 0, lerp(_q1x, _q2x, _kf), lerp(_q1y, _q2y, _kf),
                        _qsc, _qsc, 0, c_white, 1);
      }
    }

    shader_set_uniform_f(global.u_glow_falloff, 1.5);

    for (var p = 0; p < array_length(cube_edge_pulses); p++) {
      var _qp = cube_edge_pulses[p];
      var _qpe = cube_edges[_qp.edge];
      var _qpa = _qp.from_a ? cube_cv_frame[_qpe[0]] : cube_cv_frame[_qpe[1]];
      var _qpb = _qp.from_a ? cube_cv_frame[_qpe[1]] : cube_cv_frame[_qpe[0]];

      var _qpax = (_qpa.x - _qcx) * _qx;
      var _qpay = (_qpa.y - _qcy) * _qy;
      var _qpbx = (_qpb.x - _qcx) * _qx;
      var _qpby = (_qpb.y - _qcy) * _qy;

      var _qpl = _qp.life / _qp.life_max;
      var _qpos = clamp(_qp.pos, 0, 1);
      var _qhx = lerp(_qpax, _qpbx, _qpos);
      var _qhy = lerp(_qpay, _qpby, _qpos);
      var _qdir = point_direction(_qpax, _qpay, _qpbx, _qpby);

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, _qp.hot), lerp(_qb, 1, _qp.hot));
      shader_set_uniform_f(global.u_glow_intensity, _qpl * (0.7 + _qp.hot * 0.9));

      var _qpsc = (_qp.width * 3.6) * _qx / _qhalf;
      draw_sprite_ext(spr_glow_blob, 0, _qhx, _qhy, _qpsc * 2.4, _qpsc, _qdir, c_white, 1);
    }
  }

  if (cube_active && array_length(big_cube_projected) >= 8) {
    shader_set_uniform_f(global.u_glow_falloff, 2.0);

    for (var i = 0; i < 8; i++) {
      var _qvv = cube_cv_frame[i];
      var _qvx = (_qvv.x - _qcx) * _qx;
      var _qvy = (_qvv.y - _qcy) * _qy;
      var _qvd = clamp(_qvv.scale, 0.15, 1.2);
      var _qvh = cube_vertex_heat[i];

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, clamp(_qvh, 0, 1)),
                           lerp(_qb, 1, clamp(_qvh, 0, 1)));
      shader_set_uniform_f(global.u_glow_intensity, _qvd * (0.5 + _qvh * 1.3) * cube_extend);

      var _qvs = (10 + _qvh * 30) * _qvd * _qx / _qhalf;
      draw_sprite_ext(spr_glow_blob, 0, _qvx, _qvy, _qvs, _qvs, 0, c_white, 1);
    }
  }

  if (cube_active && array_length(big_cube_projected) >= 8) {
    shader_set_uniform_f(global.u_glow_falloff, 2.3);

    var _qcvs = cube_cv_frame;

    for (var f = 0; f < 6; f++) {
      var _qfh = cube_face_heat[f] + cube_face_flash[f] * 1.8;
      if (_qfh <= 0.02) continue;

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, clamp(_qfh * 0.6, 0, 1)),
                           lerp(_qb, 1, clamp(_qfh * 0.5, 0, 1)));
      shader_set_uniform_f(global.u_glow_intensity, clamp(_qfh, 0, 1.6) * 0.75);

      for (var gu = 0; gu < 3; gu++) {
        for (var gw = 0; gw < 3; gw++) {
          var _qfp = scr_face_uv_to_point(_qcvs, f, 0.2 + gu * 0.3, 0.2 + gw * 0.3);
          var _qfs = (30 + _qfh * 26) * clamp(_qfp.scale, 0.2, 1.2) * _qx / _qhalf;
          draw_sprite_ext(spr_glow_blob, 0, (_qfp.x - _qcx) * _qx, (_qfp.y - _qcy) * _qy,
                          _qfs, _qfs, 0, c_white, 1);
        }
      }
    }
  }

  if (cube_core_extend > 0.02 && array_length(small_cube_projected) >= 8) {
    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    var _qci = cube_core_extend * cube_core_fade * (0.55 + cube_charge * 0.4 + cube_core_flash * 0.6);

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _qce = cube_edges[e];
      var _qc1 = small_cube_projected[_qce[0]];
      var _qc2 = small_cube_projected[_qce[1]];

      var _qc1x = (_qc1.x - _qcx) * _qx;
      var _qc1y = (_qc1.y - _qcy) * _qy;
      var _qc2x = (_qc2.x - _qcx) * _qx;
      var _qc2y = (_qc2.y - _qcy) * _qy;

      shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, 0.5), lerp(_qb, 1, 0.45));
      shader_set_uniform_f(global.u_glow_intensity, _qci * 0.8);

      var _qcs = 7 * _qx / _qhalf;
      var _qcsteps = 4;
      for (var k = 0; k <= _qcsteps; k++) {
        var _kf2 = k / _qcsteps;
        draw_sprite_ext(spr_glow_blob, 0, lerp(_qc1x, _qc2x, _kf2), lerp(_qc1y, _qc2y, _kf2),
                        _qcs, _qcs, 0, c_white, 1);
      }
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 2.4);

  for (var g = 0; g < array_length(cube_ghosts); g++) {
    var _qgh = cube_ghosts[g];
    var _qgv = _qgh.verts;
    if (array_length(_qgv) < 8) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, _qgh.hot * 0.7),
                         lerp(_qb, 1, _qgh.hot * 0.6));
    shader_set_uniform_f(global.u_glow_intensity, _qgh.alpha * 0.55);

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _qge = cube_edges[e];
      var _qga = _qgv[_qge[0]];
      var _qgb2 = _qgv[_qge[1]];

      var _qgax = (lerp(cube_center_x, _qga.x, _qgh.extend) - _qcx) * _qx;
      var _qgay = (lerp(cube_center_y, _qga.y, _qgh.extend) - _qcy) * _qy;
      var _qgbx = (lerp(cube_center_x, _qgb2.x, _qgh.extend) - _qcx) * _qx;
      var _qgby = (lerp(cube_center_y, _qgb2.y, _qgh.extend) - _qcy) * _qy;

      var _qgs = 9 * _qx / _qhalf;
      for (var k = 0; k <= 4; k++) {
        var _kf3 = k / 4;
        draw_sprite_ext(spr_glow_blob, 0, lerp(_qgax, _qgbx, _kf3), lerp(_qgay, _qgby, _kf3),
                        _qgs, _qgs, 0, c_white, 1);
      }
    }
  }

  for (var s = 0; s < array_length(cube_scars); s++) {
    var _qsc2 = cube_scars[s];
    var _qsv = _qsc2.verts;
    if (array_length(_qsv) < 8) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, _qsc2.hot * 0.5),
                         lerp(_qb, 1, _qsc2.hot * 0.4));
    shader_set_uniform_f(global.u_glow_intensity, _qsc2.alpha * 0.4);

    for (var e = 0; e < array_length(cube_edges); e++) {
      var _qse = cube_edges[e];
      var _qsa = _qsv[_qse[0]];
      var _qsb = _qsv[_qse[1]];

      var _qsax = (lerp(cube_center_x, _qsa.x, _qsc2.extend) - _qcx) * _qx;
      var _qsay = (lerp(cube_center_y, _qsa.y, _qsc2.extend) - _qcy) * _qy;
      var _qsbx = (lerp(cube_center_x, _qsb.x, _qsc2.extend) - _qcx) * _qx;
      var _qsby = (lerp(cube_center_y, _qsb.y, _qsc2.extend) - _qcy) * _qy;

      var _qss = 16 * _qx / _qhalf;
      for (var k = 0; k <= 3; k++) {
        var _kf4 = k / 3;
        draw_sprite_ext(spr_glow_blob, 0, lerp(_qsax, _qsbx, _kf4), lerp(_qsay, _qsby, _kf4),
                        _qss, _qss, 0, c_white, 1);
      }
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  with (oCube) {
    if (image_alpha < 0.05) continue;

    var _ostr = 1 + clamp(speed_now / 3.5, 0, 1) * 2.4;
    var _odir = (speed_now > 0.05) ? point_direction(0, 0, vel_x, vel_y) : 0;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, 0.35), lerp(_qb, 1, 0.3));
    shader_set_uniform_f(global.u_glow_intensity, image_alpha * (0.55 + other.cube_edge_surge * 0.5));

    var _osc = (9 * image_xscale) * _qx / _qhalf;
    draw_sprite_ext(spr_glow_blob, 0, (x - _qcx) * _qx, (y - _qcy) * _qy,
                    _osc * _ostr, _osc, _odir, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.5);

  with (oCubeFaceBullet) {
    if (bullet_mode == "grid") continue;
    if (image_alpha < 0.05) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(_qg, 1, 0.4 + heat * 0.4),
                         lerp(_qb, 1, 0.35 + heat * 0.4));
    shader_set_uniform_f(global.u_glow_intensity, image_alpha * (0.55 + heat * 0.8));

    var _tn = array_length(trail);
    if (_tn < 2) continue;

    for (var _ti = 0; _ti < _tn; _ti++) {
      var _tp = trail[_ti];
      var _tf = (_ti + 1) / _tn;

      var _tsc = (7 * image_xscale * _tf * _tf) * _qx / _qhalf;
      draw_sprite_ext(spr_glow_blob, 0, (_tp.x - _qcx) * _qx, (_tp.y - _qcy) * _qy,
                      _tsc, _tsc, 0, c_white, 1);
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (shapes_core_charge > 0.01 || shapes_launch_flash > 0 || array_length(shapes_ghosts) > 0) {
  var _sh_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _sh_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _sh_cx = oCameraController.current_cam_x;
  var _sh_cy = oCameraController.current_cam_y;
  var _sh_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _sh_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _sh_uvs[0], _sh_uvs[1], _sh_uvs[2], _sh_uvs[3]);

  if (shapes_core_charge > 0.01 || shapes_launch_flash > 0) {
    var _sh_core_x = (intro_cx - _sh_cx) * _sh_gx;
    var _sh_core_y = (intro_cy - _sh_cy) * _sh_gy;

    var _sh_charge = shapes_core_charge + shapes_heartbeat * 0.6 + shapes_coil * 0.8 + shapes_launch_flash;
    var _sh_flash = clamp(shapes_core_flash / 20, 0, 1.5) * fx_get_mult_for("introshapes", "flash");
    var _sh_ccol = clamp(_sh_charge, 0, 1);

    var _sh_wash = (40 + _sh_charge * 96 + _sh_flash * 64) * _sh_gx;
    shader_set_uniform_f(global.u_glow_color, 1, 0.32, 0.28);
    shader_set_uniform_f(global.u_glow_intensity, 0.5 + _sh_charge * 0.7);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    draw_sprite_ext(spr_glow_blob, 0, _sh_core_x, _sh_core_y, _sh_wash / _sh_half, _sh_wash / _sh_half, 0, c_white, 1);

    var _sh_mid = (18 + _sh_charge * 34 + _sh_flash * 28) * _sh_gx;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.35, 0.9, _sh_ccol), lerp(0.3, 0.85, _sh_ccol));
    shader_set_uniform_f(global.u_glow_intensity, 1.0 + _sh_charge * 0.9);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _sh_core_x, _sh_core_y, _sh_mid / _sh_half, _sh_mid / _sh_half, 0, c_white, 1);

    var _sh_hot = (6 + _sh_charge * 14 + _sh_flash * 15) * _sh_gx;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.3 + _sh_charge * 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    draw_sprite_ext(spr_glow_blob, 0, _sh_core_x, _sh_core_y, _sh_hot / _sh_half, _sh_hot / _sh_half, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.9);

  for (var _sg = 0; _sg < array_length(shapes_ghosts); _sg++) {
    var _gh2 = shapes_ghosts[_sg];
    var _gp3 = _gh2.pts;
    var _gn3 = array_length(_gp3);
    if (_gn3 < 2) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.28, 1, _gh2.hot), lerp(0.24, 1, _gh2.hot));
    shader_set_uniform_f(global.u_glow_intensity, _gh2.alpha * 0.9);

    var _gscale = (3 + _gh2.width * 2.4) * _sh_gx / _sh_half;
    var _gsegs2 = _gh2.closed ? _gn3 : (_gn3 - 1);

    for (var _gs2 = 0; _gs2 < _gsegs2; _gs2++) {
      var _ga = _gp3[_gs2];
      var _gb = _gp3[(_gs2 + 1) mod _gn3];

      for (var _gk = 0; _gk < 4; _gk++) {
        var _gf = _gk / 3;
        var _gx2 = lerp(_ga.x, _gb.x, _gf);
        var _gy2 = lerp(_ga.y, _gb.y, _gf);
        draw_sprite_ext(spr_glow_blob, 0, (_gx2 - _sh_cx) * _sh_gx, (_gy2 - _sh_cy) * _sh_gy, _gscale, _gscale, 0,
                        c_white, 1);
      }
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (t >= _k_rain_start && t < 720 &&
    (array_length(kunai_impacts) > 0 || array_length(kunai_shards) > 0 || array_length(orbit_path_ghosts) > 0 ||
     array_length(kunai_absorb_pops) > 0 || array_length(rain_source_slots) > 0 ||
     array_length(rain_floor_scars) > 0 || rain_intensity > 0.02 ||
     orbit_ribbon_heat > 0.02 || big_kunai_telegraph > 0.01)) {
  var _rk_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _rk_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _rk_cx = oCameraController.current_cam_x;
  var _rk_cy = oCameraController.current_cam_y;
  var _rk_half = sprite_get_width(spr_glow_blob) * 0.5;
  var _rk_clear = clamp(1 - max(0, t - 682) / 8, 0, 1);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _rk_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _rk_uvs[0], _rk_uvs[1], _rk_uvs[2], _rk_uvs[3]);

  if (_rk_clear > 0.01 && (rain_intensity > 0.02 || array_length(rain_source_slots) > 0)) {
    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    for (var _rg = 0; _rg < array_length(rain_source_slots); _rg++) {
      var _slotg = rain_source_slots[_rg];
      var _ageg = _slotg.max_life - _slotg.life;
      var _fadeg = clamp(_slotg.life / 10, 0, 1) * _rk_clear;
      var _fireg = 1 - clamp(abs(_ageg - _slotg.fire_at) / 8, 0, 1);
      var _warmg = clamp(_slotg.hot * 0.4 + _fireg + rain_heartbeat * 0.5, 0, 1.2);
      if (_fadeg <= 0.01 || _warmg <= 0.03) continue;

      shader_set_uniform_f(global.u_glow_color, 1, lerp(0.16, 0.62, _warmg), lerp(0.12, 0.4, _warmg));
      shader_set_uniform_f(global.u_glow_intensity, _fadeg * (0.34 + _warmg * 0.9));

      var _sgs = (18 + _warmg * 24) * _rk_gx / _rk_half;
      draw_sprite_ext(spr_glow_blob, 0, (_slotg.x - _rk_cx) * _rk_gx,
                      (_slotg.y - _rk_cy) * _rk_gy, _sgs, _sgs * 0.5, 0, c_white, 1);
    }
  }

  if (orbit_ribbon_heat > 0.02 || big_kunai_telegraph > 0.01) {
    var _rib = max(orbit_ribbon_heat, big_kunai_telegraph * 0.5);
    var _rib_samples = 54;
    var _rib_scale = (4 + _rib * 9) * _rk_gx / _rk_half;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 0.95, clamp(_rib, 0, 1)),
                         lerp(0.18, 0.9, clamp(_rib, 0, 1)));
    shader_set_uniform_f(global.u_glow_intensity, clamp(_rib, 0, 1.4) * 0.85);
    shader_set_uniform_f(global.u_glow_falloff, 1.9);

    for (var _rs = 0; _rs < _rib_samples; _rs++) {
      var _ra = _rs * (360 / _rib_samples);
      var _rx = _k_orbit_cx + dcos(_ra) * _k_orbit_rx;
      var _ry = _k_orbit_cy + dsin(_ra) * _k_orbit_ry;
      draw_sprite_ext(spr_glow_blob, 0, (_rx - _rk_cx) * _rk_gx, (_ry - _rk_cy) * _rk_gy, _rib_scale, _rib_scale, 0,
                      c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.5);

  for (var _pg = 0; _pg < array_length(orbit_path_ghosts); _pg++) {
    var _gp4 = orbit_path_ghosts[_pg];

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 1, _gp4.hot), lerp(0.18, 1, _gp4.hot));
    shader_set_uniform_f(global.u_glow_intensity, _gp4.alpha * 1.2);

    var _pgs = _gp4.scale * 0.9;
    draw_sprite_ext(spr_glow_blob, 0, (_gp4.x - _rk_cx) * _rk_gx, (_gp4.y - _rk_cy) * _rk_gy, _pgs * 2.2, _pgs,
                    _gp4.ang, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  for (var _gi2 = 0; _gi2 < array_length(kunai_impacts); _gi2++) {
    var _im2 = kunai_impacts[_gi2];
    var _ia2 = _im2.life / _im2.max_life;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.18, 1, _im2.hot * _ia2), lerp(0.15, 0.95, _im2.hot * _ia2));
    shader_set_uniform_f(global.u_glow_intensity, _ia2 * _ia2 * (0.9 + _im2.hot));

    var _isc = (_im2.radius * 1.5) * _rk_gx / _rk_half;
    draw_sprite_ext(spr_glow_blob, 0, (_im2.x - _rk_cx) * _rk_gx, (_im2.y - _rk_cy) * _rk_gy, _isc, _isc * 0.5, 0,
                    c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  for (var _rfg = 0; _rfg < array_length(rain_floor_scars); _rfg++) {
    var _fsg = rain_floor_scars[_rfg];
    var _fsa = clamp(_fsg.life / _fsg.life_max, 0, 1) * _rk_clear;
    if (_fsa <= 0.01) continue;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.14, 0.7, _fsg.heat), lerp(0.1, 0.42, _fsg.heat));
    shader_set_uniform_f(global.u_glow_intensity, _fsa * _fsg.heat * 0.62);

    var _fsc = (_fsg.span * 0.9) * _rk_gx / _rk_half;
    draw_sprite_ext(spr_glow_blob, 0, (_fsg.x - _rk_cx) * _rk_gx, (_fsg.y - _rk_cy) * _rk_gy,
                    _fsc, _fsc * 0.18, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var _sg2 = 0; _sg2 < array_length(kunai_shards); _sg2++) {
    var _sh2 = kunai_shards[_sg2];
    var _sa2 = clamp(_sh2.life / _sh2.max_life, 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.1, 0.8, _sa2), lerp(0.08, 0.7, _sa2));
    shader_set_uniform_f(global.u_glow_intensity, _sa2 * 0.9);

    var _ssc = _sh2.scale * (0.5 + _sa2 * 0.5);
    draw_sprite_ext(spr_glow_blob, 0, (_sh2.x - _rk_cx) * _rk_gx, (_sh2.y - _rk_cy) * _rk_gy, _ssc, _ssc * 1.6, 0,
                    c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.3);

  for (var _ap2 = 0; _ap2 < array_length(kunai_absorb_pops); _ap2++) {
    var _pop2 = kunai_absorb_pops[_ap2];
    var _popa2 = _pop2.life / _pop2.max_life;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 1, _pop2.hot), lerp(0.26, 1, _pop2.hot));
    shader_set_uniform_f(global.u_glow_intensity, (1 - _popa2) * 1.4);

    var _psc2 = (18 + (1 - _popa2) * 26) * _rk_gx / _rk_half;
    draw_sprite_ext(spr_glow_blob, 0, (_pop2.x - _rk_cx) * _rk_gx, (_pop2.y - _rk_cy) * _rk_gy, _psc2, _psc2, 0,
                    c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (ring_spawn_flash_timer < ring_spawn_flash_duration) {
  var _fp = ring_spawn_flash_timer / ring_spawn_flash_duration;

  var gui_x =
      (arrow_ring_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var gui_y =
      (arrow_ring_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);

  var _uvs = sprite_get_uvs(spr_glow_blob, 0);

  var _outer_fade = 1 - _fp;
  var _outer_scale = (10 + _fp * arrow_ring_radius * 1.4) / 32;

  shader_set(shd_bullet_glow);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
  shader_set_uniform_f(global.u_glow_color, 1.0, 0.85, 0.75);
  shader_set_uniform_f(global.u_glow_intensity, _outer_fade * 1.6);
  shader_set_uniform_f(global.u_glow_falloff, 1.3);
  draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _outer_scale, _outer_scale, 0, c_white, 1);
  shader_reset();

  var _core_fade = clamp(1 - _fp * 3, 0, 1);
  if (_core_fade > 0) {
    var _core_scale = (30 * (1 - _fp)) / 32;

    shader_set(shd_bullet_glow);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_color, 1.0, 1.0, 0.95);
    shader_set_uniform_f(global.u_glow_intensity, _core_fade * 3.0);
    shader_set_uniform_f(global.u_glow_falloff, 0.8);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _core_scale, _core_scale, 0, c_white, 1);
    shader_reset();
  }

  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (qamb > 0.012) {
  var _sw_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _sw_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _sw_cx = oCameraController.current_cam_x;
  var _sw_cy = oCameraController.current_cam_y;

  var _sw_mult = fx_get_mult_for("quartercircles", "sweep");
  var _rim_mult = fx_get_mult_for("quartercircles", "rim");

  var _sw_bar = 0;

  if (instance_exists(oCameraController)) {
    _sw_bar = min(room_height * 0.34,
                  oCameraController.letterbox_amount * fx_get_mult("letterbox") *
                      oCameraController.current_cam_h * 0.11);
  }

  var _sw_xmin = 0;
  var _sw_xmax = room_width;
  var _sw_ymin = _sw_bar;
  var _sw_ymax = room_height - _sw_bar;

  var _sw_ox = 400;
  var _sw_oy = 304;

  var _sw_corners = [
    point_direction(_sw_ox, _sw_oy, _sw_xmax, _sw_ymin),
    point_direction(_sw_ox, _sw_oy, _sw_xmin, _sw_ymin),
    point_direction(_sw_ox, _sw_oy, _sw_xmin, _sw_ymax),
    point_direction(_sw_ox, _sw_oy, _sw_xmax, _sw_ymax)
  ];

  var _sw_cols = [ make_color_rgb(255, 46, 38), make_color_rgb(84, 166, 255) ];

  var _sw_a = qamb * (0.13 + qamb_hb * 0.11 + quarter_coil * 0.1 + quarter_beat_flash * 0.05) *
              _sw_mult;

  var _k_sw_steps = 12;
  var _k_sw_bands = 4;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_add);

  for (var _swg = 0; _swg < 2; _swg++) {
    var _sw_col = _sw_cols[_swg];
    var _sw_rin = max(8, qamb_rad[_swg] + 6);
    var _sw_lead_off = (qamb_spin[_swg] >= 0) ? 90 : 0;

    for (var _sws = 0; _sws < 2; _sws++) {
      var _sw_A = qamb_base[_swg] + _sws * 180;

      var _sw_offs = [];

      for (var _swk = 0; _swk <= _k_sw_steps; _swk++) {
        array_push(_sw_offs, _swk * (90 / _k_sw_steps));
      }

      for (var _swc = 0; _swc < 4; _swc++) {
        var _sw_co = ((_sw_corners[_swc] - _sw_A) mod 360 + 360) mod 360;
        if (_sw_co > 0.5 && _sw_co < 89.5) array_push(_sw_offs, _sw_co);
      }

      array_sort(_sw_offs, true);

      var _sw_n = array_length(_sw_offs);
      var _sw_dx = array_create(_sw_n, 0);
      var _sw_dy = array_create(_sw_n, 0);
      var _sw_d = array_create(_sw_n, 0);

      for (var _swi = 0; _swi < _sw_n; _swi++) {
        var _swa2 = _sw_A + _sw_offs[_swi];
        var _swdx = dcos(_swa2);
        var _swdy = -dsin(_swa2);
        var _swtx = 100000;
        var _swty = 100000;

        if (_swdx > 0.0001) _swtx = (_sw_xmax - _sw_ox) / _swdx;
        else if (_swdx < -0.0001) _swtx = (_sw_xmin - _sw_ox) / _swdx;

        if (_swdy > 0.0001) _swty = (_sw_ymax - _sw_oy) / _swdy;
        else if (_swdy < -0.0001) _swty = (_sw_ymin - _sw_oy) / _swdy;

        _sw_dx[_swi] = _swdx;
        _sw_dy[_swi] = _swdy;
        _sw_d[_swi] = max(_sw_rin + 1, min(_swtx, _swty));
      }

      for (var _swb = 0; _swb < _k_sw_bands; _swb++) {
        var _swu0 = _swb / _k_sw_bands;
        var _swu1 = (_swb + 1) / _k_sw_bands;
        var _swa0 = _sw_a * (0.5 + (1 - _swu0) * 0.5) * (1 - power(_swu0, 5) * 0.45);
        var _swa1 = _sw_a * (0.5 + (1 - _swu1) * 0.5) * (1 - power(_swu1, 5) * 0.45);

        draw_primitive_begin(pr_trianglestrip);

        for (var _swi = 0; _swi < _sw_n; _swi++) {
          var _swt = _sw_offs[_swi] / 90;
          var _sw_edge = clamp(min(_swt, 1 - _swt) * 7, 0.34, 1);

          var _swr0 = _sw_rin + (_sw_d[_swi] - _sw_rin) * _swu0;
          var _swr1 = _sw_rin + (_sw_d[_swi] - _sw_rin) * _swu1;

          draw_vertex_colour((_sw_ox + _sw_dx[_swi] * _swr0 - _sw_cx) * _sw_gx,
                             (_sw_oy + _sw_dy[_swi] * _swr0 - _sw_cy) * _sw_gy,
                             _sw_col, _swa0 * _sw_edge);
          draw_vertex_colour((_sw_ox + _sw_dx[_swi] * _swr1 - _sw_cx) * _sw_gx,
                             (_sw_oy + _sw_dy[_swi] * _swr1 - _sw_cy) * _sw_gy,
                             _sw_col, _swa1 * _sw_edge);
        }

        draw_primitive_end();
      }

      var _sw_la = _sw_A + _sw_lead_off;
      var _sw_ldx = dcos(_sw_la);
      var _sw_ldy = -dsin(_sw_la);
      var _sw_ltx = 100000;
      var _sw_lty = 100000;

      if (_sw_ldx > 0.0001) _sw_ltx = (_sw_xmax - _sw_ox) / _sw_ldx;
      else if (_sw_ldx < -0.0001) _sw_ltx = (_sw_xmin - _sw_ox) / _sw_ldx;

      if (_sw_ldy > 0.0001) _sw_lty = (_sw_ymax - _sw_oy) / _sw_ldy;
      else if (_sw_ldy < -0.0001) _sw_lty = (_sw_ymin - _sw_oy) / _sw_ldy;

      var _sw_ld = max(_sw_rin + 1, min(_sw_ltx, _sw_lty));

      var _sw_lnx = -_sw_ldy;
      var _sw_lny = _sw_ldx;
      var _k_sw_rsegs = 8;

      for (var _swl = 0; _swl < 2; _swl++) {
        var _sw_lhw = (_swl == 0) ? 4.5 : 1.25;
        var _sw_lamp = _sw_a * ((_swl == 0) ? 1.6 : 3.1);
        var _sw_lcol = (_swl == 0) ? _sw_col : merge_color(_sw_col, c_white, 0.45);

        draw_primitive_begin(pr_trianglestrip);

        for (var _swr = 0; _swr <= _k_sw_rsegs; _swr++) {
          var _swru = _swr / _k_sw_rsegs;
          var _swrr = _sw_rin + (_sw_ld - _sw_rin) * _swru;
          var _swra = min(1, _sw_lamp * power(sin(pi * _swru), 0.75));
          var _swrx = (_sw_ox + _sw_ldx * _swrr - _sw_cx) * _sw_gx;
          var _swry = (_sw_oy + _sw_ldy * _swrr - _sw_cy) * _sw_gy;

          draw_vertex_colour(_swrx - _sw_lnx * _sw_lhw, _swry - _sw_lny * _sw_lhw, _sw_lcol, _swra);
          draw_vertex_colour(_swrx + _sw_lnx * _sw_lhw, _swry + _sw_lny * _sw_lhw, _sw_lcol, _swra);
        }

        draw_primitive_end();
      }
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);

  var _sw_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _sw_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _sw_uvs[0], _sw_uvs[1], _sw_uvs[2], _sw_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  var _k_sw_tail = 5;

  for (var _swg = 0; _swg < 2; _swg++) {
    var _sw_rr = (_swg == 0) ? 1 : 0.35;
    var _sw_gg = (_swg == 0) ? 0.22 : 0.66;
    var _sw_bb = (_swg == 0) ? 0.18 : 1;
    var _sw_lead2 = (qamb_spin[_swg] >= 0) ? 90 : 0;

    for (var _sws = 0; _sws < 2; _sws++) {
      for (var _swt2 = 0; _swt2 < _k_sw_tail; _swt2++) {
        var _sw_ta = qamb_base[_swg] + _sws * 180 + _sw_lead2 - qamb_spin[_swg] * _swt2 * 2.4;
        var _sw_fade = 1 - (_swt2 / _k_sw_tail);
        var _sw_tdx = dcos(_sw_ta);
        var _sw_tdy = -dsin(_sw_ta);
        var _sw_ttx = 100000;
        var _sw_tty = 100000;

        if (_sw_tdx > 0.0001) _sw_ttx = (_sw_xmax - _sw_ox) / _sw_tdx;
        else if (_sw_tdx < -0.0001) _sw_ttx = (_sw_xmin - _sw_ox) / _sw_tdx;

        if (_sw_tdy > 0.0001) _sw_tty = (_sw_ymax - _sw_oy) / _sw_tdy;
        else if (_sw_tdy < -0.0001) _sw_tty = (_sw_ymin - _sw_oy) / _sw_tdy;

        var _sw_td = max(1, min(_sw_ttx, _sw_tty));
        var _sw_hx = _sw_ox + _sw_tdx * _sw_td;
        var _sw_hy = _sw_oy + _sw_tdy * _sw_td;
        var _sw_vert2 = (_sw_ttx <= _sw_tty);

        shader_set_uniform_f(global.u_glow_color, _sw_rr, _sw_gg, _sw_bb);
        shader_set_uniform_f(global.u_glow_intensity,
                             qamb * _sw_fade * _sw_fade * (0.5 + qamb_hb * 0.9) * _rim_mult);

        var _sw_bs = (26 + _sw_fade * 30) * _sw_gx / _sw_half;
        draw_sprite_ext(spr_glow_blob, 0, (_sw_hx - _sw_cx) * _sw_gx, (_sw_hy - _sw_cy) * _sw_gy,
                        _sw_vert2 ? (_sw_bs * 0.42) : _sw_bs,
                        _sw_vert2 ? _sw_bs : (_sw_bs * 0.42), 0, c_white, 1);
      }
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (array_length(quarter_craters) > 0 || array_length(quarter_stuck) > 0 ||
    array_length(quarter_tracers) > 0) {
  var _qg_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _qg_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _qg_cx = oCameraController.current_cam_x;
  var _qg_cy = oCameraController.current_cam_y;
  var _qg_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _qg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _qg_uvs[0], _qg_uvs[1], _qg_uvs[2], _qg_uvs[3]);

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  for (var _qgc = 0; _qgc < array_length(quarter_craters); _qgc++) {
    var _qgcr = quarter_craters[_qgc];
    var _qgca = _qgcr.life / _qgcr.max_life;
    var _qg_hot = _qgcr.hot * _qgca;

    if (_qgcr.cid == 0) {
      shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 1, _qg_hot), lerp(0.16, 0.95, _qg_hot));
    } else {
      shader_set_uniform_f(global.u_glow_color, lerp(0.3, 0.95, _qg_hot), lerp(0.62, 1, _qg_hot), 1);
    }

    shader_set_uniform_f(global.u_glow_intensity, _qgca * _qgca * (0.85 + _qgcr.hot));

    var _qgcs = (_qgcr.radius * 1.6) * _qg_gx / _qg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_qgcr.x - _qg_cx) * _qg_gx, (_qgcr.y - _qg_cy) * _qg_gy,
                    _qgcs, _qgcs * 0.5, _qgcr.edge, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var _qgs = 0; _qgs < array_length(quarter_stuck); _qgs++) {
    var _qgst = quarter_stuck[_qgs];
    var _qgsa = clamp(_qgst.life / _qgst.max_life, 0, 1);

    if (_qgst.cid == 0) {
      shader_set_uniform_f(global.u_glow_color, 1, lerp(0.1, 0.8, _qgsa), lerp(0.08, 0.7, _qgsa));
    } else {
      shader_set_uniform_f(global.u_glow_color, lerp(0.14, 0.8, _qgsa), lerp(0.44, 0.92, _qgsa), 1);
    }

    shader_set_uniform_f(global.u_glow_intensity, _qgsa * 0.85);

    var _qgss = (6 + _qgst.scale * 7) * (0.5 + _qgsa * 0.5) * _qg_gx / _qg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_qgst.x - _qg_cx) * _qg_gx, (_qgst.y - _qg_cy) * _qg_gy,
                    _qgss, _qgss, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var _qgt = 0; _qgt < array_length(quarter_tracers); _qgt++) {
    var _qgtr = quarter_tracers[_qgt];
    if (_qgtr.fired) continue;

    var _qgtp = clamp(1 - (_qgtr.life / max(_qgtr.max_life, 1)), 0, 1);
    var _qgti = _qgtp * _qgtp * (0.3 + qamb * 0.5);
    if (_qgti <= 0.02) continue;

    if (_qgtr.cid == 0) {
      shader_set_uniform_f(global.u_glow_color, 1, lerp(0.22, 0.85, _qgtp), lerp(0.2, 0.8, _qgtp));
    } else {
      shader_set_uniform_f(global.u_glow_color, lerp(0.3, 0.85, _qgtp), lerp(0.6, 0.92, _qgtp), 1);
    }

    shader_set_uniform_f(global.u_glow_intensity, _qgti);

    var _qgts = (6 + _qgtp * 13) * _qg_gx / _qg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_qgtr.lx - _qg_cx) * _qg_gx, (_qgtr.ly - _qg_cy) * _qg_gy,
                    _qgts, _qgts, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (lorb_amb > 0.012) {
  var _sf_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _sf_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _sf_cx = oCameraController.current_cam_x;
  var _sf_cy = oCameraController.current_cam_y;

  var _sf_mult = fx_get_mult_for("lightningorbs", "front");

  var _sf_bar = 0;

  if (instance_exists(oCameraController)) {
    _sf_bar = min(room_height * 0.34,
                  oCameraController.letterbox_amount * fx_get_mult("letterbox") *
                      oCameraController.current_cam_h * 0.11);
  }

  var _sf_ymin = _sf_bar;
  var _sf_ymax = room_height - _sf_bar;
  var _sf_h = max(8, _sf_ymax - _sf_ymin);

  var _sf_col = merge_color(global.lightning_color, c_white, 0.25 + lorb_countdown * 0.5);
  var _sf_hot = merge_color(_sf_col, c_white, 0.55);

  var _sf_a = lorb_amb * (0.105 + lorb_amb_hb * 0.115 + lorb_beat_flash * 0.06 +
                          lorb_amb_tick * 0.05) * _sf_mult;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_add);

  var _sf_air = _sf_a * (0.34 + lorb_amb_tick * 0.5);

  if (_sf_air > 0.002) {
    var _k_sf_rows = 6;

    for (var _sr = 0; _sr < _k_sf_rows; _sr++) {
      var _sv0 = _sr / _k_sf_rows;
      var _sv1 = (_sr + 1) / _k_sf_rows;
      var _sa0 = _sf_air * (power(1 - _sv0, 2.4) + power(_sv0, 3.4) * 0.75 + 0.06);
      var _sa1 = _sf_air * (power(1 - _sv1, 2.4) + power(_sv1, 3.4) * 0.75 + 0.06);

      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour((0 - _sf_cx) * _sf_gx, (_sf_ymin + _sf_h * _sv0 - _sf_cy) * _sf_gy, _sf_col, _sa0);
      draw_vertex_colour((0 - _sf_cx) * _sf_gx, (_sf_ymin + _sf_h * _sv1 - _sf_cy) * _sf_gy, _sf_col, _sa1);
      draw_vertex_colour((room_width - _sf_cx) * _sf_gx, (_sf_ymin + _sf_h * _sv0 - _sf_cy) * _sf_gy, _sf_col, _sa0);
      draw_vertex_colour((room_width - _sf_cx) * _sf_gx, (_sf_ymin + _sf_h * _sv1 - _sf_cy) * _sf_gy, _sf_col, _sa1);
      draw_primitive_end();
    }
  }

  var _sf_n = lorb_front_n;
  var _sf_wx = [ lorb_front_a, lorb_front_b ];
  var _sf_wd = [ lorb_front_dir, -1 ];
  var _sf_spd = lorb_front_speed;
  var _sf_parked = false;

  if (_sf_n <= 0 && lorb_countdown > 0.01 && t < _k_lorb_start_t) {
    var _sf_origin = lorb_front_at(_k_lorb_beats[0]);

    _sf_n = 1;
    _sf_wx[0] = _sf_origin.a;
    _sf_wd[0] = _sf_origin.dir;
    _sf_spd = 0;
    _sf_parked = true;
  }

  for (var _sw = 0; _sw < _sf_n; _sw++) {
    var _sx0 = _sf_wx[_sw];
    var _sdir = (_sf_n > 1) ? ((_sw == 0) ? 1 : -1) : _sf_wd[0];

    var _slead = 34 + _sf_spd * 1.5 + (_sf_parked ? lorb_countdown * 40 : 0);
    var _strail = 90 + _sf_spd * 4.2;

    if (_sf_parked) _strail = 26;

    var _swa = _sf_a * (_sf_parked ? (0.45 + lorb_countdown * 0.75) : 1);

    var _k_sf_hs = 14;
    var _k_sf_vs = 5;

    for (var _sb = 0; _sb < _k_sf_vs; _sb++) {
      var _sv0b = _sb / _k_sf_vs;
      var _sv1b = (_sb + 1) / _k_sf_vs;
      var _sy0 = _sf_ymin + _sf_h * _sv0b;
      var _sy1 = _sf_ymin + _sf_h * _sv1b;
      var _svp0 = 0.34 + power(1 - _sv0b, 2.2) * 0.66 + power(_sv0b, 3) * 0.46;
      var _svp1 = 0.34 + power(1 - _sv1b, 2.2) * 0.66 + power(_sv1b, 3) * 0.46;

      draw_primitive_begin(pr_trianglestrip);

      for (var _sh2 = 0; _sh2 <= _k_sf_hs; _sh2++) {
        var _su = -1 + 2 * (_sh2 / _k_sf_hs);
        var _sxp = (_su >= 0) ? (_sx0 + _slead * _su * _sdir)
                              : (_sx0 + _strail * _su * _sdir);

        var _sp = (_su >= 0) ? power(1 - _su, 2.3)
                             : power(1 + _su, 1.15) * 0.72;

        var _sxg = (_sxp - _sf_cx) * _sf_gx;

        draw_vertex_colour(_sxg, (_sy0 - _sf_cy) * _sf_gy, _sf_col, _swa * _sp * _svp0);
        draw_vertex_colour(_sxg, (_sy1 - _sf_cy) * _sf_gy, _sf_col, _swa * _sp * _svp1);
      }

      draw_primitive_end();
    }

    var _k_sf_rs = 9;

    for (var _sl = 0; _sl < 2; _sl++) {
      var _slhw = ((_sl == 0) ? 5.5 : 1.4) * _sf_gx;
      var _slamp = _swa * ((_sl == 0) ? 1.5 : 3.2);
      var _slcol = (_sl == 0) ? _sf_col : _sf_hot;
      var _slx = (_sx0 - _sf_cx) * _sf_gx;

      draw_primitive_begin(pr_trianglestrip);

      for (var _sr2 = 0; _sr2 <= _k_sf_rs; _sr2++) {
        var _sru = _sr2 / _k_sf_rs;
        var _sry = (_sf_ymin + _sf_h * _sru - _sf_cy) * _sf_gy;
        var _sra = min(1, _slamp * power(sin(pi * _sru), 0.6));

        draw_vertex_colour(_slx - _slhw, _sry, _slcol, _sra);
        draw_vertex_colour(_slx + _slhw, _sry, _slcol, _sra);
      }

      draw_primitive_end();
    }
  }

  draw_set_alpha(1);
  draw_set_color(c_white);

  var _sf_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _sf_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _sf_uvs[0], _sf_uvs[1], _sf_uvs[2], _sf_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  var _sf_r = color_get_red(_sf_col) / 255;
  var _sf_g = color_get_green(_sf_col) / 255;
  var _sf_b = color_get_blue(_sf_col) / 255;

  var _k_sf_tail = 6;

  for (var _sw2 = 0; _sw2 < _sf_n; _sw2++) {
    for (var _st = 0; _st < _k_sf_tail; _st++) {
      var _stf = _sf_parked ? _k_lorb_beats[0] : (t - _st * 1.6);
      var _stfr = lorb_front_at(_stf);
      if (_stfr.n <= 0 && !_sf_parked) continue;

      var _stx = (_sw2 == 0) ? _stfr.a : _stfr.b;
      if (!_sf_parked && abs(_stx - ((_sw2 == 0) ? lorb_front_a : lorb_front_b)) > 260) continue;

      var _stfade = 1 - (_st / _k_sf_tail);
      var _stgx = (_stx - _sf_cx) * _sf_gx;

      shader_set_uniform_f(global.u_glow_color, _sf_r, _sf_g, _sf_b);
      shader_set_uniform_f(global.u_glow_intensity,
                           lorb_amb * _stfade * _stfade * (0.55 + lorb_amb_hb * 0.9) * _sf_mult);

      var _stbs = (30 + _stfade * 34) * _sf_gx / _sf_half;
      draw_sprite_ext(spr_glow_blob, 0, _stgx, (_k_lorb_floor_y - _sf_cy) * _sf_gy,
                      _stbs, _stbs * 0.4, 0, c_white, 1);
    }

    var _sf_ahead = _sf_parked ? lorb_front_at(_k_lorb_beats[0]) : lorb_front_at(t + 4);

    if (!_sf_parked && _sf_ahead.beat != lorb_front_beat) _sf_ahead = lorb_front_at(t);

    if (_sf_ahead.n > 0 || _sf_parked) {
      var _sfax = (_sw2 == 0) ? _sf_ahead.a : _sf_ahead.b;

      shader_set_uniform_f(global.u_glow_color, _sf_r, min(1, _sf_g + 0.15), min(1, _sf_b + 0.15));
      shader_set_uniform_f(global.u_glow_intensity,
                           lorb_amb * (0.7 + lorb_amb_hb * 1.1 + lorb_beat_flash * 0.4) * _sf_mult);

      var _sfabs = (40 + lorb_countdown * 34) * _sf_gx / _sf_half;
      draw_sprite_ext(spr_glow_blob, 0, (_sfax - _sf_cx) * _sf_gx, (_sf_ymin - _sf_cy) * _sf_gy,
                      _sfabs, _sfabs * 0.46, 0, c_white, 1);
    }
  }

  // --- bloom on the streak itself ------------------------------------------
  if (lorb_front_live) {
    var _cg_trail = lorb_trail_frames(lorb_front_speed);
    var _cg_hot = clamp(0.5 + lorb_countdown * 0.4 + lorb_beat_flash * 0.4 +
                        lorb_lead_flash * 0.5, 0, 1.6);

    shader_set_uniform_f(global.u_glow_falloff, 1.8);

    for (var _cgi = 0; _cgi < lorb_front_n; _cgi++) {
      var _cgp = lorb_path_points(t - _cg_trail, t, _cgi, 0.55,
                                  _k_lorb_fray * 0.5, t * 1.7 + _cgi * 31);
      var _cgn = array_length(_cgp);
      if (_cgn < 2) continue;

      shader_set_uniform_f(global.u_glow_color, _sf_r, _sf_g, _sf_b);

      for (var _cgs = 0; _cgs < _cgn; _cgs++) {
        var _cgu = _cgp[_cgs].u;

        shader_set_uniform_f(global.u_glow_intensity,
                             (0.22 + _cg_hot * 0.5) * power(_cgu, 1.6) * _sf_mult);

        var _cgsc = (9 + _cgu * (16 + _cg_hot * 12)) * _sf_gx / _sf_half;
        draw_sprite_ext(spr_glow_blob, 0, (_cgp[_cgs].px - _sf_cx) * _sf_gx,
                        (_cgp[_cgs].py - _sf_cy) * _sf_gy, _cgsc, _cgsc, 0, c_white, 1);
      }

      var _cghx = (_cgp[_cgn - 1].px - _sf_cx) * _sf_gx;
      var _cghy = (_cgp[_cgn - 1].py - _sf_cy) * _sf_gy;

      shader_set_uniform_f(global.u_glow_intensity, (0.4 + _cg_hot * 0.6) * _sf_mult);
      var _cgwash = (34 + _cg_hot * 26) * _sf_gx / _sf_half;
      draw_sprite_ext(spr_glow_blob, 0, _cghx, _cghy, _cgwash, _cgwash, 0, c_white, 1);

      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, (0.5 + _cg_hot * 0.75) * _sf_mult);
      shader_set_uniform_f(global.u_glow_falloff, 1.3);
      var _cgcore = (7 + _cg_hot * 9) * _sf_gx / _sf_half;
      draw_sprite_ext(spr_glow_blob, 0, _cghx, _cghy, _cgcore, _cgcore, 0, c_white, 1);
      shader_set_uniform_f(global.u_glow_falloff, 1.8);
    }
  }

  for (var _wgi75 = 0; _wgi75 < array_length(lorb_wall_hits); _wgi75++) {
    var _wg75 = lorb_wall_hits[_wgi75];
    var _wg75a = power(_wg75.life / _wg75.life_max, 1.3);
    if (_wg75a <= 0.02) continue;

    shader_set_uniform_f(global.u_glow_color, _sf_r, _sf_g, _sf_b);
    shader_set_uniform_f(global.u_glow_intensity, _wg75a * (0.6 + _wg75.hot * 0.7) * _sf_mult);
    shader_set_uniform_f(global.u_glow_falloff, 1.9);

    var _wg75sc = (30 + _wg75.radius * 0.55) * _sf_gx / _sf_half;
    draw_sprite_ext(spr_glow_blob, 0, (_wg75.x - _sf_cx) * _sf_gx, (_wg75.y - _sf_cy) * _sf_gy,
                    _wg75sc * 0.55, _wg75sc * 1.5, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

var _fx_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
var _fx_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
var _fx_cx = oCameraController.current_cam_x;
var _fx_cy = oCameraController.current_cam_y;
var _fx_half = sprite_get_width(spr_glow_blob) * 0.5;

if (quarter_telegraph_active || quarter_core_charge > 0.01 || array_length(quarter_circles) > 0 ||
    stamp_rail > 0.02 || lorb_storm > 0.01 ||
    lorb_seam > 0.01 || array_length(lorb_floor_hits) > 0 || array_length(lorb_scorch) > 0 ||
    lorb_readout > 0.02) {
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _fx_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _fx_uvs[0], _fx_uvs[1], _fx_uvs[2], _fx_uvs[3]);

  if (quarter_telegraph_active) {
    var _tele_t = clamp(quarter_telegraph_timer / _k_quarter_telegraph_duration, 0, 1);
    var _tele_pulse = 0.55 + 0.45 * sin(quarter_telegraph_timer * 1.9);
    var _tele_a = _tele_pulse * (0.4 + 0.6 * _tele_t);

    var _tcx = (400 - _fx_cx) * _fx_gx;
    var _tcy = (304 - _fx_cy) * _fx_gy;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.15, 0.95, _tele_t), lerp(0.15, 0.95, _tele_t));
    shader_set_uniform_f(global.u_glow_intensity, 0.8 + _tele_a * 1.6);
    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    var _tsc = (30 + _tele_t * 60) * _fx_gx / _fx_half;
    draw_sprite_ext(spr_glow_blob, 0, _tcx, _tcy, _tsc, _tsc, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _tele_a * 2.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    var _tsc2 = (6 + _tele_t * 16) * _fx_gx / _fx_half;
    draw_sprite_ext(spr_glow_blob, 0, _tcx, _tcy, _tsc2, _tsc2, 0, c_white, 1);

    var _tlead = 1 - _tele_t;
    var _t_radii = [ 140, 70 ];
    shader_set_uniform_f(global.u_glow_falloff, 2.0);

    for (var _tr2 = 0; _tr2 < 2; _tr2++) {
      var _trr = _t_radii[_tr2] * (1 + _tlead * 0.5);
      if (_tr2 == 0) {
        shader_set_uniform_f(global.u_glow_color, 1, 0.2, 0.2);
      } else {
        shader_set_uniform_f(global.u_glow_color, 0.45, 0.75, 1);
      }
      shader_set_uniform_f(global.u_glow_intensity, _tele_a * 0.9);

      var _t_scale = (4 + _tele_t * 6) * _fx_gx / _fx_half;
      for (var _ts = 0; _ts < 2; _ts++) {
        for (var _tk = 0; _tk <= 9; _tk++) {
          var _taa = (_ts * 180) + (_tk / 9) * 90;
          var _tpx = 400 + lengthdir_x(_trr, _taa);
          var _tpy = 304 + lengthdir_y(_trr, _taa);
          draw_sprite_ext(spr_glow_blob, 0, (_tpx - _fx_cx) * _fx_gx, (_tpy - _fx_cy) * _fx_gy, _t_scale, _t_scale,
                          0, c_white, 1);
        }
      }
    }
  }

  if (quarter_core_charge > 0.01) {
    var _qch = quarter_core_charge + quarter_coil * 0.8 + quarter_lock_flash;
    var _qcol_mix = clamp(_qch, 0, 1);
    var _qcx = (400 - _fx_cx) * _fx_gx;
    var _qcy = (304 - _fx_cy) * _fx_gy;

    var _qwash = (34 + _qch * 80) * _fx_gx / _fx_half;
    shader_set_uniform_f(global.u_glow_color, 1, 0.22, 0.18);
    shader_set_uniform_f(global.u_glow_intensity, 0.4 + _qch * 0.7);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    draw_sprite_ext(spr_glow_blob, 0, _qcx, _qcy, _qwash, _qwash, 0, c_white, 1);

    var _qmid = (12 + _qch * 30) * _fx_gx / _fx_half;
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 0.9, _qcol_mix), lerp(0.25, 0.85, _qcol_mix));
    shader_set_uniform_f(global.u_glow_intensity, 0.9 + _qch * 0.9);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    draw_sprite_ext(spr_glow_blob, 0, _qcx, _qcy, _qmid, _qmid, 0, c_white, 1);

    var _qhot = (4 + _qch * 12) * _fx_gx / _fx_half;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.2 + _qch);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    draw_sprite_ext(spr_glow_blob, 0, _qcx, _qcy, _qhot, _qhot, 0, c_white, 1);
  }

  if (stamp_rail > 0.02) {
    var _sk_g_a = clamp(stamp_rail, 0, 1);
    var _sk_g_dead = stamp_dead ? clamp(stamp_blowout, 0, 1) : 1;

    if (stamp_safe_glow > 0.02) {
      var _rg = clamp(stamp_safe_glow, 0, 1) * _sk_g_a * _sk_g_dead;
      var _rseal = clamp(stamp_safe_seal, 0, 1);

      shader_set_uniform_f(global.u_glow_color, 0.28, 0.84, 1);
      shader_set_uniform_f(global.u_glow_intensity,
                           _rg * (1.1 + stamp_hb * 0.35 + _rseal * 0.9));
      shader_set_uniform_f(global.u_glow_falloff, 2.2);

      var _rgy = (_k_stamp_floor_y - 14 - _fx_cy) * _fx_gy;
      var _rgw = _k_stamp_safe_x1 - _k_stamp_safe_x0;
      var _rgn = 4;
      var _rgsc = (_rgw / _rgn * 1.5) * _fx_gx / _fx_half;

      for (var _rgi = 0; _rgi < _rgn; _rgi++) {
        var _rgx = _k_stamp_safe_x0 + (_rgi + 0.5) * (_rgw / _rgn);
        draw_sprite_ext(spr_glow_blob, 0, (_rgx - _fx_cx) * _fx_gx, _rgy,
                        _rgsc, _rgsc * 0.5, 0, c_white, 1);
      }

      shader_set_uniform_f(global.u_glow_falloff, 1.9);
      for (var _rw = 0; _rw < 2; _rw++) {
        var _rwx = (_rw == 0) ? _k_stamp_safe_x0 : _k_stamp_safe_x1;
        var _rbr = 1 - clamp(abs(stamp_face[_rw] - _rwx) / 180, 0, 1);

        shader_set_uniform_f(global.u_glow_intensity,
                             _rg * (0.5 + _rbr * 1.1 + _rseal * 0.6));
        var _rwsc = (11 + _rbr * 13) * _fx_gx / _fx_half;

        for (var _rn = 0; _rn <= 7; _rn++) {
          var _rny = _k_stamp_ceil_y + (_rn / 7) * (_k_stamp_floor_y - _k_stamp_ceil_y);
          draw_sprite_ext(spr_glow_blob, 0, (_rwx - _fx_cx) * _fx_gx,
                          (_rny - _fx_cy) * _fx_gy, _rwsc, _rwsc, 0, c_white, 1);
        }
      }
    }

    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    for (var _pgi = 0; _pgi < 2; _pgi++) {
      var _pgh = clamp(max(stamp_face_heat[_pgi], stamp_face_flash[_pgi]), 0, 1);
      if (_pgh <= 0.03) continue;

      shader_set_uniform_f(global.u_glow_color, 1,
                           0.46 + stamp_face_flash[_pgi] * 0.4,
                           0.24 + stamp_face_flash[_pgi] * 0.5);
      shader_set_uniform_f(global.u_glow_intensity,
                           (0.5 + _pgh * 1.5) * _sk_g_a * _sk_g_dead);

      var _pgx = (stamp_face[_pgi] - _fx_cx) * _fx_gx;
      var _pgsc = (13 + stamp_face_flash[_pgi] * 22) * _fx_gx / _fx_half;

      for (var _pgn = 0; _pgn <= 7; _pgn++) {
        var _pgy = _k_stamp_ceil_y + (_pgn / 7) * (_k_stamp_floor_y - _k_stamp_ceil_y);
        draw_sprite_ext(spr_glow_blob, 0, _pgx, (_pgy - _fx_cy) * _fx_gy,
                        _pgsc, _pgsc, 0, c_white, 1);
      }
    }

    if (stamp_armed && !stamp_dead && stamp_readout > 0.02) {
      shader_set_uniform_f(global.u_glow_color, 1, 0.34, 0.32);
      shader_set_uniform_f(global.u_glow_falloff, 2.1);

      for (var _tgi = 0; _tgi < 2; _tgi++) {
        var _tgt = stamp_face_target[_tgi];
        if (abs(_tgt - stamp_face[_tgi]) < 1) continue;

        shader_set_uniform_f(global.u_glow_intensity,
                             (0.3 + stamp_coil * 0.75) * _sk_g_a
                             * clamp(stamp_readout, 0, 1));

        var _tgx = (_tgt - _fx_cx) * _fx_gx;
        var _tgsc = (8 + stamp_coil * 12) * _fx_gx / _fx_half;

        for (var _tgn = 0; _tgn <= 6; _tgn++) {
          var _tgy = _k_stamp_ceil_y + (_tgn / 6) * (_k_stamp_floor_y - _k_stamp_ceil_y);
          draw_sprite_ext(spr_glow_blob, 0, _tgx, (_tgy - _fx_cy) * _fx_gy,
                          _tgsc, _tgsc, 0, c_white, 1);
        }
      }
    }

    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    for (var _ogi = 0; _ogi < array_length(stamp_orbs); _ogi++) {
      var _og = stamp_orbs[_ogi];
      if (_og.crushed) continue;
      if (_og.spawn < 1) continue;

      var _ogh = clamp(max(_og.flare, _og.pulse * 0.6), 0, 1);
      if (_ogh <= 0.06) continue;

      shader_set_uniform_f(global.u_glow_color, 1, 0.42 + _og.flare * 0.4,
                           0.2 + _og.flare * 0.45);
      shader_set_uniform_f(global.u_glow_intensity, _ogh * 1.2 * _sk_g_a * _sk_g_dead);

      var _ogsc = (_k_stamp_orb_r * 2.4 + _ogh * 10) * _fx_gx / _fx_half;
      draw_sprite_ext(spr_glow_blob, 0, (_og.x - _fx_cx) * _fx_gx,
                      (_og.y - _fx_cy) * _fx_gy, _ogsc, _ogsc, 0, c_white, 1);
    }
  }

  var _lr = color_get_red(global.lightning_color) / 255;
  var _lg = color_get_green(global.lightning_color) / 255;
  var _lb = color_get_blue(global.lightning_color) / 255;

  if (lorb_storm > 0.01) {
    shader_set_uniform_f(global.u_glow_color, _lr, _lg, _lb);
    shader_set_uniform_f(global.u_glow_intensity, lorb_storm * (0.5 + lorb_beat_flash * 0.7));
    shader_set_uniform_f(global.u_glow_falloff, 2.2);

    var _lo_scale = (26 + lorb_storm * 40) * _fx_gx / _fx_half;
    for (var _ls = 0; _ls <= 16; _ls++) {
      var _lsx = (_ls / 16) * room_width;
      draw_sprite_ext(spr_glow_blob, 0, (_lsx - _fx_cx) * _fx_gx, (2 - _fx_cy) * _fx_gy, _lo_scale, _lo_scale * 0.5,
                      0, c_white, 1);
    }
  }

  if (lorb_seam > 0.01) {
    shader_set_uniform_f(global.u_glow_color, _lr, _lg, _lb);
    shader_set_uniform_f(global.u_glow_intensity, clamp(lorb_seam, 0, 1.4) * 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);

    var _sm_scale = (16 + lorb_seam * 26 + lorb_seam_flash * 50) * _fx_gx / _fx_half;
    for (var _sm = 0; _sm <= 14; _sm++) {
      var _smy = (_sm / 14) * (250 + lorb_seam_flash * 240);
      draw_sprite_ext(spr_glow_blob, 0, (400 - _fx_cx) * _fx_gx, (_smy - _fx_cy) * _fx_gy, _sm_scale * 0.6, _sm_scale,
                      0, c_white, 1);
    }
  }

  if (array_length(lorb_floor_hits) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.4);

    for (var _fi = 0; _fi < array_length(lorb_floor_hits); _fi++) {
      var _fh2 = lorb_floor_hits[_fi];
      var _fa2 = _fh2.life / _fh2.max_life;

      shader_set_uniform_f(global.u_glow_color, _lr, lerp(_lg, 1, _fh2.hot), lerp(_lb, 1, _fh2.hot));
      shader_set_uniform_f(global.u_glow_intensity, _fa2 * _fa2 * (1.1 + _fh2.hot * 0.8));

      var _fsc = (_fh2.radius * 1.7) * _fx_gx / _fx_half;
      draw_sprite_ext(spr_glow_blob, 0, (_fh2.x - _fx_cx) * _fx_gx, (_fh2.y - _fx_cy) * _fx_gy, _fsc, _fsc * 0.42, 0,
                      c_white, 1);
    }
  }

  if (array_length(lorb_scorch) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.9);

    for (var _sgi = 0; _sgi < array_length(lorb_scorch); _sgi++) {
      var _sg = lorb_scorch[_sgi];
      var _sga = clamp(_sg.alpha, 0, 1);
      if (_sga <= 0.02) continue;

      shader_set_uniform_f(global.u_glow_color, _lr, lerp(_lg, 1, _sg.hot * _sga),
                           lerp(_lb, 0.9, _sg.hot * _sga));
      shader_set_uniform_f(global.u_glow_intensity, _sga * _sga * 0.8);

      var _sgs = (_sg.w * 1.5) * _fx_gx / _fx_half;
      draw_sprite_ext(spr_glow_blob, 0, (_sg.x - _fx_cx) * _fx_gx, (_k_lorb_floor_y - _fx_cy) * _fx_gy,
                      _sgs, _sgs * 0.22, 0, c_white, 1);
    }
  }

  if (lorb_readout > 0.02 && array_length(lorb_columns) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.8);

    for (var _cgi = 0; _cgi < array_length(lorb_columns); _cgi++) {
      var _cg = lorb_columns[_cgi];
      if (_cg.landed) continue;

      var _cgf = power(clamp((t - _cg.spawn_t) / max(_cg.fall, 1), 0, 1), 2.2);
      var _cgi2 = _cgf * lorb_readout * (0.35 + lorb_amb * 0.55);
      if (_cgi2 <= 0.02) continue;

      shader_set_uniform_f(global.u_glow_color, _lr, lerp(_lg, 0.92, _cgf), lerp(_lb, 0.88, _cgf));
      shader_set_uniform_f(global.u_glow_intensity, _cgi2);

      var _cgs = (10 + _cgf * 20) * _fx_gx / _fx_half;
      draw_sprite_ext(spr_glow_blob, 0,
                      (clamp(_cg.sx, _k_lorb_pad, room_width - _k_lorb_pad) - _fx_cx) * _fx_gx,
                      (_k_lorb_floor_y - _fx_cy) * _fx_gy, _cgs, _cgs * 0.5, 0, c_white, 1);
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

with(oRedOrbQuarterCircles) {
  var gui_x = (x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var gui_y = (y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

  var _flash_frac = 1 - (color_get_green(image_blend) / 255);

  var _r, _g, _b;

  if (circle_id == 0) {
    _r = 1.0;
    _g = lerp(0.10, 0.90, _flash_frac);
    _b = lerp(0.10, 0.90, _flash_frac);
  } else {
    _r = lerp(0.28, 0.92, _flash_frac);
    _g = lerp(0.84, 0.97, _flash_frac);
    _b = 1.0;
  }

  shader_set_uniform_f(global.u_glow_color, _r, _g, _b);

  var _qm_spd = point_distance(xprevious, yprevious, x, y);
  var _qm_dir = (_qm_spd > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
  var _qm_stretch = 1 + clamp(_qm_spd / 9, 0, 1) * 2.4;

  shader_set_uniform_f(global.u_glow_intensity, 0.7 + 0.25 * _size);
  shader_set_uniform_f(global.u_glow_falloff, 1.4);
  var _glow_scale = 1.5 + 0.2 * _size;
  draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale * _qm_stretch, _glow_scale, _qm_dir, c_white, 1);

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, 0.5 + 0.9 * _flash_frac);
  shader_set_uniform_f(global.u_glow_falloff, 2.2);
  draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale * 0.4, _glow_scale * 0.4, 0, c_white, 1);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);

  if (_qm_spd > 4) {
    var _qf_tail = min(_qm_spd * 2.0, 44);
    var _qf_x = gui_x - lengthdir_x(_qf_tail, _qm_dir);
    var _qf_y = gui_y - lengthdir_y(_qf_tail, _qm_dir);
    var _qf_perp = _qm_dir + 90;
    var _qf_off = 2.5;

    gpu_set_blendmode(bm_add);
    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(0.35 * image_alpha);
    draw_line_width(_qf_x + lengthdir_x(_qf_off, _qf_perp), _qf_y + lengthdir_y(_qf_off, _qf_perp),
                    gui_x + lengthdir_x(_qf_off, _qf_perp), gui_y + lengthdir_y(_qf_off, _qf_perp), 4);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_qf_x - lengthdir_x(_qf_off, _qf_perp), _qf_y - lengthdir_y(_qf_off, _qf_perp),
                    gui_x - lengthdir_x(_qf_off, _qf_perp), gui_y - lengthdir_y(_qf_off, _qf_perp), 4);
    draw_set_color(c_white);
    draw_set_alpha(0.7 * image_alpha);
    draw_line_width(_qf_x, _qf_y, gui_x, gui_y, 2);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
  }
}
scr_draw_avoidance_burst_ring_orb_glow();

scr_draw_avoidance_ring_orb_fake_glow();

if (array_length(quarter_circles) > 0) {
  var _anchor_flash = 0;

  for (var qi = 0; qi < array_length(quarter_circles); ++qi) {
    var qc = quarter_circles[qi];
    var _f = (qc.beat_timer > 0) ? (qc.beat_timer / qc.beat_duration) : 0;
    _anchor_flash = max(_anchor_flash, _f);
  }

  var qc0 = quarter_circles[0];
  var gui_x = (qc0.cx - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var gui_y = (qc0.cy - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
  shader_set_uniform_f(global.u_glow_color, 1.0, lerp(0.3, 0.95, _anchor_flash), lerp(0.3, 0.95, _anchor_flash));
  shader_set_uniform_f(global.u_glow_intensity, lerp(0.5, 1.4, _anchor_flash));
  shader_set_uniform_f(global.u_glow_falloff, 1.6);
  draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, lerp(0.3, 0.5, _anchor_flash), lerp(0.3, 0.5, _anchor_flash), 0, c_white, 1);
  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (kdash_rift > 0.01 || instance_number(oRedKunaiDash) > 0 ||
    array_length(kdash_impacts) > 0 || array_length(kdash_ghosts) > 0 ||
    array_length(kdash_slashes) > 0 || array_length(kdash_shards) > 0 ||
    array_length(kdash_lanes) > 0 || array_length(kdash_sockets) > 0 ||
    array_length(kdash_scars) > 0) {

  var _kdg_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _kdg_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _kdg_cx = oCameraController.current_cam_x;
  var _kdg_cy = oCameraController.current_cam_y;
  var _kdg_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _kdg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _kdg_uvs[0], _kdg_uvs[1], _kdg_uvs[2], _kdg_uvs[3]);

  if (kdash_rift > 0.01) {
    var _kr2 = clamp(kdash_rift, 0, 1.6);
    var _kr_hx = lerp(kdash_rift_x_prev, kdash_rift_x, kdash_rift_slide);

    shader_set_uniform_f(global.u_glow_color, 1, 0.16, 0.14);
    shader_set_uniform_f(global.u_glow_intensity, _kr2 * kdash_rift_wash_intensity);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    var _kr_w = room_width * 0.62 * _kdg_gx / _kdg_half;
    var _kr_h = (26 + _kr2 * 22) * _kdg_gy / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (room_width * 0.5 - _kdg_cx) * _kdg_gx, (2 - _kdg_cy) * _kdg_gy,
                    _kr_w, _kr_h, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 0.9, clamp(_kr2 - 0.5, 0, 1)),
                         lerp(0.18, 0.85, clamp(_kr2 - 0.5, 0, 1)));
    shader_set_uniform_f(global.u_glow_intensity, _kr2 * kdash_rift_mouth_intensity);
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    var _krm_w = (_k_kdash_rift_width * 0.9) * _kdg_gx / _kdg_half;
    var _krm_h = (18 + _kr2 * 26) * _kdg_gy / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_kr_hx - _kdg_cx) * _kdg_gx, (4 - _kdg_cy) * _kdg_gy,
                    _krm_w, _krm_h, 0, c_white, 1);
  }

  for (var _socg = 0; _socg < array_length(kdash_sockets); _socg++) {
    var _soc2 = kdash_sockets[_socg];
    var _soa2 = clamp(_soc2.life / max(_soc2.life_max, 1), 0, 1);
    var _spulse2 = 0.65 + 0.35 * sin(_soc2.seed + t * 0.48);
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.16, 0.82, _soc2.hot), lerp(0.12, 0.55, _soc2.hot));
    shader_set_uniform_f(global.u_glow_intensity, _soa2 * _spulse2 * (0.35 + _soc2.charge * 0.72));
    shader_set_uniform_f(global.u_glow_falloff, 1.45);
    draw_sprite_ext(spr_glow_blob, 0,
                    (_soc2.x - _kdg_cx) * _kdg_gx,
                    (_k_kdash_socket_y + 12 - _kdg_cy) * _kdg_gy,
                    (18 + _soc2.charge * 18) * _kdg_gx / _kdg_half,
                    (11 + _soc2.charge * 18) * _kdg_gy / _kdg_half,
                    0, c_white, 1);
  }

  for (var _lng = 0; _lng < array_length(kdash_lanes); _lng++) {
    var _ln2 = kdash_lanes[_lng];
    var _lp2 = 1 - (_ln2.life / max(_ln2.life_max, 1));
    var _lha2 = clamp(_ln2.life / max(_ln2.life_max, 1), 0, 1);
    var _lh2 = variable_struct_exists(_ln2, "hot") ? _ln2.hot : 0.55;
    var _ls2 = variable_struct_exists(_ln2, "seed") ? _ln2.seed : 0;
    var _reach2 = lerp(_ln2.y0 + 40, _ln2.y1, _lp2);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 0.9, _lh2), lerp(0.16, 0.7, _lh2));
    shader_set_uniform_f(global.u_glow_intensity, _lha2 * (0.28 + _lp2 * 0.72));
    shader_set_uniform_f(global.u_glow_falloff, 1.7);

    for (var _pk2 = 0; _pk2 < 3; _pk2++) {
      var _pu2 = frac(t * (0.052 + _lp2 * 0.03) + _ls2 * 0.001 + _pk2 * 0.34);
      var _py2 = lerp(_ln2.y0 + 8, _reach2, _pu2);
      var _sc2 = (5 + _lh2 * 8 + _pu2 * 5) * _kdg_gx / _kdg_half;
      draw_sprite_ext(spr_glow_blob, 0,
                      (_ln2.x - _kdg_cx) * _kdg_gx,
                      (_py2 - _kdg_cy) * _kdg_gy,
                      _sc2 * 1.6, _sc2 * 0.62, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  with (oRedKunaiDash) {
    if (image_alpha <= 0.05) continue;

    var _kb_t = clamp((speed - 8) / 26, 0, 1);
    var _kb_heat = clamp(max(_kb_t, hot) + telegraph_pulse * 0.6, 0, 1.3);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 0.95, _kb_heat), lerp(0.26, 0.9, _kb_heat));
    shader_set_uniform_f(global.u_glow_intensity, lerp(other.kdash_blade_glow_min, other.kdash_blade_glow_max, _kb_heat) * image_alpha);

    var _kb_w = (12 + _kb_heat * 10) * _kdg_gx / _kdg_half;
    var _kb_h = (14 + _kb_heat * 40) * _kdg_gy / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (x - _kdg_cx) * _kdg_gx, (y - _kdg_cy) * _kdg_gy,
                    _kb_w, _kb_h, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  for (var _gg = 0; _gg < array_length(kdash_ghosts); _gg++) {
    var _ghg = kdash_ghosts[_gg];
    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.2, 1, _ghg.hot), lerp(0.18, 1, _ghg.hot));
    shader_set_uniform_f(global.u_glow_intensity, _ghg.alpha * kdash_ghost_glow_intensity);

    var _gg_w = 11 * _kdg_gx / _kdg_half;
    var _gg_h = 30 * _kdg_gy / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_ghg.x - _kdg_cx) * _kdg_gx, (_ghg.y - _kdg_cy) * _kdg_gy,
                    _gg_w, _gg_h, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.3);

  for (var _sg3 = 0; _sg3 < array_length(kdash_slashes); _sg3++) {
    var _sl2 = kdash_slashes[_sg3];
    var _sla = _sl2.life / _sl2.life_max;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 1, _sl2.hot * _sla), lerp(0.26, 1, _sl2.hot * _sla));
    shader_set_uniform_f(global.u_glow_intensity, _sla * _sla * kdash_slash_glow_intensity);

    var _sl_scale = (7 + _sl2.hot * 6) * _kdg_gx / _kdg_half;
    for (var _sk = 0; _sk <= 5; _sk++) {
      var _slf = _sk / 5;
      draw_sprite_ext(spr_glow_blob, 0,
                      (lerp(_sl2.x1, _sl2.x2, _slf) - _kdg_cx) * _kdg_gx,
                      (lerp(_sl2.y1, _sl2.y2, _slf) - _kdg_cy) * _kdg_gy,
                      _sl_scale, _sl_scale, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.4);

  for (var _ig = 0; _ig < array_length(kdash_impacts); _ig++) {
    var _im4 = kdash_impacts[_ig];
    var _ia4 = _im4.life / _im4.max_life;

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.18, 1, _im4.hot * _ia4), lerp(0.15, 0.95, _im4.hot * _ia4));
    shader_set_uniform_f(global.u_glow_intensity, _ia4 * _ia4 * (0.9 + _im4.hot) * kdash_crater_glow_mult);

    var _isc2 = (_im4.radius * 1.5) * _kdg_gx / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_im4.x - _kdg_cx) * _kdg_gx, (_im4.y - _kdg_cy) * _kdg_gy,
                    _isc2, _isc2 * 0.5, 0, c_white, 1);
  }

  for (var _scg = 0; _scg < array_length(kdash_scars); _scg++) {
    var _sc4 = kdash_scars[_scg];
    var _sca4 = clamp(_sc4.life / max(_sc4.life_max, 1), 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.16, 0.82, _sc4.heat * _sca4),
                         lerp(0.12, 0.55, _sc4.heat * _sca4));
    shader_set_uniform_f(global.u_glow_intensity, _sca4 * _sca4 * (0.35 + _sc4.heat * 0.65) * kdash_crater_glow_mult);
    shader_set_uniform_f(global.u_glow_falloff, 1.9);

    draw_sprite_ext(spr_glow_blob, 0, (_sc4.x - _kdg_cx) * _kdg_gx, (_sc4.y - _kdg_cy) * _kdg_gy,
                    (_sc4.span * 0.9) * _kdg_gx / _kdg_half,
                    (8 + _sc4.heat * 8) * _kdg_gy / _kdg_half, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var _bg = 0; _bg < array_length(kdash_shards); _bg++) {
    var _sh4 = kdash_shards[_bg];
    var _sa4 = clamp(_sh4.life / _sh4.max_life, 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1, lerp(0.1, 0.8, _sa4), lerp(0.08, 0.7, _sa4));
    shader_set_uniform_f(global.u_glow_intensity, _sa4 * kdash_shard_glow_intensity);

    var _bsc = (10 + _sa4 * 6) * _kdg_gx / _kdg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_sh4.x - _kdg_cx) * _kdg_gx, (_sh4.y - _kdg_cy) * _kdg_gy,
                    _bsc, _bsc * 1.6, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (jump_rope_alpha > 0.01 || array_length(jr_scorches) > 0 || array_length(push_waves) > 0 ||
    instance_number(oPushOrb) > 0 || array_length(jr_shards) > 0 || jr_detonate_flash > 0.01 ||
    ((t >= jump_rope_spawn_t && t < transition_reveal_t && !cube_wings_collected) ||
     jr_wing_collect_flash > 0.01)) {

  var _jrg_gx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _jrg_gy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _jrg_cx = oCameraController.current_cam_x;
  var _jrg_cy = oCameraController.current_cam_y;
  var _jrg_half = sprite_get_width(spr_glow_blob) * 0.5;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _jrg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _jrg_uvs[0], _jrg_uvs[1], _jrg_uvs[2], _jrg_uvs[3]);

  if (jump_rope_alpha > 0.01) {
    var _jr_depth01 = (jump_rope_depth + 1) / 2;
    var _jr_hot = clamp(power(_jr_depth01, 2) * 0.5 + jr_coil * 0.7 + jr_crack_flash + jr_taut_flash, 0, 1.4);

    var _jr_heat01 = clamp(_jr_hot, 0, 1);
    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.18, 0.92, _jr_heat01),
                         lerp(0.12, 0.62, _jr_heat01));
    shader_set_uniform_f(global.u_glow_intensity, (0.45 + _jr_hot * 1.1) * jump_rope_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    var _jr_scale = (7 + _jr_depth01 * 9 + _jr_hot * 7) * _jrg_gx / _jrg_half;

    var _jr_curve = scr_jump_rope_sample();
    var _jr_cn = array_length(_jr_curve);
    for (var _jb2 = 0; _jb2 < _jr_cn; _jb2 += 2) {
      var _jcp = _jr_curve[_jb2];
      if (_jcp.r <= 0.05) continue;

      draw_sprite_ext(spr_glow_blob, 0, (_jcp.x - _jrg_cx) * _jrg_gx, (_jcp.y - _jrg_cy) * _jrg_gy,
                      _jr_scale * _jcp.r, _jr_scale * _jcp.r, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_falloff, 1.3);

    for (var _hi = 0; _hi < 2; _hi++) {
      var _hx2 = (_hi == 0) ? jump_rope_anchor_left_x : jump_rope_anchor_right_x;
      var _hy2 = (_hi == 0) ? jump_rope_anchor_left_y : jump_rope_anchor_right_y;
      var _heat = jr_anchor_heat[_hi] + jr_heartbeat * 0.3;

      var _handle_heat01 = clamp(_heat, 0, 1);
      shader_set_uniform_f(global.u_glow_color, 1,
                           lerp(0.22, 0.95, _handle_heat01),
                           lerp(0.14, 0.7, _handle_heat01));
      shader_set_uniform_f(global.u_glow_intensity, (0.5 + _heat * 1.4) * jump_rope_alpha);

      var _h_sc = (16 + _heat * 26) * _jrg_gx / _jrg_half;
      draw_sprite_ext(spr_glow_blob, 0, (_hx2 - _jrg_cx) * _jrg_gx, (_hy2 - _jrg_cy) * _jrg_gy,
                      _h_sc, _h_sc, 0, c_white, 1);
    }

    var _fig_glow = clamp(max(jr_anchor_heat[0], jr_anchor_heat[1]) * 0.5 + jr_coil * 0.35 +
                          jr_crack_flash * 0.9 + jr_detonate_flash, 0, 1.2);
    if (_fig_glow > 0.03) {
      var _fig_heat01 = clamp(_fig_glow, 0, 1);
      shader_set_uniform_f(global.u_glow_color, 1,
                           lerp(0.16, 0.78, _fig_heat01),
                           lerp(0.14, 0.55, _fig_heat01));
      shader_set_uniform_f(global.u_glow_intensity, _fig_glow * 0.7 * jump_rope_alpha);
      shader_set_uniform_f(global.u_glow_falloff, 2.1);

      for (var _fi = 0; _fi < 2; _fi++) {
        var _fx2 = (_fi == 0) ? (_k_jr_anchor_left_x - _k_jr_figure_stand_offset)
                              : (_k_jr_anchor_right_x + _k_jr_figure_stand_offset);
        var _fy2 = _k_jr_floor_y - 56 * _k_jr_figure_scale;

        var _f_w = (34 + _fig_glow * 16) * _jrg_gx / _jrg_half;
        var _f_h = (78 + _fig_glow * 22) * _jrg_gy / _jrg_half;
        draw_sprite_ext(spr_glow_blob, 0, (_fx2 - _jrg_cx) * _jrg_gx, (_fy2 - _jrg_cy) * _jrg_gy,
                        _f_w, _f_h, 0, c_white, 1);
      }
    }
  }

  var _jrg_wing_active = (t >= jump_rope_spawn_t && t < transition_reveal_t && !cube_wings_collected) ||
                         jr_wing_collect_flash > 0.01;
  if (_jrg_wing_active) {
    var _wgx0 = cube_wings_collected ? jr_wing_collect_x : jr_wing_x;
    var _wgy0 = cube_wings_collected ? jr_wing_collect_y : jr_wing_y;
    var _wgstage = clamp(jr_wing_drop_stage / max(_k_jr_wing_collect_stage, 1), 0, 1);
    var _wgflash = max(jr_wing_flash, jr_wing_collect_flash);
    var _wgpull = cube_wings_collected ? jr_wing_collect_flash : 1;
    var _wgx = (_wgx0 - _jrg_cx) * _jrg_gx;
    var _wgy = (_wgy0 - _jrg_cy) * _jrg_gy;
    var _wg_pick_y = (_k_jr_wing_pickup_y - _jrg_cy) * _jrg_gy;

    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.18, 0.92, clamp(_wgstage + _wgflash, 0, 1)),
                         lerp(0.15, 0.72, clamp(_wgstage + _wgflash, 0, 1)));
    shader_set_uniform_f(global.u_glow_intensity, (0.45 + _wgstage * 0.65 + _wgflash * 0.8) * _wgpull);
    shader_set_uniform_f(global.u_glow_falloff, 1.65);

    var _wg_core = (30 + _wgstage * 16 + _wgflash * 36) * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, _wgx, _wgy, _wg_core, _wg_core * 0.72, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, (0.18 + _wgflash * 0.7) * _wgpull);
    shader_set_uniform_f(global.u_glow_falloff, 1.2);
    var _wg_hot = (10 + _wgflash * 24) * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, _wgx, _wgy, _wg_hot, _wg_hot, 0, c_white, 1);

    if (!cube_wings_collected) {
      var _wg_spot = clamp(0.25 + _wgstage * 0.58 + _wgflash * 0.32 + (jr_wing_ready ? 0.25 : 0), 0, 1.25);
      shader_set_uniform_f(global.u_glow_color, 0.72, 0.96, 1);
      shader_set_uniform_f(global.u_glow_intensity, 0.20 + _wg_spot * 0.58);
      shader_set_uniform_f(global.u_glow_falloff, 1.5);
      for (var _wgls = -1; _wgls <= 1; _wgls += 2) {
        var _wglx0 = _wgx0 + _wgls * (118 - _wgstage * 22 + sin(t * 0.031 + _wgls * 2.7) * 9);
        var _wgly0 = 28 + cos(t * 0.026 + _wgls) * 4;
        var _wglx = (_wglx0 - _jrg_cx) * _jrg_gx;
        var _wgly = (_wgly0 - _jrg_cy) * _jrg_gy;
        var _lamp_sc = (15 + _wg_spot * 15) * _jrg_gx / _jrg_half;
        draw_sprite_ext(spr_glow_blob, 0, _wglx, _wgly, _lamp_sc, _lamp_sc, 0, c_white, 1);
      }

      if (jr_wing_ready) {
        shader_set_uniform_f(global.u_glow_color, 0.82, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, 0.45 + _wgflash * 0.65);
        shader_set_uniform_f(global.u_glow_falloff, 1.35);
        var _pick_sc = (42 + _wgflash * 28) * _jrg_gx / _jrg_half;
        draw_sprite_ext(spr_glow_blob, 0, _wgx, _wg_pick_y, _pick_sc, _pick_sc * 0.82, 0, c_white, 1);
      }

      shader_set_uniform_f(global.u_glow_color, 1, 0.25, 0.18);
      shader_set_uniform_f(global.u_glow_intensity, (0.16 + _wgstage * 0.28 + jr_wing_slam * 0.45));
      shader_set_uniform_f(global.u_glow_falloff, 2.0);
      var _rail_h = max(12, (_wgy0 + 16) * _jrg_gy / _jrg_half);
      draw_sprite_ext(spr_glow_blob, 0, _wgx, ((_wgy0 * 0.5 - _jrg_cy) * _jrg_gy),
                      (7 + jr_wing_slam * 5) * _jrg_gx / _jrg_half, _rail_h, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 2.0);

  for (var _gj = 0; _gj < array_length(jr_ghosts); _gj++) {
    var _jg3 = jr_ghosts[_gj];
    var _jgp = _jg3.pts;
    var _jgn = array_length(_jgp);
    if (_jgn < 2) continue;

    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.16, 0.76, _jg3.hot),
                         lerp(0.12, 0.45, _jg3.hot));
    shader_set_uniform_f(global.u_glow_intensity, _jg3.alpha * 1.4);

    var _jg_sc = (3 + _jg3.width * 1.4) * _jrg_gx / _jrg_half;
    for (var _jgs = 0; _jgs < _jgn; _jgs++) {
      draw_sprite_ext(spr_glow_blob, 0, (_jgp[_jgs].x - _jrg_cx) * _jrg_gx,
                      (_jgp[_jgs].y - _jrg_cy) * _jrg_gy, _jg_sc, _jg_sc, 0, c_white, 1);
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.5);

  for (var _sgi = 0; _sgi < array_length(jr_scorches); _sgi++) {
    var _sco2 = jr_scorches[_sgi];
    var _scl2 = _sco2.life / _sco2.life_max;
    if (_sco2.hot < 0.02) continue;

    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.12, 0.72, _sco2.hot),
                         lerp(0.08, 0.35, _sco2.hot));
    shader_set_uniform_f(global.u_glow_intensity, _scl2 * _sco2.hot * 1.5);

    var _sc_w = (_sco2.w * 1.1) * _jrg_gx / _jrg_half;
    var _sc_h = (10 + _sco2.hot * 14) * _jrg_gy / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_sco2.x - _jrg_cx) * _jrg_gx, (_k_jr_floor_y - _jrg_cy) * _jrg_gy,
                    _sc_w, _sc_h, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.8);

  for (var _pwg = 0; _pwg < array_length(push_waves); _pwg++) {
    var _pw3 = push_waves[_pwg];
    var _pwa = _pw3.life / _pw3.max_life;
    var _pw_col3 = variable_struct_exists(_pw3, "color") ? _pw3.color : _k_er_col_cyan;

    shader_set_uniform_f(global.u_glow_color, color_get_red(_pw_col3) / 255,
                         color_get_green(_pw_col3) / 255, color_get_blue(_pw_col3) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _pwa * _pwa * (0.5 + _pw3.hot * 0.8));

    var _pw_w = room_width * 0.62 * _jrg_gx / _jrg_half;
    var _pw_h = (_pw3.thickness * 1.6) * _jrg_gy / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, (room_width * 0.5 - _jrg_cx) * _jrg_gx, (_pw3.y - _jrg_cy) * _jrg_gy,
                    _pw_w, _pw_h, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.5);

  var _po_ang_rad = degtorad(-(oCameraController.current_cam_angle + oCameraController.angle_kick * fx_get_mult("tilt")));
  var _po_cos = cos(_po_ang_rad);
  var _po_sin = sin(_po_ang_rad);
  var _po_cam_cx = _jrg_cx + oCameraController.current_cam_w * 0.5;
  var _po_cam_cy = _jrg_cy + oCameraController.current_cam_h * 0.5;

  with (oPushOrb) {
    if (image_alpha <= 0.05) continue;

    var _po_heat = clamp(hot + squash_timer * 0.6, 0, 1);
    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.18, 0.9, _po_heat),
                         lerp(0.12, 0.48, _po_heat));
    shader_set_uniform_f(global.u_glow_intensity, (0.7 + _po_heat * 1.3) * image_alpha);

    var _po_rel_x = x - _po_cam_cx;
    var _po_rel_y = y - _po_cam_cy;
    var _po_draw_x = (_po_rel_x * _po_cos - _po_rel_y * _po_sin) * _jrg_gx + oCameraController.base_view_w * 0.5;
    var _po_draw_y = (_po_rel_x * _po_sin + _po_rel_y * _po_cos) * _jrg_gy + oCameraController.base_view_h * 0.5;

    var _po_sc = (14 + _po_heat * 14) * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, _po_draw_x, _po_draw_y,
                    _po_sc * (1 - _po_heat * 0.15), _po_sc * (1 + _po_heat * 0.35), 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.6);

  for (var _dg = 0; _dg < array_length(jr_shards); _dg++) {
    var _jsh3 = jr_shards[_dg];
    var _dga = clamp(_jsh3.life / _jsh3.life_max, 0, 1);

    shader_set_uniform_f(global.u_glow_color, 1,
                         lerp(0.12, 0.78, _jsh3.hot * _dga),
                         lerp(0.08, 0.42, _jsh3.hot * _dga));
    shader_set_uniform_f(global.u_glow_intensity, _dga * 1.1);

    var _dg_sc = (9 + _jsh3.hot * 8) * _dga * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, (_jsh3.x - _jrg_cx) * _jrg_gx, (_jsh3.y - _jrg_cy) * _jrg_gy,
                    _dg_sc, _dg_sc, 0, c_white, 1);
  }

  if (jr_detonate_flash > 0.01) {
    var _df = jr_detonate_flash;
    var _dfx = (jump_rope_mid_x - _jrg_cx) * _jrg_gx;
    var _dfy = (_k_jr_floor_y - _jrg_cy) * _jrg_gy;

    shader_set_uniform_f(global.u_glow_color, 1, 0.28, 0.18);
    shader_set_uniform_f(global.u_glow_intensity, _df * 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    var _df_w = (240 + (1 - _df) * 340) * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, _dfx, _dfy, _df_w, _df_w * 0.45, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _df * 2);
    shader_set_uniform_f(global.u_glow_falloff, 1.1);
    var _dfc_w = (50 + _df * 90) * _jrg_gx / _jrg_half;
    draw_sprite_ext(spr_glow_blob, 0, _dfx, _dfy, _dfc_w, _dfc_w * 0.6, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

if (t >= _k_mill_t_seed - 4 && t <= _k_mill_window_end) {
  var _mg_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _mg_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _mg_cx = oCameraController.current_cam_x;
  var _mg_cy = oCameraController.current_cam_y;
  var _mg_half = sprite_get_width(spr_glow_blob) * 0.5;

  var _mg_r = color_get_red(_k_arc_color) / 255;
  var _mg_g = color_get_green(_k_arc_color) / 255;
  var _mg_b = color_get_blue(_k_arc_color) / 255;

  var _mg_px = (_k_mill_cx - _mg_cx) * _mg_sx;
  var _mg_py = (_k_mill_cy - _mg_cy) * _mg_sy;
  var _mcore_swapg = clamp((t - _k_mill_t_overload) / max(_k_mill_t_seed_c - _k_mill_t_overload, 1), 0, 1);
  var _mcore_armg = (t < _k_mill_t_unfold)
                    ? clamp((t - _k_mill_t_coil) / max(_k_mill_t_unfold - _k_mill_t_coil, 1), 0, 1)
                    : clamp((t - _k_mill_t_unfold) / max(_k_mill_core_arm, 1), 0, 1);
  var _mcore_rg = lerp(_k_mill_core_r_a, _k_mill_core_r_b, _mcore_swapg) * lerp(0.38, 1, _mcore_armg);
  var _mcore_visg = (t >= _k_mill_t_clear)
                    ? (1 - clamp((t - _k_mill_t_clear) / max(_k_mill_core_despawn, 1), 0, 1))
                    : 1;
  _mcore_rg *= lerp(0.18, 1, _mcore_visg);

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);
  var _mg_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _mg_uvs[0], _mg_uvs[1], _mg_uvs[2], _mg_uvs[3]);

  var _mg_core = mill_charge * 0.9 + mill_heartbeat * 0.6 + mill_blade_flash * 1.2
               + mill_overload * 2.6 + mill_field_heat * 0.5;
  if (_mg_core > 0.02 || (_mcore_armg > 0.02 && _mcore_visg > 0.02)) {
    shader_set_uniform_f(global.u_glow_color, _mg_r, _mg_g, _mg_b);
    shader_set_uniform_f(global.u_glow_intensity, max(_mg_core * 0.8, _mcore_armg * 0.55) * _mcore_visg);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);
    var _mg_w = ((_mcore_rg * 2.15 + mill_charge * 70 + mill_overload * 420 + mill_blade_flash * 100) * _mg_sx) / _mg_half;
    draw_sprite_ext(spr_glow_blob, 0, _mg_px, _mg_py, _mg_w, _mg_w * 0.88, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, max(_mg_core * 1.4, _mcore_armg * 0.8) * _mcore_visg);
    shader_set_uniform_f(global.u_glow_falloff, 2.4);
    var _mg_c = ((max(10, _mcore_rg * 0.42) + mill_charge * 20 + mill_overload * 150 + mill_blade_flash * 38) * _mg_sx) / _mg_half;
    draw_sprite_ext(spr_glow_blob, 0, _mg_px, _mg_py, _mg_c, _mg_c, 0, c_white, 1);
  }

  if (mill_rim > 4 && mill_charge > 0.02) {
    var _mgrv = _k_mill_ry_out / _k_mill_rx_out;
    shader_set_uniform_f(global.u_glow_color, 1, _mg_g * 0.7, _mg_b * 0.6);
    shader_set_uniform_f(global.u_glow_falloff, 1.9);
    shader_set_uniform_f(global.u_glow_intensity, mill_charge * (0.5 + mill_heartbeat * 0.6));
    var _mgrs = ((9 + mill_charge * 12) * _mg_sx) / _mg_half;
    for (var _mgr = 0; _mgr < 30; _mgr++) {
      var _mgra = (_mgr / 30) * 360 + mill_vortex * 0.6;
      draw_sprite_ext(spr_glow_blob, 0,
                      (_k_mill_cx + lengthdir_x(mill_rim, _mgra) - _mg_cx) * _mg_sx,
                      (_k_mill_cy + lengthdir_y(mill_rim * _mgrv, _mgra) - _mg_cy) * _mg_sy,
                      _mgrs, _mgrs, 0, c_white, 1);
    }
  }

  with (oLaserOrbTrigger) {
    if (!is_rotating) continue;
    var _mghr = _k_beam_half_length * extend;
    if (_mghr < 4) continue;

    var _mghax = image_angle - 90;
    var _mgheat = beam_heat / _k_beam_heat_max;
    var _mghn = 20;

    shader_set_uniform_f(global.u_glow_color, color_get_red(beam_col_outer) / 255,
                         color_get_green(beam_col_outer) / 255,
                         color_get_blue(beam_col_outer) / 255);
    shader_set_uniform_f(global.u_glow_falloff, 1.7);

    for (var _mgh = 0; _mgh <= _mghn; _mgh++) {
      var _mghf = (_mgh / _mghn) * 2 - 1;
      var _mghd = abs(_mghf);
      shader_set_uniform_f(global.u_glow_intensity,
                           (0.35 + _mgheat * 0.7 + other.mill_blade_flash * 0.8) * (0.45 + _mghd * 0.75));
      var _mghs = ((11 + _mgheat * 16 + other.mill_blade_flash * 20) * _mg_sx) / _mg_half;
      draw_sprite_ext(spr_glow_blob, 0,
                      (x + lengthdir_x(_mghr * _mghf, _mghax) - _mg_cx) * _mg_sx,
                      (y + lengthdir_y(_mghr * _mghf, _mghax) - _mg_cy) * _mg_sy,
                      _mghs, _mghs, 0, c_white, 1);
    }

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.5);
    shader_set_uniform_f(global.u_glow_intensity, 0.5 + _mgheat * 0.8 + other.mill_blade_flash);
    for (var _mgh2 = 0; _mgh2 <= _mghn; _mgh2++) {
      var _mghf2 = (_mgh2 / _mghn) * 2 - 1;
      var _mghs2 = ((3 + _mgheat * 5) * _mg_sx) / _mg_half;
      draw_sprite_ext(spr_glow_blob, 0,
                      (x + lengthdir_x(_mghr * _mghf2, _mghax) - _mg_cx) * _mg_sx,
                      (y + lengthdir_y(_mghr * _mghf2, _mghax) - _mg_cy) * _mg_sy,
                      _mghs2, _mghs2, 0, c_white, 1);
    }
  }

  if (!mill_torn && array_length(mill_arm_waves) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    shader_set_uniform_f(global.u_glow_color, 1, _mg_g, _mg_b);

    for (var _mgw = 0; _mgw < array_length(mill_arm_waves); _mgw++) {
      var _mgwv = mill_arm_waves[_mgw];
      if (_mgwv.per < 2) continue;
      var _mgrv = clamp(_mgwv.age / _k_mill_arm_reveal, 0, 1);
      var _mggl = _mgwv.weight * (1 - clamp((_mgwv.age - _k_mill_arm_reveal - _k_mill_arm_hold)
                                            / _k_mill_arm_fade, 0, 1))
                * (0.72 + mill_arm_glow * 0.28);
      if (_mggl < 0.01 || _mgrv <= 0) continue;

      shader_set_uniform_f(global.u_glow_intensity, _mggl * (0.55 + mill_heartbeat * 0.5));
      var _mgaw = (13 * _mg_sx) / _mg_half;

      for (var _mgaa = 0; _mgaa < _mgwv.count; _mgaa++) {
        for (var _mgb = 0; _mgb < _mgwv.per; _mgb++) {
          var _mgaf = _mgb / (_mgwv.per - 1);
          if (_mgaf > _mgrv) break;
          var _mgpt = scr_mill_arm_point(_mgwv, _mgaa, _mgaf, _k_mill_cx, _k_mill_cy);
          draw_sprite_ext(spr_glow_blob, 0,
                          (_mgpt.x - _mg_cx) * _mg_sx, (_mgpt.y - _mg_cy) * _mg_sy,
                          _mgaw, _mgaw, 0, c_white, 1);
        }
      }
    }
  }

  if (array_length(mill_seeds) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    for (var _mgs = 0; _mgs < array_length(mill_seeds); _mgs++) {
      var _mgsd = mill_seeds[_mgs];
      if (_mgsd.delay > 0) continue;

      var _mgtn = array_length(_mgsd.trail);
      shader_set_uniform_f(global.u_glow_color, _mg_r, _mg_g, _mg_b);
      for (var _mgt = 0; _mgt < _mgtn; _mgt++) {
        var _mgtp = _mgsd.trail[_mgt];
        var _mgage = _mgt / max(_mgtn - 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, _mgage * _mgage * (_mgsd.heavy ? 0.9 : 0.5));
        var _mgts = (lerp(3, 11, _mgage) * (_mgsd.heavy ? 1.7 : 1) * _mg_sx) / _mg_half;
        draw_sprite_ext(spr_glow_blob, 0, (_mgtp.x - _mg_cx) * _mg_sx, (_mgtp.y - _mg_cy) * _mg_sy,
                        _mgts, _mgts, 0, c_white, 1);
      }

      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, _mgsd.heavy ? 1.5 : 0.95);
      var _mghs3 = ((_mgsd.heavy ? 13 : 8) * _mg_sx) / _mg_half;
      draw_sprite_ext(spr_glow_blob, 0, (_mgsd.x - _mg_cx) * _mg_sx, (_mgsd.y - _mg_cy) * _mg_sy,
                      _mghs3, _mghs3, 0, c_white, 1);
    }
  }

  if (array_length(mill_touchdowns) > 0) {
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_falloff, 2.1);
    for (var _mgtd = 0; _mgtd < array_length(mill_touchdowns); _mgtd++) {
      var _mgt2 = mill_touchdowns[_mgtd];
      var _mgtl = _mgt2.life / _mgt2.life_max;
      shader_set_uniform_f(global.u_glow_intensity, _mgtl * (_mgt2.heavy ? 1.6 : 1));
      var _mgtw = (lerp(4, _mgt2.heavy ? 46 : 28, 1 - _mgtl) * _mg_sx) / _mg_half;
      draw_sprite_ext(spr_glow_blob, 0, (_mgt2.x - _mg_cx) * _mg_sx, (_mgt2.y - _mg_cy) * _mg_sy,
                      _mgtw, _mgtw * 0.55, 0, c_white, 1);
    }
  }

  if (array_length(mill_motes) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 2);
    var _mgmv = _k_mill_ry_out / _k_mill_rx_out;
    for (var _mgm = 0; _mgm < array_length(mill_motes); _mgm++) {
      var _mgmo = mill_motes[_mgm];
      shader_set_uniform_f(global.u_glow_color, 1, _mg_g * 0.5 + _mgmo.hot * 0.4, _mg_b * 0.4 + _mgmo.hot * 0.35);
      shader_set_uniform_f(global.u_glow_intensity, _mgmo.hot * (0.4 + mill_charge * 0.7));
      var _mgms = ((3.5 + _mgmo.hot * 4) * _mg_sx) / _mg_half;
      draw_sprite_ext(spr_glow_blob, 0,
                      (_k_mill_cx + lengthdir_x(_mgmo.dist, _mgmo.ang) - _mg_cx) * _mg_sx,
                      (_k_mill_cy + lengthdir_y(_mgmo.dist * _mgmv, _mgmo.ang) - _mg_cy) * _mg_sy,
                      _mgms, _mgms, 0, c_white, 1);
    }
  }

  if (array_length(mill_scars) > 0) {
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    for (var _mgsc = 0; _mgsc < array_length(mill_scars); _mgsc++) {
      var _mgs2 = mill_scars[_mgsc];
      var _mgig = max(_mgs2.ignite, _mgs2.guide);
      shader_set_uniform_f(global.u_glow_color, 1,
                           _mg_g * 0.6 + _mgs2.hot * 0.3 + _mgig * 0.6,
                           _mg_b * 0.5 + _mgs2.hot * 0.25 + _mgig * 0.55);
      shader_set_uniform_f(global.u_glow_intensity,
                           _mgs2.alpha * (0.55 + mill_overload * 0.6 + mill_collapse * 0.3) + _mgig * 1.1);
      var _mgss = ((7 + _mgs2.alpha * 11 + mill_overload * 26 + _mgig * 20) * _mg_sx) / _mg_half;
      for (var _mgsp = 0; _mgsp <= 16; _mgsp++) {
        var _mgsf = (_mgsp / 16) * 2 - 1;
        draw_sprite_ext(spr_glow_blob, 0,
                        (_k_mill_cx + lengthdir_x(_mgs2.half_len * _mgsf, _mgs2.ang) - _mg_cx) * _mg_sx,
                        (_k_mill_cy + lengthdir_y(_mgs2.half_len * _mgsf, _mgs2.ang) - _mg_cy) * _mg_sy,
                        _mgss, _mgss, 0, c_white, 1);
      }
    }
  }

  shader_set_uniform_f(global.u_glow_falloff, 2);
  with (oFallingRedOrb) {
    if (!mill_orb || dissolving || glowing) continue;
    var _mgfuse = telegraphing
                  ? clamp((telegraph_duration - telegraph_timer - mill_fuse_delay)
                          / max(mill_fuse_span, 1), 0, 1)
                  : 0;
    if (mill_gate_cyan) {
      shader_set_uniform_f(global.u_glow_color,
                           color_get_red(global.avoid_col_cyan) / 255,
                           color_get_green(global.avoid_col_cyan) / 255,
                           color_get_blue(global.avoid_col_cyan) / 255);
    } else {
      shader_set_uniform_f(global.u_glow_color, 1, _mg_g * 0.5, _mg_b * 0.45);
    }
    shader_set_uniform_f(global.u_glow_intensity,
                         (telegraphing ? lerp(0.65, 1.55, _mgfuse) : 0.55)
                         * (0.7 + other.mill_collapse * 0.5));
    var _mgbs = ((telegraphing ? lerp(14, 23, _mgfuse) : 12) * _mg_sx) / _mg_half;
    draw_sprite_ext(spr_glow_blob, 0, (x - _mg_cx) * _mg_sx, (y - _mg_cy) * _mg_sy,
                    _mgbs, _mgbs, 0, c_white, 1);
  }

  shader_set_uniform_f(global.u_glow_falloff, 1.8);
  with (oFallingRedOrb) {
    if (!mill_orb || dissolving || !mill_wired || mill_link_to == noone) continue;
    if (!instance_exists(mill_link_to)) continue;

    var _wgo = mill_link_to;
    if (!_wgo.mill_wired || _wgo.dissolving) continue;

    if (mill_gate_cyan) {
      shader_set_uniform_f(global.u_glow_color,
                           color_get_red(global.avoid_col_cyan) / 255,
                           color_get_green(global.avoid_col_cyan) / 255,
                           color_get_blue(global.avoid_col_cyan) / 255);
    } else {
      shader_set_uniform_f(global.u_glow_color, 1, _mg_g * 0.75, _mg_b * 0.6);
    }
    shader_set_uniform_f(global.u_glow_intensity, 0.85);
    var _wgs = (15 * _mg_sx) / _mg_half;

    for (var _wgi = 0; _wgi <= 4; _wgi++) {
      var _wgf = _wgi / 4;
      draw_sprite_ext(spr_glow_blob, 0,
                      (lerp(x, _wgo.x, _wgf) - _mg_cx) * _mg_sx,
                      (lerp(y, _wgo.y, _wgf) - _mg_cy) * _mg_sy,
                      _wgs, _wgs, 0, c_white, 1);
    }
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

surface_reset_target();

gpu_set_blendmode(bm_add);
draw_surface(glow_surface, 0, 0);
gpu_set_blendmode(bm_normal);

if (!is_undefined(riser)) {
  scr_riser_draw_lock(oCameraController.current_cam_x, oCameraController.current_cam_y,
                      oCameraController.base_view_w / oCameraController.current_cam_w,
                      oCameraController.base_view_h / oCameraController.current_cam_h);
}

if (transition_black_alpha > 0) {
  draw_set_color(c_black);
  draw_set_alpha(transition_black_alpha);
  draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
  draw_set_alpha(1);
}
if (transition_reveal_flash > 0) {
  draw_set_color(c_white);
  draw_set_alpha(transition_reveal_flash);
  draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
  draw_set_alpha(1);
}

if (screen_edge_warn > 0.01 || screen_edge_hit_flash > 0.01) {
  var _se_w = display_get_gui_width();
  var _se_h = display_get_gui_height();
  var _se_l = clamp(screen_edge_warn_l, 0, 1);
  var _se_r = clamp(screen_edge_warn_r, 0, 1);
  var _se_t = clamp(screen_edge_warn_t, 0, 1);
  var _se_b = clamp(screen_edge_warn_b, 0, 1);
  var _se_warn = max(max(_se_l, _se_r), max(_se_t, _se_b));
  var _se_hit = clamp(screen_edge_hit_flash, 0, 1);
  var _se_col = merge_color(global.avoid_col_warning, c_white, _se_hit * 0.45);

  shader_reset();
  gpu_set_blendmode(bm_normal);
  draw_set_color(global.avoid_col_blood);
  if (_se_t > 0.01) {
    var _se_at = power(_se_t, 1.7);
    var _se_tt = 10 + _se_at * 34 + _se_hit * 16;
    draw_set_alpha(0.08 * _se_at + 0.10 * _se_hit);
    draw_rectangle(0, 0, _se_w, _se_tt, false);
  }
  if (_se_b > 0.01) {
    var _se_ab = power(_se_b, 1.7);
    var _se_tb = 10 + _se_ab * 34 + _se_hit * 16;
    draw_set_alpha(0.08 * _se_ab + 0.10 * _se_hit);
    draw_rectangle(0, _se_h - _se_tb, _se_w, _se_h, false);
  }
  if (_se_l > 0.01) {
    var _se_al = power(_se_l, 1.7);
    var _se_tl = 10 + _se_al * 34 + _se_hit * 16;
    draw_set_alpha(0.08 * _se_al + 0.10 * _se_hit);
    draw_rectangle(0, 0, _se_tl, _se_h, false);
  }
  if (_se_r > 0.01) {
    var _se_ar = power(_se_r, 1.7);
    var _se_tr = 10 + _se_ar * 34 + _se_hit * 16;
    draw_set_alpha(0.08 * _se_ar + 0.10 * _se_hit);
    draw_rectangle(_se_w - _se_tr, 0, _se_w, _se_h, false);
  }

  gpu_set_blendmode(bm_add);
  draw_set_color(_se_col);
  if (_se_t > 0.01) {
    var _se_at2 = power(_se_t, 1.7);
    var _se_tt2 = 10 + _se_at2 * 34 + _se_hit * 16;
    draw_set_alpha(0.18 * _se_at2 + 0.22 * _se_hit);
    draw_line_width(0, _se_tt2, _se_w, _se_tt2, 2 + _se_hit * 2);
  }
  if (_se_b > 0.01) {
    var _se_ab2 = power(_se_b, 1.7);
    var _se_tb2 = 10 + _se_ab2 * 34 + _se_hit * 16;
    draw_set_alpha(0.18 * _se_ab2 + 0.22 * _se_hit);
    draw_line_width(0, _se_h - _se_tb2, _se_w, _se_h - _se_tb2, 2 + _se_hit * 2);
  }
  if (_se_l > 0.01) {
    var _se_al2 = power(_se_l, 1.7);
    var _se_tl2 = 10 + _se_al2 * 34 + _se_hit * 16;
    draw_set_alpha(0.18 * _se_al2 + 0.22 * _se_hit);
    draw_line_width(_se_tl2, 0, _se_tl2, _se_h, 2 + _se_hit * 2);
  }
  if (_se_r > 0.01) {
    var _se_ar2 = power(_se_r, 1.7);
    var _se_tr2 = 10 + _se_ar2 * 34 + _se_hit * 16;
    draw_set_alpha(0.18 * _se_ar2 + 0.22 * _se_hit);
    draw_line_width(_se_w - _se_tr2, 0, _se_w - _se_tr2, _se_h, 2 + _se_hit * 2);
  }

  var _se_inner = 10 + power(_se_warn, 1.7) * 34 + _se_hit * 16;
  draw_set_color(global.avoid_col_cyan);
  draw_set_alpha(0.05 * power(_se_warn, 1.7));
  if (_se_t > 0.01) draw_line_width(_se_inner * 0.45, _se_inner * 0.45, _se_w - _se_inner * 0.45, _se_inner * 0.45, 1);
  if (_se_b > 0.01) draw_line_width(_se_inner * 0.45, _se_h - _se_inner * 0.45, _se_w - _se_inner * 0.45, _se_h - _se_inner * 0.45, 1);
  if (_se_l > 0.01) draw_line_width(_se_inner * 0.45, _se_inner * 0.45, _se_inner * 0.45, _se_h - _se_inner * 0.45, 1);
  if (_se_r > 0.01) draw_line_width(_se_w - _se_inner * 0.45, _se_inner * 0.45, _se_w - _se_inner * 0.45, _se_h - _se_inner * 0.45, 1);

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

if (final_cut_triggered) {
  var _fcw = display_get_gui_width();
  var _fch = display_get_gui_height();
  if (_fcw < 1) _fcw = GAME_WIDTH;
  if (_fch < 1) _fch = GAME_HEIGHT;
  var _gs  = _fcw / GAME_WIDTH;

  var _fdiag = point_distance(0, 0, _fcw, _fch);
  var _fnx   = _fcw / _fdiag;
  var _fny   = _fch / _fdiag;
  var _cpx   = _fch / _fdiag;
  var _cpy   = _fcw / _fdiag;

  var _cut_ox = 0, _cut_oy = 0;
  if (instance_exists(oCameraController) &&
      oCameraController.current_cam_w > 1 && oCameraController.current_cam_h > 1) {
    var _cut_live = 1 - fin_cut_veil;
    _cut_ox = ((_k_fin_cx - oCameraController.current_cam_x)
               * (oCameraController.base_view_w / oCameraController.current_cam_w)
               - GAME_WIDTH * 0.5) * _gs * _cut_live;
    _cut_oy = ((_k_fin_cy - oCameraController.current_cam_y)
               * (oCameraController.base_view_h / oCameraController.current_cam_h)
               - GAME_HEIGHT * 0.5) * _gs * _cut_live;
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);

  // --------------------------------------------------------------------------
  // 1. THE SEVERED HALVES
  // --------------------------------------------------------------------------
  var _lip_a = 0;
  var _ex = [0, 0, 0, 0];
  var _ey = [0, 0, 0, 0];

  if (fin_cut_veil > 0.001) {
    if (!fin_cut_captured && surface_exists(scene_snapshot)) {
      final_cut_surface = surface_ensure(final_cut_surface,
                                         surface_get_width(scene_snapshot),
                                         surface_get_height(scene_snapshot));
      surface_set_target(final_cut_surface);
      draw_clear_alpha(c_black, 1);
      draw_surface(scene_snapshot, 0, 0);
      surface_reset_target();
      fin_cut_captured = true;
    }

    draw_set_color(c_black);
    draw_set_alpha(fin_cut_veil);
    draw_rectangle(0, 0, _fcw, _fch, false);
    draw_set_alpha(1);
    draw_set_color(c_white);

    if (fin_cut_captured && surface_exists(final_cut_surface)) {
      var _sep  = (_k_fin_cut_shader_sep * _fdiag)
                + fin_cut_fly * _k_fin_cut_fly_dist * _gs;
      var _sdx  = _fnx * _sep;
      var _sdy  = _fny * _sep;
      var _jit  = fin_cut_jitter * 7 * _gs;
      var _rot  = fin_cut_fly * 3.4 * fin_roll_sign;
      var _hcol = merge_color(c_white, c_black, fin_cut_fly * 0.78);
      var _halp = fin_cut_veil * (1 - power(fin_cut_fly, 2.2));

      var _hv = [
        [ [_fcw, 0, 1, 0], [0, _fch, 0, 1], [0,    0,    0, 0] ],
        [ [_fcw, 0, 1, 0], [0, _fch, 0, 1], [_fcw, _fch, 1, 1] ]
      ];

      if (_halp > 0.004) {
        draw_primitive_begin_texture(pr_trianglelist, surface_get_texture(final_cut_surface));

        for (var _hh = 0; _hh < 2; _hh++) {
          var _sgn = (_hh == 0) ? -1 : 1;
          var _hcx = (_hh == 0) ? _fcw / 3 : _fcw * 2 / 3;
          var _hcy = (_hh == 0) ? _fch / 3 : _fch * 2 / 3;
          var _ha  = _rot * _sgn;
          var _hcs = dcos(_ha);
          var _hsn = dsin(_ha);
          var _jx  = _jit * random_range(-1, 1);
          var _jy  = _jit * random_range(-1, 1);

          for (var _hi = 0; _hi < 3; _hi++) {
            var _vv = _hv[_hh][_hi];
            var _rx = _vv[0] - _hcx;
            var _ry = _vv[1] - _hcy;
            var _vx = _hcx + _rx * _hcs - _ry * _hsn + _sdx * _sgn + _jx;
            var _vy = _hcy + _rx * _hsn + _ry * _hcs + _sdy * _sgn + _jy;

            draw_vertex_texture_colour(_vx, _vy, _vv[2], _vv[3], _hcol, _halp);

            if (_hi < 2) {
              _ex[_hh * 2 + _hi] = _vx;
              _ey[_hh * 2 + _hi] = _vy;
            }
          }
        }

        draw_primitive_end();
        _lip_a = _halp;
      }
    }
  }

  if (_lip_a > 0.02) {
    gpu_set_blendmode(bm_add);
    for (var _lp = 0; _lp < 2; _lp++) {
      var _lx1 = _ex[_lp * 2],     _ly1 = _ey[_lp * 2];
      var _lx2 = _ex[_lp * 2 + 1], _ly2 = _ey[_lp * 2 + 1];

      var _lip_h = 1 - fin_cut_fly * 0.65;

      draw_set_color(merge_color(global.avoid_col_blood, global.avoid_col_ember, 0.55));
      draw_set_alpha(_lip_a * 0.16 * _lip_h);
      draw_line_width(_lx1, _ly1, _lx2, _ly2, 34 * _gs);

      draw_set_color(global.avoid_col_ember);
      draw_set_alpha(_lip_a * 0.24 * _lip_h);
      draw_line_width(_lx1, _ly1, _lx2, _ly2, 13 * _gs);

      draw_set_color(global.avoid_col_warning);
      draw_set_alpha(_lip_a * 0.34 * _lip_h);
      draw_line_width(_lx1, _ly1, _lx2, _ly2, 4.5 * _gs);

      draw_set_color(c_white);
      draw_set_alpha(_lip_a * 0.55 * _lip_h);
      draw_line_width(_lx1, _ly1, _lx2, _ly2, 1.2 * _gs);
    }
    gpu_set_blendmode(bm_normal);
  }

  var _cool   = clamp(fin_cut_scar, 0, 1);
  var _scar_a = clamp(1 - fin_blade_glow, 0, 1) * (0.60 + _cool * 0.40);
  var _scar_n = array_length(fin_cut_scar_pts);
  var _span   = fin_cut_span;

  if (_scar_a > 0.01 && _scar_n > 1) {
    var _ax0 = _cut_ox,        _ay0 = _fch + _cut_oy;
    var _ax1 = _fcw + _cut_ox, _ay1 = _cut_oy;

    var _core = merge_color(global.avoid_col_warning, c_white, _cool * 0.85);
    if (fin_cut_release > 0) {
      _core = merge_color(_core, global.avoid_col_cyan_soft, fin_cut_release * 0.85);
    }
    var _chr = (2.0 + _cool * 2.6) * _gs;

    gpu_set_blendmode(bm_add);

    var _pxp = fin_cut_scar_pts[0];
    var _prx = lerp(_ax0, _ax1, _pxp.f) + _cpx * _pxp.off * _gs;
    var _pry = lerp(_ay0, _ay1, _pxp.f) + _cpy * _pxp.off * _gs;
    var _pna = clamp((_span - abs(_pxp.f * 2 - 1)) / 0.20, 0, 1);

    for (var _sn = 1; _sn < _scar_n; _sn++) {
      var _nxp = fin_cut_scar_pts[_sn];
      var _nrx = lerp(_ax0, _ax1, _nxp.f) + _cpx * _nxp.off * _gs;
      var _nry = lerp(_ay0, _ay1, _nxp.f) + _cpy * _nxp.off * _gs;
      var _nna = clamp((_span - abs(_nxp.f * 2 - 1)) / 0.20, 0, 1);
      var _sw  = (_pxp.w + _nxp.w) * 0.5;
      var _sa  = _scar_a * min(_pna, _nna);

      if (_sa <= 0.008) {
        _pxp = _nxp; _prx = _nrx; _pry = _nry; _pna = _nna;
        continue;
      }

      draw_set_color(merge_color(global.avoid_col_danger, global.avoid_col_ember, 0.35));
      draw_set_alpha(_sa * 0.115);
      draw_line_width(_prx, _pry, _nrx, _nry, (10 + _cool * 26) * _sw * _gs);

      draw_set_color(global.avoid_col_danger);
      draw_set_alpha(_sa * 0.26 * _cool);
      draw_line_width(_prx + _cpx * _chr, _pry + _cpy * _chr,
                      _nrx + _cpx * _chr, _nry + _cpy * _chr, 2.2 * _gs);

      draw_set_color(global.avoid_col_cyan);
      draw_set_alpha(_sa * (0.26 * _cool + fin_cut_release * 0.34));
      draw_line_width(_prx - _cpx * _chr, _pry - _cpy * _chr,
                      _nrx - _cpx * _chr, _nry - _cpy * _chr, 2.2 * _gs);

      draw_set_color(_core);
      draw_set_alpha(_sa * (0.34 + _cool * 0.34));
      draw_line_width(_prx, _pry, _nrx, _nry, (1.7 + _cool * 4.6) * _sw * _gs);

      draw_set_color(c_white);
      draw_set_alpha(_sa * (0.62 + _cool * 0.38));
      draw_line_width(_prx, _pry, _nrx, _nry, (1.0 + _cool * 1.3) * _gs);

      _pxp = _nxp;
      _prx = _nrx;
      _pry = _nry;
      _pna = _nna;
    }

    var _tip_s = clamp(fin_cut_span, 0, 1);
    if (_tip_s < 0.995) {
      var _tip_h = clamp((1 - _tip_s) * 3.2, 0, 1);
      var _tipc  = merge_color(global.avoid_col_hot, global.avoid_col_cyan_soft,
                               fin_cut_release * 0.9);

      for (var _tp = 0; _tp < 2; _tp++) {
        var _tf = 0.5 + ((_tp == 0) ? -0.5 : 0.5) * _tip_s;
        var _tx = lerp(_ax0, _ax1, _tf);
        var _ty = lerp(_ay0, _ay1, _tf);
        var _ta = _scar_a * _tip_h * (1 - fin_cut_release * 0.6);

        draw_set_color(merge_color(global.avoid_col_ember, global.avoid_col_cyan,
                                   fin_cut_release * 0.9));
        draw_set_alpha(_ta * 0.26);
        draw_circle(_tx, _ty, (7 + _cool * 7) * _gs, false);

        draw_set_color(_tipc);
        draw_set_alpha(_ta * 0.70);
        draw_circle(_tx, _ty, (2.4 + _cool * 2.2) * _gs, false);

        draw_set_color(c_white);
        draw_set_alpha(_ta * 0.92);
        draw_circle(_tx, _ty, 1.3 * _gs, false);
      }
    }

    gpu_set_blendmode(bm_normal);
  }

  if (array_length(final_cut_sparks) > 0) {
    gpu_set_blendmode(bm_add);
    for (var _sd = 0; _sd < array_length(final_cut_sparks); _sd++) {
      var _sp = final_cut_sparks[_sd];
      var _sa = power(clamp(_sp.life / _sp.life_max, 0, 1), 1.5);
      if (_sa <= 0.02) continue;

      var _sgx = _sp.x * _gs + _cut_ox;
      var _sgy = _sp.y * _gs + _cut_oy;
      var _stl = 3.2;

      var _scl = merge_color(global.avoid_col_blood, _sp.col, _sa);

      draw_set_color(_scl);
      draw_set_alpha(_sa * 0.42);
      draw_line_width(_sgx, _sgy,
                      (_sp.x - _sp.vx * _stl) * _gs + _cut_ox,
                      (_sp.y - _sp.vy * _stl) * _gs + _cut_oy,
                      max(1, _sp.size * _gs));

      draw_set_color(merge_color(_scl, c_white, 0.5 + _sp.hot * 0.5));
      draw_set_alpha(_sa * _sa * 0.9);
      draw_circle(_sgx, _sgy, max(0.7, _sp.size * 0.5 * _gs), false);
    }
    gpu_set_blendmode(bm_normal);
  }

  if (fin_cut_release > 0.001) {
    var _rl = power(fin_cut_release, 0.9);
    gpu_set_blendmode(bm_add);

    var _rf0 = 0.5 - clamp(fin_cut_span, 0, 1) * 0.5;
    var _rf1 = 0.5 + clamp(fin_cut_span, 0, 1) * 0.5;
    var _rx0 = lerp(0, _fcw, _rf0), _ry0 = lerp(_fch, 0, _rf0);
    var _rx1 = lerp(0, _fcw, _rf1), _ry1 = lerp(_fch, 0, _rf1);

    var _rw  = (60 + _rl * 210) * _gs;
    var _rox = _cpx * _rw, _roy = _cpy * _rw;
    var _rux = _fcw / _fdiag, _ruy = -_fch / _fdiag;
    var _rex = _rux * _rw * 0.9, _rey = _ruy * _rw * 0.9;
    var _rc  = global.avoid_col_cyan;

    var _rcx = [_rx0 - _rex, _rx0, _rx1, _rx1 + _rex];
    var _rcy = [_ry0 - _rey, _ry0, _ry1, _ry1 + _rey];
    var _rcw = [0, 1, 1, 0];
    var _rrx = [-_rox, 0, _rox];
    var _rry = [-_roy, 0, _roy];
    var _rrw = [0, 1, 0];
    var _rpk = _rl * 0.32;

    draw_primitive_begin(pr_trianglelist);
    for (var _rq = 0; _rq < 3; _rq++) {
      for (var _rr = 0; _rr < 2; _rr++) {
        var _rgi = [[_rq, _rr], [_rq + 1, _rr], [_rq + 1, _rr + 1],
                    [_rq, _rr], [_rq + 1, _rr + 1], [_rq, _rr + 1]];
        for (var _rv = 0; _rv < 6; _rv++) {
          var _rci = _rgi[_rv][0], _rri = _rgi[_rv][1];
          draw_vertex_colour(_rcx[_rci] + _rrx[_rri], _rcy[_rci] + _rry[_rri],
                             _rc, _rpk * _rcw[_rci] * _rrw[_rri]);
        }
      }
    }
    draw_primitive_end();

    draw_set_color(global.avoid_col_cyan_soft);
    draw_set_alpha(_rl * 0.32);
    draw_line_width(_rx0, _ry0, _rx1, _ry1, 11 * _gs);

    draw_set_color(c_white);
    draw_set_alpha(_rl * 0.46);
    draw_line_width(_rx0, _ry0, _rx1, _ry1, 2.0 * _gs);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_rl * _rl * 0.18);
    draw_rectangle(0, 0, _fcw, _fch, false);

    gpu_set_blendmode(bm_normal);
  }

  if (fin_cut_flash > 0.001) {
    draw_set_color(c_white);
    draw_set_alpha(clamp(fin_cut_flash * fx_get_mult_for("finalcut", "flash"), 0, 1));
    draw_rectangle(0, 0, _fcw, _fch, false);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

var _practice_hud_active =
  variable_global_exists("avoidance_practice_active") &&
  global.avoidance_practice_active;

var _hc_fade = 1;
if (final_cut_triggered) {
  _hc_fade = clamp(1 - (t - _k_fin_t_cut - 8) / 26, 0, 1);
}

if (global.hitcount_mode && !_practice_hud_active && _hc_fade > 0.004) {
  var _hc_hits = hit_count;
  var _hc_best_hits = savedata_get_active("avoidance_best_hits");

  var _hc_text = string(_hc_hits);
  if (_hc_hits < 10) _hc_text = "00" + _hc_text;
  else if (_hc_hits < 100) _hc_text = "0" + _hc_text;

  var _hc_best_text = (_hc_best_hits < 0) ? "---" : string(_hc_best_hits);
  if (_hc_best_hits >= 0 && _hc_best_hits < 10) _hc_best_text = "00" + _hc_best_text;
  else if (_hc_best_hits >= 0 && _hc_best_hits < 100) _hc_best_text = "0" + _hc_best_text;

  var _hc_pulse = instance_exists(oGame) ? oGame.hitcount_hud_pulse : 0;
  var _hc_shock = instance_exists(oGame) ? oGame.hitcount_hud_shock : 0;
  var _hc_w = 232;
  var _hc_h = 48;
  var _hc_x = (GAME_WIDTH - _hc_w) * 0.5;
  var _hc_y = 10 + sin(current_time * 0.075) * _hc_shock * 3;
  var _hc_hot = merge_color(global.avoid_col_warning, c_white, _hc_pulse * 0.45);
  var _hc_frame_col = merge_color(global.avoid_col_cyan, _hc_hot, _hc_pulse);
  var _hc_tick = 12;

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
  gpu_set_ztestenable(false);
  gpu_set_zwriteenable(false);

  draw_set_font(fDefault);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);

  draw_set_color(c_black);
  draw_set_alpha((0.42 + _hc_pulse * 0.08) * _hc_fade);
  draw_rectangle_color(_hc_x, _hc_y, _hc_x + _hc_w, _hc_y + _hc_h,
    c_black, c_black, global.avoid_col_armor_dark, global.avoid_col_armor_dark, false);

  gpu_set_blendmode(bm_add);
  draw_set_color(_hc_hot);
  draw_set_alpha((0.18 * _hc_pulse) * _hc_fade);
  draw_rectangle(_hc_x - 6, _hc_y - 4, _hc_x + _hc_w + 6, _hc_y + _hc_h + 4, false);

  draw_set_color(_hc_frame_col);
  draw_set_alpha((0.62 + _hc_pulse * 0.3) * _hc_fade);
  draw_line_width(_hc_x, _hc_y, _hc_x + _hc_tick, _hc_y, 2);
  draw_line_width(_hc_x, _hc_y, _hc_x, _hc_y + _hc_tick, 2);
  draw_line_width(_hc_x + _hc_w, _hc_y, _hc_x + _hc_w - _hc_tick, _hc_y, 2);
  draw_line_width(_hc_x + _hc_w, _hc_y, _hc_x + _hc_w, _hc_y + _hc_tick, 2);
  draw_line_width(_hc_x, _hc_y + _hc_h, _hc_x + _hc_tick, _hc_y + _hc_h, 2);
  draw_line_width(_hc_x, _hc_y + _hc_h, _hc_x, _hc_y + _hc_h - _hc_tick, 2);
  draw_line_width(_hc_x + _hc_w, _hc_y + _hc_h, _hc_x + _hc_w - _hc_tick, _hc_y + _hc_h, 2);
  draw_line_width(_hc_x + _hc_w, _hc_y + _hc_h, _hc_x + _hc_w, _hc_y + _hc_h - _hc_tick, 2);

  var _hc_pip_x = _hc_x + 92;
  var _hc_pip_y = _hc_y + 31;
  var _hc_pip_n = 10;
  var _hc_pip_lit = min(_hc_hits, _hc_pip_n);
  for (var _hc_pi = 0; _hc_pi < _hc_pip_n; _hc_pi++) {
    var _hc_lit = (_hc_pi < _hc_pip_lit);
    draw_set_color(_hc_lit ? _hc_hot : global.avoid_col_cyan);
    draw_set_alpha((_hc_lit ? (0.52 + _hc_pulse * 0.35) : 0.16) * _hc_fade);
    draw_rectangle(_hc_pip_x + _hc_pi * 6, _hc_pip_y,
                   _hc_pip_x + _hc_pi * 6 + 3, _hc_pip_y + 8 + _hc_pulse * 2, false);
  }
  gpu_set_blendmode(bm_normal);

  draw_set_alpha((0.76) * _hc_fade);
  draw_set_color(global.avoid_col_cyan_soft);
  draw_text_transformed(_hc_x + 14, _hc_y + 7, "HIT COUNT", 0.48, 0.48, 0);

  draw_set_color(_hc_hot);
  draw_set_alpha((0.92 + _hc_pulse * 0.08) * _hc_fade);
  draw_text_transformed(_hc_x + 14 - _hc_shock, _hc_y + 20,
                        _hc_text, 1.05 + _hc_pulse * 0.08, 1.05, 0);

  if (_hc_hits > _hc_pip_n) {
    draw_set_color(_hc_hot);
    draw_set_alpha((0.84) * _hc_fade);
    draw_text_transformed(_hc_pip_x + _hc_pip_n * 6 + 3, _hc_pip_y - 4, "+", 0.62, 0.62, 0);
  }

  draw_set_halign(fa_right);
  draw_set_color(global.avoid_col_cyan_soft);
  draw_set_alpha((0.58) * _hc_fade);
  draw_text_transformed(_hc_x + _hc_w - 14, _hc_y + 8, "BEST", 0.42, 0.42, 0);
  draw_set_color(c_white);
  draw_set_alpha((0.78) * _hc_fade);
  draw_text_transformed(_hc_x + _hc_w - 14, _hc_y + 24, _hc_best_text, 0.62, 0.62, 0);

  draw_set_alpha((1) * _hc_fade);
  draw_set_color(c_white);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  gpu_set_blendmode(bm_normal);
}

if (_practice_hud_active && practice_hud_timer < 144) {
  var _pr_w = 324;
  var _pr_h = 58;
  var _pr_x = (GAME_WIDTH - _pr_w) * 0.5;
  var _pr_slide = clamp((practice_hud_timer - 104) / 40, 0, 1);
  _pr_slide = _pr_slide * _pr_slide * (3 - 2 * _pr_slide);
  var _pr_y = lerp(10, -_pr_h - 12, _pr_slide);
  var _pr_alpha = 1 - _pr_slide * 0.35;
  var _pr_tick = 12;
  var _pr_pulse = 0.5 + 0.5 * sin(current_time * 0.006);
  var _pr_hot = merge_color(global.avoid_col_cyan, c_white, 0.18 + _pr_pulse * 0.12);
  var _pr_frame_col = merge_color(global.avoid_col_cyan, global.avoid_col_warning, 0.18 + _pr_pulse * 0.16);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
  gpu_set_ztestenable(false);
  gpu_set_zwriteenable(false);

  draw_set_font(fDefault);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);

  draw_set_color(c_black);
  draw_set_alpha(0.52 * _pr_alpha);
  draw_rectangle_color(_pr_x, _pr_y, _pr_x + _pr_w, _pr_y + _pr_h,
    c_black, c_black, global.avoid_col_armor_dark, global.avoid_col_armor_dark, false);

  gpu_set_blendmode(bm_add);
  draw_set_color(_pr_hot);
  draw_set_alpha((0.06 + _pr_pulse * 0.035) * _pr_alpha);
  draw_rectangle(_pr_x - 6, _pr_y - 4, _pr_x + _pr_w + 6, _pr_y + _pr_h + 4, false);

  draw_set_color(_pr_frame_col);
  draw_set_alpha((0.58 + _pr_pulse * 0.1) * _pr_alpha);
  draw_line_width(_pr_x, _pr_y, _pr_x + _pr_tick, _pr_y, 2);
  draw_line_width(_pr_x, _pr_y, _pr_x, _pr_y + _pr_tick, 2);
  draw_line_width(_pr_x + _pr_w, _pr_y, _pr_x + _pr_w - _pr_tick, _pr_y, 2);
  draw_line_width(_pr_x + _pr_w, _pr_y, _pr_x + _pr_w, _pr_y + _pr_tick, 2);
  draw_line_width(_pr_x, _pr_y + _pr_h, _pr_x + _pr_tick, _pr_y + _pr_h, 2);
  draw_line_width(_pr_x, _pr_y + _pr_h, _pr_x, _pr_y + _pr_h - _pr_tick, 2);
  draw_line_width(_pr_x + _pr_w, _pr_y + _pr_h, _pr_x + _pr_w - _pr_tick, _pr_y + _pr_h, 2);
  draw_line_width(_pr_x + _pr_w, _pr_y + _pr_h, _pr_x + _pr_w, _pr_y + _pr_h - _pr_tick, 2);
  gpu_set_blendmode(bm_normal);

  draw_set_color(global.avoid_col_cyan_soft);
  draw_set_alpha(0.9 * _pr_alpha);
  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_text_transformed(_pr_x + _pr_w * 0.5, _pr_y + 15, "PRACTICE MODE", 0.58, 0.58, 0);

  var _pr_key_x1 = _pr_x + 28;
  var _pr_key_y1 = _pr_y + 32;
  var _pr_key_x2 = _pr_key_x1 + 116;
  var _pr_key_y2 = _pr_key_y1 + 20;
  var _pr_row_y = (_pr_key_y1 + _pr_key_y2) * 0.5;

  draw_set_color(global.avoid_col_cyan);
  draw_set_alpha(0.38 * _pr_alpha);
  draw_rectangle(_pr_key_x1, _pr_key_y1, _pr_key_x2, _pr_key_y2, false);
  draw_set_color(global.avoid_col_cyan_soft);
  draw_set_alpha(0.6 * _pr_alpha);
  draw_rectangle(_pr_key_x1, _pr_key_y1, _pr_key_x2, _pr_key_y2, true);
  draw_set_color(c_white);
  draw_set_alpha(0.96 * _pr_alpha);
  draw_text_transformed((_pr_key_x1 + _pr_key_x2) * 0.5, _pr_row_y, "BACKSPACE", 0.48, 0.48, 0);

  draw_set_color(c_white);
  draw_set_alpha(0.98 * _pr_alpha);
  draw_set_halign(fa_left);
  draw_text_transformed(_pr_key_x2 + 16, _pr_row_y, "RETURN TO HUB", 0.56, 0.56, 0);

  draw_set_alpha(1);
  draw_set_color(c_white);
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  gpu_set_blendmode(bm_normal);
}

if (instance_exists(oGameover))
{
    shader_reset();

    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
    gpu_set_ztestenable(false);
    gpu_set_zwriteenable(false);

    draw_set_alpha(1);
    draw_set_color(c_white);

    with (oGameover)
    {
        event_perform(ev_draw, ev_gui_end);
    }
}

if (DEBUG &&
    variable_global_exists("bc_cli_profile_capture_enabled") &&
    global.bc_cli_profile_capture_enabled &&
    bc_profile_active &&
    bc_profile_should_capture_frame(bc_profile_frame, bc_profile_target_frames)) {
  var _bc_capture_index = global.bc_cli_profile_index + 1;
  var _bc_capture_segment = string(_bc_capture_index);
  if (_bc_capture_index < 10) _bc_capture_segment = "0" + _bc_capture_segment;
  bc_profile_capture_frame("avoidance_" + _bc_capture_segment, bc_profile_frame);
}
