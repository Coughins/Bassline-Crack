application_surface_draw_enable(false);

var _gui_scale = 1;
if (variable_global_exists("settings")) {
    _gui_scale = max(1, global.settings[$"scale"]);
}

var _gw = GAME_WIDTH * _gui_scale;
var _gh = GAME_HEIGHT * _gui_scale;
display_set_gui_size(_gw, _gh);

hub_scene_surface = surface_ensure(hub_scene_surface, GAME_WIDTH, GAME_HEIGHT);
hub_glow_surface = surface_ensure(hub_glow_surface, GAME_WIDTH, GAME_HEIGHT);

var _time = hub_time;
var _sec = _time / max(room_speed, 1);
var _end_reveal_raw = hub_end_mode ? hub_end_reveal : 0;
var _end_reveal = _end_reveal_raw * _end_reveal_raw * (3 - 2 * _end_reveal_raw);
var _end_glow = hub_end_mode ? clamp(0.34 + _end_reveal * 0.58 + hub_minor_pulse * 0.18 + hub_major_pulse * 0.34, 0, 1.35) : 0;
var _floor_y = hub_floor_y + sin(_sec * 1.7) * 1.2 + hub_major_pulse * 2.5;
var _gate_wake = clamp(hub_gate_charge + hub_gate_pulse * 0.75 + hub_warp_flash + _end_glow * 0.24, 0, 1.6);
var _bass_idle = power(max(0, sin(_time * 0.073)), 12);
var _hum = clamp(0.2 + _bass_idle * 0.4 + hub_minor_pulse * 0.35 + hub_major_pulse * 0.55 + _gate_wake * 0.5, 0, 1.8);
var _title_jitter = (hub_major_pulse + hub_warp_flash) * sin(_time * 1.9) * 2;

surface_set_target(hub_scene_surface);
draw_clear(hub_col_void);

draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(0, 0, hub_col_void, 1);
draw_vertex_colour(GAME_WIDTH, 0, merge_color(hub_col_void, hub_col_deep, 0.32), 1);
draw_vertex_colour(0, GAME_HEIGHT, merge_color(hub_col_back, c_black, 0.32), 1);
draw_vertex_colour(GAME_WIDTH, GAME_HEIGHT, merge_color(hub_col_deep, c_black, 0.18), 1);
draw_primitive_end();

draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(0, 250, hub_col_blood, 0);
draw_vertex_colour(GAME_WIDTH, 250, hub_col_blood, 0);
draw_vertex_colour(0, GAME_HEIGHT, hub_col_blood, 0.28 + hub_major_pulse * 0.12);
draw_vertex_colour(GAME_WIDTH, GAME_HEIGHT, hub_col_blood, 0.16 + hub_major_pulse * 0.08);
draw_primitive_end();

for (var i = 0; i < array_length(hub_stars); i++) {
    var _st = hub_stars[i];
    var _tw = _time * (0.008 + _st.z * 0.015);
    var _sx = _st.x + sin(_st.seed + _tw) * (3 + _st.z * 8);
    var _sy = _st.y + cos(_st.seed * 0.7 + _tw * 0.8) * (1 + _st.z * 3);
    var _sa = (0.08 + _st.z * 0.28) * (0.45 + 0.55 * sin(_st.seed + _time * 0.026));

    draw_set_color(_st.color);
    draw_set_alpha(clamp(_sa, 0.02, 0.38));
    draw_rectangle(_sx, _sy, _sx + max(1, _st.z * 2), _sy + 1, false);
}
draw_set_alpha(1);

for (var i = 0; i < array_length(hub_towers); i++) {
    var _tw2 = hub_towers[i];
    var _base = _floor_y - 52 + sin(_tw2.seed + _sec) * 4;
    var _top = _base - _tw2.h;
    var _x0 = _tw2.x;
    var _x1 = _tw2.x + _tw2.w;
    var _lean = _tw2.lean;
    var _a = clamp(0.45 + (_tw2.h / 300) * 0.28, 0, 0.78);
    var _lit = 0.5 + 0.5 * sin(_tw2.seed + _time * 0.026);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x0 + _lean, _top, merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.12), _a);
    draw_vertex_colour(_x1 + _lean, _top + 6, hub_col_panel_dark, _a);
    draw_vertex_colour(_x0, _base, merge_color(c_black, hub_col_panel_dark, 0.22), _a);
    draw_vertex_colour(_x1, _base, merge_color(c_black, hub_col_panel_mid, 0.15), _a);
    draw_primitive_end();

    draw_set_color(merge_color(hub_col_panel_hi, c_white, 0.05));
    draw_set_alpha(_a * 0.22);
    draw_line_width(_x0 + _lean + 3, _top + 8, _x0 + 5, _base - 8, 1.2);
    draw_set_color((_tw2.seed mod 2 < 1) ? hub_col_cyan : hub_col_warning);
    draw_set_alpha(_a * (0.08 + _lit * 0.08 + _hum * 0.04));
    draw_line_width((_x0 + _x1) * 0.5 + _lean * 0.4, _top + 18,
                    (_x0 + _x1) * 0.5, _base - 12, 1.5);
}
draw_set_alpha(1);

var _ring_cx = hub_gate_x;
var _ring_cy = hub_gate_y + 6;
var _ring_spin = _time * 0.42;

gpu_set_blendmode(bm_add);
draw_set_color(hub_col_cyan);
draw_set_alpha(0.055 + _hum * 0.028);
scr_draw_smooth_ring_mask(_ring_cx, _ring_cy, 205 + sin(_sec * 1.2) * 4, 1, 5, hub_col_cyan);
draw_set_color(hub_col_warning);
draw_set_alpha(0.04 + hub_major_pulse * 0.06);
scr_draw_smooth_ring_mask(_ring_cx, _ring_cy, 164 + cos(_sec * 1.6) * 5, 1, 3.5, hub_col_warning);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

for (var _arc = 0; _arc < 18; _arc++) {
    var _af = _arc / 18;
    var _ang1 = _ring_spin + _arc * 20;
    var _ang2 = _ang1 + 8 + sin(_sec + _arc) * 8;
    var _rr = 168 + ((_arc mod 3) * 22);
    var _x1 = _ring_cx + lengthdir_x(_rr, _ang1);
    var _y1 = _ring_cy + lengthdir_y(_rr * 0.72, _ang1);
    var _x2 = _ring_cx + lengthdir_x(_rr, _ang2);
    var _y2 = _ring_cy + lengthdir_y(_rr * 0.72, _ang2);
    draw_set_color((_arc mod 4 == 0) ? hub_col_warning : hub_col_edge);
    draw_set_alpha(0.14 + _hum * 0.06 + ((_arc mod 5 == floor(_time / 20) mod 5) ? 0.12 : 0));
    draw_line_width(_x1, _y1, _x2, _y2, (_arc mod 3 == 0) ? 2 : 1);
}
draw_set_alpha(1);

for (var _br = 0; _br < 8; _br++) {
    var _f = _br / 7;
    var _sx3 = lerp(52, GAME_WIDTH - 52, _f);
    var _sy3 = 76 + sin(_br * 1.4) * 16;
    var _tx3 = hub_gate_x + lerp(-hub_gate_rx, hub_gate_rx, frac(_f * 2.7 + 0.13));
    var _ty3 = hub_gate_y - 100 + sin(_br * 2.1 + _sec) * 12;
    var _bc = (_br mod 3 == 0) ? hub_col_warning : hub_col_edge;
    draw_set_color(merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.18));
    draw_set_alpha(0.42);
    draw_line_width(_sx3, _sy3, _tx3, _ty3, 5);
    draw_set_color(_bc);
    draw_set_alpha(0.08 + _hum * 0.06);
    draw_line_width(_sx3, _sy3, _tx3, _ty3, 1.3);
}
draw_set_alpha(1);

draw_set_font(fDefault);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
if (!hub_end_mode) {
    draw_set_color(merge_color(hub_col_edge, c_white, 0.2 + hub_major_pulse * 0.25));
    draw_set_alpha(0.24);
    draw_text_transformed(304 - _title_jitter, 59, "BASSLINE", 0.92, 0.92, 0);
    draw_set_color(hub_col_warning);
    draw_set_alpha(0.20 + hub_major_pulse * 0.16);
    draw_text_transformed(306 + _title_jitter, 88, "CRACK", 1.14, 1.14, 0);
    draw_set_color(hub_col_white);
    draw_set_alpha(0.82);
    draw_text_transformed(304, 58, "BASSLINE", 0.88, 0.88, 0);
    draw_text_transformed(304, 87, "CRACK", 1.08, 1.08, 0);
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

if (hub_end_mode) {
    var _panel_a = _end_reveal;
    var _panel_x1 = 78;
    var _panel_y1 = 56;
    var _panel_x2 = GAME_WIDTH - 78;
    var _panel_y2 = 224;
    var _panel_mid = (_panel_x1 + _panel_x2) * 0.5;

    draw_set_color(c_black);
    draw_set_alpha(0.30 * _panel_a);
    draw_rectangle(_panel_x1 + 14, _panel_y1 + 18, _panel_x2 + 10, _panel_y2 + 22, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_panel_x1, _panel_y1, merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.28), 0.76 * _panel_a);
    draw_vertex_colour(_panel_x2, _panel_y1, merge_color(hub_col_panel_mid, hub_col_edge, 0.14), 0.66 * _panel_a);
    draw_vertex_colour(_panel_x1, _panel_y2, merge_color(c_black, hub_col_panel_dark, 0.38), 0.82 * _panel_a);
    draw_vertex_colour(_panel_x2, _panel_y2, merge_color(c_black, hub_col_panel_mid, 0.24), 0.70 * _panel_a);
    draw_primitive_end();

    draw_menu_title_corner_frame(_panel_x1, _panel_y1, _panel_x2, _panel_y2, 14, hub_col_edge, (0.48 + hub_major_pulse * 0.16) * _panel_a, _sec);
    draw_menu_title_corner_frame(_panel_x1 + 24, _panel_y1 + 62, _panel_x2 - 24, _panel_y2 - 30, 8, hub_col_warning, (0.20 + hub_minor_pulse * 0.08) * _panel_a, _sec + 3);

    gpu_set_blendmode(bm_add);
    draw_set_color(hub_col_cyan);
    draw_set_alpha((0.08 + _end_glow * 0.06) * _panel_a);
    draw_line_width(_panel_x1 + 34, _panel_y1 + 42, _panel_x2 - 34, _panel_y1 + 42, 2);
    draw_set_color(hub_col_warning);
    draw_set_alpha((0.06 + hub_major_pulse * 0.08) * _panel_a);
    draw_line_width(_panel_x1 + 86, _panel_y2 - 28, _panel_x2 - 86, _panel_y2 - 28, 1.5);
    gpu_set_blendmode(bm_normal);

    draw_set_font(fDefault);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(hub_col_white);
    draw_set_alpha((0.78 + hub_major_pulse * 0.12) * _panel_a);
    draw_menu_title_clean_center_fit(_panel_mid, _panel_y1 + 20, "THANK YOU FOR PLAYING", 0.98, 0.98, _panel_x2 - _panel_x1 - 74, 0.48);

    draw_set_color(merge_color(hub_col_edge, c_white, 0.22));
    draw_set_alpha(0.70 * _panel_a);
    draw_menu_title_spaced_center_fit(_panel_mid, _panel_y1 + 82, "CLEAR TIME", 5, 0.52, 0.52, 260, 1, 0.42);

    draw_set_color(merge_color(hub_col_white, hub_col_cyan, 0.18 + hub_major_pulse * 0.18));
    draw_set_alpha((0.92 + hub_minor_pulse * 0.08) * _panel_a);
    draw_menu_title_clean_center_fit(_panel_mid, _panel_y1 + 108, hub_end_clear_time_text, 1.32, 1.32, 360, 0.55);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

var _deck_top = _floor_y - 38;
var _deck_lip = _floor_y - 4;
var _deck_bot = GAME_HEIGHT + 50;

draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(-60, _deck_top, merge_color(hub_col_panel_hi, c_white, 0.06 + _hum * 0.04), 1);
draw_vertex_colour(GAME_WIDTH + 60, _deck_top, merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.28), 1);
draw_vertex_colour(-80, _deck_bot, merge_color(c_black, hub_col_panel_dark, 0.25), 1);
draw_vertex_colour(GAME_WIDTH + 80, _deck_bot, merge_color(c_black, hub_col_panel_dark, 0.46), 1);
draw_primitive_end();

draw_set_color(merge_color(c_black, hub_col_panel_dark, 0.32));
draw_set_alpha(0.86);
draw_rectangle(0, _deck_lip, GAME_WIDTH, GAME_HEIGHT, false);
draw_set_alpha(1);

for (var _row = 0; _row < 6; _row++) {
    var _y1 = _deck_top + _row * 23;
    var _y2 = _y1 + 19;
    var _shade = _row / 6;
    draw_set_color(merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.07 + _shade * 0.08));
    draw_set_alpha(0.58 - _row * 0.035);
    draw_rectangle(8, _y1, GAME_WIDTH - 8, _y2, false);

    draw_set_color(merge_color(hub_col_edge, c_white, 0.06 + _hum * 0.08));
    draw_set_alpha(0.07 + _hum * 0.04);
    draw_line_width(12, _y1 + 1, GAME_WIDTH - 12, _y1 + 1, 1);
}

for (var i = 0; i < array_length(hub_deck_panels); i++) {
    var _p = hub_deck_panels[i];
    var _px = _p.x;
    var _py = _deck_lip + (_p.step mod 3) * 21;
    var _pw = _p.w;
    var _ph = _p.h;
    var _heat = (_p.light ? 0.25 : 0.06) + _hum * 0.12 + hub_gate_charge * 0.08;
    var _pc = merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.55 + _heat);

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_px + _pw * 0.5, _py + _ph * 0.5, _pc, 0.95);
    draw_vertex_colour(_px + 5, _py, merge_color(_pc, c_white, 0.06), 0.92);
    draw_vertex_colour(_px + _pw - 3, _py + 2, merge_color(_pc, hub_col_panel_hi, 0.12), 0.92);
    draw_vertex_colour(_px + _pw - 8, _py + _ph, merge_color(_pc, c_black, 0.22), 0.95);
    draw_vertex_colour(_px, _py + _ph - 4, merge_color(_pc, c_black, 0.14), 0.95);
    draw_vertex_colour(_px + 5, _py, merge_color(_pc, c_white, 0.06), 0.92);
    draw_primitive_end();

    draw_set_color(merge_color(hub_col_edge, hub_col_panel_hi, 0.35));
    draw_set_alpha(0.12 + _heat * 0.15);
    draw_line_width(_px + 8, _py + 4, _px + _pw - 9, _py + 3, 1);
    if (_p.light) {
        draw_set_color((_p.step mod 2 == 0) ? hub_col_warning : hub_col_cyan);
        draw_set_alpha(0.16 + _hum * 0.14);
        draw_rectangle(_px + 12, _py + 10, _px + _pw - 14, _py + 13, false);
    }
}
draw_set_alpha(1);

for (var _side = -1; _side <= 1; _side += 2) {
    var _near_x = hub_gate_x + _side * 70;
    var _far_x = (_side < 0) ? -20 : GAME_WIDTH + 20;
    var _far_y = _floor_y + 56;
    draw_set_color(merge_color(c_black, hub_col_panel_dark, 0.2));
    draw_set_alpha(0.82);
    draw_line_width(_far_x, _far_y, _near_x, _floor_y - 18, 16);
    draw_set_color(merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.18));
    draw_set_alpha(0.88);
    draw_line_width(_far_x, _far_y - 3, _near_x, _floor_y - 21, 6);
    draw_set_color((_side < 0) ? hub_col_cyan : hub_col_warning);
    draw_set_alpha(0.13 + _hum * 0.12);
    draw_line_width(_far_x, _far_y - 9, _near_x, _floor_y - 26, 2);
}
draw_set_alpha(1);

var _slot_a = 0.75 + hub_gate_charge * 0.25;
draw_primitive_begin(pr_trianglestrip);
draw_vertex_colour(hub_gate_x - 82, _floor_y - 9, c_black, _slot_a);
draw_vertex_colour(hub_gate_x + 82, _floor_y - 9, c_black, _slot_a);
draw_vertex_colour(hub_gate_x - 56, _floor_y + 27, c_black, 0.35 + hub_gate_charge * 0.3);
draw_vertex_colour(hub_gate_x + 56, _floor_y + 27, c_black, 0.35 + hub_gate_charge * 0.3);
draw_primitive_end();

draw_set_color(merge_color(hub_col_edge, c_white, 0.35 + hub_gate_charge * 0.4));
draw_set_alpha(0.32 + hub_gate_charge * 0.34);
draw_line_width(hub_gate_x - 72, _floor_y - 10, hub_gate_x + 72, _floor_y - 10, 2.6);
draw_set_color(hub_col_warning);
draw_set_alpha(0.16 + hub_gate_charge * 0.2);
draw_line_width(hub_gate_x - 58, _floor_y - 14, hub_gate_x + 58, _floor_y - 14, 1.2);
draw_set_alpha(1);

var _core_rx = hub_gate_rx * (0.72 + hub_gate_charge * 0.08 + hub_warp_flash * 0.18);
var _core_ry = hub_gate_ry * (0.82 + hub_gate_charge * 0.05 + hub_warp_flash * 0.16);
draw_set_color(c_black);
draw_set_alpha(0.92);
draw_ellipse(hub_gate_x - _core_rx, hub_gate_y - _core_ry,
             hub_gate_x + _core_rx, hub_gate_y + _core_ry, false);

draw_ellipse_color(hub_gate_x - _core_rx * 0.78, hub_gate_y - _core_ry * 0.68,
                   hub_gate_x + _core_rx * 0.78, hub_gate_y + _core_ry * 0.68,
                   merge_color(c_black, hub_col_deep, 0.28), c_black, false);

for (var _side2 = -1; _side2 <= 1; _side2 += 2) {
    var _gx = hub_gate_x + _side2 * (hub_gate_rx + 22);
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_gx - _side2 * 15, hub_gate_y - hub_gate_ry - 34, merge_color(hub_col_panel_hi, c_white, 0.08), 1);
    draw_vertex_colour(_gx + _side2 * 16, hub_gate_y - hub_gate_ry - 18, hub_col_panel_dark, 1);
    draw_vertex_colour(_gx - _side2 * 20, _floor_y + 8, hub_col_panel_mid, 1);
    draw_vertex_colour(_gx + _side2 * 20, _floor_y + 18, c_black, 1);
    draw_primitive_end();

    draw_set_color(merge_color(hub_col_edge, c_white, 0.16));
    draw_set_alpha(0.32 + hub_gate_charge * 0.18);
    draw_line_width(_gx - _side2 * 13, hub_gate_y - hub_gate_ry - 20,
                    _gx - _side2 * 18, _floor_y + 4, 2);
}

draw_set_color(hub_col_panel_dark);
draw_set_alpha(1);
draw_rectangle(hub_gate_x - hub_gate_rx - 8, hub_gate_y - hub_gate_ry - 42,
               hub_gate_x + hub_gate_rx + 8, hub_gate_y - hub_gate_ry - 22, false);
draw_set_color(merge_color(hub_col_edge, c_white, 0.14));
draw_set_alpha(0.5);
draw_line_width(hub_gate_x - hub_gate_rx - 6, hub_gate_y - hub_gate_ry - 43,
                hub_gate_x + hub_gate_rx + 6, hub_gate_y - hub_gate_ry - 43, 2);
draw_set_alpha(1);

for (var _orb = 0; _orb < 10; _orb++) {
    var _ang = global.hub_orbit_angle + _orb * 36;
    var _ox = hub_gate_x + lengthdir_x(74 + sin(_time * 0.04 + _orb) * 5, _ang);
    var _oy = hub_gate_y + lengthdir_y(46 + cos(_time * 0.035 + _orb) * 4, _ang) * 0.92;
    var _front = sin(degtorad(_ang)) > -0.2;
    var _os = _front ? 0.52 : 0.34;
    var _oc = (_orb mod 3 == 0) ? hub_col_warning : hub_col_cyan;
    draw_sprite_ext(sRedOrb, 0, _ox, _oy, _os, _os, 0, merge_color(_oc, c_white, 0.18), 0.56 + _front * 0.24);
}

if (hub_end_mode) {
    var _crown_spin = _time * 0.28;
    gpu_set_blendmode(bm_add);

    for (var _ray = 0; _ray < 24; _ray++) {
        var _rf = _ray / 24;
        var _ra = _crown_spin + _ray * 15;
        var _short = (_ray mod 3 != 0);
        var _inner = _short ? 86 : 74;
        var _outer = _short ? 118 : 146 + hub_major_pulse * 12;
        var _rx1 = hub_gate_x + lengthdir_x(_inner, _ra);
        var _ry1 = hub_gate_y + lengthdir_y(_inner * 0.78, _ra);
        var _rx2 = hub_gate_x + lengthdir_x(_outer, _ra + sin(_sec + _ray) * 2);
        var _ry2 = hub_gate_y + lengthdir_y(_outer * 0.78, _ra + sin(_sec + _ray) * 2);

        draw_set_color((_ray mod 4 == 0) ? hub_col_warning : hub_col_cyan);
        draw_set_alpha((0.06 + _end_glow * 0.055 + (_short ? 0 : hub_major_pulse * 0.08)) * _end_reveal);
        draw_line_width(_rx1, _ry1, _rx2, _ry2, _short ? 1 : 1.6);
    }

    for (var _halo = 0; _halo < 4; _halo++) {
        var _hr = 58 + _halo * 24 + sin(_sec * (1.1 + _halo * 0.2)) * 3;
        draw_set_color((_halo mod 2 == 0) ? hub_col_cyan : hub_col_warning);
        draw_set_alpha((0.10 + _halo * 0.025 + hub_major_pulse * 0.06) * _end_reveal);
        scr_draw_smooth_ring_mask(hub_gate_x, hub_gate_y, _hr, 1, 1.2 + _halo * 0.45, (_halo mod 2 == 0) ? hub_col_cyan : hub_col_warning);
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

gpu_set_blendmode(bm_add);
draw_set_color(merge_color(hub_col_cyan, c_white, 0.35 + hub_gate_charge * 0.25));
draw_set_alpha(0.18 + _gate_wake * 0.22);
scr_draw_smooth_ring_mask(hub_gate_x, hub_gate_y, 76 + hub_gate_charge * 10 + hub_warp_flash * 28, 1, 3.2, hub_col_cyan);
draw_set_color(hub_col_warning);
draw_set_alpha(0.10 + hub_major_pulse * 0.14 + hub_warp_flash * 0.26);
scr_draw_smooth_ring_mask(hub_gate_x, hub_gate_y, 102 + sin(_sec * 3.4) * 3, 1, 2.2, hub_col_warning);
gpu_set_blendmode(bm_normal);

draw_set_color(merge_color(hub_col_panel_hi, c_white, 0.08 + _hum * 0.04));
draw_set_alpha(0.95);
draw_rectangle(0, _floor_y - 4, GAME_WIDTH, _floor_y + 14, false);
draw_set_color(hub_col_panel_dark);
draw_set_alpha(0.98);
draw_rectangle(0, _floor_y + 14, GAME_WIDTH, GAME_HEIGHT, false);
draw_set_color(merge_color(hub_col_edge, c_white, 0.24));
draw_set_alpha(0.42 + _hum * 0.18);
draw_line_width(0, _floor_y - 5, GAME_WIDTH, _floor_y - 5, 2.4);

if (instance_exists(oPlayer)) {
    var _feet_y = oPlayer.y + sprite_origin_to_bottom(oPlayer.sprite_index) * abs(oPlayer.image_yscale);
    var _air = clamp((_floor_y - _feet_y) / 96, 0, 1);
    var _shadow_w = lerp(20, 34, _air);
    var _shadow_h = lerp(4.2, 2.1, _air);
    var _shadow_a = lerp(0.34, 0.12, _air);

    draw_set_color(c_black);
    draw_set_alpha(_shadow_a);
    draw_ellipse(oPlayer.x - _shadow_w, _floor_y - _shadow_h,
                 oPlayer.x + _shadow_w, _floor_y + _shadow_h, false);

    draw_set_color(merge_color(hub_col_cyan, c_black, 0.65));
    draw_set_alpha((0.04 + hub_gate_charge * 0.035) * (1 - _air * 0.45));
    draw_ellipse(oPlayer.x - _shadow_w * 0.62, _floor_y - _shadow_h * 0.56,
                 oPlayer.x + _shadow_w * 0.62, _floor_y + _shadow_h * 0.56, false);
}

for (var _fg = 0; _fg < 12; _fg++) {
    var _fx = _fg * 78 - 18;
    var _lean2 = (_fg mod 2 == 0) ? 22 : -16;
    draw_set_color(merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.32));
    draw_set_alpha(0.74);
    draw_line_width(_fx, _floor_y + 22, _fx + _lean2, GAME_HEIGHT + 24, 8);
    draw_set_color(merge_color(hub_col_edge, c_white, 0.1));
    draw_set_alpha(0.08 + _hum * 0.045);
    draw_line_width(_fx - 3, _floor_y + 22, _fx + _lean2 - 3, GAME_HEIGHT + 24, 1);
}
draw_set_alpha(1);
draw_set_color(c_white);

if (!hub_end_mode) {
    var _pcx = hub_practice_x;
    var _pcy = hub_practice_y;
    var _pa = hub_practice_near ? 1 : 0.58;
    var _pflash = hub_practice_flash;
    var _pcol = global.hitcount_mode ? hub_col_cyan : hub_col_warning;

    draw_set_color(c_black);
    draw_set_alpha(0.34);
    draw_ellipse(_pcx - 82, hub_floor_y - 12, _pcx + 82, hub_floor_y + 10, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_pcx - 74, _pcy - 82, merge_color(hub_col_panel_mid, hub_col_panel_hi, 0.18), 0.84 * _pa);
    draw_vertex_colour(_pcx + 76, _pcy - 78, merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.22), 0.84 * _pa);
    draw_vertex_colour(_pcx - 92, _pcy + 6, hub_col_panel_dark, 0.95 * _pa);
    draw_vertex_colour(_pcx + 92, _pcy + 4, c_black, 0.95 * _pa);
    draw_primitive_end();

    draw_set_color(merge_color(hub_col_edge, c_white, 0.14 + _pflash * 0.2));
    draw_set_alpha((0.34 + _pflash * 0.26) * _pa);
    draw_line_width(_pcx - 70, _pcy - 77, _pcx + 70, _pcy - 74, 2);
    draw_line_width(_pcx - 84, _pcy + 4, _pcx + 86, _pcy + 2, 2);

    gpu_set_blendmode(bm_add);
    draw_set_color(_pcol);
    draw_set_alpha((0.12 + _pflash * 0.28) * _pa);
    draw_rectangle(_pcx - 56, _pcy - 58, _pcx + 56, _pcy - 25, false);
    draw_set_color(hub_col_white);
    draw_set_alpha(0.06 * _pa + _pflash * 0.12);
    draw_line_width(_pcx - 47, _pcy - 45, _pcx + 48, _pcy - 45, 1);
    gpu_set_blendmode(bm_normal);

    draw_set_font(fDefault);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(hub_col_white);
    draw_set_alpha((hub_practice_near ? 0.92 : 0.62) * _pa);
    draw_text(_pcx, _pcy - 72, "TRAINING");

    draw_set_color(merge_color(hub_col_edge, c_white, 0.16));
    draw_set_alpha((hub_practice_near ? 0.84 : 0.48) * _pa);
    draw_text(_pcx, _pcy - 52, "UP: PRACTICE");

    draw_set_color(_pcol);
    draw_set_alpha((0.78 + _pflash * 0.22) * _pa);
    draw_text(_pcx, _pcy - 35, "H: HIT COUNT " + (global.hitcount_mode ? "ON" : "OFF"));

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (instance_exists(oPlayer)) {
    var _pxp = floor(oPlayer.x);
    var _pyp = floor(oPlayer.y);

    if (hub_end_mode) {
        with (oPlayer) {
            event_perform(ev_draw, 0);
        }
    } else {
        if (oPlayer.show_parry_range) {
            gpu_set_blendmode(bm_add);
            draw_set_color(hub_col_cyan);
            draw_set_alpha(0.18);
            draw_circle(_pxp, _pyp, 40, true);
            draw_set_alpha(0.08);
            draw_circle(_pxp, _pyp, 40, false);
            gpu_set_blendmode(bm_normal);
        }

        draw_sprite_ext(oPlayer.sprite_index, oPlayer.image_index, _pxp, _pyp,
                        oPlayer.image_xscale * oPlayer.facing, oPlayer.image_yscale, oPlayer.image_angle,
                        oPlayer.image_blend, oPlayer.image_alpha);
    }

    if (instance_exists(oPlayer.weapon)) {
        var _weap = oPlayer.weapon;
        draw_sprite_ext(_weap.sprite_index, _weap.image_index, _weap.x, _weap.y,
                        _weap.image_xscale, _weap.image_yscale, _weap.image_angle,
                        _weap.image_blend, _weap.image_alpha);
    }

    with (oWeaponProjectile) {
        event_perform(ev_draw, 0);
    }
}

if (!hub_end_mode) {
    var _best_hits = savedata_get_active("avoidance_best_hits");
    var _best_hits_text = "BEST HITS: " + ((_best_hits < 0) ? "-" : string(_best_hits));
    draw_set_font(fDefault);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_set_color(merge_color(hub_col_edge, c_white, 0.22));
    draw_set_alpha(0.72);
    draw_text(GAME_WIDTH - 12, 10, _best_hits_text);

    if (!hub_practice_menu_open) {
        draw_set_color(merge_color(hub_col_edge, c_white, 0.16));
        draw_set_alpha(0.56);
        draw_text_transformed(GAME_WIDTH - 12, 30, "IN RUN: BACKSPACE RETURNS HERE", 0.72, 0.72, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (!hub_end_mode && hub_practice_menu_open) {
    var _mx0 = 72;
    var _my0 = 82;
    var _mw = 404;
    var _row_h = 27;
    var _visible_rows = 11;
    var _mh = 118 + _visible_rows * _row_h;
    var _mx1 = _mx0 + _mw;
    var _my1 = _my0 + _mh;
    var _menu_a = 0.92;
    var _count = array_length(hub_practice_markers);
    var _range_end = min(_count, hub_practice_scroll + _visible_rows);

    draw_set_color(c_black);
    draw_set_alpha(0.42);
    draw_rectangle(_mx0 + 12, _my0 + 16, _mx1 + 10, _my1 + 12, false);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_mx0, _my0, merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.36), _menu_a);
    draw_vertex_colour(_mx1, _my0, merge_color(hub_col_panel_mid, hub_col_edge, 0.10), _menu_a);
    draw_vertex_colour(_mx0, _my1, merge_color(c_black, hub_col_panel_dark, 0.42), _menu_a);
    draw_vertex_colour(_mx1, _my1, merge_color(c_black, hub_col_panel_mid, 0.25), _menu_a);
    draw_primitive_end();

    draw_menu_title_corner_frame(_mx0, _my0, _mx1, _my1, 12, hub_col_edge, 0.55 + hub_practice_menu_flash * 0.2, _sec);
    draw_menu_title_corner_frame(_mx0 + 18, _my0 + 52, _mx1 - 18, _my1 - 18, 7, hub_col_warning, 0.18 + hub_practice_menu_flash * 0.12, _sec + 5);

    draw_set_font(fDefault);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(hub_col_white);
    draw_set_alpha(0.95);
    draw_text(_mx0 + 22, _my0 + 18, "ATTACK PRACTICE");

    draw_set_color(merge_color(hub_col_edge, c_white, 0.18));
    draw_set_alpha(0.72);
    draw_text_transformed(_mx0 + 22, _my0 + 42, "UP/DOWN SELECT", 0.82, 0.82, 0);
    draw_text_transformed(_mx0 + 22, _my0 + 60, "Z/SHIFT START", 0.82, 0.82, 0);
    draw_set_halign(fa_right);
    draw_text_transformed(_mx1 - 22, _my0 + 60, "S CLOSE", 0.82, 0.82, 0);
    draw_set_halign(fa_left);

    var _list_y = _my0 + 88;
    for (var _i = hub_practice_scroll; _i < _range_end; _i++) {
        var _row_y = _list_y + (_i - hub_practice_scroll) * _row_h;
        var _m = hub_practice_markers[_i];
        var _sel = (_i == hub_practice_selected);
        var _fill = _sel ? merge_color(hub_col_panel_mid, hub_col_cyan, 0.18 + hub_practice_menu_flash * 0.08) : merge_color(hub_col_panel_dark, hub_col_panel_mid, 0.34);
        var _edge = _sel ? hub_col_cyan : merge_color(hub_col_panel_hi, c_black, 0.20);

        draw_set_alpha(_sel ? 0.92 : 0.62);
        draw_rectangle_colour(_mx0 + 18, _row_y, _mx1 - 18, _row_y + _row_h - 4, _fill, _fill, _fill, _fill, false);
        draw_set_color(_edge);
        draw_set_alpha(_sel ? 0.86 : 0.24);
        draw_rectangle(_mx0 + 18, _row_y, _mx1 - 18, _row_y + _row_h - 4, true);

        draw_set_color(_m.color);
        draw_set_alpha(_sel ? 0.95 : 0.70);
        draw_rectangle(_mx0 + 26, _row_y + 6, _mx0 + 32, _row_y + _row_h - 10, false);

        draw_set_color(_sel ? hub_col_white : merge_color(hub_col_edge, c_white, 0.16));
        draw_set_alpha(_sel ? 0.96 : 0.75);
        draw_text(_mx0 + 40, _row_y + 4, _m.name);
    }

    if (_count > _visible_rows) {
        draw_set_halign(fa_right);
        draw_set_color(merge_color(hub_col_edge, c_white, 0.12));
        draw_set_alpha(0.62);
        draw_text(_mx1 - 24, _my1 - 28, string(hub_practice_scroll + 1) + "-" + string(_range_end) + " / " + string(_count));
        draw_set_halign(fa_left);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_set_color(c_black);
for (var _scan = 0; _scan < GAME_HEIGHT; _scan += 4) {
    draw_set_alpha(0.05);
    draw_rectangle(0, _scan, GAME_WIDTH, _scan + 1, false);
}
draw_set_alpha(1);

surface_reset_target();

surface_set_target(hub_glow_surface);
draw_clear_alpha(c_black, 0);

gpu_set_blendmode(bm_add);

var _gate_glow = 0.42 + _hum * 0.32 + hub_gate_charge * 0.6 + hub_warp_flash * 1.1;
draw_sprite_ext(spr_glow_blob, 0, hub_gate_x, hub_gate_y,
                (210 + hub_gate_charge * 90 + hub_warp_flash * 180) / 64,
                (250 + hub_gate_charge * 130 + hub_warp_flash * 210) / 64,
                0, hub_col_cyan, 0.16 + _gate_glow * 0.13);
draw_sprite_ext(spr_glow_blob, 0, hub_gate_x, hub_gate_y + 4,
                (92 + hub_warp_flash * 80) / 64,
                (148 + hub_warp_flash * 120) / 64,
                0, hub_col_white, 0.16 + hub_gate_charge * 0.25 + hub_warp_flash * 0.42);
draw_sprite_ext(spr_glow_blob, 0, hub_gate_x, _floor_y - 6,
                (230 + hub_warp_flash * 160) / 64,
                (42 + hub_warp_flash * 40) / 64,
                0, hub_col_warning, 0.12 + hub_gate_charge * 0.12 + hub_warp_flash * 0.35);

if (hub_end_mode) {
    draw_sprite_ext(spr_glow_blob, 0, hub_gate_x, hub_gate_y,
                    (330 + _end_glow * 90) / 64,
                    (260 + _end_glow * 70) / 64,
                    0, hub_col_cyan, (0.08 + _end_glow * 0.08) * _end_reveal);
    draw_sprite_ext(spr_glow_blob, 0, hub_gate_x - 44, 208,
                    (360 + hub_major_pulse * 70) / 64,
                    (126 + hub_minor_pulse * 32) / 64,
                    0, hub_col_white, (0.035 + _end_glow * 0.035) * _end_reveal);

    for (var _end_node = 0; _end_node < 18; _end_node++) {
        var _na = _end_node * 20 + _time * 0.38;
        var _nr = 98 + (_end_node mod 3) * 28 + sin(_sec * 1.4 + _end_node) * 4;
        var _nx = hub_gate_x + lengthdir_x(_nr, _na);
        var _ny = hub_gate_y + lengthdir_y(_nr * 0.72, _na);
        var _node_col = (_end_node mod 4 == 0) ? hub_col_warning : hub_col_cyan;
        draw_sprite_ext(spr_glow_blob, 0, _nx, _ny,
                        (13 + hub_major_pulse * 5) / 64,
                        (13 + hub_major_pulse * 5) / 64,
                        0, _node_col, (0.11 + _end_glow * 0.06) * _end_reveal);
    }
}

for (var i = 0; i < array_length(hub_rail_nodes); i++) {
    var _n = hub_rail_nodes[i];
    var _node_p = 0.45 + 0.55 * sin(_n.seed + _time * 0.045);
    var _nc = _n.hot ? hub_col_warning : hub_col_cyan;
    draw_set_color(_nc);
    draw_set_alpha((0.07 + _hum * 0.08) * _node_p);
    draw_line_width(_n.x, _n.y, hub_gate_x + (_n.x - GAME_WIDTH * 0.5) * 0.08, _floor_y - 8, 2);
    draw_circle(_n.x, _n.y, 2 + _node_p * 1.5, false);
}

for (var i = 0; i < array_length(hub_motes); i++) {
    var _m = hub_motes[i];
    var _ma = 0.16 + 0.18 * sin(_m.seed + _time * 0.055);
    draw_set_color(_m.color);
    draw_set_alpha(clamp(_ma, 0.04, 0.28) * (0.7 + hub_gate_charge * 0.7));
    draw_circle(_m.x, _m.y, _m.size, false);
    if (_m.size > 1.4) {
        draw_line_width(_m.x, _m.y + _m.size * 2.5, _m.x, _m.y - _m.size * 2.5, 1);
    }
}

for (var i = 0; i < array_length(hub_streams); i++) {
    var _st2 = hub_streams[i];
    var _sa2 = clamp(_st2.life / max(_st2.life_max, 1), 0, 1);
    draw_set_color(_st2.color);
    draw_set_alpha(_sa2 * (0.22 + _st2.width * 0.05));
    draw_line_width(_st2.x, _st2.y, _st2.x + sin(_st2.seed + _time * 0.2) * 8,
                    _st2.y - _st2.len, _st2.width);
    draw_set_color(hub_col_white);
    draw_set_alpha(_sa2 * 0.16);
    draw_line_width(_st2.x, _st2.y - _st2.len * 0.1, _st2.x, _st2.y - _st2.len * 0.82, 1);
}

for (var i = 0; i < array_length(hub_sparks); i++) {
    var _s = hub_sparks[i];
    var _sa3 = clamp(_s.life / max(_s.life_max, 1), 0, 1);
    var _tail = 4 + _s.size * 3.2;
    draw_set_color(_s.color);
    draw_set_alpha(_sa3 * 0.48);
    draw_line_width(_s.x, _s.y, _s.x - _s.vx * _tail, _s.y - _s.vy * _tail, max(1, _s.size * 0.65));
    draw_set_color(hub_col_white);
    draw_set_alpha(_sa3 * 0.45);
    draw_circle(_s.x, _s.y, max(1, _s.size * 0.42), false);
}

for (var i = 0; i < array_length(hub_rings); i++) {
    var _r = hub_rings[i];
    var _ra = clamp(_r.life / max(_r.life_max, 1), 0, 1);
    scr_draw_smooth_ring_mask(_r.x, _r.y, _r.radius, _ra * 0.42, 3 + _r.strength * 4, _r.color);
    scr_draw_smooth_ring_mask(_r.x, _r.y, _r.radius * 0.72, _ra * 0.18, 2.2, merge_color(_r.color, hub_col_white, 0.35));
}

for (var _coil = 0; _coil < 7; _coil++) {
    var _ca = _time * (0.82 + _coil * 0.04) + _coil * 51;
    var _r1 = 82 + _coil * 9 + sin(_sec * 2 + _coil) * 5;
    var _x1c = hub_gate_x + lengthdir_x(_r1, _ca);
    var _y1c = hub_gate_y + lengthdir_y(_r1 * 1.2, _ca);
    var _x2c = hub_gate_x + lengthdir_x(_r1, _ca + 22 + hub_gate_charge * 16);
    var _y2c = hub_gate_y + lengthdir_y(_r1 * 1.2, _ca + 22 + hub_gate_charge * 16);
    draw_set_color((_coil mod 2 == 0) ? hub_col_cyan : hub_col_warning);
    draw_set_alpha(0.08 + _hum * 0.05 + hub_gate_charge * 0.06);
    draw_line_width(_x1c, _y1c, _x2c, _y2c, 2 + hub_gate_charge * 1.5);
    draw_set_color(hub_col_white);
    draw_set_alpha(hub_gate_charge * 0.08);
    draw_line_width(_x1c, _y1c, _x2c, _y2c, 1);
}

for (var i = 0; i < array_length(hub_bolts); i++) {
    hub_draw_bolt(hub_bolts[i], 1);
}

for (var _orb = 0; _orb < 10; _orb++) {
    var _ang = global.hub_orbit_angle + _orb * 36;
    var _ox = hub_gate_x + lengthdir_x(74 + sin(_time * 0.04 + _orb) * 5, _ang);
    var _oy = hub_gate_y + lengthdir_y(46 + cos(_time * 0.035 + _orb) * 4, _ang) * 0.92;
    var _oc = (_orb mod 3 == 0) ? hub_col_warning : hub_col_cyan;
    draw_sprite_ext(spr_glow_blob, 0, _ox, _oy, 0.34, 0.34, 0, _oc, 0.14 + _hum * 0.08);
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

surface_reset_target();

var _ring_count = min(array_length(hub_rings), 4);
for (var i = 0; i < 4; i++) {
    hub_ring_centers[i * 2] = 0;
    hub_ring_centers[i * 2 + 1] = 0;
    hub_ring_radii[i] = 0;
    hub_ring_strengths[i] = 0;

    if (i < _ring_count) {
        var _rring = hub_rings[array_length(hub_rings) - 1 - i];
        var _r_alpha = clamp(_rring.life / max(_rring.life_max, 1), 0, 1);
        hub_ring_centers[i * 2] = _rring.x / GAME_WIDTH;
        hub_ring_centers[i * 2 + 1] = _rring.y / GAME_HEIGHT;
        hub_ring_radii[i] = _rring.radius / GAME_WIDTH;
        hub_ring_strengths[i] = _rring.strength * _r_alpha * (0.25 + hub_gate_charge * 0.35 + hub_warp_flash * 0.6);
    }
}

var _swirl_count = 3;
hub_swirl_centers[0] = hub_gate_x / GAME_WIDTH;
hub_swirl_centers[1] = hub_gate_y / GAME_HEIGHT;
hub_swirl_radii[0] = (110 + hub_gate_charge * 42 + hub_warp_flash * 120) / GAME_WIDTH;
hub_swirl_strengths[0] = 0.018 + hub_gate_charge * 0.045 + hub_warp_flash * 0.13 + _end_glow * 0.022;

hub_swirl_centers[2] = 118 / GAME_WIDTH;
hub_swirl_centers[3] = 220 / GAME_HEIGHT;
hub_swirl_radii[1] = 160 / GAME_WIDTH;
hub_swirl_strengths[1] = 0.008 + hub_major_pulse * 0.018;

hub_swirl_centers[4] = 474 / GAME_WIDTH;
hub_swirl_centers[5] = 126 / GAME_HEIGHT;
hub_swirl_radii[2] = 130 / GAME_WIDTH;
hub_swirl_strengths[2] = 0.006 + hub_minor_pulse * 0.016;

hub_swirl_centers[6] = 0;
hub_swirl_centers[7] = 0;
hub_swirl_radii[3] = 0;
hub_swirl_strengths[3] = 0;

shader_set(shd_lightning_distort);
texture_set_stage(hub_u_base_tex, surface_get_texture(hub_scene_surface));
shader_set_uniform_f(hub_u_time, current_time * 0.001);
shader_set_uniform_f(hub_u_strength, 0.18 + hub_gate_charge * 0.18 + hub_warp_flash * 0.34 + _end_glow * 0.08);
shader_set_uniform_f(hub_u_texel, 1 / GAME_WIDTH, 1 / GAME_HEIGHT);
shader_set_uniform_f(hub_u_vignette, clamp(0.22 + _hum * 0.14 + hub_warp_flash * 0.26 + _end_glow * 0.04, 0, 0.72));
shader_set_uniform_f(hub_u_aberration, clamp(0.04 + hub_aberration_pulse + hub_warp_flash * 0.26 + _end_glow * 0.025, 0, 0.58));
shader_set_uniform_f(hub_u_bloom, clamp(0.32 + hub_bloom_pulse * 0.8 + _hum * 0.12 + hub_warp_flash * 0.52 + _end_glow * 0.20, 0, 1.25));
shader_set_uniform_f(hub_u_tear, clamp(hub_tear_pulse + hub_warp_flash * 0.28, 0, 0.65));
shader_set_uniform_f(hub_u_ripple, clamp(hub_ripple_pulse * 0.8 + hub_warp_flash * 0.55, 0, 1.1));
shader_set_uniform_f_array(hub_u_ring_centers, hub_ring_centers);
shader_set_uniform_f_array(hub_u_ring_radii, hub_ring_radii);
shader_set_uniform_f_array(hub_u_ring_strengths, hub_ring_strengths);
shader_set_uniform_i(hub_u_ring_count, _ring_count);
shader_set_uniform_f_array(hub_u_swirl_centers, hub_swirl_centers);
shader_set_uniform_f_array(hub_u_swirl_radii, hub_swirl_radii);
shader_set_uniform_f_array(hub_u_swirl_strengths, hub_swirl_strengths);
shader_set_uniform_i(hub_u_swirl_count, _swirl_count);
shader_set_uniform_f(hub_u_intro_dim, 0);
shader_set_uniform_f(hub_u_slash_amount, 0);
shader_set_uniform_f(hub_u_slash_center, hub_gate_x / GAME_WIDTH, hub_gate_y / GAME_HEIGHT);
draw_surface_stretched(hub_glow_surface, 0, 0, _gw, _gh);
shader_reset();

if (hub_warp_flash > 0.01) {
    gpu_set_blendmode(bm_add);
    draw_set_color(hub_col_cyan);
    draw_set_alpha(hub_warp_flash * 0.18);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_color(c_white);
    draw_set_alpha(max(0, hub_warp_flash - 0.48) * 0.42);
    draw_rectangle(0, 0, _gw, _gh, false);
    gpu_set_blendmode(bm_normal);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (DEBUG &&
    variable_global_exists("bc_cli_profile_capture_enabled") &&
    global.bc_cli_profile_capture_enabled &&
    variable_global_exists("bc_cli_profile_room") &&
    global.bc_cli_profile_room == "hub" &&
    bc_profile_should_capture_frame(global.bc_cli_profile_hub_frame, global.bc_cli_profile_frames)) {
    bc_profile_capture_frame("hub", global.bc_cli_profile_hub_frame);
}
