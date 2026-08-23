var _alpha = life / life_max;
var _age = 1 - _alpha;

var _len = streak_length * _alpha * clamp(speed / 6, 0.35, 1.6);
var _tail_x = x - lengthdir_x(_len, direction);
var _tail_y = y - lengthdir_y(_len, direction);

var _cool = clamp(_age * (1.5 - hot * 0.55), 0, 1);
var _col = scr_hot_metal_color(_cool);

gpu_set_blendmode(bm_add);

draw_set_color(_col);
draw_set_alpha(_alpha * 0.14);
draw_line_width(x, y, _tail_x, _tail_y, 12 * hot);
draw_set_alpha(_alpha * 0.4);
draw_line_width(x, y, _tail_x, _tail_y, 5 * hot);
draw_set_alpha(_alpha * 0.85);
draw_line_width(x, y, _tail_x, _tail_y, 2);

draw_set_color(merge_color(_col, c_white, 0.55));
draw_set_alpha(_alpha);
draw_line_width(x, y, _tail_x, _tail_y, 0.9);

draw_set_color(merge_color(_col, c_white, 0.7));
draw_set_alpha(_alpha * 0.9);
draw_circle(x, y, (1.2 + 2.6 * _alpha) * hot, false);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
