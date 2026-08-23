// ============================================================================
// THE VAULT - RENDERING
// MASS PASS AND GLOW PASS ARE INTENTIONALLY SPLIT.
// ============================================================================


function scr_vault_hex_band(_cx, _cy, _r0, _r1, _rot, _c0, _a0, _c1, _a1) {
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= 6; _i++) {
        var _a  = _rot + _i * 60;
        var _dx = dcos(_a);
        var _dy = -dsin(_a);
        draw_vertex_color(_cx + _dx * _r0, _cy + _dy * _r0, _c0, _a0);
        draw_vertex_color(_cx + _dx * _r1, _cy + _dy * _r1, _c1, _a1);
    }
    draw_primitive_end();
}


/// @func scr_vault_hex_outline(_cx, _cy, _r, _rot, _w)
function scr_vault_hex_outline(_cx, _cy, _r, _rot, _w) {
    var _px = _cx + dcos(_rot) * _r;
    var _py = _cy - dsin(_rot) * _r;
    for (var _i = 1; _i <= 6; _i++) {
        var _a  = _rot + _i * 60;
        var _nx = _cx + dcos(_a) * _r;
        var _ny = _cy - dsin(_a) * _r;
        draw_line_width(_px, _py, _nx, _ny, _w);
        _px = _nx;
        _py = _ny;
    }
}


function scr_vault_wedge(_cx, _cy, _r0, _r1, _ang, _half0, _half1, _c0, _a0, _c1, _a1) {
    var _ia = _ang - _half0, _ib = _ang + _half0;
    var _oa = _ang - _half1, _ob = _ang + _half1;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_cx + lengthdir_x(_r0, _ia), _cy + lengthdir_y(_r0, _ia), _c0, _a0);
    draw_vertex_color(_cx + lengthdir_x(_r1, _oa), _cy + lengthdir_y(_r1, _oa), _c1, _a1);
    draw_vertex_color(_cx + lengthdir_x(_r0, _ib), _cy + lengthdir_y(_r0, _ib), _c0, _a0);
    draw_vertex_color(_cx + lengthdir_x(_r1, _ob), _cy + lengthdir_y(_r1, _ob), _c1, _a1);
    draw_primitive_end();
}


function scr_vault_slab(_cx, _cy, _ang, _r0, _r1, _hw0, _hw1, _c0, _a0, _c1, _a1) {
    var _ux = lengthdir_x(1, _ang),     _uy = lengthdir_y(1, _ang);
    var _vx = lengthdir_x(1, _ang + 90), _vy = lengthdir_y(1, _ang + 90);

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(_cx + _ux * _r0 - _vx * _hw0, _cy + _uy * _r0 - _vy * _hw0, _c0, _a0);
    draw_vertex_color(_cx + _ux * _r1 - _vx * _hw1, _cy + _uy * _r1 - _vy * _hw1, _c1, _a1);
    draw_vertex_color(_cx + _ux * _r0 + _vx * _hw0, _cy + _uy * _r0 + _vy * _hw0, _c0, _a0);
    draw_vertex_color(_cx + _ux * _r1 + _vx * _hw1, _cy + _uy * _r1 + _vy * _hw1, _c1, _a1);
    draw_primitive_end();
}


// ============================================================================
// Draw_0 - the machine, and the floor of the cell
// ============================================================================

/// @func scr_vault_draw_world()
function scr_vault_draw_world() {
    if (is_undefined(vault)) exit;

    var _V   = vault;
    var _cx  = _V.cx;
    var _cy  = _V.cy;
    var _rot = _V.rot;

    var _blood  = global.avoid_col_blood;
    var _danger = global.avoid_col_danger;
    var _warn   = global.avoid_col_warning;
    var _cyan   = global.avoid_col_cyan;
    var _cyans  = global.avoid_col_cyan_soft;
    var _armor  = global.avoid_col_armor_dark;
    var _armorm = global.avoid_col_armor_mid;
    var _edge   = global.avoid_col_armor_edge;

    var _survey = scr_vault_survey();
    var _burst  = scr_vault_burst();
    var _charge = scr_vault_charge();

    var _grow  = 1 + power(_burst, 0.55) * (_k_vault_hc_radius / _k_vault_wall_in - 1);
    var _rin   = scr_vault_circum(_k_vault_wall_in)  * _grow;
    var _rout  = scr_vault_circum(_k_vault_wall_out) * _grow;
    var _live  = 1 - _burst;

    // ---------------------------------------------------------------- SURVEY
    if (_V.stage == 0) {
        var _sv_a = power(_survey, 1.5);

        gpu_set_blendmode(bm_normal);
        var _sv_plate = power(_survey, 1.6);
        scr_vault_hex_band(_cx, _cy, 0, _rout, _rot,
                           _armor, _sv_plate * 0.42, _armor, _sv_plate * 0.74);

        gpu_set_blendmode(bm_add);

        draw_set_color(_cyan);
        draw_set_alpha((0.14 + _sv_a * 0.34) * 0.35);
        scr_vault_hex_outline(_cx, _cy, _rin, _rot, 6);
        draw_set_alpha(0.14 + _sv_a * 0.34);
        scr_vault_hex_outline(_cx, _cy, _rin, _rot, 1.6);
        draw_set_alpha(0.06 + _sv_a * 0.14);
        scr_vault_hex_outline(_cx, _cy, _rout, _rot, 1);

        for (var _sb = 0; _sb < 6; _sb++) {
            var _sr = clamp(_survey * 7.2 - _sb, 0, 1);
            if (_sr <= 0) continue;

            var _sa2 = _rot + _sb * 60;
            var _svx = _cx + lengthdir_x(_rin, _sa2);
            var _svy = _cy + lengthdir_y(_rin, _sa2);

            draw_set_color(merge_color(_cyan, c_white, 0.4));
            draw_set_alpha(_sr * (0.30 + _sv_a * 0.4));
            for (var _sk = 0; _sk < 2; _sk++) {
                var _sd = _sa2 + (_sk == 0 ? 120 : 240);
                draw_line_width(_svx, _svy,
                                _svx + lengthdir_x(17, _sd), _svy + lengthdir_y(17, _sd), 1.6);
            }
            draw_set_color(c_white);
            draw_set_alpha(_sr * (0.2 + _sv_a * 0.5));
            draw_circle(_svx, _svy, 1.6, false);
        }

        var _lockp = power(_survey, 2.6);
        for (var _sr2 = 0; _sr2 < 3; _sr2++) {
            var _srr  = 176 + _sr2 * 46;
            var _sdir = (_sr2 mod 2 == 0) ? 1 : -1;
            var _soff = (1 - _lockp) * 150 * _sdir + _V.seed * 0.02;

            draw_set_color(merge_color(_cyan, c_white, _lockp * 0.5));
            for (var _st = 0; _st < 6; _st++) {
                var _sta = _rot + 30 + _st * 60 + _soff;
                var _stx = _cx + lengthdir_x(_srr, _sta);
                var _sty = _cy + lengthdir_y(_srr, _sta);
                draw_set_alpha((0.06 + _sv_a * 0.22) * (0.5 + _lockp * 0.5));
                draw_line_width(_stx, _sty,
                                _stx + lengthdir_x(9 + _lockp * 7, _sta),
                                _sty + lengthdir_y(9 + _lockp * 7, _sta), 1.4);
            }
        }

        var _scan = (t - _k_vault_t_survey) * 4.4;
        var _scx  = _cx + lengthdir_x(_rout + 150, _scan);
        var _scy  = _cy + lengthdir_y(_rout + 150, _scan);
        draw_set_color(_cyans);
        draw_set_alpha(0.05 + _sv_a * 0.10);
        draw_line_width(_cx + lengthdir_x(40, _scan), _cy + lengthdir_y(40, _scan), _scx, _scy, 1);
        draw_set_color(c_white);
        draw_set_alpha(0.10 + _sv_a * 0.30);
        var _shx = _cx + lengthdir_x(_rin, _scan);
        var _shy = _cy + lengthdir_y(_rin, _scan);
        draw_circle(_shx, _shy, 1.8, false);

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }

    if (_V.stage < 1) exit;

    var _void   = scr_vault_void();
    var _tunnel = scr_vault_tunnel();
    var _tphase = scr_vault_tunnel_phase();
    var _iris   = scr_vault_iris();
    var _shear  = scr_vault_shear();

    // ------------------------------------------------------------ VOID WASH
    if (_void > 0.01) {
        gpu_set_blendmode(bm_normal);
        scr_vault_hex_band(_cx, _cy, _rout * 1.04, _k_vault_far_r, _rot,
                           _armor, _void * 0.96, _armor, _void);
    }

    // ------------------------------------------------------- SECTOR PLATING
    if (_void > 0.05) {
        var _plr0 = _rout * 1.30;
        var _pla  = clamp(_void, 0, 1);

        gpu_set_blendmode(bm_add);
        for (var _sp = 0; _sp < 6; _sp++) {
            var _spa = _rot + _sp * 60;
            scr_vault_wedge(_cx, _cy, _plr0, _k_vault_far_r, _spa, 30, 30,
                            merge_color(_blood, _danger, 0.30), _pla * 0.30,
                            _blood, _pla * 0.03);

            for (var _ps = 0; _ps < 3; _ps++) {
                var _psr = _plr0 + 120 + _ps * 210;
                if (_psr > _k_vault_far_r) break;
                draw_set_color(merge_color(_blood, _danger, 0.5));
                draw_set_alpha(_pla * 0.16);
                draw_line_width(_cx + lengthdir_x(_psr, _spa - 30), _cy + lengthdir_y(_psr, _spa - 30),
                                _cx + lengthdir_x(_psr, _spa + 30), _cy + lengthdir_y(_psr, _spa + 30), 2);
            }
        }
    }

    // -------------------------------------------------------------- THROAT
    // while the machine opens up and pour back inward from OVERLOAD.
    if (_tunnel > 0.01) {
        gpu_set_blendmode(bm_add);

        var _tf = _tphase - floor(_tphase);
        for (var _tr = 0; _tr < _k_vault_throat_rings; _tr++) {
            var _tk = _tr + _tf;
            var _trr = _k_vault_throat_r0 * power(_k_vault_throat_step, _tk);
            if (_trr > _k_vault_far_r) continue;

            var _tp = _tk / _k_vault_throat_rings;
            var _ta = _tunnel * (0.34 - _tp * 0.20) * min(1, _tk * 2.2);
            if (_ta <= 0.008) continue;

            var _tw  = 1 + (1 - _tp) * 2.4;
            var _tc  = merge_color(_blood, _danger, 0.25 + (1 - _tp) * 0.55);
            var _twist = _rot + _tk * 9 * _V.spin_dir;

            draw_set_color(_tc);
            draw_set_alpha(_ta * 0.4);
            scr_vault_hex_outline(_cx, _cy, _trr, _twist, _tw * 3);
            draw_set_alpha(_ta);
            scr_vault_hex_outline(_cx, _cy, _trr, _twist, _tw);
        }
    }

    // ------------------------------------------------------------- APERTURE
    if (_iris > 0.005) {
        var _ic   = clamp(_iris, 0, 1);
        var _irin = lerp(_k_vault_iris_start, _k_vault_iris_stop, _ic)
                  - max(0, _iris - 1) * 70;
        var _ispin = _V.spin_dir * (14 + _ic * 40 + _V.beat_flash * 9) + _V.seed * 0.05;
        var _ihalf = 360 / _k_vault_iris_blades;

        gpu_set_blendmode(bm_normal);
        for (var _ib = 0; _ib < _k_vault_iris_blades; _ib++) {
            var _iba = _ib * _ihalf + _ispin;
            scr_vault_wedge(_cx, _cy, _irin, _k_vault_far_r, _iba,
                            _ihalf * 0.30, _ihalf * 0.50,
                            _armorm, 0.92, _armor, 0.98);
        }

        gpu_set_blendmode(bm_add);
        for (var _ib2 = 0; _ib2 < _k_vault_iris_blades; _ib2++) {
            var _iba2 = _ib2 * _ihalf + _ispin;
            var _ihot = 0.30 + _ic * 0.35 + _V.beat_flash * 0.35;

            scr_vault_wedge(_cx, _cy, _irin, _irin + 30 + _ic * 26, _iba2,
                            _ihalf * 0.30, _ihalf * 0.40,
                            merge_color(_danger, c_white, 0.35), _ihot * 0.9,
                            _danger, 0);

            var _ilx1 = _cx + lengthdir_x(_irin, _iba2 - _ihalf * 0.30);
            var _ily1 = _cy + lengthdir_y(_irin, _iba2 - _ihalf * 0.30);
            var _ilx2 = _cx + lengthdir_x(_irin, _iba2 + _ihalf * 0.30);
            var _ily2 = _cy + lengthdir_y(_irin, _iba2 + _ihalf * 0.30);

            draw_set_color(merge_color(_warn, c_white, 0.25 + _V.beat_flash * 0.5));
            draw_set_alpha(0.55 + _ic * 0.35);
            draw_line_width(_ilx1, _ily1, _ilx2, _ily2, 2.2);

            for (var _it = 0; _it < 4; _it++) {
                var _itu = (_it + 0.5) / 4;
                var _itx = lerp(_ilx1, _ilx2, _itu);
                var _ity = lerp(_ily1, _ily2, _itu);
                draw_set_color(_edge);
                draw_set_alpha(0.22 + _ic * 0.25);
                draw_line_width(_itx, _ity,
                                _itx + lengthdir_x(15, _iba2), _ity + lengthdir_y(15, _iba2), 1.5);
            }
        }
    }

    // ---------------------------------------------------------------- KERFS
    if (_shear > 0.02 && _live > 0.02) {
        var _kw   = min(_shear, 3.0) * _k_vault_kerf_w;
        var _kr0  = _rout * 1.45;
        var _kout = _k_vault_far_r;
        var _kfade = clamp(_shear, 0, 1) * _live;

        gpu_set_blendmode(bm_normal);
        for (var _kk = 0; _kk < 6; _kk++) {
            var _ka = _rot + 30 + _kk * 60 + _V.kerf_roll;
            scr_vault_slab(_cx, _cy, _ka, _kr0, _kout, _kw * 0.55, _kw * 3.4,
                           _armor, 0.98 * _live, _armor, 0.98 * _live);
        }

        gpu_set_blendmode(bm_add);
        for (var _kk2 = 0; _kk2 < 6; _kk2++) {
            var _ka2 = _rot + 30 + _kk2 * 60 + _V.kerf_roll;
            var _kux = lengthdir_x(1, _ka2),      _kuy = lengthdir_y(1, _ka2);
            var _kvx = lengthdir_x(1, _ka2 + 90), _kvy = lengthdir_y(1, _ka2 + 90);

            for (var _ks = -1; _ks <= 1; _ks += 2) {
                var _kx1 = _cx + _kux * _kr0  + _kvx * _kw * 0.55 * _ks;
                var _ky1 = _cy + _kuy * _kr0  + _kvy * _kw * 0.55 * _ks;
                var _kx2 = _cx + _kux * _kout + _kvx * _kw * 3.4 * _ks;
                var _ky2 = _cy + _kuy * _kout + _kvy * _kw * 3.4 * _ks;

                draw_set_color(_danger);
                draw_set_alpha(_kfade * 0.34);
                draw_line_width(_kx1, _ky1, _kx2, _ky2, 5);
                draw_set_color(merge_color(_warn, c_white, 0.55));
                draw_set_alpha(_kfade * 0.75);
                draw_line_width(_kx1, _ky1, _kx2, _ky2, 1.4);
            }

            scr_vault_slab(_cx, _cy, _ka2, _kr0, _kout, _kw * 0.55, _kw * 3.4,
                           global.avoid_col_violet, _kfade * 0.13,
                           global.avoid_col_violet, 0);

            draw_set_color(global.avoid_col_violet);
            draw_set_alpha(_kfade * 0.30);
            for (var _kg = 0; _kg < 5; _kg++) {
                var _kgr = _kr0 + 90 + _kg * 150;
                if (_kgr > _kout) break;
                var _kgw = lerp(_kw * 0.55, _kw * 3.4, (_kgr - _kr0) / max(1, _kout - _kr0));
                draw_line_width(_cx + _kux * _kgr - _kvx * _kgw, _cy + _kuy * _kgr - _kvy * _kgw,
                                _cx + _kux * _kgr + _kvx * _kgw, _cy + _kuy * _kgr + _kvy * _kgw, 1);
            }
        }
    }

    // ---------------------------------------------------------------- BEAMS
    if (array_length(_V.beams) > 0) {
        gpu_set_blendmode(bm_add);

        for (var _bi = 0; _bi < array_length(_V.beams); _bi++) {
            var _bm  = _V.beams[_bi];
            var _ba  = _rot + 30 + _bm.e * 60;
            var _bl  = _bm.spd * 3.2 + 90;
            var _bnear = clamp(1 - (_bm.r - _k_vault_wall_out) / 420, 0, 1);

            scr_vault_slab(_cx, _cy, _ba, _bm.r, _bm.r + _bl,
                           _bm.w * (0.5 + _bnear * 0.5), _bm.w * 0.22,
                           merge_color(_danger, c_white, 0.4), 0.55 + _bnear * 0.35,
                           _blood, 0);

            var _bhx = _cx + lengthdir_x(_bm.r, _ba);
            var _bhy = _cy + lengthdir_y(_bm.r, _ba);
            draw_set_color(c_white);
            draw_set_alpha(0.55 + _bnear * 0.4);
            draw_line_width(_bhx - lengthdir_x(_bm.w, _ba + 90), _bhy - lengthdir_y(_bm.w, _ba + 90),
                            _bhx + lengthdir_x(_bm.w, _ba + 90), _bhy + lengthdir_y(_bm.w, _ba + 90), 2);
        }
    }

    // ----------------------------------------------------------- SHOCKWAVES
    if (array_length(_V.rings) > 0) {
        gpu_set_blendmode(bm_add);

        for (var _ri = 0; _ri < array_length(_V.rings); _ri++) {
            var _rg = _V.rings[_ri];
            var _ra = power(_rg.life / _rg.life_max, 1.5) * _rg.power;
            if (_ra <= 0.01) continue;

            var _rc = merge_color(_cyan, c_white, 0.35 + _ra * 0.35);
            draw_set_color(_rc);
            draw_set_alpha(_ra * 0.22);
            scr_vault_hex_outline(_cx, _cy, _rg.r, _rot, _rg.width * 2.4);
            draw_set_alpha(_ra * 0.62);
            scr_vault_hex_outline(_cx, _cy, _rg.r, _rot, max(1, _rg.width * 0.5));
        }
    }

    // ------------------------------------------------------------ THE MOAT
    var _moat = scr_vault_moat() * _live;
    if (_moat > 0.02) {
        gpu_set_blendmode(bm_add);

        var _mpulse = 0.85 + dsin(t * 4.2 + _V.heartbeat_phase * 30) * 0.15;

        scr_vault_hex_band(_cx, _cy, _rout * 1.02, _k_vault_iris_stop * 1.06, _rot,
                           merge_color(_danger, _warn, 0.4), _moat * 0.30 * _mpulse,
                           _blood, 0);

        // Hazard teeth, rotating, pointing back at the wall.
        var _chr = _rout * 1.24;
        var _chn = 30;
        var _chs = _V.spin_dir * (t * 0.55);
        var _cha = (0.34 + _charge * 0.35 + _V.beat_flash * 0.3) * _moat;

        for (var _ch = 0; _ch < _chn; _ch++) {
            var _chg = _chs + _ch * (360 / _chn);
            var _chx = _cx + lengthdir_x(_chr, _chg);
            var _chy = _cy + lengthdir_y(_chr, _chg);
            var _chtip_x = _chx - lengthdir_x(13, _chg);
            var _chtip_y = _chy - lengthdir_y(13, _chg);

            draw_set_color((_ch mod 3 == 0) ? merge_color(_warn, c_white, 0.4) : _danger);
            draw_set_alpha(_cha);
            draw_line_width(_chx + lengthdir_x(10, _chg + 126), _chy + lengthdir_y(10, _chg + 126),
                            _chtip_x, _chtip_y, 2.4);
            draw_line_width(_chx + lengthdir_x(10, _chg - 126), _chy + lengthdir_y(10, _chg - 126),
                            _chtip_x, _chtip_y, 2.4);
        }
    }

    // -------------------------------------------------------- THE CELL FLOOR
    if (_live > 0.02) {
        gpu_set_blendmode(bm_normal);
        scr_vault_hex_band(_cx, _cy, 0, _rin, _rot,
                           _armor, 0.62 * _live, _armor, 0.80 * _live);

        gpu_set_blendmode(bm_add);

        var _flit = (0.16 + _V.wall_hot * 0.12 + _V.heartbeat * 0.10) * _live;
        scr_vault_hex_band(_cx, _cy, _rin * 0.34, _rin, _rot,
                           _cyan, 0, merge_color(_cyan, c_white, 0.2), _flit);

        var _fp = 0.6 + dsin(t * 3.1) * 0.4;
        for (var _fr = 0; _fr < 3; _fr++) {
            draw_set_color(_cyan);
            draw_set_alpha((0.07 + _fr * 0.022) * _live * (0.7 + _fp * 0.3));
            scr_vault_hex_outline(_cx, _cy, _rin * (0.42 + _fr * 0.23), _rot, 1);
        }

        for (var _fs = 0; _fs < 6; _fs++) {
            var _fsa = _rot + _fs * 60;
            draw_set_color(_cyan);
            draw_set_alpha(0.06 * _live);
            draw_line_width(_cx + lengthdir_x(_rin * 0.40, _fsa), _cy + lengthdir_y(_rin * 0.40, _fsa),
                            _cx + lengthdir_x(_rin, _fsa), _cy + lengthdir_y(_rin, _fsa), 1);
        }

        var _sbp  = frac((t - _k_vault_beats[0]) / 62);
        var _sby  = _cy + lerp(-_rin * 0.88, _rin * 0.88, _sbp);
        var _sbhw = max(0, _rin - abs(_sby - _cy) * 0.5774) * 0.94;
        if (_sbhw > 4) {
            draw_set_color(_cyans);
            draw_set_alpha(0.10 * _live);
            draw_line_width(_cx - _sbhw, _sby, _cx + _sbhw, _sby, 3);
            draw_set_color(c_white);
            draw_set_alpha(0.07 * _live);
            draw_line_width(_cx - _sbhw, _sby, _cx + _sbhw, _sby, 1);
        }
    }

    // ------------------------------------------------------------- HANDOFF
    if (_burst > 0) {
        gpu_set_blendmode(bm_add);

        for (var _pr = 0; _pr < _k_vault_print_rings; _pr++) {
            var _pp = clamp(_burst * 1.55 - _pr * 0.10, 0, 1);
            if (_pp <= 0 || _pp >= 1) continue;

            var _prr = lerp(scr_vault_circum(_k_vault_wall_in), _k_vault_hc_radius * 1.12,
                            1 - power(1 - _pp, 2.2));
            var _pa2 = sin(_pp * pi) * (0.75 - _pr * 0.07);

            draw_set_color(merge_color(_danger, c_white, 0.35));
            draw_set_alpha(_pa2 * 0.24);
            scr_vault_hex_outline(_cx, _cy, _prr, _rot + _pr * 12, 9);
            draw_set_color(merge_color(_warn, c_white, 0.6));
            draw_set_alpha(_pa2 * 0.7);
            scr_vault_hex_outline(_cx, _cy, _prr, _rot + _pr * 12, 2);
        }

        var _wa = power(_burst, 0.8) * (1 - power(_burst, 3)) * 1.6;
        if (_wa > 0.01) {
            var _wtop = _cy - 700;
            var _wbot = _cy + 700;
            for (var _ws = -1; _ws <= 1; _ws += 2) {
                var _wx = _cx + _k_vault_hc_radius * _ws;
                draw_set_color(_danger);
                draw_set_alpha(_wa * 0.30);
                draw_line_width(_wx, _wtop, _wx, _wbot, 16);
                draw_set_color(c_white);
                draw_set_alpha(_wa * 0.55);
                draw_line_width(_wx, _wtop, _wx, _wbot, 2);
            }
        }
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}



/// @func scr_vault_draw_shell()
function scr_vault_draw_shell() {
    if (is_undefined(vault)) exit;

    var _V = vault;
    if (_V.stage < 1) exit;

    var _cx  = _V.cx;
    var _cy  = _V.cy;
    var _rot = _V.rot;

    var _cyan   = global.avoid_col_cyan;
    var _cyans  = global.avoid_col_cyan_soft;
    var _edge   = global.avoid_col_armor_edge;
    var _armor  = global.avoid_col_armor_dark;
    var _armorm = global.avoid_col_armor_mid;
    var _danger = global.avoid_col_danger;
    var _warn   = global.avoid_col_warning;

    var _burst  = scr_vault_burst();
    var _live   = 1 - power(_burst, 1.4);
    if (_live <= 0.01) exit;

    var _grow = 1 + power(_burst, 0.55) * (_k_vault_hc_radius / _k_vault_wall_in - 1);
    var _rin  = scr_vault_circum(_k_vault_wall_in)  * _grow;
    var _rout = scr_vault_circum(_k_vault_wall_out) * _grow;

    var _mass   = _live * _live;
    var _lock   = scr_vault_lock();
    var _charge = scr_vault_charge();
    var _hot    = clamp(_V.wall_hot + _V.beat_flash * 0.5 + _V.heartbeat * 0.5, 0, 1);

    // ------------------------------------------------------------- PLATES
    for (var _e = 0; _e < 6; _e++) {
        var _n   = _rot + 30 + _e * 60;
        var _av  = _rot + _e * 60;
        var _bv  = _rot + (_e + 1) * 60;

        var _ax_i = _cx + lengthdir_x(_rin, _av),  _ay_i = _cy + lengthdir_y(_rin, _av);
        var _bx_i = _cx + lengthdir_x(_rin, _bv),  _by_i = _cy + lengthdir_y(_rin, _bv);
        var _ax_o = _cx + lengthdir_x(_rout, _av), _ay_o = _cy + lengthdir_y(_rout, _av);
        var _bx_o = _cx + lengthdir_x(_rout, _bv), _by_o = _cy + lengthdir_y(_rout, _bv);

        var _ehit  = _V.edge_hit[_e];
        var _ewarn = _V.edge_warn[_e];
        var _eheat = clamp(_hot * 0.6 + _ehit + _ewarn * 0.9, 0, 1);

        // while scr_riser_inside still lets a player through it would be the
        var _elock = _lock;
        if (!is_undefined(riser) && _e == riser.door) {
            var _rd = scr_riser_door();
            if (_rd > 0.02) {
                var _span = _k_riser_door_half * 2 / (_k_vault_wall_in * 2 * 0.5774);
                _elock = min(_elock, 1 - _span * _rd);
            }
        }

        for (var _h = 0; _h < 2; _h++) {
            var _u0 = (_h == 0) ? 0 : 1;
            var _u1 = (_h == 0) ? (_elock * 0.5) : (1 - _elock * 0.5);
            if (abs(_u1 - _u0) < 0.004) continue;

            var _p0ix = lerp(_ax_i, _bx_i, _u0), _p0iy = lerp(_ay_i, _by_i, _u0);
            var _p1ix = lerp(_ax_i, _bx_i, _u1), _p1iy = lerp(_ay_i, _by_i, _u1);
            var _p0ox = lerp(_ax_o, _bx_o, _u0), _p0oy = lerp(_ay_o, _by_o, _u0);
            var _p1ox = lerp(_ax_o, _bx_o, _u1), _p1oy = lerp(_ay_o, _by_o, _u1);

            gpu_set_blendmode(bm_normal);
            draw_primitive_begin(pr_trianglestrip);
            draw_vertex_color(_p0ix, _p0iy, _armorm, _mass);
            draw_vertex_color(_p0ox, _p0oy, _armor,  _mass);
            draw_vertex_color(_p1ix, _p1iy, _armorm, _mass);
            draw_vertex_color(_p1ox, _p1oy, _armor,  _mass);
            draw_primitive_end();

            gpu_set_blendmode(bm_add);

            draw_set_color(merge_color(_cyan, c_white, 0.25 + _eheat * 0.45));
            draw_set_alpha(_live * (0.30 + _eheat * 0.35));
            draw_line_width(_p0ix, _p0iy, _p1ix, _p1iy, 7);
            draw_set_color(c_white);
            draw_set_alpha(_live * (0.62 + _eheat * 0.38));
            draw_line_width(_p0ix, _p0iy, _p1ix, _p1iy, 1.8);

            draw_set_color(merge_color(_danger, c_white, _ehit * 0.6));
            draw_set_alpha(_live * (0.16 + _ehit * 0.5 + _charge * 0.14));
            draw_line_width(_p0ox, _p0oy, _p1ox, _p1oy, 3);

            var _ribs = 5;
            draw_set_color(_edge);
            draw_set_alpha(_live * (0.14 + _eheat * 0.20));
            for (var _rb = 0; _rb <= _ribs; _rb++) {
                var _ru = _u0 + (_u1 - _u0) * (_rb / _ribs);
                draw_line_width(lerp(_ax_i, _bx_i, _ru), lerp(_ay_i, _by_i, _ru),
                                lerp(_ax_o, _bx_o, _ru), lerp(_ay_o, _by_o, _ru), 1);
            }

            var _pk = 3;
            for (var _pi = 0; _pi < _pk; _pi++) {
                var _pf = frac(t / 46 + _pi / _pk + _e * 0.17);
                var _pu = _u0 + (_u1 - _u0) * _pf;
                var _pxx = lerp(_ax_i, _bx_i, _pu);
                var _pyy = lerp(_ay_i, _by_i, _pu);
                draw_set_color(merge_color(_cyans, c_white, 0.5));
                draw_set_alpha(_live * (0.30 + _eheat * 0.4));
                draw_line_width(_pxx, _pyy,
                                _pxx + lengthdir_x(5, _n), _pyy + lengthdir_y(5, _n), 3);
            }
        }

        if (_e == 4 && _lock >= 0.999 && _burst <= 0.01) {
            gpu_set_blendmode(bm_add);
            draw_set_color(merge_color(_cyans, c_white, 0.55));
            draw_set_alpha(_live * (0.45 + _eheat * 0.3));
            draw_line_width(_ax_i, _ay_i, _bx_i, _by_i, 2.6);

            draw_set_color(_edge);
            draw_set_alpha(_live * 0.30);
            for (var _tk = 1; _tk < 9; _tk++) {
                var _tu = _tk / 9;
                var _tx = lerp(_ax_i, _bx_i, _tu);
                var _ty = lerp(_ay_i, _by_i, _tu);
                draw_line_width(_tx, _ty, _tx, _ty - 4, 1.4);
            }
        }

        if (_V.seam_flash > 0.02 && _elock >= 0.999) {
            var _smx = (_ax_i + _bx_i) * 0.5;
            var _smy = (_ay_i + _by_i) * 0.5;
            gpu_set_blendmode(bm_add);
            draw_set_color(c_white);
            draw_set_alpha(_V.seam_flash * _live * 0.9);
            draw_line_width(_smx - lengthdir_x(11, _n), _smy - lengthdir_y(11, _n),
                            _smx + lengthdir_x(15, _n), _smy + lengthdir_y(15, _n), 2);
        }

        if (_ehit > 0.02) {
            var _hx = _cx + lengthdir_x(_rout, _n);
            var _hy = _cy + lengthdir_y(_rout, _n);
            gpu_set_blendmode(bm_add);
            for (var _hr = 0; _hr < 3; _hr++) {
                draw_set_color(merge_color(_warn, c_white, 0.5));
                draw_set_alpha(_ehit * _live * (0.30 - _hr * 0.08));
                draw_circle(_hx, _hy, (1 - _ehit) * (30 + _hr * 26) + 6, true);
            }
        }
    }

    // ------------------------------------------------------------- PYLONS
    for (var _p = 0; _p < 6; _p++) {
        var _seat = _V.pylon[_p];
        if (_seat <= 0.01) continue;

        var _pa  = _rot + _p * 60;
        var _pin = _rin * 0.94;
        var _pou = _rout + _k_vault_pylon_len * (1 + _V.beat_flash * 0.55);
        var _pw  = 13;

        var _pux = lengthdir_x(1, _pa),      _puy = lengthdir_y(1, _pa);
        var _pvx = lengthdir_x(1, _pa + 90), _pvy = lengthdir_y(1, _pa + 90);

        gpu_set_blendmode(bm_normal);
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_color(_cx + _pux * _pin - _pvx * _pw, _cy + _puy * _pin - _pvy * _pw, _armorm, _mass);
        draw_vertex_color(_cx + _pux * _pou - _pvx * 3,   _cy + _puy * _pou - _pvy * 3,   _armor,  _mass);
        draw_vertex_color(_cx + _pux * _pin + _pvx * _pw, _cy + _puy * _pin + _pvy * _pw, _armorm, _mass);
        draw_vertex_color(_cx + _pux * _pou + _pvx * 3,   _cy + _puy * _pou + _pvy * 3,   _armor,  _mass);
        draw_primitive_end();

        gpu_set_blendmode(bm_add);

        var _phot = clamp(_hot * 0.5 + _V.beat_flash * 0.6 + _charge * 0.4, 0, 1);

        for (var _ps = -1; _ps <= 1; _ps += 2) {
            draw_set_color(merge_color(_cyan, c_white, 0.3 + _phot * 0.4));
            draw_set_alpha(_live * (0.35 + _phot * 0.4));
            draw_line_width(_cx + _pux * _pin + _pvx * _pw * _ps, _cy + _puy * _pin + _pvy * _pw * _ps,
                            _cx + _pux * _pou + _pvx * 3 * _ps,   _cy + _puy * _pou + _pvy * 3 * _ps, 1.6);
        }

        var _hvx = _cx + _pux * _rin;
        var _hvy = _cy + _puy * _rin;
        draw_set_color(merge_color(_cyan, c_white, 0.55 + _phot * 0.45));
        draw_set_alpha(_live * (0.5 + _phot * 0.5));
        draw_circle(_hvx, _hvy, 3.2 + _phot * 2.4, false);
        draw_set_color(c_white);
        draw_set_alpha(_live * (0.35 + _phot * 0.5));
        draw_circle(_hvx, _hvy, 1.4 + _phot * 1.2, false);

        draw_set_color(_cyan);
        draw_set_alpha(_live * (0.28 + _phot * 0.32));
        for (var _bk = 0; _bk < 2; _bk++) {
            var _bd = _pa + (_bk == 0 ? 120 : 240);
            draw_line_width(_hvx, _hvy,
                            _hvx + lengthdir_x(20, _bd), _hvy + lengthdir_y(20, _bd), 2);
        }
    }

    // -------------------------------------------------------------- BREACH
    if (_V.breach > 0.02) {
        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_warn, c_white, _V.breach * 0.5));
        draw_set_alpha(_V.breach * 0.55);
        scr_vault_hex_outline(_cx, _cy, _rin, _rot, 5 + _V.breach * 9);
        draw_set_alpha(_V.breach * 0.30);
        scr_vault_hex_outline(_cx, _cy, _rin * (1 + (1 - _V.breach) * 0.5), _rot, 3);
    }

    // --------------------------------------------------------------- VENTS
    if (array_length(_V.vents) > 0) {
        gpu_set_blendmode(bm_add);
        scr_draw_vent_streams(_V.vents, 0, 0, 1);
    }

    // ---------------------------------------------------------------- GLOW
    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);

    var _uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);

    var _blob = sprite_get_width(spr_glow_blob) * 0.5;
    var _gr   = color_get_red(_cyan) / 255;
    var _gg   = color_get_green(_cyan) / 255;
    var _gb   = color_get_blue(_cyan) / 255;

    for (var _gv = 0; _gv < 6; _gv++) {
        var _gva = _rot + _gv * 60;
        var _gvi = clamp(0.55 + _hot * 0.55 + _V.beat_flash * 0.5, 0, 1.4);
        shader_set_uniform_f(global.u_glow_color, lerp(_gr, 1, _hot), lerp(_gg, 1, _hot), lerp(_gb, 1, _hot));
        shader_set_uniform_f(global.u_glow_intensity, _gvi);

        var _gs = (10 + _hot * 8) / _blob;
        draw_sprite_ext(spr_glow_blob, 0,
                        _cx + lengthdir_x(_rin, _gva), _cy + lengthdir_y(_rin, _gva),
                        _gs, _gs, 0, c_white, _live);
    }

    for (var _ge = 0; _ge < 6; _ge++) {
        var _gea = _rot + 30 + _ge * 60;
        var _geh = clamp(_V.edge_hit[_ge] + _V.edge_warn[_ge] * 0.8, 0, 1);
        if (_geh <= 0.05) continue;

        shader_set_uniform_f(global.u_glow_color, 1, lerp(0.3, 1, _geh), lerp(0.28, 1, _geh));
        shader_set_uniform_f(global.u_glow_intensity, clamp(_geh * 1.3, 0, 1.3));

        var _ges = (12 + _geh * 16) / _blob;
        draw_sprite_ext(spr_glow_blob, 0,
                        _cx + lengthdir_x(_rout, _gea), _cy + lengthdir_y(_rout, _gea),
                        _ges, _ges, 0, c_white, _live);
    }

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}



/// @func scr_vault_draw_bolts(_camx, _camy, _sx, _sy)
function scr_vault_draw_bolts(_camx, _camy, _sx, _sy) {
    if (is_undefined(vault)) exit;

    var _V = vault;
    var _cx = _V.cx;
    var _cy = _V.cy;

    var _gcx = (_cx - _camx) * _sx;
    var _gcy = (_cy - _camy) * _sy;

    var _cyan   = global.avoid_col_cyan;
    var _danger = global.avoid_col_danger;

    gpu_set_blendmode(bm_add);

    for (var _a = 0; _a < array_length(_V.arcs); _a++) {
        var _ar = _V.arcs[_a];
        var _al = _ar.life / _ar.life_max;

        var _x1 = (_cx + lengthdir_x(_ar.r0, _ar.ang) - _camx) * _sx;
        var _y1 = (_cy + lengthdir_y(_ar.r0, _ar.ang) - _camy) * _sy;
        var _x2 = (_cx + lengthdir_x(_ar.r1, _ar.ang) - _camx) * _sx;
        var _y2 = (_cy + lengthdir_y(_ar.r1, _ar.ang) - _camy) * _sy;

        scr_draw_energy_bolt(_x1, _y1, _x2, _y2, _al * 0.9,
                             merge_color(_cyan, c_white, _ar.hot * 0.5),
                             _ar.off, (1 + _ar.hot * 1.6) * _sx, 0.85);
    }

    for (var _b = 0; _b < array_length(_V.beams); _b++) {
        var _bm = _V.beams[_b];
        var _ba = _V.rot + 30 + _bm.e * 60;
        var _bl = _bm.spd * 3.2 + 90;

        var _bx1 = (_cx + lengthdir_x(_bm.r + _bl, _ba) - _camx) * _sx;
        var _by1 = (_cy + lengthdir_y(_bm.r + _bl, _ba) - _camy) * _sy;
        var _bx2 = (_cx + lengthdir_x(_bm.r, _ba) - _camx) * _sx;
        var _by2 = (_cy + lengthdir_y(_bm.r, _ba) - _camy) * _sy;

        scr_draw_energy_bolt(_bx1, _by1, _bx2, _by2, 0.85, _danger, _bm.off, 1.8 * _sx, 0.8);
    }

    var _rim = clamp(_V.wall_hot * 0.5 + _V.beat_flash * 0.6 + _V.heartbeat * 0.5, 0, 1);
    if (_rim > 0.02 && _V.stage >= 1) {
        var _rr = _k_vault_wall_in * _sx / VAULT_COS30;
        draw_set_color(merge_color(_cyan, c_white, 0.5));
        draw_set_alpha(_rim * 0.35);
        scr_vault_hex_outline(_gcx, _gcy, _rr, _V.rot, 2.5 * _sx);
        lightning_bloom_boost += _rim * 0.05;
    }

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
