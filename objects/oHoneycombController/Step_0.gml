var _t = instance_exists(oAvoidanceController) ? oAvoidanceController.t : 0;

// function of `t`, and it runs FIRST so the beat block below can fire surges
scr_duct_update(_t);

if (!hc_detonated) {
    var _band = scr_honeycomb_visible_band(center_y, depth_offset, cull_margin);

    if (!window_initialised) {
        var _blo = 0, _bhi = spec_count;
        while (_blo < _bhi) {
            var _mid = (_blo + _bhi) div 2;
            if (bullet_specs[_mid].height < _band.top) _blo = _mid + 1; else _bhi = _mid;
        }
        spec_lo = _blo;
        spec_hi = _blo;
        window_initialised = true;
    }

    var _budget = spawn_budget_per_frame;

    var _cull_top = _band.top - cull_hysteresis;
    var _cull_bot = _band.bottom + cull_hysteresis;

    while (spec_hi > spec_lo && bullet_specs[spec_hi - 1].height > _cull_bot) {
        spec_hi--;
        var _sd = bullet_specs[spec_hi];
        _sd.live = false;
        _sd.hit_active = false;
        _sd.draw_alpha = 0;
    }
    while (spec_lo < spec_hi && bullet_specs[spec_lo].height < _cull_top) {
        var _su = bullet_specs[spec_lo];
        _su.live = false;
        _su.hit_active = false;
        _su.draw_alpha = 0;
        spec_lo++;
    }

    while (_budget > 0 && spec_hi < spec_count && bullet_specs[spec_hi].height <= _band.bottom) {
        scr_honeycomb_spawn_bullet(spec_hi);
        spec_hi++;
        _budget--;
    }
    while (_budget > 0 && spec_lo > 0 && bullet_specs[spec_lo - 1].height >= _band.top) {
        spec_lo--;
        scr_honeycomb_spawn_bullet(spec_lo);
        _budget--;
    }

    live_bullet_count = spec_hi - spec_lo;
}

if (hc_phase == "materialize") {
    var _mat_band = scr_honeycomb_visible_band(center_y, depth_offset, cull_margin);
    var _mat_span = _k_hc_t_live - _k_hc_t_spawn;
    materialize_p = clamp((_t - _k_hc_t_spawn) / _mat_span, 0, 1);

    materialize_h = lerp(home_height, _mat_band.bottom + 120, power(materialize_p, 0.85));

    if (instance_exists(oAvoidanceController)) {
        with (oAvoidanceController) {
            vignette_pulse   = max(vignette_pulse, 0.10 + other.materialize_p * 0.22);
            aberration_pulse = max(aberration_pulse, other.materialize_p * 0.45);
            bloom_pulse      = max(bloom_pulse, other.materialize_p * 0.18);
        }
    }
    if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = max(oCameraController.letterbox_target, materialize_p * 0.6);
    }

    if (materialize_p > 0.02 && irandom(100) < 55) {
        if (array_length(hc_scan_arcs) > 14) array_delete(hc_scan_arcs, 0, 1);
        var _sa1 = random(2 * pi);
        array_push(hc_scan_arcs, {
            a1   : _sa1,
            a2   : _sa1 + random_range(0.5, 2.1) * choose(-1, 1),
            h    : materialize_h + random_range(-40, 20),
            life : irandom_range(5, 11),
            life_max : 11,
            off  : scr_bolt_offsets(4, 16)
        });
    }

    if (_t >= _k_hc_t_live) {
        hc_phase = "travel";
        materialize_h = 100000;
        materialize_p = 1;
        if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0;
    }
}

if (bass_index < array_length(bass_times)) {
    if (_t >= bass_times[bass_index]) {
        var _is_detonation_beat = (bass_times[bass_index] >= _k_hc_t_detonate);
        bass_index++;

        if (!_is_detonation_beat) {
            bass_pulse_id++;
            bass_escalation = clamp((bass_index - 1) / max(1, bass_beat_total - 1), 0, 1);

            var _beat_power = lerp(0.55, 1.5, bass_escalation);
            bass_flash = _beat_power;
            rotation_speed += _k_hc_rotation_speed_gain;
            hc_rotation_kick = max(hc_rotation_kick,
                                   lerp(_k_hc_rotation_kick_min,
                                        _k_hc_rotation_kick_max,
                                        bass_escalation));
            hc_wall_heat = max(hc_wall_heat, lerp(0.35, 1.0, bass_escalation));

            if (array_length(hc_pulse_rings) >= _k_hc_max_pulse_rings) array_delete(hc_pulse_rings, 0, 1);
            array_push(hc_pulse_rings, {
                h      : scr_duct_plug_h() + duct_flow * _k_hc_pulse_width * 0.5,
                vel    : -duct_flow * _k_hc_pulse_speed * lerp(1, 1.9, bass_escalation),
                life   : 90,
                life_max : 90,
                power  : _beat_power
            });

            lane_guide_pulse = 1;
            scr_duct_beat(bass_index);

            scr_impact_pulse(0.12 + bass_escalation * 0.20, 0.35 + bass_escalation * 0.7,
                             0.15 + bass_escalation * 0.35, center_x, center_y);
            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 2 + bass_escalation * 5);
                if (bass_escalation > 0.6) {
                    oCameraController.zoom_punch = max(oCameraController.zoom_punch,
                                                      (bass_escalation - 0.6) * 0.12);
                }
            }
        }
    }
}

bass_flash = lerp(bass_flash, 0, 0.12);
hc_wall_heat = max(0, hc_wall_heat - 0.045);
hc_rotation_kick *= 0.86;
if (hc_rotation_kick < 0.0002) hc_rotation_kick = 0;

for (var i = array_length(hc_pulse_rings) - 1; i >= 0; i--) {
    var _pr = hc_pulse_rings[i];
    _pr.h += _pr.vel;
    _pr.life--;
    if (_pr.life <= 0) array_delete(hc_pulse_rings, i, 1);
}

if (!hc_detonated && _t >= _k_hc_t_coil) {
    hc_phase = "coil";
    var _coil_raw = clamp((_t - _k_hc_t_coil) / (_k_hc_t_detonate - _k_hc_t_coil), 0, 1);
    hc_coil = power(_coil_raw, 1.6);

    radius = radius_base * lerp(1, 0.87, hc_coil);
    depth_offset = depth_offset_base * lerp(1, 2.0, hc_coil);
    open_alpha = lerp(_k_duct_open_alpha, _k_duct_open_alpha_coil, hc_coil);

    hc_heartbeat_phase += lerp(0.055, 0.19, hc_coil);
    var _hb_env = power(max(0, sin(hc_heartbeat_phase)), 6);
    hc_heartbeat = _hb_env * lerp(0.25, 1, hc_coil);

    if (irandom(100) < 6 + hc_coil * 34) {
        _k_hc_coil_arc_id++;
        if (array_length(hc_coil_arcs) > 22) array_delete(hc_coil_arcs, 0, 1);
        array_push(hc_coil_arcs, {
            ang      : random(360),
            reach    : random_range(300, 560) * lerp(1.15, 0.75, hc_coil),
            h        : random_range(-260, 260),
            life     : irandom_range(7, 13),
            life_max : 13,
            off      : scr_bolt_offsets(5, 20 + hc_coil * 22),
            bolt_id  : "hc_coil_" + string(_k_hc_coil_arc_id)
        });
    }

    with (oAvoidanceController) {
        vignette_pulse   = max(vignette_pulse, 0.2 + other.hc_coil * 0.5 + other.hc_heartbeat * 0.25);
        aberration_pulse = max(aberration_pulse, other.hc_coil * 0.6 + other.hc_heartbeat * 0.8);
        bloom_pulse      = max(bloom_pulse, other.hc_heartbeat * 0.45 + other.hc_coil * 0.2);
        global_ripple_pulse = max(global_ripple_pulse, other.hc_coil * 0.10 + other.hc_heartbeat * 0.12);
    }
    if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = max(oCameraController.letterbox_target, hc_coil * 0.45);
        oCameraController.shake = max(oCameraController.shake, hc_coil * 4 + hc_heartbeat * 3);
    }
}

else {
    hc_heartbeat = max(0, hc_heartbeat - 0.06);
}

for (var i = array_length(hc_coil_arcs) - 1; i >= 0; i--) {
    hc_coil_arcs[i].life--;
    if (hc_coil_arcs[i].life <= 0) array_delete(hc_coil_arcs, i, 1);
}
for (var i = array_length(hc_scan_arcs) - 1; i >= 0; i--) {
    hc_scan_arcs[i].life--;
    if (hc_scan_arcs[i].life <= 0) array_delete(hc_scan_arcs, i, 1);
}

if (!hc_detonated && _t >= _k_hc_t_detonate) {
    hc_detonated = true;
    hc_phase = "impact";
    hc_detonate_flash = 1;
    hc_coil = 1;

    for (var _hb_i = spec_lo; _hb_i < spec_hi; _hb_i++) {
        var _hb = bullet_specs[_hb_i];
        if (!_hb.live || _hb.draw_alpha <= 0.01) continue;

        _hb.despawning = true;
        _hb.despawn_timer = 0;
        _hb.despawn_duration = 44;

        var _out_dir = point_direction(center_x, center_y, _hb.draw_x, _hb.draw_y);
        var _vent_dir = point_direction(_hb.draw_x, _hb.draw_y,
                                        _hb.draw_x + random_range(-110, 110), _k_duct_seam_y);
        var _spin_bias = (rotation_speed >= 0) ? 90 : -90;
        _hb.blast_dir   = _out_dir + angle_difference(_vent_dir, _out_dir) * 0.55
                        + _spin_bias * 0.28 + random_range(-12, 12);
        _hb.blast_speed = random_range(7, 19) * (0.55 + max(_hb.honeycomb_depth, 0) * 0.75);
        _hb.blast_spin  = random_range(-11, 11);
        _hb.blast_active = true;
        _hb.ignite_flash = 1;
    }

    hc_shock_rings = [
        { r: 20,  vel: 26, life: 34, life_max: 34, width: 7 },
        { r: 0,   vel: 17, life: 46, life_max: 46, width: 12 },
        { r: 0,   vel: 9,  life: 62, life_max: 62, width: 20 }
    ];

    scr_impact_pulse(0.52, 1.25, 0.44, center_x, center_y);
    with (oAvoidanceController) {
        tear_amount = max(tear_amount, 0.34);
        global_ripple_pulse = max(global_ripple_pulse, 0.52);
    }
    if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 20);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.17);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
        oCameraController.angle_kick = choose(-3.0, 3.0);
        oCameraController.letterbox_target = 0;
    }
    scr_bg_bass_hit();
}

hc_detonate_flash = max(0, hc_detonate_flash - 0.045);

for (var i = array_length(hc_shock_rings) - 1; i >= 0; i--) {
    var _sr = hc_shock_rings[i];
    _sr.r += _sr.vel;
    _sr.vel *= 0.94;
    _sr.life--;
    if (_sr.life <= 0) array_delete(hc_shock_rings, i, 1);
}

if (hc_detonated && hc_active_count <= 0 && array_length(hc_shock_rings) == 0) {
    instance_destroy();
    exit;
}

if (hc_phase == "materialize") {
    rotation_ease = 0;
    scroll_ease = 0;
} else {
    if (rotation_ease < 1) rotation_ease = min(1, rotation_ease + 1 / _k_hc_rotation_ease_frames);
    if (scroll_ease < 1) scroll_ease = min(1, scroll_ease + 1 / _k_hc_scroll_ease_frames);
}
cylinder_rotation += (rotation_speed + hc_rotation_kick) * rotation_ease;

lane_guide_pulse = max(0, lane_guide_pulse - 0.055);

if (!hc_detonated && hc_phase != "materialize") {
    if (move_dir == 1) {
        center_y += scroll_ease;
    } else {
        center_y -= scroll_ease;
    }
}


scr_duct_cells_update();

scr_honeycomb_update_specs();
