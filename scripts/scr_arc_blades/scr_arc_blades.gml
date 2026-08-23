


function arc_rift_y_at(_x) {
    var _span = max(1, _k_arc_right_x - _k_arc_left_x);
    var _u    = clamp((_x - _k_arc_left_x) / _span, 0, 1);
    return lerp(_k_arc_top_y, _k_arc_bottom_y, dsin(_u * 180)) - _k_arc_rift_lift;
}

function arc_view_bottom() {
    if (instance_exists(oCameraController) && oCameraController.current_cam_h > 1) {
        return oCameraController.current_cam_y + oCameraController.current_cam_h;
    }
    return room_height;
}

function arc_view_top() {
    if (instance_exists(oCameraController) && oCameraController.current_cam_h > 1) {
        return oCameraController.current_cam_y;
    }
    return 0;
}

function arc_build_formation() {
    arc_blades      = [];
    arc_lances      = [];
    arc_shards      = [];
    arc_forge_pops  = [];
    arc_vents       = [];
    arc_volley_hit  = false;
    arc_ceiling_hit = false;

    arc_safe_x = random_range(_k_arc_left_x + 110, _k_arc_right_x - 110);

    arc_reveal_flip = choose(true, false);
    arc_seed_salt   = random(1000);
}

function arc_aim_x_at(_x, _y, _dir, _plane_y) {
    var _dy = -dsin(_dir);
    if (_dy < 0.08) return _x;
    var _reach = (_plane_y - _y) / _dy;
    if (_reach <= 0) return _x;
    return _x + lengthdir_x(_reach, _dir);
}

function arc_aim_clears_corridor(_x, _y, _dir) {
    if (-dsin(_dir) < 0.08) return true;

    var _a = arc_aim_x_at(_x, _y, _dir, _k_arc_read_y0) - arc_safe_x;
    var _b = arc_aim_x_at(_x, _y, _dir, _k_arc_read_y1) - arc_safe_x;

    if ((_a < 0) != (_b < 0)) return false;
    return (abs(_a) > _k_arc_safe_half && abs(_b) > _k_arc_safe_half);
}

function arc_roll_aim(_x, _y, _wave) {
    var _span = array_length(_k_arc_waves) - 1;
    var _f = (_span > 0) ? (_wave / _span) : 1;
    var _spread = lerp(_k_arc_aim_spread_min, _k_arc_aim_spread_max, _f);

    for (var _i = 0; _i < _k_arc_aim_tries; _i++) {
        var _dir = 270 + random_range(-_spread, _spread);
        if (arc_aim_clears_corridor(_x, _y, _dir)) return _dir;
    }

    var _away = (_x < arc_safe_x) ? -1 : 1;
    return 270 + _away * _spread;
}


function scr_draw_arc_rift(_hot, _lethal) {
    if (array_length(arc_rift_pts) < 2) return;

    var _n     = array_length(arc_rift_pts);
    var _top   = arc_view_top() - 40;
    var _open  = clamp(arc_rift_open, 0, 1);
    var _lit   = _open * (_n - 1);
    var _breath = 0.86 + 0.14 * dsin(t * 3.1 + arc_seed_salt);

    // --- the void: everything above the seam is an absence of world ---------------
    var _void_a = _k_arc_void_alpha_min
                + (_k_arc_void_alpha_max - _k_arc_void_alpha_min) * clamp(_hot, 0, 1);

    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i < _n; _i++) {
        var _p = arc_rift_pts[_i];
        var _y = _p.y + _p.jag;
        draw_vertex_colour(_p.x, _top, c_black, _void_a);
        draw_vertex_colour(_p.x, _y,   c_black, _void_a);
    }
    draw_primitive_end();

    gpu_set_blendmode(bm_add);

    // --- spill: light bleeding down out of the tear, three passes deep to narrow ---
    var _col  = merge_color(_k_arc_color, _k_arc_hot_color, clamp(_hot, 0, 1) * 0.55);
    var _deep = _k_arc_spill_depth * (0.45 + _hot * 0.55);
    var _pass = [ [ 1.00, 0.13 + _hot * 0.15, 0.00 ],
                  [ 0.42, 0.15 + _hot * 0.20, 0.35 ],
                  [ 0.16, 0.18 + _hot * 0.32, 0.85 ] ];

    for (var _p2 = 0; _p2 < 3; _p2++) {
        var _pd = _deep * _pass[_p2][0];
        var _pa = min(1, _pass[_p2][1]) * _breath;
        var _pc = merge_color(_col, c_white, _pass[_p2][2]);

        draw_primitive_begin(pr_trianglestrip);
        for (var _i2 = 0; _i2 < _n; _i2++) {
            var _q = arc_rift_pts[_i2];
            var _qy = _q.y + _q.jag;
            draw_vertex_colour(_q.x, _qy,       _pc, _pa);
            draw_vertex_colour(_q.x, _qy + _pd, _pc, 0);
        }
        draw_primitive_end();
    }

    for (var _i3 = 0; _i3 < _n - 1; _i3++) {
        if (_i3 > _lit) break;

        var _a1 = arc_rift_pts[_i3];
        var _a2 = arc_rift_pts[_i3 + 1];
        var _y1 = _a1.y + _a1.jag;
        var _y2 = _a2.y + _a2.jag;
        var _edge = 1 - clamp(_lit - _i3, 0, 1) * 0.5;
        var _la = arc_rift * (0.45 + _hot * 0.55) * _edge;

        var _fr = _k_arc_fringe_px * (0.4 + _hot * 0.6);
        draw_set_color(c_red);
        draw_set_alpha(_la * 0.34);
        draw_line_width(_a1.x, _y1 - _fr, _a2.x, _y2 - _fr, 2);
        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_la * 0.30);
        draw_line_width(_a1.x, _y1 + _fr, _a2.x, _y2 + _fr, 2);

        draw_set_color(merge_color(_k_arc_color, c_white, 0.25 + _hot * 0.35));
        draw_set_alpha(_la * 0.9);
        draw_line_width(_a1.x, _y1, _a2.x, _y2, 2.4 + _hot * 3.2);

        draw_set_color(c_white);
        draw_set_alpha(_la * (0.55 + _hot * 0.45) * _breath);
        draw_line_width(_a1.x, _y1, _a2.x, _y2, 1.1 + _hot * 1.5);
    }

    if (_lethal) {
        var _step  = _k_arc_tick_step;
        var _phase = (t * _k_arc_tick_scroll) mod _step;
        var _tickc = merge_color(global.avoid_col_warning, c_white, _hot * 0.4);

        for (var _tx = _k_arc_left_x - _step; _tx < _k_arc_right_x + _step; _tx += _step) {
            var _sx = _tx + _phase;
            if (_sx < arc_view_left() - 20 || _sx > arc_view_right() + 20) continue;
            var _sy = arc_rift_y_at(_sx);
            var _tl = _k_arc_tick_len * (0.55 + _hot * 0.45);

            draw_set_color(_tickc);
            draw_set_alpha((0.30 + _hot * 0.45) * _breath);
            draw_line_width(_sx, _sy, _sx - _tl * 0.5, _sy + _tl, 2);

            draw_set_color(global.avoid_col_cyan);
            draw_set_alpha((0.16 + _hot * 0.24) * _breath);
            draw_line_width(_sx + 2, _sy, _sx - _tl * 0.5 + 2, _sy + _tl, 1);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

function arc_view_left() {
    if (instance_exists(oCameraController) && oCameraController.current_cam_w > 1) {
        return oCameraController.current_cam_x;
    }
    return 0;
}

function arc_view_right() {
    if (instance_exists(oCameraController) && oCameraController.current_cam_w > 1) {
        return oCameraController.current_cam_x + oCameraController.current_cam_w;
    }
    return room_width;
}


function scr_draw_arc_blade(_bx, _by, _ang, _scale, _forge, _hot, _aim, _fade) {
    if (_fade <= 0.01 || _scale <= 0.01) return;

    var _L = _k_arc_blade_len  * _scale;
    var _W = _k_arc_blade_half * _scale;

    var _ux = lengthdir_x(1, _ang);
    var _uy = lengthdir_y(1, _ang);
    var _px = lengthdir_x(1, _ang - 90);
    var _py = lengthdir_y(1, _ang - 90);

    var _hull = [ [  1.00,  0.00 ],
                  [  0.10,  0.62 ],
                  [ -0.34,  1.00 ],
                  [ -0.16,  0.30 ],
                  [ -0.80,  0.16 ],
                  [ -0.80, -0.16 ],
                  [ -0.16, -0.30 ],
                  [ -0.34, -1.00 ],
                  [  0.10, -0.62 ] ];
    var _hn = array_length(_hull);

    var _wx = array_create(_hn, 0);
    var _wy = array_create(_hn, 0);
    for (var _i = 0; _i < _hn; _i++) {
        var _al = _hull[_i][0] * _L;
        var _ac = _hull[_i][1] * _W;
        _wx[_i] = _bx + _ux * _al + _px * _ac;
        _wy[_i] = _by + _uy * _al + _py * _ac;
    }

    // --- black solid (bm_normal). The blade's silhouette. ------------------------
    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_bx, _by, c_black, _fade);
    for (var _i2 = 0; _i2 < _hn; _i2++) draw_vertex_colour(_wx[_i2], _wy[_i2], c_black, _fade);
    draw_vertex_colour(_wx[0], _wy[0], c_black, _fade);
    draw_primitive_end();

    gpu_set_blendmode(bm_add);

    // --- hot fill: cold at the tail, incandescent at the tip --------------------
    var _body = merge_color(_k_arc_color, _k_arc_hot_color, clamp(_forge * 0.85 + _hot * 0.3, 0, 1));
    var _core = merge_color(_body, c_white, 0.35 + _forge * 0.55);
    var _fa   = _fade * (0.42 + _hot * 0.22 + _forge * 0.5 + _aim * 0.25);

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_colour(_bx, _by, _core, _fa);
    for (var _i3 = 0; _i3 < _hn; _i3++) {
        var _edge_hot = (_hull[_i3][0] + 0.8) / 1.8;
        draw_vertex_colour(_wx[_i3], _wy[_i3],
                           merge_color(_body, _core, _edge_hot), _fa * (0.25 + _edge_hot * 0.5));
    }
    draw_vertex_colour(_wx[0], _wy[0], _core, _fa * 0.75);
    draw_primitive_end();

    // --- chromatic fringe on the silhouette, split along the across-axis ---------
    var _fr = _k_arc_fringe_px * (0.5 + _forge * 0.5 + _aim * 0.8);
    if (_fr > 0.4) {
        draw_set_alpha(_fade * (0.22 + _aim * 0.3));
        draw_set_color(c_red);
        for (var _i4 = 0; _i4 < _hn; _i4++) {
            var _j = (_i4 + 1) mod _hn;
            draw_line_width(_wx[_i4] + _px * _fr, _wy[_i4] + _py * _fr,
                            _wx[_j]  + _px * _fr, _wy[_j]  + _py * _fr, 1.4);
        }
        draw_set_color(global.avoid_col_cyan);
        for (var _i5 = 0; _i5 < _hn; _i5++) {
            var _j2 = (_i5 + 1) mod _hn;
            draw_line_width(_wx[_i5] - _px * _fr, _wy[_i5] - _py * _fr,
                            _wx[_j2] - _px * _fr, _wy[_j2] - _py * _fr, 1.4);
        }
    }

    // --- white-hot edge -----------------------------------------------------------
    draw_set_color(c_white);
    draw_set_alpha(_fade * (0.5 + _forge * 0.5 + _aim * 0.35));
    for (var _i6 = 0; _i6 < _hn; _i6++) {
        var _j3 = (_i6 + 1) mod _hn;
        draw_line_width(_wx[_i6], _wy[_i6], _wx[_j3], _wy[_j3], 1.0 + _forge * 1.4 + _aim * 1.1);
    }

    // --- spine: the light running down the middle toward the tip -----------------
    draw_set_alpha(_fade * (0.35 + _forge * 0.6 + _aim * 0.5));
    draw_line_width(_bx - _ux * _L * 0.7, _by - _uy * _L * 0.7,
                    _bx + _ux * _L * 0.95, _by + _uy * _L * 0.95, 1.2 + _aim * 1.6);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}


function scr_draw_arc_rail(_x, _y, _dir, _len, _p, _seed) {
    if (_p <= 0.01 || _len <= 1) return;

    var _x2 = _x + lengthdir_x(_len, _dir);
    var _y2 = _y + lengthdir_y(_len, _dir);

    gpu_set_blendmode(bm_add);

    var _pulse = 0.6 + 0.4 * dsin(t * 6 + _seed);
    var _col   = merge_color(global.avoid_col_warning, c_white, _p * 0.4);

    draw_set_color(_col);
    draw_set_alpha(_p * 0.12 * _pulse);
    draw_line_width(_x, _y, _x2, _y2, 8 * _p);

    draw_set_color(c_white);
    draw_set_alpha(_p * 0.34 * _pulse);
    draw_line_width(_x, _y, _x2, _y2, 1);

    var _f  = frac(t * 0.04 + _seed * 0.01);
    var _px = lerp(_x, _x2, _f);
    var _py = lerp(_y, _y2, _f);
    draw_set_alpha(_p * 0.7);
    draw_line_width(_px, _py,
                    _px + lengthdir_x(18, _dir), _py + lengthdir_y(18, _dir), 2);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}


function scr_draw_arc_lance(_x1, _y1, _x2, _y2, _w, _a, _hot) {
    if (_a <= 0.01 || _w <= 0.05) return;

    var _col  = merge_color(_k_arc_color, _k_arc_hot_color, _hot * 0.5);
    var _halo = _w * _k_arc_lance_halo;
    var _dir  = point_direction(_x1, _y1, _x2, _y2);
    var _px   = lengthdir_x(1, _dir - 90);
    var _py   = lengthdir_y(1, _dir - 90);

    var _bw = _w * 0.9;
    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x1 - _px * _bw, _y1 - _py * _bw, c_black, _a * 0.55);
    draw_vertex_colour(_x1 + _px * _bw, _y1 + _py * _bw, c_black, _a * 0.55);
    draw_vertex_colour(_x2 - _px * _bw, _y2 - _py * _bw, c_black, _a * 0.35);
    draw_vertex_colour(_x2 + _px * _bw, _y2 + _py * _bw, c_black, _a * 0.35);
    draw_primitive_end();

    gpu_set_blendmode(bm_add);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x1 - _px * _halo, _y1 - _py * _halo, _col, 0);
    draw_vertex_colour(_x2 - _px * _halo, _y2 - _py * _halo, _col, 0);
    draw_vertex_colour(_x1, _y1, _col, _a * 0.14);
    draw_vertex_colour(_x2, _y2, _col, _a * 0.09);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x1, _y1, _col, _a * 0.14);
    draw_vertex_colour(_x2, _y2, _col, _a * 0.09);
    draw_vertex_colour(_x1 + _px * _halo, _y1 + _py * _halo, _col, 0);
    draw_vertex_colour(_x2 + _px * _halo, _y2 + _py * _halo, _col, 0);
    draw_primitive_end();

    var _fr = _w * 0.9 + _k_arc_fringe_px;
    draw_set_color(c_red);
    draw_set_alpha(_a * 0.30);
    draw_line_width(_x1 - _px * _fr, _y1 - _py * _fr, _x2 - _px * _fr, _y2 - _py * _fr, 1.6);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(_a * 0.26);
    draw_line_width(_x1 + _px * _fr, _y1 + _py * _fr, _x2 + _px * _fr, _y2 + _py * _fr, 1.6);

    draw_set_color(_col);
    draw_set_alpha(_a * 0.34);
    draw_line_width(_x1, _y1, _x2, _y2, _w * 2);

    draw_set_color(c_white);
    draw_set_alpha(_a * 0.72);
    draw_line_width(_x1, _y1, _x2, _y2, max(1, _w * 0.38));

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
