event_inherited();

if (!instance_exists(oHoneycombController)) {
    hit_active = false;
    exit;
}
var _ctrl = oHoneycombController;

if (blast_active) {
    hit_active = false;
    despawn_timer++;
    var _bt = clamp(despawn_timer / despawn_duration, 0, 1);

    draw_x = x + lengthdir_x(blast_speed, blast_dir);
    draw_y = y + lengthdir_y(blast_speed, blast_dir);
    x = draw_x;
    y = draw_y;

    blast_speed *= 0.965;
    blast_angle += blast_spin;

    ignite_flash = max(0, ignite_flash - 0.05);
    draw_scale = lerp(1.5, 0.05, power(_bt, 1.6)) * max(honeycomb_depth * 0.5 + 0.75, 0.4);
    draw_alpha = 1 - power(_bt, 2.4);

    if (despawn_timer >= despawn_duration) instance_destroy();
    exit;
}

if (!ignited) {
    if (honeycomb_height <= _ctrl.materialize_h) {
        ignited = true;
        ignite_flash = 1;
        if (spec_index >= 0) _ctrl.bullet_specs[spec_index].seen = true;
    } else {
        hit_active = false;
        draw_alpha = 0;

        var _pre_angle = honeycomb_angle + _ctrl.cylinder_rotation;
        draw_x = _ctrl.center_x + cos(_pre_angle) * _ctrl.radius;
        draw_y = _ctrl.center_y + honeycomb_height + sin(_pre_angle) * _ctrl.depth_offset;
        x = draw_x;
        y = draw_y;
        exit;
    }
}

ignite_flash = max(0, ignite_flash - 0.055);

if (!spawn_complete) {
    spawn_timer++;
    var _t = spawn_timer / spawn_duration;
    image_alpha = 1 - power(1 - _t, 4);
    if (spawn_timer >= spawn_duration) {
        image_alpha = 1;
        spawn_complete = true;
    }
}

if (despawning) {
    despawn_timer++;
    var _dt = despawn_timer / despawn_duration;
    image_alpha = 1 - power(_dt, 3);
    pulse_scale = lerp(1, 0.7, _dt);
    if (despawn_timer >= despawn_duration) {
        instance_destroy();
        exit;
    }
}

var _current_angle = honeycomb_angle + _ctrl.cylinder_rotation;
var _z = sin(_current_angle);
var _face = (_z + 1) * 0.5;

draw_x = _ctrl.center_x + cos(_current_angle) * _ctrl.radius;
draw_y = _ctrl.center_y + honeycomb_height + (_z * _ctrl.depth_offset);
honeycomb_depth = _z;

var _proj_scale = lerp(_ctrl.scale_min, _ctrl.scale_max, _face);
var _proj_alpha = lerp(_ctrl.alpha_min, _ctrl.alpha_max, _face);

ring_heat = 0;
var _rings = _ctrl.hc_pulse_rings;
var _ring_count = array_length(_rings);
for (var i = 0; i < _ring_count; i++) {
    var _r = _rings[i];
    var _d = abs(honeycomb_height - _r.h);
    if (_d < _ctrl._k_hc_pulse_width) {

        var _band = power(1 - (_d / _ctrl._k_hc_pulse_width), 1.5);
        ring_heat = max(ring_heat, _band * _r.power * (_r.life / _r.life_max));
    }
}

prox_heat = 0;
if (_z > 0.2 && instance_exists(oPlayer)) {
    var _pd = point_distance(draw_x, draw_y, oPlayer.x, oPlayer.y);
    if (_pd < 190) prox_heat = power(1 - _pd / 190, 2);
}

var _heat = ring_heat + _ctrl.hc_wall_heat * 0.35 + prox_heat * 0.5 + ignite_flash;

if (is_open) {

    var _shimmer = 0.6 + 0.4 * sin(current_time * 0.004 + shimmer_phase);
    var _lane_bonus = is_lane_gap ? (0.45 + _ctrl.lane_guide_pulse * 0.5) : 0;
    draw_alpha = _ctrl.open_alpha * image_alpha * (_shimmer + _lane_bonus) * (0.45 + _face * 0.55);
    draw_scale = _proj_scale * pulse_scale * 0.55;
} else {
    draw_alpha = _proj_alpha * image_alpha + pulse_glow * 0.35 + _heat * 0.5;
    draw_scale = _proj_scale * pulse_scale * (1 + _heat * 0.55);
}

x = draw_x;
y = draw_y;
hit_active = !is_open && !despawning && _z > 0.2 && draw_alpha > hit_alpha_min && draw_scale > hit_scale_min;

var _bucket = round(-_z * 32);
if (_bucket != last_depth_bucket) {
    last_depth_bucket = _bucket;
    depth = _bucket * 31;
}

if (last_pulse_id != _ctrl.bass_pulse_id) {
    last_pulse_id = _ctrl.bass_pulse_id;
    pulse_scale = 1.05 + _ctrl.bass_escalation * 0.22;
    pulse_glow = 1;
    pulse_glow_timer = 10;
} else if (!despawning) {

    pulse_scale = lerp(pulse_scale, 1, 0.18);
}

if (pulse_glow_timer > 0) {
    pulse_glow_timer--;
} else {
    pulse_glow = lerp(pulse_glow, 0, 0.2);
}

if (!is_open && _z > 0.72 && prox_heat > 0.05) {
    scr_register_glow_point(draw_x, draw_y);
}
