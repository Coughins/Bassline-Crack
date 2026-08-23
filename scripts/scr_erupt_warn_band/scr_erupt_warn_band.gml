function scr_erupt_warn_band_axes(_edge) {
    switch (_edge) {
        case 0:  return { ox:0,          oy:0,           tx:0, ty:1, px: 1, py: 0, len:room_height };
        case 1:  return { ox:room_width, oy:0,           tx:0, ty:1, px:-1, py: 0, len:room_height };
        case 2:  return { ox:0,          oy:0,           tx:1, ty:0, px: 0, py: 1, len:room_width  };
        default: return { ox:0,          oy:room_height, tx:1, ty:0, px: 0, py:-1, len:room_width  };
    }
}

function scr_start_erupt_warn_band(_edge, _lead) {
    laser_warn_band_edge   = _edge;
    laser_warn_band_len    = max(1, _lead);
    laser_warn_band_t      = 0;
    laser_warn_band_coil   = 0;
    laser_warn_band_active = true;
}

function scr_update_erupt_warn_band() {
    if (laser_warn_band_active) {
        laser_warn_band_t++;
        var _raw = clamp(laser_warn_band_t / laser_warn_band_len, 0, 1);
        laser_warn_band_coil = max(power(_raw, 1.45),
                                   lerp(_k_lwb_read_floor, 1, power(_raw, 1.2)));
        if (laser_warn_band_t >= laser_warn_band_len) laser_warn_band_active = false;
    } else {

        laser_warn_band_coil = max(0, laser_warn_band_coil - 0.12);
    }

    var _c = laser_warn_band_coil;
    if (_c > 0.02) {
        var _ax = scr_erupt_warn_band_axes(laser_warn_band_edge);
        var _in_dir = point_direction(0, 0, _ax.px, _ax.py);
        var _spread = lerp(30, 9, _c);

        var _dens = max(1, _ax.len / _k_lwb_density_ref);

        if (laser_warn_band_active && (laser_warn_band_t mod 2) == 0) {
            var _vn = round(_dens * (1 + _c));
            for (var _v = 0; _v < _vn; _v++) {
                var _f = random(1);
                scr_spawn_vent_stream(laser_warn_band_vents,
                    _ax.ox + _ax.tx * _ax.len * _f + _ax.px * random_range(-3, 7),
                    _ax.oy + _ax.ty * _ax.len * _f + _ax.py * random_range(-3, 7),
                    _in_dir + random_range(-_spread, _spread),
                    _c, _k_lwb_vent_cols, 240);
            }
        }

        if (laser_warn_band_active && (laser_warn_band_t mod 2) == 0) {
            var _hn = round(_dens);
            for (var _h = 0; _h < _hn; _h++) {
                array_push(laser_warn_band_haze, {
                    f    : random(1),
                    w    : random_range(190, 380),
                    prog : 0,
                    life : 16, life_max : 16,
                    hot  : _c
                });
            }
        }

        if (laser_warn_band_active && (laser_warn_band_t mod 7) == 0) {
            array_push(laser_warn_band_sweeps, {
                d     : 0,
                spd   : random_range(3.5, 6.8) * (0.8 + _c * 0.6),
                life  : 28, life_max : 28,
                hot   : 0.55 + _c * 0.45,
                color : global.avoid_col_warning
            });
        }

        if (laser_warn_band_active && (laser_warn_band_t mod 3) == 0) {
            var _an = round(_dens * (0.4 + _c * 0.6));
            for (var _a = 0; _a < _an; _a++) {
                var _f1 = random(1);
                var _f2 = clamp(_f1 + random_range(-0.12, 0.12), 0, 1);
                var _rail = random_range(34, 90);
                var _land = random_range(1, 8);
                array_push(laser_warn_band_arcs, {
                    x1 : _ax.ox + _ax.tx * _ax.len * _f1 + _ax.px * _rail,
                    y1 : _ax.oy + _ax.ty * _ax.len * _f1 + _ax.py * _rail,
                    x2 : _ax.ox + _ax.tx * _ax.len * _f2 + _ax.px * _land,
                    y2 : _ax.oy + _ax.ty * _ax.len * _f2 + _ax.py * _land,
                    life : irandom_range(8, 15),
                    life_max : 15,
                    hot : _c,
                    color : choose(global.avoid_col_cyan, global.avoid_col_warning,
                                   global.avoid_col_violet),
                    off : scr_bolt_offsets(5, 8 + _c * 18)
                });
            }
        }

        vignette_pulse      = max(vignette_pulse, _c * 0.22);
        bloom_pulse         = max(bloom_pulse, _c * _c * 0.2);
        aberration_pulse    = max(aberration_pulse, _c * _c * 0.18);
        global_ripple_pulse = max(global_ripple_pulse, _c * 0.1);
    }

    scr_update_vent_streams(laser_warn_band_vents);
    for (var _i = array_length(laser_warn_band_arcs) - 1; _i >= 0; _i--) {
        laser_warn_band_arcs[_i].life--;
        if (laser_warn_band_arcs[_i].life <= 0) array_delete(laser_warn_band_arcs, _i, 1);
    }
    for (var _i = array_length(laser_warn_band_haze) - 1; _i >= 0; _i--) {
        var _hz = laser_warn_band_haze[_i];
        _hz.prog += 0.05;
        _hz.life--;
        if (_hz.life <= 0) array_delete(laser_warn_band_haze, _i, 1);
    }
    for (var _i = array_length(laser_warn_band_sweeps) - 1; _i >= 0; _i--) {
        var _sw = laser_warn_band_sweeps[_i];
        _sw.d += _sw.spd;
        _sw.life--;
        if (_sw.life <= 0) array_delete(laser_warn_band_sweeps, _i, 1);
    }
}

function scr_draw_erupt_warn_band(_edge, _coil) {
    if (_coil <= 0.01) return;

    var _ax   = scr_erupt_warn_band_axes(_edge);
    var _vert = (_edge == 0 || _edge == 1);
    var _px   = _ax.px;
    var _py   = _ax.py;
    var _x1   = _ax.ox;
    var _y1   = _ax.oy;
    var _x2   = _ax.ox + _ax.tx * _ax.len;
    var _y2   = _ax.oy + _ax.ty * _ax.len;

    var _hot = _coil * _coil;
    var _col = merge_color(global.avoid_col_armor_edge, make_color_rgb(246, 254, 255), _hot * 0.8);
    var _gain = _k_lwb_spill_gain;

    var _slot   = _k_lwb_depth * _k_lwb_slot_mult;
    var _hold   = _slot * _k_lwb_slot_hold;
    var _slot_a = _k_lwb_slot_alpha_min
                + (_k_lwb_slot_alpha_max - _k_lwb_slot_alpha_min) * _coil;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x1, _y1, c_black, _slot_a);
    draw_vertex_colour(_x2, _y2, c_black, _slot_a);
    draw_vertex_colour(_x1 + _px * _hold, _y1 + _py * _hold, c_black, _slot_a);
    draw_vertex_colour(_x2 + _px * _hold, _y2 + _py * _hold, c_black, _slot_a);
    draw_primitive_end();

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_colour(_x1 + _px * _hold, _y1 + _py * _hold, c_black, _slot_a);
    draw_vertex_colour(_x2 + _px * _hold, _y2 + _py * _hold, c_black, _slot_a);
    draw_vertex_colour(_x1 + _px * _slot, _y1 + _py * _slot, c_black, 0);
    draw_vertex_colour(_x2 + _px * _slot, _y2 + _py * _slot, c_black, 0);
    draw_primitive_end();

    gpu_set_blendmode(bm_add);

    var _deep = 24 + _hot * _k_lwb_spill_deep;

    var _pd = [ 1.00,       0.16 + _hot * 0.16,   0.00 ];
    var _pm = [ 0.40,       0.18 + _hot * 0.20,   0.35 ];
    var _pn = [ 0.17,       0.22 + _hot * 0.34,   0.80 ];
    var _passes = [ _pd, _pm, _pn ];

    for (var _p = 0; _p < 3; _p++) {
        var _pass = _passes[_p];
        var _pdep = _deep * _pass[0];
        var _pcol = merge_color(_col, c_white, _pass[2]);
        var _pa   = min(1, _pass[1] * _gain);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_x1, _y1, _pcol, _pa);
        draw_vertex_colour(_x2, _y2, _pcol, _pa);
        draw_vertex_colour(_x1 + _px * _pdep, _y1 + _py * _pdep, _pcol, 0);
        draw_vertex_colour(_x2 + _px * _pdep, _y2 + _py * _pdep, _pcol, 0);
        draw_primitive_end();
    }

    for (var _h = 0; _h < array_length(laser_warn_band_haze); _h++) {
        var _hz    = laser_warn_band_haze[_h];
        var _ha    = clamp(_hz.life / _hz.life_max, 0, 1);
        var _hrise = _hz.prog * 90;
        var _hhw   = _hz.w * 0.5 * (0.5 + _hz.prog * 0.6);
        var _hwob  = sin(_hz.prog * 7 + _hz.f * 41) * 6;
        var _hcen  = _hz.f * _ax.len + _hwob;
        var _hcol  = merge_color(global.avoid_col_cyan, make_color_rgb(246, 254, 255), _hz.hot * 0.7);
        var _hal   = min(1, _ha * _ha * 0.16 * _hz.hot * _gain);
        var _hfar  = _hrise + 22;

        var _hax = _ax.tx * (_hcen - _hhw), _hay = _ax.ty * (_hcen - _hhw);
        var _hbx = _ax.tx * (_hcen + _hhw), _hby = _ax.ty * (_hcen + _hhw);

        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_x1 + _hax + _px * _hrise, _y1 + _hay + _py * _hrise, _hcol, _hal);
        draw_vertex_colour(_x1 + _hbx + _px * _hrise, _y1 + _hby + _py * _hrise, _hcol, _hal);
        draw_vertex_colour(_x1 + _hax + _px * _hfar,  _y1 + _hay + _py * _hfar,  _hcol, _hal);
        draw_vertex_colour(_x1 + _hbx + _px * _hfar,  _y1 + _hby + _py * _hfar,  _hcol, _hal);
        draw_primitive_end();
    }

    for (var _w = 0; _w < array_length(laser_warn_band_sweeps); _w++) {
        var _sw  = laser_warn_band_sweeps[_w];
        var _sa  = clamp(_sw.life / _sw.life_max, 0, 1);
        var _sd  = _sw.d;
        var _bar = 2 + _sw.hot * 4;
        var _sx1 = _x1 + _px * _sd, _sy1 = _y1 + _py * _sd;
        var _sx2 = _x2 + _px * _sd, _sy2 = _y2 + _py * _sd;

        draw_set_color(_sw.color);
        draw_set_alpha(_sa * _sa * (0.12 + _sw.hot * 0.22));
        draw_line_width(_sx1, _sy1, _sx2, _sy2, _bar * 2);
        draw_set_color(c_white);
        draw_set_alpha(_sa * _sw.hot * 0.55);
        draw_line_width(_sx1, _sy1, _sx2, _sy2, 1.5);

        for (var _sl = 0; _sl < 3; _sl++) {
            var _slo = 6 + _sl * 9;
            draw_set_color(_sw.color);
            draw_set_alpha(_sa * (0.08 + _sw.hot * 0.08) * (1 - _sl / 3));
            draw_line_width(_sx1 + _px * _slo, _sy1 + _py * _slo,
                            _sx2 + _px * _slo, _sy2 + _py * _slo, 1);
        }
    }

    var _body_w   = 4 + _coil * 14;
    var _seam_off = _body_w * 0.5 + 2;
    var _sxa = _x1 + _px * _seam_off, _sya = _y1 + _py * _seam_off;
    var _sxb = _x2 + _px * _seam_off, _syb = _y2 + _py * _seam_off;

    draw_set_color(_col);
    draw_set_alpha(0.25 + _hot * 0.55);
    draw_line_width(_sxa, _sya, _sxb, _syb, _body_w);

    draw_set_color(c_white);
    draw_set_alpha(0.30 + _hot * 0.62);
    draw_line_width(_sxa, _sya, _sxb, _syb, 1.5 + _coil * 3);

    var _fringe = 2 + _hot * 6;
    draw_set_color(c_red);
    draw_set_alpha(0.10 + _hot * 0.3);
    draw_line_width(_sxa - _px * _fringe, _sya - _py * _fringe,
                    _sxb - _px * _fringe, _syb - _py * _fringe, 3);
    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha(0.10 + _hot * 0.3);
    draw_line_width(_sxa + _px * _fringe, _sya + _py * _fringe,
                    _sxb + _px * _fringe, _syb + _py * _fringe, 3);

    var _hd  = (_k_lwb_depth - _k_lwb_inset) * 0.5;
    var _off = (_k_lwb_depth + _k_lwb_inset) * 0.5;
    var _cx  = _ax.ox + _ax.tx * _ax.len * 0.5 + _px * _off;
    var _cy  = _ax.oy + _ax.ty * _ax.len * 0.5 + _py * _off;

    scr_draw_lock_bracket(_cx - _ax.len * 0.5, _cy - _hd,
                          _cx + _ax.len * 0.5, _cy + _hd,
                          global.avoid_col_warning, _coil, 1,
                          _k_lwb_tick, true, -_k_lwb_inset, _vert ? 90 : 0,
                          0.62 + 0.38 * sin(current_time * 0.018),
                          global.avoid_col_cyan);

    var _gt = current_time * 0.001;
    var _tick_n = 6 + floor(_coil * 26);
    draw_set_color(c_white);
    for (var _s = 0; _s < _tick_n; _s++) {
        var _f = frac(_s * 0.61803 + 0.137);
        var _tx = _ax.ox + _ax.tx * _ax.len * _f;
        var _ty = _ax.oy + _ax.ty * _ax.len * _f;
        var _flick = 0.4 + 0.6 * frac(sin(_f * 12.9898 + _gt * 40) * 43758.5453);
        var _reach = 8 + frac(sin(_f * 7.7 + _gt * 33) * 43758.5453) * 12;
        draw_set_alpha(_coil * _flick * 0.8);
        draw_line_width(_tx + _px * _reach, _ty + _py * _reach,
                        _tx + _px * (_reach + 14), _ty + _py * (_reach + 14), 1.5);
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
