
if (!variable_global_exists("debug_restart_t")) global.debug_restart_t = 0;

if (!variable_global_exists("debug_music_instance")) global.debug_music_instance = -4;

t = global.debug_restart_t;
attack_timer = 0;
music_offset = 0;
avoidance_run_stopped = false;
avoidance_music_cut = false;
audio_sync_tolerance_frames = 5;
audio_sync_stall_delta_frames = 60;

hit_count = 0;
practice_hud_timer = 0;

_radius = 0;
ang = 0;
dir = 0;
hot = 0;
life = 0;
max_life = 0;
off = 0;
offset = 0;
shockwave_alpha = 0;
shockwave_max_radius = 0;
shockwave_radius = 0;
speed = 0;

if (audio_exists(global.debug_music_instance) && audio_is_playing(global.debug_music_instance)) {
  audio_stop_sound(global.debug_music_instance);
}

audio_stop_all();

music_instance = audio_play_sound(sBasslineCrack, 1, false);
global.debug_music_instance = music_instance;

function avoidance_stop_for_death() {
  avoidance_run_stopped = true;
  last_t = t;

  if (avoidance_music_cut) return;
  avoidance_music_cut = true;

  if (audio_exists(music_instance) && audio_is_playing(music_instance)) {
    audio_sound_gain(music_instance, 0, 0);
    audio_stop_sound(music_instance);
  }
  if (audio_exists(global.debug_music_instance) && audio_is_playing(global.debug_music_instance)) {
    audio_sound_gain(global.debug_music_instance, 0, 0);
    audio_stop_sound(global.debug_music_instance);
  }
}

last_t = 0;

var music_time = audio_sound_get_track_position(global.debug_music_instance);
audio_sync_prev_music_t = floor(music_time * room_speed);

if (instance_exists(oPlayer) && oPlayer.dead) {
  instance_destroy(oPlayer);
}
if (instance_exists(oGameover))    instance_destroy(oGameover);
if (instance_exists(oBloodEmitter)) instance_destroy(oBloodEmitter);
if (instance_exists(oPlayerDeath)) instance_destroy(oPlayerDeath);

if (instance_exists(oPlayer)) {
  with(oPlayer) {
    x = room_width / 2;
    y = 567;
  }
} else {
  player_spawn(room_width / 2, 567);
}

player_set_stopped(false);

if (instance_exists(oPlayer)) {
  savedata_save_player();
}

scr_glow_init();

bassline_text_points = [];
bass_text_crack_flash = 0;
bass_text_cracks = [];
bass_text_particles = [];
bass_text_rings = [];
bass_text_splatter = [];
bass_text_tears = [];
bass_text_crack_embers = [];
slash_seam_embers = [];

bassline_text_created = false;
bassline_text_exploding = false;

_k_bass_text_cut_t = 1364;
_k_bass_text_detonate_t = 1367;

bass_text_heat = 0;
bass_text_core_charge = 0;
bass_text_freeze = 0;
bass_text_arcs = [];
bass_text_arc_timer = 0;
bass_text_arc_id_counter = 0;
bass_text_seams = [];
bass_text_shards = [];
bass_text_scar = [];
bass_text_word_cx = room_width / 2;
bass_text_word_cy = room_height / 2;
bass_text_word_w = 1;
bass_text_word_h = 1;
bass_text_pulse_timer = 0;
bass_text_pulse_index = 0;

_k_bass_text_arc_interval_far = 10;
_k_bass_text_arc_interval_near = 2;
_k_bass_text_arc_count = 3;
_k_bass_text_arc_life = 7;
_k_bass_text_seam_count = 8;
_k_bass_text_seam_start_t = 1338;
_k_bass_text_scar_fade = 0.0045;
_k_bass_text_pulse_interval_far = 24;
_k_bass_text_pulse_interval_near = 5;
_k_bass_text_chroma_max = 5;

bass_text_leaks = [];
_k_bass_text_leak_chance = 0.16;
_k_bass_text_leak_max = 3;
_k_bass_text_leak_reach = 190;

slash_bolts = [];
_k_slash_bolt_max = 40;

slash_warps = [];
_k_slash_warp_max = 4;

slash_lens_x = 0;
slash_lens_y = 0;
slash_lens_radius = 0;
slash_lens_strength = 0;

_k_containment_shield_break_t = 1365;
_k_containment_shield_break_life = 92;
_k_containment_shield_cut_life = 24;
containment_shield_destroyed = false;
containment_shield_break_timer = 0;
containment_shield_flash = 0;
containment_shield_shards = [];
containment_shield_fractures = [];
containment_shield_ensure_side_blocks = function() {
  with (oBlock) {
    var _is_side_wall = (abs(y) < 0.1 && image_yscale >= 17 && image_xscale <= 1.5);
    var _is_room_side =
      abs(x + 32) < 0.1 ||
      abs(x) < 0.1 ||
      abs(x - 768) < 0.1 ||
      abs(x - room_width) < 0.1;
    if (_is_side_wall && _is_room_side) instance_destroy();
  }

  var _left_wall = instance_create_layer(-32, 0, "Instances", oBlock);
  with (_left_wall) {
    image_xscale = 1;
    image_yscale = 18;
  }

  var _right_wall = instance_create_layer(room_width, 0, "Instances", oBlock);
  with (_right_wall) {
    image_xscale = 1;
    image_yscale = 18;
  }
};

global.avoid_col_blood       = make_color_rgb(96, 8, 18);
global.avoid_col_danger      = make_color_rgb(255, 42, 38);
global.avoid_col_warning     = make_color_rgb(255, 46, 72);
global.avoid_col_ember       = make_color_rgb(255, 84, 28);
global.avoid_col_hot         = make_color_rgb(255, 216, 184);
global.avoid_col_cyan        = make_color_rgb(72, 214, 255);
global.avoid_col_cyan_soft   = make_color_rgb(132, 232, 255);
global.avoid_col_violet      = make_color_rgb(162, 72, 255);
global.avoid_col_armor_dark  = make_color_rgb(7, 12, 26);
global.avoid_col_armor_mid   = make_color_rgb(21, 34, 54);
global.avoid_col_armor_edge  = make_color_rgb(112, 198, 226);

global.lightning_color = global.avoid_col_cyan;

lightning_bloom_boost = 0;
lightning_imprints = [];

converge_motes = [];

intro_cx = room_width / 2;
intro_cy = room_height / 2;

intro_ring_bullets = [];
intro_x_bullets = [];


shapes_telegraphs = [];
shapes_arcs = [];
shapes_ghosts = [];
shapes_arc_id = 0;

shapes_heartbeat = 0;
shapes_heartbeat_phase = 0;
shapes_coil = 0;
shapes_core_charge = 0;
shapes_core_flash = 0;
shapes_chroma = 0;
shapes_radius_pump = 0;
shapes_radius_pump_vel = 0;
shapes_wound = 0;
shapes_rot_speed = 0;
shapes_launch_flash = 0;

_k_shapes_window_start = 276;
_k_shapes_window_end = 420;
_k_shapes_lands = [ 292, 314, 333 ];
_k_shapes_releases = [ 367, 377 ];
_k_shapes_telegraph_lead = 10;
_k_shapes_coil_leads = [ 12, 10 ];
_k_shapes_contract = 30;
_k_shapes_arc_life = 9;
_k_shapes_arc_segments = 5;
_k_shapes_arc_jitter = 5;
_k_shapes_ghost_interval = 2;

shapes_snapshot = function(_include_ring, _include_x, _alpha, _hot, _width) {
  if (_include_ring) {
    for (var s = 0; s < 2; s++) {
      var _pts = [];

      for (var i = 0; i < array_length(intro_ring_bullets); i++) {
        var _b = intro_ring_bullets[i];
        if (!instance_exists(_b) || !_b.revealed || _b.shape_id != s) continue;
        array_push(_pts, {x : _b.x, y : _b.y});
      }

      if (array_length(_pts) > 2) {
        array_push(shapes_ghosts, {pts : _pts, alpha : _alpha, hot : _hot, closed : true, width : _width});
      }
    }
  }

  if (_include_x) {
    for (var d = 0; d < 4; d++) {
      var _apts = [ {x : intro_cx, y : intro_cy} ];

      for (var i = 0; i < array_length(intro_x_bullets); i++) {
        var _b = intro_x_bullets[i];
        if (!instance_exists(_b) || !_b.revealed || _b.trace_group != d) continue;
        array_push(_apts, {x : _b.x, y : _b.y});
      }

      if (array_length(_apts) > 1) {
        array_push(shapes_ghosts, {pts : _apts, alpha : _alpha, hot : _hot, closed : false, width : _width});
      }
    }
  }
};

shapes_land_payoff = function(_index, _radius) {
  var _ramp = _index / 2;

  shapes_wound = (_index + 1) / 3;
  shapes_radius_pump_vel += 6 + _ramp * 5;
  shapes_core_flash = max(shapes_core_flash, 14 + _ramp * 10);
  shapes_launch_flash = max(shapes_launch_flash, 0.35 + _ramp * 0.25);
  shapes_chroma = 1;

  var _sw_life = 26 + round(_ramp * 8);
  array_push(ring_shockwaves, {
    x : intro_cx,
    y : intro_cy,
    radius : 8,
    max_radius : _radius * (1.7 + _ramp * 0.5),
    life : _sw_life,
    max_life : _sw_life,
    width : 14 + _ramp * 8,
    hot : 0.55 + _ramp * 0.35,
    vs : 1
  });

  array_push(ring_bursts, {
    x : intro_cx,
    y : intro_cy,
    tier : 2,
    color : merge_color(global.lightning_color, c_white, 0.35 + _ramp * 0.3),
    num : 6,
    offset : random(360),
    life : 28,
    shockwave_radius : 0,
    shockwave_max_radius : 200 + _ramp * 90,
    shockwave_alpha : 1.0 + _ramp * 0.4,
    shockwave_alpha_start : 1.0 + _ramp * 0.4
  });

  for (var p = 0; p < 18 + round(_ramp * 14); p++) {
    var _pa = random(360);
    var _ps = random_range(2.5, 7 + _ramp * 3);
    array_push(arrow_ring_particles, {
      x : intro_cx + lengthdir_x(_radius * random_range(0.5, 1), _pa),
      y : intro_cy + lengthdir_y(_radius * random_range(0.5, 1), _pa),
      vx : lengthdir_x(_ps, _pa),
      vy : lengthdir_y(_ps, _pa),
      life : 20,
      max_life : 20,
      size : random_range(0.12, 0.3),
      grav : 0.03,
      drag : 0.95,
      hot : 0.55 + _ramp * 0.4
    });
  }

  for (var sIdx = 0; sIdx < 14 + round(_ramp * 12); sIdx++) {
    array_push(ring_streaks, {
      cx : intro_cx,
      cy : intro_cy,
      vs : 1,
      ang : random(360),
      dist : _radius * random_range(0.55, 0.95),
      len : 22 + irandom(20) + _ramp * 12,
      speed : 13 + _ramp * 6,
      width : 1.5 + random(2),
      life : 13,
      max_life : 13,
      hot : 0.5 + _ramp * 0.4
    });
  }
};


fan_clockwise = true;

crosshair_release_flash_timer = 0;
crosshair_release_x = 0;
crosshair_release_y = 0;
crosshair_release_flash_scale = 1;

t377_flash_timer = 0;

impact_wave_radius = -1;
impact_wave_color = c_white;
impact_wave_speed = 0.12;


arrow_arc_from_left = true;

arrow_arc_orbs = [];
arrow_arc_wave_index = 0;
arrow_arc_lasers = [];
salvo_lightning_arcs = [];

salvo_lightning_arcs = [];
salvo_arc_id_counter = 0;

_k_arc_count_per_salvo = 3;
_k_arc_life = 10;
_k_arc_segments = 6;
_k_arc_jitter = 6;


_k_arc_rift_t       = 5960;
_k_arc_waves        = [ 5974, 6004, 6033, 6063, 6090 ];
_k_arc_lock_t       = 6114;
_k_arc_fire_t       = 6134;
_k_orb_beats        = [ 6134, 6156, 6175, 6195, 6215, 6235, 6255, 6275 ];
_k_orb_split_beats  = [ 6303, 6332, 6363, 6384, 6414, 6445 ];
_k_orb_ring_beats   = [ 6466, 6482, 6499, 6513, 6528, 6536 ];
_k_orb_unwrap_start = 6547;
_k_orb_unwrap_end   = 6600;
_k_arc_window_end   = 6640;

_k_arc_left_x   = 0;
_k_arc_right_x  = room_width;
_k_arc_top_y    = 50;
_k_arc_bottom_y = 150;
_k_arc_count    = 4;

// ============================================================================
// THE ARC — READ THE BLADES. 
// ============================================================================
_k_arc_aim_spread_min = 15;   
_k_arc_aim_spread_max = 40;   
_k_arc_jitter_x       = 30;
_k_arc_read_y0        = 400;
_k_arc_read_y1        = 585;
_k_arc_safe_half      = 52;   
_k_arc_aim_tries      = 28;
_k_arc_rail_full_at   = 0.80;

_k_arc_blade_len   = 34;
_k_arc_blade_half  = 13;
_k_arc_hang_min    = 34;
_k_arc_hang_max    = 78;
_k_arc_blade_r     = 15;

_k_arc_void_alpha_min = 0.35;
_k_arc_void_alpha_max = 0.92;
_k_arc_spill_depth    = 130;
_k_arc_fringe_px      = 2.6;

_k_arc_tick_step   = 46;
_k_arc_tick_len    = 13;
_k_arc_tick_scroll = 0.35;

_k_arc_lance_halo      = 1.5;
_k_arc_lance_hit_half  = 11;
_k_arc_lance_live      = 7;
_k_arc_lance_fade      = 20;

_k_arc_rift_kill_pad = 6;

arc_blades      = [];
arc_lances      = [];
arc_shards      = [];
arc_forge_pops  = [];
arc_vents       = [];
arc_safe_x      = 400;   
arc_reveal_flip = false;
arc_seed_salt   = 0;
arc_volley_hit  = false;
arc_ceiling_hit = false;
arc_ceiling_live = false;
arc_fire_ripple = 0;
arc_tear_spike = 0;

_k_arc_wave_shake     = [ 4, 6, 9, 13, 18 ];
_k_arc_wave_flash     = [ 0.06, 0.10, 0.15, 0.22, 0.32 ];
_k_arc_wave_zoom      = [ 0.015, 0.025, 0.04, 0.06, 0.09 ];
_k_arc_wave_sparks    = [ 8, 11, 15, 20, 27 ];
_k_arc_wave_embers    = [ 2, 3, 4, 6, 9 ];
_k_arc_wave_tilt      = [ 0.8, -1.1, 1.4, -1.8, 2.4 ];

_k_orb_beat_shake   = [ 6, 7, 8, 10, 12, 14, 17, 21 ];
_k_orb_beat_flash   = [ 0.18, 0.21, 0.25, 0.29, 0.34, 0.40, 0.47, 0.58 ];
_k_orb_beat_zoom    = [ 0.03, 0.035, 0.045, 0.055, 0.07, 0.085, 0.10, 0.14 ];
_k_orb_beat_arrows  = [ 8, 9, 10, 11, 12, 14, 16, 20 ];
_k_orb_beat_streaks = [ 12, 14, 17, 20, 24, 28, 34, 44 ];
_k_orb_beat_frames  = [ 12, 12, 11, 11, 10, 10, 9, 8 ];

_k_orb_split_shake = [ 9, 11, 13, 16, 20, 26 ];
_k_orb_split_flash = [ 0.26, 0.30, 0.35, 0.42, 0.50, 0.62 ];
_k_orb_split_zoom  = [ 0.05, 0.06, 0.075, 0.09, 0.11, 0.15 ];
_k_orb_split_tilt  = [ -1.4, 1.7, -2.1, 2.5, -3.0, 3.6 ];

_k_arc_color      = make_color_rgb(255, 46, 40);
_k_arc_hot_color  = make_color_rgb(255, 190, 150);
_k_arc_beam_len   = 1800;
_k_arc_laser_hit_half_width  = 9;
_k_arc_laser_warn_half_width = 18;
_k_arc_laser_strike_scale    = 2.7;
_k_arc_laser_shrink_step     = 0.27;

_k_arc_rift_segments = 22;
_k_arc_rift_lift     = 34;
_k_arc_weld_max      = 40;
_k_arc_stitch_max    = 24;
_k_orb_leak_max      = 26;
_k_orb_bridge_max    = 20;
_k_orb_ghost_max     = 48;

arc_rift = 0;
arc_rift_open = 0;
arc_rift_pts = [];
arc_rift_built = false;

arc_charge = 0;
arc_heartbeat = 0;
arc_heartbeat_phase = 0;
arc_wave_flash = 0;
arc_lock_flash = 0;
arc_fire_flash = 0;
arc_aim = 0;

arc_welds = [];
arc_stitch = [];
arc_muzzles = [];

orb_beat_index = 0;
orb_split_index = 0;
orb_ring_index = 0;
orb_heat = 0;
orb_beat_flash = 0;
orb_heartbeat = 0;
orb_heartbeat_phase = 0;

orb_leaks = [];
orb_ghosts = [];

orb_ring_lock = 0;

orb_unwrap_flash = 0;
orb_final_burst = 0;

// ============================================================================
// ============================================================================

_k_orb_split_lead = 16;
_k_orb_split_child_speed_cap = 7.0;

_k_orb_split_style = [
  { debris :  9, scar : 1, bridge : 3.6, aspect : 2.3, violet : 1, vent : 5, hold : 15 },
  { debris : 12, scar : 2, bridge : 3.0, aspect : 2.0, violet : 0, vent : 4, hold : 14 },
  { debris : 13, scar : 2, bridge : 2.6, aspect : 1.8, violet : 0, vent : 3, hold : 13 },
  { debris :  5, scar : 0, bridge : 1.5, aspect : 1.1, violet : 0, vent : 0, hold :  8 },
  { debris : 16, scar : 3, bridge : 3.2, aspect : 2.7, violet : 1, vent : 6, hold : 16 },
  { debris : 22, scar : 4, bridge : 2.0, aspect : 3.2, violet : 0, vent : 7, hold : 18 }
];

orb_split_axis  = [ 0, 0, 0, 0, 0, 0 ];
orb_plates      = [];
orb_scars       = [];
orb_bridges     = [];
orb_rails       = [];
orb_hub         = 0;
orb_hub_grow    = 0;
orb_latch       = 0;
orb_assembly_r  = 0;    // outermost armed rail radius, for the structure bracket
orb_next_x      = 400;
orb_next_y      = 180;
orb_feed        = 0;
orb_power       = 1;

_k_orb_plate_max  = 96;
_k_orb_scar_max   = 12;
_k_orb_rail_radius = [ 250, 150, 50 ];

_k_orb_ring_share = [ 0, 5/9, 8/9, 1 ];

_k_orb_rail_cx    = 400;
_k_orb_rail_cy    = 200;

_k_orb_unwrap_track_max  = 42;
_k_orb_unwrap_track_life = 24;
_k_orb_unwrap_track_len  = 92;
_k_orb_unwrap_residue_max  = 24;
_k_orb_unwrap_residue_life = 58;
_k_orb_unwrap_bus_width    = 18;
_k_orb_unwrap_packet_len   = 28;
_k_orb_unwrap_machine_floor = 0.30;
_k_orb_unwrap_machine_pulse = 0.28;
_k_orb_unwrap_sweep_alpha   = 0.08;

orb_unwrap_tracks      = [];
orb_unwrap_residue     = [];
orb_unwrap_sink_charge = 0;
orb_unwrap_recoil      = 0;


_k_mill_cx      = 400;
_k_mill_cy      = 304;
_k_mill_r_in    = 74;

_k_mill_rx_out  = 560;
_k_mill_ry_out  = 426;
_k_mill_edge_fill = 1.02;
_k_mill_arm_twist = 0.34;

_k_mill_arm_reveal   = 14;
_k_mill_arm_hold     = 14;
_k_mill_arm_fade     = 16;

_k_mill_arm_w        = 2.4;
_k_mill_arm_segs     = 22;
_k_mill_arm_dashes   = 9;
_k_mill_arm_dash_on  = 0.58;
_k_mill_arm_mark     = 5.5;

_k_mill_t_seed     = 6628;
_k_mill_t_seed_b   = 6645;
_k_mill_t_coil     = 6647;
_k_mill_t_unfold   = 6671;
_k_mill_t_feed     = 6715;
_k_mill_t_twin     = 6755;
_k_mill_t_strain   = 6792;
_k_mill_t_overload = 6797;
_k_mill_t_seed_c   = 6815;
_k_mill_t_wound    = 6856;
_k_mill_t_tear     = 6921;
_k_mill_t_clear    = 6955;
_k_mill_window_end = 6990;

_k_mill_chop_beats = [ 6675, 6695, 6715, 6735, 6755, 6775 ];

_k_mill_spin_start   = 1.1;
_k_mill_spin_end     = 5.6;
_k_mill_stall_frames = 3;
_k_mill_snap_mult    = 2.6;
_k_mill_extend_end   = 1.80;
_k_mill_extend_burst = 2.05;
_k_mill_pop_wave_spd = 20;

_k_mill_core_r_a     = 58;
_k_mill_core_r_b     = 92;
_k_mill_core_arm     = 10;
_k_mill_core_despawn = _k_mill_window_end - _k_mill_t_clear;

_k_mill_scar_count   = 5;
_k_mill_scar_beads   = 20;

_k_mill_scar_lead    = 16;

_k_mill_bead_speed   = 3.7;
_k_mill_bead_accel   = 0.22;

_k_mill_bead_fill    = 1.04;

_k_mill_orbit_from   = 0;
_k_mill_orbit_life   = 1;
_k_mill_orbit_end    = 6917;
_k_mill_orbit_fade   = 12;
_k_mill_orbit_lock   = 4;
_k_mill_orbit_band   = 54;

_k_mill_fence_from   = 3;
_k_mill_fence_links  = 3;
_k_mill_fence_w      = 7;

_k_mill_fuse_frames  = 10;
_k_mill_fuse_burn    = 5;

_k_mill_door_lo      = 470;
_k_mill_door_hi      = 600;

_k_mill_volley_beats  = [ 6856, 6859, 6862, 6865, 6868, 6871, 6874, 6877, 6880 ];
_k_mill_volley_scars  = [    1,    1,    1,    1,    1,    1,    1,    1,    1 ];
_k_mill_volley_count  = [   20,   20,   20,   20,   20,   20,   20,   20,   20 ];
_k_mill_volley_shake  = [    7,    8,    9,   10,   11,   12,   14,   16,   18 ];

mill_charge          = 0;
mill_heartbeat       = 0;
mill_heartbeat_phase = 0;
mill_blade_flash     = 0;
mill_overload        = 0;
mill_field_heat      = 0;
mill_collapse        = 0;
mill_rim             = 0;
mill_vortex          = 0;
mill_snap            = 0;
mill_arm_glow        = 0;

mill_seeds      = [];
mill_touchdowns = [];
mill_motes      = [];
mill_pop_queue  = [];

mill_scars      = [];
mill_gate_cyan_first = true;

mill_scar_queue = [];

mill_arm_base   = 0;
mill_arm_count  = 5;
mill_arm_sign   = 1;

mill_arm_waves  = [];

mill_blade_a   = noone;
mill_blade_b   = noone;
mill_stall     = 0;
mill_torn      = false;


_k_er_floor_y = 576;
_k_er_floor_base_y = 576;
_k_er_grav = 0.55;
_k_er_fast_rise_mult = 1.05;
_k_er_spear_w = 24;

_k_er_materialize_t = 2326;
_k_er_materialize_dur = 26;
_k_er_collapse_t = 2597;
_k_er_active_until = 2650;
_k_er_coil_read_floor = 0.16;
_k_er_opener_coil_floor = 0.38;
_k_er_side_burst_duration = 16;
_k_er_side_burst_hit_r = 10;
_k_er_side_burst_y_off = -4;

_k_er_side_burst_warn_lead = 72;
_k_er_side_warn_lane_r     = _k_er_side_burst_hit_r + 12;
_k_er_side_warn_slot_a     = [ 0.42, 0.96 ];
_k_er_side_warn_slot_hold  = 0.55;
_k_er_side_warn_spill      = 74;
_k_er_side_warn_read_floor = 0.34;
_k_er_side_warn_gate_w     = 74;
_k_er_side_warn_packet_n   = 9;
_k_er_side_warn_vent_cols  = [ global.avoid_col_cyan, global.avoid_col_warning,
                               global.avoid_col_violet ];

_k_er_beats = [ 2352, 2393, 2434, 2472, 2515, 2536, 2558, 2579 ];
_k_er_side_burst_t = _k_er_collapse_t;

_k_er_shake      = [ 6,    15   ];
_k_er_zoom       = [ 0.03, 0.09 ];
_k_er_vignette   = [ 0.18, 0.44 ];
_k_er_aberration = [ 0.10, 0.28 ];
_k_er_bloom      = [ 0.10, 0.26 ];
_k_er_ripple     = [ 0.16, 0.38 ];
_k_er_flash      = [ 0.06, 0.18 ];
_k_er_tear       = [ 0.08, 0.26 ];
_k_er_angle_kick = [ 0.3,  1.3  ];

_k_er_collapse_shake = 22;
_k_er_collapse_zoom = 0.16;
_k_er_collapse_vignette = 0.65;
_k_er_collapse_aberration = 0.42;
_k_er_collapse_bloom = 0.36;
_k_er_collapse_ripple = 0.6;
_k_er_collapse_flash = 0.35;
_k_er_collapse_tear = 0.45;
_k_er_collapse_duration = 40;
_k_er_despawn_duration = 58;
_k_er_despawn_sweep_count = 7;
_k_er_despawn_plate_count = 18;
_k_er_despawn_thread_count = 34;

_k_er_col_deep    = global.avoid_col_blood;
_k_er_col_molten  = global.avoid_col_warning;
_k_er_col_hot     = global.avoid_col_hot;
_k_er_col_white   = make_color_rgb(246, 254, 255);
_k_er_col_rock    = make_color_rgb(8, 11, 24);
_k_er_col_rim     = make_color_rgb(42, 68, 96);
_k_er_col_cyan    = global.avoid_col_cyan;
_k_er_col_violet  = global.avoid_col_violet;
_k_er_col_warning = global.avoid_col_warning;
_k_er_col_armor_dark = global.avoid_col_armor_dark;
_k_er_col_armor_mid  = global.avoid_col_armor_mid;
_k_er_col_armor_hi   = make_color_rgb(72, 106, 132);
_k_er_col_armor_edge = global.avoid_col_armor_edge;

_k_er_grid_plate_w = 68;
_k_er_grid_trace_a = 0.42;
_k_er_lock_life = 22;
_k_er_scan_life = 28;
_k_er_lane_residue_life = 150;
_k_er_lane_residue_max = 22;

_k_er_plan = [
  { cols : [ {cx:400, w:80} ],
    slab_h : 96, rise : 19.0, lead : 44, stray : 0, fast : false },

  { cols : [ {cx:190, w:100}, {cx:610, w:100} ],
    slab_h : 96, rise : 19.5, lead : 38, stray : 0, fast : false },

  { cols : [ {cx:120, w:90}, {cx:400, w:90}, {cx:680, w:90} ],
    slab_h : 96, rise : 20.0, lead : 34, stray : 0, fast : false },

  { cols : [ {cx:0, w:60}, {cx:260, w:90}, {cx:540, w:90}, {cx:800, w:60} ],
    slab_h : 96, rise : 20.5, lead : 34, stray : 0, fast : false },

  { cols : [], phase : 0, slab_h : 74, rise : 29, lead : 18, stray : 0, fast : true },
  { cols : [], phase : 1, slab_h : 74, rise : 30, lead : 18, stray : 0, fast : true },
  { cols : [], phase : 0, slab_h : 74, rise : 31, lead : 18, stray : 0, fast : true },
  { cols : [], phase : 1, slab_h : 74, rise : 32, lead : 18, stray : 0, fast : true }
];

var _k_er_fast_braid = [
  [ {cx:20,  w:40}, {cx:180, w:40}, {cx:340, w:40}, {cx:500, w:40}, {cx:660, w:40} ],
  [ {cx:60,  w:40}, {cx:220, w:40}, {cx:380, w:40}, {cx:540, w:40}, {cx:700, w:40} ],
  [ {cx:100, w:40}, {cx:260, w:40}, {cx:420, w:40}, {cx:580, w:40}, {cx:740, w:40} ],
  [ {cx:140, w:40}, {cx:300, w:40}, {cx:460, w:40}, {cx:620, w:40}, {cx:780, w:40} ]
];
var _er_fast_i = 0;
for (var _erp = 0; _erp < array_length(_k_er_plan); _erp++) {
  var _er_entry = _k_er_plan[_erp];
  if (_er_entry.fast) {
    var _er_cols = [];
    var _er_lane = _k_er_fast_braid[_er_fast_i];
    for (var _er_l = 0; _er_l < array_length(_er_lane); _er_l++) {
      var _er_lane_col = _er_lane[_er_l];
      var _er_x = _er_lane_col.cx;
      if (_er_x > -_k_er_spear_w && _er_x < room_width + _k_er_spear_w) {
        array_push(_er_cols, { cx : _er_x, w : _er_lane_col.w });
      }
    }
    _er_entry.cols = _er_cols;
    _er_entry.braid = _er_fast_i;
    _er_fast_i++;
  }
}

if (array_length(_k_er_beats) != array_length(_k_er_plan)) {
  show_debug_message("ERUPTION: _k_er_beats has " + string(array_length(_k_er_beats))
                   + " entries but _k_er_plan has " + string(array_length(_k_er_plan)));
}

_k_er_collapse_phase = 1;
_k_er_collapse_slab_h = 120;
_k_er_collapse_rise = 38;
_k_er_collapse_lead = 14;

_k_er_collapse_cols = _k_er_plan[7].cols;

erupt_materialize = 0;
erupt_pressure = 0;
erupt_coil = 0;
erupt_coil_index = -1;
erupt_flash = 0;
erupt_floor_heat = 0;
erupt_shudder = 0;
erupt_beat_index = 0;
erupt_active_until = _k_er_active_until;
erupt_collapsing = false;
erupt_collapse_timer = 0;
erupt_despawn_active = false;
erupt_despawn_timer = 0;
erupt_despawn_flash = 0;
erupt_despawn_sink = 0;
erupt_despawn_sweeps = [];
erupt_despawn_plates = [];
erupt_despawn_threads = [];
erupt_despawn_motes = [];
erupt_despawn_lip = [];
for (var _erl = 0; _erl <= 32; _erl++) {
  array_push(erupt_despawn_lip, random_range(-1.5, 1.5));
}

erupt_armed_cols = [];
erupt_armed_fast = false;
erupt_last_lock_index = -99;

erupt_pillars = [];
erupt_shards = [];
erupt_gravel = [];
erupt_ridges = [];
erupt_scars = [];
erupt_sparks = [];
erupt_haze = [];
erupt_strays = [];
erupt_side_bursts = [];
erupt_side_warn_vents = [];
erupt_seed_streams = [];
erupt_lock_frames = [];
erupt_charge_arcs = [];
erupt_scan_sweeps = [];
erupt_code_streams = [];
erupt_panel_afterimages = [];
erupt_reactor_rings = [];
erupt_collapse_beams = [];
erupt_lane_residue = [];

ember_spray = [];


_k_kdash_prelude_t = 3331;
_k_kdash_start_t = 3344;
_k_kdash_end_t   = 3565;

_k_kdash_beats = [3344, 3362, 3383, 3403, 3423, 3443, 3463, 3484, 3505, 3525, 3546];

kunai_dash_cycle_index = 0;
kdash_beat_index = 0;
kdash_escalation = 0;
kdash_heartbeat = 0;
kdash_heartbeat_phase = 0;
kdash_coil = 0;
kdash_strike_flash = 0;
kdash_chroma = 0;
kdash_rift = 0;
kdash_rift_x = 400;
kdash_rift_x_prev = 400;
kdash_rift_slide = 1;
kdash_finale = 0;
kdash_active = false;

_k_kdash_coil_lead = 13;
_k_kdash_spawn_interval_start = 6;
_k_kdash_spawn_interval_end = 4;
_k_kdash_fall_speed_start = 9;
_k_kdash_fall_speed_end = 13;
_k_kdash_dash_speed_start = 22;
_k_kdash_dash_speed_end = 38;
_k_kdash_dash_frames = 9;
_k_kdash_impact_cap = 34;
_k_kdash_ghost_cap = 90;
_k_kdash_rift_width = 120;
_k_kdash_socket_cap = 64;
_k_kdash_scar_cap = 48;
_k_kdash_socket_y = 7;
_k_kdash_socket_w = 22;
_k_kdash_socket_h = 13;
_k_kdash_lane_half_w = 13;
_k_kdash_lane_segments = 7;

ini_open(CONFIG_FILENAME);
kdash_trail_alpha         = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_trail_alpha", 0.65);
kdash_hotcore_alpha       = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_hotcore_alpha", 0.55);
kdash_rift_wash_intensity = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_rift_wash_intensity", 0.42);
kdash_rift_mouth_intensity= ini_read_real(CONFIG_SECTION_KUNAI, "kdash_rift_mouth_intensity", 0.85);
kdash_blade_glow_min      = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_blade_glow_min", 0.5);
kdash_blade_glow_max      = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_blade_glow_max", 1.75);
kdash_strike_bloom_base   = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_strike_bloom_base", 0.55);
kdash_strike_bloom_scale  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_strike_bloom_scale", 0.6);
kdash_telegraph_bloom_alpha = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_telegraph_bloom_alpha", 0.35);
kdash_telegraph_band_alpha  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_telegraph_band_alpha", 0.55);
kdash_strike_flash_mult   = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_strike_flash_mult", 1.0);
kdash_chroma_fringe_mult  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_chroma_fringe_mult", 1.0);
kdash_body_hot_blend      = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_body_hot_blend", 0.55);
kdash_body_alpha_mult     = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_body_alpha_mult", 1.0);
kdash_ghost_glow_intensity  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_ghost_glow_intensity", 1.1);
kdash_slash_glow_intensity  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_slash_glow_intensity", 1.3);
kdash_crater_glow_mult       = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_crater_glow_mult", 1.0);
kdash_shard_glow_intensity  = ini_read_real(CONFIG_SECTION_KUNAI, "kdash_shard_glow_intensity", 0.85);

kunai_burst_flash_mult = ini_read_real(CONFIG_SECTION_KUNAI, "kunai_burst_flash_mult", 0.65);
kunai_edge_wave_mult   = ini_read_real(CONFIG_SECTION_KUNAI, "kunai_edge_wave_mult", 0.65);
big_kunai_note_tear_mult = ini_read_real(CONFIG_SECTION_KUNAI, "big_kunai_note_tear_mult", 1.0);
ini_close();

ini_open(CONFIG_FILENAME);

laser_beam_w_bloom = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_w_bloom", 38);
laser_beam_w_halo  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_w_halo",  18);
laser_beam_w_glow  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_w_glow",  7);
laser_beam_w_core  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_w_core",  2.2);

laser_beam_a_bloom = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_a_bloom", 0.09);
laser_beam_a_halo  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_a_halo",  0.2);
laser_beam_a_glow  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_a_glow",  0.34);
laser_beam_a_core  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_a_core",  1.0);

laser_beam_bead_freq  = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_bead_freq",  3.0);
laser_beam_bead_speed = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_bead_speed", 22);
laser_beam_bead_depth = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_bead_depth", 0.55);

laser_beam_fil_frac = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_fil_frac", 0.75);
laser_beam_fil_wave = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_fil_wave", 190);
laser_beam_fil_w    = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_fil_w",    1.7);

laser_beam_packet_gap   = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_packet_gap",   240);
laser_beam_packet_speed = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_packet_speed", 26);
laser_beam_packet_len   = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_packet_len",   110);
laser_beam_packet_a     = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_packet_a",     0.7);
laser_beam_tick_a       = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_tick_a",       0.3);

laser_beam_lead_squash = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_lead_squash", 0.5);
laser_beam_wake_stretch= ini_read_real(CONFIG_SECTION_LASER, "laser_beam_wake_stretch", 1.7);
laser_beam_rim_a       = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_rim_a", 0.55);

laser_beam_trail_len = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_trail_len", 10);
laser_beam_trail_a   = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_trail_a",   0.2);

laser_beam_blade_arc = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_blade_arc", 26);

laser_beam_split = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_split", 3.0);

laser_beam_gain = ini_read_real(CONFIG_SECTION_LASER, "laser_beam_gain", 1.0);
ini_close();

kdash_impacts = [];
kdash_shards  = [];
kdash_ghosts  = [];
kdash_arcs    = [];
kdash_slashes = [];
kdash_lanes   = [];
kdash_sockets = [];
kdash_scars   = [];

rain_spawn_timer = 0;
rain_safe_x = 400;
rain_safe_x_prev = 400;
rain_safe_slide = 1;
rain_safe_width = 96;
rain_lane_flash = 0;
rain_intensity = 0;
rain_heartbeat = 0;
rain_heartbeat_phase = 0;
rain_band_crackle = [];
rain_source_slots = [];
rain_floor_scars = [];

kunai_impacts = [];
kunai_shards = [];
_k_kunai_floor_y = 576;
_k_kunai_impact_cap = 40;
_k_rain_source_y = 23;
_k_rain_source_life = 34;
_k_rain_source_cap = 64;
_k_rain_source_w = 28;
_k_rain_source_h = 9;
_k_rain_floor_scar_cap = 34;

big_kunai_telegraph = 0;
big_kunai_build = 0;
big_kunai_locked = false;
big_kunai_lock_flash = 0;
big_kunai_coil = 0;
big_kunai_release = 0;
orbit_ribbon_heat = 0;
orbit_path_ghosts = [];
kunai_absorb_pops = [];

_k_orbit_cx = 400;
_k_orbit_cy = 200;
_k_orbit_rx = 200;
_k_orbit_ry = 100;

_k_rain_start = 378;
_k_rain_end = 626;
_k_rain_interval_start = 20;
_k_rain_interval_end = 11;
_k_big_kunai_spawn_t = 500;
_k_big_kunai_telegraph_lead = 14;
_k_big_kunai_notes = [ 623, 643, 662, 681 ];
_k_big_kunai_note_shake = [ 12, 17, 23, 30 ];
_k_big_kunai_note_zoom = [ 0.06, 0.09, 0.13, 0.19 ];
_k_big_kunai_note_flash = [ 0.18, 0.28, 0.4, 0.6 ];
_k_big_kunai_note_tilt = [ 1.6, -2.1, 2.6, -3.4 ];
_k_big_kunai_note_tear = [ 0.28, 0.42, 0.58, 0.82 ];
_k_big_kunai_coil_lead = 10;

arrow_ring_count = 8;

arrow_ring_x = room_width * 0.5;
arrow_ring_y = room_height * 0.35;

arrow_ring_radius = 180;
arrow_ring_current_radius = 0;
arrow_ring_vertical_scale = 0.55;

arrow_ring_angle = 0;
arrow_ring_timer = 0;

arrow_ring_rotate_speed = 0;

ring_outline_pulse = 0;

arrow_ring_history = [];

ring_ripples = [];

arrow_ring_created = false;
arrow_ring = [];

ring_telegraph_alpha = 0;

ring_vignette_strength = 0;

ring_color = 255;

_k_ring_home_x = room_width * 0.5;
_k_ring_home_y = room_height * 0.35;

_k_ring_telegraph_start = 6;
_k_ring_spawn_start = 17;
_k_ring_lock_t = 48;

_k_arrow_stagger_frames = 2;
_k_arrow_spawn_duration_each = 18;
arrow_ring_spawn_duration = _k_arrow_stagger_frames * (arrow_ring_count - 1) + _k_arrow_spawn_duration_each;

_k_ring_strike_frames = [ 170, 188, 203, 214 ];
_k_ring_coil_lead = 14;
_k_ring_despawn_t = 280;
_k_ring_cleanup_t = 292;

_k_strike_shake = [ 10, 14, 18, 26 ];
_k_strike_zoom_punch = [ 0.05, 0.075, 0.1, 0.16 ];
_k_strike_flash = [ 0.12, 0.18, 0.26, 0.45 ];
_k_strike_tilt = [ 1.2, -1.6, 2.0, -3.0 ];
_k_strike_streaks = [ 14, 18, 24, 34 ];
_k_strike_particles = [ 16, 22, 30, 44 ];
_k_strike_embers = [ 6, 9, 13, 20 ];
_k_strike_splatter = [ 5, 9, 14, 22 ];
_k_strike_salvo_interval = [ 11, 9, 8, 6 ];

ring_missiles = [];
ring_missile_shards = [];
ring_missile_bursts = [];
ring_missile_reticles = [];
ring_missile_locks = [];
ring_missile_id_counter = 0;
ring_missile_hand_angle = 0;
ring_missile_hand_flash = 0;
ring_missile_focus_x = _k_ring_home_x;
ring_missile_focus_y = _k_ring_home_y;
ring_ghost_active = false;
ring_ghost_timer = 0;
ring_ghost_push = 0;
ring_arrow_recoil = 0;
ring_arrow_recoil_vel = 0;
ring_missile_slow_spin_dir = 1;

_k_ring_ghost_alpha = 0.5;
_k_ring_ghost_hold = 12;
_k_ring_final_ghost_hold = 1;
_k_ring_missile_lock_lead = 30;
_k_ring_missile_slow_spin = 1.15;
_k_ring_missile_fuse = [ 25, 27, 28, 30 ];
_k_ring_final_salvo_speed = [ 5, 4, 3 ];
_k_ring_final_ghost_exit_speed = 20;
_k_ring_missile_blast_radius = [ 17, 21, 25, 31 ];
_k_ring_missile_shard_count = [ 4, 6, 8, 10 ];
_k_ring_missile_shard_speed = [ 4.8, 5.4, 6.0, 6.7 ];
_k_ring_missile_shard_life = [ 7, 8, 8, 9 ];
_k_ring_missile_hit_radius = 9;
_k_ring_missile_trail_length = 8;
_k_ring_missile_target_pad = 42;

ring_apply_missile_focus = function(_hit_index, _allow_live_target) {
  var _lock = undefined;
  if (_hit_index >= 0 && _hit_index < array_length(ring_missile_locks)) {
    _lock = ring_missile_locks[_hit_index];
  }

  if (is_struct(_lock) && _lock.active) {
    ring_missile_focus_x = _lock.x;
    ring_missile_focus_y = _lock.y;
    ring_missile_hand_angle = _lock.ang;
    arrow_scan_angle = _lock.ang;
    return true;
  }

  if (_allow_live_target && instance_exists(oPlayer)) {
    ring_missile_focus_x = clamp(oPlayer.x, _k_ring_missile_target_pad, room_width - _k_ring_missile_target_pad);
    ring_missile_focus_y = clamp(oPlayer.y, _k_ring_missile_target_pad, _k_ring_floor_y - _k_ring_missile_target_pad * 0.5);
    ring_missile_hand_angle = point_direction(arrow_ring_x, arrow_ring_y, ring_missile_focus_x, ring_missile_focus_y);
    arrow_scan_angle = ring_missile_hand_angle;
    return true;
  }

  return false;
};

ring_capture_missile_lock = function(_hit_index) {
  var _tx = room_width * 0.5;
  var _ty = room_height * 0.72;

  if (instance_exists(oPlayer)) {
    _tx = clamp(oPlayer.x, _k_ring_missile_target_pad, room_width - _k_ring_missile_target_pad);
    _ty = clamp(oPlayer.y, _k_ring_missile_target_pad, _k_ring_floor_y - _k_ring_missile_target_pad * 0.5);
  }

  var _ang = point_direction(arrow_ring_x, arrow_ring_y, _tx, _ty);
  var _fuse = _k_ring_missile_fuse[_hit_index];
  var _life = max(1, _k_ring_strike_frames[_hit_index] - t) + _fuse + 8;

  ring_missile_locks[_hit_index] = {
    active : true,
    fired : false,
    x : _tx,
    y : _ty,
    ang : _ang,
    lock_t : t,
    seed : random(1000)
  };

  ring_missile_hand_angle = _ang;
  ring_missile_focus_x = _tx;
  ring_missile_focus_y = _ty;
  arrow_scan_angle = _ang;

  array_push(ring_missile_reticles, {
    mid : -100 - _hit_index,
    x : _tx,
    y : _ty,
    life : _life,
    max_life : _life,
    fuse : _fuse,
    hit_index : _hit_index,
    seed : random(1000)
  });
};

ring_spawn_lock_missile = function(_hit_index) {
  var _lock = undefined;
  if (_hit_index >= 0 && _hit_index < array_length(ring_missile_locks)) {
    _lock = ring_missile_locks[_hit_index];
  }

  var _tx = room_width * 0.5;
  var _ty = room_height * 0.72;
  var _ang;
  var _has_lock = is_struct(_lock) && _lock.active;

  if (_has_lock) {
    _tx = _lock.x;
    _ty = _lock.y;
    _ang = _lock.ang;
    ring_missile_locks[_hit_index].fired = true;
  } else {
    if (instance_exists(oPlayer)) {
      _tx = clamp(oPlayer.x, _k_ring_missile_target_pad, room_width - _k_ring_missile_target_pad);
      _ty = clamp(oPlayer.y, _k_ring_missile_target_pad, _k_ring_floor_y - _k_ring_missile_target_pad * 0.5);
    }
    _ang = point_direction(arrow_ring_x, arrow_ring_y, _tx, _ty);
  }

  var _dist_to_target = point_distance(arrow_ring_x, arrow_ring_y, _tx, _ty);
  var _hand_len = clamp(_dist_to_target * 0.36, 56, max(64, arrow_ring_current_radius * 0.82));
  var _ox = arrow_ring_x + lengthdir_x(_hand_len, _ang);
  var _oy = arrow_ring_y + lengthdir_y(_hand_len, _ang);
  var _fuse = _k_ring_missile_fuse[_hit_index];

  ring_missile_id_counter++;
  ring_missile_hand_angle = _ang;
  ring_missile_focus_x = _tx;
  ring_missile_focus_y = _ty;
  arrow_scan_angle = _ang;

  array_push(ring_missiles, {
    mid : ring_missile_id_counter,
    hit_index : _hit_index,
    ox : _ox,
    oy : _oy,
    tx : _tx,
    ty : _ty,
    ang : _ang,
    x : _ox,
    y : _oy,
    px : _ox,
    py : _oy,
    timer : -1,
    fuse : _fuse,
    seed : random(1000),
    trail : [],
    hot : 0.62 + _hit_index * 0.12
  });

  if (!_has_lock) {
    array_push(ring_missile_reticles, {
      mid : ring_missile_id_counter,
      x : _tx,
      y : _ty,
      life : _fuse + 8,
      max_life : _fuse + 8,
      fuse : _fuse,
      hit_index : _hit_index,
      seed : random(1000)
    });
  }
};

ring_detonate_lock_missile = function(_m) {
  var _hit_index = _m.hit_index;
  var _hot = 0.72 + _hit_index * 0.09;

  array_push(ring_missile_bursts, {
    x : _m.tx,
    y : _m.ty,
    radius : 6,
    max_radius : _k_ring_missile_blast_radius[_hit_index],
    life : 18 + _hit_index * 3,
    max_life : 18 + _hit_index * 3,
    danger_life : 6,
    hit_radius : 9 + _hit_index * 2,
    hot : _hot,
    used : false
  });

  var _count = _k_ring_missile_shard_count[_hit_index];
  var _step = 360 / _count;
  var _offset = _m.ang + 90 + _hit_index * 17;
  var _speed = _k_ring_missile_shard_speed[_hit_index];
  var _life = _k_ring_missile_shard_life[_hit_index];

  for (var _si = 0; _si < _count; _si++) {
    var _ang = _offset + _si * _step;
    var _spd = _speed + random_range(-0.35, 0.45);
    array_push(ring_missile_shards, {
      x : _m.tx,
      y : _m.ty,
      px : _m.tx,
      py : _m.ty,
      vx : lengthdir_x(_spd, _ang),
      vy : lengthdir_y(_spd, _ang),
      ang : _ang,
      spin : random_range(-2.2, 2.2),
      life : _life,
      max_life : _life,
      delay : 0,
      scale : 1.05 + _hit_index * 0.08,
      hot : _hot,
      used : false
    });
  }

  if (_hit_index == 3) {
    var _final_count = 12;
    var _final_step = 360 / _final_count;
    var _final_offset = _offset + _final_step * 0.5;

    for (var _fi = 0; _fi < _final_count; _fi++) {
      var _fang = _final_offset + _fi * _final_step;
      var _fspd = 5.2 + random_range(-0.25, 0.45);
      array_push(ring_missile_shards, {
        x : _m.tx,
        y : _m.ty,
        px : _m.tx,
        py : _m.ty,
        vx : lengthdir_x(_fspd, _fang),
        vy : lengthdir_y(_fspd, _fang),
        ang : _fang,
        spin : random_range(-1.8, 1.8),
        life : 9,
        max_life : 9,
        delay : 5,
        scale : 0.95,
        hot : 1,
        used : false
      });
    }
  }

  for (var _p = 0; _p < 18 + _hit_index * 6; _p++) {
    var _pa = random(360);
    var _ps = random_range(2.4, 7.4 + _hit_index);
    array_push(arrow_ring_particles, {
      x : _m.tx,
      y : _m.ty,
      vx : lengthdir_x(_ps, _pa),
      vy : lengthdir_y(_ps, _pa),
      life : 18,
      max_life : 18,
      size : random_range(0.1, 0.28),
      grav : 0.03,
      drag : 0.94,
      hot : _hot
    });
  }

  ring_radius_pump_vel += 2.5 + _hit_index;
  arrow_core_flash = max(arrow_core_flash, (10 + _hit_index * 3) * fx_get_mult_for("arrowring", "flash"));

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 4 + _hit_index * 2);
  }
};

ring_phase = "void";

ring_coil_amount = 0;
ring_strike_index = 0;
ring_salvo_interval = 12;
ring_salvo_timer = 0;

ring_heartbeat = 0;
ring_heartbeat_phase = 0;
ring_core_charge = 0;

ring_radius_pump = 0;
ring_radius_pump_vel = 0;

ring_chroma = 0;
ring_lock_flash = 0;
ring_bloom_hot = 0;
ring_wound = 0;

ring_charge_motes = [];
ring_inward_arcs = [];
ring_embers = [];
ring_shockwaves = [];
ring_rim_afterglow = [];
ring_leak_arcs = [];
ring_splatter = [];

_k_ring_arena_pad = 34;
_k_ring_floor_y = 576;

ring_ambient = 0;
ring_band_ignited = false;
ring_band_ignite_t = -10000;

ring_safe_ang = 90;
ring_safe_ang_prev = 90;
ring_safe_slide = 1;
ring_safe_arc = 40;
ring_sector_flash = 0;
ring_safe_arc_cap = 32;

ring_tracers = [];
ring_craters = [];
ring_stuck_arrows = [];
ring_rim_crackle = [];

_k_ring_tracer_lead = 8;
_k_ring_max_tracers = 64;
_k_ring_max_craters = 34;
_k_ring_max_stuck = 30;
_k_ring_spin_damp = 0.08;

ring_coil_armed = -1;
ring_salvo_traced = false;

ring_arena_hit = function(_x, _y, _ang) {
  var _dx = dcos(_ang);
  var _dy = -dsin(_ang);

  var _xmin = _k_ring_arena_pad;
  var _xmax = room_width - _k_ring_arena_pad;
  var _ymin = _k_ring_arena_pad;
  var _ymax = _k_ring_floor_y;

  var _big = 100000;
  var _tx = _big;
  var _ty = _big;

  if (_dx > 0.0001) _tx = (_xmax - _x) / _dx;
  else if (_dx < -0.0001) _tx = (_xmin - _x) / _dx;

  if (_dy > 0.0001) _ty = (_ymax - _y) / _dy;
  else if (_dy < -0.0001) _ty = (_ymin - _y) / _dy;

  var _t = max(1, min(_tx, _ty));

  return {
    x : _x + _dx * _t,
    y : _y + _dy * _t,
    dist : _t,
    vertical : (_tx <= _ty)
  };
};

ring_move_safe_sector = function(_ang) {
  ring_safe_ang_prev = ring_safe_ang;
  ring_safe_ang = _ang;
  ring_safe_slide = 0;
  ring_sector_flash = 1;
};

ring_land_arrow = function(_lx, _ly, _ang, _vertical, _hot) {
  var _edge_ang = _vertical ? 90 : 0;

  array_push(ring_craters, {
    x : _lx,
    y : _ly,
    edge : _edge_ang,
    radius : 3,
    max_radius : 15 + _hot * 20,
    life : 22 + irandom(8),
    max_life : 30,
    hot : _hot
  });

  if (array_length(ring_craters) > _k_ring_max_craters) array_delete(ring_craters, 0, 1);

  if (_hot > 0.6 || irandom(2) == 0) {
    array_push(ring_stuck_arrows, {
      x : _lx - lengthdir_x(4 + random(3), _ang),
      y : _ly - lengthdir_y(4 + random(3), _ang),
      ang : _ang + random_range(-7, 7),
      life : 74 + irandom(40),
      max_life : 114,
      scale : random_range(2.1, 3.2),
      wobble : 9 + _hot * 7,
      phase : random(6.28),
      hot : _hot
    });

    if (array_length(ring_stuck_arrows) > _k_ring_max_stuck) array_delete(ring_stuck_arrows, 0, 1);
  }

  array_push(ring_shockwaves, {
    x : _lx,
    y : _ly,
    radius : 4,
    max_radius : (26 + _hot * 26) * (_vertical ? 0.34 : 1),
    life : 16,
    max_life : 16,
    width : 5 + _hot * 5,
    hot : _hot * 0.7,
    vs : _vertical ? 2.94 : 0.34
  });

  for (var _lp = 0; _lp < 3 + irandom(3); _lp++) {
    var _sa = _edge_ang + random_range(-64, 64) + (irandom(1) ? 180 : 0);
    var _ss = random_range(1.4, 4);

    array_push(arrow_ring_particles, {
      x : _lx,
      y : _ly,
      vx : lengthdir_x(_ss, _sa),
      vy : lengthdir_y(_ss, _sa),
      life : 14,
      max_life : 14,
      size : random_range(0.08, 0.22),
      grav : 0.12,
      drag : 0.93,
      hot : 0.55 + _hot * 0.45
    });
  }

  if (irandom(1) == 0) {
    array_push(ring_embers, {
      x : _lx,
      y : _ly,
      vx : -lengthdir_x(random_range(0.6, 1.8), _ang),
      vy : -lengthdir_y(random_range(0.6, 1.8), _ang) - random(1),
      life : 28 + irandom(24),
      max_life : 52,
      size : random_range(0.07, 0.16),
      hot : 0.4 + _hot * 0.5
    });
  }

  array_push(ring_rim_crackle, {
    ang : point_direction(arrow_ring_x, arrow_ring_y, _lx, _ly),
    life : 7,
    life_max : 7,
    len : random_range(26, 58 + _hot * 40)
  });

  ring_ambient = min(1.3, ring_ambient + 0.02 + _hot * 0.03);
};

ring_push_tracer = function(_track, _ang, _ox, _oy, _life, _speed, _hot) {
  if (array_length(ring_tracers) >= _k_ring_max_tracers) return;

  var _hit = ring_arena_hit(_ox, _oy, _ang);

  array_push(ring_tracers, {
    track : _track,
    ang : _ang,
    ox : _ox,
    oy : _oy,
    lx : _hit.x,
    ly : _hit.y,
    dist : _hit.dist,
    vertical : _hit.vertical,
    life : _life,
    max_life : _life,
    fired : false,
    travel : 0,
    speed : _speed,
    seed : random(1000),
    hot : _hot
  });
};

ring_streaks = [];

ripple_trigger_time = -10000;

ripple_trigger_x = 0;
ripple_trigger_y = 0;

arrow_ring_spawn_timer = 0;

ring_spawn_flash = 0;

ring_spawn_flash_timer = 0;
ring_spawn_flash_duration = 0;

arrow_ring_despawning = false;

arrow_ring_despawn_timer = 0;

arrow_ring_despawn_duration = 12;

ring_bass_flash_amount = 0;
ring_bass_flash_target = 0;

arrow_ring_particles = [];

arrow_ring_particle_timer = 0;

arrow_scan_angle = 0;
arrow_scan_speed = 2;

arrow_scan_flash = 0;

arrow_core_pulse = 0;
arrow_core_rotation = 0;
arrow_core_flash = 0;

arrow_energy_flow = 0;
arrow_energy_speed = 0.08;

arrow_ring_despawn_burst = false;

_k_intro_heartbeats = [ 2, 11, 19, 26, 32, 36, 39, 42, 44, 46, 47 ];
intro_heartbeat_pulse = 0;

convergence_flash_active = false;

convergence_flash_timer = 0;

convergence_flash_duration = 20;

telegraph_arc_regen_timer = 0;

telegraph_arcs = [];

pending_kunai_spawns = [];

kunai_pair = array_create(2, -4);

shared_orbit_angle = 0;

orbit_speed_current = 3;
orbit_speed_floor = 3;
orbit_ramp_start_speed = 3;
orbit_ramp_target = 3;
orbit_ramp_timer = 0;
orbit_speed_min_ever = 3;
orbit_speed_max_ever = 26;

ring_built = false;

ring_bursts = [];

ring_pulse_timer = 0;

ring_pulse_duration = 18;

ring_pulse_strength = 1.6;

ring_pulse_mult = 1;

_k_quarter_telegraph_duration = 8;

_k_quarter_spawn_duration = 20;

_k_quarter_beats = [ 709, 730, 751, 772, 792, 813, 833, 853, 875, 895, 915, 935, 956, 975 ];

_k_quarter_lock_t = 709;
_k_quarter_coil_t = 956;
_k_quarter_collapse_t = 976;
_k_quarter_collapse_frames = 20;

quarter_telegraph_active = false;

quarter_telegraph_timer = 0;

quarter_shockwaves = [];

quarter_heat = 0;
quarter_beat_flash = 0;
quarter_lock_flash = 0;
quarter_coil = 0;
quarter_core_charge = 0;
quarter_detonated = false;
quarter_arcs = [];
quarter_ghosts = [];
quarter_scars = [];

_k_qamb_pad = 34;
_k_qamb_floor_y = 576;

qamb = 0;
qamb_hb = 0;
qamb_hb_phase = 0;
quarter_locked = false;
quarter_lock_frame = -10000;
quarter_readout = 0;

qamb_base = [ 0, 0 ];
qamb_rad = [ 140, 70 ];
qamb_spin = [ 1.2, -2.2 ];
qamb_live = false;

quarter_safe_ang = 90;
quarter_safe_ang_prev = 90;
quarter_safe_slide = 1;
quarter_safe_w = 90;
quarter_safe_flash = 0;
quarter_pinch = 0;
quarter_pinch_eta = 999;
quarter_alt_ang = 0;
quarter_alt_ang_draw = 0;
quarter_alt_w = 0;

_k_q_pinch_w = 15;

quarter_tracers = [];
quarter_craters = [];
quarter_stuck = [];
quarter_rim_crackle = [];
quarter_lock_frames = [];
quarter_vents = [];

_k_q_tracer_lead = 7;
_k_q_max_tracers = 72;

_k_q_lock_life = 22;
_k_q_max_vents = 56;
_k_q_vent_cols = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];
_k_q_max_craters = 30;
_k_q_max_stuck = 26;
_k_q_land_every = 3;

quarter_beat_traced = -1;
quarter_land_cursor = 0;

quarter_rim_hit = function(_x, _y, _ang) {
  var _dx = dcos(_ang);
  var _dy = -dsin(_ang);

  var _xmin = _k_qamb_pad;
  var _xmax = room_width - _k_qamb_pad;
  var _ymin = _k_qamb_pad;
  var _ymax = _k_qamb_floor_y;

  var _big = 100000;
  var _tx = _big;
  var _ty = _big;

  if (_dx > 0.0001) _tx = (_xmax - _x) / _dx;
  else if (_dx < -0.0001) _tx = (_xmin - _x) / _dx;

  if (_dy > 0.0001) _ty = (_ymax - _y) / _dy;
  else if (_dy < -0.0001) _ty = (_ymin - _y) / _dy;

  var _t = max(1, min(_tx, _ty));

  return {
    x : _x + _dx * _t,
    y : _y + _dy * _t,
    dist : _t,
    vertical : (_tx <= _ty)
  };
};

quarter_move_safe = function(_ang) {
  quarter_safe_ang_prev = quarter_safe_ang;
  quarter_safe_ang = _ang;
  quarter_safe_slide = 0;
  quarter_safe_flash = 1;
};

quarter_push_tracer = function(_gi, _oi, _ang, _ox, _oy, _life, _speed, _hot, _cid, _lands) {
  if (array_length(quarter_tracers) >= _k_q_max_tracers) return;

  var _hit = quarter_rim_hit(_ox, _oy, _ang);

  array_push(quarter_tracers, {
    gi : _gi,
    oi : _oi,
    ang : _ang,
    ox : _ox,
    oy : _oy,
    lx : _hit.x,
    ly : _hit.y,
    dist : _hit.dist,
    vertical : _hit.vertical,
    life : _life,
    max_life : max(1, _life),
    fired : false,
    travel : 0,
    speed : _speed,
    seed : random(1000),
    hot : _hot,
    cid : _cid,
    lands : _lands
  });
};

quarter_push_lock = function(_cx, _cy, _r, _cid, _hot) {
  array_push(quarter_lock_frames, {
    cx : _cx,
    cy : _cy,
    r : _r,
    life : _k_q_lock_life,
    life_max : _k_q_lock_life,
    hot : clamp(_hot, 0, 1),
    cid : _cid,
    seed : random(1000)
  });
};

quarter_land_child = function(_lx, _ly, _ang, _vertical, _hot, _cid) {
  var _edge_ang = _vertical ? 90 : 0;

  array_push(quarter_craters, {
    x : _lx,
    y : _ly,
    edge : _edge_ang,
    radius : 3,
    max_radius : 13 + _hot * 18,
    life : 20 + irandom(8),
    max_life : 28,
    hot : _hot,
    cid : _cid
  });

  if (array_length(quarter_craters) > _k_q_max_craters) array_delete(quarter_craters, 0, 1);

  if (_hot > 0.7 || irandom(1) == 0) {
    array_push(quarter_stuck, {
      x : _lx - lengthdir_x(3 + random(3), _ang),
      y : _ly - lengthdir_y(3 + random(3), _ang),
      ang : _ang + random_range(-6, 6),
      edge : _edge_ang,
      life : 66 + irandom(38),
      max_life : 104,
      scale : random_range(0.8, 1.5),
      wobble : 8 + _hot * 6,
      phase : random(6.28),
      hot : _hot,
      cid : _cid
    });

    if (array_length(quarter_stuck) > _k_q_max_stuck) array_delete(quarter_stuck, 0, 1);
  }

  array_push(ring_shockwaves, {
    x : _lx,
    y : _ly,
    radius : 4,
    max_radius : (20 + _hot * 20) * (_vertical ? 0.34 : 1),
    life : 13,
    max_life : 13,
    width : 4 + _hot * 4,
    hot : _hot * 0.6,
    vs : _vertical ? 2.94 : 0.34
  });

  for (var _lp = 0; _lp < 2 + irandom(2); _lp++) {
    var _sa = _edge_ang + random_range(-62, 62) + (irandom(1) ? 180 : 0);
    var _ss = random_range(1.3, 3.6);

    array_push(arrow_ring_particles, {
      x : _lx,
      y : _ly,
      vx : lengthdir_x(_ss, _sa),
      vy : lengthdir_y(_ss, _sa),
      life : 13,
      max_life : 13,
      size : random_range(0.07, 0.2),
      grav : 0.11,
      drag : 0.93,
      hot : 0.5 + _hot * 0.45
    });
  }

  array_push(quarter_rim_crackle, {
    ang : point_direction(400, 304, _lx, _ly),
    life : 6,
    life_max : 6,
    len : random_range(22, 46 + _hot * 34),
    cid : _cid
  });

  var _q_vent_dir = point_direction(_lx, _ly, 400, 304);
  var _q_vent_n = (_hot > 0.55) ? 2 : 1;
  for (var _qv = 0; _qv < _q_vent_n; _qv++) {
    scr_spawn_vent_stream(quarter_vents, _lx, _ly,
                          _q_vent_dir + random_range(-26, 26),
                          0.35 + _hot * 0.6,
                          _k_q_vent_cols, _k_q_max_vents);
  }

  qamb = min(1.3, qamb + 0.012 + _hot * 0.018);
};

_k_stamp_x0 = 32;
_k_stamp_x1 = 768;
_k_stamp_floor_y = 576;
_k_stamp_ceil_y = 0;
_k_stamp_mid_x = (_k_stamp_x0 + _k_stamp_x1) * 0.5;

_k_stamp_safe_x0 = 338;
_k_stamp_safe_x1 = 462;

_k_stamp_beats = [ 1036, 1052, 1070, 1080, 1095, 1111, 1122, 1135, 1150, 1162 ];
_k_stamp_advance = [ 8, 10, 26, 26, 43, 46, 32, 37, 43, 35 ];

_k_stamp_rest_inset = 22;

_k_stamp_jaw_depth = 46;
_k_stamp_drive_rate = 0.42;
_k_stamp_snap = 0.7;

_k_stamp_col_pitch = 55.2;
_k_stamp_row_pitch = 48;
_k_stamp_rows = 12;
_k_stamp_orb_r = 8;
_k_stamp_row_base = 16;

_k_stamp_arch_rows = 2;
_k_stamp_mid_rows = 4;
_k_stamp_reach_y = 412;

_k_stamp_mid_chance = 0.42;
_k_stamp_deco_chance = 0.47;

_k_stamp_wall_runway = 1;

_k_stamp_orb_fade = 24;
_k_stamp_orb_spread = 10;

_k_stamp_spawn_clear = 58;

_k_stamp_window_margin = 8;

_k_stamp_density_edge = 0.36;
_k_stamp_density_core = 0.74;
_k_stamp_max_thread_run = 2;
_k_stamp_rest_window = 3;
_k_stamp_crush_warn = 70;

_k_stamp_lead_alpha = 0.5;
_k_stamp_lead_bracket = 0.55;
_k_stamp_lead_fill = 0.1;

_k_stamp_coil_fill = 0.22;
_k_stamp_read_floor = 0.17;
_k_stamp_coil_ease = 1.2;
_k_stamp_lock_life = 26;
_k_stamp_lock_tick = 14;

_k_stamp_vent_cols = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];
_k_stamp_col_press = global.avoid_col_warning;
_k_stamp_col_safe = global.avoid_col_cyan;
_k_stamp_col_frame = global.avoid_col_armor_mid;
_k_stamp_col_edge = global.avoid_col_armor_edge;
_k_stamp_col_body = global.avoid_col_armor_dark;

_k_stamp_shake_slam = 7;
_k_stamp_zoom_slam = 0.045;
_k_stamp_flash_slam = 0.09;
_k_stamp_shake_blowout = 16;
_k_stamp_letterbox = 0.45;
_k_stamp_vent_cap = 96;
_k_stamp_spark_cap = 170;
_k_stamp_shard_cap = 110;

_k_stamp_t_arm = 995;
_k_stamp_t_blowout = 1172;
_k_stamp_t_clear = 1213;

_k_stamp_run_rate = 3.0;
_k_stamp_safety = 1.0;
_k_stamp_player_w = 11;
_k_stamp_player_h = 21;

#macro STAMP_OPEN   0
#macro STAMP_HOP    1
#macro STAMP_THREAD 2
#macro STAMP_DUCK   3

_k_stamp_grid_cols = floor((_k_stamp_x1 - _k_stamp_x0) / _k_stamp_col_pitch);

stamp_grid_x = function(_i) {
  return _k_stamp_x0 + (_i + 0.5) * _k_stamp_col_pitch;
};
stamp_grid_y = function(_j) {
  return _k_stamp_floor_y - _k_stamp_row_base - _j * _k_stamp_row_pitch;
};

stamp_face_at = function(_side, _n) {
  if (_n <= 0) {
    return (_side == 0) ? _k_stamp_x0 - _k_stamp_rest_inset
                        : _k_stamp_x1 + _k_stamp_rest_inset;
  }
  var _d = 0;
  for (var _i = 0; _i < min(_n, array_length(_k_stamp_advance)); _i++) {
    _d += _k_stamp_advance[_i];
  }
  return (_side == 0) ? _k_stamp_x0 + _d : _k_stamp_x1 - _d;
};

stamp_in_safe = function(_x) {
  return (_x >= _k_stamp_safe_x0 && _x <= _k_stamp_safe_x1);
};

stamp_col_blocked = function(_i) {
  var _cx = stamp_grid_x(_i);
  var _half = _k_stamp_col_pitch * 0.5;
  return (_cx + _half > _k_stamp_safe_x0 - _k_stamp_orb_r) &&
         (_cx - _half < _k_stamp_safe_x1 + _k_stamp_orb_r);
};

stamp_build_grid = function(_seed) {
  var _prev = random_get_seed();
  random_set_seed(_seed);

  stamp_orbs = [];

  var _thread_run = 0;
  var _since_rest = 0;

  for (var _i = 0; _i < _k_stamp_grid_cols; _i++) {
    var _cx = stamp_grid_x(_i);

    if (stamp_col_blocked(_i)) {
      _thread_run = 0;
      _since_rest = 0;

      for (var _bd = _k_stamp_mid_rows; _bd < _k_stamp_rows; _bd++) {
        if (random(1) >= _k_stamp_deco_chance) continue;
        array_push(stamp_orbs, {
          col : _i, row : _bd, type : STAMP_OPEN,
          x : _cx, y : stamp_grid_y(_bd),
          seed : random(1000),
          spin : random_range(-1.4, 1.4),
          spawn : 0,
          delay : 0,
          flare : 0, pulse : 0, crushed : false
        });
      }
      continue;
    }

    var _near = 1 - clamp(min(abs(_cx - _k_stamp_safe_x0), abs(_cx - _k_stamp_safe_x1))
                          / ((_k_stamp_safe_x0 - _k_stamp_x0)), 0, 1);
    var _density = lerp(_k_stamp_density_edge, _k_stamp_density_core, _near);

    var _type = STAMP_OPEN;

    var _runway = (_i < _k_stamp_wall_runway) ||
                  (_i >= _k_stamp_grid_cols - _k_stamp_wall_runway);

    if (!_runway && random(1) < _density) {
      var _r = random(1);
      if (_r < 0.42)      _type = STAMP_HOP;
      else if (_r < 0.78) _type = STAMP_THREAD;
      else                _type = STAMP_DUCK;
    }

    if (_type == STAMP_THREAD) {
      if (_thread_run >= _k_stamp_max_thread_run) _type = STAMP_HOP;
    }
    if (_since_rest >= _k_stamp_rest_window - 1 &&
        (_type == STAMP_HOP || _type == STAMP_THREAD)) {
      _type = (random(1) < 0.5) ? STAMP_OPEN : STAMP_DUCK;
    }

    _thread_run = (_type == STAMP_THREAD) ? _thread_run + 1 : 0;
    _since_rest = (_type == STAMP_HOP || _type == STAMP_THREAD) ? _since_rest + 1 : 0;

    var _rows = [];
    switch (_type) {
      case STAMP_HOP:    _rows = [ 0 ];    break;
      case STAMP_THREAD: _rows = [ 0, 1 ]; break;
      case STAMP_DUCK:   _rows = [ 1 ];    break;
    }

    var _flight_clear = (_type == STAMP_OPEN || _type == STAMP_DUCK);
    if (_flight_clear) {
      for (var _m = _k_stamp_arch_rows; _m < _k_stamp_mid_rows; _m++) {
        if (random(1) < _k_stamp_mid_chance) array_push(_rows, _m);
      }
    }

    for (var _d2 = _k_stamp_mid_rows; _d2 < _k_stamp_rows; _d2++) {
      if (random(1) < _k_stamp_deco_chance) array_push(_rows, _d2);
    }

    for (var _n = 0; _n < array_length(_rows); _n++) {
      var _row = _rows[_n];

      var _wall_d = min(_cx - _k_stamp_x0, _k_stamp_x1 - _cx);
      var _delay = (1 - clamp(_wall_d / 260, 0, 1)) * _k_stamp_orb_spread;

      array_push(stamp_orbs, {
        col : _i,
        row : _row,
        type : _type,
        x : _cx,
        y : stamp_grid_y(_row),
        seed : random(1000),
        spin : random_range(-1.4, 1.4),
        spawn : 0,
        delay : _delay,
        flare : 0,
        pulse : 0,
        crushed : false
      });
    }
  }

  random_set_seed(_prev);
};

stamp_ensure_floor_block = function(_px, _py) {
  var _has_left = false;
  var _has_right = false;

  for (var _i = 0; _i < array_length(stamp_orbs); _i++) {
    if (stamp_orbs[_i].row != 0) continue;
    if (stamp_orbs[_i].x < _k_stamp_mid_x) _has_left = true;
    else _has_right = true;
  }

  if (_has_left && _has_right) return;

  for (var _side = 0; _side < 2; _side++) {
    var _want_left = (_side == 0);
    if (_want_left && _has_left) continue;
    if (!_want_left && _has_right) continue;

    var _best_col = -1;
    var _best_d = -1;

    for (var _i = 0; _i < _k_stamp_grid_cols; _i++) {
      var _runway = (_i < _k_stamp_wall_runway) ||
                    (_i >= _k_stamp_grid_cols - _k_stamp_wall_runway);
      if (_runway || stamp_col_blocked(_i)) continue;

      var _cx = stamp_grid_x(_i);
      if ((_cx < _k_stamp_mid_x) != _want_left) continue;

      var _d = point_distance(_cx, stamp_grid_y(0), _px, _py);
      if (_d > _best_d) {
        _best_d = _d;
        _best_col = _i;
      }
    }

    if (_best_col == -1 || _best_d < _k_stamp_spawn_clear) continue;

    var _fcx = stamp_grid_x(_best_col);
    var _wall_d = min(_fcx - _k_stamp_x0, _k_stamp_x1 - _fcx);

    array_push(stamp_orbs, {
      col : _best_col,
      row : 0,
      type : STAMP_HOP,
      x : _fcx,
      y : stamp_grid_y(0),
      seed : random(1000),
      spin : random_range(-1.4, 1.4),
      spawn : 0,
      delay : (1 - clamp(_wall_d / 260, 0, 1)) * _k_stamp_orb_spread,
      flare : 0,
      pulse : 0,
      crushed : false
    });
  }
};

if (array_length(_k_stamp_beats) != array_length(_k_stamp_advance)) {
  show_debug_message("STAMP: _k_stamp_beats has " + string(array_length(_k_stamp_beats))
                   + " entries but _k_stamp_advance has "
                   + string(array_length(_k_stamp_advance)));
}

var _sk_total = 0;
for (var _sa = 0; _sa < array_length(_k_stamp_advance); _sa++) {
  _sk_total += _k_stamp_advance[_sa];
}
var _sk_need = _k_stamp_safe_x0 - _k_stamp_x0;
if (abs(_sk_total - _sk_need) > 0.5) {
  show_debug_message("STAMP: the advances sum to " + string(_sk_total)
                   + "px but the wall has " + string(_sk_need)
                   + "px to cover before the safe room — the faces will "
                   + ((_sk_total > _sk_need) ? "CRUSH IT" : "stop short of it"));
}

for (var _sb = 0; _sb < array_length(_k_stamp_advance); _sb++) {
  var _sb_gap = (_sb > 0) ? (_k_stamp_beats[_sb] - _k_stamp_beats[_sb - 1])
                          : (_k_stamp_beats[0] - _k_stamp_t_arm);
  var _sb_buy = _sb_gap * _k_stamp_run_rate;
  if (_k_stamp_advance[_sb] > _sb_buy * _k_stamp_safety) {
    show_debug_message("STAMP: the slam at t" + string(_k_stamp_beats[_sb]) + " takes "
                     + string(_k_stamp_advance[_sb]) + "px against a " + string(_sb_buy)
                     + "px gap — a player standing on the face cannot outrun it");
  }
}

var _sk_cross = (_k_stamp_safe_x0 + _k_stamp_player_w * 0.5) - _k_stamp_x0;
var _sk_frames = _k_stamp_beats[array_length(_k_stamp_beats) - 1] - _k_stamp_t_arm;
if (_sk_cross > _sk_frames * _k_stamp_run_rate * _k_stamp_safety) {
  show_debug_message("STAMP: crossing to the safe room is " + string(_sk_cross)
                   + "px against " + string(_sk_frames * _k_stamp_run_rate)
                   + "px of run — there is no time for the lattice");
}

var _sk_window = _k_stamp_row_pitch - _k_stamp_orb_r * 2;
if (_sk_window < _k_stamp_player_h + _k_stamp_window_margin) {
  show_debug_message("STAMP: the lattice window is " + string(_sk_window)
                   + "px for a " + string(_k_stamp_player_h) + "px player — raise "
                   + "`_k_stamp_row_pitch` or lower `_k_stamp_orb_r`");
}

var _sk_land = _k_stamp_col_pitch - _k_stamp_orb_r * 2;
if (_sk_land < _k_stamp_player_w + 6) {
  show_debug_message("STAMP: adjacent floor nodes leave " + string(_sk_land)
                   + "px to land in for a " + string(_k_stamp_player_w) + "px player");
}

if (stamp_grid_y(0) + _k_stamp_orb_r < _k_stamp_floor_y - _k_stamp_player_h) {
  show_debug_message("STAMP: the floor row sits above a standing player's head — nothing "
                   + "in the lattice blocks running");
}

if (_k_stamp_rest_inset < 2) {
  show_debug_message("STAMP: the heads rest flush with the walls — a player standing against "
                   + "one is inside a lethal rect the moment the section arms");
}

var _sk_live_t = _k_stamp_t_arm + _k_stamp_orb_fade + _k_stamp_orb_spread;
if (_sk_live_t > _k_stamp_beats[0] - 4) {
  show_debug_message("STAMP: the lattice is not solid until t" + string(_sk_live_t)
                   + " but the first slam lands at t" + string(_k_stamp_beats[0]));
}

var _sk_thread_head = (_k_stamp_floor_y - _k_stamp_player_h)
                    - ((_k_stamp_floor_y - (stamp_grid_y(1) + _k_stamp_orb_r))
                       - _k_stamp_player_h);
if (stamp_grid_y(_k_stamp_arch_rows) + _k_stamp_orb_r > _sk_thread_head) {
  show_debug_message("STAMP: band 2 starts at y"
                   + string(stamp_grid_y(_k_stamp_arch_rows))
                   + " which a threading hop can already reach");
}

stamp_live = false;
stamp_armed = false;
stamp_dead = false;

stamp_face = [ _k_stamp_x0, _k_stamp_x1 ];
stamp_face_target = [ _k_stamp_x0, _k_stamp_x1 ];
stamp_face_heat = [ 0, 0 ];
stamp_face_flash = [ 0, 0 ];

stamp_orbs = [];
stamp_grid_seed = 0;

stamp_rail = 0;
stamp_amb = 0;
stamp_coil = 0;
stamp_heat = 0;
stamp_readout = 0;
stamp_slam_flash = 0;
stamp_beat_flash = 0;
stamp_blowout = 0;
stamp_chroma = 0;
stamp_hb = 0;
stamp_hb_phase = 0;

stamp_safe_glow = 0;
stamp_safe_seal = 0;
stamp_player_safe = false;
stamp_was_safe = false;

stamp_lock_frames = [];
stamp_vents = [];
stamp_sparks = [];
stamp_shards = [];
stamp_scars = [];
stamp_arcs = [];
stamp_tips = [];

_k_lorb_telegraph_t = 1189;
_k_lorb_start_t = 1209;
_k_lorb_beats = [ 1209, 1227, 1250, 1261, 1271 ];
_k_lorb_durations = [ 11, 13, 11, 10, 10 ];
_k_lorb_heads = [ 1, 1, 2, 2, 2 ];

lorb_storm = 0;
lorb_heat = 0;
lorb_beat_flash = 0;
lorb_arcs = [];
lorb_floor_hits = [];
lorb_sky_rifts = [];
lorb_impact_sparks = [];
lorb_seam_pulses = [];
lorb_lead_bursts = [];
lorb_lead_flash = 0;
lorb_lead_phase = 0;
lorb_lead_spawn = 0;
lorb_lead_despawn = 0;
lorb_lead_exit_x = 400;
lorb_lead_exit_y = 108;
lorb_seam = 0;
lorb_seam_flash = 0;

_k_lorb_floor_y = 576;
_k_lorb_pad = 34;
_k_lorb_spawn_band = 250;
_k_lorb_col_every = 4;
_k_lorb_slam_t = 1280;

lorb_amb = 0;
lorb_amb_hb = 0;
lorb_amb_hb_phase = 0;
lorb_amb_tick = 0;
lorb_countdown = 0;
lorb_eta = 999;
lorb_readout = 0;

lorb_front_live = false;
lorb_front_n = 0;
lorb_front_a = 0;
lorb_front_b = 0;
lorb_front_ay = 0;
lorb_front_by = 0;
lorb_front_parked = false;
lorb_front_dir = 1;
lorb_front_speed = 0;
lorb_front_beat = -1;

lorb_columns = [];
lorb_col_marks = [];
lorb_scorch = [];
lorb_floor_crack = [];

lorb_gap_x = 400;
lorb_gap_x_draw = 400;
lorb_gap_w = 0;
lorb_gap_flash = 0;

_k_lorb_mark_lead = 6;
_k_lorb_max_marks = 6;
_k_lorb_max_columns = 24;
_k_lorb_max_hits = 26;
_k_lorb_max_scorch = 44;
_k_lorb_max_crack = 10;
_k_lorb_max_rifts = 26;
_k_lorb_max_sparks = 140;
_k_lorb_max_seam_pulses = 10;
_k_lorb_max_lead_bursts = 12;
_k_lorb_predict = 3;

_k_lorb_debug_counts = false;
_k_lorb_whip = 0.55;

_k_lorb_amp0 = 78;       
_k_lorb_amp1 = 48;            
_k_lorb_mid0 = 146;
_k_lorb_mid1 = 118;
_k_lorb_hub_x = 400;
_k_lorb_hub_y = 110;
_k_lorb_conv_belly = 78;  
_k_lorb_sweep_bow = 46;      
_k_lorb_sweep_skew = 0.22;   

_k_lorb_stamp_frames = [ 2, 2, 2, 2, 2 ];
_k_lorb_ghosts = 4;         

_k_lorb_orb_every_stamp = [ 1, 1, 3, 3, 2 ];

_k_lorb_strike_every = 2;
_k_lorb_strike_life = 5;
_k_lorb_max_strikes = 44;
_k_lorb_strike_forks = 3;
_k_lorb_fray = 13;     

_k_lorb_trail_px = 190;
_k_lorb_trail_min_f = 1.8;
_k_lorb_trail_max_f = 5.0;
_k_lorb_trail_step = 0.22;  
_k_lorb_scar_step = 0.5;    
_k_lorb_scar_life = 40;
_k_lorb_max_scars = 8;
_k_lorb_max_wall_hits = 8;
_k_lorb_max_drips = 30;
_k_lorb_max_head_sparks = 64;
_k_lorb_strike_cols = [ global.avoid_col_cyan, global.avoid_col_cyan_soft,
                        global.avoid_col_cyan, global.avoid_col_violet ];

lorb_strikes = [];
lorb_strike_flash = 0;
lorb_park = 0;           
lorb_seed = irandom(99999);
lorb_roll = function(_a, _b) {
  var _h = frac(sin((lorb_seed * 0.0013 + _a * 12.9898 + _b * 78.233)) * 43758.5453);
  return (_h < 0) ? -_h : _h;
};

lorb_scars = [];
lorb_wall_hits = [];
lorb_drips = [];
lorb_head_sparks = [];

lorb_trail_frames = function(_speed) {
  return clamp(_k_lorb_trail_px / max(_speed, 6), _k_lorb_trail_min_f, _k_lorb_trail_max_f);
};

lorb_beat_at = function(_f) {
  for (var _bi = 0; _bi < array_length(_k_lorb_beats); _bi++) {
    if (_f >= _k_lorb_beats[_bi] && _f < _k_lorb_beats[_bi] + _k_lorb_durations[_bi]) return _bi;
  }
  return -1;
};

lorb_ease_whip = function(_u) {
  var _s = _u * _u * (3 - 2 * _u);
  return lerp(_u, _s, _k_lorb_whip);
};

lorb_resolve = function(_f) {
  var _n = array_length(_k_lorb_beats);

  for (var _i = 0; _i < _n; _i++) {
    if (_f < _k_lorb_beats[_i]) {
      if (_i == 0) return { b : 0, f : _k_lorb_beats[0], parked : true, park_p : 0 };

      var _pe = _k_lorb_beats[_i - 1] + _k_lorb_durations[_i - 1];
      var _rest = max(1, _k_lorb_beats[_i] - _pe);

      return { b : _i - 1, f : _pe - 0.0001, parked : true,
               park_p : clamp((_f - _pe) / _rest, 0, 1) };
    }

    if (_f < _k_lorb_beats[_i] + _k_lorb_durations[_i]) {
      return { b : _i, f : _f, parked : false, park_p : 0 };
    }
  }

  var _lb = _n - 1;

  return { b : _lb, f : _k_lorb_beats[_lb] + _k_lorb_durations[_lb] - 0.0001,
           parked : true, park_p : 1 };
};

lorb_head_at = function(_f, _lane = 0) {
  var _last = array_length(_k_lorb_beats) - 1;
  var _res = lorb_resolve(_f);
  var _b = _res.b;

  _f = _res.f;

  var _u = clamp((_f - _k_lorb_beats[_b]) / _k_lorb_durations[_b], 0, 1);
  var _e = lorb_ease_whip(_u);
  var _g = _b + _u;
  var _amp = lerp(_k_lorb_amp0, _k_lorb_amp1, _g / (_last + 1));
  var _mid = lerp(_k_lorb_mid0, _k_lorb_mid1, _g / (_last + 1));

  var _x, _y;

  if (_b < _last) {
    var _rev = ((_b mod 2) == 0);
    if (_lane > 0) _rev = !_rev;             

    _x = _rev ? lerp(0, room_width, _e) : lerp(room_width, 0, _e);
    _y = _mid - _amp * cos(pi * _g) * ((_lane > 0) ? -1 : 1);

    var _bow = (lorb_roll(_b, 1 + _lane * 7) * 2 - 1) * _k_lorb_sweep_bow;
    var _skew = clamp(0.5 + (lorb_roll(_b, 2 + _lane * 7) * 2 - 1) * _k_lorb_sweep_skew, 0.2, 0.8);
    var _bu = (_u < _skew) ? (_u / _skew) * 0.5 : 0.5 + ((_u - _skew) / (1 - _skew)) * 0.5;

    _y += (1 - cos(2 * pi * _bu)) * 0.5 * _bow * abs(sin(pi * _g));
  } else {

    var _amp4 = lerp(_k_lorb_amp0, _k_lorb_amp1, _last / (_last + 1));
    var _mid4 = lerp(_k_lorb_mid0, _k_lorb_mid1, _last / (_last + 1));
    var _from = (_lane > 0) ? (_mid4 + _amp4) : (_mid4 - _amp4);
    var _bell = (1 - cos(2 * pi * _u)) * 0.5;
    var _belly = (_lane > 0) ? -_k_lorb_conv_belly : _k_lorb_conv_belly;

    _x = (_lane > 0) ? lerp(room_width, _k_lorb_hub_x, _e) : lerp(0, _k_lorb_hub_x, _e);
    _y = lerp(_from, _k_lorb_hub_y, _u * _u * (3 - 2 * _u)) + _bell * _belly;
  }

  return { x : _x, y : clamp(_y, 40, _k_lorb_spawn_band - 6) };
};

lorb_stamp_f = function(_f, _lane = 0) {
  var _res = lorb_resolve(_f);
  var _b = _res.b;

  _f = _res.f;

  var _step = _k_lorb_stamp_frames[_b];
  var _off = _lane * floor(_step * 0.5);
  var _rel = _f - _k_lorb_beats[_b] - _off;

  return max(_k_lorb_beats[_b], _k_lorb_beats[_b] + _off + floor(_rel / _step) * _step);
};

lorb_stamp_at = function(_f, _lane = 0) {
  return lorb_head_at(lorb_stamp_f(_f, _lane), _lane);
};

lorb_stamp_index = function(_f, _lane = 0) {
  var _b = lorb_resolve(_f).b;
  var _step = _k_lorb_stamp_frames[_b];
  var _off = _lane * floor(_step * 0.5);

  return max(0, floor((lorb_stamp_f(_f, _lane) - _k_lorb_beats[_b] - _off) / _step));
};

lorb_stamp_age = function(_f, _lane = 0) {
  var _b = lorb_resolve(_f).b;

  return clamp((_f - lorb_stamp_f(_f, _lane)) / _k_lorb_stamp_frames[_b], 0, 1);
};

lorb_front_at = function(_f) {
  var _last = array_length(_k_lorb_beats) - 1;
  var _end = _k_lorb_beats[_last] + _k_lorb_durations[_last];

  if (_f < _k_lorb_beats[0] || _f >= _end) {
    return { n : 0, a : 0, b : 0, ay : 0, by : 0, dir : 1, speed : 0, vx : 0, vy : 0,
             jitter : 0, grav : 1, beat : -1, parked : false, park_p : 0 };
  }

  var _res = lorb_resolve(_f);
  var _b = _res.b;
  var _esc = _b / 3;

  var _h0 = lorb_stamp_at(_f, 0);
  var _prev = lorb_head_at(_f - 0.5, 0);
  var _next = lorb_head_at(_f + 0.5, 0);

  if (_b < _last) {
    var _n = _k_lorb_heads[_b];
    var _hb = (_n > 1) ? lorb_stamp_at(_f, 1) : { x : 0, y : 0 };

    return {
      n : _n,
      a : _h0.x,
      b : _hb.x,
      ay : _h0.y,
      by : _hb.y,
      dir : ((_b mod 2) == 0) ? 1 : -1,
      vx : _next.x - _prev.x,
      vy : _next.y - _prev.y,
      speed : point_distance(_prev.x, _prev.y, _next.x, _next.y),
      jitter : lerp(40, 15, _esc),
      grav : lerp(0.5, 1.0, _esc),
      beat : _b,
      parked : _res.parked,
      park_p : _res.park_p
    };
  }

  var _h1 = lorb_stamp_at(_f, 1);

  return {
    n : 2,
    a : _h0.x,
    b : _h1.x,
    ay : _h0.y,
    by : _h1.y,
    dir : 1,
    vx : _next.x - _prev.x,
    vy : _next.y - _prev.y,
    speed : point_distance(_prev.x, _prev.y, _next.x, _next.y),
    jitter : 12,
    grav : 1.1,
    beat : _b,
    parked : _res.parked,
    park_p : _res.park_p
  };
};

lorb_lead_y_at = function(_f, _lane) {
  return lorb_head_at(_f, _lane).y;
};


lorb_path_points = function(_f0, _f1, _lane, _step, _fray = 0, _fray_seed = 0, _stamp = true) {
  var _res = lorb_resolve(_f1);
  var _b = _res.b;

  if (_lane > 0 && _k_lorb_heads[_b] < 2) return [];

  var _lo = max(_k_lorb_beats[_b], _f0);
  var _hi = min(_k_lorb_beats[_b] + _k_lorb_durations[_b] - 0.001, _f1);

  if (_hi - _lo <= 0.05) return [];

  var _span = _hi - _lo;
  var _n = clamp(ceil(_span / max(0.05, _step)), 2, 96);
  var _pts = array_create(_n + 1);

  for (var _i = 0; _i <= _n; _i++) {
    var _u = _i / _n;
    var _at = _lo + _span * _u;
    var _h = _stamp ? lorb_stamp_at(_at, _lane) : lorb_head_at(_at, _lane);
    var _px = _h.x;
    var _py = _h.y;


    if (_fray > 0 && _i > 0 && _i < _n) {
      var _hn = lorb_head_at(_at + 0.4, _lane);
      var _dx = _hn.x - _h.x;
      var _dy = _hn.y - _h.y;
      var _dl = max(0.0001, sqrt(_dx * _dx + _dy * _dy));
      var _amt = sin(_fray_seed + _i * 2.7) * _fray * sin(pi * _u);

      _px += (-_dy / _dl) * _amt;
      _py += ( _dx / _dl) * _amt;
    }

    _pts[_i] = { px : _px, py : _py, u : _u };
  }

  return _pts;
};

lorb_push_strike = function(_x1, _y1, _x2, _y2, _hot, _wide) {
  if (array_length(lorb_strikes) >= _k_lorb_max_strikes) array_delete(lorb_strikes, 0, 1);

  var _len = max(1, point_distance(_x1, _y1, _x2, _y2));
  var _dir = point_direction(_x1, _y1, _x2, _y2);
  var _forks = [];
  var _nf = irandom(_k_lorb_strike_forks);

  for (var _fi = 0; _fi < _nf; _fi++) {
    var _at = random_range(0.15, 0.95);
    var _fa = _dir + choose(-1, 1) * random_range(38, 118);
    var _fl = _len * random_range(0.25, 0.8) + random_range(20, 70);

    array_push(_forks, {
      x1 : lerp(_x1, _x2, _at),
      y1 : lerp(_y1, _y2, _at),
      x2 : lerp(_x1, _x2, _at) + lengthdir_x(_fl, _fa),
      y2 : lerp(_y1, _y2, _at) + lengthdir_y(_fl, _fa),
      off : scr_bolt_offsets(3 + irandom(2), 8 + _hot * 20),
      w : 0.5 + _hot * 0.9,
      col : _k_lorb_strike_cols[irandom(array_length(_k_lorb_strike_cols) - 1)]
    });
  }

  array_push(lorb_strikes, {
    x1 : _x1, y1 : _y1,
    x2 : _x2, y2 : _y2,
    hot : _hot,
    wide : _wide,
    life : _k_lorb_strike_life + irandom(2),
    life_max : _k_lorb_strike_life + 2,
    width : (1.1 + _hot * 1.7) * (_wide ? 1.5 : 1),
    off : scr_bolt_offsets(4 + irandom(3), (10 + _hot * 26) * (_wide ? 1.4 : 1)),
    forks : _forks,
    col : _k_lorb_strike_cols[irandom(array_length(_k_lorb_strike_cols) - 1)],
    seed : random(1000)
  });
};

lorb_push_scar = function(_f0, _f1, _lane, _hot) {
  if (array_length(lorb_scars) >= _k_lorb_max_scars) array_delete(lorb_scars, 0, 1);

  array_push(lorb_scars, {
    f0 : _f0,
    f1 : _f1,
    lane : _lane,
    hot : _hot,
    life : _k_lorb_scar_life,
    life_max : _k_lorb_scar_life,
    seed : random(1000)
  });
};

lorb_push_wall_hit = function(_x, _y, _dir, _hot) {
  if (array_length(lorb_wall_hits) >= _k_lorb_max_wall_hits) array_delete(lorb_wall_hits, 0, 1);

  array_push(lorb_wall_hits, {
    x : _x,
    y : _y,
    dir : _dir,
    hot : _hot,
    life : 20 + round(_hot * 8),
    life_max : 28,
    radius : 6,
    max_radius : 74 + _hot * 90,
    seed : random(1000),
    off : scr_bolt_offsets(6, 16 + _hot * 20)
  });
};

lorb_push_drip = function(_x, _y, _hot) {
  if (array_length(lorb_drips) >= _k_lorb_max_drips) array_delete(lorb_drips, 0, 1);

  array_push(lorb_drips, {
    x : _x,
    y : _y,
    hot : _hot,
    life : 11 + irandom(6),
    life_max : 17,
    reach : random_range(26, 58) * (0.7 + _hot * 0.6),
    seed : random(1000)
  });
};

lorb_fall_frames = function(_y0, _g) {
  return sqrt(2 * max(1, _k_lorb_floor_y - _y0) / max(_g, 0.01));
};

lorb_push_column = function(_sx, _y0, _g, _band, _banded, _beat) {
  var _fall = lorb_fall_frames(_y0, _g);

  array_push(lorb_columns, {
    sx : _sx,
    band : _band,
    banded : _banded,
    spawn_t : t,
    land_t : t + _fall,
    fall : _fall,
    y0 : _y0,
    g : _g,
    beat : _beat,
    hot : 0.35 + lorb_countdown * 0.65,
    seed : random(1000),
    slice : random_range(0.7, 1.35),
    landed : false
  });

  if (array_length(lorb_columns) > _k_lorb_max_columns) array_delete(lorb_columns, 0, 1);
};

lorb_push_head_spark = function(_x, _y, _vx, _vy, _hot) {
  if (array_length(lorb_head_sparks) >= _k_lorb_max_head_sparks) array_delete(lorb_head_sparks, 0, 1);

  var _life = 8 + irandom(9);

  array_push(lorb_head_sparks, {
    x : _x,
    y : _y,
    px : _x,
    py : _y,
    vx : _vx,
    vy : _vy,
    hot : _hot,
    life : _life,
    life_max : _life,
    drag : random_range(0.85, 0.93),
    grav : random_range(0.04, 0.22),
    size : random_range(0.7, 2.2 + _hot)
  });
};

lorb_push_lead_burst = function(_x, _y, _dir, _hot) {
  if (array_length(lorb_lead_bursts) >= _k_lorb_max_lead_bursts) array_delete(lorb_lead_bursts, 0, 1);

  var _life = 20 + round(_hot * 8);

  array_push(lorb_lead_bursts, {
    x : _x,
    y : _y,
    dir : _dir,
    hot : _hot,
    life : _life,
    life_max : _life,
    radius : 6,
    max_radius : 72 + _hot * 86,
    width : 10 + _hot * 10,
    seed : random(1000),
    off : scr_bolt_offsets(5, 16 + _hot * 24)
  });
};

lorb_push_sky_rift = function(_x, _hot, _reach) {
  if (array_length(lorb_sky_rifts) >= _k_lorb_max_rifts) array_delete(lorb_sky_rifts, 0, 1);

  var _y0 = random_range(-18, 18);
  var _drift = random_range(-52, 52);

  array_push(lorb_sky_rifts, {
    x1 : clamp(_x, -40, room_width + 40),
    y1 : _y0,
    x2 : clamp(_x + _drift, -60, room_width + 60),
    y2 : _y0 + _reach,
    life : 12 + irandom(8),
    life_max : 20,
    hot : _hot,
    width : 0.9 + _hot * 1.6,
    seed : random(1000),
    off : scr_bolt_offsets(5, 10 + _hot * 22)
  });
};

lorb_push_seam_pulse = function(_hot) {
  if (array_length(lorb_seam_pulses) >= _k_lorb_max_seam_pulses) array_delete(lorb_seam_pulses, 0, 1);

  array_push(lorb_seam_pulses, {
    y : random_range(52, 168),
    radius : 8,
    max_radius : 90 + _hot * 170,
    life : 18 + round(_hot * 10),
    life_max : 28,
    width : 7 + _hot * 12,
    hot : _hot,
    seed : random(1000)
  });
};

lorb_push_impact_sparks = function(_x, _y, _hot, _count) {
  for (var _li = 0; _li < _count; _li++) {
    if (array_length(lorb_impact_sparks) >= _k_lorb_max_sparks) array_delete(lorb_impact_sparks, 0, 1);

    var _sa = random_range(20, 160);
    var _ss = random_range(2.0, 6.0 + _hot * 4);

    array_push(lorb_impact_sparks, {
      x : _x + random_range(-5, 5),
      y : _y - random_range(0, 4),
      px : _x,
      py : _y,
      vx : lengthdir_x(_ss, _sa),
      vy : lengthdir_y(_ss, _sa) - random_range(1.2, 3.4),
      life : 14 + irandom(12),
      life_max : 26,
      size : random_range(0.7, 2.2 + _hot),
      hot : _hot,
      drag : random_range(0.88, 0.94),
      grav : random_range(0.16, 0.28)
    });
  }
};

lorb_land_orb = function(_lx, _hot) {
  var _fx = clamp(_lx, _k_lorb_pad, room_width - _k_lorb_pad);
  var _fy = _k_lorb_floor_y;

  array_push(lorb_floor_hits, {
    x : _fx,
    y : _fy,
    life : 20 + irandom(8),
    max_life : 28,
    radius : 3,
    max_radius : 16 + _hot * 26,
    hot : _hot,
    seed : random(1000)
  });

  if (array_length(lorb_floor_hits) > _k_lorb_max_hits) array_delete(lorb_floor_hits, 0, 1);

  array_push(lorb_scorch, {
    x : _fx,
    w : 13 + _hot * 20 + random(9),
    alpha : 0.55 + _hot * 0.45,
    hot : _hot,
    seed : random(1000)
  });

  if (array_length(lorb_scorch) > _k_lorb_max_scorch) array_delete(lorb_scorch, 0, 1);

  lorb_push_impact_sparks(_fx, _fy, _hot, 4 + round(_hot * 6));

  array_push(lorb_arcs, {
    x1 : _fx + random_range(-20, 20),
    y1 : random_range(0, 36),
    x2 : _fx + random_range(-8, 8),
    y2 : _fy - random_range(28, 66),
    life : 6,
    max_life : 6,
    hot : _hot,
    width : 0.8 + _hot * 1.1,
    off : scr_bolt_offsets(5, 10 + _hot * 16)
  });

  array_push(ring_shockwaves, {
    x : _fx, y : _fy,
    radius : 4,
    max_radius : 22 + _hot * 26,
    life : 14, max_life : 14,
    width : 4 + _hot * 5,
    hot : _hot * 0.7,
    vs : 0.3
  });

  for (var _lp = 0; _lp < 3 + irandom(3); _lp++) {
    var _sa = random_range(-70, 70) + (irandom(1) ? 180 : 0);
    var _ss = random_range(1.6, 4.6);

    array_push(arrow_ring_particles, {
      x : _fx, y : _fy,
      vx : lengthdir_x(_ss, _sa),
      vy : lengthdir_y(_ss, _sa) - random(1.2),
      life : 14, max_life : 14,
      size : random_range(0.07, 0.21),
      grav : 0.3,
      drag : 0.93,
      hot : 0.5 + _hot * 0.45
    });
  }

  if (irandom(1) == 0) {
    array_push(lorb_floor_crack, {
      x : _fx,
      life : 6, life_max : 6,
      len : random_range(26, 54 + _hot * 40),
      dir : choose(-1, 1)
    });

    if (array_length(lorb_floor_crack) > _k_lorb_max_crack) array_delete(lorb_floor_crack, 0, 1);
  }

  scr_floor_impact(_fx, _fy, 0.26 + _hot * 0.5, (_hot > 0.8 && irandom(2) == 0) ? 1 : 0,
                   merge_color(global.lightning_color, c_white, 0.35));
  scr_add_light(_fx, _fy - 28, merge_color(global.lightning_color, c_white, 0.35), 1.2 + _hot * 1.8);

  lorb_amb = min(1.35, lorb_amb + 0.01 + _hot * 0.014);
};

test_scythe = [];
test_scythe_time = 0;
test_scythe_active = false;

jump_rope_spawn_t = 3560;

jump_rope_beats = [ 3667, 3710, 3752, 3790, 3829, 3852, 3873, 3895 ];

_k_jr_taut_t = 3566;

_k_jr_detonate_t = 3915;

jump_rope_key_times = [jump_rope_spawn_t];

array_copy(jump_rope_key_times, 1, jump_rope_beats, 0, array_length(jump_rope_beats));

_k_jr_floor_y = 576;

_k_jr_anchor_left_x = 60;
_k_jr_anchor_right_x = 740;

_k_jr_anchor_y = _k_jr_floor_y - 66;

_k_jr_anchor_swing_x = 9;

jump_rope_anchor_left_x = _k_jr_anchor_left_x;
jump_rope_anchor_right_x = _k_jr_anchor_right_x;

_k_jr_amp_y = 260;

_k_jr_fade_in_frames = 90;

_k_jr_hazard_window = 0.35;

_k_jr_bullet_count = 30;

jump_rope_phase = 0;

jump_rope_depth = 1;

jump_rope_mid_x = 0;

jump_rope_mid_y = 0;

jump_rope_alpha = 0;

jump_rope_anchor_left_y = _k_jr_anchor_y;
jump_rope_anchor_right_y = _k_jr_anchor_y;

jump_rope_hazard_active = false;

jump_rope_bullets = [];

_k_jr_twist_amp = 10;

_k_jr_twist_freq = 3;

jump_rope_color_far = _k_er_col_armor_edge;

jump_rope_color_near = _k_er_col_white;

jump_rope_beat_index = 0;

_k_jr_anchor_sway = 14;

jump_rope_prev_hazard_active = false;

jump_rope_telegraph_prog = 0;

jump_rope_finished = false;

jump_rope_dust = [];

_k_jr_fade_out_frames = 60;

_k_jr_telegraph_lead = 20;

_k_jr_shine_speed = 0.08;

_k_jr_bullet_bias = 1.8;

_k_jr_dust_count = 10;

jump_rope_figure_bounce = 0;

_k_jr_figure_scale = 2;

_k_jr_figure_stand_offset = 25;

jr_weave = 0;
jr_taut_flash = 0;
jr_coil = 0;
jr_crack_flash = 0;
jr_heartbeat = 0;
jr_heartbeat_phase = 0;
jr_chroma = 0;
jr_escalation = 0;
jr_detonated = false;
jr_detonate_flash = 0;
jr_anchor_heat = [0, 0];
jr_handle_spin = 0;

_k_jr_weave_frames = 26;
_k_jr_coil_lead = 12;
_k_jr_ghost_interval = 3;
_k_jr_ghost_cap = 14;
_k_jr_scorch_cap = 10;
_k_jr_arc_cap = 26;
_k_jr_crack_span = 300;
_k_jr_stream_cap = 80;
_k_jr_scan_cap = 24;
_k_jr_lock_cap = 12;

jr_ghosts = [];
jr_scorches = [];
jr_arcs = [];
jr_shards = [];
jr_reactor_streams = [];
jr_scan_sweeps = [];
jr_lock_frames = [];
jr_ghost_timer = 0;
jr_lock_index = -99;

jr_curve_pts = [];
jr_curve_t = -1;

push_waves = [];
_k_push_wave_speed = 26;
_k_push_wave_life = 44;
_k_push_wave_cap = 6;
push_orb_arrival_flash = 0;

push_orb_gap_x = 400;
push_orb_gap_flash = 0;

push_orb_spawn_t = 3560;

push_orb_end_t = 4000;

push_orb_beat_index = 0;

push_orb_field = [];

_k_push_orb_field_count = 14;

_k_push_orb_idle_fall_speed = 0.6;

_k_push_orb_shove_base = 7;

_k_push_orb_shove_growth = 1.3;

_k_push_orb_wave_count = 5;

_k_push_orb_safe_gap = 100;

_k_push_orb_decay_rate = 0.06;

transition_fade_start_t = 3918;

transition_fade_full_t = 3985;

transition_reveal_t = 4000;

transition_black_alpha = 0;

transition_reveal_flash = 0;

_k_transition_cleanup_start_t = 3918;

_k_transition_cleanup_end_t = 3985;

_k_jr_wing_pickup_x = room_width / 2;
_k_jr_wing_pickup_y = 450;
_k_jr_wing_collect_stage = 4;
_k_jr_wing_collect_w = 58;
_k_jr_wing_collect_h = 58;
_k_jr_wing_drop_y = [158, 238, 318, 392, _k_jr_wing_pickup_y];

jr_wing_x = _k_jr_wing_pickup_x;
jr_wing_y = _k_jr_wing_drop_y[0];
jr_wing_drop_stage = 0;
jr_wing_ready = false;
jr_wing_slam = 0;
jr_wing_flash = 0;
jr_wing_collect_flash = 0;
jr_wing_prompt_timer = 0;
jr_wing_prompt_max = 96;
jr_wing_collect_x = jr_wing_x;
jr_wing_collect_y = jr_wing_y;
cube_wings_collected = false;
cube_wings_collect_t = -1;

big_orb_instance = -4;

big_orb_regions = [];

big_orb_rings = [];

big_orb_unwrap_index = 0;

quarter_circles = [];

warning_flash_timer = 0;
warning_band_ignited = false;
warning_band_ignite_t = 0;

laser_x_chains = [];
laser_x_marks = [];
laser_chain_arcs = [];
laser_chain_arc_id_counter = 0;

_k_laser_chain_glow_color = global.avoid_col_warning;
_k_laser_chain_arc_count_per_tick = 3;
_k_laser_chain_arc_interval = 8;
_k_laser_chain_arc_life = 10;
_k_laser_chain_arc_segments = 5;
_k_laser_chain_arc_jitter = 5;
laser_chain_arc_timer = 0;

laser_chain_spawn_flashes = [];
_k_laser_chain_spawn_flash_life = 14;
_k_laser_chain_spawn_flash_radius = 55;
_k_laser_x_mark_life = 78;
_k_laser_x_mark_active_life = 30;
_k_laser_x_mark_arm_len = 66;
_k_laser_x_mark_arm_width = 16;
_k_laser_x_mark_cap = 6;
_k_laser_x_mark_trigger_radius = 15;
_k_laser_x_mark_kill_width = 10;
_k_laser_x_mark_spark_count = 4;

laser_attack_positions = [];
laser_seed_drift_dir = choose(-1, 1);

_k_laser_seed_drift_frames = 25;
_k_laser_seed_drift_min = 28;
_k_laser_seed_drift_max = 88;
_k_laser_seed_drift_edge_margin = 28;
_k_laser_seed_drift_final_sep = 24;

_k_laser_beats = [1387, 1407, 1428, 1448, 1469, 1489, 1509, 1527, 1547, 1570, 1590, 1610, 1630, 1648];

_k_laser_t_lock_arm = 1364;
_k_laser_t_top_warn = 1395;
_k_laser_t_sweep = 1407;
_k_laser_t_chains = 1448;
_k_laser_t_center_warn = 1457;
_k_laser_t_center_fire = 1469;
_k_laser_t_cross_a = 1489;
_k_laser_t_cross_b = 1509;
_k_laser_t_volley_a = 1527;
_k_laser_t_volley_b = 1547;
_k_laser_t_edge_warn = 1558;
_k_laser_t_hsweep = 1570;
_k_laser_t_finale_beats = [1590, 1610, 1630];
_k_laser_t_finale = 1648;

_k_laser_beam_speed_mult = 1.2;

_k_laser_spiral_orb_count = 54;
_k_laser_spiral_arms = 3;
_k_laser_spiral_r_min = 16;
_k_laser_spiral_r_max = 535;
_k_laser_spiral_y_scale = 1.0;
_k_laser_spiral_angle_step = 20;
_k_laser_spiral_spawn_window = max(1, (_k_laser_t_center_fire - _k_laser_t_chains) - 3);
_k_laser_spiral_materialize_min = 5;
_k_laser_spiral_materialize_max = 9;

laser_clear_spiral_orbs = function() {
  with (oLaserOrb_Pop) {
    if (variable_instance_exists(id, "laser_spiral_orb") && laser_spiral_orb) instance_destroy();
  }
};

laser_spawn_spiral_orbs = function() {
  laser_clear_spiral_orbs();

  var _cx = room_width * 0.5;
  var _cy = room_height * 0.5;
  var _arms = max(1, _k_laser_spiral_arms);
  var _rings = max(1, ceil(_k_laser_spiral_orb_count / _arms));
  var _base = random(360);
  var _spawn_finish = _k_laser_spiral_spawn_window;
  var _mat_max = _k_laser_spiral_materialize_max + 2;
  var _delay_max = max(0, _spawn_finish - _mat_max);
  var _x_min = 8;
  var _x_max = room_width - 8;
  var _y_min = 8;
  var _y_max = room_height - 8;

  for (var _i = 0; _i < _k_laser_spiral_orb_count; _i++) {
    var _arm = _i mod _arms;
    var _ring = _i div _arms;
    var _rf = (_rings <= 1) ? 1 : (_ring / (_rings - 1));
    var _order_f = (_k_laser_spiral_orb_count <= 1) ? 0 : (_i / (_k_laser_spiral_orb_count - 1));
    var _ang = _base + (_arm * 360 / _arms) + _ring * _k_laser_spiral_angle_step;
    var _rad = lerp(_k_laser_spiral_r_min, _k_laser_spiral_r_max, power(_rf, 0.74));
    var _sx = clamp(_cx + lengthdir_x(_rad, _ang), _x_min, _x_max);
    var _sy = clamp(_cy + lengthdir_y(_rad, _ang) * _k_laser_spiral_y_scale, _y_min, _y_max);
    var _delay = round(_order_f * _delay_max);
    var _mat = round(lerp(_k_laser_spiral_materialize_min,
                          _k_laser_spiral_materialize_max,
                          _rf)) + irandom(2);
    var _scale = random_range(0.82, 1.02);

    with (instance_create_layer(_sx, _sy, layer, oLaserOrb_Pop)) {
      laser_meteor_visual = true;
      laser_spiral_orb = true;
      laser_spawn_delay = _delay;

      base_scale = _scale;
      materialize_duration = _mat;
      spawn_flash_duration = _mat + 3;
      idle_alpha_max_override = 0.5;
      idle_alpha_min_override = 0.5;
      image_alpha = 0.5;
      deadly_while_idle = false;
      laser_pop_enabled = true;
      pop_persist = false;
      _k_spawn_flash_color = global.avoid_col_cyan;
      _k_sustained_glow_color = global.avoid_col_danger;
      _k_shockwave_color = global.avoid_col_warning;
    }
  }

  array_push(ring_shockwaves, {
    x : _cx, y : _cy,
    radius : 16, max_radius : 340,
    life : 24, max_life : 24,
    width : 18, hot : 0.62, vs : 1
  });

  for (var _sp = 0; _sp < 34; _sp++) {
    var _pa = random(360);
    var _ps = random_range(2.4, 8.5);
    array_push(arrow_ring_particles, {
      x : _cx + lengthdir_x(random_range(0, 18), _pa),
      y : _cy + lengthdir_y(random_range(0, 18), _pa),
      vx : lengthdir_x(_ps, _pa),
      vy : lengthdir_y(_ps, _pa),
      life : 14 + irandom(14), max_life : 28,
      size : random_range(0.06, 0.15),
      grav : 0.04, drag : 0.94, hot : random_range(0.55, 1)
    });
  }

  scr_impact_pulse(0.22, 0.38, 0.32, _cx, _cy);
  global_ripple_pulse = max(global_ripple_pulse, 0.32);
};

laser_jump_warn_active = false;
laser_jump_warn_t = 0;
laser_jump_warn_len = 1;
laser_jump_warn_coil = 0;
laser_jump_warn_vents = [];
laser_jump_warn_arcs = [];
laser_jump_bursts = [];

_k_laser_jump_warn_lead = _k_er_side_burst_warn_lead;
_k_laser_jump_y = room_height - 64;
_k_laser_jump_burst_duration = _k_er_side_burst_duration;
_k_laser_jump_burst_hit_r = 28;
_k_laser_jump_warn_lane_r = _k_laser_jump_burst_hit_r + 12;
_k_laser_jump_warn_slot_a = _k_er_side_warn_slot_a;
_k_laser_jump_warn_slot_hold = _k_er_side_warn_slot_hold;
_k_laser_jump_warn_spill = _k_er_side_warn_spill;
_k_laser_jump_warn_read_floor = _k_er_side_warn_read_floor;
_k_laser_jump_warn_gate_w = _k_er_side_warn_gate_w;
_k_laser_jump_warn_packet_n = _k_er_side_warn_packet_n;
_k_laser_jump_warn_vent_cols = _k_er_side_warn_vent_cols;

laser_jump_clear = function() {
  laser_jump_warn_active = false;
  laser_jump_warn_t = 0;
  laser_jump_warn_coil = 0;
  laser_jump_warn_vents = [];
  laser_jump_warn_arcs = [];
  laser_jump_bursts = [];
  laser_clear_spiral_orbs();
};

laser_jump_start = function(_lead) {
  laser_jump_warn_active = true;
  laser_jump_warn_t = 0;
  laser_jump_warn_len = max(1, _lead);
  laser_jump_warn_coil = _k_laser_jump_warn_read_floor;
  laser_jump_warn_vents = [];
  laser_jump_warn_arcs = [];
  laser_jump_bursts = [];
};

laser_jump_fire = function() {
  laser_jump_warn_active = false;
  laser_jump_warn_coil = 1;
  laser_jump_bursts = [];

  var _side_col = merge_color(_k_er_col_hot, c_white, 0.55);
  array_push(laser_jump_bursts, {
    dir : 1,
    y : _k_laser_jump_y,
    life : _k_laser_jump_burst_duration,
    life_max : _k_laser_jump_burst_duration,
    seed : random(1000),
    col : _side_col
  });
  array_push(laser_jump_bursts, {
    dir : -1,
    y : _k_laser_jump_y,
    life : _k_laser_jump_burst_duration,
    life_max : _k_laser_jump_burst_duration,
    seed : random(1000),
    col : _side_col
  });

  for (var _es = 0; _es < 2; _es++) {
    var _edir = (_es == 0) ? 1 : -1;
    var _edge_x = (_es == 0) ? 0 : room_width;
    repeat(18) {
      array_push(arrow_ring_particles, {
        x : _edge_x + _edir * random_range(0, 10),
        y : _k_laser_jump_y + random_range(-18, 18),
        vx : _edir * random_range(2.5, 7.0),
        vy : random_range(-3.2, 2.0),
        life : irandom_range(18, 30),
        max_life : 30,
        size : random_range(0.08, 0.18),
        grav : 0.12,
        drag : 0.92,
        hot : random_range(0.75, 1)
      });
    }
  }

  scr_impact_pulse(0.28, 0.55, 0.35, room_width / 2, _k_laser_jump_y);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 7);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.08);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.12);
  }
};

laser_jump_update = function() {
  if (laser_jump_warn_active) {
    laser_jump_warn_t++;
    var _raw = clamp(laser_jump_warn_t / max(laser_jump_warn_len, 1), 0, 1);
    laser_jump_warn_coil = max(_raw, _k_laser_jump_warn_read_floor);

    var _sw_c = laser_jump_warn_coil;
    var _sw_head = lerp(_k_laser_jump_warn_gate_w * 0.72,
                        room_width * 0.5 - 10,
                        power(_raw, 0.78));

    if (laser_jump_warn_t mod 2 == 0) {
      var _sw_vn = 4 + round(5 * _sw_c);
      for (var _sv = 0; _sv < _sw_vn; _sv++) {
        var _sv_side = choose(-1, 1);
        var _sv_x = (random(1) < 0.62)
                  ? ((_sv_side < 0) ? random(_sw_head) : room_width - random(_sw_head))
                  : random(room_width);
        scr_spawn_vent_stream(laser_jump_warn_vents,
          _sv_x, _k_laser_jump_y + random_range(-3, 3),
          90 + random_range(-lerp(24, 7, _sw_c), lerp(24, 7, _sw_c)),
          _sw_c, _k_laser_jump_warn_vent_cols, 200);
      }
    }

    if (laser_jump_warn_t mod 3 == 0) {
      var _sw_an = 1 + floor(_sw_c * 2);
      for (var _sa = 0; _sa < _sw_an; _sa++) {
        var _sa_side = choose(-1, 1);
        var _sa_x = (_sa_side < 0) ? random_range(10, _sw_head)
                                   : room_width - random_range(10, _sw_head);
        var _sa_rail = random_range(34, 92);
        array_push(laser_jump_warn_arcs, {
          x1 : _sa_x + _sa_side * random_range(20, 70),
          y1 : _k_laser_jump_y - _sa_rail,
          x2 : _sa_x,
          y2 : _k_laser_jump_y + random_range(-4, 4),
          life : irandom_range(8, 15),
          life_max : 15,
          hot : _sw_c,
          color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
          off : scr_bolt_offsets(5, 8 + _sw_c * 18)
        });
      }
    }

    vignette_pulse = max(vignette_pulse, _sw_c * 0.2);
    bloom_pulse = max(bloom_pulse, _sw_c * _sw_c * 0.18);
    aberration_pulse = max(aberration_pulse, _sw_c * _sw_c * 0.16);

    if (laser_jump_warn_t >= laser_jump_warn_len) laser_jump_warn_active = false;
  } else {
    laser_jump_warn_coil = max(0, laser_jump_warn_coil - 0.12);
  }

  scr_update_vent_streams(laser_jump_warn_vents);
  for (var _ja = array_length(laser_jump_warn_arcs) - 1; _ja >= 0; _ja--) {
    laser_jump_warn_arcs[_ja].life--;
    if (laser_jump_warn_arcs[_ja].life <= 0) array_delete(laser_jump_warn_arcs, _ja, 1);
  }

  for (var _jb = array_length(laser_jump_bursts) - 1; _jb >= 0; _jb--) {
    var _sb = laser_jump_bursts[_jb];
    var _age = _sb.life_max - _sb.life;
    var _sp = clamp(_age / max(_sb.life_max - 1, 1), 0, 1);
    var _sweep = 1 - power(1 - clamp(_sp * 1.45, 0, 1), 3);
    var _x0 = (_sb.dir > 0) ? 0 : room_width;
    var _x1 = _x0 + _sb.dir * room_width * _sweep;

    if (_sp > 0.08 && instance_exists(oPlayer) && !instance_exists(oGameover)) {
      if (player_meeting_line_width(_x0, _sb.y, _x1, _sb.y, _k_laser_jump_burst_hit_r)) {
        player_register_hazard_hit();
      }
    }

    if (t mod 2 == 0 && _sp < 0.9) {
      var _spark_x = lerp(_x0, _x1, random(1));
      array_push(arrow_ring_particles, {
        x : _spark_x,
        y : _sb.y + random_range(-5, 8),
        vx : _sb.dir * random_range(1.5, 5.0) + random_range(-1.0, 1.0),
        vy : -random_range(0.6, 3.4),
        life : irandom_range(12, 24),
        max_life : 24,
        size : random_range(0.06, 0.16),
        grav : 0.12,
        drag : 0.92,
        hot : random_range(0.82, 1)
      });
    }

    _sb.life--;
    if (_sb.life <= 0) array_delete(laser_jump_bursts, _jb, 1);
  }
};

laser_beam_scars = [];
_k_laser_scar_fade = 0.012;
_k_laser_scar_max = 6;

laser_chain_breaks = [];
_k_laser_chain_break_life = 12;
_k_laser_chain_break_max = 22;

laser_finale_charge = 0;
laser_finale_released = false;
laser_finale_pulses = [];
laser_finale_pulse_timer = 0;
laser_finale_flash = 0;
_k_laser_finale_pulse_interval_far = 20;
_k_laser_finale_pulse_interval_near = 6;

laser_finale_leaks = [];
_k_laser_finale_leak_max = 3;
_k_laser_finale_leak_reach = 240;

laser_coil_active = false;
laser_coil_x = 0;
laser_coil_y = 0;
laser_coil_dir = 0;
laser_coil_centered = false;
laser_coil_t = 0;
laser_coil_len = 12;
laser_coil_power = 1;
laser_coil_arcs = [];
laser_coil_leaks = [];
laser_coil_pulses = [];
laser_coil_pulse_timer = 0;
laser_coil_flash = 0;

laser_vents = [];
_k_laser_vent_cols = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];
_k_laser_lock_read_floor = 0.18;

laser_lock_cx = 0;
laser_lock_cy = 0;
laser_lock_ang = 0;
laser_lock_len = 0;
laser_lock_wid = 0;
_k_laser_lock_pad = 26;
_k_laser_lock_reach = 450;

_k_laser_lock_half_h = 36;
_k_laser_lock_push = 54;
_k_laser_lock_tick = 14;
_k_laser_lock_pad_box = 5;

_k_laser_lock_heavy_power = 1.2;
_k_laser_lock_light_bloom = 0.7;

_k_laser_coil_ring_start = 92;
_k_laser_coil_ring_end = 26;
_k_laser_coil_arc_interval = 3;
_k_laser_coil_arc_max = 5;
_k_laser_coil_arc_outer = 120;
_k_laser_coil_leak_chance = 0.12;
_k_laser_coil_leak_max = 2;
_k_laser_coil_leak_reach = 170;
_k_laser_coil_pulse_far = 7;
_k_laser_coil_pulse_near = 2;

orb_volley_shards = [];
orb_volley_bursts = [];
orb_volley_shard_id_counter = 0;
orb_volley_lock_on_timer = 0;
orb_volley_lock_on_targets = [];
orb_volley_lock_on_origin_x = 0;
orb_volley_lock_on_origin_y = 0;
orb_volley_jump_route = [];
orb_volley_jump_band_y = room_height - 130;

_k_orb_volley_count = 15;
_k_orb_volley_travel_frames = 22;
_k_orb_volley_stagger_max = 10;
_k_orb_volley_ready_lead_frames = 5;
_k_orb_volley_color = global.avoid_col_warning;
_k_orb_volley_trail_length = 8;
_k_orb_volley_lock_on_frames = 8;
_k_orb_volley_route_floor_y = room_height - 40;
_k_orb_volley_route_bottom_w = 64;
_k_orb_volley_route_mid_w = 88;
_k_orb_volley_route_top_w = 74;
_k_orb_volley_jump_band_half = 34;

rain_splashes = [];
_k_rain_floor_y = room_height;

reentry_shards = [];
reentry_touchdowns = [];
reentry_embers = [];
reentry_shard_id_counter = 0;
storm_intensity = 0;

_k_reentry_stagger_max = 42;
_k_reentry_duration_min = 16;
_k_reentry_duration_max = 30;
_k_reentry_bolide_chance = 0.1;
_k_reentry_curve_max = 70;
_k_reentry_edge_seed_count = 12;
_k_reentry_edge_pad = 12;
_k_reentry_edge_band = 42;
_k_reentry_edge_stagger_max = 3;
_k_reentry_edge_duration_min = 14;
_k_reentry_edge_duration_max = 18;

storm_rain_streaks = [];
storm_rain_seeded = false;
storm_wind = 0;
storm_wind_target = 0;
storm_sky_flash = 0;
storm_sky_bolts = [];
storm_sky_timer = 0;

storm_sweep = 0;
storm_sweep_active = false;

_k_storm_rain_count = 160;
_k_storm_rain_bands = 3;
_k_storm_rain_alpha = 0.20;
_k_storm_wind_ease = 0.06;

// ============================================================================
// ORB RAIN (t1691-1856) — THE BASS KNOCKS THEM OFF THE CEILING
// ============================================================================

orb_ceiling_pts    = [];
orb_ceiling_built  = false;
orb_ceiling_flex   = 0;      
orb_ceiling_heat   = 0;      
orb_ceiling_epi    = 400;    

orb_cracks         = [];     

orb_fronts         = [];
orb_whips          = [];     
orb_sockets        = [];     
orb_shocks         = [];     
orb_rain_vents     = [];     
orb_snap_motes     = [];

orb_rain_flash     = 0;
orb_rain_beat      = -1;     
orb_finale         = 0;      
orb_finale_active  = false;

_k_orbrain_ceiling_y     = 16;    
_k_orbrain_ceiling_segs  = 36;
_k_orbrain_crack_speed   = 52;    
_k_orbrain_crack_life    = 26;
_k_orbrain_whip_life     = 18;
_k_orbrain_socket_life   = 84;
_k_orbrain_knock_down    = 2.6;
_k_orbrain_knock_side    = 2.2;
_k_orbrain_hold_frames   = 2;     
_k_orbrain_front_speed   = 20;
_k_orbrain_front_life    = 42;
_k_orbrain_front_band    = 54;    
_k_orbrain_front_lead    = 0.38;
_k_orbrain_front_sigma   = 260;
_k_fall_gravity_ref      = 0.5;
_k_orbrain_shock_speed   = 27;
_k_orbrain_shock_life    = 22;
_k_orbrain_vent_cap      = 40;
_k_orbrain_mote_cap      = 260;
_k_orbrain_ceiling_ports = 9;
_k_orbrain_socket_w      = 30;
_k_orbrain_socket_h      = 9;
_k_orbrain_socket_jaw    = 11;
_k_orbrain_socket_tick   = 7;
_k_orbrain_edge_arm_band = 68;
_k_orbrain_vent_cols     = [ global.avoid_col_cyan, global.avoid_col_warning,
                             global.avoid_col_violet ];

orbrain_build_ceiling = function() {
  orb_ceiling_pts = [];
  for (var _i = 0; _i <= _k_orbrain_ceiling_segs; _i++) {
    var _f = _i / _k_orbrain_ceiling_segs;
    array_push(orb_ceiling_pts, {
      x  : _f * room_width,
      y0 : _k_orbrain_ceiling_y + sin(_f * 21.7 + _i * 1.9) * 5 + random_range(-3.5, 3.5),
      s  : random(1000)
    });
  }
  orb_ceiling_built = true;
};

orbrain_seam_y = function(_x) {
  if (!orb_ceiling_built || array_length(orb_ceiling_pts) < 2) return _k_orbrain_ceiling_y;

  var _n = array_length(orb_ceiling_pts) - 1;
  var _f = clamp(_x / max(room_width, 1), 0, 1) * _n;
  var _i = clamp(floor(_f), 0, _n - 1);
  var _base = lerp(orb_ceiling_pts[_i].y0, orb_ceiling_pts[_i + 1].y0, _f - _i);

  var _d = abs(_x - orb_ceiling_epi);
  var _bulge = orb_ceiling_flex * exp(-(_d * _d) / (2 * 240 * 240));
  return _base + _bulge;
};

orbrain_attach = function(_orb) {
  with (_orb) {
    rain_orb      = true;
    tether_ax     = x + random_range(-14, 14);
    tether_ay     = other.orbrain_seam_y(tether_ax);
    tether_seed   = random(1000);
    rain_material_spin = tether_seed * 137.3;
    rain_core_phase    = tether_seed * 19.7;
    tether_state  = 0;
    tether_charge = 0;
    hit_active    = false;
  }
};

orbrain_arm = function(_orb, _heavy, _beat) {
  if (!instance_exists(_orb)) return;
  if (_orb.tether_state != 0 || _orb.dissolving) return;

  with (_orb) {
    tether_state = 1;
    tether_heavy = _heavy;
    armed_beat   = _beat;
    arm_flash    = 1;
  }
};

orbrain_arm_group = function(_beat, _count, _heavy, _hail) {
  var _pool = [];
  var _have = 0;

  with (oFallingRedOrb) {
    if (!rain_orb || dissolving) continue;
    if (tether_state == 0) array_push(_pool, id);
    else if (tether_state == 1 && armed_beat == _beat) _have++;
  }

  var _need = max(0, min(_count - _have, array_length(_pool)));
  var _armed_now = 0;

  var _edge_left_x  = _k_reentry_edge_pad + _k_reentry_edge_band * 0.5;
  var _edge_right_x = room_width - _edge_left_x;
  var _edge_first_left = ((_beat mod 2) == 0);
  var _edge_need = min(2, _need);

  for (var _ei = 0; _ei < _edge_need; _ei++) {
    var _edge_target = (_edge_first_left == (_ei == 0)) ? _edge_left_x : _edge_right_x;
    var _best_i = -1;
    var _best_d = _k_orbrain_edge_arm_band;

    for (var _pi = 0; _pi < array_length(_pool); _pi++) {
      var _cand = _pool[_pi];
      if (!instance_exists(_cand)) continue;

      var _dx_edge = abs(_cand.x - _edge_target);
      if (_dx_edge <= _best_d) {
        _best_d = _dx_edge;
        _best_i = _pi;
      }
    }

    if (_best_i >= 0) {
      var _edge_orb = _pool[_best_i];
      array_delete(_pool, _best_i, 1);
      orbrain_arm(_edge_orb, _heavy, _beat);
      if (_hail && _armed_now == 0 && _have == 0) _edge_orb.is_hailstone = true;
      _armed_now++;
    }
  }

  var _random_need = _need - _armed_now;
  for (var _i = 0; _i < _random_need; _i++) {
    var _pick = irandom(array_length(_pool) - 1);
    var _orb = _pool[_pick];
    array_delete(_pool, _pick, 1);
    orbrain_arm(_orb, _heavy, _beat);
    if (_hail && _armed_now + _i == 0 && _have == 0) _orb.is_hailstone = true;
  }
};

orbrain_strike = function(_orb, _lateral, _power) {
  if (!instance_exists(_orb)) return;
  if (_orb.tether_state >= 3 || _orb.dissolving) return;

  var _heavy = _orb.tether_heavy;
  var _ax = _orb.tether_ax;
  var _ay = _orb.tether_ay;
  var _ox = _orb.x;
  var _oy = _orb.y;

  array_push(orb_whips, {
    ax : _ax, ay : _ay,
    x : _ox, y : _oy,
    len : point_distance(_ax, _ay, _ox, _oy),
    vx : random_range(-2.2, 2.2),
    vy : -random_range(3.5, 7),
    life : _k_orbrain_whip_life, life_max : _k_orbrain_whip_life,
    heavy : _heavy, seed : random(1000)
  });

  array_push(orb_sockets, {
    x : _ax, y : _ay,
    life : _k_orbrain_socket_life, life_max : _k_orbrain_socket_life,
    heavy : _heavy, seed : random(1000)
  });

  var _vn = _heavy ? 2 : 1;
  for (var _v = 0; _v < _vn; _v++) {
    scr_spawn_vent_stream(orb_rain_vents, _ax + random_range(-6, 6), _ay,
                          90 + random_range(-22, 22),
                          _heavy ? 0.85 : 0.5,
                          _k_orbrain_vent_cols, _k_orbrain_vent_cap);
  }

  with (_orb) {
    tether_state  = 3;
    socket_heat   = 1;
    strike_squash = 1;
    strike_hold   = other._k_orbrain_hold_frames;

    strike_grav   = is_hailstone ? other._k_fall_gravity_ref * 1.8 : other._k_fall_gravity_ref;
    knock_vx = _lateral * other._k_orbrain_knock_side * _power + random_range(-0.5, 0.5);
    knock_vy = other._k_orbrain_knock_down * _power * (_heavy ? 1.25 : 0.7);
    spin_rate = random_range(-7, 7) * (_heavy ? 1.4 : 1);
  }
};

chain2_last_orb = -4;

warning_edge = 0;
warning_flash_timer = 0;

_k_warning_flash_duration = 12;
_k_warning_edge_width = 60;
_k_warning_wave_freq = 0.05;
_k_warning_wave_speed = 0.15;
_k_warning_wave_min_mult = 0.6;
_k_warning_wave_max_mult = 1.0;
_k_warning_core_width = 6;
_k_warning_edge_color = global.avoid_col_warning;
_k_warning_base_alpha = 0.55;
_k_warning_pulse_speed = 0.5;
warning_wave_phase = random(2 * pi);

laser_warn_band_edge   = 2;
laser_warn_band_t      = 0;
laser_warn_band_len    = 1;
laser_warn_band_coil   = 0;
laser_warn_band_active = false;
laser_warn_band_vents  = [];
laser_warn_band_arcs   = [];
laser_warn_band_haze   = [];
laser_warn_band_sweeps = [];

_k_lwb_depth      = 72;
_k_lwb_read_floor = 0.16;
_k_lwb_tick       = 14;
_k_lwb_inset      = 3;

_k_lwb_density_ref = 100;
_k_lwb_spill_gain = 1.0;
_k_lwb_spill_deep = 150;

_k_lwb_slot_mult      = 2.4;
_k_lwb_slot_hold      = 0.55;
_k_lwb_slot_alpha_min = 0.25;
_k_lwb_slot_alpha_max = 0.94;
_k_lwb_vent_cols  = [ global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet ];

_k_center_warning_duration = 12;
_k_center_warning_beam_half_len = 500;
_k_center_warning_beam_width = 40;
_k_center_warning_core_radius = 30;
_k_center_warning_color = global.avoid_col_warning;
_k_center_warning_iris_start_radius = 90;
_k_center_warning_lash_count = 10;
_k_center_warning_lash_length = 45;
_k_center_warning_lash_spread = 50;
_k_center_warning_hot_color = c_white;
_k_center_warning_release_shake = 14;
_k_center_warning_sclera_intensity = 0.25;
_k_center_warning_sclera_radius = 220;
_k_center_warning_jitter_angle = 4;
_k_center_warning_jitter_width = 0.12;
_k_center_warning_pupil_intensity = 1.5;
_k_center_warning_pupil_scale_start = 0.5;
_k_center_warning_pupil_scale_end = 0.15;
_k_center_warning_echo_interval = 3;
_k_center_warning_echo_life = 18;
_k_center_warning_echo_start_alpha = 0.35;
_k_center_warning_glint_speed = 0.3;
_k_center_warning_glint_alpha = 0.8;
_k_center_warning_glint_offset_x = -10;
_k_center_warning_glint_offset_y = -8;
_k_center_warning_glint_radius = 4;

center_warning_timer = 0;
center_warning_image_angle = 0;
center_warning_x = 400;
center_warning_y = 304;
prev_center_warning_timer = 0;
iris_echoes = [];

lat = undefined;

_k_lat_coil_frames = 15;

dna_write_arcs = [];

dna_chain_flash = 0;
dna_cross_arcs = [];
_k_dna_cross_arc_max = 14;

vault = undefined;

_k_vault_cx = 400;
_k_vault_cy = 304;

_k_vault_hex_rot = 0;

_k_vault_t_survey    = 5088;
_k_vault_beats       = [5146, 5163, 5179, 5193, 5209];
_k_vault_t_discharge = 5219;   // oHoneycombController spawns on this frame
_k_vault_t_end       = 5254;
_k_vault_lead        = 11;     // anticipation lead into a beat

_k_vault_wall_in   = 118;
_k_vault_wall_out  = 137;
_k_vault_kill_r    = 127;
_k_vault_warn_band = 46;       // how far out a plate starts warning

_k_vault_burst_frames = 26;

_k_vault_far_r        = 1250;
_k_vault_iris_blades  = 9;
_k_vault_iris_start   = 780;   //   of the cell and must not look like it is.
_k_vault_iris_stop    = 236;   // start sits just off the frame so the eleven
_k_vault_throat_rings = 7;
_k_vault_throat_r0    = 205;
_k_vault_throat_step  = 1.38;
_k_vault_kerf_w       = 26;
_k_vault_pylon_len    = 44;
_k_vault_print_rings  = 6;

// with hex_radius 100 and cols 13. The discharge unfolds onto exactly this,
_k_vault_hc_radius = 358.36;

_k_vault_ring_max = 8;
_k_vault_arc_max  = 20;
_k_vault_beam_max = 8;
_k_vault_vent_max = 48;

_k_vault_lattice_hole_r = 150;

global.light_surface = -1;

blackhole_pending = [];

blackhole_push_mode = false;

_k_bh_breakdown_letterbox = 1.0;
_k_bh_dark_max = 0.55;
_k_bh_spawn_min_x = 110;
_k_bh_spawn_max_x = room_width - 110;
_k_bh_spawn_min_y = 72;
_k_bh_spawn_max_y = room_height * 0.36;
_k_bh_spawn_player_safe_dist = 300;
_k_bh_spawn_pair_safe_dist = 260;
_k_bh_orbit_cx = room_width / 2;
_k_bh_orbit_cy = room_height * 0.26;
_k_bh_orbit_rx_min = 130;
_k_bh_orbit_rx_max = 270;
_k_bh_orbit_ry_min = 36;
_k_bh_orbit_ry_max = 82;
_k_bh_orbit_min_y = 64;
_k_bh_orbit_max_y = room_height * 0.39;

_k_bh_drop_shake = 34;
_k_bh_drop_zoom = 0.3;
_k_bh_drop_vignette = 1.0;
_k_bh_drop_aberration = 0.85;
_k_bh_drop_bloom = 0.7;
_k_bh_drop_ripple = 1.0;
_k_bh_drop_flash = 0.85;
_k_bh_drop_tear = 0.95;
_k_bh_drop_angle = 5;

_k_bh_forge_start_t = 3237;
_k_bh_forge_release_t = 3303;
_k_bh_forge_detonate_t = 3320;
_k_bh_forge_center_x = room_width / 2;
_k_bh_forge_center_y = room_height / 2;
_k_bh_forge_leak_max = 16;
_k_bh_forge_mote_max = 48;
_k_bh_forge_draw_mult = 0.28;
_k_bh_forge_screen_mult = 0.35;
_k_bh_despawn_swell_scale = 1.28;
_k_bh_despawn_draw_mult = 0.26;
_k_bh_despawn_screen_mult = 0.30;
_k_bh_detonation_draw_mult = 0.30;
_k_bh_detonation_particle_mult = 0.46;
_k_bh_finale_edge_draw_mult = 0.42;
_k_bh_finale_burst_draw_mult = 0.42;
_k_bh_finale_kunai_alpha = 0.68;
_k_bh_finale_kunai_fx_mult = 0.42;
_k_bh_finale_kunai_glow_mult = 0.28;
_k_bh_finale_kunai_light_mult = 0.35;
_k_bh_bullet_density = 0.80;
_k_bh_white_rain_speed_mult = 0.80;

bh_phase_charge = 0;
bh_heartbeat = 0;
bh_breakdown = 0;
bh_drop_flash = 0;
bh_inversion_rings = [];
bh_scene_reverse = 0;
bh_reverse_frames = 0;
bh_swallow_flashes = [];
bh_ambient_arcs = [];
bh_infall_streaks = [];
bh_kunai_bursts = [];
bh_edge_waves = [];
bh_horizon_cracks = [];
bh_forge_charge = 0;
bh_forge_flash = 0;
bh_forge_pulse = 0;
bh_forge_pulse_timer = 0;
bh_forge_arcs = [];
bh_forge_motes = [];
bh_forge_slashes = [];
bh_wave_conduits = [];
bh_wave_sparks = [];
bh_wave_gate_charge = 0;
bh_wave_gate_flash = 0;

bh_rain_beats = [
  2681, 2703, 2723, 2744, 2765, 2784, 2806, 2826, 2847, 2866, 2886, 2906, 2926, 2947, 2968,
  3012, 3033, 3053, 3073, 3094, 3114, 3135, 3155, 3174, 3195, 3216
];

bh_finale_beats = [ 3260, 3272, 3283, 3292, 3303 ];

fruit_explosion_triggered = false;

tree_data = undefined;
tree_shockwaves = [];
tree_crown_center_x = room_width / 2;
tree_crown_center_y = room_height / 2;
sky_strikes = [];
sky_strike_id_counter = 0;

storm_orb_x = room_width / 2;
storm_orb_y = room_height / 2;
storm_charge_arcs = [];
storm_charge_arc_timer = 0;
storm_charge_released = false;
storm_sphere_visibility = 0;
storm_orb_radius = 0;
storm_orb_pulse_freq = 0.05;
storm_orb_scale_punch = 1;
_k_storm_clearing_radius = 80;
_k_storm_dim_alpha = 0.1;

global.tree_fire_color = global.avoid_col_ember;

tree_ignite_start_t = 1895;

tree_telegraph_start_t = 1826;

tree_telegraph_end_t = 1856;

tree_payoff_triggered = false;

tree_payoff_flash_timer = 999999;

tree_payoff_t = 0;

tree_root_base_y = room_height - 6;
tree_root_base_xs = [ room_width / 2 - 190, room_width / 2, room_width / 2 + 190 ];

tree_fruit_hold_brake_t = 2085;
tree_fruit_hold_suction_t = 2106;

tree_root_rake_floor_y = room_height - 6;
tree_root_rake_hit_radius = 14;
tree_root_rake_debug = false;
tree_root_rake_debris_timer = 0;
tree_root_rake_flash = 0;
tree_root_rake_pressure = 0;
tree_fruit_hold_tension = 0;
tree_organism_tension = 0;
tree_root_rakes = [
  {
    side : -1,
    warn_t : 2028,
    acquire_t : 2045,
    tense_t : 2065,
    strike_t : 2077,
    hold_t : 2106,
    release_t : 2140,
    reach : 154,
    lift : 118,
    seed : 13.7,
    weight : 1.0
  },
  {
    side : 1,
    warn_t : 2038,
    acquire_t : 2045,
    tense_t : 2065,
    strike_t : 2085,
    hold_t : 2127,
    release_t : 2168,
    reach : 158,
    lift : 124,
    seed : 41.3,
    weight : 1.08
  }
];

tree_telegraph_heat = 0;
tree_root_fissures = [];
tree_root_spurt_timer = 0;
tree_pre_pulses = [];
tree_pre_next_pulse = 0;
tree_branch_sparks = [];
tree_branch_spark_timer = 0;
tree_crown_pulses = [];
tree_root_spines = [];
tree_network_flash = 0;
tree_crown_charge = 0;

tree_scar_segments = [];
tree_scar_alpha = 0;
tree_scar_flash = 0;
tree_scar_motes = [];

_k_scar_width_mult = 2.4;
_k_scar_fade = 0.0055;
_k_scar_burn_min = 0.30;
_k_scar_burn_max = 0.92;
_k_scar_sag = 7;
_k_scar_glow_budget = 190;

tree_burn_heat = 0;
tree_burn_next_pulse = 0;
tree_canopy_drip_timer = 0;

storm_discharge_arcs = [];
storm_charge_beat_punch = 0;

global.tree_embers = [];

fruit_bursts = [];

fruit_shockwaves = [];

fruit_streaks = [];

ember_implosion_active = false;

ember_implosion_timer = 0;

ember_implosion_spawn_rate = 4;

ember_implosion_spawn_count = 3;

ember_implosion_last_t = 0;

ember_edge_glows = [];

_k_incoming_warn_range = 420;
_k_incoming_warn_floor = 0.34;
_k_incoming_warn_box_far = 30;
_k_incoming_warn_box_near = 14;
_k_incoming_warn_tick = 12;
_k_incoming_warn_chevrons_max = 5;

ember_coil_pulses = [];
ember_coil_arcs = [];
ember_coil_next_pulse_t = 0;

ember_burst_flash = 0;
ember_burst_rings = [];
ember_burst_arcs = [];
ember_drip_particles = [];

ember_crush_rings = [];
ember_crush_heat = 0;

finale_lightning_col = global.avoid_col_cyan_soft;
finale_lightning_hot = make_color_rgb(225, 245, 255);
finale_motes = [];
finale_seed_alpha = 0;
finale_coil_pulses = [];
finale_coil_arcs = [];
finale_coil_next_pulse_t = 0;
finale_impact_cracks = [];
finale_drip_particles = [];

finale_ground_strikes = [];
finale_railgun_beams = [];

_k_er_lift_charge_t = 2252;
_k_er_lift_beats = [ 2270, 2286, 2302, 2318 ];
_k_er_lift_lock_t = 2326;
_k_er_lift_release_t = 2650;
_k_er_lift_start_top_y = _k_er_floor_base_y + 84;
_k_er_lift_born_top_y = _k_er_floor_base_y + 8;
_k_er_lift_final_top_y = _k_er_floor_base_y - floor(room_height * 0.335);
_k_er_lift_body_h = 58;
_k_er_lift_overhang = 42;
_k_er_lift_segment_w = 32;
_k_er_lift_warning_h = 52;
_k_er_lift_despawn_duration = 70;
_k_er_lift_despawn_drop = 170;
_k_er_lift_despawn_crack_count = 16;
_k_hc_front_telegraph = 10;
_k_hc_front_life = 56;
_k_hc_front_scar_life = 74;
_k_hc_front_cx = 400;
_k_hc_front_cy = 304;
_k_hc_front_radius0 = 118;
_k_hc_front_radius1 = [ 418, 468, 520, 570 ];
_k_hc_front_width = [ 22, 24, 27, 30 ];
_k_hc_front_arc_span = 184;
_k_hc_front_segments = 34;
_k_hc_front_socket_count = 7;

er_lift_active = false;
er_lift_locked = false;
er_lift_despawning = false;
er_lift_despawn_timer = 0;
er_lift_despawn_flash = 0;
er_lift_platform = noone;
er_lift_top_y = _k_er_lift_start_top_y;
er_lift_prev_top_y = er_lift_top_y;
er_lift_vspeed = 0;
er_lift_target_y = _k_er_lift_start_top_y;
er_lift_draw_bob = 0;
er_lift_hit_flash = 0;
er_lift_core_flash = 0;
er_lift_lock_flash = 0;
er_lift_heat = 0;
er_lift_charge = 0;
er_lift_beat_index = -1;
er_lift_phase_pulse = 0;
er_lift_rail_alpha = 0;
er_lift_seed = random(1000);
er_lift_lip = [];
er_lift_vents = [];
er_lift_plumes = [];
er_lift_sparks = [];
er_lift_chunks = [];
er_lift_shockwaves = [];
er_lift_ridges = [];
er_lift_lavafalls = [];
er_lift_bolts = [];
er_lift_edge_flares = [];
er_lift_despawn_cracks = [];

for (var _ml = -_k_er_lift_overhang; _ml <= room_width + _k_er_lift_overhang; _ml += _k_er_lift_segment_w) {
  array_push(er_lift_lip, {
    x : _ml,
    top : random_range(-4, 5),
    under : random_range(10, 28),
    chip : random_range(0, 8),
    vein : random(1),
    seed : random(1000)
  });
}

swirl_center_x = 400;

swirl_center_y = 304;

swirl_radius_px = 260;

_k_fin_cx = 400;
_k_fin_cy = 304;

_k_fin_t_open      = 6960;
_k_fin_throw_beats = [ 6960, 7044 ];
_k_fin_spike_beats = [ 7001, 7086 ];
_k_fin_shell_beats = [ 7124, 7144, 7163, 7186, 7207 ];

_k_fin_shell_lead = 2;
_k_fin_breath_beats = [ 7222, 7242, 7258, 7270, 7279, 7285, 7289 ];
_k_fin_t_breath    = 7207;
_k_fin_t_cut       = 7291;

_k_fin_close_frames    = [  16,   16 ];
_k_fin_converge_frames = [   9,    8 ];

_k_fin_coil_frames = [];
for (var _fci = 0; _fci < array_length(_k_fin_throw_beats); _fci++) {
    array_push(_k_fin_coil_frames,
               _k_fin_spike_beats[_fci] - _k_fin_throw_beats[_fci] - _k_fin_close_frames[_fci] + 1);
}

_k_fin_spike_mode  = [     0,    1 ];
_k_fin_spike_start = [    90,  270 ];
_k_fin_spike_rate  = [ 0.095, 0.17 ];
_k_fin_spike_rehearse = [ 2, 2 ];

_k_fin_orb_count  = [   34,   30 ];
_k_fin_layers     = [    1,    2 ];
_k_fin_gap_count  = [    2,    2 ];
_k_fin_gap_width  = [   70,   70 ];
_k_fin_r_spawn    = [  560,  620 ];
_k_fin_r_lock     = [  300,  285 ];
_k_fin_pullback   = [   70,  105 ];
_k_fin_player_track = [ 0.28, 0.28 ];

_k_fin_hit_radius = 9;

_k_fin_shake      = [   30,   46 ];
_k_fin_punch      = [ 0.28, 0.44 ];
_k_fin_roll       = [  5.4,  8.0 ];
_k_fin_flash      = [ 0.52, 0.80 ];
_k_fin_tear       = [ 0.72, 0.98 ];
_k_fin_lb_open    = 0.16;
_k_fin_lb_coil    = [ 0.34, 0.50 ];
_k_fin_lb_after   = [ 0.18,    0 ];
_k_fin_streaks    = [   64,   96 ];
_k_fin_splatter   = [   20,   30 ];
_k_fin_embers     = [   30,   48 ];
_k_fin_bolts      = [    9,   14 ];

_k_fin_spike_shake   = [  3.2,  4.6 ];
_k_fin_spike_streaks = [    4,    6 ];

_k_fin_gap_base = 270;
_k_fin_gap_step = 60;
_k_fin_gap_reuse_min = 22;
_k_fin_gap_choices = [
  [ 198, 222, 246, 270, 294, 318, 342 ],
  [ 198, 222, 246, 270, 294, 318, 342 ]
];
_k_fin_rot_start_choices = [
  [ -72, -58, 58, 72 ],
  [ -72, -58, 58, 72 ]
];
_k_fin_rot_settle = [ 22, 22 ];

_k_fin_comet_r      = 1250;
_k_fin_comet_frames = 11;
_k_fin_trail_len    = 14;
_k_fin_ghost_every  = 2;

_k_fin_shell_sides  = [    6,    5,    4,    3,    2 ];
_k_fin_shell_r_out  = [  900,  800,  720,  640,  520 ];
_k_fin_shell_r_lock = [  535,  455,  365,  285,  100 ];
_k_fin_shell_span   = [    0,    0,    0,    0,  460 ];

_k_fin_shell_arm    = [    8,    8,    8,    8,    8 ];
_k_fin_shell_slam   = [   12,   12,   12,   12,   14 ];
_k_fin_shell_rot    = [   90,   18,   45,  270,    0 ];
_k_fin_shell_spin   = [  -38,   30,   44,  -52,   26 ];

_k_fin_shell_arm_drift = 1.10;

_k_fin_shell_ladder  = 1.10;
_k_fin_shell_creep   = 0.075;
_k_fin_shell_drift   = 0.22;

_k_fin_shell_swallow = [ 0.86, 0.86, 0.86, 0.86, 0.90 ];

_k_fin_shell_col = [ global.avoid_col_cyan, global.avoid_col_cyan_soft,
                     global.avoid_col_cyan_soft, global.avoid_col_violet,
                     global.avoid_col_hot ];
_k_fin_shell_hot = [ 0.26, 0.42, 0.60, 0.80, 1.00 ];

_k_fin_shell_shake   = [   16,   21,   26,   33,   44 ];
_k_fin_shell_punch   = [ 0.12, 0.17, 0.23, 0.30, 0.40 ];
_k_fin_shell_roll    = [  2.4,  3.4,  4.4,  5.6,  7.4 ];
_k_fin_shell_flash   = [ 0.20, 0.26, 0.33, 0.42, 0.58 ];
_k_fin_shell_tear    = [ 0.36, 0.48, 0.62, 0.78, 0.98 ];
_k_fin_shell_streaks = [   24,   31,   39,   49,   64 ];
_k_fin_shell_sparks  = [   24,   31,   39,   49,   64 ];
_k_fin_shell_bolts   = [    5,    6,    8,   10,   13 ];
_k_fin_shell_vent    = [ 0.55, 0.66, 0.77, 0.88, 1.00 ];

_k_fin_shell_wall_w   = [  4.6,  5.2,  5.9,  6.8,  8.4 ];
_k_fin_shell_groove_w = 3.4;
_k_fin_shell_ghost_every = 2;
_k_fin_shell_ghost_fade  = 0.085;
_k_fin_shell_spark_max   = 300;
_k_fin_shell_vent_max    = 110;
_k_fin_shell_dashes      = 15;
_k_fin_shell_dash_on     = 0.54;
_k_fin_shell_tendon_max  = 0.55;

_k_fin_gap_lane_xmin = 150;
_k_fin_gap_lane_xmax = 650;
_k_fin_gap_step_min  = 30;
_k_fin_gap_step_max  = 52;
_k_fin_gap_band_px   = 88;
_k_fin_gap_band_y    = 560;
_k_fin_shell_hit_r   = 8;

_k_fin_shell_drag_in  = 2.6;
_k_fin_shell_drag_pad = 90;

_k_fin_lb_fill        = 0.40;

_k_fin_breath_lb      = 0.52;
_k_fin_mote_rate      = 5;
_k_fin_mote_max       = 260;
_k_fin_still_frames   = 3;

bass_rings               = [];
orbit_rings              = [];
fin_shells               = [];
fin_shell_ghosts         = [];
fin_shell_sparks         = [];
fin_shell_vents          = [];
bass_ring_pierce_flashes = [];
fin_ghosts               = [];
fin_motes                = [];

_k_fin_assembly_t_start = _k_fin_t_open;
_k_fin_assembly_t_ready = _k_fin_throw_beats[1];
_k_fin_assembly_t_fade  = _k_fin_shell_beats[0];
_k_fin_assembly_t_end   = _k_fin_t_breath;
_k_fin_assembly_packet_max = 56;
_k_fin_assembly_ring_r      = [ 118, 205, 295, 395 ];
_k_fin_assembly_ring_delay  = [ 0.00, 0.12, 0.26, 0.42 ];
_k_fin_assembly_ring_segs   = [   10,   12,   14,   16 ];
_k_fin_assembly_ring_offset = [  -18,   26,  -34,   42 ];

fin_assembly_pulse   = 0;
fin_assembly_sync    = 0;
fin_assembly_packets = [];
fin_assembly_nodes   = [];
fin_assembly_scars   = [
  { ang : 334, off : -20, len_a : 330, len_b : 295, wave : 9,  delay : 0.00 },
  { ang :  18, off :  18, len_a : 250, len_b : 210, wave : 7,  delay : 0.16 },
  { ang : 154, off : -10, len_a : 210, len_b : 245, wave : 11, delay : 0.32 }
];

var _fa_node_r     = [ 118, 205, 295, 395 ];
var _fa_node_count = [   4,   6,   8,   8 ];
for (var _far = 0; _far < array_length(_fa_node_r); _far++) {
  var _fac = _fa_node_count[_far];
  for (var _fai = 0; _fai < _fac; _fai++) {
    array_push(fin_assembly_nodes, {
      ring  : _far,
      r     : _fa_node_r[_far],
      ang   : _k_fin_assembly_ring_offset[_far] + (_fai / _fac) * 360,
      delay : _k_fin_assembly_ring_delay[_far] + (_fai / max(_fac - 1, 1)) * 0.08,
      pulse : 0,
      seed  : _fai * 17 + _far * 43
    });
  }
}

fin_assembly_visibility = function() {
  var _rise = clamp((t - _k_fin_assembly_t_start)
                    / max(_k_fin_assembly_t_ready - _k_fin_assembly_t_start, 1), 0, 1);
  var _fade = 1 - clamp((t - _k_fin_assembly_t_fade)
                        / max(_k_fin_assembly_t_end - _k_fin_assembly_t_fade, 1), 0, 1);
  return power(_rise, 0.72) * clamp(_fade, 0, 1) * (1 - fin_hush * 0.75);
};

fin_assembly_ring_progress = function(_delay) {
  var _build = clamp((t - _k_fin_assembly_t_start)
                     / max(_k_fin_assembly_t_ready - _k_fin_assembly_t_start, 1), 0, 1);
  return clamp((_build - _delay) / max(1 - _delay, 0.001), 0, 1);
};

fin_spear_index  = 0;
fin_shell_index  = 0;
fin_shell_gaps   = [];
fin_shell_seed   = 0;
fin_breath_index = 0;
fin_opened       = false;
fin_breath_active = false;
fin_roll_sign    = 1;
fin_cage_seed    = 0;
fin_cage_layout  = [];

fin_build_cage_layout = function(_seed) {
  var _prev_seed = random_get_seed();
  random_set_seed(_seed);

  fin_cage_layout = [];
  var _prev_gaps = [];

  for (var _li = 0; _li < array_length(_k_fin_throw_beats); _li++) {
    var _choices = _k_fin_gap_choices[_li];
    var _filtered = [];

    for (var _ci = 0; _ci < array_length(_choices); _ci++) {
      var _candidate = _choices[_ci];
      var _ok = true;

      if (_li > 0) {
        for (var _cg = 0; _cg < _k_fin_gap_count[_li]; _cg++) {
          var _candidate_gap = _candidate + _cg * (360 / _k_fin_gap_count[_li]);
          for (var _pg = 0; _pg < array_length(_prev_gaps); _pg++) {
            if (abs(angle_difference(_candidate_gap, _prev_gaps[_pg])) < _k_fin_gap_reuse_min) {
              _ok = false;
              break;
            }
          }
          if (!_ok) break;
        }
      }

      if (_ok) array_push(_filtered, _candidate);
    }

    var _pick_src = (array_length(_filtered) > 0) ? _filtered : _choices;
    var _gap = _pick_src[irandom(array_length(_pick_src) - 1)];

    var _rot_choices = _k_fin_rot_start_choices[_li];
    var _rot = _rot_choices[irandom(array_length(_rot_choices) - 1)];

    var _gaps = [];
    for (var _gg = 0; _gg < _k_fin_gap_count[_li]; _gg++) {
      array_push(_gaps, _gap + _gg * (360 / _k_fin_gap_count[_li]));
    }

    array_push(fin_cage_layout, { gap : _gap, rot : _rot, gaps : _gaps });
    _prev_gaps = _gaps;
  }

  random_set_seed(_prev_seed);
};

fin_ensure_cage_layout = function() {
  if (array_length(fin_cage_layout) >= array_length(_k_fin_throw_beats)) return;

  if (fin_cage_seed == 0) {
    if (variable_global_exists("debug_fin_cage_seed") && global.debug_fin_cage_seed != 0) {
      fin_cage_seed = global.debug_fin_cage_seed;
    } else {
      fin_cage_seed = 1 + irandom(999998);
    }
  }

  fin_build_cage_layout(fin_cage_seed);
};

fin_shell_wall = function(_sh, _i) {
  var _n   = _sh.sides;
  var _ang = _sh.rot + _i * (360 / _n);
  var _ap  = (_n >= 3) ? _sh.radius * cos(pi / _n) : _sh.radius;
  var _hl  = (_n >= 3) ? _sh.radius * sin(pi / _n) : _sh.span;
  var _cx  = _k_fin_cx + lengthdir_x(_ap, _ang);
  var _cy  = _k_fin_cy + lengthdir_y(_ap, _ang);
  var _tx  = lengthdir_x(_hl, _ang + 90);
  var _ty  = lengthdir_y(_hl, _ang + 90);

  return {
    ang : _ang, ap : _ap, hl : _hl,
    cx : _cx, cy : _cy,
    x1 : _cx - _tx, y1 : _cy - _ty,
    x2 : _cx + _tx, y2 : _cy + _ty
  };
};

fin_shell_segments = function(_sh) {
  var _segs = [];
  for (var _i = 0; _i < _sh.sides; _i++) {
    var _w = fin_shell_wall(_sh, _i);
    array_push(_segs, { x1 : _w.x1, y1 : _w.y1, x2 : _w.x2, y2 : _w.y2 });
  }
  return _segs;
};

fin_shell_spark = function(_x, _y, _dir, _spd, _hot) {
  if (array_length(fin_shell_sparks) >= _k_fin_shell_spark_max) return;

  array_push(fin_shell_sparks, {
    x    : _x,
    y    : _y,
    vx   : lengthdir_x(_spd, _dir),
    vy   : lengthdir_y(_spd, _dir),
    life : 16 + irandom(28),
    max_life : 44,
    size : random_range(0.05, 0.16) + _hot * 0.07,
    hot  : _hot,
    col  : choose(global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet)
  });
};

fin_start_shell = function(_idx) {
  fin_ensure_shell_gaps();

  var _rot  = _k_fin_shell_rot[_idx];
  var _spin = _k_fin_shell_spin[_idx];

  var _sh = {
    idx      : _idx,
    sides    : _k_fin_shell_sides[_idx],
    span     : _k_fin_shell_span[_idx],
    state    : "arm",
    timer    : 0,
    age      : 0,
    arm_f    : _k_fin_shell_arm[_idx],
    slam_f   : _k_fin_shell_slam[_idx],
    r_out    : _k_fin_shell_r_out[_idx],
    r_lock   : _k_fin_shell_r_lock[_idx],
    radius   : _k_fin_shell_r_out[_idx] * _k_fin_shell_arm_drift,
    slam_from: _k_fin_shell_r_out[_idx],
    r_target : _k_fin_shell_r_lock[_idx],
    rot      : _rot - _spin,
    rot_from : _rot - _spin,
    rot_to   : _rot,
    col      : _k_fin_shell_col[_idx],
    hot      : _k_fin_shell_hot[_idx],
    wall_w   : _k_fin_shell_wall_w[_idx],
    arm_p    : 0,
    gap      : fin_shell_gaps[_idx],
    land_flash : 0,
    ring     : 0,
    burn     : 1,
    ghost_t  : 0,
    seed     : random(1000)
  };

  array_push(fin_shells, _sh);

  fin_charge = max(fin_charge, 0.30 + _idx * 0.12);
  fin_chroma = max(fin_chroma, 0.20 + _idx * 0.10);

  for (var _i = 0; _i < _sh.sides; _i++) {
    var _w = fin_shell_wall(_sh, _i);
    scr_add_light(_w.cx, _w.cy, _sh.col, 3 + _idx);
  }
};

fin_build_shell_gaps = function(_seed) {
  var _prev = random_get_seed();
  random_set_seed(_seed);

  fin_shell_gaps = [];
  var _x = _k_fin_gap_lane_xmin + random(_k_fin_gap_lane_xmax - _k_fin_gap_lane_xmin);

  for (var _i = 0; _i < array_length(_k_fin_shell_beats); _i++) {
    if (_i > 0) {
      var _step = _k_fin_gap_step_min + random(_k_fin_gap_step_max - _k_fin_gap_step_min);
      if (random(1) < 0.5) _step = -_step;

      var _n = _x + _step;
      if (_n < _k_fin_gap_lane_xmin || _n > _k_fin_gap_lane_xmax) _n = _x - _step;
      _x = clamp(_n, _k_fin_gap_lane_xmin, _k_fin_gap_lane_xmax);
    }

    var _a  = point_direction(_k_fin_cx, _k_fin_cy, _x, _k_fin_gap_band_y);
    var _ae = point_direction(_k_fin_cx, _k_fin_cy,
                              _x + _k_fin_gap_band_px * 0.5, _k_fin_gap_band_y);

    array_push(fin_shell_gaps, {
      ang  : _a,
      w    : abs(angle_difference(_ae, _a)) * 2,
      lane : _x
    });
  }

  random_set_seed(_prev);
};

fin_ensure_shell_gaps = function() {
  if (array_length(fin_shell_gaps) >= array_length(_k_fin_shell_beats)) return;

  if (fin_shell_seed == 0) {
    if (variable_global_exists("debug_fin_shell_seed") && global.debug_fin_shell_seed != 0) {
      fin_shell_seed = global.debug_fin_shell_seed;
    } else {
      fin_shell_seed = 1 + irandom(999998);
    }
  }

  fin_build_shell_gaps(fin_shell_seed);
};

fin_shell_in_gap = function(_sh, _x, _y) {
  return abs(angle_difference(point_direction(_k_fin_cx, _k_fin_cy, _x, _y), _sh.gap.ang))
         < _sh.gap.w * 0.5;
};

fin_shell_gap_span = function(_sh, _w) {
  var _ex = _w.x2 - _w.x1;
  var _ey = _w.y2 - _w.y1;
  var _ts = [];

  for (var _s = -1; _s <= 1; _s += 2) {
    var _a  = _sh.gap.ang + _s * _sh.gap.w * 0.5;
    var _dx = lengthdir_x(1, _a);
    var _dy = lengthdir_y(1, _a);
    var _den = _ex * _dy - _ey * _dx;
    if (abs(_den) < 0.000001) continue;

    var _tt = ((_k_fin_cx - _w.x1) * _dy - (_k_fin_cy - _w.y1) * _dx) / _den;
    if (_tt >= 0 && _tt <= 1) array_push(_ts, _tt);
  }

  if (array_length(_ts) >= 2) return [ min(_ts[0], _ts[1]), max(_ts[0], _ts[1]) ];

  if (array_length(_ts) == 1) {
    return fin_shell_in_gap(_sh, _w.x1, _w.y1) ? [ 0, _ts[0] ] : [ _ts[0], 1 ];
  }

  return fin_shell_in_gap(_sh, (_w.x1 + _w.x2) * 0.5, (_w.y1 + _w.y2) * 0.5)
         ? [ 0, 1 ] : [ 1, 1 ];
};

fin_shell_solidity = function(_sh) {
  if (_sh.state == "arm")  return 0;
  if (_sh.state == "slam") return clamp(_sh.timer / max(_sh.slam_f, 1), 0, 1);
  return 1;
};

fin_section_p     = 0;
fin_charge        = 0;
fin_heartbeat     = 0;
fin_heartbeat_phase = 0;
fin_lock_flash    = 0;
fin_strike_flash  = 0;
fin_impact        = 0;
fin_chroma        = 0;
fin_implode       = 0;
fin_core          = 0;
fin_gap_glow      = 0;

_k_fin_orb_color      = global.avoid_col_danger;
_k_fin_orb_hot        = global.avoid_col_hot;
_k_fin_orb_glow_scale = 1.15;
_k_fin_spear_stretch  = 6.5;
_k_fin_stretch_div    = 2.4;

bullets_rewinding = false;

global.tidal_asteroid_templates = [];

var _template_count = 8;

for (var _template_id = 0; _template_id < _template_count; _template_id++) {
  var _verts = [];

  var _vert_count = irandom_range(7, 9);

  var _step = 360 / _vert_count;

  for (var i = 0; i < _vert_count; i++) {
    array_push(_verts, {ang : (i * _step) + random_range(-_step * 0.25, _step * 0.25), rad : random_range(0.55, 1.45)});
  }

  for (var i = 0; i < irandom_range(1, 3); i++) {
    var _v = irandom(array_length(_verts) - 1);

    _verts[_v].rad *= random_range(0.55, 0.75);
  }

  for (var i = 0; i < irandom_range(1, 2); i++) {
    var _v = irandom(array_length(_verts) - 1);

    _verts[_v].rad *= random_range(1.25, 1.5);
  }

  array_push(global.tidal_asteroid_templates, _verts);
}

tidal_streams = [];

tidal_wall_left = [];

tidal_wall_right = [];

tidal_debris = [];

tidal_dust = [];

tidal_wall_back_left = [];

tidal_wall_back_right = [];

tidal_wall_built = false;

tidal_wall_escalation = 0;

tidal_spawn_timer = 0;

tidal_spawn_interval = 30;

tidal_wall_progress = 0;

tidal_prev_heartbeat = 0;

cube_angle_x = 0;

cube_angle_y = 0;

cube_rot_speed_x = 0.5;

cube_rot_speed_y = 0.8;

cube_size = 250;

cube_center_x = room_width / 2;

cube_center_y = room_height / 2;

cube_perspective_dist = 500;

big_cube_projected = [];

cube_edges = [
  [ 0, 1 ], [ 1, 2 ], [ 2, 3 ], [ 3, 0 ],

  [ 4, 5 ], [ 5, 6 ], [ 6, 7 ], [ 7, 4 ],

  [ 0, 4 ], [ 1, 5 ], [ 2, 6 ], [ 3, 7 ]
];

cube_bullets_per_edge = 10;

_k_cube_line_player_clear_near = 56;
_k_cube_line_player_clear_far = 104;

cube_phase_timer = 0;

cube_breath_timer = 0;

cube_size_base = 220;

cube_edge_phase = 0;

cube_shoot_timestamps = [ 4653, 4654, 4684, 4711, 4756, 4776, 4797, 4817, 4851, 4879, 4920, 4940 ];

cube_face_current = -1;

cube_face_fade_timer = 0;

cube_face_fade_duration = 100;

cube_face_previous = -1;

cube_max_bullets_per_face = 3;
cube_face_bullets_enabled = false;
cube_face_grid_enabled = true;
cube_face_grid_spawned = false;

cube_rot_speed_x_normal = 0;

cube_rot_speed_y_normal = 0;

cube_shoot_phase_active = false;

cube_shoot_phase_slow_factor = 0.3;

cube_active = false;

cube_spawn_active = false;

cube_spawn_timer = 0;

cube_spawn_duration = 45;

cube_despawn_active = false;

cube_despawn_timer = 0;

cube_despawn_duration = 17;

hitstop_frames = 0;

cube_rot_ease_timer = 0;

cube_rot_ease_duration = room_speed * 3;

cube_extend = 1;

cube_seed_flash_timer = 0;

cube_seed_flash_duration = 10;

cube_echo_snapshots = [];

cube_echo_capture_timer = 0;

cube_boundary_push_amount = 0;

_k_cube_beat_len = 20.5;
cube_beats = [
  3997, 4018, 4038, 4059, 4079, 4100, 4120, 4141, 4161, 4182,
  4202, 4223, 4243, 4264, 4284, 4305, 4325, 4346, 4366, 4387,
  4407, 4428, 4448, 4469, 4489, 4510, 4530, 4551, 4571, 4592,
  4612, 4633, 4653, 4674, 4694, 4715, 4735, 4756, 4776, 4797,
  4817, 4838, 4858, 4879, 4899, 4920, 4940, 4961, 4981
];
cube_beat_index = 0;

_k_cube_t_spawn      = 4000;
_k_cube_t_idle       = 4059;
_k_cube_t_windup     = 4284;
_k_cube_t_coil       = 4530;
_k_cube_t_salvo      = 4653;
_k_cube_t_overload   = 4941;
_k_cube_t_despawn    = 4961;
_k_cube_t_surface_grid = _k_cube_t_salvo;

_k_screen_edge_hazard_t = _k_cube_t_spawn;
_k_screen_edge_warn_dist = 96;
_k_screen_edge_kill_pad = -56; // negative = kill boundary sits outside the visible camera rect,
screen_edge_warn = 0;
screen_edge_warn_l = 0;
screen_edge_warn_r = 0;
screen_edge_warn_t = 0;
screen_edge_warn_b = 0;
screen_edge_hit_flash = 0;

_k_cube_grid_margin = 0.24;
_k_cube_grid_size = 3;
_k_cube_grid_scale = 0.60;
_k_cube_grid_fade_lead = 100;
_k_cube_grid_preview_alpha = 0.50;
_k_cube_grid_back_alpha = 0.10;
_k_cube_grid_front_scale = 0.90;
_k_cube_grid_dim_scale = 0.82;
_k_cube_t_surface_grid_preview = _k_cube_t_surface_grid - _k_cube_grid_fade_lead;
_k_cube_grid_life_pad = 5;

cube_phase = "off";
cube_section_p = 0;

cube_heartbeat = 0;
cube_heartbeat_sub = 0;
_k_cube_heartbeat_decay = 0.075;

cube_charge = 0;
cube_coil = 0;
cube_overload = 0;
cube_core_flash = 0;
cube_ignite_flash = 0;
cube_detonation_flash = 0;
cube_strobe = 0;
cube_rot_surge = 0;
cube_edge_surge = 0;
cube_lock_flash = 0;

cube_face_heat = array_create(6, 0);
cube_face_flash = array_create(6, 0);
cube_vertex_heat = array_create(8, 0);
cube_vertex_ignited = array_create(8, false);

small_cube_projected = [];
_k_cube_core_size = 62;
cube_core_angle_x = 0;
cube_core_angle_y = 0;
_k_cube_core_rot_x = -0.9;
_k_cube_core_rot_y = 1.6;
cube_core_extend = 0;
cube_core_fade = 1;
_k_cube_core_clear_near = 60;
_k_cube_core_clear_far = 150;
_k_cube_core_clear_floor = 0.15;

cube_arcs = [];
_k_cube_arc_max = 26;

cube_leaks = [];
_k_cube_leak_max = 12;

cube_edge_pulses = [];
_k_cube_edge_pulse_max = 40;

cube_scars = [];
_k_cube_scar_max = 8;

cube_cracks = [];
_k_cube_crack_max = 30;

cube_muzzles = [];
_k_cube_muzzle_max = 24;

cube_ignitions = [];

cube_ghosts = [];
_k_cube_ghost_max = 10;
cube_ghost_timer = 0;

_k_cube_arc_chance_idle    = 0.10;
_k_cube_arc_chance_peak    = 0.85;
_k_cube_leak_chance        = 0.16;
_k_cube_ghost_interval     = 4;
_k_cube_beat_shake         = 3.5;
_k_cube_salvo_shake        = 11;
_k_cube_lens_radius        = 300;
_k_cube_lens_max           = 0.50;
_k_cube_letterbox_coil     = 0.85;
_k_cube_letterbox_overload = 0.95;
_k_cube_converge_per_beat  = 7;

application_surface_draw_enable(false);

scene_snapshot = -1;

bolt_surface = -1;

u_time_handle = shader_get_uniform(shd_lightning_glow, "u_time");

u_intensity_handle = shader_get_uniform(shd_lightning_glow, "u_intensity");

u_texel_handle = shader_get_uniform(shd_lightning_glow, "u_texel");

lightning_surface = -1;

u_time_handle2 = shader_get_uniform(shd_lightning_distort, "u_time");

u_strength_handle = shader_get_uniform(shd_lightning_distort, "u_strength");

u_texel_handle2 = shader_get_uniform(shd_lightning_distort, "u_texel");

u_baseTex_handle = shader_get_sampler_index(shd_lightning_distort, "u_baseTex");

u_vignette_handle = shader_get_uniform(shd_lightning_distort, "u_vignette_intensity");

u_aberration_handle = shader_get_uniform(shd_lightning_distort, "u_aberration_strength");

u_bloom_handle = shader_get_uniform(shd_lightning_distort, "u_bloom_intensity");

u_tear_handle = shader_get_uniform(shd_lightning_distort, "u_tear_amount");

u_ripple_handle = shader_get_uniform(shd_lightning_distort, "u_global_ripple");

u_ring_centers_handle = shader_get_uniform(shd_lightning_distort, "u_ring_centers");

u_ring_radii_handle = shader_get_uniform(shd_lightning_distort, "u_ring_radii");

u_ring_strengths_handle = shader_get_uniform(shd_lightning_distort, "u_ring_strengths");

u_ring_count_handle = shader_get_uniform(shd_lightning_distort, "u_ring_count");

u_swirl_centers_handle = shader_get_uniform(shd_lightning_distort, "u_swirl_centers");

u_swirl_radii_handle = shader_get_uniform(shd_lightning_distort, "u_swirl_radii");

u_swirl_strengths_handle = shader_get_uniform(shd_lightning_distort, "u_swirl_strengths");

u_swirl_count_handle = shader_get_uniform(shd_lightning_distort, "u_swirl_count");

u_glow_color_handle = shader_get_uniform(shd_bullet_glow, "u_color");

u_glow_falloff_handle = shader_get_uniform(shd_bullet_glow, "u_falloff");

u_glow_uvrect_handle = shader_get_uniform(shd_bullet_glow, "u_uvRect");

u_glow_intensity_handle = shader_get_uniform(shd_bullet_glow, "u_intensity");

u_intro_dim_h = shader_get_uniform(shd_lightning_distort, "u_intro_dim");

u_bass = shader_get_uniform(shd_hex, "u_bass");

u_slash_amount_handle = shader_get_uniform(shd_lightning_distort, "u_slash_amount");
u_slash_center_handle = shader_get_uniform(shd_lightning_distort, "u_slash_center");

slash_amount = 0;
slash_center_x = room_width / 2;
slash_center_y = room_height / 2;
slash_timer = 0;
slash_active = false;

bass_flash = 0;

bass_visual = 0;

bass_wave = 0;

bass_waves = [];

shadow_positions = [];

arena_lights = [];

bass_hits = [
  51,   171,  185,  201,  212,  291,  316,  336,  353,  369,  380,  504,  518,  533,  544,  709,  730,  751,  772,
  792,  813,  833,  853,  875,  895,  915,  935,  956,  975,  995,  1036, 1052, 1070, 1080, 1095, 1111, 1122, 1135,
  1150, 1162, 1172, 1280, 1367, 1387, 1407, 1428, 1448, 1469, 1489, 1509, 1529, 1550, 1570, 1590, 1610, 1630, 1648,
  1691, 1712, 1733, 1752, 1773, 1793, 1814, 1835, 1856, 1875, 1895, 1916, 2025, 2045, 2065, 2085, 2106, 2127, 2147,
  2168, 2188, 2207, 2228, 2248, 2270, 2286, 2302, 2318, 2352, 2393, 2434, 2472, 2515, 2536, 2558, 2579, 2597, 2681,
  2703, 2723, 2744, 2765, 2784, 2806, 2826, 2847, 2866, 2886, 2906, 2926, 2947, 2968, 3012, 3033, 3053, 3073, 3094,
  3114, 3135, 3155, 3174, 3195, 3216, 3237, 3260, 3272, 3283, 3292, 3303, 3320, 3322, 3344, 3362, 3383, 3403, 3423,
  3443, 3463, 3484, 3505, 3525, 3546, 3566, 3667, 3710, 3752, 3790, 3829, 3852, 3873, 3895, 3915
];

_k_floor_quake_max = 6;
_k_floor_quake_speed = 0.055;
_k_floor_quake_life = 46;
_k_floor_scar_max = 6;
_k_floor_scar_life = 300;
_k_floor_scar_threshold = 0.62;
_k_floor_charge_decay = 0.965;
_k_floor_charge_follow = 0.11;
_k_floor_beat_decay = 0.085;
_k_floor_spin_decay = 0.88;
_k_floor_spin_max = 8;
_k_floor_epicentre_min_power = 3;
_k_floor_epicentre_hold = 40;
_k_floor_molten = global.avoid_col_ember;

floor_quakes = [];
floor_scars = [];

floor_beat = 0;
floor_charge = 0;
floor_charge_target = 0;
floor_spin = 0;

floor_focus_x = room_width / 2;
floor_focus_y = room_height / 2;
floor_focus_amount = 0;

floor_epicenter_x = room_width / 2;
floor_epicenter_y = room_height / 2;
floor_epicenter_power = 0;
floor_epicenter_hold = 0;

floor_quake_last_t = -999;

u_ribbon_time = shader_get_uniform(shd_ribbon_plasma, "u_time");

intro_dim_amount = 0;

glow_surface = -1;

u_laser_time_handle = shader_get_uniform(shd_laser_beam, "u_time");

u_laser_noise_handle = shader_get_sampler_index(shd_laser_beam, "u_noise");

u_laser_speed_handle = shader_get_uniform(shd_laser_beam, "u_speed");

u_laser_coreWidth_handle = shader_get_uniform(shd_laser_beam, "u_coreWidth");

u_laser_haloWidth_handle = shader_get_uniform(shd_laser_beam, "u_haloWidth");

u_laser_noiseStrength_handle = shader_get_uniform(shd_laser_beam, "u_noiseStrength");

u_laser_twist_handle = shader_get_uniform(shd_laser_beam, "u_twist");

u_laser_brightness_handle = shader_get_uniform(shd_laser_beam, "u_brightness");

u_laser_whiteAmount_handle = shader_get_uniform(shd_laser_beam, "u_whiteAmount");

ini_open(CONFIG_FILENAME);
laser_glowIntensity = ini_read_real(CONFIG_SECTION_LASER, "laser_glowIntensity", 1.14);
laser_glowRadius    = ini_read_real(CONFIG_SECTION_LASER, "laser_glowRadius", 100);
laser_glowFalloff   = ini_read_real(CONFIG_SECTION_LASER, "laser_glowFalloff", 2.1);
ini_close();

vignette_pulse = 0;

aberration_pulse = 0;

bloom_base = 0.26;

bloom_pulse = 0;

tear_amount = 0;

global_ripple_pulse = 0;

swirl_strength = 0;

swirl_target = 0;

dna_active = false;

dna_veil = 0;
dna_fade_active = false;
dna_fade_start_t = 0;

dna_rotating = false;

dna_center_y = room_height / 2;

dna_height = 800;

dna_radius = 60;

dna_amount = 40;

dna_time = 0;

dna_rung_spacing = 2;

rung_bullets = 5;

chain_delay = 2;

chain_step = 2;

active_dna_rung_chains = 0;

dna_rung_queue = [];

k_max_concurrent_rung_chains = 150;

dna_spawn_cursor = 0;
dna_spawn_rows_per_frame = dna_amount;

var _rung_columns = ceil(dna_amount / dna_rung_spacing);

var _array_size = (dna_amount * 2) + (_rung_columns * rung_bullets);

dna_structures = [];

dna_structures[0] = {
  array : array_create(_array_size, -4),
  center_x : -100,
  center_y : dna_center_y,
  time : 0,
  dir : -1,
  angle_offset : 0,
  mirror : 1
};

dna_structures[1] = {
  array : array_create(_array_size, -4),
  center_x : 900,
  center_y : dna_center_y,
  time : 0,
  dir : -1,
  angle_offset : pi,
  mirror : -1
};

_k_dna_spawn_t = _k_arc_rift_t;
_k_dna_fade_frames = 34;
_k_dna_phase_seed_t = 4990;
_k_dna_phase_hide_t = 5219;
_k_dna_phase_resume_t = 5965;

dna_time_for_t = function(_time) {
  var _frames = 0;
  if (_time >= _k_dna_phase_seed_t) {
    _frames += min(_time, _k_dna_phase_hide_t) - _k_dna_phase_seed_t + 1;
  }
  if (_time > _k_dna_phase_resume_t) {
    _frames += _time - _k_dna_phase_resume_t;
  }
  return max(0, _frames) * 0.04;
};

dna_spawn_fully_active = function() {
  if (dna_spawn_cursor >= dna_amount) return;

  for (var i = 0; i < dna_amount; i++) {
    for (var s = 0; s < array_length(dna_structures); s++) {
      var _struct = dna_structures[s];
      var _cx = _struct.center_x;
      var _cy = _struct.center_y;

      if (!instance_exists(_struct.array[i])) {
        var _b = instance_create_layer(_cx, _cy, "Instances", oDNATest);
        _b.dna_mode = true;
        _b.dna_type = 0;
        _b.dna_side = 0;
        _b.dna_index = i;
        _b.spawn_scale = 1;
        _b.spawn_timer = 0;
        _b.spawn_duration = 1;
        _b.strand = 0;
        _b.struct_id = s;
        _b.dna_rung_spacing = dna_rung_spacing;
        _b.rung_bullets = rung_bullets;
        _b.chain_delay = chain_delay;
        _b.chain_step = chain_step;
        _b.chain_dir = 1;
        _b.lightning_hit = true;
        _b.active = true;
        _b.state = "idle";
        _b.hit_timer = 0;
        _b.strike_flash = 0;
        _b.line_life = 0;
        _b.visible = true;
        _struct.array[i] = _b;
      }

      if (!instance_exists(_struct.array[i + dna_amount])) {
        var _b2 = instance_create_layer(_cx, _cy, "Instances", oDNATest);
        _b2.dna_mode = true;
        _b2.dna_type = 0;
        _b2.dna_side = 1;
        _b2.dna_index = i;
        _b2.spawn_scale = 1;
        _b2.spawn_timer = 0;
        _b2.spawn_duration = 1;
        _b2.strand = 1;
        _b2.struct_id = s;
        _b2.dna_rung_spacing = dna_rung_spacing;
        _b2.rung_bullets = rung_bullets;
        _b2.chain_delay = chain_delay;
        _b2.chain_step = chain_step;
        _b2.chain_dir = 1;
        _b2.lightning_hit = true;
        _b2.active = true;
        _b2.state = "idle";
        _b2.hit_timer = 0;
        _b2.strike_flash = 0;
        _b2.line_life = 0;
        _b2.visible = true;
        _struct.array[i + dna_amount] = _b2;
      }

      if (i mod dna_rung_spacing == 0) {
        for (var r = 0; r < rung_bullets; r++) {
          var _rung_index = dna_amount * 2 + floor(i / dna_rung_spacing) * rung_bullets + r;

          if (!instance_exists(_struct.array[_rung_index])) {
            var _rb = instance_create_layer(_cx, _cy, "Instances", oDNATest);
            _rb.dna_mode = true;
            _rb.dna_type = 2;
            _rb.rung_id = i;
            _rb.rung_position = r;
            _rb.spawn_scale = 1;
            _rb.spawn_timer = 0;
            _rb.spawn_duration = 1;
            _rb.strand = -1;
            _rb.dna_index = -1;
            _rb.struct_id = s;
            _rb.dna_rung_spacing = dna_rung_spacing;
            _rb.rung_bullets = rung_bullets;
            _rb.chain_delay = chain_delay;
            _rb.chain_step = chain_step;
            _rb.rung_claimed = true;
            _rb.rung_dir = 1;
            _rb.chain_is_rung = false;
            _rb.lightning_hit = true;
            _rb.active = true;
            _rb.state = "idle";
            _rb.hit_timer = 0;
            _rb.strike_flash = 0;
            _rb.line_life = 0;
            _rb.visible = true;
            _struct.array[_rung_index] = _rb;
          }
        }
      }
    }
  }

  dna_spawn_cursor = dna_amount;
  active_dna_rung_chains = 0;
  dna_rung_queue = [];
  dna_write_arcs = [];
  dna_cross_arcs = [];
  dna_chain_flash = 0;
};

_k_dna_despawn_t = 6527;

dna_despawn_active = false;

dna_despawn_start_t = 0;

_k_dna_despawn_duration = 90;

_k_dna_despawn_sweep_start_y = room_height + 40;

_k_dna_despawn_sweep_end_y = -dna_height;

dna_despawn_sweep_y = _k_dna_despawn_sweep_start_y;

final_cut_triggered = false;

final_cut_timer = 0;

song_end_handled = false;

with (oFinalCutWarp) instance_destroy();

// ============================================================================
// FINAL CUT (t7291 -> t7470)
// ----------------------------------------------------------------------------
// ============================================================================
_k_fin_t_end            = 7470;  // HARD warp frame
_k_fin_cut_timeout      = 260;   // watchdog: frames since the hit, if t stalls
_k_final_cut_shake      = 30;

_k_fin_seal_lead        = 12;

_k_fin_hush_lead        = 9;     // frames of suppression before the beat
_k_fin_blade_lead       = 4;     // frames the stroke takes to cross the frame
_k_fin_cut_veil_start   = 5;     // frame the live scene hands over to the halves
_k_fin_cut_veil_frames  = 3;     // cross-dissolve length
_k_fin_cut_fly_frames   = 32;    // frames the two halves take to leave
_k_fin_cut_fly_dist     = 560;

_k_fin_cut_flare_beats  = [ 7310, 7315, 7320, 7330 ];
_k_fin_cut_flare_power  = [ 1.00, 0.78, 0.60, 0.44 ];

_k_fin_cut_cool_frames  = 80;    // frames from the hit to the wound's cold floor
_k_fin_cut_span_max     = 1.22;
_k_fin_cut_span_min     = 0.13;
_k_fin_cut_span_start   = 80;    // frame the wound starts closing
_k_fin_cut_span_frames  = 76;
_k_fin_cut_drip_from    = 26;    // frame the wound starts bleeding embers
_k_fin_cut_drip_every   = 5;
_k_fin_cut_release_t    = 136;   // frame the cyan release starts rising
_k_fin_cut_release_len  = 31;    // ... and peaks at t7458, where the seal takes over
_k_fin_cut_spark_max    = 170;

_k_fin_cut_shader_sep   = 0.05 / sqrt(2);

final_cut_capture = 0;

fin_hush          = 0;   // 0..1 suppression ramp into the beat
fin_blade_p       = 0;   // 0..1 stroke progress; exactly 1 on the beat
fin_blade_glow    = 0;
fin_cut_flash     = 0;   // the impact frame
fin_cut_veil      = 0;
fin_cut_fly       = 0;
fin_cut_scar      = 0;   // the wound's heat
fin_cut_flare     = 0;
fin_cut_span      = 0;
fin_cut_release   = 0;
fin_cut_jitter    = 0;
fin_cut_kicked    = false;

final_cut_surface = -1;  // the frame frozen at the moment it was cut in two
fin_cut_captured  = false;
final_cut_sparks  = [];
fin_cut_scar_pts  = [];

fin_cut_roll_scar = function() {
  fin_cut_scar_pts = [];

  var _a1 = random_range(1.1, 1.8), _q1 = random_range(2.2, 3.4), _s1 = random(2 * pi);
  var _a2 = random_range(0.5, 0.9), _q2 = random_range(5.0, 7.5), _s2 = random(2 * pi);
  var _a3 = random_range(0.2, 0.4), _q3 = random_range(11, 15),   _s3 = random(2 * pi);
  var _qw = random_range(3.5, 6.0), _sw = random(2 * pi);

  var _scn = 96;
  for (var _sci = 0; _sci <= _scn; _sci++) {
    var _scf = _sci / _scn;
    var _sce = 1 - power(abs(_scf * 2 - 1), 2);

    array_push(fin_cut_scar_pts, {
      f   : _scf,
      off : (_a1 * sin(_q1 * _scf * pi + _s1)
           + _a2 * sin(_q2 * _scf * pi + _s2)
           + _a3 * sin(_q3 * _scf * pi + _s3)) * _sce,
      w   : 0.55 + _sce * 0.75 + 0.10 * sin(_qw * _scf * pi + _sw)
    });
  }
};

fin_cut_push_embers = function(_n, _power, _burst) {
  var _ax = GAME_WIDTH, _ay = -GAME_HEIGHT;
  var _al = point_distance(0, 0, _ax, _ay);
  var _ux = _ax / _al, _uy = _ay / _al;
  var _px = -_uy,      _py = _ux;

  var _reach = max(_k_fin_cut_span_min, clamp(fin_cut_span, 0, 1));

  for (var _ei = 0; _ei < _n; _ei++) {
    if (array_length(final_cut_sparks) >= _k_fin_cut_spark_max) return;

    var _slow = _burst ? ((_ei mod 4) == 3) : true;
    var _ef = _burst ? random_range(-0.96, 0.96)
                     : choose(-1, 1) * _reach * random_range(0.84, 1.0);
    var _es = choose(-1, 1);
    var _ev = (_slow ? random_range(0.5, 2.2)
                     : random_range(3.5, 12.5) * (1 - abs(_ef) * 0.35)) * _power;
    var _ea = random_range(-2.6, 2.6) * (_slow ? 0.3 : 1);
    var _el = _slow ? (52 + irandom(30)) : (22 + irandom(16));

    array_push(final_cut_sparks, {
      x  : GAME_WIDTH  * 0.5 + _ux * _al * 0.5 * _ef + _px * random_range(-3, 3),
      y  : GAME_HEIGHT * 0.5 + _uy * _al * 0.5 * _ef + _py * random_range(-3, 3),
      vx : _px * _ev * _es + _ux * _ea,
      vy : _py * _ev * _es + _uy * _ea,
      life : _el, life_max : _el,
      size : _slow ? random_range(0.5, 1.1) : random_range(0.6, 1.7),
      hot  : random_range(0.45, 1),
      col  : choose(global.avoid_col_warning, global.avoid_col_ember,
                    global.avoid_col_hot, global.avoid_col_cyan)
    });
  }
};

fin_cut_axis = function() {
  var _vw = GAME_WIDTH, _vh = GAME_HEIGHT;
  if (instance_exists(oCameraController) &&
      oCameraController.current_cam_w > 1 && oCameraController.current_cam_h > 1) {
    _vw = oCameraController.current_cam_w;
    _vh = oCameraController.current_cam_h;
  }
  return {
    ang  : point_direction(0, 0, _vw, -_vh),
    half : point_distance(0, 0, _vw, _vh) * 0.55
  };
};

riser = undefined;

_k_riser_cx           = 400;
_k_riser_deck_y       = 708;                              // the reactor deck

_k_riser_fall_letterbox = 0;
_k_riser_top_y        = _k_vault_cy + _k_vault_wall_in;   // 422, the plug's floor
_k_riser_half_deck    = 200;                              // half-width at the deck
_k_riser_channel      = 92;
_k_riser_crown_y      = 100;
_k_riser_crown_half   = 96;
_k_riser_shell_in     = _k_vault_wall_in;                 // 118
_k_riser_shell_out    = _k_vault_wall_out;                // 137
_k_riser_plug_circum  = _k_vault_wall_out / 0.86602540;   // 158.19
_k_riser_vault_circum = _k_vault_wall_in / 0.86602540;    // 136.26
_k_riser_deck_reach   = 34;
_k_riser_deck_grace   = 2;     // the deck's face is machine, not a surface
_k_riser_wall_grace   = 4;     // reconciles a centre-point test with an 11 px mask
_k_riser_far_x        = 760;   // where the casing parks before it closes

// -- the door ---------------------------------------------------------------
_k_riser_door_faces  = [0, 2, 3, 5];
_k_riser_door_half   = 50;
_k_riser_t_door_mark = 5000;  // beat 0, the frame the structure comes up
_k_riser_t_door_open = 5017;  // beat 1

// -- the ladder -------------------------------------------------------------
_k_riser_t_fall    = _k_cube_t_despawn;                          // 4961
_k_riser_t_deck    = _k_cube_t_despawn + cube_despawn_duration;  // 4978
_k_riser_t_erect   = 5000;
_k_riser_t_arm     = 5017;
_k_riser_t_survey  = 5085;
_k_riser_t_purge   = 5119;
_k_riser_t_handoff = _k_vault_beats[0];                          // 5146 ANCHOR

_k_riser_t_seal    = _k_vault_beats[2];                          // 5179 WAKE
_k_riser_t_end     = 5192;

_k_riser_beats     = [5000, 5017, 5034, 5051, 5068, 5085, 5102, 5119];

_k_riser_beat_arms = [   0,    0,    1,    0,    2,    0,    2,    0];

// -- breaker levels ---------------------------------------------------------
// with an upper door face that is not hard, it is impossible.
_k_riser_levels    = 4;
_k_riser_level_y0  = 668;
_k_riser_level_gap = 48;

// -- the arms ---------------------------------------------------------------
_k_riser_arm_life       = 1;      // beats an arm holds before it withdraws
_k_riser_arm_lock       = 2;      // beats before its level can be used again

_k_riser_arm_lead_beats = 2;

_k_riser_door_side_levels = 1;
_k_riser_cover_min      = 0.30;
_k_riser_cover_max      = 0.44;
_k_riser_cover_jam      = 0.12;
_k_riser_arm_clear      = 30;
_k_riser_arm_reach_band = 26;
_k_riser_arm_kill       = 10;     // lethal half-thickness
_k_riser_arm_th         = 13;     // drawn half-thickness
_k_riser_arm_head       = 16;
_k_riser_head_len       = 8;
_k_riser_rib_gap        = 18;
_k_riser_arm_jitter     = 4;
_k_riser_stinger        = 26;

_k_riser_out_steps  = [0.55, 0.86, 1.00];
_k_riser_in_steps   = [0.68, 0.30, 0.00];
_k_riser_coil_floor = 0.20;
_k_riser_tick       = 12;

// -- the walls --------------------------------------------------------------
_k_riser_rail_w       = 18;
_k_riser_rail_kill    = 22;   // the purge's lethal band, measured inward
_k_riser_purge_frames = 12;
_k_riser_rung_gap     = 21;
_k_riser_rung_len     = 7;
_k_riser_packets      = 4;
_k_riser_packet_rate  = 34;
_k_riser_slot_h       = 16;
_k_riser_head_w       = 14;
_k_riser_head_h       = 22;

_k_riser_seam_ratio = 0.26;

// -- the casing -------------------------------------------------------------
_k_riser_recess    = 46;
_k_riser_recess_a  = 0.55;
_k_riser_panel_gap = 58;
_k_riser_conduit_x = 252;
_k_riser_conduit_w = 15;
_k_riser_conduit_j = 88;    // joint collar spacing
_k_riser_chev_gap  = 46;
_k_riser_chev_rate = 9;
_k_riser_chev_off  = 13;
_k_riser_chev_w    = 13;
_k_riser_chev_h    = 9;

// -- the flood --------------------------------------------------------------
_k_riser_flood_t      = [4978, 5000, 5017, 5034, 5051, 5068, 5085, 5102, 5119, 5133, 5146, 5158];
_k_riser_flood_h      = [ 718,  716,  712,  704,  690,  670,  644,  614,  580,  542,  504,  468];
_k_riser_flood_rest   = 724;
_k_riser_flood_settle = 456;
_k_riser_flood_grace  = 4;
_k_riser_flood_band   = 62;
_k_riser_flood_lift   = 150;
_k_riser_flood_glow_n = 10;
_k_riser_surf_n       = 22;
_k_riser_surf_amp     = 7;

// -- assembly ---------------------------------------------------------------
_k_riser_erect_t  = [_k_riser_t_erect, _k_riser_t_erect + 6,
                     _k_riser_t_erect + 12, _k_riser_t_arm];
_k_riser_erect_h  = [0.34, 0.66, 0.90, 1.00];
_k_riser_casing_t = [_k_riser_t_deck, _k_riser_t_deck + 7,
                     _k_riser_t_deck + 14, _k_riser_t_erect];
_k_riser_casing_h = [0.24, 0.54, 0.82, 1.00];

_k_riser_mouth_reach = 96;
_k_riser_mouth_a     = 0.26;

_k_riser_flue_top    = 26;
_k_riser_flue_rib    = 38;

// -- the lock ---------------------------------------------------------------
_k_riser_lock_r0     = 250;
_k_riser_lock_r1     = 78;    // where the rings converge
_k_riser_lock_rings  = 3;
_k_riser_lock_squash = 0.30;
_k_riser_lock_half   = 132;

_k_riser_lock_high   = 236;
_k_riser_lock_chev   = 5;

// -- the fall ---------------------------------------------------------------
_k_riser_fall_swing  = 236;
_k_riser_fall_ease   = 1.55;
_k_riser_tether_lag  = 0.17;
_k_riser_tether_rise = 26;
_k_riser_tether_grab = 3.4;
_k_riser_tether_auth = 0.86;

_k_riser_release_pop = 7.6;
_k_riser_release_y   = 30;

// -- pools ------------------------------------------------------------------
_k_riser_ring_max   = 10;
_k_riser_vent_max   = 74;
_k_riser_spark_max  = 90;
_k_riser_debris_max = 12;
_k_riser_vent_cols  = [global.avoid_col_cyan, global.avoid_col_warning,
                       global.avoid_col_violet];

bc_profile_active = false;
bc_profile_segment_name = "";
bc_profile_segment_t = 0;
bc_profile_target_frames = 0;
bc_profile_frame = 0;
bc_profile_samples = 0;
bc_profile_invalid_samples = 0;
bc_profile_fps_sum = 0;
bc_profile_fps_min = 999999;

var _bc_profile_requested =
  DEBUG &&
  variable_global_exists("bc_cli_profile_enabled") &&
  global.bc_cli_profile_enabled &&
  variable_global_exists("bc_cli_profile_segments") &&
  global.bc_cli_profile_index < array_length(global.bc_cli_profile_segments);

var _practice_requested =
  variable_global_exists("avoidance_practice_active") &&
  global.avoidance_practice_active &&
  variable_global_exists("avoidance_practice_t");

if (_bc_profile_requested) {
  var _bc_profile_segment = global.bc_cli_profile_segments[global.bc_cli_profile_index];
  bc_profile_active = true;
  bc_profile_segment_name = _bc_profile_segment.name;
  bc_profile_segment_t = _bc_profile_segment.t;
  bc_profile_target_frames = _bc_profile_segment.frames;
  bc_profile_frame = 0;
  bc_profile_samples = 0;
  bc_profile_invalid_samples = 0;
  bc_profile_fps_sum = 0;
  bc_profile_fps_min = 999999;

  show_debug_message("[BC_PROFILE] start " + string(global.bc_cli_profile_index + 1) + "/" +
    string(array_length(global.bc_cli_profile_segments)) + ": " + bc_profile_segment_name +
    " @ t" + string(bc_profile_segment_t) + " for " + string(bc_profile_target_frames) + " frames");

  set_t(bc_profile_segment_t);
}
else if (_practice_requested) {
  set_t(global.avoidance_practice_t);
  global.debug_resume_t = global.avoidance_practice_t;
}
else {
  if (t > 0) set_t(t);

  if (variable_global_exists("debug_resume_t")) set_t(global.debug_resume_t);
}
