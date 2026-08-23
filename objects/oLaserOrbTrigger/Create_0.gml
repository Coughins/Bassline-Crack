_k_speed = 11;
_k_direction = 270;
_k_orb_check_width = 20;
_k_beam_half_length = 450;

_k_orb_sweep_step = 12;
_k_orb_sweep_max  = 14;

apply_gravity_on_pop = false;
gravity_dir_to_apply = 0;
_k_gravity_strength = 1;

move_dir = _k_direction;
move_speed = _k_speed;

image_angle = 90;

beam_col_core     = c_white;
beam_col_inner    = global.avoid_col_cyan_soft;
beam_col_outer    = global.avoid_col_cyan;
beam_col_fringe_a = global.avoid_col_cyan;
beam_col_fringe_b = global.avoid_col_violet;
beam_col_spark    = global.avoid_col_cyan_soft;

beam_set_palette_red = function() {
    beam_col_core     = c_white;
    beam_col_inner    = global.avoid_col_hot;
    beam_col_outer    = global.avoid_col_danger;
    beam_col_fringe_a = global.avoid_col_warning;
    beam_col_fringe_b = global.avoid_col_ember;
    beam_col_spark    = global.avoid_col_hot;
};

_k_beam_draw_half = 600;
_k_beam_taper     = 0.10;
_k_beam_segs      = 90;
_k_beam_fil_segs  = 96;

_k_beam_w_bloom = 38;
_k_beam_w_halo  = 18;
_k_beam_w_glow  = 7;
_k_beam_w_core  = 2.2;

_k_beam_a_bloom = 0.09;
_k_beam_a_halo  = 0.2;
_k_beam_a_glow  = 0.34;
_k_beam_a_core  = 1.0;

_k_beam_ripple_freq  = 3.0;
_k_beam_ripple_speed = 22;
_k_beam_ripple_depth = 0.55;

_k_beam_filaments = 2;
_k_beam_fil_frac  = 0.75;
_k_beam_fil_wave  = 190;
_k_beam_fil_spin  = 6.5;
_k_beam_fil_w     = 1.7;

_k_beam_packet_gap   = 240;
_k_beam_packet_speed = 26;
_k_beam_packet_len   = 110;
_k_beam_packet_a     = 0.7;
_k_beam_tick_a       = 0.3;

_k_beam_lead_squash  = 0.5;
_k_beam_wake_stretch = 1.7;
_k_beam_rim_a        = 0.55;

_k_beam_trail_len = 10;

_k_beam_blade_arc = 26;
_k_beam_trail_a   = 0.2;

_k_beam_arc_chance = 0.5;
_k_beam_arc_life   = 5;
_k_beam_arc_reach  = 46;
_k_beam_arc_max    = 12;
beam_arcs = [];

_k_beam_ignite_frames = 7;
beam_born = 0;

beam_phase = 0;
beam_seed  = random(360);

_k_beam_split = 3.0;

_k_beam_gain  = 1.0;
beam_paired_center = false;

_k_beam_light_samples = 4;
_k_beam_light_power   = 1.6;

trail_positions = [];

is_rotating = false;
rotate_speed = 0;

muzzle_flash_timer = 0;
_k_muzzle_flash_duration = 8;
_k_muzzle_flash_peak_radius = 40;
_k_muzzle_flash_color = c_white;

beam_heat = 0;
_k_beam_heat_per_kill = 0.45;
_k_beam_heat_decay = 0.055;
_k_beam_heat_max = 2.2;
kill_count = 0;

_k_cut_spark_rate = 0.55;
_k_cut_spark_spread = 0.9;

exit_done = false;
_k_exit_margin = 40;

_k_fringe_offset = 2.6;

motion_speed = 0;
motion_dir   = 0;
trail_angles = [];
_k_blade_trail_len = 10;
_k_blade_ghost_step = 2;

extend = 1;
beam_draw_soft_bar = function(_x1, _y1, _x2, _y2, _w, _col, _a) {
    if (_a <= 0.004 || _w <= 0.05) return;
    var _pd = point_direction(_x1, _y1, _x2, _y2) + 90;
    var _ex = lengthdir_x(_w, _pd);
    var _ey = lengthdir_y(_w, _pd);
    for (var _s = -1; _s <= 1; _s += 2) {
        draw_primitive_begin(pr_trianglestrip);
        draw_vertex_colour(_x1, _y1, _col, _a);
        draw_vertex_colour(_x1 + _ex * _s, _y1 + _ey * _s, _col, 0);
        draw_vertex_colour(_x2, _y2, _col, _a);
        draw_vertex_colour(_x2 + _ex * _s, _y2 + _ey * _s, _col, 0);
        draw_primitive_end();
    }
};
