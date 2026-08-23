event_inherited();

scr_register_glow_point(x, y);


var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _light_col = (circle_id == 1)
    ? ((_ctrl != noone) ? _ctrl._k_er_col_cyan : global.avoid_col_cyan)
    : ((_ctrl != noone) ? _ctrl._k_er_col_warning : global.avoid_col_danger);
scr_add_light(x, y, _light_col, 0.8);
