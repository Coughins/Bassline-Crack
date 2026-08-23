function scr_draw_center_laser_warning(){
if (center_warning_timer <= 0) exit;

var _prog = 1 - (center_warning_timer / _k_center_warning_duration);
var _alpha_mult = 0.3 + 0.7 * _prog;
var _hot_color = merge_color(_k_center_warning_color, _k_center_warning_hot_color, _prog);

vignette_pulse = max(vignette_pulse, 0.3 * _prog);
global_ripple_pulse = max(global_ripple_pulse, 0.25 * _prog);

gpu_set_blendmode(bm_add);
shader_set(shd_bullet_glow);
var _sclera_uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _sclera_uvs[0], _sclera_uvs[1], _sclera_uvs[2], _sclera_uvs[3]);
shader_set_uniform_f(global.u_glow_color,
    color_get_red(_hot_color)/255, color_get_green(_hot_color)/255, color_get_blue(_hot_color)/255);
shader_set_uniform_f(global.u_glow_intensity, _k_center_warning_sclera_intensity * _alpha_mult);
shader_set_uniform_f(global.u_glow_falloff, 2.2);
var _sclera_scale = _k_center_warning_sclera_radius / 32;
draw_sprite_ext(spr_glow_blob, 0, center_warning_x, center_warning_y, _sclera_scale, _sclera_scale, 0, c_white, 1);
shader_reset();
var _beam_angle = center_warning_image_angle - 90;
var _dx = lengthdir_x(1, _beam_angle);
var _dy = lengthdir_y(1, _beam_angle);
var _px = lengthdir_x(1, _beam_angle + 90);
var _py = lengthdir_y(1, _beam_angle + 90);
var _half_len = _k_center_warning_beam_half_len;
var _half_wid = _k_center_warning_beam_width * 0.5 * _alpha_mult * (1 + random_range(-_k_center_warning_jitter_width, _k_center_warning_jitter_width));

draw_primitive_begin(pr_trianglestrip);
draw_vertex_color(center_warning_x - _dx * _half_len, center_warning_y - _dy * _half_len, _hot_color, 0);
draw_vertex_color(center_warning_x + _px * _half_wid, center_warning_y + _py * _half_wid, _hot_color, 0.5 * _alpha_mult);
draw_vertex_color(center_warning_x - _px * _half_wid, center_warning_y - _py * _half_wid, _hot_color, 0.5 * _alpha_mult);
draw_vertex_color(center_warning_x + _dx * _half_len, center_warning_y + _dy * _half_len, _hot_color, 0);
draw_primitive_end();

var _lash_alpha = _prog * _alpha_mult;
if (_lash_alpha > 0.01)
{
    draw_set_color(_hot_color);
    var _half_count = _k_center_warning_lash_count / 2;
    for (var _side = -1; _side <= 1; _side += 2)
    {
        for (var _l = 0; _l < _half_count; _l++)
        {
            var _spread_t = (_half_count <= 1) ? 0 : (_l / (_half_count - 1));
            var _lash_angle = (_beam_angle + 90 * _side) + lerp(-_k_center_warning_lash_spread, _k_center_warning_lash_spread, _spread_t) * 0.5 + random_range(-_k_center_warning_jitter_angle, _k_center_warning_jitter_angle);
            var _lash_len = _k_center_warning_lash_length * _lash_alpha * (0.7 + 0.3 * _spread_t);
            var _lx = center_warning_x + lengthdir_x(_lash_len, _lash_angle);
            var _ly = center_warning_y + lengthdir_y(_lash_len, _lash_angle);
            draw_set_alpha(_lash_alpha * 0.7);
            draw_line_width(center_warning_x, center_warning_y, _lx, _ly, 2);
        }
    }
    draw_set_alpha(1);
}

shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color,
    color_get_red(_hot_color)/255, color_get_green(_hot_color)/255, color_get_blue(_hot_color)/255);
shader_set_uniform_f(global.u_glow_intensity, 0.8 * _alpha_mult);
shader_set_uniform_f(global.u_glow_falloff, 1.4);
var _core_scale = (_k_center_warning_core_radius / 32) * (0.9 + 0.2 * _prog);
draw_sprite_ext(spr_glow_blob, 0, center_warning_x, center_warning_y, _core_scale, _core_scale, 0, c_white, 1);
shader_reset();
shader_set(shd_bullet_glow);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
shader_set_uniform_f(global.u_glow_intensity, _k_center_warning_pupil_intensity * _alpha_mult);
shader_set_uniform_f(global.u_glow_falloff, 2.5);
var _pupil_scale = lerp(_k_center_warning_pupil_scale_start, _k_center_warning_pupil_scale_end, _prog) * (_k_center_warning_core_radius / 32);
draw_sprite_ext(spr_glow_blob, 0, center_warning_x, center_warning_y, _pupil_scale, _pupil_scale, 0, c_white, 1);
shader_reset();
for (var _e = 0; _e < array_length(iris_echoes); _e++)
{
    var _echo = iris_echoes[_e];
    var _echo_prog = _echo.age / _k_center_warning_echo_life;
    var _echo_alpha = lerp(_k_center_warning_echo_start_alpha, 0, _echo_prog) * _alpha_mult;
    if (_echo_alpha > 0.01)
    {
        draw_set_color(merge_color(_hot_color, c_white, 0.3));
        draw_set_alpha(_echo_alpha);
        draw_circle(center_warning_x, center_warning_y, _echo.radius, true);
    }
}
draw_set_color(merge_color(_hot_color, c_white, 0.5));
draw_set_alpha(0.6 * _alpha_mult);
var _iris_radius = lerp(_k_center_warning_iris_start_radius, 4, _prog);
draw_circle(center_warning_x, center_warning_y, _iris_radius, true);
draw_set_alpha(1);
var _glint_pulse = 0.6 + 0.4 * sin(current_time * _k_center_warning_glint_speed);
draw_set_color(c_white);
draw_set_alpha(_k_center_warning_glint_alpha * _glint_pulse * _alpha_mult);
draw_circle(center_warning_x + _k_center_warning_glint_offset_x, center_warning_y + _k_center_warning_glint_offset_y, _k_center_warning_glint_radius, false);
draw_set_alpha(1);

gpu_set_blendmode(bm_normal);
}