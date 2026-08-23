shader_set(shd_bg_plasma);
shader_set_uniform_f(u_time_h, bg_time);
shader_set_uniform_f(u_intensity_h, bg_pulse);
shader_set_uniform_f(u_noise_scale_h, _k_noise_scale);
shader_set_uniform_f(u_scroll_h, _k_scroll_speed_x, _k_scroll_speed_y);
shader_set_uniform_f_array(u_color_low_h, _k_color_low);
shader_set_uniform_f_array(u_color_high_h, _k_color_high);
shader_set_uniform_f(u_base_bright_h, _k_base_brightness);

shader_set_uniform_f_array(u_glow_points_h, glow_points);
shader_set_uniform_f(u_darken_radius_h, _k_darken_radius / _view_w);
shader_set_uniform_f(u_darken_strength_h, _k_darken_strength);

draw_rectangle(_view_x, _view_y, _view_x + _view_w, _view_y + _view_h, false);

shader_reset();