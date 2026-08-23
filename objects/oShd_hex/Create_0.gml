intro_dim = 0;

u_time_h = shader_get_uniform(shd_hex_2, "u_time");
u_resolution_h = shader_get_uniform(shd_hex_2, "u_resolution");
u_intro_dim_h = shader_get_uniform(shd_hex_2, "u_intro_dim");
u_bass_h = shader_get_uniform(shd_hex_2, "u_bass");
u_beat_h = shader_get_uniform(shd_hex_2, "u_beat");
u_charge_h = shader_get_uniform(shd_hex_2, "u_charge");

u_quad_scale_h = shader_get_uniform(shd_hex_2, "u_quad_scale");
u_floor_zoom_h = shader_get_uniform(shd_hex_2, "u_floor_zoom");
u_floor_offset_h = shader_get_uniform(shd_hex_2, "u_floor_offset");
u_spin_h = shader_get_uniform(shd_hex_2, "u_spin");

u_bass_waves_h = shader_get_uniform(shd_hex_2, "u_bass_waves");
u_bass_wave_count_h = shader_get_uniform(shd_hex_2, "u_bass_wave_count");
u_impact_radius_h = shader_get_uniform(shd_hex_2, "u_impact_wave_radius");
u_impact_color_h = shader_get_uniform(shd_hex_2, "u_impact_wave_color");
u_quakes_h = shader_get_uniform(shd_hex_2, "u_quakes");
u_quake_count_h = shader_get_uniform(shd_hex_2, "u_quake_count");
u_scar_a_h = shader_get_uniform(shd_hex_2, "u_scar_a");
u_scar_b_h = shader_get_uniform(shd_hex_2, "u_scar_b");
u_scar_c_h = shader_get_uniform(shd_hex_2, "u_scar_c");
u_scar_col_h = shader_get_uniform(shd_hex_2, "u_scar_col");
u_scar_count_h = shader_get_uniform(shd_hex_2, "u_scar_count");
u_focus_h = shader_get_uniform(shd_hex_2, "u_focus");
u_focus_amt_h = shader_get_uniform(shd_hex_2, "u_focus_amt");

u_player_pos_h = shader_get_uniform(shd_hex_2, "u_player_pos");
u_player_glow_h = shader_get_uniform(shd_hex_2, "u_player_glow");
u_shadow_pos_h = shader_get_uniform(shd_hex_2, "u_shadow_pos");
u_shadow_count_h = shader_get_uniform(shd_hex_2, "u_shadow_count");
u_light_pos_h = shader_get_uniform(shd_hex_2, "u_light_pos_flat");
u_light_color_h = shader_get_uniform(shd_hex_2, "u_light_color");
u_light_power_h = shader_get_uniform(shd_hex_2, "u_light_power");
u_light_count_h = shader_get_uniform(shd_hex_2, "u_light_count");

buf_light_pos = array_create(256, 0);
buf_light_color = array_create(384, 0);
buf_light_power = array_create(128, 0);
buf_waves = array_create(8, 0);
buf_shadow_pos = array_create(64, 0);
buf_quakes = array_create(24, 0);
buf_scar_a = array_create(32, 0);
buf_scar_b = array_create(32, 0);
buf_scar_c = array_create(32, 0);
buf_scar_col = array_create(24, 0);

_k_floor_parallax = 1.0;

_k_quad_pad = 1.30;

_k_player_glow = 0.55;
