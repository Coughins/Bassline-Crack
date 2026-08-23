function scr_draw_avoidance_tree_fruit_glow_helpers() {
  scr_draw_avoidance_tree_root_telegraph();
  scr_draw_avoidance_tree_ignition_spark();
  scr_draw_avoidance_tree_payoff_flash();
  scr_draw_avoidance_tree_embers();
  scr_draw_avoidance_tree_node_glow();
  scr_draw_avoidance_fruit_idle_glow();
  scr_draw_avoidance_fruit_charge_arcs();
  scr_draw_avoidance_storm_charge_orb();
  scr_draw_avoidance_fruit_burst_flash();
  scr_draw_avoidance_dna_test_glow();
  scr_draw_avoidance_big_red_orb_glow();
}

function scr_draw_avoidance_fruit_seed_projectile(_x, _y, _xscale = 1, _yscale = 1, _angle = 0,
                                                 _alpha = 1, _fruit_color = c_red,
                                                 _heat = 1, _ring_power = 1, _seed = 0,
                                                 _sprite = sWhiteOrb, _subimg = 0,
                                                 _move_dir = 0, _move_speed = 0,
                                                 _cocoon_shift = 0) {
  if (_alpha <= 0.004) return;

  var _scale = max(abs(_xscale), abs(_yscale));
  var _pulse = 0.5 + 0.5 * sin(current_time * 0.018 + _seed);
  _cocoon_shift = clamp(_cocoon_shift, 0, 1);
  var _cocoon_edge = merge_color(global.avoid_col_cyan_soft, c_white, 0.22);
  var _cocoon_deep = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, 0.68);
  var _blood_seed = merge_color(global.avoid_col_blood, _cocoon_deep, _cocoon_shift);
  var _sap_col = merge_color(_blood_seed, _fruit_color, clamp(0.38 + _heat * 0.45, 0, 1));
  var _body_col = merge_color(_blood_seed, _fruit_color, clamp(0.44 + _heat * 0.25, 0, 1));
  var _core_col = merge_color(_fruit_color, c_white, clamp(0.36 + _heat * 0.35, 0, 0.9));
  _sap_col = merge_color(_sap_col, _cocoon_edge, _cocoon_shift * 0.72);
  _body_col = merge_color(_body_col, _cocoon_deep, _cocoon_shift * 0.48);
  _core_col = merge_color(_core_col, c_white, _cocoon_shift * 0.55);
  var _tail_hot_col = merge_color(global.avoid_col_danger, _cocoon_edge, _cocoon_shift);
  var _tail_cool_col = merge_color(global.avoid_col_cyan, c_white, _cocoon_shift * 0.55);
  var _ring_r = (9.5 + _heat * 4.8 + _pulse * (2.2 + _ring_power * 1.4)) * _scale;
  var _ring_a = _alpha * clamp(0.24 + _ring_power * 0.36 + _heat * 0.18, 0, 1.1);

  gpu_set_blendmode(bm_add);

  if (_move_speed > 2) {
    var _tail_len = min(_move_speed * (1.7 + _heat * 0.35), 54);
    var _tail_x = _x - lengthdir_x(_tail_len, _move_dir);
    var _tail_y = _y - lengthdir_y(_tail_len, _move_dir);
    var _perp = _move_dir + 90;
    var _off = 1.6 + _ring_power * 0.9;

    draw_set_color(_tail_hot_col);
    draw_set_alpha(_alpha * 0.28);
    draw_line_width(_tail_x + lengthdir_x(_off, _perp), _tail_y + lengthdir_y(_off, _perp),
                    _x + lengthdir_x(_off, _perp), _y + lengthdir_y(_off, _perp), 4.2 * _scale);
    draw_set_color(_tail_cool_col);
    draw_set_alpha(_alpha * 0.22);
    draw_line_width(_tail_x - lengthdir_x(_off, _perp), _tail_y - lengthdir_y(_off, _perp),
                    _x - lengthdir_x(_off, _perp), _y - lengthdir_y(_off, _perp), 3.2 * _scale);
    draw_set_color(_sap_col);
    draw_set_alpha(_alpha * 0.48);
    draw_line_width(_tail_x, _tail_y, _x, _y, max(2, 5.8 * _scale));
    draw_set_color(c_white);
    draw_set_alpha(_alpha * 0.72);
    draw_line_width(lerp(_tail_x, _x, 0.22), lerp(_tail_y, _y, 0.22), _x, _y, max(0.9, 1.5 * _scale));
  }

  draw_set_color(_sap_col);
  draw_set_alpha(_ring_a * 0.65);
  draw_circle(_x, _y, _ring_r, true);
  draw_set_color(_tail_cool_col);
  draw_set_alpha(_ring_a * 0.2);
  draw_circle(_x, _y, _ring_r * 0.66, true);
  draw_set_color(c_white);
  draw_set_alpha(_ring_a * 0.28);
  draw_circle(_x, _y, _ring_r * 0.84, true);

  var _ring_rot = _angle + current_time * (0.035 + _heat * 0.015) + _seed * 0.17;
  for (var _ri = 0; _ri < 3; _ri++) {
    var _ra = _ring_rot + _ri * 120;
    draw_set_color(merge_color(_sap_col, c_white, 0.4));
    draw_set_alpha(_ring_a * 0.85);
    draw_line_width(_x + lengthdir_x(_ring_r * 0.72, _ra),
                    _y + lengthdir_y(_ring_r * 0.72, _ra),
                    _x + lengthdir_x(_ring_r * 1.12, _ra),
                    _y + lengthdir_y(_ring_r * 1.12, _ra), max(0.9, 1.1 * _scale));
  }

  var _bead_ang = _ring_rot + 64;
  draw_set_color(c_white);
  draw_set_alpha(_ring_a);
  draw_circle(_x + lengthdir_x(_ring_r, _bead_ang), _y + lengthdir_y(_ring_r, _bead_ang),
              max(1.2, 1.8 * _scale), false);

  gpu_set_blendmode(bm_normal);

  draw_sprite_ext(_sprite, _subimg, _x, _y,
                  _xscale * (1 + _heat * 0.08), _yscale * (1 + _heat * 0.08),
                  _angle, _body_col, _alpha);

  gpu_set_blendmode(bm_add);

  shader_set(shd_bullet_glow);
  var _uvs_seed = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs_seed[0], _uvs_seed[1], _uvs_seed[2], _uvs_seed[3]);
  shader_set_uniform_f(global.u_glow_color, color_get_red(_sap_col) / 255, color_get_green(_sap_col) / 255,
                       color_get_blue(_sap_col) / 255);
  shader_set_uniform_f(global.u_glow_intensity, _alpha * (0.7 + _heat * 0.85));
  shader_set_uniform_f(global.u_glow_falloff, 1.45);
  draw_sprite_ext(spr_glow_blob, 0, _x, _y, _scale * (0.52 + _heat * 0.18),
                  _scale * (0.52 + _heat * 0.18), 0, c_white, 1);

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, _alpha * (0.85 + _heat * 0.9));
  shader_set_uniform_f(global.u_glow_falloff, 2.35);
  draw_sprite_ext(spr_glow_blob, 0, _x, _y, _scale * 0.26, _scale * 0.26, 0, c_white, 1);
  shader_reset();

  draw_sprite_ext(_sprite, _subimg, _x, _y,
                  _xscale * (1.45 + _heat * 0.18), _yscale * (1.45 + _heat * 0.18),
                  _angle, _fruit_color, _alpha * (0.16 + _heat * 0.24));
  draw_sprite_ext(_sprite, _subimg, _x, _y,
                  _xscale * 0.5, _yscale * 0.5, _angle,
                  c_white, _alpha * (0.32 + _heat * 0.42));

  draw_set_color(_core_col);
  draw_set_alpha(_alpha * (0.36 + _heat * 0.38));
  for (var _vi = 0; _vi < 4; _vi++) {
    var _va = _angle + _seed * 0.31 + _vi * 93;
    var _vr = (3.5 + _heat * 5 + _pulse * 1.2) * _scale;
    draw_line_width(_x, _y,
                    _x + lengthdir_x(_vr, _va),
                    _y + lengthdir_y(_vr, _va), max(0.7, 0.9 * _scale));
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);
}

function scr_tree_root_rake_eval(_rk) {
  var _warn = clamp((t - _rk.warn_t) / max(1, _rk.acquire_t - _rk.warn_t), 0, 1);
  var _acquire = clamp((t - _rk.acquire_t) / max(1, _rk.tense_t - _rk.acquire_t), 0, 1);
  var _tense = clamp((t - _rk.tense_t) / max(1, _rk.strike_t - _rk.tense_t), 0, 1);
  var _strike = clamp((t - _rk.strike_t) / max(1, _rk.hold_t - _rk.strike_t), 0, 1);
  var _release = clamp((t - _rk.hold_t) / max(1, _rk.release_t - _rk.hold_t), 0, 1);
  var _warn_e = _warn * _warn;
  var _acq_e = 1 - power(1 - _acquire, 2.2);
  var _tense_e = power(_tense, 1.6);
  var _strike_e = 1 - power(1 - _strike, 3.0);
  var _release_e = power(_release, 0.7);
  var _visible = (t >= _rk.warn_t && t < _rk.release_t + 18);
  var _alpha = _visible ? clamp(0.12 + _warn_e * 0.28 + _acq_e * 0.34 + _strike_e * 0.42, 0, 1) : 0;
  _alpha *= (1 - _release_e * 0.82);
  var _reach = _rk.reach * clamp(0.16 + _warn_e * 0.22 + _acq_e * 0.28 + _strike_e * 0.68, 0, 1.18);
  var _lift = _rk.lift * (_tense_e * 0.24 + _strike_e * 0.76) * (1 - _release_e * 0.55);
  var _heat = clamp(_tense_e * 0.45 + _strike_e * 0.7 + tree_root_rake_flash * 0.35, 0, 1.35);
  var _active = (t >= _rk.strike_t && t < _rk.hold_t && _strike_e > 0.16);

  return {
    visible : _visible && _alpha > 0.01,
    active : _active,
    warn : _warn_e,
    acquire : _acq_e,
    tense : _tense_e,
    strike : _strike_e,
    release : _release_e,
    alpha : _alpha,
    reach : _reach,
    lift : _lift,
    heat : _heat
  };
}

function scr_tree_root_rake_geom(_rk, _ev, _claw) {
  var _side = _rk.side;
  var _floor = tree_root_rake_floor_y;
  var _root_x = (_side < 0) ? tree_root_base_xs[0] : tree_root_base_xs[array_length(tree_root_base_xs) - 1];
  var _edge_x = (_side < 0) ? -22 : room_width + 22;
  var _base_y = _floor - 2 - _claw * 19;
  var _reach = _ev.reach * (0.90 + _claw * 0.09);
  var _tip_x = (_side < 0) ? _reach + _claw * 13 : room_width - _reach - _claw * 13;
  var _tip_y = _floor - (36 + _claw * 43) - _ev.lift * (0.18 + _claw * 0.10);
  var _mid_x = lerp(_edge_x, _tip_x, 0.52 + _claw * 0.035);
  var _mid_y = lerp(_base_y, _tip_y, 0.46) + (1 - _ev.strike) * (28 + _claw * 10) - _ev.tense * (12 + _claw * 8);
  var _root_pull = clamp(_ev.warn + _ev.acquire + _ev.strike, 0, 1);
  var _floor_x = lerp(_root_x, _edge_x, _root_pull);
  var _w = max(4, (26 - _claw * 4.5) * _rk.weight * (0.38 + _ev.alpha * 0.78) * (1 - _ev.release * 0.42));

  return {
    root_x : _root_x,
    root_y : _floor,
    floor_x : _floor_x,
    edge_x : _edge_x,
    sx : _edge_x,
    sy : _base_y,
    mx : _mid_x,
    my : _mid_y,
    tx : _tip_x,
    ty : _tip_y,
    w : _w
  };
}

function scr_tree_root_rake_collision() {
  if (!instance_exists(oPlayer)) return;
  if (!variable_instance_exists(id, "tree_root_rakes")) return;

  for (var _ri = 0; _ri < array_length(tree_root_rakes); _ri++) {
    var _rk = tree_root_rakes[_ri];
    var _ev = scr_tree_root_rake_eval(_rk);
    if (!_ev.active) continue;

    for (var _claw = 0; _claw < 3; _claw++) {
      var _g = scr_tree_root_rake_geom(_rk, _ev, _claw);
      var _hit_r = tree_root_rake_hit_radius * (1 - _claw * 0.12) * (0.82 + _ev.strike * 0.18);
      if (player_meeting_line_width(_g.sx, _g.sy, _g.mx, _g.my, _hit_r) ||
          player_meeting_line_width(_g.mx, _g.my, _g.tx, _g.ty, _hit_r * 0.92)) {
        player_register_hazard_hit();
        return;
      }
    }
  }
}

function scr_tree_root_rake_curve_point(_g, _u) {
  var _a_x = lerp(_g.sx, _g.mx, _u);
  var _a_y = lerp(_g.sy, _g.my, _u);
  var _b_x = lerp(_g.mx, _g.tx, _u);
  var _b_y = lerp(_g.my, _g.ty, _u);

  return {
    x : lerp(_a_x, _b_x, _u),
    y : lerp(_a_y, _b_y, _u)
  };
}

function scr_draw_tree_matched_branch_segment(_x0, _y0, _x1, _y1,
                                              _parent_scale, _child_scale,
                                              _alpha, _heat, _current,
                                              _network_flash, _role,
                                              _spur_count, _bark_seed, _vein_seed) {
  var _seg_len = point_distance(_x0, _y0, _x1, _y1);
  var _draw_alpha = clamp(_alpha, 0, 1);
  if (_seg_len <= 1 || _draw_alpha <= 0.01) return;

  var _branch_heat = clamp(_heat + _network_flash * 0.65, 0, 1);
  var _branch_current = clamp(_current + _network_flash, 0, 1.4);
  var _ignite_color_unlit = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, 0.58);
  var _ignite_color_hot = merge_color(global.tree_fire_color, global.avoid_col_danger, 0.22);
  var _image_blend = merge_color(_ignite_color_unlit, _ignite_color_hot, _branch_heat);
  var _body_col = merge_color(global.avoid_col_armor_dark, global.avoid_col_blood, 0.35 + _branch_heat * 0.45);
  var _bark_black = merge_color(c_black, global.avoid_col_blood, 0.18 + _branch_heat * 0.18);
  var _bark_ridge_col = merge_color(global.avoid_col_armor_dark, c_black, 0.32);
  var _sap_col = merge_color(global.avoid_col_blood, _ignite_color_hot, _branch_heat);
  var _edge_col = merge_color(_ignite_color_unlit, global.avoid_col_danger, _branch_heat);
  var _hot_col = merge_color(_sap_col, c_white, clamp(_branch_heat * 0.65 + _network_flash * 0.35, 0, 0.9));
  var _seg_dir = point_direction(_x0, _y0, _x1, _y1);
  var _seg_perp = _seg_dir + 90;
  var _w_child = max(1.45, _child_scale * 2.75);
  var _w_parent = max(_w_child, _parent_scale * 2.45);
  var _role_mass = 1 + _role * 0.12;
  _w_child *= _role_mass;
  _w_parent *= _role_mass;

  var _px1 = _x0 + lengthdir_x(_w_parent, _seg_perp);
  var _py1 = _y0 + lengthdir_y(_w_parent, _seg_perp);
  var _px2 = _x0 - lengthdir_x(_w_parent, _seg_perp);
  var _py2 = _y0 - lengthdir_y(_w_parent, _seg_perp);
  var _cx1 = _x1 + lengthdir_x(_w_child, _seg_perp);
  var _cy1 = _y1 + lengthdir_y(_w_child, _seg_perp);
  var _cx2 = _x1 - lengthdir_x(_w_child, _seg_perp);
  var _cy2 = _y1 - lengthdir_y(_w_child, _seg_perp);

  gpu_set_blendmode(bm_normal);
  draw_set_color(c_black);
  draw_set_alpha(_draw_alpha * (0.22 + _role * 0.08));
  draw_line_width(_x0 + 1.5, _y0 + 2, _x1 + 1.5, _y1 + 2, max(_w_parent * 2.05, 5));

  draw_primitive_begin(pr_trianglestrip);
  draw_vertex_colour(_px1, _py1, _body_col, _draw_alpha * 0.74);
  draw_vertex_colour(_px2, _py2, _body_col, _draw_alpha * 0.74);
  draw_vertex_colour(_cx1, _cy1, _body_col, _draw_alpha * 0.88);
  draw_vertex_colour(_cx2, _cy2, _body_col, _draw_alpha * 0.88);
  draw_primitive_end();

  draw_set_color(merge_color(_body_col, c_black, 0.28));
  draw_set_alpha(_draw_alpha * 0.55);
  draw_line_width(_x0, _y0, _x1, _y1, max(_w_child * 1.25, 2.4));

  var _ridge_off = max(1.4, _w_child * 0.42);
  draw_set_color(_bark_ridge_col);
  draw_set_alpha(_draw_alpha * 0.52);
  draw_line_width(_x0 + lengthdir_x(_ridge_off, _seg_perp),
                  _y0 + lengthdir_y(_ridge_off, _seg_perp),
                  _x1 + lengthdir_x(_ridge_off * 0.72, _seg_perp),
                  _y1 + lengthdir_y(_ridge_off * 0.72, _seg_perp),
                  max(0.9, _w_child * 0.22));
  draw_line_width(_x0 - lengthdir_x(_ridge_off, _seg_perp),
                  _y0 - lengthdir_y(_ridge_off, _seg_perp),
                  _x1 - lengthdir_x(_ridge_off * 0.72, _seg_perp),
                  _y1 - lengthdir_y(_ridge_off * 0.72, _seg_perp),
                  max(0.9, _w_child * 0.18));

  gpu_set_blendmode(bm_add);
  draw_set_color(_sap_col);
  draw_set_alpha(_draw_alpha * (0.20 + _branch_heat * 0.24));
  draw_line_width(_x0, _y0, _x1, _y1, max(_w_child * 0.72, 1.4));

  if (_branch_current > 0.05) {
    var _flow_count = 1 + floor(clamp(_branch_current, 0, 1.4) * 2.2);
    var _pulse_len = clamp(0.15 + _branch_current * 0.13, 0.15, 0.38);
    var _vein_w = max(1.0, _w_child * 0.3);

    for (var _fi = 0; _fi < _flow_count; _fi++) {
      var _phase = _fi / max(1, _flow_count);
      var _pulse = frac(current_time * (0.0011 + _branch_current * 0.00065) + _vein_seed * 0.013 + _phase);
      var _ta = clamp(_pulse - _pulse_len * 0.5, 0, 1);
      var _tb = clamp(_pulse + _pulse_len * 0.5, 0, 1);
      var _j0 = sin(_vein_seed + current_time * 0.017 + _fi * 11.7) * _w_child * 0.12;
      var _j1 = cos(_vein_seed * 0.7 + current_time * 0.019 + _fi * 9.3) * _w_child * 0.12;
      var _vx1 = lerp(_x0, _x1, _ta) + lengthdir_x(_j0, _seg_perp);
      var _vy1 = lerp(_y0, _y1, _ta) + lengthdir_y(_j0, _seg_perp);
      var _vx2 = lerp(_x0, _x1, _tb) + lengthdir_x(_j1, _seg_perp);
      var _vy2 = lerp(_y0, _y1, _tb) + lengthdir_y(_j1, _seg_perp);
      var _flow_col = (_fi mod 2 == 0)
        ? merge_color(global.avoid_col_cyan, c_white, _branch_heat * 0.35)
        : merge_color(_sap_col, c_white, 0.25 + _branch_heat * 0.35);

      draw_set_color(_flow_col);
      draw_set_alpha(_draw_alpha * clamp(_branch_current, 0, 1) * (0.32 + _branch_heat * 0.24));
      draw_line_width(_vx1, _vy1, _vx2, _vy2, _vein_w * (1.35 + _branch_heat * 0.45));
      draw_set_color(c_white);
      draw_set_alpha(_draw_alpha * clamp(_branch_current - 0.2, 0, 1) * 0.75);
      draw_line_width(_vx1, _vy1, _vx2, _vy2, max(0.75, _vein_w * 0.42));
    }
  }

  if (_branch_heat > 0.08) {
    draw_set_color(_hot_col);
    draw_set_alpha(_draw_alpha * _branch_heat * 0.75);
    draw_line_width(_x0, _y0, _x1, _y1, max(0.8, _w_child * 0.22));
  }

  if (_seg_len > 14 && _spur_count > 0) {
    gpu_set_blendmode(bm_normal);
    for (var _spi = 0; _spi < _spur_count; _spi++) {
      var _rnd0 = frac(abs(sin(_bark_seed + _spi * 19.37) * 43758.5453));
      var _rnd1 = frac(abs(sin(_bark_seed + _spi * 31.11) * 24634.6345));
      var _rnd2 = frac(abs(sin(_bark_seed + _spi * 47.73) * 12615.1221));
      var _sf = lerp(0.16, 0.84, _rnd0);
      var _side = (_rnd1 < 0.5) ? -1 : 1;
      var _spur_len = lerp(5, 13 + _role * 4, _rnd2) * clamp(_seg_len / 60, 0.55, 1.1);
      var _spur_ang = _seg_perp + ((_side < 0) ? 180 : 0) + _side * (18 + _rnd2 * 28);
      var _spur_x = lerp(_x0, _x1, _sf);
      var _spur_y = lerp(_y0, _y1, _sf);
      var _spur_base_off = _w_child * lerp(0.26, 0.42, _sf);
      var _spur_bx = _spur_x + lengthdir_x(_spur_base_off * _side, _seg_perp);
      var _spur_by = _spur_y + lengthdir_y(_spur_base_off * _side, _seg_perp);
      var _spur_ex = _spur_bx + lengthdir_x(_spur_len, _spur_ang);
      var _spur_ey = _spur_by + lengthdir_y(_spur_len, _spur_ang);

      draw_set_color(_bark_black);
      draw_set_alpha(_draw_alpha * (0.42 + _role * 0.12));
      draw_line_width(_spur_bx, _spur_by, _spur_ex, _spur_ey, max(1.1, _w_child * 0.26));

      if (_branch_heat > 0.35 || _network_flash > 0.1) {
        gpu_set_blendmode(bm_add);
        draw_set_color(_hot_col);
        draw_set_alpha(_draw_alpha * clamp(_branch_heat + _network_flash, 0, 1) * 0.28);
        draw_line_width(_spur_bx, _spur_by,
                        lerp(_spur_bx, _spur_ex, 0.72),
                        lerp(_spur_by, _spur_ey, 0.72),
                        max(0.7, _w_child * 0.08));
        gpu_set_blendmode(bm_normal);
      }
    }
    gpu_set_blendmode(bm_add);
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);

  var _angle = point_direction(_x1, _y1, _x0, _y0);
  var _length_scale = _seg_len / max(1, sprite_get_width(sWhiteOrb));
  var _img_xs = _child_scale * _length_scale;
  var _img_ys = _child_scale * 0.62;
  draw_sprite_ext(sWhiteOrb, 0, _x1, _y1,
                  _img_xs, _img_ys * 0.86, _angle,
                  merge_color(_body_col, _image_blend, 0.42), _draw_alpha * 0.42);

  if (_draw_alpha > 0.02 && (_role >= 1 || _spur_count >= 4)) {
    var _socket_r = _child_scale * 2.1;
    var _socket_a = _draw_alpha * 0.38;
    gpu_set_blendmode(bm_normal);
    draw_set_color(_bark_black);
    draw_set_alpha(_socket_a);
    draw_circle(_x1, _y1, max(1.3, _socket_r), false);

    gpu_set_blendmode(bm_add);
    draw_set_color(_sap_col);
    draw_set_alpha(_draw_alpha * (0.18 + _branch_current * 0.16));
    draw_circle(_x1, _y1, max(1.0, _socket_r * 0.72), true);
    draw_set_color(c_white);
    draw_set_alpha(_draw_alpha * clamp(_branch_current + _branch_heat, 0, 1) * 0.24);
    draw_circle(_x1, _y1, max(0.8, _socket_r * 0.34), false);
  }

  gpu_set_blendmode(bm_add);
  draw_set_color(_edge_col);
  draw_set_alpha(_draw_alpha * (0.16 + _branch_current * 0.18));
  draw_circle(_x1, _y1, max(1.4, _child_scale * 2.2), false);
  if (_branch_heat > 0.05 || _network_flash > 0.4) {
    draw_set_color(_hot_col);
    draw_set_alpha(_draw_alpha * (0.35 + _branch_heat * 0.45));
    draw_circle(_x1, _y1, max(1.0, _child_scale * 1.15), false);
    draw_set_color(c_white);
    draw_set_alpha(_draw_alpha * clamp(_branch_heat + _network_flash, 0, 1) * 0.55);
    draw_circle(_x1, _y1, max(0.8, _child_scale * 0.55), false);
  }
  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendmode(bm_normal);

  gpu_set_blendmode(bm_add);
  shader_set(shd_bullet_glow);
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
  shader_set_uniform_f(global.u_glow_color, color_get_red(_image_blend) / 255,
                       color_get_green(_image_blend) / 255,
                       color_get_blue(_image_blend) / 255);
  shader_set_uniform_f(global.u_glow_intensity,
                       (0.28 + _branch_current * 0.28 + _branch_heat * 0.42) * _draw_alpha);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);
  draw_sprite_ext(spr_glow_blob, 0, _x1, _y1, _img_xs * 0.75, _img_ys * 1.6, _angle, c_white, 1);
  shader_reset();
  gpu_set_blendmode(bm_normal);
}

function scr_draw_tree_root_rakes_mass() {
  if (!variable_instance_exists(id, "tree_root_rakes")) return;

  for (var _ri = 0; _ri < array_length(tree_root_rakes); _ri++) {
    var _rk = tree_root_rakes[_ri];
    var _ev = scr_tree_root_rake_eval(_rk);
    if (!_ev.visible) continue;

    var _side = _rk.side;
    var _floor = tree_root_rake_floor_y;
    var _root_x = (_side < 0) ? tree_root_base_xs[0] : tree_root_base_xs[array_length(tree_root_base_xs) - 1];
    var _edge_x = (_side < 0) ? -22 : room_width + 22;
    var _mat_heat = clamp(_ev.heat, 0, 1);
    var _mat_current = clamp(0.12 + _ev.warn * 0.18 + _ev.acquire * 0.32 + _ev.tense * 0.46 + _ev.strike * 0.54, 0, 1.4);
    var _network_flash = clamp(tree_network_flash * 0.55 + tree_root_rake_flash * 0.45, 0, 1);
    var _feed_extent = clamp(max(_ev.warn, _ev.acquire * 0.9 + _ev.strike * 0.1), 0, 1);
    var _seed = _rk.seed;

    if (_feed_extent > 0.01) {
      var _prev_x = _root_x;
      var _prev_y = _floor + 1;
      var _prev_scale = 4.9 * _rk.weight;
      var _feed_segments = 5;
      for (var _fs = 1; _fs <= _feed_segments; _fs++) {
        var _fu = _feed_extent * (_fs / _feed_segments);
        var _fx = lerp(_root_x, _edge_x, _fu);
        var _fy = _floor - 1 - sin(_fu * pi) * (5 + _ev.tense * 5);
        var _child_scale = lerp(4.9, 3.3, _fu) * _rk.weight;
        scr_draw_tree_matched_branch_segment(_prev_x, _prev_y, _fx, _fy,
                                             _prev_scale, _child_scale,
                                             _ev.alpha * (0.72 + _ev.acquire * 0.18),
                                             _mat_heat * 0.78, _mat_current,
                                             _network_flash, 2, 4,
                                             _seed + _fs * 12.7, _seed + _fs * 19.3);
        _prev_x = _fx;
        _prev_y = _fy;
        _prev_scale = _child_scale;
      }
    }

    for (var _claw = 0; _claw < 3; _claw++) {
      var _g = scr_tree_root_rake_geom(_rk, _ev, _claw);
      var _last = { x : _g.sx, y : _g.sy };
      var _parent_scale = max(2.2, _g.w / 5.5);
      var _seg_count = 4 + _claw;
      for (var _rs = 1; _rs <= _seg_count; _rs++) {
        var _ru = _rs / _seg_count;
        var _pt = scr_tree_root_rake_curve_point(_g, _ru);
        var _child_scale = lerp(_parent_scale, max(1.8, _parent_scale * 0.62), _ru);
        var _role = (_claw == 0 && _ru < 0.72) ? 2 : 1;
        var _spurs = (_role >= 2) ? 5 : 4;

        scr_draw_tree_matched_branch_segment(_last.x, _last.y, _pt.x, _pt.y,
                                             _parent_scale, _child_scale,
                                             _ev.alpha * (0.82 + _ev.strike * 0.16),
                                             _mat_heat, _mat_current,
                                             _network_flash, _role, _spurs,
                                             _seed + _claw * 61.3 + _rs * 17.9,
                                             _seed + _claw * 43.1 + _rs * 23.7);
        _last = _pt;
        _parent_scale = _child_scale;
      }
    }

    if (tree_root_rake_debug) {
      gpu_set_blendmode(bm_add);
      draw_set_color(global.avoid_col_cyan);
      draw_set_alpha(0.55);
      for (var _dc = 0; _dc < 3; _dc++) {
        var _dg = scr_tree_root_rake_geom(_rk, _ev, _dc);
        draw_line_width(_dg.sx, _dg.sy, _dg.mx, _dg.my, tree_root_rake_hit_radius * 2);
        draw_line_width(_dg.mx, _dg.my, _dg.tx, _dg.ty, tree_root_rake_hit_radius * 1.8);
      }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_tree_root_rakes_glow() {
  return;
}

function scr_draw_avoidance_tree_root_telegraph() {
  if (t < tree_telegraph_start_t || t >= tree_telegraph_end_t)
    return;

  var _k_telegraph_size_min = 1.2;
  var _k_telegraph_size_max = 3.4;
  var _tp = (t - tree_telegraph_start_t) / (tree_telegraph_end_t - tree_telegraph_start_t);
  var _tp_heat = _tp * _tp;
  var _cam_sx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _cam_sy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _tr = color_get_red(global.tree_fire_color) / 255;
  var _tg = color_get_green(global.tree_fire_color) / 255;
  var _tb = color_get_blue(global.tree_fire_color) / 255;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs_tel = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs_tel[0], _uvs_tel[1], _uvs_tel[2], _uvs_tel[3]);

  for (var _tbi = 0; _tbi < array_length(tree_root_base_xs); _tbi++) {
    var _pulse = 0.5 + 0.5 * sin(t * 0.4 + _tbi * 2.1);
    var _gx = (tree_root_base_xs[_tbi] - oCameraController.current_cam_x) * _cam_sx;
    var _gy = (tree_root_base_y - oCameraController.current_cam_y) * _cam_sy;

    shader_set_uniform_f(global.u_glow_color, _tr, _tg, _tb);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.2, 1.4, _tp_heat) * _pulse);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    var _tsize = lerp(_k_telegraph_size_min, _k_telegraph_size_max, _tp_heat);
    draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, _tsize, _tsize * 0.5, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0, 1.6, _tp_heat) * _pulse);
    shader_set_uniform_f(global.u_glow_falloff, 2.4);
    draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, _tsize * 0.3, _tsize * 0.18, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_tree_ignition_spark() {
  if (t < tree_ignite_start_t || t > tree_payoff_t + 20)
    return;

  var _k_spark_size = 1.4;
  var _k_spark_intensity = 1.3;
  var _fr = color_get_red(global.tree_fire_color) / 255;
  var _fg = color_get_green(global.tree_fire_color) / 255;
  var _fb = color_get_blue(global.tree_fire_color) / 255;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);

  var _tree_spark_shader_active = false;
  var _uvs2 = sprite_get_uvs(spr_glow_blob, 0);
  for (var i = 0; i < array_length(tree_data.nodes); i++) {
    var _node = tree_data.nodes[i];
    if (_node.parent == -1) continue;

    var _pnode = tree_data.nodes[_node.parent];
    var _t_p = tree_ignite_start_t + _pnode.ignite_delay;
    var _t_c = tree_ignite_start_t + _node.ignite_delay;
    if (t < _t_p || t > _t_c) continue;

    var _sp = (_t_c > _t_p) ? (t - _t_p) / (_t_c - _t_p) : 1;
    var _sx = lerp(_pnode.x, _node.x, _sp);
    var _sy = lerp(_pnode.y, _node.y, _sp);
    var _gx2 = (_sx - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gy2 = (_sy - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_tree_spark_shader_active) {
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs2[0], _uvs2[1], _uvs2[2], _uvs2[3]);
      shader_set_uniform_f(global.u_glow_color, _fr, _fg, _fb);
      shader_set_uniform_f(global.u_glow_intensity, _k_spark_intensity);
      shader_set_uniform_f(global.u_glow_falloff, 1.8);
      _tree_spark_shader_active = true;
    }

    draw_sprite_ext(spr_glow_blob, 0, _gx2, _gy2, _k_spark_size, _k_spark_size, 0, c_white, 1);
  }

  if (_tree_spark_shader_active) shader_reset();
  gpu_set_blendequation(bm_eq_add);

  for (var i2 = 0; i2 < array_length(tree_data.nodes); i2++) {
    var _node2 = tree_data.nodes[i2];
    if (_node2.parent == -1) continue;

    var _pnode2 = tree_data.nodes[_node2.parent];
    var _t_p2 = tree_ignite_start_t + _pnode2.ignite_delay;
    var _t_c2 = tree_ignite_start_t + _node2.ignite_delay;
    if (t < _t_p2 || t > _t_c2) continue;

    var _sp2 = (_t_c2 > _t_p2) ? (t - _t_p2) / (_t_c2 - _t_p2) : 1;
    var _tail2 = max(0, _sp2 - 0.34);
    var _lx0 = lerp(_pnode2.x, _node2.x, _tail2);
    var _ly0 = lerp(_pnode2.y, _node2.y, _tail2);
    var _lx1 = lerp(_pnode2.x, _node2.x, _sp2);
    var _ly1 = lerp(_pnode2.y, _node2.y, _sp2);
    var _ggx0 = (_lx0 - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _ggy0 = (_ly0 - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _ggx1 = (_lx1 - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _ggy1 = (_ly1 - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _node_scale2 = variable_struct_exists(_node2, "base_scale") ? _node2.base_scale : 1;
    var _spark_w = 3.2 + clamp(_node_scale2, 0, 5) * 0.9;
    var _spark_a = 0.45 + 0.35 * sin(current_time * 0.035 + i2);

    draw_set_color(global.tree_fire_color);
    draw_set_alpha(_spark_a * 0.55);
    draw_line_width(_ggx0, _ggy0, _ggx1, _ggy1, _spark_w);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_spark_a * 0.22);
    draw_line_width(_ggx0 + 1.5, _ggy0, _ggx1 + 1.5, _ggy1, max(1, _spark_w * 0.36));
    draw_set_color(c_white);
    draw_set_alpha(_spark_a * 0.85);
    draw_line_width(_ggx0, _ggy0, _ggx1, _ggy1, max(0.8, _spark_w * 0.25));
  }

  draw_set_alpha(1);
  draw_set_color(c_white);
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_tree_payoff_flash() {
  if (!tree_payoff_triggered || tree_payoff_flash_timer >= 20)
    return;

  var _k_payoff_duration = 20;
  var _fp = tree_payoff_flash_timer / _k_payoff_duration;
  var _gx3 = (tree_data.nodes[tree_data.trunk_end].x - oCameraController.current_cam_x) *
             (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _gy3 = (tree_data.nodes[tree_data.trunk_end].y - oCameraController.current_cam_y) *
             (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _cgx3 = (tree_crown_center_x - oCameraController.current_cam_x) *
              (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _cgy3 = (tree_crown_center_y - oCameraController.current_cam_y) *
              (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _fr2 = color_get_red(global.tree_fire_color) / 255;
  var _fg2 = color_get_green(global.tree_fire_color) / 255;
  var _fb2 = color_get_blue(global.tree_fire_color) / 255;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs3 = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs3[0], _uvs3[1], _uvs3[2], _uvs3[3]);
  shader_set_uniform_f(global.u_glow_color, _fr2, _fg2, _fb2);
  shader_set_uniform_f(global.u_glow_intensity, lerp(1.2, 0, _fp));
  shader_set_uniform_f(global.u_glow_falloff, 1.3);
  draw_sprite_ext(spr_glow_blob, 0, _gx3, _gy3, lerp(2, 9, _fp), lerp(2, 9, _fp), 0, c_white, 1);
  draw_sprite_ext(spr_glow_blob, 0, _cgx3, _cgy3, lerp(3.5, 12, _fp), lerp(3.5, 12, _fp), 0, c_white, 1);

  var _core_p = clamp(_fp / 0.33, 0, 1);
  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_intensity, lerp(2.0, 0, _core_p));
  shader_set_uniform_f(global.u_glow_falloff, 2.2);
  draw_sprite_ext(spr_glow_blob, 0, _gx3, _gy3, lerp(4, 0, _core_p), lerp(4, 0, _core_p), 0, c_white, 1);
  draw_sprite_ext(spr_glow_blob, 0, _cgx3, _cgy3, lerp(5, 0, _core_p), lerp(5, 0, _core_p), 0, c_white, 1);

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_tree_embers() {
  if (array_length(global.tree_embers) <= 0)
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs4 = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs4[0], _uvs4[1], _uvs4[2], _uvs4[3]);
  shader_set_uniform_f(global.u_glow_falloff, 2.0);

  for (var i = 0; i < array_length(global.tree_embers); i++) {
    var _em = global.tree_embers[i];
    var _ep = _em.life / _em.max_life;
    var _ex = (_em.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _ey = (_em.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _er = color_get_red(_em.color) / 255;
    var _eg = color_get_green(_em.color) / 255;
    var _eb = color_get_blue(_em.color) / 255;

    shader_set_uniform_f(global.u_glow_color, _er, _eg, _eb);
    shader_set_uniform_f(global.u_glow_intensity, lerp(1.0, 0, _ep));
    var _esize = lerp(0.7, 0.15, _ep);
    draw_sprite_ext(spr_glow_blob, 0, _ex, _ey, _esize, _esize, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_tree_node_glow() {
  if (!instance_exists(oTree))
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);

  var _count = instance_number(oTree);
  for (var _i = 0; _i < _count; _i++) {
    var _tree = instance_find(oTree, _i);
    if (!instance_exists(_tree)) continue;
    if (_tree.state != 1) continue;

    var _gx4 = (_tree.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gy4 = (_tree.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _ign_p = clamp(_tree.state_timer / _tree.grow_duration, 0, 1);

    shader_set(shd_bullet_glow);
    var _tuvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _tuvs[0], _tuvs[1], _tuvs[2], _tuvs[3]);
    shader_set_uniform_f(global.u_glow_color, color_get_red(_tree.ignite_color_hot) / 255,
                         color_get_green(_tree.ignite_color_hot) / 255, color_get_blue(_tree.ignite_color_hot) / 255);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.4, 1.1, _ign_p));
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, _gx4, _gy4, _tree.base_scale * 0.35, _tree.base_scale * 0.35, 0, c_white, 1);
    shader_reset();

    draw_set_color(_tree.ignite_color_hot);
    draw_set_alpha(0.8);
    var _crackle_count = 2;
    for (var c = 0; c < _crackle_count; c++) {
      var _cang = random(360);
      var _clen = random_range(4, 10);
      var _ex2 = _gx4 + lengthdir_x(_clen, _cang);
      var _ey2 = _gy4 + lengthdir_y(_clen, _cang);
      draw_line_width(_gx4, _gy4, _ex2, _ey2, 1.5);
    }
    draw_set_alpha(1);
  }

  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_fruit_charge_arcs() {
  if (t < 1900 || t >= 2025)
    return;

  var _ccx = (tree_crown_center_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _ccy = (tree_crown_center_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

  gpu_set_blendmode(bm_add);

  var _count = instance_number(oFruit);
  for (var _i = 0; _i < _count; _i++) {
    var _fruit = instance_find(oFruit, _i);
    if (!instance_exists(_fruit)) continue;
    var _fruit_charge = max(max(_fruit.unstable, tree_crown_charge * 0.35), _fruit.cocoon_pressure * 0.75);
    if (_fruit_charge <= 0.02) continue;

    var _fgx2 = (_fruit.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _fgy2 = (_fruit.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _agx = (_fruit.anchor_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _agy = (_fruit.anchor_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _mgx = lerp(_fgx2, _ccx, 0.5) + sin(current_time * 0.027 + _fruit.sap_tether_seed) * (3 + _fruit_charge * 6);
    var _mgy = lerp(_fgy2, _ccy, 0.5) + cos(current_time * 0.023 + _fruit.sap_tether_seed) * (3 + _fruit_charge * 6);
    var _line_color = merge_color(global.avoid_col_cyan, _fruit.fruit_color, clamp(0.18 + _fruit.cocoon_pressure * 0.42, 0, 0.72));

    draw_set_color(merge_color(global.avoid_col_cyan, _line_color, 0.35));
    draw_set_alpha(0.22 * _fruit_charge);
    draw_line_width(_agx, _agy, _fgx2, _fgy2, 3);

    draw_set_color(_line_color);
    draw_set_alpha(0.35 * _fruit_charge);
    draw_line_width(_fgx2, _fgy2, _mgx, _mgy, 4);
    draw_line_width(_mgx, _mgy, _ccx, _ccy, 4);
    draw_set_color(c_white);
    draw_set_alpha(0.65 * _fruit_charge);
    draw_line_width(_fgx2, _fgy2, _mgx, _mgy, 1.5);
    draw_line_width(_mgx, _mgy, _ccx, _ccy, 1.5);

    var _flow = ((current_time * (0.0015 + _fruit_charge * 0.001)) + _fruit.idle_timer * 0.01) mod 1;
    var _flow_x = lerp(_fgx2, _ccx, _flow);
    var _flow_y = lerp(_fgy2, _ccy, _flow);
    draw_set_color(_line_color);
    draw_set_alpha(_fruit_charge * 0.5);
    draw_circle(_flow_x, _flow_y, 5 + _fruit_charge * 3, false);
    draw_set_color(c_white);
    draw_set_alpha(_fruit_charge * 0.85);
    draw_circle(_flow_x, _flow_y, 2.4 + _fruit_charge * 1.3, false);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_storm_charge_orb() {
  if (storm_sphere_visibility <= 0.001)
    return;

  var _so_gx = (storm_orb_x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
  var _so_gy = (storm_orb_y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
  var _so_cam_scale = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _so_sphere_r = _k_storm_clearing_radius * _so_cam_scale * storm_sphere_visibility;
  var _so_orb_r = storm_orb_radius * _so_cam_scale;
  var _so_charge01 = clamp(storm_orb_radius / 46, 0, 1);

  var _so_skin = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, _so_charge01 * 0.14);
  var _so_core_shadow = merge_color(global.avoid_col_armor_dark, c_black, 0.45);

  draw_set_alpha(0.9 * storm_sphere_visibility);
  draw_circle_color(_so_gx, _so_gy, _so_sphere_r, _so_skin, _so_core_shadow, false);
  draw_set_alpha(1);

  gpu_set_blendmode(bm_add);
  shader_set(shd_bullet_glow);

  var _so_uvs0 = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _so_uvs0[0], _so_uvs0[1], _so_uvs0[2], _so_uvs0[3]);
  shader_set_uniform_f(global.u_glow_color, 0.75, 0.88, 1);
  shader_set_uniform_f(global.u_glow_intensity, 0.7 * storm_sphere_visibility);
  shader_set_uniform_f(global.u_glow_falloff, 2.4);
  draw_sprite_ext(spr_glow_blob, 0, _so_gx - _so_sphere_r * 0.38, _so_gy - _so_sphere_r * 0.4,
                  (_so_sphere_r / 32) * 0.55, (_so_sphere_r / 32) * 0.55, 0, c_white, 1);
  shader_reset();
  gpu_set_blendmode(bm_normal);

  var _so_rim_color = merge_color(make_color_rgb(100, 150, 255), c_white, _so_charge01 * 0.4);
  gpu_set_blendmode(bm_add);
  scr_draw_smooth_ring_mask(_so_gx, _so_gy, _so_sphere_r, (0.5 + _so_charge01 * 0.3) * storm_sphere_visibility, 20, _so_rim_color);
  for (var _so_v = 0; _so_v < 3; _so_v++) {
    var _vein_r = _so_sphere_r * (0.34 + _so_v * 0.18);
    var _vein_ang = current_time * (0.022 + _so_v * 0.006) + _so_v * 119;
    var _vein_col = merge_color(global.avoid_col_blood, global.tree_fire_color, 0.35 + _so_charge01 * 0.35);
    if (_so_v == 1) {
      _vein_col = merge_color(global.avoid_col_cyan, c_white, 0.25 + _so_charge01 * 0.35);
    }
    scr_draw_lightning_arc(_so_gx, _so_gy, _vein_r, _vein_ang, _vein_ang + 115 + _so_charge01 * 70,
                           storm_sphere_visibility * (0.35 + _so_charge01 * 0.65), 1, _vein_col, false);
  }
  gpu_set_blendmode(bm_normal);

  if (_so_orb_r > 0.5) {
    var _so_lc = global.lightning_color;
    var _so_lc_r = color_get_red(_so_lc) / 255;
    var _so_lc_g = color_get_green(_so_lc) / 255;
    var _so_lc_b = color_get_blue(_so_lc) / 255;

    gpu_set_blendmode(bm_add);

    shader_set(shd_bullet_glow);
    var _so_uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _so_uvs[0], _so_uvs[1], _so_uvs[2], _so_uvs[3]);
    shader_set_uniform_f(global.u_glow_color, _so_lc_r, _so_lc_g, _so_lc_b);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.3, 1.2, _so_charge01) * storm_orb_scale_punch);
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    draw_sprite_ext(spr_glow_blob, 0, _so_gx, _so_gy, (_so_orb_r / 32) * 2.2, (_so_orb_r / 32) * 2.2, 0, c_white, 1);

    for (var wi = 0; wi < 3; wi++) {
      var _wisp_ang = current_time * 0.0012 * (wi + 1) * (wi mod 2 == 0 ? 1 : -1) + wi * 130;
      var _wisp_r = _so_orb_r * (0.25 + 0.15 * sin(current_time * 0.002 + wi * 3));
      var _wx = _so_gx + lengthdir_x(_wisp_r, _wisp_ang);
      var _wy = _so_gy + lengthdir_y(_wisp_r, _wisp_ang);

      shader_set_uniform_f(global.u_glow_color, _so_lc_r, _so_lc_g, _so_lc_b);
      shader_set_uniform_f(global.u_glow_intensity, 0.5 * _so_charge01);
      shader_set_uniform_f(global.u_glow_falloff, 2.0);
      draw_sprite_ext(spr_glow_blob, 0, _wx, _wy, (_so_orb_r / 32) * 0.3, (_so_orb_r / 32) * 0.3, 0, c_white, 1);
    }

    var _so_pulse = 0.6 + 0.4 * sin(current_time * storm_orb_pulse_freq);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, (0.5 + _so_charge01 * 1.5) * _so_pulse);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, _so_gx, _so_gy, (_so_orb_r / 32) * 0.8 * storm_orb_scale_punch,
                    (_so_orb_r / 32) * 0.8 * storm_orb_scale_punch, 0, c_white, 1);
    shader_reset();
    gpu_set_blendmode(bm_normal);

    var _so_ring_color = merge_color(_so_lc, c_white, _so_charge01 * 0.5);
    scr_draw_lightning_arc(_so_gx, _so_gy, _so_orb_r, 0, 360, 1, 1, _so_ring_color);
    scr_draw_lightning_arc(_so_gx, _so_gy, _so_orb_r * 0.7, 180, 540, 1, 1, _so_ring_color);

    gpu_set_blendmode(bm_add);
    for (var sci = 0; sci < array_length(storm_charge_arcs); sci++) {
      var _sca = storm_charge_arcs[sci];
      var _sca_alpha = _sca.life / _sca.life_max;
      var _sca_ox = _so_gx + lengthdir_x(_so_orb_r * 1.8, _sca.ang);
      var _sca_oy = _so_gy + lengthdir_y(_so_orb_r * 1.8, _sca.ang);

      draw_set_color(_so_ring_color);
      draw_set_alpha(_sca_alpha * 0.7);
      draw_line_width(_sca_ox, _sca_oy, _so_gx, _so_gy, 2);
      draw_set_alpha(_sca_alpha * 0.9);
      draw_circle(_sca_ox, _sca_oy, 2, false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
  }

  gpu_set_blendmode(bm_add);
  for (var mi = 0; mi < 4; mi++) {
    var _mote_ang = current_time * 0.001 * (mi mod 2 == 0 ? 1 : -0.7) + mi * 90;
    var _mote_r = _so_sphere_r * (1.08 + 0.06 * sin(current_time * 0.003 + mi));
    var _mx = _so_gx + lengthdir_x(_mote_r, _mote_ang);
    var _my = _so_gy + lengthdir_y(_mote_r, _mote_ang);

    draw_set_color(merge_color(global.lightning_color, c_white, 0.3));
    draw_set_alpha(0.6 * storm_sphere_visibility);
    draw_circle(_mx, _my, 1.6, false);
  }

  draw_set_alpha(1);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_fruit_burst_flash() {
  if (array_length(fruit_bursts) <= 0)
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  for (var i = 0; i < array_length(fruit_bursts); i++) {
    var _fb = fruit_bursts[i];
    var _fbp = _fb.timer / _fb.duration;
    var _fgx = (_fb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _fgy = (_fb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _fb_col = variable_struct_exists(_fb, "color") ? _fb.color : global.tree_fire_color;
    var _tr2 = color_get_red(_fb_col) / 255;
    var _tg2 = color_get_green(_fb_col) / 255;
    var _tb2 = color_get_blue(_fb_col) / 255;
    var _uvs6 = sprite_get_uvs(spr_glow_blob, 0);

    shader_set_uniform_f(global.u_glow_uvrect, _uvs6[0], _uvs6[1], _uvs6[2], _uvs6[3]);
    shader_set_uniform_f(global.u_glow_color, _tr2, _tg2, _tb2);
    shader_set_uniform_f(global.u_glow_intensity, lerp(1.1, 0, _fbp));
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    draw_sprite_ext(spr_glow_blob, 0, _fgx, _fgy, lerp(1.5, 5, _fbp), lerp(1.5, 5, _fbp), 0, c_white, 1);

    var _core_p2 = clamp(_fbp / 0.35, 0, 1);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, lerp(2.2, 0, _core_p2));
    shader_set_uniform_f(global.u_glow_falloff, 2.4);
    draw_sprite_ext(spr_glow_blob, 0, _fgx, _fgy, lerp(2.5, 0, _core_p2), lerp(2.5, 0, _core_p2), 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_dna_test_glow() {
  if (!instance_exists(oDNATest))
    return;

  // uniform for each one. The Duct hides the helices for its entire 745
  if (dna_veil <= 0.02)
    return;

  var _dna_gsx = oCameraController.base_view_w / oCameraController.current_cam_w;
  var _dna_gsy = oCameraController.base_view_h / oCameraController.current_cam_h;
  var _dna_gcx = oCameraController.current_cam_x;
  var _dna_gcy = oCameraController.current_cam_y;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _dna_uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _dna_uvs[0], _dna_uvs[1], _dna_uvs[2], _dna_uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.0);

  var _dna_blood = global.avoid_col_blood;
  var _dna_danger = global.avoid_col_danger;
  var _dna_cyan = global.avoid_col_cyan;

  var _dna_count = instance_number(oDNATest);
  for (var _i = 0; _i < _dna_count; _i++) {
    var _dna = instance_find(oDNATest, _i);
    if (!instance_exists(_dna)) continue;
    if (_dna.state != "idle") continue;

    var gui_x = (_dna.x - _dna_gcx) * _dna_gsx;
    var gui_y = (_dna.y - _dna_gcy) * _dna_gsy;
    var _dna_i = 1.0 + dna_chain_flash * 1.3;
    var _dna_lit = _dna.lightning_hit ? 1 : 0;
    var _dna_col = merge_color(_dna_blood, _dna_danger, 0.52 + _dna_lit * 0.18 + dna_chain_flash * 0.18);
    if (_dna.dna_type == 2) {
      _dna_col = merge_color(_dna_blood, _dna_cyan, 0.18 + _dna_lit * 0.10 + dna_chain_flash * 0.10);
    }

    shader_set_uniform_f(global.u_glow_color, colour_get_red(_dna_col) / 255,
                         colour_get_green(_dna_col) / 255, colour_get_blue(_dna_col) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _dna_i);
    var _dna_gs = 1.0 + dna_chain_flash * 0.5;
    // while the player is sealed inside something. It multiplies the SPRITE's
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _dna_gs, _dna_gs, 0, c_white, dna_veil);
  }

  shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
  shader_set_uniform_f(global.u_glow_falloff, 2.2);

  for (var _j = 0; _j < _dna_count; _j++) {
    var _dna_strike = instance_find(oDNATest, _j);
    if (!instance_exists(_dna_strike)) continue;
    if (_dna_strike.strike_flash < 0.08) continue;

    var _dsx = (_dna_strike.x - _dna_gcx) * _dna_gsx;
    var _dsy = (_dna_strike.y - _dna_gcy) * _dna_gsy;
    shader_set_uniform_f(global.u_glow_intensity, _dna_strike.strike_flash * 2.4);
    draw_sprite_ext(spr_glow_blob, 0, _dsx, _dsy, 0.4 + _dna_strike.strike_flash * 0.7, 0.4 + _dna_strike.strike_flash * 0.7,
                    0, c_white, dna_veil);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}
