var _fa = global.fps_adjust;
t += 1 / _fa;

var _p0 = _k_p0_contact;
var _p1 = _k_p1_overload;
var _p2 = _k_p2_cut;
var _p3 = _k_p3_bleed;
var _p4 = _k_p4_scar;

if (t >= _k_blade_launch) {
    var _was_flying = (blade_t < 1);
    blade_t = clamp((t - _k_blade_launch) / _k_blade_travel, 0, 1);
    blade_glow = (blade_t < 1) ? 1 : max(0, blade_glow - 0.04 / _fa);

    if (blade_t < 1 && has_camera) {
        oCameraController.screen_flash_alpha =
            min(oCameraController.screen_flash_alpha, 0.10);
    }

    if (_was_flying && blade_t >= 1) {
        whiteout   = 1;
        whiteout_t = 0;
        redout     = 1;
        death_aftershock = max(death_aftershock, _k_aftershock_len);

        if (has_camera) {
            oCameraController.shake              = max(oCameraController.shake, 76);
            oCameraController.zoom_punch         = max(oCameraController.zoom_punch, 0.58);
            oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 1.0);
        }
        if (has_controller) {
            with (oAvoidanceController) {
                hitstop_frames      = max(hitstop_frames, 28);
                vignette_pulse      = max(vignette_pulse, 2.4);
                bloom_pulse         = max(bloom_pulse, 2.7);
                aberration_pulse    = max(aberration_pulse, 1.45);
                tear_amount         = max(tear_amount, 0.95);
                global_ripple_pulse = max(global_ripple_pulse, 0.95);
            }
        }

        repeat (8) {
            array_push(shock_rings, {
                r : 0,
                life : 38, life_max : 38,
                w : random_range(7, 24),
                speed : random_range(34, 78)
            });
        }

        repeat (120) {
            array_push(seam_embers, {
                u  : random_range(-0.95, 0.95),
                vx : random_range(-4.0, 4.0),
                vy : random_range(-2.8, 5.2),
                drop : 0,
                alpha : 1
            });
        }

        var _gc = scr_death_room_to_gui(death_x, death_y);
        var _gw = display_get_gui_width();
        var _gh = display_get_gui_height();
        repeat (_k_screen_splats) {
            var _sa = random(360);
            var _sd = random_range(12, max(_gw, _gh) * 0.52);
            array_push(screen_splats, {
                x : clamp(_gc.x + lengthdir_x(_sd, _sa), -60, _gw + 60),
                y : clamp(_gc.y + lengthdir_y(_sd, _sa), -60, _gh + 60),
                rx : random_range(9, 46),
                ry : random_range(4, 22),
                run : 0,
                target : random_range(28, 220),
                speed : random_range(1.8, 7.0),
                w : random_range(1.2, 5.8),
                alpha : random_range(0.48, 0.95),
                heat : random_range(0.0, 0.35),
                delay : irandom_range(0, 14),
                life : irandom_range(76, 145)
            });
        }
    }
}

if (whiteout > 0) {
    whiteout_t += 1 / _fa;
    if (whiteout_t <= _k_whiteout_hold) {
        whiteout = 1;
    } else {
        whiteout = max(0, 1 - (whiteout_t - _k_whiteout_hold) / _k_whiteout_fade);
    }
}

if (redout > 0) {
    var _red_decay = (whiteout > 0.05) ? 0.012 : 0.026;
    redout = max(0, redout - _red_decay / _fa);
}

for (var i = array_length(shock_rings) - 1; i >= 0; i--) {
    var _sr = shock_rings[i];
    _sr.r += _sr.speed / _fa;
    _sr.speed *= 0.93;
    _sr.life -= 1 / _fa;
    if (_sr.life <= 0) array_delete(shock_rings, i, 1);
}

if (death_aftershock > 0) {
    var _as = clamp(death_aftershock / _k_aftershock_len, 0, 1);
    var _punch = power(_as, 2);

    if (has_camera) {
        oCameraController.shake = max(oCameraController.shake, 7 + _punch * 31);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, _punch * 0.095);
    }
    if (has_controller) {
        oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, _punch * 1.25);
        oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, _punch * 1.05);
        oAvoidanceController.tear_amount = max(oAvoidanceController.tear_amount, _punch * 0.62);
        oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, _punch * 0.55);
    }

    if (random(1) < _as * 1.4 / _fa && array_length(seam_embers) < 170) {
        array_push(seam_embers, {
            u : random_range(-0.98, 0.98),
            vx : random_range(-3.5, 3.5),
            vy : random_range(-0.5, 5.0),
            drop : 0,
            alpha : random_range(0.5, 1)
        });
    }

    death_aftershock -= 1 / _fa;
}

if (t < _p2) {
    overload = clamp((t - _p0) / (_p1 - _p0), 0, 1);

    body_white = power(overload, 1.6);
    body_shake = overload * 2.4;

    cut_preview = power(overload, 3.2) * 0.42;

    var _rate = _k_arc_rate_max * power(overload, 1.4) / _fa;
    while (_rate > 0) {
        if (_rate < 1 && random(1) > _rate) break;
        _rate -= 1;

        var _ang  = random(360);
        var _len  = random_range(28, _k_arc_reach) * (0.35 + overload * 0.65);
        var _tx   = death_x + lengthdir_x(_len, _ang);
        var _ty   = death_y + lengthdir_y(_len, _ang);
        var _life = irandom_range(3, 8);

        array_push(arcs, {
            x1 : death_x, y1 : death_y,
            x2 : _tx,     y2 : _ty,
            life : _life, life_max : _life,
            hot  : random_range(0.35, 1) * (0.4 + overload * 0.6)
        });

        if (has_controller) {
            scr_slash_bolt(death_x, death_y, _tx, _ty,
                _life, 5 + overload * 7, 0.9 + overload * 1.1, 0.35 + overload * 0.6);
        }
    }

    for (var i = array_length(motes) - 1; i >= 0; i--) {
        var _m = motes[i];
        _m.dist -= _m.speed * overload * 1.7 / _fa;
        _m.ang  += (10 + _m.speed * 7) * overload / _fa;
        if (_m.dist <= 6) {
            _m.dist = random_range(140, 250);
            _m.ang  = random(360);
            if (has_camera) oCameraController.shake = max(oCameraController.shake, 0.6 * overload);
        }
    }

    if (overload > 0.45 && random(1) < overload * 0.5 / _fa * 6) {
        var _a = cut_angle + 90 + choose(0, 180) + random_range(-30, 30);
        array_push(droplets, {
            x : death_x + random_range(-4, 4),
            y : death_y + random_range(-8, 8),
            vx : lengthdir_x(random_range(0.6, 2.1), _a),
            vy : lengthdir_y(random_range(0.6, 2.1), _a) - 0.8,
            life : 60, life_max : 60,
            size : random_range(0.7, 1.8),
            landed : false
        });
    }

    if (floor(t) == _k_prestrike_a && !prestrike_a_done) {
        prestrike_a_done = true;
        death_add_strike(cut_angle - 34, -26, 5, 3.5);
    }
    if (floor(t) == _k_prestrike_b && !prestrike_b_done) {
        prestrike_b_done = true;
        death_add_strike(cut_angle + 28, 22, 5, 4.5);
    }

    if (has_controller) {
        with (oAvoidanceController) {
            vignette_pulse     = max(vignette_pulse, other.overload * 0.95);
            bloom_pulse        = max(bloom_pulse, other.overload * 0.7);
            aberration_pulse   = max(aberration_pulse, other.overload * 1.3);
            global_ripple_pulse = max(global_ripple_pulse, other.overload * 0.3);
            tear_amount        = max(tear_amount, power(other.overload, 2) * 0.65);
        }
    }
    if (has_camera) {
        oCameraController.shake = max(oCameraController.shake, overload * 5.5);
        oCameraController.letterbox_target = 1;
    }
}

if (!body_split && t >= _p2) {
    body_split = true;
    overload = 0;
    body_white = 1;
    cut_preview = 0;
    cut_flash = 1;
    wound = 1;

    arcs  = [];
    motes = [];

    var _poly = scr_death_body_poly(body_sprite, body_index, body_xscale, body_yscale);
    var _pa = scr_death_clip_poly(_poly, cut_nx, cut_ny,  1);
    var _pb = scr_death_clip_poly(_poly, cut_nx, cut_ny, -1);

    var _sep = 5.4;
    half_a = {
        poly : _pa,
        cx : death_x, cy : death_y,
        vx : inherit_vx * 0.75 +  cut_nx * _sep + random_range(-1.8, 1.8),
        vy : inherit_vy * 0.65 +  cut_ny * _sep - random_range(3.6, 7.6),
        rot : body_angle, spin : random_range(8.0, 17.5),
        hit_ground : false
    };
    half_b = {
        poly : _pb,
        cx : death_x, cy : death_y,
        vx : inherit_vx * 0.75 + -cut_nx * _sep + random_range(-1.8, 1.8),
        vy : inherit_vy * 0.65 + -cut_ny * _sep - random_range(4.0, 8.2),
        rot : body_angle, spin : random_range(-17.5, -8.0),
        hit_ground : false
    };

    if (has_camera) {
        oCameraController.shake            = max(oCameraController.shake, 24);
        oCameraController.zoom_punch       = max(oCameraController.zoom_punch, 0.16);
        oCameraController.letterbox_target = 1;
    }
    if (has_controller) {
        with (oAvoidanceController) {
            hitstop_frames   = max(hitstop_frames, 9);
            vignette_pulse   = max(vignette_pulse, 1.45);
            bloom_pulse      = max(bloom_pulse, 1.15);
            aberration_pulse = max(aberration_pulse, 1.10);
            tear_amount      = max(tear_amount, 0.68);
            slash_center_x = other.death_x;
            slash_center_y = other.death_y;
        }
        for (var i = 0; i < 26; i++) {
            var _a  = cut_angle + (i / 26) * 360 + random_range(-10, 10);
            var _d  = random_range(180, 440);
            var _bx = death_x + lengthdir_x(_d, _a);
            var _by = death_y + lengthdir_y(_d, _a);
            scr_slash_bolt(death_x, death_y, _bx, _by,
                irandom_range(7, 15), 22, 2.4, 1.0);
        }
    }

    for (var i = 0; i < 90; i++) {
        var _a = cut_angle + choose(0, 180) + random_range(-26, 26);
        var _s = random_range(4.5, 16);
        array_push(embers, {
            x : death_x, y : death_y,
            vx : lengthdir_x(_s, _a),
            vy : lengthdir_y(_s, _a),
            life : irandom_range(22, 62), life_max : 62,
            size : random_range(0.8, 3.4)
        });
    }

    for (var i = 0; i < _k_spray_count; i++) {
        var _side = choose(-1, 1);
        var _a = cut_angle + 90 * _side + random_range(-82, 82);
        var _s = random_range(3.5, 20.0);
        array_push(droplets, {
            x : death_x + random_range(-5, 5),
            y : death_y + random_range(-7, 7),
            vx : inherit_vx * 0.25 + lengthdir_x(_s, _a),
            vy : inherit_vy * 0.18 + lengthdir_y(_s, _a) - random_range(1.2, 6.5),
            life : irandom_range(42, 118), life_max : 118,
            size : random_range(0.6, 3.2),
            landed : false
        });
    }

    for (var i = 0; i < _k_shrapnel_count; i++) {
        var _side = choose(-1, 1);
        var _a = cut_angle + 90 * _side + random_range(-70, 70);
        var _s = random_range(4.5, 18.5);
        var _life = irandom_range(72, 150);
        var _size = random_range(2.0, 7.6);
        array_push(chunks, {
            x : death_x + random_range(-6, 6),
            y : death_y + random_range(-8, 8),
            vx : inherit_vx * 0.35 + lengthdir_x(_s, _a),
            vy : inherit_vy * 0.25 + lengthdir_y(_s, _a) - random_range(2.0, 8.0),
            rot : random(360),
            spin : random_range(-22, 22),
            life : _life, life_max : _life,
            size : _size,
            heat : random_range(0.0, 0.55),
            poly : scr_death_chunk_poly(irandom_range(5, 9), 0.45, 1.25),
            landed : false,
            smear : random_range(8, 34)
        });
    }

    for (var i = 0; i < _k_splinter_count; i++) {
        var _a = cut_angle + choose(0, 180) + random_range(-28, 28);
        var _s = random_range(8, 25);
        var _life = irandom_range(34, 92);
        array_push(splinters, {
            x : death_x + random_range(-4, 4),
            y : death_y + random_range(-6, 6),
            vx : inherit_vx * 0.2 + lengthdir_x(_s, _a),
            vy : inherit_vy * 0.15 + lengthdir_y(_s, _a) - random_range(0.5, 4.5),
            ang : _a,
            spin : random_range(-18, 18),
            life : _life, life_max : _life,
            len : random_range(10, 46),
            w : random_range(1, 4),
            heat : random_range(0.55, 1),
            landed : false
        });
    }
}

if (body_split) {
    var _since = t - _p2;

    wound = max(0, wound - _k_wound_fade / _fa);

    if (t < _k_split_start) {
        screen_split = 0;
    } else {
        var _sp_t = t - _k_split_start;

        if (_sp_t < _k_split_slam_hold) {
            screen_split = _k_split_slam + random_range(-_k_split_jitter, _k_split_jitter);
        } else {
            var _drift_span = max(1, _p4 - _k_split_start - _k_split_slam_hold);
            var _drift_t = clamp((_sp_t - _k_split_slam_hold) / _drift_span, 0, 1);
            screen_split = lerp(_k_split_slam, _k_split_drift_to, _drift_t);
        }
    }

    if (t >= _p3) {
        seam_heat = 1 - clamp((t - _p3) / (_p4 - _p3), 0, 1);
    }

    if (screen_split > 0.6 && array_length(seam_embers) < 170) {
        repeat (4) {
            array_push(seam_embers, {
                u  : random_range(-0.92, 0.92),
                vx : random_range(-1.0, 1.0),
                vy : random_range(0.7, 3.2),
                drop : 0,
                alpha : 1
            });
        }
    }

    if (has_controller && screen_split > 0.001) {
        with (oAvoidanceController) {
            slash_amount   = max(slash_amount, other.screen_split);
            slash_center_x = other.death_x;
            slash_center_y = other.death_y;
        }
    }

    cut_flash = max(0, cut_flash - 0.36 / _fa);

    var _halves = [half_a, half_b];
    for (var h = 0; h < 2; h++) {
        var _p = _halves[h];
        if (is_undefined(_p)) continue;

        _p.vy += 0.62 / _fa;
        _p.cx += _p.vx / _fa;
        _p.cy += _p.vy / _fa;
        _p.rot += _p.spin / _fa;

        if (!is_undefined(ground_y) && _p.cy >= ground_y - 4) {
            var _impact_v = abs(_p.vy);
            _p.cy = ground_y - 4;
            if (!_p.hit_ground) {
                _p.hit_ground = true;
                death_add_decal(_p.cx, ground_y, random_range(15, 31));
                array_push(floor_smears, {
                    x1 : _p.cx - _p.vx * random_range(1.2, 2.8),
                    y1 : ground_y,
                    x2 : _p.cx + _p.vx * random_range(5.0, 11.0),
                    y2 : ground_y + random_range(-1.5, 1.5),
                    w : random_range(7, 18),
                    alpha : random_range(0.58, 0.95),
                    heat : random_range(0.0, 0.22)
                });

                repeat (24) {
                    array_push(droplets, {
                        x : _p.cx + random_range(-10, 10),
                        y : ground_y - random_range(0, 4),
                        vx : _p.vx * random_range(0.15, 0.55) + random_range(-5, 5),
                        vy : -random_range(2.0, 9.0) - _impact_v * 0.18,
                        life : irandom_range(36, 88), life_max : 88,
                        size : random_range(0.7, 2.4),
                        landed : false
                    });
                }

                if (has_camera) oCameraController.shake = max(oCameraController.shake, 8 + _impact_v * 1.7);
            }
            _p.vy *= -0.14;
            _p.vx *= 0.48;
            _p.spin *= 0.34;
            if (abs(_p.vy) < 0.5) { _p.vy = 0; _p.spin *= 0.6; }
        }
    }

    for (var r = 0; r < array_length(ribbons); r++) {
        var _rb = ribbons[r];

        if (_rb.emit_left > 0) {
            _rb.emit_left -= 1 / _fa;
            var _pulse = 0.55 + 0.45 * dsin(t * 26 + r * 60);
            var _sp  = _rb.speed * _pulse;
            var _jx  = random_range(-0.5, 0.5);
            var _jy  = random_range(-0.5, 0.5);
            var _nvx = lengthdir_x(_sp, _rb.jet_ang) + _jx;
            var _nvy = lengthdir_y(_sp, _rb.jet_ang) + _jy;
            array_insert(_rb.nodes, 0, {
                x : death_x + random_range(-3, 3),
                y : death_y + random_range(-3, 3),
                vx : _nvx,
                vy : _nvy,
                a : 1, w : random_range(0.75, 1.25),
                landed : false
            });
            if (array_length(_rb.nodes) > _k_ribbon_nodes) {
                array_resize(_rb.nodes, _k_ribbon_nodes);
            }
        }

        for (var i = array_length(_rb.nodes) - 1; i >= 0; i--) {
            var _nd = _rb.nodes[i];
            if (!_nd.landed) {
                _nd.vy += _k_ribbon_gravity / _fa;
                _nd.x  += _nd.vx / _fa;
                _nd.y  += _nd.vy / _fa;

                if (!is_undefined(ground_y) && _nd.y >= ground_y) {
                    _nd.y = ground_y;
                    _nd.landed = true;
                    _nd.vx = 0; _nd.vy = 0;
                    death_add_decal(_nd.x, ground_y, random_range(3, 9));
                }
            }
            _nd.a -= 0.012 / _fa;
            if (_nd.a <= 0) array_delete(_rb.nodes, i, 1);
        }
    }

    for (var i = 0; i < array_length(seam_drips); i++) {
        var _sd = seam_drips[i];
        if (_sd.delay > 0) { _sd.delay -= 1 / _fa; continue; }
        if (_sd.len < _sd.target) _sd.len += _sd.speed / _fa;
        if (t >= _p3) _sd.alpha -= 0.016 / _fa;
    }
}

for (var i = array_length(arcs) - 1; i >= 0; i--) {
    arcs[i].life -= 1 / _fa;
    if (arcs[i].life <= 0) array_delete(arcs, i, 1);
}

for (var i = array_length(cut_strikes) - 1; i >= 0; i--) {
    cut_strikes[i].life -= 1 / _fa;
    if (cut_strikes[i].life <= 0) array_delete(cut_strikes, i, 1);
}

for (var i = array_length(seam_embers) - 1; i >= 0; i--) {
    var _se = seam_embers[i];
    _se.vy += 0.09 / _fa;
    _se.drop += _se.vy / _fa;
    _se.u += (_se.vx * 0.002) / _fa;
    _se.alpha -= 0.035 / _fa;
    if (_se.alpha <= 0) array_delete(seam_embers, i, 1);
}

for (var i = array_length(chunks) - 1; i >= 0; i--) {
    var _ch = chunks[i];
    if (!_ch.landed) {
        _ch.vy += _k_chunk_gravity / _fa;
        _ch.vx *= 0.988;
        _ch.x += _ch.vx / _fa;
        _ch.y += _ch.vy / _fa;
        _ch.rot += _ch.spin / _fa;

        if (!is_undefined(ground_y) && _ch.y >= ground_y) {
            _ch.y = ground_y;
            _ch.landed = true;
            death_add_decal(_ch.x, ground_y, _ch.size * random_range(1.7, 3.6));
            if (abs(_ch.vx) > 1.1) {
                array_push(floor_smears, {
                    x1 : _ch.x,
                    y1 : ground_y + random_range(-1, 1),
                    x2 : _ch.x + _ch.vx * _ch.smear,
                    y2 : ground_y + random_range(-2, 2),
                    w : random_range(2.5, 8.5),
                    alpha : random_range(0.42, 0.8),
                    heat : random_range(0.0, 0.25)
                });
            }
            _ch.vx *= 0.38;
            _ch.vy *= -0.12;
            _ch.spin *= 0.3;
        }
    } else {
        _ch.vx *= 0.86;
        _ch.spin *= 0.82;
    }

    _ch.life -= 1 / _fa;
    if (_ch.life <= 0) array_delete(chunks, i, 1);
}

for (var i = array_length(splinters) - 1; i >= 0; i--) {
    var _spn = splinters[i];
    if (!_spn.landed) {
        _spn.vy += 0.24 / _fa;
        _spn.x += _spn.vx / _fa;
        _spn.y += _spn.vy / _fa;
        _spn.ang += _spn.spin / _fa;
        _spn.vx *= 0.985;

        if (!is_undefined(ground_y) && _spn.y >= ground_y) {
            _spn.y = ground_y;
            _spn.landed = true;
            _spn.vx *= 0.22;
            _spn.vy = 0;
            _spn.spin *= 0.15;
            if (random(1) < 0.55) death_add_decal(_spn.x, ground_y, random_range(1.5, 4.5));
        }
    }

    _spn.life -= 1 / _fa;
    if (_spn.life <= 0) array_delete(splinters, i, 1);
}

for (var i = array_length(droplets) - 1; i >= 0; i--) {
    var _d = droplets[i];
    if (!_d.landed) {
        _d.vy += _k_droplet_gravity / _fa;
        _d.x  += _d.vx / _fa;
        _d.y  += _d.vy / _fa;
        if (!is_undefined(ground_y) && _d.y >= ground_y) {
            _d.y = ground_y;
            _d.landed = true;
            death_add_decal(_d.x, ground_y, _d.size * random_range(1.4, 3.0));
        }
    }
    _d.life -= 1 / _fa;
    if (_d.life <= 0) array_delete(droplets, i, 1);
}

for (var i = array_length(embers) - 1; i >= 0; i--) {
    var _e = embers[i];
    _e.vy += 0.16 / _fa;
    _e.vx *= 0.965;
    _e.x  += _e.vx / _fa;
    _e.y  += _e.vy / _fa;
    _e.life -= 1 / _fa;
    if (_e.life <= 0) array_delete(embers, i, 1);
}

for (var i = array_length(screen_splats) - 1; i >= 0; i--) {
    var _ss = screen_splats[i];
    if (_ss.delay > 0) {
        _ss.delay -= 1 / _fa;
    } else {
        if (_ss.run < _ss.target) _ss.run += _ss.speed / _fa;
        _ss.life -= 1 / _fa;
        if (_ss.life < 40) _ss.alpha -= 0.018 / _fa;
    }
    if (_ss.life <= 0 || _ss.alpha <= 0) array_delete(screen_splats, i, 1);
}

if (has_controller && body_split && floor(t) == floor(_p2) + 1) {
    scr_impact_pulse(1.35, 1.15, 1.65, death_x, death_y);
}

if (t >= _k_gameover_at && !instance_exists(oGameover)) {
    instance_create_depth(0, 0, depth - 1, oGameover);
}
