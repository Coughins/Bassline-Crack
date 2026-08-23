shader_set(shd_cell);

var t = shader_get_uniform(shd_cell, "u_time");
var r = shader_get_uniform(shd_cell, "u_resolution");
var m = shader_get_uniform(shd_cell, "u_mouse");

shader_set_uniform_f(t, current_time / 1000);

shader_set_uniform_f(r,
    surface_get_width(application_surface),
    surface_get_height(application_surface)
);

shader_set_uniform_f(m,
    device_mouse_x_to_gui(0) / display_get_gui_width(),
    device_mouse_y_to_gui(0) / display_get_gui_height()
);

draw_surface(application_surface,0,0);

shader_reset();