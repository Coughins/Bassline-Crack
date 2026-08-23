
shader_set(shader_id);



shader_set_uniform_f(u_time, matrix_time);
shader_set_uniform_f(u_rain_time, matrix_rain_time);

shader_set_uniform_f(u_speed, matrix_speed);



shader_set_uniform_f(u_resolution, _view_w, _view_h);

shader_set_uniform_f(u_brightness, matrix_brightness * alpha);



var _r = colour_get_red(global.lightning_color) / 255.0;
var _g = colour_get_green(global.lightning_color) / 255.0;
var _b = colour_get_blue(global.lightning_color) / 255.0;

shader_set_uniform_f(u_color, _r, _g, _b);

shader_set_uniform_f(
    u_color_deep,
    colour_get_red(_k_deep_color) / 255.0,
    colour_get_green(_k_deep_color) / 255.0,
    colour_get_blue(_k_deep_color) / 255.0);

shader_set_uniform_f(
    u_color_hot,
    lerp(_r, 1, _k_hot_white),
    lerp(_g, 1, _k_hot_white),
    lerp(_b, 1, _k_hot_white));



shader_set_uniform_f(u_beat, matrix_beat);
shader_set_uniform_f(u_impact, matrix_impact);
shader_set_uniform_f(u_charge, matrix_charge);
shader_set_uniform_f(u_glitch, matrix_glitch);
shader_set_uniform_f(u_roll, matrix_roll);



var _sr = [-1000, -1000, -1000];
var _sp = [0, 0, 0];

var _shock_amount = min(array_length(matrix_shocks), _k_shock_max);

for (var i = 0; i < _shock_amount; i++) {
  _sr[i] = matrix_shocks[i].r;
  _sp[i] = matrix_shocks[i].p;
}

shader_set_uniform_f(u_shock_r, _sr[0], _sr[1], _sr[2]);
shader_set_uniform_f(u_shock_p, _sp[0], _sp[1], _sp[2]);



draw_surface_stretched(
    application_surface,
    _view_x,
    _view_y,
    _view_w,
    _view_h
);


shader_reset();
