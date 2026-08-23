function scr_draw_glow_line(_x1, _y1, _x2, _y2, _color, _intensity, _core_width) {
    var _k_stamp_spacing = 6;
    var _k_glow_scale    = 1.6;
    var _k_glow_falloff  = 1.0;
    var _k_core_alpha    = 0.85;
    var _k_core_whiten   = 0.5;

    var _dist  = point_distance(_x1, _y1, _x2, _y2);
    var _steps = max(1, floor(_dist / _k_stamp_spacing));

    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_color, color_get_red(_color) / 255, color_get_green(_color) / 255, color_get_blue(_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _intensity);
    shader_set_uniform_f(global.u_glow_falloff, _k_glow_falloff);

    for (var i = 0; i <= _steps; ++i) {
        var _px = lerp(_x1, _x2, i / _steps);
        var _py = lerp(_y1, _y2, i / _steps);
        draw_sprite_ext(spr_glow_blob, 0, _px, _py, _k_glow_scale, _k_glow_scale, 0, c_white, 1);
    }
    shader_reset();

    draw_set_alpha(_k_core_alpha);
    draw_set_color(merge_color(_color, c_white, _k_core_whiten));
    draw_line_width(_x1, _y1, _x2, _y2, _core_width);
    draw_set_alpha(1);
    draw_set_color(c_white);
}