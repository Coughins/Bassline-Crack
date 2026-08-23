if (!instance_exists(oAvoidanceController) || !instance_exists(oCameraController)) exit;

var _ctrl = oAvoidanceController;
var _cam = oCameraController;

var _bw = _cam.base_view_w;
var _bh = _cam.base_view_h;
var _aspect = _bw / _bh;

var _cam_x = _cam.current_cam_x;
var _cam_y = _cam.current_cam_y;
var _cam_w = _cam.current_cam_w;
var _cam_h = _cam.current_cam_h;

shader_set(shd_hex_2);

shader_set_uniform_f(u_time_h, 37 + _ctrl.t / room_speed);
shader_set_uniform_f(u_resolution_h, _bw, _bh);
shader_set_uniform_f(u_intro_dim_h, intro_dim);
shader_set_uniform_f(u_bass_h, _ctrl.bass_visual);
shader_set_uniform_f(u_beat_h, _ctrl.floor_beat);
shader_set_uniform_f(u_charge_h, _ctrl.floor_charge);

var _zoom = _cam_w / _bw;
var _px = _k_floor_parallax;

var _off_x = _aspect * ((_zoom - 1) + 2 * _cam_x / _bw) * _px;
var _off_y = ((_zoom - 1) + 2 * _cam_y / _bh) * _px;

shader_set_uniform_f(u_quad_scale_h, _k_quad_pad);
shader_set_uniform_f(u_floor_zoom_h, lerp(1, _zoom, _px));
shader_set_uniform_f(u_floor_offset_h, _off_x, _off_y);
shader_set_uniform_f(u_spin_h, degtorad(_ctrl.floor_spin));

var _light_amount = min(array_length(_ctrl.arena_lights), 128);

shader_set_uniform_f(u_light_count_h, _light_amount);

for (var i = 0; i < _light_amount; i++) {
  var _l = _ctrl.arena_lights[i];

  buf_light_pos[i * 2 + 0] = (2 * (_l.x - _cam_x) / _cam_w - 1) * _aspect;
  buf_light_pos[i * 2 + 1] = 2 * (_l.y - _cam_y) / _cam_h - 1;

  buf_light_color[i * 3 + 0] = _l.r;
  buf_light_color[i * 3 + 1] = _l.g;
  buf_light_color[i * 3 + 2] = _l.b;

  buf_light_power[i] = _l.power;
}

shader_set_uniform_f_array(u_light_color_h, buf_light_color);
shader_set_uniform_f_array(u_light_power_h, buf_light_power);
shader_set_uniform_f_array(u_light_pos_h, buf_light_pos);

var _pl_x = 0;
var _pl_y = 0;
var _pl_glow = 0;

if (instance_exists(oPlayer)) {
  _pl_x = (2 * (oPlayer.x - _cam_x) / _cam_w - 1) * _aspect;
  _pl_y = 2 * (oPlayer.y - _cam_y) / _cam_h - 1;
  _pl_glow = _k_player_glow;
}

shader_set_uniform_f(u_player_pos_h, _pl_x, _pl_y);
shader_set_uniform_f(u_player_glow_h, _pl_glow);

var _shadow_amount = min(array_length(_ctrl.shadow_positions), 32);
for (var i = 0; i < _shadow_amount; i++) {
  var _s = _ctrl.shadow_positions[i];
  buf_shadow_pos[i * 2 + 0] = (2 * (_s.x - _cam_x) / _cam_w - 1) * _aspect;
  buf_shadow_pos[i * 2 + 1] = 2 * (_s.y - _cam_y) / _cam_h - 1;
}
shader_set_uniform_f(u_shadow_count_h, _shadow_amount);
if (_shadow_amount > 0) shader_set_uniform_f_array(u_shadow_pos_h, buf_shadow_pos);

shader_set_uniform_f(
    u_focus_h,
    (2 * (_ctrl.floor_focus_x - _cam_x) / _cam_w - 1) * _aspect,
    2 * (_ctrl.floor_focus_y - _cam_y) / _cam_h - 1);
shader_set_uniform_f(u_focus_amt_h, _ctrl.floor_focus_amount);

var _wave_amount = min(array_length(_ctrl.bass_waves), 8);

shader_set_uniform_f(u_bass_wave_count_h, _wave_amount);

for (var i = 0; i < 8; i++) {
  buf_waves[i] = (i < _wave_amount) ? _ctrl.bass_waves[i] : 0;
}

shader_set_uniform_f_array(u_bass_waves_h, buf_waves);

shader_set_uniform_f(u_impact_radius_h, _ctrl.impact_wave_radius);
shader_set_uniform_f(
    u_impact_color_h,
    colour_get_red(_ctrl.impact_wave_color) / 255,
    colour_get_green(_ctrl.impact_wave_color) / 255,
    colour_get_blue(_ctrl.impact_wave_color) / 255);

var _quake_amount = min(array_length(_ctrl.floor_quakes), 6);

for (var i = 0; i < _quake_amount; i++) {
  var _q = _ctrl.floor_quakes[i];
  buf_quakes[i * 4 + 0] = (2 * _q.x / _bw - 1) * _aspect;
  buf_quakes[i * 4 + 1] = 2 * _q.y / _bh - 1;
  buf_quakes[i * 4 + 2] = _q.radius;
  buf_quakes[i * 4 + 3] = _q.power * (_q.life / _q.max_life);
}

shader_set_uniform_f(u_quake_count_h, _quake_amount);
if (_quake_amount > 0) shader_set_uniform_f_array(u_quakes_h, buf_quakes);

var _scar_amount = min(array_length(_ctrl.floor_scars), 8);
var _px_to_floor = 2 / _bh;

for (var i = 0; i < _scar_amount; i++) {
  var _sc = _ctrl.floor_scars[i];

  buf_scar_a[i * 4 + 0] = (2 * _sc.x / _bw - 1) * _aspect;
  buf_scar_a[i * 4 + 1] = 2 * _sc.y / _bh - 1;
  buf_scar_a[i * 4 + 2] = degtorad(_sc.angle);
  buf_scar_a[i * 4 + 3] = _sc.span * _px_to_floor;

  buf_scar_b[i * 4 + 0] = _sc.age / _sc.life;
  buf_scar_b[i * 4 + 1] = _sc.heat;
  buf_scar_b[i * 4 + 2] = _sc.seed;
  buf_scar_b[i * 4 + 3] = _sc.width * _px_to_floor;

  buf_scar_c[i * 4 + 0] = degtorad(_sc.branch_angle);
  buf_scar_c[i * 4 + 1] = _sc.branch_offset;

  buf_scar_col[i * 3 + 0] = colour_get_red(_sc.color) / 255;
  buf_scar_col[i * 3 + 1] = colour_get_green(_sc.color) / 255;
  buf_scar_col[i * 3 + 2] = colour_get_blue(_sc.color) / 255;
}

shader_set_uniform_f(u_scar_count_h, _scar_amount);
if (_scar_amount > 0) {
  shader_set_uniform_f_array(u_scar_a_h, buf_scar_a);
  shader_set_uniform_f_array(u_scar_b_h, buf_scar_b);
  shader_set_uniform_f_array(u_scar_c_h, buf_scar_c);
  shader_set_uniform_f_array(u_scar_col_h, buf_scar_col);
}

var _qw = _cam_w * _k_quad_pad;
var _qh = _cam_h * _k_quad_pad;

draw_surface_stretched(
    application_surface,
    _cam_x + _cam_w / 2 - _qw / 2,
    _cam_y + _cam_h / 2 - _qh / 2,
    _qw,
    _qh);

shader_reset();

with (_ctrl) {
  var _shield_break_age_bg = t - _k_containment_shield_break_t;
  var _shield_break_active_bg = (_shield_break_age_bg >= 0 && _shield_break_age_bg < _k_containment_shield_break_life);
  var _shield_a_bg = 0;
  if (t < _k_containment_shield_break_t) {
    _shield_a_bg = 1;
  } else if (_shield_break_active_bg) {
    var _shield_fail_flicker_bg = 0.35 + 0.65 * power(0.5 + 0.5 * sin(t * 1.7), 2);
    _shield_a_bg = max(0, 1 - _shield_break_age_bg / 14) * _shield_fail_flicker_bg;
  }

  if (_shield_a_bg > 0.02) {
    gpu_set_blendmode(bm_normal);

    var _sh_l_bg = _k_ring_arena_pad;
    var _sh_r_bg = room_width - _k_ring_arena_pad;
    var _sh_t_bg = _k_ring_arena_pad;
    var _sh_b_bg = _k_ring_floor_y;
    var _sh_time_bg = t / max(room_speed, 1);
    var _sh_ring_window_bg = clamp(1 - max(0, t - (_k_ring_cleanup_t + 45)) / 170, 0, 1);
    var _sh_lift_wake_bg = clamp((t - (_k_er_lift_charge_t - 230)) / 230, 0, 1);
    var _sh_ring_heat_bg = clamp(ring_ambient * 0.9 + ring_sector_flash * 0.34 + ring_heartbeat * 0.24 +
                                 ring_coil_amount * 0.38 + ring_wound * 0.22 + ring_lock_flash * 0.06, 0, 1.35);
    var _sh_hum_bg = clamp(0.12 + bass_visual * 0.08 + floor_beat * 0.08 + _sh_lift_wake_bg * 0.18 +
                           _sh_ring_heat_bg * (0.42 + _sh_ring_window_bg * 0.44), 0, 1.25);
    var _sh_alpha_bg = _shield_a_bg * (0.45 + _sh_hum_bg * 0.34);
    var _sh_col_bg = merge_color(_k_er_col_cyan, c_white, 0.18 + _sh_ring_heat_bg * 0.22);
    var _sh_hot_bg = merge_color(_k_er_col_warning, c_white, 0.18 + _sh_ring_heat_bg * 0.18);
    var _sh_edge_col_bg = merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.22 + _sh_hum_bg * 0.24);
    var _sh_core_col_bg = merge_color(_k_er_col_cyan, c_white, 0.56);

    var _sh_support_pad_x_bg = 270;
    var _sh_support_pad_y_bg = 210;
    if (instance_exists(oCameraController) && oCameraController.current_cam_w > 0) {
      _sh_support_pad_x_bg = max(_sh_support_pad_x_bg, (oCameraController.current_cam_w - room_width) * 0.5 + 120);
      _sh_support_pad_y_bg = max(_sh_support_pad_y_bg, (oCameraController.current_cam_h - room_height) * 0.5 + 120);
    }

    var _sh_world_l_bg = -_sh_support_pad_x_bg;
    var _sh_world_r_bg = room_width + _sh_support_pad_x_bg;
    var _sh_world_t_bg = -_sh_support_pad_y_bg;
    var _sh_anchor_b_bg = _sh_b_bg + 132;
    var _sh_support_a_bg = _shield_a_bg * (0.42 + _sh_hum_bg * 0.16);
    var _sh_support_dark_bg = merge_color(c_black, _k_er_col_armor_dark, 0.48);
    var _sh_support_mid_bg = merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, 0.56);
    var _sh_support_hi_bg = merge_color(_k_er_col_armor_mid, _k_er_col_armor_hi, 0.28 + _sh_hum_bg * 0.08);

    draw_set_color(_sh_support_dark_bg);
    draw_set_alpha(_sh_support_a_bg * 0.72);
    draw_rectangle(_sh_world_l_bg, _sh_t_bg - 76, _sh_l_bg - 34, _sh_anchor_b_bg, false);
    draw_rectangle(_sh_r_bg + 34, _sh_t_bg - 76, _sh_world_r_bg, _sh_anchor_b_bg, false);
    draw_rectangle(_sh_l_bg - 92, _sh_world_t_bg + 54, _sh_r_bg + 92, _sh_t_bg - 16, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_world_l_bg, _sh_t_bg - 76, _sh_support_mid_bg, _sh_support_a_bg * 0.52);
    draw_vertex_colour(_sh_l_bg - 34, _sh_t_bg - 76, _sh_support_dark_bg, _sh_support_a_bg * 0.68);
    draw_vertex_colour(_sh_world_l_bg, _sh_anchor_b_bg, merge_color(c_black, _k_er_col_armor_dark, 0.30), _sh_support_a_bg * 0.72);
    draw_vertex_colour(_sh_l_bg - 34, _sh_anchor_b_bg, _sh_support_dark_bg, _sh_support_a_bg * 0.78);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_r_bg + 34, _sh_t_bg - 76, _sh_support_dark_bg, _sh_support_a_bg * 0.68);
    draw_vertex_colour(_sh_world_r_bg, _sh_t_bg - 76, _sh_support_mid_bg, _sh_support_a_bg * 0.52);
    draw_vertex_colour(_sh_r_bg + 34, _sh_anchor_b_bg, _sh_support_dark_bg, _sh_support_a_bg * 0.78);
    draw_vertex_colour(_sh_world_r_bg, _sh_anchor_b_bg, merge_color(c_black, _k_er_col_armor_dark, 0.30), _sh_support_a_bg * 0.72);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_l_bg - 92, _sh_world_t_bg + 54, merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.20), _sh_support_a_bg * 0.58);
    draw_vertex_colour(_sh_r_bg + 92, _sh_world_t_bg + 54, merge_color(_k_er_col_armor_dark, _k_er_col_armor_hi, 0.20), _sh_support_a_bg * 0.58);
    draw_vertex_colour(_sh_l_bg - 62, _sh_t_bg - 16, _sh_support_dark_bg, _sh_support_a_bg * 0.82);
    draw_vertex_colour(_sh_r_bg + 62, _sh_t_bg - 16, _sh_support_dark_bg, _sh_support_a_bg * 0.82);
    draw_primitive_end();

    for (var _bay_side_bg = 0; _bay_side_bg < 2; _bay_side_bg++) {
      var _bay_l_bg = (_bay_side_bg == 0) ? _sh_world_l_bg + 18 : _sh_r_bg + 54;
      var _bay_r_bg = (_bay_side_bg == 0) ? _sh_l_bg - 54 : _sh_world_r_bg - 18;
      if (_bay_r_bg <= _bay_l_bg) continue;

      var _bay_w_bg = _bay_r_bg - _bay_l_bg;
      var _bay_count_bg = max(2, ceil(_bay_w_bg / 86));
      for (var _bay_bg = 0; _bay_bg < _bay_count_bg; _bay_bg++) {
        var _bay_f_bg = (_bay_bg + 0.5) / _bay_count_bg;
        var _bay_x_bg = lerp(_bay_l_bg, _bay_r_bg, _bay_f_bg);
        var _bay_hash_bg = frac(sin(_bay_bg * 52.73 + _bay_side_bg * 91.4) * 43758.5453);
        var _bay_panel_w_bg = min(58, _bay_w_bg / max(1, _bay_count_bg) * 0.66);
        var _bay_y0_bg = _sh_t_bg - 38 + ((_bay_bg + _bay_side_bg) mod 3) * 28;
        var _bay_y1_bg = min(_sh_anchor_b_bg - 24, _bay_y0_bg + 78 + _bay_hash_bg * 86);

        draw_set_color(merge_color(_sh_support_dark_bg, _sh_support_mid_bg, 0.20 + _bay_hash_bg * 0.18));
        draw_set_alpha(_shield_a_bg * (0.26 + _bay_hash_bg * 0.12));
        draw_rectangle(_bay_x_bg - _bay_panel_w_bg * 0.5, _bay_y0_bg, _bay_x_bg + _bay_panel_w_bg * 0.5, _bay_y1_bg, false);
        draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.35));
        draw_set_alpha(_shield_a_bg * (0.06 + _sh_hum_bg * 0.035));
        draw_line_width(_bay_x_bg - _bay_panel_w_bg * 0.36, _bay_y0_bg + 4, _bay_x_bg + _bay_panel_w_bg * 0.36, _bay_y0_bg + 4, 1);
        draw_line_width(_bay_x_bg - _bay_panel_w_bg * 0.36, _bay_y1_bg - 4, _bay_x_bg + _bay_panel_w_bg * 0.36, _bay_y1_bg - 4, 1);
      }
    }

    for (var _pylon_side_bg = 0; _pylon_side_bg < 2; _pylon_side_bg++) {
      var _pylon_sign_bg = (_pylon_side_bg == 0) ? -1 : 1;
      var _pylon_x_bg = (_pylon_side_bg == 0) ? _sh_l_bg - 44 : _sh_r_bg + 44;
      var _pylon_outer_bg = _pylon_x_bg + _pylon_sign_bg * 42;

      draw_primitive_begin(pr_trianglestrip);
      draw_vertex_colour(_pylon_x_bg - 16, _sh_t_bg - 56, _sh_support_hi_bg, _shield_a_bg * 0.72);
      draw_vertex_colour(_pylon_x_bg + 16, _sh_t_bg - 56, _sh_support_dark_bg, _shield_a_bg * 0.82);
      draw_vertex_colour(_pylon_x_bg - 20, _sh_anchor_b_bg, _sh_support_dark_bg, _shield_a_bg * 0.88);
      draw_vertex_colour(_pylon_x_bg + 20, _sh_anchor_b_bg, merge_color(c_black, _k_er_col_armor_dark, 0.36), _shield_a_bg * 0.90);
      draw_primitive_end();

      draw_set_color(_k_er_col_armor_dark);
      draw_set_alpha(_shield_a_bg * 0.85);
      draw_line_width(_pylon_x_bg + _pylon_sign_bg * 18, _sh_t_bg - 48, _pylon_x_bg + _pylon_sign_bg * 18, _sh_anchor_b_bg, 4);
      draw_set_color(merge_color(_k_er_col_armor_edge, c_white, 0.08));
      draw_set_alpha(_shield_a_bg * (0.18 + _sh_hum_bg * 0.06));
      draw_line_width(_pylon_x_bg - _pylon_sign_bg * 11, _sh_t_bg - 48, _pylon_x_bg - _pylon_sign_bg * 14, _sh_anchor_b_bg - 10, 1.5);

      for (var _rib_bg = 0; _rib_bg < 7; _rib_bg++) {
        var _rib_f_bg = _rib_bg / 6;
        var _rib_y_bg = lerp(_sh_t_bg - 18, _sh_anchor_b_bg - 34, _rib_f_bg);
        var _rib_tilt_bg = 18 + ((_rib_bg mod 2) * 16);
        draw_set_color(_sh_support_mid_bg);
        draw_set_alpha(_shield_a_bg * 0.58);
        draw_line_width(_pylon_x_bg - _pylon_sign_bg * 18, _rib_y_bg, _pylon_outer_bg, _rib_y_bg + _rib_tilt_bg, 5);
        draw_set_color(merge_color(_k_er_col_armor_edge, _k_er_col_cyan, 0.18));
        draw_set_alpha(_shield_a_bg * (0.08 + _sh_hum_bg * 0.05));
        draw_line_width(_pylon_x_bg - _pylon_sign_bg * 18, _rib_y_bg - 1, _pylon_outer_bg, _rib_y_bg + _rib_tilt_bg - 1, 1);
      }
    }

    for (var _side_strut_bg = 0; _side_strut_bg < 2; _side_strut_bg++) {
      var _strut_sign_bg = (_side_strut_bg == 0) ? -1 : 1;
      var _inner_x_bg = (_side_strut_bg == 0) ? _sh_l_bg - 10 : _sh_r_bg + 10;
      var _outer_x_bg = (_side_strut_bg == 0) ? _sh_world_l_bg + 74 : _sh_world_r_bg - 74;
      var _top_anchor_y_bg = _sh_t_bg + 20;
      var _mid_anchor_y_bg = _sh_t_bg + 205;
      var _bot_anchor_y_bg = _sh_b_bg + 32;
      var _deck_anchor_y_bg = _sh_anchor_b_bg - 10;

      draw_set_color(_sh_support_mid_bg);
      draw_set_alpha(_shield_a_bg * 0.62);
      draw_line_width(_outer_x_bg, _mid_anchor_y_bg, _inner_x_bg, _top_anchor_y_bg, 10);
      draw_line_width(_outer_x_bg, _mid_anchor_y_bg + 70, _inner_x_bg, _bot_anchor_y_bg, 12);
      draw_line_width(_outer_x_bg + _strut_sign_bg * 42, _deck_anchor_y_bg, _inner_x_bg, _sh_t_bg + 92, 7);

      draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.14));
      draw_set_alpha(_shield_a_bg * 0.50);
      draw_line_width(_outer_x_bg + _strut_sign_bg * 5, _mid_anchor_y_bg + 7, _inner_x_bg + _strut_sign_bg * 5, _top_anchor_y_bg + 7, 4);
      draw_line_width(_outer_x_bg + _strut_sign_bg * 5, _mid_anchor_y_bg + 77, _inner_x_bg + _strut_sign_bg * 5, _bot_anchor_y_bg + 7, 5);

      gpu_set_blendmode(bm_add);
      draw_set_color((_side_strut_bg == 0) ? _sh_col_bg : _sh_hot_bg);
      draw_set_alpha(_shield_a_bg * (0.045 + _sh_hum_bg * 0.055));
      draw_line_width(_outer_x_bg, _mid_anchor_y_bg, _inner_x_bg, _top_anchor_y_bg, 2);
      draw_line_width(_outer_x_bg, _mid_anchor_y_bg + 70, _inner_x_bg, _bot_anchor_y_bg, 2);
      draw_set_color(c_white);
      draw_set_alpha(_shield_a_bg * _sh_hum_bg * 0.035);
      draw_line_width(_outer_x_bg + _strut_sign_bg * 42, _deck_anchor_y_bg, _inner_x_bg, _sh_t_bg + 92, 1);
      gpu_set_blendmode(bm_normal);
    }

    var _gantry_y_bg = _sh_t_bg - 48;
    draw_set_color(_sh_support_dark_bg);
    draw_set_alpha(_shield_a_bg * 0.86);
    draw_rectangle(_sh_l_bg - 112, _gantry_y_bg - 16, _sh_r_bg + 112, _gantry_y_bg + 18, false);
    draw_set_color(_sh_support_hi_bg);
    draw_set_alpha(_shield_a_bg * 0.52);
    draw_line_width(_sh_l_bg - 118, _gantry_y_bg - 16, _sh_r_bg + 118, _gantry_y_bg - 16, 2);
    draw_set_color(_k_er_col_armor_dark);
    draw_set_alpha(_shield_a_bg * 0.78);
    draw_line_width(_sh_l_bg - 112, _gantry_y_bg + 19, _sh_r_bg + 112, _gantry_y_bg + 19, 4);

    for (var _gt_bg = 0; _gt_bg <= 13; _gt_bg++) {
      var _gt_f_bg = _gt_bg / 13;
      var _gt_x_bg = lerp(_sh_l_bg - 96, _sh_r_bg + 96, _gt_f_bg);
      var _gt_dir_bg = (_gt_bg mod 2 == 0) ? 1 : -1;
      var _gt_len_bg = 26 + ((_gt_bg mod 3) * 8);
      draw_set_color(_sh_support_mid_bg);
      draw_set_alpha(_shield_a_bg * 0.46);
      draw_line_width(_gt_x_bg, _gantry_y_bg - 12, _gt_x_bg + _gt_dir_bg * _gt_len_bg, _gantry_y_bg + 16, 4);

      if (_gt_bg mod 3 == 0) {
        gpu_set_blendmode(bm_add);
        var _node_p_bg = 0.55 + 0.45 * sin(_sh_time_bg * 5.8 + _gt_bg * 1.6);
        draw_set_color((_gt_bg mod 6 == 0) ? _sh_hot_bg : _sh_col_bg);
        draw_set_alpha(_shield_a_bg * (0.045 + _sh_hum_bg * 0.10) * _node_p_bg);
        draw_line_width(_gt_x_bg - 8, _gantry_y_bg + 2, _gt_x_bg + 8, _gantry_y_bg + 2, 2);
        draw_set_color(c_white);
        draw_set_alpha(_shield_a_bg * _sh_hum_bg * 0.045 * _node_p_bg);
        draw_circle(_gt_x_bg, _gantry_y_bg + 2, 1.4, false);
        gpu_set_blendmode(bm_normal);
      }
    }

    draw_set_alpha(_shield_a_bg);
    draw_set_color(merge_color(c_black, _k_er_col_armor_dark, 0.68));
    draw_rectangle(0, _sh_t_bg - 25, _sh_l_bg - 9, _sh_b_bg + 9, false);
    draw_rectangle(_sh_r_bg + 9, _sh_t_bg - 25, room_width, _sh_b_bg + 9, false);
    draw_rectangle(_sh_l_bg - 24, 0, _sh_r_bg + 24, _sh_t_bg - 9, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_l_bg - 17, _sh_t_bg - 20, merge_color(_k_er_col_armor_hi, c_white, 0.05), _shield_a_bg * 0.74);
    draw_vertex_colour(_sh_l_bg - 7, _sh_t_bg - 20, _k_er_col_armor_dark, _shield_a_bg * 0.82);
    draw_vertex_colour(_sh_l_bg - 17, _sh_b_bg + 10, _k_er_col_armor_dark, _shield_a_bg * 0.82);
    draw_vertex_colour(_sh_l_bg - 7, _sh_b_bg + 10, merge_color(c_black, _k_er_col_armor_dark, 0.45), _shield_a_bg * 0.88);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_r_bg + 7, _sh_t_bg - 20, _k_er_col_armor_dark, _shield_a_bg * 0.82);
    draw_vertex_colour(_sh_r_bg + 17, _sh_t_bg - 20, merge_color(_k_er_col_armor_hi, c_white, 0.05), _shield_a_bg * 0.74);
    draw_vertex_colour(_sh_r_bg + 7, _sh_b_bg + 10, merge_color(c_black, _k_er_col_armor_dark, 0.45), _shield_a_bg * 0.88);
    draw_vertex_colour(_sh_r_bg + 17, _sh_b_bg + 10, _k_er_col_armor_dark, _shield_a_bg * 0.82);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_l_bg - 22, _sh_t_bg - 18, merge_color(_k_er_col_armor_hi, c_white, 0.04), _shield_a_bg * 0.72);
    draw_vertex_colour(_sh_r_bg + 22, _sh_t_bg - 18, merge_color(_k_er_col_armor_hi, c_white, 0.04), _shield_a_bg * 0.72);
    draw_vertex_colour(_sh_l_bg - 10, _sh_t_bg - 7, _k_er_col_armor_dark, _shield_a_bg * 0.88);
    draw_vertex_colour(_sh_r_bg + 10, _sh_t_bg - 7, _k_er_col_armor_dark, _shield_a_bg * 0.88);
    draw_primitive_end();

    draw_set_color(merge_color(_k_er_col_armor_edge, c_black, 0.22));
    draw_set_alpha(_shield_a_bg * 0.86);
    draw_line_width(_sh_l_bg - 7, _sh_t_bg - 18, _sh_l_bg - 7, _sh_b_bg + 8, 3);
    draw_line_width(_sh_r_bg + 7, _sh_t_bg - 18, _sh_r_bg + 7, _sh_b_bg + 8, 3);
    draw_line_width(_sh_l_bg - 20, _sh_t_bg - 7, _sh_r_bg + 20, _sh_t_bg - 7, 3);

    gpu_set_blendmode(bm_add);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_l_bg - 1, _sh_t_bg, _sh_col_bg, _sh_alpha_bg * (0.26 + _sh_hum_bg * 0.10));
    draw_vertex_colour(_sh_l_bg + 42, _sh_t_bg, _sh_col_bg, _sh_alpha_bg * 0.024);
    draw_vertex_colour(_sh_l_bg - 1, _sh_b_bg, _sh_col_bg, _sh_alpha_bg * (0.24 + _sh_hum_bg * 0.09));
    draw_vertex_colour(_sh_l_bg + 42, _sh_b_bg, _sh_col_bg, _sh_alpha_bg * 0.020);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_r_bg - 42, _sh_t_bg, _sh_col_bg, _sh_alpha_bg * 0.024);
    draw_vertex_colour(_sh_r_bg + 1, _sh_t_bg, _sh_col_bg, _sh_alpha_bg * (0.26 + _sh_hum_bg * 0.10));
    draw_vertex_colour(_sh_r_bg - 42, _sh_b_bg, _sh_col_bg, _sh_alpha_bg * 0.020);
    draw_vertex_colour(_sh_r_bg + 1, _sh_b_bg, _sh_col_bg, _sh_alpha_bg * (0.24 + _sh_hum_bg * 0.09));
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_sh_l_bg, _sh_t_bg - 1, _sh_col_bg, _sh_alpha_bg * (0.23 + _sh_hum_bg * 0.10));
    draw_vertex_colour(_sh_r_bg, _sh_t_bg - 1, _sh_col_bg, _sh_alpha_bg * (0.23 + _sh_hum_bg * 0.10));
    draw_vertex_colour(_sh_l_bg, _sh_t_bg + 34, _sh_col_bg, _sh_alpha_bg * 0.018);
    draw_vertex_colour(_sh_r_bg, _sh_t_bg + 34, _sh_col_bg, _sh_alpha_bg * 0.018);
    draw_primitive_end();

    draw_set_color(_sh_col_bg);
    draw_set_alpha(_sh_alpha_bg * (0.24 + _sh_hum_bg * 0.15));
    draw_line_width(_sh_l_bg, _sh_t_bg, _sh_l_bg, _sh_b_bg, 7);
    draw_line_width(_sh_r_bg, _sh_t_bg, _sh_r_bg, _sh_b_bg, 7);
    draw_line_width(_sh_l_bg, _sh_t_bg, _sh_r_bg, _sh_t_bg, 7);

    draw_set_color(_sh_core_col_bg);
    draw_set_alpha(_sh_alpha_bg * (0.38 + _sh_hum_bg * 0.20));
    draw_line_width(_sh_l_bg, _sh_t_bg, _sh_l_bg, _sh_b_bg, 2);
    draw_line_width(_sh_r_bg, _sh_t_bg, _sh_r_bg, _sh_b_bg, 2);
    draw_line_width(_sh_l_bg, _sh_t_bg, _sh_r_bg, _sh_t_bg, 2);

    var _scan_step_bg = 28;
    var _scan_off_bg = frac(_sh_time_bg * (10 + _sh_hum_bg * 10)) * _scan_step_bg;
    for (var _scan_y_bg = _sh_t_bg + 10 - _scan_off_bg; _scan_y_bg < _sh_b_bg; _scan_y_bg += _scan_step_bg) {
      if (_scan_y_bg < _sh_t_bg + 6) continue;
      var _scan_phase_bg = 0.55 + 0.45 * sin(_sh_time_bg * 6.2 + _scan_y_bg * 0.037);
      var _scan_a_bg = _shield_a_bg * (0.025 + _sh_hum_bg * 0.08) * _scan_phase_bg;
      draw_set_color((_scan_y_bg mod (_scan_step_bg * 3) < _scan_step_bg) ? _sh_hot_bg : _sh_col_bg);
      draw_set_alpha(_scan_a_bg);
      draw_line_width(_sh_l_bg + 3, _scan_y_bg, _sh_l_bg + 31, _scan_y_bg + sin(_scan_y_bg * 0.09 + _sh_time_bg) * 2, 1);
      draw_line_width(_sh_r_bg - 31, _scan_y_bg + sin(_scan_y_bg * 0.08 - _sh_time_bg) * 2, _sh_r_bg - 3, _scan_y_bg, 1);
    }
    gpu_set_blendmode(bm_normal);

    draw_set_alpha(1);
    draw_set_color(c_white);
  }
}

with (_ctrl) {
  var _predeck_a = 0;
  if (t < _k_er_lift_charge_t) {
    _predeck_a = 1;
  } else if (t < _k_er_lift_beats[0]) {
    _predeck_a = 1 - clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_beats[0] - _k_er_lift_charge_t, 1), 0, 1);
  }

  if (_predeck_a > 0.02) {
    gpu_set_blendmode(bm_normal);

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
    var _wake = clamp((t - (_k_er_lift_charge_t - 190)) / 190, 0, 1);
    var _hum = clamp(floor_beat * 0.55 + bass_visual * 0.22 + floor_charge * 0.18 + _wake * 0.16, 0, 1);
    var _deck_alpha = _predeck_a;
    var _tsec = t / room_speed;

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
}
