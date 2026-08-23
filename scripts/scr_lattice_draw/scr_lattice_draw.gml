

function scr_lattice_draw_wire() {
    if (is_undefined(lat)) exit;

    var _L = lat;
    var _ec = array_length(_L.edges);
    var _nc = array_length(_L.nodes);
    if (_ec == 0) exit;

    var _danger = global.avoid_col_danger;
    var _blood = global.avoid_col_blood;
    var _cyan = global.avoid_col_cyan;
    var _col  = merge_color(_blood, _danger, 0.62);
    var _warm = merge_color(_danger, c_white, 0.45);
    var _hotc = merge_color(_danger, c_white, 0.8);
    var _cell_idle = merge_color(_blood, _cyan, 0.18);
    var _build_col = merge_color(_cyan, c_white, 0.30);
    var _wire = _L.wire;
    var _breathe = 0.85 + dsin(_L.age * 3.4) * 0.15;

    var _cc = array_length(_L.cells);
    for (var _c = 0; _c < _cc; _c++) {
        var _cl = _L.cells[_c];
        var _fa = 0.045 * _wire + _cl.heat * 0.30;
        if (_fa <= 0.006) continue;

        var _ready = true;
        for (var _k = 0; _k < 6; _k++) {
            if (_L.nodes[_cl.n[_k]].born < 1) { _ready = false; break; }
        }
        if (!_ready) continue;

        draw_set_color(_cl.heat > 0.05 ? _warm : _cell_idle);
        draw_set_alpha(_fa);
        draw_primitive_begin(pr_trianglefan);
        draw_vertex(_cl.cx, _cl.cy);
        for (var _k = 0; _k <= 6; _k++) {
            var _vn = _L.nodes[_cl.n[_k mod 6]];
            draw_vertex(_vn.x, _vn.y);
        }
        draw_primitive_end();
    }

    for (var _e = 0; _e < _ec; _e++) {
        var _ed = _L.edges[_e];
        if (_ed.grow <= 0.001) continue;

        var _na = _L.nodes[_ed.a];
        var _nb = _L.nodes[_ed.b];

        var _x1 = _na.x, _y1 = _na.y;
        var _x2 = lerp(_na.x, _nb.x, _ed.grow);
        var _y2 = lerp(_na.y, _nb.y, _ed.grow);

        var _al = 0.20 * _wire;
        var _w  = 1.4;
        var _lc = _col;

        if (_ed.state == 2) {
            _al = (0.16 + _ed.hot * 0.55) * _wire;
            _w  = 1.4 + _ed.hot * 2.2;
            _lc = merge_color(_danger, c_white, _ed.hot * 0.7);
        } else if (_ed.cond && _L.reveal > 0) {
            var _rv = clamp((_L.reveal - _ed.rev * 0.85) * 3.5, 0, 1);
            _al = (0.20 + _rv * (0.34 + _L.coil * 0.30) * _breathe) * _wire;
            _w  = 1.4 + _rv * 1.5;
            _lc = merge_color(_danger, c_white, _rv * 0.45);
        }

        draw_set_color(_lc);
        draw_set_alpha(_al * 0.35);
        draw_line_width(_x1, _y1, _x2, _y2, _w * 2.6);
        draw_set_alpha(_al);
        draw_line_width(_x1, _y1, _x2, _y2, _w);

        if (_ed.grow < 1) {
            draw_set_color(c_white);
            draw_set_alpha(0.85 * _wire);
            draw_circle(_x2, _y2, 2.6, false);
        }
    }

    if (_L.phase == "coil" && _L.reveal > 0) {
        draw_set_color(_hotc);
        for (var _e = 0; _e < _ec; _e++) {
            var _ed2 = _L.edges[_e];
            if (!_ed2.cond) continue;
            if (_L.reveal < _ed2.rev * 0.85) continue;

            var _na2 = _L.nodes[_ed2.fa];
            var _nb2 = _L.nodes[_ed2.fb];

            var _pp = frac(_L.coil_t / 14 - _ed2.rev * 1.6 + 1);
            var _pxp = lerp(_na2.x, _nb2.x, _pp);
            var _pyp = lerp(_na2.y, _nb2.y, _pp);

            draw_set_alpha((0.35 + _L.coil * 0.6) * _wire);
            draw_circle(_pxp, _pyp, 1.6 + _L.coil * 1.6, false);
        }
    }

    for (var _n = 0; _n < _nc; _n++) {
        var _nd = _L.nodes[_n];
        if (_nd.born <= 0.01) continue;

        var _na3 = (0.28 + _nd.lit * 0.72) * _wire * _nd.born;
        var _r   = (1.9 + _nd.lit * 3.4) * (0.4 + _nd.born * 0.6);

        draw_set_color(_nd.lit > 0.05 ? merge_color(_danger, c_white, _nd.lit) : _col);
        draw_set_alpha(_na3 * 0.4);
        draw_circle(_nd.x, _nd.y, _r * 2.1, false);
        draw_set_alpha(_na3);
        draw_circle(_nd.x, _nd.y, _r, false);
    }

    if (_L.phase == "grow") {
        var _gp = clamp(_L.grow_t / _L.grow_len, 0, 1);
        draw_set_color(merge_color(_build_col, c_white, 0.55));
        draw_set_alpha((1 - _gp) * 0.5);
        draw_circle(_L.ax, _L.ay, _L.grow_front, true);
        draw_set_alpha((1 - _gp) * 0.22);
        draw_circle(_L.ax, _L.ay, _L.grow_front * 0.94, true);
    }

    if (_L.void_r > 0) {
        var _vra = 0.10 + _L.coil * 0.34 + _L.flash * 0.30;
        var _vseg = 22;
        draw_set_color(merge_color(_cyan, c_white, 0.25 + _L.coil * 0.4));
        for (var _vs = 0; _vs < _vseg; _vs++) {
            if ((_vs mod 3) == 0) continue;
            var _va1 = _vs * (360 / _vseg) - _L.age * 0.7;
            var _va2 = _va1 + (360 / _vseg) * 0.55;
            var _vr  = _L.void_r * (1 - _L.coil * 0.04);
            draw_set_alpha(_vra * 0.7);
            draw_line_width(_L.void_x + lengthdir_x(_vr, _va1), _L.void_y + lengthdir_y(_vr, _va1),
                            _L.void_x + lengthdir_x(_vr, _va2), _L.void_y + lengthdir_y(_vr, _va2), 1.6);
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}


function scr_lattice_draw_bolts(_cx, _cy, _sx, _sy) {
    if (is_undefined(lat)) exit;

    var _L = lat;
    var _ec = array_length(_L.edges);
    var _danger = global.avoid_col_danger;
    var _blood = global.avoid_col_blood;
    var _cyan = global.avoid_col_cyan;
    var _col = _danger;
    var _coil_col = merge_color(_cyan, c_white, 0.35);
    var _scar_col = merge_color(_blood, _danger, 0.40);
    var _abr = fx_get_mult_for("dnagrid", "aberration");

    for (var _a = 0; _a < array_length(_L.arcs); _a++) {
        var _ar = _L.arcs[_a];
        var _an = _L.nodes[_ar.n];
        var _alf = _ar.life / _ar.life_max;

        var _sx1 = _an.x + lengthdir_x(_ar.reach, _ar.ang);
        var _sy1 = _an.y + lengthdir_y(_ar.reach, _ar.ang);

        scr_draw_energy_bolt((_sx1 - _cx) * _sx, (_sy1 - _cy) * _sy,
                             (_an.x - _cx) * _sx, (_an.y - _cy) * _sy,
                             _alf * 0.9, merge_color(_coil_col, c_white, _L.coil * 0.5),
                             _ar.off, (1 + _L.coil * 1.6) * _sx, 0.8);
    }

    for (var _e = 0; _e < _ec; _e++) {
        var _ed = _L.edges[_e];
        if (_ed.state != 2 || _ed.hot <= 0.02) continue;

        var _na = _L.nodes[_ed.a];
        var _nb = _L.nodes[_ed.b];
        var _sa = power(_ed.hot, 2.0);

        var _px1 = (_na.x - _cx) * _sx, _py1 = (_na.y - _cy) * _sy;
        var _px2 = (_nb.x - _cx) * _sx, _py2 = (_nb.y - _cy) * _sy;

        draw_set_color(merge_color(_scar_col, c_white, _sa * 0.42));
        draw_set_alpha(_sa * 0.28);
        draw_line_width(_px1, _py1, _px2, _py2, 5 * _sx);
        draw_set_alpha(_sa * 0.7);
        draw_line_width(_px1, _py1, _px2, _py2, 1.6 * _sx);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);

    var _k_bolt_budget = 70;
    var _drawn = 0;

    for (var _e = 0; _e < _ec; _e++) {
        var _ed2 = _L.edges[_e];
        if (_ed2.state != 1) continue;

        var _fa = _L.nodes[_ed2.fa];
        var _fb = _L.nodes[_ed2.fb];

        var _hx = lerp(_fa.x, _fb.x, _ed2.head);
        var _hy = lerp(_fa.y, _fb.y, _ed2.head);

        var _gx1 = (_fa.x - _cx) * _sx, _gy1 = (_fa.y - _cy) * _sy;
        var _ghx = (_hx  - _cx) * _sx, _ghy = (_hy  - _cy) * _sy;

        var _la = clamp(_ed2.live / (_L.k_cross + _L.k_hold), 0, 1);
        var _pw = 0.8 + _L.strike * 0.35;

        if (_drawn < _k_bolt_budget) {
            scr_draw_energy_bolt(_gx1, _gy1, _ghx, _ghy,
                                 (0.35 + _la * 0.6) * _pw, _col, _ed2.off, 1.7 * _sx, 0.8);
            _drawn++;
        } else {
            draw_set_color(_col);
            draw_set_alpha(_la * 0.32 * _pw);
            draw_line_width(_gx1, _gy1, _ghx, _ghy, 5 * _sx);
            draw_set_color(merge_color(_col, c_white, 0.7));
            draw_set_alpha(_la * 0.8 * _pw);
            draw_line_width(_gx1, _gy1, _ghx, _ghy, 1.7 * _sx);
        }

        if (_ed2.head < 1) {
            var _hdir = point_direction(_fa.x, _fa.y, _fb.x, _fb.y);
            var _tail = min(_L.cell * 0.45 * _sx, point_distance(_gx1, _gy1, _ghx, _ghy));
            var _htx = _ghx - lengthdir_x(_tail, _hdir);
            var _hty = _ghy - lengthdir_y(_tail, _hdir);
            var _perp = _hdir + 90;
            var _hoff = 2.2 * _sx * _abr;
            var _ha = (0.55 + _la * 0.45) * _pw;

            draw_set_color(_danger);
            draw_set_alpha(_ha * 0.4);
            draw_line_width(_htx + lengthdir_x(_hoff, _perp), _hty + lengthdir_y(_hoff, _perp),
                            _ghx + lengthdir_x(_hoff, _perp), _ghy + lengthdir_y(_hoff, _perp), 4.5 * _sx);
            draw_set_color(_cyan);
            draw_line_width(_htx - lengthdir_x(_hoff, _perp), _hty - lengthdir_y(_hoff, _perp),
                            _ghx - lengthdir_x(_hoff, _perp), _ghy - lengthdir_y(_hoff, _perp), 4.5 * _sx);

            draw_set_color(c_white);
            draw_set_alpha(_ha);
            draw_line_width(_htx, _hty, _ghx, _ghy, 2.4 * _sx);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);

    if (_L.flash > 0.02) {
        var _f = _L.flash;
        draw_set_color(merge_color(_col, c_white, 0.7));
        for (var _k = 0; _k < array_length(_L.entry); _k++) {
            var _en = _L.nodes[_L.entry[_k]];
            var _ex = (_en.x - _cx) * _sx;
            var _ey = (_en.y - _cy) * _sy;
            for (var _r2 = 0; _r2 < 3; _r2++) {
                draw_set_alpha(_f * (0.4 - _r2 * 0.11));
                draw_circle(_ex, _ey, (1 - _f) * (70 + _r2 * 46) * _sx, true);
            }
        }
        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}


function scr_lattice_draw_glow(_cx, _cy, _sx, _sy) {
    if (is_undefined(lat)) exit;

    var _L = lat;
    var _nc = array_length(_L.nodes);
    var _ec = array_length(_L.edges);
    var _danger = global.avoid_col_danger;
    var _cyan = global.avoid_col_cyan;
    var _dr = color_get_red(_danger) / 255;
    var _dg = color_get_green(_danger) / 255;
    var _db = color_get_blue(_danger) / 255;
    var _cr = color_get_red(_cyan) / 255;
    var _cg = color_get_green(_cyan) / 255;
    var _cb = color_get_blue(_cyan) / 255;

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);

    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);

    for (var _n = 0; _n < _nc; _n++) {
        var _nd = _L.nodes[_n];
        if (_nd.lit <= 0.04) continue;

        shader_set_uniform_f(global.u_glow_color, lerp(_dr, 1, _nd.lit),
                             lerp(_dg, 1, _nd.lit), lerp(_db, 1, _nd.lit));
        shader_set_uniform_f(global.u_glow_intensity, _nd.lit * 1.3);

        var _sc = (0.16 + _nd.lit * 0.34) * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_nd.x - _cx) * _sx, (_nd.y - _cy) * _sy,
                        _sc, _sc, 0, c_white, 1);
    }

    for (var _e = 0; _e < _ec; _e++) {
        var _ed = _L.edges[_e];
        if (_ed.state != 1 || _ed.head >= 1) continue;

        var _fa = _L.nodes[_ed.fa];
        var _fb = _L.nodes[_ed.fb];
        var _hx = lerp(_fa.x, _fb.x, _ed.head);
        var _hy = lerp(_fa.y, _fb.y, _ed.head);

        shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, 1.4);

        var _hs = 0.30 * _sx;
        draw_sprite_ext(spr_glow_blob, 0, (_hx - _cx) * _sx, (_hy - _cy) * _sy,
                        _hs * 1.5, _hs, point_direction(_fa.x, _fa.y, _fb.x, _fb.y), c_white, 1);
    }

    if (_L.coil > 0.02) {
        for (var _k = 0; _k < array_length(_L.entry); _k++) {
            var _en = _L.nodes[_L.entry[_k]];
            shader_set_uniform_f(global.u_glow_color, lerp(_cr, 1, _L.coil),
                                 lerp(_cg, 1, _L.coil), lerp(_cb, 1, _L.coil));
            shader_set_uniform_f(global.u_glow_intensity, _L.coil * 1.5);
            var _es = (0.2 + _L.coil * 0.5) * _sx;
            draw_sprite_ext(spr_glow_blob, 0, (_en.x - _cx) * _sx, (_en.y - _cy) * _sy,
                            _es, _es, 0, c_white, 1);
        }
    }

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
}
