if (laser_meteor_visual) {
    var _rx = 9 * abs(image_xscale);
    var _ry = 9 * abs(image_yscale);
    var _rmin = max(1, min(_rx, _ry));
    var _active = is_popped;
    var _core_base = _active ? global.avoid_col_danger : global.avoid_col_cyan;
    var _core_hot = _active ? global.avoid_col_hot : global.avoid_col_cyan_soft;
    var _flash = _active
               ? clamp(1 - (pop_flash_timer / max(_k_pop_flash_duration, 1)), 0, 1)
               : clamp(1 - (spawn_flash_timer / max(spawn_flash_duration, 1)), 0, 1);
    var _heat = clamp((_active ? 0.58 : 0.18) + image_alpha * 0.35 + _flash * 0.3, 0, 1);
    var _spin = image_angle + laser_meteor_spin_seed + current_time * (_active ? 0.045 : 0.018);
    var _body_a = clamp(image_alpha + (_active ? 0.08 : 0.12), 0, 1);

    if (_active && array_length(trail_positions) > 1) {
        var _tn = array_length(trail_positions);
        var _fall_dir = point_direction(xprevious, yprevious, x, y);

        gpu_set_blendmode(bm_add);
        draw_primitive_begin(pr_trianglestrip);
        for (var _ti = 0; _ti < _tn; _ti++) {
            var _tp = trail_positions[_ti];
            var _tx = _tp[0];
            var _ty = _tp[1];
            var _u = _ti / max(_tn - 1, 1);
            var _dirn = _fall_dir;
            if (_ti < _tn - 1) {
                var _nxt = trail_positions[_ti + 1];
                if (point_distance(_tx, _ty, _nxt[0], _nxt[1]) > 0.01) {
                    _dirn = point_direction(_tx, _ty, _nxt[0], _nxt[1]);
                }
            } else if (_ti > 0) {
                var _prv = trail_positions[_ti - 1];
                if (point_distance(_prv[0], _prv[1], _tx, _ty) > 0.01) {
                    _dirn = point_direction(_prv[0], _prv[1], _tx, _ty);
                }
            }

            var _tw = lerp(0.7, 3.4, _u) * max(_rmin / 9, 0.8);
            var _ta = image_alpha * power(_u, 1.6) * 0.38;
            var _nx = lengthdir_x(_tw, _dirn + 90);
            var _ny = lengthdir_y(_tw, _dirn + 90);
            var _tc = merge_color(global.avoid_col_blood, global.avoid_col_danger, _u);
            draw_vertex_color(_tx + _nx, _ty + _ny, _tc, _ta);
            draw_vertex_color(_tx - _nx, _ty - _ny, _tc, _ta);
        }
        draw_primitive_end();

        for (var _si = 1; _si < _tn; _si += 2) {
            var _sa = _si / max(_tn - 1, 1);
            if (_sa < 0.22) continue;
            var _a0 = trail_positions[_si - 1];
            var _a1 = trail_positions[_si];
            draw_set_color(merge_color(global.avoid_col_danger, global.avoid_col_hot, _sa * 0.45));
            draw_set_alpha(image_alpha * _sa * _sa * 0.36);
            draw_line_width(_a0[0], _a0[1], _a1[0], _a1[1], max(0.8, _rmin * 0.13));
            if (_si mod 4 == 1) {
                draw_set_color(c_white);
                draw_set_alpha(image_alpha * _sa * 0.22);
                draw_line_width(_a0[0], _a0[1], _a1[0], _a1[1], max(0.7, _rmin * 0.055));
            }
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
        var _plate_col = merge_color(global.avoid_col_armor_dark, global.avoid_col_armor_mid, 0.20 + _heat * 0.22);
        var _rim_col = merge_color(global.avoid_col_armor_edge, c_white, _flash * 0.28);
        var _core_col = merge_color(_core_base, _core_hot, 0.18 + _heat * 0.36);

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

        draw_set_color(merge_color(global.avoid_col_armor_dark, _core_base, 0.34));
        draw_set_alpha(_body_a * 0.55);
        draw_ellipse(x - _core_rx * 1.42, y - _core_ry * 1.42,
                     x + _core_rx * 1.42, y + _core_ry * 1.42, false);

        draw_set_color(_core_col);
        draw_set_alpha(_body_a * (0.82 + _flash * 0.12));
        draw_ellipse(x - _core_rx, y - _core_ry, x + _core_rx, y + _core_ry, false);

        draw_set_color(merge_color(_core_base, c_white, 0.26 + _flash * 0.34));
        draw_set_alpha(_body_a * (0.42 + _heat * 0.3));
        draw_ellipse(x - _core_rx * 1.7, y - _core_ry * 1.7,
                     x + _core_rx * 1.7, y + _core_ry * 1.7, true);

        draw_set_color(c_white);
        draw_set_alpha(_body_a * (0.12 + _flash * 0.46));
        draw_ellipse(x - _core_rx * 0.32, y - _core_ry * 0.32,
                     x + _core_rx * 0.32, y + _core_ry * 0.32, false);

        gpu_set_blendmode(bm_add);
        draw_set_color(_core_base);
        draw_set_alpha(_body_a * (0.12 + _heat * 0.16));
        draw_ellipse(x - _rx * 1.15, y - _ry * 1.15, x + _rx * 1.15, y + _ry * 1.15, false);

        var _arc_count = _active ? 2 : 1;
        for (var _j = 0; _j < _arc_count; _j++) {
            var _ja = _spin + sin(laser_meteor_core_phase + current_time * 0.006 + _j * 3.1) * 26 + _j * 180;
            var _jr0 = _rmin * 0.72;
            var _jr1 = _rmin * (1.02 + _flash * 0.2);
            draw_set_color(merge_color(_core_base, c_white, _flash * 0.35));
            draw_set_alpha(_body_a * (_active ? (0.25 + _flash * 0.35) : 0.22));
            draw_line_width(x + lengthdir_x(_jr0, _ja), y + lengthdir_y(_jr0, _ja),
                            x + lengthdir_x(_jr1, _ja + 10), y + lengthdir_y(_jr1, _ja + 10),
                            max(0.8, _rmin * 0.08));
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    if (!is_popped && spawn_flash_timer < spawn_flash_duration) {
        var _sp = spawn_flash_timer / max(spawn_flash_duration, 1);
        var _flash_alpha = (1 - _sp) * _k_spawn_flash_peak_intensity;
        var _flash_scale = lerp(_k_spawn_flash_peak_scale, 1, _sp) * base_scale;

        gpu_set_blendmode(bm_add);
        shader_set(shd_bullet_glow);
        var _uvs = sprite_get_uvs(spr_glow_blob, 0);
        shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
        shader_set_uniform_f(global.u_glow_color,
            color_get_red(global.avoid_col_cyan) / 255, color_get_green(global.avoid_col_cyan) / 255,
            color_get_blue(global.avoid_col_cyan) / 255);
        shader_set_uniform_f(global.u_glow_intensity, _flash_alpha);
        shader_set_uniform_f(global.u_glow_falloff, 2.0);
        draw_sprite_ext(spr_glow_blob, 0, x, y, _flash_scale * 0.6, _flash_scale * 0.6, 0, c_white, 1);
        shader_reset();
        gpu_set_blendmode(bm_normal);
    }

    if (is_popped && pop_flash_timer > 0 && pop_flash_timer < _k_pop_flash_duration) {
        var _pf = 1 - (pop_flash_timer / max(_k_pop_flash_duration, 1));
        gpu_set_blendmode(bm_add);
        scr_draw_smooth_ring_mask(x, y, 8 + (1 - _pf) * 34, _pf * 0.58, 4 + _pf * 4,
                                  merge_color(global.avoid_col_warning, c_white, 0.4));
        draw_set_color(c_white);
        draw_set_alpha(_pf * 0.68);
        draw_circle(x, y, 2.4 + _pf * 4.5, false);
        draw_set_alpha(1);
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
    exit;
}

draw_self();

if (!is_popped && spawn_flash_timer < spawn_flash_duration) {
    var _p = spawn_flash_timer / spawn_flash_duration;
    var _flash_alpha = (1 - _p) * _k_spawn_flash_peak_intensity;
    var _flash_scale = lerp(_k_spawn_flash_peak_scale, 1, _p) * base_scale;

    gpu_set_blendmode(bm_add);
    shader_set(shd_bullet_glow);
    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_color,
        color_get_red(_k_spawn_flash_color) / 255, color_get_green(_k_spawn_flash_color) / 255,
        color_get_blue(_k_spawn_flash_color) / 255);
    shader_set_uniform_f(global.u_glow_intensity, _flash_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    draw_sprite_ext(spr_glow_blob, 0, x, y, _flash_scale * 0.6, _flash_scale * 0.6, 0, c_white, 1);
    shader_reset();
    gpu_set_blendmode(bm_normal);
}
