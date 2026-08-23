_k_noise_scale      = 6.0;
_k_scroll_speed_x    = 0.02;
_k_scroll_speed_y    = 0.015;
_k_base_brightness   = 0.08;
_k_pulse_boost       = 0.85;
_k_pulse_decay       = 0.04;
_k_color_low         = [0.08, 0.08, 0.09];
_k_color_high        = [0.55, 0.05, 0.05];

bg_time = 0;
bg_pulse = 0;

u_time_h        = shader_get_uniform(shd_bg_plasma, "u_time");
u_intensity_h    = shader_get_uniform(shd_bg_plasma, "u_intensity");
u_noise_scale_h  = shader_get_uniform(shd_bg_plasma, "u_noise_scale");
u_scroll_h       = shader_get_uniform(shd_bg_plasma, "u_scroll_speed");
u_color_low_h    = shader_get_uniform(shd_bg_plasma, "u_color_low");
u_color_high_h   = shader_get_uniform(shd_bg_plasma, "u_color_high");
u_base_bright_h  = shader_get_uniform(shd_bg_plasma, "u_base_brightness");
_k_max_glow_points = 150;
glow_points = array_create(_k_max_glow_points * 2, -10);
glow_point_count = 0;

_k_darken_radius   = 130;
_k_darken_strength = 0.9;

u_glow_points_h     = shader_get_uniform(shd_bg_plasma, "u_glow_points");
u_darken_radius_h   = shader_get_uniform(shd_bg_plasma, "u_darken_radius");
u_darken_strength_h = shader_get_uniform(shd_bg_plasma, "u_darken_strength");

_view_x = -100;
_view_y = -100;
_view_w = room_width+100;
_view_h = room_height+100;