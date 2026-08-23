function scr_honeycomb_spawn_bullet(_spec_index) {
    var _spec = bullet_specs[_spec_index];

    _spec.live = true;
    _spec.hit_active = false;
    _spec.ring_heat = 0;
    _spec.prox_heat = 0;
    _spec.pulse_scale = 1;
    _spec.pulse_glow = 0;
    _spec.pulse_glow_timer = 0;
    _spec.despawning = false;
    _spec.despawn_timer = 0;
    _spec.despawn_duration = 44;
    _spec.blast_active = false;
    _spec.blast_speed = 0;
    _spec.blast_spin = 0;
    _spec.blast_angle = 0;

    _spec.shimmer_phase = _spec.angle * 3.1 + _spec.height * 0.021;

    _spec.last_pulse_id = bass_pulse_id;

    if (_spec.seen) {
        _spec.spawn_complete = true;
        _spec.image_alpha = 1;
        _spec.ignited = true;
        _spec.ignite_flash = 0;
    } else {
        _spec.spawn_timer = 0;
        _spec.spawn_duration = 26;
        _spec.spawn_complete = false;
        _spec.image_alpha = 0;
        _spec.ignited = (_spec.height <= materialize_h);
        _spec.ignite_flash = 0;
        if (_spec.ignited) {
            _spec.seen = true;
            _spec.ignite_flash = 1;
        }
    }

    var _pre_angle = _spec.angle + cylinder_rotation;
    var _z = sin(_pre_angle);
    _spec.draw_x = center_x + cos(_pre_angle) * radius;
    _spec.draw_y = center_y + _spec.height + _z * depth_offset;
    _spec.x = _spec.draw_x;
    _spec.y = _spec.draw_y;
    _spec.honeycomb_depth = _z;
    _spec.draw_scale = 1;
    _spec.draw_alpha = 0;

    return _spec;
}
