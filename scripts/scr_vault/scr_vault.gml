// ============================================================================
// THE VAULT
// PRESERVES THE PHANTOM MAZE MUSICAL LANDING FRAMES.
// ============================================================================

#macro VAULT_COS30 0.86602540


/// @func scr_vault_begin()
function scr_vault_begin() {
    var _s0 = scr_vault_stage_for_t(t);

    var _V = {
        stage : _s0 - 1,
        age   : 0,

        cx  : _k_vault_cx,
        cy  : _k_vault_cy,
        rot : _k_vault_hex_rot,

        lethal     : (_s0 >= 3),
        beat_flash : 0,
        seam_flash : 0,
        wall_hot   : 0,
        breach     : 0,

        heartbeat       : 0,
        heartbeat_phase : 0,

        edge_hit  : array_create(6, 0),
        edge_warn : array_create(6, 0),
        pylon     : array_create(6, (_s0 >= 1) ? 1 : 0),

        beams : [],
        arcs  : [],
        vents : [],
        rings : [],

        floor : noone,

        beam_timer : 0,

        spin_dir  : choose(-1, 1),
        kerf_roll : random_range(-3, 3),
        beam_next : irandom(5),
        seed      : random(1000)
    };

    vault = _V;
}


/// @func scr_vault_clear()
function scr_vault_clear() {
    if (!is_undefined(vault) && instance_exists(vault.floor)) instance_destroy(vault.floor);
    vault = undefined;
    dna_veil = 1;
}


/// @func scr_vault_seal_floor()
function scr_vault_seal_floor() {
    var _V = vault;
    if (instance_exists(_V.floor)) exit;

    var _top  = _V.cy + _k_vault_wall_in;
    var _half = _k_vault_wall_in * 0.5774;      // half of a hexagon edge

    var _p = instance_create_layer(_V.cx, _top, layer, oPlatform);
    with (_p) {
        visible = false;
        image_angle  = 0;
        image_xscale = (_half * 2) / sprite_get_width(sprite_index);
        image_yscale = 1;
        y = _top - sprite_origin_to_top(sprite_index) * image_yscale;
    }

    _V.floor = _p;
}


/// @func scr_vault_stage_for_t(_time)
function scr_vault_stage_for_t(_time) {
    if (_time >= _k_vault_t_discharge) return 6;

    var _s = 0;
    for (var _i = 0; _i < array_length(_k_vault_beats); _i++) {
        if (_time >= _k_vault_beats[_i]) _s = _i + 1;
    }
    return _s;
}


/// @func scr_vault_tween(_from, _to, _t0, _t1, _pw)
function scr_vault_tween(_from, _to, _t0, _t1, _pw) {
    var _p = clamp((t - _t0) / max(1, _t1 - _t0), 0, 1);
    return lerp(_from, _to, power(_p, _pw));
}



/// @func scr_vault_circum(_apothem)
function scr_vault_circum(_apothem) {
    return _apothem / VAULT_COS30;
}


/// @func scr_vault_reach(_V, _px, _py)
function scr_vault_reach(_V, _px, _py) {
    var _dx = _px - _V.cx;
    var _dy = _py - _V.cy;
    var _m  = -999999;

    for (var _i = 0; _i < 6; _i++) {
        var _a = _V.rot + 30 + _i * 60;
        var _p = _dx * dcos(_a) - _dy * dsin(_a);
        if (_p > _m) _m = _p;
    }
    return _m;
}


/// @func scr_vault_nearest_edge(_V, _px, _py)
function scr_vault_nearest_edge(_V, _px, _py) {
    var _dx = _px - _V.cx;
    var _dy = _py - _V.cy;
    var _m  = -999999;
    var _e  = 0;

    for (var _i = 0; _i < 6; _i++) {
        var _a = _V.rot + 30 + _i * 60;
        var _p = _dx * dcos(_a) - _dy * dsin(_a);
        if (_p > _m) { _m = _p; _e = _i; }
    }
    return _e;
}



/// @func scr_vault_survey()
function scr_vault_survey() {
    return clamp((t - _k_vault_t_survey) / max(1, _k_vault_beats[0] - _k_vault_t_survey), 0, 1);
}


/// @func scr_vault_lock()
function scr_vault_lock() {
    if (t < _k_vault_beats[0]) return 0;
    return scr_vault_tween(0, 1, _k_vault_beats[0], _k_vault_beats[1], 1.7);
}


/// @func scr_vault_iris()
function scr_vault_iris() {
    var _b2 = _k_vault_beats[2];
    var _b3 = _k_vault_beats[3];
    var _b4 = _k_vault_beats[4];
    var _td = _k_vault_t_discharge;

    if (t >= _td) return 1.08 - clamp((t - _td) / 18, 0, 1) * 2.0;
    if (t >= _b4) return scr_vault_tween(1.00, 1.08, _b4, _td, 1.0);
    if (t >= _b3) return scr_vault_tween(0.80, 1.00, _b3 + 5, _b4, 2.6);
    if (t >= _b2) return scr_vault_tween(0.55, 0.80, _b2 + 3, _b3, 2.4);
    return scr_vault_tween(0, 0.55, _b2 - _k_vault_lead, _b2, 2.4);
}


/// @func scr_vault_tunnel()
function scr_vault_tunnel() {
    var _td = _k_vault_t_discharge;
    if (t >= _td) return max(0, 1 - (t - _td) / 20);
    if (t >= _k_vault_beats[4]) return 1;
    if (t >= _k_vault_beats[3]) return scr_vault_tween(0.78, 1.00, _k_vault_beats[3], _k_vault_beats[4], 1.2);
    if (t >= _k_vault_beats[2]) return scr_vault_tween(0.55, 0.78, _k_vault_beats[2], _k_vault_beats[3], 1.2);
    if (t >= _k_vault_beats[1]) return scr_vault_tween(0, 0.55, _k_vault_beats[1] + 2, _k_vault_beats[2], 2.4);
    return 0;
}


/// @func scr_vault_tunnel_phase()
function scr_vault_tunnel_phase() {
    var _t0 = _k_vault_beats[1] + 2;
    var _b4 = _k_vault_beats[4];
    var _td = _k_vault_t_discharge;

    if (t < _t0) return 0;
    if (t < _b4) return (t - _t0) * 0.032;

    var _at_turn = (_b4 - _t0) * 0.032;
    if (t < _td) return _at_turn - (t - _b4) * 0.075;

    return _at_turn - (_td - _b4) * 0.075 + (t - _td) * 0.26;
}


/// @func scr_vault_shear()
function scr_vault_shear() {
    var _b3 = _k_vault_beats[3];
    var _b4 = _k_vault_beats[4];
    var _td = _k_vault_t_discharge;

    if (t >= _td) return 1.0 + clamp((t - _td) / 16, 0, 1) * 2.6;
    if (t >= _b4) return 0.14;
    if (t >= _b4 - 5) return scr_vault_tween(1.0, 0.14, _b4 - 5, _b4, 1.6);
    if (t >= _b3) return 1.0;
    return scr_vault_tween(0, 1.0, _b3 - 6, _b3, 3.0);
}


/// @func scr_vault_void()
function scr_vault_void() {
    var _td = _k_vault_t_discharge;

    if (t >= _td) return max(0, 0.86 - (t - _td) / 22 * 0.86);
    if (t >= _k_vault_beats[4]) return scr_vault_tween(0.70, 0.86, _k_vault_beats[4], _td, 1.0);
    if (t >= _k_vault_beats[2]) return scr_vault_tween(0.55, 0.70, _k_vault_beats[2], _k_vault_beats[4], 1.0);
    if (t >= _k_vault_beats[1]) return scr_vault_tween(0.34, 0.55, _k_vault_beats[1], _k_vault_beats[2], 1.0);
    if (t >= _k_vault_beats[0]) return scr_vault_tween(0.06, 0.34, _k_vault_beats[0], _k_vault_beats[1], 1.0);
    return 0;
}


/// @func scr_vault_moat()
function scr_vault_moat() {
    var _td = _k_vault_t_discharge;
    if (t >= _td) return max(0, 1 - (t - _td) / 14);
    if (t >= _k_vault_beats[4]) return 1;
    if (t >= _k_vault_beats[1]) return scr_vault_tween(0.55, 1.0, _k_vault_beats[1], _k_vault_beats[4], 1.0);
    return 0;
}


/// @func scr_vault_charge()
function scr_vault_charge() {
    if (t < _k_vault_beats[4]) return 0;
    return clamp((t - _k_vault_beats[4]) / max(1, _k_vault_t_discharge - _k_vault_beats[4]), 0, 1);
}


/// @func scr_vault_burst()
function scr_vault_burst() {
    if (t < _k_vault_t_discharge) return 0;
    return clamp((t - _k_vault_t_discharge) / _k_vault_burst_frames, 0, 1);
}



/// @func scr_vault_enter_stage(_stage)
function scr_vault_enter_stage(_stage) {
    var _V = vault;
    var _cx = _V.cx;
    var _cy = _V.cy;

    switch (_stage) {

        // -- SURVEY ---------------------------------------------------------
        case 0:
            break;

        // -- ANCHOR ---------------------------------------------------------
        case 1:
            for (var _p = 0; _p < 6; _p++) _V.pylon[_p] = 1;
            _V.beat_flash = 1;
            _V.wall_hot   = 0.85;

            scr_vault_push_ring(_V, scr_vault_circum(_k_vault_wall_in), 26, 34, 8, 1.15);

            for (var _v = 0; _v < 6; _v++) {
                var _pa = _V.rot + _v * 60;
                var _pr = scr_vault_circum(_k_vault_wall_out);
                for (var _s = 0; _s < 4; _s++) {
                    scr_vault_spawn_vent(_V, _cx + lengthdir_x(_pr, _pa), _cy + lengthdir_y(_pr, _pa),
                                         _pa + random_range(-38, 38), 0.75);
                }
            }

            scr_impact_pulse(0.30, 0.85, 0.18, _cx, _cy);
            hitstop_frames = max(hitstop_frames, 2);

            if (instance_exists(oCameraController)) {
                oCameraController.shake              = max(oCameraController.shake, 10);
                oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.06);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.28);
                oCameraController.letterbox_target   = max(oCameraController.letterbox_target, 0.75);
            }

            scr_vault_purge_lattice();
            break;

        // -- SEAL -----------------------------------------------------------
        case 2:
            _V.beat_flash = 1;
            _V.seam_flash = 1;
            _V.wall_hot   = 1;

            scr_vault_push_ring(_V, scr_vault_circum(_k_vault_wall_out), 15, 40, 11, 1.3);

            for (var _e = 0; _e < 6; _e++) {
                var _ea = _V.rot + 30 + _e * 60;
                var _er = _k_vault_wall_out;
                for (var _s2 = 0; _s2 < 3; _s2++) {
                    scr_vault_spawn_vent(_V, _cx + lengthdir_x(_er, _ea), _cy + lengthdir_y(_er, _ea),
                                         _ea + choose(-74, 74) + random_range(-14, 14), 0.85);
                }
                scr_vault_push_arc(_V, _ea, _er, random_range(210, 330), 0.9);
            }

            scr_impact_pulse(0.34, 1.05, 0.22, _cx, _cy);

            if (instance_exists(oCameraController)) {
                oCameraController.shake              = max(oCameraController.shake, 13);
                oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.08);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.34);
                oCameraController.angle_kick         = 1.9 * _V.spin_dir;
                oCameraController.letterbox_target   = max(oCameraController.letterbox_target, 0.85);
            }
            break;

        // -- WAKE -----------------------------------------------------------
        case 3:
            _V.lethal     = true;
            _V.beat_flash = 0.85;
            _V.wall_hot   = max(_V.wall_hot, 0.5);

            scr_vault_push_ring(_V, 250, 20, 30, 9, 0.9);
            scr_impact_pulse(0.30, 0.80, 0.20, _cx, _cy);

            if (instance_exists(oCameraController)) {
                oCameraController.shake              = max(oCameraController.shake, 11);
                oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.05);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.16);
                oCameraController.letterbox_target   = max(oCameraController.letterbox_target, 0.9);
            }
            break;

        // -- SCALE ----------------------------------------------------------
        case 4:
            _V.beat_flash = 0.95;
            _V.wall_hot   = max(_V.wall_hot, 0.6);
            _V.beam_timer = 0;

            scr_vault_push_ring(_V, 300, 24, 30, 12, 1.0);

            for (var _k = 0; _k < 6; _k++) {
                scr_vault_push_arc(_V, _V.rot + 30 + _k * 60 + random_range(-22, 22),
                                   _k_vault_wall_out, random_range(360, 620), 0.8);
            }

            scr_impact_pulse(0.36, 1.15, 0.24, _cx, _cy);
            tear_amount = max(tear_amount, 0.14);

            if (instance_exists(oCameraController)) {
                oCameraController.shake              = max(oCameraController.shake, 14);
                oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.07);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.20);
                oCameraController.angle_kick         = -2.3 * _V.spin_dir;
                oCameraController.letterbox_target   = max(oCameraController.letterbox_target, 0.95);
            }
            break;

        // -- OVERLOAD -------------------------------------------------------
        case 5:
            _V.beat_flash = 0.6;
            _V.heartbeat_phase = 0;

            scr_impact_pulse(0.26, 0.45, 0.14, _cx, _cy);

            if (instance_exists(oCameraController)) {
                oCameraController.zoom_punch       = max(oCameraController.zoom_punch, 0.03);
                oCameraController.letterbox_target = max(oCameraController.letterbox_target, 1.0);
            }
            break;

        // -- DISCHARGE ------------------------------------------------------
        case 6:
            _V.lethal     = false;
            _V.beat_flash = 1;
            _V.seam_flash = 1;
            _V.wall_hot   = 1;
            _V.beams      = [];

            scr_vault_push_ring(_V, scr_vault_circum(_k_vault_wall_in), 30, 44, 14, 1.4);
            scr_vault_push_ring(_V, scr_vault_circum(_k_vault_wall_out), 17, 56, 22, 1.0);

            for (var _b = 0; _b < 10; _b++) {
                scr_vault_push_arc(_V, random(360), _k_vault_wall_in, random_range(420, 780), 1);
            }
            for (var _pe = 0; _pe < 6; _pe++) {
                var _pn = _V.rot + 30 + _pe * 60;
                var _ph = _k_vault_wall_out * 0.5774;
                for (var _pk = 0; _pk < 5; _pk++) {
                    var _pu = (_pk / 4 - 0.5) * 2 * _ph;
                    var _px2 = _cx + lengthdir_x(_k_vault_wall_out, _pn);
                    var _py2 = _cy + lengthdir_y(_k_vault_wall_out, _pn);
                    _px2 += lengthdir_x(_pu, _pn + 90);
                    _py2 += lengthdir_y(_pu, _pn + 90);
                    scr_vault_spawn_vent(_V, _px2, _py2, _pn + random_range(-26, 26), 0.8);
                }
            }

            hitstop_frames = max(hitstop_frames, 3);

            tear_amount         = max(tear_amount, 0.30);
            global_ripple_pulse = max(global_ripple_pulse, 0.55);
            scr_impact_pulse(0.46, 1.30, 0.34, _cx, _cy);
            scr_bg_bass_hit();

            if (instance_exists(oCameraController)) {
                oCameraController.shake              = max(oCameraController.shake, 20);
                oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.16);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.50);
                oCameraController.angle_kick         = 2.8 * _V.spin_dir;
                oCameraController.letterbox_target   = 0;
            }
            break;
    }
}


function scr_vault_push_ring(_V, _r, _vel, _life, _width, _power) {
    if (array_length(_V.rings) >= _k_vault_ring_max) array_delete(_V.rings, 0, 1);
    array_push(_V.rings, {
        r : _r, vel : _vel, life : _life, life_max : _life,
        width : _width, power : _power
    });
}


/// @func scr_vault_push_arc(_V, _ang, _from_r, _reach, _hot)
function scr_vault_push_arc(_V, _ang, _from_r, _reach, _hot) {
    if (array_length(_V.arcs) >= _k_vault_arc_max) array_delete(_V.arcs, 0, 1);
    array_push(_V.arcs, {
        ang : _ang, r0 : _from_r, r1 : _from_r + _reach,
        life : irandom_range(5, 10), life_max : 10, hot : _hot,
        off : scr_bolt_offsets(4, 14 + _hot * 22)
    });
}


/// @func scr_vault_spawn_vent(_V, _x, _y, _dir, _hot)
function scr_vault_spawn_vent(_V, _x, _y, _dir, _hot) {
    scr_spawn_vent_stream(_V.vents, _x, _y, _dir, _hot,
                          [global.avoid_col_cyan, global.avoid_col_cyan_soft, global.avoid_col_armor_edge],
                          _k_vault_vent_max);
}


/// @func scr_vault_purge_lattice()
function scr_vault_purge_lattice() {
    if (is_undefined(lat)) exit;

    var _L = lat;
    _L.phase  = "cool";
    _L.cool_t = 0;
    _L.cool_len = 14;
    _L.flash  = max(_L.flash, 0.7);

    for (var _n = 0; _n < array_length(_L.nodes); _n++) {
        var _nd = _L.nodes[_n];
        var _d  = point_direction(_k_vault_cx, _k_vault_cy, _nd.bx, _nd.by);
        _nd.kx += lengthdir_x(3.4, _d);
        _nd.ky += lengthdir_y(3.4, _d);
    }
}


// ---------------------------------------------------------------------------
// Per-frame
// ---------------------------------------------------------------------------

/// @func scr_vault_update()
function scr_vault_update() {
    if (is_undefined(vault)) exit;

    var _V = vault;
    _V.age++;

    var _want = scr_vault_stage_for_t(t);
    while (_V.stage < _want) {
        _V.stage++;
        scr_vault_enter_stage(_V.stage);
    }

    var _cx = _V.cx;
    var _cy = _V.cy;

    if (_V.stage >= 2 && _V.stage < 6) {
        if (!instance_exists(_V.floor)) scr_vault_seal_floor();
    } else if (instance_exists(_V.floor)) {
        instance_destroy(_V.floor);
        _V.floor = noone;
    }

    _V.beat_flash = max(0, _V.beat_flash - 0.14);
    _V.seam_flash = max(0, _V.seam_flash - 0.09);
    _V.breach     = max(0, _V.breach - 0.06);
    _V.wall_hot   = max(0, _V.wall_hot - 0.05);

    for (var _e = 0; _e < 6; _e++) {
        _V.edge_hit[_e] = max(0, _V.edge_hit[_e] - 0.10);
    }

    var _charge = scr_vault_charge();
    var _burst  = scr_vault_burst();

    _V.rot = _k_vault_hex_rot + power(_burst, 0.7) * 30;

    // -- heartbeat ----------------------------------------------------------
    if (_V.stage == 5) {
        _V.heartbeat_phase += lerp(0.22, 0.58, _charge);
        _V.heartbeat = power(max(0, sin(_V.heartbeat_phase)), 5) * (0.45 + _charge * 0.55);
    } else {
        _V.heartbeat = max(0, _V.heartbeat - 0.10);
    }

    // -- survey inflow ------------------------------------------------------
    if (_V.stage == 0) {
        var _sv = scr_vault_survey();
        if ((_V.age mod 4) == 0 && array_length(converge_motes) < 90) {
            var _sa = random(360);
            array_push(converge_motes, {
                cx : _cx, cy : _cy,
                ang : _sa,
                dist : random_range(360, 620),
                dest : _k_vault_wall_out + random_range(0, 26),
                speed : random_range(5, 11) * (0.6 + _sv),
                size : random_range(0.05, 0.16),
                spin : random_range(-2.5, 2.5),
                hot : 0.15 + _sv * 0.45,
                feed : ""
            });
        }
    }

    // -- inbound beams ------------------------------------------------------
    if (_V.stage >= 4 && _V.stage <= 5 && t < _k_vault_t_discharge) {
        _V.beam_timer--;
        if (_V.beam_timer <= 0) {
            _V.beam_timer = (_V.stage == 5) ? 3 : 5;

            var _reps = (_V.stage == 5) ? 2 : 1;
            for (var _r = 0; _r < _reps; _r++) {
                if (array_length(_V.beams) >= _k_vault_beam_max) break;

                _V.beam_next = (_V.beam_next + irandom_range(1, 5)) mod 6;
                array_push(_V.beams, {
                    e   : _V.beam_next,
                    r   : 900 + random(220),
                    spd : random_range(62, 96) * (1 + _charge * 0.7),
                    w   : random_range(13, 26),
                    off : scr_bolt_offsets(5, 22)
                });
            }
        }
    }

    var _wall_r = _k_vault_wall_out;
    for (var _b = array_length(_V.beams) - 1; _b >= 0; _b--) {
        var _bm = _V.beams[_b];
        _bm.r -= _bm.spd;

        if (_bm.r <= _wall_r) {
            var _ba = _V.rot + 30 + _bm.e * 60;
            var _hx = _cx + lengthdir_x(_wall_r, _ba);
            var _hy = _cy + lengthdir_y(_wall_r, _ba);

            _V.edge_hit[_bm.e] = 1;
            _V.wall_hot = max(_V.wall_hot, 0.55);

            for (var _s = 0; _s < 3; _s++) {
                scr_vault_spawn_vent(_V, _hx, _hy, _ba + choose(-80, 80) + random_range(-20, 20), 0.9);
            }
            scr_vault_push_arc(_V, _ba + random_range(-26, 26), _wall_r, random_range(160, 300), 0.75);

            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 4.5);
            }
            aberration_pulse = max(aberration_pulse, 0.45);

            array_delete(_V.beams, _b, 1);
        }
    }

    // -- decoration pools ---------------------------------------------------
    for (var _a = array_length(_V.arcs) - 1; _a >= 0; _a--) {
        _V.arcs[_a].life--;
        if (_V.arcs[_a].life <= 0) array_delete(_V.arcs, _a, 1);
    }

    for (var _i = array_length(_V.rings) - 1; _i >= 0; _i--) {
        var _rg = _V.rings[_i];
        _rg.r   += _rg.vel;
        _rg.vel *= 0.94;
        _rg.life--;
        if (_rg.life <= 0) array_delete(_V.rings, _i, 1);
    }

    scr_update_vent_streams(_V.vents);

    if (_V.stage >= 2 && t < _k_vault_t_discharge && (_V.age mod 3) == 0) {
        var _ve   = irandom(5);
        var _va2  = _V.rot + 30 + _ve * 60;
        var _vtan = _va2 + 90;
        var _vu   = random_range(-0.62, 0.62) * _k_vault_wall_out * 0.5774;
        var _vx   = _cx + lengthdir_x(_k_vault_wall_out, _va2);
        var _vy   = _cy + lengthdir_y(_k_vault_wall_out, _va2);
        _vx += lengthdir_x(_vu, _vtan);
        _vy += lengthdir_y(_vu, _vtan);
        scr_vault_spawn_vent(_V, _vx, _vy, _va2 + choose(-72, 72), 0.35 + _charge * 0.5);
    }

    // -- the rule -----------------------------------------------------------
    if (_V.lethal && instance_exists(oPlayer) && !oPlayer.dead && !instance_exists(oGameover)) {
        var _reach = scr_vault_reach(_V, oPlayer.x, oPlayer.y);

        var _near = scr_vault_nearest_edge(_V, oPlayer.x, oPlayer.y);
        _V.edge_warn[_near] = max(_V.edge_warn[_near],
                                  clamp((_reach - (_k_vault_kill_r - _k_vault_warn_band)) / _k_vault_warn_band, 0, 1));

        if (_reach > _k_vault_kill_r) {
            if (player_register_hazard_hit()) {
                _V.breach = 1;
                _V.edge_hit[_near] = 1;

                var _bax = _V.rot + 30 + _near * 60;
                for (var _s3 = 0; _s3 < 6; _s3++) {
                    scr_vault_spawn_vent(_V, oPlayer.x, oPlayer.y, _bax + random_range(-60, 60), 1);
                }
                scr_impact_pulse(0.35, 1.0, 0.20, oPlayer.x, oPlayer.y);
                if (instance_exists(oCameraController)) {
                    oCameraController.shake              = max(oCameraController.shake, 12);
                    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.30);
                }
            }
        }
    }

    for (var _w = 0; _w < 6; _w++) {
        _V.edge_warn[_w] = max(0, _V.edge_warn[_w] - 0.12);
    }

    // -- post FX ------------------------------------------------------------
    var _hold = scr_vault_void();

    dna_veil = 1 - _hold * 0.94;

    if (_V.stage >= 1 && t < _k_vault_t_discharge) {
        vignette_pulse = max(vignette_pulse, 0.16 + _hold * 0.26 + _V.heartbeat * 0.16);
        bloom_pulse    = max(bloom_pulse, 0.06 + _V.beat_flash * 0.12 + _V.heartbeat * 0.14);
        aberration_pulse = max(aberration_pulse, _V.beat_flash * _V.beat_flash * 0.75 + _V.heartbeat * 0.6);

        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, _charge * 3.2 + _V.heartbeat * 2.4);
        }
    }

    if (_burst > 0 && _burst < 1) {
        bloom_pulse    = max(bloom_pulse, (1 - _burst) * 0.20);
        vignette_pulse = max(vignette_pulse, (1 - _burst) * 0.18);
    }
}
