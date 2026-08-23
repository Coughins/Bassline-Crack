var _ax   = image_angle - 90;
var _perp = _ax + 90;
var _half = _k_beam_draw_half * (is_rotating ? extend : 1);

var _ux = lengthdir_x(1, _ax);
var _uy = lengthdir_y(1, _ax);
var _vx = lengthdir_x(1, _perp);
var _vy = lengthdir_y(1, _perp);

var _heat   = clamp(beam_heat / _k_beam_heat_max, 0, 1);
var _ignite = clamp(beam_born / _k_beam_ignite_frames, 0, 1);
var _flash  = 1 - _ignite;
var _breath = 1 + 0.05 * dsin(beam_phase * 17 + beam_seed);

var _again = (0.9 + _heat * 0.5) * (1 + _flash * 0.9) * _breath * _k_beam_gain;
var _wgain = (1 + _heat * 0.45) * (1 + _flash * _flash * 1.7);
var _tap   = _k_beam_taper;

var _paired_center = beam_paired_center;
var _paired_wide_alpha = _paired_center ? 0.66 : 1;
var _paired_inner_alpha = _paired_center ? 0.82 : 1;
var _paired_white_alpha = _paired_center ? 0.46 : 1;
var _paired_bloom_width = _paired_center ? 0.76 : 1;
var _paired_halo_width = _paired_center ? 0.82 : 1;
var _paired_core_width = _paired_center ? 0.64 : 1;
var _paired_wake_stretch = _paired_center ? (1 + (_k_beam_wake_stretch - 1) * 0.36) : _k_beam_wake_stretch;
var _paired_detail_col = _paired_center ? merge_color(beam_col_inner, beam_col_core, 0.48) : beam_col_core;

var _lead_side = 0;
if (!is_rotating && move_speed != 0) {
    var _mvx = lengthdir_x(1, move_dir) * sign(move_speed);
    var _mvy = lengthdir_y(1, move_dir) * sign(move_speed);
    _lead_side = sign(_mvx * _vx + _mvy * _vy);
}

var _blade_lead = (is_rotating && rotate_speed != 0) ? sign(rotate_speed) : 0;

gpu_set_blendmode(bm_add);

if (_half >= 2) {

if (_paired_center) {
    var _body_len = _half * (1 - _tap * 0.6);
    var _body_w = max(_k_orb_check_width * 0.55, _k_beam_w_glow * 1.35) * (0.92 + _heat * 0.1);
    var _body_col = merge_color(global.avoid_col_armor_dark, beam_col_outer, 0.72);
    var _edge_col = merge_color(global.avoid_col_armor_dark, beam_col_outer, 0.35);
    var _body_a = (0.44 + _heat * 0.1) * _ignite;

    gpu_set_blendmode(bm_normal);
    beam_draw_soft_bar(x - _ux * _body_len, y - _uy * _body_len,
                       x + _ux * _body_len, y + _uy * _body_len,
                       _body_w, _body_col, _body_a);

    draw_set_color(_edge_col);
    draw_set_alpha(0.34 * _ignite);
    var _edge_w = _body_w * 0.95;
    draw_line_width(x - _ux * _body_len + _vx * _edge_w, y - _uy * _body_len + _vy * _edge_w,
                    x + _ux * _body_len + _vx * _edge_w, y + _uy * _body_len + _vy * _edge_w, 1.2);
    draw_line_width(x - _ux * _body_len - _vx * _edge_w, y - _uy * _body_len - _vy * _edge_w,
                    x + _ux * _body_len - _vx * _edge_w, y + _uy * _body_len - _vy * _edge_w, 1.2);
    gpu_set_blendmode(bm_add);
    draw_set_alpha(1);
}

if (is_rotating) {
    var _an = array_length(trail_angles);
    for (var _gi = 0; _gi < _an; _gi += _k_blade_ghost_step) {
        var _gage = _gi / max(_an - 1, 1);
        var _galpha = _gage * _gage * (_k_beam_trail_a * 0.6 + _heat * 0.35) * _again;
        if (_galpha <= 0.006) continue;

        var _ga  = trail_angles[_gi] - 90;
        var _gdx = lengthdir_x(_half, _ga);
        var _gdy = lengthdir_y(_half, _ga);
        beam_draw_soft_bar(x - _gdx, y - _gdy, x + _gdx, y + _gdy,
                           _k_beam_w_glow * _wgain, beam_col_outer, _galpha);
    }
} else {
    var _tn = array_length(trail_positions);
    for (var _gi = 0; _gi < _tn; _gi++) {
        var _gage = _gi / _tn;
        var _galpha = _gage * _gage * (_k_beam_trail_a + _heat * 0.3) * _again * _paired_wide_alpha;
        if (_galpha <= 0.006) continue;

        var _tp  = trail_positions[_gi];
        var _gdx = _ux * _half;
        var _gdy = _uy * _half;
        beam_draw_soft_bar(_tp[0] - _gdx, _tp[1] - _gdy, _tp[0] + _gdx, _tp[1] + _gdy,
                           _k_beam_w_halo * _wgain * _paired_halo_width * (0.3 + 0.7 * _gage),
                           beam_col_outer, _galpha);
    }
}

var _segs = _k_beam_segs;

for (var _b = 0; _b < 4; _b++) {
    var _bw, _ba, _bc;
    switch (_b) {
        case 0:  _bw = _k_beam_w_bloom * _paired_bloom_width; _ba = _k_beam_a_bloom * _paired_wide_alpha;  _bc = beam_col_outer; break;
        case 1:  _bw = _k_beam_w_halo  * _paired_halo_width;  _ba = _k_beam_a_halo  * _paired_wide_alpha;  _bc = beam_col_outer; break;
        case 2:  _bw = _k_beam_w_glow;                       _ba = _k_beam_a_glow  * _paired_inner_alpha; _bc = beam_col_inner; break;
        default: _bw = _k_beam_w_core  * _paired_core_width;  _ba = _k_beam_a_core  * _paired_white_alpha; _bc = beam_col_core;  break;
    }

    var _w = _bw * _wgain;
    var _a = _ba * _again;
    if (_a <= 0.004) continue;

    var _depth = (_b == 0) ? 0 : _k_beam_ripple_depth;

    for (var _side = -1; _side <= 1; _side += 2) {
        var _asym_travel = 1;
        if (_lead_side != 0) {
            _asym_travel = (_side == _lead_side) ? _k_beam_lead_squash : _paired_wake_stretch;
        }

        draw_primitive_begin(pr_trianglestrip);
        for (var _s = 0; _s <= _segs; _s++) {
            var _f = (_s / _segs) * 2 - 1;
            var _d = _f * _half;

            var _fa = abs(_f);
            var _t  = (_fa > 1 - _tap) ? (1 - _fa) / _tap : 1;
            _t = _t * _t * (3 - 2 * _t);

            var _rip = 1 - _depth + _depth * (0.5 + 0.5 * dsin(_d * _k_beam_ripple_freq
                                                               + beam_phase * _k_beam_ripple_speed
                                                               + beam_seed + _b * 63));

            var _asym = _asym_travel;
            if (_blade_lead != 0) {
                var _bl = (_f >= 0) ? _blade_lead : -_blade_lead;
                var _bfull = (_side == _bl) ? _k_beam_lead_squash : _paired_wake_stretch;
                _asym = lerp(1, _bfull, abs(_f));
            }

            var _va = _a * _t * _rip;
            var _vw = _w * (0.35 + 0.65 * _t) * (0.62 + 0.38 * _rip) * _asym;
            var _cx = x + _ux * _d;
            var _cy = y + _uy * _d;

            draw_vertex_colour(_cx, _cy, _bc, _va);
            draw_vertex_colour(_cx + _vx * _vw * _side, _cy + _vy * _vw * _side, _bc, 0);
        }
        draw_primitive_end();
    }
}

var _rz = _half * (1 - _tap);
draw_set_color(beam_col_core);
draw_set_alpha(min(1, (0.72 + _heat * 0.28) * _again * _paired_white_alpha));
draw_line_width(x - _ux * _rz, y - _uy * _rz, x + _ux * _rz, y + _uy * _rz,
                max(1, 1.8 * _wgain * _paired_core_width));

if (_lead_side != 0 && _k_beam_rim_a > 0.01) {
    var _rim_off = _k_beam_w_glow * _wgain * _k_beam_lead_squash * _lead_side;
    var _rim_x = x + _vx * _rim_off;
    var _rim_y = y + _vy * _rim_off;

    draw_set_color(beam_col_inner);
    draw_set_alpha(min(1, _k_beam_rim_a * _again * (0.7 + _heat * 0.3) * _paired_inner_alpha));
    draw_line_width(_rim_x - _ux * _rz, _rim_y - _uy * _rz,
                    _rim_x + _ux * _rz, _rim_y + _uy * _rz, max(1, 2.2 * _wgain));

    var _shock_off = _rim_off * 2.1;
    beam_draw_soft_bar(x + _vx * _shock_off - _ux * _rz, y + _vy * _shock_off - _uy * _rz,
                       x + _vx * _shock_off + _ux * _rz, y + _vy * _shock_off + _uy * _rz,
                       _k_beam_w_glow * 0.8 * _wgain, beam_col_outer,
                       _k_beam_rim_a * 0.32 * _again * _paired_wide_alpha);
} else if (_blade_lead != 0 && _k_beam_rim_a > 0.01) {
    var _brw = max(1, 2.2 * _wgain);
    draw_set_color(beam_col_inner);
    draw_set_alpha(min(1, _k_beam_rim_a * _again * (0.7 + _heat * 0.3) * _paired_inner_alpha));
    for (var _hh = -1; _hh <= 1; _hh += 2) {
        var _bro = _k_beam_w_glow * _wgain * _k_beam_lead_squash * _blade_lead * _hh;
        draw_line_width(x + _vx * _bro, y + _vy * _bro,
                        x + _vx * _bro + _ux * _rz * _hh,
                        y + _vy * _bro + _uy * _rz * _hh, _brw);
    }
}

var _split = _k_beam_split * (0.45 + _heat + clamp(motion_speed / 16, 0, 1.5))
             * _wgain * fx_get_mult("aberration");
if (_split > 0.15) {
    var _sa = 0.4 * clamp(0.3 + _heat, 0, 1) * _again * _paired_wide_alpha;
    for (var _sg = -1; _sg <= 1; _sg += 2) {
        var _sc  = (_lead_side != 0)
                 ? ((_sg == _lead_side) ? beam_col_fringe_a : beam_col_fringe_b)
                 : ((_sg < 0) ? beam_col_fringe_a : beam_col_fringe_b);
        var _sox = _vx * _split * _sg;
        var _soy = _vy * _split * _sg;
        beam_draw_soft_bar(x + _sox - _ux * _rz, y + _soy - _uy * _rz,
                           x + _sox + _ux * _rz, y + _soy + _uy * _rz,
                           _k_beam_w_glow * 0.7 * _wgain * _paired_halo_width, _sc, _sa);
    }
}

var _fsegs = _k_beam_fil_segs;

var _famp = _k_beam_w_halo * _k_beam_fil_frac * (0.7 + _heat * 0.5);

for (var _fi = 0; _fi < _k_beam_filaments; _fi++) {
    var _fph = beam_seed + (_fi / _k_beam_filaments) * 360;

    for (var _pass = 0; _pass < 2; _pass++) {
        var _pw = ((_pass == 0) ? _k_beam_fil_w * 3.4 : _k_beam_fil_w) * _wgain;
        var _pa = ((_pass == 0) ? 0.2 * _paired_inner_alpha : 0.8 * _paired_white_alpha) * _again;
        var _pc = (_pass == 0) ? beam_col_inner : _paired_detail_col;

        draw_primitive_begin(pr_trianglestrip);
        for (var _s = 0; _s <= _fsegs; _s++) {
            var _f = (_s / _fsegs) * 2 - 1;
            var _d = _f * _half;

            var _fa = abs(_f);
            var _t  = (_fa > 1 - _tap) ? (1 - _fa) / _tap : 1;
            _t = _t * _t * (3 - 2 * _t);

            var _ang = (_d / _k_beam_fil_wave) * 360 + _fph + beam_phase * _k_beam_fil_spin;
            var _o   = _famp * dsin(_ang) * _t;
            var _dep = 0.5 + 0.5 * dcos(_ang);

            var _fw = _pw * (0.55 + 0.45 * _dep);
            var _fv = _pa * _t * (0.25 + 0.75 * _dep);

            var _cx = x + _ux * _d + _vx * _o;
            var _cy = y + _uy * _d + _vy * _o;
            draw_vertex_colour(_cx + _vx * _fw, _cy + _vy * _fw, _pc, _fv);
            draw_vertex_colour(_cx - _vx * _fw, _cy - _vy * _fw, _pc, _fv);
        }
        draw_primitive_end();
    }
}

var _pk_a = _k_beam_packet_a * _again * (0.6 + _heat * 0.7) * (_paired_center ? 0.72 : 1);
if (_pk_a > 0.01) {
    var _pk_gap   = _k_beam_packet_gap;
    var _pk_phase = (beam_phase * _k_beam_packet_speed) mod _pk_gap;
    var _pk_hl    = _k_beam_packet_len * 0.5;
    var _pk_segs  = 10;
    var _pk_n     = ceil((_half * 2) / _pk_gap) + 2;

    for (var _pi = 0; _pi < _pk_n; _pi++) {
        var _pd, _nose;
        if (is_rotating) {
            _nose = (_pi mod 2 == 0) ? 1 : -1;
            _pd   = _nose * (_pk_phase + floor(_pi / 2) * _pk_gap);
        } else {
            _nose = 1;
            _pd   = -_half + _pk_phase + _pi * _pk_gap;
        }
        if (abs(_pd) > _half) continue;

        for (var _side = -1; _side <= 1; _side += 2) {
            draw_primitive_begin(pr_trianglestrip);
            for (var _ps = 0; _ps <= _pk_segs; _ps++) {
                var _u  = _ps / _pk_segs;
                var _dd = _pd + (_u * 2 - 1) * _pk_hl * _nose;

                var _sn = dsin(_u * 180);
                var _shape = _sn * _sn * (0.3 + 0.7 * _u);
                if (abs(_dd) > _half) _shape = 0;

                var _cx = x + _ux * _dd;
                var _cy = y + _uy * _dd;
                var _pw2 = _k_beam_w_core * 2.6 * _wgain * _paired_core_width * _shape;

                draw_vertex_colour(_cx, _cy, _paired_detail_col, _pk_a * _shape);
                draw_vertex_colour(_cx + _vx * _pw2 * _side, _cy + _vy * _pw2 * _side,
                                   beam_col_inner, 0);
            }
            draw_primitive_end();
        }

        var _tkd = _pd + _pk_hl * 0.85 * _nose;
        if (abs(_tkd) <= _half) {
            var _tkw = _k_beam_w_halo * 1.5 * _wgain;
            draw_set_color(beam_col_inner);
            draw_set_alpha(_k_beam_tick_a * _again * _paired_inner_alpha);
            draw_line_width(x + _ux * _tkd + _vx * _tkw, y + _uy * _tkd + _vy * _tkw,
                            x + _ux * _tkd - _vx * _tkw, y + _uy * _tkd - _vy * _tkw, 1.5);
        }
    }
}

for (var _ai = 0; _ai < array_length(beam_arcs); _ai++) {
    var _arc = beam_arcs[_ai];
    if (abs(_arc.d) > _half) continue;

    var _alife = _arc.life / _arc.max_life;
    var _a1x = x + _ux * _arc.d;
    var _a1y = y + _uy * _arc.d;
    var _a2x = _a1x + _vx * _arc.reach * _arc.side + _ux * _arc.skew;
    var _a2y = _a1y + _vy * _arc.reach * _arc.side + _uy * _arc.skew;

    scr_draw_energy_bolt(_a1x, _a1y, _a2x, _a2y, _alife * 0.7 * _again,
                         beam_col_spark, _arc.offs, 1.4, 0.8);
}

var _spark_pulse = 1.5 + 0.35 * dsin(beam_phase * 30 + beam_seed);
if (is_rotating) {
    var _ls_gain = 1 + clamp(motion_speed / 30, 0, 1.6);
    for (var _lt = 0; _lt < 2; _lt++) {
        var _lside = (_lt == 0) ? 1 : -1;
        var _ldir  = motion_dir + ((_lside < 0) ? 180 : 0);
        var _lx = x + _ux * _half * _lside + lengthdir_x(10, _ldir);
        var _ly = y + _uy * _half * _lside + lengthdir_y(10, _ldir);
        var _lr = 9 * _spark_pulse * (1 + _heat * 0.4) * _ls_gain;

        draw_set_color(beam_col_inner);
        draw_set_alpha(0.35 * _spark_pulse * (1 + _heat * 0.4));
        draw_circle(_lx, _ly, _lr, false);
        draw_set_color(beam_col_core);
        draw_set_alpha(0.5 * _spark_pulse);
        draw_circle(_lx, _ly, _lr * 0.4, false);
    }
} else if (move_speed != 0) {
    var _lead_x = x + lengthdir_x(10, move_dir) * sign(move_speed);
    var _lead_y = y + lengthdir_y(10, move_dir) * sign(move_speed);
    var _lr2 = 9 * _spark_pulse * (1 + _heat * 0.35);

    draw_set_color(beam_col_inner);
    draw_set_alpha(0.35 * _spark_pulse * (1 + _heat * 0.4));
    draw_circle(_lead_x, _lead_y, _lr2, false);
    draw_set_color(beam_col_core);
    draw_set_alpha(0.5 * _spark_pulse);
    draw_circle(_lead_x, _lead_y, _lr2 * 0.4, false);
}

}

if (muzzle_flash_timer < _k_muzzle_flash_duration) {
    var _mp = muzzle_flash_timer / _k_muzzle_flash_duration;
    var _ma = 1 - _mp;
    var _mr = lerp(6, _k_muzzle_flash_peak_radius, _mp);

    draw_set_color(beam_col_outer);
    draw_set_alpha(_ma * 0.5);
    draw_circle(xstart, ystart, _mr * 1.35, false);
    draw_set_color(beam_col_inner);
    draw_set_alpha(_ma * 0.6);
    draw_circle(xstart, ystart, _mr, false);
    draw_set_color(beam_col_core);
    draw_set_alpha(_ma);
    draw_circle(xstart, ystart, _mr * 0.35, false);

    var _star = _mr * (2.6 + _ma * 2.2);
    draw_set_color(beam_col_core);
    draw_set_alpha(_ma * _ma * 0.75);
    draw_line_width(xstart - _ux * _star, ystart - _uy * _star,
                    xstart + _ux * _star, ystart + _uy * _star, 1 + _ma * 2);
    draw_line_width(xstart - _vx * _star * 0.45, ystart - _vy * _star * 0.45,
                    xstart + _vx * _star * 0.45, ystart + _vy * _star * 0.45, 1 + _ma);
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
