
var _age = 1 - (life / life_max);
var _a = (life / life_max) * image_alpha * fx_dim;
var _col = scr_hot_metal_color(_age * (1.15 - hot * 0.35));

gpu_set_blendmode(bm_add);

draw_set_color(_col);
draw_set_alpha(_a * 0.45);
draw_line_width(prev_x, prev_y, x, y, size * 1.6);

draw_set_color(merge_color(_col, c_white, 0.45 * _a));
draw_set_alpha(_a);
draw_circle(x, y, max(0.5, size * (1 - _age * 0.55)), false);

gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(_col) / 255, color_get_green(_col) / 255,
                     color_get_blue(_col) / 255);
shader_set_uniform_f(global.u_glow_intensity, _a * 0.75);
shader_set_uniform_f(global.u_glow_falloff, 1.4);
var _gs = 0.22 * (1 - _age * 0.4);
draw_sprite_ext(spr_glow_blob, 0, x, y, _gs, _gs, 0, c_white, 1);
shader_reset();
gpu_set_blendequation(bm_eq_add);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
