var _angle = image_angle + jitter_angle;
var _dx = x + jitter_x;
var _dy = y + jitter_y;
var _ripe_heat = clamp(base_alpha + unstable * 0.55 + crack_glow * 0.35 + crack_flash * 0.25, 0, 1.35);
var _blood_seed = make_color_rgb(68, 9, 16);
var _sap_col = merge_color(global.avoid_col_blood, fruit_color, clamp(0.35 + _ripe_heat * 0.5, 0, 1));
var _core_col = merge_color(fruit_color, c_white, clamp(0.35 + _ripe_heat * 0.38, 0, 0.9));
var _body_col = merge_color(_blood_seed, fruit_color, clamp(base_alpha * 0.78, 0, 1));
_body_col = merge_color(_body_col, c_white, clamp(crack_flash * 0.55, 0, 0.75));
var _orbit_pulse = 0.5 + 0.5 * sin(current_time * 0.017 + orbit_phase);
var _identity_a = image_alpha * clamp(0.16 + base_alpha * 0.42 + unstable * 0.72 + crack_glow * 0.32, 0, 1.25);
var _fruit_scale = max(abs(image_xscale), abs(image_yscale));
var _cocoon_a = image_alpha * clamp(cocoon_shell_alpha, 0, 1);
var _cocoon_heat = clamp(cocoon_pressure + crack_flash * 0.14 + cocoon_crack_flash * 0.28 + cocoon_rupture_flash * 0.5, 0, 1.65);
var _cocoon_r = (14.5 + _cocoon_heat * 5.2 + _orbit_pulse * (1.4 + unstable * 1.2)) * _fruit_scale;
var _cocoon_col = merge_color(global.avoid_col_cyan, global.tree_fire_color, clamp(0.20 + _cocoon_heat * 0.42, 0, 0.82));
var _cocoon_edge = merge_color(global.avoid_col_cyan_soft, c_white, clamp(cocoon_crack_flash * 0.22 + cocoon_rupture_flash * 0.35, 0, 0.6));

if (_identity_a > 0.01) {
    gpu_set_blendmode(bm_add);

    var _stem_dist = point_distance(anchor_x, anchor_y, _dx, _dy);
    if (_stem_dist > 0.5) {
        draw_set_color(_sap_col);
        draw_set_alpha(_identity_a * 0.34);
        draw_line_width(anchor_x, anchor_y, _dx, _dy, 3.2 + unstable * 2.2);
        draw_set_color(c_white);
        draw_set_alpha(_identity_a * 0.42);
        draw_line_width(anchor_x, anchor_y, _dx, _dy, 0.9 + unstable * 0.6);
    }

    if (unstable > 0.08) {
        var _cx0 = crown_x;
        var _cy0 = crown_y;
        var _crown_dist = point_distance(_dx, _dy, _cx0, _cy0);
        if (_crown_dist > 8) {
            var _mid_x = lerp(_dx, _cx0, 0.5) + sin(current_time * 0.031 + sap_tether_seed) * 8 * unstable;
            var _mid_y = lerp(_dy, _cy0, 0.5) + cos(current_time * 0.026 + sap_tether_seed) * 6 * unstable;
            draw_set_color(merge_color(global.avoid_col_cyan, _sap_col, 0.38));
            draw_set_alpha(_identity_a * unstable * 0.16);
            draw_line_width(_dx, _dy, _mid_x, _mid_y, 2.2);
            draw_line_width(_mid_x, _mid_y, _cx0, _cy0, 2.2);
        }
    }

    var _ring_r = 8.5 + _ripe_heat * 4.5 + _orbit_pulse * (1.5 + unstable * 2.5);
    var _ring_a = _identity_a * (0.22 + unstable * 0.42 + crack_flash * 0.35);
    draw_set_color(_sap_col);
    draw_set_alpha(_ring_a);
    draw_circle(_dx, _dy, _ring_r, true);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_ring_a * (0.18 + unstable * 0.22));
    draw_circle(_dx, _dy, _ring_r * (0.64 + _orbit_pulse * 0.08), true);

    var _ring_rot = orbit_phase + current_time * (0.045 + unstable * 0.05);
    for (var _fr = 0; _fr < 3; _fr++) {
        var _ra = _ring_rot + _fr * 120;
        draw_set_color(merge_color(_sap_col, c_white, 0.35));
        draw_set_alpha(_ring_a * 0.78);
        draw_line_width(_dx + lengthdir_x(_ring_r * 0.72, _ra),
                        _dy + lengthdir_y(_ring_r * 0.72, _ra),
                        _dx + lengthdir_x(_ring_r * 1.12, _ra),
                        _dy + lengthdir_y(_ring_r * 1.12, _ra), 1.1);
    }

    var _bead_a = _ring_rot + 70;
    draw_set_color(c_white);
    draw_set_alpha(_ring_a * 0.9);
    draw_circle(_dx + lengthdir_x(_ring_r, _bead_a), _dy + lengthdir_y(_ring_r, _bead_a),
                1.4 + unstable * 1.4, false);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

if (_cocoon_a > 0.01) {
    gpu_set_blendmode(bm_add);

    var _shell_fill = _cocoon_a * (0.07 + _cocoon_heat * 0.025);
    draw_set_color(merge_color(global.avoid_col_cyan, _cocoon_col, 0.35));
    draw_set_alpha(_shell_fill);
    draw_circle_color(_dx, _dy, _cocoon_r * 1.08, _cocoon_col, _blood_seed, false);

    var _sap_lens_a = _cocoon_a * (0.08 + _cocoon_heat * 0.04);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_sap_lens_a);
    draw_circle(_dx, _dy, _cocoon_r * 0.78, false);

    for (var _cb = 0; _cb < 3; _cb++) {
        var _band_rot = cocoon_seed + _cb * 64 + current_time * (0.018 + _cb * 0.006) * ((_cb == 1) ? -1 : 1);
        var _tilt = 0.22 + _cb * 0.13;
        var _last_x = 0;
        var _last_y = 0;
        var _has_last = false;

        for (var _bs = 0; _bs <= 9; _bs++) {
            var _ba = -118 + _bs * 26 + current_time * 0.015;
            var _lx = lengthdir_x(_cocoon_r * (0.78 + _cb * 0.035), _ba);
            var _ly = lengthdir_y(_cocoon_r * _tilt, _ba);
            var _px = _dx + _lx * dcos(_band_rot) - _ly * dsin(_band_rot);
            var _py = _dy + _lx * dsin(_band_rot) + _ly * dcos(_band_rot);

            if (_has_last) {
                draw_set_color(merge_color(global.avoid_col_cyan, _cocoon_col, 0.35 + _cb * 0.12));
                draw_set_alpha(_cocoon_a * (0.11 + _cocoon_heat * 0.035) * (1 - _cb * 0.16));
                draw_line_width(_last_x, _last_y, _px, _py, 2.1 - _cb * 0.25);
            }
            _last_x = _px;
            _last_y = _py;
            _has_last = true;
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

draw_sprite_ext(
    sprite_index,
    image_index,
    _dx,
    _dy,
    image_xscale,
    image_yscale,
    _angle,
    _body_col,
    image_alpha
);

if (_cocoon_a > 0.01) {
    gpu_set_blendmode(bm_add);

    draw_set_color(_cocoon_col);
    draw_set_alpha(_cocoon_a * (0.32 + _cocoon_heat * 0.12));
    draw_circle(_dx, _dy, _cocoon_r, true);

    draw_set_color(_cocoon_edge);
    draw_set_alpha(_cocoon_a * (0.22 + cocoon_crack_flash * 0.18 + cocoon_rupture_flash * 0.45));
    draw_circle(_dx, _dy, _cocoon_r * 0.91, true);

    var _glint_ang = cocoon_glint_seed + current_time * (0.06 + _cocoon_heat * 0.025);
    var _glint_len = _cocoon_r * (0.42 + _cocoon_heat * 0.06);
    var _glint_x = _dx + lengthdir_x(_cocoon_r * 0.43, _glint_ang);
    var _glint_y = _dy + lengthdir_y(_cocoon_r * 0.25, _glint_ang + 18);
    draw_set_color(c_white);
    draw_set_alpha(_cocoon_a * (0.22 + cocoon_crack_flash * 0.16));
    draw_line_width(_glint_x - lengthdir_x(_glint_len * 0.45, _glint_ang + 92),
                    _glint_y - lengthdir_y(_glint_len * 0.45, _glint_ang + 92),
                    _glint_x + lengthdir_x(_glint_len * 0.55, _glint_ang + 92),
                    _glint_y + lengthdir_y(_glint_len * 0.55, _glint_ang + 92), 1.1);

    var _crack_a = _cocoon_a * clamp(unstable * 0.52 + cocoon_crack_flash * 0.72 + cocoon_rupture_flash, 0, 1.25);
    if (_crack_a > 0.015) {
        for (var _cci = 0; _cci < array_length(cocoon_cracks); _cci++) {
            var _cc = cocoon_cracks[_cci];
            var _ca = _cc.ang + sin(current_time * 0.018 + cocoon_seed + _cci) * (1.5 + unstable * 2.5);
            var _r0 = _cocoon_r * _cc.inner;
            var _r1 = min(_cocoon_r * 1.04, _r0 + _cc.len * (0.48 + unstable * 0.55 + cocoon_crack_flash * 0.28 + cocoon_rupture_flash * 0.6));
            var _x0 = _dx + lengthdir_x(_r0, _ca);
            var _y0 = _dy + lengthdir_y(_r0, _ca);
            var _x1 = _dx + lengthdir_x(_r1, _ca + _cc.bend * 0.22);
            var _y1 = _dy + lengthdir_y(_r1, _ca + _cc.bend * 0.22);

            draw_set_color(global.avoid_col_cyan_soft);
            draw_set_alpha(_crack_a * 0.34);
            draw_line_width(_x0, _y0, _x1, _y1, 2.0);
            draw_set_color(c_white);
            draw_set_alpha(_crack_a * 0.55);
            draw_line_width(_x0, _y0, _x1, _y1, 0.8);

            if (_crack_a > 0.35) {
                var _sx = lerp(_x0, _x1, 0.58);
                var _sy = lerp(_y0, _y1, 0.58);
                var _sl = _cc.len * 0.42 * clamp(_crack_a, 0, 1);
                draw_set_alpha(_crack_a * 0.34);
                draw_line_width(_sx, _sy,
                                _sx + lengthdir_x(_sl, _ca + _cc.split),
                                _sy + lengthdir_y(_sl, _ca + _cc.split), 0.75);
            }
        }
    }

    if (cocoon_rupture_flash > 0.01) {
        var _rupt_a = clamp(cocoon_rupture_flash, 0, 1);
        draw_set_color(c_white);
        draw_set_alpha(_rupt_a * 0.72);
        draw_circle(_dx, _dy, _cocoon_r * (1.0 + (1 - _rupt_a) * 0.4), true);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
shader_set(shd_bullet_glow);
var _uvsf = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvsf[0], _uvsf[1], _uvsf[2], _uvsf[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(_sap_col) / 255, color_get_green(_sap_col) / 255,
                     color_get_blue(_sap_col) / 255);
shader_set_uniform_f(global.u_glow_intensity, (0.18 + _ripe_heat * 0.75 + crack_glow * 0.8) * image_alpha);
shader_set_uniform_f(global.u_glow_falloff, 1.45);
draw_sprite_ext(spr_glow_blob, 0, _dx, _dy, image_xscale * (0.62 + unstable * 0.22),
                image_yscale * (0.62 + unstable * 0.22), 0, c_white, 1);
shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
shader_set_uniform_f(global.u_glow_intensity, (0.3 + base_alpha * 0.5 + crack_glow * 1.2) * image_alpha);
shader_set_uniform_f(global.u_glow_falloff, 2.3);
draw_sprite_ext(spr_glow_blob, 0, _dx, _dy, image_xscale * 0.35, image_yscale * 0.35, 0, c_white, 1);
shader_reset();
gpu_set_blendmode(bm_normal);

if (unstable > 0.15) {
    if (array_length(stress_cracks) == 0) {
        var _sc_count = irandom_range(3, 5);
        for (var sci = 0; sci < _sc_count; sci++) {
            array_push(stress_cracks, {ang: random(360), len: random_range(5, 10)});
        }
    }
    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_core_col, global.avoid_col_danger, 0.5));
    draw_set_alpha(unstable * 0.9);
    for (var sci = 0; sci < array_length(stress_cracks); sci++) {
        var _sc = stress_cracks[sci];
        var _jit2 = sin(current_time * 0.03 + sci * 11) * 1.5 * unstable;
        var _scx = _dx + lengthdir_x(_sc.len + _jit2, _sc.ang);
        var _scy = _dy + lengthdir_y(_sc.len + _jit2, _sc.ang);
        draw_line_width(_dx, _dy, _scx, _scy, 1.2);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
