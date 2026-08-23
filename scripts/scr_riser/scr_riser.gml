// ============================================================================
// THE RISER (T4961-T5192)
// AUDIO-LOCKED CLIMB INTO THE VAULT.
// NO STANDABLE FLOOR EXISTS IN THIS SECTION.
// ============================================================================



/// @func scr_riser_plug_half(_y)
function scr_riser_plug_half(_y) {
    var _dy = abs(_y - _k_vault_cy);
    if (_dy > _k_riser_shell_out) return 0;
    return _k_riser_plug_circum * (1 - _dy / (2 * _k_riser_shell_out));
}


/// @func scr_riser_half(_y)
function scr_riser_half(_y) {
    var _lo = _k_vault_cy - _k_riser_shell_out;
    var _hi = _k_vault_cy + _k_riser_shell_out;

    if (_y >= _hi) {
        var _p = clamp((_y - _hi) / max(1, _k_riser_deck_y - _hi), 0, 1);
        return lerp(scr_riser_plug_half(_hi) + _k_riser_channel, _k_riser_half_deck, _p);
    }
    if (_y >= _lo) return scr_riser_plug_half(_y) + _k_riser_channel;

    var _q = clamp((_lo - _y) / max(1, _lo - _k_riser_crown_y), 0, 1);
    return lerp(scr_riser_plug_half(_lo) + _k_riser_channel, _k_riser_crown_half, _q);
}


/// @func scr_riser_nearest_edge(_px, _py)
function scr_riser_nearest_edge(_px, _py) {
    var _dx = _px - _k_vault_cx;
    var _dy = _py - _k_vault_cy;
    var _m  = -999999;
    var _e  = 0;
    for (var _i = 0; _i < 6; _i++) {
        var _a = _k_vault_hex_rot + 30 + _i * 60;
        var _p = _dx * dcos(_a) - _dy * dsin(_a);
        if (_p > _m) { _m = _p; _e = _i; }
    }
    return _e;
}


/// @func scr_riser_door()
function scr_riser_door() {
    if (t < _k_riser_t_door_open) return 0;
    if (t < _k_riser_t_purge) return 1;
    var _p = clamp((t - _k_riser_t_purge) / max(1, _k_riser_t_seal - _k_riser_t_purge), 0, 1);
    return clamp(1 - power(_p, 2.2), 0, 1);
}


/// @func scr_riser_door_mark()
function scr_riser_door_mark() {
    if (t < _k_riser_t_door_mark) return 0;
    return clamp((t - _k_riser_t_door_mark) /
                 max(1, _k_riser_t_door_open - _k_riser_t_door_mark), 0, 1);
}


/// @func scr_riser_in_doorway(_px, _py)
function scr_riser_in_doorway(_px, _py) {
    if (is_undefined(riser)) return false;

    var _open = scr_riser_door();
    if (_open <= 0.02) return false;
    if (scr_riser_nearest_edge(_px, _py) != riser.door) return false;

    var _n   = _k_vault_hex_rot + 30 + riser.door * 60;
    var _mid = (_k_riser_shell_in + _k_riser_shell_out) * 0.5;
    var _mx  = _k_vault_cx + lengthdir_x(_mid, _n);
    var _my  = _k_vault_cy + lengthdir_y(_mid, _n);
    var _u   = (_px - _mx) * lengthdir_x(1, _n + 90)
             + (_py - _my) * lengthdir_y(1, _n + 90);

    return (abs(_u) <= _k_riser_door_half * _open + _k_riser_wall_grace);
}


/// @func scr_riser_level_y(_i)
function scr_riser_level_y(_i) {
    return _k_riser_level_y0 - _i * _k_riser_level_gap;
}


/// @func scr_riser_hex_reach(_px, _py)
function scr_riser_hex_reach(_px, _py) {
    var _dx = _px - _k_vault_cx;
    var _dy = _py - _k_vault_cy;
    var _m  = -999999;
    for (var _i = 0; _i < 6; _i++) {
        var _a = _k_vault_hex_rot + 30 + _i * 60;
        var _p = _dx * dcos(_a) - _dy * dsin(_a);
        if (_p > _m) _m = _p;
    }
    return _m;
}


/// @func scr_riser_inside(_px, _py)
function scr_riser_inside(_px, _py) {
    if (_py > _k_riser_deck_y - _k_riser_deck_grace) return false;
    if (_py < _k_riser_crown_y + _k_riser_deck_grace) return false;

    var _line = scr_riser_half(_py) - _k_riser_rail_w * 0.5 + _k_riser_wall_grace;
    if (abs(_px - _k_riser_cx) > _line) return false;

    // -- THE PLUG --------------------------------------------------------
    var _reach = scr_riser_hex_reach(_px, _py);

    if (_reach >= _k_riser_shell_out) return true;
    if (_reach <= _k_riser_shell_in)  return (t >= _k_riser_t_door_open);
    return scr_riser_in_doorway(_px, _py);
}



/// @func scr_riser_beat_for_t(_time)
function scr_riser_beat_for_t(_time) {
    var _b = -1;
    for (var _i = 0; _i < array_length(_k_riser_beats); _i++) {
        if (_time >= _k_riser_beats[_i]) _b = _i;
    }
    return _b;
}


/// @func scr_riser_stamp(_times, _values, _below)
function scr_riser_stamp(_times, _values, _below) {
    var _v = _below;
    for (var _i = 0; _i < array_length(_times); _i++) {
        if (t >= _times[_i]) _v = _values[_i]; else break;
    }
    return _v;
}


/// @func scr_riser_flood_y()
function scr_riser_flood_y() {
    if (t < _k_riser_flood_t[0]) return _k_riser_flood_rest;

    var _last = array_length(_k_riser_flood_t) - 1;
    if (t >= _k_riser_flood_t[_last]) {
        return lerp(_k_riser_flood_h[_last], _k_riser_flood_settle,
                    clamp((t - _k_riser_flood_t[_last]) / 11, 0, 1));
    }
    return scr_riser_stamp(_k_riser_flood_t, _k_riser_flood_h, _k_riser_flood_rest);
}


/// @func scr_riser_erect()
function scr_riser_erect() {
    if (t < _k_riser_erect_t[0]) return 0;
    return scr_riser_stamp(_k_riser_erect_t, _k_riser_erect_h, 0);
}


/// @func scr_riser_casing()
function scr_riser_casing() {
    if (t < _k_riser_casing_t[0]) return 0;

    if (t >= _k_riser_t_handoff) {
        var _h = clamp((t - _k_riser_t_handoff) / max(1, _k_riser_t_end - _k_riser_t_handoff), 0, 1);
        return 1 - power(_h, 1.5);
    }

    return scr_riser_stamp(_k_riser_casing_t, _k_riser_casing_h, 0);
}


/// @func scr_riser_mouth()
function scr_riser_mouth() {
    if (t < _k_riser_t_survey) return 0;
    return clamp((t - _k_riser_t_survey) / max(1, _k_riser_t_handoff - _k_riser_t_survey), 0, 1);
}


/// @func scr_riser_handoff()
function scr_riser_handoff() {
    if (t < _k_riser_t_handoff) return 0;
    return clamp((t - _k_riser_t_handoff) / max(1, _k_riser_t_seal - _k_riser_t_handoff), 0, 1);
}


/// @func scr_riser_fade()
function scr_riser_fade() {
    if (t <= _k_riser_t_seal) return 1;
    return clamp(1 - (t - _k_riser_t_seal) / max(1, _k_riser_t_end - _k_riser_t_seal), 0, 1);
}


/// @func scr_riser_lethal()
function scr_riser_lethal() {
    return (t >= _k_riser_t_erect && t < _k_riser_t_seal);
}



/// @func scr_riser_begin()
function scr_riser_begin() {
    var _R = {
        age   : 0,
        beat  : -1,
        seed  : random(1000),
        swing : choose(-1, 1),
        door  : _k_riser_door_faces[irandom(array_length(_k_riser_door_faces) - 1)],

        lvl_side : array_create(_k_riser_levels, 1),
        plan     : [],

        arms    : [],
        pending : [],
        debris  : [],
        vents   : [],
        rings   : [],
        sparks  : [],

        fall_x : _k_vault_cx, fall_y : _k_vault_cy,
        fall_p : 0,
        landed : false,
        tether : 0,
        tether_x : _k_vault_cx, tether_y : _k_vault_cy,

        rail_hot   : 0,   // charge sitting in the walls between beats
        rail_live  : 0,   // the purge discharge. Lethal while it burns.
        beat_flash : 0,
        slam       : 0,   // the flood stepped this frame
        jam_flash  : 0,
        purge      : 0,
        land       : 0,   // the deck impact

        flood_prev : _k_riser_flood_rest,
        surf       : [],

        cleared : false
    };

    // ---------------------------------------------------------------- WALLS
    var _dn   = _k_vault_hex_rot + 30 + _R.door * 60;
    var _door_s = (dcos(_dn) >= 0) ? 1 : -1;
    var _far_s  = -_door_s;

    for (var _i = 0; _i < _k_riser_levels; _i++) _R.lvl_side[_i] = _far_s;

    var _flipped = 0;
    var _tries = 0;
    var _flip_max = max(0, floor(_k_riser_levels / 2) - 1);
    while (_flipped < _k_riser_door_side_levels && _tries < 40) {
        _tries++;
        var _c = irandom(_flip_max);
        if (_R.lvl_side[_c] == _door_s) continue;
        _R.lvl_side[_c] = _door_s;
        _flipped++;
    }

    // ----------------------------------------------------------------- PLAN
    var _free_at = array_create(_k_riser_levels, 0);

    for (var _b = 0; _b < array_length(_k_riser_beats); _b++) {
        var _row = [];
        var _want = _k_riser_beat_arms[_b];

        if (_want > 0) {
            var _pool = [];
            for (var _l = 0; _l < _k_riser_levels; _l++) {
                if (_free_at[_l] <= _b) array_push(_pool, _l);
            }
            for (var _k = array_length(_pool) - 1; _k > 0; _k--) {
                var _j = irandom(_k);
                var _tmp = _pool[_k]; _pool[_k] = _pool[_j]; _pool[_j] = _tmp;
            }
            var _take = min(_want, array_length(_pool));
            for (var _k2 = 0; _k2 < _take; _k2++) {
                array_push(_row, _pool[_k2]);
                _free_at[_pool[_k2]] = _b + _k_riser_arm_lock;
            }
        }

        array_push(_R.plan, _row);
    }

    riser = _R;

    var _want_beat = scr_riser_beat_for_t(t);
    while (_R.beat < _want_beat) {
        _R.beat++;
        scr_riser_enter_beat(_R, _R.beat, false);
    }
}


/// @func scr_riser_clear()
function scr_riser_clear() {
    riser = undefined;

    if (is_undefined(vault)) dna_veil = 1;
}



/// @func scr_riser_enter_beat(_R, _beat, _loud)
function scr_riser_enter_beat(_R, _beat, _loud) {
    var _cx = _k_riser_cx;

    for (var _a = array_length(_R.arms) - 1; _a >= 0; _a--) {
        if (_R.arms[_a].die <= _beat) {
            _R.arms[_a].state = 2;
            _R.arms[_a].step  = 0;
        }
    }

    switch (_beat) {

        // -- ERECT ----------------------------------------------------------
        case 0:
            if (_loud) {
                _R.beat_flash = 1;
                scr_riser_push_ring(_R, _k_riser_cx, _k_riser_deck_y, 30, 26, 34, 10, 1.0);
                scr_impact_pulse(0.20, 0.55, 0.16, _cx, _k_riser_deck_y);
                if (instance_exists(oCameraController)) {
                    oCameraController.shake = max(oCameraController.shake, 9);
                    oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.55);
                }
            }
            break;

        // -- ARM ------------------------------------------------------------
        case 1:
            _R.rail_hot = max(_R.rail_hot, 0.45);
            if (_loud) {
                _R.beat_flash = 0.8;
                for (var _v = 0; _v < 8; _v++) {
                    var _vy = lerp(_k_riser_crown_y, _k_riser_deck_y, _v / 7);
                    var _vs = (_v mod 2 == 0) ? -1 : 1;
                    scr_riser_push_vent(_R, _cx + _vs * scr_riser_half(_vy), _vy,
                                        (_vs < 0) ? random_range(-40, 40) : random_range(140, 220), 0.55);
                }
                scr_impact_pulse(0.18, 0.5, 0.14, _cx, _k_riser_top_y + 120);
                if (instance_exists(oCameraController)) {
                    oCameraController.shake = max(oCameraController.shake, 7);
                }
            }
            break;

        // -- PURGE ----------------------------------------------------------
        case 7:
            _R.purge     = 1;
            _R.rail_live = 1;
            _R.rail_hot  = 1;
            _R.beat_flash = 1;

            for (var _a2 = array_length(_R.arms) - 1; _a2 >= 0; _a2--) {
                scr_riser_eject_arm(_R, _R.arms[_a2]);
            }
            _R.arms = [];
            _R.pending = [];

            if (_loud) {
                scr_riser_push_ring(_R, _cx, (_k_vault_cy + _k_riser_deck_y) * 0.5,
                                    40, 34, 40, 16, 1.3);
                for (var _s2 = -1; _s2 <= 1; _s2 += 2) {
                    for (var _v2 = 0; _v2 < 9; _v2++) {
                        var _vy2 = lerp(_k_riser_crown_y, _k_riser_deck_y, _v2 / 8);
                        scr_riser_push_vent(_R, _cx + _s2 * scr_riser_half(_vy2), _vy2,
                                            (_s2 < 0) ? random_range(-52, 52) : random_range(128, 232), 1);
                    }
                }

                hitstop_frames = max(hitstop_frames, 2);
                tear_amount = max(tear_amount, 0.55);
                global_ripple_pulse = max(global_ripple_pulse, 0.42);
                scr_impact_pulse(0.40, 1.35, 0.34, _cx, _k_riser_flood_h[5]);
                scr_bg_bass_hit();

                if (instance_exists(oCameraController)) {
                    oCameraController.shake              = max(oCameraController.shake, 16);
                    oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.10);
                    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.42);
                    oCameraController.angle_kick         = 2.4 * _R.swing;
                    oCameraController.letterbox_target   = max(oCameraController.letterbox_target, 0.8);
                }
            }
            break;

        // -- BREAKS ---------------------------------------------------------
        default:
            if (_loud && array_length(_R.plan[_beat]) > 0) {
                _R.beat_flash = max(_R.beat_flash, 0.85);
                _R.rail_hot   = max(_R.rail_hot, 0.7);
                scr_impact_pulse(0.16, 0.55, 0.14, _cx, scr_riser_level_y(_R.plan[_beat][0]));
                if (instance_exists(oCameraController)) {
                    oCameraController.shake = max(oCameraController.shake, 6.5);
                }
            }
            break;
    }

    scr_riser_fire_beat(_R, _beat, _loud);
    scr_riser_charge_beat(_R, _beat + _k_riser_arm_lead_beats);
}


/// @func scr_riser_charge_beat(_R, _beat)
function scr_riser_charge_beat(_R, _beat) {
    if (_beat < _k_riser_arm_lead_beats || _beat >= array_length(_k_riser_beats)) exit;

    var _row = _R.plan[_beat];
    if (array_length(_row) == 0) exit;

    var _t0  = _k_riser_beats[_beat - _k_riser_arm_lead_beats];
    var _len = _k_riser_beats[_beat] - _t0;

    var _px = 100000, _pl = 100000, _pr = -100000, _pt = 0, _pb = 0;
    var _have_player = (instance_exists(oPlayer) && !oPlayer.dead);
    if (_have_player) {
        _px = oPlayer.x;
        _pl = oPlayer.bbox_left;
        _pr = oPlayer.bbox_right;
        _pt = oPlayer.bbox_top;
        _pb = oPlayer.bbox_bottom;
    }

    for (var _i = 0; _i < array_length(_row); _i++) {
        var _lvl  = _row[_i];
        var _y    = scr_riser_level_y(_lvl);
        var _side = _R.lvl_side[_lvl];
        var _half = scr_riser_half(_y);
        var _w    = _half * 2;
        var _rx   = _k_riser_cx + _side * _half;

        var _cover = random_range(_k_riser_cover_min, _k_riser_cover_max);
        var _tip   = _rx - _side * _cover * _w;

        var _jam = false;
        if (_have_player &&
            _pb > _y - _k_riser_arm_reach_band && _pt < _y + _k_riser_arm_reach_band) {

            var _stop = (_side < 0) ? (_pl - _k_riser_arm_clear)
                                    : (_pr + _k_riser_arm_clear);

            if ((_side < 0 && _tip > _stop) || (_side > 0 && _tip < _stop)) {
                _tip   = _stop;
                _cover = (_rx - _tip) * _side / _w;
            }
            if (_cover < _k_riser_cover_jam) _jam = true;
        }

        _cover = clamp(_cover, 0, 0.95);
        _tip   = _rx - _side * _cover * _w;

        array_push(_R.pending, {
            lvl   : _lvl,
            side  : _side,
            cover : _cover,
            y     : _y,
            rx    : _rx,
            tip   : _tip,
            beat  : _beat,
            t0    : _t0,
            len   : max(1, _len),
            coil  : 0,
            jam   : _jam,
            seed  : random(1000),
            off   : scr_bolt_offsets(4, _k_riser_arm_jitter)
        });
    }
}


/// @func scr_riser_fire_beat(_R, _beat, _loud)
function scr_riser_fire_beat(_R, _beat, _loud) {
    for (var _i = array_length(_R.pending) - 1; _i >= 0; _i--) {
        var _p = _R.pending[_i];
        if (_p.beat != _beat) continue;

        if (_p.jam) {
            _R.jam_flash = 1;
            for (var _v = 0; _v < 5; _v++) {
                scr_riser_push_vent(_R, _p.rx, _p.y,
                                    (_p.side < 0 ? 0 : 180) + random_range(-58, 58), 0.7);
            }
            if (_loud) {
                scr_riser_push_ring(_R, _p.rx, _p.y, 8, 15, 18, 5, 0.5);
                aberration_pulse = max(aberration_pulse, 0.3);
            }
        }
        else {
            array_push(_R.arms, {
                lvl   : _p.lvl,
                side  : _p.side,
                cover : _p.cover,
                y     : _p.y,
                state : 0,
                step  : 0,
                ext   : 0,
                die   : _beat + _k_riser_arm_life,
                hot   : 1,
                seed  : _p.seed,
                off   : _p.off,
                shock : 0
            });

            if (_loud) {
                var _tipx = _p.rx - _p.side * _p.cover * scr_riser_half(_p.y) * 2;
                scr_riser_push_ring(_R, _tipx, _p.y, 6, 20, 22, 7, 0.85);
                for (var _v2 = 0; _v2 < 4; _v2++) {
                    scr_riser_push_vent(_R, _tipx, _p.y,
                                        (_p.side < 0 ? 0 : 180) + choose(-74, 74) + random_range(-18, 18), 0.85);
                }
            }
        }

        array_delete(_R.pending, _i, 1);
    }
}


/// @func scr_riser_eject_arm(_R, _arm)
function scr_riser_eject_arm(_R, _arm) {
    if (array_length(_R.debris) >= _k_riser_debris_max) array_delete(_R.debris, 0, 1);

    var _half = scr_riser_half(_arm.y);
    var _rx   = _k_riser_cx + _arm.side * _half;
    var _len  = _arm.cover * _half * 2 * _arm.ext;

    array_push(_R.debris, {
        x   : _rx - _arm.side * _len * 0.5,
        y   : _arm.y,
        vx  : -_arm.side * random_range(3.5, 9) + random_range(-2, 2),
        vy  : random_range(-11, -4),
        len : _len,
        ang : 0,
        spin: random_range(-13, 13) * _arm.side,
        life : irandom_range(26, 44), life_max : 44,
        hot  : 1
    });

    for (var _v = 0; _v < 3; _v++) {
        scr_riser_push_vent(_R, _rx - _arm.side * _len * 0.5, _arm.y, random(360), 1);
    }
}



function scr_riser_push_ring(_R, _x, _y, _r, _vel, _life, _w, _power) {
    if (array_length(_R.rings) >= _k_riser_ring_max) array_delete(_R.rings, 0, 1);
    array_push(_R.rings, {
        x : _x, y : _y, r : _r, vel : _vel,
        life : _life, life_max : _life, width : _w, power : _power
    });
}


/// @func scr_riser_push_vent(_R, _x, _y, _dir, _hot)
function scr_riser_push_vent(_R, _x, _y, _dir, _hot) {
    scr_spawn_vent_stream(_R.vents, _x, _y, _dir, _hot,
                          _k_riser_vent_cols, _k_riser_vent_max);
}


/// @func scr_riser_push_spark(_R, _x, _y, _dir, _spd, _hot)
function scr_riser_push_spark(_R, _x, _y, _dir, _spd, _hot) {
    if (array_length(_R.sparks) >= _k_riser_spark_max) array_delete(_R.sparks, 0, 1);
    array_push(_R.sparks, {
        x : _x,
        y : _y,
        vx : lengthdir_x(_spd, _dir),
        vy : lengthdir_y(_spd, _dir),
        life : irandom_range(12, 26), life_max : 26,
        hot : _hot,
        col : choose(global.avoid_col_warning, global.avoid_col_ember,
                     global.avoid_col_hot, global.avoid_col_cyan)
    });
}


/// @func scr_riser_resample_surface(_R)
function scr_riser_resample_surface(_R) {
    _R.surf = [];
    for (var _i = 0; _i <= _k_riser_surf_n; _i++) {
        array_push(_R.surf, random_range(-1, 1));
    }
}


// ---------------------------------------------------------------------------
// Per-frame
// ---------------------------------------------------------------------------

/// @func scr_riser_update()
function scr_riser_update() {
    if (is_undefined(riser)) exit;

    var _R = riser;
    _R.age++;

    var _cx = _k_riser_cx;

    if (t < _k_riser_t_deck) {
        scr_riser_fall_update();

        cube_despawn_active = true;
        cube_shoot_phase_active = false;
        cube_despawn_timer = clamp(t - _k_riser_t_fall, 0, cube_despawn_duration - 2);
    }
    else if (!_R.landed) {
        cube_despawn_timer = cube_despawn_duration - 1;
        scr_riser_land();
    }

    if (t <= _k_riser_t_deck + 8 && instance_exists(oCameraController)) {
        oCameraController.letterbox_target = min(oCameraController.letterbox_target,
                                                 _k_riser_fall_letterbox);
    }

    var _want = scr_riser_beat_for_t(t);
    while (_R.beat < _want) {
        _R.beat++;
        scr_riser_enter_beat(_R, _R.beat, true);
    }

    var _flood = scr_riser_flood_y();

    _R.beat_flash = max(0, _R.beat_flash - 0.13);
    _R.jam_flash  = max(0, _R.jam_flash  - 0.10);
    _R.slam       = max(0, _R.slam       - 0.16);
    _R.land       = max(0, _R.land       - 0.06);
    _R.purge      = max(0, _R.purge      - 0.045);
    _R.rail_live  = max(0, _R.rail_live  - 1 / _k_riser_purge_frames);
    _R.rail_hot   = max(0, _R.rail_hot   - 0.028);

    if (abs(_flood - _R.flood_prev) > 0.5) {
        var _stepped = (abs(_flood - _R.flood_prev) > 3);
        _R.flood_prev = _flood;

        if (_stepped) {
            _R.slam = 1;
            scr_riser_resample_surface(_R);

            var _fh = scr_riser_half(_flood);
            scr_riser_push_ring(_R, _cx, _flood, _fh * 0.4, 22, 22, 8, 0.8);

            for (var _s = -1; _s <= 1; _s += 2) {
                for (var _v = 0; _v < 3; _v++) {
                    scr_riser_push_vent(_R, _cx + _s * _fh * random_range(0.55, 0.98), _flood,
                                        (_s < 0 ? 250 : 290) + random_range(-34, 34), 0.9);
                }
            }
            for (var _k = 0; _k < 9; _k++) {
                scr_riser_push_spark(_R, _cx + random_range(-_fh, _fh) * 0.92, _flood,
                                     random_range(240, 300), random_range(4, 12), 1);
            }

            scr_impact_pulse(0.14, 0.45, 0.12, _cx, _flood);
            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 5.5);
            }
        }
    }

    if (array_length(_R.surf) == 0) scr_riser_resample_surface(_R);

    if (t >= _k_riser_t_deck && (_R.age mod 2) == 0) {
        var _fh2 = scr_riser_half(_flood);
        scr_riser_push_vent(_R, _cx + random_range(-_fh2, _fh2) * 0.94, _flood,
                            270 + random_range(-40, 40), 0.35 + _R.slam * 0.5);
        if ((_R.age mod 6) == 0) {
            scr_riser_push_spark(_R, _cx + random_range(-_fh2, _fh2) * 0.9, _flood,
                                 random_range(238, 302), random_range(2.5, 7), 0.8);
        }
    }

    for (var _p = 0; _p < array_length(_R.pending); _p++) {
        var _pd = _R.pending[_p];
        var _raw = clamp((t - _pd.t0) / _pd.len, 0, 1);

        _pd.coil = max(power(_raw, 1.45),
                       lerp(_k_riser_coil_floor, 1, power(_raw, 1.2)));

        if ((_R.age mod 3) == 0) {
            scr_riser_push_vent(_R, _pd.rx, _pd.y,
                                (_pd.side < 0 ? 0 : 180) + random_range(-40, 40),
                                _pd.coil * 0.85);
        }
        if (_pd.coil > 0.5 && (_R.age mod 4) == 0) {
            scr_riser_push_spark(_R, _pd.rx, _pd.y,
                                 (_pd.side < 0 ? 0 : 180) + random_range(-70, 70),
                                 random_range(2, 6), _pd.coil);
        }
    }

    for (var _a = array_length(_R.arms) - 1; _a >= 0; _a--) {
        var _ar = _R.arms[_a];
        _ar.hot   = max(0, _ar.hot - 0.045);
        _ar.shock = max(0, _ar.shock - 0.12);

        if (_ar.state == 0) {
            _ar.ext = _k_riser_out_steps[min(_ar.step, array_length(_k_riser_out_steps) - 1)];
            _ar.step++;
            if (_ar.step >= array_length(_k_riser_out_steps)) {
                _ar.state = 1;
                _ar.ext   = 1;
                _ar.shock = 1;
            }
        }
        else if (_ar.state == 2) {
            _ar.ext = _k_riser_in_steps[min(_ar.step, array_length(_k_riser_in_steps) - 1)];
            _ar.step++;
            if (_ar.step >= array_length(_k_riser_in_steps)) {
                array_delete(_R.arms, _a, 1);
                continue;
            }
        }

        if (_ar.state == 1 && (_R.age + _ar.lvl * 3) mod 7 == 0) {
            var _half3 = scr_riser_half(_ar.y);
            var _tipx3 = _cx + _ar.side * _half3 - _ar.side * _ar.cover * _half3 * 2;
            scr_riser_push_vent(_R, _tipx3, _ar.y,
                                (_ar.side < 0 ? 0 : 180) + choose(-84, 84), 0.4);
        }
    }

    for (var _d = array_length(_R.debris) - 1; _d >= 0; _d--) {
        var _db = _R.debris[_d];
        _db.x += _db.vx;
        _db.y += _db.vy;
        _db.vy += 0.42;
        _db.vx *= 0.985;
        _db.ang += _db.spin;
        _db.spin *= 0.98;
        _db.hot = max(0, _db.hot - 0.024);
        _db.life--;
        if (_db.life <= 0) array_delete(_R.debris, _d, 1);
    }

    for (var _sp = array_length(_R.sparks) - 1; _sp >= 0; _sp--) {
        var _s3 = _R.sparks[_sp];
        _s3.x += _s3.vx;
        _s3.y += _s3.vy;
        _s3.vy += 0.30;
        _s3.vx *= 0.97;
        _s3.life--;
        if (_s3.life <= 0) array_delete(_R.sparks, _sp, 1);
    }

    for (var _rg = array_length(_R.rings) - 1; _rg >= 0; _rg--) {
        var _rr = _R.rings[_rg];
        _rr.r   += _rr.vel;
        _rr.vel *= 0.93;
        _rr.life--;
        if (_rr.life <= 0) array_delete(_R.rings, _rg, 1);
    }

    scr_update_vent_streams(_R.vents);

    if (t >= _k_riser_t_arm && (_R.age mod 3) == 0 && scr_riser_erect() > 0.9) {
        var _wy = random_range(_k_riser_crown_y, _k_riser_deck_y);
        var _ws = choose(-1, 1);
        scr_riser_push_spark(_R, _cx + _ws * scr_riser_half(_wy), _wy,
                             (_ws < 0 ? 0 : 180) + random_range(-30, 30),
                             random_range(1.5, 4), 0.4 + _R.rail_hot * 0.5);
    }

    scr_riser_kill_check(_R, _flood);

    // for. See [never touch instance activation] - this is the cheap way.
    var _cas = scr_riser_casing();
    dna_veil = min(dna_veil, 1 - _cas * 0.995);

    if (t >= _k_riser_t_erect && t < _k_riser_t_seal) {
        var _rise = clamp((t - _k_riser_t_erect) / (_k_riser_t_purge - _k_riser_t_erect), 0, 1);

        vignette_pulse   = max(vignette_pulse, 0.14 + _rise * 0.18 + _R.slam * 0.12);
        bloom_pulse      = max(bloom_pulse, 0.05 + _R.beat_flash * 0.12 + _R.rail_live * 0.18);
        aberration_pulse = max(aberration_pulse,
                               _R.beat_flash * _R.beat_flash * 0.34 + _R.rail_live * 0.45);

        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake,
                                          _R.rail_live * 4 + _R.slam * 2.2);
        }
    }
}


/// @func scr_riser_kill_check(_R, _flood)
function scr_riser_kill_check(_R, _flood) {
    if (!scr_riser_lethal()) exit;
    if (!instance_exists(oPlayer) || oPlayer.dead || instance_exists(oGameover)) exit;
    if (_R.tether > 0) exit;

    var _px = oPlayer.x;
    var _py = oPlayer.y;
    var _cx = _k_riser_cx;

    if (!scr_riser_inside(_px, _py)) {
        if (player_register_hazard_hit()) {
            scr_riser_breach(_R, _px, _py, (_px < _cx) ? 0 : 180);
        }
        exit;
    }

    if (oPlayer.bbox_bottom >= _flood + _k_riser_flood_grace) {
        if (player_register_hazard_hit()) {
            scr_riser_breach(_R, _px, _flood, 270);
        }
        exit;
    }

    if (_R.rail_live > 0.02) {
        var _band = _k_riser_rail_kill * _R.rail_live;
        if (abs(_px - _cx) > scr_riser_half(_py) - _band) {
            if (player_register_hazard_hit()) {
                scr_riser_breach(_R, _px, _py, (_px < _cx) ? 0 : 180);
            }
            exit;
        }
    }

    for (var _a = 0; _a < array_length(_R.arms); _a++) {
        var _ar = _R.arms[_a];
        if (_ar.ext <= 0.04) continue;

        var _half = scr_riser_half(_ar.y);
        var _rx   = _cx + _ar.side * _half;
        var _tip  = _rx - _ar.side * _ar.cover * _half * 2 * _ar.ext;

        if (_py < _ar.y - _k_riser_arm_reach_band) continue;
        if (_py > _ar.y + _k_riser_arm_reach_band + 24) continue;

        if (player_meeting_line_width(_rx, _ar.y, _tip, _ar.y, _k_riser_arm_kill)) {
            if (player_register_hazard_hit()) {
                _ar.hot = 1;
                scr_riser_breach(_R, _px, _ar.y, (_ar.side < 0) ? 0 : 180);
            }
            exit;
        }
    }
}


/// @func scr_riser_breach(_R, _x, _y, _dir)
function scr_riser_breach(_R, _x, _y, _dir) {
    for (var _v = 0; _v < 7; _v++) {
        scr_riser_push_vent(_R, _x, _y, _dir + random_range(-64, 64), 1);
    }
    for (var _s = 0; _s < 10; _s++) {
        scr_riser_push_spark(_R, _x, _y, random(360), random_range(3, 11), 1);
    }
    scr_riser_push_ring(_R, _x, _y, 6, 22, 20, 7, 1);
    scr_impact_pulse(0.35, 1.0, 0.20, _x, _y);
    if (instance_exists(oCameraController)) {
        oCameraController.shake              = max(oCameraController.shake, 12);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.30);
    }
}



/// @func scr_riser_fall_point(_R, _u)
function scr_riser_fall_point(_R, _u) {
    var _u2 = clamp(_u, 0, 1);
    var _iv = 1 - _u2;

    var _c1x = _k_vault_cx + _R.swing * _k_riser_fall_swing;
    var _c1y = lerp(_k_vault_cy, _k_riser_deck_y, 0.55);

    return {
        x : _iv * _iv * _k_vault_cx + 2 * _iv * _u2 * _c1x + _u2 * _u2 * _k_riser_cx,
        y : _iv * _iv * _k_vault_cy + 2 * _iv * _u2 * _c1y + _u2 * _u2 * _k_riser_deck_y
    };
}


/// @func scr_riser_fall_progress()
function scr_riser_fall_progress() {
    return clamp((t - _k_riser_t_fall) / max(1, _k_riser_t_deck - _k_riser_t_fall), 0, 1);
}


/// @func scr_riser_fall_update()
function scr_riser_fall_update() {
    if (is_undefined(riser)) exit;

    var _R = riser;
    var _p = scr_riser_fall_progress();
    var _u = power(_p, _k_riser_fall_ease);

    var _c = scr_riser_fall_point(_R, _u);
    _R.fall_x = _c.x;
    _R.fall_y = _c.y;
    _R.fall_p = _p;

    if (_R.landed) { _R.tether = 0; exit; }

    var _lag = _k_riser_tether_lag * (1 - _u);
    var _pp  = scr_riser_fall_point(_R, _u - _lag);

    _R.tether_x = _pp.x;
    _R.tether_y = _pp.y - _k_riser_tether_rise * (1 - _u);
    _R.tether   = clamp(_p * _k_riser_tether_grab, 0, 1) * _k_riser_tether_auth;

    if ((_R.age mod 2) == 0) {
        scr_riser_push_spark(_R, _c.x, _c.y, random(360), random_range(2, 8), 1);
    }
}


/// @func scr_riser_land()
function scr_riser_land() {
    if (is_undefined(riser)) exit;
    if (riser.landed) exit;

    var _R = riser;
    _R.landed = true;
    _R.tether = 0;
    _R.land   = 1;

    var _lx = _k_riser_cx;
    var _ly = _k_riser_deck_y - _k_riser_release_y;
    var _pop = _k_riser_release_pop;

    if (instance_exists(oPlayer)) {
        with (oPlayer) {
            x = _lx;
            y = _ly;
            velocity.x = 0;
            velocity.y = -_pop;
            airjump_index = 0;
        }
    }

    for (var _v = 0; _v < 16; _v++) {
        scr_riser_push_vent(_R, _k_riser_cx + random_range(-_k_riser_half_deck, _k_riser_half_deck),
                            _k_riser_deck_y, 270 + random_range(-62, 62), 1);
    }
    for (var _s = 0; _s < 26; _s++) {
        scr_riser_push_spark(_R, _k_riser_cx + random_range(-60, 60), _k_riser_deck_y,
                             random_range(200, 340), random_range(6, 17), 1);
    }
    scr_riser_push_ring(_R, _k_riser_cx, _k_riser_deck_y, 14, 40, 30, 16, 1.3);
    scr_riser_push_ring(_R, _k_riser_cx, _k_riser_deck_y, 26, 22, 46, 26, 0.7);
}


// ---------------------------------------------------------------------------
// Seek
// ---------------------------------------------------------------------------

/// @func scr_riser_seat_player(_time)
function scr_riser_seat_player(_time) {
    if (is_undefined(riser)) exit;
    if (!instance_exists(oPlayer)) exit;

    var _R = riser;
    var _flood = scr_riser_flood_y();

    var _y = clamp(_flood - 54,
                   _k_vault_cy + _k_riser_shell_out + 30,
                   _k_riser_deck_y - 40);
    var _dn = _k_vault_hex_rot + 30 + _R.door * 60;
    var _x = _k_riser_cx + sign(dcos(_dn)) * scr_riser_half(_y) * 0.5;

    var _best = 0;
    for (var _s = -1; _s <= 1; _s += 2) {
        var _half = scr_riser_half(_y);
        var _cand = _k_riser_cx + _s * _half * 0.55;
        var _clear = _half;
        for (var _a = 0; _a < array_length(_R.arms); _a++) {
            var _ar = _R.arms[_a];
            if (abs(_ar.y - _y) > _k_riser_level_gap * 0.75) continue;
            var _h2 = scr_riser_half(_ar.y);
            var _tip = _k_riser_cx + _ar.side * _h2 - _ar.side * _ar.cover * _h2 * 2;
            var _d = (_cand - _tip) * -_ar.side;
            _clear = min(_clear, _d);
        }
        if (_clear > _best) { _best = _clear; _x = _cand; }
    }

    with (oPlayer) {
        x = _x;
        y = _y;
        velocity.x = 0;
        velocity.y = 0;
    }
}


/// @func scr_riser_seek(_time)
function scr_riser_seek(_time) {
    if (!is_undefined(riser)) scr_riser_clear();

    scr_riser_begin();

    var _R = riser;

    for (var _a = array_length(_R.arms) - 1; _a >= 0; _a--) {
        if (_R.arms[_a].state == 2) {
            array_delete(_R.arms, _a, 1);
            continue;
        }
        _R.arms[_a].state = 1;
        _R.arms[_a].ext   = 1;
        _R.arms[_a].hot   = 0;
        _R.arms[_a].shock = 0;
    }
    for (var _p = 0; _p < array_length(_R.pending); _p++) {
        var _pd = _R.pending[_p];
        var _raw = clamp((_time - _pd.t0) / _pd.len, 0, 1);
        _pd.coil = max(power(_raw, 1.45), lerp(_k_riser_coil_floor, 1, power(_raw, 1.2)));
    }

    _R.landed     = (_time >= _k_riser_t_deck);
    _R.tether     = 0;
    _R.beat_flash = 0;
    _R.rail_live  = (_time < _k_riser_t_purge + _k_riser_purge_frames && _time >= _k_riser_t_purge)
                    ? clamp(1 - (_time - _k_riser_t_purge) / _k_riser_purge_frames, 0, 1) : 0;
    _R.purge      = _R.rail_live;
    _R.flood_prev = scr_riser_flood_y();
    scr_riser_resample_surface(_R);

    if (_time < _k_riser_t_seal) scr_riser_seat_player(_time);
}
