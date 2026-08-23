scr_register_glow_point(x, y);
if (spawn_timer < spawn_duration)
{
    spawn_timer += 1;
    var _p = spawn_timer / spawn_duration;
    spawn_scale = 1 - power(1 - _p, 3);
}
else
{
    spawn_scale = 1;
}

if (spawn_timer >= spawn_duration && !despawning)
{
    age_timer += 1;
    escalation = clamp(age_timer / escalation_ramp_time, 0, 1);
}

if (spawn_timer >= spawn_duration && !despawning && !flare_active)
{
    flare_timer -= 1;
    if (flare_timer <= 0)
    {
        if (random(1) < flare_chance_at_max_escalation * escalation)
        {
            flare_active = true;
            flare_life = 0;
            if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 4 + escalation * 4);
            }
        }
        flare_timer = irandom_range(60, 140);
    }
}
if (flare_active)
{
    flare_life += 1;
    if (flare_life >= flare_duration)
    {
        flare_active = false;
    }
}

if (instance_exists(oPlayer)) {
    var _pd = point_distance(x, y, oPlayer.x, oPlayer.y);
    proximity_factor = clamp(1 - (_pd / 250), 0, 1);
} else {
    proximity_factor = 0;
}

var _rev = (oAvoidanceController.bh_scene_reverse > 0) ? -1 : 1;

feed_charge = max(0, feed_charge - 0.018);
feed_flash = max(0, feed_flash - 0.1);
invert_shock = max(0, invert_shock - 0.05);

breath_timer += 1 * _rev;
var _breath_cycle = 80;
if (breath_timer >= _breath_cycle) breath_timer = 0;
if (breath_timer < 0) breath_timer = _breath_cycle - 1;
var _breath_progress = breath_timer / _breath_cycle;

if (_breath_progress < 0.15) {
    breath_scale = lerp(1, 0.85, _breath_progress / 0.15);
} else if (_breath_progress < 0.3) {
    var _bp = (_breath_progress - 0.15) / 0.15;
    breath_scale = lerp(0.85, 1.1, _bp);
} else {
    var _bp = (_breath_progress - 0.3) / 0.7;
    breath_scale = lerp(1.1, 1, _bp);
}

var _hb = oAvoidanceController.bh_heartbeat;
heartbeat_scale = 1 + _hb * (0.1 + oAvoidanceController.bh_phase_charge * 0.22) + feed_charge * 0.14;
breath_scale *= heartbeat_scale;

var _spin = (1 + oAvoidanceController.bh_phase_charge * 0.8 + feed_charge * 0.5) * _rev;
swirl_angle += 4 * _spin;
second_ring_angle += second_ring_speed * _spin;

disk_angle += disk_speed * (1 + escalation * 0.6) * _spin;
for (var i = 0; i < array_length(disk_clumps); i++) {
    disk_clumps[i].angle += disk_clumps[i].speed * (1 + escalation * 0.6) * _spin;
}

if (!despawning && _rev > 0 && random(1) < 0.12 + feed_charge * 0.5 + oAvoidanceController.bh_phase_charge * 0.2) {
    var _dc = disk_clumps[irandom(array_length(disk_clumps) - 1)];
    array_push(disk_sparks, {
        ang: _dc.angle + random_range(-14, 14),
        rad: lerp(disk_inner_radius, disk_outer_radius, _dc.radius_t),
        spin: _dc.speed * random_range(0.5, 1.1),
        out: random_range(0.6, 2.6) * (oAvoidanceController.blackhole_push_mode ? 1 : -0.55),
        life: irandom_range(16, 34), life_max: 34,
        size: random_range(1.2, 3.4)
    });
}
for (var i = array_length(disk_sparks) - 1; i >= 0; i--) {
    var _sp = disk_sparks[i];
    _sp.ang += _sp.spin * _rev;
    _sp.rad += _sp.out * _rev;
    _sp.life -= 1;
    if (_sp.life <= 0 || _sp.rad < core_radius * 0.4) array_delete(disk_sparks, i, 1);
}

var _jet_target = 0;
if (!despawning) {
    var _overload = max(escalation, oAvoidanceController.bh_phase_charge);
    _jet_target = max(0, (_overload - 0.45) / 0.55) * ring_radius * 1.6;
    if (oAvoidanceController.blackhole_push_mode) _jet_target = max(_jet_target, ring_radius * 2.6);
    _jet_target *= (1 + feed_charge * 0.5 + invert_shock * 1.2);
}
jet_length += (_jet_target - jet_length) * 0.08;
jet_angle += 0.25 * _rev;

var _field_target = oAvoidanceController.blackhole_push_mode ? 1 : -1;
field_line_curve += (_field_target - field_line_curve) * 0.06;

for (var i = 0; i < array_length(debris); i++) {
    debris[i].angle += debris[i].speed;
    debris[i].radius -= 0.3;
    if (debris[i].radius < core_radius * 0.5) {
        debris[i].radius = ring_radius * 0.9;
        debris[i].angle = random(360);
    }
}

var _streak_spiral = sign(disk_speed) * 0.4;
var _push_mode = oAvoidanceController.blackhole_push_mode;
var _streak_dir = (_push_mode ? 1 : -1) * _rev;
for (var i = 0; i < array_length(matter_streaks); i++) {
    matter_streaks[i].dist += _streak_dir * matter_streaks[i].speed * (1 + escalation * 0.5 + feed_charge * 1.2);
    matter_streaks[i].angle += _streak_spiral * _rev;

    if (!_push_mode && matter_streaks[i].dist <= disk_outer_radius) {
        matter_streaks[i].dist = random_range(disk_outer_radius * 1.2, disk_outer_radius * 2.5);
        matter_streaks[i].angle = random(360);
    }
    else if (_push_mode && matter_streaks[i].dist >= disk_outer_radius * 2.5) {
        matter_streaks[i].dist = random_range(disk_inner_radius, disk_outer_radius * 0.9);
        matter_streaks[i].angle = random(360);
    }
}

if (!oAvoidanceController.bullets_rewinding && !despawning)
{
    wobble_timer -= 1;
    if (wobble_timer <= 0)
    {
        orbit_speed += random_range(-0.15, 0.15);
        orbit_speed = clamp(orbit_speed, -1.4, 1.4);
        orbit_radius += random_range(-25, 25);
        orbit_radius_y += random_range(-10, 10);
        orbit_radius = clamp(orbit_radius, oAvoidanceController._k_bh_orbit_rx_min, oAvoidanceController._k_bh_orbit_rx_max);
        orbit_radius_y = clamp(orbit_radius_y, oAvoidanceController._k_bh_orbit_ry_min, oAvoidanceController._k_bh_orbit_ry_max);
        wobble_timer = irandom_range(30, 60);
    }
    orbit_angle += orbit_speed;

    var _force_x = 0, _force_y = 0;
    var _interact_range = 180;
    var _close_range = 60;
    with (oBlackHole)
    {
        if (id != other.id)
        {
            var _d = point_distance(other.x, other.y, x, y);
            if (_d < _interact_range && _d > 1)
            {
                var _dir, _strength;
                if (_d < _close_range) {
                    _dir = point_direction(x, y, other.x, other.y);
                    _strength = (1 - _d / _close_range) * 1.2;
                } else {
                    _dir = point_direction(other.x, other.y, x, y);
                    _strength = (1 - _d / _interact_range) * 0.4;
                }
                _force_x += lengthdir_x(_strength, _dir);
                _force_y += lengthdir_y(_strength, _dir);
            }
        }
    }
    interaction_offset_x = (interaction_offset_x + _force_x) * 0.9;
    interaction_offset_y = (interaction_offset_y + _force_y) * 0.9;

    var _orbit_x = orbit_cx + lengthdir_x(orbit_radius, orbit_angle);
    var _orbit_y = orbit_cy + lengthdir_y(orbit_radius_y, orbit_angle);
    var _next_x = _orbit_x + interaction_offset_x;
    var _next_y = _orbit_y + interaction_offset_y;

    if (instance_exists(oPlayer)) {
        var _safe_dist = oAvoidanceController._k_bh_spawn_player_safe_dist;
        var _pd_safe = point_distance(_next_x, _next_y, oPlayer.x, oPlayer.y);
        if (_pd_safe < _safe_dist && _pd_safe > 1) {
            var _away = point_direction(oPlayer.x, oPlayer.y, _next_x, _next_y);
            var _push = (_safe_dist - _pd_safe) * 0.06;
            interaction_offset_x += lengthdir_x(_push, _away);
            interaction_offset_y += lengthdir_y(_push, _away) * 0.4;
            _next_x += lengthdir_x(_push, _away);
            _next_y += lengthdir_y(_push, _away) * 0.4;
        }
    }

    x = clamp(_next_x, oAvoidanceController._k_bh_spawn_min_x, oAvoidanceController._k_bh_spawn_max_x);
    y = clamp(_next_y, oAvoidanceController._k_bh_orbit_min_y, oAvoidanceController._k_bh_orbit_max_y);
}

if (spawn_timer >= spawn_duration && !despawning)
{
    storm_timer -= 1;
    if (storm_timer <= 0)
    {
        var _menace = max(escalation, oAvoidanceController.bh_phase_charge);
        var _count = irandom_range(1, 2) + (feed_charge > 0.4 ? 1 : 0) + (_menace > 0.8 ? 1 : 0);
        for (var i = 0; i < _count; i++)
        {
            var _start_ang = random(360);
            var _arc_span = random_range(40, 100);
            var _end_ang  = _start_ang + choose(-1, 1) * _arc_span;
            var _r = random_range(ring_radius * 1.1, ring_radius * 1.6);
            array_push(storm_bolts, [_start_ang, _end_ang, _r, 10, 10]);
        }
        storm_timer = max(irandom_range(8, 20) - round(_menace * 11), 2);
    }
}
for (var i = array_length(storm_bolts) - 1; i >= 0; i--)
{
    storm_bolts[i][3] -= 1;
    if (storm_bolts[i][3] <= 0) array_delete(storm_bolts, i, 1);
}

if (spawn_timer >= spawn_duration && !despawning)
{
    var _hb_now = oAvoidanceController.bh_heartbeat;
    if (_hb_now > prev_heartbeat + 0.04)
    {
        array_push(pulse_waves, [0, 0.7 + _hb_now * 0.5]);
        scr_impact_pulse(0.12 + _hb_now * 0.16, 0.8 + _hb_now * 0.9, 0.15 + _hb_now * 0.3, x, y);
        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 2 + _hb_now * 4);
        }
    }
    prev_heartbeat = _hb_now;
}
for (var i = array_length(pulse_waves) - 1; i >= 0; i--)
{
    pulse_waves[i][0] += 4 * (1 + oAvoidanceController.bh_phase_charge * 0.6);
    pulse_waves[i][1] -= 0.04;
    if (pulse_waves[i][1] <= 0)
    {
        array_delete(pulse_waves, i, 1);
    }
}

if (despawning)
{
    despawn_timer += 1;
    var _p2 = clamp(despawn_timer / despawn_duration, 0, 1);
    var _despawn_screen_dim = oAvoidanceController._k_bh_despawn_screen_mult;

    if (_p2 < 0.55)
    {
        var _p1 = _p2 / 0.55;
        despawn_scale = lerp(1, oAvoidanceController._k_bh_despawn_swell_scale, 1 - power(1 - _p1, 2));

        oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, (0.25 + _p1 * 0.18) * _despawn_screen_dim);
        oAvoidanceController.bloom_pulse = max(oAvoidanceController.bloom_pulse, _p1 * 0.12 * _despawn_screen_dim);
    }
    else
    {
        var _p3 = (_p2 - 0.55) / 0.45;
        despawn_scale = lerp(oAvoidanceController._k_bh_despawn_swell_scale, 0, _p3 * _p3 * _p3);

        oAvoidanceController.vignette_pulse = max(oAvoidanceController.vignette_pulse, (0.32 + _p3 * 0.22) * _despawn_screen_dim);
        oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, (0.14 + _p3 * 0.22) * _despawn_screen_dim);
        oAvoidanceController.tear_amount = max(oAvoidanceController.tear_amount, _p3 * 0.28 * _despawn_screen_dim);
        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 3 + _p3 * 8);
        }

        if (random(1) < _p3 * 0.5) {
            array_push(oAvoidanceController.bh_horizon_cracks, {
                x : x, y : y,
                ang : random(360),
                len : random_range(30, 40 + _p3 * 90),
                life : 18, life_max : 18,
                seed : random(1000)
            });
        }
    }

    if (_p2 >= 0.97 && !exploded)
    {
        exploded = true;
        scr_blackhole_explode();
    }
}

var _scale = spawn_scale * despawn_scale * breath_scale;
var _light_col = oAvoidanceController.blackhole_push_mode
                 ? merge_color(global.lightning_color, c_white, 0.85)
                 : global.lightning_color;
var _light_pow = 10 * _scale
               * (1 + feed_charge * 0.8 + invert_shock * 1.5)
               * (oAvoidanceController.blackhole_push_mode ? 1.9 : 1)
               * (despawning ? oAvoidanceController._k_bh_despawn_draw_mult : 1);
scr_add_light(x, y, _light_col, _light_pow);
