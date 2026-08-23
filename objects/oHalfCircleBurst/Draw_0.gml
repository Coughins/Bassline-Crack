event_inherited();

var _eg_speed = point_distance(xprevious, yprevious, x, y);
var _eg_dir = (_eg_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
var _eg_col = merge_color(make_color_rgb(120, 200, 255), c_white, 0.2);

gpu_set_blendmode(bm_add);
gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _eg_uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _eg_uvs[0], _eg_uvs[1], _eg_uvs[2], _eg_uvs[3]);

shader_set_uniform_f(global.u_glow_color, 0.47, 0.78, 1);
shader_set_uniform_f(global.u_glow_intensity, 1.2 * image_alpha);
shader_set_uniform_f(global.u_glow_falloff, 1.6);
draw_sprite_ext(spr_glow_blob, 0, x, y, 0.7 * image_xscale, 0.7 * image_yscale, 0, c_white, 1);

shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
shader_set_uniform_f(global.u_glow_intensity, 1.4 * image_alpha);
shader_set_uniform_f(global.u_glow_falloff, 2.2);
draw_sprite_ext(spr_glow_blob, 0, x, y, 0.3 * image_xscale, 0.3 * image_yscale, 0, c_white, 1);

shader_reset();
gpu_set_blendequation(bm_eq_add);
gpu_set_blendmode(bm_normal);

if (_eg_speed > 4)
{
    var _eg_tail = min(_eg_speed * 1.6, 40);
    var _eg_tail_x = x - lengthdir_x(_eg_tail, _eg_dir);
    var _eg_tail_y = y - lengthdir_y(_eg_tail, _eg_dir);
    var _eg_perp = _eg_dir + 90;
    var _eg_off = 2.2 * fx_get_mult_for("halfcircle", "aberration");

    gpu_set_blendmode(bm_add);
    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(0.35 * image_alpha);
    draw_line_width(_eg_tail_x + lengthdir_x(_eg_off, _eg_perp), _eg_tail_y + lengthdir_y(_eg_off, _eg_perp),
                    x + lengthdir_x(_eg_off, _eg_perp), y + lengthdir_y(_eg_off, _eg_perp), 4);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_eg_tail_x - lengthdir_x(_eg_off, _eg_perp), _eg_tail_y - lengthdir_y(_eg_off, _eg_perp),
                    x - lengthdir_x(_eg_off, _eg_perp), y - lengthdir_y(_eg_off, _eg_perp), 4);

    if (chain_mode)
    {
        var _eg_jit = random_range(-5, 5);
        var _eg_mid_x = (_eg_tail_x + x) * 0.5 + lengthdir_x(_eg_jit, _eg_perp);
        var _eg_mid_y = (_eg_tail_y + y) * 0.5 + lengthdir_y(_eg_jit, _eg_perp);

        draw_set_color(_eg_col);
        draw_set_alpha(0.45 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, _eg_mid_x, _eg_mid_y, 7);
        draw_line_width(_eg_mid_x, _eg_mid_y, x, y, 7);
        draw_set_color(c_white);
        draw_set_alpha(0.8 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, _eg_mid_x, _eg_mid_y, 2.5);
        draw_line_width(_eg_mid_x, _eg_mid_y, x, y, 2.5);
    }
    else
    {
        draw_set_color(_eg_col);
        draw_set_alpha(0.45 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, x, y, 7);
        draw_set_color(c_white);
        draw_set_alpha(0.75 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, x, y, 3);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha);
gpu_set_blendmode(bm_normal);
