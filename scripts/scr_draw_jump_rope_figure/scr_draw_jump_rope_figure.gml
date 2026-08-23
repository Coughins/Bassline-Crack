function scr_jr_ik(_rx, _ry, _tx, _ty, _l1, _l2, _bend) {
    var _dir = point_direction(_rx, _ry, _tx, _ty);
    var _d = clamp(point_distance(_rx, _ry, _tx, _ty), abs(_l1 - _l2) + 0.01, _l1 + _l2 - 0.01);

    var _a = (_l1 * _l1 - _l2 * _l2 + _d * _d) / (2 * _d);
    var _h = sqrt(max(_l1 * _l1 - _a * _a, 0));

    var _mx = _rx + lengthdir_x(_a, _dir);
    var _my = _ry + lengthdir_y(_a, _dir);

    return {
        x : _mx + lengthdir_x(_h, _dir + 90 * _bend),
        y : _my + lengthdir_y(_h, _dir + 90 * _bend)
    };
}

function scr_jr_limb(_x1, _y1, _x2, _y2, _w1, _w2) {
    var _steps = 2;
    var _px = _x1, _py = _y1;
    for (var i = 1; i <= _steps; i++) {
        var _f = i / _steps;
        var _nx = lerp(_x1, _x2, _f);
        var _ny = lerp(_y1, _y2, _f);
        draw_line_width(_px, _py, _nx, _ny, lerp(_w1, _w2, _f));
        _px = _nx;
        _py = _ny;
    }
    draw_circle(_x1, _y1, _w1 * 0.5, false);
    draw_circle(_x2, _y2, _w2 * 0.5, false);
}

function scr_jr_metal_limb(_x1, _y1, _x2, _y2, _w1, _w2, _alpha, _heat, _accent, _seed) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _dl = max(0.001, sqrt(_dx * _dx + _dy * _dy));
    var _nx = -_dy / _dl;
    var _ny =  _dx / _dl;

    var _h1 = _w1 * 0.5;
    var _h2 = _w2 * 0.5;

    var _armor  = _k_er_col_armor_dark;
    var _armorm = _k_er_col_armor_mid;
    var _edge   = _k_er_col_armor_edge;
    var _blood  = global.avoid_col_blood;

    var _lip_hot = clamp(_heat * 0.55, 0, 1);
    var _lip_hi  = merge_color(merge_color(_armorm, _edge, 0.68), c_white, _lip_hot * 0.28);
    var _mass    = merge_color(_armor, _armorm, 0.36);
    var _core    = merge_color(_blood, _armor, 0.64);
    var _shade   = merge_color(c_black, _armor, 0.34);

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.54);
    draw_line_width(_x1, _y1, _x2, _y2, max(_w1, _w2) * 1.42);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_x1 - _nx * _h1,        _y1 - _ny * _h1,        _lip_hi, _alpha);
    draw_vertex_color(_x2 - _nx * _h2,        _y2 - _ny * _h2,        _lip_hi, _alpha);
    draw_vertex_color(_x1 - _nx * _h1 * 0.68, _y1 - _ny * _h1 * 0.68, _mass,   _alpha);
    draw_vertex_color(_x2 - _nx * _h2 * 0.68, _y2 - _ny * _h2 * 0.68, _mass,   _alpha);
    draw_vertex_color(_x1 - _nx * _h1 * 0.24, _y1 - _ny * _h1 * 0.24, _mass,   _alpha);
    draw_vertex_color(_x2 - _nx * _h2 * 0.24, _y2 - _ny * _h2 * 0.24, _mass,   _alpha);
    draw_vertex_color(_x1,                    _y1,                    _core,   _alpha);
    draw_vertex_color(_x2,                    _y2,                    _core,   _alpha);
    draw_vertex_color(_x1 + _nx * _h1 * 0.24, _y1 + _ny * _h1 * 0.24, _mass,   _alpha);
    draw_vertex_color(_x2 + _nx * _h2 * 0.24, _y2 + _ny * _h2 * 0.24, _mass,   _alpha);
    draw_vertex_color(_x1 + _nx * _h1 * 0.70, _y1 + _ny * _h1 * 0.70, _shade,  _alpha);
    draw_vertex_color(_x2 + _nx * _h2 * 0.70, _y2 + _ny * _h2 * 0.70, _shade,  _alpha);
    draw_vertex_color(_x1 + _nx * _h1,        _y1 + _ny * _h1,        c_black, _alpha * 0.82);
    draw_vertex_color(_x2 + _nx * _h2,        _y2 + _ny * _h2,        c_black, _alpha * 0.82);
    draw_primitive_end();

    gpu_set_blendmode(bm_add);
    var _seam_a = _alpha * (0.07 + _heat * 0.22);
    if (_seam_a > 0.01) {
        var _u0 = 0.20;
        var _u1 = 0.82;
        var _sx0 = lerp(_x1, _x2, _u0);
        var _sy0 = lerp(_y1, _y2, _u0);
        var _sx1 = lerp(_x1, _x2, _u1);
        var _sy1 = lerp(_y1, _y2, _u1);

        draw_set_color(merge_color(_accent, c_white, _heat * 0.35));
        draw_set_alpha(_seam_a);
        draw_line_width(_sx0, _sy0, _sx1, _sy1, max(0.75, min(_w1, _w2) * 0.16));

        draw_set_color(c_white);
        draw_set_alpha(_alpha * _heat * 0.20);
        draw_line_width(_sx0, _sy0, _sx1, _sy1, max(0.55, min(_w1, _w2) * 0.055));
    }

    if (_dl > 18) {
        draw_set_color(merge_color(_edge, c_white, 0.18));
        draw_set_alpha(_alpha * (0.12 + _heat * 0.10));
        for (var _p = 0; _p < 2; _p++) {
            var _u = 0.34 + _p * 0.32 + sin(_seed + _p * 2.1) * 0.025;
            var _tx = lerp(_x1, _x2, _u);
            var _ty = lerp(_y1, _y2, _u);
            var _tw = lerp(_h1, _h2, _u) * 0.70;
            draw_line_width(_tx - _nx * _tw, _ty - _ny * _tw,
                            _tx + _nx * _tw, _ty + _ny * _tw, 0.9);
        }
    }

    gpu_set_blendmode(bm_normal);
}

function scr_jr_joint(_x, _y, _r, _alpha, _heat, _accent, _major) {
    var _edge = _k_er_col_armor_edge;
    var _mass = merge_color(_k_er_col_armor_dark, _k_er_col_armor_mid, _major ? 0.72 : 0.48);
    var _ring = merge_color(_edge, c_white, 0.12 + _heat * 0.25);

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.82);
    draw_circle(_x, _y, _r * 1.48, false);
    draw_set_color(_mass);
    draw_set_alpha(_alpha);
    draw_circle(_x, _y, _r * 1.08, false);
    draw_set_color(_ring);
    draw_set_alpha(_alpha * (0.34 + _heat * 0.18));
    draw_circle(_x, _y, _r * 1.38, true);

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_accent, c_white, _heat * 0.42));
    draw_set_alpha(_alpha * (0.20 + _heat * 0.32));
    draw_circle(_x, _y, max(1, _r * 0.36), false);
    if (_major && _heat > 0.10) {
        draw_set_color(c_white);
        draw_set_alpha(_alpha * _heat * 0.28);
        draw_circle(_x, _y, _r * 0.18, false);
    }
    gpu_set_blendmode(bm_normal);
}

function scr_jr_head(_x, _y, _r, _facing, _alpha, _heat, _accent) {
    var _armor = _k_er_col_armor_dark;
    var _armorm = _k_er_col_armor_mid;
    var _edge = _k_er_col_armor_edge;

    gpu_set_blendmode(bm_normal);
    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.88);
    draw_circle(_x, _y, _r * 1.36, false);
    draw_set_color(merge_color(_armor, _armorm, 0.62));
    draw_set_alpha(_alpha);
    draw_circle(_x, _y, _r * 1.06, false);
    draw_set_color(merge_color(_armorm, _edge, 0.62));
    draw_set_alpha(_alpha * 0.42);
    draw_circle(_x, _y, _r * 1.16, true);

    draw_set_color(c_black);
    draw_set_alpha(_alpha * 0.34);
    draw_line_width(_x - _r * 0.72, _y + _r * 0.38,
                    _x + _r * 0.72, _y + _r * 0.22, max(1, _r * 0.22));

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_accent, c_white, 0.28 + _heat * 0.32));
    draw_set_alpha(_alpha * (0.22 + _heat * 0.34));
    draw_circle(_x + _facing * _r * 0.23, _y - _r * 0.05, _r * 0.34, false);
    draw_set_color(c_white);
    draw_set_alpha(_alpha * (0.16 + _heat * 0.26));
    draw_line_width(_x + _facing * _r * 0.02, _y - _r * 0.20,
                    _x + _facing * _r * 0.58, _y - _r * 0.20, max(0.8, _r * 0.12));
    gpu_set_blendmode(bm_normal);
}

function scr_draw_jump_rope_figure(_base_x, _hand_x, _hand_y, _facing, _floor_y, _bounce, _phase,
                                   _sprite, _color, _scale, _alpha = 1, _coil = 0, _lit = 0, _crank = 0,
                                   _additive = false) {
    if (_alpha <= 0.01) return;

    var _rest_blend = _additive ? bm_add : bm_normal;
    gpu_set_blendmode(_rest_blend);

    var _k_hip_h      = 33;
    var _k_chest_h    = 50;
    var _k_shoulder_h = 56;
    var _k_neck_h     = 61;
    var _k_head_h     = 69;
    var _k_head_r     = 7.5;
    var _k_shoulder_w = 6;
    var _k_hip_w      = 4.5;

    var _k_upper_arm  = 13;
    var _k_forearm    = 13;
    var _k_thigh      = 14;
    var _k_shin       = 14;

    var _lift = (_bounce * 5 - _coil * 7) * _scale;

    var _idle = sin(_phase * 2 + _base_x) * 1.2 * _scale;
    var _sway = sin(_phase) * 2.5 * _scale;

    var _hip_y      = _floor_y - _k_hip_h * _scale + _lift;
    var _chest_y    = _floor_y - _k_chest_h * _scale + _lift + _idle * 0.3;
    var _shoulder_y = _floor_y - _k_shoulder_h * _scale + _lift + _idle * 0.3;
    var _neck_y     = _floor_y - _k_neck_h * _scale + _lift + _idle * 0.4;
    var _head_y     = _floor_y - _k_head_h * _scale + _lift + _idle * 0.5;

    var _lean = (_coil * 4 + _bounce * -2) * _scale * _facing;
    var _hip_x   = _base_x + _sway * 0.2;
    var _chest_x = _base_x + _lean * 0.7 + _sway * 0.4;
    var _neck_x  = _base_x + _lean + _sway * 0.5;
    var _head_x  = _base_x + _lean * 1.1 + _sway * 0.55;

    var _front_foot_x = _base_x + _facing * 9 * _scale;
    var _back_foot_x  = _base_x - _facing * (8 + _coil * 4) * _scale;

    var _hip_f_x = _hip_x + _facing * _k_hip_w * _scale * 0.6;
    var _hip_b_x = _hip_x - _facing * _k_hip_w * _scale * 0.6;

    var _knee_f = scr_jr_ik(_hip_f_x, _hip_y, _front_foot_x, _floor_y,
                            _k_thigh * _scale, _k_shin * _scale, _facing);
    var _knee_b = scr_jr_ik(_hip_b_x, _hip_y, _back_foot_x, _floor_y,
                            _k_thigh * _scale, _k_shin * _scale, _facing);

    var _sh_in_x  = _neck_x + _facing * _k_shoulder_w * _scale;
    var _sh_out_x = _neck_x - _facing * _k_shoulder_w * _scale;

    var _elbow_in = scr_jr_ik(_sh_in_x, _shoulder_y, _hand_x, _hand_y,
                              _k_upper_arm * _scale, _k_forearm * _scale, -_facing);

    var _out_hand_x = _neck_x - _facing * (17 + _coil * 6) * _scale;
    var _out_hand_y = _shoulder_y + (14 - _coil * 8 + _bounce * 6) * _scale;
    var _elbow_out = scr_jr_ik(_sh_out_x, _shoulder_y, _out_hand_x, _out_hand_y,
                               _k_upper_arm * _scale, _k_forearm * _scale, _facing);

    if (!_additive) {
        var _rig_heat = clamp(_lit * 0.6 + _coil * 0.55 + _bounce * 0.25, 0, 1);
        var _rig_a = _alpha * (0.11 + _rig_heat * 0.42);
        if (_rig_a > 0.025) {
            var _rig_x = _base_x - _facing * (20 + _coil * 8) * _scale;
            var _rig_y = _floor_y - (150 + _lit * 10) * _scale;
            var _rig_col = merge_color(_k_er_col_violet, _k_er_col_warning, _rig_heat);

            gpu_set_blendmode(bm_add);
            draw_set_color(_rig_col);
            draw_set_alpha(_rig_a * 0.55);
            draw_line_width(_rig_x, _rig_y, _neck_x, _neck_y, max(1, 0.65 * _scale));
            draw_line_width(_rig_x - _facing * 7 * _scale, _rig_y + 8 * _scale,
                            _sh_out_x, _shoulder_y, max(1, 0.55 * _scale));
            draw_line_width(_rig_x + _facing * 6 * _scale, _rig_y + 11 * _scale,
                            _out_hand_x, _out_hand_y, max(1, 0.5 * _scale));

            draw_set_color(merge_color(_k_er_col_warning, _k_er_col_white, _rig_heat * 0.65));
            draw_set_alpha(_rig_a * 0.65);
            draw_circle(_neck_x, _neck_y, 4.4 * _scale, true);
            draw_circle(_rig_x, _rig_y, 3.2 * _scale, true);

            draw_set_color(c_white);
            draw_set_alpha(_rig_a * _rig_heat * 0.38);
            draw_line_width(_rig_x - _facing * 10 * _scale, _rig_y,
                            _rig_x + _facing * 10 * _scale, _rig_y, max(1, 0.55 * _scale));
            gpu_set_blendmode(_rest_blend);
        }
    }

    if (!_additive) {
        var _sh_w = (18 + _coil * 5) * _scale;
        draw_set_color(c_black);
        draw_set_alpha(_alpha * 0.35 * (1 - _bounce * 0.5));
        draw_ellipse(_base_x - _sh_w, _floor_y - 3 * _scale, _base_x + _sh_w, _floor_y + 3 * _scale, false);
    }

    if (_additive) {
        gpu_set_blendmode(bm_add);
        draw_set_color(_color);
        draw_set_alpha(_alpha);

        scr_jr_limb(_hip_x, _hip_y, _chest_x, _chest_y,
                    _k_hip_w * 2 * _scale, _k_shoulder_w * 1.7 * _scale);
        scr_jr_limb(_chest_x, _chest_y, _neck_x, _neck_y,
                    _k_shoulder_w * 1.7 * _scale, _k_shoulder_w * 0.9 * _scale);
        scr_jr_limb(_sh_out_x, _shoulder_y, _sh_in_x, _shoulder_y,
                    3 * _scale, 3 * _scale);
        scr_jr_limb(_hip_b_x, _hip_y, _knee_b.x, _knee_b.y,
                    4.4 * _scale, 3.4 * _scale);
        scr_jr_limb(_knee_b.x, _knee_b.y, _back_foot_x, _floor_y,
                    3.4 * _scale, 2.4 * _scale);
        scr_jr_limb(_hip_f_x, _hip_y, _knee_f.x, _knee_f.y,
                    4.6 * _scale, 3.6 * _scale);
        scr_jr_limb(_knee_f.x, _knee_f.y, _front_foot_x, _floor_y,
                    3.6 * _scale, 2.6 * _scale);
        scr_jr_limb(_front_foot_x, _floor_y,
                    _front_foot_x + _facing * 5 * _scale, _floor_y,
                    2.6 * _scale, 1.8 * _scale);
        scr_jr_limb(_back_foot_x, _floor_y,
                    _back_foot_x + _facing * 4 * _scale, _floor_y,
                    2.4 * _scale, 1.6 * _scale);
        scr_jr_limb(_sh_out_x, _shoulder_y, _elbow_out.x, _elbow_out.y,
                    3.4 * _scale, 2.8 * _scale);
        scr_jr_limb(_elbow_out.x, _elbow_out.y, _out_hand_x, _out_hand_y,
                    2.8 * _scale, 2.2 * _scale);
        draw_circle(_head_x, _head_y, _k_head_r * _scale, false);
        scr_jr_limb(_sh_in_x, _shoulder_y, _elbow_in.x, _elbow_in.y,
                    3.6 * _scale, 3 * _scale);
        scr_jr_limb(_elbow_in.x, _elbow_in.y, _hand_x, _hand_y,
                    3 * _scale, 2.4 * _scale);
    } else {
        var _mat_heat = clamp(_lit * 0.72 + _coil * 0.42 + _bounce * 0.18, 0, 1);
        var _mat_accent = merge_color(_k_er_col_cyan, _k_er_col_warning,
                                      clamp(_mat_heat * 0.62 + _coil * 0.24, 0, 1));

        draw_set_circle_precision(10);

        scr_jr_metal_limb(_hip_b_x, _hip_y, _knee_b.x, _knee_b.y,
                          4.4 * _scale, 3.4 * _scale, _alpha, _mat_heat * 0.70, _mat_accent, _phase + 0.4);
        scr_jr_metal_limb(_knee_b.x, _knee_b.y, _back_foot_x, _floor_y,
                          3.4 * _scale, 2.4 * _scale, _alpha, _mat_heat * 0.58, _mat_accent, _phase + 1.2);
        scr_jr_metal_limb(_hip_f_x, _hip_y, _knee_f.x, _knee_f.y,
                          4.6 * _scale, 3.6 * _scale, _alpha, _mat_heat * 0.74, _mat_accent, _phase + 2.0);
        scr_jr_metal_limb(_knee_f.x, _knee_f.y, _front_foot_x, _floor_y,
                          3.6 * _scale, 2.6 * _scale, _alpha, _mat_heat * 0.62, _mat_accent, _phase + 2.8);
        scr_jr_metal_limb(_front_foot_x, _floor_y,
                          _front_foot_x + _facing * 5 * _scale, _floor_y,
                          2.6 * _scale, 1.8 * _scale, _alpha, _mat_heat * 0.45, _mat_accent, _phase + 3.4);
        scr_jr_metal_limb(_back_foot_x, _floor_y,
                          _back_foot_x + _facing * 4 * _scale, _floor_y,
                          2.4 * _scale, 1.6 * _scale, _alpha, _mat_heat * 0.38, _mat_accent, _phase + 4.0);

        scr_jr_metal_limb(_hip_x, _hip_y, _chest_x, _chest_y,
                          _k_hip_w * 2 * _scale, _k_shoulder_w * 1.7 * _scale,
                          _alpha, _mat_heat, _mat_accent, _phase + 4.6);
        scr_jr_metal_limb(_chest_x, _chest_y, _neck_x, _neck_y,
                          _k_shoulder_w * 1.7 * _scale, _k_shoulder_w * 0.9 * _scale,
                          _alpha, _mat_heat, _mat_accent, _phase + 5.2);
        scr_jr_metal_limb(_sh_out_x, _shoulder_y, _sh_in_x, _shoulder_y,
                          3 * _scale, 3 * _scale, _alpha, _mat_heat * 0.65, _mat_accent, _phase + 6.0);

        scr_jr_metal_limb(_sh_out_x, _shoulder_y, _elbow_out.x, _elbow_out.y,
                          3.4 * _scale, 2.8 * _scale, _alpha, _mat_heat * 0.58, _mat_accent, _phase + 6.8);
        scr_jr_metal_limb(_elbow_out.x, _elbow_out.y, _out_hand_x, _out_hand_y,
                          2.8 * _scale, 2.2 * _scale, _alpha, _mat_heat * 0.50, _mat_accent, _phase + 7.4);
        scr_jr_metal_limb(_sh_in_x, _shoulder_y, _elbow_in.x, _elbow_in.y,
                          3.6 * _scale, 3 * _scale, _alpha, _mat_heat * 0.72, _mat_accent, _phase + 8.2);
        scr_jr_metal_limb(_elbow_in.x, _elbow_in.y, _hand_x, _hand_y,
                          3 * _scale, 2.4 * _scale, _alpha, _mat_heat * 0.82, _mat_accent, _phase + 9.0);

        scr_jr_joint(_hip_x, _hip_y, 4.4 * _scale, _alpha, _mat_heat * 0.80, _mat_accent, true);
        scr_jr_joint(_chest_x, _chest_y, 4.0 * _scale, _alpha, _mat_heat, _mat_accent, true);
        scr_jr_joint(_neck_x, _neck_y, 2.8 * _scale, _alpha, _mat_heat, _mat_accent, false);
        scr_jr_joint(_sh_out_x, _shoulder_y, 2.5 * _scale, _alpha, _mat_heat * 0.62, _mat_accent, false);
        scr_jr_joint(_sh_in_x, _shoulder_y, 2.7 * _scale, _alpha, _mat_heat * 0.75, _mat_accent, false);
        scr_jr_joint(_elbow_out.x, _elbow_out.y, 2.0 * _scale, _alpha, _mat_heat * 0.46, _mat_accent, false);
        scr_jr_joint(_elbow_in.x, _elbow_in.y, 2.1 * _scale, _alpha, _mat_heat * 0.70, _mat_accent, false);
        scr_jr_joint(_knee_b.x, _knee_b.y, 2.3 * _scale, _alpha, _mat_heat * 0.42, _mat_accent, false);
        scr_jr_joint(_knee_f.x, _knee_f.y, 2.4 * _scale, _alpha, _mat_heat * 0.50, _mat_accent, false);

        scr_jr_head(_head_x, _head_y, _k_head_r * _scale, _facing, _alpha, _mat_heat, _mat_accent);

        draw_set_circle_precision(24);
    }

    var _grip_len = 5 * _scale;
    var _grip_a = _crank;
    var _detail_heat = clamp(_lit * 0.72 + _coil * 0.42 + _bounce * 0.18, 0, 1);
    var _detail_accent = merge_color(_k_er_col_cyan, _k_er_col_warning,
                                     clamp(_detail_heat * 0.62 + _coil * 0.24, 0, 1));

    if (!_additive) {
        draw_set_color(c_black);
        draw_set_alpha(_alpha * 0.8);
        draw_line_width(_hand_x - lengthdir_x(_grip_len, _grip_a), _hand_y - lengthdir_y(_grip_len, _grip_a) * 0.55,
                        _hand_x + lengthdir_x(_grip_len, _grip_a), _hand_y + lengthdir_y(_grip_len, _grip_a) * 0.55,
                        4.5 * _scale);
        draw_set_color(merge_color(_k_er_col_armor_mid, _k_er_col_armor_edge, 0.40));
        draw_set_alpha(_alpha * 0.72);
        draw_line_width(_hand_x - lengthdir_x(_grip_len * 0.92, _grip_a), _hand_y - lengthdir_y(_grip_len * 0.92, _grip_a) * 0.55,
                        _hand_x + lengthdir_x(_grip_len * 0.92, _grip_a), _hand_y + lengthdir_y(_grip_len * 0.92, _grip_a) * 0.55,
                        2.6 * _scale);
    }

    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(_detail_accent, _k_er_col_white, _detail_heat * 0.5));
    draw_set_alpha(_alpha * (0.34 + _detail_heat * 0.42));
    draw_line_width(_hand_x - lengthdir_x(_grip_len, _grip_a), _hand_y - lengthdir_y(_grip_len, _grip_a) * 0.55,
                    _hand_x + lengthdir_x(_grip_len, _grip_a), _hand_y + lengthdir_y(_grip_len, _grip_a) * 0.55,
                    1.4 * _scale);
    draw_set_color(merge_color(_k_er_col_cyan, c_white, clamp(_lit, 0, 1) * 0.65));
    draw_set_alpha(_alpha * (0.22 + _detail_heat * 0.36));
    draw_circle(_hand_x, _hand_y, 3.2 * _scale, true);
    gpu_set_blendmode(_rest_blend);

    var _tail_root_x = _head_x - _facing * _k_head_r * 0.8 * _scale;
    var _tail_root_y = _head_y - _k_head_r * 0.4 * _scale;
    var _tail_swing = sin(_phase * 2 + 1.2) * 5 * _scale + _coil * 4 * _scale;

    var _tx = _tail_root_x, _ty = _tail_root_y;
    for (var i = 1; i <= 3; i++) {
        var _f = i / 3;
        var _nx = _tail_root_x - _facing * (5 + i * 4) * _scale + _tail_swing * _f;
        var _ny = _tail_root_y + (2 + i * 3) * _scale - _tail_swing * 0.3 * _f;

        if (_additive) {
            gpu_set_blendmode(bm_add);
            draw_set_color(_color);
            draw_set_alpha(_alpha * 0.8);
            draw_line_width(_tx, _ty, _nx, _ny, lerp(3.2, 1.2, _f) * _scale);
        } else {
            scr_jr_metal_limb(_tx, _ty, _nx, _ny,
                              lerp(3.2, 1.8, _f) * _scale,
                              lerp(2.6, 1.2, _f) * _scale,
                              _alpha * 0.86, _detail_heat * 0.36, _detail_accent, _phase + i * 1.3);
            if (i == 3) scr_jr_joint(_nx, _ny, 1.25 * _scale, _alpha * 0.82, _detail_heat * 0.45, _detail_accent, false);
        }
        _tx = _nx;
        _ty = _ny;
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
