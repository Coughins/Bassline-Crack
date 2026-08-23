shader_id = shd_matrix_rain;

matrix_speed = 0.1;
_k_walk_mult = 1.0;
_k_walk_charge = 2.0;
_k_fall_mult = 9.0;
_k_fall_charge = 5.0;
_k_fall_beat = 6.0;

_k_beat_ref = 0.35;
_k_bloom_ref = 0.55;
_k_charge_ramp = 0.45;
_k_ramp_start = 4000;
_k_ramp_end = 7123;
_k_hit_threshold = 0.12;
_k_hit_ref = 1.2;
_k_impact_decay = 0.13;
_k_glitch_ref = 1.6;
_k_glitch_decay = 0.22;

_k_shock_max = 3;
_k_shock_speed = 1.15;
_k_shock_range = 27;
_k_shock_fade = 0.955;

_k_roll_kick = 0.055;
_k_roll_decay = 0.16;

_k_deep_color = make_color_rgb(150, 12, 24);
_k_hot_white = 0.75;

matrix_time = 0;
matrix_rain_time = 0;

matrix_beat = 0;
matrix_impact = 0;
matrix_charge = 0;
matrix_glitch = 0;
matrix_roll = 0;

matrix_prev_aberration = 0;
matrix_shocks = [];

matrix_brightness = 1.0;

alpha = 0;
target_alpha = 1;

fade_speed = 0.03;

u_time = shader_get_uniform(shader_id, "u_time");
u_rain_time = shader_get_uniform(shader_id, "u_rain_time");
u_resolution = shader_get_uniform(shader_id, "u_resolution");

u_speed = shader_get_uniform(shader_id, "u_speed");
u_brightness = shader_get_uniform(shader_id, "u_brightness");

u_color = shader_get_uniform(shader_id, "u_color");
u_color_deep = shader_get_uniform(shader_id, "u_color_deep");
u_color_hot = shader_get_uniform(shader_id, "u_color_hot");

u_beat = shader_get_uniform(shader_id, "u_beat");
u_impact = shader_get_uniform(shader_id, "u_impact");
u_charge = shader_get_uniform(shader_id, "u_charge");
u_glitch = shader_get_uniform(shader_id, "u_glitch");
u_roll = shader_get_uniform(shader_id, "u_roll");

u_shock_r = shader_get_uniform(shader_id, "u_shock_r");
u_shock_p = shader_get_uniform(shader_id, "u_shock_p");

_view_x = -room_width;
_view_y = -room_height;

_view_w = room_width * 3;
_view_h = room_height * 3;
