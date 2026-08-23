var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _c  = scr_death_room_to_gui(death_x, death_y);
var _cx = _c.x;
var _cy = _c.y;

var _reach = point_distance(0, 0, _gw, _gh) * 1.2;
var _dx = lengthdir_x(_reach, cut_angle);
var _dy = lengthdir_y(_reach, cut_angle);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

if (overload > 0.01 && !body_split) {
    draw_set_alpha(overload * 0.34);
    draw_set_colour(make_colour_rgb(16, 2, 6));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}

if (redout > 0.001) {
    draw_set_alpha(redout * 0.32);
    draw_set_colour(scr_death_blood_colour(0.05));
    draw_rectangle(0, 0, _gw, _gh, false);

    gpu_set_blendmode(bm_add);
    draw_set_alpha(redout * 0.22);
    draw_set_colour(scr_death_blood_colour(0.5));
    draw_rectangle(0, 0, _gw, _gh, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

for (var i = 0; i < array_length(cut_strikes); i++) {
    var _st = cut_strikes[i];
    var _f  = clamp(_st.life / _st.life_max, 0, 1);

    var _sdx = lengthdir_x(_reach, _st.ang);
    var _sdy = lengthdir_y(_reach, _st.ang);
    var _offx = lengthdir_x(_st.off, _st.ang + 90);
    var _offy = lengthdir_y(_st.off, _st.ang + 90);

    var _ax = _cx + _offx;
    var _ay = _cy + _offy;

    gpu_set_blendmode(bm_add);

    draw_set_alpha(_f * 0.40);
    draw_set_colour(scr_death_blood_colour(0.75));
    draw_line_width(_ax - _sdx, _ay - _sdy, _ax + _sdx, _ay + _sdy, _st.w * 3.4 * _f);

    draw_set_alpha(_f * 0.85);
    draw_set_colour(scr_death_blood_colour(0.95));
    draw_line_width(_ax - _sdx, _ay - _sdy, _ax + _sdx, _ay + _sdy, _st.w * 1.5 * _f);

    draw_set_alpha(_f);
    draw_set_colour(c_white);
    draw_line_width(_ax - _sdx, _ay - _sdy, _ax + _sdx, _ay + _sdy, max(1, _st.w * 0.35 * _f));

    gpu_set_blendmode(bm_normal);
}
draw_set_alpha(1);

if (cut_preview > 0.005) {
    gpu_set_blendmode(bm_add);

    draw_set_alpha(cut_preview * 0.35);
    draw_set_colour(scr_death_blood_colour(0.6));
    draw_line_width(_cx - _dx, _cy - _dy, _cx + _dx, _cy + _dy, 5);

    var _j = cut_preview * 3;
    draw_set_alpha(cut_preview);
    draw_set_colour(c_white);
    draw_line_width(
        _cx - _dx + random_range(-_j, _j), _cy - _dy + random_range(-_j, _j),
        _cx + _dx + random_range(-_j, _j), _cy + _dy + random_range(-_j, _j), 1);

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

if (blade_t > 0 && blade_glow > 0.01) {
    var _moving = (blade_t < 1);

    var _blade_edge = point_distance(0, 0, _gw, _gh) * _k_blade_edge_frac;
    var _bex = lengthdir_x(_blade_edge, cut_angle);
    var _bey = lengthdir_y(_blade_edge, cut_angle);

    var _ent_x = _cx - _bex, _ent_y = _cy - _bey;
    var _ext_x = _cx + _bex, _ext_y = _cy + _bey;

    var _bx = lerp(_ent_x, _ext_x, blade_t);
    var _by = lerp(_ent_y, _ext_y, blade_t);

    var _perp = cut_angle + 90;

    if (_moving) {
        var _dim = _k_blade_dim * min(1, blade_t * 6);
        draw_set_alpha(_dim);
        draw_set_colour(make_colour_rgb(4, 0, 2));
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1);
    }

    gpu_set_blendmode(bm_add);

    var _pass_w = [1.00, 0.55, 0.22, 0.06];
    var _pass_a = [0.30, 0.55, 0.85, 1.00];
    var _pass_c = [scr_death_blood_colour(0.55), scr_death_blood_colour(0.8),
                   scr_death_blood_colour(0.97), c_white];

    for (var _p = 0; _p < 4; _p++) {
        var _hw = _k_blade_head_w * _pass_w[_p] * blade_glow;
        var _hx = lengthdir_x(_hw, _perp);
        var _hy = lengthdir_y(_hw, _perp);
        var _tw = _hw * 0.10;
        var _tx = lengthdir_x(_tw, _perp);
        var _ty = lengthdir_y(_tw, _perp);
        var _aa = _pass_a[_p] * blade_glow;

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_ent_x - _tx, _ent_y - _ty, _pass_c[_p], 0);
        draw_vertex_colour(_ent_x + _tx, _ent_y + _ty, _pass_c[_p], 0);
        draw_vertex_colour(_bx - _hx,   _by - _hy,     _pass_c[_p], _aa);
        draw_vertex_colour(_bx + _hx,   _by + _hy,     _pass_c[_p], _aa);
        draw_primitive_end();
    }

    if (_moving) {

        var _alx = lengthdir_x(_reach * 2, _perp);
        var _aly = lengthdir_y(_reach * 2, _perp);

        var _band_w = [_k_band_half, _k_band_half * 0.55, _k_band_core, _k_band_core * 0.35];
        var _band_a = [0.40, 0.75, 1.00, 1.00];
        var _band_c = [scr_death_blood_colour(0.75), scr_death_blood_colour(0.95),
                       c_white, c_white];

        for (var _b = 0; _b < 4; _b++) {
            var _bw = _band_w[_b];
            var _bwx = lengthdir_x(_bw, cut_angle);
            var _bwy = lengthdir_y(_bw, cut_angle);
            var _ba = _band_a[_b];

            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_colour(_bx - _alx - _bwx, _by - _aly - _bwy, _band_c[_b], 0);
            draw_vertex_colour(_bx + _alx - _bwx, _by + _aly - _bwy, _band_c[_b], 0);
            draw_vertex_colour(_bx - _alx,        _by - _aly,        _band_c[_b], _ba);
            draw_vertex_colour(_bx + _alx,        _by + _aly,        _band_c[_b], _ba);
            draw_vertex_colour(_bx - _alx + _bwx, _by - _aly + _bwy, _band_c[_b], 0);
            draw_vertex_colour(_bx + _alx + _bwx, _by + _aly + _bwy, _band_c[_b], 0);
            draw_primitive_end();
        }
    }

    if (_moving) {

        var _sx = _bx - lengthdir_x(_k_blade_streak, cut_angle);
        var _sy = _by - lengthdir_y(_k_blade_streak, cut_angle);

        draw_set_alpha(0.5);
        draw_set_colour(scr_death_blood_colour(0.9));
        draw_line_width(_sx, _sy, _bx, _by, 46);

        draw_set_alpha(0.95);
        draw_set_colour(c_white);
        draw_line_width(_sx, _sy, _bx, _by, 14);

        draw_set_alpha(0.35);
        draw_set_colour(scr_death_blood_colour(0.7));
        draw_ellipse(_bx - _k_blade_bloom, _by - _k_blade_bloom,
                     _bx + _k_blade_bloom, _by + _k_blade_bloom, false);

        draw_set_alpha(0.7);
        draw_set_colour(scr_death_blood_colour(0.95));
        draw_ellipse(_bx - _k_blade_bloom * 0.45, _by - _k_blade_bloom * 0.45,
                     _bx + _k_blade_bloom * 0.45, _by + _k_blade_bloom * 0.45, false);

        draw_set_alpha(1);
        draw_set_colour(c_white);
        draw_ellipse(_bx - 52, _by - 52, _bx + 52, _by + 52, false);

        for (var _sp = 0; _sp < 26; _sp++) {
            var _sang = _perp + choose(0, 180) + random_range(-46, 46);
            var _slen = random_range(60, 340);
            draw_set_alpha(random_range(0.35, 1));
            draw_set_colour(scr_death_blood_colour(random_range(0.6, 1)));
            draw_line_width(_bx, _by,
                _bx + lengthdir_x(_slen, _sang),
                _by + lengthdir_y(_slen, _sang),
                random_range(1, 6));
        }
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}

if (body_split) {

    if (wound > 0.01) {

        var _w_ex = _cx - _dx;
        var _w_ey = _cy - _dy;
        var _w_bx = lerp(_w_ex, _cx + _dx, blade_t);
        var _w_by = lerp(_w_ey, _cy + _dy, blade_t);
        var _col  = scr_death_blood_colour(0.15 + seam_heat * 0.75);

        gpu_set_blendmode(bm_add);
        draw_set_alpha(wound * 0.28 * (0.35 + seam_heat * 0.65));
        draw_set_colour(_col);
        draw_line_width(_w_ex, _w_ey, _w_bx, _w_by, 16 * wound);
        gpu_set_blendmode(bm_normal);

        draw_set_alpha(wound * 0.95);
        draw_set_colour(scr_death_blood_colour(0));
        draw_line_width(_w_ex, _w_ey, _w_bx, _w_by, 1 + wound * 6);

        draw_set_alpha(1);
    }

    for (var i = 0; i < array_length(seam_drips); i++) {
        var _sd = seam_drips[i];
        if (_sd.delay > 0 || _sd.len <= 0 || _sd.alpha <= 0) continue;

        var _ox = _cx + _dx * _sd.u;
        var _oy = _cy + _dy * _sd.u;
        var _ey = _oy + _sd.len;

        draw_set_alpha(clamp(_sd.alpha, 0, 1) * 0.95);
        draw_set_colour(scr_death_blood_colour(0.08));
        draw_line_width(_ox, _oy, _ox, _ey, _sd.w);

        draw_set_colour(scr_death_blood_colour(0.2));
        draw_ellipse(_ox - _sd.w * 0.9, _ey - _sd.w * 0.7,
                     _ox + _sd.w * 0.9, _ey + _sd.w * 1.5, false);
    }
    draw_set_alpha(1);

    for (var i = 0; i < array_length(seam_embers); i++) {
        var _se = seam_embers[i];
        var _a  = clamp(_se.alpha, 0, 1);
        var _ex = _cx + _dx * _se.u + _se.vx * _se.drop * 0.3;
        var _ey = _cy + _dy * _se.u + _se.drop;

        gpu_set_blendmode(bm_add);
        draw_set_alpha(_a * 0.7);
        draw_set_colour(scr_death_blood_colour(0.55));
        draw_line_width(_ex, _ey - 2.5, _ex, _ey + 2.5, 2.4);
        gpu_set_blendmode(bm_normal);

        draw_set_alpha(_a);
        draw_set_colour(scr_death_blood_colour(0.12));
        draw_line_width(_ex, _ey - 1.5, _ex, _ey + 1.5, 1.2);
    }
    draw_set_alpha(1);
}

for (var i = 0; i < array_length(screen_splats); i++) {
    var _ss = screen_splats[i];
    if (_ss.delay > 0) continue;

    var _a = clamp(_ss.alpha, 0, 1);
    var _ey = _ss.y + _ss.run;

    draw_set_alpha(_a * 0.94);
    draw_set_colour(scr_death_blood_colour(_ss.heat));
    draw_ellipse(_ss.x - _ss.rx, _ss.y - _ss.ry,
                 _ss.x + _ss.rx, _ss.y + _ss.ry, false);

    draw_set_alpha(_a * 0.72);
    draw_set_colour(scr_death_blood_colour(0));
    draw_ellipse(_ss.x - _ss.rx * 0.45, _ss.y - _ss.ry * 0.45,
                 _ss.x + _ss.rx * 0.45, _ss.y + _ss.ry * 0.45, false);

    if (_ss.run > 1) {
        draw_set_alpha(_a * 0.78);
        draw_set_colour(scr_death_blood_colour(0.06));
        draw_line_width(_ss.x, _ss.y, _ss.x, _ey, _ss.w);

        draw_set_alpha(_a);
        draw_set_colour(scr_death_blood_colour(0.16));
        draw_ellipse(_ss.x - _ss.w * 1.1, _ey - _ss.w * 0.7,
                     _ss.x + _ss.w * 1.1, _ey + _ss.w * 1.7, false);
    }
}
draw_set_alpha(1);

gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(shock_rings); i++) {
    var _sr = shock_rings[i];
    var _f  = clamp(_sr.life / _sr.life_max, 0, 1);

    var _steps = max(1, floor(_sr.w));
    for (var _k = 0; _k < _steps; _k++) {
        var _rr = _sr.r + _k;
        var _ka = _f * (1 - _k / _steps);
        draw_set_alpha(_ka);
        draw_set_colour(merge_colour(scr_death_blood_colour(0.8), c_white, _ka));
        draw_ellipse(_cx - _rr, _cy - _rr, _cx + _rr, _cy + _rr, true);
    }
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

if (whiteout > 0.001) {
    var _wo = power(whiteout, 0.7);

    draw_set_alpha(_wo);
    draw_set_colour(c_white);
    draw_rectangle(0, 0, _gw, _gh, false);

    if (whiteout < 0.75) {
        gpu_set_blendmode(bm_add);
        draw_set_alpha((1 - whiteout) * whiteout * 1.6);
        draw_set_colour(scr_death_blood_colour(0.5));
        draw_rectangle(0, 0, _gw, _gh, false);
        gpu_set_blendmode(bm_normal);
    }
    draw_set_alpha(1);
}

draw_set_alpha(1);
draw_set_colour(c_white);
