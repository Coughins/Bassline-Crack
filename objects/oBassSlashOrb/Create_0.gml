phase = "materialize";

alpha = 0;
scale = 0;

_k_materialize_x = room_width / 2;
_k_materialize_y = room_height / 2;


_k_windup_depart_dir = 180;
_k_windup_depart_dist = 650;
_k_windup_ease_power = 3; 

_k_windup_hold_x = -150;
_k_windup_hold_y = 700;

_k_windup_p0_x = _k_materialize_x;
_k_windup_p0_y = _k_materialize_y;
_k_windup_p1_x = _k_materialize_x + lengthdir_x(_k_windup_depart_dist, _k_windup_depart_dir);
_k_windup_p1_y = _k_materialize_y + lengthdir_y(_k_windup_depart_dist, _k_windup_depart_dir);
_k_windup_p2_x = _k_windup_hold_x;
_k_windup_p2_y = _k_windup_hold_y;

_k_swing_distance = 1000;
var _slash_dir_x = room_width;
var _slash_dir_y = -room_height;
var _slash_dir_len = point_distance(0, 0, _slash_dir_x, _slash_dir_y);
_k_swing_end_x = _k_windup_hold_x + (_slash_dir_x / _slash_dir_len) * _k_swing_distance;
_k_swing_end_y = _k_windup_hold_y + (_slash_dir_y / _slash_dir_len) * _k_swing_distance;

_k_coil_creep_dist = 50;
var _coil_dir = point_direction(_k_windup_hold_x, _k_windup_hold_y, _k_swing_end_x, _k_swing_end_y);
_k_swing_launch_x = _k_windup_hold_x + lengthdir_x(_k_coil_creep_dist, _coil_dir);
_k_swing_launch_y = _k_windup_hold_y + lengthdir_y(_k_coil_creep_dist, _coil_dir);

_k_t_materialize_start = 1283;
_k_t_windup_start = 1288;
_k_t_coil_start = 1330;
_k_t_swing_start = 1352;
_k_t_swing_end = 1364;

with (oCameraController)
{
    slash_zoom_active = true;
    slash_zoom_phase = "out";
    slash_zoom_timer = 0;
    slash_zoom_from = zoom;
    slash_zoom_to = _k_slash_zoom_target;
}

_k_materialize_spark_count = 16;
_k_materialize_spark_speed_min = 3;
_k_materialize_spark_speed_max = 7;
_k_materialize_spark_fade = 0.04;
_k_materialize_ring_speed = 6;
_k_materialize_ring_fade = 0.035;
_k_orb_glow_color = [1.0, 0.25, 0.2];

materialize_rings = [{ radius: 0, alpha: 1 }];
materialize_sparks = [];
for (var i = 0; i < _k_materialize_spark_count; i++)
{
    var _ang = (360 / _k_materialize_spark_count) * i + random_range(-10, 10);
    var _spd = random_range(_k_materialize_spark_speed_min, _k_materialize_spark_speed_max);
    array_push(materialize_sparks, {
        x: _k_materialize_x,
        y: _k_materialize_y,
        vx: lengthdir_x(_spd, _ang),
        vy: lengthdir_y(_spd, _ang),
        alpha: 1
    });
}

trail_positions = [];
_k_trail_max_normal = 10;
_k_trail_max_swing = 26;

_k_coil_ring_radius_start = 75;
_k_coil_ring_radius_end = 38;

_k_coil_arc_count = 5;
_k_coil_arc_outer_radius = 130;
_k_coil_arc_regen_frames = 5;
coil_arc_regen_timer = 0;
coil_arcs = [];

_k_coil_mote_count = 20;
_k_coil_mote_radius_max = 170;
_k_coil_mote_pull_speed_min = 2.5;
_k_coil_mote_pull_speed_max = 5;
coil_motes = [];
for (var i = 0; i < _k_coil_mote_count; i++)
{
    array_push(coil_motes, {
        ang: random(360),
        radius: random_range(50, _k_coil_mote_radius_max),
        speed: random_range(_k_coil_mote_pull_speed_min, _k_coil_mote_pull_speed_max)
    });
}

_k_coil_pulse_interval = 7;
_k_coil_pulse_speed = 5;
_k_coil_pulse_fade = 0.05;
coil_pulse_timer = 0;
coil_pulses = [];

_k_swing_lookahead_mult = 1.4;
_k_swing_tail_mult = 3.2;
swing_launch_done = false;

_k_t_impact_end = _k_t_swing_end + 10;
impact_done = false;
impact_x = 0;
impact_y = 0;

_k_windup_arc_count = 3;
_k_windup_arc_regen_frames = 4;
_k_windup_arc_reach = 55;
windup_arc_regen_timer = 0;
windup_arcs = [];

_k_windup_orbit_count = 3;
_k_windup_orbit_radius = 26;
_k_windup_orbit_speed = 14;
windup_orbit_motes = [];
for (var i = 0; i < _k_windup_orbit_count; i++)
{
    array_push(windup_orbit_motes, { ang: (360 / _k_windup_orbit_count) * i });
}

_k_ember_chance = 0.6;
orb_embers = [];

_k_impact_arc_count = 8;
_k_impact_arc_reach = 190;
impact_arcs = [];

_k_windup_afterglow_points = 36;
_k_windup_afterglow_fade = 0.006;
windup_afterglow_points = [];
for (var i = 0; i <= _k_windup_afterglow_points; i++)
{
    var _pt = i / _k_windup_afterglow_points;
    var _inv = 1 - _pt;
    array_push(windup_afterglow_points, {
        t: _pt,
        x: (_inv * _inv) * _k_windup_p0_x + 2 * _inv * _pt * _k_windup_p1_x + (_pt * _pt) * _k_windup_p2_x,
        y: (_inv * _inv) * _k_windup_p0_y + 2 * _inv * _pt * _k_windup_p1_y + (_pt * _pt) * _k_windup_p2_y,
        revealed: false,
        alpha: 0
    });
}

_k_coil_leak_chance = 0.05;
_k_coil_leak_reach = 220;
_k_coil_leak_max = 2;
coil_leak_arcs = [];

_k_swing_afterimage_interval = 3;
swing_afterimages = [];
swing_afterimage_timer = 0;


_k_shell_ring_count = 3;
_k_shell_base_radius = 34;
_k_shell_radius_step = 19;
_k_shell_crush = 0.34;
shell_rings = [];
for (var i = 0; i < _k_shell_ring_count; i++)
{
    array_push(shell_rings, {
        sides: 6 + i * 2,
        radius: _k_shell_base_radius + i * _k_shell_radius_step,
        rot: random(360),
        rot_speed: (i mod 2 == 0 ? 1 : -1) * (0.9 + i * 0.5),
        assemble: 0
    });
}
shell_shatter_done = false;
shell_shards = [];

_k_satellite_count = 3;
_k_satellite_orbit_radius = 96;
_k_satellite_orbit_speed = 2.6;
satellites = [];
for (var i = 0; i < _k_satellite_count; i++)
{
    array_push(satellites, {
        ang: (360 / _k_satellite_count) * i,
        radius: _k_satellite_orbit_radius,
        alive: true,
        consume_flash: 0,
        spin: random(360)
    });
}
satellites_consumed = 0;

core_charge = 0;
core_flash = 0;
_k_core_vibrate_max = 4;

_k_lens_radius_px = 210;
_k_lens_strength_max = 0.42;

orb_shocks = [];

_k_ribbon_width_head = 30;
_k_ribbon_width_tail = 2;
_k_ribbon_fringe = 4.5;

_k_orb_bolt_life = 6;