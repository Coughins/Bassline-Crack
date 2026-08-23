core_radius = 14;
ring_radius = 60;
swirl_angle = 0;

core_color_blend = 0;

pull_radius = 220;
pull_strength = 0.15;

orbit_cx = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_cx : room_width / 2;
orbit_cy = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_cy : room_height * 0.26;
var _spawn_rx = abs(x - orbit_cx);
var _spawn_ry = abs(y - orbit_cy);
var _rx_min = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_rx_min : 130;
var _rx_max = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_rx_max : 270;
var _ry_min = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_ry_min : 36;
var _ry_max = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_orbit_ry_max : 82;
orbit_radius = clamp(_spawn_rx, _rx_min, _rx_max);
orbit_radius_y = clamp(_spawn_ry, _ry_min, _ry_max);
orbit_angle = point_direction(orbit_cx, orbit_cy, x, y);
orbit_speed = choose(-1, 1) * random_range(0.5, 1.1);
wobble_timer = irandom_range(30, 60);
interaction_offset_x = 0;
interaction_offset_y = 0;

spawn_timer = 0;
spawn_duration = 20;
spawn_scale = 0;

despawning = false;
despawn_timer = 0;
despawn_duration = 69;
despawn_scale = 1;
exploded = false;

pulse_timer = 0;
pulse_interval = 20;
pulse_waves = [];
prev_heartbeat = 0;

storm_bolts = [];
storm_timer = irandom_range(5, 15);

second_ring_angle = 0;
second_ring_radius = ring_radius * 0.55;
second_ring_speed = -10;

debris = [];
var _debris_count = 6;
for (var i = 0; i < _debris_count; i++) {
    array_push(debris, {
        angle: random(360),
        radius: random_range(ring_radius * 0.3, ring_radius * 0.9),
        speed: choose(-1, 1) * random_range(2, 5),
        size: random_range(2, 5)
    });
}

breath_timer = 0;
breath_scale = 1;
proximity_factor = 0;

disk_inner_radius = core_radius * 1.8;
disk_outer_radius = ring_radius * 1.15;
disk_squash = 0.35;
disk_angle = 0;
disk_speed = 6;
disk_band_count = 5;

disk_clumps = [];
var _clump_count = 4;
for (var i = 0; i < _clump_count; i++) {
    array_push(disk_clumps, {
        angle: random(360),
        speed: choose(-1, 1) * random_range(3, 7),
        width: random_range(20, 45),
        radius_t: random_range(0.2, 0.8)
    });
}

matter_streaks = [];
var _streak_count = 8;
for (var i = 0; i < _streak_count; i++) {
    array_push(matter_streaks, {
        angle: random(360),
        dist: random_range(disk_outer_radius * 1.2, disk_outer_radius * 2.5),
        speed: random_range(1.5, 3.5),
        length: random_range(8, 20)
    });
}

shimmer_amplitude = 2;
shimmer_speed = 3;
shimmer_segments = 24;
shimmer_seed = random(1000);

age_timer = 0;
escalation = 0;
escalation_ramp_time = 300;

field_line_count = 8;
field_lines = [];
for (var i = 0; i < field_line_count; i++) {
    array_push(field_lines, {
        angle: (360 / field_line_count) * i + random_range(-10, 10),
        length_mult: random_range(0.8, 1.3)
    });
}
field_line_curve = 0;

flare_timer = irandom_range(60, 140);
flare_active = false;
flare_life = 0;
flare_duration = 18;
flare_chance_at_max_escalation = 0.35;


feed_charge = 0;
feed_flash = 0;
feed_streak_angle = 0;
swallow_count = 0;

inverted_at = -1;
invert_shock = 0;

heartbeat_scale = 1;

disk_sparks = [];

jet_length = 0;
jet_angle = random(360);
