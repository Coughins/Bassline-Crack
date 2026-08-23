event_inherited();

var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _col_dark  = (_ctrl != noone) ? _ctrl._k_er_col_armor_dark : make_color_rgb(7, 12, 26);
var _col_mid   = (_ctrl != noone) ? _ctrl._k_er_col_armor_mid : make_color_rgb(21, 34, 54);
var _col_edge  = (_ctrl != noone) ? _ctrl._k_er_col_armor_edge : make_color_rgb(112, 198, 226);
var _col_warn  = (_ctrl != noone) ? _ctrl._k_er_col_warning : make_color_rgb(255, 46, 72);
var _col_hot   = (_ctrl != noone) ? _ctrl._k_er_col_hot : make_color_rgb(255, 216, 184);
var _col_white = (_ctrl != noone) ? _ctrl._k_er_col_white : c_white;
var _col_cyan  = (_ctrl != noone) ? _ctrl._k_er_col_cyan : make_color_rgb(72, 214, 255);

var _motion_speed = is_thrown ? sqrt(hsp * hsp + vsp * vsp) : max(speed, dash_speed);
var _speed_t = clamp((_motion_speed - trail_speed_threshold) / 16, 0, 1);
var _spawn_t = (spawn_duration > 0) ? clamp(spawn_timer / spawn_duration, 0, 1) : 1;
var _spawn_flash = sqr(1 - _spawn_t);
var _return_t = (is_feeder && state == "returning") ? clamp(return_timer / max(return_duration, 1), 0, 1) : 0;
var _feed_heat = (is_feeder && state == "returning") ? lerp(0.25, 0.85, _return_t) : 0;
var _heat = clamp(max(_speed_t, _feed_heat, _spawn_flash * 0.65), 0, 1);
var _fx_chroma = fx_get_mult_for("kunairain", "aberration");
var _fringe = clamp((_speed_t * 0.72 + _feed_heat * 0.45) * _fx_chroma, 0, 1) * 2.1;
var _shiver = sin(draw_heat_seed + current_time * 0.035) * _heat * 0.55;

var _sx = x + _shiver;
var _sy = y;
var _ux = lengthdir_x(1, image_angle);
var _uy = lengthdir_y(1, image_angle);
var _vx = lengthdir_x(1, image_angle + 90);
var _vy = lengthdir_y(1, image_angle + 90);

var _blade_len = max(10, sprite_get_height(sprite_index) * abs(image_yscale) * 1.35 + _speed_t * 6);
var _tail_len = max(4, sprite_get_width(sprite_index) * abs(image_xscale) * 0.28);
var _half_w = max(1.9, sprite_get_width(sprite_index) * abs(image_xscale) * 0.16);

var _tip_x = _sx + _ux * (_blade_len * 0.64);
var _tip_y = _sy + _uy * (_blade_len * 0.64);
var _shoulder_x = _sx - _ux * (_blade_len * 0.08);
var _shoulder_y = _sy - _uy * (_blade_len * 0.08);
var _base_x = _sx - _ux * (_blade_len * 0.36);
var _base_y = _sy - _uy * (_blade_len * 0.36);
var _handle_x = _base_x - _ux * _tail_len;
var _handle_y = _base_y - _uy * _tail_len;

var _sh_lx = _shoulder_x + _vx * _half_w;
var _sh_ly = _shoulder_y + _vy * _half_w;
var _sh_rx = _shoulder_x - _vx * _half_w;
var _sh_ry = _shoulder_y - _vy * _half_w;
var _ba_lx = _base_x + _vx * (_half_w * 0.45);
var _ba_ly = _base_y + _vy * (_half_w * 0.45);
var _ba_rx = _base_x - _vx * (_half_w * 0.45);
var _ba_ry = _base_y - _vy * (_half_w * 0.45);

var _body_alpha = clamp(image_alpha, 0, 1);
var _body_col = merge_color(merge_color(_col_dark, _col_edge, 0.3 + _heat * 0.15), _col_edge, 0.25 + _heat * 0.15);
var _edge_col = merge_color(_col_edge, _col_hot, _heat * 0.45);

gpu_set_blendmode(bm_add);

for (var i = array_length(trail_history) - 1; i >= 0; i--) {
    var _h = trail_history[i];
    var _fade = 1 - (i / trail_length);
    var _hot = variable_struct_exists(_h, "hot") ? _h.hot : _fade;
    var _ta = _body_alpha * _fade * _fade * lerp(0.22, 0.58, _hot);
    if (_ta <= 0.01) continue;

    var _tux = lengthdir_x(1, _h.ang);
    var _tuy = lengthdir_y(1, _h.ang);
    var _tvx = lengthdir_x(1, _h.ang + 90);
    var _tvy = lengthdir_y(1, _h.ang + 90);
    var _tlen = lerp(9, 24, _hot) * (0.72 + _speed_t * 0.35) * _fade;
    var _twid = lerp(1.1, 3.4, _fade) * (0.85 + _hot * 0.45);
    var _tx0 = _h.x - _tux * _tlen;
    var _ty0 = _h.y - _tuy * _tlen;
    var _tx1 = _h.x + _tux * (_tlen * 0.18);
    var _ty1 = _h.y + _tuy * (_tlen * 0.18);

    draw_set_color(_col_warn);
    draw_set_alpha(_ta * 0.34);
    draw_line_width(_tx0 + _tvx * _twid, _ty0 + _tvy * _twid,
                    _tx1 + _tvx * (_twid * 0.24), _ty1 + _tvy * (_twid * 0.24),
                    max(1, _twid * 0.55));

    draw_set_color(merge_color(_col_warn, _col_hot, _hot * 0.5));
    draw_set_alpha(_ta * 0.74);
    draw_line_width(_tx0, _ty0, _tx1, _ty1, max(1, _twid * 0.35));

    if (_hot > 0.45 && _fade > 0.45) {
        draw_set_color(_col_cyan);
        draw_set_alpha(_ta * 0.13);
        draw_line_width(_tx0 - _tvx * (_twid * 0.8), _ty0 - _tvy * (_twid * 0.8),
                        _tx1 - _tvx * (_twid * 0.22), _ty1 - _tvy * (_twid * 0.22),
                        max(1, _twid * 0.32));
    }
}

if (_spawn_flash > 0.02 || _feed_heat > 0.02) {
    var _pulse = max(_spawn_flash, _feed_heat * (0.5 + 0.5 * sin(current_time * 0.08 + draw_heat_seed)));
    draw_set_color(_col_white);
    draw_set_alpha(_body_alpha * _pulse * 0.48);
    draw_line_width(_handle_x, _handle_y, _tip_x, _tip_y, 3.8 + _pulse * 4.5);
}

if (_fringe > 0.18) {
    draw_set_color(_col_warn);
    draw_set_alpha(_body_alpha * 0.42);
    draw_line_width(_handle_x + _vx * _fringe, _handle_y + _vy * _fringe,
                    _tip_x + _vx * _fringe, _tip_y + _vy * _fringe, 1.6);
    draw_set_color(_col_cyan);
    draw_set_alpha(_body_alpha * 0.25);
    draw_line_width(_handle_x - _vx * _fringe, _handle_y - _vy * _fringe,
                    _tip_x - _vx * _fringe, _tip_y - _vy * _fringe, 1.2);
}

gpu_set_blendmode(bm_normal);

draw_set_color(c_black);
draw_set_alpha(_body_alpha * 0.26);
draw_triangle(_tip_x - _ux * 1.2, _tip_y - _uy * 1.2,
              _sh_lx - _ux * 1.2, _sh_ly - _uy * 1.2,
              _sh_rx - _ux * 1.2, _sh_ry - _uy * 1.2, false);

draw_set_color(_body_col);
draw_set_alpha(_body_alpha * 0.96);
draw_triangle(_tip_x, _tip_y, _sh_lx, _sh_ly, _sh_rx, _sh_ry, false);
draw_triangle(_sh_lx, _sh_ly, _ba_lx, _ba_ly, _ba_rx, _ba_ry, false);
draw_triangle(_sh_lx, _sh_ly, _ba_rx, _ba_ry, _sh_rx, _sh_ry, false);

draw_set_color(merge_color(_body_col, c_black, 0.35));
draw_set_alpha(_body_alpha * 0.76);
draw_line_width(_ba_lx, _ba_ly, _ba_rx, _ba_ry, max(1.1, _half_w * 0.55));

draw_set_color(_edge_col);
draw_set_alpha(_body_alpha * (0.42 + _heat * 0.18));
draw_line_width(_tip_x, _tip_y, _sh_lx, _sh_ly, 1);
draw_line_width(_tip_x, _tip_y, _sh_rx, _sh_ry, 1);

draw_set_color(merge_color(_col_mid, _col_edge, 0.36));
draw_set_alpha(_body_alpha * 0.82);
draw_line_width(_handle_x, _handle_y, _base_x, _base_y, max(1.4, _half_w * 0.62));
draw_line_width(_base_x - _vx * (_half_w * 1.15), _base_y - _vy * (_half_w * 1.15),
                _base_x + _vx * (_half_w * 1.15), _base_y + _vy * (_half_w * 1.15),
                max(1, _half_w * 0.36));

gpu_set_blendmode(bm_add);

var _seam_col = merge_color(_col_warn, _col_hot, _heat * 0.55);
draw_set_color(_seam_col);
draw_set_alpha(_body_alpha * (0.28 + _heat * 0.4));
draw_line_width(_base_x, _base_y, _tip_x - _ux * 2, _tip_y - _uy * 2, 1 + _heat * 0.55);

draw_set_color(_col_white);
draw_set_alpha(_body_alpha * _heat * 0.5);
draw_line_width(_tip_x - _ux * 3, _tip_y - _uy * 3, _tip_x, _tip_y, 1.1 + _heat * 0.6);

if (_heat > 0.25) {
    var _node_x = lerp(_base_x, _tip_x, 0.34);
    var _node_y = lerp(_base_y, _tip_y, 0.34);
    draw_set_color(_col_cyan);
    draw_set_alpha(_body_alpha * _heat * 0.12);
    draw_line_width(_node_x - _vx * (_half_w * 0.55), _node_y - _vy * (_half_w * 0.55),
                    _node_x + _vx * (_half_w * 0.55), _node_y + _vy * (_half_w * 0.55), 1);
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
