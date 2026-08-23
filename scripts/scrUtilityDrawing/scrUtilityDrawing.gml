function surface_create_clear(w, h, col) {
	var s = surface_create(w, h)
	surface_set_target(s)
	draw_clear(col)
	surface_reset_target()
	return s
}

function surface_create_clear_alpha(w, h, col, a) {
	var s = surface_create(w, h)
	surface_set_target(s)
	draw_clear_alpha(col, a)
	surface_reset_target()
	return s
}

function surface_ensure(surf, w, h) {
	if (surface_exists(surf)) {
		if (surface_get_width(surf) == w && surface_get_height(surf) == h)
			return surf

		surface_free(surf)
	}

	return surface_create(w, h)
}

function time_to_string(time) {
	var sec, mn, hr, str
	sec = floor(argument[0] % 60)
	mn = floor(argument[0] / 60) % 60
	hr = floor(argument[0] / 3600)

	if (log10(hr) >= 1)
		str = string(hr) + " : "
	else
		str = "0" + string(hr) + " : "
	
	if (log10(mn) >= 1)
		str += string(mn) + " : "
	else
		str += "0" + string(mn) + " : "
	
	if (log10(sec) >= 1)
		str += string(sec)
	else
		str += "0" + string(sec)

	return str
}

function draw_sprite_ext_skew(sprite, subimg, _x, _y, scalex, scaley, rot, alpha, skew_kx, skew_ky, skew_sx, skew_sy) {
	var rcos = dcos(rot)
	var rsin = -dsin(rot)
	var x1 = -sprite_get_xoffset(sprite) * scalex
	var x2 = x1 + sprite_get_width(sprite) * scalex
	var y1 = -sprite_get_yoffset(sprite) * scaley
	var y2 = y1 + sprite_get_height(sprite) * scaley

	for (var c = 0; c < 4; c++) {
	    var lx if (c & 1) lx = x2 else lx = x1
	    var ly if (c & 2) ly = y2 else ly = y1
	    var rx = lx * rcos - ly * rsin
	    var ry = lx * rsin + ly * rcos
	    global._draw_sprite_ext_skew_x[c] = _x + (rx + ry * skew_kx) * skew_sx
	    global._draw_sprite_ext_skew_y[c] = _y + (ry + rx * skew_ky) * skew_sy
	}

	draw_sprite_pos(sprite, subimg,
	    global._draw_sprite_ext_skew_x[0],
	    global._draw_sprite_ext_skew_y[0],
	    global._draw_sprite_ext_skew_x[1],
	    global._draw_sprite_ext_skew_y[1],
	    global._draw_sprite_ext_skew_x[3],
	    global._draw_sprite_ext_skew_y[3],
	    global._draw_sprite_ext_skew_x[2],
	    global._draw_sprite_ext_skew_y[2],
	    alpha
	)
}

function draw_text_shadow(xx, yy, str, col, off) {
	var c = draw_get_color()
	draw_set_color(col)
	draw_text(xx + off, yy + off, str)
	draw_set_color(c)
	draw_text(xx, yy, str)
}

function draw_text_outline(xx, yy, str, col, off) {
	var c = draw_get_color()
	draw_set_color(col)
	draw_text(xx + off, yy + off, str)
	draw_text(xx - off, yy + off, str)
	draw_text(xx - off, yy - off, str)
	draw_text(xx + off, yy - off, str)
	draw_set_color(c)
	draw_text(xx, yy, str)
}

function draw_text_array(xx, yy, arr, ysep) {
	var num = array_length(arr)
	for (var i = 0; i < num; i++) {
		draw_text(xx, yy, arr[@i])
		yy += string_height(arr[@i]) + ysep
	}
}

function draw_text_array_shadow(xx, yy, arr, ysep, col, off) {
	var c = draw_get_color()
	draw_set_color(col)
	draw_text_array(xx + off, yy + off, arr, ysep)
	draw_set_color(c)
	draw_text_array(xx, yy, arr, ysep)
}

function draw_set_defaults() {
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_set_alpha(1.0)
}

function draw_sprite_ext_outline(spr, img, xx, yy, xscl, yscl, rot, blend, a, off, oblend) {
	draw_sprite_ext(spr, img, xx + off, yy + off, xscl, yscl, rot, oblend, a)
	draw_sprite_ext(spr, img, xx + off, yy - off, xscl, yscl, rot, oblend, a)
	draw_sprite_ext(spr, img, xx - off, yy + off, xscl, yscl, rot, oblend, a)
	draw_sprite_ext(spr, img, xx - off, yy - off, xscl, yscl, rot, oblend, a)
	draw_sprite_ext(spr, img, xx, yy, xscl, yscl, rot, blend, a)
}

function draw_menu_title_hash(_value) {
	var _n = sin(_value * 12.9898 + 78.233) * 43758.5453
	return _n - floor(_n)
}

function draw_menu_title_segmented_line(_x1, _y1, _x2, _y2, _pieces, _phase, _col, _alpha, _width) {
	var _dx = _x2 - _x1
	var _dy = _y2 - _y1
	var _scan = floor(_phase)

	draw_set_color(_col)

	for (var i = 0; i < _pieces; i++) {
		var _skip = ((i + _scan) mod 7 == 0) || ((i + _scan * 2) mod 11 == 0)
		if (_skip) continue

		var _a = i / _pieces
		var _b = min(1, (i + 0.72) / _pieces)

		draw_set_alpha(_alpha * (0.72 + 0.28 * draw_menu_title_hash(i + _phase * 0.17)))
		draw_line_width(
			_x1 + _dx * _a,
			_y1 + _dy * _a,
			_x1 + _dx * _b,
			_y1 + _dy * _b,
			_width
		)
	}

	draw_set_alpha(1)
}

function draw_menu_title_corner_frame(_x1, _y1, _x2, _y2, _cut, _col, _alpha, _time) {
	gpu_set_blendmode(bm_add)

	draw_menu_title_segmented_line(_x1 + _cut, _y1, _x2 - _cut, _y1, 38, _time * 3, _col, _alpha, 1)
	draw_menu_title_segmented_line(_x2, _y1 + _cut, _x2, _y2 - _cut, 24, _time * 2 + 4, _col, _alpha * 0.82, 1)
	draw_menu_title_segmented_line(_x2 - _cut, _y2, _x1 + _cut, _y2, 38, _time * 3 + 9, _col, _alpha, 1)
	draw_menu_title_segmented_line(_x1, _y2 - _cut, _x1, _y1 + _cut, 24, _time * 2 + 13, _col, _alpha * 0.82, 1)

	draw_set_color(_col)
	draw_set_alpha(_alpha)
	draw_line_width(_x1, _y1 + _cut, _x1 + _cut, _y1, 1)
	draw_line_width(_x2 - _cut, _y1, _x2, _y1 + _cut, 1)
	draw_line_width(_x2, _y2 - _cut, _x2 - _cut, _y2, 1)
	draw_line_width(_x1 + _cut, _y2, _x1, _y2 - _cut, 1)

	draw_set_alpha(_alpha * 0.45)
	draw_line_width(_x1 + 8, _y1 + _cut + 42, _x1 + 8, _y1 + _cut + 72, 1)
	draw_line_width(_x2 - 8, _y1 + _cut + 42, _x2 - 8, _y1 + _cut + 72, 1)
	draw_line_width(_x1 + 8, _y2 - _cut - 72, _x1 + 8, _y2 - _cut - 42, 1)
	draw_line_width(_x2 - 8, _y2 - _cut - 72, _x2 - 8, _y2 - _cut - 42, 1)

	gpu_set_blendmode(bm_normal)
	draw_set_alpha(1)
}

function draw_menu_title_waveform(_x1, _x2, _y, _amp, _samples, _col, _alpha, _time, _seed) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	draw_set_alpha(_alpha * 0.22)
	draw_line_width(_x1, _y, _x2, _y, 1)

	for (var i = 0; i < _samples; i++) {
		var _p = i / max(1, _samples - 1)
		var _x = lerp(_x1, _x2, _p)
		var _beat = power(max(0, sin(_time * 4.4 + _seed)), 5)
		var _tone = abs(sin(i * 1.81 + _time * 6.2 + _seed))
		var _grain = abs(sin(i * 0.47 - _time * 2.1 + _seed * 2.0))
		var _height = _amp * (0.12 + _tone * 0.36 + _grain * 0.18 + _beat * draw_menu_title_hash(i + _seed) * 0.7)

		if (i mod 17 == floor((_time * 16 + _seed) mod 17)) {
			_height *= 1.85
		}

		draw_set_alpha(_alpha * (0.28 + _height / max(1, _amp) * 0.75))
		draw_line_width(_x, _y - _height, _x, _y + _height, 1)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_vertical_analyzer(_x, _y1, _y2, _col, _alpha, _time) {
	gpu_set_blendmode(bm_add)

	draw_set_color(_col)
	draw_set_alpha(_alpha * 0.24)
	draw_line_width(_x, _y1, _x, _y2, 1)

	var _steps = 84
	var _scan_y = lerp(_y1, _y2, 0.5 + 0.5 * sin(_time * 0.9))

	for (var i = 0; i < _steps; i++) {
		var _p = i / max(1, _steps - 1)
		var _y = lerp(_y1, _y2, _p)
		var _scan = max(0, 1 - abs(_y - _scan_y) / 56)
		var _wave = abs(sin(i * 0.82 + _time * 5.5)) * abs(sin(i * 0.19 - _time * 2.0))
		var _w = 4 + _wave * 20 + _scan * 36

		if (i mod 9 == 0) {
			draw_set_alpha(_alpha * 0.62)
			draw_line_width(_x - _w * 1.45, _y, _x + _w * 1.45, _y, 1)
		} else {
			draw_set_alpha(_alpha * (0.16 + _wave * 0.34 + _scan * 0.55))
			draw_line_width(_x - _w, _y, _x + _w, _y, 1)
		}
	}

	var _flare = 0.55 + 0.45 * sin(_time * 5.0)
	draw_set_alpha(_alpha * 0.6)
	draw_circle(_x, _scan_y, 4 + _flare * 3, false)
	draw_set_alpha(_alpha * 0.22)
	draw_circle(_x, _scan_y, 16 + _flare * 10, false)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_crack_field(_cx, _cy, _scale, _col, _alpha, _time) {
	gpu_set_blendmode(bm_add)

	var _spark = 0.65 + 0.35 * sin(_time * 5.2)

	draw_set_color(_col)
	draw_set_alpha(_alpha * 0.18)
	draw_circle(_cx, _cy, 42 * _scale, false)

	for (var i = 0; i < 28; i++) {
		var _h = draw_menu_title_hash(i * 19 + 2)
		var _ang = i * 137.5 + draw_menu_title_hash(i + 11) * 28 + sin(_time * 0.55 + i) * 2.0
		var _len = (54 + _h * 270) * _scale
		var _start = (7 + draw_menu_title_hash(i + 41) * 26) * _scale
		var _x1 = _cx + lengthdir_x(_start, _ang)
		var _y1 = _cy + lengthdir_y(_start, _ang)
		var _x2 = _cx + lengthdir_x(_len, _ang)
		var _y2 = _cy + lengthdir_y(_len, _ang)
		var _line_alpha = _alpha * (0.12 + _h * 0.46)

		draw_set_color(_col)
		draw_set_alpha(_line_alpha * 0.42)
		draw_line_width(_x1, _y1, _x2, _y2, 3)
		draw_set_alpha(_line_alpha)
		draw_line_width(_x1, _y1, _x2, _y2, 1)

		if (i mod 4 == 0) {
			var _bp = 0.35 + draw_menu_title_hash(i + 70) * 0.45
			var _bx = lerp(_x1, _x2, _bp)
			var _by = lerp(_y1, _y2, _bp)
			var _ba = _ang + 38 + draw_menu_title_hash(i + 90) * 65
			var _bl = _len * (0.12 + draw_menu_title_hash(i + 120) * 0.18)

			draw_set_alpha(_line_alpha * 0.72)
			draw_line_width(_bx, _by, _bx + lengthdir_x(_bl, _ba), _by + lengthdir_y(_bl, _ba), 1)
		}
	}

	draw_set_color(c_white)
	draw_set_alpha(_alpha * (0.25 + _spark * 0.35))
	draw_line_width(_cx - 20 * _scale, _cy, _cx + 20 * _scale, _cy, 1)
	draw_line_width(_cx, _cy - 20 * _scale, _cx, _cy + 20 * _scale, 1)
	draw_circle(_cx, _cy, 3 + _spark * 2, false)

	gpu_set_blendmode(bm_normal)
	draw_set_alpha(1)
}

function draw_menu_title_album_burst(_x, _y, _size, _col, _time) {
	var _cx = _x + _size * 0.5
	var _cy = _y + _size * 0.5

	draw_set_color(make_color_rgb(8, 8, 8))
	draw_set_alpha(0.96)
	draw_rectangle(_x, _y, _x + _size, _y + _size, false)

	for (var i = 0; i < 46; i++) {
		var _a1 = i * (360 / 46) + sin(_time * 0.6 + i) * 1.5
		var _a2 = (i + 1.2) * (360 / 46) + sin(_time * 0.45 + i * 0.7) * 1.2
		var _inner = _size * (0.12 + draw_menu_title_hash(i + 6) * 0.13)
		var _outer = _size * (0.27 + draw_menu_title_hash(i + 22) * 0.25)
		var _shade = draw_menu_title_hash(i + 100)
		var _grey = make_color_rgb(28 + floor(_shade * 100), 24 + floor(_shade * 82), 22 + floor(_shade * 72))

		draw_set_color(merge_color(_grey, _col, (i mod 6 == 0) ? 0.42 : 0.08))
		draw_set_alpha(0.24 + _shade * 0.28)
		draw_triangle(
			_cx + lengthdir_x(_inner, (_a1 + _a2) * 0.5),
			_cy + lengthdir_y(_inner, (_a1 + _a2) * 0.5),
			_cx + lengthdir_x(_outer, _a1),
			_cy + lengthdir_y(_outer, _a1),
			_cx + lengthdir_x(_outer, _a2),
			_cy + lengthdir_y(_outer, _a2),
			false
		)
	}

	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 22; i++) {
		var _ang = i * 137.5 + draw_menu_title_hash(i + 301) * 32
		var _len = _size * (0.18 + draw_menu_title_hash(i + 401) * 0.46)
		var _sx = _cx + lengthdir_x(_size * 0.11, _ang)
		var _sy = _cy + lengthdir_y(_size * 0.11, _ang)
		var _ex = _cx + lengthdir_x(_len, _ang)
		var _ey = _cy + lengthdir_y(_len, _ang)

		draw_set_alpha(0.24 + draw_menu_title_hash(i + 501) * 0.36)
		draw_line_width(_sx, _sy, _ex, _ey, 1)
	}

	var _pulse = 0.75 + 0.25 * sin(_time * 4.0)
	draw_set_alpha(0.35)
	draw_circle(_cx, _cy, _size * 0.18 * _pulse, false)
	draw_set_alpha(0.72)
	draw_circle(_cx, _cy, _size * 0.13, true)
	draw_circle(_cx, _cy, _size * 0.22, true)
	draw_circle(_cx, _cy, _size * 0.31, true)

	draw_set_font(fMenu)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_set_color(merge_color(_col, c_white, 0.12))
	draw_set_alpha(0.86)
	draw_text_transformed(_cx, _cy + 2, "G", 1.8, 1.8, 0)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_panel(_x, _y, _w, _h, _col, _time) {
	draw_set_color(make_color_rgb(5, 5, 5))
	draw_set_alpha(0.76)
	draw_rectangle(_x, _y, _x + _w, _y + _h, false)

	draw_set_color(_col)
	draw_set_alpha(0.08)
	draw_rectangle(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, false)

	draw_menu_title_corner_frame(_x, _y, _x + _w, _y + _h, 10, _col, 0.86, _time)
	draw_menu_title_corner_frame(_x + 12, _y + 64, _x + _w - 12, _y + _h - 40, 6, _col, 0.34, _time + 5)

	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)

	draw_set_color(_col)
	draw_set_alpha(0.88)
	var _plus_l = _x + 28
	var _plus_r = _x + _w - 28
	var _header_cx = (_plus_l + _plus_r) * 0.5
	var _plus_w = string_width("+")
	draw_menu_title_spaced_center_fit(_header_cx, _y + 24, "TRACK INFORMATION", 4, 0.6, 0.6, _plus_r - _plus_l - 32)
	draw_text(_plus_l - _plus_w * 0.5, _y + 22, "+")
	draw_text(_plus_r - _plus_w * 0.5, _y + 22, "+")

	var _art = _w - 70
	var _art_x = _x + (_w - _art) * 0.5
	var _art_y = _y + 78

	draw_set_color(_col)
	draw_set_alpha(0.55)
	draw_rectangle(_art_x - 1, _art_y - 1, _art_x + _art + 1, _art_y + _art + 1, true)
	draw_menu_title_album_burst(_art_x, _art_y, _art, _col, _time)

	var _info_y = _art_y + _art + 22
	draw_set_alpha(1)
	draw_set_color(_col)
	draw_text_spaced(_x + 34, _info_y, "TRACK", 4, 0.55, 0.55)
	draw_set_color(c_white)
	draw_menu_title_spaced_fit(_x + 34, _info_y + 19, "BASSLINE CRACK", 5, 0.68, 0.68, _w - 68)

	draw_set_color(_col)
	draw_set_alpha(0.28)
	draw_line(_x + 24, _info_y + 50, _x + _w - 24, _info_y + 50)

	draw_set_alpha(1)
	draw_text_spaced(_x + 34, _info_y + 60, "ARTIST", 4, 0.55, 0.55)
	draw_set_color(c_white)
	draw_menu_title_spaced_fit(_x + 34, _info_y + 78, "GETTY", 7, 0.68, 0.68, _w - 68)

	draw_set_color(_col)
	draw_set_alpha(0.28)
	draw_line(_x + 24, _info_y + 108, _x + _w - 24, _info_y + 108)
	draw_menu_title_waveform(_x + 40, _x + _w - 40, _info_y + 126, 7, 86, _col, 0.72, _time, 4.8)

	draw_set_alpha(0.92)
	draw_set_color(_col)
	draw_text(_x + 24, _y + _h - 34, "*")
	draw_menu_title_clean_center_fit(_x + _w * 0.5, _y + _h - 31, "THANK YOU FOR PLAYING", 0.5, 0.5, _w - 62, 0.72)
	draw_text(_x + _w - 31, _y + _h - 34, "*")

	draw_set_alpha(1)
}

function draw_menu_title_icon_row(_x, _y, _gap, _col, _time) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 4; i++) {
		var _cx = _x + i * _gap
		var _pulse = 0.55 + 0.45 * sin(_time * 2.0 + i * 1.8)
		draw_set_alpha(0.48 + _pulse * 0.22)

		switch (i) {
			case 0:
				draw_circle(_cx, _y, 7, true)
				draw_line(_cx - 7, _y, _cx + 7, _y)
				draw_line(_cx, _y - 7, _cx, _y + 7)
				draw_circle(_cx, _y, 3, true)
			break

			case 1:
				draw_triangle(_cx, _y - 8, _cx - 8, _y + 7, _cx + 8, _y + 7, true)
				draw_line(_cx, _y - 3, _cx, _y + 3)
				draw_circle(_cx, _y + 5, 1, false)
			break

			case 2:
				draw_circle(_cx, _y, 7, true)
				draw_line(_cx - 9, _y - 9, _cx + 9, _y + 9)
				draw_line(_cx - 5, _y, _cx + 5, _y)
				draw_line(_cx, _y - 5, _cx, _y + 5)
			break

			case 3:
				draw_circle(_cx, _y, 7, true)
				draw_circle(_cx, _y, 3, true)
				draw_line(_cx - 9, _y - 9, _cx + 9, _y + 9)
				draw_line(_cx - 9, _y + 9, _cx + 9, _y - 9)
			break
		}
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_logo(_x, _y, _scale, _alpha, _time) {
	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)

	var _red = make_color_rgb(228, 28, 24)
	var _stone = make_color_rgb(190, 178, 166)

	gpu_set_blendmode(bm_add)

	for (var ox = -1; ox <= 1; ox++) {
		for (var oy = -1; oy <= 1; oy++) {
			draw_set_color(_red)
			draw_set_alpha(_alpha * 0.23)
			draw_text_transformed(_x + ox, _y + oy, "BASSLINE", _scale, _scale, 0)
			draw_set_color(_stone)
			draw_text_transformed(_x + ox, _y + 108 * _scale / 3.8 + oy, "CRACK", _scale * 1.12, _scale * 1.12, 0)
		}
	}

	draw_set_alpha(_alpha * 0.38)
	draw_set_color(_red)
	draw_text_transformed(_x, _y, "BASSLINE", _scale, _scale, 0)
	draw_set_color(_stone)
	draw_text_transformed(_x, _y + 108 * _scale / 3.8, "CRACK", _scale * 1.12, _scale * 1.12, 0)

	gpu_set_blendmode(bm_normal)

	draw_set_color(c_black)
	for (var i = 0; i < 22; i++) {
		var _yy = _y + draw_menu_title_hash(i + 11) * 220 * _scale / 3.8
		var _x1 = _x + draw_menu_title_hash(i + 31) * 350 * _scale / 3.8
		var _x2 = _x1 + (24 + draw_menu_title_hash(i + 41) * 82) * _scale / 3.8
		draw_set_alpha(_alpha * (0.24 + draw_menu_title_hash(i + 2) * 0.5))
		draw_line_width(_x1, _yy, _x2, _yy + sin(i) * 12, 2)
	}

	draw_set_alpha(1)
	draw_set_color(c_white)
}

function draw_menu_title_glow_line(_x1, _y1, _x2, _y2, _col, _alpha, _width) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	draw_set_alpha(_alpha * 0.12)
	draw_line_width(_x1, _y1, _x2, _y2, max(1, _width * 6))
	draw_set_alpha(_alpha * 0.32)
	draw_line_width(_x1, _y1, _x2, _y2, max(1, _width * 3))
	draw_set_alpha(_alpha)
	draw_line_width(_x1, _y1, _x2, _y2, max(1, _width))

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_scanlines(_w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)

	for (var _scan_y = 0; _scan_y < _h; _scan_y += 3) {
		var _crawl = 0.5 + 0.5 * sin(_time * 9 + _scan_y * 0.035)
		draw_set_color((_scan_y mod 12 == 0) ? _col : c_black)
		draw_set_alpha(_alpha * ((_scan_y mod 12 == 0) ? 0.035 + _crawl * 0.02 : 0.055))
		draw_rectangle(0, _scan_y, _w, _scan_y + 1, false)
	}

	var _bar_y = (_time * 42) mod (_h + 90) - 45
	draw_set_color(_col)
	draw_set_alpha(_alpha * 0.10)
	draw_rectangle(0, _bar_y - 7, _w, _bar_y + 7, false)
	draw_set_alpha(_alpha * 0.18)
	draw_line_width(0, _bar_y, _w, _bar_y, 1)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_dust(_w, _h, _col, _time, _alpha, _count) {
	gpu_set_blendmode(bm_add)

	for (var i = 0; i < _count; i++) {
		var _seed = i * 17
		var _x = (draw_menu_title_hash(_seed + 2) * _w + _time * (4 + draw_menu_title_hash(_seed + 3) * 18)) mod _w
		var _y = (draw_menu_title_hash(_seed + 7) * _h + sin(_time * 0.5 + i) * 6) mod _h
		var _hot = ((i mod 13) == (floor(_time * 9 + i) mod 13))
		var _size = _hot ? 2 : 1

		draw_set_color(_hot ? _col : make_color_rgb(120, 42, 38))
		draw_set_alpha(_alpha * (_hot ? 0.16 : 0.035 + draw_menu_title_hash(_seed + 11) * 0.055))
		draw_rectangle(_x, _y, _x + _size, _y + _size, false)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_floor_grid(_cx, _horizon, _w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 18; i++) {
		var _p = i / 17
		var _e = power(_p, 2.15)
		var _y = lerp(_horizon, _h + 18, _e)
		var _a = _alpha * (0.12 + _p * 0.19)

		if ((i mod 4) == (floor(_time * 3) mod 4)) _a *= 1.9

		draw_set_alpha(_a)
		draw_line_width(0, _y, _w, _y, 1)
	}

	for (var i = -12; i <= 12; i++) {
		var _spread = i / 12
		var _x2 = _cx + _spread * _w * 0.78
		var _x1 = _cx + _spread * 26
		draw_set_alpha(_alpha * (0.08 + abs(_spread) * 0.08))
		draw_line_width(_x1, _horizon, _x2, _h + 20, 1)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_signal_lattice(_w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)

	for (var i = 0; i < 46; i++) {
		var _seed = i * 29
		var _x1 = draw_menu_title_hash(_seed + 1) * _w
		var _y1 = draw_menu_title_hash(_seed + 2) * _h
		var _x2 = _x1 + lengthdir_x(60 + draw_menu_title_hash(_seed + 3) * 330, draw_menu_title_hash(_seed + 4) * 360)
		var _y2 = _y1 + lengthdir_y(60 + draw_menu_title_hash(_seed + 5) * 210, draw_menu_title_hash(_seed + 6) * 360)
		var _wake = max(0, 1 - abs(((i / 46 + _time * 0.06) mod 1) - 0.5) * 2)

		draw_set_color((i mod 10 == 0) ? c_white : _col)
		draw_set_alpha(_alpha * (0.035 + draw_menu_title_hash(_seed + 9) * 0.075 + _wake * 0.12))
		draw_line_width(_x1, _y1, _x2, _y2, (i mod 10 == 0) ? 2 : 1)

		if (i mod 6 == 0) {
			draw_set_alpha(_alpha * (0.08 + _wake * 0.18))
			draw_rectangle(_x1 - 2, _y1 - 2, _x1 + 2, _y1 + 2, true)
		}
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_shock_rings(_cx, _cy, _col, _time, _alpha, _size) {
	gpu_set_blendmode(bm_add)

	for (var i = 0; i < 9; i++) {
		var _p = ((i / 9) + _time * 0.18) mod 1
		var _r = _size * power(_p, 1.4)
		var _a = _alpha * power(1 - _p, 1.8) * 0.35

		draw_set_color((i mod 3 == 0) ? c_white : _col)
		draw_set_alpha(_a)
		draw_circle(_cx, _cy, _r, true)

		if (i mod 2 == 0) {
			draw_set_alpha(_a * 0.45)
			draw_circle(_cx, _cy, _r + 5, true)
		}
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_bass_columns(_x, _y, _w, _h, _col, _time, _alpha, _count, _seed) {
	gpu_set_blendmode(bm_add)

	for (var i = 0; i < _count; i++) {
		var _p = i / max(1, _count - 1)
		var _x1 = _x + _p * _w
		var _beat = power(max(0, sin(_time * 3.1 + _seed)), 8)
		var _tone = abs(sin(i * 0.74 + _time * 5.0 + _seed))
		var _grain = draw_menu_title_hash(i + floor(_time * 11) + _seed)
		var _bar = _h * (0.08 + _tone * 0.32 + _grain * 0.18 + _beat * 0.55)
		var _hot = ((i mod 11) == (floor(_time * 18 + _seed) mod 11))

		draw_set_color(_hot ? c_white : _col)
		draw_set_alpha(_alpha * (_hot ? 0.66 : 0.18 + _bar / max(1, _h) * 0.42))
		draw_rectangle(_x1, _y + _h - _bar, _x1 + max(1, _w / _count * 0.36), _y + _h, false)

		draw_set_color(_col)
		draw_set_alpha(_alpha * 0.09)
		draw_rectangle(_x1, _y, _x1 + 1, _y + _h, false)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_scope(_cx, _cy, _r, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 5; i++) {
		draw_set_alpha(_alpha * (0.09 + i * 0.035))
		draw_circle(_cx, _cy, _r * (0.28 + i * 0.18), true)
	}

	var _sweep = _time * 42
	for (var i = 0; i < 9; i++) {
		var _ang = _sweep - i * 4
		draw_set_alpha(_alpha * (0.22 - i * 0.018))
		draw_line_width(_cx, _cy, _cx + lengthdir_x(_r, _ang), _cy + lengthdir_y(_r, _ang), 1)
	}

	draw_set_alpha(_alpha * 0.34)
	draw_line_width(_cx - _r, _cy, _cx + _r, _cy, 1)
	draw_line_width(_cx, _cy - _r, _cx, _cy + _r, 1)
	draw_set_alpha(_alpha * 0.8)
	draw_rectangle(_cx - 3, _cy - 3, _cx + 3, _cy + 3, false)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_title_underlay(_cx, _cy, _w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)

	draw_set_color(_col)
	for (var i = 0; i < 24; i++) {
		var _p = i / 23
		var _y = _cy - _h * 0.5 + _p * _h
		var _offset = sin(_time * 2.0 + i * 0.72) * 14
		var _a = _alpha * (0.025 + draw_menu_title_hash(i + 23) * 0.05)

		draw_set_alpha(_a)
		draw_line_width(_cx - _w * 0.5 + _offset, _y, _cx + _w * 0.5 + _offset * 0.3, _y + sin(i) * 7, 2)
	}

	draw_set_alpha(_alpha * 0.18)
	draw_rectangle(_cx - _w * 0.5, _cy - _h * 0.5, _cx + _w * 0.5, _cy + _h * 0.5, true)
	draw_set_alpha(_alpha * 0.08)
	draw_rectangle(_cx - _w * 0.5 - 12, _cy - _h * 0.5 - 8, _cx + _w * 0.5 + 12, _cy + _h * 0.5 + 8, true)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_crisp_logo(_cx, _y, _max_width, _alpha, _time, _exit) {
	var _red = make_color_rgb(236, 28, 24)
	var _stone = make_color_rgb(218, 203, 188)
	var _bass = "BASSLINE"
	var _crack = "CRACK"

	draw_set_font(fAvoidance)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)

	var _bass_scale = min(1.08, _max_width / max(1, string_width(_bass)))
	var _crack_scale = min(1.18, (_max_width * 0.76) / max(1, string_width(_crack)))
	var _crack_y = _y + string_height(_bass) * _bass_scale * 0.68
	var _bass_jitter = sin(_time * 19) * _exit * 13
	var _crack_jitter = -sin(_time * 22) * _exit * 16

	gpu_set_blendmode(bm_add)
	for (var pass = 0; pass < 4; pass++) {
		var _spread = pass * 2
		draw_set_color(pass == 0 ? c_white : _red)
		draw_set_alpha(_alpha * (0.06 + pass * 0.045))
		draw_text_transformed(_cx + _bass_jitter + sin(_time * 8 + pass) * _spread, _y - pass, _bass, _bass_scale + pass * 0.012, _bass_scale, 0)
		draw_set_color(pass == 0 ? c_white : _stone)
		draw_set_alpha(_alpha * (0.05 + pass * 0.035))
		draw_text_transformed(_cx + _crack_jitter - sin(_time * 7 + pass) * _spread, _crack_y + pass, _crack, _crack_scale + pass * 0.010, _crack_scale, 0)
	}
	gpu_set_blendmode(bm_normal)

	draw_set_color(_red)
	draw_set_alpha(_alpha * 0.96)
	draw_text_transformed(_cx + _bass_jitter, _y, _bass, _bass_scale, _bass_scale, 0)

	draw_set_color(_stone)
	draw_set_alpha(_alpha * 0.94)
	draw_text_transformed(_cx + _crack_jitter, _crack_y, _crack, _crack_scale, _crack_scale, 0)

	draw_set_color(c_black)
	for (var i = 0; i < 34; i++) {
		var _seed = i * 23
		var _on_crack = ((i mod 2) == 0)
		var _yy = _y + draw_menu_title_hash(_seed + 2) * string_height(_bass) * _bass_scale
		if (_on_crack) {
			_yy = _crack_y + draw_menu_title_hash(_seed + 1) * string_height(_crack) * _crack_scale
		}
		var _ww = (42 + draw_menu_title_hash(_seed + 3) * 148) * (_on_crack ? _crack_scale : _bass_scale)
		var _xx = _cx - _max_width * 0.45 + draw_menu_title_hash(_seed + 4) * _max_width * 0.9

		draw_set_alpha(_alpha * (0.12 + draw_menu_title_hash(_seed + 5) * 0.25))
		draw_rectangle(_xx - _ww * 0.5, _yy, _xx + _ww * 0.5, _yy + 2 + draw_menu_title_hash(_seed + 6) * 3, false)
	}

	gpu_set_blendmode(bm_add)
	draw_set_color(_red)
	for (var i = 0; i < 10; i++) {
		var _slice_y = _y + draw_menu_title_hash(300 + i) * (_crack_y - _y + string_height(_crack) * _crack_scale)
		draw_set_alpha(_alpha * (0.05 + draw_menu_title_hash(500 + i) * 0.11))
		draw_line_width(_cx - _max_width * 0.47, _slice_y, _cx + _max_width * 0.47, _slice_y + sin(i) * 6, 1)
	}
	gpu_set_blendmode(bm_normal)

	draw_set_alpha(1)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
}

function draw_menu_title_menu_shell(_x, _y, _w, _h, _title, _menu_index, _option_index, _rows, _reveal, _flash) {
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 22, 18)
	var _dark = make_color_rgb(5, 5, 5)
	var _r = clamp(_reveal, 0, 1)
	var _open_w = _w * max(0.08, _r)
	var _right = _x + _open_w
	var _pulse = 0.55 + 0.45 * sin(_time * 4.4)

	draw_set_color(_dark)
	draw_set_alpha(0.86 * _r)
	draw_rectangle(_x, _y, _right, _y + _h, false)

	gpu_set_blendmode(bm_add)
	draw_set_color(_red)
	draw_set_alpha((0.10 + _flash * 0.16) * _r)
	draw_rectangle(_x + 2, _y + 2, _right - 2, _y + _h - 2, false)
	gpu_set_blendmode(bm_normal)

	draw_menu_title_corner_frame(_x, _y, _x + _w, _y + _h, 12, _red, (0.55 + _flash * 0.28) * _r, _time)

	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(_red)
	draw_set_alpha((0.78 + _pulse * 0.15) * _r)
	draw_menu_title_spaced_fit(_x + 28, _y + 20, _title, 5, 0.72, 0.72, _w - 76)

	draw_set_alpha(0.34 * _r)
	draw_menu_title_clean_fit(_x + 28, _y + 43, "INDEX  " + string(_menu_index) + ":" + string(_option_index), 0.46, 0.46, _w - 90, 0.7)
	draw_menu_title_waveform(_x + 26, _x + _w - 26, _y + 67, 4 + _flash * 7, 74, _red, 0.55 * _r, _time, 14.4 + _menu_index)

	draw_menu_title_bass_columns(_x + _w - 45, _y + 86, 18, max(44, _h - 150), _red, _time, 0.52 * _r, 10, 8 + _menu_index)

	draw_set_alpha(1)
	draw_set_color(c_white)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_menu_option(_x, _y, _text, _selected, _disabled, _row, _flash, _reveal = 1, _text_scale = 1, _text_spacing = 10, _max_width = 330) {
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 38, 32)
	var _soft = make_color_rgb(180, 156, 145)
	var _fit = draw_menu_title_spaced_fit_data(_text, _text_spacing, _text_scale, _max_width, 1, 0.48)
	var _spacing = _fit[0]
	var _scale = _fit[1]
	var _tw = _fit[2]
	var _w = _tw + 128
	var _jit = _selected ? sin(_time * 32) * (1 + _flash * 3) : 0
	var _r = clamp(_reveal, 0, 1)
	var _slide = (1 - _r) * -18
	var _text_h = string_height(_text) * _scale

	if (_selected && _r > 0.18) {
		draw_menu_highlight(_x + _slide - 3, _y - 12, min(_w, _max_width + 100), _text_h + 25)
		gpu_set_blendmode(bm_add)
		draw_set_color(_red)
		draw_set_alpha((0.20 + _flash * 0.16) * _r)
		draw_rectangle(_x + _slide - 72, _y - 10, _x + _slide + min(_w, _max_width + 100) - 16, _y + _text_h + 13, true)
		draw_set_alpha((0.42 + _flash * 0.18) * _r)
		draw_line_width(_x + _slide - 52, _y + 5, _x + _slide - 24, _y + 5, 1)
		draw_line_width(_x + _slide + _tw + 28, _y + 5, _x + _slide + _tw + 68, _y + 5, 1)
		gpu_set_blendmode(bm_normal)
	}

	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)

	draw_set_color(_red)
	draw_set_alpha((_selected ? 0.28 : 0.11) * _r)
	draw_text_spaced(_x + _slide + _jit + 2, _y + 2, _text, _spacing, _scale, _scale)

	draw_set_color(_disabled ? make_color_rgb(92, 74, 70) : (_selected ? c_white : _soft))
	draw_set_alpha((_disabled ? 0.42 : (_selected ? 1 : 0.72)) * _r)
	draw_text_spaced(_x + _slide + _jit, _y, _text, _spacing, _scale, _scale)

	if (_selected && _r > 0.18) {
		gpu_set_blendmode(bm_add)
		draw_set_color(_red)
		for (var i = 0; i < 7; i++) {
			var _slice_y = _y + draw_menu_title_hash(_row * 31 + i) * string_height(_text)
			var _slice_x = _x + _slide + draw_menu_title_hash(_row * 61 + i) * max(1, _tw)
			draw_set_alpha((0.08 + _flash * 0.12) * draw_menu_title_hash(_row * 19 + i) * _r)
			draw_rectangle(_slice_x, _slice_y, _slice_x + 24 + draw_menu_title_hash(i + 6) * 70, _slice_y + 1, false)
		}
		gpu_set_blendmode(bm_normal)
	}

	draw_set_alpha(1)
	draw_set_color(c_white)
}

function draw_menu_title_menu_value(_x, _y, _text, _selected, _row, _flash, _reveal = 1, _text_scale = 1, _text_spacing = 10, _max_width = 150) {
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 36, 30)
	var _fit = draw_menu_title_spaced_fit_data(_text, _text_spacing, _text_scale, _max_width, 1, 0.48)
	var _spacing = _fit[0]
	var _scale = _fit[1]
	var _tw = _fit[2]
	var _jit = _selected ? cos(_time * 28 + _row) * (1 + _flash * 2) : 0
	var _r = clamp(_reveal, 0, 1)
	var _slide = (1 - _r) * 18

	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(_selected ? _red : make_color_rgb(215, 204, 194))
	draw_set_alpha((_selected ? 0.96 : 0.62) * _r)
	draw_text_spaced(_x + _slide + _jit, _y, _text, _spacing, _scale, _scale)

	if (_selected && _r > 0.18) {
		gpu_set_blendmode(bm_add)
		draw_set_color(_red)
		draw_set_alpha((0.24 + _flash * 0.16) * _r)
		draw_line_width(_x + _slide - 12, _y + string_height(_text) * _scale + 11, _x + _slide + min(_max_width, _tw + 32), _y + string_height(_text) * _scale + 11, 1)
		gpu_set_blendmode(bm_normal)
	}

	draw_set_alpha(1)
	draw_set_color(c_white)
}

function draw_menu_title_save_focus(_x, _y, _slot_text, _deaths_text, _time_text, _flash) {
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 28, 22)
	var _w = 330
	var _h = 250

	draw_set_color(make_color_rgb(5, 5, 5))
	draw_set_alpha(0.80)
	draw_rectangle(_x - _w * 0.5, _y - 46, _x + _w * 0.5, _y + _h - 46, false)
	draw_menu_title_corner_frame(_x - _w * 0.5, _y - 46, _x + _w * 0.5, _y + _h - 46, 10, _red, 0.68 + _flash * 0.18, _time)

	draw_menu_title_scope(_x, _y + 34, 70 + _flash * 12, _red, _time, 0.58)
	draw_menu_title_waveform(_x - 118, _x + 118, _y + 122, 8 + _flash * 8, 90, _red, 0.72, _time, 17.7)

	draw_set_font(fMenu)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_set_alpha(0.96)
	draw_menu_title_spaced_center(_x, _y, _slot_text, 10, 1, 1)
	draw_set_color(make_color_rgb(210, 190, 176))
	draw_set_alpha(0.70)
	draw_menu_title_spaced_center(_x, _y + 78, _deaths_text, 5, 0.72, 0.72)
	draw_menu_title_spaced_center(_x, _y + 106, _time_text, 5, 0.72, 0.72)

	gpu_set_blendmode(bm_add)
	draw_set_color(_red)
	draw_set_alpha(0.5 + _flash * 0.24)
	draw_line_width(_x - 12, _y - 38, _x, _y - 52, 1)
	draw_line_width(_x, _y - 52, _x + 12, _y - 38, 1)
	draw_line_width(_x - 12, _y + 168, _x, _y + 182, 1)
	draw_line_width(_x, _y + 182, _x + 12, _y + 168, 1)
	gpu_set_blendmode(bm_normal)

	draw_set_alpha(1)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
}

function draw_menu_title_background(_show_logo = true, _menu_index = 0, _option_index = 0, _flash = 0, _reveal = 1) {
	var _w = room_width
	var _h = room_height
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 22, 18)
	var _deep_red = make_color_rgb(86, 6, 4)
	var _show = clamp(_reveal, 0, 1)
	var _hit = clamp(_flash, 0, 1.4)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_black)
	draw_set_alpha(1)
	draw_rectangle(0, 0, _w, _h, false)

	draw_set_color(make_color_rgb(18, 10, 9))
	draw_set_alpha(0.35)
	draw_rectangle(0, 0, _w, _h, false)

	draw_menu_title_dust(_w, _h, _red, _time, 0.92, 175)
	draw_menu_title_floor_grid(_w * 0.49, _h * 0.52, _w, _h, _red, _time, 0.28 + _hit * 0.08)
	draw_menu_title_signal_lattice(_w, _h, _deep_red, _time, 0.90)
	draw_menu_title_shock_rings(_w * 0.57, _h * 0.34, _red, _time, 0.55 + _hit * 0.2, 330)

	draw_menu_title_corner_frame(9, 13, _w - 9, _h - 12, 15, _red, 0.78 + _hit * 0.18, _time)

	gpu_set_blendmode(bm_add)
	draw_set_color(_deep_red)
	draw_set_alpha(0.18)
	draw_line_width(82, 50, 446, 200, 1)
	draw_line_width(132, 572, 462, 488, 1)
	draw_line_width(278, 0, 512, 238, 1)
	draw_line_width(322, 420, 680, 530, 1)
	gpu_set_blendmode(bm_normal)

	draw_menu_title_crack_field(_w * 0.56, _h * 0.33, 0.94, _red, 0.68 + _hit * 0.12, _time)
	draw_menu_title_orbit_core(_w * 0.56, _h * 0.33, 72 + _hit * 12, _red, _time, 0.32 + _hit * 0.14)
	draw_menu_title_vertical_analyzer(_w * 0.64, _h * 0.27, _h * 0.86, _red, 0.54 + _hit * 0.12, _time)

	if (_show_logo) {
		draw_menu_title_title_underlay(246, 295, 350, 220, _red, _time, 0.18 * _show)
		draw_menu_title_scope(246, 297, 92 + _hit * 6, _red, _time, 0.22 * _show)
		draw_menu_title_waveform(118, 364, 471, 11 + _hit * 6, 116, _red, 0.52 * _show, _time, 2.2)

		draw_set_font(fMenu)
	}

	draw_set_font(fMenu)
	draw_set_color(_red)
	draw_set_alpha(0.78 + _hit * 0.1)
	draw_text_spaced(28, 66, "BC--00:00", 2, 0.48, 0.48)
	draw_text_spaced(28, 83, "// SYSTEM READY", 2, 0.48, 0.48)
	draw_menu_title_waveform(28, 104, 113, 4, 24, _red, 0.55, _time, 7.3)

	draw_menu_title_icon_row(130, 560, 70, _red, _time)
	draw_menu_title_waveform(286, 390, 586, 3, 40, _red, 0.38, _time, 9.1)
	draw_set_color(_red)
	draw_set_alpha(0.54)
	draw_menu_title_clean_fit(424, 585, "MENU " + string(_menu_index) + "   OPTION " + string(_option_index), 0.38, 0.38, 210, 0.72)

	draw_menu_title_panel(520, 72, 242, 470, _red, _time)
	draw_menu_title_scanlines(_w, _h, _red, _time, 0.52)
	draw_menu_title_vignette(_w, _h, 0.28)

	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_spaced_width(_text, _spacing, _xscale) {
	var _w = 0

	for (var i = 1; i <= string_length(_text); i++) {
		_w += string_width(string_char_at(_text, i)) * _xscale
		if (i < string_length(_text)) _w += _spacing
	}

	return _w
}

function draw_menu_title_spaced_fit_data(_text, _spacing, _xscale, _max_width, _min_spacing = 1, _min_scale = 0.45) {
	var _gaps = max(0, string_length(_text) - 1)
	var _fit_spacing = _spacing
	var _fit_scale = _xscale
	var _width = draw_menu_title_spaced_width(_text, _fit_spacing, _fit_scale)

	if (_width > _max_width && _gaps > 0) {
		var _base_width = string_width(_text) * _fit_scale
		_fit_spacing = max(_min_spacing, min(_spacing, (_max_width - _base_width) / _gaps))
		_width = draw_menu_title_spaced_width(_text, _fit_spacing, _fit_scale)
	}

	if (_width > _max_width) {
		var _ratio = max(_min_scale, _max_width / max(1, _width))
		_fit_scale *= _ratio
		_fit_spacing *= _ratio
		_width = draw_menu_title_spaced_width(_text, _fit_spacing, _fit_scale)

		if (_width > _max_width) {
			var _hard_ratio = _max_width / max(1, _width)
			_fit_scale *= _hard_ratio
			_fit_spacing *= _hard_ratio
			_width = draw_menu_title_spaced_width(_text, _fit_spacing, _fit_scale)
		}
	}

	return [_fit_spacing, _fit_scale, _width]
}

function draw_menu_title_spaced_fit(_x, _y, _text, _spacing, _xscale, _yscale, _max_width, _min_spacing = 1, _min_scale = 0.45) {
	var _fit = draw_menu_title_spaced_fit_data(_text, _spacing, _xscale, _max_width, _min_spacing, _min_scale)
	var _scale_ratio = _fit[1] / max(0.001, _xscale)
	draw_text_spaced(_x, _y, _text, _fit[0], _fit[1], _yscale * _scale_ratio)
}

function draw_menu_title_spaced_center_fit(_x, _y, _text, _spacing, _xscale, _yscale, _max_width, _min_spacing = 1, _min_scale = 0.45) {
	var _fit = draw_menu_title_spaced_fit_data(_text, _spacing, _xscale, _max_width, _min_spacing, _min_scale)
	var _scale_ratio = _fit[1] / max(0.001, _xscale)
	draw_text_spaced(_x - _fit[2] * 0.5, _y, _text, _fit[0], _fit[1], _yscale * _scale_ratio)
}

function draw_menu_title_spaced_center(_x, _y, _text, _spacing, _xscale, _yscale) {
	draw_text_spaced(_x - draw_menu_title_spaced_width(_text, _spacing, _xscale) * 0.5, _y, _text, _spacing, _xscale, _yscale)
}

function draw_menu_title_clean_fit_data(_text, _xscale, _yscale, _max_width, _min_scale = 0.45) {
	var _fit_x = _xscale
	var _fit_y = _yscale
	var _width = string_width(_text) * _fit_x

	if (_width > _max_width) {
		var _ratio = max(_min_scale, _max_width / max(1, _width))
		_fit_x *= _ratio
		_fit_y *= _ratio
		_width = string_width(_text) * _fit_x
	}

	return [_fit_x, _fit_y, _width]
}

function draw_menu_title_clean_fit(_x, _y, _text, _xscale, _yscale, _max_width, _min_scale = 0.45) {
	var _fit = draw_menu_title_clean_fit_data(_text, _xscale, _yscale, _max_width, _min_scale)
	draw_text_transformed(_x, _y, _text, _fit[0], _fit[1], 0)
}

function draw_menu_title_clean_center_fit(_x, _y, _text, _xscale, _yscale, _max_width, _min_scale = 0.45) {
	var _fit = draw_menu_title_clean_fit_data(_text, _xscale, _yscale, _max_width, _min_scale)
	draw_text_transformed(_x - _fit[2] * 0.5, _y, _text, _fit[0], _fit[1], 0)
}

function draw_menu_title_vignette(_w, _h, _alpha) {
	draw_set_color(c_black)

	for (var i = 0; i < 10; i++) {
		var _p = i / 10
		draw_set_alpha(_alpha * power(1 - _p, 1.7))
		draw_rectangle(0, 0, _w, 18 + i * 18, false)
		draw_rectangle(0, _h - 18 - i * 18, _w, _h, false)
		draw_rectangle(0, 0, 18 + i * 24, _h, false)
		draw_rectangle(_w - 18 - i * 24, 0, _w, _h, false)
	}

	draw_set_alpha(1)
}

function draw_menu_title_tunnel(_cx, _cy, _w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 34; i++) {
		var _p = i / 33
		var _top_x = lerp(0, _w, _p)
		var _bot_x = lerp(_w, 0, _p)
		var _pulse = 0.45 + 0.55 * draw_menu_title_hash(i * 9 + floor(_time * 3))

		draw_set_alpha(_alpha * 0.04 * _pulse)
		draw_line_width(_top_x, 0, _cx, _cy, 1)
		draw_line_width(_bot_x, _h, _cx, _cy, 1)
	}

	for (var ring = 0; ring < 12; ring++) {
		var _t = ((ring / 12) + _time * 0.07) mod 1
		var _rw = lerp(48, _w * 1.15, power(_t, 1.65))
		var _rh = lerp(32, _h * 1.05, power(_t, 1.65))
		var _a = _alpha * (1 - _t) * 0.18
		var _x1 = _cx - _rw * 0.5
		var _x2 = _cx + _rw * 0.5
		var _y1 = _cy - _rh * 0.5
		var _y2 = _cy + _rh * 0.5

		draw_set_alpha(_a)
		draw_rectangle(_x1, _y1, _x2, _y2, true)
		draw_line_width(_x1, _cy, _x1 + 18, _cy, 1)
		draw_line_width(_x2 - 18, _cy, _x2, _cy, 1)
		draw_line_width(_cx, _y1, _cx, _y1 + 14, 1)
		draw_line_width(_cx, _y2 - 14, _cx, _y2, 1)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_orbit_core(_cx, _cy, _radius, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)

	for (var ring = 0; ring < 7; ring++) {
		var _r = _radius * (0.28 + ring * 0.12) + sin(_time * 2.3 + ring) * 2
		draw_set_color((ring mod 2 == 0) ? _col : c_white)
		draw_set_alpha(_alpha * (0.08 + ring * 0.025))
		draw_circle(_cx, _cy, _r, true)
	}

	draw_set_color(_col)
	for (var i = 0; i < 96; i++) {
		var _ang = i * 3.75 + _time * 18
		var _long = (i mod 8 == 0)
		var _inner = _radius * (_long ? 0.58 : 0.66)
		var _outer = _radius * (_long ? 0.88 : 0.76)
		var _pulse = 0.45 + 0.55 * sin(_time * 3.0 + i * 0.23)

		draw_set_alpha(_alpha * (_long ? 0.58 : 0.22) * _pulse)
		draw_line_width(
			_cx + lengthdir_x(_inner, _ang),
			_cy + lengthdir_y(_inner, _ang),
			_cx + lengthdir_x(_outer, _ang),
			_cy + lengthdir_y(_outer, _ang),
			_long ? 2 : 1
		)
	}

	for (var i = 0; i < 8; i++) {
		var _a = i * 45 - _time * 42
		var _x = _cx + lengthdir_x(_radius * 0.98, _a)
		var _y = _cy + lengthdir_y(_radius * 0.98, _a)

		draw_set_alpha(_alpha * 0.72)
		draw_rectangle(_x - 3, _y - 3, _x + 3, _y + 3, true)
		draw_set_alpha(_alpha * 0.2)
		draw_line_width(_cx, _cy, _x, _y, 1)
	}

	draw_set_alpha(_alpha * 0.45)
	draw_circle(_cx, _cy, 12 + sin(_time * 6) * 3, false)
	draw_set_color(c_white)
	draw_set_alpha(_alpha * 0.75)
	draw_circle(_cx, _cy, 3, false)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_fragment_storm(_cx, _cy, _w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)

	for (var i = 0; i < 78; i++) {
		var _seed = i * 31
		var _ang = draw_menu_title_hash(_seed) * 360 + sin(_time * 0.35 + i) * 6
		var _dist = 24 + draw_menu_title_hash(_seed + 2) * 520
		var _drift = (_time * (8 + draw_menu_title_hash(_seed + 3) * 26)) mod 72
		var _x = _cx + lengthdir_x(_dist + _drift, _ang)
		var _y = _cy + lengthdir_y(_dist + _drift, _ang) * 0.72

		if (_x < -40 || _x > _w + 40 || _y < -40 || _y > _h + 40) continue

		var _len = 10 + draw_menu_title_hash(_seed + 4) * 78
		var _tilt = _ang + 90 + draw_menu_title_hash(_seed + 5) * 26
		var _hot = draw_menu_title_hash(_seed + floor(_time * 8))
		var _a = _alpha * (0.08 + _hot * 0.36)

		draw_set_color((i mod 9 == 0) ? c_white : _col)
		draw_set_alpha(_a * 0.55)
		draw_line_width(_x, _y, _x + lengthdir_x(_len, _tilt), _y + lengthdir_y(_len, _tilt), 2)
		draw_set_color(_col)
		draw_set_alpha(_a)
		draw_line_width(_x, _y, _x + lengthdir_x(_len * 0.8, _tilt), _y + lengthdir_y(_len * 0.8, _tilt), 1)
	}

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_glitch_text(_text, _x, _y, _sx, _sy, _col, _alpha, _time, _seed) {
	draw_set_font(fMenu)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)

	gpu_set_blendmode(bm_add)
	for (var pass = 0; pass < 5; pass++) {
		var _j = sin(_time * (8 + pass) + _seed + pass * 19) * (pass + 1)
		var _col2 = (pass == 0) ? c_white : _col
		draw_set_color(_col2)
		draw_set_alpha(_alpha * (pass == 0 ? 0.08 : 0.18))
		draw_text_transformed(_x + _j, _y - _j * 0.3, _text, _sx * (1 + pass * 0.012), _sy, 0)
	}

	draw_set_color(_col)
	draw_set_alpha(_alpha * 0.92)
	draw_text_transformed(_x, _y, _text, _sx, _sy, 0)

	gpu_set_blendmode(bm_normal)

	for (var i = 0; i < 18; i++) {
		var _yy = _y + draw_menu_title_hash(_seed + i) * 68 * _sy
		var _ww = string_width(_text) * _sx * (0.18 + draw_menu_title_hash(_seed + i + 44) * 0.62)
		var _xx = _x - string_width(_text) * _sx * 0.5 + draw_menu_title_hash(_seed + i + 88) * string_width(_text) * _sx

		draw_set_color(c_black)
		draw_set_alpha(_alpha * (0.18 + draw_menu_title_hash(_seed + i + 5) * 0.38))
		draw_rectangle(_xx - _ww * 0.5, _yy, _xx + _ww * 0.5, _yy + 2 + draw_menu_title_hash(i) * 4, false)
	}

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_data_rails(_w, _h, _col, _time, _alpha) {
	gpu_set_blendmode(bm_add)
	draw_set_font(fMenu)
	draw_set_color(_col)

	for (var row = 0; row < 7; row++) {
		var _y = 54 + row * 27
		var _x1 = 36 + draw_menu_title_hash(row + floor(_time * 2)) * 40
		var _x2 = 210 + draw_menu_title_hash(row + 30) * 80
		draw_set_alpha(_alpha * (0.12 + row * 0.025))
		draw_line_width(_x1, _y, _x2, _y, 1)
	}

	draw_set_alpha(_alpha * 0.78)
	draw_text_spaced(32, 48, "BC--00:00", 2, 0.48, 0.48)
	draw_text_spaced(32, 70, "// LINK READY", 2, 0.48, 0.48)
	draw_text_spaced(32, 92, "// SYSTEM READY", 2, 0.48, 0.48)

	for (var i = 0; i < 42; i++) {
		var _x = lerp(36, _w - 36, i / 41)
		var _h1 = 3 + abs(sin(i * 0.72 + _time * 6)) * 16
		draw_set_alpha(_alpha * (0.18 + _h1 * 0.025))
		draw_line_width(_x, _h - 42 - _h1, _x, _h - 42 + _h1 * 0.35, 1)
	}

	draw_set_alpha(_alpha * 0.42)
	draw_text_spaced(_w - 240, 46, "GETTY // BASSLINE CRACK", 2, 0.4, 0.4)
	draw_text_spaced(_w - 190, _h - 62, "NOISE FLOOR: ACTIVE", 2, 0.38, 0.38)

	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_prompt(_cx, _y, _col, _time, _alpha) {
	var _blink = 0.55 + 0.45 * sin(_time * 5.2)
	var _hit = power(max(0, sin(_time * 2.4)), 10)
	var _w = 250 + _hit * 28
	var _h = 42

	gpu_set_blendmode(bm_add)
	draw_set_color(_col)
	draw_set_alpha(_alpha * (0.28 + _blink * 0.26))
	draw_rectangle(_cx - _w * 0.5, _y - 8, _cx + _w * 0.5, _y + _h, true)
	draw_line_width(_cx - _w * 0.5 - 22, _y + 12, _cx - _w * 0.5 + 18, _y + 12, 1)
	draw_line_width(_cx + _w * 0.5 - 18, _y + 12, _cx + _w * 0.5 + 22, _y + 12, 1)

	draw_set_font(fMenu)
	draw_set_color(c_white)
	draw_set_alpha(_alpha * (0.52 + _blink * 0.4))
	draw_menu_title_spaced_center(_cx, _y, "PRESS SHIFT", 9, 0.92, 0.92)

	draw_set_color(_col)
	draw_set_alpha(_alpha * 0.45)
	draw_menu_title_waveform(_cx - 145, _cx + 145, _y + 45, 8 + _hit * 8, 92, _col, _alpha * 0.8, _time, 12.6)

	gpu_set_blendmode(bm_normal)
	draw_set_alpha(1)
}

function draw_menu_title_shatter_transition(_w, _h, _col, _time, _exit) {
	if (_exit <= 0) return

	var _e = clamp(_exit, 0, 1)
	gpu_set_blendmode(bm_add)
	draw_set_color(_col)

	for (var i = 0; i < 28; i++) {
		var _y = draw_menu_title_hash(i + 80) * _h
		var _len = lerp(40, _w * 1.3, _e)
		var _x = lerp(_w * 0.5, -_w * 0.2 + draw_menu_title_hash(i) * _w * 1.4, _e)
		draw_set_alpha((1 - _e) * (0.15 + draw_menu_title_hash(i + 3) * 0.5))
		draw_line_width(_x - _len * 0.5, _y, _x + _len * 0.5, _y + sin(i) * 12, 2 + _e * 8)
	}

	draw_set_alpha((1 - _e) * 0.7)
	draw_circle(_w * 0.5, _h * 0.47, 40 + _e * 540, true)

	gpu_set_blendmode(bm_normal)
	draw_set_color(c_black)
	draw_set_alpha(power(_e, 2.2))
	draw_rectangle(0, 0, _w, _h, false)
	draw_set_alpha(1)
}

function draw_menu_startup_notice(_age = 0, _exit = 0) {
	var _w = room_width
	var _h = room_height
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 18, 14)
	var _cyan = make_color_rgb(72, 214, 255)
	var _dark = make_color_rgb(6, 8, 13)
	var _panel_dark = make_color_rgb(13, 10, 15)
	var _panel_edge = make_color_rgb(34, 20, 26)
	var _exit_clamped = clamp(_exit, 0, 1)
	var _fade_in = clamp(_age / 24, 0, 1)
	var _alpha = _fade_in * (1 - power(_exit_clamped, 1.35))
	var _cx = _w * 0.5
	var _cy = _h * 0.5
	var _panel_w = min(_w - 120, 620)
	var _panel_h = 292
	var _px0 = _cx - _panel_w * 0.5
	var _py0 = _cy - _panel_h * 0.5 - 8
	var _px1 = _cx + _panel_w * 0.5
	var _py1 = _py0 + _panel_h
	var _blink = 0.55 + 0.45 * sin(_time * 4.2)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_black)
	draw_set_alpha(1)
	draw_rectangle(0, 0, _w, _h, false)

	draw_set_color(_dark)
	draw_set_alpha(0.96 * _alpha)
	draw_rectangle(0, 0, _w, _h, false)

	draw_set_color(_red)
	draw_set_alpha(0.10 * _alpha)
	draw_line_width(82, _h * 0.24, _w - 92, _h * 0.24 + sin(_time) * 5, 1)
	draw_set_color(_cyan)
	draw_set_alpha(0.08 * _alpha)
	draw_line_width(118, _h * 0.76, _w - 124, _h * 0.76 + sin(_time * 0.9) * 4, 1)

	draw_set_alpha(0.88 * _alpha)
	draw_rectangle_colour(_px0, _py0, _px1, _py1,
		_panel_edge, _panel_dark, c_black, _panel_dark, false)

	gpu_set_blendmode(bm_add)
	draw_menu_title_corner_frame(_px0, _py0, _px1, _py1, 16, _red, 0.38 * _alpha, _time)
	draw_menu_title_corner_frame(_px0 + 18, _py0 + 18, _px1 - 18, _py1 - 18, 8, _cyan, 0.16 * _alpha, _time + 4.6)
	draw_set_color(_red)
	draw_set_alpha(0.12 * _alpha)
	draw_menu_title_waveform(_cx - 230, _cx + 230, _py0 + 76, 5 + _blink * 3, 118, _red, 0.24 * _alpha, _time, 11.3)
	gpu_set_blendmode(bm_normal)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)

	draw_set_font(fMenu)
	draw_set_color(c_white)
	draw_set_alpha(0.95 * _alpha)
	draw_menu_title_spaced_center_fit(_cx, _py0 + 38, "FOR THE BEST EXPERIENCE", 6, 0.62, 0.62, _panel_w - 96)

	draw_set_font(fDefault)
	draw_set_color(merge_color(c_white, _cyan, 0.08))
	draw_set_alpha(0.88 * _alpha)
	draw_menu_title_clean_center_fit(_cx, _py0 + 116, "Headphones are highly recommended.", 1, 1, _panel_w - 120)

	draw_set_color(merge_color(c_white, _red, 0.08))
	draw_set_alpha(0.82 * _alpha)
	draw_menu_title_clean_center_fit(_cx, _py0 + 158, "For your first playthrough, the intended experience is", 0.88, 0.88, _panel_w - 120)

	draw_set_font(fMenu)
	draw_set_color(_cyan)
	draw_set_alpha(0.92 * _alpha)
	draw_menu_title_spaced_center_fit(_cx, _py0 + 190, "HIT COUNT ON", 6, 0.60, 0.60, _panel_w - 150)

	draw_menu_title_scanlines(_w, _h, _red, _time, 0.24 * _alpha)
	draw_menu_title_vignette(_w, _h, 0.42 * _alpha)

	var _prompt_y = _py1 - 52
	var _prompt_w = 286
	gpu_set_blendmode(bm_add)
	draw_set_color(_cyan)
	draw_set_alpha((0.08 + _blink * 0.08) * _alpha)
	draw_rectangle(_cx - _prompt_w * 0.5, _prompt_y - 5, _cx + _prompt_w * 0.5, _prompt_y + 25, false)
	draw_set_alpha((0.24 + _blink * 0.12) * _alpha)
	draw_line_width(_cx - _prompt_w * 0.5, _prompt_y + 27, _cx + _prompt_w * 0.5, _prompt_y + 27, 1)
	gpu_set_blendmode(bm_normal)

	draw_set_font(fDefault)
	draw_set_color(c_white)
	draw_set_alpha((0.78 + _blink * 0.18) * _alpha)
	draw_menu_title_clean_center_fit(_cx, _prompt_y, "PRESS SHIFT TO CONTINUE", 0.82, 0.82, _panel_w - 120)

	if (_exit_clamped > 0) {
		draw_set_color(c_black)
		draw_set_alpha(power(_exit_clamped, 1.6))
		draw_rectangle(0, 0, _w, _h, false)
	}

	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	gpu_set_blendmode(bm_normal)
}

function draw_menu_title_splash(_exit = 0) {
	var _w = room_width
	var _h = room_height
	var _time = current_time * 0.001
	var _red = make_color_rgb(255, 18, 14)
	var _dark_red = make_color_rgb(80, 4, 2)
	var _exit_clamped = clamp(_exit, 0, 1)
	var _alpha = 1 - power(_exit_clamped, 1.35)
	var _cx = _w * 0.5
	var _cy = _h * 0.47
	var _wake = clamp(_time * 0.55, 0, 1)
	var _beat = power(max(0, sin(_time * 2.45)), 8)

	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_black)
	draw_set_alpha(1)
	draw_rectangle(0, 0, _w, _h, false)

	draw_set_color(make_color_rgb(14, 6, 5))
	draw_set_alpha(0.85 * _alpha)
	draw_rectangle(0, 0, _w, _h, false)

	draw_menu_title_floor_grid(_cx, _h * 0.53, _w, _h, _red, _time, 0.22 * _alpha)
	draw_menu_title_tunnel(_cx, _cy, _w, _h, _red, _time, _alpha * (0.8 + _beat * 0.2))
	draw_menu_title_signal_lattice(_w, _h, _dark_red, _time, 0.82 * _alpha)
	draw_menu_title_dust(_w, _h, _red, _time, 0.95 * _alpha, 210)
	draw_menu_title_corner_frame(12, 14, _w - 12, _h - 12, 18, _red, (0.88 + _beat * 0.16) * _alpha, _time)
	draw_menu_title_fragment_storm(_cx + 62 * _exit_clamped, _cy - 10, _w, _h, _red, _time + _exit_clamped * 4, _alpha)
	draw_menu_title_shock_rings(_cx + 126, _cy - 14, _red, _time, (0.58 + _beat * 0.2) * _alpha, 420)

	gpu_set_blendmode(bm_add)
	draw_set_color(_dark_red)
	draw_set_alpha((0.35 + _beat * 0.12) * _alpha)
	draw_line_width(40, _h * 0.23, _cx - 40, _cy - 36, 2)
	draw_line_width(_w - 40, _h * 0.22, _cx + 36, _cy - 22, 2)
	draw_line_width(32, _h * 0.82, _cx - 50, _cy + 46, 1)
	draw_line_width(_w - 60, _h * 0.84, _cx + 42, _cy + 52, 1)
	gpu_set_blendmode(bm_normal)

	draw_menu_title_crack_field(_cx + 126, _cy - 14, 1.30 + _exit_clamped * 0.28, _red, (0.80 + _beat * 0.12) * _alpha, _time)
	draw_menu_title_orbit_core(_cx + 126, _cy - 14, 118 + _beat * 18, _red, _time, _alpha)
	draw_menu_title_vertical_analyzer(_cx + 226, 108, _h - 100, _red, (0.64 + _beat * 0.22) * _alpha, _time)
	draw_menu_title_bass_columns(_cx + 206, 126, 46, _h - 228, _red, _time, 0.36 * _alpha, 16, 33)

	draw_menu_title_title_underlay(_cx - 94, 278, 490, 260, _red, _time, (0.70 + _beat * 0.16) * _alpha)
	draw_menu_title_crisp_logo(_cx - 86, 164 - _exit_clamped * 10, 520, _alpha, _time, _exit_clamped)

	gpu_set_blendmode(bm_add)
	draw_set_color(_red)
	draw_set_alpha(0.5 * _alpha)
	draw_menu_title_waveform(_cx - 270, _cx + 270, 431, 18 + _beat * 16, 160, _red, 0.82 * _alpha, _time, 19.2)
	draw_set_alpha(1)
	gpu_set_blendmode(bm_normal)

	draw_menu_title_prompt(_cx, 465 + sin(_time * 3.2) * 2, _red, _time, _alpha * (0.82 + _wake * 0.18))
	draw_menu_title_data_rails(_w, _h, _red, _time, _alpha)
	draw_menu_title_icon_row(_cx - 105, _h - 40, 70, _red, _time)
	draw_menu_title_scope(82, _h - 62, 35, _red, _time, 0.42 * _alpha)
	draw_menu_title_scope(_w - 78, 76, 32, _red, -_time, 0.36 * _alpha)

	draw_set_font(fMenu)
	draw_set_color(make_color_rgb(178, 138, 124))
	draw_set_alpha(0.42 * _alpha)
	draw_menu_title_spaced_center_fit(_cx, _h - 75, "AVOID. SURVIVE. BREAK THE BASSLINE.", 6, 0.44, 0.44, 460)

	draw_menu_title_scanlines(_w, _h, _red, _time, 0.62 * _alpha)
	draw_menu_title_vignette(_w, _h, 0.36 + _exit_clamped * 0.45)
	draw_menu_title_shatter_transition(_w, _h, _red, _time, _exit_clamped)

	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	gpu_set_blendmode(bm_normal)
}
