
var _push = oAvoidanceController.blackhole_push_mode;

var _base_col = _push ? c_white : merge_color(c_purple, global.lightning_color, 0.35 + rain_escalation * 0.4);
var _hot_col = merge_color(_base_col, c_white, 0.55 + rain_escalation * 0.35 + inverted_flash * 0.5);

var _tn = array_length(trail_positions);

if (_tn > 1)
{
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < _tn - 1; i++)
    {
        var _p0 = trail_positions[i];
        var _p1 = trail_positions[i + 1];
        var _ta = (i / _tn);
        var _tw = 1 + _ta * (2.5 + capture * 4);

        draw_set_color(_base_col);
        draw_set_alpha(_ta * 0.34 * (1 + capture));
        draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], _tw * 2.4);

        draw_set_color(_hot_col);
        draw_set_alpha(_ta * 0.6 * (1 + capture));
        draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], _tw);
    }
    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(1);

var _fringe = (capture * 4 + rain_escalation * 1.5 + inverted_flash * 5) * fx_get_mult_for("blackholes", "aberration");
if (_fringe > 0.4 && _tn > 1)
{
    var _tail = trail_positions[0];
    var _perp = direction + 90;
    gpu_set_blendmode(bm_add);
    draw_set_color(c_red);
    draw_set_alpha(0.35);
    draw_line_width(_tail[0] + lengthdir_x(_fringe, _perp), _tail[1] + lengthdir_y(_fringe, _perp),
                    x + lengthdir_x(_fringe, _perp), y + lengthdir_y(_fringe, _perp), 2);
    draw_set_color(c_aqua);
    draw_line_width(_tail[0] - lengthdir_x(_fringe, _perp), _tail[1] - lengthdir_y(_fringe, _perp),
                    x - lengthdir_x(_fringe, _perp), y - lengthdir_y(_fringe, _perp), 2);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

if (rewinding)
{
    var _rgb_off_mult = fx_get_mult_for("blackholes", "aberration");
    var _rgb_ox = rgb_offset_x * _rgb_off_mult;
    var _rgb_oy = rgb_offset_y * _rgb_off_mult;
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x + _rgb_ox, y, image_xscale, image_yscale, image_angle, c_red, 0.5);
    draw_sprite_ext(sprite_index, image_index, x - _rgb_ox, y + _rgb_oy, image_xscale, image_yscale, image_angle, c_aqua, 0.5);
    draw_sprite_ext(sprite_index, image_index, x, y - _rgb_oy, image_xscale, image_yscale, image_angle, c_lime, 0.35);
    gpu_set_blendmode(bm_normal);
}

var _sx = image_xscale * (1 + inverted_flash * 0.6);
var _sy = image_yscale * (1 + inverted_flash * 0.6);
draw_sprite_ext(sprite_index, image_index, x, y, _sx * stretch, _sy / max(1, sqrt(stretch)), direction,
                image_blend, image_alpha);

gpu_set_blendmode(bm_add);
gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(_hot_col) / 255, color_get_green(_hot_col) / 255,
                     color_get_blue(_hot_col) / 255);
shader_set_uniform_f(global.u_glow_intensity, (0.7 + rain_escalation * 0.5 + capture * 0.8 + inverted_flash * 1.2) * image_alpha);
shader_set_uniform_f(global.u_glow_falloff, 1.3);
var _gs = 0.36 * (1 + capture * 0.8 + inverted_flash);
draw_sprite_ext(spr_glow_blob, 0, x, y, _gs, _gs, 0, c_white, 1);
shader_reset();
gpu_set_blendequation(bm_eq_add);
gpu_set_blendmode(bm_normal);

draw_set_alpha(1);
draw_set_color(c_white);
