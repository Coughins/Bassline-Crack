var _age = max(0, time - offset)
var _r = clamp(_age / max(1, reveal_length), 0, 1)
if (_r <= 0) exit

var _ease = 1 - power(1 - _r, 3)
var _gw = display_get_gui_width()
var _gh = display_get_gui_height()
var _cx = _gw * 0.5
var _cy = _gh * 0.5
var _clock = time / FPS_BASE
var _red = make_color_rgb(255, 22, 18)
var _deep_red = make_color_rgb(88, 4, 4)
var _soft = make_color_rgb(214, 194, 180)
var _cyan = make_color_rgb(64, 220, 255)
var _hit = power(max(0, sin(_clock * 2.3)), 8)
var _glitch = power(max(0, sin(_clock * 7.1 + overlay_seed)), 14)

draw_set_halign(fa_left)
draw_set_valign(fa_top)
gpu_set_blendmode(bm_normal)

draw_set_color(c_black)
draw_set_alpha((0.44 + _hit * 0.07) * _ease)
draw_rectangle(0, 0, _gw, _gh, false)

draw_set_color(make_color_rgb(22, 3, 4))
draw_set_alpha(0.24 * _ease)
draw_rectangle(0, 0, _gw, _gh, false)

gpu_set_blendmode(bm_add)
draw_set_color(_red)
draw_set_alpha((0.07 + _hit * 0.08) * _ease)
draw_rectangle(0, 0, _gw, _gh, false)
gpu_set_blendmode(bm_normal)

draw_menu_title_dust(_gw, _gh, _red, _clock + overlay_seed * 0.001, 0.72 * _ease, 120)
draw_menu_title_signal_lattice(_gw, _gh, _deep_red, _clock + 9.7, 0.48 * _ease)
draw_menu_title_shock_rings(_cx, _cy - 22, _red, _clock, (0.32 + _hit * 0.16) * _ease, 360)
draw_menu_title_scanlines(_gw, _gh, _red, _clock, 0.58 * _ease)

var _slice_x = _cx
var _slice_y = _cy
var _slice_angle = 45
if (instance_exists(oPlayerDeath)) {
	var _death = instance_find(oPlayerDeath, 0)
	var _p = scr_death_room_to_gui(_death.death_x, _death.death_y)
	_slice_x = _p.x
	_slice_y = _p.y
	_slice_angle = _death.cut_angle
}

var _reach = point_distance(0, 0, _gw, _gh) * 1.18
var _dx = lengthdir_x(_reach, _slice_angle)
var _dy = lengthdir_y(_reach, _slice_angle)

gpu_set_blendmode(bm_add)
draw_set_color(_red)
draw_set_alpha((0.18 + _hit * 0.14) * _ease)
draw_line_width(_slice_x - _dx, _slice_y - _dy, _slice_x + _dx, _slice_y + _dy, 18)
draw_set_alpha((0.65 + _glitch * 0.25) * _ease)
draw_line_width(_slice_x - _dx, _slice_y - _dy, _slice_x + _dx, _slice_y + _dy, 2)

for (var i = 0; i < array_length(rupture_ticks); i++) {
	var _tk = rupture_ticks[i]
	if (_age < _tk.delay) continue

	var _tx = _slice_x + _dx * _tk.u
	var _ty = _slice_y + _dy * _tk.u
	var _a = clamp((_age - _tk.delay) / 22, 0, 1) * _ease
	var _tick_ang = _slice_angle + 90 + _tk.side * random_range(-5, 5)
	var _len = _tk.len * (0.65 + _hit * 0.35)

	draw_set_color(merge_color(_red, c_white, _tk.heat))
	draw_set_alpha(_a * (0.18 + _tk.heat * 0.38))
	draw_line_width(_tx, _ty, _tx + lengthdir_x(_len, _tick_ang), _ty + lengthdir_y(_len, _tick_ang), 1)
}
gpu_set_blendmode(bm_normal)

var _panel_w = min(_gw - 96, 640)
var _panel_h = 360
var _panel_x = _cx - _panel_w * 0.5
var _panel_y = _cy - _panel_h * 0.5 + 12
var _open_w = _panel_w * max(0.06, _ease)

draw_set_color(make_color_rgb(4, 4, 4))
draw_set_alpha(0.78 * _ease)
draw_rectangle(_panel_x, _panel_y, _panel_x + _open_w, _panel_y + _panel_h, false)

gpu_set_blendmode(bm_add)
draw_set_color(_red)
draw_set_alpha((0.11 + _hit * 0.10 + _glitch * 0.12) * _ease)
draw_rectangle(_panel_x + 3, _panel_y + 3, _panel_x + _open_w - 3, _panel_y + _panel_h - 3, false)
gpu_set_blendmode(bm_normal)

draw_menu_title_corner_frame(
	_panel_x,
	_panel_y,
	_panel_x + _panel_w,
	_panel_y + _panel_h,
	14,
	_red,
	(0.72 + _hit * 0.18 + _glitch * 0.18) * _ease,
	_clock
)

draw_set_font(fMenu)
draw_set_color(_red)
draw_set_alpha(0.82 * _ease)
draw_menu_title_spaced_center_fit(_cx, _panel_y + 24, "FATAL SIGNAL", 6, 0.62, 0.62, _panel_w - 96)
draw_set_font(fMenu)

draw_set_color(_red)
draw_set_alpha(0.88 * _ease)

draw_menu_title_spaced_center_fit(
    _cx,
    _panel_y + 24,
    "FATAL SIGNAL",
    6,
    0.62,
    0.62,
    _panel_w - 96
)


draw_set_color(merge_color(_red, c_white, 0.28))
draw_set_alpha(0.76 * _ease)

draw_menu_title_clean_center_fit(
    _cx,
    _panel_y + 50,
    "RUN TERMINATED // MUSIC CUT // TIMELINE LOCKED",
    0.60,
    0.60,
    _panel_w - 96,
    0.52
)


draw_menu_title_waveform(
    _panel_x + 42,
    _panel_x + _panel_w - 42,
    _panel_y + 82,
    6 + _hit * 9,
    120,
    _red,
    0.60 * _ease,
    _clock,
    22.8
)
draw_menu_title_waveform(_panel_x + 42, _panel_x + _panel_w - 42, _panel_y + 76, 6 + _hit * 9, 120, _red, 0.60 * _ease, _clock, 22.8)


draw_set_font(fAvoidance)
draw_set_halign(fa_center)
draw_set_valign(fa_top)

var _word_scale = min(
    0.92,
    (_panel_w - 148) / max(1, string_width("GAME"))
)

var _word_h = string_height("GAME") * _word_scale;



var _title_y = _panel_y + 88;

var _over_y = _title_y + _word_h * 0.72;


var _tear = 5 + _ease * 12 + _glitch * 10;
var _jit = sin(_clock * 38) * (0.8 + _glitch * 5);



draw_set_color(c_black);

for (var i = 0; i < 15; i++)
{
    var _seed = overlay_seed + i * 37;

    var _yy =
        _title_y
        + draw_menu_title_hash(_seed)
        * (_word_h * 1.42);

    var _ww =
        (
            52
            + draw_menu_title_hash(_seed + 5) * 240
        )
        * _word_scale;

    var _xx =
        _cx
        - _panel_w * 0.35
        + draw_menu_title_hash(_seed + 9)
        * _panel_w * 0.70;

    draw_set_alpha(
        _ease
        * (
            0.08
            + draw_menu_title_hash(_seed + 12) * 0.18
        )
    );

    draw_rectangle(
        _xx - _ww * 0.5,
        _yy,
        _xx + _ww * 0.5,
        _yy + 2 + draw_menu_title_hash(_seed + 15) * 3,
        false
    );
}



gpu_set_blendmode(bm_add);

draw_set_color(_red);

for (var i = 0; i < 10; i++)
{
    var _seed = overlay_seed + i * 53;

    var _yy =
        _title_y
        + draw_menu_title_hash(_seed + 20)
        * (_word_h * 1.40);

    var _x1 =
        _cx
        - _panel_w * 0.32
        + draw_menu_title_hash(_seed + 21)
        * _panel_w * 0.18;

    var _x2 =
        _cx
        + _panel_w * 0.06
        + draw_menu_title_hash(_seed + 22)
        * _panel_w * 0.34;

    draw_set_alpha(
        _ease
        * (
            0.04
            + _glitch * 0.08
            + draw_menu_title_hash(_seed + 23) * 0.06
        )
    );

    draw_line_width(
        _x1,
        _yy,
        _x2,
        _yy + sin(i + _clock * 5) * 5,
        1
    );
}

gpu_set_blendmode(bm_normal);



gpu_set_blendmode(bm_add);


draw_set_color(_cyan);
draw_set_alpha(0.13 * _ease);

draw_text_transformed(
    _cx - _tear * 0.8 - _jit,
    _title_y + 2,
    "GAME",
    _word_scale,
    _word_scale,
    0
);

draw_text_transformed(
    _cx + _tear * 0.9 + _jit,
    _over_y + 4,
    "OVER",
    _word_scale,
    _word_scale,
    0
);


draw_set_color(_red);
draw_set_alpha(
    (0.40 + _hit * 0.18) * _ease
);

draw_text_transformed(
    _cx - _tear,
    _title_y,
    "GAME",
    _word_scale,
    _word_scale,
    0
);

draw_text_transformed(
    _cx + _tear,
    _over_y,
    "OVER",
    _word_scale,
    _word_scale,
    0
);

gpu_set_blendmode(bm_normal);



draw_set_color(c_white);
draw_set_alpha(0.94 * _ease);

draw_text_transformed(
    _cx - _tear * 0.35,
    _title_y,
    "GAME",
    _word_scale,
    _word_scale,
    0
);


draw_set_color(_soft);
draw_set_alpha(0.94 * _ease);

draw_text_transformed(
    _cx + _tear * 0.35,
    _over_y,
    "OVER",
    _word_scale,
    _word_scale,
    0
);


draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

var _prompt_r = clamp((_age - prompt_delay) / 18, 0, 1)
var _prompt_ease = (1 - power(1 - _prompt_r, 3)) * _ease
var _blink = 0.50 + 0.50 * sin(_clock * 5.8)
var _prompt_y = _panel_y + _panel_h - 62
var _key_w = 62
var _key_h = 42
var _key_x = _cx - 205

if (_prompt_ease > 0) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_red)
	draw_set_alpha(_prompt_ease * (0.22 + _blink * 0.22))
	draw_rectangle(_cx - 252, _prompt_y - 12, _cx + 252, _prompt_y + 62, true)
	draw_line_width(_cx - 278, _prompt_y + 16, _cx - 228, _prompt_y + 16, 1)
	draw_line_width(_cx + 228, _prompt_y + 16, _cx + 278, _prompt_y + 16, 1)
	gpu_set_blendmode(bm_normal)

	draw_set_color(make_color_rgb(5, 5, 5))
	draw_set_alpha(0.86 * _prompt_ease)
	draw_rectangle(_key_x, _prompt_y - 8, _key_x + _key_w, _prompt_y - 8 + _key_h, false)
	draw_menu_title_corner_frame(_key_x, _prompt_y - 8, _key_x + _key_w, _prompt_y - 8 + _key_h, 7, _red, (0.64 + _blink * 0.25) * _prompt_ease, _clock)

	draw_set_font(fMenu)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_set_alpha(_prompt_ease)
	draw_text_transformed(_key_x + _key_w * 0.5, _prompt_y - 3, "R", 1.16, 1.16, 0)

	draw_set_halign(fa_left)
	draw_set_color(_soft)
	draw_set_alpha(_prompt_ease * (0.68 + _blink * 0.28))
	draw_menu_title_spaced_fit(_key_x + _key_w + 22, _prompt_y + 1, "PRESS R TO RESTART", 7, 0.76, 0.76, 372, 1, 0.52)

	draw_set_color(_red)
	draw_set_alpha(_prompt_ease * 0.52)
	draw_menu_title_waveform(_cx - 210, _cx + 210, _prompt_y + 54, 6 + _blink * 8, 108, _red, _prompt_ease * 0.72, _clock, 30.2)
}

draw_set_font(fMenu)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

var _locked_t = 0
if (instance_exists(oAvoidanceController)) _locked_t = oAvoidanceController.t

gpu_set_blendmode(bm_add)
draw_set_color(_red)
draw_set_alpha(0.44 * _ease)
draw_menu_title_bass_columns(42, _panel_y + 94, 24, _panel_h - 146, _red, _clock, 0.62 * _ease, 11, 44)
draw_menu_title_vertical_analyzer(_panel_x + _panel_w - 36, _panel_y + 92, _panel_y + _panel_h - 46, _red, 0.42 * _ease, _clock)

for (var i = 0; i < array_length(scan_rows); i++) {
	var _row = scan_rows[i]
	var _yy = _gh * _row.y
	var _xx = ((_clock * _row.speed + draw_menu_title_hash(i + overlay_seed) * _gw) mod (_gw + _row.w)) - _row.w
	draw_set_alpha(_row.alpha * _ease)
	draw_line_width(_xx, _yy, _xx + _row.w, _yy + sin(_clock * 3 + i) * 6, 1)
}
gpu_set_blendmode(bm_normal)

draw_set_color(_red)
draw_set_alpha(0.52 * _ease)
draw_text_spaced(36, _gh - 58, "DEATH EVENT", 3, 0.46, 0.46)
draw_menu_title_clean_fit(36, _gh - 38, "T LOCK " + string(round(_locked_t)), 0.40, 0.40, 180)

draw_set_halign(fa_right)
draw_set_color(_soft)
draw_set_alpha(0.42 * _ease)
draw_text_transformed(_gw - 36, _gh - 45, "BASSLINE CRACK", 0.44, 0.44, 0)

draw_menu_title_vignette(_gw, _gh, 0.34 + _ease * 0.16)
draw_menu_title_corner_frame(10, 12, _gw - 10, _gh - 10, 18, _red, (0.42 + _hit * 0.12) * _ease, _clock + 4)

draw_set_alpha(1)
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
gpu_set_blendmode(bm_normal)
