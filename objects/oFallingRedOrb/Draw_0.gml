event_inherited();

if (rain_orb) {
    var _rx = 9 * abs(image_xscale);
    var _ry = 9 * abs(image_yscale);
    var _rmin = max(1, min(_rx, _ry));
    var _fall_speed = point_distance(xprevious, yprevious, x, y);
    var _fall_dir = (_fall_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : 270;
    var _active = glowing && !telegraphing && !dissolving;
    var _armed = tether_state >= 1 && tether_state < 3;
    var _charge = clamp(tether_charge + arm_flash * 0.45 + socket_heat * 0.45 + (_active ? 0.38 : 0), 0, 1.35);
    var _flash = clamp(_charge + (pop_flash_timer > 0 ? (1 - pop_flash_timer / max(pop_flash_duration, 1)) : 0), 0, 1);
    var _heat = clamp(0.22 + _charge * 0.5 + image_alpha * 0.45 + (is_hailstone ? 0.18 : 0), 0, 1);
    var _dissolve_body = dissolving ? power(max(0, 1 - dissolve_prog), 1.35) : 1;
    var _spin = image_angle + rain_material_spin;
    var _handoff_fade = 1;
    if (dissolving && instance_exists(oAvoidanceController)) {
        var _hf = clamp((oAvoidanceController.t - 1856) / 16, 0, 1);
        _handoff_fade = 1 - (_hf * _hf * (3 - 2 * _hf));
    }
    var _body_a = clamp(image_alpha * _dissolve_body * _handoff_fade + (_armed ? 0.10 : 0) + (_active ? 0.08 : 0), 0, 1);

    if (_active && array_length(trail_positions) > 1) {
        var _tn = array_length(trail_positions);
        gpu_set_blendmode(bm_add);

        draw_primitive_begin(pr_trianglestrip);
        for (var i = 0; i < _tn; i++) {
            var _tp = trail_positions[i];
            var _u = i / max(_tn - 1, 1);
            var _dirn = _fall_dir;
            if (i < _tn - 1) {
                var _nxt = trail_positions[i + 1];
                if (point_distance(_tp.x, _tp.y, _nxt.x, _nxt.y) > 0.01) {
                    _dirn = point_direction(_tp.x, _tp.y, _nxt.x, _nxt.y);
                }
            } else if (i > 0) {
                var _prv = trail_positions[i - 1];
                if (point_distance(_prv.x, _prv.y, _tp.x, _tp.y) > 0.01) {
                    _dirn = point_direction(_prv.x, _prv.y, _tp.x, _tp.y);
                }
            }

            var _tw = lerp(0.6, is_hailstone ? 5.2 : 3.2, _u) * max(_rmin / 9, 0.8);
            var _ta = image_alpha * power(_u, 1.65) * (is_hailstone ? 0.58 : 0.36);
            var _nx = lengthdir_x(_tw, _dirn + 90);
            var _ny = lengthdir_y(_tw, _dirn + 90);
            var _tc = merge_color(global.avoid_col_blood, global.avoid_col_danger, _u);
            draw_vertex_color(_tp.x + _nx, _tp.y + _ny, _tc, _ta);
            draw_vertex_color(_tp.x - _nx, _tp.y - _ny, _tc, _ta);
        }
        draw_primitive_end();

        for (var si = 1; si < _tn; si += 2) {
            var _sa = si / max(_tn - 1, 1);
            if (_sa < 0.26) continue;
            var _a0 = trail_positions[si - 1];
            var _a1 = trail_positions[si];
            var _seg_col = merge_color(global.avoid_col_danger, global.avoid_col_hot, _sa * 0.45);
            draw_set_color(_seg_col);
            draw_set_alpha(image_alpha * _sa * _sa * (is_hailstone ? 0.54 : 0.34));
            draw_line_width(_a0.x, _a0.y, _a1.x, _a1.y, max(0.8, _rmin * 0.13));
            if (si mod 4 == 1) {
                draw_set_color(c_white);
                draw_set_alpha(image_alpha * _sa * 0.22);
                draw_line_width(_a0.x, _a0.y, _a1.x, _a1.y, max(0.7, _rmin * 0.055));
            }
        }

        for (var gi = _tn - 2; gi >= 0; gi -= (is_hailstone ? 3 : 4)) {
            var _gp = trail_positions[gi];
            var _gu = gi / max(_tn - 1, 1);
            if (_gu < 0.22) continue;
            var _g_alpha = image_alpha * power(_gu, 2) * (is_hailstone ? 0.34 : 0.22);
            scr_draw_core_cell_ghost(_gp.x, _gp.y, _rmin * lerp(0.58, 0.92, _gu),
                                     _spin - gi * 8, _fall_dir, lerp(1.15, 1.7, _gu),
                                     _g_alpha, 0.4 + _heat * 0.5);
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    if (_body_a > 0.02 && _rx > 1 && _ry > 1) {
        var _body_rx = max(2, _rx * 0.96);
        var _body_ry = max(2, _ry * 0.96);
        var _core_rx = max(1.6, _rx * 0.36);
        var _core_ry = max(1.6, _ry * 0.36);
        var _plate_col = merge_color(global.avoid_col_armor_dark, global.avoid_col_armor_mid, 0.22 + _heat * 0.22);
        var _rim_col = merge_color(global.avoid_col_armor_edge, c_white, _flash * 0.28);
        var _core_col = merge_color(global.avoid_col_danger, global.avoid_col_hot, 0.18 + _heat * 0.36);

        gpu_set_blendmode(bm_normal);
        draw_set_color(_plate_col);
        draw_set_alpha(_body_a * 0.96);
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(x, y);
        for (var _h = 0; _h <= 8; _h++) {
            var _ha = _spin + _h * 45;
            draw_vertex(x + dcos(_ha) * _body_rx, y + dsin(_ha) * _body_ry);
        }
        draw_primitive_end();

        var _px = x + dcos(_spin) * _body_rx;
        var _py = y + dsin(_spin) * _body_ry;
        draw_set_color(_rim_col);
        draw_set_alpha(_body_a * (0.48 + _heat * 0.28));
        for (var _e = 1; _e <= 8; _e++) {
            var _ea = _spin + _e * 45;
            var _ex = x + dcos(_ea) * _body_rx;
            var _ey = y + dsin(_ea) * _body_ry;
            draw_line_width(_px, _py, _ex, _ey, max(1, _rmin * 0.13));
            _px = _ex;
            _py = _ey;
        }

        for (var _p = 0; _p < 4; _p++) {
            var _pa = _spin + 45 + _p * 90;
            draw_set_color(global.avoid_col_armor_edge);
            draw_set_alpha(_body_a * 0.26);
            draw_line_width(x + dcos(_pa) * _rmin * 0.58, y + dsin(_pa) * _rmin * 0.58,
                            x + dcos(_pa) * _rmin * 0.92, y + dsin(_pa) * _rmin * 0.92,
                            max(0.8, _rmin * 0.08));
        }

        draw_set_color(global.avoid_col_blood);
        draw_set_alpha(_body_a * 0.55);
        draw_ellipse(x - _core_rx * 1.42, y - _core_ry * 1.42,
                     x + _core_rx * 1.42, y + _core_ry * 1.42, false);

        draw_set_color(_core_col);
        draw_set_alpha(_body_a * (0.82 + _flash * 0.12));
        draw_ellipse(x - _core_rx, y - _core_ry, x + _core_rx, y + _core_ry, false);

        draw_set_color(merge_color(global.avoid_col_danger, c_white, 0.28 + _flash * 0.32));
        draw_set_alpha(_body_a * (0.42 + _heat * 0.3));
        draw_ellipse(x - _core_rx * 1.7, y - _core_ry * 1.7,
                     x + _core_rx * 1.7, y + _core_ry * 1.7, true);

        draw_set_color(c_white);
        draw_set_alpha(_body_a * (0.16 + _flash * 0.44));
        draw_ellipse(x - _core_rx * 0.32, y - _core_ry * 0.32,
                     x + _core_rx * 0.32, y + _core_ry * 0.32, false);

        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha(_body_a * (0.12 + _heat * 0.14));
        draw_ellipse(x - _rx * 1.15, y - _ry * 1.15, x + _rx * 1.15, y + _ry * 1.15, false);

        if (_armed || _active) {
            draw_set_color(merge_color(global.avoid_col_warning, c_white, _flash * 0.35));
            draw_set_alpha(_body_a * (0.25 + _flash * 0.35));
            for (var _j = 0; _j < 2; _j++) {
                var _ja = _spin + sin(rain_core_phase + t * 0.8 + _j * 3.1) * 26 + _j * 180;
                var _jr0 = _rmin * 0.72;
                var _jr1 = _rmin * (1.05 + _flash * 0.18);
                draw_line_width(x + lengthdir_x(_jr0, _ja), y + lengthdir_y(_jr0, _ja),
                                x + lengthdir_x(_jr1, _ja + 10), y + lengthdir_y(_jr1, _ja + 10),
                                max(0.8, _rmin * 0.08));
            }
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    if (glowing && pop_flash_timer > 0 && pop_flash_timer < pop_flash_duration) {
        var _pf = 1 - (pop_flash_timer / max(pop_flash_duration, 1));
        var _pf_hot = is_hailstone ? 1.5 : 1;

        gpu_set_blendmode(bm_add);

        scr_draw_smooth_ring_mask(x, y, (8 + (1 - _pf) * 34) * _pf_hot, _pf * 0.58, 4 + _pf * 4,
                                  merge_color(global.avoid_col_warning, c_white, 0.4));

        var _rk = point_distance(0, 0, knock_vx, knock_vy);
        if (_rk > 0.2) {
            var _rk_dir = point_direction(0, 0, knock_vx, knock_vy);
            var _rk_len = (12 + _rk * 5) * _pf;
            draw_set_color(global.avoid_col_warning);
            draw_set_alpha(_pf * 0.5);
            draw_line_width(x, y,
                            x + lengthdir_x(_rk_len, _rk_dir),
                            y + lengthdir_y(_rk_len, _rk_dir), 2.1);
        }

        draw_set_color(c_white);
        draw_set_alpha(_pf * 0.68);
        draw_circle(x, y, (2.4 + _pf * 4.5) * _pf_hot, false);

        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }

    if (dissolving) {
        var _beam_alpha = (1 - dissolve_prog) * 0.8 * _handoff_fade;
        var _beam_len = 70 + dissolve_prog * 40;
        gpu_set_blendmode(bm_add);
        if (_beam_alpha > 0.01) {
            draw_set_color(c_white);
            draw_set_alpha(_beam_alpha);
            draw_line_width(x, y, x, y - _beam_len, lerp(6, 0.5, dissolve_prog));
            draw_set_alpha(_beam_alpha * 0.5);
            draw_circle(x, y, 10 * (1 - dissolve_prog) + 2, false);
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
    exit;
}

if (glowing && array_length(trail_positions) > 1) {
    var _tn = array_length(trail_positions);
    var _trail_col = (mill_orb && mill_gate_cyan) ? global.avoid_col_cyan
                   : (is_hailstone ? c_white : c_red);

    gpu_set_blendmode(bm_add);
    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_color,
        color_get_red(_trail_col) / 255, color_get_green(_trail_col) / 255, color_get_blue(_trail_col) / 255);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    for (var i = 0; i < _tn; i++) {
        var _tp = trail_positions[i];
        var _age = i / max(_tn - 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, _age * _age * (is_hailstone ? 1.4 : 0.8));
        draw_sprite_ext(spr_glow_blob, 0, _tp.x, _tp.y, lerp(0.15, 0.5, _age) * _size, lerp(0.15, 0.5, _age) * _size,
                        0, c_white, 1);
    }
    shader_reset();
    gpu_set_blendmode(bm_normal);
}

if (glowing && array_length(trail_positions) > 1) {
    var _fall_speed = point_distance(xprevious, yprevious, x, y);
    var _fall_dir = (_fall_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : 270;

    var _gn = array_length(trail_positions);
    var _k_ghost_step = is_hailstone ? 2 : 3;
    gpu_set_blendmode(bm_add);
    for (var gi = 0; gi < _gn; gi += _k_ghost_step) {
        var _gp = trail_positions[gi];
        var _gage = gi / max(_gn - 1, 1);
        var _gscale = _size * lerp(0.35, 0.95, _gage);
        draw_sprite_ext(sprite_index, image_index, _gp.x, _gp.y, _gscale, _gscale, image_angle,
                        merge_color(image_blend, c_white, _gage * 0.5),
                        _gage * _gage * (is_hailstone ? 0.5 : 0.3));
    }
    gpu_set_blendmode(bm_normal);

    if (_fall_speed > 3) {
        var _f_tail = min(_fall_speed * 2.2, is_hailstone ? 60 : 38);
        var _f_tx = x - lengthdir_x(_f_tail, _fall_dir);
        var _f_ty = y - lengthdir_y(_f_tail, _fall_dir);
        var _f_perp = _fall_dir + 90;
        var _f_off = (is_hailstone ? 3.5 : 2) * fx_get_mult("aberration");
        var _f_w = is_hailstone ? 6 : 3.5;

        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha(0.35 * image_alpha);
        draw_line_width(_f_tx + lengthdir_x(_f_off, _f_perp), _f_ty + lengthdir_y(_f_off, _f_perp),
                        x + lengthdir_x(_f_off, _f_perp), y + lengthdir_y(_f_off, _f_perp), _f_w);
        draw_set_color(global.avoid_col_cyan);
        draw_line_width(_f_tx - lengthdir_x(_f_off, _f_perp), _f_ty - lengthdir_y(_f_off, _f_perp),
                        x - lengthdir_x(_f_off, _f_perp), y - lengthdir_y(_f_off, _f_perp), _f_w);
        draw_set_color(c_white);
        draw_set_alpha(0.65 * image_alpha);
        draw_line_width(_f_tx, _f_ty, x, y, _f_w * 0.35);
        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }
}

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha);
gpu_set_blendmode(bm_normal);

if (rain_orb && glowing && pop_flash_timer > 0 && pop_flash_timer < pop_flash_duration) {
    var _pf = 1 - (pop_flash_timer / max(pop_flash_duration, 1));
    var _pf_hot = is_hailstone ? 1.5 : 1;

    gpu_set_blendmode(bm_add);

    scr_draw_smooth_ring_mask(x, y, (8 + (1 - _pf) * 34) * _pf_hot, _pf * 0.7, 4 + _pf * 4,
                              merge_color(global.avoid_col_warning, c_white, 0.45));

    var _rk = point_distance(0, 0, knock_vx, knock_vy);
    if (_rk > 0.2) {
        var _rk_dir = point_direction(0, 0, knock_vx, knock_vy);
        var _rk_len = (12 + _rk * 5) * _pf;
        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_pf * 0.6);
        draw_line_width(x, y,
                        x + lengthdir_x(_rk_len, _rk_dir),
                        y + lengthdir_y(_rk_len, _rk_dir), 2.4);
    }

    draw_set_color(c_white);
    draw_set_alpha(_pf * 0.85);
    draw_circle(x, y, (3 + _pf * 5) * _pf_hot, false);

    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (dissolving) {
    var _beam_alpha = (1 - dissolve_prog) * 0.8;
    var _beam_len = 70 + dissolve_prog * 40;
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(_beam_alpha);
    draw_line_width(x, y, x, y - _beam_len, lerp(6, 0.5, dissolve_prog));
    draw_set_alpha(_beam_alpha * 0.5);
    draw_circle(x, y, 10 * (1 - dissolve_prog) + 2, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
}
