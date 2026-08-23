function scr_draw_avoidance_fruit_idle_glow() {
  if (!instance_exists(oFruit))
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
  shader_set_uniform_f(global.u_glow_falloff, 1.7);

  var _count = instance_number(oFruit);
  for (var _i = 0; _i < _count; _i++) {
    var _fruit = instance_find(oFruit, _i);
    if (!instance_exists(_fruit)) continue;

    var _cocoon_heat = variable_instance_exists(_fruit, "cocoon_pressure") ? _fruit.cocoon_pressure : 0;
    var _cocoon_alpha = variable_instance_exists(_fruit, "cocoon_shell_alpha") ? _fruit.cocoon_shell_alpha : 0;
    var _ripe_color = merge_color(_fruit._k_unripe_color, _fruit.fruit_color, _fruit.base_alpha);
    _ripe_color = merge_color(merge_color(global.avoid_col_cyan, _ripe_color, 0.55), _ripe_color, clamp(_cocoon_heat * 0.65, 0, 1));
    var _fr = color_get_red(_ripe_color) / 255;
    var _fg = color_get_green(_ripe_color) / 255;
    var _fb = color_get_blue(_ripe_color) / 255;
    var _gx = (_fruit.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var _gy = (_fruit.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    shader_set_uniform_f(global.u_glow_color, _fr, _fg, _fb);
    shader_set_uniform_f(global.u_glow_intensity, _fruit.base_alpha * 0.9 + _fruit.crack_glow + _cocoon_alpha * 0.35);
    draw_sprite_ext(spr_glow_blob, 0, _gx, _gy, 1.3 + _cocoon_heat * 0.22, 1.3 + _cocoon_heat * 0.22, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}
