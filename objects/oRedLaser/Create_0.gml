event_inherited();
explode = 0
time = 0
get_smaller = 0
explode_timer = -1
already_hit_player = false;

hit_active = false;
beam_live = true;
beam_start_x = x;
beam_start_y = y;
beam_end_x = x;
beam_end_y = y;
beam_len = sprite_get_height(sprite_index);
beam_len_max = 1800;
beam_room_pad = 0;
beam_seed = random(1000);
beam_hit_half_width = 9;
beam_hit_half_width_max = 9;
beam_warn_half_width = 18;
beam_strike_scale = 2.7;
beam_shrink_step = 0.27;

u_laser_time_handle          = shader_get_uniform(shd_laser_beam, "u_time");
u_laser_noise_handle         = shader_get_sampler_index(shd_laser_beam, "u_noise");
u_laser_speed_handle         = shader_get_uniform(shd_laser_beam, "u_speed");
u_laser_coreWidth_handle     = shader_get_uniform(shd_laser_beam, "u_coreWidth");
u_laser_haloWidth_handle     = shader_get_uniform(shd_laser_beam, "u_haloWidth");
u_laser_noiseStrength_handle = shader_get_uniform(shd_laser_beam, "u_noiseStrength");
u_laser_twist_handle         = shader_get_uniform(shd_laser_beam, "u_twist");
u_laser_brightness_handle    = shader_get_uniform(shd_laser_beam, "u_brightness");
u_laser_whiteAmount_handle   = shader_get_uniform(shd_laser_beam, "u_whiteAmount");

laser_speed         = 4.6;
laser_coreWidth     = 0.5;
laser_haloWidth     = 1.2;
laser_noiseStrength = 0.2;
laser_twist         = 0.76;
laser_brightness    = 7.5;
laser_whiteAmount   = 3.4;

charging = false;
source_arrow = noone;
charge_timer = 0;
charge_duration = 20;
charge_flare = 0;
beam_dir = image_angle + 90;
