is_rotating = 0
rotate_speed = 0
explode = 0
get_smaller = 0

u_laser_time_handle  = shader_get_uniform(shd_laser_beam, "u_time");
u_laser_noise_handle = shader_get_sampler_index(shd_laser_beam, "u_noise");
trail_positions = [];

gravity_dir_to_apply = 0;