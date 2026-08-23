function scr_draw_avoidance_simple_object_glows() {
  scr_draw_avoidance_falling_red_orb_glow();
  scr_draw_avoidance_red_arrow_glow();
  scr_draw_avoidance_red_bullet_intro_glow();
  scr_draw_avoidance_energized_killer_glow();
  scr_draw_avoidance_cube_basic_glow();
  scr_draw_avoidance_red_orb_squares_glow();
  scr_draw_avoidance_red_orb_square_trail_glow();
  scr_draw_avoidance_half_circle_burst_glow();
  scr_draw_avoidance_kunai_warning_glow();
  scr_draw_avoidance_red_kunai_glow();
  scr_draw_avoidance_ring_orb_basic_glow();
  scr_draw_avoidance_red_orb2_glow();
  scr_draw_avoidance_burst_ring_orb_glow();
  scr_draw_avoidance_ring_orb_fake_glow();
}

function scr_draw_avoidance_falling_red_orb_glow() {
  var _k_sustained_glow_intensity = 0.9;
  var _k_telegraph_color_start = c_red;
  var _k_telegraph_color_end = c_white;
  var _k_sustained_glow_color = global.avoid_col_danger;
  var _k_core_flash_color = make_color_rgb(255, 255, 240);
  var _k_pop_flash_peak_intensity = 1.8;
  var _k_pop_flash_peak_scale = 1.8;
  var _k_core_peak_intensity = 1.8;
  var _k_core_peak_scale = 1.0;

  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oFallingRedOrb);

  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oFallingRedOrb, _i);
    if (!instance_exists(_orb)) continue;
    if (!_orb.telegraphing && !_orb.glowing) continue;

    var gui_x = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      _glow_active = true;
    }

    if (_orb.telegraphing) {
      var _prog = 1 - (_orb.telegraph_timer / _orb.telegraph_duration);
      var _glow_color = merge_color(_k_telegraph_color_start, _k_telegraph_color_end, _prog);
      shader_set_uniform_f(global.u_glow_color, color_get_red(_glow_color) / 255,
                           color_get_green(_glow_color) / 255, color_get_blue(_glow_color) / 255);
      shader_set_uniform_f(global.u_glow_intensity, lerp(0.6, 1.8, _prog));
      shader_set_uniform_f(global.u_glow_falloff, 1.4);
      draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, lerp(1.0, 1.8, _prog), lerp(1.0, 1.8, _prog), 0, c_white, 1);
    }

    if (_orb.glowing) {
      var _flash_prog = clamp(_orb.pop_flash_timer / _orb.pop_flash_duration, 0, 1);
      var _intensity = lerp(_k_pop_flash_peak_intensity, _k_sustained_glow_intensity, _flash_prog);
      var _scale = lerp(_k_pop_flash_peak_scale, 1.2, _flash_prog);

      shader_set_uniform_f(global.u_glow_color, color_get_red(_k_sustained_glow_color) / 255,
                           color_get_green(_k_sustained_glow_color) / 255, color_get_blue(_k_sustained_glow_color) / 255);
      shader_set_uniform_f(global.u_glow_intensity, _intensity);
      shader_set_uniform_f(global.u_glow_falloff, 1.3);
      draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _scale, _scale, 0, c_white, 1);

      if (_flash_prog < 0.66) {
        var _core_prog = _flash_prog / 0.66;
        shader_set_uniform_f(global.u_glow_color, color_get_red(_k_core_flash_color) / 255,
                             color_get_green(_k_core_flash_color) / 255, color_get_blue(_k_core_flash_color) / 255);
        shader_set_uniform_f(global.u_glow_intensity, lerp(_k_core_peak_intensity, 0, _core_prog));
        shader_set_uniform_f(global.u_glow_falloff, 1.6);
        draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, lerp(0.6, _k_core_peak_scale, _core_prog),
                        lerp(0.6, _k_core_peak_scale, _core_prog), 0, c_white, 1);
      }
    }
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_red_arrow_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oRedArrow);

  for (var _i = 0; _i < _count; _i++) {
    var _arrow = instance_find(oRedArrow, _i);
    if (!instance_exists(_arrow) || !_arrow.glow_enabled) continue;

    var gui_x = (_arrow.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_arrow.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      _glow_active = true;
    }

    var _flash_prog = clamp(_arrow.glow_timer / _arrow._k_glow_flash_duration, 0, 1);
    var _intensity = lerp(_arrow._k_glow_peak_intensity, _arrow._k_glow_sustain_intensity, _flash_prog);
    var _glow_scale = _arrow.image_xscale * lerp(_arrow._k_glow_peak_scale_mult, _arrow._k_glow_sustain_scale_mult, _flash_prog);
    var _glow_stretch = _glow_scale * _arrow.draw_stretch;

    shader_set_uniform_f(global.u_glow_color, color_get_red(_arrow.image_blend) / 255,
                         color_get_green(_arrow.image_blend) / 255, color_get_blue(_arrow.image_blend) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _intensity);
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_stretch, _glow_scale, _arrow.image_angle, c_white, 1);

    if (_flash_prog < 0.5) {
      var _core_prog = _flash_prog / 0.5;
      var _core_scale = _arrow.image_xscale * lerp(1.0, _arrow._k_glow_core_scale_mult, _core_prog);
      shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
      shader_set_uniform_f(global.u_glow_intensity, lerp(_arrow._k_glow_core_intensity, 0, _core_prog));
      shader_set_uniform_f(global.u_glow_falloff, 1.6);
      draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _core_scale, _core_scale, 0, c_white, 1);
    }
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_red_bullet_intro_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _danger_col = global.avoid_col_danger;
  var _lr = color_get_red(_danger_col) / 255;
  var _lg = color_get_green(_danger_col) / 255;
  var _lb = color_get_blue(_danger_col) / 255;
  var _count = instance_number(oRedBulletIntro);

  for (var _i = 0; _i < _count; _i++) {
    var _bullet = instance_find(oRedBulletIntro, _i);
    if (!instance_exists(_bullet) || !_bullet.revealed) continue;

    var gui_x = (_bullet.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_bullet.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      _glow_active = true;
    }

    var _flash_prog = clamp((_bullet.pop_flash - 0) / 1, 0, 1);
    var _gr = lerp(_lr, 1, _flash_prog);
    var _gg = lerp(_lg, 1, _flash_prog);
    var _gb = lerp(_lb, 1, _flash_prog);
    var _intensity = lerp(_bullet.glow_sustain_intensity, _bullet.glow_sustain_intensity + _bullet.glow_flash_bonus, _flash_prog);
    var _glow_scale = _bullet.image_xscale * lerp(_bullet.glow_scale_mult, _bullet.glow_core_scale_mult, _flash_prog);

    shader_set_uniform_f(global.u_glow_color, _gr, _gg, _gb);
    shader_set_uniform_f(global.u_glow_intensity, _intensity);
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale, _glow_scale, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_energized_killer_glow() {
  var _glow_active = false;
  var _uv = sprite_get_uvs(spr_glow_blob, 0);
  var _r = color_get_red(global.lightning_color) / 255;
  var _g = color_get_green(global.lightning_color) / 255;
  var _b = color_get_blue(global.lightning_color) / 255;
  var _u_color = shader_get_uniform(shd_bullet_glow, "u_color");
  var _u_intensity = shader_get_uniform(shd_bullet_glow, "u_intensity");
  var _u_falloff = shader_get_uniform(shd_bullet_glow, "u_falloff");
  var _u_uvrect = shader_get_uniform(shd_bullet_glow, "u_uvRect");
  var _count = instance_number(oKiller);

  for (var _i = 0; _i < _count; _i++) {
    var _bullet = instance_find(oKiller, _i);
    if (!instance_exists(_bullet) || !_bullet.energized) continue;

    if (!_glow_active) {
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(_u_color, _r, _g, _b);
      shader_set_uniform_f(_u_falloff, 2.2);
      shader_set_uniform_f(_u_uvrect, _uv[0], _uv[1], _uv[2], _uv[3]);
      _glow_active = true;
    }

    shader_set_uniform_f(_u_intensity, 0.2 * _bullet.energize_flicker);
    draw_sprite_ext(spr_glow_blob, 0, _bullet.x, _bullet.y,
                    (_bullet.sprite_width * 4.5 * _bullet.energize_glow_scale) / sprite_get_width(spr_glow_blob),
                    (_bullet.sprite_height * 4.5 * _bullet.energize_glow_scale) / sprite_get_height(spr_glow_blob),
                    0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
  }
}

function scr_draw_avoidance_cube_basic_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _r = color_get_red(global.lightning_color) / 255;
  var _g = color_get_green(global.lightning_color) / 255;
  var _b = color_get_blue(global.lightning_color) / 255;
  var _count = instance_number(oCube);

  for (var _i = 0; _i < _count; _i++) {
    var _cube = instance_find(oCube, _i);
    if (!instance_exists(_cube)) continue;

    var gui_x = (_cube.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_cube.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_color, _r, _g, _b);
      shader_set_uniform_f(global.u_glow_intensity, 1.0);
      shader_set_uniform_f(global.u_glow_falloff, 1.6);
      _glow_active = true;
    }

    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, 3.0, 3.0, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_red_orb_squares_glow() {
  if (!instance_exists(oRedOrbSquares))
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

  var _count = instance_number(oRedOrbSquares);
  for (var _i = 0; _i < _count; _i++) {
    var _sq = instance_find(oRedOrbSquares, _i);
    if (!instance_exists(_sq) || _sq.hide_visual) continue;

    var _k_corner_scale_mult = 2.6;
    var _k_edge_scale_mult = 1.5;
    var _k_corner_intensity = 1.3;
    var _k_edge_intensity = 0.72;
    var _k_glow_falloff = 1.0;

    var gui_x = (_sq.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_sq.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _scale_mult = _sq.is_corner ? _k_corner_scale_mult : _k_edge_scale_mult;
    var _intensity = (_sq.is_corner ? _k_corner_intensity : _k_edge_intensity)
                   * (1 + _sq.burst_escalation * 0.45 + _sq.birth_heat * 0.9) * _sq.glow_mult;
    var _glow_scale = _sq.base_size * _sq.pop_scale * _scale_mult * 0.4
                    * (0.45 + _sq.glow_mult * 0.55);

    shader_set_uniform_f(global.u_glow_color, color_get_red(_sq.glow_color) / 255,
                         color_get_green(_sq.glow_color) / 255, color_get_blue(_sq.glow_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _intensity);
    shader_set_uniform_f(global.u_glow_falloff, _k_glow_falloff);

    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale * _sq.stretch,
                    _glow_scale / max(1, sqrt(_sq.stretch)), _sq.direction, c_white, _sq.image_alpha);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}

function scr_draw_avoidance_red_orb_square_trail_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oRedOrbSquares_Trail);

  for (var _i = 0; _i < _count; _i++) {
    var _trail = instance_find(oRedOrbSquares_Trail, _i);
    if (!instance_exists(_trail)) continue;

    var _k_glow_scale_mult = 3.0;
    var _k_glow_intensity = 1.3;
    var _k_glow_falloff = 1.0;
    var gui_x = (_trail.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_trail.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _glow_scale = _trail.image_xscale * _k_glow_scale_mult * 0.4;

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_falloff, _k_glow_falloff);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_color, color_get_red(_trail.glow_color) / 255,
                         color_get_green(_trail.glow_color) / 255, color_get_blue(_trail.glow_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _k_glow_intensity * _trail.image_alpha * (1 + _trail.burst_escalation * 0.4));
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale, _glow_scale, 0, c_white, _trail.image_alpha);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_half_circle_burst_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oHalfCircleBurst);

  for (var _i = 0; _i < _count; _i++) {
    var _burst = instance_find(oHalfCircleBurst, _i);
    if (!instance_exists(_burst)) continue;

    var gui_x = (_burst.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_burst.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_color, 0.42, 0.72, 0.95);
      shader_set_uniform_f(global.u_glow_intensity, 0.85);
      shader_set_uniform_f(global.u_glow_falloff, 1.25);
      _glow_active = true;
    }

    var _burst_size = variable_instance_exists(_burst, "_size")
                    ? max(0.7, _burst._size)
                    : max(0.7, max(abs(_burst.image_xscale), abs(_burst.image_yscale)));
    var _burst_alpha = clamp(_burst.image_alpha, 0, 1);
    var _glow_scale = clamp(0.95 + _burst_size * 0.42, 0.95, 2.05);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale, _glow_scale, 0, c_white, 0.76 * _burst_alpha);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_kunai_warning_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oKunaiWarning);

  for (var _i = 0; _i < _count; _i++) {
    var _warning = instance_find(oKunaiWarning, _i);
    if (!instance_exists(_warning)) continue;

    var _t = 1 - (_warning.life / _warning.max_life);
    var _fade_frames = min(3, _warning.max_life);
    var _fade_in = clamp((_warning.max_life - _warning.life) / _fade_frames, 0, 1);
    var _fade_out = clamp(_warning.life / _fade_frames, 0, 1);
    var _envelope = min(_fade_in, _fade_out);
    var _flash = (_t > 0.75) ? (_t - 0.75) / 0.25 : 0;
    var gui_x = (_warning.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (30 - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_falloff, 1.4);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_color, 1.0, lerp(0.2, 1.0, _flash), lerp(0.2, 1.0, _flash));
    shader_set_uniform_f(global.u_glow_intensity, (1.0 + _flash * 1.0) * _envelope);

    var _w = (lerp(35, 55, _t) * _envelope) / sprite_get_width(spr_glow_blob);
    var _h = (lerp(60, 95, _t) * _envelope) / sprite_get_height(spr_glow_blob);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _w, _h, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_red_kunai_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oRedKunai);

  for (var _i = 0; _i < _count; _i++) {
    var _kunai = instance_find(oRedKunai, _i);
    if (!instance_exists(_kunai)) continue;

    var gui_x = (_kunai.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_kunai.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _motion_speed = _kunai.is_thrown ? sqrt(_kunai.hsp * _kunai.hsp + _kunai.vsp * _kunai.vsp) : max(_kunai.speed, _kunai.dash_speed);
    var _speed_t = clamp((_motion_speed - 8) / 16, 0, 1);
    var _spawn_t = (_kunai.spawn_duration > 0) ? clamp(_kunai.spawn_timer / _kunai.spawn_duration, 0, 1) : 1;
    var _spawn_flash = sqr(1 - _spawn_t);
    var _return_t = (_kunai.is_feeder && _kunai.state == "returning") ? clamp(_kunai.return_timer / max(_kunai.return_duration, 1), 0, 1) : 0;
    var _heat = max(_speed_t, _spawn_flash * 0.65, _return_t * 0.75);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_color, 1.0, lerp(0.32, 0.12, _heat), lerp(0.28, 0.08, _heat));
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.85, 2.45, _heat));
    shader_set_uniform_f(global.u_glow_falloff, lerp(1.75, 1.15, _heat));
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, lerp(0.62, 1.22, _heat), lerp(0.7, 1.45, _heat), _kunai.image_angle, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_ring_orb_basic_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oRingOrb);

  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oRingOrb, _i);
    if (!instance_exists(_orb)) continue;

    var gui_x = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_intensity, 1.0);
      shader_set_uniform_f(global.u_glow_falloff, 1.0);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_color, colour_get_red(_orb.ring_color) / 255,
                         colour_get_green(_orb.ring_color) / 255, colour_get_blue(_orb.ring_color) / 255);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _orb._size * 1.0, _orb._size * 1.0, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_red_orb2_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _danger_col = global.avoid_col_danger;
  var _lr = colour_get_red(_danger_col) / 255;
  var _lg = colour_get_green(_danger_col) / 255;
  var _lb = colour_get_blue(_danger_col) / 255;
  var _count = instance_number(oRedOrb_2);

  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oRedOrb_2, _i);
    if (!instance_exists(_orb)) continue;

    var gui_x = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_color, _lr, _lg, _lb);
      shader_set_uniform_f(global.u_glow_falloff, 1.0);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_intensity, _orb.image_alpha);
    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _orb._size * 1.0, _orb._size * 1.0, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}

function scr_draw_avoidance_burst_ring_orb_glow() {
  var _count = instance_number(oRingOrb);

  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oRingOrb, _i);
    if (!instance_exists(_orb)) continue;

    var _ro_gx = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _ro_gy = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);
    var _ro_spd = point_distance(_orb.xprevious, _orb.yprevious, _orb.x, _orb.y);
    var _ro_dir = (_ro_spd > 0.01) ? point_direction(_orb.xprevious, _orb.yprevious, _orb.x, _orb.y) : _orb.image_angle;
    var _ro_stretch = 1 + clamp(_ro_spd / 14, 0, 1) * 3.2;
    var _ro_charge = (_orb.use_dash && _orb.dash_state == 1) ? (_orb.dash_timer / max(1, _orb.dash_wait_duration)) : 0;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);

    var _ro_uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _ro_uvs[0], _ro_uvs[1], _ro_uvs[2], _ro_uvs[3]);
    shader_set_uniform_f(global.u_glow_color, color_get_red(_orb.ring_color) / 255,
                         color_get_green(_orb.ring_color) / 255, color_get_blue(_orb.ring_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, 0.9 + _orb.ring_tier * 0.12 + _ro_charge * 1.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.5);

    var _ro_scale = (1.1 + _orb._size * 0.35 + _ro_charge * 0.6);
    draw_sprite_ext(spr_glow_blob, 0, _ro_gx, _ro_gy, _ro_scale * _ro_stretch, _ro_scale, _ro_dir, c_white, 1);

    var _ro_colored_core = (_orb.ring_tier >= 3);
    var _ro_core_col = _ro_colored_core ? merge_color(_orb.ring_color, c_white, 0.16) : c_white;
    shader_set_uniform_f(global.u_glow_color, color_get_red(_ro_core_col) / 255,
                         color_get_green(_ro_core_col) / 255, color_get_blue(_ro_core_col) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _ro_colored_core ? (0.55 + _ro_charge * 0.65) : (1.1 + _ro_charge * 1.6));
    shader_set_uniform_f(global.u_glow_falloff, _ro_colored_core ? 2.7 : 2.3);
    draw_sprite_ext(spr_glow_blob, 0, _ro_gx, _ro_gy, _ro_scale * (_ro_colored_core ? 0.22 : 0.38),
                    _ro_scale * (_ro_colored_core ? 0.22 : 0.38), 0, c_white, 1);

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);

    if (_ro_spd > 6) {
      var _ro_tail = min(_ro_spd * 2.2, 60);
      var _ro_tx = _ro_gx - lengthdir_x(_ro_tail, _ro_dir);
      var _ro_ty = _ro_gy - lengthdir_y(_ro_tail, _ro_dir);
      var _ro_perp = _ro_dir + 90;

      gpu_set_blendmode(bm_add);
      draw_set_color(global.avoid_col_danger);
      draw_set_alpha(0.4);
      draw_line_width(_ro_tx + lengthdir_x(3, _ro_perp), _ro_ty + lengthdir_y(3, _ro_perp),
                      _ro_gx + lengthdir_x(3, _ro_perp), _ro_gy + lengthdir_y(3, _ro_perp), 5);
      draw_set_color(global.avoid_col_cyan);
      draw_line_width(_ro_tx - lengthdir_x(3, _ro_perp), _ro_ty - lengthdir_y(3, _ro_perp),
                      _ro_gx - lengthdir_x(3, _ro_perp), _ro_gy - lengthdir_y(3, _ro_perp), 5);
      draw_set_color(c_white);
      draw_set_alpha(0.8);
      draw_line_width(_ro_tx, _ro_ty, _ro_gx, _ro_gy, 2);
      draw_set_alpha(1);
      gpu_set_blendmode(bm_normal);
    }
  }
}

function scr_draw_avoidance_ring_orb_fake_glow() {
  var _glow_active = false;
  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  var _count = instance_number(oRingOrbFake);

  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oRingOrbFake, _i);
    if (!instance_exists(_orb)) continue;

    var _rf_gx = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _rf_gy = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    if (!_glow_active) {
      gpu_set_blendmode(bm_add);
      gpu_set_blendequation(bm_eq_max);
      shader_set(shd_bullet_glow);
      shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
      shader_set_uniform_f(global.u_glow_falloff, 1.9);
      _glow_active = true;
    }

    shader_set_uniform_f(global.u_glow_color, color_get_red(_orb.ring_color) / 255,
                         color_get_green(_orb.ring_color) / 255, color_get_blue(_orb.ring_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, 0.55 * _orb.image_alpha);
    draw_sprite_ext(spr_glow_blob, 0, _rf_gx, _rf_gy, 0.8 + _orb._size * 0.25, 0.8 + _orb._size * 0.25, 0, c_white, 1);
  }

  if (_glow_active) {
    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
  }
}
