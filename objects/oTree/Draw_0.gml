var _angle = image_angle;

if (spawn_snap > 0)
{
    _angle += random_range(-spawn_snap, spawn_snap);
}

var _clearing_mult = 1;
if (instance_exists(oAvoidanceController)) {
    var _ctrl = oAvoidanceController;
    if (_ctrl.storm_sphere_visibility > 0.001) {
        var _clear_radius = _ctrl._k_storm_clearing_radius;
        var _dist_to_orb = point_distance(x, y, _ctrl.storm_orb_x, _ctrl.storm_orb_y);
        if (_dist_to_orb < _clear_radius) {
            var _edge_band = 16;
            var _dim_target = _ctrl._k_storm_dim_alpha;
            if (_dist_to_orb > _clear_radius - _edge_band) {
                var _edge_t = (_clear_radius - _dist_to_orb) / _edge_band;
                _dim_target = lerp(1, _ctrl._k_storm_dim_alpha, _edge_t);
            }
            _clearing_mult = lerp(1, _dim_target, _ctrl.storm_sphere_visibility);
        }
    }
}

var _draw_alpha = image_alpha * _clearing_mult;
var _branch_heat = clamp(branch_heat + branch_network_flash * 0.65, 0, 1);
var _branch_current = clamp(branch_current + branch_network_flash, 0, 1.4);
var _body_col = merge_color(global.avoid_col_armor_dark, global.avoid_col_blood, 0.35 + _branch_heat * 0.45);
var _bark_black = merge_color(c_black, global.avoid_col_blood, 0.18 + _branch_heat * 0.18);
var _bark_ridge_col = merge_color(global.avoid_col_armor_dark, c_black, 0.32);
var _sap_col = merge_color(global.avoid_col_blood, ignite_color_hot, _branch_heat);
var _edge_col = merge_color(ignite_color_unlit, global.avoid_col_danger, _branch_heat);
var _hot_col = merge_color(_sap_col, c_white, clamp(_branch_heat * 0.65 + branch_network_flash * 0.35, 0, 0.9));
var _has_parent = point_distance(x, y, branch_parent_x, branch_parent_y) > 1;

if (_has_parent && _draw_alpha > 0.01) {
    var _seg_dir = point_direction(branch_parent_x, branch_parent_y, x, y);
    var _seg_perp = _seg_dir + 90;
    var _w_child = max(1.45, base_scale * 2.75);
    var _w_parent = max(_w_child, branch_parent_scale * 2.45);
    var _role_mass = 1 + branch_role * 0.12;
    _w_child *= _role_mass;
    _w_parent *= _role_mass;
    var _px1 = branch_parent_x + lengthdir_x(_w_parent, _seg_perp);
    var _py1 = branch_parent_y + lengthdir_y(_w_parent, _seg_perp);
    var _px2 = branch_parent_x - lengthdir_x(_w_parent, _seg_perp);
    var _py2 = branch_parent_y - lengthdir_y(_w_parent, _seg_perp);
    var _cx1 = x + lengthdir_x(_w_child, _seg_perp);
    var _cy1 = y + lengthdir_y(_w_child, _seg_perp);
    var _cx2 = x - lengthdir_x(_w_child, _seg_perp);
    var _cy2 = y - lengthdir_y(_w_child, _seg_perp);

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_draw_alpha * (0.22 + branch_role * 0.08));
    draw_line_width(branch_parent_x + 1.5, branch_parent_y + 2, x + 1.5, y + 2, max(_w_parent * 2.05, 5));

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_px1, _py1, _body_col, _draw_alpha * 0.74);
    draw_vertex_colour(_px2, _py2, _body_col, _draw_alpha * 0.74);
    draw_vertex_colour(_cx1, _cy1, _body_col, _draw_alpha * 0.88);
    draw_vertex_colour(_cx2, _cy2, _body_col, _draw_alpha * 0.88);
    draw_primitive_end();

    draw_set_color(merge_color(_body_col, c_black, 0.28));
    draw_set_alpha(_draw_alpha * 0.55);
    draw_line_width(branch_parent_x, branch_parent_y, x, y, max(_w_child * 1.25, 2.4));

    var _ridge_off = max(1.4, _w_child * 0.42);
    draw_set_color(_bark_ridge_col);
    draw_set_alpha(_draw_alpha * 0.52);
    draw_line_width(branch_parent_x + lengthdir_x(_ridge_off, _seg_perp),
                    branch_parent_y + lengthdir_y(_ridge_off, _seg_perp),
                    x + lengthdir_x(_ridge_off * 0.72, _seg_perp),
                    y + lengthdir_y(_ridge_off * 0.72, _seg_perp),
                    max(0.9, _w_child * 0.22));
    draw_line_width(branch_parent_x - lengthdir_x(_ridge_off, _seg_perp),
                    branch_parent_y - lengthdir_y(_ridge_off, _seg_perp),
                    x - lengthdir_x(_ridge_off * 0.72, _seg_perp),
                    y - lengthdir_y(_ridge_off * 0.72, _seg_perp),
                    max(0.9, _w_child * 0.18));

    gpu_set_blendmode(bm_add);
    draw_set_color(_sap_col);
    draw_set_alpha(_draw_alpha * (0.20 + _branch_heat * 0.24));
    draw_line_width(branch_parent_x, branch_parent_y, x, y, max(_w_child * 0.72, 1.4));

    if (_branch_current > 0.05) {
        var _flow_count = 1 + floor(clamp(_branch_current, 0, 1.4) * 2.2);
        var _pulse_len = clamp(0.15 + _branch_current * 0.13, 0.15, 0.38);
        var _vein_w = max(1.0, _w_child * 0.3);

        for (var _fi = 0; _fi < _flow_count; _fi++) {
            var _phase = _fi / max(1, _flow_count);
            var _pulse = frac(current_time * (0.0011 + _branch_current * 0.00065) + vein_seed * 0.013 + _phase);
            var _ta = clamp(_pulse - _pulse_len * 0.5, 0, 1);
            var _tb = clamp(_pulse + _pulse_len * 0.5, 0, 1);
            var _j0 = sin(vein_seed + current_time * 0.017 + _fi * 11.7) * _w_child * 0.12;
            var _j1 = cos(vein_seed * 0.7 + current_time * 0.019 + _fi * 9.3) * _w_child * 0.12;
            var _vx1 = lerp(branch_parent_x, x, _ta) + lengthdir_x(_j0, _seg_perp);
            var _vy1 = lerp(branch_parent_y, y, _ta) + lengthdir_y(_j0, _seg_perp);
            var _vx2 = lerp(branch_parent_x, x, _tb) + lengthdir_x(_j1, _seg_perp);
            var _vy2 = lerp(branch_parent_y, y, _tb) + lengthdir_y(_j1, _seg_perp);
            var _flow_col = (_fi mod 2 == 0)
                ? merge_color(global.avoid_col_cyan, c_white, _branch_heat * 0.35)
                : merge_color(_sap_col, c_white, 0.25 + _branch_heat * 0.35);

            draw_set_color(_flow_col);
            draw_set_alpha(_draw_alpha * clamp(_branch_current, 0, 1) * (0.32 + _branch_heat * 0.24));
            draw_line_width(_vx1, _vy1, _vx2, _vy2, _vein_w * (1.35 + _branch_heat * 0.45));
            draw_set_color(c_white);
            draw_set_alpha(_draw_alpha * clamp(_branch_current - 0.2, 0, 1) * 0.75);
            draw_line_width(_vx1, _vy1, _vx2, _vy2, max(0.75, _vein_w * 0.42));
        }
    }

    if (_branch_heat > 0.08) {
        draw_set_color(_hot_col);
        draw_set_alpha(_draw_alpha * _branch_heat * 0.75);
        draw_line_width(branch_parent_x, branch_parent_y, x, y, max(0.8, _w_child * 0.22));
    }

    var _seg_len = point_distance(branch_parent_x, branch_parent_y, x, y);
    if (_seg_len > 14 && branch_spur_count > 0) {
        gpu_set_blendmode(bm_normal);
        for (var _spi = 0; _spi < branch_spur_count; _spi++) {
            var _rnd0 = frac(abs(sin(bark_seed + _spi * 19.37) * 43758.5453));
            var _rnd1 = frac(abs(sin(bark_seed + _spi * 31.11) * 24634.6345));
            var _rnd2 = frac(abs(sin(bark_seed + _spi * 47.73) * 12615.1221));
            var _sf = lerp(0.16, 0.84, _rnd0);
            var _side = (_rnd1 < 0.5) ? -1 : 1;
            var _spur_len = lerp(5, 13 + branch_role * 4, _rnd2) * clamp(_seg_len / 60, 0.55, 1.1);
            var _spur_ang = _seg_perp + ((_side < 0) ? 180 : 0) + _side * (18 + _rnd2 * 28);
            var _spur_x = lerp(branch_parent_x, x, _sf);
            var _spur_y = lerp(branch_parent_y, y, _sf);
            var _spur_base_off = _w_child * lerp(0.26, 0.42, _sf);
            var _spur_bx = _spur_x + lengthdir_x(_spur_base_off * _side, _seg_perp);
            var _spur_by = _spur_y + lengthdir_y(_spur_base_off * _side, _seg_perp);
            var _spur_ex = _spur_bx + lengthdir_x(_spur_len, _spur_ang);
            var _spur_ey = _spur_by + lengthdir_y(_spur_len, _spur_ang);

            draw_set_color(_bark_black);
            draw_set_alpha(_draw_alpha * (0.42 + branch_role * 0.12));
            draw_line_width(_spur_bx, _spur_by, _spur_ex, _spur_ey, max(1.1, _w_child * 0.26));

            if (_branch_heat > 0.35 || branch_network_flash > 0.1) {
                gpu_set_blendmode(bm_add);
                draw_set_color(_hot_col);
                draw_set_alpha(_draw_alpha * clamp(_branch_heat + branch_network_flash, 0, 1) * 0.28);
                draw_line_width(_spur_bx, _spur_by,
                                lerp(_spur_bx, _spur_ex, 0.72),
                                lerp(_spur_by, _spur_ey, 0.72),
                                max(0.7, _w_child * 0.08));
                gpu_set_blendmode(bm_normal);
            }
        }
        gpu_set_blendmode(bm_add);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale, image_yscale * 0.86, _angle,
                merge_color(_body_col, image_blend, 0.42), _draw_alpha * 0.42);

if (_draw_alpha > 0.02 && (branch_child_count >= 2 || branch_is_leaf || branch_role >= 1)) {
    var _socket_r = base_scale * (branch_is_leaf ? 1.65 : 2.1);
    var _socket_a = _draw_alpha * (branch_is_leaf ? 0.5 : 0.38);
    gpu_set_blendmode(bm_normal);
    draw_set_color(_bark_black);
    draw_set_alpha(_socket_a);
    draw_circle(x, y, max(1.3, _socket_r), false);

    if (branch_child_count >= 2 || branch_is_leaf) {
        gpu_set_blendmode(bm_add);
        draw_set_color(_sap_col);
        draw_set_alpha(_draw_alpha * (0.18 + _branch_current * 0.16));
        draw_circle(x, y, max(1.0, _socket_r * 0.72), true);
        draw_set_color(c_white);
        draw_set_alpha(_draw_alpha * clamp(_branch_current + _branch_heat, 0, 1) * 0.24);
        draw_circle(x, y, max(0.8, _socket_r * 0.34), false);
    }
}

gpu_set_blendmode(bm_add);
draw_set_color(_edge_col);
draw_set_alpha(_draw_alpha * (0.16 + _branch_current * 0.18));
draw_circle(x, y, max(1.4, base_scale * 2.2), false);
if (_branch_heat > 0.05 || spawn_snap > 0.4) {
    draw_set_color(_hot_col);
    draw_set_alpha(_draw_alpha * (0.35 + _branch_heat * 0.45 + clamp(spawn_snap / 12, 0, 1) * 0.25));
    draw_circle(x, y, max(1.0, base_scale * 1.15), false);
    draw_set_color(c_white);
    draw_set_alpha(_draw_alpha * clamp(_branch_heat + branch_network_flash, 0, 1) * 0.55);
    draw_circle(x, y, max(0.8, base_scale * 0.55), false);
}
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

gpu_set_blendmode(bm_add);
shader_set(shd_bullet_glow);
var _uvs3 = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs3[0], _uvs3[1], _uvs3[2], _uvs3[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(image_blend) / 255, color_get_green(image_blend) / 255,
                     color_get_blue(image_blend) / 255);
shader_set_uniform_f(global.u_glow_intensity, glow_intensity * image_alpha * _clearing_mult);
shader_set_uniform_f(global.u_glow_falloff, 1.7);
draw_sprite_ext(spr_glow_blob, 0, x, y, image_xscale * 0.75, image_yscale * 1.6, _angle, c_white, 1);
shader_reset();
gpu_set_blendmode(bm_normal);

if (state == 1) {
    var _ign_p2 = clamp(state_timer / grow_duration, 0, 1);

    gpu_set_blendmode(bm_add);
    shader_set(shd_bullet_glow);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs3[0], _uvs3[1], _uvs3[2], _uvs3[3]);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, lerp(0.5, 1.6, _ign_p2) * _clearing_mult);
    shader_set_uniform_f(global.u_glow_falloff, 2.3);
    draw_sprite_ext(spr_glow_blob, 0, x, y, image_xscale * 0.35, image_yscale * 0.9, _angle, c_white, 1);
    shader_reset();

    var _perp2 = _angle + 90;
    var _half_len = image_xscale * sprite_get_width(sprite_index) * 0.5;
    var _fx1 = x + lengthdir_x(_half_len, _angle);
    var _fy1 = y + lengthdir_y(_half_len, _angle);
    var _fx2 = x - lengthdir_x(_half_len, _angle);
    var _fy2 = y - lengthdir_y(_half_len, _angle);
    var _foff2 = 2;
    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(0.35 * _ign_p2 * _clearing_mult);
    draw_line_width(_fx1 + lengthdir_x(_foff2, _perp2), _fy1 + lengthdir_y(_foff2, _perp2),
                    _fx2 + lengthdir_x(_foff2, _perp2), _fy2 + lengthdir_y(_foff2, _perp2), 2);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_fx1 - lengthdir_x(_foff2, _perp2), _fy1 - lengthdir_y(_foff2, _perp2),
                    _fx2 - lengthdir_x(_foff2, _perp2), _fy2 - lengthdir_y(_foff2, _perp2), 2);
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}

if (spawn_snap > 0.4) {
    var _flash_p = clamp(spawn_snap / 12, 0, 1);
    gpu_set_blendmode(bm_add);
    shader_set(shd_bullet_glow);
    var _uvs2 = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs2[0], _uvs2[1], _uvs2[2], _uvs2[3]);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, _flash_p * 1.5);
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    var _flash_scale = base_scale * 0.5 * (0.5 + _flash_p * 0.7);
    draw_sprite_ext(spr_glow_blob, 0, x, y, _flash_scale, _flash_scale, 0, c_white, 1);
    shader_reset();
    gpu_set_blendmode(bm_normal);
}

if (array_length(crack_points) > 0 && image_alpha > 0.05) {
    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(ignite_color_hot, c_white, 0.3));
    draw_set_alpha(image_alpha * 0.8 * _clearing_mult);
    for (var cc = 0; cc < array_length(crack_points); cc++) {
        var _cp = crack_points[cc];
        var _jit = sin(current_time * 0.02 + cc * 7) * 2;
        var _cex = x + lengthdir_x(_cp.len + _jit, _cp.ang);
        var _cey = y + lengthdir_y(_cp.len + _jit, _cp.ang);
        draw_line_width(x, y, _cex, _cey, 1.5);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
