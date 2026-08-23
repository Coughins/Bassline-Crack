var _dx = x - xprevious;
var _dy = y - yprevious;
var _travel_dir = direction;
if (abs(_dx) + abs(_dy) > 0.01) {
	_travel_dir = point_direction(0, 0, _dx, _dy);
} else if (speed < 0) {
	_travel_dir += 180;
}

var _ux = lengthdir_x(1, _travel_dir);
var _uy = lengthdir_y(1, _travel_dir);
var _px = lengthdir_x(1, _travel_dir + 90);
var _py = lengthdir_y(1, _travel_dir + 90);

var _blood   = variable_global_exists("avoid_col_warning")    ? global.avoid_col_warning    : make_color_rgb(255, 46, 72);
var _danger  = variable_global_exists("avoid_col_danger")     ? global.avoid_col_danger     : make_color_rgb(255, 42, 38);
var _ember   = variable_global_exists("avoid_col_ember")      ? global.avoid_col_ember      : make_color_rgb(255, 84, 28);
var _hot     = variable_global_exists("avoid_col_hot")        ? global.avoid_col_hot        : make_color_rgb(255, 216, 184);
var _cyan    = variable_global_exists("avoid_col_cyan")       ? global.avoid_col_cyan       : make_color_rgb(72, 214, 255);
var _armor   = variable_global_exists("avoid_col_armor_dark") ? global.avoid_col_armor_dark : make_color_rgb(7, 12, 26);
var _edge    = variable_global_exists("avoid_col_armor_edge") ? global.avoid_col_armor_edge : make_color_rgb(112, 198, 226);

var _a = image_alpha;
var _t = current_time * 0.001 + x * 0.013 + y * 0.021;
var _pulse = 0.5 + 0.5 * sin(_t * 21);
var _wake = clamp(abs(speed) / 50, 0.16, 1);
var _trail_len = 24 + _wake * 30 + _pulse * 5;
var _scar_w = 4.8 + _pulse * 1.6;

var _nose_x = x + _ux * 10;
var _nose_y = y + _uy * 10;
var _core_x = x + _ux * 1.5;
var _core_y = y + _uy * 1.5;
var _tail_x = x - _ux * 8.5;
var _tail_y = y - _uy * 8.5;
var _wake_x = x - _ux * _trail_len;
var _wake_y = y - _uy * _trail_len;

gpu_set_blendmode(bm_add);

draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(_wake_x + _px * _scar_w, _wake_y + _py * _scar_w, _blood, 0);
draw_vertex_colour(_wake_x - _px * _scar_w, _wake_y - _py * _scar_w, _blood, 0);
draw_vertex_colour(_tail_x + _px * 4.2, _tail_y + _py * 4.2, _blood, _a * 0.30);
draw_vertex_colour(_tail_x - _px * 2.8, _tail_y - _py * 2.8, _danger, _a * 0.18);
draw_vertex_colour(_core_x + _px * 2.4, _core_y + _py * 2.4, _hot, _a * 0.24);
draw_vertex_colour(_core_x - _px * 1.5, _core_y - _py * 1.5, _danger, _a * 0.16);
draw_primitive_end();

draw_set_color(_blood);
draw_set_alpha(_a * 0.17);
draw_line_width(_wake_x, _wake_y, _nose_x - _ux * 2, _nose_y - _uy * 2, 9.5);
draw_set_alpha(_a * 0.44);
draw_line_width(_tail_x, _tail_y, _nose_x - _ux, _nose_y - _uy, 3.4);
draw_set_color(_cyan);
draw_set_alpha(_a * (0.30 + _pulse * 0.14));
draw_line_width(_tail_x - _px * 1.8, _tail_y - _py * 1.8, _nose_x - _ux * 2 - _px, _nose_y - _uy * 2 - _py, 1.0);
draw_set_color(c_white);
draw_set_alpha(_a * (0.38 + _pulse * 0.20));
draw_line_width(_tail_x + _ux * 2, _tail_y + _uy * 2, _nose_x - _ux * 1.4, _nose_y - _uy * 1.4, 1.0);

for (var _s = -1; _s <= 1; _s += 2) {
	var _spark_t = 0.28 + _pulse * 0.26;
	var _sx = _core_x - _ux * (2 + _pulse * 3) + _px * _s * 2.1;
	var _sy = _core_y - _uy * (2 + _pulse * 3) + _py * _s * 2.1;
	draw_set_color(_s < 0 ? _cyan : _ember);
	draw_set_alpha(_a * 0.22);
	draw_line_width(_sx, _sy, _sx - _ux * (6 + _spark_t * 5) + _px * _s * 2.4,
					_sy - _uy * (6 + _spark_t * 5) + _py * _s * 2.4, 0.85);
}

gpu_set_blendmode(bm_normal);

draw_primitive_begin(pr_trianglefan);
draw_vertex_colour(_nose_x, _nose_y, _hot, _a);
draw_vertex_colour(_core_x + _px * 5.4, _core_y + _py * 5.4, merge_color(_edge, _cyan, 0.25), _a * 0.78);
draw_vertex_colour(_tail_x + _px * 3.2, _tail_y + _py * 3.2, _armor, _a * 0.94);
draw_vertex_colour(_tail_x - _px * 3.4, _tail_y - _py * 3.4, merge_color(_armor, c_black, 0.35), _a * 0.98);
draw_vertex_colour(_core_x - _px * 5.6, _core_y - _py * 5.6, merge_color(_blood, _armor, 0.25), _a * 0.92);
draw_vertex_colour(_nose_x, _nose_y, _hot, _a);
draw_primitive_end();

draw_set_color(c_black);
draw_set_alpha(_a * 0.60);
draw_line_width(_tail_x + _px * 3.2, _tail_y + _py * 3.2, _nose_x, _nose_y, 1.6);
draw_line_width(_tail_x - _px * 3.4, _tail_y - _py * 3.4, _nose_x, _nose_y, 1.4);

gpu_set_blendmode(bm_add);
draw_set_color(_blood);
draw_set_alpha(_a * (0.36 + _pulse * 0.14));
draw_line_width(_tail_x - _px * 0.3, _tail_y - _py * 0.3, _nose_x - _ux * 2, _nose_y - _uy * 2, 1.6);
draw_set_color(_hot);
draw_set_alpha(_a * (0.42 + _pulse * 0.18));
draw_line_width(_core_x, _core_y, _nose_x, _nose_y, 0.8);
draw_set_color(_cyan);
draw_set_alpha(_a * 0.22);
draw_circle(_tail_x, _tail_y, 2.2 + _pulse * 0.8, false);
draw_set_color(c_white);
draw_set_alpha(_a * (0.44 + _pulse * 0.22));
draw_circle(_nose_x, _nose_y, 1.3 + _pulse * 0.3, false);
gpu_set_blendmode(bm_normal);

draw_set_alpha(1);
draw_set_color(c_white);
