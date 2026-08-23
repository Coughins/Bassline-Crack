function scr_draw_avoidance_big_red_orb_glow() {
  if (!instance_exists(oBigRedOrb))
    return;

  gpu_set_blendmode(bm_add);
  gpu_set_blendequation(bm_eq_max);
  shader_set(shd_bullet_glow);

  var _uvs = sprite_get_uvs(spr_glow_blob, 0);
  shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
  shader_set_uniform_f(global.u_glow_color, 1.0, 0.2, 0.2);
  shader_set_uniform_f(global.u_glow_intensity, 1.0);
  shader_set_uniform_f(global.u_glow_falloff, 1.0);

  var _count = instance_number(oBigRedOrb);
  for (var _i = 0; _i < _count; _i++) {
    var _orb = instance_find(oBigRedOrb, _i);
    if (!instance_exists(_orb)) continue;

    var gui_x = (_orb.x - oCameraController.current_cam_x) * (oCameraController.base_view_w / oCameraController.current_cam_w);
    var gui_y = (_orb.y - oCameraController.current_cam_y) * (oCameraController.base_view_h / oCameraController.current_cam_h);

    var _k_glow_scale = 1.2;
    var _glow_scale = _orb.image_xscale * _k_glow_scale;

    draw_sprite_ext(spr_glow_blob, 0, gui_x, gui_y, _glow_scale, _glow_scale, 0, c_white, 1);
  }

  shader_reset();
  gpu_set_blendequation(bm_eq_add);
  gpu_set_blendmode(bm_normal);
}
