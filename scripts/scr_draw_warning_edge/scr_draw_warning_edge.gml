function scr_draw_warning_edge(_edge, _alpha_mult){


var _is_vertical = (_edge == 0 || _edge == 1);
var _length = _is_vertical ? room_height : room_width;
var _segments = 24;

var _origin_x = 0, _origin_y = 0, _tan_x = 0, _tan_y = 0, _perp_x = 0, _perp_y = 0;
switch (_edge)
{
    case 0: _origin_x = 0;          _origin_y = 0; _tan_x = 0; _tan_y = 1; _perp_x =  1; _perp_y = 0; break;
    case 1: _origin_x = room_width; _origin_y = 0; _tan_x = 0; _tan_y = 1; _perp_x = -1; _perp_y = 0; break;
    case 2: _origin_x = 0; _origin_y = 0;           _tan_x = 1; _tan_y = 0; _perp_x = 0; _perp_y =  1; break;
    case 3: _origin_x = 0; _origin_y = room_height; _tan_x = 1; _tan_y = 0; _perp_x = 0; _perp_y = -1; break;
}

gpu_set_blendmode(bm_add);

draw_primitive_begin(pr_trianglestrip);
for (var i = 0; i <= _segments; i++)
{
    var _t = (i / _segments) * _length;
    var _wave_mult = lerp(_k_warning_wave_min_mult, _k_warning_wave_max_mult,
        (sin(_t * _k_warning_wave_freq + warning_wave_phase) + 1) * 0.5);
    var _depth = _k_warning_edge_width * _wave_mult;

    var _edge_x  = _origin_x + _tan_x * _t;
    var _edge_y  = _origin_y + _tan_y * _t;
    var _inner_x = _edge_x + _perp_x * _depth;
    var _inner_y = _edge_y + _perp_y * _depth;

    draw_vertex_color(_edge_x,  _edge_y,  _k_warning_edge_color, _k_warning_base_alpha * _alpha_mult);
    draw_vertex_color(_inner_x, _inner_y, _k_warning_edge_color, 0);
}
draw_primitive_end();

draw_set_color(merge_color(_k_warning_edge_color, c_white, 0.6));
draw_set_alpha(0.9 * _alpha_mult);
switch (_edge)
{
    case 0: draw_rectangle(0, 0, _k_warning_core_width, room_height, false); break;
    case 1: draw_rectangle(room_width - _k_warning_core_width, 0, room_width, room_height, false); break;
    case 2: draw_rectangle(0, 0, room_width, _k_warning_core_width, false); break;
    case 3: draw_rectangle(0, room_height - _k_warning_core_width, room_width, room_height, false); break;
}

var _wf = (1.5 + _alpha_mult * 4) * _k_warning_core_width / 6;
var _wf_x = _perp_x * _wf;
var _wf_y = _perp_y * _wf;
var _wf_len = _is_vertical ? room_height : room_width;
var _wf_a = 0.16 + _alpha_mult * 0.34;

draw_set_alpha(_wf_a);
draw_set_color(c_red);
draw_line_width(_origin_x + _wf_x, _origin_y + _wf_y,
                _origin_x + _tan_x * _wf_len + _wf_x, _origin_y + _tan_y * _wf_len + _wf_y, 3);
draw_set_color(global.avoid_col_cyan);
draw_line_width(_origin_x + _wf_x * 2.4, _origin_y + _wf_y * 2.4,
                _origin_x + _tan_x * _wf_len + _wf_x * 2.4,
                _origin_y + _tan_y * _wf_len + _wf_y * 2.4, 3);

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);
}