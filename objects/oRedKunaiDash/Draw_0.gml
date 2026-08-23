event_inherited();

var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _chroma = (_ctrl != noone) ? _ctrl.kdash_chroma : 0;

var _col_dark  = (_ctrl != noone) ? _ctrl._k_er_col_armor_dark : make_color_rgb(7, 12, 26);
var _col_mid   = (_ctrl != noone) ? _ctrl._k_er_col_armor_mid : make_color_rgb(21, 34, 54);
var _col_edge  = (_ctrl != noone) ? _ctrl._k_er_col_armor_edge : make_color_rgb(112, 198, 226);
var _col_warn  = (_ctrl != noone) ? _ctrl._k_er_col_warning : make_color_rgb(255, 46, 72);
var _col_hot   = (_ctrl != noone) ? _ctrl._k_er_col_hot : make_color_rgb(255, 216, 184);
var _col_white = (_ctrl != noone) ? _ctrl._k_er_col_white : c_white;
var _col_cyan  = (_ctrl != noone) ? _ctrl._k_er_col_cyan : make_color_rgb(72, 214, 255);

var _k_chroma_offset  = 3.0;
var _k_trail_alpha    = (_ctrl != noone) ? _ctrl.kdash_trail_alpha : 0.65;
var _k_hotcore_alpha  = (_ctrl != noone) ? _ctrl.kdash_hotcore_alpha : 0.55;
var _k_telegraph_bloom_alpha = (_ctrl != noone) ? _ctrl.kdash_telegraph_bloom_alpha : 0.35;
var _k_telegraph_band_alpha  = (_ctrl != noone) ? _ctrl.kdash_telegraph_band_alpha : 0.55;
var _k_strike_flash_mult = (_ctrl != noone) ? _ctrl.kdash_strike_flash_mult : 1.0;
var _k_chroma_fringe_mult = (_ctrl != noone) ? _ctrl.kdash_chroma_fringe_mult : 1.0;
var _k_body_hot_blend = (_ctrl != noone) ? _ctrl.kdash_body_hot_blend : 0.55;
var _k_body_alpha_mult = (_ctrl != noone) ? _ctrl.kdash_body_alpha_mult : 1.0;
var _k_shiver_amp     = 1.0;

var _sx = x + sin(coil_seed + current_time * 0.06) * hitch * _k_shiver_amp;
var _sy = y;

var _ux = lengthdir_x(1, image_angle);
var _uy = lengthdir_y(1, image_angle);
var _vx = lengthdir_x(1, image_angle + 90);
var _vy = lengthdir_y(1, image_angle + 90);

var _speed01 = clamp(travel_len / 38, 0, 1);
var _heat = clamp(max(max(hot, telegraph_pulse * 0.85), pop_flash * 0.25), 0, 1.25);
var _body_alpha = clamp(image_alpha * _k_body_alpha_mult, 0, 1);

var _blade_len = max(10, sprite_get_height(sprite_index) * abs(image_yscale) * 1.35 + _speed01 * 6);
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

gpu_set_blendmode(bm_add);

var _tn = array_length(trail_positions);
for (var i = 0; i < _tn; i++) {
    var _p = trail_positions[i];
    var _f = (i + 1) / _tn;
    var _a = _p.life * _f * _f * _k_trail_alpha;
    if (_a <= 0.01) continue;

    var _pux = lengthdir_x(1, _p.ang);
    var _puy = lengthdir_y(1, _p.ang);
    var _pvx = lengthdir_x(1, _p.ang + 90);
    var _pvy = lengthdir_y(1, _p.ang + 90);
    var _plen = lerp(12, 30, clamp(dash_peak / 38, 0, 1)) * _f;
    var _pwid = lerp(1.3, 4.2, _f) * (0.7 + _p.hot * 0.45);
    var _px0 = _p.px - _pux * _plen;
    var _py0 = _p.py - _puy * _plen;
    var _px1 = _p.px + _pux * (_plen * 0.24);
    var _py1 = _p.py + _puy * (_plen * 0.24);

    draw_set_color(_col_warn);
    draw_set_alpha(_a * 0.34);
    draw_line_width(_px0 + _pvx * _pwid, _py0 + _pvy * _pwid,
                    _px1 + _pvx * (_pwid * 0.32), _py1 + _pvy * (_pwid * 0.32), max(1, _pwid * 0.7));
    draw_set_color(_col_cyan);
    draw_set_alpha(_a * 0.20);
    draw_line_width(_px0 - _pvx * _pwid, _py0 - _pvy * _pwid,
                    _px1 - _pvx * (_pwid * 0.32), _py1 - _pvy * (_pwid * 0.32), max(1, _pwid * 0.45));
    draw_set_color(merge_color(_col_hot, _col_white, _p.hot * _f));
    draw_set_alpha(_a * 0.68);
    draw_line_width(_px0, _py0, _px1, _py1, max(1, _pwid * 0.34));
}

if (telegraph_pulse > 0.01) {
    var _tp = telegraph_pulse;
    var _coil_span = _blade_len * (0.75 + _tp * 0.28);
    var _coil_w = _half_w * (2.2 + _tp * 1.4);
    var _back_x = _sx - _ux * _coil_span;
    var _back_y = _sy - _uy * _coil_span;
    var _front_x = _sx + _ux * (_coil_span * 0.36);
    var _front_y = _sy + _uy * (_coil_span * 0.36);

    draw_set_color(_col_warn);
    draw_set_alpha(_tp * _k_telegraph_bloom_alpha * 0.55);
    draw_line_width(_back_x + _vx * _coil_w, _back_y + _vy * _coil_w,
                    _front_x + _vx * (_coil_w * 0.28), _front_y + _vy * (_coil_w * 0.28), 2.4);
    draw_line_width(_back_x - _vx * _coil_w, _back_y - _vy * _coil_w,
                    _front_x - _vx * (_coil_w * 0.28), _front_y - _vy * (_coil_w * 0.28), 2.4);

    var _band_y = _sy + lerp(18, -18, (sin(coil_seed * 3 + current_time * 0.02) + 1) * 0.5);
    draw_set_color(_col_white);
    draw_set_alpha(_tp * _k_telegraph_band_alpha * 0.58);
    draw_line_width(_sx - _vx * (_half_w * 1.55), _band_y - _vy * (_half_w * 1.55),
                    _sx + _vx * (_half_w * 1.55), _band_y + _vy * (_half_w * 1.55), 1.3);
}

if (pop_flash > 0) {
    draw_set_color(_col_white);
    draw_set_alpha(clamp(pop_flash * _k_strike_flash_mult, 0, 1) * 0.45);
    draw_line_width(_handle_x, _handle_y, _tip_x, _tip_y, 4.5 + pop_flash * 5);
}

var _fringe = clamp(_chroma * clamp(travel_len / 22, 0, 1), 0, 1) * _k_chroma_offset * fx_get_mult_for("dashingkunai", "aberration");

if (_fringe > 0.2) {
    draw_set_color(_col_warn);
    draw_set_alpha(_body_alpha * 0.54 * _k_chroma_fringe_mult);
    draw_line_width(_handle_x + _vx * _fringe, _handle_y + _vy * _fringe,
                    _tip_x + _vx * _fringe, _tip_y + _vy * _fringe, 2.0);
    draw_set_color(_col_cyan);
    draw_set_alpha(_body_alpha * 0.36 * _k_chroma_fringe_mult);
    draw_line_width(_handle_x - _vx * _fringe, _handle_y - _vy * _fringe,
                    _tip_x - _vx * _fringe, _tip_y - _vy * _fringe, 1.6);
}

var _read_glow = clamp(0.2 + _heat * 0.45 + telegraph_pulse * 0.5 + (is_dashing ? 0.35 : 0), 0, 1.2);
draw_set_color(_col_warn);
draw_set_alpha(_body_alpha * _read_glow * 0.16);
draw_line_width(_handle_x, _handle_y, _tip_x, _tip_y, max(2.2, _half_w * 1.45));
draw_set_color(_col_cyan);
draw_set_alpha(_body_alpha * _read_glow * 0.09);
draw_line_width(_handle_x - _vx * max(1.2, _half_w * 0.7), _handle_y - _vy * max(1.2, _half_w * 0.7),
                _tip_x - _vx * max(1.2, _half_w * 0.7), _tip_y - _vy * max(1.2, _half_w * 0.7), 1.3);
draw_set_color(merge_color(_col_hot, _col_white, clamp(_heat + telegraph_pulse * 0.4, 0, 1)));
draw_set_alpha(_body_alpha * (0.16 + _read_glow * 0.2));
draw_line_width(_base_x, _base_y, _tip_x, _tip_y, 1.1);

gpu_set_blendmode(bm_normal);

var _body_col = merge_color(merge_color(_col_dark, _col_edge, 0.3 + clamp(_heat, 0, 1) * 0.15), _col_edge, 0.25 + clamp(_heat, 0, 1) * 0.15);
var _edge_col = merge_color(_col_edge, _col_hot, clamp(_heat * _k_body_hot_blend, 0, 1));

draw_set_color(c_black);
draw_set_alpha(_body_alpha * 0.28);
draw_triangle(_tip_x - _ux * 1.5, _tip_y - _uy * 1.5,
              _sh_lx - _ux * 1.5, _sh_ly - _uy * 1.5,
              _sh_rx - _ux * 1.5, _sh_ry - _uy * 1.5, false);

draw_set_color(_body_col);
draw_set_alpha(_body_alpha * 0.96);
draw_triangle(_tip_x, _tip_y, _sh_lx, _sh_ly, _sh_rx, _sh_ry, false);
draw_triangle(_sh_lx, _sh_ly, _ba_lx, _ba_ly, _ba_rx, _ba_ry, false);
draw_triangle(_sh_lx, _sh_ly, _ba_rx, _ba_ry, _sh_rx, _sh_ry, false);

draw_set_color(merge_color(_body_col, c_black, 0.35));
draw_set_alpha(_body_alpha * 0.78);
draw_line_width(_ba_lx, _ba_ly, _ba_rx, _ba_ry, max(1.2, _half_w * 0.55));

draw_set_color(_edge_col);
draw_set_alpha(_body_alpha * (0.42 + clamp(_heat, 0, 1) * 0.18));
draw_line_width(_tip_x, _tip_y, _sh_lx, _sh_ly, 1.1);
draw_line_width(_tip_x, _tip_y, _sh_rx, _sh_ry, 1.1);

draw_set_color(merge_color(_col_mid, _col_edge, 0.42));
draw_set_alpha(_body_alpha * 0.85);
draw_line_width(_handle_x, _handle_y, _base_x, _base_y, max(1.6, _half_w * 0.72));
draw_line_width(_base_x - _vx * (_half_w * 1.25), _base_y - _vy * (_half_w * 1.25),
                _base_x + _vx * (_half_w * 1.25), _base_y + _vy * (_half_w * 1.25), max(1.2, _half_w * 0.38));

gpu_set_blendmode(bm_add);

var _seam_col = merge_color(_col_warn, _col_hot, clamp(_heat, 0, 1) * 0.55);
draw_set_color(_seam_col);
draw_set_alpha(_body_alpha * (0.24 + _heat * 0.42));
draw_line_width(_base_x, _base_y, _tip_x - _ux * 2, _tip_y - _uy * 2, 1 + _heat * 0.65);

draw_set_color(_col_white);
draw_set_alpha(_body_alpha * _heat * _k_hotcore_alpha);
draw_line_width(_tip_x - _ux * 4, _tip_y - _uy * 4, _tip_x, _tip_y, 1.2 + _heat * 0.7);

var _node_x = lerp(_base_x, _tip_x, 0.34);
var _node_y = lerp(_base_y, _tip_y, 0.34);
draw_set_color(_col_cyan);
draw_set_alpha(_body_alpha * (0.12 + _heat * 0.16));
draw_line_width(_node_x - _vx * (_half_w * 0.62), _node_y - _vy * (_half_w * 0.62),
                _node_x + _vx * (_half_w * 0.62), _node_y + _vy * (_half_w * 0.62), 1);

if (is_dashing) {
    draw_set_color(_col_white);
    draw_set_alpha(_k_hotcore_alpha * 0.42);
    draw_line_width(_handle_x, _handle_y, _tip_x, _tip_y, 1.4);
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
