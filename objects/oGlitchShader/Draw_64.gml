shader_set(sh_channel_shift);

var u;

u = shader_get_uniform(sh_channel_shift, "u_amount");
shader_set_uniform_f(u, glitch_amount);

u = shader_get_uniform(sh_channel_shift, "u_time");
shader_set_uniform_f(u, shader_time);

draw_surface(application_surface, screen_offset, 0);

shader_reset();