var _t = 1 - (life / life_max);
var _radius = lerp(4, 50, _t);
var _alpha = life / life_max;

gpu_set_blendmode(bm_add);
draw_set_color(c_white);
draw_set_alpha(_alpha);
draw_circle(x, y, _radius, false);
draw_set_alpha(_alpha * 0.5);
draw_circle(x, y, _radius * 1.8, false);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);