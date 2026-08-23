event_inherited();

var _lead_y = y;
var _lead_x = x + (sign(lengthdir_x(1, direction)) * 10);

var _spark_pulse = 1.6 + 0.4 * sin(current_time * 0.05);
gpu_set_blendmode(bm_add);
draw_set_color(c_white);
draw_set_alpha(0.6 * _spark_pulse);
draw_circle(x, y, 10 * _spark_pulse, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(trail_positions); i++)
{
    var _alpha = (i / array_length(trail_positions)) * 0.2;
    draw_sprite_ext(sprite_index, image_index, trail_positions[i], y, image_xscale, image_yscale, image_angle, c_red, _alpha);
}
gpu_set_blendmode(bm_normal);

gpu_set_blendmode(bm_add);
draw_set_color(c_red);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 5, image_yscale, image_angle, c_red, 0.3);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 2.5, image_yscale, image_angle, c_red, 0.45);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

gpu_set_texrepeat(true);
gpu_set_blendmode(bm_add);
shader_set(shd_laser_beam);
texture_set_stage(u_laser_noise_handle, sprite_get_texture(spr_laser_noise, 0));
shader_set_uniform_f(u_laser_time_handle, (current_time / 1000) mod 1000);
draw_self();
shader_reset();
gpu_set_blendmode(bm_normal);
gpu_set_texrepeat(false);
