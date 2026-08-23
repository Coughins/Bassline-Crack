var _t = oAvoidanceController.t;

for (var ri = array_length(materialize_rings) - 1; ri >= 0; ri--)
{
    var _r = materialize_rings[ri];
    _r.radius += _k_materialize_ring_speed;
    _r.alpha -= _k_materialize_ring_fade;
    if (_r.alpha <= 0) array_delete(materialize_rings, ri, 1);
}
for (var si = array_length(materialize_sparks) - 1; si >= 0; si--)
{
    var _s = materialize_sparks[si];
    _s.x += _s.vx;
    _s.y += _s.vy;
    _s.vx *= 0.94;
    _s.vy *= 0.94;
    _s.alpha -= _k_materialize_spark_fade;
    if (_s.alpha <= 0) array_delete(materialize_sparks, si, 1);
}

for (var wei = array_length(orb_embers) - 1; wei >= 0; wei--)
{
    var _we = orb_embers[wei];
    _we.x += _we.vx;
    _we.y += _we.vy;
    _we.vx *= 0.92;
    _we.vy *= 0.92;
    _we.alpha -= 0.045;
    if (_we.alpha <= 0) array_delete(orb_embers, wei, 1);
}

for (var wpi = 0; wpi < array_length(windup_afterglow_points); wpi++)
{
    var _wp = windup_afterglow_points[wpi];
    if (_wp.revealed) _wp.alpha = max(0, _wp.alpha - _k_windup_afterglow_fade);
}

for (var sai = array_length(swing_afterimages) - 1; sai >= 0; sai--)
{
    swing_afterimages[sai].alpha -= 0.12;
    if (swing_afterimages[sai].alpha <= 0) array_delete(swing_afterimages, sai, 1);
}

core_flash = max(0, core_flash - 0.07);

for (var ssi = array_length(shell_shards) - 1; ssi >= 0; ssi--)
{
    var _ss = shell_shards[ssi];
    _ss.x += _ss.vx;
    _ss.y += _ss.vy;
    _ss.vx *= 0.97;
    _ss.vy = _ss.vy * 0.97 + 0.12;
    _ss.ang += _ss.spin;
    _ss.spin *= 0.98;
    _ss.alpha -= 0.02;
    if (_ss.alpha <= 0) array_delete(shell_shards, ssi, 1);
}

for (var osi = array_length(orb_shocks) - 1; osi >= 0; osi--)
{
    var _os = orb_shocks[osi];
    _os.life--;
    _os.radius = lerp(_os.radius, _os.max_radius, 0.17);
    if (_os.life <= 0) array_delete(orb_shocks, osi, 1);
}

for (var sti = 0; sti < array_length(satellites); sti++)
{
    satellites[sti].consume_flash = max(0, satellites[sti].consume_flash - 0.08);
}

scr_register_glow_point(x, y);
if (alpha > 0.05)
{
    scr_add_light(x, y, make_color_rgb(255, 70, 55), (0.7 + core_charge * 1.6 + core_flash * 1.2) * alpha);
}

switch (phase)
{
    case "materialize":
        var _mat_p = clamp((_t - _k_t_materialize_start) / (_k_t_windup_start - _k_t_materialize_start), 0, 1);
        x = _k_materialize_x;
        y = _k_materialize_y;
        alpha = _mat_p;
        scale = _mat_p;

        for (var shi = 0; shi < array_length(shell_rings); shi++)
        {
            var _sr = shell_rings[shi];
            _sr.assemble = min(1, _mat_p * 1.4);
            _sr.rot += _sr.rot_speed * 3;
        }

        if (_t >= _k_t_windup_start) phase = "windup";
        break;

case "windup":
        var _wind_p = clamp((_t - _k_t_windup_start) / (_k_t_coil_start - _k_t_windup_start), 0, 1);
        var _wind_eased = 1 - power(1 - _wind_p, _k_windup_ease_power);

        var _wind_inv = 1 - _wind_eased;
        x = (_wind_inv * _wind_inv) * _k_windup_p0_x
            + 2 * _wind_inv * _wind_eased * _k_windup_p1_x
            + (_wind_eased * _wind_eased) * _k_windup_p2_x;
        y = (_wind_inv * _wind_inv) * _k_windup_p0_y
            + 2 * _wind_inv * _wind_eased * _k_windup_p1_y
            + (_wind_eased * _wind_eased) * _k_windup_p2_y;
        alpha = 1;
        scale = 1;

        for (var wpi = 0; wpi < array_length(windup_afterglow_points); wpi++)
        {
            var _wp = windup_afterglow_points[wpi];
            if (!_wp.revealed && _wind_eased >= _wp.t)
            {
                _wp.revealed = true;
                _wp.alpha = 1;
            }
        }

        windup_arc_regen_timer -= 1;
        if (windup_arc_regen_timer <= 0)
        {
            windup_arc_regen_timer = _k_windup_arc_regen_frames;
            var _life_max_w = _k_windup_arc_regen_frames + 2;
            var _wang = random(360);
            array_push(windup_arcs, { ang: _wang, life: _life_max_w, life_max: _life_max_w });
            if (array_length(windup_arcs) > _k_windup_arc_count) array_delete(windup_arcs, 0, 1);

            scr_slash_bolt(x, y,
                           x + lengthdir_x(_k_windup_arc_reach, _wang),
                           y + lengthdir_y(_k_windup_arc_reach, _wang),
                           _life_max_w, 5, 1.0, 0.3);
        }
        for (var wai = array_length(windup_arcs) - 1; wai >= 0; wai--)
        {
            windup_arcs[wai].life -= 1;
            if (windup_arcs[wai].life <= 0) array_delete(windup_arcs, wai, 1);
        }

        for (var omi = 0; omi < array_length(windup_orbit_motes); omi++)
        {
            windup_orbit_motes[omi].ang += _k_windup_orbit_speed;
        }

        var _wind_speed = point_distance(xprevious, yprevious, x, y);
        if (random(1) < _k_ember_chance * clamp(_wind_speed / 6, 0.3, 1.6))
        {
            var _eject_ang = point_direction(x, y, xprevious, yprevious) + random_range(-35, 35);
            array_push(orb_embers, {
                x: x, y: y,
                vx: lengthdir_x(random_range(1, 3), _eject_ang),
                vy: lengthdir_y(random_range(1, 3), _eject_ang),
                alpha: 1
            });
        }

        for (var shi = 0; shi < array_length(shell_rings); shi++)
        {
            var _sr = shell_rings[shi];
            _sr.assemble = 1;
            _sr.rot += _sr.rot_speed;
        }
        for (var sti = 0; sti < array_length(satellites); sti++)
        {
            satellites[sti].ang += _k_satellite_orbit_speed;
            satellites[sti].spin += 7;
        }

        if (instance_exists(oAvoidanceController) && random(1) < 0.22)
        {
            var _tsi = irandom(array_length(satellites) - 1);
            var _tsat = satellites[_tsi];
            if (_tsat.alive)
            {
                var _tsx = x + lengthdir_x(_tsat.radius, _tsat.ang);
                var _tsy = y + lengthdir_y(_tsat.radius, _tsat.ang);
                if (array_length(oAvoidanceController.slash_bolts) < oAvoidanceController._k_slash_bolt_max)
                {
                    array_push(oAvoidanceController.slash_bolts, {
                        x1: _tsx, y1: _tsy, x2: x, y2: y,
                        life: _k_orb_bolt_life, life_max: _k_orb_bolt_life,
                        off: scr_bolt_offsets(4, 6), width: 1.1, hot: 0.35
                    });
                }
            }
        }

        if (_t >= _k_t_coil_start)
        {
            phase = "coil";
            if (instance_exists(oCameraController)) oCameraController.letterbox_target = 1;
        }
        break;

case "coil":
        var _coil_p = clamp((_t - _k_t_coil_start) / (_k_t_swing_start - _k_t_coil_start), 0, 1);
		x = lerp(_k_windup_hold_x, _k_swing_launch_x, _coil_p);
        y = lerp(_k_windup_hold_y, _k_swing_launch_y, _coil_p);
        alpha = 1;
        scale = 1 + sin(_coil_p * pi * (3 + _coil_p * 4)) * lerp(0.15, 0.3, _coil_p);

        coil_arc_regen_timer -= 1;
        if (coil_arc_regen_timer <= 0)
        {
            coil_arc_regen_timer = _k_coil_arc_regen_frames;
            var _life_max = _k_coil_arc_regen_frames + 2;
            var _cang = random(360);
            array_push(coil_arcs, { ang: _cang, life: _life_max, life_max: _life_max });
            if (array_length(coil_arcs) > _k_coil_arc_count) array_delete(coil_arcs, 0, 1);

            scr_slash_bolt(x + lengthdir_x(_k_coil_arc_outer_radius, _cang),
                           y + lengthdir_y(_k_coil_arc_outer_radius, _cang),
                           x, y, _life_max, 5 + _coil_p * 7, 1.1 + _coil_p * 1.3, 0.3 + _coil_p * 0.5);
        }
        for (var ai = array_length(coil_arcs) - 1; ai >= 0; ai--)
        {
            coil_arcs[ai].life -= 1;
            if (coil_arcs[ai].life <= 0) array_delete(coil_arcs, ai, 1);
        }

        if (array_length(coil_leak_arcs) < _k_coil_leak_max && random(1) < _k_coil_leak_chance * (0.4 + _coil_p))
        {
            var _life_max_l = 10;
            var _lang = random(360);
            array_push(coil_leak_arcs, { ang: _lang, life: _life_max_l, life_max: _life_max_l });

            var _lring_r = lerp(_k_coil_ring_radius_start, _k_coil_ring_radius_end, _coil_p);
            scr_slash_bolt(x + lengthdir_x(_lring_r, _lang), y + lengthdir_y(_lring_r, _lang),
                           x + lengthdir_x(_k_coil_leak_reach, _lang), y + lengthdir_y(_k_coil_leak_reach, _lang),
                           _life_max_l, 9, 1.3, 0.55);
        }
        for (var lai = array_length(coil_leak_arcs) - 1; lai >= 0; lai--)
        {
            coil_leak_arcs[lai].life -= 1;
            if (coil_leak_arcs[lai].life <= 0) array_delete(coil_leak_arcs, lai, 1);
        }

        for (var mi = 0; mi < array_length(coil_motes); mi++)
        {
            var _m = coil_motes[mi];
            _m.radius -= _m.speed * (1 + _coil_p);
            if (_m.radius <= 4)
            {
                _m.radius = _k_coil_mote_radius_max;
                _m.ang = random(360);
            }
        }

        coil_pulse_timer -= 1;
        if (coil_pulse_timer <= 0)
        {
            coil_pulse_timer = lerp(_k_coil_pulse_interval, _k_coil_pulse_interval * 0.4, _coil_p);
            array_push(coil_pulses, { radius: 4, alpha: 0.8 });

            if (instance_exists(oAvoidanceController))
            {
                oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, lerp(0.15, 0.4, _coil_p));
                oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, lerp(0.1, 0.3, _coil_p));
            }
        }
        for (var pui = array_length(coil_pulses) - 1; pui >= 0; pui--)
        {
            coil_pulses[pui].radius += _k_coil_pulse_speed;
            coil_pulses[pui].alpha -= _k_coil_pulse_fade;
            if (coil_pulses[pui].alpha <= 0) array_delete(coil_pulses, pui, 1);
        }

        core_charge = _coil_p + satellites_consumed * 0.14;

        for (var shi = 0; shi < array_length(shell_rings); shi++)
        {
            var _sr = shell_rings[shi];
            _sr.assemble = 1;
            _sr.rot += _sr.rot_speed * (1 + _coil_p * 5);
        }

        for (var sti = 0; sti < array_length(satellites); sti++)
        {
            var _sat = satellites[sti];
            if (!_sat.alive) continue;

            _sat.ang += _k_satellite_orbit_speed * (1 + _coil_p * 3.5);
            _sat.spin += 7 + _coil_p * 18;

            var _due = (sti + 1) / (array_length(satellites) + 1);
            _sat.radius = lerp(_k_satellite_orbit_radius, 6, clamp(_coil_p / _due, 0, 1));

            if (instance_exists(oAvoidanceController) && random(1) < 0.4)
            {
                var _stx = x + lengthdir_x(_sat.radius, _sat.ang);
                var _sty = y + lengthdir_y(_sat.radius, _sat.ang);
                if (array_length(oAvoidanceController.slash_bolts) < oAvoidanceController._k_slash_bolt_max)
                {
                    array_push(oAvoidanceController.slash_bolts, {
                        x1: _stx, y1: _sty, x2: x, y2: y,
                        life: _k_orb_bolt_life, life_max: _k_orb_bolt_life,
                        off: scr_bolt_offsets(4, 4 + _coil_p * 8),
                        width: 1.1 + _coil_p * 1.4, hot: 0.3 + _coil_p * 0.6
                    });
                }
            }

            if (_coil_p >= _due)
            {
                _sat.alive = false;
                _sat.consume_flash = 1;
                satellites_consumed++;

                core_flash = 1;

                array_push(orb_shocks, {
                    radius: 8, max_radius: 120 + satellites_consumed * 40,
                    life: 16, life_max: 16,
                    width: 12 + satellites_consumed * 5, hot: 0.5 + satellites_consumed * 0.16
                });

                repeat (10)
                {
                    var _dang = random(360);
                    array_push(orb_embers, {
                        x: x, y: y,
                        vx: lengthdir_x(random_range(2, 6), _dang),
                        vy: lengthdir_y(random_range(2, 6), _dang),
                        alpha: 1
                    });
                }

                if (instance_exists(oCameraController))
                {
                    oCameraController.shake = max(oCameraController.shake, 4 + satellites_consumed * 3);
                    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.04 + satellites_consumed * 0.025);
                }
                if (instance_exists(oAvoidanceController))
                {
                    oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, 0.2 + satellites_consumed * 0.1);
                    oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, 0.25 + satellites_consumed * 0.12);
                    oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, 0.15 + satellites_consumed * 0.12);
                    oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, 0.2 + satellites_consumed * 0.13);

                    if (array_length(oAvoidanceController.slash_warps) < oAvoidanceController._k_slash_warp_max)
                    {
                        array_push(oAvoidanceController.slash_warps, {
                            x: x, y: y, radius: 10, max_radius: 260,
                            strength: 0.5 + satellites_consumed * 0.2, life: 18, life_max: 18
                        });
                    }
                }
            }
        }

        if (instance_exists(oAvoidanceController))
        {
            oAvoidanceController.slash_lens_x = x;
            oAvoidanceController.slash_lens_y = y;
            oAvoidanceController.slash_lens_radius = _k_lens_radius_px * (0.55 + _coil_p * 0.65);
            oAvoidanceController.slash_lens_strength = max(oAvoidanceController.slash_lens_strength,
                                                           _k_lens_strength_max * power(_coil_p, 1.4));
        }

        if (_t >= _k_t_swing_start)
        {
            phase = "swing";

            with (oCameraController)
            {
                slash_zoom_phase = "in";
                slash_zoom_timer = 0;
                slash_zoom_from = zoom;
                slash_zoom_to = 1;
            }
        }
        break;

    case "swing":
        var _swing_p = clamp((_t - _k_t_swing_start) / (_k_t_swing_end - _k_t_swing_start), 0, 1);
        var _swing_eased = _swing_p * _swing_p * _swing_p;

		x = lerp(_k_swing_launch_x, _k_swing_end_x, _swing_eased);
        y = lerp(_k_swing_launch_y, _k_swing_end_y, _swing_eased);
        alpha = 1;
        scale = 1;

        if (!swing_launch_done)
        {
            swing_launch_done = true;
            if (instance_exists(oCameraController))
            {
                oCameraController.shake = max(oCameraController.shake, 6);
                oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.1);
            }
        }

        if (!shell_shatter_done)
        {
            shell_shatter_done = true;
            core_flash = 1.4;

            for (var shi = 0; shi < array_length(shell_rings); shi++)
            {
                var _sr = shell_rings[shi];
                var _crushed_r = _sr.radius * _k_shell_crush;

                for (var vi = 0; vi < _sr.sides; vi++)
                {
                    var _va = _sr.rot + (360 / _sr.sides) * vi;
                    var _vx = x + lengthdir_x(_crushed_r, _va);
                    var _vy = y + lengthdir_y(_crushed_r, _va);
                    var _out = random_range(5, 13);

                    array_push(shell_shards, {
                        x: _vx, y: _vy,
                        vx: lengthdir_x(_out, _va) + random_range(-2, 2),
                        vy: lengthdir_y(_out, _va) + random_range(-2, 2),
                        ang: _va,
                        spin: random_range(-16, 16),
                        len: random_range(7, 17),
                        alpha: 1
                    });
                }
            }

            array_push(orb_shocks, {
                radius: 12, max_radius: 300, life: 20, life_max: 20, width: 26, hot: 1
            });

            if (instance_exists(oAvoidanceController) &&
                array_length(oAvoidanceController.slash_warps) < oAvoidanceController._k_slash_warp_max)
            {
                array_push(oAvoidanceController.slash_warps, {
                    x: x, y: y, radius: 12, max_radius: 340, strength: 1.1, life: 20, life_max: 20
                });
            }
        }

        swing_afterimage_timer -= 1;
        if (swing_afterimage_timer <= 0)
        {
            swing_afterimage_timer = _k_swing_afterimage_interval;
            array_push(swing_afterimages, { x: x, y: y, alpha: 1 });
        }

        var _speed = point_distance(xprevious, yprevious, x, y);
        if (instance_exists(oCameraController))
        {
            oCameraController.shake = max(oCameraController.shake, _speed * 0.06);
        }
        if (instance_exists(oAvoidanceController))
        {
            oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, _speed * 0.5);
            oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, 0.4);
            oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, 0.3);
        }

        if (_speed > 2)
        {
            var _perp_ang = point_direction(xprevious, yprevious, x, y) + choose(90, -90) + random_range(-15, 15);
            repeat (2)
            {
                array_push(orb_embers, {
                    x: x, y: y,
                    vx: lengthdir_x(random_range(3, 7), _perp_ang),
                    vy: lengthdir_y(random_range(3, 7), _perp_ang),
                    alpha: 1
                });
            }
        }

        if (_t >= _k_t_swing_end)
        {
            phase = "impact";
            impact_x = x;
            impact_y = y;
        }
        break;

    case "impact":
        x = impact_x;
        y = impact_y;

        if (!impact_done)
        {
            impact_done = true;

            var _impact_ix = impact_x;
            var _impact_iy = impact_y;
            var _impact_dir = point_direction(_k_swing_launch_x, _k_swing_launch_y, _k_swing_end_x, _k_swing_end_y);

            if (instance_exists(oCameraController))
            {
                oCameraController.shake = max(oCameraController.shake, 16);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.55);
                oCameraController.letterbox_target = 0;
            }
            if (instance_exists(oAvoidanceController))
            {
                oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, 0.7);
                oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, 0.8);
                oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, 0.6);
                oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, 0.7);
                oAvoidanceController.tear_amount = max(oAvoidanceController.tear_amount, 1.2);
            }

            impact_arcs = [];
            var _life_max_i = 14;
            for (var iai = 0; iai < _k_impact_arc_count; iai++)
            {
                var _iang2 = (360 / _k_impact_arc_count) * iai + random_range(-10, 10);
                array_push(impact_arcs, {
                    ang: _iang2,
                    life: _life_max_i,
                    life_max: _life_max_i
                });

                scr_slash_bolt(_impact_ix, _impact_iy,
                               _impact_ix + lengthdir_x(_k_impact_arc_reach, _iang2),
                               _impact_iy + lengthdir_y(_k_impact_arc_reach, _iang2),
                               _life_max_i, 13, 2.0, 0.7);
            }

            core_flash = 2;

            if (instance_exists(oAvoidanceController))
            {
                with (oAvoidanceController)
                {
                    for (var _iw = 0; _iw < 3; _iw++)
                    {
                        array_push(ring_shockwaves, {
                            x: _impact_ix, y: _impact_iy,
                            radius: 12 + _iw * 28, max_radius: 260 + _iw * 200,
                            life: 24 - _iw * 4, max_life: 24 - _iw * 4,
                            width: 40 - _iw * 10, hot: 1 - _iw * 0.24, vs: 1
                        });
                    }

                    for (var _is = 0; _is < 26; _is++)
                    {
                        var _isang = (random(1) < 0.6) ? _impact_dir + choose(0, 180) + random_range(-26, 26)
                                                       : random(360);
                        array_push(ring_streaks, {
                            cx: _impact_ix, cy: _impact_iy, vs: 1,
                            ang: _isang, dist: random_range(15, 80), len: random_range(50, 200),
                            speed: random_range(10, 24), life: 13 + irandom(11), max_life: 24,
                            width: random_range(1.2, 3.2), hot: random_range(0.5, 1)
                        });
                    }

                    for (var _ip = 0; _ip < 46; _ip++)
                    {
                        var _ipang = (random(1) < 0.55) ? _impact_dir + choose(0, 180) + random_range(-40, 40)
                                                        : random(360);
                        var _ipspd = random_range(3, 12);
                        array_push(arrow_ring_particles, {
                            x: _impact_ix, y: _impact_iy,
                            vx: lengthdir_x(_ipspd, _ipang), vy: lengthdir_y(_ipspd, _ipang),
                            life: 15 + irandom(18), max_life: 33,
                            size: random_range(0.07, 0.22),
                            grav: 0.2, drag: 0.94, hot: random_range(0.5, 1)
                        });
                    }

                    for (var _ie = 0; _ie < 18; _ie++)
                    {
                        var _ieang = _impact_dir + choose(0, 180) + random_range(-45, 45);
                        array_push(ring_embers, {
                            x: _impact_ix + lengthdir_x(random_range(-90, 90), _impact_dir),
                            y: _impact_iy + lengthdir_y(random_range(-90, 90), _impact_dir),
                            vx: lengthdir_x(random_range(0.5, 2.2), _ieang),
                            vy: lengthdir_y(random_range(0.5, 2.2), _ieang) - random_range(0.4, 1.8),
                            life: 14 + irandom(12), max_life: 26,
                            size: random_range(0.11, 0.28), hot: random_range(0.5, 0.95)
                        });
                    }

                    if (array_length(slash_warps) < _k_slash_warp_max)
                    {
                        array_push(slash_warps, {
                            x: _impact_ix, y: _impact_iy, radius: 14, max_radius: 460,
                            strength: 1.4, life: 24, life_max: 24
                        });
                    }
                }

                scr_floor_impact(_impact_ix, _impact_iy, 1.0, 1);
            }
        }

        for (var iai = array_length(impact_arcs) - 1; iai >= 0; iai--)
        {
            impact_arcs[iai].life -= 1;
            if (impact_arcs[iai].life <= 0) array_delete(impact_arcs, iai, 1);
        }

        var _impact_p = clamp((_t - _k_t_swing_end) / (_k_t_impact_end - _k_t_swing_end), 0, 1);
        alpha = 1 - _impact_p;
        scale = 1 + _impact_p * 3;

        if (_t >= _k_t_impact_end)
        {
            instance_destroy();
        }
        break;
}

if (phase != "materialize" && phase != "impact")
{
    array_push(trail_positions, { x: x, y: y });
    var _trail_max = (phase == "swing") ? _k_trail_max_swing : _k_trail_max_normal;
    while (array_length(trail_positions) > _trail_max) array_delete(trail_positions, 0, 1);
}
