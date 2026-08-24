iris_echoes = [];

if (variable_global_exists("avoidance_practice_active") && global.avoidance_practice_active) {
  practice_hud_timer++;
}

var _death_stops_run =
  avoidance_run_stopped ||
  instance_exists(oPlayerDeath) ||
  instance_exists(oGameover) ||
  (instance_exists(oPlayer) && oPlayer.dead);

if (_death_stops_run) {
  avoidance_stop_for_death();

  intro_dim_amount = 0;

  for (var _sb = array_length(slash_bolts) - 1; _sb >= 0; _sb--) {
    slash_bolts[_sb].life--;
    if (slash_bolts[_sb].life <= 0) array_delete(slash_bolts, _sb, 1);
  }

  exit;
}

last_t = t;

t++;

var music_t = floor(audio_sound_get_track_position(global.debug_music_instance) * room_speed);
var _music_delta = music_t - audio_sync_prev_music_t;
audio_sync_prev_music_t = music_t;

if (_music_delta > audio_sync_stall_delta_frames) {
  audio_sound_set_track_position(global.debug_music_instance, music_offset + t / room_speed);
  audio_sync_prev_music_t = t;
  music_t = t;
}
else if (abs(music_t - t) > audio_sync_tolerance_frames) {
  if (music_t > t) {
    t = music_t;
  } else {
    t = music_t;
    last_t = t;
  }
}

screen_edge_hit_flash = max(0, screen_edge_hit_flash - 0.08);
screen_edge_warn = 0;
screen_edge_warn_l = 0;
screen_edge_warn_r = 0;
screen_edge_warn_t = 0;
screen_edge_warn_b = 0;

if (t >= _k_screen_edge_hazard_t && instance_exists(oCameraController) &&
    instance_exists(oPlayer) && !oPlayer.dead && !instance_exists(oGameover)) {
  var _edge_l = oCameraController.current_cam_x + _k_screen_edge_kill_pad;
  var _edge_t = oCameraController.current_cam_y + _k_screen_edge_kill_pad;
  var _edge_r = oCameraController.current_cam_x + oCameraController.current_cam_w - _k_screen_edge_kill_pad;
  var _edge_b = oCameraController.current_cam_y + oCameraController.current_cam_h - _k_screen_edge_kill_pad;

  if (oCameraController.current_cam_w > 0 && oCameraController.current_cam_h > 0) {
    var _edge_dl = oPlayer.bbox_left - _edge_l;
    var _edge_dr = _edge_r - oPlayer.bbox_right;
    var _edge_dt = oPlayer.bbox_top - _edge_t;
    var _edge_db = _edge_b - oPlayer.bbox_bottom;
    var _edge_warn_dist = max(_k_screen_edge_warn_dist, 1);

    screen_edge_warn_l = clamp(1 - (_edge_dl / _edge_warn_dist), 0, 1);
    screen_edge_warn_r = clamp(1 - (_edge_dr / _edge_warn_dist), 0, 1);
    screen_edge_warn_t = clamp(1 - (_edge_dt / _edge_warn_dist), 0, 1);
    screen_edge_warn_b = clamp(1 - (_edge_db / _edge_warn_dist), 0, 1);

    var _edge_min = min(min(_edge_dl, _edge_dr), min(_edge_dt, _edge_db));

    screen_edge_warn = max(max(screen_edge_warn_l, screen_edge_warn_r),
                           max(screen_edge_warn_t, screen_edge_warn_b));

    if (_edge_min < 0) {
      screen_edge_warn = 1;
      if (player_register_hazard_hit()) {
        screen_edge_hit_flash = 1;
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 8);
          oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.18);
        }
      }
    }
  }
}

for (var i = 0; i < array_length(bass_hits); i++) {
  if (bass_hits[i] > last_t && bass_hits[i] <= t) {
    bass_flash = min(1, bass_flash + 0.6);
    floor_beat = 1;
  }
}

if (impact_wave_radius >= 0) {
  impact_wave_radius += impact_wave_speed;
  if (impact_wave_radius > 3.0) impact_wave_radius = -1;
}

if (array_contains(bass_hits, t)) {
  array_push(bass_waves, 0);
}

for (var i = array_length(bass_waves) - 1; i >= 0; i--) {
  bass_waves[i] += 0.035;

  if (bass_waves[i] > 3.0) {
    array_delete(bass_waves, i, 1);
  }
}

bass_visual = lerp(bass_visual, bass_flash, 0.25);
bass_flash = max(0, bass_flash - 0.08);

for (var i = array_length(floor_quakes) - 1; i >= 0; i--) {
  floor_quakes[i].radius += floor_quakes[i].speed;
  floor_quakes[i].life--;
  if (floor_quakes[i].life <= 0) array_delete(floor_quakes, i, 1);
}

for (var i = array_length(floor_scars) - 1; i >= 0; i--) {
  floor_scars[i].age++;
  floor_scars[i].heat = max(0, floor_scars[i].heat - floor_scars[i].cool);
  if (floor_scars[i].age >= floor_scars[i].life) array_delete(floor_scars, i, 1);
}

floor_beat = max(0, floor_beat - _k_floor_beat_decay);

if (instance_exists(oCameraController)) {
  floor_charge_target = max(floor_charge_target, oCameraController.letterbox_target / 0.7);
}
floor_charge_target = clamp(floor_charge_target * _k_floor_charge_decay, 0, 1);
floor_charge += (floor_charge_target - floor_charge) * _k_floor_charge_follow;

floor_spin = clamp(floor_spin * _k_floor_spin_decay, -_k_floor_spin_max, _k_floor_spin_max);
if (abs(floor_spin) < 0.01) floor_spin = 0;

if (floor_epicenter_hold > 0) {
  floor_epicenter_hold--;
  floor_focus_x = lerp(floor_focus_x, floor_epicenter_x, 0.2);
  floor_focus_y = lerp(floor_focus_y, floor_epicenter_y, 0.2);
} else {
  floor_epicenter_x = lerp(floor_epicenter_x, room_width / 2, 0.05);
  floor_epicenter_y = lerp(floor_epicenter_y, room_height / 2, 0.05);
}

var _floor_focus_want = (floor_epicenter_hold > 0) ? floor_charge * 0.85 : 0;
floor_focus_amount += (_floor_focus_want - floor_focus_amount) * 0.08;

var dna_count = instance_number(oDNATest);

vignette_pulse = max(0, vignette_pulse - 0.05);
aberration_pulse = max(0, aberration_pulse - 1.5);
bloom_pulse = max(0, bloom_pulse - 0.02);
global_ripple_pulse = max(0, global_ripple_pulse - 0.05);
arrow_scan_flash = max(0, arrow_scan_flash - 1);

for (var i = array_length(lightning_imprints) - 1; i >= 0; i--) {
  lightning_imprints[i].life -= 1;
  if (lightning_imprints[i].life <= 0) {
    array_delete(lightning_imprints, i, 1);
  }
}

for (var i = array_length(ring_ripples) - 1; i >= 0; i--) {
  ring_ripples[i].radius += 6;
  ring_ripples[i].life--;
  ring_ripples[i].alpha = ring_ripples[i].life / 24;
  if (ring_ripples[i].life <= 0) array_delete(ring_ripples, i, 1);
}

for (var i = array_length(ring_splatter) - 1; i >= 0; i--) {
  ring_splatter[i].alpha -= ring_splatter[i].fade;
  if (ring_splatter[i].alpha <= 0) array_delete(ring_splatter, i, 1);
}
ring_spawn_flash_timer = min(ring_spawn_flash_timer + 1, ring_spawn_flash_duration);

if (warning_flash_timer > 0) warning_flash_timer--;

if (center_warning_timer == 1) {
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_center_warning_release_shake);
  }
}
if (center_warning_timer > 0 && (center_warning_timer mod _k_center_warning_echo_interval == 0)) {
  var _echo_prog = 1 - (center_warning_timer / _k_center_warning_duration);
  var _echo_radius = lerp(_k_center_warning_iris_start_radius, 4, _echo_prog);
  array_push(iris_echoes, {radius : _echo_radius, age : 0});
}
for (var _ei = array_length(iris_echoes) - 1; _ei >= 0; _ei--) {
  iris_echoes[_ei].age++;
  if (iris_echoes[_ei].age > _k_center_warning_echo_life) {
    array_delete(iris_echoes, _ei, 1);
  }
}
prev_center_warning_timer = center_warning_timer;
if (center_warning_timer > 0) center_warning_timer--;

warning_wave_phase += _k_warning_wave_speed;

scr_update_erupt_warn_band();
laser_jump_update();

if (tear_amount > 0) {
  tear_amount -= 1 / 30;
  tear_amount = max(tear_amount, 0);
}

if (crosshair_release_flash_timer > 0) {
  crosshair_release_flash_timer++;
  if (crosshair_release_flash_timer > 20 * crosshair_release_flash_scale) {
    crosshair_release_flash_timer = 0;
    crosshair_release_flash_scale = 1;
  }
}

if (t <= _k_ring_lock_t) {
  var _ip = clamp(t / _k_ring_lock_t, 0, 1);

  intro_dim_amount = power(1 - _ip, 2.4);

  for (var _hb = 0; _hb < array_length(_k_intro_heartbeats); _hb++) {
    if (timeline_hit(_k_intro_heartbeats[_hb])) {
      var _hb_strength = 0.22 + (_hb / max(array_length(_k_intro_heartbeats) - 1, 1)) * 0.78;

      intro_heartbeat_pulse = max(intro_heartbeat_pulse, _hb_strength);
      arrow_core_flash = max(arrow_core_flash, (3 + _hb_strength * 12) * fx_get_mult_for("arrowring", "flash"));

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, _hb_strength * 3.5);
      }

      array_push(ring_shockwaves, {
        x : _k_ring_home_x,
        y : _k_ring_home_y,
        radius : 4,
        max_radius : 60 + _hb_strength * 300,
        life : 26,
        max_life : 26,
        width : 5 + _hb_strength * 11,
        hot : _hb_strength * 0.55
      });
    }
  }

  var _hb_env = intro_heartbeat_pulse;

  vignette_pulse = max(vignette_pulse, (1 - _ip) * 0.85 + _hb_env * 0.35);
  aberration_pulse = max(aberration_pulse, (1 - _ip) * 0.95 + _hb_env * 0.7);
  bloom_pulse = max(bloom_pulse, _hb_env * 0.5 + power(_ip, 3) * 0.4);
  global_ripple_pulse = max(global_ripple_pulse, _hb_env * 0.14);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 1;
  }
}

intro_heartbeat_pulse = max(0, intro_heartbeat_pulse - 0.055);

if (t >= 1 && t < _k_ring_cleanup_t) {
  if (arrow_ring_created && t < _k_ring_spawn_start) {
    for (var i = 0; i < array_length(arrow_ring); i++) {
      if (instance_exists(arrow_ring[i])) instance_destroy(arrow_ring[i]);
    }

    arrow_ring = [];
    arrow_ring_created = false;
    arrow_ring_despawning = false;
    arrow_ring_history = [];
    ring_charge_motes = [];
    ring_inward_arcs = [];
    ring_leak_arcs = [];
    salvo_lightning_arcs = [];
    ring_embers = [];
    ring_rim_afterglow = [];
    ring_shockwaves = [];
    ring_streaks = [];
    ring_splatter = [];
    arrow_ring_particles = [];
    ring_missiles = [];
    ring_missile_shards = [];
    ring_missile_bursts = [];
    ring_missile_reticles = [];
    ring_missile_locks = [];
    ring_missile_hand_flash = 0;
    ring_ghost_active = false;
    ring_ghost_timer = 0;
    ring_arrow_recoil = 0;
    ring_arrow_recoil_vel = 0;

    ring_tracers = [];
    ring_craters = [];
    ring_stuck_arrows = [];
    ring_rim_crackle = [];
    ring_coil_armed = -1;
    ring_salvo_traced = false;
    ring_band_ignited = false;
    ring_ambient = 0;
  }

  if (!arrow_ring_created && t >= _k_ring_spawn_start) {
    arrow_ring_created = true;

    arrow_ring = [];

    arrow_ring_x = _k_ring_home_x;
    arrow_ring_y = _k_ring_home_y;

    arrow_ring_radius = 180;
    arrow_ring_vertical_scale = 0.55;

    arrow_ring_angle = 0;
    arrow_ring_timer = 0;
    arrow_ring_spawn_timer = 0;
    arrow_ring_rotate_speed = 0;
    arrow_ring_history = [];
    ring_ripples = [];
    ring_phase = "assemble";

    ring_strike_index = 0;
    ring_wound = 0;
    ring_salvo_interval = 12;
    ring_salvo_timer = 12;
    ring_ghost_active = false;
    ring_ghost_timer = 0;
    ring_arrow_recoil = 0;
    ring_arrow_recoil_vel = 0;
    ring_missiles = [];
    ring_missile_shards = [];
    ring_missile_bursts = [];
    ring_missile_reticles = [];
    ring_missile_locks = [];
    ring_missile_hand_flash = 0;

    for (var i = 0; i < arrow_ring_count; i++) {
      var _ang = i * (360 / arrow_ring_count);

      arrow_ring_history[i] = [];

      var a = instance_create_layer(arrow_ring_x, arrow_ring_y, layer, oRedArrow);

      a.arrow_ring = true;
      a.arrow_ring_id = i;
      a.arrow_spawn_progress = 0;
      a.ring_pulse = 0;
      a.ring_flash = 0;
      a.spawn_scale = 0;
      a.glow_enabled = true;
      a.glow_timer = 0;

      a._k_glow_peak_intensity = 1.3;
      a._k_glow_sustain_intensity = 0.6;
      a._k_glow_peak_scale_mult = 1.6;
      a._k_glow_sustain_scale_mult = 1.15;
      a._k_glow_core_intensity = 1.2;

      a.image_xscale = 0;
      a.image_yscale = 0;
      a.image_alpha = 0;

      a.image_angle = _ang;
      a.direction = _ang;
      a.speed = 0;

      a.shrink = 0;
      a.trail = 1;

      arrow_ring[i] = a;
    }
  }

  if (t >= _k_ring_telegraph_start && t < _k_ring_spawn_start) {
    var _tp = (t - _k_ring_telegraph_start) / max(_k_ring_spawn_start - _k_ring_telegraph_start, 1);
    ring_telegraph_alpha = power(_tp, 0.7);
    ring_phase = "summon";

    if (t mod 2 == 0) {
      repeat (2) {
        array_push(ring_charge_motes, {
          ang : random(360),
          dist : arrow_ring_radius * random_range(1.4, 2.6),
          speed : random_range(5, 10),
          size : random_range(0.14, 0.32),
          spin : random_range(-3, 3),
          hot : random_range(0.3, 0.9)
        });
      }
    }
  } else if (t >= _k_ring_spawn_start) {
    ring_telegraph_alpha = max(0, ring_telegraph_alpha - 0.25);
  }

  var _amb_target;

  if (!ring_band_ignited) {
    _amb_target = intro_heartbeat_pulse * 0.6 + ring_telegraph_alpha * 0.1;
  } else {
    var _amb_p = clamp((t - _k_ring_lock_t) / max(_k_ring_despawn_t - _k_ring_lock_t, 1), 0, 1);
    _amb_target = 0.34 + _amb_p * 0.46 + ring_wound * 0.18;
  }

  if (arrow_ring_despawning) {
    _amb_target *= 1 - clamp(arrow_ring_despawn_timer / max(arrow_ring_despawn_duration, 1), 0, 1);
  }

  ring_ambient = lerp(ring_ambient, _amb_target, (_amb_target > ring_ambient) ? 0.34 : 0.06);

  ring_safe_slide = min(1, ring_safe_slide + 0.09);
  ring_sector_flash = max(0, ring_sector_flash - 0.06);

  var _sec_p = clamp((t - _k_ring_lock_t) / max(_k_ring_strike_frames[3] - _k_ring_lock_t, 1), 0, 1);
  ring_safe_arc = min(lerp(40, 22, _sec_p), ring_safe_arc_cap);

  if (ring_ambient > 0.25 && irandom(max(3, round(22 - ring_ambient * 14))) == 0) {
    array_push(ring_rim_crackle, {ang : random(360), life : 8, life_max : 8, len : random_range(26, 90)});
  }

  if (arrow_ring_created) {
    arrow_ring_timer++;
    arrow_ring_spawn_timer++;

    var _assembled = (arrow_ring_spawn_timer >= arrow_ring_spawn_duration);

    var _coil_index = -1;
    var _coil_t = 0;

    for (var i = 0; i < array_length(_k_ring_strike_frames); i++) {
      var _sf = _k_ring_strike_frames[i];
      if (t >= _sf - _k_ring_coil_lead && t < _sf) {
        _coil_index = i;
        _coil_t = (t - (_sf - _k_ring_coil_lead)) / _k_ring_coil_lead;
      }
    }

    for (var i = 0; i < array_length(_k_ring_strike_frames); i++) {
      var _lock_frame = _k_ring_strike_frames[i] - _k_ring_missile_lock_lead;
      if (t >= _lock_frame && t < _k_ring_strike_frames[i]) {
        var _lock = undefined;
        if (i < array_length(ring_missile_locks)) _lock = ring_missile_locks[i];
        if (!is_struct(_lock) || !_lock.active) ring_capture_missile_lock(i);
      }
    }

    if (_coil_index != ring_coil_armed) {
      ring_coil_armed = _coil_index;

      if (_coil_index >= 0) {
        ring_apply_missile_focus(_coil_index, true);

        ring_safe_arc_cap = 46;
        ring_move_safe_sector(ring_missile_hand_angle);
      }
    }

    if (_coil_index >= 0) {
      ring_coil_amount = power(clamp(_coil_t, 0, 1), 1.7);
      ring_phase = "coil";

      ring_apply_missile_focus(_coil_index, true);
    } else {
      ring_coil_amount = lerp(ring_coil_amount, 0, 0.22);
      if (ring_coil_amount < 0.01) ring_coil_amount = 0;
      if (_assembled && !arrow_ring_despawning && ring_phase != "implode") ring_phase = "body";
    }

    var _life_progress = clamp((t - _k_ring_spawn_start) / (_k_ring_despawn_t - _k_ring_spawn_start), 0, 1);
    var _hb_freq = lerp(0.075, 0.26, _life_progress) + ring_coil_amount * 0.4;

    ring_heartbeat_phase += _hb_freq;

    ring_heartbeat = power((sin(ring_heartbeat_phase) + 1) * 0.5, 3) *
                     (0.3 + _life_progress * 0.35 + ring_coil_amount * 0.9);

    ring_core_charge = lerp(ring_core_charge, 0.15 + _life_progress * 0.35 + ring_coil_amount * 1.1, 0.15);

    ring_outline_pulse = max(0, ring_outline_pulse - 1);
    ring_lock_flash = max(0, ring_lock_flash - 0.075);
    ring_bloom_hot = max(0, ring_bloom_hot - 0.08);
    ring_chroma = lerp(ring_chroma, ring_coil_amount * 0.35, 0.12);
    ring_missile_hand_flash = max(0, ring_missile_hand_flash - 0.055);
    if (ring_ghost_timer > 0) {
      ring_ghost_timer--;
      if (ring_ghost_timer <= 0) ring_ghost_active = false;
    }

    var _missile_payload_active = !arrow_ring_despawning &&
      (array_length(ring_missiles) > 0 ||
       array_length(ring_missile_reticles) > 0);
    var _missile_spin_slowed = _missile_payload_active && ring_strike_index > 0;
    var _missile_salvo_suppressed = _missile_payload_active &&
                                    ring_strike_index > 0 && ring_strike_index < 4;
    var _ring_salvo_coil_open = (ring_coil_amount <= 0.02) ||
                                ring_strike_index <= 0 || ring_strike_index >= 4;

    if (_missile_spin_slowed) {
      var _slow_dir = ring_missile_slow_spin_dir;
      if (abs(arrow_ring_rotate_speed) > 0.05) _slow_dir = (arrow_ring_rotate_speed < 0) ? -1 : 1;
      ring_missile_slow_spin_dir = _slow_dir;
      arrow_ring_rotate_speed = lerp(arrow_ring_rotate_speed, _slow_dir * _k_ring_missile_slow_spin, 0.22);
    }

    if (_missile_salvo_suppressed) {
      ring_salvo_timer = max(ring_salvo_timer, 4);
      ring_salvo_traced = false;
      if (array_length(ring_tracers) > 0) ring_tracers = [];
    }

    ring_radius_pump_vel += (0 - ring_radius_pump) * 0.17;
    ring_radius_pump_vel *= 0.86;
    ring_radius_pump += ring_radius_pump_vel;

    ring_arrow_recoil_vel += (0 - ring_arrow_recoil) * 0.22;
    ring_arrow_recoil_vel *= 0.72;
    ring_arrow_recoil += ring_arrow_recoil_vel;
    if (abs(ring_arrow_recoil) < 0.05 && abs(ring_arrow_recoil_vel) < 0.05) {
      ring_arrow_recoil = 0;
      ring_arrow_recoil_vel = 0;
    }

    arrow_ring_angle += arrow_ring_rotate_speed;
    arrow_scan_angle += arrow_scan_speed * (1 + ring_coil_amount * 3);
    if (ring_missile_hand_flash > 0.01) arrow_scan_angle = ring_missile_hand_angle;

    if (_coil_index < 0) {
      ring_safe_ang += arrow_ring_rotate_speed;
      ring_safe_ang_prev += arrow_ring_rotate_speed;
    }

    arrow_ring_rotate_speed = lerp(arrow_ring_rotate_speed, 0, _k_ring_spin_damp);

    arrow_core_rotation += ((arrow_ring_rotate_speed >= 0) ? -2 : 2) * (1 + ring_coil_amount * 4);
    arrow_core_pulse += 0.12 + ring_coil_amount * 0.25;

    arrow_energy_flow += arrow_energy_speed * (1 + ring_coil_amount * 5);
    if (arrow_energy_flow >= 1) arrow_energy_flow = 0;

    ring_bass_flash_amount = lerp(ring_bass_flash_amount, 0, 0.15);

    var _base_white = 0.1 + _life_progress * 0.2;
    var _white_amount = max(max(_base_white, ring_bass_flash_amount), max(ring_coil_amount * 0.6, ring_lock_flash));

    ring_color = merge_color(global.lightning_color, c_white, clamp(_white_amount, 0, 1));

    var _spawn_t = clamp(arrow_ring_spawn_timer / arrow_ring_spawn_duration, 0, 1);
    var _c1 = 1.7;
    var _c3 = _c1 + 1;
    var _spawn_eased = 1 + _c3 * power(_spawn_t - 1, 3) + _c1 * power(_spawn_t - 1, 2);

    var _despawn_mult = 1;

    if (arrow_ring_despawning) {
      arrow_ring_despawn_timer++;

      var _despawn_t = clamp(arrow_ring_despawn_timer / arrow_ring_despawn_duration, 0, 1);
      _despawn_mult = 1 - (_despawn_t * _despawn_t * _despawn_t);

      arrow_ring_rotate_speed = lerp(arrow_ring_rotate_speed, 34, 0.12);

      arrow_ring_x = lerp(_k_ring_home_x, intro_cx, _despawn_t);
      arrow_ring_y = lerp(_k_ring_home_y, intro_cy, _despawn_t);

      vignette_pulse = max(vignette_pulse, 0.25 + _despawn_t * 0.5);
      bloom_pulse = max(bloom_pulse, _despawn_t * 0.5);
      aberration_pulse = max(aberration_pulse, _despawn_t * 0.8);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 4 + _despawn_t * 12);
      }
    }

    var _k_coil_contract = 34;
    var _radius_offset = ring_radius_pump - ring_coil_amount * _k_coil_contract + ring_heartbeat * 5;

    arrow_ring_current_radius = max(0, arrow_ring_radius * _spawn_eased * _despawn_mult + _radius_offset * _despawn_mult);

    for (var i = 0; i < arrow_ring_count; i++) {
      var a = arrow_ring[i];
      if (!instance_exists(a)) continue;

      var _ang = arrow_ring_angle + i * (360 / arrow_ring_count);

      var _own_timer = max(0, arrow_ring_spawn_timer - i * _k_arrow_stagger_frames);
      var _own_spawn_t = clamp(_own_timer / _k_arrow_spawn_duration_each, 0, 1);
      var _c1o = 1.7;
      var _c3o = _c1o + 1;
      var _own_eased = 1 + _c3o * power(_own_spawn_t - 1, 3) + _c1o * power(_own_spawn_t - 1, 2);

      var _cur_radius = max(0, arrow_ring_radius * _own_eased * _despawn_mult +
                               (_radius_offset + ring_arrow_recoil) * _despawn_mult);

      var _jitter = ring_coil_amount * 3.5;

      a.x = arrow_ring_x + lengthdir_x(_cur_radius, _ang) + random_range(-_jitter, _jitter);
      a.y = arrow_ring_y + lengthdir_y(_cur_radius * arrow_ring_vertical_scale, _ang) + random_range(-_jitter, _jitter);

      if (_own_spawn_t < 1) {
        var _spin_start = _ang + 720 + (i * 35);
        a.image_angle = lerp(_spin_start, _ang, _own_eased);
      } else {
        a.image_angle = _ang;
      }
      a.direction = _ang;

      a.spawn_scale = clamp(_own_eased, 0, 1) * _despawn_mult;
      var _member_alpha = clamp(_own_spawn_t * 1.5, 0, 1) * _despawn_mult;
      if (ring_ghost_active) _member_alpha *= _k_ring_ghost_alpha;
      a.image_alpha = _member_alpha;
      a.hit_active = !ring_ghost_active && _member_alpha > a.hit_alpha_min;

      if (a.arrow_spawn_progress < 1 && _own_spawn_t >= 1) {
        var _land_ramp = i / max(arrow_ring_count - 1, 1);

        a.ring_pulse = 14 + round(_land_ramp * 10);
        a.ring_flash = 1;

        ring_radius_pump_vel += 1.5 + _land_ramp * 3;
        arrow_core_flash = max(arrow_core_flash, (5 + _land_ramp * 12) * fx_get_mult_for("arrowring", "flash"));

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 2 + _land_ramp * 7);
        }

        for (var la = 0; la < _k_arc_count_per_salvo; la++) {
          var _seg = irandom(arrow_ring_count - 1);
          salvo_arc_id_counter++;
          array_push(salvo_lightning_arcs, {
            seg : _seg,
            life : _k_arc_life,
            life_max : _k_arc_life,
            bolt_id : "ring_arc_" + string(salvo_arc_id_counter)
          });
        }

        array_push(ring_shockwaves, {
          x : a.x,
          y : a.y,
          radius : 4,
          max_radius : 40 + _land_ramp * 70,
          life : 18,
          max_life : 18,
          width : 7 + _land_ramp * 8,
          hot : 0.5 + _land_ramp * 0.5
        });

        for (var lp = 0; lp < 5 + round(_land_ramp * 8); lp++) {
          var _pa = random(360);
          var _ps = random_range(1.5, 4.5);
          array_push(arrow_ring_particles, {
            x : a.x,
            y : a.y,
            vx : lengthdir_x(_ps, _pa),
            vy : lengthdir_y(_ps, _pa) * arrow_ring_vertical_scale,
            life : 16,
            max_life : 16,
            size : random_range(0.1, 0.28),
            grav : 0,
            drag : 0.94,
            hot : 0.6 + _land_ramp * 0.4
          });
        }
      }

      a.arrow_spawn_progress = _own_spawn_t;

      var _motion = abs(arrow_ring_rotate_speed) + abs(ring_radius_pump_vel);
      if (_motion > 0.6) {
        array_insert(arrow_ring_history[i], 0, {
          ang : _ang,
          radius : _cur_radius,
          xscale : a.image_xscale,
          yscale : a.image_yscale,
          alpha : clamp(_motion / 8, 0, 1)
        });
      } else if (array_length(arrow_ring_history[i]) > 0) {
        array_delete(arrow_ring_history[i], array_length(arrow_ring_history[i]) - 1, 1);
      }

      if (array_length(arrow_ring_history[i]) > 8) {
        array_delete(arrow_ring_history[i], 8, array_length(arrow_ring_history[i]) - 8);
      }
    }

    if (ring_coil_amount > 0.02) {
      var _mote_n = 1 + floor(ring_coil_amount * 3);
      for (var m = 0; m < _mote_n; m++) {
        array_push(ring_charge_motes, {
          ang : random(360),
          dist : arrow_ring_radius * random_range(1.1, 2.3),
          speed : random_range(5, 11) * (0.6 + ring_coil_amount),
          size : random_range(0.12, 0.34),
          spin : random_range(-3.5, 3.5),
          hot : random_range(0.4, 1)
        });
      }

      if (ring_coil_amount > 0.25 && t mod 2 == 0) {
        salvo_arc_id_counter++;
        array_push(ring_inward_arcs, {
          seg : irandom(arrow_ring_count - 1),
          life : 6,
          life_max : 6,
          bolt_id : "ring_in_" + string(salvo_arc_id_counter)
        });
      }

      vignette_pulse = max(vignette_pulse, 0.3 + ring_coil_amount * 0.5);
      bloom_pulse = max(bloom_pulse, ring_coil_amount * 0.35);
      global_ripple_pulse = max(global_ripple_pulse, ring_coil_amount * 0.1);

      if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = max(oCameraController.letterbox_target, ring_coil_amount);
        oCameraController.shake = max(oCameraController.shake, ring_coil_amount * 3.5);
      }
    }

    if (_assembled && !arrow_ring_despawning && !_missile_salvo_suppressed && _ring_salvo_coil_open) {
      ring_salvo_timer--;

      if (!ring_salvo_traced && ring_salvo_timer <= _k_ring_tracer_lead) {
        ring_salvo_traced = true;

        for (var _ti = 0; _ti < arrow_ring_count; _ti++) {
          var _ta = arrow_ring[_ti];
          if (!instance_exists(_ta)) continue;

          ring_push_tracer(_ti, arrow_ring_angle + _ti * (360 / arrow_ring_count), _ta.x, _ta.y,
                           max(1, ring_salvo_timer), 10, 0.45);
        }

        ring_safe_arc_cap = (360 / arrow_ring_count) * 0.72;
        ring_move_safe_sector(arrow_ring_angle +
                              (irandom(arrow_ring_count - 1) + 0.5) * (360 / arrow_ring_count));
      }

      if (ring_salvo_timer <= 0) {
        ring_salvo_timer = ring_salvo_interval;
        ring_salvo_traced = false;

        for (var _tf = 0; _tf < array_length(ring_tracers); _tf++) {
          var _tfr = ring_tracers[_tf];
          if (_tfr.track < 0 || _tfr.fired) continue;

          var _tfa = arrow_ring[_tfr.track];

          if (instance_exists(_tfa)) {
            _tfr.ang = _tfa.image_angle;
            _tfr.ox = _tfa.x;
            _tfr.oy = _tfa.y;

            var _tfh = ring_arena_hit(_tfr.ox, _tfr.oy, _tfr.ang);
            _tfr.lx = _tfh.x;
            _tfr.ly = _tfh.y;
            _tfr.dist = _tfh.dist;
            _tfr.vertical = _tfh.vertical;
          }

          _tfr.fired = true;
          _tfr.travel = 0;
        }

        for (var i = 0; i < arrow_ring_count; i++) {
          var a = arrow_ring[i];
          if (!instance_exists(a)) continue;

          a.ring_pulse = 16;
          a.ring_flash = 0.8;

          for (var la = 0; la < _k_arc_count_per_salvo; la++) {
            var _seg = irandom(arrow_ring_count - 1);
            salvo_arc_id_counter++;
            array_push(salvo_lightning_arcs, {
              seg : _seg,
              life : _k_arc_life,
              life_max : _k_arc_life,
              bolt_id : "ring_arc_" + string(salvo_arc_id_counter)
            });
          }

          var _shots = irandom_range(1, 3);

          for (var s = 0; s < _shots; s++) {
            var b = instance_create_layer(a.x, a.y, layer, oRedArrow);
            b.direction = a.image_angle;
            b.image_angle = a.image_angle;
            var _speed_i = min(s, array_length(_k_ring_final_salvo_speed) - 1);
            b.speed = (ring_strike_index >= 4) ? _k_ring_final_salvo_speed[_speed_i] : max(3, 8 - s);
            b.image_xscale = 4 + s;
            b.image_yscale = 4 + s;
            b.shrink = 1;
            b.trail = 1;
            b.image_blend = ring_color;
            b.glow_enabled = true;
            b.hit_active = !ring_ghost_active;
            if (ring_ghost_active) b.image_alpha = _k_ring_ghost_alpha;

            b._k_glow_peak_scale_mult = 0.5;
            b._k_glow_sustain_scale_mult = 0.35;
            b._k_glow_peak_intensity = 1.2;
            b._k_glow_sustain_intensity = 0.55;
          }
        }

        arrow_ring_rotate_speed = random_range(-8, 8);
        ring_radius_pump_vel += 2.5;

        ring_outline_pulse = 12;
        arrow_scan_flash = 12 * fx_get_mult_for("arrowring", "flash");
        arrow_core_flash = max(arrow_core_flash, 12 * fx_get_mult_for("arrowring", "flash"));

        array_push(ring_shockwaves, {
          x : arrow_ring_x,
          y : arrow_ring_y,
          radius : 6,
          max_radius : arrow_ring_radius * 1.5,
          life : 22,
          max_life : 22,
          width : 10,
          hot : 0.55
        });

        for (var p = 0; p < 14; p++) {
          var _pa = random(360);
          var _ps = random_range(2, 6);
          array_push(arrow_ring_particles, {
            x : arrow_ring_x,
            y : arrow_ring_y,
            vx : lengthdir_x(_ps, _pa),
            vy : lengthdir_y(_ps, _pa) * arrow_ring_vertical_scale,
            life : 18,
            max_life : 18,
            size : random_range(0.12, 0.3),
            grav : 0,
            drag : 0.96,
            hot : 0.5
          });
        }

        for (var sIdx = 0; sIdx < 10; sIdx++) {
          array_push(ring_streaks, {
            ang : random(360),
            dist : arrow_ring_radius * 0.3,
            len : 20,
            speed : 14,
            width : 2,
            life : 12,
            max_life : 12,
            hot : 0.4
          });
        }

        array_push(ring_ripples, {x : arrow_ring_x, y : arrow_ring_y, radius : 10, alpha : 1, life : 24});

        ripple_trigger_x = arrow_ring_x;
        ripple_trigger_y = arrow_ring_y;
        ripple_trigger_time = current_time;
      }
    }

    if (ring_wound > 0 && !arrow_ring_despawning) {
      if (irandom(max(4, round(30 - ring_wound * 22))) == 0) {
        salvo_arc_id_counter++;
        array_push(ring_leak_arcs, {
          seg : irandom(arrow_ring_count - 1),
          ang : random(360),
          len : random_range(30, 55 + ring_wound * 60),
          life : 7,
          life_max : 7,
          bolt_id : "ring_leak_" + string(salvo_arc_id_counter)
        });
      }

      if (irandom(max(2, round(14 - ring_wound * 10))) == 0) {
        var _wi = irandom(arrow_ring_count - 1);
        var _wa = arrow_ring[_wi];
        if (instance_exists(_wa)) {
          array_push(ring_embers, {
            x : _wa.x,
            y : _wa.y,
            vx : random_range(-0.7, 0.7),
            vy : random_range(-0.4, 0.4),
            life : 40 + irandom(30),
            max_life : 70,
            size : random_range(0.09, 0.2),
            hot : random_range(0.4, 1)
          });
        }
      }
    }
  }

  if (timeline_hit_many(170, 188, 203, 214)) {
    var _hit_index = 0;
    if (timeline_hit(170))
      _hit_index = 0;
    else if (timeline_hit(188))
      _hit_index = 1;
    else if (timeline_hit(203))
      _hit_index = 2;
    else if (timeline_hit(214))
      _hit_index = 3;

    var _final_hit = (_hit_index == 3);

    ring_strike_index = _hit_index + 1;
    ring_wound = min(1, ring_strike_index / 4);
    ring_phase = "strike";
    ring_ghost_active = true;
    ring_ghost_timer = _final_hit ? _k_ring_final_ghost_hold : _k_ring_ghost_hold;
    ring_ghost_push = 12 + _hit_index * 6;

    ring_bass_flash_target = 0.4 + _hit_index * 0.2;
    ring_bass_flash_amount = ring_bass_flash_target;
    ring_coil_amount = 0;
    ring_chroma = 1;
    ring_lock_flash = max(ring_lock_flash, 0.5 + _hit_index * 0.12);
    ring_missile_hand_flash = 1;

    ring_radius_pump_vel += 9 + _hit_index * 3;
    ring_arrow_recoil_vel += ring_ghost_push * 0.62;
    ring_missile_slow_spin_dir = (_hit_index mod 2 == 0) ? 1 : -1;
    arrow_ring_rotate_speed = ring_missile_slow_spin_dir * _k_ring_missile_slow_spin * (1 + _hit_index * 0.12);

    ring_outline_pulse = 14;
    arrow_scan_flash = 14 * fx_get_mult_for("arrowring", "flash");
    arrow_core_flash = max(arrow_core_flash, (16 + _hit_index * 4) * fx_get_mult_for("arrowring", "flash"));

    ring_salvo_interval = _k_strike_salvo_interval[_hit_index];
    ring_salvo_timer = _final_hit ? 1 : ring_salvo_interval;
    ring_salvo_traced = false;
    ring_tracers = [];

    with (oRedArrow) {
      hit_active = false;
      image_alpha = min(image_alpha, other._k_ring_ghost_alpha);
      ring_flash = max(ring_flash, 0.65 + other.ring_strike_index * 0.08);
      chroma_amount = max(chroma_amount, 0.8);

      if (!arrow_ring) {
        x -= lengthdir_x(other.ring_ghost_push, image_angle);
        y -= lengthdir_y(other.ring_ghost_push, image_angle);
        if (other.ring_strike_index >= 4) {
          direction = image_angle;
          speed = max(speed * 2, other._k_ring_final_ghost_exit_speed);
        } else {
          speed *= 0.35;
        }
      } else {
        x += lengthdir_x(other.ring_ghost_push * 0.55, image_angle);
        y += lengthdir_y(other.ring_ghost_push * 0.55 * other.arrow_ring_vertical_scale, image_angle);
      }
    }

    for (var _tf = 0; _tf < array_length(ring_tracers); _tf++) {
      var _tfr = ring_tracers[_tf];
      if (_tfr.track < 0 && !_tfr.fired) {
        _tfr.fired = true;
        _tfr.travel = 0;
      }
    }

    scr_bg_bass_hit();
    scr_impact_pulse(0.4 + _hit_index * 0.12, 0.9 + _hit_index * 0.25, 0.14,
                     arrow_ring_x, arrow_ring_y);
    ring_bloom_hot = max(ring_bloom_hot, 0.4 + _hit_index * _hit_index * 0.061);

    if (_final_hit) tear_amount = max(tear_amount, 1.0);

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_strike_shake[_hit_index]);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_strike_zoom_punch[_hit_index]);
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, _k_strike_flash[_hit_index]);
      oCameraController.angle_kick = _k_strike_tilt[_hit_index];
      oCameraController.letterbox_target = 0;
    }

    array_push(ring_shockwaves, {
      x : arrow_ring_x,
      y : arrow_ring_y,
      radius : 10,
      max_radius : arrow_ring_radius * (2.2 + _hit_index * 0.4),
      life : 30 + _hit_index * 4,
      max_life : 30 + _hit_index * 4,
      width : 18 + _hit_index * 6,
      hot : 0.8 + _hit_index * 0.05
    });
    array_push(ring_ripples, {x : arrow_ring_x, y : arrow_ring_y, radius : 10, alpha : 1, life : 24});

    array_push(ring_bursts, {
      x : arrow_ring_x,
      y : arrow_ring_y,
      tier : 2 + (_final_hit ? 1 : 0),
      color : merge_color(global.lightning_color, c_white, 0.4 + _hit_index * 0.2),
      num : 6 + _hit_index * 2,
      offset : random(360),
      life : 30,
      shockwave_radius : 0,
      shockwave_max_radius : 180 + _hit_index * 50,
      shockwave_alpha : 1.2 + _hit_index * 0.2,
      shockwave_alpha_start : 1.2 + _hit_index * 0.2
    });

    for (var _s = 0; _s < arrow_ring_count; _s++) {
      salvo_arc_id_counter++;
      array_push(salvo_lightning_arcs, {
        seg : _s,
        life : _k_arc_life + _hit_index * 2,
        life_max : _k_arc_life + _hit_index * 2,
        bolt_id : "ring_arc_" + string(salvo_arc_id_counter)
      });
    }

    for (var i = 0; i < array_length(arrow_ring); i++) {
      var a = arrow_ring[i];
      if (instance_exists(a)) {
        a.ring_pulse = 20 + _hit_index * 2;
        a.ring_flash = 1;
      }
    }

    var _snap_strike = [];
    for (var i = 0; i < arrow_ring_count; i++) {
      var a = arrow_ring[i];
      if (instance_exists(a)) array_push(_snap_strike, {x : a.x, y : a.y});
    }
    if (array_length(_snap_strike) > 2) {
      array_push(ring_rim_afterglow, {pts : _snap_strike, alpha : 0.9, hot : 0.6 + _hit_index * 0.13});
    }

    for (var p = 0; p < _k_strike_particles[_hit_index]; p++) {
      var _pa = random(360);
      var _ps = random_range(3, 8 + _hit_index);
      array_push(arrow_ring_particles, {
        x : arrow_ring_x,
        y : arrow_ring_y,
        vx : lengthdir_x(_ps, _pa),
        vy : lengthdir_y(_ps, _pa) * arrow_ring_vertical_scale,
        life : 20,
        max_life : 20,
        size : random_range(0.14, 0.36),
        grav : 0,
        drag : 0.95,
        hot : 0.7 + _hit_index * 0.1
      });
    }

    for (var sIdx = 0; sIdx < _k_strike_streaks[_hit_index]; sIdx++) {
      array_push(ring_streaks, {
        ang : random(360),
        dist : arrow_ring_radius * random_range(0.2, 0.45),
        len : 26 + irandom(24) + _hit_index * 8,
        speed : 16 + _hit_index * 4,
        width : 2 + random(2),
        life : 14,
        max_life : 14,
        hot : 0.6 + _hit_index * 0.13
      });
    }

    for (var e = 0; e < _k_strike_embers[_hit_index]; e++) {
      var _ea = random(360);
      var _es = random_range(2, 6.5);
      array_push(ring_embers, {
        x : arrow_ring_x + lengthdir_x(arrow_ring_current_radius * random_range(0.3, 1), _ea),
        y : arrow_ring_y + lengthdir_y(arrow_ring_current_radius * arrow_ring_vertical_scale * random_range(0.3, 1), _ea),
        vx : lengthdir_x(_es, _ea),
        vy : lengthdir_y(_es, _ea) * arrow_ring_vertical_scale - random_range(0.5, 2),
        life : 50 + irandom(40),
        max_life : 90,
        size : random_range(0.1, 0.26),
        hot : 0.6 + random(0.4)
      });
    }

    for (var sp = 0; sp < _k_strike_splatter[_hit_index]; sp++) {
      var _spa = random(360);
      var _sp_dist = arrow_ring_current_radius * random_range(0.75, 1.6) + random(60);

      array_push(ring_splatter, {
        x : arrow_ring_x + lengthdir_x(_sp_dist, _spa),
        y : arrow_ring_y + lengthdir_y(_sp_dist * arrow_ring_vertical_scale, _spa),
        size : random_range(2, 7 + _hit_index * 1.5),
        drag_len : random_range(6, 26 + _hit_index * 10),
        drag_ang : _spa,
        alpha : random_range(0.55, 1),
        fade : random_range(0.004, 0.011),
        hot : 0.25 + random(0.4)
      });
    }

    ring_spawn_lock_missile(_hit_index);

    ripple_trigger_x = arrow_ring_x;
    ripple_trigger_y = arrow_ring_y;
    ripple_trigger_time = current_time;
  }

  if (arrow_core_flash > 0) arrow_core_flash--;

  arrow_ring_particle_timer++;

  if (arrow_ring_created && arrow_ring_particle_timer >= 8) {
    var _vertex = irandom(arrow_ring_count - 1);
    var _a = arrow_ring_angle + _vertex * (360 / arrow_ring_count);
    var _ps = random_range(1, 3);

    array_push(arrow_ring_particles, {
      x : arrow_ring_x + lengthdir_x(arrow_ring_current_radius, _a),
      y : arrow_ring_y + lengthdir_y(arrow_ring_current_radius * arrow_ring_vertical_scale, _a),
      vx : lengthdir_x(_ps, _a),
      vy : lengthdir_y(_ps, _a) * arrow_ring_vertical_scale,
      life : 20,
      max_life : 20,
      size : random_range(0.08, 0.22),
      grav : 0,
      drag : 0.97,
      hot : 0.35
    });

    arrow_ring_particle_timer = 0;
  }

  for (var i = array_length(arrow_ring_particles) - 1; i >= 0; i--) {
    var p = arrow_ring_particles[i];
    p.x += p.vx;
    p.y += p.vy;
    p.vx *= p.drag;
    p.vy = p.vy * p.drag + p.grav;
    p.life--;
    if (p.life <= 0) array_delete(arrow_ring_particles, i, 1);
  }

  for (var i = array_length(ring_missile_reticles) - 1; i >= 0; i--) {
    ring_missile_reticles[i].life--;
    if (ring_missile_reticles[i].life <= 0) array_delete(ring_missile_reticles, i, 1);
  }

  for (var i = array_length(ring_missiles) - 1; i >= 0; i--) {
    var _m = ring_missiles[i];

    _m.timer++;
    var _mp = clamp(_m.timer / max(_m.fuse, 1), 0, 1);
    var _me = 1 - power(1 - _mp, 3);
    var _arc = dsin(_mp * 180) * (18 + _m.hit_index * 4);
    var _perp = point_direction(_m.ox, _m.oy, _m.tx, _m.ty) + 90;

    _m.px = _m.x;
    _m.py = _m.y;
    _m.x = lerp(_m.ox, _m.tx, _me) + lengthdir_x(_arc, _perp);
    _m.y = lerp(_m.oy, _m.ty, _me) + lengthdir_y(_arc, _perp);

    array_insert(_m.trail, 0, {x : _m.px, y : _m.py});
    if (array_length(_m.trail) > _k_ring_missile_trail_length) {
      array_delete(_m.trail, _k_ring_missile_trail_length,
                   array_length(_m.trail) - _k_ring_missile_trail_length);
    }

    if (_m.timer >= _m.fuse) {
      ring_detonate_lock_missile(_m);
      array_delete(ring_missiles, i, 1);
    }
  }

  for (var i = array_length(ring_missile_bursts) - 1; i >= 0; i--) {
    var _b = ring_missile_bursts[i];
    _b.life--;
    _b.radius = lerp(_b.radius, _b.max_radius, 0.28);
    if (_b.danger_life > 0) _b.danger_life--;

    if (!_b.used && _b.danger_life > 0 && instance_exists(oPlayer)) {
      if (collision_circle(_b.x, _b.y, _b.hit_radius, oPlayer, false, true) != noone) {
        if (player_register_hazard_hit()) _b.used = true;
      }
    }

    if (_b.life <= 0) array_delete(ring_missile_bursts, i, 1);
  }

  for (var i = array_length(ring_missile_shards) - 1; i >= 0; i--) {
    var _sh = ring_missile_shards[i];

    if (_sh.delay > 0) {
      _sh.delay--;
      continue;
    }

    _sh.px = _sh.x;
    _sh.py = _sh.y;
    _sh.x += _sh.vx;
    _sh.y += _sh.vy;
    _sh.vx *= 0.985;
    _sh.vy *= 0.985;
    _sh.ang += _sh.spin;
    _sh.life--;

    if (!_sh.used && _sh.life < _sh.max_life - 2 && instance_exists(oPlayer)) {
      if (collision_circle(_sh.x, _sh.y, _k_ring_missile_hit_radius * _sh.scale, oPlayer, false, true) != noone) {
        if (player_register_hazard_hit()) _sh.used = true;
      }
    }

    if (_sh.life <= 0 || _sh.x < -80 || _sh.x > room_width + 80 || _sh.y < -80 || _sh.y > room_height + 80) {
      array_delete(ring_missile_shards, i, 1);
    }
  }

  for (var i = array_length(ring_charge_motes) - 1; i >= 0; i--) {
    var _m = ring_charge_motes[i];
    _m.dist -= _m.speed;
    _m.ang += _m.spin;

    if (_m.dist <= 6) {
      arrow_core_flash = max(arrow_core_flash, 3 * fx_get_mult_for("arrowring", "flash"));
      array_delete(ring_charge_motes, i, 1);
    }
  }

  for (var i = array_length(ring_embers) - 1; i >= 0; i--) {
    var _e = ring_embers[i];

    if (arrow_ring_despawning) {
      var _pull = point_direction(_e.x, _e.y, arrow_ring_x, arrow_ring_y);
      _e.vx += lengthdir_x(1.4, _pull);
      _e.vy += lengthdir_y(1.4, _pull);
      _e.vx *= 0.9;
      _e.vy *= 0.9;
    } else {
      _e.vy += 0.14;
      _e.vx *= 0.985;
      _e.vy *= 0.99;
    }

    _e.x += _e.vx;
    _e.y += _e.vy;
    _e.life--;

    if (_e.life <= 0) array_delete(ring_embers, i, 1);
  }

  for (var i = array_length(ring_shockwaves) - 1; i >= 0; i--) {
    var _sw = ring_shockwaves[i];
    _sw.life--;
    _sw.radius = lerp(_sw.radius, _sw.max_radius, 0.16);
    if (_sw.life <= 0) array_delete(ring_shockwaves, i, 1);
  }

  for (var i = array_length(ring_rim_afterglow) - 1; i >= 0; i--) {
    ring_rim_afterglow[i].alpha -= 0.022;
    if (ring_rim_afterglow[i].alpha <= 0) array_delete(ring_rim_afterglow, i, 1);
  }

  for (var i = array_length(ring_streaks) - 1; i >= 0; i--) {
    ring_streaks[i].dist += ring_streaks[i].speed;
    ring_streaks[i].life--;
    if (ring_streaks[i].life <= 0) array_delete(ring_streaks, i, 1);
  }

  for (var i = array_length(salvo_lightning_arcs) - 1; i >= 0; i--) {
    salvo_lightning_arcs[i].life--;
    if (salvo_lightning_arcs[i].life <= 0) array_delete(salvo_lightning_arcs, i, 1);
  }

  for (var i = array_length(ring_inward_arcs) - 1; i >= 0; i--) {
    ring_inward_arcs[i].life--;
    if (ring_inward_arcs[i].life <= 0) array_delete(ring_inward_arcs, i, 1);
  }

  for (var i = array_length(ring_leak_arcs) - 1; i >= 0; i--) {
    ring_leak_arcs[i].life--;
    if (ring_leak_arcs[i].life <= 0) array_delete(ring_leak_arcs, i, 1);
  }

  var _ring_vignette_target = arrow_ring_created ? 0.3 : 0;
  ring_vignette_strength = lerp(ring_vignette_strength, _ring_vignette_target, 0.05);
  vignette_pulse = max(vignette_pulse, ring_vignette_strength + ring_heartbeat * 0.2);
  bloom_pulse = max(bloom_pulse, ring_heartbeat * 0.08 + ring_bloom_hot);

  var _ring_aberration_elapsed = current_time - ripple_trigger_time;

  if (_ring_aberration_elapsed < 300) {
    var _decay = 1 - (_ring_aberration_elapsed / 300);
    aberration_pulse = max(aberration_pulse, _decay * 0.5);
    global_ripple_pulse = max(global_ripple_pulse, _decay * 0.08);
  }
}

if (timeline_hit(_k_ring_lock_t)) {
  intro_dim_amount = 0;
  intro_heartbeat_pulse = 0;

  ring_phase = "body";
  ring_lock_flash = 1;

  ring_band_ignited = true;
  ring_band_ignite_t = t;
  ring_ambient = 1.15;
  ring_sector_flash = 1;

  for (var _lc = 0; _lc < 10; _lc++) {
    array_push(ring_rim_crackle,
               {ang : _lc * 36 + random(24), life : 10, life_max : 10, len : random_range(50, 140)});
  }
  ring_chroma = 1;
  ring_core_charge = 0.5;
  ring_outline_pulse = 20;
  arrow_core_flash = 26 * fx_get_mult_for("arrowring", "flash");
  arrow_scan_flash = 20 * fx_get_mult_for("arrowring", "flash");
  ring_radius_pump_vel += 11;
  ring_salvo_timer = 10;

  scr_bg_bass_hit();
  scr_impact_pulse(0.55, 1.2, 0.18, arrow_ring_x, arrow_ring_y);
  ring_bloom_hot = max(ring_bloom_hot, 0.58);

  tear_amount = max(tear_amount, 0.8);
  global_ripple_pulse = max(global_ripple_pulse, 0.75);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0;
    oCameraController.shake = max(oCameraController.shake, 20);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.13);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.5);
    oCameraController.angle_kick = -2.2;
  }

  array_push(ring_shockwaves, {
    x : arrow_ring_x,
    y : arrow_ring_y,
    radius : 12,
    max_radius : arrow_ring_radius * 2.8,
    life : 36,
    max_life : 36,
    width : 26,
    hot : 1
  });
  array_push(ring_ripples, {x : arrow_ring_x, y : arrow_ring_y, radius : 10, alpha : 1, life : 24});

  ripple_trigger_x = arrow_ring_x;
  ripple_trigger_y = arrow_ring_y;
  ripple_trigger_time = current_time;

  for (var i = 0; i < array_length(arrow_ring); i++) {
    var a = arrow_ring[i];
    if (instance_exists(a)) {
      a.ring_pulse = 24;
      a.ring_flash = 1;
    }
  }

  for (var _s = 0; _s < arrow_ring_count; _s++) {
    salvo_arc_id_counter++;
    array_push(salvo_lightning_arcs, {
      seg : _s,
      life : _k_arc_life + 4,
      life_max : _k_arc_life + 4,
      bolt_id : "ring_arc_" + string(salvo_arc_id_counter)
    });
  }

  var _snap_lock = [];
  for (var i = 0; i < arrow_ring_count; i++) {
    var a = arrow_ring[i];
    if (instance_exists(a)) array_push(_snap_lock, {x : a.x, y : a.y});
  }
  if (array_length(_snap_lock) > 2) array_push(ring_rim_afterglow, {pts : _snap_lock, alpha : 1, hot : 1});

  for (var p = 0; p < 40; p++) {
    var _pa = random(360);
    var _ps = random_range(3, 9);
    array_push(arrow_ring_particles, {
      x : arrow_ring_x,
      y : arrow_ring_y,
      vx : lengthdir_x(_ps, _pa),
      vy : lengthdir_y(_ps, _pa) * arrow_ring_vertical_scale,
      life : 24,
      max_life : 24,
      size : random_range(0.12, 0.34),
      grav : 0,
      drag : 0.95,
      hot : 0.9
    });
  }

  for (var sIdx = 0; sIdx < 26; sIdx++) {
    array_push(ring_streaks, {
      ang : random(360),
      dist : arrow_ring_radius * random_range(0.15, 0.4),
      len : 34 + irandom(30),
      speed : 20,
      width : 2 + random(2),
      life : 15,
      max_life : 15,
      hot : 0.9
    });
  }
}

if (timeline_hit(_k_ring_despawn_t) && arrow_ring_created && !arrow_ring_despawning) {
  arrow_ring_despawning = true;
  arrow_ring_despawn_timer = 0;
  arrow_ring_despawn_burst = true;
  arrow_ring_despawn_duration = _k_ring_cleanup_t - _k_ring_despawn_t;
  ring_phase = "implode";

  ring_chroma = 1;

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0.7;
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.06);
    oCameraController.shake = max(oCameraController.shake, 10);
  }

  array_push(ring_bursts, {
    x : arrow_ring_x,
    y : arrow_ring_y,
    tier : 3,
    color : c_white,
    num : 8,
    offset : 0,
    life : 40,
    shockwave_radius : 0,
    shockwave_max_radius : 300,
    shockwave_alpha : 1.8,
    shockwave_alpha_start : 1.8
  });

  var _snap_death = [];
  for (var i = 0; i < arrow_ring_count; i++) {
    var a = arrow_ring[i];
    if (instance_exists(a)) array_push(_snap_death, {x : a.x, y : a.y});
  }
  if (array_length(_snap_death) > 2) array_push(ring_rim_afterglow, {pts : _snap_death, alpha : 1, hot : 1});
}

if (timeline_hit(_k_ring_cleanup_t)) {
  arrow_ring_created = false;
  arrow_ring_despawning = false;
  ring_phase = "done";

  ring_spawn_flash_timer = 0;
  ring_spawn_flash_duration = 24;

  ring_lock_flash = 0.55;
  ring_bloom_hot = max(ring_bloom_hot, 0.5);
  ring_chroma = 1;
  ring_coil_amount = 0;
  ring_heartbeat = 0;

  scr_impact_pulse(0.6, 1.3, 0.16, intro_cx, intro_cy);
  tear_amount = max(tear_amount, 1.1);
  global_ripple_pulse = max(global_ripple_pulse, 0.8);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0;
    oCameraController.shake = max(oCameraController.shake, 24);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.15);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.55);
    oCameraController.angle_kick = 2.6;
  }

  ripple_trigger_x = arrow_ring_x;
  ripple_trigger_y = arrow_ring_y;
  ripple_trigger_time = current_time;

  array_push(ring_ripples, {x : arrow_ring_x, y : arrow_ring_y, radius : 10, alpha : 1, life : 24});

  array_push(ring_shockwaves, {
    x : arrow_ring_x,
    y : arrow_ring_y,
    radius : 8,
    max_radius : 300,
    life : 22,
    max_life : 22,
    width : 24,
    hot : 1
  });

  for (var p = 0; p < 52; p++) {
    var _pa = random(360);
    var _ps = random_range(3, 11);
    array_push(arrow_ring_particles, {
      x : arrow_ring_x,
      y : arrow_ring_y,
      vx : lengthdir_x(_ps, _pa),
      vy : lengthdir_y(_ps, _pa),
      life : 28,
      max_life : 28,
      size : random_range(0.12, 0.38),
      grav : 0.06,
      drag : 0.96,
      hot : 1
    });
  }

  for (var e = 0; e < 26; e++) {
    var _ea = random(360);
    var _es = random_range(3, 8);
    array_push(ring_embers, {
      x : arrow_ring_x,
      y : arrow_ring_y,
      vx : lengthdir_x(_es, _ea),
      vy : lengthdir_y(_es, _ea) - random_range(1, 3),
      life : 60 + irandom(40),
      max_life : 100,
      size : random_range(0.1, 0.3),
      hot : 1
    });
  }

  for (var sp = 0; sp < 34; sp++) {
    var _spa = random(360);
    var _sp_dist = random_range(20, 210);

    array_push(ring_splatter, {
      x : arrow_ring_x + lengthdir_x(_sp_dist, _spa),
      y : arrow_ring_y + lengthdir_y(_sp_dist, _spa),
      size : random_range(2.5, 10),
      drag_len : random_range(10, 46),
      drag_ang : _spa,
      alpha : random_range(0.6, 1),
      fade : random_range(0.003, 0.009),
      hot : 0.3 + random(0.5)
    });
  }

  for (var sIdx = 0; sIdx < 40; sIdx++) {
    array_push(ring_streaks, {
      ang : random(360),
      dist : random_range(4, 40),
      len : 40 + irandom(50),
      speed : 24,
      width : 2 + random(2.5),
      life : 18,
      max_life : 18,
      hot : 1
    });
  }

  for (var i = 0; i < array_length(arrow_ring); i++) {
    if (instance_exists(arrow_ring[i])) instance_destroy(arrow_ring[i]);
  }
  arrow_ring = [];

  ring_charge_motes = [];
  ring_inward_arcs = [];
  ring_leak_arcs = [];
  salvo_lightning_arcs = [];
  arrow_ring_history = [];
  ring_missiles = [];
  ring_missile_shards = [];
  ring_missile_bursts = [];
  ring_missile_reticles = [];
  ring_missile_locks = [];
  ring_missile_hand_flash = 0;
  ring_ghost_active = false;
  ring_ghost_timer = 0;
  ring_arrow_recoil = 0;
  ring_arrow_recoil_vel = 0;
}

if (t >= _k_ring_cleanup_t && ring_ambient > 0.001) {
  ring_ambient = max(0, ring_ambient - 0.05);
  ring_sector_flash = max(0, ring_sector_flash - 0.06);
}

if (array_length(ring_tracers) > 0 || array_length(ring_craters) > 0 ||
    array_length(ring_stuck_arrows) > 0 || array_length(ring_rim_crackle) > 0) {
  for (var i = array_length(ring_tracers) - 1; i >= 0; i--) {
    var _tr = ring_tracers[i];

    if (!_tr.fired) {
      if (_tr.track >= 0 && arrow_ring_created && _tr.track < array_length(arrow_ring)) {
        var _ta = arrow_ring[_tr.track];

        if (instance_exists(_ta)) {
          _tr.ang = arrow_ring_angle + _tr.track * (360 / arrow_ring_count);
          _tr.ox = _ta.x;
          _tr.oy = _ta.y;

          var _th = ring_arena_hit(_tr.ox, _tr.oy, _tr.ang);
          _tr.lx = _th.x;
          _tr.ly = _th.y;
          _tr.dist = _th.dist;
          _tr.vertical = _th.vertical;
        }
      }

      _tr.life--;

      if (_tr.life <= -8) array_delete(ring_tracers, i, 1);
      continue;
    }

    _tr.travel += _tr.speed;

    if (_tr.travel >= _tr.dist) {
      ring_land_arrow(_tr.lx, _tr.ly, _tr.ang, _tr.vertical, _tr.hot);
      array_delete(ring_tracers, i, 1);
    }
  }

  for (var i = array_length(ring_craters) - 1; i >= 0; i--) {
    var _cr = ring_craters[i];
    _cr.life--;
    _cr.radius = lerp(_cr.radius, _cr.max_radius, 0.24);
    if (_cr.life <= 0) array_delete(ring_craters, i, 1);
  }

  for (var i = array_length(ring_stuck_arrows) - 1; i >= 0; i--) {
    var _sa = ring_stuck_arrows[i];
    _sa.life--;
    _sa.wobble *= 0.86;
    if (_sa.life <= 0) array_delete(ring_stuck_arrows, i, 1);
  }

  for (var i = array_length(ring_rim_crackle) - 1; i >= 0; i--) {
    ring_rim_crackle[i].life--;
    if (ring_rim_crackle[i].life <= 0) array_delete(ring_rim_crackle, i, 1);
  }
}

if (t >= _k_ring_cleanup_t && !arrow_ring_created &&
    (array_length(ring_embers) > 0 || array_length(ring_rim_afterglow) > 0 ||
     array_length(ring_shockwaves) > 0 || array_length(ring_streaks) > 0 ||
     array_length(arrow_ring_particles) > 0)) {
  for (var i = array_length(ring_embers) - 1; i >= 0; i--) {
    var _e = ring_embers[i];
    _e.vy += 0.14;
    _e.vx *= 0.985;
    _e.x += _e.vx;
    _e.y += _e.vy;
    _e.life--;
    if (_e.life <= 0) array_delete(ring_embers, i, 1);
  }

  for (var i = array_length(ring_rim_afterglow) - 1; i >= 0; i--) {
    ring_rim_afterglow[i].alpha -= 0.022;
    if (ring_rim_afterglow[i].alpha <= 0) array_delete(ring_rim_afterglow, i, 1);
  }

  for (var i = array_length(ring_shockwaves) - 1; i >= 0; i--) {
    var _sw = ring_shockwaves[i];
    _sw.life--;
    _sw.radius = lerp(_sw.radius, _sw.max_radius, 0.16);
    if (_sw.life <= 0) array_delete(ring_shockwaves, i, 1);
  }

  for (var i = array_length(ring_streaks) - 1; i >= 0; i--) {
    ring_streaks[i].dist += ring_streaks[i].speed;
    ring_streaks[i].life--;
    if (ring_streaks[i].life <= 0) array_delete(ring_streaks, i, 1);
  }

  for (var i = array_length(arrow_ring_particles) - 1; i >= 0; i--) {
    var p = arrow_ring_particles[i];
    p.x += p.vx;
    p.y += p.vy;
    p.vx *= p.drag;
    p.vy = p.vy * p.drag + p.grav;
    p.life--;
    if (p.life <= 0) array_delete(arrow_ring_particles, i, 1);
  }

  ring_lock_flash = max(0, ring_lock_flash - 0.045);
  ring_chroma = lerp(ring_chroma, 0, 0.12);
}

if (t < 690 && array_length(ring_bursts) > 0) {
  for (var i = array_length(ring_bursts) - 1; i >= 0; i--) {
    var _rb = ring_bursts[i];
    _rb.life--;

    if (_rb.shockwave_radius < _rb.shockwave_max_radius) {
      _rb.shockwave_radius += 8;
      var _rb_prog = _rb.shockwave_radius / _rb.shockwave_max_radius;
      var _rb_start = variable_struct_exists(_rb, "shockwave_alpha_start") ? _rb.shockwave_alpha_start : 0.5;
      _rb.shockwave_alpha = _rb_start * (1 - _rb_prog);
    } else {
      _rb.shockwave_alpha = 0;
    }

    if (_rb.life <= 0) array_delete(ring_bursts, i, 1);
  }
}
if (array_length(converge_motes) > 0) {
  for (var i = array_length(converge_motes) - 1; i >= 0; i--) {
    var _mo = converge_motes[i];
    _mo.dist = max(_mo.dest, _mo.dist - _mo.speed);
    _mo.ang += _mo.spin;

    if (_mo.dist <= _mo.dest + 0.5) {
      switch (_mo.feed) {
        case "shapes": shapes_core_flash = max(shapes_core_flash, 3); break;
        case "orbit": orbit_ribbon_heat = min(1.4, orbit_ribbon_heat + 0.03); break;
        case "quarter": quarter_core_charge = min(2.2, quarter_core_charge + 0.055); break;
        case "stamp": stamp_rail = min(1, stamp_rail + 0.03);
                      stamp_face_heat[0] = min(1.6, stamp_face_heat[0] + 0.02);
                      stamp_face_heat[1] = min(1.6, stamp_face_heat[1] + 0.02);
                      break;
        case "seam": lorb_seam = min(1.6, lorb_seam + 0.035); break;
        case "storm": storm_charge_beat_punch = min(0.7, storm_charge_beat_punch + 0.04); break;
        case "ringrim": ring_ambient = min(1.3, ring_ambient + 0.012); break;
        case "rope":
          jr_anchor_heat[0] = min(1.6, jr_anchor_heat[0] + 0.02);
          jr_anchor_heat[1] = min(1.6, jr_anchor_heat[1] + 0.02);
          break;
        case "cube":
          cube_core_flash = min(1.6, cube_core_flash + 0.035);
          cube_edge_surge = min(1.4, cube_edge_surge + 0.03);
          break;
      }
      array_delete(converge_motes, i, 1);
    }
  }
}

if (t >= _k_shapes_window_start && t < _k_shapes_window_end) {
  if (timeline_hit(_k_shapes_window_start)) {
    for (var i = 0; i < array_length(intro_ring_bullets); i++) {
      if (instance_exists(intro_ring_bullets[i])) instance_destroy(intro_ring_bullets[i]);
    }
    for (var i = 0; i < array_length(intro_x_bullets); i++) {
      if (instance_exists(intro_x_bullets[i])) instance_destroy(intro_x_bullets[i]);
    }

    intro_ring_bullets = [];
    intro_x_bullets = [];
    shapes_telegraphs = [];
    converge_motes = [];
    rain_spawn_timer = 0;
    shapes_arcs = [];
    shapes_ghosts = [];
    shapes_wound = 0;
    shapes_coil = 0;
    shapes_heartbeat = 0;
    shapes_rot_speed = 0;
    shapes_radius_pump = 0;
    shapes_radius_pump_vel = 0;
  }

  for (var s = 0; s < array_length(_k_shapes_lands); s++) {
    if (timeline_hit(_k_shapes_lands[s] - _k_shapes_telegraph_lead)) {
      array_push(shapes_telegraphs, {shape : s, timer : 0, duration : _k_shapes_telegraph_lead});
    }
  }

  for (var s = array_length(shapes_telegraphs) - 1; s >= 0; s--) {
    var _tg = shapes_telegraphs[s];
    _tg.timer++;

    var _tp = clamp(_tg.timer / _tg.duration, 0, 1);
    var _tg_r = (_tg.shape == 1) ? 220 : ((_tg.shape == 2) ? 200 : 180);

    if (t mod 2 == 0) {
      repeat (2 + floor(_tp * 3)) {
        array_push(converge_motes, {
          cx : intro_cx,
          cy : intro_cy,
          ang : random(360),
          dist : _tg_r * random_range(1.5, 2.8),
          dest : _tg_r,
          speed : random_range(6, 12),
          size : random_range(0.12, 0.3),
          spin : random_range(-3, 3),
          hot : random_range(0.3, 0.9),
          feed : "shapes"
        });
      }
    }

    shapes_core_charge = max(shapes_core_charge, 0.15 + _tp * 0.35);
    vignette_pulse = max(vignette_pulse, 0.12 + _tp * 0.22);
    aberration_pulse = max(aberration_pulse, _tp * 0.35);

    if (_tg.timer >= _tg.duration) array_delete(shapes_telegraphs, s, 1);
  }

  var _shapes_alive = (array_length(intro_ring_bullets) > 0 || array_length(intro_x_bullets) > 0);
  var _life_p = clamp((t - _k_shapes_lands[0]) / (_k_shapes_releases[1] - _k_shapes_lands[0]), 0, 1);

  var _coil_t = 0;
  var _coil_found = false;

  for (var s = 0; s < array_length(_k_shapes_releases); s++) {
    var _rf = _k_shapes_releases[s];
    var _lead = _k_shapes_coil_leads[s];
    if (t >= _rf - _lead && t < _rf) {
      _coil_t = (t - (_rf - _lead)) / _lead;
      _coil_found = true;
    }
  }

  if (_coil_found) {
    shapes_coil = power(clamp(_coil_t, 0, 1), 1.7);
  } else {
    shapes_coil = lerp(shapes_coil, 0, 0.22);
    if (shapes_coil < 0.01) shapes_coil = 0;
  }

  var _hb_freq = lerp(0.085, 0.30, _life_p) + shapes_coil * 0.45;
  shapes_heartbeat_phase += _hb_freq;
  shapes_heartbeat = power((sin(shapes_heartbeat_phase) + 1) * 0.5, 3) *
                     (0.25 + _life_p * 0.4 + shapes_coil * 0.9) * (_shapes_alive ? 1 : 0);

  var _core_target = _shapes_alive ? (0.12 + _life_p * 0.4 + shapes_coil * 1.1 + shapes_wound * 0.15) : 0;
  shapes_core_charge = lerp(shapes_core_charge, _core_target, 0.15);

  shapes_core_flash = max(0, shapes_core_flash - 1);
  shapes_launch_flash = max(0, shapes_launch_flash - 0.05);

  shapes_chroma = lerp(shapes_chroma, max(shapes_coil * 0.4, abs(shapes_rot_speed) / 9 * 0.5), 0.12);

  shapes_radius_pump_vel += (0 - shapes_radius_pump) * 0.17;
  shapes_radius_pump_vel *= 0.86;
  shapes_radius_pump += shapes_radius_pump_vel;

  var _radius_scale = 1 + (shapes_radius_pump + shapes_heartbeat * 7 - shapes_coil * _k_shapes_contract) / 180;
  var _bullet_jitter = shapes_coil * 3.2 + shapes_wound * 0.35;

  for (var i = 0; i < array_length(intro_ring_bullets); i++) {
    var _b = intro_ring_bullets[i];
    if (!instance_exists(_b)) continue;
    _b.radius_scale = _radius_scale;
    _b.jitter_amount = _bullet_jitter;
    _b.chroma_amount = max(_b.chroma_amount, shapes_chroma * 0.6);
  }

  for (var i = 0; i < array_length(intro_x_bullets); i++) {
    var _b = intro_x_bullets[i];
    if (!instance_exists(_b)) continue;
    _b.radius_scale = _radius_scale;
    _b.jitter_amount = _bullet_jitter;
    _b.chroma_amount = max(_b.chroma_amount, shapes_chroma * 0.6);
  }

  if (_shapes_alive) {
    var _ring_n = array_length(intro_ring_bullets);
    var _x_n = array_length(intro_x_bullets);

    if (_ring_n > 1 && irandom(max(2, round(9 - shapes_wound * 4 - shapes_coil * 5))) == 0) {
      shapes_arc_id++;
      array_push(shapes_arcs, {
        arr : 0,
        i1 : irandom(_ring_n - 1),
        i2 : -2,
        delay : 0,
        life : _k_shapes_arc_life,
        life_max : _k_shapes_arc_life,
        bolt_id : "shape_arc_" + string(shapes_arc_id)
      });
    }

    if (_x_n > 0 && irandom(max(3, 12 - round(shapes_coil * 9))) == 0) {
      shapes_arc_id++;
      array_push(shapes_arcs, {
        arr : 1,
        i1 : irandom(_x_n - 1),
        i2 : -1,
        delay : 0,
        life : _k_shapes_arc_life,
        life_max : _k_shapes_arc_life,
        bolt_id : "shape_arc_" + string(shapes_arc_id)
      });
    }

    if (shapes_coil > 0.25 && t mod 2 == 0 && _ring_n > 0) {
      shapes_arc_id++;
      array_push(shapes_arcs, {
        arr : 0,
        i1 : irandom(_ring_n - 1),
        i2 : -1,
        delay : 0,
        life : 6,
        life_max : 6,
        bolt_id : "shape_in_" + string(shapes_arc_id)
      });
    }

    if (t mod 5 == 0) {
      var _pool = (_ring_n > 0) ? intro_ring_bullets : intro_x_bullets;
      var _pn = array_length(_pool);

      if (_pn > 0) {
        var _sb = _pool[irandom(_pn - 1)];
        if (instance_exists(_sb) && _sb.revealed) {
          var _sa = point_direction(intro_cx, intro_cy, _sb.x, _sb.y);
          var _ss = random_range(0.8, 2.4);
          array_push(arrow_ring_particles, {
            x : _sb.x,
            y : _sb.y,
            vx : lengthdir_x(_ss, _sa),
            vy : lengthdir_y(_ss, _sa),
            life : 20,
            max_life : 20,
            size : random_range(0.08, 0.2),
            grav : 0.02,
            drag : 0.97,
            hot : 0.35 + shapes_wound * 0.3
          });
        }
      }
    }
  }

  for (var i = array_length(shapes_arcs) - 1; i >= 0; i--) {
    var _ar = shapes_arcs[i];
    if (_ar.delay > 0) {
      _ar.delay--;
    } else {
      _ar.life--;
      if (_ar.life <= 0) array_delete(shapes_arcs, i, 1);
    }
  }

  for (var i = array_length(shapes_ghosts) - 1; i >= 0; i--) {
    shapes_ghosts[i].alpha -= 0.028;
    if (shapes_ghosts[i].alpha <= 0) array_delete(shapes_ghosts, i, 1);
  }

  if (_shapes_alive || array_length(shapes_telegraphs) > 0 || shapes_launch_flash > 0) {
    vignette_pulse = max(vignette_pulse, 0.18 + shapes_heartbeat * 0.25 + shapes_coil * 0.5);
    bloom_pulse = max(bloom_pulse, shapes_heartbeat * 0.22 + shapes_launch_flash * 0.5);
    aberration_pulse = max(aberration_pulse, shapes_chroma * 0.5 + shapes_coil * 0.35);
    global_ripple_pulse = max(global_ripple_pulse, shapes_heartbeat * 0.05 + shapes_coil * 0.08);

    if (shapes_coil > 0.02 && instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, shapes_coil * 0.85);
      oCameraController.shake = max(oCameraController.shake, shapes_coil * 3);
    }
  }
}

if
  true {
    if (timeline_hit(292))
    {
      var _k_circle_count = 20;
      var _k_circle_radius = 180;
      var _k_circle_trace_stagger = 0.8;

      for (var i = 0; i < _k_circle_count; i++) {
        var _angle = (360 / _k_circle_count) * i;
        scr_spawn_intro_bullet(intro_cx, intro_cy, _angle, _k_circle_radius, intro_ring_bullets, i * _k_circle_trace_stagger, 0,
                               i, 0);
      }

      for (var s = 0; s < _k_circle_count; s++) {
        shapes_arc_id++;
        array_push(shapes_arcs, {
          arr : 0,
          i1 : s,
          i2 : -2,
          delay : round(s * _k_circle_trace_stagger) + 2,
          life : _k_shapes_arc_life + 3,
          life_max : _k_shapes_arc_life + 3,
          bolt_id : "shape_land_" + string(shapes_arc_id)
        });
      }

      shapes_land_payoff(0, _k_circle_radius);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 14);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.07);
      }
      scr_bg_bass_hit();
      scr_impact_pulse(0.35, 0.7, 0.5);
      scr_add_light(intro_cx, intro_cy, global.lightning_color, 5);
    }

    if (timeline_hit(314))
    {
      var _k_square_count = 24;
      var _k_square_half = 220;
      var _k_square_trace_stagger = 0.8;

      var _k_square_phase_offset = 7.5;

      for (var i = 0; i < _k_square_count; i++) {
        var _angle = (360 / _k_square_count) * i + _k_square_phase_offset;
        var _radius = _k_square_half / max(abs(cos(degtorad(_angle))), abs(sin(degtorad(_angle))));
        scr_spawn_intro_bullet(intro_cx, intro_cy, _angle, _radius, intro_ring_bullets, i * _k_square_trace_stagger, 1, i, 0);
      }

      var _square_base = array_length(intro_ring_bullets) - _k_square_count;

      for (var s = 0; s < _k_square_count; s++) {
        shapes_arc_id++;
        array_push(shapes_arcs, {
          arr : 0,
          i1 : _square_base + s,
          i2 : -2,
          delay : round(s * _k_square_trace_stagger) + 2,
          life : _k_shapes_arc_life + 3,
          life_max : _k_shapes_arc_life + 3,
          bolt_id : "shape_land_" + string(shapes_arc_id)
        });
      }

      shapes_land_payoff(1, _k_square_half);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 12);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.06);
        oCameraController.angle_kick = 1.4;
      }
      scr_bg_bass_hit();
      scr_impact_pulse(0.35, 0.7, 0.45);
      scr_add_light(intro_cx, intro_cy, global.lightning_color, 6);
    }

    if (timeline_hit(333)) {
      var _k_x_arm_len = 200;
      var _k_x_per_arm = 8;
      var _k_x_trace_stagger = 1.5;
      var _diag_dirs = [ 0, 90, 180, 270 ];

      for (var d = 0; d < 4; d++) {
        for (var i = 1; i <= _k_x_per_arm; i++) {
          var _radius = (_k_x_arm_len / _k_x_per_arm) * i;
          var _angle = _diag_dirs[d];
          scr_spawn_intro_bullet(intro_cx, intro_cy, _angle, _radius, intro_x_bullets, (i - 1) * _k_x_trace_stagger, 2, i, d);
        }
      }

      for (var d = 0; d < 4; d++) {
        for (var i = 0; i < _k_x_per_arm; i++) {
          shapes_arc_id++;
          array_push(shapes_arcs, {
            arr : 1,
            i1 : d * _k_x_per_arm + i,
            i2 : -1,
            delay : round(i * _k_x_trace_stagger) + 2,
            life : 7,
            life_max : 7,
            bolt_id : "shape_arm_" + string(shapes_arc_id)
          });
        }
      }

      shapes_land_payoff(2, _k_x_arm_len);

      for (var d = 0; d < 4; d++) {
        for (var sIdx = 0; sIdx < 5; sIdx++) {
          array_push(ring_streaks, {
            cx : intro_cx,
            cy : intro_cy,
            vs : 1,
            ang : _diag_dirs[d] + random_range(-4, 4),
            dist : random_range(20, 90),
            len : 40 + irandom(40),
            speed : 20,
            width : 1.5 + random(2),
            life : 14,
            max_life : 14,
            hot : 0.9
          });
        }
      }

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 12);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.06);
        oCameraController.angle_kick = -1.6;
      }
      scr_bg_bass_hit();
      scr_impact_pulse(0.35, 0.7, 0.45);
      scr_add_light(intro_cx, intro_cy, global.lightning_color, 7);
    }
    if (t >= 350 && t < 360) {
      var _rot_per_frame = 9;

      shapes_rot_speed = _rot_per_frame;

      for (var i = 0; i < array_length(intro_ring_bullets); i++) {
        var _b = intro_ring_bullets[i];
        if (instance_exists(_b)) {
          _b.intro_rotate_mode = true;
          _b.intro_rotate_speed = _rot_per_frame;
        }
      }

      if (t mod _k_shapes_ghost_interval == 0) {
        var _swing_p = (t - 350) / 10;
        shapes_snapshot(true, true, 0.55 - _swing_p * 0.15, 0.45 + _swing_p * 0.4, 2);
      }

      if (t mod 2 == 0) {
        var _rn = array_length(intro_ring_bullets);
        if (_rn > 0) {
          repeat (3) {
            var _rb = intro_ring_bullets[irandom(_rn - 1)];
            if (!instance_exists(_rb) || !_rb.revealed) continue;
            var _tang = point_direction(intro_cx, intro_cy, _rb.x, _rb.y) + 90;
            var _tspd = random_range(2, 5);
            array_push(arrow_ring_particles, {
              x : _rb.x,
              y : _rb.y,
              vx : lengthdir_x(_tspd, _tang),
              vy : lengthdir_y(_tspd, _tang),
              life : 16,
              max_life : 16,
              size : random_range(0.1, 0.24),
              grav : 0.02,
              drag : 0.94,
              hot : 0.55
            });
          }
        }
      }

      aberration_pulse = max(aberration_pulse, 0.4);
      bloom_pulse = max(bloom_pulse, 0.2);

      if (timeline_hit(350)) {
        shapes_radius_pump_vel += 5;
        shapes_core_flash = max(shapes_core_flash, 16);
        shapes_chroma = 1;

        array_push(ring_shockwaves, {
          x : intro_cx,
          y : intro_cy,
          radius : 6,
          max_radius : 300,
          life : 24,
          max_life : 24,
          width : 14,
          hot : 0.65,
          vs : 1
        });

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 8);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.04);
          oCameraController.angle_kick = 2.4;
        }
        scr_bg_bass_hit();
      }
    } else {
      shapes_rot_speed = lerp(shapes_rot_speed, 0, 0.3);
    }

    if (t >= 355 && t < 367) {
      var _k_wind_up_start = 355;
      var _k_wind_up_end = 367;
      var _k_blink_slow = 6;
      var _k_blink_fast = 1;

      var _progress = (t - _k_wind_up_start) / (_k_wind_up_end - _k_wind_up_start);
      var _blink_speed = lerp(_k_blink_slow, _k_blink_fast, _progress);
      var _cycle_len = max(1, round(_blink_speed));

      if (t mod _cycle_len == 0) {
        for (var i = 0; i < array_length(intro_x_bullets); i++) {
          var _b = intro_x_bullets[i];
          if (instance_exists(_b)) {
            _b.pop_flash = 1;
          }
        }
      }

      var _coil_p = power(_progress, 1.7);

      vignette_pulse = max(vignette_pulse, 0.25 + _coil_p * 0.5);
      bloom_pulse = max(bloom_pulse, _coil_p * 0.3);
      aberration_pulse = max(aberration_pulse, _coil_p * 0.5);

      var _wind_motes = 1 + floor(_coil_p * 3);
      for (var m = 0; m < _wind_motes; m++) {
        array_push(converge_motes, {
          cx : intro_cx,
          cy : intro_cy,
          ang : random(360),
          dist : random_range(210, 320),
          dest : 0,
          speed : random_range(7, 14) * (0.6 + _coil_p),
          size : random_range(0.12, 0.32),
          spin : random_range(-4, 4),
          hot : random_range(0.5, 1),
          feed : "shapes"
        });
      }

      if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = max(oCameraController.letterbox_target, _coil_p * 0.85);
        oCameraController.shake = max(oCameraController.shake, _coil_p * 3);
      }
    }

    if (timeline_hit(360)) {
      for (var i = 0; i < array_length(intro_x_bullets); i++) {
        var _b = intro_x_bullets[i];
        if (instance_exists(_b)) {
          _b.intro_rotate_mode = false;
        }
      }

      for (var i = 0; i < array_length(intro_ring_bullets); i++) {
        var _b = intro_ring_bullets[i];
        if (instance_exists(_b)) {
          _b.intro_rotate_mode = false;
        }
      }
    }
    if (timeline_hit(367)) {
      shapes_snapshot(false, true, 1, 0.9, 3);

      for (var i = 0; i < array_length(intro_x_bullets); i++) {
        var _b = intro_x_bullets[i];
        if (instance_exists(_b)) {
          var _dir = point_direction(intro_cx, intro_cy, _b.x, _b.y);
          _b.intro_locked = false;
          _b.direction = _dir;
          _b.image_angle = _dir;
          _b.speed = 18;
          _b.pop_flash = 1.5;
          _b.pop_scale = 1.6;
          _b.pop_target = 1;
          _b.pop_overshoot = true;
          _b.chroma_amount = 1;
          _b.trail_enabled = true;
        }
      }
      intro_x_bullets = [];

      shapes_radius_pump_vel += 9;
      shapes_core_flash = max(shapes_core_flash, 22);
      shapes_launch_flash = 0.85;
      shapes_chroma = 1;

      array_push(ring_shockwaves, {
        x : intro_cx,
        y : intro_cy,
        radius : 10,
        max_radius : 420,
        life : 32,
        max_life : 32,
        width : 20,
        hot : 0.85,
        vs : 1
      });

      array_push(ring_bursts, {
        x : intro_cx,
        y : intro_cy,
        tier : 3,
        color : merge_color(global.lightning_color, c_white, 0.6),
        num : 8,
        offset : 0,
        life : 32,
        shockwave_radius : 0,
        shockwave_max_radius : 330,
        shockwave_alpha : 1.5,
        shockwave_alpha_start : 1.5
      });

      for (var p = 0; p < 34; p++) {
        var _pa = random(360);
        var _ps = random_range(3, 9);
        array_push(arrow_ring_particles, {
          x : intro_cx,
          y : intro_cy,
          vx : lengthdir_x(_ps, _pa),
          vy : lengthdir_y(_ps, _pa),
          life : 22,
          max_life : 22,
          size : random_range(0.12, 0.32),
          grav : 0.05,
          drag : 0.95,
          hot : 0.85
        });
      }

      for (var e = 0; e < 16; e++) {
        var _ea = random(360);
        var _es = random_range(2, 6);
        array_push(ring_embers, {
          x : intro_cx + lengthdir_x(random_range(10, 90), _ea),
          y : intro_cy + lengthdir_y(random_range(10, 90), _ea),
          vx : lengthdir_x(_es, _ea),
          vy : lengthdir_y(_es, _ea) - random_range(0.5, 2),
          life : 55 + irandom(35),
          max_life : 90,
          size : random_range(0.1, 0.26),
          hot : 0.7 + random(0.3)
        });
      }

      for (var sIdx = 0; sIdx < 24; sIdx++) {
        array_push(ring_streaks, {
          cx : intro_cx,
          cy : intro_cy,
          vs : 1,
          ang : random(360),
          dist : random_range(6, 50),
          len : 34 + irandom(34),
          speed : 20,
          width : 2 + random(2),
          life : 15,
          max_life : 15,
          hot : 0.85
        });
      }

      crosshair_release_x = intro_cx;
      crosshair_release_y = intro_cy;
      crosshair_release_flash_timer = 1;
      scr_add_light(intro_cx, intro_cy, global.lightning_color,
                    6);
      impact_wave_radius = 0;
      impact_wave_color = global.lightning_color;

      if (instance_exists(oCameraController)) {
        oCameraController.shake =
            max(oCameraController.shake, 18);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.11);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.3);
        oCameraController.angle_kick = 2.0;
        oCameraController.letterbox_target = 0;
      }
      scr_bg_bass_hit();
      scr_impact_pulse(0.45, 1.0, 0.7);
      tear_amount = max(tear_amount, 0.6);
    }
    if (timeline_hit(377)) {
      shapes_snapshot(true, false, 1, 1, 4);

      for (var i = 0; i < array_length(intro_ring_bullets); i++) {
        var _b = intro_ring_bullets[i];
        if (instance_exists(_b)) {
          var _dir = point_direction(intro_cx, intro_cy, _b.x, _b.y);
          _b.intro_locked = false;
          _b.direction = _dir;
          _b.image_angle = _dir;
          _b.speed = 18;
          _b.pop_flash = 1;
          _b.pop_scale = 1.6;
          _b.pop_target = 1;
          _b.pop_overshoot = true;
          _b.chroma_amount = 1;
          _b.trail_enabled = true;
        }
      }
      intro_ring_bullets = [];

      shapes_launch_flash = 1;
      shapes_core_flash = max(shapes_core_flash, 30);
      shapes_chroma = 1;
      shapes_coil = 0;
      shapes_heartbeat = 0;
      shapes_radius_pump = 0;
      shapes_radius_pump_vel = 0;

      for (var w = 0; w < 3; w++) {
        array_push(ring_shockwaves, {
          x : intro_cx,
          y : intro_cy,
          radius : 8 + w * 14,
          max_radius : 320 + w * 190,
          life : 20 + w * 4,
          max_life : 20 + w * 4,
          width : 30 - w * 7,
          hot : 1 - w * 0.2,
          vs : 1
        });
      }

      array_push(ring_bursts, {
        x : intro_cx,
        y : intro_cy,
        tier : 3,
        color : c_white,
        num : 8,
        offset : 0,
        life : 42,
        shockwave_radius : 0,
        shockwave_max_radius : 480,
        shockwave_alpha : 2.0,
        shockwave_alpha_start : 2.0
      });

      for (var p = 0; p < 60; p++) {
        var _pa = random(360);
        var _ps = random_range(3, 12);
        array_push(arrow_ring_particles, {
          x : intro_cx,
          y : intro_cy,
          vx : lengthdir_x(_ps, _pa),
          vy : lengthdir_y(_ps, _pa),
          life : 28,
          max_life : 28,
          size : random_range(0.12, 0.4),
          grav : 0.06,
          drag : 0.96,
          hot : 1
        });
      }

      for (var e = 0; e < 30; e++) {
        var _ea = random(360);
        var _es = random_range(3, 8);
        array_push(ring_embers, {
          x : intro_cx,
          y : intro_cy,
          vx : lengthdir_x(_es, _ea),
          vy : lengthdir_y(_es, _ea) - random_range(1, 3),
          life : 60 + irandom(45),
          max_life : 105,
          size : random_range(0.1, 0.3),
          hot : 1
        });
      }

      for (var sIdx = 0; sIdx < 40; sIdx++) {
        array_push(ring_streaks, {
          cx : intro_cx,
          cy : intro_cy,
          vs : 1,
          ang : random(360),
          dist : random_range(4, 44),
          len : 42 + irandom(52),
          speed : 25,
          width : 2 + random(2.5),
          life : 18,
          max_life : 18,
          hot : 1
        });
      }

      crosshair_release_x = intro_cx;
      crosshair_release_y = intro_cy;
      crosshair_release_flash_scale = 1.0;
      crosshair_release_flash_timer = 1;
      scr_add_light(intro_cx, intro_cy, global.lightning_color, 14);
      impact_wave_radius = 0;
      impact_wave_color = global.lightning_color;
      t377_flash_timer = 1;

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 26);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.17);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.5);
        oCameraController.angle_kick = -3.2;
        oCameraController.letterbox_target = 0;
      }
      scr_bg_bass_hit();
      scr_impact_pulse(0.6, 1.3, 1.0);
      tear_amount = max(tear_amount, 1.1);

      warning_band_ignited = true;
      warning_band_ignite_t = t;

      var _k_thrown_count = 20;
      var _k_thrown_speed_min = 14;
      var _k_thrown_speed_max = 20;
      var _k_thrown_spread_deg = 35;

      for (var g = 0; g < 26; g++) {
        var _gdir = 90 + random_range(-_k_thrown_spread_deg, _k_thrown_spread_deg);
        array_push(ring_streaks, {
          cx : intro_cx,
          cy : intro_cy,
          vs : 1,
          ang : _gdir,
          dist : random_range(0, 40),
          len : 50 + irandom(70),
          speed : 26,
          width : 1.5 + random(2.5),
          life : 20,
          max_life : 20,
          hot : 1
        });
      }

      for (var g = 0; g < 30; g++) {
        var _gdir = 90 + random_range(-_k_thrown_spread_deg - 12, _k_thrown_spread_deg + 12);
        var _gspd = random_range(6, 16);
        array_push(arrow_ring_particles, {
          x : intro_cx + random_range(-14, 14),
          y : intro_cy,
          vx : lengthdir_x(_gspd, _gdir),
          vy : lengthdir_y(_gspd, _gdir),
          life : 34,
          max_life : 34,
          size : random_range(0.12, 0.34),
          grav : 0.22,
          drag : 0.99,
          hot : 1
        });
      }

      for (var i = 0; i < _k_thrown_count; i++) {
        var _launch_speed = random_range(_k_thrown_speed_min, _k_thrown_speed_max);
        var _launch_dir = 90 + random_range(-_k_thrown_spread_deg, _k_thrown_spread_deg);

        with instance_create_layer(intro_cx, intro_cy, layer, oRedKunai) {
          is_feeder = false;
          state = "normal";
          is_thrown = true;
          locked_direction = true;
          impacts_floor = true;
          speed = 0;
          hsp = lengthdir_x(_launch_speed, _launch_dir);
          vsp = lengthdir_y(_launch_speed, _launch_dir);
          direction = _launch_dir;
          image_angle = _launch_dir;
        }
      }
    }
  }
if (t >= _k_rain_start && t < 700) {
  var _rain_p = clamp((t - _k_rain_start) / (_k_rain_end - _k_rain_start), 0, 1);
  var _rain_on = (t < 570);

  rain_intensity = lerp(rain_intensity, _rain_on ? (0.35 + _rain_p * 0.65) : 0, 0.08);

  var _rain_hb_freq = lerp(0.07, 0.22, _rain_p) + big_kunai_coil * 0.4;
  rain_heartbeat_phase += _rain_hb_freq;
  rain_heartbeat = power((sin(rain_heartbeat_phase) + 1) * 0.5, 3) * (0.2 + _rain_p * 0.45) * rain_intensity;

  rain_lane_flash = max(0, rain_lane_flash - 0.06);
  rain_safe_slide = min(1, rain_safe_slide + 0.09);

  if (_rain_on) {
    var _speed_min = lerp(5, 10, _rain_p);
    var _speed_max = lerp(9, 13, _rain_p) + (_rain_p * 5);
    var _count = floor(lerp(5, 3, _rain_p));
    var _interval = max(4, round(lerp(_k_rain_interval_start, _k_rain_interval_end, _rain_p)));

    rain_spawn_timer--;

    if (rain_spawn_timer <= 0) {
      rain_spawn_timer = _interval;

      rain_safe_x_prev = rain_safe_x;
      rain_safe_x = random_range(70, room_width - 70);
      rain_safe_slide = 0;
      rain_safe_width = lerp(112, 78, _rain_p);
      rain_lane_flash = 1;

      for (var i = 0; i < _count; i++) {
        var _x;
        do {
          _x = random_range(0, 800);
        } until (abs(_x - rain_safe_x) > rain_safe_width / 2);

        var _warn_delay = irandom_range(5, 8);
        var _source_seed = frac(abs(sin((_x + 17.0) * 12.9898 + t * 78.233 + i * 37.719)) * 43758.5453);

        with instance_create_layer(_x, 0, layer, oKunaiWarning) {
          life = _warn_delay;
          max_life = _warn_delay;
          impact_y = other._k_kunai_floor_y;
        }

        if (array_length(rain_source_slots) >= _k_rain_source_cap) array_delete(rain_source_slots, 0, 1);
        array_push(rain_source_slots, {
          x : _x,
          y : _k_rain_source_y,
          life : _k_rain_source_life,
          max_life : _k_rain_source_life,
          fire_at : _warn_delay,
          seed : _source_seed,
          hot : 0.35 + _rain_p * 0.65
        });

        array_push(pending_kunai_spawns,
                   {spawn_x : _x, timer : _warn_delay, speed_min : _speed_min, speed_max : _speed_max,
                    seed : _source_seed});
      }

      repeat (2) {
        array_push(rain_band_crackle,
                   {x : random_range(0, room_width), life : 8, life_max : 8, len : random_range(40, 140)});
      }
    }

    vignette_pulse = max(vignette_pulse, 0.12 + rain_heartbeat * 0.3);
    bloom_pulse = max(bloom_pulse, rain_heartbeat * 0.25);
  }

  for (var i = array_length(kunai_impacts) - 1; i >= 0; i--) {
    var _im = kunai_impacts[i];
    _im.life--;
    _im.radius = lerp(_im.radius, _im.max_radius, 0.24);
    if (_im.life <= 0) array_delete(kunai_impacts, i, 1);
  }

  for (var i = array_length(kunai_shards) - 1; i >= 0; i--) {
    var _sh = kunai_shards[i];
    _sh.life--;
    _sh.wobble *= 0.84;
    if (_sh.life <= 0) array_delete(kunai_shards, i, 1);
  }

  for (var i = array_length(rain_source_slots) - 1; i >= 0; i--) {
    rain_source_slots[i].life--;
    if (rain_source_slots[i].life <= 0) array_delete(rain_source_slots, i, 1);
  }

  for (var i = array_length(rain_floor_scars) - 1; i >= 0; i--) {
    rain_floor_scars[i].life--;
    rain_floor_scars[i].heat *= 0.91;
    if (rain_floor_scars[i].life <= 0) array_delete(rain_floor_scars, i, 1);
  }

  for (var i = array_length(rain_band_crackle) - 1; i >= 0; i--) {
    rain_band_crackle[i].life--;
    if (rain_band_crackle[i].life <= 0) array_delete(rain_band_crackle, i, 1);
  }

  for (var i = array_length(kunai_absorb_pops) - 1; i >= 0; i--) {
    kunai_absorb_pops[i].life--;
    if (kunai_absorb_pops[i].life <= 0) array_delete(kunai_absorb_pops, i, 1);
  }

  for (var i = array_length(orbit_path_ghosts) - 1; i >= 0; i--) {
    orbit_path_ghosts[i].alpha -= 0.035;
    if (orbit_path_ghosts[i].alpha <= 0) array_delete(orbit_path_ghosts, i, 1);
  }

  if (t >= _k_big_kunai_spawn_t - _k_big_kunai_telegraph_lead && t < _k_big_kunai_spawn_t) {
    var _tel_p = (t - (_k_big_kunai_spawn_t - _k_big_kunai_telegraph_lead)) / _k_big_kunai_telegraph_lead;
    big_kunai_telegraph = power(_tel_p, 0.7);

    if (t mod 2 == 0) {
      repeat (2) {
        var _ma = random(360);
        array_push(converge_motes, {
          cx : _k_orbit_cx + dcos(_ma) * _k_orbit_rx,
          cy : _k_orbit_cy + dsin(_ma) * _k_orbit_ry,
          ang : random(360),
          dist : random_range(120, 260),
          dest : 0,
          speed : random_range(7, 13),
          size : random_range(0.12, 0.3),
          spin : random_range(-3, 3),
          hot : random_range(0.4, 1),
          feed : "orbit"
        });
      }
    }

    vignette_pulse = max(vignette_pulse, 0.2 + big_kunai_telegraph * 0.3);
    aberration_pulse = max(aberration_pulse, big_kunai_telegraph * 0.4);

    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, big_kunai_telegraph * 0.5);
    }
  } else {
    big_kunai_telegraph = max(0, big_kunai_telegraph - 0.12);
  }

  var _charge_total = 0;
  var _charge_cap = 0;

  for (var k = 0; k < 2; k++) {
    if (instance_exists(kunai_pair[k])) {
      _charge_total += kunai_pair[k].charge;
      _charge_cap += kunai_pair[k].charge_needed;
    }
  }

  big_kunai_build = lerp(big_kunai_build, (_charge_cap > 0) ? clamp(_charge_total / _charge_cap, 0, 1) : 0, 0.2);
  big_kunai_lock_flash = max(0, big_kunai_lock_flash - 0.04);
  big_kunai_release = max(0, big_kunai_release - 0.055);

  var _spin_norm = clamp((orbit_speed_current - orbit_speed_min_ever) /
                             max(orbit_speed_max_ever - orbit_speed_min_ever, 1),
                         0, 1);
  var _ribbon_target = big_kunai_locked ? (0.35 + _spin_norm * 0.9 + big_kunai_coil * 0.4) : (big_kunai_build * 0.3);
  orbit_ribbon_heat = lerp(orbit_ribbon_heat, _ribbon_target, 0.12);

  if (big_kunai_locked && t mod 2 == 0) {
    for (var k = 0; k < 2; k++) {
      if (instance_exists(kunai_pair[k]) && kunai_pair[k].built && !kunai_pair[k].deorbiting) {
        array_push(orbit_path_ghosts, {
          x : kunai_pair[k].x,
          y : kunai_pair[k].y,
          ang : kunai_pair[k].image_angle,
          alpha : 0.35 + _spin_norm * 0.5,
          hot : 0.3 + _spin_norm * 0.7,
          scale : 0.6 + _spin_norm * 0.9
        });
      }
    }
  }

  var _bk_coil_found = false;

  for (var n = 0; n < array_length(_k_big_kunai_notes); n++) {
    var _nf = _k_big_kunai_notes[n];
    if (t >= _nf - _k_big_kunai_coil_lead && t < _nf) {
      big_kunai_coil = power(clamp((t - (_nf - _k_big_kunai_coil_lead)) / _k_big_kunai_coil_lead, 0, 1), 1.7);
      _bk_coil_found = true;
    }
  }

  if (!_bk_coil_found) {
    big_kunai_coil = lerp(big_kunai_coil, 0, 0.2);
    if (big_kunai_coil < 0.01) big_kunai_coil = 0;
  }

  if (big_kunai_coil > 0.02) {
    if (t mod 2 == 0) {
      var _ca = random(360);
      array_push(converge_motes, {
        cx : _k_orbit_cx + dcos(_ca) * _k_orbit_rx,
        cy : _k_orbit_cy + dsin(_ca) * _k_orbit_ry,
        ang : random(360),
        dist : random_range(90, 240) * (0.6 + big_kunai_coil),
        dest : 0,
        speed : random_range(8, 16) * (0.6 + big_kunai_coil),
        size : random_range(0.12, 0.34),
        spin : random_range(-4, 4),
        hot : random_range(0.5, 1),
        feed : "orbit"
      });
    }

    vignette_pulse = max(vignette_pulse, 0.14 + big_kunai_coil * 0.25);
    bloom_pulse = max(bloom_pulse, big_kunai_coil * 0.175);
    aberration_pulse = max(aberration_pulse, big_kunai_coil * 0.275);

    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, big_kunai_coil * 0.9);
      oCameraController.shake = max(oCameraController.shake, big_kunai_coil * 3.5);
    }
  }

  bloom_pulse = max(bloom_pulse, big_kunai_lock_flash * 0.7 + big_kunai_release * 0.6 + orbit_ribbon_heat * 0.075);
  vignette_pulse = max(vignette_pulse, orbit_ribbon_heat * 0.09);
}

if
  true {
    var _k_orbit_ramp_duration = 10;
    var _k_orbit_friction_rate =
        0.02;

    var _hits = [ 623, 643, 662, 681 ];
    var _peak_speeds = [ 11, 15, 20, 26 ];
    var _base_speeds = [ 3, 5, 8, 12 ];

    for (var i = 0; i < array_length(_hits); i++) {
      if (t == _hits[i]) {
        orbit_ramp_start_speed = orbit_speed_current;
        orbit_ramp_target = _peak_speeds[i];
        orbit_ramp_timer = 0;
        orbit_speed_floor = _base_speeds[i];
      }
    }

    if (orbit_ramp_timer < _k_orbit_ramp_duration) {
      orbit_ramp_timer++;
      var _p = orbit_ramp_timer / _k_orbit_ramp_duration;
      var _eased = 1 - power(1 - _p, 3);
      orbit_speed_current = lerp(orbit_ramp_start_speed, orbit_ramp_target, _eased);
    } else {
      orbit_speed_current = lerp(orbit_speed_current, orbit_speed_floor, _k_orbit_friction_rate);
    }

    shared_orbit_speed = orbit_speed_current;

    if (!ring_built && instance_exists(kunai_pair[0]) && instance_exists(kunai_pair[1]) &&
        kunai_pair[0].charge >= kunai_pair[0].charge_needed && kunai_pair[1].charge >= kunai_pair[1].charge_needed) {
      ring_built = true;
      shared_orbit_angle = 0;
      with(kunai_pair[0]) {
        built = true;
        image_alpha = 1;
        image_xscale = 5;
        image_yscale = 5;
      }
      with(kunai_pair[1]) {
        built = true;
        image_alpha = 1;
        image_xscale = 5;
        image_yscale = 5;
      }

      big_kunai_locked = true;
      big_kunai_lock_flash = 1;
      orbit_ribbon_heat = max(orbit_ribbon_heat, 1);

      scr_bg_bass_hit();
      scr_impact_pulse(0.5, 1.1, 0.9);
      tear_amount = max(tear_amount, 0.7);
      global_ripple_pulse = max(global_ripple_pulse, 0.7);
      scr_add_light(_k_orbit_cx, _k_orbit_cy, global.lightning_color, 12);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 20);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.12);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.4);
        oCameraController.angle_kick = -2.4;
        oCameraController.letterbox_target = 0;
      }

      array_push(ring_bursts, {
        x : _k_orbit_cx,
        y : _k_orbit_cy,
        tier : 3,
        color : c_white,
        num : 8,
        offset : 0,
        life : 38,
        shockwave_radius : 0,
        shockwave_max_radius : 400,
        shockwave_alpha : 1.7,
        shockwave_alpha_start : 1.7
      });

      for (var s = 0; s < 40; s++) {
        var _ia = s * (360 / 40);
        var _ix = _k_orbit_cx + dcos(_ia) * _k_orbit_rx;
        var _iy = _k_orbit_cy + dsin(_ia) * _k_orbit_ry;

        array_push(orbit_path_ghosts, {x : _ix, y : _iy, ang : _ia + 90, alpha : 1, hot : 1, scale : 1.3});

        var _ispd = random_range(2, 6);
        array_push(arrow_ring_particles, {
          x : _ix,
          y : _iy,
          vx : lengthdir_x(_ispd, _ia),
          vy : lengthdir_y(_ispd, _ia) * (_k_orbit_ry / _k_orbit_rx),
          life : 24,
          max_life : 24,
          size : random_range(0.12, 0.32),
          grav : 0.02,
          drag : 0.95,
          hot : 1
        });
      }

      for (var k = 0; k < 2; k++) {
        if (!instance_exists(kunai_pair[k])) continue;
        array_push(ring_shockwaves, {
          x : kunai_pair[k].x,
          y : kunai_pair[k].y,
          radius : 8,
          max_radius : 260,
          life : 30,
          max_life : 30,
          width : 20,
          hot : 1,
          vs : 1
        });
      }
    }

    if (ring_built) {
      shared_orbit_angle += shared_orbit_speed;
    }

    for (var j = array_length(pending_kunai_spawns) - 1; j >= 0; j--) {
      var _spawn = pending_kunai_spawns[j];
      _spawn.timer--;
      if (_spawn.timer <= 0) {
        var _spawn_seed = variable_struct_exists(_spawn, "seed") ? _spawn.seed : 0;
        with instance_create_layer(_spawn.spawn_x, 0, layer, oRedKunai) {
          direction = 270 + random_range(-8, 8);
          speed = random_range(_spawn.speed_min, _spawn.speed_max);
          impacts_floor = true;
          rain_forged = true;
          rain_source_x = _spawn.spawn_x;
          rain_source_seed = _spawn_seed;
        }
        array_delete(pending_kunai_spawns, j, 1);
      }
    }

    if timeline_hit (500) {
      big_kunai_locked = false;
      ring_built = false;
      big_kunai_build = 0;
      orbit_path_ghosts = [];

      kunai_pair[0] = instance_create_layer(400, 200, layer, oBigKunai);
      with(kunai_pair[0]) {
        base_orbit_offset = 0;
        orbit_angle = base_orbit_offset;
        x = orbit_center_x + dcos(orbit_angle) * orbit_radius_x;
        y = orbit_center_y + dsin(orbit_angle) * orbit_radius_y;
        image_angle = point_direction(orbit_center_x, orbit_center_y, x, y);
      }

      kunai_pair[1] = instance_create_layer(400, 200, layer, oBigKunai);
      with(kunai_pair[1]) {
        base_orbit_offset = 180;
        orbit_angle = base_orbit_offset;
        x = orbit_center_x + dcos(orbit_angle) * orbit_radius_x;
        y = orbit_center_y + dsin(orbit_angle) * orbit_radius_y;
        image_angle = point_direction(orbit_center_x, orbit_center_y, x, y);
      }

      scr_kunai_burst(400, 200, 5, kunai_pair[0]);

      big_kunai_lock_flash = max(big_kunai_lock_flash, 0.6);
      scr_bg_bass_hit();
      scr_impact_pulse(0.4, 0.9, 0.7);
      tear_amount = max(tear_amount, 0.5);
      scr_add_light(_k_orbit_cx, _k_orbit_cy, global.lightning_color, 9);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 16);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.1);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.28);
        oCameraController.angle_kick = 2.2;
        oCameraController.letterbox_target = 0;
      }

      array_push(ring_bursts, {
        x : _k_orbit_cx,
        y : _k_orbit_cy,
        tier : 2,
        color : merge_color(global.lightning_color, c_white, 0.5),
        num : 8,
        offset : random(360),
        life : 30,
        shockwave_radius : 0,
        shockwave_max_radius : 300,
        shockwave_alpha : 1.3,
        shockwave_alpha_start : 1.3
      });

      for (var k = 0; k < 2; k++) {
        if (!instance_exists(kunai_pair[k])) continue;

        array_push(ring_shockwaves, {
          x : kunai_pair[k].x,
          y : kunai_pair[k].y,
          radius : 6,
          max_radius : 200,
          life : 26,
          max_life : 26,
          width : 16,
          hot : 0.85,
          vs : 1
        });

        for (var sIdx = 0; sIdx < 14; sIdx++) {
          array_push(ring_streaks, {
            cx : kunai_pair[k].x,
            cy : kunai_pair[k].y,
            vs : 1,
            ang : random(360),
            dist : random_range(4, 30),
            len : 30 + irandom(34),
            speed : 19,
            width : 1.5 + random(2),
            life : 15,
            max_life : 15,
            hot : 0.85
          });
        }
      }
    }
    if timeline_hit (515) {
      scr_kunai_burst(400, 200, 5, kunai_pair[1]);
    }
    if timeline_hit (531) {
      scr_kunai_burst(400, 200, 5, kunai_pair[0]);
    }
    if timeline_hit (541) {
      scr_kunai_burst(400, 200, 5, kunai_pair[1]);
    }

    if timeline_hit_many (500, 515, 531, 541) {
      var _burst_target = (timeline_hit(500) || timeline_hit(531)) ? 0 : 1;

      if (instance_exists(kunai_pair[_burst_target])) {
        with(kunai_pair[_burst_target]) {
          hit_flash_timer = 6;
          hit_flash_strength = 0.5;
        }
      }

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 9);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.045);
      }
      scr_impact_pulse(0.25, 0.55, 0.4);

      array_push(ring_shockwaves, {
        x : 400,
        y : 200,
        radius : 5,
        max_radius : 150,
        life : 20,
        max_life : 20,
        width : 11,
        hot : 0.6,
        vs : 1
      });
    }

    if timeline_hit_many (623, 643, 662, 681) {
      var _note_hits = [ 623, 643, 662, 681 ];
      var _note_flash_strengths = [ 0.4, 0.6, 0.8, 1.0 ];
      var _note_index = -1;
      for (var n = 0; n < array_length(_note_hits); n++) {
        if (t == _note_hits[n]) {
          _note_index = n;
          break;
        }
      }
      if (_note_index != -1) {
        big_kunai_release = 0.6 + _note_index * 0.13;
        big_kunai_coil = 0;
        orbit_ribbon_heat = max(orbit_ribbon_heat, 0.8 + _note_index * 0.15);

        var _ramp = _note_index / 3;

        scr_bg_bass_hit();
        scr_impact_pulse(0.35 + _ramp * 0.25, 0.85 + _ramp * 0.5, 0.55 + _ramp * 0.5);
        tear_amount = max(tear_amount, _k_big_kunai_note_tear[_note_index] * big_kunai_note_tear_mult);
        global_ripple_pulse = max(global_ripple_pulse, 0.4 + _ramp * 0.4);

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, _k_big_kunai_note_shake[_note_index]);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_big_kunai_note_zoom[_note_index]);
          oCameraController.screen_flash_alpha =
              max(oCameraController.screen_flash_alpha, _k_big_kunai_note_flash[_note_index]);
          oCameraController.angle_kick = _k_big_kunai_note_tilt[_note_index];
          oCameraController.letterbox_target = 0;
        }

        array_push(ring_bursts, {
          x : _k_orbit_cx,
          y : _k_orbit_cy,
          tier : 2 + (_note_index == 3 ? 1 : 0),
          color : merge_color(global.lightning_color, c_white, 0.4 + _ramp * 0.4),
          num : 6 + _note_index * 2,
          offset : random(360),
          life : 30,
          shockwave_radius : 0,
          shockwave_max_radius : 240 + _note_index * 70,
          shockwave_alpha : 1.1 + _ramp * 0.5,
          shockwave_alpha_start : 1.1 + _ramp * 0.5
        });

        for (var s = 0; s < 20 + _note_index * 8; s++) {
          var _pa2 = s * (360 / (20 + _note_index * 8));
          var _px2 = _k_orbit_cx + dcos(_pa2) * _k_orbit_rx;
          var _py2 = _k_orbit_cy + dsin(_pa2) * _k_orbit_ry;

          array_push(orbit_path_ghosts,
                     {x : _px2, y : _py2, ang : _pa2 + 90, alpha : 0.5 + _ramp * 0.5, hot : 0.5 + _ramp * 0.5,
                      scale : 0.9 + _ramp * 0.8});
        }

        for (var k = 0; k < 2; k++) {
          if (!instance_exists(kunai_pair[k]) || !kunai_pair[k].built) continue;

          with(kunai_pair[k]) {
            hit_flash_timer = 6;
            hit_flash_strength = _note_flash_strengths[_note_index];
          }

          array_push(ring_shockwaves, {
            x : kunai_pair[k].x,
            y : kunai_pair[k].y,
            radius : 8,
            max_radius : 170 + _note_index * 60,
            life : 24 + _note_index * 3,
            max_life : 24 + _note_index * 3,
            width : 14 + _note_index * 5,
            hot : 0.6 + _ramp * 0.4,
            vs : 1
          });

          var _tan_dir = kunai_pair[k].current_tangent_dir;
          for (var p = 0; p < 14 + _note_index * 7; p++) {
            var _pd = _tan_dir + 180 + random_range(-55, 55);
            var _ps2 = random_range(3, 9 + _note_index * 2);
            var _pt_roll = random(1);
            var _pt_col = (_pt_roll < 0.68) ? global.avoid_col_warning
                        : ((_pt_roll < 0.92) ? global.avoid_col_cyan : global.avoid_col_violet);
            array_push(arrow_ring_particles, {
              x : kunai_pair[k].x,
              y : kunai_pair[k].y,
              vx : lengthdir_x(_ps2, _pd),
              vy : lengthdir_y(_ps2, _pd),
              life : 22,
              max_life : 22,
              size : random_range(0.12, 0.34),
              grav : 0.08,
              drag : 0.95,
              hot : 0.6 + _ramp * 0.4,
              col : _pt_col
            });
          }

          for (var e = 0; e < 6 + _note_index * 4; e++) {
            var _ed = _tan_dir + 180 + random_range(-70, 70);
            var _es2 = random_range(2, 6);
            array_push(ring_embers, {
              x : kunai_pair[k].x,
              y : kunai_pair[k].y,
              vx : lengthdir_x(_es2, _ed),
              vy : lengthdir_y(_es2, _ed),
              life : 45 + irandom(35),
              max_life : 80,
              size : random_range(0.1, 0.26),
              hot : 0.6 + random(0.4)
            });
          }
        }

        scr_add_light(_k_orbit_cx, _k_orbit_cy, global.lightning_color, 6 + _note_index * 3);
      }

      if (timeline_hit(681)) {
        big_kunai_release = 1;
        orbit_ribbon_heat = max(orbit_ribbon_heat, 1.4);
        t377_flash_timer = 1;

        for (var k = 0; k < 2; k++) {
          if (instance_exists(kunai_pair[k]) && kunai_pair[k].built) {
            with(kunai_pair[k]) {
              deorbiting = true;
              deorbit_timer = 0;
              deorbit_start_dir = current_tangent_dir;
              deorbit_start_speed = current_tangent_speed;
            }

            var _fling_dir = kunai_pair[k].current_tangent_dir;
            for (var sIdx = 0; sIdx < 22; sIdx++) {
              array_push(ring_streaks, {
                cx : kunai_pair[k].x,
                cy : kunai_pair[k].y,
                vs : 1,
                ang : _fling_dir + 180 + random_range(-38, 38),
                dist : random_range(0, 40),
                len : 55 + irandom(60),
                speed : 28,
                width : 2 + random(2.5),
                life : 18,
                max_life : 18,
                hot : 1
              });
            }
          }
        }

        for (var s = 0; s < 56; s++) {
          var _sa2 = s * (360 / 56);
          array_push(orbit_path_ghosts, {
            x : _k_orbit_cx + dcos(_sa2) * _k_orbit_rx,
            y : _k_orbit_cy + dsin(_sa2) * _k_orbit_ry,
            ang : _sa2 + 90,
            alpha : 1,
            hot : 1,
            scale : 1.6
          });
        }

        for (var e = 0; e < 34; e++) {
          var _ea2 = random(360);
          var _ex = _k_orbit_cx + dcos(_ea2) * _k_orbit_rx;
          var _ey = _k_orbit_cy + dsin(_ea2) * _k_orbit_ry;
          array_push(ring_embers, {
            x : _ex,
            y : _ey,
            vx : random_range(-3, 3),
            vy : random_range(-3, 1),
            life : 70 + irandom(45),
            max_life : 115,
            size : random_range(0.1, 0.3),
            hot : 1
          });
        }

        if (instance_exists(oCameraController)) {
          oCameraController.letterbox_target = 0;
          oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
        }
      }
    }
  }
if
  true {
    if (timeline_hit(690 - _k_quarter_telegraph_duration)) {
      quarter_telegraph_active = true;
      quarter_telegraph_timer = 0;

      quarter_arcs = [];
      quarter_ghosts = [];
      quarter_scars = [];
      quarter_heat = 0;
      quarter_coil = 0;
      quarter_core_charge = 0;
      quarter_lock_flash = 0;
      quarter_beat_flash = 0;
      quarter_detonated = false;

      qamb = 0;
      qamb_hb = 0;
      quarter_readout = 0;
      quarter_locked = false;
      quarter_lock_frame = -10000;
      qamb_live = false;
      quarter_safe_slide = 1;
      quarter_safe_flash = 0;
      quarter_safe_w = 90;
      quarter_pinch = 0;
      quarter_pinch_eta = 999;
      quarter_alt_w = 0;
      quarter_beat_traced = -1;
      quarter_tracers = [];
      quarter_craters = [];
      quarter_stuck = [];
      quarter_rim_crackle = [];
      quarter_lock_frames = [];
      quarter_vents = [];

      for (var _qi = 0; _qi < 44; _qi++) {
        var _q_dest = (_qi mod 2 == 0) ? 140 : 70;
        array_push(converge_motes, {
          cx : 400,
          cy : 304,
          ang : random(360),
          dist : _q_dest + random_range(150, 340),
          dest : _q_dest,
          speed : random_range(7, 13),
          size : random_range(0.15, 0.5),
          spin : random_range(-4, 4),
          hot : random_range(0, 0.6),
          feed : "quarter"
        });
      }

      if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = 0.5;
      }
    }
    if (quarter_telegraph_active) {
      quarter_telegraph_timer++;
      if (quarter_telegraph_timer >= _k_quarter_telegraph_duration) {
        quarter_telegraph_active = false;
      }
    }

    if (timeline_hit(690)) {
      quarter_circles = [];

      var _q_corner_axes = [
        point_direction(400, 304, _k_qamb_pad, _k_qamb_pad) mod 180,
        point_direction(400, 304, room_width - _k_qamb_pad, _k_qamb_pad) mod 180
      ];

      var _q_last_beat_t = _k_quarter_beats[array_length(_k_quarter_beats) - 1];

      var _q_unit = 1;
      var _q_dbig = 0;
      var _q_dbig_at_beat = [];
      var _q_beat_cursor = 0;
      for (var _qf = _k_quarter_lock_t; _qf <= _q_last_beat_t; _qf++) {
        var _q_heat_sim = clamp((_qf - _k_quarter_lock_t) / max(1, _q_last_beat_t - _k_quarter_lock_t), 0, 1);
        var _q_coil_sim = (_qf >= _k_quarter_coil_t)
            ? power(clamp((_qf - _k_quarter_coil_t) / (_k_quarter_collapse_t - _k_quarter_coil_t), 0, 1), 1.6)
            : 0;
        var _q_is_beat = (_q_beat_cursor < array_length(_k_quarter_beats) && _qf == _k_quarter_beats[_q_beat_cursor]);

        _q_unit = _q_is_beat ? (4 + _q_heat_sim * 3.5 + _q_coil_sim * 4)
                              : lerp(_q_unit, 1 + _q_coil_sim * 2.5, 0.08 * (1 - _q_coil_sim * 0.6));

        _q_dbig += 1.2 * _q_unit;

        if (_q_is_beat) {
          array_push(_q_dbig_at_beat, _q_dbig);
          _q_beat_cursor++;
        }
      }

      var _q_phi0 = random(180);
      var _q_seed_big = random(360);
      var _q_best_streak = 999;

      for (var _q_try = 0; _q_try < 40; _q_try++) {
        var _q_cand_big0 = random(360);
        var _q_max_streak = 0;
        var _q_streak = [0, 0];

        for (var _q_bi = 0; _q_bi < array_length(_q_dbig_at_beat); _q_bi++) {
          var _q_db = _q_dbig_at_beat[_q_bi];
          var _q_phi = ((_q_phi0 - (17 / 6) * _q_db) mod 180 + 180) mod 180;
          var _q_w = abs(_q_phi - 90);
          var _q_off = (_q_phi <= 90) ? (135 + _q_phi * 0.5) : (45 + _q_phi * 0.5);
          var _q_center = _q_cand_big0 + _q_db + _q_phi * 0.5 + _q_off;

          for (var _q_ax = 0; _q_ax < 2; _q_ax++) {
            var _q_d = ((_q_center - _q_corner_axes[_q_ax]) mod 180 + 180) mod 180;
            if (_q_d > 90) _q_d = 180 - _q_d;

            if (_q_d <= _q_w * 0.5) {
              _q_streak[_q_ax] = 0;
            } else {
              _q_streak[_q_ax]++;
              _q_max_streak = max(_q_max_streak, _q_streak[_q_ax]);
            }
          }
        }

        if (_q_max_streak < _q_best_streak) {
          _q_best_streak = _q_max_streak;
          _q_seed_big = _q_cand_big0;
          if (_q_best_streak <= 2) break;
        }
      }

      var _q_seed_small = _q_seed_big + _q_phi0;

      var big_num = 3;
      var big = {
        cx : 400,
        cy : 304,
        radius : 140,
        radius_current : 140,
        radius_pulse_scale : 1.15,
        base_angle : _q_seed_big,
        spin_speed : 1.2,
        current_spin : 1.2,
        kick_multiplier : 4,
        spin_ease_rate : 0.08,
        size : 2.0,
        child_speed : 6.4,
        pulse_scale : 1.8,
        pulse_duration : 10,
        beat_timer : 0,
        beat_duration : 10,
        orbiters : [],
        spawn_timer : 0,
        spawn_duration : _k_quarter_spawn_duration,
        spawned : false,
        despawning : false,
        despawn_timer : 0,
        despawn_duration : 33,
        despawn_start_spin : 0,
        despawn_start_radius : 0,
        despawn_shake : 0,
        despawn_flash : 0,
        despawn_expand_mult : 1,
        despawn_wobble : 0,
        gravity_strength : 0
      };
      for (var i = 0; i < big_num; ++i) {
        var f = i / (big_num - 1);
        var a = lerp(0, 90, f);
        var _orb = instance_create_layer(big.cx, big.cy, layer, oRedOrbQuarterCircles);
        _orb.circle_id = 0;
        _orb.qc_radius = big.radius;
        _orb.qc_angle = a;
        _orb.qc_spin = big.spin_speed;

        array_push(big.orbiters, {inst : _orb, offset : a, pulse_timer : 0});

        _orb = instance_create_layer(big.cx, big.cy, layer, oRedOrbQuarterCircles);
        _orb.circle_id = 0;
        _orb.qc_radius = big.radius;
        _orb.qc_angle = 270 - a;
        _orb.qc_spin = big.spin_speed;

        array_push(big.orbiters, {inst : _orb, offset : 270 - a, pulse_timer : 0});
      }
      for (var i = 0; i < array_length(big.orbiters); ++i) {
        var o = big.orbiters[i];
        o.inst.speed = 0;
        o.inst._size = big.size;
        o.inst.image_xscale = big.size;
        o.inst.image_yscale = big.size;
        o.inst.circle_id = 0;
        o.inst.image_alpha = 0;
      }

      array_push(quarter_circles, big);

      var small_num = 5;
      var small = {
        cx : 400,
        cy : 304,
        radius : 70,
        radius_current : 70,
        radius_pulse_scale : 1.15,
        base_angle : _q_seed_small,
        spin_speed : -2.2,
        current_spin : -2.2,
        kick_multiplier : 4,
        spin_ease_rate : 0.08,
        size : 1.0,
        child_speed : 4.8,
        pulse_scale : 1.8,
        pulse_duration : 10,
        beat_timer : 0,
        beat_duration : 10,
        orbiters : [],
        spawn_timer : 0,
        spawn_duration : _k_quarter_spawn_duration,
        spawned : false,
        despawning : false,
        despawn_timer : 0,
        despawn_duration : 33,
        despawn_start_spin : 0,
        despawn_start_radius : 0,
        despawn_shake : 0,
        despawn_flash : 0,
        despawn_expand_mult : 1,
        despawn_wobble : 0,
        gravity_strength : 0
      };
      for (var i = 0; i < small_num; ++i) {
        var f = i / (small_num - 1);
        var a = lerp(0, 90, f);
        var _orb = instance_create_layer(small.cx, small.cy, layer, oRedOrbQuarterCircles);
        _orb.sprite_index = sBlueOrb;
        _orb.circle_id = 1;
        _orb.qc_radius = small.radius;
        _orb.qc_angle = a;
        _orb.qc_spin = small.spin_speed;

        array_push(small.orbiters, {inst : _orb, offset : a, pulse_timer : 0});

        _orb = instance_create_layer(small.cx, small.cy, layer, oRedOrbQuarterCircles);
        _orb.sprite_index = sBlueOrb;
        _orb.circle_id = 1;
        _orb.qc_radius = small.radius;
        _orb.qc_angle = 270 - a;
        _orb.qc_spin = small.spin_speed;

        array_push(small.orbiters, {inst : _orb, offset : 270 - a, pulse_timer : 0});
      }
      for (var i = 0; i < array_length(small.orbiters); ++i) {
        var o = small.orbiters[i];
        o.inst.speed = 0;
        o.inst._size = small.size;
        o.inst.image_xscale = small.size;
        o.inst.image_yscale = small.size;
        o.inst.circle_id = 1;
        o.inst.image_alpha = 0;
      }
      array_push(quarter_circles, small);
    }
    if (t >= 690 && t < 1040) {
      var _q_beat = false;
      var _q_beat_i = -1;
      for (var _bi = 0; _bi < array_length(_k_quarter_beats); _bi++) {
        if (timeline_hit(_k_quarter_beats[_bi])) {
          _q_beat = true;
          _q_beat_i = _bi;
          break;
        }
      }

      var _q_last_beat = _k_quarter_beats[array_length(_k_quarter_beats) - 1];
      quarter_heat = clamp((t - _k_quarter_lock_t) / max(1, _q_last_beat - _k_quarter_lock_t), 0, 1);

      if (quarter_detonated) {
        quarter_coil = max(0, quarter_coil - 0.08);
      } else if (t >= _k_quarter_coil_t) {
        quarter_coil =
            power(clamp((t - _k_quarter_coil_t) / (_k_quarter_collapse_t - _k_quarter_coil_t), 0, 1), 1.6);
      }

      var _q_pulse = 0.5 + 0.5 * sin(t * (0.09 + quarter_heat * 0.16));
      vignette_pulse = max(vignette_pulse, (0.05 + quarter_heat * 0.16) * _q_pulse + quarter_coil * 0.5);
      bloom_pulse = max(bloom_pulse, quarter_beat_flash * 0.25 + quarter_coil * 0.4);

      if (array_length(quarter_circles) >= 2) {
        qamb_live = true;

        for (var _mi = 0; _mi < 2; _mi++) {
          var _mg = quarter_circles[_mi];
          var _m_ease = _mg.spawned ? 1 : (1 - power(1 - (_mg.spawn_timer / _mg.spawn_duration), 3));

          qamb_base[_mi] = _mg.base_angle + _mg.despawn_wobble;
          qamb_rad[_mi] = _mg.radius_current * _m_ease;
          qamb_spin[_mi] = _mg.current_spin;
        }
      } else {
        qamb_live = false;

        qamb_base[0] += qamb_spin[0];
        qamb_base[1] += qamb_spin[1];
      }

      var _qamb_target;

      if (!quarter_locked) {
        _qamb_target = clamp((t - 690) / 19, 0, 1) * 0.28;
      } else {
        _qamb_target = 0.34 + quarter_heat * 0.4 + quarter_coil * 0.5;
      }

      if (quarter_detonated) {
        _qamb_target *= clamp(1 - (t - 995) / 34, 0, 1);
      }

      qamb = lerp(qamb, _qamb_target, (_qamb_target > qamb) ? 0.32 : 0.055);

      var _qhb_freq = lerp(0.08, 0.27, quarter_heat) + quarter_coil * 0.45;
      qamb_hb_phase += _qhb_freq;
      qamb_hb = power((sin(qamb_hb_phase) + 1) * 0.5, 3) *
                (0.26 + quarter_heat * 0.4 + quarter_coil * 0.85);

      var _qread_target = (quarter_locked && !quarter_detonated && t < _k_quarter_collapse_t) ? 1 : 0;
      quarter_readout = lerp(quarter_readout, _qread_target, (_qread_target > quarter_readout) ? 0.14 : 0.09);

      quarter_safe_slide = min(1, quarter_safe_slide + 0.1);
      quarter_safe_flash = max(0, quarter_safe_flash - 0.055);

      if (qamb_live) {
        var _phi = ((qamb_base[1] - qamb_base[0]) mod 180 + 180) mod 180;

        quarter_safe_w = abs(_phi - 90);

        var _derived = (_phi <= 90) ? (qamb_base[0] + 135 + _phi * 0.5)
                                    : (qamb_base[0] + 45 + _phi * 0.5);

        if (abs(angle_difference(_derived + 180, quarter_safe_ang)) <
            abs(angle_difference(_derived, quarter_safe_ang))) {
          _derived += 180;
        }

        var _qdif = angle_difference(_derived, quarter_safe_ang);

        if (abs(_qdif) > 25) {
          if (instance_exists(oPlayer)) {
            var _player_ang = point_direction(400, 304, oPlayer.x, oPlayer.y);
            var _derived_alt = _derived + 180;

            if (abs(angle_difference(_derived_alt, _player_ang)) <
                abs(angle_difference(_derived, _player_ang))) {
              _derived = _derived_alt;
            }
          }

          quarter_move_safe(_derived);
        } else {
          quarter_safe_ang += _qdif;
          quarter_safe_ang_prev += _qdif;
        }

        quarter_pinch = clamp(1 - quarter_safe_w / _k_q_pinch_w, 0, 1);

        var _dphi = qamb_spin[1] - qamb_spin[0];
        var _qdrift = abs(_dphi);
        var _qgap = (_dphi < 0) ? (((_phi - 90) mod 180 + 180) mod 180)
                                : (((90 - _phi) mod 180 + 180) mod 180);

        quarter_pinch_eta = (_qdrift > 0.01) ? (_qgap / _qdrift) : 999;

        if (quarter_safe_w < _k_q_pinch_w * 2) {
          var _qbears = [];

          for (var _gi2 = 0; _gi2 < array_length(quarter_circles); _gi2++) {
            var _gg = quarter_circles[_gi2];
            for (var _oi2 = 0; _oi2 < array_length(_gg.orbiters); _oi2++) {
              var _oo = _gg.orbiters[_oi2];
              if (!instance_exists(_oo.inst)) continue;
              array_push(_qbears, ((_gg.base_angle + _gg.despawn_wobble + _oo.offset) mod 360 + 360) mod 360);
            }
          }

          var _qbn = array_length(_qbears);

          if (_qbn > 1) {
            array_sort(_qbears, true);

            var _qbestw = -1;
            var _qbestc = quarter_alt_ang;

            for (var _bi2 = 0; _bi2 < _qbn; _bi2++) {
              var _qb0 = _qbears[_bi2];
              var _qb1 = (_bi2 == _qbn - 1) ? (_qbears[0] + 360) : _qbears[_bi2 + 1];
              var _qbw = _qb1 - _qb0;

              if (_qbw > _qbestw) {
                _qbestw = _qbw;
                _qbestc = _qb0 + _qbw * 0.5;
              }
            }

            quarter_alt_w = _qbestw;
            quarter_alt_ang = _qbestc;
          }
        } else {
          quarter_alt_w = 0;
        }
      }

      quarter_alt_ang_draw += angle_difference(quarter_alt_ang, quarter_alt_ang_draw) * 0.22;

      if (qamb > 0.3 && irandom(max(4, round(26 - qamb * 16))) == 0) {
        array_push(quarter_rim_crackle, {
          ang : random(360),
          life : 7,
          life_max : 7,
          len : random_range(20, 54),
          cid : irandom(1)
        });
      }

      if (quarter_locked && qamb_live && !quarter_detonated && t < _k_quarter_collapse_t) {
        var _q_next_t = -1;
        var _q_next_i = -1;

        for (var _nb = 0; _nb < array_length(_k_quarter_beats); _nb++) {
          if (_k_quarter_beats[_nb] > t) {
            _q_next_t = _k_quarter_beats[_nb];
            _q_next_i = _nb;
            break;
          }
        }

        if (_q_next_i >= 0 && _q_next_i != quarter_beat_traced &&
            (_q_next_t - t) <= _k_q_tracer_lead) {
          quarter_beat_traced = _q_next_i;
          quarter_land_cursor++;

          var _q_life = _q_next_t - t;

          for (var _tg = 0; _tg < array_length(quarter_circles); _tg++) {
            var _tgq = quarter_circles[_tg];

            for (var _to = 0; _to < array_length(_tgq.orbiters); _to++) {
              var _too = _tgq.orbiters[_to];
              if (!instance_exists(_too.inst)) continue;

              var _t_lands = (((_to + quarter_land_cursor) mod _k_q_land_every) == 0);

              quarter_push_tracer(_tg, _to, _tgq.base_angle + _tgq.despawn_wobble + _too.offset,
                                  _too.inst.x, _too.inst.y, _q_life, _tgq.child_speed,
                                  0.3 + quarter_heat * 0.45 + quarter_coil * 0.25, _tg, _t_lands);
            }
          }
        }
      }

      if (timeline_hit(_k_quarter_lock_t)) {
        quarter_lock_flash = 1;
        quarter_core_charge = max(quarter_core_charge, 1.6);

        quarter_locked = true;
        quarter_lock_frame = t;
        qamb = max(qamb, 0.55);

        for (var _qlk = 0; _qlk < array_length(quarter_circles); _qlk++) {
          var _qlc = quarter_circles[_qlk];
          quarter_push_lock(_qlc.cx, _qlc.cy, _qlc.radius, _qlk, 0.55);
        }

        if (instance_exists(oCameraController)) {
          oCameraController.letterbox_target = 0;
          oCameraController.shake = max(oCameraController.shake, 7);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.07);
          oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.22);
        }
        aberration_pulse = max(aberration_pulse, 0.7);
        global_ripple_pulse = max(global_ripple_pulse, 0.45);

        for (var _qi = 0; _qi < array_length(quarter_circles); ++_qi) {
          var _qc0 = quarter_circles[_qi];
          array_push(ring_shockwaves, {
            x : _qc0.cx,
            y : _qc0.cy,
            vs : 1,
            radius : _qc0.radius * 0.4,
            max_radius : _qc0.radius + 150,
            life : 24,
            max_life : 24,
            width : 12,
            hot : 0.7
          });
        }

        for (var _p = 0; _p < 26; _p++) {
          var _pa = random(360);
          var _ps = random_range(3, 9);
          array_push(arrow_ring_particles, {
            x : 400,
            y : 304,
            vx : lengthdir_x(_ps, _pa),
            vy : lengthdir_y(_ps, _pa),
            life : 20 + irandom(12),
            max_life : 32,
            size : random_range(0.12, 0.32),
            grav : 0.05,
            drag : 0.95,
            hot : 0.7
          });
        }
      }

      if (timeline_hit(_k_quarter_coil_t)) {
        if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0.9;

        for (var _qlk2 = 0; _qlk2 < array_length(quarter_circles); _qlk2++) {
          var _qlc2 = quarter_circles[_qlk2];
          quarter_push_lock(_qlc2.cx, _qlc2.cy, _qlc2.radius_current, _qlk2, 0.85);
        }

        for (var _ci = 0; _ci < 70; _ci++) {
          array_push(converge_motes, {
            cx : 400,
            cy : 304,
            ang : random(360),
            dist : random_range(240, 520),
            dest : random_range(10, 46),
            speed : random_range(9, 17),
            size : random_range(0.2, 0.65),
            spin : random_range(-6, 6),
            hot : random_range(0.3, 1),
            feed : "quarter"
          });
        }
      }

      if (timeline_hit(_k_quarter_collapse_t)) {
        for (var qi = 0; qi < array_length(quarter_circles); ++qi) {
          var qc = quarter_circles[qi];

          quarter_push_lock(qc.cx, qc.cy, qc.radius_current, qi, 1);

          qc.despawning = true;
          qc.despawn_timer = 0;
          qc.despawn_duration = _k_quarter_collapse_frames;
          qc.despawn_start_spin = qc.current_spin;
          qc.despawn_start_radius = qc.radius_current;
        }

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 10);
        }
        tear_amount = max(tear_amount, 0.35);
      }

      var _q_charge = max(quarter_heat, quarter_coil * 1.3);

      if (array_length(quarter_circles) >= 2) {
        var _qa = quarter_circles[0];
        var _qb = quarter_circles[1];

        if (irandom(max(1, round(lerp(12, 2, clamp(_q_charge, 0, 1))))) == 0) {
          var _oa = _qa.orbiters[irandom(array_length(_qa.orbiters) - 1)];
          var _ob = _qb.orbiters[irandom(array_length(_qb.orbiters) - 1)];

          if (instance_exists(_oa.inst) && instance_exists(_ob.inst)) {
            array_push(quarter_arcs, {
              ax : _oa.inst.x,
              ay : _oa.inst.y,
              bx : _ob.inst.x,
              by : _ob.inst.y,
              life : 6,
              max_life : 6,
              hot : 0.3 + _q_charge * 0.6,
              width : 0.8 + _q_charge * 1.1,
              off : scr_bolt_offsets(4, 6 + _q_charge * 12)
            });
          }
        }

        if (_q_charge > 0.25 && irandom(max(2, round(lerp(22, 4, clamp(_q_charge, 0, 1))))) == 0) {
          var _lo = _qa.orbiters[irandom(array_length(_qa.orbiters) - 1)];
          if (instance_exists(_lo.inst)) {
            var _lang = point_direction(_qa.cx, _qa.cy, _lo.inst.x, _lo.inst.y) + random_range(-40, 40);
            var _llen = random_range(35, 60 + _q_charge * 90);
            array_push(quarter_arcs, {
              ax : _lo.inst.x,
              ay : _lo.inst.y,
              bx : _lo.inst.x + lengthdir_x(_llen, _lang),
              by : _lo.inst.y + lengthdir_y(_llen, _lang),
              life : 5,
              max_life : 5,
              hot : 0.8,
              width : 0.7 + _q_charge,
              off : scr_bolt_offsets(3, 8 + _q_charge * 10)
            });
          }
        }
      }

      if (_q_charge > 0.2 && (t mod max(3, round(lerp(9, 3, clamp(_q_charge, 0, 1)))) == 0)) {
        for (var _gi = 0; _gi < array_length(quarter_circles); ++_gi) {
          var _gq = quarter_circles[_gi];
          array_push(quarter_ghosts, {
            cx : _gq.cx,
            cy : _gq.cy,
            radius : _gq.radius_current,
            ang : _gq.base_angle + _gq.despawn_wobble,
            alpha : 0.35 + _q_charge * 0.4,
            hot : (_gi == 0) ? 0.25 : 0.6,
            id : _gi
          });
        }
      }

      if (_q_charge > 0.15 && irandom(max(1, round(lerp(9, 2, clamp(_q_charge, 0, 1))))) == 0 &&
          array_length(quarter_circles) > 0) {
        var _dq = quarter_circles[0];
        var _dang = random(360);
        array_push(ring_embers, {
          x : _dq.cx + lengthdir_x(_dq.radius_current, _dang),
          y : _dq.cy + lengthdir_y(_dq.radius_current, _dang),
          vx : random_range(-0.8, 0.8),
          vy : random_range(-0.6, 0.2),
          life : 40 + irandom(35),
          max_life : 75,
          size : random_range(0.08, 0.2),
          hot : random_range(0.4, 1)
        });
      }

      if (_q_beat) {
        quarter_beat_flash = 1;
        quarter_core_charge = max(quarter_core_charge, 0.5 + quarter_heat * 0.9);

        if (instance_exists(oCameraController)) {
          with(oCameraController) {
            zoom_kick_active = true;
            zoom_kick_timer = 0;
          }
          oCameraController.shake = max(oCameraController.shake, 2 + quarter_heat * 6);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.015 + quarter_heat * 0.05);
        }

        aberration_pulse = max(aberration_pulse, 0.15 + quarter_heat * 0.55);

        for (var _qi = 0; _qi < array_length(quarter_circles); ++_qi) {
          var _qc1 = quarter_circles[_qi];
          array_push(ring_shockwaves, {
            x : _qc1.cx,
            y : _qc1.cy,
            vs : 1,
            radius : _qc1.radius_current,
            max_radius : _qc1.radius_current + 70 + quarter_heat * 130,
            life : 15,
            max_life : 15,
            width : 6 + quarter_heat * 8,
            hot : 0.25 + quarter_heat * 0.6
          });

          var _spark_n = 1 + round(quarter_heat * 2);
          for (var _oi = 0; _oi < array_length(_qc1.orbiters); _oi += 2) {
            var _so = _qc1.orbiters[_oi];
            if (!instance_exists(_so.inst)) continue;

            var _tan = point_direction(_qc1.cx, _qc1.cy, _so.inst.x, _so.inst.y) + ((_qc1.spin_speed > 0) ? 90 : -90);
            for (var _sp = 0; _sp < _spark_n; _sp++) {
              var _ss = random_range(2, 5 + quarter_heat * 5);
              var _sa = _tan + random_range(-28, 28);
              array_push(arrow_ring_particles, {
                x : _so.inst.x,
                y : _so.inst.y,
                vx : lengthdir_x(_ss, _sa),
                vy : lengthdir_y(_ss, _sa),
                life : 12 + irandom(10),
                max_life : 22,
                size : random_range(0.08, 0.22),
                grav : 0.07,
                drag : 0.94,
                hot : 0.35 + quarter_heat * 0.5
              });
            }
          }
        }

        if (_q_beat_i mod 3 == 0) {
          array_push(ring_bursts, {
            x : 400,
            y : 304,
            tier : 0,
            color : global.lightning_color,
            num : 0,
            offset : 0,
            life : 26,
            shockwave_radius : 12,
            shockwave_max_radius : 150 + quarter_heat * 90,
            shockwave_alpha_start : 0.3 + quarter_heat * 0.35,
            shockwave_alpha : 0.3 + quarter_heat * 0.35
          });
        }
      }

      for (var qi = 0; qi < array_length(quarter_circles); ++qi) {
        var qc = quarter_circles[qi];

        if (qc.despawning) {
          qc.despawn_timer++;

          var d = clamp(qc.despawn_timer / qc.despawn_duration, 0, 1);

          var expand_time = max(3, round(qc.despawn_duration * 0.3));

          if (qc.despawn_timer <= expand_time) {
            var charge = qc.despawn_timer / expand_time;

            var expand = power(charge, 2);

            qc.despawn_expand_mult = lerp(1, 1.6, expand);

            qc.radius_current = qc.despawn_start_radius * qc.despawn_expand_mult;

            qc.current_spin = lerp(qc.despawn_start_spin, qc.despawn_start_spin * 3, expand);

            qc.base_angle += qc.current_spin;

            qc.despawn_wobble = sin(qc.despawn_timer * 3) * charge * 5 * fx_get_mult_for("quartercircles", "ripple");
          }

          else {
            var collapse = (qc.despawn_timer - expand_time) / (qc.despawn_duration - expand_time);

            qc.gravity_strength = power(collapse, 3) * 35;

            var collapse_curve = power(collapse, 1.35);

            qc.radius_current = lerp(qc.despawn_start_radius * 1.6, 0, collapse_curve);

            qc.current_spin = lerp(qc.despawn_start_spin * 3, 0, power(collapse, 2));

            qc.base_angle += qc.current_spin * (1 + collapse * 5);

            qc.despawn_wobble = sin(qc.despawn_timer * 5) * collapse * 10 * fx_get_mult_for("quartercircles", "ripple");

            if (collapse > 0.7) {
              qc.despawn_flash = (collapse - 0.7) / 0.3;
            }
          }

          if (d >= 1) {
            var _q_first = !quarter_detonated;
            quarter_detonated = true;

            for (var i = 0; i < array_length(qc.orbiters); i++) {
              var o = qc.orbiters[i];

              if (instance_exists(o.inst)) {
                instance_destroy(o.inst);
              }
            }

            array_push(quarter_scars, {
              cx : qc.cx,
              cy : qc.cy,
              radius : qc.despawn_start_radius,
              ang : qc.base_angle,
              alpha : 1,
              hot : (qc.radius > 100) ? 0.55 : 0.85
            });

            if (_q_first) {
              if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 22);
                oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.22);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.55);
                oCameraController.letterbox_target = 0;
                oCameraController.angle_kick = 3.5;
              }

              vignette_pulse = max(vignette_pulse, 0.9);
              bloom_pulse = max(bloom_pulse, 0.9);
              aberration_pulse = max(aberration_pulse, 1.2);
              global_ripple_pulse = max(global_ripple_pulse, 1);
              tear_amount = max(tear_amount, 0.8);
              quarter_core_charge = 2.2;

              array_push(ring_bursts, {
                x : 400, y : 304, tier : 0, color : c_white, num : 0, offset : 0,
                life : 40,
                shockwave_radius : 6,
                shockwave_max_radius : 300,
                shockwave_alpha_start : 0.95,
                shockwave_alpha : 0.95
              });
              array_push(ring_bursts, {
                x : 400, y : 304, tier : 0, color : global.lightning_color, num : 0, offset : 0,
                life : 46,
                shockwave_radius : 60,
                shockwave_max_radius : 460,
                shockwave_alpha_start : 0.55,
                shockwave_alpha : 0.55
              });

              array_push(ring_shockwaves, {
                x : 400, y : 304, vs : 1,
                radius : 8, max_radius : 420,
                life : 34, max_life : 34, width : 22, hot : 1
              });
              array_push(ring_shockwaves, {
                x : 400, y : 304, vs : 1,
                radius : 4, max_radius : 210,
                life : 22, max_life : 22, width : 12, hot : 0.5
              });

              for (var _s = 0; _s < 44; _s++) {
                array_push(ring_streaks, {
                  cx : 400, cy : 304, vs : 1,
                  ang : random(360),
                  dist : random_range(0, 40),
                  len : 70 + irandom(120),
                  speed : 26 + random(16),
                  width : 2 + random(3),
                  life : 20,
                  max_life : 20,
                  hot : 1
                });
              }

              for (var _p = 0; _p < 70; _p++) {
                var _pa2 = random(360);
                var _ps2 = random_range(4, 16);
                array_push(arrow_ring_particles, {
                  x : 400, y : 304,
                  vx : lengthdir_x(_ps2, _pa2),
                  vy : lengthdir_y(_ps2, _pa2),
                  life : 22 + irandom(20),
                  max_life : 42,
                  size : random_range(0.12, 0.4),
                  grav : 0.12,
                  drag : 0.94,
                  hot : 0.8
                });
              }

              for (var _e = 0; _e < 40; _e++) {
                var _ea3 = random(360);
                var _er3 = random_range(20, 150);
                array_push(ring_embers, {
                  x : 400 + lengthdir_x(_er3, _ea3),
                  y : 304 + lengthdir_y(_er3, _ea3),
                  vx : random_range(-3.5, 3.5),
                  vy : random_range(-3.5, 0.5),
                  life : 60 + irandom(50),
                  max_life : 110,
                  size : random_range(0.1, 0.3),
                  hot : 1
                });
              }

              for (var _b2 = 0; _b2 < 16; _b2++) {
                var _bang = _b2 * (360 / 16) + random_range(-8, 8);
                var _blen = random_range(150, 300);
                array_push(quarter_arcs, {
                  ax : 400,
                  ay : 304,
                  bx : 400 + lengthdir_x(_blen, _bang),
                  by : 304 + lengthdir_y(_blen, _bang),
                  life : 12,
                  max_life : 12,
                  hot : 1,
                  width : 2.2,
                  off : scr_bolt_offsets(5, 26)
                });
              }
            }

            array_delete(quarter_circles, qi, 1);
            continue;
          }
        }

        if (!qc.spawned) {
          qc.spawn_timer++;
          if (qc.spawn_timer >= qc.spawn_duration) {
            qc.spawned = true;
            scr_quarter_spawn_shockwave(qc.cx, qc.cy);
          }
        }
        var _spawn_ease = qc.spawned ? 1 : (1 - power(1 - (qc.spawn_timer / qc.spawn_duration), 3));

        if (!qc.despawning) {
          if (_q_beat) {
            qc.current_spin = qc.spin_speed * (qc.kick_multiplier + quarter_heat * 3.5 + quarter_coil * 4);
            qc.beat_timer = qc.beat_duration;
          } else {
            qc.current_spin =
                lerp(qc.current_spin, qc.spin_speed * (1 + quarter_coil * 2.5), qc.spin_ease_rate * (1 - quarter_coil * 0.6));
          }
        }
        qc.base_angle += qc.current_spin;

        if (!qc.despawning) {
          var radius_frac = (qc.beat_timer > 0) ? (qc.beat_timer / qc.beat_duration) : 0;
          qc.radius_current = lerp(qc.radius, qc.radius * qc.radius_pulse_scale, radius_frac);

          if (qc.beat_timer > 0) qc.beat_timer -= 1;
        }

        var radius_frac = (qc.beat_timer > 0) ? (qc.beat_timer / qc.beat_duration) : 0;
        var flash_blend = merge_colour(c_white, global.lightning_color, radius_frac);

        for (var i = 0; i < array_length(qc.orbiters); ++i) {
          var o = qc.orbiters[i];
          if (!instance_exists(o.inst)) continue;

          var ang = qc.base_angle + o.offset + qc.despawn_wobble;
          var _display_radius = qc.radius_current * _spawn_ease;

          var pull = qc.gravity_strength;

          o.inst.x = qc.cx + lengthdir_x(max(0, _display_radius - pull), ang);
          o.inst.y = qc.cy + lengthdir_y(max(0, _display_radius - pull), ang);
          o.inst.direction = ang;
          var final_blend = merge_colour(flash_blend, c_white, qc.despawn_flash);

          o.inst.image_blend = final_blend;
          o.inst.image_alpha = _spawn_ease;

          if (o.pulse_timer > 0) {
            var pulse_frac = o.pulse_timer / qc.pulse_duration;
            var scale_now = lerp(qc.size, qc.size * qc.pulse_scale, pulse_frac) * _spawn_ease;
            o.inst._size = scale_now;
            o.inst.image_xscale = scale_now;
            o.inst.image_yscale = scale_now;
            o.pulse_timer -= 1;
          } else {
            var _s = qc.size * _spawn_ease;
            o.inst._size = _s;
            o.inst.image_xscale = _s;
            o.inst.image_yscale = _s;
          }
          o.inst.hit_active = _spawn_ease > 0.35 && abs(o.inst.image_xscale) > 0.25 && abs(o.inst.image_yscale) > 0.25;

          if (!qc.despawning && _q_beat) {
            o.pulse_timer = qc.pulse_duration;

            var _child_dir = ang;
            var _child_spd = qc.child_speed;
            var _child_size = qc.size;
            var _spawn_x = o.inst.x;
            var _spawn_y = o.inst.y;
            var _child_circle_id =
                (qc == quarter_circles[0]) ? 0 : 1;

            with(instance_create_layer(_spawn_x, _spawn_y, layer, oRedOrbQuarterCircles)) {
              direction = _child_dir;
              speed = _child_spd;
              _size = _child_size;
              image_xscale = _child_size;
              image_yscale = _child_size;
              circle_id = _child_circle_id;

              if (circle_id == 1) {
                sprite_index = sBlueOrb;
              }
            }
          }
        }
      }

      if (_q_beat && array_length(quarter_tracers) > 0) {
        for (var _tf = array_length(quarter_tracers) - 1; _tf >= 0; _tf--) {
          var _tfr = quarter_tracers[_tf];
          if (_tfr.fired) continue;

          if (!_tfr.lands) {
            array_delete(quarter_tracers, _tf, 1);
            continue;
          }

          if (_tfr.gi < array_length(quarter_circles)) {
            var _tfg = quarter_circles[_tfr.gi];

            if (_tfr.oi < array_length(_tfg.orbiters)) {
              var _tfo = _tfg.orbiters[_tfr.oi];

              if (instance_exists(_tfo.inst)) {
                _tfr.ang = _tfg.base_angle + _tfg.despawn_wobble + _tfo.offset;
                _tfr.ox = _tfo.inst.x;
                _tfr.oy = _tfo.inst.y;

                var _tfh = quarter_rim_hit(_tfr.ox, _tfr.oy, _tfr.ang);
                _tfr.lx = _tfh.x;
                _tfr.ly = _tfh.y;
                _tfr.dist = _tfh.dist;
                _tfr.vertical = _tfh.vertical;
              }
            }
          }

          _tfr.fired = true;
          _tfr.travel = 0;
        }
      }
    }

    quarter_beat_flash = max(0, quarter_beat_flash - 0.075);
    quarter_lock_flash = max(0, quarter_lock_flash - 0.05);
    quarter_core_charge = max(0, quarter_core_charge - 0.04);
    if (t < 690 || t >= 1040) quarter_coil = max(0, quarter_coil - 0.08);

    for (var i = array_length(quarter_arcs) - 1; i >= 0; i--) {
      quarter_arcs[i].life--;
      if (quarter_arcs[i].life <= 0) array_delete(quarter_arcs, i, 1);
    }

    for (var i = array_length(quarter_lock_frames) - 1; i >= 0; i--) {
      quarter_lock_frames[i].life--;
      if (quarter_lock_frames[i].life <= 0) array_delete(quarter_lock_frames, i, 1);
    }

    scr_update_vent_streams(quarter_vents);

    for (var i = array_length(quarter_ghosts) - 1; i >= 0; i--) {
      quarter_ghosts[i].alpha -= 0.055;
      if (quarter_ghosts[i].alpha <= 0) array_delete(quarter_ghosts, i, 1);
    }

    for (var i = array_length(quarter_scars) - 1; i >= 0; i--) {
      quarter_scars[i].alpha -= 0.014;
      if (quarter_scars[i].alpha <= 0) array_delete(quarter_scars, i, 1);
    }

    for (var i = array_length(quarter_shockwaves) - 1; i >= 0; i--) {
      var sw = quarter_shockwaves[i];
      sw.radius += sw.speed;
      sw.alpha = 1 - (sw.radius / sw.max_radius);
      if (sw.radius >= sw.max_radius) {
        array_delete(quarter_shockwaves, i, 1);
      }
    }

    if (t < 690 || t >= 1040) {
      qamb = max(0, qamb - 0.045);
      qamb_hb = max(0, qamb_hb - 0.06);
      quarter_readout = max(0, quarter_readout - 0.09);
      quarter_safe_flash = max(0, quarter_safe_flash - 0.055);
      quarter_pinch = max(0, quarter_pinch - 0.05);
    }

    if (array_length(quarter_tracers) > 0 || array_length(quarter_craters) > 0 ||
        array_length(quarter_stuck) > 0 || array_length(quarter_rim_crackle) > 0) {
      for (var i = array_length(quarter_tracers) - 1; i >= 0; i--) {
        var _qtr = quarter_tracers[i];

        if (!_qtr.fired) {
          if (_qtr.gi < array_length(quarter_circles)) {
            var _qtg = quarter_circles[_qtr.gi];

            if (_qtr.oi < array_length(_qtg.orbiters)) {
              var _qto = _qtg.orbiters[_qtr.oi];

              if (instance_exists(_qto.inst)) {
                _qtr.ang = _qtg.base_angle + _qtg.despawn_wobble + _qto.offset;
                _qtr.ox = _qto.inst.x;
                _qtr.oy = _qto.inst.y;

                var _qth = quarter_rim_hit(_qtr.ox, _qtr.oy, _qtr.ang);
                _qtr.lx = _qth.x;
                _qtr.ly = _qth.y;
                _qtr.dist = _qth.dist;
                _qtr.vertical = _qth.vertical;
              }
            }
          }

          _qtr.life--;

          if (_qtr.life <= -6) array_delete(quarter_tracers, i, 1);
          continue;
        }

        _qtr.travel += _qtr.speed;

        if (_qtr.travel >= _qtr.dist) {
          quarter_land_child(_qtr.lx, _qtr.ly, _qtr.ang, _qtr.vertical, _qtr.hot, _qtr.cid);
          array_delete(quarter_tracers, i, 1);
        }
      }

      for (var i = array_length(quarter_craters) - 1; i >= 0; i--) {
        var _qcr = quarter_craters[i];
        _qcr.life--;
        _qcr.radius = lerp(_qcr.radius, _qcr.max_radius, 0.24);
        if (_qcr.life <= 0) array_delete(quarter_craters, i, 1);
      }

      for (var i = array_length(quarter_stuck) - 1; i >= 0; i--) {
        var _qst = quarter_stuck[i];
        _qst.life--;
        _qst.wobble *= 0.86;
        if (_qst.life <= 0) array_delete(quarter_stuck, i, 1);
      }

      for (var i = array_length(quarter_rim_crackle) - 1; i >= 0; i--) {
        quarter_rim_crackle[i].life--;
        if (quarter_rim_crackle[i].life <= 0) array_delete(quarter_rim_crackle, i, 1);
      }
    }

    if (t >= 690 && t < 1900) {
      for (var i = array_length(ring_bursts) - 1; i >= 0; --i) {
        var _b = ring_bursts[i];
        _b.life -= 1;

        if (_b.shockwave_radius < _b.shockwave_max_radius) {
          _b.shockwave_radius += 8;
          var _progress = _b.shockwave_radius / _b.shockwave_max_radius;
          var _b_start = variable_struct_exists(_b, "shockwave_alpha_start") ? _b.shockwave_alpha_start : 0.5;
          _b.shockwave_alpha = _b_start * (1 - _progress);
        } else {
          _b.shockwave_alpha = 0;
        }

        if (_b.life <= 0) array_delete(ring_bursts, i, 1);
      }
    }
  }
if
  true {
    var _st_n = array_length(_k_stamp_beats);

    var _st_fired = 0;
    for (var _sb = 0; _sb < _st_n; _sb++) {
      if (t >= _k_stamp_beats[_sb]) _st_fired++;
    }

    var _st_next_i = _st_fired;
    var _st_has_next = (_st_next_i < _st_n);
    var _st_next_t = _st_has_next ? _k_stamp_beats[_st_next_i] : _k_stamp_t_blowout;
    var _st_prev_t = (_st_fired > 0) ? _k_stamp_beats[_st_fired - 1] : _k_stamp_t_arm;

    stamp_live = (t >= _k_stamp_t_arm - 2 && t <= _k_stamp_t_clear);
    stamp_armed = (t >= _k_stamp_t_arm && t < _k_stamp_t_blowout);
    stamp_dead = (t >= _k_stamp_t_blowout);

    var _st_seat = [ stamp_face_at(0, _st_fired), stamp_face_at(1, _st_fired) ];

    if (stamp_dead) {
      stamp_face_target[0] = _k_stamp_x0 - 30;
      stamp_face_target[1] = _k_stamp_x1 + 30;
    } else if (_st_has_next) {
      stamp_face_target[0] = stamp_face_at(0, _st_fired + 1);
      stamp_face_target[1] = stamp_face_at(1, _st_fired + 1);
    } else {
      stamp_face_target[0] = _st_seat[0];
      stamp_face_target[1] = _st_seat[1];
    }

    stamp_slam_flash = max(0, stamp_slam_flash - 0.075);
    stamp_beat_flash = max(0, stamp_beat_flash - 0.055);
    stamp_chroma = lerp(stamp_chroma, 0, 0.11);
    stamp_safe_seal = max(0, stamp_safe_seal - 0.03);
    stamp_face_flash[0] = max(0, stamp_face_flash[0] - 0.08);
    stamp_face_flash[1] = max(0, stamp_face_flash[1] - 0.08);

    if (stamp_live && !stamp_dead) {
      var _st_prog = clamp((t - _k_stamp_t_arm) / max(1, _k_stamp_t_blowout - _k_stamp_t_arm), 0, 1);
      stamp_amb = lerp(stamp_amb, 0.35 + _st_prog * 0.85, 0.09);
      stamp_heat = lerp(stamp_heat, _st_prog, 0.06);
      stamp_rail = lerp(stamp_rail, 1, 0.14);
      stamp_readout = lerp(stamp_readout, 1, 0.12);
    } else {
      stamp_amb = max(0, stamp_amb - 0.02);
      stamp_heat = max(0, stamp_heat - 0.012);
      stamp_readout = max(0, stamp_readout - 0.06);
      if (!stamp_live) stamp_rail = max(0, stamp_rail - 0.05);
    }

    if (stamp_live && !stamp_dead) {
      var _st_hb_rate = 0.16 + stamp_heat * 0.22;
      stamp_hb_phase += _st_hb_rate;
      stamp_hb = (0.5 + 0.5 * sin(stamp_hb_phase)) * (0.25 + stamp_heat * 0.75);
    } else {
      stamp_hb = lerp(stamp_hb, 0, 0.12);
    }

    if (stamp_live) {
      var _st_gapf = 1 - clamp((_k_stamp_safe_x0 - stamp_face[0])
                               / max(1, _k_stamp_safe_x0 - _k_stamp_x0), 0, 1);
      stamp_safe_glow = lerp(stamp_safe_glow, stamp_dead ? 0.2 : (0.3 + _st_gapf * 0.7), 0.08);
    } else {
      stamp_safe_glow = max(0, stamp_safe_glow - 0.03);
    }

    if (stamp_live && !stamp_dead && _st_has_next) {
      var _st_span = max(1, _st_next_t - _st_prev_t);
      var _st_raw = clamp((t - _st_prev_t) / _st_span, 0, 1);
      stamp_coil = max(_k_stamp_read_floor, power(_st_raw, _k_stamp_coil_ease));
    } else {
      stamp_coil = max(0, stamp_coil - 0.07);
    }

    var _st_hit = false;
    var _st_hit_i = -1;
    for (var _hb = 0; _hb < _st_n; _hb++) {
      if (timeline_hit(_k_stamp_beats[_hb])) {
        _st_hit = true;
        _st_hit_i = _hb;
        break;
      }
    }

    if (_st_hit) {
      var _st_adv = _k_stamp_advance[_st_hit_i];
      var _st_big = (_st_adv >= 25);

      stamp_slam_flash = max(stamp_slam_flash, _st_big ? 1 : 0.66);
      stamp_beat_flash = max(stamp_beat_flash, _st_big ? 1 : 0.55);
      stamp_chroma = max(stamp_chroma, _st_big ? 0.85 : 0.4);

      for (var _sd = 0; _sd < 2; _sd++) {
        stamp_face_heat[_sd] = min(1.6, stamp_face_heat[_sd] + (_st_big ? 0.7 : 0.4));
        stamp_face_flash[_sd] = 1;

        var _sf_to = _st_seat[_sd];
        stamp_face[_sd] = lerp(stamp_face[_sd], _sf_to, _k_stamp_snap);

        var _sfx = stamp_face[_sd];
        var _sdir = (_sd == 0) ? 1 : -1;

        if (array_length(stamp_tips) < 24) {
          array_push(stamp_tips, {
            x : _sfx,
            life : _st_big ? 15 : 10,
            life_max : _st_big ? 15 : 10,
            hot : _st_big ? 1 : 0.6,
            color : _k_stamp_col_press,
            side : _sd
          });
        }

        var _spark_n = _st_big ? 13 : 8;
        for (var _sp = 0; _sp < _spark_n; _sp++) {
          if (array_length(stamp_sparks) >= _k_stamp_spark_cap) break;
          var _sa = ((_sdir > 0) ? 0 : 180) + random_range(-58, 58);
          var _ss = random_range(2.6, 7.5 + stamp_heat * 3);
          array_push(stamp_sparks, {
            x : _sfx,
            y : random_range(_k_stamp_ceil_y + 20, _k_stamp_floor_y - 4),
            vx : lengthdir_x(_ss, _sa),
            vy : lengthdir_y(_ss, _sa) - random_range(0, 1.6),
            life : irandom_range(11, 26),
            life_max : 26,
            size : random_range(1.1, 2.9),
            hot : random_range(0.45, 1),
            color : (_sp mod 3 == 0) ? c_white : _k_stamp_col_press
          });
        }

        var _vent_n = _st_big ? 3 : 2;
        for (var _vn = 0; _vn < _vent_n; _vn++) {
          scr_spawn_vent_stream(stamp_vents,
                                _sfx - _sdir * random_range(4, 40),
                                random_range(_k_stamp_ceil_y + 30, _k_stamp_floor_y - 20),
                                (_sdir > 0) ? 180 : 0,
                                0.35 + stamp_heat * 0.6,
                                _k_stamp_vent_cols, _k_stamp_vent_cap);
        }

        if (array_length(stamp_scars) < 34) {
          array_push(stamp_scars, {
            x : _sfx,
            w : _st_adv,
            life : 190,
            life_max : 190,
            color : _k_stamp_col_press,
            seed : random(1000)
          });
        }

        scr_add_light(_sfx, _k_stamp_floor_y - 90, _k_stamp_col_press, 2.2 + stamp_heat * 2);
      }

      if (_st_has_next || _st_hit_i + 1 < _st_n) {
        for (var _lb = 0; _lb < 2; _lb++) {
          var _lb_from = _st_seat[_lb];
          var _lb_to = stamp_face_at(_lb, _st_hit_i + 1);
          if (abs(_lb_to - _lb_from) < 1) continue;

          array_push(stamp_lock_frames, {
            side : _lb,
            x0 : min(_lb_from, _lb_to),
            x1 : max(_lb_from, _lb_to),
            life : _k_stamp_lock_life,
            life_max : _k_stamp_lock_life,
            hot : 0.9,
            seed : random(1000)
          });
        }
      }

      var _arc_n = _st_big ? 4 : 2;
      for (var _an = 0; _an < _arc_n; _an++) {
        if (array_length(stamp_arcs) >= 26) break;
        var _as = choose(0, 1);
        var _ax = stamp_face[_as];
        var _ay = random_range(_k_stamp_ceil_y + 40, _k_stamp_floor_y - 40);
        array_push(stamp_arcs, {
          x1 : _ax, y1 : _ay,
          x2 : _ax + random_range(-14, 14), y2 : _ay + random_range(70, 160),
          life : irandom_range(5, 11),
          life_max : 11,
          hot : _st_big ? 0.85 : 0.5,
          color : choose(global.avoid_col_cyan, _k_stamp_col_press, global.avoid_col_violet),
          off : scr_bolt_offsets(6, 8 + stamp_heat * 12)
        });
      }

      var _chip_n = _st_big ? 8 : 4;
      for (var _cn = 0; _cn < _chip_n; _cn++) {
        if (array_length(stamp_shards) >= _k_stamp_shard_cap) break;
        var _cs = choose(0, 1);
        array_push(stamp_shards, {
          x : stamp_face[_cs],
          y : random_range(_k_stamp_ceil_y, _k_stamp_floor_y),
          vx : ((_cs == 0) ? 1 : -1) * random_range(1.6, 4.6),
          vy : random_range(-2.6, 1.6),
          size : random_range(3, 8.5),
          rot : random(360),
          spin : random_range(-11, 11),
          life : irandom_range(28, 52),
          life_max : 52,
          color : choose(_k_stamp_col_frame, _k_stamp_col_edge, _k_stamp_col_press),
          hot : random_range(0.3, 0.9)
        });
      }

      for (var _ob = 0; _ob < array_length(stamp_orbs); _ob++) {
        if (stamp_orbs[_ob].crushed) continue;
        stamp_orbs[_ob].pulse = _st_big ? 1 : 0.6;
      }

      if (_st_big) {
        scr_impact_pulse(0.14, 0.26, 0.22, _k_stamp_mid_x, _k_stamp_floor_y - 60);
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, _k_stamp_shake_slam);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_stamp_zoom_slam);
          oCameraController.screen_flash_alpha =
            max(oCameraController.screen_flash_alpha, _k_stamp_flash_slam);
        }
        scr_floor_impact(stamp_face[0], _k_stamp_floor_y, 0.4 + stamp_heat * 0.45, -1,
                         _k_stamp_col_press);
        scr_floor_impact(stamp_face[1], _k_stamp_floor_y, 0.4 + stamp_heat * 0.45, -1,
                         _k_stamp_col_press);
      } else {
        scr_impact_pulse(0.07, 0.15, 0.11);
      }
    }

    if (timeline_hit(_k_stamp_t_arm)) {
      stamp_rail = 0;
      stamp_amb = 0.2;
      stamp_heat = 0;
      stamp_dead = false;
      stamp_blowout = 0;
      stamp_safe_glow = 0;
      stamp_safe_seal = 0;
      stamp_was_safe = false;
      stamp_face[0] = _k_stamp_x0;
      stamp_face[1] = _k_stamp_x1;
      stamp_face_target[0] = stamp_face_at(0, 1);
      stamp_face_target[1] = stamp_face_at(1, 1);
      stamp_face_heat[0] = 0;
      stamp_face_heat[1] = 0;
      stamp_lock_frames = [];
      stamp_vents = [];
      stamp_sparks = [];
      stamp_shards = [];
      stamp_scars = [];
      stamp_arcs = [];
      stamp_tips = [];

      if (variable_global_exists("debug_stamp_seed") && global.debug_stamp_seed != 0) {
        stamp_grid_seed = global.debug_stamp_seed;
      } else {
        stamp_grid_seed = irandom(999999);
      }
      stamp_build_grid(stamp_grid_seed);

      if (instance_exists(oPlayer)) {
        for (var _cl = array_length(stamp_orbs) - 1; _cl >= 0; _cl--) {
          var _cn = stamp_orbs[_cl];
          if (point_distance(_cn.x, _cn.y, oPlayer.x, oPlayer.y) < _k_stamp_spawn_clear) {
            array_delete(stamp_orbs, _cl, 1);
          }
        }

        stamp_ensure_floor_block(oPlayer.x, oPlayer.y);
      }

      for (var _mm = 0; _mm < 36; _mm++) {
        array_push(converge_motes, {
          cx : (_mm mod 2 == 0) ? _k_stamp_x0 : _k_stamp_x1,
          cy : random_range(_k_stamp_ceil_y + 30, _k_stamp_floor_y - 30),
          ang : random(360),
          dist : random_range(130, 340),
          dest : random_range(4, 24),
          speed : random_range(9, 17),
          size : random_range(0.16, 0.46),
          spin : random_range(-5, 5),
          hot : random_range(0.2, 0.7),
          feed : "stamp"
        });
      }

      if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = _k_stamp_letterbox;
      }
      scr_impact_pulse(0.2, 0.2, 0.25);

      if (instance_exists(oPlayer)) {
        if (abs(oPlayer.run_speed - _k_stamp_run_rate) > 0.01) {
          show_debug_message("STAMP: oPlayer.run_speed is " + string(oPlayer.run_speed)
                           + " but the slam schedule was walked against "
                           + string(_k_stamp_run_rate) + " — re-walk `_k_stamp_advance`");
        }

        var _pl_w = oPlayer.bbox_right - oPlayer.bbox_left + 1;
        var _pl_h = oPlayer.bbox_bottom - oPlayer.bbox_top + 1;

        if (_pl_w != _k_stamp_player_w || _pl_h != _k_stamp_player_h) {
          show_debug_message("STAMP: the player hitbox is " + string(_pl_w) + "x" + string(_pl_h)
                           + " but the lattice windows were cut for "
                           + string(_k_stamp_player_w) + "x" + string(_k_stamp_player_h));
        }

        var _need_lo = _k_stamp_floor_y - (stamp_grid_y(0) - _k_stamp_orb_r);
        var _need_hi = (_k_stamp_floor_y - (stamp_grid_y(1) + _k_stamp_orb_r)) - _pl_h;

        var _pl_g = max(0.0001, oPlayer.gravity_pull);
        var _pl_cut = oPlayer.jump_strength * oPlayer.yvelocity_fall;
        var _hop_min = _pl_cut * _pl_cut / (2 * _pl_g);
        var _hop_max = (oPlayer.jump_strength * oPlayer.jump_strength) / (2 * _pl_g);

        if (_need_hi <= _need_lo) {
          show_debug_message("STAMP: a THREAD column has NO legal apex — it wants a rise of "
                           + "at least " + string(_need_lo) + "px and at most "
                           + string(_need_hi) + "px");
        }
        if (_hop_min > _need_hi) {
          show_debug_message("STAMP: the smallest hop the player can make is "
                           + string(_hop_min) + "px but a THREAD column tops out at "
                           + string(_need_hi) + "px — every threaded column is a wall");
        }
        if (_hop_max < _need_lo) {
          show_debug_message("STAMP: a full jump rises " + string(_hop_max)
                           + "px but the floor row needs " + string(_need_lo)
                           + "px to clear — the lattice cannot be crossed");
        }

        show_debug_message("STAMP: THREAD apex band is " + string(_need_lo) + ".."
                         + string(_need_hi) + "px (" + string(_need_hi - _need_lo)
                         + "px of room); player hop range " + string(_hop_min) + ".."
                         + string(_hop_max) + "px");
      }
    }

    if (timeline_hit(_k_stamp_t_blowout)) {
      stamp_blowout = 1;
      stamp_slam_flash = 1.4;
      stamp_chroma = 1.2;
      stamp_face_heat[0] = 1.6;
      stamp_face_heat[1] = 1.6;

      for (var _bs = 0; _bs < 90; _bs++) {
        if (array_length(stamp_sparks) >= _k_stamp_spark_cap) break;
        var _bside = choose(0, 1);
        var _bsp = random_range(3.5, 11);
        var _bang = ((_bside == 0) ? 0 : 180) + random_range(-80, 80);
        array_push(stamp_sparks, {
          x : stamp_face[_bside],
          y : random_range(_k_stamp_ceil_y, _k_stamp_floor_y),
          vx : lengthdir_x(_bsp, _bang),
          vy : lengthdir_y(_bsp, _bang),
          life : irandom_range(18, 40),
          life_max : 40,
          size : random_range(1.2, 3.4),
          hot : random_range(0.5, 1),
          color : choose(c_white, global.avoid_col_warning, global.avoid_col_cyan)
        });
      }

      for (var _bo = 0; _bo < array_length(stamp_orbs); _bo++) {
        var _bn = stamp_orbs[_bo];
        if (_bn.crushed) continue;
        _bn.crushed = true;
        if (_bn.spawn < 0.5) continue;
        for (var _bsh = 0; _bsh < 3; _bsh++) {
          if (array_length(stamp_shards) >= _k_stamp_shard_cap) break;
          array_push(stamp_shards, {
            x : _bn.x, y : _bn.y,
            vx : random_range(-5, 5),
            vy : random_range(-5, 2),
            size : random_range(2.5, 6),
            rot : random(360),
            spin : random_range(-16, 16),
            life : irandom_range(26, 50),
            life_max : 50,
            color : choose(_k_stamp_col_frame, _k_stamp_col_edge, global.avoid_col_ember),
            hot : random_range(0.4, 1)
          });
        }
      }

      for (var _bv = 0; _bv < 26; _bv++) {
        var _bvs = choose(0, 1);
        scr_spawn_vent_stream(stamp_vents,
                              stamp_face[_bvs],
                              random_range(_k_stamp_ceil_y, _k_stamp_floor_y),
                              (_bvs == 0) ? 180 : 0,
                              0.85, _k_stamp_vent_cols, _k_stamp_vent_cap);
      }

      scr_impact_pulse(0.5, 0.8, 0.6, _k_stamp_mid_x, _k_stamp_floor_y - 80);
      scr_floor_impact(_k_stamp_mid_x, _k_stamp_floor_y, 1.0, 1, global.avoid_col_ember);
      tear_amount = max(tear_amount, 0.85);
      global_ripple_pulse = max(global_ripple_pulse, 0.8);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, _k_stamp_shake_blowout);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.11);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.2);
        oCameraController.letterbox_target = 0;
      }
    }

    if (stamp_blowout > 0) stamp_blowout = max(0, stamp_blowout - 0.016);

    for (var _fi = 0; _fi < 2; _fi++) {
      var _f_to = stamp_dead ? stamp_face_target[_fi] : _st_seat[_fi];
      stamp_face[_fi] = lerp(stamp_face[_fi], _f_to, _k_stamp_drive_rate);
      if (abs(stamp_face[_fi] - _f_to) < 0.15) stamp_face[_fi] = _f_to;
      stamp_face_heat[_fi] = max(stamp_face_heat[_fi] * 0.93,
                                 stamp_coil * 0.45 * stamp_amb);
    }

    if (stamp_live) {
      for (var _oi = 0; _oi < array_length(stamp_orbs); _oi++) {
        var _on = stamp_orbs[_oi];

        _on.pulse = max(0, _on.pulse - 0.06);
        if (_on.crushed) continue;

        var _age = t - (_k_stamp_t_arm + _on.delay);
        _on.spawn = clamp(_age / max(1, _k_stamp_orb_fade), 0, 1);

        var _eaten = (stamp_face[0] >= _on.x - _k_stamp_orb_r * 0.4) ||
                     (stamp_face[1] <= _on.x + _k_stamp_orb_r * 0.4);

        if (_eaten) {
          _on.crushed = true;

          for (var _cs2 = 0; _cs2 < 5; _cs2++) {
            if (array_length(stamp_sparks) >= _k_stamp_spark_cap) break;
            var _ca = random(360);
            var _cv = random_range(1.4, 4.6);
            array_push(stamp_sparks, {
              x : _on.x, y : _on.y,
              vx : lengthdir_x(_cv, _ca), vy : lengthdir_y(_cv, _ca),
              life : irandom_range(9, 20), life_max : 20,
              size : random_range(0.9, 2.2),
              hot : random_range(0.4, 1),
              color : choose(c_white, global.avoid_col_ember, global.avoid_col_cyan)
            });
          }
          for (var _cs3 = 0; _cs3 < 2; _cs3++) {
            if (array_length(stamp_shards) >= _k_stamp_shard_cap) break;
            array_push(stamp_shards, {
              x : _on.x, y : _on.y,
              vx : random_range(-3, 3),
              vy : random_range(-3.4, 0.6),
              size : random_range(2, 5),
              rot : random(360),
              spin : random_range(-14, 14),
              life : irandom_range(20, 40),
              life_max : 40,
              color : choose(_k_stamp_col_frame, _k_stamp_col_edge),
              hot : random_range(0.3, 0.8)
            });
          }
          continue;
        }

        var _near = min(abs(_on.x - stamp_face[0]), abs(_on.x - stamp_face[1]));
        var _fl = 1 - clamp(_near / _k_stamp_crush_warn, 0, 1);
        _on.flare = lerp(_on.flare, _fl, 0.16);
      }
    }

    if (stamp_armed && !stamp_dead && instance_exists(oPlayer)) {
      var _st_hurt = false;

      if (collision_rectangle(_k_stamp_x0 - 60, _k_stamp_ceil_y - 40,
                              stamp_face[0], _k_stamp_floor_y, oPlayer, false, true) != noone) {
        _st_hurt = true;
      }
      if (!_st_hurt &&
          collision_rectangle(stamp_face[1], _k_stamp_ceil_y - 40,
                              _k_stamp_x1 + 60, _k_stamp_floor_y, oPlayer, false, true) != noone) {
        _st_hurt = true;
      }

      if (!_st_hurt) {
        for (var _xi = 0; _xi < array_length(stamp_orbs); _xi++) {
          var _xn = stamp_orbs[_xi];
          if (_xn.crushed) continue;
          if (_xn.spawn < 1) continue;
          if (collision_circle(_xn.x, _xn.y, _k_stamp_orb_r, oPlayer, false, true) != noone) {
            _st_hurt = true;
            break;
          }
        }
      }

      if (_st_hurt) player_register_hazard_hit();

      stamp_player_safe = stamp_in_safe(oPlayer.x);
      if (stamp_player_safe && !stamp_was_safe) {
        stamp_safe_seal = 1;
        scr_impact_pulse(0.08, 0.1, 0.16, _k_stamp_mid_x, _k_stamp_floor_y - 40);
        scr_add_light(_k_stamp_mid_x, _k_stamp_floor_y - 60, _k_stamp_col_safe, 3);
        for (var _ss2 = 0; _ss2 < 14; _ss2++) {
          scr_spawn_vent_stream(stamp_vents,
                                choose(_k_stamp_safe_x0, _k_stamp_safe_x1),
                                random_range(_k_stamp_ceil_y + 60, _k_stamp_floor_y),
                                90, 0.7, _k_stamp_vent_cols, _k_stamp_vent_cap);
        }
      }
      stamp_was_safe = stamp_player_safe;
    }

    if (stamp_live && !stamp_dead) {
      if (stamp_coil > 0.3 && (t mod 2 == 0)) {
        var _rv = choose(0, 1);
        scr_spawn_vent_stream(stamp_vents,
                              stamp_face[_rv],
                              random_range(_k_stamp_ceil_y + 20, _k_stamp_floor_y - 10),
                              (_rv == 0) ? 0 : 180,
                              stamp_coil * 0.7, _k_stamp_vent_cols, _k_stamp_vent_cap);
      }

      if (stamp_coil > 0.5 && irandom(3) == 0 && array_length(stamp_arcs) < 26) {
        var _ai = choose(0, 1);
        var _a_from = stamp_face[_ai];
        var _a_to = stamp_face_target[_ai];
        var _ay2 = random_range(_k_stamp_ceil_y + 40, _k_stamp_floor_y - 20);
        array_push(stamp_arcs, {
          x1 : _a_from, y1 : _ay2,
          x2 : _a_to, y2 : _ay2 + random_range(-18, 18),
          life : irandom_range(4, 8),
          life_max : 8,
          hot : 0.35 + stamp_coil * 0.5,
          color : global.avoid_col_warning,
          off : scr_bolt_offsets(5, 7)
        });
      }
    }

    scr_update_vent_streams(stamp_vents);

    for (var _q1 = array_length(stamp_lock_frames) - 1; _q1 >= 0; _q1--) {
      stamp_lock_frames[_q1].life--;
      if (stamp_lock_frames[_q1].life <= 0) array_delete(stamp_lock_frames, _q1, 1);
    }

    for (var _q2 = array_length(stamp_tips) - 1; _q2 >= 0; _q2--) {
      stamp_tips[_q2].life--;
      if (stamp_tips[_q2].life <= 0) array_delete(stamp_tips, _q2, 1);
    }

    for (var _q3 = array_length(stamp_arcs) - 1; _q3 >= 0; _q3--) {
      stamp_arcs[_q3].life--;
      if (stamp_arcs[_q3].life <= 0) array_delete(stamp_arcs, _q3, 1);
    }

    for (var _q4 = array_length(stamp_sparks) - 1; _q4 >= 0; _q4--) {
      var _sk = stamp_sparks[_q4];
      _sk.x += _sk.vx;
      _sk.y += _sk.vy;
      _sk.vx *= 0.94;
      _sk.vy = _sk.vy * 0.94 + 0.16;
      _sk.life--;
      if (_sk.life <= 0) array_delete(stamp_sparks, _q4, 1);
    }

    for (var _q5 = array_length(stamp_shards) - 1; _q5 >= 0; _q5--) {
      var _sh = stamp_shards[_q5];
      _sh.x += _sh.vx;
      _sh.y += _sh.vy;
      _sh.vx *= 0.985;
      _sh.vy = _sh.vy * 0.985 + 0.19;
      _sh.rot += _sh.spin;
      _sh.spin *= 0.98;
      _sh.life--;
      if (_sh.life <= 0 || _sh.y > _k_stamp_floor_y + 40) array_delete(stamp_shards, _q5, 1);
    }

    for (var _q6 = array_length(stamp_scars) - 1; _q6 >= 0; _q6--) {
      stamp_scars[_q6].life--;
      if (stamp_scars[_q6].life <= 0) array_delete(stamp_scars, _q6, 1);
    }

    if (timeline_hit(_k_stamp_t_clear)) {
      stamp_lock_frames = [];
      stamp_arcs = [];
      stamp_tips = [];
      stamp_orbs = [];
      stamp_live = false;
      stamp_armed = false;
      stamp_player_safe = false;
      stamp_was_safe = false;
    }
  }
if
  true {
    for (var i = array_length(lorb_arcs) - 1; i >= 0; i--) {
      lorb_arcs[i].life--;
      if (lorb_arcs[i].life <= 0) array_delete(lorb_arcs, i, 1);
    }
    for (var i = array_length(lorb_floor_hits) - 1; i >= 0; i--) {
      lorb_floor_hits[i].life--;
      if (lorb_floor_hits[i].life <= 0) array_delete(lorb_floor_hits, i, 1);
    }
    for (var i = array_length(lorb_sky_rifts) - 1; i >= 0; i--) {
      lorb_sky_rifts[i].life--;
      if (lorb_sky_rifts[i].life <= 0) array_delete(lorb_sky_rifts, i, 1);
    }
    for (var i = array_length(lorb_impact_sparks) - 1; i >= 0; i--) {
      var _lsp = lorb_impact_sparks[i];
      _lsp.px = _lsp.x;
      _lsp.py = _lsp.y;
      _lsp.x += _lsp.vx;
      _lsp.y += _lsp.vy;
      _lsp.vx *= _lsp.drag;
      _lsp.vy = _lsp.vy * _lsp.drag + _lsp.grav;
      _lsp.life--;
      if (_lsp.life <= 0 || _lsp.y > _k_lorb_floor_y + 36) array_delete(lorb_impact_sparks, i, 1);
    }
    for (var i = array_length(lorb_seam_pulses) - 1; i >= 0; i--) {
      var _lpu = lorb_seam_pulses[i];
      _lpu.radius = lerp(_lpu.radius, _lpu.max_radius, 0.24);
      _lpu.life--;
      if (_lpu.life <= 0) array_delete(lorb_seam_pulses, i, 1);
    }
    for (var i = array_length(lorb_head_sparks) - 1; i >= 0; i--) {
      var _lhs = lorb_head_sparks[i];
      _lhs.px = _lhs.x;
      _lhs.py = _lhs.y;
      _lhs.x += _lhs.vx;
      _lhs.y += _lhs.vy;
      _lhs.vx *= _lhs.drag;
      _lhs.vy = _lhs.vy * _lhs.drag + _lhs.grav;
      _lhs.life--;
      if (_lhs.life <= 0) array_delete(lorb_head_sparks, i, 1);
    }
    for (var i = array_length(lorb_scars) - 1; i >= 0; i--) {
      lorb_scars[i].life--;
      if (lorb_scars[i].life <= 0) array_delete(lorb_scars, i, 1);
    }
    for (var i = array_length(lorb_wall_hits) - 1; i >= 0; i--) {
      var _lwh = lorb_wall_hits[i];
      _lwh.radius = lerp(_lwh.radius, _lwh.max_radius, 0.22);
      _lwh.life--;
      if (_lwh.life <= 0) array_delete(lorb_wall_hits, i, 1);
    }
    for (var i = array_length(lorb_drips) - 1; i >= 0; i--) {
      lorb_drips[i].life--;
      if (lorb_drips[i].life <= 0) array_delete(lorb_drips, i, 1);
    }
    for (var i = array_length(lorb_lead_bursts) - 1; i >= 0; i--) {
      var _llb = lorb_lead_bursts[i];
      _llb.radius = lerp(_llb.radius, _llb.max_radius, 0.26);
      _llb.life--;
      if (_llb.life <= 0) array_delete(lorb_lead_bursts, i, 1);
    }
    for (var i = array_length(lorb_strikes) - 1; i >= 0; i--) {
      lorb_strikes[i].life--;
      if (lorb_strikes[i].life <= 0) array_delete(lorb_strikes, i, 1);
    }
    lorb_strike_flash = max(0, lorb_strike_flash - 0.28);
    lorb_beat_flash = max(0, lorb_beat_flash - 0.07);
    lorb_lead_flash = max(0, lorb_lead_flash - 0.075);
    lorb_lead_spawn = max(0, lorb_lead_spawn - 0.07);
    lorb_lead_despawn = max(0, lorb_lead_despawn - 0.17);
    lorb_seam_flash = max(0, lorb_seam_flash - 0.045);
    lorb_seam = max(0, lorb_seam - 0.02);
    if (t < _k_lorb_telegraph_t || t >= _k_lorb_start_t) lorb_storm = max(0, lorb_storm - 0.012);

    lorb_eta = _k_lorb_slam_t - t;

    var _lo_active = (t >= _k_lorb_telegraph_t && t < _k_lorb_slam_t + 50);

    if (_lo_active) {
      lorb_countdown = clamp(1 - lorb_eta / (_k_lorb_slam_t - _k_lorb_telegraph_t), 0, 1);
    } else {
      lorb_countdown = max(0, lorb_countdown - 0.03);
    }

    var _lo_amb_target = 0;

    if (_lo_active) {
      _lo_amb_target = 0.30 + lorb_countdown * 0.58 + lorb_beat_flash * 0.24 +
                       clamp(lorb_seam, 0, 1) * 0.22;

      if (t > _k_lorb_slam_t) _lo_amb_target *= clamp(1 - (t - _k_lorb_slam_t) / 26, 0, 1);
    }

    lorb_amb = lerp(lorb_amb, _lo_amb_target, (_lo_amb_target > lorb_amb) ? 0.34 : 0.05);

    var _lo_urgency = power(lorb_countdown, 1.35);
    var _lo_hb_freq = lerp(0.09, 0.60, _lo_urgency) + clamp(lorb_seam, 0, 1) * 0.30;
    var _lo_hb_prev = lorb_amb_hb_phase;

    lorb_amb_hb_phase += _lo_hb_freq * (_lo_active ? 1 : 0);

    if (_lo_active && floor(lorb_amb_hb_phase / (2 * pi)) > floor(_lo_hb_prev / (2 * pi))) {
      lorb_amb_tick = 1;
    }

    lorb_amb_tick = max(0, lorb_amb_tick - 0.14);
    lorb_amb_hb = power((sin(lorb_amb_hb_phase) + 1) * 0.5, 3) * (0.24 + _lo_urgency * 0.72);
    lorb_gap_flash = max(0, lorb_gap_flash - 0.06);

    var _lo_fr = lorb_front_at(t);

    lorb_front_n = _lo_fr.n;
    lorb_front_a = _lo_fr.a;
    lorb_front_b = _lo_fr.b;
    lorb_front_ay = _lo_fr.ay;
    lorb_front_by = _lo_fr.by;
    lorb_front_parked = _lo_fr.parked;
    lorb_front_dir = _lo_fr.dir;
    lorb_front_speed = _lo_fr.speed;
    lorb_front_beat = _lo_fr.beat;
    lorb_front_live = (_lo_fr.n > 0);
    lorb_lead_phase += (lorb_front_live ? (0.25 + lorb_countdown * 0.24 + lorb_lead_flash * 0.18) : 0.05);

    if (lorb_front_live) {
      var _lead_hot = clamp(0.42 + lorb_countdown * 0.42 + lorb_beat_flash * 0.32 +
                            ((lorb_front_beat >= 4) ? 0.2 : 0), 0, 1.35);

      var _st_hot = clamp(0.45 + lorb_countdown * 0.45 + lorb_beat_flash * 0.3 +
                          lorb_front_beat * 0.06, 0, 1.4);
      var _st_fired = false;

      for (var _sh = 0; _sh < lorb_front_n; _sh++) {
        var _st_now = lorb_stamp_f(t, _sh);
        var _st_was = lorb_stamp_f(t - 1, _sh);

        if (_st_now != _st_was) {
          var _st_a = lorb_head_at(_st_was, _sh);
          var _st_b = lorb_head_at(_st_now, _sh);

          lorb_push_strike(_st_a.x, _st_a.y, _st_b.x, _st_b.y, _st_hot, true);
          _st_fired = true;

          var _st_kick = random_range(40, 110 + lorb_countdown * 80);
          var _st_ang = point_direction(_st_a.x, _st_a.y, _st_b.x, _st_b.y) +
                        choose(-1, 1) * random_range(50, 130);

          lorb_push_strike(_st_b.x, _st_b.y,
                           _st_b.x + lengthdir_x(_st_kick, _st_ang),
                           _st_b.y + lengthdir_y(_st_kick, _st_ang),
                           _st_hot * 0.85, false);
        } else {
          var _rt = lorb_head_at(_st_now, _sh);
          var _rt_ang = random(360);
          var _rt_len = random_range(24, 74 + lorb_countdown * 60);

          lorb_push_strike(_rt.x, _rt.y,
                           _rt.x + lengthdir_x(_rt_len, _rt_ang),
                           _rt.y + lengthdir_y(_rt_len, _rt_ang),
                           _st_hot * 0.55, false);
        }
      }

      if (_st_fired) {
        lorb_strike_flash = 1;
        lightning_bloom_boost += 0.22;

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 1.8 + lorb_countdown * 3.2);
        }
      }

      if (_lo_fr.parked) {
        lorb_park = min(1, _lo_fr.park_p);
        lightning_bloom_boost += lorb_park * 0.2;

        if (t mod 2 == 0) {
          lorb_push_head_spark(lorb_front_a, lorb_front_ay,
                               lengthdir_x(random_range(1.2, 3.5), random(360)),
                               lengthdir_y(random_range(1.2, 3.5), random(360)),
                               0.5 + lorb_park * 0.6);
        }
      } else {
        lorb_park = 0;
      }

      var _spark_dir = point_direction(0, 0, _lo_fr.vx, _lo_fr.vy) + 180;
      var _spark_n = 2 + irandom(2 + round(lorb_countdown * 3));

      for (var _hs = 0; _hs < _spark_n; _hs++) {
        var _hsa = _spark_dir + random_range(-52, 52);
        var _hss = random_range(1.4, 3.2 + _lo_fr.speed * 0.06);

        lorb_push_head_spark(lorb_front_a + random_range(-5, 5), lorb_front_ay + random_range(-5, 5),
                             lengthdir_x(_hss, _hsa), lengthdir_y(_hss, _hsa), _lead_hot);
      }

      if (lorb_front_n > 1) {
        var _spark_dir2 = point_direction(0, 0, -_lo_fr.vx, _lo_fr.vy) + 180;

        for (var _hs2 = 0; _hs2 < _spark_n; _hs2++) {
          var _hsa2 = _spark_dir2 + random_range(-52, 52);
          var _hss2 = random_range(1.4, 3.2 + _lo_fr.speed * 0.06);

          lorb_push_head_spark(lorb_front_b + random_range(-5, 5),
                               lorb_front_by + random_range(-5, 5),
                               lengthdir_x(_hss2, _hsa2), lengthdir_y(_hss2, _hsa2),
                               min(1.45, _lead_hot + 0.18));
        }
      }

      if (t mod 5 == 0 && lorb_amb > 0.25) {
        lorb_push_sky_rift(lorb_front_a + random_range(-20, 20), _lead_hot,
                           random_range(150, 290 + lorb_countdown * 90));

        if (lorb_front_n > 1) {
          lorb_push_sky_rift(lorb_front_b + random_range(-20, 20), _lead_hot,
                             random_range(170, 330 + lorb_countdown * 100));
        }
      }
    }

    var _lo_read_target = (t >= _k_lorb_telegraph_t + 12 && t < _k_lorb_beats[3]) ? 1 : 0;
    lorb_readout = lerp(lorb_readout, _lo_read_target, (_lo_read_target > lorb_readout) ? 0.16 : 0.10);

    if (_lo_active) {
      var _lo_first = t + ((_k_lorb_col_every - (t mod _k_lorb_col_every)) mod _k_lorb_col_every);
      if (_lo_first <= t) _lo_first += _k_lorb_col_every;

      for (var _lf = _lo_first; _lf <= t + _k_lorb_mark_lead; _lf += _k_lorb_col_every) {
        var _lb = lorb_beat_at(_lf);
        if (_lb < 0) continue;

        var _lexists = false;

        for (var _lm = 0; _lm < array_length(lorb_col_marks); _lm++) {
          if (lorb_col_marks[_lm].spawn_t == _lf) { _lexists = true; break; }
        }

        if (_lexists) continue;
        if (array_length(lorb_col_marks) >= _k_lorb_max_marks) array_delete(lorb_col_marks, 0, 1);

        var _lfr = lorb_front_at(_lf);
        var _lban = ((_lf mod 8) == 0);

        array_push(lorb_col_marks, {
          sx : _lfr.a,
          sx2 : (_lfr.n > 1) ? _lfr.b : -1,
          band : _lfr.jitter,
          banded : _lban,
          spawn_t : _lf,
          life : _lf - t,
          max_life : max(1, _lf - t),
          beat : _lb,
          seed : random(1000)
        });
      }
    }

    for (var i = array_length(lorb_col_marks) - 1; i >= 0; i--) {
      lorb_col_marks[i].life = lorb_col_marks[i].spawn_t - t;
      if (lorb_col_marks[i].life <= 0) array_delete(lorb_col_marks, i, 1);
    }

    for (var i = array_length(lorb_columns) - 1; i >= 0; i--) {
      if (t >= lorb_columns[i].land_t) lorb_columns[i].landed = true;
      if (t > lorb_columns[i].land_t + 8) array_delete(lorb_columns, i, 1);
    }

    if (lorb_readout > 0.02) {
      var _lo_xs = [];

      for (var i = 0; i < array_length(lorb_columns); i++) {
        var _lc = lorb_columns[i];
        if (_lc.landed) continue;

        var _lcf = clamp((t - _lc.spawn_t) / max(_lc.fall, 1), 0, 1);
        if (_lcf < 0.3) continue;

        array_push(_lo_xs, _lc.sx - (_lc.banded ? _lc.band : 0));
        array_push(_lo_xs, _lc.sx + (_lc.banded ? _lc.band : 0));
      }

      array_push(_lo_xs, _k_lorb_pad);
      array_push(_lo_xs, room_width - _k_lorb_pad);
      array_sort(_lo_xs, true);

      var _lo_bw = -1;
      var _lo_bc = lorb_gap_x;

      for (var i = 0; i < array_length(_lo_xs) - 1; i++) {
        var _lw = _lo_xs[i + 1] - _lo_xs[i];
        if (_lw > _lo_bw) {
          _lo_bw = _lw;
          _lo_bc = (_lo_xs[i] + _lo_xs[i + 1]) * 0.5;
        }
      }

      lorb_gap_w = max(0, _lo_bw);

      if (abs(_lo_bc - lorb_gap_x) > 40) lorb_gap_flash = 1;

      lorb_gap_x = _lo_bc;
    } else {
      lorb_gap_w = max(0, lorb_gap_w - 6);
    }

    lorb_gap_x_draw += (lorb_gap_x - lorb_gap_x_draw) * 0.2;

    if (lorb_front_live && lorb_amb > 0.3 && irandom(max(3, round(20 - lorb_countdown * 14))) == 0) {
      if (array_length(lorb_floor_crack) < _k_lorb_max_crack) {
        array_push(lorb_floor_crack, {
          x : lorb_front_a + random_range(-30, 30),
          life : 6, life_max : 6,
          len : random_range(24, 64),
          dir : choose(-1, 1)
        });
      }
    }

    for (var i = array_length(lorb_floor_crack) - 1; i >= 0; i--) {
      lorb_floor_crack[i].life--;
      if (lorb_floor_crack[i].life <= 0) array_delete(lorb_floor_crack, i, 1);
    }

    for (var i = array_length(lorb_scorch) - 1; i >= 0; i--) {
      lorb_scorch[i].alpha -= 0.0024;
      if (lorb_scorch[i].alpha <= 0) array_delete(lorb_scorch, i, 1);
    }

    for (var i = 0; i < array_length(lorb_floor_hits); i++) {
      lorb_floor_hits[i].radius = lerp(lorb_floor_hits[i].radius, lorb_floor_hits[i].max_radius, 0.26);
    }

    if (_lo_active) {
      vignette_pulse = max(vignette_pulse, lorb_amb_hb * 0.34);
      bloom_pulse = max(bloom_pulse, lorb_amb_hb * 0.24);
    }

    if (t >= _k_lorb_telegraph_t && t < _k_lorb_start_t) {
      lorb_storm = clamp((t - _k_lorb_telegraph_t) / (_k_lorb_start_t - _k_lorb_telegraph_t), 0, 1);

      if (timeline_hit(_k_lorb_telegraph_t)) {
        lorb_arcs = [];
        lorb_floor_hits = [];
        lorb_sky_rifts = [];
        lorb_impact_sparks = [];
        lorb_seam_pulses = [];
        lorb_strikes = [];
        lorb_strike_flash = 0;
        lorb_seed = irandom(99999);
        lorb_head_sparks = [];
        lorb_scars = [];
        lorb_wall_hits = [];
        lorb_drips = [];
        lorb_lead_bursts = [];
        lorb_lead_flash = 0;
        lorb_lead_phase = 0;
        lorb_lead_spawn = 0;
        lorb_lead_despawn = 0;
        if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0.7;
      }

      if (irandom(max(1, round(lerp(6, 1, lorb_storm)))) == 0) {
        var _cx1 = random_range(-40, room_width);
        var _clen = random_range(70, 130 + lorb_storm * 190);
        array_push(lorb_arcs, {
          x1 : _cx1,
          y1 : random_range(2, 16 + lorb_storm * 26),
          x2 : _cx1 + _clen,
          y2 : random_range(2, 16 + lorb_storm * 26),
          life : 5 + irandom(4),
          max_life : 9,
          hot : 0.3 + lorb_storm * 0.6,
          width : 0.7 + lorb_storm * 1.3,
          off : scr_bolt_offsets(5, 5 + lorb_storm * 16)
        });
      }

      var _rift_step = max(2, round(lerp(5, 2, lorb_storm)));
      if (t mod _rift_step == 0) {
        lorb_push_sky_rift(random_range(20, room_width - 20), 0.35 + lorb_storm * 0.65,
                           random_range(110, 220 + lorb_storm * 130));
      }

      var _storm_beat = round(lerp(9, 3, lorb_storm));
      if (t mod _storm_beat == 0) {
        vignette_pulse = max(vignette_pulse, 0.15 + lorb_storm * 0.45);
        bloom_pulse = max(bloom_pulse, 0.1 + lorb_storm * 0.3);
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 1 + lorb_storm * 4);
        }
      }
    }

    var _lo_end_t = _k_lorb_beats[array_length(_k_lorb_beats) - 1] +
                    _k_lorb_durations[array_length(_k_lorb_durations) - 1];

    if (t >= _k_lorb_start_t && t < _lo_end_t) {
      var _beats = _k_lorb_beats;
      var _durations = _k_lorb_durations;

      if (timeline_hit(_k_lorb_start_t)) {
        chain2_last_orb = noone;
        lorb_storm = 1;
        lorb_lead_spawn = 1;
        lorb_lead_despawn = 0;
        lorb_lead_flash = 1;
        lorb_lead_exit_x = 0;
        lorb_lead_exit_y = lorb_lead_y_at(_k_lorb_start_t, 0);
        lorb_push_lead_burst(0, lorb_lead_exit_y, 1, 1.05);
        lorb_push_sky_rift(24, 0.95, 330);
        if (instance_exists(oCameraController)) {
          oCameraController.letterbox_target = 0.25;
          oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.3);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.1);
        }
        global_ripple_pulse = max(global_ripple_pulse, 0.6);
      }

      lorb_heat = clamp((t - _k_lorb_start_t) / (_lo_end_t - _k_lorb_start_t), 0, 1);

      if (irandom(max(1, round(lerp(5, 1, lorb_heat)))) == 0) {
        var _web_list = [];
        with(oRedOrb_2) { array_push(_web_list, id); }

        var _web_n = array_length(_web_list);
        if (_web_n > 1) {
          var _web_a = _web_list[irandom(_web_n - 1)];
          var _web_b = noone;
          var _web_best = 240 + lorb_heat * 130;

          for (var _wi = 0; _wi < _web_n; _wi++) {
            var _wc = _web_list[_wi];
            if (_wc == _web_a) continue;
            var _wd = point_distance(_wc.x, _wc.y, _web_a.x, _web_a.y);
            if (_wd < _web_best) {
              _web_best = _wd;
              _web_b = _wc;
            }
          }

          if (_web_b != noone && instance_exists(_web_b)) {
            array_push(lorb_arcs, {
              x1 : _web_a.x, y1 : _web_a.y,
              x2 : _web_b.x, y2 : _web_b.y,
              life : 4,
              max_life : 4,
              hot : 0.4 + lorb_heat * 0.6,
              width : 0.6 + lorb_heat * 1.1,
              off : scr_bolt_offsets(4, 7 + lorb_heat * 14)
            });
          }
        }
      }

      for (var _wb = 0; _wb < array_length(_beats) - 1; _wb++) {
        if (!timeline_hit(_beats[_wb] + _durations[_wb])) continue;

        var _wall_hot = clamp(0.6 + _wb * 0.12, 0, 1.4);
        var _wall_end = _beats[_wb] + _durations[_wb] - 0.001;
        var _wall_p = lorb_head_at(_wall_end, 0);
        var _wall_dir = ((_wb mod 2) == 0) ? -1 : 1;

        lorb_push_wall_hit(_wall_p.x, _wall_p.y, _wall_dir, _wall_hot);
        lorb_push_impact_sparks(_wall_p.x + _wall_dir * 6, _wall_p.y, _wall_hot,
                                8 + round(_wall_hot * 10));
        scr_add_light(_wall_p.x, _wall_p.y,
                      merge_color(global.lightning_color, c_white, 0.5), 2.2 + _wb * 0.4);

        if (_k_lorb_heads[_wb] > 1) {
          var _wall_p2 = lorb_head_at(_wall_end, 1);
          lorb_push_wall_hit(_wall_p2.x, _wall_p2.y, -_wall_dir, _wall_hot);
          lorb_push_impact_sparks(_wall_p2.x - _wall_dir * 6, _wall_p2.y, _wall_hot,
                                  8 + round(_wall_hot * 10));
        }

        lorb_push_scar(_beats[_wb], _beats[_wb] + _durations[_wb], 0,
                       clamp(0.45 + _wb * 0.13, 0, 1.2));

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 5 + _wb * 2);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05 + _wb * 0.02);
        }

        aberration_pulse = max(aberration_pulse, 0.35 + _wb * 0.15);
      }

      for (var b = 0; b < array_length(_beats); b++) {
        var _beat_t = _beats[b];
        var _dur = _durations[b];

        if (t >= _beat_t && t < _beat_t + _dur) {
          if (timeline_hit(_beat_t)) {
            lorb_beat_flash = 1;
            lorb_lead_flash = 1;

            var _lead_beat = lorb_front_at(_beat_t + 1);
            var _lead_burst_hot = clamp(0.62 + b * 0.13, 0, 1.45);
            var _lead_burst_y = lorb_lead_y_at(_beat_t + 1, 0);

            if (_lead_beat.n > 0) {
              lorb_push_lead_burst(_lead_beat.a, _lead_burst_y, _lead_beat.dir, _lead_burst_hot);
              scr_add_light(_lead_beat.a, _lead_burst_y, merge_color(global.lightning_color, c_white, 0.45),
                            1.9 + b * 0.45);

              if (_lead_beat.n > 1) {
                var _lead_burst_y2 = lorb_lead_y_at(_beat_t + 1, 1);
                lorb_push_lead_burst(_lead_beat.b, _lead_burst_y2, -1, min(1.5, _lead_burst_hot + 0.2));
                scr_add_light(_lead_beat.b, _lead_burst_y2, merge_color(global.lightning_color, c_white, 0.55),
                              2.5 + b * 0.5);
              }
            }

            if (b == 4) {
              lorb_push_lead_burst(400, 108, 1, 1.5);
              lorb_push_lead_burst(400, 108, -1, 1.5);
            }

            if (instance_exists(oCameraController)) {
              var _shake_amt = (b < 4) ? (4 + b * 2) : 16;
              oCameraController.shake = max(oCameraController.shake, _shake_amt);
              oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.03 + b * 0.02);
              if (b == 3) oCameraController.letterbox_target = 0.75;
              if (b == 4) oCameraController.letterbox_target = 1;
            }

            aberration_pulse = max(aberration_pulse, 0.3 + b * 0.2);
            vignette_pulse = max(vignette_pulse, 0.2 + b * 0.14);

            for (var _rf = 0; _rf < 2 + min(b, 3); _rf++) {
              lorb_push_sky_rift(random_range(24, room_width - 24), 0.48 + b * 0.12,
                                 random_range(170, 310 + b * 18));
            }

            if (b >= 3) {
              lorb_push_seam_pulse(0.65 + b * 0.12);
              scr_add_light(400, 120, merge_color(global.lightning_color, c_white, 0.55), 3 + b);
            }

            if (b >= 3) {
              for (var _ci = 0; _ci < 34; _ci++) {
                var _cy2 = random_range(0, 250);
                array_push(converge_motes, {
                  cx : 400, cy : _cy2,
                  ang : choose(0, 180) + random_range(-22, 22),
                  dist : random_range(160, 420),
                  dest : random_range(2, 20),
                  speed : random_range(10, 22),
                  size : random_range(0.15, 0.5),
                  spin : random_range(-2, 2),
                  hot : 0.4 + b * 0.15,
                  feed : "seam"
                });
              }
            }
          }

          var _progress = (t - _beat_t) / _dur;
          var _escalation = b / 3;

          var _chain_col = merge_color(global.lightning_color, c_white, min(_escalation, 1));

          var _orb_every = _k_lorb_orb_every_stamp[b];

          var _jitter = (b < 4) ? lerp(40, 15, _escalation) : 12;
          var _gravity = (b < 4) ? lerp(0.5, 1.0, _escalation) : 1.1;

          if (b >= 4) lorb_seam = max(lorb_seam, 0.35 + _progress * 0.9);

          if (t mod 2 == 0) {
            if (b >= 4) {
              array_push(lorb_arcs, {
                x1 : _lo_fr.a, y1 : _lo_fr.ay,
                x2 : _lo_fr.b, y2 : _lo_fr.by,
                life : 4,
                max_life : 4,
                hot : 0.5 + _progress * 0.5,
                width : 0.9 + _progress * 1.6,
                off : scr_bolt_offsets(6, 14 + _progress * 26)
              });
            } else {
              for (var _ah = 0; _ah < _lo_fr.n; _ah++) {
                var _ahx = (_ah == 0) ? _lo_fr.a : _lo_fr.b;
                var _ahy = (_ah == 0) ? _lo_fr.ay : _lo_fr.by;

                array_push(lorb_arcs, {
                  x1 : _ahx, y1 : _ahy,
                  x2 : _ahx + random_range(-40, 40) - _lo_fr.vx * 0.3,
                  y2 : _ahy + random_range(70, 160),
                  life : 4,
                  max_life : 4,
                  hot : 0.45 + _escalation * 0.5,
                  width : 0.7 + _escalation * 0.9,
                  off : scr_bolt_offsets(5, 12 + _escalation * 18)
                });
              }
            }
          }

          for (var _hd = 0; _hd < _lo_fr.n; _hd++) {
            var _hx = (_hd == 0) ? _lo_fr.a : _lo_fr.b;
            var _hy = (_hd == 0) ? _lo_fr.ay : _lo_fr.by;

            var _sf_now = lorb_stamp_f(t, _hd);
            if (_sf_now == lorb_stamp_f(t - 1, _hd)) continue;

            var _stamp_i = lorb_stamp_index(t, _hd);
            if ((_stamp_i mod _orb_every) != 0) continue;

            var _banded = ((_stamp_i mod 3) == 0);
            var _pop_flash = (b >= 4) ? (0.65 + _escalation * 0.25) : (0.45 + _escalation * 0.18);

            var _sp_y = clamp(_hy + random_range(-10, 34), 6, _k_lorb_spawn_band);

            lorb_push_drip(_hx, _hy, 0.55 + _escalation * 0.5);

            with (instance_create_layer(_hx, _sp_y, layer, oRedOrb_2)) {
              gravity = _gravity;
              orb_pop_scale = (oAvoidanceController.lorb_front_beat >= 4) ? 1.8 : 1.6;
              orb_pop_target = 1.0;
              image_xscale = 1.0;
              image_yscale = 1.0;
              spark_glow = true;
              image_blend = _chain_col;
              trail = true;
              orb_pop_flash = max(orb_pop_flash, _pop_flash + 0.1);
              chain_prev_orb = oAvoidanceController.chain2_last_orb;
              chain_line_life = chain_line_life_max;
              chain_color = _chain_col;
              chain_jag = 4 + round(_escalation * 5);
              oAvoidanceController.chain2_last_orb = id;

              if (chain_prev_orb != noone) {
                scr_energize_bullet(id, _chain_col);
                scr_energize_bullet(chain_prev_orb, _chain_col);
              }
            }

            lorb_push_column(_hx, _sp_y, _gravity, _jitter, _banded, b);

            scr_impact_pulse(0.3, 2.0, 0.2);
          }

          if (b >= 4) {
            if (timeline_hit(_beat_t + _dur - 1)) {
              convergence_flash_active = true;
              convergence_flash_timer = 0;
              lorb_push_scar(_beat_t, _beat_t + _dur, 0, 1.2);
              lorb_push_scar(_beat_t, _beat_t + _dur, 1, 1.2);
              lorb_seam = 1.6;
              lorb_seam_flash = 1;
              lorb_lead_despawn = 1;
              lorb_lead_spawn = 0;
              lorb_lead_flash = 1.25;
              lorb_lead_exit_x = 400;
              lorb_lead_exit_y = 108;
              lorb_push_lead_burst(400, 108, 1, 1.5);
              lorb_push_lead_burst(400, 108, -1, 1.5);

              if (instance_exists(oCameraController)) {
                oCameraController.shake = max(oCameraController.shake, 24);
                oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.24);
                oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
                oCameraController.letterbox_target = 0;
                oCameraController.angle_kick = choose(-1, 1) * 4;
              }

              vignette_pulse = max(vignette_pulse, 1);
              bloom_pulse = max(bloom_pulse, 1);
              aberration_pulse = max(aberration_pulse, 1.4);
              global_ripple_pulse = max(global_ripple_pulse, 1);
              tear_amount = max(tear_amount, 1);

              for (var _spu = 0; _spu < 4; _spu++) {
                lorb_push_seam_pulse(1);
                lorb_push_sky_rift(400 + random_range(-60, 60), 1, random_range(280, 420));
              }

              array_push(ring_bursts, {
                x : 400, y : 125, tier : 0, color : c_white, num : 0, offset : 0,
                life : 42,
                shockwave_radius : 8,
                shockwave_max_radius : 340,
                shockwave_alpha_start : 0.9,
                shockwave_alpha : 0.9
              });

              array_push(ring_shockwaves, {
                x : 400, y : 125, vs : 1,
                radius : 8, max_radius : 400,
                life : 30, max_life : 30, width : 20, hot : 1
              });

              for (var _sb = 0; _sb < 10; _sb++) {
                var _sy1 = random_range(-20, 260);
                array_push(lorb_arcs, {
                  x1 : 400 + random_range(-14, 14), y1 : _sy1,
                  x2 : 400 + random_range(-14, 14), y2 : _sy1 + random_range(90, 260),
                  life : 14,
                  max_life : 14,
                  hot : 1,
                  width : 1.8,
                  off : scr_bolt_offsets(6, 22)
                });
              }

              for (var _sb = 0; _sb < 14; _sb++) {
                var _sa2 = _sb * (360 / 14) + random_range(-9, 9);
                var _sl2 = random_range(120, 280);
                array_push(lorb_arcs, {
                  x1 : 400, y1 : 125,
                  x2 : 400 + lengthdir_x(_sl2, _sa2),
                  y2 : 125 + lengthdir_y(_sl2, _sa2),
                  life : 12,
                  max_life : 12,
                  hot : 1,
                  width : 1.6,
                  off : scr_bolt_offsets(5, 24)
                });
              }

              for (var _sp2 = 0; _sp2 < 60; _sp2++) {
                var _spa = random(360);
                var _sps = random_range(4, 15);
                array_push(arrow_ring_particles, {
                  x : 400, y : 125,
                  vx : lengthdir_x(_sps, _spa),
                  vy : lengthdir_y(_sps, _spa),
                  life : 20 + irandom(18),
                  max_life : 38,
                  size : random_range(0.12, 0.36),
                  grav : 0.14,
                  drag : 0.945,
                  hot : 0.9
                });
              }

              for (var _ss = 0; _ss < 34; _ss++) {
                array_push(ring_streaks, {
                  cx : 400, cy : 125, vs : 1,
                  ang : random(360),
                  dist : random_range(0, 30),
                  len : 60 + irandom(130),
                  speed : 24 + random(14),
                  width : 2 + random(2.5),
                  life : 18,
                  max_life : 18,
                  hot : 1
                });
              }
            }
          }

          break;
        }
      }
    }

    if (t >= _k_lorb_start_t && t < 1330) {
      var _floor_y = _k_lorb_floor_y;

      with(oRedOrb_2) {
        if (lorb_floor_done) {
          image_alpha = max(0, image_alpha - 0.14);
          continue;
        }

        if (y < _floor_y || vspeed <= 0) continue;

        lorb_floor_done = true;
        hit_active = false;

        var _land_x = x;
        var _land_hot = 0.4 + oAvoidanceController.lorb_countdown * 0.6;

        with (oAvoidanceController) { lorb_land_orb(_land_x, _land_hot); }

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 1.5);
        }
      }
    }
  }
if
  true {
    if (timeline_hit(1286) && !bassline_text_created) {
      bassline_text_created = true;
      bass_text_particles = [];
      bass_text_rings = [];
      bass_text_cracks = [];
      bass_text_crack_flash = 0;
      bass_text_arcs = [];
      bass_text_seams = [];
      bass_text_shards = [];
      bass_text_scar = [];
      bass_text_heat = 0;
      bass_text_core_charge = 0;
      bass_text_freeze = 0;
      bass_text_pulse_timer = 0;
      bass_text_pulse_index = 0;

      bassline_text_points = scr_generate_text_points("Bassline Crack", room_width / 2, room_height / 2, fAvoidance, 5);

      for (var i = 0; i < array_length(bassline_text_points); i++) {
        bassline_text_points[i].scale = 0;
        bassline_text_points[i].draw_scale = 0;
        bassline_text_points[i].phase = random(360);
        bassline_text_points[i].rotation = 0;
        bassline_text_points[i].rot_speed = 0;
        bassline_text_points[i].suck_amount = 0;
        bassline_text_points[i].shard = 0;
        bassline_text_points[i].rel_dist = 0;
        bassline_text_points[i].rel_dir = 0;
      }

      var _tmin_x = infinity, _tmax_x = -infinity, _tmin_y = infinity, _tmax_y = -infinity;
      for (var i = 0; i < array_length(bassline_text_points); i++) {
        _tmin_x = min(_tmin_x, bassline_text_points[i].x);
        _tmax_x = max(_tmax_x, bassline_text_points[i].x);
        _tmin_y = min(_tmin_y, bassline_text_points[i].y);
        _tmax_y = max(_tmax_y, bassline_text_points[i].y);
      }
      var _word_w = max(_tmax_x - _tmin_x, 1);
      var _word_h = max(_tmax_y - _tmin_y, 1);
      var _word_cx = (_tmin_x + _tmax_x) * 0.5;
      var _word_cy = (_tmin_y + _tmax_y) * 0.5;
      bass_text_word_cx = _word_cx;
      bass_text_word_cy = _word_cy;
      bass_text_word_w = _word_w;
      bass_text_word_h = _word_h;

      var _seam_span = point_distance(0, 0, _word_w, _word_h);
      for (var s = 0; s < _k_bass_text_seam_count; s++) {
        var _seam_ang = choose(1, -1) * random_range(52, 118);
        var _kinks = [];
        for (var _kk = 0; _kk < 4; _kk++) array_push(_kinks, random_range(-7, 7));

        array_push(bass_text_seams, {
          x : _word_cx + random_range(-_word_w * 0.46, _word_w * 0.46),
          y : _word_cy + random_range(-_word_h * 0.35, _word_h * 0.35),
          ang : _seam_ang,
          nx : lengthdir_x(1, _seam_ang + 90),
          ny : lengthdir_y(1, _seam_ang + 90),
          span : _seam_span * 0.62,
          kinks : _kinks,
          grow : 0,
          start_t : _k_bass_text_seam_start_t + (s / max(_k_bass_text_seam_count - 1, 1)) * 14
        });
      }

      var _shard_lookup = {};
      for (var i = 0; i < array_length(bassline_text_points); i++) {
        var _pt = bassline_text_points[i];
        var _mask = "";
        for (var s = 0; s < array_length(bass_text_seams); s++) {
          var _sm = bass_text_seams[s];
          var _side = ((_pt.x - _sm.x) * _sm.nx + (_pt.y - _sm.y) * _sm.ny) > 0;
          _mask += _side ? "1" : "0";
        }

        if (!variable_struct_exists(_shard_lookup, _mask)) {
          _shard_lookup[$ _mask] = array_length(bass_text_shards);
          array_push(bass_text_shards, {
            cx : 0, cy : 0, n : 0,
            cx_off : 0, cy_off : 0,
            vx : 0, vy : 0,
            rot : 0, rot_speed : 0,
            drift_ang : 0, drift : random_range(0.5, 1.4),
            delay : 0, released : false
          });
        }

        var _si = _shard_lookup[$ _mask];
        _pt.shard = _si;
        var _sh = bass_text_shards[_si];
        _sh.cx += _pt.x;
        _sh.cy += _pt.y;
        _sh.n += 1;
      }

      for (var s = 0; s < array_length(bass_text_shards); s++) {
        var _sh = bass_text_shards[s];
        _sh.cx /= max(_sh.n, 1);
        _sh.cy /= max(_sh.n, 1);
        _sh.drift_ang = point_direction(_word_cx, _word_cy, _sh.cx, _sh.cy) + random_range(-25, 25);
        _sh.rot_speed = random_range(-2.2, 2.2);
      }

      for (var i = 0; i < 110; i++) {
        var _ang = random(360);
        var _dist = random_range(260, 560);

        array_push(bass_text_particles, {
          x : _word_cx + lengthdir_x(_dist, _ang),
          y : _word_cy + lengthdir_y(_dist, _ang),
          prev_x : 0, prev_y : 0,
          tx : _word_cx, ty : _word_cy,
          speed : random_range(0.018, 0.045),
          alpha : random_range(0.2, 0.8),
          size : random_range(0.3, 1),
          hot : random_range(0.1, 0.6)
        });
        bass_text_particles[i].prev_x = bass_text_particles[i].x;
        bass_text_particles[i].prev_y = bass_text_particles[i].y;
      }

      var _center_x = room_width / 2;
      for (var i = 0; i < array_length(bassline_text_points); i++) {
        bassline_text_points[i].dist = abs(bassline_text_points[i].x - _center_x);
      }

      array_sort(bassline_text_points, function(_a, _b) { return _a.dist - _b.dist; });

      var _count = array_length(bassline_text_points);
      var _window = _k_bass_text_cut_t - 1286;
      for (var i = 0; i < _count; i++) {
        bassline_text_points[i].reveal_t = 1286 + (i / max(_count - 1, 1)) * _window * 0.35;
      }

      var _full_reveal_time = 1286 + _window * 0.35;
      var _color_sweep_duration = 20;
      for (var i = 0; i < _count; i++) {
        bassline_text_points[i].color_start_t = _full_reveal_time + (i / max(_count - 1, 1)) * _color_sweep_duration;
      }
    }

    if (bassline_text_created && t >= 1286 && t < _k_bass_text_cut_t) {
      bass_text_heat = clamp((t - 1286) / max(_k_bass_text_cut_t - 1286, 1), 0, 1);

      var _word_cx = bass_text_word_cx;
      var _word_cy = bass_text_word_cy;

      for (var i = 0; i < array_length(bassline_text_points); i++) {
        var _p = bassline_text_points[i];
        if (!_p.revealed && t >= _p.reveal_t) {
          _p.revealed = true;

          if (random(1) < 0.22) {
            var _rs_ang = random(360);
            array_push(arrow_ring_particles, {
              x : _p.x, y : _p.y,
              vx : lengthdir_x(random_range(0.6, 2.2), _rs_ang),
              vy : lengthdir_y(random_range(0.6, 2.2), _rs_ang),
              life : 8 + irandom(8), max_life : 16,
              size : random_range(0.05, 0.13),
              grav : 0.06, drag : 0.9, hot : 0.85
            });
          }
          bass_text_core_charge = min(bass_text_core_charge + 0.004, 2);
        }
        if (_p.revealed) {
          _p.alpha = min(_p.alpha + 0.12, 1);

          _p.scale = lerp(_p.scale, 1, 0.35);

          var _bass_pulse = sin(t * 0.8 + _p.phase) * (0.05 + bass_text_heat * 0.06);

          _p.draw_scale = _p.scale + _bass_pulse;

          _p.glow_intensity = min(_p.glow_intensity + 0.15, 1);

          if (t >= 1300 && t < 1345 && _p.color_progress > 0.4 && random(1) < 0.004) {
            array_push(bass_text_tears, {
              x : _p.x,
              y : _p.y,
              start_y : _p.y,
              vy : 0.3,
              alpha : 0.7
            });
          }
        }
        if (t >= _p.color_start_t)
        {
          _p.color_progress = min(_p.color_progress + 0.05, 1);
        }
      }

      var _pcount = array_length(bassline_text_points);
      for (var i = 0; i < array_length(bass_text_particles); i++) {
        var p = bass_text_particles[i];

        if (p.tx == _word_cx && p.ty == _word_cy && _pcount > 0) {
          var _cand = bassline_text_points[irandom(_pcount - 1)];
          if (_cand.revealed) {
            p.tx = _cand.x;
            p.ty = _cand.y;
          }
        }

        p.prev_x = p.x;
        p.prev_y = p.y;

        p.speed = min(p.speed * (1.02 + bass_text_heat * 0.02), 0.4);
        p.x = lerp(p.x, p.tx, p.speed);
        p.y = lerp(p.y, p.ty, p.speed);
        p.alpha = min(p.alpha + 0.03, 1);

        if (point_distance(p.x, p.y, p.tx, p.ty) < 5) {
          bass_text_core_charge = min(bass_text_core_charge + 0.02, 2.2);

          if (random(1) < 0.5) {
            var _pa_ang = random(360);
            array_push(arrow_ring_particles, {
              x : p.x, y : p.y,
              vx : lengthdir_x(random_range(0.4, 1.6), _pa_ang),
              vy : lengthdir_y(random_range(0.4, 1.6), _pa_ang),
              life : 6 + irandom(7), max_life : 13,
              size : random_range(0.04, 0.1),
              grav : 0.05, drag : 0.9, hot : 0.9
            });
          }

          var _ra = random(360);
          var _rd = random_range(300, 580);
          p.x = _word_cx + lengthdir_x(_rd, _ra);
          p.y = _word_cy + lengthdir_y(_rd, _ra);
          p.prev_x = p.x;
          p.prev_y = p.y;
          p.speed = random_range(0.018, 0.05);
          p.alpha = random_range(0.15, 0.5);
          p.hot = random_range(0.1, 0.6);
          p.tx = _word_cx;
          p.ty = _word_cy;
        }
      }

      bass_text_pulse_timer--;
      if (bass_text_pulse_timer <= 0) {
        bass_text_pulse_timer = max(3, round(lerp(_k_bass_text_pulse_interval_far, _k_bass_text_pulse_interval_near,
                                                  power(bass_text_heat, 1.5))));
        bass_text_pulse_index++;

        array_push(bass_text_rings, {
          radius : 18, alpha : 0.4 + bass_text_heat * 0.55,
          width : 1 + bass_text_heat * 3.5, hot : bass_text_heat
        });

        bass_text_core_charge = min(bass_text_core_charge + 0.12 + bass_text_heat * 0.3, 2.2);

        vignette_pulse = max(vignette_pulse, lerp(0.06, 0.34, bass_text_heat));
        bloom_pulse = max(bloom_pulse, lerp(0.05, 0.32, bass_text_heat));
        if (bass_text_heat > 0.4) {
          aberration_pulse = max(aberration_pulse, (bass_text_heat - 0.4) * 0.5);
          if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, (bass_text_heat - 0.4) * 6);
          }
        }
      }

      bass_text_arc_timer--;
      if (bass_text_arc_timer <= 0 && _pcount > 4) {
        bass_text_arc_timer = max(1, round(lerp(_k_bass_text_arc_interval_far, _k_bass_text_arc_interval_near,
                                                bass_text_heat)));
        var _arc_n = 1 + round(bass_text_heat * (_k_bass_text_arc_count - 1));

        for (var a = 0; a < _arc_n; a++) {
          var _ai = irandom(_pcount - 1);
          var _pa = bassline_text_points[_ai];
          if (!_pa.revealed) continue;

          var _best = -1;
          var _best_d = 100000;
          repeat (7) {
            var _bi = irandom(_pcount - 1);
            if (_bi == _ai) continue;
            var _pb = bassline_text_points[_bi];
            if (!_pb.revealed) continue;
            var _d = point_distance(_pa.x, _pa.y, _pb.x, _pb.y);
            if (_d > 6 && _d < _best_d) { _best_d = _d; _best = _bi; }
          }
          if (_best < 0) continue;

          var _pb2 = bassline_text_points[_best];
          array_push(bass_text_arcs, {
            ax : _pa.x, ay : _pa.y, bx : _pb2.x, by : _pb2.y,
            life : _k_bass_text_arc_life, life_max : _k_bass_text_arc_life,
            off : scr_bolt_offsets(4, 2 + bass_text_heat * 6),
            width : 0.5 + bass_text_heat * 1.2,
            hot : 0.3 + bass_text_heat * 0.6
          });
        }
      }

      var _frac = clamp((t - _k_bass_text_seam_start_t) / max(_k_bass_text_cut_t - _k_bass_text_seam_start_t, 1), 0, 1);
      for (var s = 0; s < array_length(bass_text_seams); s++) {
        var _sm = bass_text_seams[s];
        if (t >= _sm.start_t) {
          _sm.grow = min(_sm.grow + 0.12, 1);

          if (_sm.grow < 1 && random(1) < 0.5) {
            var _tipd = (random(1) < 0.5) ? _sm.span * _sm.grow : -_sm.span * _sm.grow;
            var _tip_x = _sm.x + lengthdir_x(_tipd, _sm.ang);
            var _tip_y = _sm.y + lengthdir_y(_tipd, _sm.ang);
            var _spark_ang = _sm.ang + choose(90, -90) + random_range(-30, 30);
            array_push(arrow_ring_particles, {
              x : _tip_x, y : _tip_y,
              vx : lengthdir_x(random_range(0.6, 2), _spark_ang),
              vy : lengthdir_y(random_range(0.6, 2), _spark_ang),
              life : 9 + irandom(9), max_life : 18,
              size : random_range(0.05, 0.12),
              grav : 0.1, drag : 0.9, hot : 1
            });
          }
        }
      }

      if (_frac > 0) {
        for (var s = 0; s < array_length(bass_text_shards); s++) {
          var _sh = bass_text_shards[s];
          var _push = power(_frac, 2) * 5 * _sh.drift;
          _sh.cx_off = lengthdir_x(_push, _sh.drift_ang) + sin(t * 0.9 + s) * _frac * 1.2;
          _sh.cy_off = lengthdir_y(_push, _sh.drift_ang) + cos(t * 1.1 + s) * _frac * 1.2;
        }
      }

      if (t >= 1356 && t < _k_bass_text_cut_t) {
        var _suck = (t - 1356) / max(_k_bass_text_cut_t - 1356, 1);

        for (var i = 0; i < array_length(bassline_text_points); i++) {
          var _p = bassline_text_points[i];

          _p.suck_amount = _suck;
        }

        if (instance_exists(oCameraController)) {
          oCameraController.letterbox_target = 1;
        }
        vignette_pulse = max(vignette_pulse, 0.3 + _suck * 0.45);
        bloom_pulse = max(bloom_pulse, 0.3 + _suck * 0.6);
        aberration_pulse = max(aberration_pulse, _suck * 0.7);
        global_ripple_pulse = max(global_ripple_pulse, _suck * 0.5);
        bass_text_core_charge = min(bass_text_core_charge + 0.06, 2.4);
      }

      if (t >= 1360 && !bassline_text_exploding) {
        var _compress = (t - 1360) / 8;

        for (var i = 0; i < array_length(bassline_text_points); i++) {
          var _p = bassline_text_points[i];

          var _cx = room_width / 2;
          var _cy = room_height / 2;

          _p.x = lerp(_p.x, _cx + (_p.x - _cx) * 0.55, _compress);

          _p.y = lerp(_p.y, _cy + (_p.y - _cy) * 0.55, _compress);
        }
      }
    }

    if (bassline_text_created) {
      for (var ring_i = array_length(bass_text_rings) - 1; ring_i >= 0; ring_i--) {
        var _ring = bass_text_rings[ring_i];

        _ring.radius += 8;
        _ring.alpha -= 0.025;

        if (_ring.alpha <= 0) {
          array_delete(bass_text_rings, ring_i, 1);
        }
      }
    }

    if (timeline_hit(_k_bass_text_cut_t) && bassline_text_created && !bassline_text_exploding) {
      bass_text_freeze = 1;

      slash_active = true;
      slash_timer = 0;

      bass_text_scar = [];
      for (var scar_i = 0; scar_i < array_length(bassline_text_points); scar_i++) {
        var _sp = bassline_text_points[scar_i];
        if (!_sp.revealed) continue;
        var _ssh = bass_text_shards[_sp.shard];

        var _scx = _sp.x + _ssh.cx_off;
        var _scy = _sp.y + _ssh.cy_off;
        _scx = lerp(_scx, room_width / 2, _sp.suck_amount * 0.15);
        _scy = lerp(_scy, room_height / 2, _sp.suck_amount * 0.15);

        array_push(bass_text_scar, {x : _scx, y : _scy, alpha : 0.85});
      }

      scr_add_light(room_width / 2, room_height / 2, c_white, 2.0);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 10);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.75);
        oCameraController.letterbox_target = 1;
      }
      vignette_pulse = max(vignette_pulse, 0.8);
      bloom_pulse = max(bloom_pulse, 1.0);
      aberration_pulse = max(aberration_pulse, 0.9);
    }

    if (t < _k_containment_shield_break_t && containment_shield_destroyed) {
      containment_shield_destroyed = false;
      containment_shield_break_timer = 0;
      containment_shield_flash = 0;
      containment_shield_shards = [];
      containment_shield_fractures = [];
    }

    if (timeline_hit(_k_containment_shield_break_t) && !containment_shield_destroyed) {
      containment_shield_destroyed = true;
      containment_shield_break_timer = _k_containment_shield_break_life;
      containment_shield_flash = 1.35;
      containment_shield_shards = [];
      containment_shield_fractures = [];
      containment_shield_ensure_side_blocks();

      var _cs_l = _k_ring_arena_pad;
      var _cs_r = room_width - _k_ring_arena_pad;
      var _cs_t = _k_ring_arena_pad;
      var _cs_b = _k_ring_floor_y;
      var _cs_cx = room_width * 0.5;
      var _cs_cy = room_height * 0.5;
      var _cs_cut_ang = point_direction(0, 0, room_width, -room_height);
      var _cs_nx = lengthdir_x(1, _cs_cut_ang + 90);
      var _cs_ny = lengthdir_y(1, _cs_cut_ang + 90);
      var _cs_edges = [
        {x1 : _cs_l, y1 : _cs_t, x2 : _cs_l, y2 : _cs_b, pieces : 12, edge_ang : 90},
        {x1 : _cs_r, y1 : _cs_t, x2 : _cs_r, y2 : _cs_b, pieces : 12, edge_ang : 90},
        {x1 : _cs_l, y1 : _cs_t, x2 : _cs_r, y2 : _cs_t, pieces : 18, edge_ang : 0}
      ];

      for (var _ce = 0; _ce < array_length(_cs_edges); _ce++) {
        var _edge = _cs_edges[_ce];
        for (var _cp = 0; _cp < _edge.pieces; _cp++) {
          var _cf = (_cp + random_range(0.16, 0.84)) / _edge.pieces;
          var _px = lerp(_edge.x1, _edge.x2, _cf);
          var _py = lerp(_edge.y1, _edge.y2, _cf);
          var _cut_dist = abs((_px - _cs_cx) * _cs_nx + (_py - _cs_cy) * _cs_ny);
          var _near_cut = clamp(1 - _cut_dist / 190, 0, 1);
          var _release_delay = max(0, round(_cut_dist / 34 + random(5) - _near_cut * 4));
          var _out_ang = point_direction(_cs_cx, _cs_cy, _px, _py);
          var _slice_ang = _cs_cut_ang + choose(0, 180) + random_range(-18, 18);
          var _spd = random_range(1.8, 5.5) + _near_cut * random_range(4, 8);
          var _slice_spd = random_range(1.2, 4.6) + _near_cut * 4;
          var _life = 42 + irandom(34) + round(_near_cut * 18);

          array_push(containment_shield_shards, {
            x : _px, y : _py,
            vx : lengthdir_x(_spd, _out_ang) + lengthdir_x(_slice_spd, _slice_ang),
            vy : lengthdir_y(_spd, _out_ang) + lengthdir_y(_slice_spd, _slice_ang) - random_range(0.2, 1.1),
            ang : _edge.edge_ang + random_range(-20, 20),
            spin : random_range(-8, 8) + _near_cut * random_range(-7, 7),
            len : random_range(10, 28 + _near_cut * 18),
            width : random_range(1.0, 2.7 + _near_cut * 2.2),
            life : _life,
            max_life : _life,
            delay : _release_delay,
            hot : 0.35 + _near_cut * 0.65,
            seed : random(1000)
          });

          if (_cp mod 2 == 0 || _near_cut > 0.45) {
            var _f_life = 20 + irandom(18) + round(_near_cut * 18);
            array_push(containment_shield_fractures, {
              x : _px,
              y : _py,
              edge_ang : _edge.edge_ang,
              side : choose(-1, 1),
              len : random_range(18, 52 + _near_cut * 55),
              spread : random_range(7, 18 + _near_cut * 22),
              life : _f_life,
              max_life : _f_life,
              delay : max(0, _release_delay - 2),
              hot : 0.35 + _near_cut * 0.65,
              seed : random(1000)
            });
          }
        }
      }

      for (var _cb = 0; _cb < 13; _cb++) {
        var _along = random_range(-520, 520);
        var _jitter = random_range(-90, 90);
        var _sx = _cs_cx + lengthdir_x(_along, _cs_cut_ang) + lengthdir_x(_jitter, _cs_cut_ang + 90);
        var _sy = _cs_cy + lengthdir_y(_along, _cs_cut_ang) + lengthdir_y(_jitter, _cs_cut_ang + 90);
        var _bolt_ang = _cs_cut_ang + choose(0, 180) + random_range(-22, 22);
        var _bolt_len = random_range(120, 260);
        scr_slash_bolt(_sx, _sy,
                       _sx + lengthdir_x(_bolt_len, _bolt_ang),
                       _sy + lengthdir_y(_bolt_len, _bolt_ang),
                       8 + irandom(8), 16 + random(10), 1.4 + random(1.5), 0.65 + random(0.35));
      }

      for (var _cg = 0; _cg < 72; _cg++) {
        var _eg = _cs_edges[irandom(array_length(_cs_edges) - 1)];
        var _ef = random(1);
        var _ex = lerp(_eg.x1, _eg.x2, _ef);
        var _ey = lerp(_eg.y1, _eg.y2, _ef);
        var _e_cut_dist = abs((_ex - _cs_cx) * _cs_nx + (_ey - _cs_cy) * _cs_ny);
        var _e_hot = clamp(1 - _e_cut_dist / 220, 0, 1);
        var _e_ang = point_direction(_cs_cx, _cs_cy, _ex, _ey) + random_range(-60, 60);
        var _e_spd = random_range(2.5, 9.5 + _e_hot * 7);
        array_push(arrow_ring_particles, {
          x : _ex, y : _ey,
          vx : lengthdir_x(_e_spd, _e_ang),
          vy : lengthdir_y(_e_spd, _e_ang) - random_range(0.2, 1.8),
          life : 16 + irandom(24), max_life : 40,
          size : random_range(0.06, 0.22),
          grav : 0.12, drag : 0.93, hot : 0.45 + _e_hot * 0.55
        });
      }

      for (var _cw = 0; _cw < 2; _cw++) {
        array_push(ring_shockwaves, {
          x : _cs_cx, y : _cs_cy, vs : 1,
          radius : 10 + _cw * 32, max_radius : 430 + _cw * 210,
          life : 24 - _cw * 4, max_life : 24 - _cw * 4,
          width : 22 - _cw * 6, hot : 0.75 - _cw * 0.20
        });
      }

      if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
      array_push(slash_warps, {
        x : _cs_l + 8, y : _cs_b, radius : 20, max_radius : 520,
        strength : 1.45, life : 26, life_max : 26
      });
      if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
      array_push(slash_warps, {
        x : _cs_r - 10, y : _cs_t, radius : 18, max_radius : 470,
        strength : 1.2, life : 22, life_max : 22
      });

      slash_lens_x = _cs_cx;
      slash_lens_y = _cs_cy;
      slash_lens_radius = 360;
      slash_lens_strength = max(slash_lens_strength, 0.55);

      scr_add_light(_cs_cx, _cs_cy, c_white, 5);
      scr_impact_pulse(0.34, 0.7, 0.55, _cs_cx, _cs_cy);
      bloom_pulse = max(bloom_pulse, 1.0);
      aberration_pulse = max(aberration_pulse, 0.9);
      global_ripple_pulse = max(global_ripple_pulse, 0.75);
      tear_amount = max(tear_amount, 0.9);
    }

    if (timeline_hit(_k_bass_text_detonate_t) && bassline_text_created && !bassline_text_exploding) {
      for (var ring_spawn_i = 0; ring_spawn_i < 12; ring_spawn_i++) {
        array_push(bass_text_rings, {radius : 20 + ring_spawn_i * 8, alpha : 1, width : 2.5, hot : 1});
      }

      scr_add_light(room_width / 2, room_height / 2, global.lightning_color, 2.0);

      bassline_text_exploding = true;

      bass_text_cracks = [];

      var _diag_ang = point_direction(0, 0, room_width, -room_height);

      for (var crack_i = 0; crack_i < 18; crack_i++) {
        var _branches = [];

        for (var branch_i = 0; branch_i < 3; branch_i++) {
          array_push(_branches, {
            offset : random_range(-35, 35),
            length : random_range(35, 90),
            growth : 0,
            speed : random_range(5, 10),
            width : random_range(1, 2)
          });
        }

        var _ca = (random(1) < 0.72)
                  ? _diag_ang + choose(0, 180) + random_range(-38, 38)
                  : random(360);

        var _kinks = [];
        for (var _kk = 0; _kk < 4; _kk++) array_push(_kinks, random_range(-9, 9));

        array_push(bass_text_cracks, {
          angle : _ca,
          length : random_range(180, 420),
          growth : 0,
          speed : random_range(10, 18),
          alpha : 1,
          width : random_range(2, 4),
          kinks : _kinks,
          branches : _branches
        });
      }

      bass_text_crack_flash = 1.0;

      bass_text_seams = [];
      bass_text_tears = [];

      var _cx = room_width / 2;
      var _cy = room_height / 2;

      var _k_smear_strength = 80;
      var _k_smear_radial_mix = 0.25;
      var _k_smear_curve = 5.8;

      for (var s = 0; s < array_length(bass_text_shards); s++) {
        var _sh = bass_text_shards[s];
        _sh.cx += _sh.cx_off;
        _sh.cy += _sh.cy_off;
        _sh.vx = 0;
        _sh.vy = 0;
        _sh.rot = 0;
        _sh.rot_speed = random_range(-9, 9);
        _sh.released = false;
        _sh.delay = 0;
      }

      for (var explode_i = 0; explode_i < array_length(bassline_text_points); explode_i++) {
        var _p = bassline_text_points[explode_i];
        var _sh2 = bass_text_shards[_p.shard];

        _p.x += _sh2.cx_off;
        _p.y += _sh2.cy_off;

        var _ang = point_direction(_cx, _cy, _p.x, _p.y);
        var _dist = point_distance(_cx, _cy, _p.x, _p.y);
        var _force = lerp(8, 18, clamp(_dist / 400, 0, 1));

        var _smear_curved = sign(_p.smear_norm) * power(abs(_p.smear_norm), _k_smear_curve);
        var _smear_force = _smear_curved * _k_smear_strength;

        var _k_stagger_max_frames = 10;

        _p.pending_vx = lengthdir_x(_smear_force, _diag_ang) + lengthdir_x(_force, _ang) * _k_smear_radial_mix;
        _p.pending_vy = lengthdir_y(_smear_force, _diag_ang) + lengthdir_y(_force, _ang) * _k_smear_radial_mix;

        _sh2.vx += _p.pending_vx;
        _sh2.vy += _p.pending_vy;
        _sh2.delay += abs(_smear_curved) * _k_stagger_max_frames;

        _p.rel_dist = point_distance(_sh2.cx, _sh2.cy, _p.x, _p.y);
        _p.rel_dir = point_direction(_sh2.cx, _sh2.cy, _p.x, _p.y);

        _p.rotation = 0;
        _p.rot_speed = 0;
        _p.life = 1;
        _p.prev_x = _p.x;
        _p.prev_y = _p.y;
        _p.explode_triggered = false;
      }

      for (var s = 0; s < array_length(bass_text_shards); s++) {
        var _sh3 = bass_text_shards[s];
        var _n = max(_sh3.n, 1);
        _sh3.vx /= _n;
        _sh3.vy /= _n;
        _sh3.delay /= _n;
        _sh3.cx_off = 0;
        _sh3.cy_off = 0;
      }

      bass_text_splatter = [];
      var _k_splatter_count = 60;
      for (var splat_i = 0; splat_i < _k_splatter_count; splat_i++) {
        var _along = random_range(-520, 520);
        var _perp = random_range(-70, 70) * power(random(1), 2);

        var _sx = _cx + lengthdir_x(_along, _diag_ang) + lengthdir_x(_perp, _diag_ang + 90);
        var _sy = _cy + lengthdir_y(_along, _diag_ang) + lengthdir_y(_perp, _diag_ang + 90);

        array_push(bass_text_splatter, {
          x : _sx,
          y : _sy,
          size : random_range(2, 10),
          alpha : random_range(0.6, 1),
          fade : random_range(0.04, 0.07)
        });
      }

      for (var _bw = 0; _bw < 3; _bw++) {
        array_push(ring_shockwaves, {
          x : _cx, y : _cy,
          radius : 10 + _bw * 26, max_radius : 300 + _bw * 190,
          life : 26 - _bw * 4, max_life : 26 - _bw * 4,
          width : 46 - _bw * 11, hot : 1 - _bw * 0.22, vs : 1
        });
      }

      for (var _st = 0; _st < 30; _st++) {
        var _sang = (random(1) < 0.65) ? _diag_ang + choose(0, 180) + random_range(-30, 30) : random(360);
        array_push(ring_streaks, {
          cx : _cx, cy : _cy, vs : 1,
          ang : _sang, dist : random_range(20, 90), len : random_range(50, 190),
          speed : random_range(9, 22), life : 14 + irandom(12), max_life : 26,
          width : random_range(1.2, 3.4), hot : random_range(0.5, 1)
        });
      }

      for (var _dp = 0; _dp < 60; _dp++) {
        var _dang = (random(1) < 0.6) ? _diag_ang + choose(0, 180) + random_range(-45, 45) : random(360);
        var _dspd = random_range(3, 13);
        array_push(arrow_ring_particles, {
          x : _cx + lengthdir_x(random_range(0, 60), _dang),
          y : _cy + lengthdir_y(random_range(0, 60), _dang),
          vx : lengthdir_x(_dspd, _dang), vy : lengthdir_y(_dspd, _dang),
          life : 16 + irandom(20), max_life : 36,
          size : random_range(0.08, 0.24),
          grav : 0.22, drag : 0.94, hot : random_range(0.5, 1)
        });
      }

      for (var _em = 0; _em < 26; _em++) {
        var _eang = _diag_ang + choose(0, 180) + random_range(-50, 50);
        array_push(ring_embers, {
          x : _cx + lengthdir_x(random_range(-260, 260), _diag_ang),
          y : _cy + lengthdir_y(random_range(-260, 260), _diag_ang),
          vx : lengthdir_x(random_range(0.5, 2.5), _eang),
          vy : lengthdir_y(random_range(0.5, 2.5), _eang) - random_range(0.5, 2),
          life : 14 + irandom(12), max_life : 26,
          size : random_range(0.12, 0.3), hot : random_range(0.5, 0.95)
        });
      }

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 35);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.22);
        oCameraController.letterbox_target = 0;
      }

      vignette_pulse = max(vignette_pulse, 1.0);
      bloom_pulse = max(bloom_pulse, 1.0);
      aberration_pulse = max(aberration_pulse, 1.0);
      global_ripple_pulse = max(global_ripple_pulse, 1.0);
      tear_amount = max(tear_amount, 1.2);

      scr_floor_impact(_cx, _cy, 1.15, 1);
    }

    if (array_length(bass_text_cracks) > 0) {
      for (var crack_update_i = array_length(bass_text_cracks) - 1; crack_update_i >= 0; crack_update_i--) {
        var _crack = bass_text_cracks[crack_update_i];

        _crack.growth += _crack.speed;
        _crack.growth = min(_crack.growth, _crack.length);

        _crack.alpha -= 0.04;

        for (var branch_i = 0; branch_i < array_length(_crack.branches); branch_i++) {
          var _branch = _crack.branches[branch_i];

          _branch.growth += _branch.speed;
          _branch.growth = min(_branch.growth, _branch.length);
        }

        if (_crack.growth < _crack.length && random(1) < 0.3) {
          var _crack_tip_x = room_width / 2 + lengthdir_x(_crack.growth, _crack.angle);
          var _crack_tip_y = room_height / 2 + lengthdir_y(_crack.growth, _crack.angle);
          var _crack_ember_ang = _crack.angle + random_range(-20, 20);
          array_push(bass_text_crack_embers, {
            x : _crack_tip_x,
            y : _crack_tip_y,
            vx : lengthdir_x(random_range(0.5, 2), _crack_ember_ang),
            vy : lengthdir_y(random_range(0.5, 2), _crack_ember_ang) - 0.3,
            alpha : 1
          });
        }

        if (_crack.alpha <= 0) {
          array_delete(bass_text_cracks, crack_update_i, 1);
        }
      }
    }

    for (var ce_i = array_length(bass_text_crack_embers) - 1; ce_i >= 0; ce_i--) {
      var _ce = bass_text_crack_embers[ce_i];
      _ce.vy += 0.06;
      _ce.x += _ce.vx;
      _ce.y += _ce.vy;
      _ce.alpha -= 0.03;
      if (_ce.alpha <= 0) {
        array_delete(bass_text_crack_embers, ce_i, 1);
      }
    }

    if (bassline_text_exploding) {
      for (var s = 0; s < array_length(bass_text_shards); s++) {
        var _sh = bass_text_shards[s];

        if (!_sh.released) {
          _sh.delay -= 1;
          if (_sh.delay > 0) continue;
          _sh.released = true;
        }

        _sh.vx += (_sh.cx - room_width / 2) * 0.001;
        _sh.vy += (_sh.cy - room_height / 2) * 0.001;

        _sh.cx += _sh.vx;
        _sh.cy += _sh.vy;

        _sh.vx *= 0.965;
        _sh.vy *= 0.965;

        _sh.rot += _sh.rot_speed;
        _sh.rot_speed *= 0.97;
      }

      for (var text_explode_i = array_length(bassline_text_points) - 1; text_explode_i >= 0; text_explode_i--) {
        var _p = bassline_text_points[text_explode_i];
        var _psh = bass_text_shards[_p.shard];

        if (!_psh.released) continue;

        _p.explode_triggered = true;
        _p.prev_x = _p.x;
        _p.prev_y = _p.y;

        _p.x = _psh.cx + lengthdir_x(_p.rel_dist, _p.rel_dir + _psh.rot);
        _p.y = _psh.cy + lengthdir_y(_p.rel_dist, _p.rel_dir + _psh.rot);

        _p.vx = _p.x - _p.prev_x;
        _p.vy = _p.y - _p.prev_y;
        _p.rotation = _psh.rot;

        _p.alpha -= 0.018;

        if (_p.alpha <= 0) {
          array_delete(bassline_text_points, text_explode_i, 1);
        }
      }

      for (var particle_fade_i = 0; particle_fade_i < array_length(bass_text_particles); particle_fade_i++) {
        bass_text_particles[particle_fade_i].alpha *= 0.9;
      }
    }

    if (bass_text_crack_flash > 0) {
      bass_text_crack_flash *= 0.82;
      if (bass_text_crack_flash < 0.002) bass_text_crack_flash = 0;
    }

    bass_text_freeze = max(0, bass_text_freeze - 0.09);

    for (var tear_i = array_length(bass_text_tears) - 1; tear_i >= 0; tear_i--) {
      var _tr = bass_text_tears[tear_i];
      _tr.vy += 0.05;
      _tr.y += _tr.vy;
      _tr.alpha -= bassline_text_exploding ? 0.08 : 0.01;
      if (_tr.alpha <= 0 || _tr.y - _tr.start_y > 60) {
        array_delete(bass_text_tears, tear_i, 1);
      }
    }

    for (var _sb = array_length(slash_bolts) - 1; _sb >= 0; _sb--) {
      slash_bolts[_sb].life--;
      if (slash_bolts[_sb].life <= 0) array_delete(slash_bolts, _sb, 1);
    }

    for (var _sw = array_length(slash_warps) - 1; _sw >= 0; _sw--) {
      var _swp = slash_warps[_sw];
      _swp.life--;
      _swp.radius = lerp(_swp.radius, _swp.max_radius, 0.16);
      if (_swp.life <= 0) array_delete(slash_warps, _sw, 1);
    }

    slash_lens_strength = max(0, slash_lens_strength - 0.05);

    if (containment_shield_break_timer > 0) containment_shield_break_timer--;
    containment_shield_flash = max(0, containment_shield_flash - 0.055);

    for (var _css = array_length(containment_shield_shards) - 1; _css >= 0; _css--) {
      var _csh = containment_shield_shards[_css];
      if (_csh.delay > 0) {
        _csh.delay--;
        continue;
      }

      _csh.x += _csh.vx;
      _csh.y += _csh.vy;
      _csh.vx *= 0.955;
      _csh.vy = _csh.vy * 0.955 + 0.08;
      _csh.ang += _csh.spin;
      _csh.spin *= 0.97;
      _csh.life--;
      if (_csh.life <= 0) array_delete(containment_shield_shards, _css, 1);
    }

    for (var _csf = array_length(containment_shield_fractures) - 1; _csf >= 0; _csf--) {
      var _cff = containment_shield_fractures[_csf];
      if (_cff.delay > 0) {
        _cff.delay--;
        continue;
      }

      _cff.life--;
      if (_cff.life <= 0) array_delete(containment_shield_fractures, _csf, 1);
    }

    if (bassline_text_created && !bassline_text_exploding && t >= _k_bass_text_seam_start_t &&
        array_length(bass_text_leaks) < _k_bass_text_leak_max) {
      var _leak_frac = clamp((t - _k_bass_text_seam_start_t) / max(_k_bass_text_cut_t - _k_bass_text_seam_start_t, 1), 0, 1);
      if (random(1) < _k_bass_text_leak_chance * _leak_frac) {
        var _lk_ang = random(360);
        var _lk_r = bass_text_word_w * 0.4;
        array_push(bass_text_leaks, {
          x1 : bass_text_word_cx + lengthdir_x(_lk_r, _lk_ang),
          y1 : bass_text_word_cy + lengthdir_y(_lk_r * 0.45, _lk_ang),
          ang : _lk_ang,
          reach : _k_bass_text_leak_reach * random_range(0.6, 1.2),
          life : 11, life_max : 11,
          off : scr_bolt_offsets(5, 11)
        });
      }
    }
    for (var _lk = array_length(bass_text_leaks) - 1; _lk >= 0; _lk--) {
      bass_text_leaks[_lk].life--;
      if (bass_text_leaks[_lk].life <= 0) array_delete(bass_text_leaks, _lk, 1);
    }
    if (bassline_text_exploding) {
      bass_text_heat = max(0, bass_text_heat - 0.03);
      bass_text_core_charge = max(0, bass_text_core_charge - 0.07);
    }

    for (var _ba = array_length(bass_text_arcs) - 1; _ba >= 0; _ba--) {
      bass_text_arcs[_ba].life--;
      if (bass_text_arcs[_ba].life <= 0) array_delete(bass_text_arcs, _ba, 1);
    }

    for (var _bs = array_length(bass_text_scar) - 1; _bs >= 0; _bs--) {
      bass_text_scar[_bs].alpha -= _k_bass_text_scar_fade;
      if (bass_text_scar[_bs].alpha <= 0) array_delete(bass_text_scar, _bs, 1);
    }

    for (var splat_update_i = array_length(bass_text_splatter) - 1; splat_update_i >= 0; splat_update_i--) {
      bass_text_splatter[splat_update_i].alpha -= bass_text_splatter[splat_update_i].fade;
      if (bass_text_splatter[splat_update_i].alpha <= 0) {
        array_delete(bass_text_splatter, splat_update_i, 1);
      }
    }

    if (slash_active) {
      var _k_slash_rise_frames = 6;
      var _k_slash_hold_frames = 10;
      var _k_slash_fall_frames = 14;

      slash_timer += 1;

      if (slash_timer <= _k_slash_rise_frames) {
        var _t = slash_timer / _k_slash_rise_frames;
        slash_amount = 1 - power(1 - _t, 3);
      } else if (slash_timer <= _k_slash_rise_frames + _k_slash_hold_frames) {
        slash_amount = 1;
      } else if (slash_timer <= _k_slash_rise_frames + _k_slash_hold_frames + _k_slash_fall_frames) {
        var _fall_t = (slash_timer - _k_slash_rise_frames - _k_slash_hold_frames) / _k_slash_fall_frames;
        slash_amount = 1 - (_fall_t * _fall_t);
      } else {
        slash_amount = 0;
        slash_active = false;
      }

      if (slash_amount > 0.5 && random(1) < 0.5) {
        var _seam_diag_ang = point_direction(0, 0, room_width, -room_height);
        var _seam_along = random_range(-400, 400);
        array_push(slash_seam_embers, {
          x : room_width / 2 + lengthdir_x(_seam_along, _seam_diag_ang),
          y : room_height / 2 + lengthdir_y(_seam_along, _seam_diag_ang),
          vx : random_range(-0.3, 0.3),
          vy : random_range(0.4, 1.2),
          alpha : 1
        });
      }
    }

    for (var se_i = array_length(slash_seam_embers) - 1; se_i >= 0; se_i--) {
      var _se = slash_seam_embers[se_i];
      _se.vy += 0.05;
      _se.x += _se.vx;
      _se.y += _se.vy;
      _se.alpha -= 0.055;
      if (_se.alpha <= 0) {
        array_delete(slash_seam_embers, se_i, 1);
      }
    }

    if (timeline_hit_many(_k_bass_text_detonate_t, 1387)) {
      var _fld_wave = (t >= 1380) ? 1 : 0;
      var _fld_cols = 5 - _fld_wave;
      var _fld_rows = 4 - _fld_wave;
      var _fld_cw = room_width / 4;
      var _fld_ch = 575 / 3;
      var _fld_cx = room_width / 2;
      var _fld_cy = room_height / 2;
      if (_fld_wave == 0) laser_seed_drift_dir = choose(-1, 1);
      var _fld_drift_dir = (_fld_wave == 0) ? laser_seed_drift_dir : -laser_seed_drift_dir;
      var _fld_drift_frames = min(_k_laser_seed_drift_frames, max(1, _k_laser_t_sweep - t - 1));

      for (var _gy = 0; _gy < _fld_rows; _gy++) {
        for (var _gx = 0; _gx < _fld_cols; _gx++) {
          var _ox = (_gx + 0.5 * _fld_wave) * _fld_cw;
          var _oy = (_gy + 0.5 * _fld_wave) * _fld_ch;
          var _odist = point_distance(_fld_cx, _fld_cy, _ox, _oy);

          var _spawn_orb = function(_sx, _sy, _sdist, _drift_dir, _drift_frames) {
            var _target_x = clamp(_sx + _drift_dir * random_range(_k_laser_seed_drift_min, _k_laser_seed_drift_max),
                                  -_k_laser_seed_drift_edge_margin,
                                  room_width + _k_laser_seed_drift_edge_margin);

            var _blocked = false;
            with (oLaserOrb_Pop) {
              var _other_target_x = variable_instance_exists(id, "laser_seed_drift_target_x") ? laser_seed_drift_target_x : x;
              if (point_distance(x, y, _sx, _sy) < 12) _blocked = true;
              if (point_distance(_other_target_x, y, _target_x, _sy) < other._k_laser_seed_drift_final_sep) _blocked = true;
            }
            if (_blocked) return;

            with (instance_create_layer(_sx, _sy, layer, oLaserOrb_Pop)) {
              laser_meteor_visual = true;
              _k_spawn_flash_color = global.avoid_col_cyan;
              _k_sustained_glow_color = global.avoid_col_danger;
              _k_shockwave_color = global.avoid_col_warning;
              materialize_duration = 10 + round(_sdist / 22) + irandom(6);
              idle_alpha_max_override = 0.5;
              idle_alpha_min_override = 0.5;
              image_alpha = 0.5;
              deadly_while_idle = false;
              laser_seed_drift_active = true;
              laser_seed_drift_timer = 0;
              laser_seed_drift_duration = _drift_frames;
              laser_seed_drift_start_x = _sx;
              laser_seed_drift_target_x = _target_x;
            }
          };

          _spawn_orb(_ox, _oy, _odist, _fld_drift_dir, _fld_drift_frames);

          if ((_gy == 0 || _gy == _fld_rows - 1) && _ox + _fld_cw * 0.5 <= room_width) {
            var _ox2 = _ox + _fld_cw * 0.5;
            var _oy2 = _oy;
            var _odist2 = point_distance(_fld_cx, _fld_cy, _ox2, _oy2);
            _spawn_orb(_ox2, _oy2, _odist2, _fld_drift_dir, _fld_drift_frames);
          }
        }
      }

      array_push(ring_shockwaves, {
        x : _fld_cx, y : _fld_cy,
        radius : 30, max_radius : 460,
        life : 22, max_life : 22,
        width : 22, hot : 0.55, vs : 1
      });
      scr_impact_pulse(0.18, 0.3, 0.35, _fld_cx, _fld_cy);
    }
  }
if (timeline_hit(1283)) {
  instance_create_layer(300, 350, layer, oBassSlashOrb);
}
if true {
	if (timeline_hit(_k_laser_t_lock_arm)) {
	  laser_jump_clear();
	  scr_start_laser_coil(400, 0, 270, _k_laser_t_sweep - _k_laser_t_lock_arm, 1.0);

	  scr_start_erupt_warn_band(2, _k_laser_t_sweep - _k_laser_t_lock_arm);
	}

	if (timeline_hit(_k_laser_t_top_warn)) {
	  scr_trigger_laser_warning(2);

	  for (var _cm = 0; _cm < 16; _cm++) {
	    array_push(converge_motes, {
	      cx : 400, cy : 0,
	      ang : random(360), dist : random_range(120, 300), dest : 8,
	      speed : random_range(9, 20), size : random_range(0.1, 0.24),
	      spin : random_range(-6, 6), hot : random_range(0.4, 1),
	      feed : ""
	    });
	  }
	}
	if (timeline_hit(_k_laser_t_sweep)) {
	  laser_attack_positions = [];

	  var laser_attack_spawn_x = 400;
	  var laser_attack_spawn_y = 0;
	  var laser_attack_sweep_speed = 13 * _k_laser_beam_speed_mult;

	  with oLaserOrb_Pop { array_push(other.laser_attack_positions, [ x, y ]); }

	  with instance_create_layer(laser_attack_spawn_x, laser_attack_spawn_y, layer, oLaserOrbTrigger) {
	    image_angle = 90;
	    move_dir = 270;
	    move_speed = laser_attack_sweep_speed;
	  }

	  scr_laser_muzzle_burst(laser_attack_spawn_x, laser_attack_spawn_y, 270, 1.0);

	  scr_impact_pulse(0.22, 0.4, 0.35, laser_attack_spawn_x, laser_attack_spawn_y);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 8);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.07);
	  }
	  global_ripple_pulse = max(global_ripple_pulse, 0.3);
	}

	if (timeline_hit(_k_laser_t_chains - _k_laser_jump_warn_lead)) {
	  laser_jump_start(_k_laser_jump_warn_lead);
	}

	if (timeline_hit(_k_laser_t_chains)) {
	  laser_x_chains = [];
	  laser_x_marks = [];
	  laser_chain_arcs = [];
	  laser_chain_breaks = [];
	  laser_chain_spawn_flashes = [];
	  laser_jump_fire();
	  laser_spawn_spiral_orbs();
	}
	if (timeline_hit(_k_laser_t_center_warn)) {
	  scr_trigger_center_laser_warning(400, 304, -45);

	  if (instance_exists(oCameraController)) {
	    oCameraController.letterbox_target = 1;
	  }

	  scr_start_laser_coil(400, 304, 135, _k_laser_t_center_fire - _k_laser_t_center_warn, 1.4);

	  for (var _cm = 0; _cm < 30; _cm++) {
	    array_push(converge_motes, {
	      cx : 400, cy : 304,
	      ang : random(360), dist : random_range(180, 420), dest : 10,
	      speed : random_range(14, 32), size : random_range(0.12, 0.3),
	      spin : random_range(-8, 8), hot : random_range(0.5, 1),
	      feed : ""
	    });
	  }
	}
	if (timeline_hit(_k_laser_t_center_fire)) {
	  var _cf_speed = 12 * _k_laser_beam_speed_mult;
	  with instance_create_layer(400, 304, layer, oLaserOrbTrigger) {
	    image_angle = -45;
	    move_dir = 135;
	    move_speed = _cf_speed;
	    beam_paired_center = true;
	  }
	  with instance_create_layer(400, 304, layer, oLaserOrbTrigger) {
	    image_angle = -45;
	    move_dir = 135;
	    move_speed = -_cf_speed;
	    beam_paired_center = true;
	  }

	  scr_laser_muzzle_burst(400, 304, 135, 1.35);
	  scr_laser_muzzle_burst(400, 304, 315, 1.35);

	  scr_impact_pulse(0.45, 0.75, 0.6, 400, 304);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 14);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.18);
	    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.3);
	  }
	  global_ripple_pulse = max(global_ripple_pulse, 0.6);
	  tear_amount = max(tear_amount, 0.6);
	}

	if (timeline_hit(_k_laser_t_cross_a - 10)) scr_start_laser_coil(400, 304, 195, 10, 0.95);
	if (timeline_hit(_k_laser_t_cross_b - 10)) scr_start_laser_coil(400, 304, 225, 10, 1.2);

	if (timeline_hit(_k_laser_t_cross_a) || timeline_hit(_k_laser_t_cross_b)) {
	  var _cf_second = timeline_hit(_k_laser_t_cross_b);
	  var _cf_angle = _cf_second ? 45 : 15;
	  var _cf_dir = _cf_angle + 180;

	  var _cf_speed = 13 * _k_laser_beam_speed_mult;
	  with instance_create_layer(400, 304, layer, oLaserOrbTrigger) {
	    image_angle = _cf_angle;
	    move_dir = _cf_dir;
	    move_speed = _cf_speed;
	    beam_paired_center = true;
	  }
	  with instance_create_layer(400, 304, layer, oLaserOrbTrigger) {
	    image_angle = _cf_angle;
	    move_dir = _cf_dir;
	    move_speed = -_cf_speed;
	    beam_paired_center = true;
	  }

	  scr_laser_muzzle_burst(400, 304, _cf_dir, _cf_second ? 1.2 : 0.95);
	  scr_laser_muzzle_burst(400, 304, _cf_dir + 180, _cf_second ? 1.2 : 0.95);

	  scr_impact_pulse(_cf_second ? 0.4 : 0.3, _cf_second ? 0.65 : 0.5, _cf_second ? 0.55 : 0.45, 400, 304);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, _cf_second ? 12 : 9);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _cf_second ? 0.15 : 0.11);
	  }
	  global_ripple_pulse = max(global_ripple_pulse, _cf_second ? 0.55 : 0.45);
	}

	if (timeline_hit(_k_laser_t_cross_b + 12)) {
	  if (instance_exists(oCameraController)) {
	    oCameraController.letterbox_target = 0;
	  }
	}
	var _orb_volley_make_jump_route = function() {
	  orb_volley_jump_band_y = random_range(room_height - 150, room_height - 105);

	  var _entry_x = random_range(220, 580);
	  var _mid_x = clamp(_entry_x + random_range(-130, 130), 150, 650);
	  var _high_x = clamp(_mid_x + random_range(-150, 150), 110, 690);
	  var _exit_x = clamp(_high_x + random_range(-120, 120), 90, 710);

	  orb_volley_jump_route = [
	    [_entry_x, _k_orb_volley_route_floor_y],
	    [_mid_x, orb_volley_jump_band_y + random_range(-10, 10)],
	    [_high_x, orb_volley_jump_band_y - 110 + random_range(-22, 22)],
	    [_exit_x, 80 + random_range(-20, 34)]
	  ];
	};

	var _orb_volley_grid_targets = function() {
	  var _cols = 5;
	  var _rows = 3;
	  var _x0 = 40, _x1 = 760;
	  var _y0 = 40, _y1 = room_height - 40;
	  var _cw = (_x1 - _x0) / max(1, _cols - 1);
	  var _ch = (_y1 - _y0) / max(1, _rows - 1);
	  var _jx = _cw * 0.3;
	  var _jy = _ch * 0.3;
	  var _min_sep = 34;
	  var _targets = [];

	  for (var _gy = 0; _gy < _rows; _gy++) {
	    for (var _gx = 0; _gx < _cols; _gx++) {
	      var _bx = _x0 + _gx * _cw;
	      var _by = _y0 + _gy * _ch;

	      var _best_x = _bx;
	      var _best_y = _by;
	      var _best_d = -1;

	      for (var _att = 0; _att < 10; _att++) {
	        var _cx = _bx + random_range(max(-_jx, _x0 - _bx), min(_jx, _x1 - _bx));
	        var _cy = _by + random_range(max(-_jy, _y0 - _by), min(_jy, _y1 - _by));
	        if (abs(_cy - orb_volley_jump_band_y) < _k_orb_volley_jump_band_half) continue;

	        var _route_p = clamp(1 - ((_cy - 60) / max(1, _k_orb_volley_route_floor_y - 60)), 0, 1);
	        var _route_w = (_route_p < 0.55)
	                       ? lerp(_k_orb_volley_route_bottom_w, _k_orb_volley_route_mid_w, _route_p / 0.55)
	                       : lerp(_k_orb_volley_route_mid_w, _k_orb_volley_route_top_w, (_route_p - 0.55) / 0.45);
	        var _route_d = 100000;
	        if (_cy <= _k_orb_volley_route_floor_y && array_length(orb_volley_jump_route) >= 2) {
	          for (var _ri = 0; _ri < array_length(orb_volley_jump_route) - 1; _ri++) {
	            var _a = orb_volley_jump_route[_ri];
	            var _b = orb_volley_jump_route[_ri + 1];
	            var _vx = _b[0] - _a[0];
	            var _vy = _b[1] - _a[1];
	            var _len2 = _vx * _vx + _vy * _vy;
	            var _u = (_len2 <= 0) ? 0 : clamp(((_cx - _a[0]) * _vx + (_cy - _a[1]) * _vy) / _len2, 0, 1);
	            var _px = _a[0] + _vx * _u;
	            var _py = _a[1] + _vy * _u;
	            _route_d = min(_route_d, point_distance(_cx, _cy, _px, _py));
	          }
	        }
	        if (_route_d < _route_w) continue;

	        var _near = 100000;

	        for (var _pi = 0; _pi < array_length(_targets); _pi++) {
	          _near = min(_near, point_distance(_cx, _cy, _targets[_pi][0], _targets[_pi][1]));
	        }
	        with (oLaserOrb_Pop) {
	          _near = min(_near, point_distance(x, y, _cx, _cy));
	        }
	        for (var _si = 0; _si < array_length(orb_volley_shards); _si++) {
	          _near = min(_near, point_distance(_cx, _cy, orb_volley_shards[_si].tx,
	                                                      orb_volley_shards[_si].ty));
	        }

	        if (_near > _best_d) {
	          _best_d = _near;
	          _best_x = _cx;
	          _best_y = _cy;
	        }
	        if (_near >= _min_sep) break;
	      }

	      if (_best_d < 0) continue;
	      array_push(_targets, [_best_x, _best_y]);
	    }
	  }
	  return _targets;
	};

	if (timeline_hit(_k_laser_t_volley_a - _k_orb_volley_lock_on_frames)) {
	  _orb_volley_make_jump_route();
	  orb_volley_lock_on_origin_x = 400;
	  orb_volley_lock_on_origin_y = room_height + 60;
	  orb_volley_lock_on_targets = _orb_volley_grid_targets();
	  orb_volley_lock_on_timer = _k_orb_volley_lock_on_frames;
	}
	if (timeline_hit(_k_laser_t_volley_b - _k_orb_volley_lock_on_frames)) {
	  if (array_length(orb_volley_jump_route) < 2) _orb_volley_make_jump_route();
	  orb_volley_lock_on_origin_x = 400;
	  orb_volley_lock_on_origin_y = -60;
	  orb_volley_lock_on_targets = _orb_volley_grid_targets();
	  orb_volley_lock_on_timer = _k_orb_volley_lock_on_frames;
	}

	if (timeline_hit_many(_k_laser_t_volley_a, _k_laser_t_volley_b)) {
	  for (var i = 0; i < array_length(orb_volley_lock_on_targets); i++) {
	    var _tgt = orb_volley_lock_on_targets[i];
	    var _orb = instance_create_layer(_tgt[0], _tgt[1], layer, oLaserOrb_Pop);
	    with (_orb) {
	      laser_meteor_visual = true;
	      _k_spawn_flash_color = global.avoid_col_cyan;
	      _k_sustained_glow_color = global.avoid_col_danger;
	      _k_shockwave_color = global.avoid_col_warning;
	      pop_persist = true;
	      laser_pop_enabled = false;
	      idle_alpha_max_override = 0.5;
	      idle_alpha_min_override = 0.5;
	      image_alpha = 0.5;
	      deadly_while_idle = false;
	    }

	    orb_volley_shard_id_counter++;
	    array_push(orb_volley_shards, {
	      ox: orb_volley_lock_on_origin_x, oy: orb_volley_lock_on_origin_y,
	      tx: _tgt[0], ty: _tgt[1],
	      x: orb_volley_lock_on_origin_x, y: orb_volley_lock_on_origin_y,
	      delay: irandom(_k_orb_volley_stagger_max),
	      timer: 0,
	      trail: [],
	      orb: _orb
	    });
	  }

	  array_push(orb_volley_bursts, {
	    x: orb_volley_lock_on_origin_x, y: orb_volley_lock_on_origin_y,
	    life: 20, life_max: 20, max_radius: 90
	  });

	  scr_laser_muzzle_burst(orb_volley_lock_on_origin_x, orb_volley_lock_on_origin_y,
	                         (orb_volley_lock_on_origin_y < 0) ? 270 : 90, 1.15);

	  scr_impact_pulse(0.34, 0.55, 0.5, 400, room_height / 2);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 12);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.1);
	  }
	  global_ripple_pulse = max(global_ripple_pulse, 0.45);
	}

	if (array_length(orb_volley_shards) > 0 || array_length(orb_volley_bursts) > 0 || orb_volley_lock_on_timer > 0) {
	  if (orb_volley_lock_on_timer > 0) orb_volley_lock_on_timer--;

	  for (var i = array_length(orb_volley_bursts) - 1; i >= 0; i--) {
	    orb_volley_bursts[i].life--;
	    if (orb_volley_bursts[i].life <= 0) array_delete(orb_volley_bursts, i, 1);
	  }

	  for (var i = array_length(orb_volley_shards) - 1; i >= 0; i--) {
	    var _s = orb_volley_shards[i];
	    if (_s.delay > 0) {
	      _s.delay--;
	      continue;
	    }
	    _s.timer++;
	    var _prog = clamp(_s.timer / _k_orb_volley_travel_frames, 0, 1);
	    var _eased = _prog * _prog * _prog;

	    var _prev_x = _s.x, _prev_y = _s.y;
	    _s.x = lerp(_s.ox, _s.tx, _eased);
	    _s.y = lerp(_s.oy, _s.ty, _eased);

	    array_push(_s.trail, {x: _prev_x, y: _prev_y});
	    if (array_length(_s.trail) > _k_orb_volley_trail_length) array_delete(_s.trail, 0, 1);

	    if (_prog >= 1) {
	      if (instance_exists(_s.orb)) {
	        with (_s.orb) {
	          laser_pop_enabled = true;
	        }
	      }

	      array_push(orb_volley_bursts, {x: _s.tx, y: _s.ty, life: 14, life_max: 14, max_radius: 40});

	      var _land_back = point_direction(_s.tx, _s.ty, _s.ox, _s.oy);
	      for (var _ls = 0; _ls < 5; _ls++) {
	        var _lang = _land_back + random_range(-70, 70);
	        var _lspd = random_range(1.5, 4.5);
	        array_push(arrow_ring_particles, {
	          x : _s.tx, y : _s.ty,
	          vx : lengthdir_x(_lspd, _lang), vy : lengthdir_y(_lspd, _lang),
	          life : 9 + irandom(10), max_life : 19,
	          size : random_range(0.06, 0.16),
	          grav : 0.2, drag : 0.92, hot : random_range(0.6, 1)
	        });
	      }

	      if (instance_exists(oCameraController)) {
	        oCameraController.shake = max(oCameraController.shake, 2);
	      }

	      array_delete(orb_volley_shards, i, 1);
	    }
	  }
	}

	if (timeline_hit(_k_laser_t_edge_warn)) {
	  scr_trigger_laser_warning((random(1) < 0.5) ? 0 : 1);

	  var _wm_x = (warning_edge == 0) ? 0 : room_width;
	  scr_start_laser_coil(_wm_x, room_height / 2, (warning_edge == 0) ? 0 : 180,
	                       _k_laser_t_hsweep - _k_laser_t_edge_warn, 1.1);

	  scr_start_erupt_warn_band(warning_edge, _k_laser_t_hsweep - _k_laser_t_edge_warn);

	  for (var _cm = 0; _cm < 20; _cm++) {
	    array_push(converge_motes, {
	      cx : _wm_x, cy : room_height / 2,
	      ang : random(360), dist : random_range(140, 340), dest : 8,
	      speed : random_range(11, 24), size : random_range(0.1, 0.26),
	      spin : random_range(-6, 6), hot : random_range(0.4, 1),
	      feed : ""
	    });
	  }
	}

	if (timeline_hit(_k_laser_t_hsweep)) {
	  var _from_left = (warning_edge == 0);
	  var _laser;
	  if (_from_left) {
	    _laser = instance_create_layer(-50, room_height / 2, layer, oLaserOrbTrigger);
	    _laser.image_angle = 0;
	    _laser.move_dir = 0;
	    _laser.gravity_dir_to_apply = 180;
	  } else {
	    _laser = instance_create_layer(room_width + 50, room_height / 2, layer, oLaserOrbTrigger);
	    _laser.image_angle = 0;
	    _laser.move_dir = 180;
	    _laser.gravity_dir_to_apply = 0;
	  }
	  _laser.move_speed = 12 * _k_laser_beam_speed_mult;
	  _laser.apply_gravity_on_pop = true;

	  scr_laser_muzzle_burst(_from_left ? 0 : room_width, room_height / 2, _from_left ? 0 : 180, 1.1);
	  scr_impact_pulse(0.28, 0.45, 0.4, _from_left ? 0 : room_width, room_height / 2);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 9);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.08);
	  }
	  global_ripple_pulse = max(global_ripple_pulse, 0.35);
	}

	for (var _fb = 0; _fb < array_length(_k_laser_t_finale_beats); _fb++) {
	  if (!timeline_hit(_k_laser_t_finale_beats[_fb])) continue;

	  var _fb_prog = (_fb + 1) / array_length(_k_laser_t_finale_beats);
	  laser_finale_charge = max(laser_finale_charge, _fb_prog);
	  laser_finale_flash = 1;

	  with (oLaserOrb_Pop) {
	    if (pop_persist) {
	      shockwave_active = true;
	      shockwave_radius = 0;
	      shockwave_max_radius = _k_shockwave_radius_base * base_scale * (0.5 + _fb_prog * 0.7);
	      shockwave_alpha = _k_shockwave_alpha_start * _fb_prog;
	    }
	  }

	  var _fb_motes = 12 + round(_fb_prog * 22);
	  for (var _cm = 0; _cm < _fb_motes; _cm++) {
	    array_push(converge_motes, {
	      cx : room_width / 2, cy : room_height / 2,
	      ang : random(360), dist : random_range(240, 520), dest : 14,
	      speed : random_range(8, 14 + _fb_prog * 16), size : random_range(0.1, 0.3),
	      spin : random_range(-7, 7), hot : 0.3 + _fb_prog * 0.7,
	      feed : ""
	    });
	  }

	  array_push(ring_shockwaves, {
	    x : room_width / 2, y : room_height / 2,
	    radius : 20, max_radius : 180 + _fb_prog * 260,
	    life : 20, max_life : 20,
	    width : 14 + _fb_prog * 20, hot : _fb_prog, vs : 1
	  });

	  scr_impact_pulse(0.18 + _fb_prog * 0.22, 0.25 + _fb_prog * 0.35, 0.25 + _fb_prog * 0.35,
	                   room_width / 2, room_height / 2);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 4 + _fb_prog * 7);
	    if (_fb_prog >= 1) oCameraController.letterbox_target = 1;
	  }
	}

	if (laser_finale_charge > 0 && !laser_finale_released) {
	  laser_finale_pulse_timer--;
	  if (laser_finale_pulse_timer <= 0) {
	    laser_finale_pulse_timer = max(3, round(lerp(_k_laser_finale_pulse_interval_far,
	                                                 _k_laser_finale_pulse_interval_near, laser_finale_charge)));
	    array_push(laser_finale_pulses, {radius : 10, alpha : 0.35 + laser_finale_charge * 0.5, hot : laser_finale_charge});
	    vignette_pulse = max(vignette_pulse, laser_finale_charge * 0.28);
	    bloom_pulse = max(bloom_pulse, laser_finale_charge * 0.25);
	  }
	}

	if (timeline_hit(_k_laser_t_finale)) {
	  laser_finale_released = true;
	  laser_finale_flash = 1.4;

	  with(oLaserOrb_Pop) {
	    if (pop_persist && gravity_activated) {
	      gravity_direction = (gravity_direction == 0) ? 180 : 0;
	      gravity = 1;
	      shockwave_active = true;
	      shockwave_radius = 0;
	      shockwave_max_radius = _k_shockwave_radius_base * base_scale * 1.5;
	      shockwave_alpha = _k_shockwave_alpha_start;

	      var _flip_x = x;
	      var _flip_y = y;
	      var _flip_dir = gravity_direction;
	      with (oAvoidanceController) {
	        for (var _fs = 0; _fs < 4; _fs++) {
	          var _fang = _flip_dir + random_range(-55, 55);
	          var _fspd = random_range(1.5, 4.5);
	          array_push(arrow_ring_particles, {
	            x : _flip_x, y : _flip_y,
	            vx : lengthdir_x(_fspd, _fang), vy : lengthdir_y(_fspd, _fang),
	            life : 12 + irandom(12), max_life : 24,
	            size : random_range(0.06, 0.17),
	            grav : 0.14, drag : 0.93, hot : random_range(0.6, 1)
	          });
	        }
	      }
	    }
	  }

	  for (var _fw = 0; _fw < 3; _fw++) {
	    array_push(ring_shockwaves, {
	      x : room_width / 2, y : room_height / 2,
	      radius : 14 + _fw * 30, max_radius : 380 + _fw * 220,
	      life : 28 - _fw * 5, max_life : 28 - _fw * 5,
	      width : 40 - _fw * 10, hot : 1 - _fw * 0.25, vs : 1
	    });
	  }
	  for (var _ft = 0; _ft < 26; _ft++) {
	    array_push(ring_streaks, {
	      cx : room_width / 2, cy : room_height / 2, vs : 1,
	      ang : random(360), dist : random_range(30, 110), len : random_range(50, 170),
	      speed : random_range(10, 24), life : 14 + irandom(10), max_life : 24,
	      width : random_range(1.2, 3), hot : random_range(0.5, 1)
	    });
	  }

	  tear_amount = max(tear_amount, 1.2);
	  vignette_pulse = max(vignette_pulse, 0.9);
	  bloom_pulse = max(bloom_pulse, 0.9);
	  aberration_pulse = max(aberration_pulse, 0.8);
	  global_ripple_pulse = max(global_ripple_pulse, 0.9);
	  if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 22);
	    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.2);
	    oCameraController.letterbox_target = 0;
	  }
	  scr_floor_impact(room_width / 2, room_height / 2, 1.1, 1);
	}

	if (laser_finale_charge > 0 || array_length(laser_finale_pulses) > 0 || laser_finale_flash > 0) {
	  laser_finale_flash = max(0, laser_finale_flash - 0.06);
	  if (laser_finale_released) laser_finale_charge = max(0, laser_finale_charge - 0.03);

	  for (var _fp = array_length(laser_finale_pulses) - 1; _fp >= 0; _fp--) {
	    var _fpu = laser_finale_pulses[_fp];
	    _fpu.radius += 7;
	    _fpu.alpha -= 0.022;
	    if (_fpu.alpha <= 0) array_delete(laser_finale_pulses, _fp, 1);
	  }
	}

	if (laser_finale_charge > 0 && !laser_finale_released &&
	    array_length(laser_finale_leaks) < _k_laser_finale_leak_max && random(1) < 0.09 * laser_finale_charge) {
	  var _flk_ang = random(360);
	  var _flk_r = lerp(300, 120, laser_finale_charge);
	  array_push(laser_finale_leaks, {
	    x1 : room_width / 2 + lengthdir_x(_flk_r, _flk_ang),
	    y1 : room_height / 2 + lengthdir_y(_flk_r, _flk_ang),
	    x2 : room_width / 2 + lengthdir_x(_flk_r + _k_laser_finale_leak_reach, _flk_ang),
	    y2 : room_height / 2 + lengthdir_y(_flk_r + _k_laser_finale_leak_reach, _flk_ang),
	    life : 12, life_max : 12,
	    off : scr_bolt_offsets(5, 12)
	  });
	}
	for (var _flk = array_length(laser_finale_leaks) - 1; _flk >= 0; _flk--) {
	  laser_finale_leaks[_flk].life--;
	  if (laser_finale_leaks[_flk].life <= 0) array_delete(laser_finale_leaks, _flk, 1);
	}

	laser_coil_flash = max(0, laser_coil_flash - 0.09);

	if (laser_coil_active) {
	  laser_coil_t++;
	  var _lc_p = clamp(laser_coil_t / laser_coil_len, 0, 1);

	  if (laser_coil_t mod _k_laser_coil_arc_interval == 0 && array_length(laser_coil_arcs) < _k_laser_coil_arc_max) {
	    array_push(laser_coil_arcs, {
	      ang : random(360),
	      life : _k_laser_coil_arc_interval + 3, life_max : _k_laser_coil_arc_interval + 3,
	      off : scr_bolt_offsets(5, 5 + _lc_p * 7)
	    });
	  }

	  if (array_length(laser_coil_leaks) < _k_laser_coil_leak_max &&
	      random(1) < _k_laser_coil_leak_chance * (0.4 + _lc_p)) {
	    array_push(laser_coil_leaks, {ang : random(360), life : 9, life_max : 9, off : scr_bolt_offsets(5, 10)});
	  }

	  laser_coil_pulse_timer--;
	  if (laser_coil_pulse_timer <= 0) {
	    laser_coil_pulse_timer = max(1, round(lerp(_k_laser_coil_pulse_far, _k_laser_coil_pulse_near, _lc_p)));
	    array_push(laser_coil_pulses, {radius : 6, alpha : 0.3 + _lc_p * 0.5});
	    vignette_pulse = max(vignette_pulse, (0.08 + _lc_p * 0.16) * laser_coil_power);
	    bloom_pulse = max(bloom_pulse, (0.06 + _lc_p * 0.18) * laser_coil_power);
	  }

	  if (laser_coil_t mod 2 == 0) {
	    array_push(converge_motes, {
	      cx : laser_coil_x, cy : laser_coil_y,
	      ang : random(360), dist : random_range(90, 230), dest : 6,
	      speed : random_range(10, 18 + _lc_p * 14), size : random_range(0.09, 0.22),
	      spin : random_range(-7, 7), hot : 0.3 + _lc_p * 0.7,
	      feed : ""
	    });
	  }

	  laser_lock_ang = laser_coil_dir - (laser_coil_centered ? 0 : 90);

	  laser_lock_wid = _k_laser_lock_half_h;

	  var _ll_push = laser_coil_centered ? 0 : _k_laser_lock_push;
	  laser_lock_cx = laser_coil_x + lengthdir_x(_ll_push, laser_coil_dir);
	  laser_lock_cy = laser_coil_y + lengthdir_y(_ll_push, laser_coil_dir);

	  var _ll_ux = lengthdir_x(1, laser_lock_ang);
	  var _ll_uy = lengthdir_y(1, laser_lock_ang);

	  var _ll_bound_l = _k_laser_lock_pad;
	  var _ll_bound_r = room_width - _k_laser_lock_pad;
	  var _ll_bound_t = _k_laser_lock_pad;
	  var _ll_bound_b = room_height - _k_laser_lock_pad;
	  var _ll_lim = _k_laser_lock_reach;

	  if (laser_coil_centered && instance_exists(oCameraController)) {
	    var _ll_cam = oCameraController;
	    _ll_bound_l = _ll_cam.current_cam_x + _k_laser_lock_pad;
	    _ll_bound_r = _ll_cam.current_cam_x + _ll_cam.current_cam_w - _k_laser_lock_pad;
	    _ll_bound_t = _ll_cam.current_cam_y + _k_laser_lock_pad;
	    _ll_bound_b = _ll_cam.current_cam_y + _ll_cam.current_cam_h - _k_laser_lock_pad;
	    _ll_lim = max(_ll_cam.current_cam_w, _ll_cam.current_cam_h);
	  }

	  if (abs(_ll_ux) > 0.0001) {
	    _ll_lim = min(_ll_lim, max((_ll_bound_l - laser_lock_cx) / _ll_ux,
	                               (_ll_bound_r - laser_lock_cx) / _ll_ux));
	  }
	  if (abs(_ll_uy) > 0.0001) {
	    _ll_lim = min(_ll_lim, max((_ll_bound_t - laser_lock_cy) / _ll_uy,
	                               (_ll_bound_b - laser_lock_cy) / _ll_uy));
	  }
	  laser_lock_len = max(0, _ll_lim);

	  if (laser_coil_t mod 2 == 0) {
	    var _lc_spread = lerp(30, 9, _lc_p);
	    var _lc_vn = (laser_coil_power >= _k_laser_lock_heavy_power) ? 3 : 2;
	    for (var _lcv = 0; _lcv < _lc_vn; _lcv++) {
	      var _lc_off = random_range(-1, 1) * laser_lock_len * 0.92;
	      scr_spawn_vent_stream(laser_vents,
	                            laser_lock_cx + lengthdir_x(_lc_off, laser_lock_ang),
	                            laser_lock_cy + lengthdir_y(_lc_off, laser_lock_ang),
	                            laser_coil_dir + random_range(-_lc_spread, _lc_spread),
	                            (0.3 + _lc_p * 0.7) * laser_coil_power,
	                            _k_laser_vent_cols, 56);
	    }
	  }

	  if (laser_coil_t >= laser_coil_len) {
	    laser_coil_active = false;
	    laser_coil_flash = 1;
	  }
	}

	for (var _lca = array_length(laser_coil_arcs) - 1; _lca >= 0; _lca--) {
	  laser_coil_arcs[_lca].life--;
	  if (laser_coil_arcs[_lca].life <= 0) array_delete(laser_coil_arcs, _lca, 1);
	}
	for (var _lcl = array_length(laser_coil_leaks) - 1; _lcl >= 0; _lcl--) {
	  laser_coil_leaks[_lcl].life--;
	  if (laser_coil_leaks[_lcl].life <= 0) array_delete(laser_coil_leaks, _lcl, 1);
	}

	scr_update_vent_streams(laser_vents);

	for (var _lcp = array_length(laser_coil_pulses) - 1; _lcp >= 0; _lcp--) {
	  laser_coil_pulses[_lcp].radius += 6;
	  laser_coil_pulses[_lcp].alpha -= 0.05;
	  if (laser_coil_pulses[_lcp].alpha <= 0) array_delete(laser_coil_pulses, _lcp, 1);
	}

	for (var _bsc = array_length(laser_beam_scars) - 1; _bsc >= 0; _bsc--) {
	  laser_beam_scars[_bsc].alpha -= _k_laser_scar_fade;
	  if (laser_beam_scars[_bsc].alpha <= 0) array_delete(laser_beam_scars, _bsc, 1);
	}

	for (var _cbk = array_length(laser_chain_breaks) - 1; _cbk >= 0; _cbk--) {
	  laser_chain_breaks[_cbk].life--;
	  if (laser_chain_breaks[_cbk].life <= 0) array_delete(laser_chain_breaks, _cbk, 1);
	}

	if (array_length(laser_x_marks) > 0 || array_length(laser_chain_spawn_flashes) > 0) {
	  for (var i = array_length(laser_chain_spawn_flashes) - 1; i >= 0; i--) {
	    laser_chain_spawn_flashes[i].life--;
	    if (laser_chain_spawn_flashes[i].life <= 0) array_delete(laser_chain_spawn_flashes, i, 1);
	  }

	  var _laser_x_activated = 0;
	  var _laser_x_last_x = room_width * 0.5;
	  var _laser_x_last_y = room_height * 0.5;
	  var _beam_count = instance_number(oLaserOrbTrigger);

	  for (var xm = array_length(laser_x_marks) - 1; xm >= 0; xm--) {
	    var _mark = laser_x_marks[xm];

	    if (!_mark.active && _beam_count > 0) {
	      var _hit_beam = noone;
	      var _hit_axis = _mark.ang;

	      for (var _bi = 0; _bi < _beam_count; _bi++) {
	        var _beam = instance_find(oLaserOrbTrigger, _bi);
	        if (!instance_exists(_beam)) continue;

	        var _axis = _beam.image_angle - 90;
	        var _ux = lengthdir_x(1, _axis);
	        var _uy = lengthdir_y(1, _axis);
	        var _px = lengthdir_x(1, _axis + 90);
	        var _py = lengthdir_y(1, _axis + 90);
	        var _dx = _mark.x - _beam.x;
	        var _dy = _mark.y - _beam.y;
	        var _along = _dx * _ux + _dy * _uy;
	        var _perp = abs(_dx * _px + _dy * _py);
	        var _extend = variable_instance_exists(_beam, "extend") ? _beam.extend : 1;
	        var _half = (variable_instance_exists(_beam, "_k_beam_half_length") ? _beam._k_beam_half_length : 450)
	                  * max(0.05, _extend);
	        var _beam_r = (variable_instance_exists(_beam, "_k_orb_check_width") ? _beam._k_orb_check_width : 20) * 0.5;

	        if (_along >= -_half - _k_laser_x_mark_trigger_radius &&
	            _along <=  _half + _k_laser_x_mark_trigger_radius &&
	            _perp <= _beam_r + _k_laser_x_mark_trigger_radius) {
	          _hit_beam = _beam;
	          _hit_axis = _axis;
	          break;
	        }
	      }

	      if (_hit_beam != noone) {
	        _mark.active = true;
	        _mark.life = _k_laser_x_mark_active_life;
	        _mark.active_life = _k_laser_x_mark_active_life;
	        _mark.hot = 1.35;
	        _mark.ring = 1.2;
	        _mark.strike = 1;
	        _mark.trigger_ang = _hit_axis;

	        with (_hit_beam) {
	          beam_heat = min(beam_heat + _k_beam_heat_per_kill * 0.65, _k_beam_heat_max);
	          kill_count++;
	        }

	        array_push(laser_chain_spawn_flashes,
	                  {x: _mark.x, y: _mark.y, life: _k_laser_chain_spawn_flash_life, life_max: _k_laser_chain_spawn_flash_life});

	        for (var _xs = 0; _xs < _k_laser_x_mark_spark_count; _xs++) {
	          var _sang = _hit_axis + choose(-90, 90) + random_range(-42, 42);
	          var _sspd = random_range(2.2, 6.2);
	          array_push(arrow_ring_particles, {
	            x : _mark.x, y : _mark.y,
	            vx : lengthdir_x(_sspd, _sang), vy : lengthdir_y(_sspd, _sang),
	            life : 8 + irandom(10), max_life : 18,
	            size : random_range(0.06, 0.13),
	            grav : 0.10, drag : 0.91, hot : random_range(0.86, 1)
	          });
	        }

	        _laser_x_activated++;
	        _laser_x_last_x = _mark.x;
	        _laser_x_last_y = _mark.y;
	      }
	    }

	    if (_mark.active && _mark.life > 3 &&
	        instance_exists(oPlayer) && !oPlayer.dead && !instance_exists(oGameover)) {
	      var _active_p = clamp(_mark.life / max(_mark.active_life, 1), 0, 1);
	      var _kill_len = _mark.arm_len * lerp(0.3, 1, power(_active_p, 0.7));
	      var _kill_w = _k_laser_x_mark_kill_width * clamp(_active_p + 0.22, 0.38, 1);
	      var _mark_hit_player = collision_circle(_mark.x, _mark.y, _kill_w * 1.35, oPlayer, false, true) != noone;

	      for (var _ka = 0; _ka < 2 && !_mark_hit_player; _ka++) {
	        var _kang2 = _mark.ang + _ka * 90;
	        if (player_meeting_line_width(_mark.x + lengthdir_x(_kill_len, _kang2),
	                                      _mark.y + lengthdir_y(_kill_len, _kang2),
	                                      _mark.x - lengthdir_x(_kill_len, _kang2),
	                                      _mark.y - lengthdir_y(_kill_len, _kang2),
	                                      _kill_w)) {
	          _mark_hit_player = true;
	        }
	      }

	      if (_mark_hit_player && player_register_hazard_hit()) {
	        _mark.hot = max(_mark.hot, 1.45);
	        _mark.ring = max(_mark.ring, 1);
	      }
	    }

	    _mark.life--;
	    _mark.hot = max(0, _mark.hot - (_mark.active ? 0.025 : 0.055));
	    _mark.ring = max(0, _mark.ring - (_mark.active ? 0.09 : 0.07));
	    _mark.strike = max(0, _mark.strike - 0.12);
	    _mark.phase += 0.12 + _mark.hot * 0.18 + (_mark.active ? 0.08 : 0);

	    if (_mark.life <= 0) array_delete(laser_x_marks, xm, 1);
	  }

	  if (_laser_x_activated > 0) {
	    scr_impact_pulse(min(0.3, 0.08 + _laser_x_activated * 0.015),
	                     min(0.55, 0.22 + _laser_x_activated * 0.025),
	                     0.25, _laser_x_last_x, _laser_x_last_y);
	    if (instance_exists(oCameraController)) {
	      oCameraController.shake = max(oCameraController.shake, min(8, 2 + _laser_x_activated * 0.35));
	      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, min(0.16, 0.04 + _laser_x_activated * 0.006));
	    }
	  }
	}

	var _k_drop_interval_min = 5;
	var _k_drop_interval_max = 9;
	var _k_telegraph_frames = 4;
	var _k_idle_pulse_speed = 0.08;
	var _k_idle_alpha_min = 0.08;
	var _k_idle_alpha_max = 0.22;
	var _k_fall_gravity = 0.5;
	var _k_escalate_start_t = 1790;
	var _k_escalate_min_mult = 0.8;
	var _k_shockwave_max_radius = 40;
	var _k_shockwave_speed = 3;
	var _k_shockwave_start_alpha = 0.8;
	var _k_pop_flash_duration = 6;
}
if (timeline_hit_many(1691, 1712)) {
  if (!orb_ceiling_built) orbrain_build_ceiling();

  for (var i = 0; i < 40; ++i) {
    var _edge_side = 0;
    if (i < _k_reentry_edge_seed_count) {
      _edge_side = (i mod 2 == 0) ? -1 : 1;
    }

    var _ox = random_range(0, room_width);
    var _oy = random_range(-140, -20);
    var _tx = 0;
    if (_edge_side < 0) {
      _tx = random_range(_k_reentry_edge_pad, _k_reentry_edge_pad + _k_reentry_edge_band);
    } else if (_edge_side > 0) {
      _tx = random_range(room_width - _k_reentry_edge_pad - _k_reentry_edge_band,
                         room_width - _k_reentry_edge_pad);
    } else {
      var _inner_pad = _k_reentry_edge_pad + _k_reentry_edge_band;
      _tx = random_range(_inner_pad, room_width - _inner_pad);
    }
    var _ty = random_range(72, 322);
    var _is_bolide = (random(1) < _k_reentry_bolide_chance);
    var _delay_max = (_edge_side != 0) ? _k_reentry_edge_stagger_max : _k_reentry_stagger_max;
    var _dur_min = (_edge_side != 0) ? _k_reentry_edge_duration_min : _k_reentry_duration_min;
    var _dur_max = (_edge_side != 0) ? _k_reentry_edge_duration_max : _k_reentry_duration_max;

    var _dir = point_direction(_ox, _oy, _tx, _ty);
    var _perp = _dir + 90;
    var _bow = random_range(-_k_reentry_curve_max, _k_reentry_curve_max);
    var _mid_x = lerp(_ox, _tx, 0.5) + lengthdir_x(_bow, _perp);
    var _mid_y = lerp(_oy, _ty, 0.5) + lengthdir_y(_bow, _perp);

    reentry_shard_id_counter++;
    array_push(reentry_shards, {
      ox: _ox, oy: _oy, tx: _tx, ty: _ty, mx: _mid_x, my: _mid_y,
      x: _ox, y: _oy,
      delay: irandom(_delay_max),
      timer: 0,
      duration: irandom_range(_dur_min, _dur_max),
      is_bolide: _is_bolide,
      trail: [],
      shed_timer: irandom_range(2, 5)
    });
  }
}

storm_intensity = 0;
if (t >= 1691 && t < 1856) {
  if (t < 1740) {
    storm_intensity = clamp((t - 1691) / (1740 - 1691), 0, 1);
  } else if (t < 1820) {
    storm_intensity = 1;
  } else {
    storm_intensity = clamp(1 - (t - 1820) / (1856 - 1820), 0, 1);
  }
}
if (storm_intensity > 0) {
  vignette_pulse = max(vignette_pulse, storm_intensity * 0.22);
  bloom_pulse = max(bloom_pulse, storm_intensity * 0.18);
  aberration_pulse = max(aberration_pulse, storm_intensity * 0.06);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, storm_intensity * 1.4);
  }
}

if (storm_intensity > 0.001) {
  if (!storm_rain_seeded) {
    storm_rain_seeded = true;
    storm_rain_streaks = [];
    for (var _rsi = 0; _rsi < _k_storm_rain_count; _rsi++) {
      var _band = _rsi mod _k_storm_rain_bands;
      array_push(storm_rain_streaks, {
        x : random_range(-120, room_width + 120),
        y : random_range(-room_height, room_height),
        len : lerp(10, 30, _band / (_k_storm_rain_bands - 1)) * random_range(0.7, 1.3),
        spd : lerp(13, 27, _band / (_k_storm_rain_bands - 1)) * random_range(0.85, 1.15),
        band : _band
      });
    }
  }

  storm_wind += (storm_wind_target - storm_wind) * _k_storm_wind_ease;
  storm_wind_target *= 0.94;

  for (var _rsi = 0; _rsi < array_length(storm_rain_streaks); _rsi++) {
    var _rs = storm_rain_streaks[_rsi];
    var _depth = 0.5 + (_rs.band / max(_k_storm_rain_bands - 1, 1)) * 0.5;
    _rs.y += _rs.spd * (0.6 + storm_intensity * 0.4);
    _rs.x += storm_wind * _depth;
    if (_rs.y > room_height + 40) {
      _rs.y -= (room_height + 80);
      _rs.x = random_range(-120, room_width + 120);
    }
    if (_rs.x < -140) _rs.x += room_width + 280;
    else if (_rs.x > room_width + 140) _rs.x -= room_width + 280;
  }

  storm_sky_timer--;
  if (storm_sky_timer <= 0) {
    storm_sky_timer = irandom_range(14, 30);
    storm_sky_flash = max(storm_sky_flash, random_range(0.25, 0.55) * storm_intensity);

    if (random(1) < 0.55) {
      array_push(storm_sky_bolts, {
        x : random_range(60, room_width - 60),
        y : random_range(40, 150),
        seed : random(1000),
        life : 8, life_max : 8,
        w : random_range(1.5, 3.5)
      });
    }
    bloom_pulse = max(bloom_pulse, storm_sky_flash * 0.25);
  }
}
storm_sky_flash = max(0, storm_sky_flash - 0.055);
if (storm_sweep_active) {
  storm_sweep += 0.045;
  if (storm_sweep >= 1) {
    storm_sweep = 0;
    storm_sweep_active = false;
  }
}
for (var i = array_length(storm_sky_bolts) - 1; i >= 0; i--) {
  storm_sky_bolts[i].life--;
  if (storm_sky_bolts[i].life <= 0) array_delete(storm_sky_bolts, i, 1);
}

if (array_length(reentry_shards) > 0 || array_length(reentry_embers) > 0 || array_length(reentry_touchdowns) > 0) {
  for (var i = array_length(reentry_touchdowns) - 1; i >= 0; i--) {
    reentry_touchdowns[i].life--;
    if (reentry_touchdowns[i].life <= 0) array_delete(reentry_touchdowns, i, 1);
  }

  for (var i = array_length(reentry_embers) - 1; i >= 0; i--) {
    var _em = reentry_embers[i];
    _em.x += _em.vx;
    _em.y += _em.vy;
    _em.vx *= 0.94;
    _em.vy *= 0.94;
    _em.alpha -= 0.045;
    if (_em.alpha <= 0) array_delete(reentry_embers, i, 1);
  }

  for (var i = array_length(reentry_shards) - 1; i >= 0; i--) {
    var _s = reentry_shards[i];
    if (_s.delay > 0) {
      _s.delay--;
      continue;
    }

    _s.timer++;
    var _prog = clamp(_s.timer / _s.duration, 0, 1);
    var _eased = 1 - power(1 - _prog, 2);

    var _prev_x = _s.x, _prev_y = _s.y;
    var _inv = 1 - _eased;
    _s.x = _inv * _inv * _s.ox + 2 * _inv * _eased * _s.mx + _eased * _eased * _s.tx;
    _s.y = _inv * _inv * _s.oy + 2 * _inv * _eased * _s.my + _eased * _eased * _s.ty;

    array_push(_s.trail, {x: _prev_x, y: _prev_y});
    var _trail_max = _s.is_bolide ? 14 : 9;
    if (array_length(_s.trail) > _trail_max) array_delete(_s.trail, 0, 1);

    _s.shed_timer--;
    if (_s.shed_timer <= 0) {
      _s.shed_timer = _s.is_bolide ? 2 : 5;
      var _eject_ang = point_direction(_s.x, _s.y, _prev_x, _prev_y) + random_range(-25, 25);
      array_push(reentry_embers, {
        x: _s.x, y: _s.y,
        vx: lengthdir_x(random_range(1, 3), _eject_ang),
        vy: lengthdir_y(random_range(1, 3), _eject_ang),
        alpha: 1,
        bolide: _s.is_bolide
      });
    }

    if (_prog >= 1) {
      orbrain_attach(instance_create_layer(_s.tx, _s.ty, layer, oFallingRedOrb));
      array_push(reentry_touchdowns, {x: _s.tx, y: _s.ty, life: 12, life_max: 12, bolide: _s.is_bolide});
      if (_s.is_bolide && instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 4);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.08);
      }
      array_delete(reentry_shards, i, 1);
    }
  }
}

if (t >= 1685 && t < 1872) {
  if (!orb_ceiling_built) orbrain_build_ceiling();

  orb_ceiling_flex = max(0, orb_ceiling_flex - 1.15);
  orb_ceiling_heat = max(0, orb_ceiling_heat - 0.035);
  orb_rain_flash   = max(0, orb_rain_flash - 0.075);
  if (orb_finale_active) orb_finale = min(1, orb_finale + 0.05);

  scr_update_vent_streams(orb_rain_vents);

  for (var _si = array_length(orb_shocks) - 1; _si >= 0; _si--) {
    var _sk = orb_shocks[_si];
    _sk.radius += _k_orbrain_shock_speed * (0.55 + _sk.hot * 0.75);
    _sk.life--;
    if (_sk.life <= 0) array_delete(orb_shocks, _si, 1);
  }

  for (var _wi = array_length(orb_whips) - 1; _wi >= 0; _wi--) {
    var _wp = orb_whips[_wi];
    _wp.x += _wp.vx;
    _wp.y += _wp.vy;
    _wp.vy += 0.55;
    _wp.vx *= 0.97;
    _wp.life--;
    if (_wp.life <= 0) array_delete(orb_whips, _wi, 1);
  }

  for (var _oi = array_length(orb_sockets) - 1; _oi >= 0; _oi--) {
    orb_sockets[_oi].life--;
    if (orb_sockets[_oi].life <= 0) array_delete(orb_sockets, _oi, 1);
  }

  for (var _mi = array_length(orb_snap_motes) - 1; _mi >= 0; _mi--) {
    var _mt = orb_snap_motes[_mi];
    _mt.x += _mt.vx;
    _mt.y += _mt.vy;
    _mt.vx *= 0.94;
    _mt.vy = _mt.vy * 0.94 + 0.12;
    _mt.life--;
    if (_mt.life <= 0) array_delete(orb_snap_motes, _mi, 1);
  }

  for (var _ci = array_length(orb_cracks) - 1; _ci >= 0; _ci--) {
    var _ck = orb_cracks[_ci];
    _ck.reach += _ck.speed;
    _ck.speed *= 0.985;
    _ck.life--;
    if (_ck.life <= 0) array_delete(orb_cracks, _ci, 1);
  }

  // --- THE PRESSURE FRONT: the thing that actually hits the orbs ---
  var _strike_list = [];
  var _strike_lat  = [];

  for (var _fi = array_length(orb_fronts) - 1; _fi >= 0; _fi--) {
    var _fr = orb_fronts[_fi];
    _fr.depth += _fr.speed;
    _fr.speed *= 0.995;
    _fr.life--;
    if (_fr.life <= 0) {
      array_delete(orb_fronts, _fi, 1);
      continue;
    }

    var _fr_epi = _fr.epi;
    var _fr_depth = _fr.depth;
    var _fr_beat = _fr.beat;
    var _fr_lead = _k_orbrain_front_lead;
    var _fr_denom = 2 * _k_orbrain_front_sigma * _k_orbrain_front_sigma;

    with (oFallingRedOrb) {
      if (!rain_orb || dissolving) continue;
      if (tether_state >= 3 || armed_beat != _fr_beat) continue;
      if (tether_state != 1 && tether_state != 2) continue;

      var _dxf = tether_ax - _fr_epi;
      var _lead_f = (1 - _fr_lead) + _fr_lead * exp(-(_dxf * _dxf) / _fr_denom);
      var _front_y = tether_ay + _fr_depth * _lead_f;

      var _span_f = max(y - tether_ay, 1);
      var _prog_f = clamp((_front_y - tether_ay) / _span_f, 0, 1);

      if (_prog_f > 0) {
        tether_state = 2;
        tether_charge = max(tether_charge, _prog_f);
      }

      if (_prog_f >= 1) {
        array_push(_strike_list, id);
        array_push(_strike_lat, clamp((x - _fr_epi) / 300, -1, 1));
      }
    }
  }

  // --- tethers ride the flexing seam; drips fuse on their own ---
  var _drip_list = [];

  with (oFallingRedOrb) {
    if (!rain_orb || dissolving) continue;

    if (tether_state < 3) tether_ay = other.orbrain_seam_y(tether_ax);

    if (tether_state == 1 && drip_fuse > 0) {
      drip_fuse--;
      if (drip_fuse <= 0) array_push(_drip_list, id);
    }
  }

  for (var _dq = 0; _dq < array_length(_drip_list); _dq++) {
    var _do = _drip_list[_dq];
    if (!instance_exists(_do)) continue;
    array_push(_strike_list, _do);
    array_push(_strike_lat, random_range(-0.4, 0.4));
    with (_do) {
      tether_state = 2;
      tether_charge = 1;
    }
  }

  // --- the strike: front lands, orb deforms and holds, then gravity owns it ---
  for (var _sq = 0; _sq < array_length(_strike_list); _sq++) {
    var _so = _strike_list[_sq];
    if (!instance_exists(_so)) continue;
    if (_so.tether_state >= 3 || _so.dissolving) continue;

    var _heavy_rel = _so.tether_heavy;
    var _snap_x = _so.x;
    var _snap_y = _so.y;
    var _lat = _strike_lat[_sq];

    orbrain_strike(_so, _lat, _heavy_rel ? 1 : 0.65);

    with (_so) {
      telegraphing = 0;
      waiting_to_fall = 0;
      trail = 1;
      image_alpha = 1;
      hit_active = false;
      image_blend = c_white;
      gravity = 0;
      gravity_direction = 270;
      speed = 0;
      vspeed = 0;
      _size = is_hailstone ? 1.8 : 1;
      trail_positions = [];

      shockwave_active = true;
      shockwave_radius = 0;
      shockwave_max_radius = is_hailstone ? _k_shockwave_max_radius * 2 : _k_shockwave_max_radius;
      shockwave_alpha = _k_shockwave_start_alpha;

      pop_flash_timer = 1;
      glowing = true;
      pop_flash_duration = _k_pop_flash_duration;

      growing = true;
      grow_timer = 0;
      _k_grow_overshoot_scale = is_hailstone ? 2.0 : 1.5;
    }

    var _mn = _heavy_rel ? 16 : 7;
    if (_so.is_hailstone) _mn += 12;
    var _mote_spd_max = _heavy_rel ? 5.4 : 3.2;
    var _mote_size_max = _heavy_rel ? 3.4 : 2.2;
    var _mote_cols_n = array_length(_k_orbrain_vent_cols);
    var _cone_dir = 270 + _lat * 26;

    for (var _mq = 0; _mq < _mn; _mq++) {
      if (array_length(orb_snap_motes) >= _k_orbrain_mote_cap) break;
      var _splash = (_mq mod 5 == 0);
      var _ma = _splash ? (90 + random_range(-55, 55))
                        : (_cone_dir + random_range(-62, 62));
      var _ms = random_range(1.2, _mote_spd_max) * (_splash ? 0.6 : 1);
      var _mvx = lengthdir_x(_ms, _ma);
      var _mvy = lengthdir_y(_ms, _ma);
      array_push(orb_snap_motes, {
        x : _snap_x + random_range(-5, 5),
        y : _snap_y + random_range(-5, 5),
        vx : _mvx,
        vy : _mvy,
        life : 16 + irandom(16), max_life : 32,
        size : random_range(1.2, _mote_size_max),
        col : _k_orbrain_vent_cols[irandom(_mote_cols_n - 1)]
      });
    }
  }
}

with(oFallingRedOrb) {
  if (dissolving) {
    hit_active = false;
    if (dissolve_delay > 0) {
      dissolve_delay--;
      continue;
    }
    dissolve_timer++;
    dissolve_prog = clamp(dissolve_timer / dissolve_duration, 0, 1);
    image_alpha = 1 - dissolve_prog;
    image_blend = c_white;
    var _dissolve_scale = _size * lerp(1.5, 0, dissolve_prog);
    image_xscale = _dissolve_scale;
    image_yscale = _dissolve_scale;
    if (dissolve_prog >= 1) instance_destroy();
    continue;
  }

  if (waiting_to_fall == 1 && !telegraphing) {
    if (mill_orb) {
      image_alpha = lerp(0.42, 0.78,
                         (sin((current_time / 1000 + idle_pulse_offset) * _k_idle_pulse_speed) + 1) / 2);
      hit_active = false;
    } else if (rain_orb) {
      var _idle_w = (sin((current_time / 1000 + idle_pulse_offset) * _k_idle_pulse_speed) + 1) / 2;

      if (tether_state == 2) {
        image_alpha = lerp(0.55, 1, tether_charge);
        image_blend = merge_color(tether_heavy ? global.avoid_col_warning
                                               : global.avoid_col_cyan,
                                  c_white, tether_charge);
      } else if (tether_state == 1) {
        var _arm_w = (sin(other.t * 0.34 + idle_pulse_offset) + 1) / 2;
        image_alpha = lerp(0.34, 0.62, _arm_w) + arm_flash * 0.3;
        image_blend = merge_color(tether_heavy ? global.avoid_col_warning
                                               : global.avoid_col_cyan,
                                  c_white, 0.15 + _arm_w * 0.2);
      } else {
        image_alpha = lerp(_k_idle_alpha_min, _k_idle_alpha_max, _idle_w);
        image_blend = c_red;
      }

      hit_active = false;
    } else {
      image_alpha = lerp(_k_idle_alpha_min, _k_idle_alpha_max,
                         (sin((current_time / 1000 + idle_pulse_offset) * _k_idle_pulse_speed) + 1) / 2);
      hit_active = image_alpha > 0.25;
    }
  }

  if (shockwave_active) {
    shockwave_radius += _k_shockwave_speed;
    shockwave_alpha = _k_shockwave_start_alpha * (1 - (shockwave_radius / shockwave_max_radius));
    if (shockwave_radius >= shockwave_max_radius) shockwave_active = false;
  }

  if (pop_flash_timer > 0 && pop_flash_timer < pop_flash_duration) {
    pop_flash_timer++;
    if (pop_flash_timer >= pop_flash_duration) pop_flash_timer = pop_flash_duration;
  }

  if (mill_orbiting) {
    mill_orbit_timer++;
    var _olife = max(mill_orbit_life, 1);
    var _op = clamp(mill_orbit_timer / _olife, 0, 1);
    var _osnap = clamp(mill_orbit_timer / max(other._k_mill_orbit_lock, 1), 0, 1);
    var _oease = _op * _op * _op * (_op * (_op * 6 - 15) + 10);
    mill_orbit_angle = mill_orbit_start_angle + mill_orbit_span * _oease;

    var _otx = other._k_mill_cx + lengthdir_x(mill_orbit_radius, mill_orbit_angle);
    var _oty = other._k_mill_cy + lengthdir_y(mill_orbit_radius, mill_orbit_angle);
    x = lerp(x, _otx, _osnap);
    y = lerp(y, _oty, _osnap);

    image_alpha = lerp(1, 0.58, max(0, (_op - 0.68) / 0.32));
    hit_active = true;
    array_push(trail_positions, {x: x, y: y});
    if (array_length(trail_positions) > _k_trail_length) array_delete(trail_positions, 0, 1);

    if (mill_orbit_timer >= _olife) {
      mill_orbiting = false;
      mill_wired = false;
      mill_link_to = noone;
      dissolving = true;
      hit_active = false;
      dissolve_timer = 0;
      dissolve_duration = other._k_mill_orbit_fade;
      dissolve_delay = irandom(3);
    }
  }
  else if (glowing && !telegraphing) {
    if (rain_orb && strike_hold > 0) continue;

    hit_active = true;
    x += wind_drift + sin((other.t + idle_pulse_offset * 100) * 0.08) * 0.3;

    array_push(trail_positions, {x: x, y: y});
    if (array_length(trail_positions) > _k_trail_length) array_delete(trail_positions, 0, 1);

    if (y >= other._k_rain_floor_y) {
      if (mill_orb) {
        var _mlx = clamp(x, 8, room_width - 8);
        var _min_dir = point_direction(xprevious, yprevious, x, y);
        scr_floor_impact(_mlx, other._k_rain_floor_y, is_hailstone ? 0.8 : 0.22, is_hailstone ? 1 : 0);

        var _msn = is_hailstone ? 18 : 6;
        for (var _ms = 0; _ms < _msn; _ms++) {
          var _mang = -_min_dir + random_range(-45, 45);
          var _mspd = random_range(2, is_hailstone ? 9 : 5);
          array_push(other.arrow_ring_particles, {
            x : _mlx, y : other._k_rain_floor_y,
            vx : lengthdir_x(_mspd, _mang), vy : lengthdir_y(_mspd, _mang),
            life : 18 + irandom(10), max_life : 28,
            size : random_range(0.07, is_hailstone ? 0.3 : 0.16),
            grav : 0.2, drag : 0.95, hot : 0.6 + random(0.4)
          });
        }
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, is_hailstone ? 9 : 2);
        }
        instance_destroy();
        continue;
      }

      array_push(other.rain_splashes, {
        x: x, y: other._k_rain_floor_y,
        life: 16, life_max: 16,
        max_radius: is_hailstone ? 70 : 30,
        hailstone: is_hailstone
      });
      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, is_hailstone ? 8 : 1.5);
        if (is_hailstone) {
          oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.15);
        }
      }

      if (is_hailstone) {
        scr_floor_impact(x, other._k_rain_floor_y, 0.85, 1);
        for (var _hp = 0; _hp < 22; _hp++) {
          var _hang = 200 + random(140);
          var _hspd = random_range(3, 9);
          array_push(other.arrow_ring_particles, {
            x : x + random_range(-10, 10), y : other._k_rain_floor_y,
            vx : lengthdir_x(_hspd, _hang),
            vy : lengthdir_y(_hspd, _hang),
            life : 26, max_life : 26,
            size : random_range(0.12, 0.34),
            grav : 0.22, drag : 0.96,
            hot : 0.7 + random(0.3)
          });
        }
        for (var _he = 0; _he < 10; _he++) {
          var _heang = 210 + random(120);
          var _hes = random_range(2, 6);
          array_push(other.ring_embers, {
            x : x, y : other._k_rain_floor_y,
            vx : lengthdir_x(_hes, _heang),
            vy : lengthdir_y(_hes, _heang) - random_range(0.5, 2),
            life : 40 + irandom(30), max_life : 70,
            size : random_range(0.1, 0.26),
            hot : 0.8 + random(0.2)
          });
        }
      } else {
        scr_floor_impact(x, other._k_rain_floor_y, 0.14, 0);
      }
      instance_destroy();
    }
  }
}

for (var i = array_length(rain_splashes) - 1; i >= 0; i--) {
  rain_splashes[i].life--;
  if (rain_splashes[i].life <= 0) array_delete(rain_splashes, i, 1);
}

if (t >= 1735 && t < 1840) {
  if (!variable_instance_exists(id, "orb_drop_timer")) {
    orb_drop_timer = irandom_range(_k_drop_interval_min, _k_drop_interval_max);
  }

  orb_drop_timer--;
  if (orb_drop_timer <= 0) {
    var _drip_pool = [];
    with (oFallingRedOrb) {
      if (rain_orb && !dissolving && tether_state == 0) array_push(_drip_pool, id);
    }

    if (array_length(_drip_pool) > 0) {
      var _chosen = _drip_pool[irandom(array_length(_drip_pool) - 1)];
      orbrain_arm(_chosen, false, -99);
      _chosen.drip_fuse = _k_telegraph_frames + 3;
      _chosen.socket_heat = 0.6;
    }

    var _mult = 1;
    if (t > _k_escalate_start_t) {
      _mult = lerp(1, _k_escalate_min_mult, clamp((t - _k_escalate_start_t) / (1840 - _k_escalate_start_t), 0, 1));
    }
    orb_drop_timer = irandom_range(_k_drop_interval_min, _k_drop_interval_max) * _mult;
  }
}

if (timeline_hit_many(1712, 1733, 1752, 1773, 1793, 1814, 1835)) {
  var _k_rain_burst_count     = [ 2,     3,     4,     5,     6,     7,     10    ];
  var _k_rain_burst_shake     = [ 3,     4,     6,     8,     10,    12,    18    ];
  var _k_rain_burst_hailstone = [ false, false, true,  true,  true,  true,  true  ];

  var _hit_index = 0;
  if (timeline_hit(1712)) _hit_index = 0;
  else if (timeline_hit(1733)) _hit_index = 1;
  else if (timeline_hit(1752)) _hit_index = 2;
  else if (timeline_hit(1773)) _hit_index = 3;
  else if (timeline_hit(1793)) _hit_index = 4;
  else if (timeline_hit(1814)) _hit_index = 5;
  else if (timeline_hit(1835)) _hit_index = 6;

  storm_wind_target = ((_hit_index mod 2 == 0) ? 1 : -1) * (2.2 + _hit_index * 1.1);
  storm_sky_flash = max(storm_sky_flash, 0.4 + _hit_index * 0.09);
  var _k_beat_bolts = [ 1, 1, 2, 2, 3, 3, 5 ];
  for (var _sbi = 0; _sbi < _k_beat_bolts[_hit_index]; _sbi++) {
    array_push(storm_sky_bolts, {
      x : random_range(40, room_width - 40),
      y : random_range(30, 170),
      seed : random(1000),
      life : 10 + _hit_index, life_max : 10 + _hit_index,
      w : random_range(2, 4 + _hit_index * 0.5)
    });
  }

  var _epi_x = random_range(90, room_width - 90);
  orb_ceiling_epi  = _epi_x;
  orb_ceiling_flex = 7 + _hit_index * 3.4;
  orb_ceiling_heat = 1;
  orb_rain_flash   = 1;
  orb_rain_beat    = _hit_index;

  for (var _cd = 0; _cd < 2; _cd++) {
    array_push(orb_cracks, {
      x : _epi_x,
      dir : (_cd == 0) ? -1 : 1,
      reach : 0,
      speed : _k_orbrain_crack_speed * (0.82 + _hit_index * 0.07),
      life : _k_orbrain_crack_life,
      life_max : _k_orbrain_crack_life,
      beat : _hit_index,
      seed : random(1000),
      w : 2.2 + _hit_index * 0.55
    });
  }

  array_push(orb_fronts, {
    epi : _epi_x,
    depth : 0,
    speed : _k_orbrain_front_speed * (0.86 + _hit_index * 0.06),
    beat : _hit_index,
    life : _k_orbrain_front_life,
    life_max : _k_orbrain_front_life,
    hot : clamp(0.4 + _hit_index * 0.11, 0, 1),
    seed : random(1000)
  });

  array_push(orb_shocks, {
    x : _epi_x, y : orbrain_seam_y(_epi_x),
    radius : 6,
    life : _k_orbrain_shock_life, life_max : _k_orbrain_shock_life,
    hot : clamp(0.35 + _hit_index * 0.12, 0, 1)
  });

  var _vn_beat = 3 + _hit_index;
  for (var _vb = 0; _vb < _vn_beat; _vb++) {
    var _vbx = _epi_x + random_range(-70, 70) * (1 + _hit_index * 0.25);
    scr_spawn_vent_stream(orb_rain_vents, _vbx, orbrain_seam_y(_vbx),
                          90 + random_range(-26, 26),
                          clamp(0.4 + _hit_index * 0.1, 0, 1),
                          _k_orbrain_vent_cols, _k_orbrain_vent_cap);
  }

  if (_hit_index == 6) {
    orb_finale_active = true;
    orb_finale = 0;
    orb_ceiling_flex = 26;

    for (var _fc = 0; _fc < 2; _fc++) {
      array_push(orb_cracks, {
        x : _epi_x,
        dir : (_fc == 0) ? -1 : 1,
        reach : 0,
        speed : _k_orbrain_crack_speed * 2.1,
        life : _k_orbrain_crack_life + 18,
        life_max : _k_orbrain_crack_life + 18,
        beat : -999,
        seed : random(1000),
        w : 6.5
      });
    }

    for (var _fs = 0; _fs < 3; _fs++) {
      array_push(orb_shocks, {
        x : _epi_x, y : orbrain_seam_y(_epi_x),
        radius : 6 + _fs * 40,
        life : _k_orbrain_shock_life + 14, life_max : _k_orbrain_shock_life + 14,
        hot : 1
      });
    }

    array_push(orb_fronts, {
      epi : _epi_x,
      depth : 0,
      speed : _k_orbrain_front_speed * 1.7,
      beat : -999,
      life : _k_orbrain_front_life + 20,
      life_max : _k_orbrain_front_life + 20,
      hot : 1,
      seed : random(1000)
    });

    for (var _fv = 0; _fv < 16; _fv++) {
      var _fvx = random_range(20, room_width - 20);
      scr_spawn_vent_stream(orb_rain_vents, _fvx, orbrain_seam_y(_fvx),
                            90 + random_range(-30, 30), 1,
                            _k_orbrain_vent_cols, _k_orbrain_vent_cap);
    }

    with (oFallingRedOrb) {
      if (!rain_orb || dissolving) continue;

      var _fd = abs(tether_ax - _epi_x) / max(room_width, 1);
      var _fdelay = round(_fd * 16);

      if (tether_state < 3) {
        array_push(other.orb_whips, {
          ax : tether_ax, ay : tether_ay,
          x : x, y : y,
          len : point_distance(tether_ax, tether_ay, x, y),
          vx : random_range(-2.5, 2.5),
          vy : -random_range(4, 8),
          life : other._k_orbrain_whip_life + 8,
          life_max : other._k_orbrain_whip_life + 8,
          heavy : true, seed : random(1000)
        });
        array_push(other.orb_sockets, {
          x : tether_ax, y : tether_ay,
          life : other._k_orbrain_socket_life, life_max : other._k_orbrain_socket_life,
          heavy : true, seed : random(1000)
        });
        tether_state = 3;
      }

      dissolving = true;
      hit_active = false;
      dissolve_timer = 0;
      dissolve_duration = 18;
      dissolve_delay = _fdelay;
      knock_vy = -random_range(4.5, 8);
      knock_vx = random_range(-1.6, 1.6);
      spin_rate = random_range(-9, 9);
    }

    storm_sweep = 0;
    storm_sweep_active = true;
    storm_sky_flash = max(storm_sky_flash, 1);
    storm_wind_target = 0;
    for (var _swb = 0; _swb < 7; _swb++) {
      array_push(storm_sky_bolts, {
        x : random_range(30, room_width - 30),
        y : random_range(30, 190),
        seed : random(1000),
        life : 16, life_max : 16,
        w : random_range(2.5, 6)
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_rain_burst_shake[_hit_index]);
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.4);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.1);
    }
    scr_impact_pulse(0.15 + _hit_index * 0.03, 0.2 + _hit_index * 0.05, 0.15 + _hit_index * 0.04);
    global_ripple_pulse = max(global_ripple_pulse, 0.2 + _hit_index * 0.03);
    vignette_pulse = max(vignette_pulse, 0.6);
    bloom_pulse = max(bloom_pulse, 0.6);
    aberration_pulse = max(aberration_pulse, 0.4);
    tear_amount = max(tear_amount, 0.18);
  } else {
    var _heavy_now = true;
    orbrain_arm_group(_hit_index, _k_rain_burst_count[_hit_index], _heavy_now,
                      _k_rain_burst_hailstone[_hit_index]);

    if (_hit_index < 6) {
      orbrain_arm_group(_hit_index + 1, _k_rain_burst_count[_hit_index + 1], true,
                        _k_rain_burst_hailstone[_hit_index + 1]);
    }

    with (oFallingRedOrb) {
      if (rain_orb && tether_state == 1) wind_drift = random_range(-0.6, 0.6);
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_rain_burst_shake[_hit_index]);
    }
    scr_impact_pulse(0.15 + _hit_index * 0.03, 0.2 + _hit_index * 0.05, 0.15 + _hit_index * 0.04);
    global_ripple_pulse = max(global_ripple_pulse, 0.2 + _hit_index * 0.03);
  }
}

if timeline_hit (1848) {
  with (oFallingRedOrb) {
    if (!dissolving) {
      dissolving = true;
      hit_active = false;
      dissolve_timer = 0;
      if (rain_orb) tether_state = 3;
    }
  }
}

if (timeline_hit(1872)) {
  orb_cracks = [];
  orb_fronts = [];
  orb_whips = [];
  orb_sockets = [];
  orb_shocks = [];
  orb_snap_motes = [];
  orb_rain_vents = [];
  orb_ceiling_built = false;
  orb_ceiling_flex = 0;
  orb_ceiling_heat = 0;
  orb_rain_flash = 0;
  orb_finale = 0;
  orb_finale_active = false;
  orb_rain_beat = -1;
}


if (t >= tree_telegraph_start_t && t < tree_telegraph_end_t) {
  var _tel_p = clamp((t - tree_telegraph_start_t) / (tree_telegraph_end_t - tree_telegraph_start_t), 0, 1);
  tree_telegraph_heat = _tel_p * _tel_p;

  tree_root_spurt_timer--;
  if (tree_root_spurt_timer <= 0) {
    tree_root_spurt_timer = round(lerp(9, 2, tree_telegraph_heat));
    var _base_i = irandom(array_length(tree_root_base_xs) - 1);
    var _bx = tree_root_base_xs[_base_i];

    array_push(tree_root_fissures, {
      x : _bx + random_range(-26, 26), y : tree_root_base_y,
      ang : 180 + random(180),
      len : random_range(18, 34) * (0.6 + tree_telegraph_heat),
      grow : 0,
      life : 60, life_max : 60
    });

    var _spurt_n = round(lerp(2, 7, tree_telegraph_heat));
    for (var _sp = 0; _sp < _spurt_n; _sp++) {
      array_push(global.tree_embers, {
        x : _bx + random_range(-18, 18),
        y : tree_root_base_y,
        xspeed : random_range(-0.9, 0.9),
        yspeed : -random_range(1.5, 3.5) * (0.7 + tree_telegraph_heat),
        life : 0,
        max_life : irandom_range(24, 46),
        color : merge_color(global.tree_fire_color, c_white, 0.15)
      });
    }

    var _spine_n = round(lerp(1, 4, tree_telegraph_heat));
    for (var _tsi0 = 0; _tsi0 < _spine_n; _tsi0++) {
      array_push(tree_root_spines, {
        x : _bx + random_range(-20, 20),
        y : tree_root_base_y + 3,
        ang : 270 + random_range(-18, 18),
        len : random_range(28, 76) * (0.45 + tree_telegraph_heat),
        life : 18 + round(tree_telegraph_heat * 10),
        life_max : 18 + round(tree_telegraph_heat * 10),
        w : random_range(2.2, 5.5),
        seed : random(1000),
        hot : tree_telegraph_heat
      });
    }

    scr_floor_impact(_bx, tree_root_base_y, 0.16 + tree_telegraph_heat * 0.3, 0);
  }

  tree_pre_next_pulse--;
  if (tree_pre_next_pulse <= 0) {
    tree_pre_next_pulse = round(lerp(16, 4, tree_telegraph_heat));
    for (var _bpi = 0; _bpi < array_length(tree_root_base_xs); _bpi++) {
      array_push(tree_pre_pulses, {
        x : tree_root_base_xs[_bpi], y : tree_root_base_y,
        radius : lerp(26, 74, tree_telegraph_heat),
        alpha : lerp(0.25, 0.8, tree_telegraph_heat),
        life : 18, life_max : 18
      });
    }
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, lerp(0.5, 5, tree_telegraph_heat));
    }
    vignette_pulse = max(vignette_pulse, lerp(0.03, 0.28, tree_telegraph_heat));
  }

  if (t >= 1840 && instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 1;
  }
}

for (var i = array_length(tree_root_fissures) - 1; i >= 0; i--) {
  var _tf = tree_root_fissures[i];
  _tf.grow = min(1, _tf.grow + 0.14);
  _tf.life--;
  if (_tf.life <= 0) array_delete(tree_root_fissures, i, 1);
}
for (var i = array_length(tree_pre_pulses) - 1; i >= 0; i--) {
  tree_pre_pulses[i].life--;
  if (tree_pre_pulses[i].life <= 0) array_delete(tree_pre_pulses, i, 1);
}
for (var i = array_length(tree_root_spines) - 1; i >= 0; i--) {
  var _trs = tree_root_spines[i];
  _trs.life--;
  if (_trs.life <= 0) array_delete(tree_root_spines, i, 1);
}
for (var i = array_length(tree_branch_sparks) - 1; i >= 0; i--) {
  var _tbs = tree_branch_sparks[i];
  _tbs.timer++;
  _tbs.life--;
  if (_tbs.life <= 0) array_delete(tree_branch_sparks, i, 1);
}
for (var i = array_length(tree_crown_pulses) - 1; i >= 0; i--) {
  var _tcp = tree_crown_pulses[i];
  _tcp.timer++;
  if (_tcp.timer >= _tcp.duration) array_delete(tree_crown_pulses, i, 1);
}
tree_network_flash = max(0, tree_network_flash - 0.06);
tree_crown_charge = (t >= 1900 && t < 2025) ? clamp((t - 1900) / 125, 0, 1) : max(0, tree_crown_charge - 0.04);
tree_root_rake_flash = max(0, tree_root_rake_flash - 0.055);
tree_root_rake_pressure = 0;
if (variable_instance_exists(id, "tree_root_rakes")) {
  for (var _rki = 0; _rki < array_length(tree_root_rakes); _rki++) {
    var _rkev = scr_tree_root_rake_eval(tree_root_rakes[_rki]);
    if (!_rkev.visible) continue;
    tree_root_rake_pressure = max(tree_root_rake_pressure,
                                  clamp(_rkev.acquire * 0.35 + _rkev.tense * 0.35 + _rkev.strike * 0.55, 0, 1));
  }
}
tree_fruit_hold_tension = (t >= tree_fruit_hold_brake_t && t < tree_fruit_hold_suction_t)
                        ? clamp((t - tree_fruit_hold_brake_t) / max(1, tree_fruit_hold_suction_t - tree_fruit_hold_brake_t), 0, 1)
                        : max(0, tree_fruit_hold_tension - 0.08);
tree_organism_tension = max(tree_root_rake_pressure, tree_fruit_hold_tension);
if (tree_organism_tension > 0.02) {
  tree_scar_flash = max(tree_scar_flash, tree_organism_tension * 0.26);
  tree_burn_heat = max(tree_burn_heat, tree_organism_tension * 0.32);
}

if (timeline_hit_many(2045, 2065, 2077, 2085, 2106, 2127)) {
  tree_root_rake_flash = max(tree_root_rake_flash, 0.72);
  tree_network_flash = max(tree_network_flash, 0.55);
  tree_scar_flash = max(tree_scar_flash, 0.45 + tree_organism_tension * 0.25);
  with (oTree) { spawn_snap = max(spawn_snap, 2.8); }
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 3 + tree_organism_tension * 5);
  }
  vignette_pulse = max(vignette_pulse, 0.08 + tree_organism_tension * 0.18);
}

if (tree_root_rake_pressure > 0.02) {
  tree_root_rake_debris_timer--;
  if (tree_root_rake_debris_timer <= 0) {
    tree_root_rake_debris_timer = round(lerp(8, 3, tree_root_rake_pressure));
    for (var _rki2 = 0; _rki2 < array_length(tree_root_rakes); _rki2++) {
      var _rk2 = tree_root_rakes[_rki2];
      var _ev2 = scr_tree_root_rake_eval(_rk2);
      if (!_ev2.visible) continue;
      var _edge_x2 = (_rk2.side < 0) ? 0 : room_width;
      var _spit = 1 + round(tree_root_rake_pressure * 2);
      for (var _rde = 0; _rde < _spit; _rde++) {
        array_push(global.tree_embers, {
          x : _edge_x2 + _rk2.side * random_range(-4, 18),
          y : tree_root_rake_floor_y - random_range(0, 36),
          xspeed : -_rk2.side * random_range(0.4, 1.8),
          yspeed : -random_range(0.8, 2.6) * (0.7 + tree_root_rake_pressure),
          life : 0,
          max_life : irandom_range(18, 36),
          color : merge_color(global.tree_fire_color, c_white, 0.18 + _ev2.heat * 0.22)
        });
      }

      if (random(1) < tree_root_rake_pressure * 0.55) {
        array_push(tree_root_fissures, {
          x : _edge_x2 - _rk2.side * random_range(10, 70),
          y : tree_root_rake_floor_y,
          ang : (_rk2.side < 0) ? random_range(335, 380) : random_range(160, 205),
          len : random_range(20, 58) * (0.6 + tree_root_rake_pressure),
          grow : 0,
          life : 32,
          life_max : 32
        });
      }
    }
  }
}
scr_tree_root_rake_collision();

if (timeline_hit(1856)) {
  var _tree_target_x = clamp(oPlayer.x, 40, room_width - 40);
  var _tree_target_y = oPlayer.y - 30;
  tree_data = scr_generate_tree(_tree_target_x, _tree_target_y);
  if (DEBUG) show_debug_message(variable_struct_exists(tree_data, "nodes"));
  scr_compute_tree_ignite_delays(tree_data, 3);
  tree_spawn_mid = array_length(tree_data.nodes) div 2;
  tree_leaf_indices = scr_get_leaf_nodes(tree_data);

  var _k_tree_ignite_duration = 78;
  var _raw_max_delay = 0;
  for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
    _raw_max_delay = max(_raw_max_delay, tree_data.nodes[_tmi].ignite_delay);
  }
  if (_raw_max_delay > 0) {
    var _ignite_scale = _k_tree_ignite_duration / _raw_max_delay;
    for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
      tree_data.nodes[_tmi].ignite_delay = round(tree_data.nodes[_tmi].ignite_delay * _ignite_scale);
    }
  }

  tree_max_ignite_delay = 0;
  for (var _tmi = 0; _tmi < array_length(tree_data.nodes); _tmi++) {
    tree_max_ignite_delay = max(tree_max_ignite_delay, tree_data.nodes[_tmi].ignite_delay);
  }
  tree_payoff_t = tree_ignite_start_t + tree_max_ignite_delay;

  scr_spawn_tree_half(tree_data, 0, tree_spawn_mid);

  for (var _rb2 = 0; _rb2 < array_length(tree_root_base_xs); _rb2++) {
    var _rbx = tree_root_base_xs[_rb2];

    array_push(tree_shockwaves, {
      x: _rbx, y: tree_root_base_y, radius: 0, max_radius: 190, alpha: 1,
      color: merge_color(global.tree_fire_color, c_white, 0.4)
    });

    scr_floor_impact(_rbx, tree_root_base_y, 1.0, 1, global.tree_fire_color);

    var _ember_count = irandom_range(14, 20);
    for (var e = 0; e < _ember_count; e++) {
      array_push(global.tree_embers, {
        x : _rbx + random_range(-26, 26),
        y : tree_root_base_y - random_range(0, 18),
        xspeed : random_range(-2.2, 2.2),
        yspeed : -random_range(1.5, 4.5),
        life : 0,
        max_life : irandom_range(30, 60),
        color : merge_color(global.tree_fire_color, c_black, 0.55)
      });
    }

    for (var _rp = 0; _rp < 26; _rp++) {
      var _rang = 200 + random(140);
      var _rspd = random_range(4, 12);
      array_push(arrow_ring_particles, {
        x : _rbx + random_range(-14, 14), y : tree_root_base_y,
        vx : lengthdir_x(_rspd, _rang),
        vy : lengthdir_y(_rspd, _rang),
        life : 30, max_life : 30,
        size : random_range(0.14, 0.4),
        grav : 0.24, drag : 0.965,
        hot : 0.55 + random(0.35)
      });
    }

    for (var _rs = 0; _rs < 10; _rs++) {
      array_push(tree_root_spines, {
        x : _rbx + random_range(-28, 28),
        y : tree_root_base_y + 4,
        ang : 270 + random_range(-26, 26),
        len : random_range(80, 180),
        life : irandom_range(20, 34),
        life_max : 34,
        w : random_range(3.5, 8.5),
        seed : random(1000),
        hot : 1
      });
    }
  }
  tree_network_flash = 1;

  array_push(ring_bursts, {
    x: storm_orb_x, y: storm_orb_y,
    shockwave_radius: 0, shockwave_max_radius: 260,
    shockwave_alpha: 0.5, shockwave_alpha_start: 0.5,
    life: 40
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 16);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.18);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.35);
    oCameraController.letterbox_target = 0;
  }
  scr_impact_pulse(0.4, 0.4, 0.4, room_width / 2, tree_root_base_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.45);
  tear_amount = max(tear_amount, 0.3);
  tree_telegraph_heat = 0;
}

for (var i = array_length(tree_shockwaves) - 1; i >= 0; i--) {
  var _sw = tree_shockwaves[i];

  _sw.radius += 20;
  _sw.alpha -= 0.06;

  if (_sw.alpha <= 0) {
    array_delete(tree_shockwaves, i, 1);
  }
}

if (timeline_hit(1875)) {
  scr_spawn_tree_half(tree_data, tree_spawn_mid, array_length(tree_data.nodes));
}
if (timeline_hit(1875)) {
  var _crown_sum_x = 0, _crown_sum_y = 0;
  for (var i = 0; i < array_length(tree_leaf_indices); i++) {
    var _node = tree_data.nodes[tree_leaf_indices[i]];
    var _fruit = instance_create_layer(_node.x, _node.y, layer, oFruit);

    _fruit.spawn_burst = true;
    _fruit.anchor_x = _node.x;
    _fruit.anchor_y = _node.y;
    _fruit.anchor_index = tree_leaf_indices[i];
    _crown_sum_x += _node.x;
    _crown_sum_y += _node.y;
  }
  if (array_length(tree_leaf_indices) > 0) {
    tree_crown_center_x = _crown_sum_x / array_length(tree_leaf_indices);
    tree_crown_center_y = _crown_sum_y / array_length(tree_leaf_indices);
  }
  with (oFruit) {
    crown_x = oAvoidanceController.tree_crown_center_x;
    crown_y = oAvoidanceController.tree_crown_center_y;
  }

  with(oTree) { spawn_snap = max(spawn_snap, 3); }
  tree_network_flash = max(tree_network_flash, 0.65);
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 30,
    radius : 120, width : 9,
    color : global.avoid_col_cyan,
    hot : 0.45
  });
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 38,
    radius : 190, width : 14,
    color : merge_color(global.tree_fire_color, c_white, 0.25),
    hot : 0.7
  });

  for (var _fri = 0; _fri < array_length(tree_leaf_indices); _fri++) {
    var _fn = tree_data.nodes[tree_leaf_indices[_fri]];
    array_push(fruit_shockwaves, {x: _fn.x, y: _fn.y, radius: 0, max_radius: 34, alpha: 0.55});
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 8);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.09);
  }
  scr_impact_pulse(0.24, 0.28, 0.3, tree_crown_center_x, tree_crown_center_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.22);
}

if (t >= 1875 && t < 2025
&& variable_instance_exists(id, "tree_data")
&& !is_undefined(tree_data)
&& is_struct(tree_data)
&& variable_struct_exists(tree_data, "nodes")
&& array_length(tree_data.nodes) > 1) {
  var _flow_heat = max(tree_burn_heat, clamp((t - 1895) / 130, 0, 1));
  tree_branch_spark_timer--;
  if (tree_branch_spark_timer <= 0) {
    tree_branch_spark_timer = round(lerp(9, 2, _flow_heat));
    var _spark_count = round(lerp(1, 7, _flow_heat));
    var _node_count = array_length(tree_data.nodes);
    for (var _sbi = 0; _sbi < _spark_count; _sbi++) {
      var _pick = -1;
      for (var _try = 0; _try < 8; _try++) {
        var _candidate = irandom(_node_count - 1);
        if (tree_data.nodes[_candidate].parent != -1) {
          _pick = _candidate;
          break;
        }
      }
      if (_pick == -1) continue;
      array_push(tree_branch_sparks, {
        node : _pick,
        timer : 0,
        life : irandom_range(14, 24),
        life_max : 24,
        hot : _flow_heat,
        cyan : random(1) < lerp(0.45, 0.14, _flow_heat),
        seed : random(1000)
      });
    }
  }
}

if (timeline_hit_many(1993, 2003, 2013, 2019)) {
  var _k_sky_strike_count  = [ 1,    2,    3,    1    ];
  var _k_sky_ring_radius   = [ 150,  220,  300,  120  ];
  var _k_sky_ring_alpha    = [ 0.6,  0.75, 0.9,  0.5  ];
  var _k_sky_strike_shake  = [ 5,    8,    12,   3    ];

  var _sky_tier = 0;
  if (timeline_hit(1993)) {
    _sky_tier = 0;
    scr_tree_crack_pulse(0);
    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = 1;
    }
  } else if (timeline_hit(2003)) {
    _sky_tier = 1;
    scr_tree_crack_pulse(1);
  } else if (timeline_hit(2013)) {
    _sky_tier = 2;
    scr_tree_crack_pulse(2);
  } else if (timeline_hit(2019)) {
    _sky_tier = 3;
    scr_tree_crack_pulse(3);
  }

  for (var ssi = 0; ssi < _k_sky_strike_count[_sky_tier]; ssi++) {
    var _strike_tx = tree_crown_center_x + random_range(-40, 40);
    var _strike_ty = tree_crown_center_y + random_range(-20, 20);
    sky_strike_id_counter++;
    array_push(sky_strikes, {
      ox: _strike_tx + random_range(-70, 70), oy: -80,
      tx: _strike_tx, ty: _strike_ty,
      life: 16, life_max: 16
    });
  }

  array_push(ring_bursts, {
    x: tree_crown_center_x, y: tree_crown_center_y,
    shockwave_radius: 0, shockwave_max_radius: _k_sky_ring_radius[_sky_tier],
    shockwave_alpha: _k_sky_ring_alpha[_sky_tier], shockwave_alpha_start: _k_sky_ring_alpha[_sky_tier],
    life: 40
  });
  tree_network_flash = max(tree_network_flash, 0.55 + _sky_tier * 0.15);
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 18 + _sky_tier * 4,
    radius : _k_sky_ring_radius[_sky_tier] * 0.55,
    width : 7 + _sky_tier * 3,
    color : (_sky_tier < 2) ? global.avoid_col_cyan : global.avoid_col_danger,
    hot : 0.55 + _sky_tier * 0.13
  });
  if (variable_instance_exists(id, "tree_data") && !is_undefined(tree_data) && is_struct(tree_data)) {
    var _node_count2 = array_length(tree_data.nodes);
    var _pulse_sparks = 10 + _sky_tier * 7;
    if (_node_count2 > 1) {
      for (var _psi = 0; _psi < _pulse_sparks; _psi++) {
        var _pick2 = irandom(_node_count2 - 1);
        if (tree_data.nodes[_pick2].parent == -1) continue;
        array_push(tree_branch_sparks, {
          node : _pick2,
          timer : 0,
          life : irandom_range(16, 28),
          life_max : 28,
          hot : 0.75 + _sky_tier * 0.08,
          cyan : _sky_tier < 2,
          seed : random(1000)
        });
      }
    }
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_sky_strike_shake[_sky_tier]);
  }
  aberration_pulse = max(aberration_pulse, 0.2 + _sky_tier * 0.08);
}

if (t >= 1900) {
for (var i = array_length(sky_strikes) - 1; i >= 0; i--) {
  sky_strikes[i].life--;
  if (sky_strikes[i].life <= 0) array_delete(sky_strikes, i, 1);
}
for (var i = array_length(ring_bursts) - 1; i >= 0; i--) {
  var _rb = ring_bursts[i];
  _rb.life--;
  if (_rb.shockwave_radius < _rb.shockwave_max_radius) {
    _rb.shockwave_radius += 8;
    var _rb_prog = _rb.shockwave_radius / _rb.shockwave_max_radius;
    var _rb_start_alpha = variable_struct_exists(_rb, "shockwave_alpha_start") ? _rb.shockwave_alpha_start : 0.5;
    _rb.shockwave_alpha = _rb_start_alpha * (1 - _rb_prog);
  } else {
    _rb.shockwave_alpha = 0;
  }
  if (_rb.life <= 0) array_delete(ring_bursts, i, 1);
}
}

if (!fruit_explosion_triggered && timeline_hit(2025)) {
  fruit_explosion_triggered = true;
  var _fruit_count = instance_number(oFruit);
  with(oFruit) {
    explode_pending = true;
    explode_timer = 0;
    cocoon_rupture_flash = max(cocoon_rupture_flash, 1.2);
    cocoon_crack_flash = max(cocoon_crack_flash, 1.4);
  }

  global.tree_embers = [];

  var _fruit_scale = clamp(_fruit_count / 6, 1, 2.2);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 16 * _fruit_scale);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.5);
    oCameraController.letterbox_target = 0;
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.18);
  }
  vignette_pulse = max(vignette_pulse, 0.7 * min(_fruit_scale, 1.3));
  bloom_pulse = max(bloom_pulse, 0.8 * min(_fruit_scale, 1.3));
  aberration_pulse = max(aberration_pulse, 0.6 * min(_fruit_scale, 1.3));
  global_ripple_pulse = max(global_ripple_pulse, 0.7);
  tear_amount = max(tear_amount, 0.8);

  var _finale_streak_count = 16;
  for (var fs = 0; fs < _finale_streak_count; fs++) {
    array_push(fruit_streaks, {
      x: tree_crown_center_x, y: tree_crown_center_y,
      angle: (360 / _finale_streak_count) * fs + random_range(-8, 8),
      len: 0, max_len: random_range(60, 110),
      timer: 0, duration: 16,
      color: merge_color(global.tree_fire_color, c_white, 0.4),
      fringe: true
    });
  }
  array_push(fruit_shockwaves, {x: tree_crown_center_x, y: tree_crown_center_y, radius: 0, max_radius: 220, alpha: 1});
  tree_network_flash = 1.2;
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 24,
    radius : 320, width : 22,
    color : c_white,
    hot : 1.2
  });

  tree_scar_segments = [];
  tree_scar_motes = [];

  var _scar_max_w = 0.001;
  for (var _tsi = 0; _tsi < array_length(tree_data.nodes); _tsi++) {
    var _tsn0 = tree_data.nodes[_tsi];
    if (!variable_struct_exists(_tsn0, "base_scale")) continue;
    _scar_max_w = max(_scar_max_w, _tsn0.base_scale);
  }

  for (var _tsi = 0; _tsi < array_length(tree_data.nodes); _tsi++) {
    var _tsn = tree_data.nodes[_tsi];
    if (!variable_struct_exists(_tsn, "inst")) continue;
    if (_tsn.parent == -1) continue;
    var _tsp = tree_data.nodes[_tsn.parent];

    var _tsw = variable_struct_exists(_tsn, "base_scale") ? _tsn.base_scale : 1;
    var _thin01 = 1 - clamp(_tsw / _scar_max_w, 0, 1);

    array_push(tree_scar_segments, {
      ax : _tsn.x, ay : _tsn.y,
      bx : _tsp.x, by : _tsp.y,
      w : _tsw * _k_scar_width_mult,
      thin01 : _thin01,
      burn_at : clamp(lerp(_k_scar_burn_max, _k_scar_burn_min, _thin01) + random_range(-0.07, 0.07),
                      0.12, 1),
      seed : random(1000),
      len : point_distance(_tsn.x, _tsn.y, _tsp.x, _tsp.y),
      dead : false
    });
  }
  tree_scar_alpha = 1;
  tree_scar_flash = 1;

  for (var _dsi2 = 0; _dsi2 < array_length(tree_leaf_indices); _dsi2++) {
    var _dsn = tree_data.nodes[tree_leaf_indices[_dsi2]];
    var _ds_ang = point_direction(tree_crown_center_x, tree_crown_center_y, _dsn.x, _dsn.y)
                  + random_range(-14, 14);
    array_push(fruit_streaks, {
      x: _dsn.x, y: _dsn.y,
      angle: _ds_ang,
      len: 0, max_len: random_range(45, 90),
      timer: 0, duration: 20,
      color: merge_color(global.tree_fire_color, c_white, 0.25),
      fringe: true
    });
  }
}
for (var i = array_length(fruit_bursts) - 1; i >= 0; i--) {
  fruit_bursts[i].timer += 1;
  if (fruit_bursts[i].timer >= fruit_bursts[i].duration) array_delete(fruit_bursts, i, 1);
}
for (var i = array_length(fruit_shockwaves) - 1; i >= 0; i--) {
  var _sw = fruit_shockwaves[i];
  _sw.radius += (_sw.max_radius / 14);
  _sw.alpha -= 0.8 / 14;
  if (_sw.alpha <= 0) array_delete(fruit_shockwaves, i, 1);
}
for (var i = array_length(fruit_streaks) - 1; i >= 0; i--) {
  var _st = fruit_streaks[i];
  _st.timer += 1;
  _st.len = lerp(0, _st.max_len, clamp(_st.timer / _st.duration, 0, 1));
  if (_st.timer >= _st.duration) array_delete(fruit_streaks, i, 1);
}
if (tree_scar_alpha > 0) {
  tree_scar_alpha = max(0, tree_scar_alpha - _k_scar_fade);
  var _scar_burn = 1 - tree_scar_alpha;

  for (var i = 0; i < array_length(tree_scar_segments); i++) {
    var _sg = tree_scar_segments[i];
    if (_sg.dead || _scar_burn < _sg.burn_at) continue;

    _sg.dead = true;
    var _crumb = (_sg.thin01 > 0.6) ? 1 : 2;
    for (var _cbi = 0; _cbi < _crumb; _cbi++) {
      var _cb_t = random(1);
      array_push(tree_scar_motes, {
        x : lerp(_sg.ax, _sg.bx, _cb_t),
        y : lerp(_sg.ay, _sg.by, _cb_t),
        vx : random_range(-0.5, 0.5),
        vy : random_range(-0.4, 0.5),
        life : irandom_range(28, 55), life_max : 55,
        size : lerp(0.09, 0.26, 1 - _sg.thin01)
      });
    }
  }
}
tree_scar_flash = max(0, tree_scar_flash - 0.085);

for (var i = array_length(tree_scar_motes) - 1; i >= 0; i--) {
  var _sm = tree_scar_motes[i];
  _sm.x += _sm.vx;
  _sm.y += _sm.vy;
  _sm.vy += 0.035;
  _sm.vx *= 0.985;
  _sm.life--;
  if (_sm.life <= 0) array_delete(tree_scar_motes, i, 1);
}
var _k_sphere_fadein_frames = 10;
var _k_sphere_close_frames = 40;
var _sphere_end_t = 1933 + _k_sphere_close_frames;

storm_sphere_visibility = 0;
storm_orb_radius = 0;

if (t >= 1856 && t < _sphere_end_t) {
  if (t < 1856 + _k_sphere_fadein_frames) {
    storm_sphere_visibility = clamp((t - 1856) / _k_sphere_fadein_frames, 0, 1);
  } else if (t < 1933) {
    storm_sphere_visibility = 1;
  } else {
    storm_sphere_visibility = clamp(1 - (t - 1933) / _k_sphere_close_frames, 0, 1);
  }

  if (t < 1894) {
    var _idle_p = clamp((t - 1856) / _k_sphere_fadein_frames, 0, 1);
    storm_orb_radius = lerp(0, 14, _idle_p);
    storm_orb_pulse_freq = 0.05;
    storm_orb_scale_punch = 1;
    storm_charge_arc_timer--;
    if (storm_charge_arc_timer <= 0) {
      storm_charge_arc_timer = 14;
      array_push(storm_charge_arcs, {ang: random(360), life: 10, life_max: 10});
    }
  } else if (t < 1933) {
    var _charge_prog = clamp((t - 1894) / 39, 0, 1);
    storm_orb_radius = lerp(14, 46, _charge_prog);
    storm_orb_pulse_freq = lerp(0.06, 0.3, _charge_prog);
    storm_orb_scale_punch = 1 + storm_charge_beat_punch;

    storm_charge_arc_timer--;
    if (storm_charge_arc_timer <= 0) {
      storm_charge_arc_timer = round(lerp(10, 3, _charge_prog));
      array_push(storm_charge_arcs, {ang: random(360), life: 10, life_max: 10});
    }

    if (t mod 3 == 0) {
      var _cm_ang = random(360);
      array_push(converge_motes, {
        cx : storm_orb_x, cy : storm_orb_y,
        ang : _cm_ang,
        dist : random_range(150, 300),
        dest : _k_storm_clearing_radius,
        speed : lerp(3.5, 9, _charge_prog),
        size : random_range(0.12, 0.3),
        spin : choose(-1, 1) * random_range(0.8, 2.4),
        hot : 0.5 + _charge_prog * 0.5,
        feed : "storm"
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, lerp(0, 3, _charge_prog));
    }
    vignette_pulse = max(vignette_pulse, lerp(0, 0.25, _charge_prog));

    if (timeline_hit(1916)) {
      storm_charge_beat_punch = 0.55;
      for (var _gi = 0; _gi < 8; _gi++) {
        array_push(storm_charge_arcs, {ang: random(360), life: 12, life_max: 12});
      }
      array_push(sky_strikes, {
        ox : storm_orb_x + random_range(-70, 70), oy : -100,
        tx : storm_orb_x + random_range(-16, 16), ty : storm_orb_y,
        life : 16, life_max : 16
      });
      array_push(ring_bursts, {
        x: storm_orb_x, y: storm_orb_y,
        shockwave_radius: 0, shockwave_max_radius: 150,
        shockwave_alpha: 0.55, shockwave_alpha_start: 0.55,
        life: 40
      });
      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 7);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05);
      }
      scr_impact_pulse(0.3, 0.25, 0.3, storm_orb_x, storm_orb_y);
      global_ripple_pulse = max(global_ripple_pulse, 0.25);
      with (oTree) { spawn_snap = max(spawn_snap, 2.5); }
    }
  } else if (t < 1933 + 16) {
    var _diss_p = clamp((t - 1933) / 16, 0, 1);
    storm_orb_radius = lerp(46, 0, _diss_p) * (1 - _diss_p * 0.6);
    storm_orb_scale_punch = lerp(1, 1.6, _diss_p);
    storm_orb_pulse_freq = 0.3;
  }
}

for (var i = array_length(storm_charge_arcs) - 1; i >= 0; i--) {
  storm_charge_arcs[i].life--;
  if (storm_charge_arcs[i].life <= 0) array_delete(storm_charge_arcs, i, 1);
}
storm_charge_beat_punch = max(0, storm_charge_beat_punch - 0.06);
for (var i = array_length(storm_discharge_arcs) - 1; i >= 0; i--) {
  storm_discharge_arcs[i].life--;
  if (storm_discharge_arcs[i].life <= 0) array_delete(storm_discharge_arcs, i, 1);
}

if (!storm_charge_released && timeline_hit(1933)) {
  storm_charge_released = true;

  for (var rsi = 0; rsi < 5; rsi++) {
    var _rtx = storm_orb_x + random_range(-50, 50);
    var _rty = storm_orb_y + random_range(-20, 20);
    sky_strike_id_counter++;
    array_push(sky_strikes, {
      ox: _rtx + random_range(-40, 40), oy: -80,
      tx: _rtx, ty: _rty,
      life: 18, life_max: 18
    });
  }

  var _dis_targets = min(12, array_length(tree_leaf_indices));
  for (var _dsi = 0; _dsi < _dis_targets; _dsi++) {
    var _leaf = tree_data.nodes[tree_leaf_indices[irandom(array_length(tree_leaf_indices) - 1)]];
    array_push(storm_discharge_arcs, {
      tx : _leaf.x, ty : _leaf.y,
      life : 14, life_max : 14,
      bolt_id : "stormdis_" + string(_dsi)
    });
    for (var _de = 0; _de < 3; _de++) {
      array_push(global.tree_embers, {
        x : _leaf.x, y : _leaf.y,
        xspeed : random_range(-1.6, 1.6),
        yspeed : random_range(-2.2, 1.4),
        life : 0,
        max_life : irandom_range(22, 44),
        color : merge_color(global.tree_fire_color, c_white, 0.35)
      });
    }
  }
  with (oTree) { spawn_snap = max(spawn_snap, 6); }
  with (oFruit) { crack_flash = max(crack_flash, 1.2); crack_glow = max(crack_glow, 1.2); crack_timer = 8; }
  tree_network_flash = max(tree_network_flash, 0.9);
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 28,
    radius : 210, width : 12,
    color : global.avoid_col_cyan,
    hot : 0.85
  });

  array_push(ring_bursts, {
    x: storm_orb_x, y: storm_orb_y,
    shockwave_radius: 0, shockwave_max_radius: 240,
    shockwave_alpha: 0.9, shockwave_alpha_start: 0.9,
    life: 40
  });
  array_push(ring_bursts, {
    x: storm_orb_x, y: storm_orb_y,
    shockwave_radius: 0, shockwave_max_radius: 400,
    shockwave_alpha: 0.45, shockwave_alpha_start: 0.45,
    life: 40
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 15);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.14);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.4);
  }
  scr_impact_pulse(0.5, 0.4, 0.5, storm_orb_x, storm_orb_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.5);
  tear_amount = max(tear_amount, 0.4);
}

if (timeline_hit(tree_ignite_start_t)) {
  for (var i = 0; i < array_length(tree_data.nodes); i++) {
    var _node = tree_data.nodes[i];
    if (!variable_struct_exists(_node, "inst") || !instance_exists(_node.inst)) continue;
    _node.inst.ignite_delay = _node.ignite_delay;
    _node.inst.ignite_pending = true;
  }
  tree_network_flash = max(tree_network_flash, 0.75);
  array_push(tree_crown_pulses, {
    x : storm_orb_x, y : storm_orb_y,
    timer : 0, duration : 24,
    radius : 150, width : 10,
    color : merge_color(global.avoid_col_cyan, c_white, 0.25),
    hot : 0.55
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 9);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.07);
  }
  scr_impact_pulse(0.3, 0.3, 0.35, storm_orb_x, storm_orb_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.28);
}

if (!tree_payoff_triggered && tree_payoff_t > 0 && t >= tree_payoff_t && t < 2025) {
  tree_payoff_triggered = true;
  tree_payoff_flash_timer = 0;
  tree_burn_heat = 1;
  tree_network_flash = 1;
  array_push(tree_crown_pulses, {
    x : tree_crown_center_x, y : tree_crown_center_y,
    timer : 0, duration : 34,
    radius : 250, width : 16,
    color : merge_color(global.tree_fire_color, c_white, 0.35),
    hot : 1
  });

  for (var _pfi = 0; _pfi < array_length(tree_leaf_indices); _pfi++) {
    var _pn = tree_data.nodes[tree_leaf_indices[_pfi]];
    for (var _pe = 0; _pe < 3; _pe++) {
      array_push(global.tree_embers, {
        x : _pn.x, y : _pn.y,
        xspeed : random_range(-1.4, 1.4),
        yspeed : random_range(-2.4, 1.2),
        life : 0,
        max_life : irandom_range(26, 52),
        color : merge_color(global.tree_fire_color, c_white, 0.3)
      });
    }
  }

  array_push(ring_bursts, {
    x: tree_crown_center_x, y: tree_crown_center_y,
    shockwave_radius: 0, shockwave_max_radius: 240,
    shockwave_alpha: 0.7, shockwave_alpha_start: 0.7,
    life: 40
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 11);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.09);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.2);
  }
  scr_impact_pulse(0.38, 0.3, 0.45, tree_crown_center_x, tree_crown_center_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.35);
}
if (tree_payoff_triggered && tree_payoff_flash_timer < 20) tree_payoff_flash_timer++;

if (t >= 1940 && t < 1993) {
  var _burn_p = clamp((t - 1940) / (1993 - 1940), 0, 1);
  tree_burn_heat = max(tree_burn_heat, 0.25 + _burn_p * 0.55);

  tree_burn_next_pulse--;
  if (tree_burn_next_pulse <= 0) {
    tree_burn_next_pulse = round(lerp(22, 7, _burn_p));
    array_push(tree_pre_pulses, {
      x : tree_crown_center_x, y : tree_crown_center_y,
      radius : lerp(50, 130, _burn_p),
      alpha : lerp(0.2, 0.5, _burn_p),
      life : 22, life_max : 22
    });
    with (oTree) { spawn_snap = max(spawn_snap, lerp(0.8, 2.2, _burn_p)); }
    vignette_pulse = max(vignette_pulse, lerp(0.05, 0.2, _burn_p));
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, lerp(0.6, 3.5, _burn_p));
    }
  }

  tree_canopy_drip_timer--;
  if (tree_canopy_drip_timer <= 0) {
    tree_canopy_drip_timer = round(lerp(6, 2, _burn_p));
    with (oFruit) {
      if (random(1) > lerp(0.25, 0.7, _burn_p)) continue;
      array_push(global.tree_embers, {
        x : x + random_range(-4, 4), y : y + 4,
        xspeed : random_range(-0.25, 0.25),
        yspeed : random_range(0.9, 2.2),
        life : 0,
        max_life : irandom_range(18, 34),
        color : merge_color(global.tree_fire_color, c_white, 0.2)
      });
    }
  }
}
tree_burn_heat = max(0, tree_burn_heat - 0.02);

for (var i = array_length(global.tree_embers) - 1; i >= 0; i--) {
  var _em = global.tree_embers[i];
  _em.x += _em.xspeed;
  _em.y += _em.yspeed;
  _em.yspeed += 0.03;
  _em.life += 1;
  if (_em.life >= _em.max_life) {
    array_delete(global.tree_embers, i, 1);
  }
}

if timeline_hit_many (2025, 2045) {
  var _k_scatter_count = 5;
  var _zone_ang = 360 / _k_scatter_count;
  for (var i = 0; i < _k_scatter_count; ++i) {
    var _spawn_ang = i * _zone_ang + random_range(0, _zone_ang);

    var _dir_x = lengthdir_x(1, _spawn_ang);
    var _dir_y = lengthdir_y(1, _spawn_ang);
    var _t_x = (abs(_dir_x) > 0.0001) ? (400 / abs(_dir_x)) : 99999;
    var _t_y = (abs(_dir_y) > 0.0001) ? (304 / abs(_dir_y)) : 99999;
    var _spawn_dist = min(_t_x, _t_y) + random_range(100, 200);
    var _sx = 400 + _dir_x * _spawn_dist;
    var _sy = 304 + _dir_y * _spawn_dist;

    var _scatter_orb = instance_create_layer(_sx, _sy, layer, oRedOrb);
    _scatter_orb.image_alpha = 0.1;
    _scatter_orb.fruit_seed_visual = true;
    _scatter_orb.fruit_seed_color = global.tree_fire_color;
    _scatter_orb.fruit_seed_heat = 1.05;
    _scatter_orb.fruit_seed_ring_power = 1.2;
  }
}
if timeline_hit (2065) {
  with (oRedOrb) {
    ember_split = true;
    image_alpha = 1;
    fruit_seed_visual = true;
    fruit_seed_color = global.tree_fire_color;
    fruit_seed_heat = 1.15;
    fruit_seed_ring_power = 1.35;
    var _inside_room = (x >= 0 && x <= 800 && y >= 0 && y <= 608);
    if (_inside_room) {
      trail = 1;
      speed_up = true;
      speed_up_max = 14;
      speed_up_amount = 0.7;
      direction = 270;
      is_curving = true;
      curve_amount = choose(0.2, -0.2);
    }
  }
}
if timeline_hit (2085) {
  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 1;
  }
  ember_coil_next_pulse_t = 0;
  ember_coil_pulses = [];
  ember_coil_arcs = [];
}
if t
  >= 2085 && t < 2106 {
    with oRedOrb {
      if (ember_split) {
        speed = lerp(speed, 0, 0.15);
        if (speed < 0.1) speed = 0;
      }
    }

    var _coil_p = clamp((t - 2085) / (2106 - 2085), 0, 1);

    with oFruitBullet {
      if (post_reform && !fruit_imploding) {
        speed = lerp(speed, 0, 0.15);
        if (speed < 0.1) speed = 0;
        fruit_seed_ring_power = max(fruit_seed_ring_power, 1.25 + _coil_p * 0.45);
        fruit_seed_heat = max(fruit_seed_heat, 1.1 + _coil_p * 0.35);
      }
    }

    ember_coil_next_pulse_t -= 1;
    if (ember_coil_next_pulse_t <= 0) {
      ember_coil_next_pulse_t = lerp(11, 3, _coil_p);

      array_push(ember_coil_pulses, {
        radius : lerp(30, 70, _coil_p),
        alpha : lerp(0.35, 0.9, _coil_p),
        life : 16,
        life_max : 16
      });

      var _arc_count = round(lerp(2, 5, _coil_p));
      for (var _aci = 0; _aci < _arc_count; _aci++) {
        array_push(ember_coil_arcs, {
          ang : random(360),
          life : 10,
          life_max : 10,
          bolt_id : "coil" + string(t) + "_" + string(_aci)
        });
      }

      vignette_pulse = max(vignette_pulse, lerp(0.05, 0.22, _coil_p));
      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, lerp(1, 5, _coil_p));
      }
    }
  }

if timeline_hit (2106) {
  var _ember_positions = [];
  with(oRedOrb) {
    if (ember_split) {
      array_push(_ember_positions, [ x, y ]);
      instance_destroy(id);
    }
  }
  for (var _ei = 0; _ei < array_length(_ember_positions); _ei++) {
    var _px = _ember_positions[_ei][0];
    var _py = _ember_positions[_ei][1];
    var _child = instance_create_layer(_px, _py, layer, oRedOrb_2);
    _child.dying = true;
    _child.image_alpha = 1;
    _child.trail = 1;
    _child.orb_pop_scale = 2.5;
    _child.orb_pop_target = 1.0;
    _child.orb_pop_overshoot = true;
    _child.image_blend = c_white;
    _child.ember_glow_core = true;
    _child.fruit_seed_visual = true;
    _child.fruit_seed_color = global.tree_fire_color;
    _child.fruit_seed_heat = 1.25;
    _child.fruit_seed_ring_power = 1.45;

    array_push(ember_edge_glows, {bullet_id : _child, life : 12, fading : false,
                              mark_x : 0, mark_y : 0, mark_dir : 0, mark_dist : 9999, start_dist : -1});
  }
  with(oFruitBullet) {
    if (post_reform) {
      fruit_imploding = true;
      fruit_implosion_speed_mult = 1;
      fruit_implosion_speed_mult_target = 1;
      fruit_implosion_timer = 0;
      speed = 0;
      fruit_seed_heat = max(fruit_seed_heat, 1.25);
      fruit_seed_ring_power = max(fruit_seed_ring_power, 1.45);

      array_push(other.ember_edge_glows, {bullet_id : id, life : 12, fading : false,
                              mark_x : 0, mark_y : 0, mark_dir : 0, mark_dist : 9999, start_dist : -1});
    }
  }
  ember_implosion_timer = 0;
  ember_implosion_active = true;
  ember_implosion_spawn_rate = 66;
  ember_implosion_spawn_count = 1;
  ember_implosion_last_t = t;
  for (var _ei = 0; _ei < array_length(_ember_positions); _ei++) {
    var _px = _ember_positions[_ei][0];
    var _py = _ember_positions[_ei][1];
    array_push(ring_ripples, {x : _px, y : _py, radius : 5, alpha : 1, life : 16});
  }
  scr_bg_bass_hit();
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 14);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05);
  }
  vignette_pulse = max(vignette_pulse, 0.3);
  aberration_pulse = max(aberration_pulse, 0.35);
  bloom_pulse = max(bloom_pulse, 0.15);
  global_ripple_pulse = max(global_ripple_pulse, 0.3);
  swirl_center_x = 400;
  swirl_center_y = 304;
  swirl_radius_px = 260;

  swirl_target = 0.6;

  ember_coil_next_pulse_t = 999999;
}

if (timeline_hit_many(2127, 2147, 2168)) {
  var _crush_i = 0;
  if (timeline_hit(2147)) _crush_i = 1;
  else if (timeline_hit(2168)) _crush_i = 2;

  var _k_crush_start_r  = [ 300,  360,  430  ];
  var _k_crush_alpha    = [ 0.5,  0.68, 0.88 ];
  var _k_crush_band     = [ 18,   24,   32   ];
  var _k_crush_arcs     = [ 5,    8,    12   ];
  var _k_crush_spawn    = [ 3,    4,    6    ];
  var _k_crush_shake    = [ 8,    12,   16   ];
  var _k_crush_swirl    = [ 0.7,  0.82, 0.94 ];
  var _k_crush_vignette = [ 0.28, 0.38, 0.5  ];

  array_push(ember_crush_rings, {
    radius : _k_crush_start_r[_crush_i], start_radius : _k_crush_start_r[_crush_i],
    alpha : _k_crush_alpha[_crush_i],
    life : 26, life_max : 26,
    band : _k_crush_band[_crush_i]
  });
  ember_crush_heat = max(ember_crush_heat, 0.45 + _crush_i * 0.22);

  var _k_crush_reach = [ 300, 240, 180 ];
  for (var _cai2 = 0; _cai2 < _k_crush_arcs[_crush_i]; _cai2++) {
    array_push(ember_coil_arcs, {
      ang : random(360),
      life : 12, life_max : 12,
      reach : _k_crush_reach[_crush_i],
      bolt_id : "crush" + string(t) + "_" + string(_cai2)
    });
  }

  for (var _csi = 0; _csi < _k_crush_spawn[_crush_i]; _csi++) {
    var _cs_ang = (_csi / _k_crush_spawn[_crush_i]) * 360 + random_range(-14, 14);
    var _cs_dist = random_range(420, 560);
    var _cs_child = instance_create_layer(400 + lengthdir_x(_cs_dist, _cs_ang),
                                          304 + lengthdir_y(_cs_dist, _cs_ang), layer, oRedOrb_2);
    _cs_child.dying = true;
    _cs_child.image_alpha = 1;
    _cs_child.trail = 1;
    _cs_child.orb_pop_scale = 2.2;
    _cs_child.orb_pop_target = 0.9;
    _cs_child.orb_pop_overshoot = true;
    _cs_child.image_blend = c_white;
    _cs_child.ember_glow_core = true;
    _cs_child.fruit_seed_visual = true;
    _cs_child.fruit_seed_color = global.tree_fire_color;
    _cs_child.fruit_seed_heat = 1.25;
    _cs_child.fruit_seed_ring_power = 1.45;
    array_push(ember_edge_glows, {bullet_id : _cs_child, life : 12, fading : false,
                              mark_x : 0, mark_y : 0, mark_dir : 0, mark_dist : 9999, start_dist : -1});
  }

  scr_bg_bass_hit();
  swirl_target = max(swirl_target, _k_crush_swirl[_crush_i]);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_crush_shake[_crush_i]);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.03 + _crush_i * 0.02);
    oCameraController.letterbox_target = 1;
  }
  scr_impact_pulse(_k_crush_vignette[_crush_i], 0.2 + _crush_i * 0.12, 0.12 + _crush_i * 0.07, 400, 304);
  aberration_pulse = max(aberration_pulse, 0.25 + _crush_i * 0.12);
  global_ripple_pulse = max(global_ripple_pulse, 0.22 + _crush_i * 0.1);
}

for (var i = array_length(ember_crush_rings) - 1; i >= 0; i--) {
  var _cr = ember_crush_rings[i];
  _cr.life--;
  var _cr_p = 1 - clamp(_cr.life / _cr.life_max, 0, 1);
  _cr.radius = lerp(_cr.start_radius, 18, _cr_p * _cr_p);
  _cr.alpha *= 0.94;
  if (_cr.life <= 0 || _cr.alpha < 0.02) array_delete(ember_crush_rings, i, 1);
}
ember_crush_heat = max(0, ember_crush_heat - 0.018);

if timeline_hit (2188) {
  var _candidates = ds_list_create();
  with(oRedOrb_2) {
    if (dying && !dying_boosted) {
      ds_list_add(_candidates, id);
    }
  }
  var _total = ds_list_size(_candidates);
  var _half = floor(_total / 2);
  for (var i = 0; i < _total; i++) {
    var _swap = irandom(_total - 1);
    var _tmp = _candidates[| i];
    _candidates[| i] = _candidates[| _swap];
    _candidates[| _swap] = _tmp;
  }
  for (var i = 0; i < _half; i++) {
    var _orb_id = _candidates[| i];
    if (instance_exists(_orb_id)) {
      with(_orb_id) {
        dying_speed_mult = 4;
        dying_boosted = true;
        orb_pop_scale = 2.8;
        orb_pop_target = 1.0;
        orb_pop_overshoot = true;
        orb_pop_flash = 1;
        orb_pop_color = c_white;
        image_blend = c_white;
      }
    }
  }
  ds_list_destroy(_candidates);
  with(oFruitBullet) {
    if (post_reform && fruit_imploding && !fruit_implosion_boosted) {
      fruit_implosion_speed_mult_target = 4;
      fruit_implosion_boosted = true;
      fruit_seed_heat = max(fruit_seed_heat, 1.45);
      fruit_seed_ring_power = max(fruit_seed_ring_power, 1.65);
      image_xscale = max(image_xscale, 1.45);
      image_yscale = max(image_yscale, 1.45);
    }
  }
  scr_bg_bass_hit();
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 18);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.08);
    oCameraController.letterbox_target = 1;
  }
  vignette_pulse = max(vignette_pulse, 0.5);
  aberration_pulse = max(aberration_pulse, 0.6);
  bloom_pulse = max(bloom_pulse, 0.25);
  global_ripple_pulse = max(global_ripple_pulse, 0.4);

  swirl_target = 1.0;
}
if timeline_hit (2207) {
  var _candidates = ds_list_create();
  with(oRedOrb_2) {
    if (dying && !dying_boosted) {
      ds_list_add(_candidates, id);
    }
  }
  var _total = ds_list_size(_candidates);
  for (var i = 0; i < _total; i++) {
    var _orb_id = _candidates[| i];
    if (instance_exists(_orb_id)) {
      with(_orb_id) {
        dying_speed_mult = 6;
        dying_boosted = true;
        orb_pop_scale = 3.0;
        orb_pop_target = 1.0;
        orb_pop_overshoot = true;
        orb_pop_flash = 1;
        orb_pop_color = c_white;
        image_blend = c_white;
      }
    }
  }
  ds_list_destroy(_candidates);
  with(oFruitBullet) {
    if (post_reform && fruit_imploding) {
      fruit_implosion_speed_mult_target = 6;
      fruit_implosion_boosted = true;
      fruit_seed_heat = max(fruit_seed_heat, 1.55);
      fruit_seed_ring_power = max(fruit_seed_ring_power, 1.75);
      image_xscale = max(image_xscale, 1.6);
      image_yscale = max(image_yscale, 1.6);
    }
  }
  scr_bg_bass_hit();
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 22);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.16);
    oCameraController.letterbox_target = 0;
  }
  vignette_pulse = max(vignette_pulse, 0.7);
  aberration_pulse = max(aberration_pulse, 0.15);
  bloom_pulse = max(bloom_pulse, 0.35);
  global_ripple_pulse = max(global_ripple_pulse, 0.6);

  ember_implosion_active = false;

  swirl_target = 0;

  var _burst_cx = 400, _burst_cy = 304;
  var _k_burst_count = 40;
  var _k_burst_speed_min = 9;
  var _k_burst_speed_max = 17;

  var _burst_to_player_dir = instance_exists(oPlayer) ? point_direction(_burst_cx, _burst_cy, oPlayer.x, oPlayer.y) : -1;
  var _k_burst_danger_cone = 26;

  for (var _bi = 0; _bi < _k_burst_count; _bi++) {
    var _bang = (_bi / _k_burst_count) * 360 + random_range(-6, 6);
    if (_burst_to_player_dir != -1) {
      var _bdiff = angle_difference(_bang, _burst_to_player_dir);
      if (abs(_bdiff) < _k_burst_danger_cone) {
        var _bsign = (_bdiff >= 0) ? 1 : -1;
        _bang = _burst_to_player_dir + _bsign * (_k_burst_danger_cone + 10);
      }
    }
    var _child = instance_create_layer(_burst_cx, _burst_cy, layer, oRedOrb_2);
    _child.direction = _bang;
    _child.speed = random_range(_k_burst_speed_min, _k_burst_speed_max);
    _child.image_alpha = 1;
    _child.trail = 1;
    _child.image_blend = c_white;
    _child.orb_pop_scale = 3.2;
    _child.orb_pop_target = 1.0;
    _child.orb_pop_overshoot = true;
    _child.orb_pop_flash = 1;
    _child.ember_glow_core = true;
    _child.ember_drip = true;
    _child.fruit_seed_visual = true;
    _child.fruit_seed_color = global.tree_fire_color;
    _child.fruit_seed_heat = 1.35;
    _child.fruit_seed_ring_power = 1.5;
  }

  ember_burst_flash = 1;

  ember_burst_arcs = [];
  var _k_impact_arc_count = 14;
  for (var _iai = 0; _iai < _k_impact_arc_count; _iai++) {
    array_push(ember_burst_arcs, {
      ang : (_iai / _k_impact_arc_count) * 360 + random_range(-8, 8),
      life : 14,
      life_max : 14,
      bolt_id : "ember_burst_" + string(_iai)
    });
  }

  ember_burst_rings = [
    { delay : 0, radius : 0, max_radius : 340, alpha : 0.85, band : 26 },
    { delay : 5, radius : 0, max_radius : 300, alpha : 0.7, band : 16 },
    { delay : 10, radius : 0, max_radius : 420, alpha : 0.5, band : 40 }
  ];
}

if (ember_implosion_active && t > ember_implosion_last_t && t < 2207 && t mod 10 == 0) {
  ember_implosion_timer += (t - ember_implosion_last_t);
  while (ember_implosion_timer >= ember_implosion_spawn_rate) {
    ember_implosion_timer -= ember_implosion_spawn_rate;
    repeat(ember_implosion_spawn_count) {
      var _side_roll = random(1);
      var _side;
      if (_side_roll < 0.4) {
        _side = 2;
      } else if (_side_roll < 0.6) {
        _side = 0;
      } else if (_side_roll < 0.8) {
        _side = 1;
      } else {
        _side = 3;
      }
      var _px, _py;
      switch (_side) {
        case 0:
          _px = random_range(-200, -100);
          _py = random_range(-150, 758);
          break;
        case 1:
          _px = random_range(900, 1000);
          _py = random_range(-150, 758);
          break;
        case 2:
          _px = random_range(0, 800);
          _py = random_range(-200, -100);
          break;
        case 3:
          _px = random_range(0, 800);
          _py = random_range(708, 808);
          break;
      }

      var _child = instance_create_layer(_px, _py, layer, oRedOrb_2);
      _child.dying = true;
      _child.image_alpha = 1;
      _child.trail = 1;
      _child.orb_pop_scale = 2.0;
      _child.orb_pop_target = 0.8;
      _child.orb_pop_overshoot = true;
      _child.image_blend = c_white;
      _child.ember_glow_core = true;
      _child.fruit_seed_visual = true;
      _child.fruit_seed_color = global.tree_fire_color;
      _child.fruit_seed_heat = 1.25;
      _child.fruit_seed_ring_power = 1.45;

      array_push(ember_edge_glows, {bullet_id : _child, life : 12, fading : false,
                              mark_x : 0, mark_y : 0, mark_dir : 0, mark_dist : 9999, start_dist : -1});

      vignette_pulse = max(vignette_pulse, 0.06);
      bloom_pulse = max(bloom_pulse, 0.05);
    }
  }
  ember_implosion_last_t = t;
}

for (var i = array_length(ember_edge_glows) - 1; i >= 0; i--) {
  var _eg = ember_edge_glows[i];
  if (!instance_exists(_eg.bullet_id)) {
    array_delete(ember_edge_glows, i, 1);
    continue;
  }
  var _bx = _eg.bullet_id.x;
  var _by = _eg.bullet_id.y;
  var _onscreen = (_bx >= 0 && _bx <= room_width && _by >= 0 && _by <= room_height);
  if (_onscreen) {
    _eg.fading = true;
    _eg.mark_dist = 0;
  } else {
    var _entry = scr_ray_rect_entry(_bx, _by, _eg.bullet_id.direction, 0, 0, room_width, room_height);
    _eg.mark_x = _entry.x;
    _eg.mark_y = _entry.y;
    _eg.mark_dir = _eg.bullet_id.direction;
    _eg.mark_dist = point_distance(_bx, _by, _eg.mark_x, _eg.mark_y);

    if (_eg.start_dist <= 0) {
      _eg.start_dist = max(_eg.mark_dist, 1);
    }
  }
  if (_eg.fading) {
    _eg.life -= 1;
    if (_eg.life <= 0) {
      array_delete(ember_edge_glows, i, 1);
    }
  }
}

for (var i = array_length(ember_coil_pulses) - 1; i >= 0; i--) {
  ember_coil_pulses[i].life -= 1;
  if (ember_coil_pulses[i].life <= 0) {
    array_delete(ember_coil_pulses, i, 1);
  }
}

for (var i = array_length(ember_coil_arcs) - 1; i >= 0; i--) {
  ember_coil_arcs[i].life -= 1;
  if (ember_coil_arcs[i].life <= 0) {
    array_delete(ember_coil_arcs, i, 1);
  }
}

for (var i = array_length(ember_burst_arcs) - 1; i >= 0; i--) {
  ember_burst_arcs[i].life -= 1;
  if (ember_burst_arcs[i].life <= 0) {
    array_delete(ember_burst_arcs, i, 1);
  }
}

for (var i = array_length(ember_burst_rings) - 1; i >= 0; i--) {
  var _br = ember_burst_rings[i];
  if (_br.delay > 0) {
    _br.delay -= 1;
    continue;
  }
  _br.radius += (_br.max_radius - _br.radius) * 0.12 + 2;
  _br.alpha *= 0.93;
  if (_br.radius >= _br.max_radius - 1 || _br.alpha < 0.02) {
    array_delete(ember_burst_rings, i, 1);
  }
}

if (ember_burst_flash > 0) {
  ember_burst_flash -= 0.06;
  if (ember_burst_flash < 0) ember_burst_flash = 0;
}

for (var i = array_length(ember_drip_particles) - 1; i >= 0; i--) {
  var _dp = ember_drip_particles[i];
  _dp.x += _dp.xspeed;
  _dp.y += _dp.yspeed;
  _dp.yspeed += 0.22;
  _dp.life -= 1;
  if (_dp.life <= 0) {
    array_delete(ember_drip_particles, i, 1);
  }
}

if timeline_hit (2228) {
  var _ring_dir = choose(-1, 1);
  with (oRedOrb_2) {
    if (ember_glow_core && !dying && !orb_rotate_mode) {
      orb_rotate_cx = 400;
      orb_rotate_cy = 304;
      orb_rotate_radius = point_distance(x, y, 400, 304);
      orb_rotate_angle = point_direction(400, 304, x, y);
      orb_rotate_speed = _ring_dir * random_range(5, 8);
      orb_rotate_decay = 0.9995;
      orb_rotate_mode = true;
      fruit_seed_contained = true;
      fruit_seed_containment_flash = max(fruit_seed_containment_flash, 1);
      hit_active = false;
    }
  }
  vignette_pulse = max(vignette_pulse, 0.15);
  bloom_pulse = max(bloom_pulse, 0.12);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 4);
  }
}

if timeline_hit (2248) {
  with (oRedOrb_2) {
    if (orb_rotate_mode && !ember_ring_release) {
      ember_ring_release = true;
      ember_ring_release_delay = random_range(0, 16);
      fruit_seed_release_flash = max(fruit_seed_release_flash, 1);
      fruit_seed_containment_flash = max(fruit_seed_containment_flash, 0.9);
      hit_active = false;
    }
  }

  var _seed_cocoon_ring_col = merge_color(global.avoid_col_cyan_soft, c_white, 0.18);
  array_push(ember_burst_rings, {delay : 0, radius : 20, max_radius : 200, alpha : 0.5, band : 14, color : _seed_cocoon_ring_col});
  array_push(ember_burst_rings, {delay : 4, radius : 10, max_radius : 260, alpha : 0.35, band : 10, color : global.avoid_col_cyan});

  vignette_pulse = max(vignette_pulse, 0.2);
  aberration_pulse = max(aberration_pulse, 0.25);
  bloom_pulse = max(bloom_pulse, 0.15);
  global_ripple_pulse = max(global_ripple_pulse, 0.25);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 8);
  }
}

if timeline_hit (2252) {
  var _k_mote_count = 18;
  for (var mi = 0; mi < _k_mote_count; mi++) {
    var _mang = random(360);
    var _mrad = random_range(90, 260);
    array_push(finale_motes, {
      x : 400 + lengthdir_x(_mrad, _mang),
      y : 304 + lengthdir_y(_mrad, _mang),
      life : 0,
      life_max : irandom_range(16, 26)
    });
  }
  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 1;
  }
  vignette_pulse = max(vignette_pulse, 0.1);
}

if (t >= 2252 && t < 2270) {
  var _seed_p = clamp((t - 2252) / (2270 - 2252), 0, 1);
  finale_seed_alpha = _seed_p;

  finale_coil_next_pulse_t -= 1;
  if (finale_coil_next_pulse_t <= 0) {
    finale_coil_next_pulse_t = lerp(9, 2, _seed_p);

    array_push(finale_coil_pulses, {
      radius : lerp(25, 65, _seed_p),
      alpha : lerp(0.4, 0.95, _seed_p),
      life : 14,
      life_max : 14
    });

    var _arc_count = round(lerp(2, 6, _seed_p));
    for (var _aci = 0; _aci < _arc_count; _aci++) {
      array_push(finale_coil_arcs, {
        ang : random(360),
        life : 9,
        life_max : 9,
        bolt_id : "fin" + string(t) + "_" + string(_aci)
      });
    }

    vignette_pulse = max(vignette_pulse, lerp(0.08, 0.35, _seed_p));
    aberration_pulse = max(aberration_pulse, lerp(0.05, 0.2, _seed_p));
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, lerp(1, 7, _seed_p));
    }
  }
}

for (var i = array_length(finale_motes) - 1; i >= 0; i--) {
  finale_motes[i].life += 1;
  if (finale_motes[i].life >= finale_motes[i].life_max) {
    array_delete(finale_motes, i, 1);
  }
}
for (var i = array_length(finale_coil_pulses) - 1; i >= 0; i--) {
  finale_coil_pulses[i].life -= 1;
  if (finale_coil_pulses[i].life <= 0) {
    array_delete(finale_coil_pulses, i, 1);
  }
}
for (var i = array_length(finale_coil_arcs) - 1; i >= 0; i--) {
  finale_coil_arcs[i].life -= 1;
  if (finale_coil_arcs[i].life <= 0) {
    array_delete(finale_coil_arcs, i, 1);
  }
}
for (var i = array_length(finale_impact_cracks) - 1; i >= 0; i--) {
  finale_impact_cracks[i].life -= 1;
  if (finale_impact_cracks[i].life <= 0) {
    array_delete(finale_impact_cracks, i, 1);
  }
}
for (var i = array_length(finale_drip_particles) - 1; i >= 0; i--) {
  var _fd = finale_drip_particles[i];
  _fd.x += _fd.xspeed;
  _fd.y += _fd.yspeed;
  _fd.yspeed += 0.25;
  _fd.life -= 1;
  if (_fd.life <= 0) {
    array_delete(finale_drip_particles, i, 1);
  }
}

for (var i = array_length(finale_ground_strikes) - 1; i >= 0; i--) {
  var _gs = finale_ground_strikes[i];
  if (!_gs.struck) {
    _gs.timer -= 1;
    if (_gs.timer <= 0) {
      _gs.struck = true;
      _gs.struck_timer = 0;

      if (instance_exists(oPlayer) && point_distance(oPlayer.x, oPlayer.y, _gs.x, _gs.y) < _gs.radius) {
        player_register_hazard_hit();
      }

      array_push(sky_strikes, {
        ox : _gs.x + random_range(-50, 50), oy : -140,
        tx : _gs.x, ty : _gs.y,
        life : 18, life_max : 18,
        color : finale_lightning_hot
      });
      for (var _ci2 = 0; _ci2 < 6; _ci2++) {
        array_push(finale_impact_cracks, {
          x : _gs.x, y : _gs.y, ang : random(360),
          len : random_range(30, 60), life : 22, life_max : 22
        });
      }
      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 14);
      }
      vignette_pulse = max(vignette_pulse, 0.35);
    }
  } else {
    _gs.struck_timer += 1;
    if (_gs.struck_timer >= 14) {
      array_delete(finale_ground_strikes, i, 1);
    }
  }
}

for (var i = array_length(finale_railgun_beams) - 1; i >= 0; i--) {
  var _rg = finale_railgun_beams[i];
  _rg.timer -= 1;

  if (_rg.state == 0 && _rg.timer <= 0) {
    _rg.state = 1;
    _rg.timer = _rg.fire_duration;
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 10);
    }
    vignette_pulse = max(vignette_pulse, 0.3);
  }

  if (_rg.state == 1) {
    if (instance_exists(oPlayer)) {
      var _line_dir = point_direction(_rg.x1, _rg.y1, _rg.x2, _rg.y2);
      var _to_p_dir = point_direction(_rg.x1, _rg.y1, oPlayer.x, oPlayer.y);
      var _to_p_dist = point_distance(_rg.x1, _rg.y1, oPlayer.x, oPlayer.y);
      var _perp_dist = abs(_to_p_dist * sin(degtorad(_to_p_dir - _line_dir)));
      var _beam_len = point_distance(_rg.x1, _rg.y1, _rg.x2, _rg.y2);
      var _along = (oPlayer.x - _rg.x1) * dcos(_line_dir) + (oPlayer.y - _rg.y1) * dsin(_line_dir);
      if (_along >= 0 && _along <= _beam_len && _perp_dist < _rg.width * 0.5) {
        player_register_hazard_hit();
      }
    }
    if (_rg.timer <= 0) {
      array_delete(finale_railgun_beams, i, 1);
    }
  }
}

if timeline_hit (2266) {
  with (oRedLightningOrb) instance_destroy();
  with (oRedKunai) instance_destroy();
  with (oRedGravityOrb) instance_destroy();
  with (oLaserOrb_Pop) instance_destroy();
  with (oRedOrb) instance_destroy();
  with (oFruitBullet) { if (post_reform) instance_destroy(); }
  with (oHalfCircleBurst) instance_destroy();
  tree_root_rake_flash = 0;
  tree_root_rake_pressure = 0;
  tree_fruit_hold_tension = 0;
  tree_organism_tension = 0;
  tree_root_fissures = [];
  tree_root_spines = [];
  tree_pre_pulses = [];
  global.tree_embers = [];
}

if (timeline_hit(_k_er_lift_charge_t)) {
  er_lift_active = true;
  er_lift_locked = false;
  er_lift_despawning = false;
  er_lift_despawn_timer = 0;
  er_lift_despawn_flash = 0;
  er_lift_top_y = _k_er_lift_start_top_y;
  er_lift_prev_top_y = er_lift_top_y;
  er_lift_target_y = er_lift_top_y;
  er_lift_vspeed = 0;
  er_lift_draw_bob = 0;
  er_lift_hit_flash = 0;
  er_lift_core_flash = 0.35;
  er_lift_lock_flash = 0;
  er_lift_heat = 0;
  er_lift_charge = 0;
  er_lift_beat_index = -1;
  er_lift_phase_pulse = 0;
  er_lift_rail_alpha = 0;
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
  finale_ground_strikes = [];
  finale_railgun_beams = [];

  if (instance_exists(er_lift_platform)) instance_destroy(er_lift_platform);
  er_lift_platform = instance_create_layer(room_width * 0.5,
                                           er_lift_top_y + _k_er_lift_body_h * 0.5,
                                           "Instances", oPlatform);
  er_lift_platform.image_xscale = (room_width + _k_er_lift_overhang * 2) / sprite_get_width(sPlatform);
  er_lift_platform.image_yscale = _k_er_lift_body_h / sprite_get_height(sPlatform);
  er_lift_platform.image_alpha = 0;
  er_lift_platform.hspeed = 0;
  er_lift_platform.vspeed = 0;

  for (var _lv = 0; _lv < 7; _lv++) {
    array_push(er_lift_vents, {
      x : lerp(70, room_width - 70, _lv / 6),
      w : random_range(45, 90),
      life : 34 + _lv * 2,
      life_max : 44,
      hot : 0.35,
      seed : random(1000)
    });
  }

  if (instance_exists(oCameraController)) oCameraController.letterbox_target = 1;
}

var _lift_should_exist = (t >= _k_er_lift_charge_t && t <= _k_er_lift_release_t);
if (_lift_should_exist && !er_lift_active) {
  er_lift_active = true;
  er_lift_despawning = false;
  finale_ground_strikes = [];
  finale_railgun_beams = [];
  with (oHalfCircleBurst) instance_destroy();
  if (!instance_exists(er_lift_platform)) {
    er_lift_platform = instance_create_layer(room_width * 0.5,
                                             er_lift_top_y + _k_er_lift_body_h * 0.5,
                                             "Instances", oPlatform);
    er_lift_platform.image_xscale = (room_width + _k_er_lift_overhang * 2) / sprite_get_width(sPlatform);
    er_lift_platform.image_yscale = _k_er_lift_body_h / sprite_get_height(sPlatform);
    er_lift_platform.image_alpha = 0;
  }
}

if (_lift_should_exist && er_lift_active) {
  er_lift_despawning = false;
  var _lt0 = _k_er_lift_charge_t;
  var _lt1 = _k_er_lift_beats[0];
  var _ly0 = _k_er_lift_start_top_y;
  var _ly1 = _k_er_lift_born_top_y;

  if (t >= _k_er_lift_beats[0]) {
    _lt0 = _k_er_lift_beats[0];
    _lt1 = _k_er_lift_beats[1];
    _ly0 = _k_er_lift_born_top_y;
    _ly1 = lerp(_k_er_lift_born_top_y, _k_er_lift_final_top_y, 0.33);
  }
  if (t >= _k_er_lift_beats[1]) {
    _lt0 = _k_er_lift_beats[1];
    _lt1 = _k_er_lift_beats[2];
    _ly0 = lerp(_k_er_lift_born_top_y, _k_er_lift_final_top_y, 0.33);
    _ly1 = lerp(_k_er_lift_born_top_y, _k_er_lift_final_top_y, 0.66);
  }
  if (t >= _k_er_lift_beats[2]) {
    _lt0 = _k_er_lift_beats[2];
    _lt1 = _k_er_lift_beats[3];
    _ly0 = lerp(_k_er_lift_born_top_y, _k_er_lift_final_top_y, 0.66);
    _ly1 = _k_er_lift_final_top_y + 14;
  }
  if (t >= _k_er_lift_beats[3]) {
    _lt0 = _k_er_lift_beats[3];
    _lt1 = _k_er_lift_lock_t;
    _ly0 = _k_er_lift_final_top_y + 14;
    _ly1 = _k_er_lift_final_top_y;
  }

  var _lp = clamp((t - _lt0) / max(_lt1 - _lt0, 1), 0, 1);
  var _le = 1 - power(1 - _lp, 3);
  er_lift_prev_top_y = er_lift_top_y;
  er_lift_top_y = lerp(_ly0, _ly1, _le);
  er_lift_vspeed = er_lift_top_y - er_lift_prev_top_y;
  er_lift_target_y = _ly1;
  er_lift_charge = clamp((t - _k_er_lift_charge_t) / max(_k_er_lift_lock_t - _k_er_lift_charge_t, 1), 0, 1);
  er_lift_heat = lerp(er_lift_heat, 0.22 + er_lift_charge * 0.58 + er_lift_phase_pulse * 0.35, 0.18);
  er_lift_draw_bob = lerp(er_lift_draw_bob, 0, 0.18);
  er_lift_rail_alpha = max(er_lift_rail_alpha - 0.025, 0);
  _k_er_floor_y = _k_er_floor_base_y;

  if (instance_exists(er_lift_platform)) {
    er_lift_platform.x = room_width * 0.5;
    er_lift_platform.y = er_lift_top_y + _k_er_lift_body_h * 0.5;
    er_lift_platform.hspeed = 0;
    er_lift_platform.vspeed = er_lift_vspeed;
    er_lift_platform.image_xscale = (room_width + _k_er_lift_overhang * 2) / sprite_get_width(sPlatform);
    er_lift_platform.image_yscale = _k_er_lift_body_h / sprite_get_height(sPlatform);
    er_lift_platform.image_alpha = 0;
  }

  if (t >= _k_er_lift_lock_t) er_lift_locked = true;

  if (t mod 2 == 0 && random(1) < 0.55 + er_lift_heat * 0.45) {
    array_push(er_lift_plumes, {
      x : random_range(-20, room_width + 20),
      y : er_lift_top_y + random_range(14, _k_er_lift_body_h),
      vx : random_range(-0.8, 0.8),
      vy : -random_range(0.8, 2.4) * (0.7 + er_lift_heat),
      size : random_range(2, 7),
      life : irandom_range(18, 34),
      life_max : 34,
      hot : er_lift_heat,
      seed : random(1000)
    });
  }

  if (random(1) < 0.28 + er_lift_heat * 0.22) {
    var _fall_side = choose(-1, 1);
    array_push(er_lift_lavafalls, {
      x : (_fall_side < 0) ? random_range(-20, 70) : random_range(room_width - 70, room_width + 20),
      y : er_lift_top_y + random_range(10, 34),
      len : random_range(25, 90),
      vy : random_range(1.2, 3.6),
      w : random_range(3, 8),
      life : irandom_range(24, 46),
      life_max : 46,
      hot : er_lift_heat,
      seed : random(1000)
    });
  }
} else if (er_lift_active) {
  _k_er_floor_y = _k_er_floor_base_y;

  if (!er_lift_despawning) {
    er_lift_despawning = true;
    er_lift_despawn_timer = 0;
    er_lift_despawn_flash = 1;
    er_lift_prev_top_y = er_lift_top_y;
    er_lift_target_y = er_lift_top_y + _k_er_lift_despawn_drop;
    er_lift_rail_alpha = 0;
    er_lift_despawn_cracks = [];

    for (var _dc = 0; _dc < _k_er_lift_despawn_crack_count; _dc++) {
      var _df = _dc / max(1, _k_er_lift_despawn_crack_count - 1);
      array_push(er_lift_despawn_cracks, {
        x : lerp(-30, room_width + 30, _df) + random_range(-18, 18),
        w : random_range(28, 88),
        delay : _dc * 2 + irandom(4),
        life : irandom_range(24, 42),
        life_max : 42,
        hot : random_range(0.45, 1),
        seed : random(1000)
      });
    }

    repeat(28) {
      array_push(er_lift_chunks, {
        x : random_range(-30, room_width + 30),
        y : er_lift_top_y + random_range(0, _k_er_lift_body_h),
        vx : random_range(-4, 4),
        vy : -random_range(1.5, 6),
        size : random_range(5, 19),
        rot : random(360),
        spin : random_range(-9, 9),
        life : irandom_range(36, 64),
        life_max : 64,
        seed : random(1000)
      });
    }

    repeat(34) {
      var _sp_ang = random_range(190, 350);
      array_push(er_lift_sparks, {
        x : random_range(-20, room_width + 20),
        y : er_lift_top_y + random_range(4, _k_er_lift_body_h),
        vx : lengthdir_x(random_range(1.2, 6), _sp_ang),
        vy : lengthdir_y(random_range(1.2, 6), _sp_ang),
        size : random_range(1.5, 5),
        life : irandom_range(24, 52),
        life_max : 52,
        col : merge_color(_k_er_col_hot, c_white, random_range(0.1, 0.85))
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 8);
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.12);
    }
  }

  er_lift_despawn_timer++;
  var _ldp = clamp(er_lift_despawn_timer / _k_er_lift_despawn_duration, 0, 1);
  var _ld_ease = power(_ldp, 2.2);
  var _sink_wobble = sin(_ldp * pi * 5) * (1 - _ldp) * 5;

  er_lift_prev_top_y = er_lift_top_y;
  er_lift_top_y = lerp(_k_er_lift_final_top_y, _k_er_lift_final_top_y + _k_er_lift_despawn_drop, _ld_ease)
                + _sink_wobble;
  er_lift_vspeed = er_lift_top_y - er_lift_prev_top_y;
  er_lift_heat = lerp(er_lift_heat, max(0, 0.85 * (1 - _ldp)), 0.12);
  er_lift_despawn_flash = max(0, er_lift_despawn_flash - 0.035);
  er_lift_draw_bob = lerp(er_lift_draw_bob, 0, 0.2);

  if (instance_exists(er_lift_platform)) {
    er_lift_platform.x = room_width * 0.5;
    er_lift_platform.y = er_lift_top_y + _k_er_lift_body_h * 0.5;
    er_lift_platform.hspeed = 0;
    er_lift_platform.vspeed = er_lift_vspeed;
    er_lift_platform.image_alpha = 0;
  }

  if (er_lift_despawn_timer mod 5 == 0 && _ldp < 0.72) {
    array_push(er_lift_lavafalls, {
      x : random_range(-30, room_width + 30),
      y : er_lift_top_y + random_range(6, _k_er_lift_body_h),
      len : random_range(35, 115),
      vy : random_range(1.8, 4.4),
      w : random_range(3, 9),
      life : irandom_range(24, 46),
      life_max : 46,
      hot : 0.45 + (1 - _ldp) * 0.55,
      seed : random(1000)
    });
  }

  if (er_lift_despawn_timer >= _k_er_lift_despawn_duration) {
    if (instance_exists(er_lift_platform)) instance_destroy(er_lift_platform);
    er_lift_active = false;
    er_lift_locked = false;
    er_lift_despawning = false;
    er_lift_despawn_flash = 0;
  }
} else {
  _k_er_floor_y = _k_er_floor_base_y;
  er_lift_locked = false;
}

if (timeline_hit_many(_k_er_lift_beats[0], _k_er_lift_beats[1],
                      _k_er_lift_beats[2], _k_er_lift_beats[3])) {
  var phase = 0;
  if (timeline_hit(_k_er_lift_beats[1])) phase = 1;
  if (timeline_hit(_k_er_lift_beats[2])) phase = 2;
  if (timeline_hit(_k_er_lift_beats[3])) phase = 3;

  er_lift_beat_index = phase;
  er_lift_hit_flash = 1;
  er_lift_core_flash = 1;
  er_lift_phase_pulse = 1;
  er_lift_draw_bob = 8 + phase * 3;
  er_lift_rail_alpha = 1;
  finale_seed_alpha = 1;

  var _lift_pow = phase / 3;
  var _lift_col = merge_color(_k_er_col_cyan, _k_er_col_white, 0.25 + _lift_pow * 0.55);

  scr_impact_pulse(0.15, 0, 1.4);
  vignette_pulse = max(vignette_pulse, lerp(0.34, 0.72, _lift_pow));
  var _lift_warp_pow = _lift_pow * _lift_pow;
  aberration_pulse = max(aberration_pulse, lerp(0.04, 0.12, _lift_warp_pow));
  bloom_pulse = max(bloom_pulse, lerp(0.24, 0.55, _lift_pow));
  global_ripple_pulse = max(global_ripple_pulse, lerp(0.025, 0.105, _lift_warp_pow));
  tear_amount = max(tear_amount, _lift_warp_pow * 0.045);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, lerp(12, 28, _lift_pow));
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, lerp(0.07, 0.20, _lift_pow));
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, lerp(0.12, 0.42, _lift_pow));
    if (phase == 3) oCameraController.letterbox_target = 0.25;
  }

  array_push(er_lift_shockwaves, {
    y : er_lift_top_y,
    radius : 0,
    max_radius : lerp(260, 620, _lift_pow),
    alpha : lerp(0.55, 0.95, _lift_pow),
    life : 28,
    life_max : 28,
    col : _lift_col
  });
  array_push(ember_burst_rings, {
    delay : 0,
    radius : 0,
    max_radius : lerp(260, 520, _lift_pow),
    alpha : lerp(0.45, 0.8, _lift_pow),
    band : lerp(18, 38, _lift_pow),
    color : _lift_col,
    phase : phase,
    hc_front : true
  });

  var _vent_count = 6 + phase * 3;
  for (var _vi = 0; _vi < _vent_count; _vi++) {
    array_push(er_lift_vents, {
      x : lerp(-20, room_width + 20, (_vi + random_range(-0.25, 0.25)) / max(_vent_count - 1, 1)),
      w : random_range(36, 94) * (1 + _lift_pow * 0.35),
      life : irandom_range(22, 38),
      life_max : 38,
      hot : 0.55 + _lift_pow * 0.45,
      seed : random(1000)
    });
  }

  var _chunk_count = 10 + phase * 6;
  for (var _ch = 0; _ch < _chunk_count; _ch++) {
    array_push(er_lift_chunks, {
      x : random_range(-20, room_width + 20),
      y : er_lift_top_y + random_range(0, 24),
      vx : random_range(-5, 5),
      vy : -random_range(3, 9) * (0.8 + _lift_pow * 0.5),
      size : random_range(5, 18),
      rot : random(360),
      spin : random_range(-10, 10),
      life : irandom_range(34, 58),
      life_max : 58,
      seed : random(1000)
    });
  }

  var _spark_count = 24 + phase * 16;
  for (var _sp = 0; _sp < _spark_count; _sp++) {
    var _sa = random_range(205, 335);
    array_push(er_lift_sparks, {
      x : random_range(-20, room_width + 20),
      y : er_lift_top_y + random_range(8, 44),
      vx : lengthdir_x(random_range(2, 9), _sa),
      vy : lengthdir_y(random_range(2, 9), _sa),
      size : random_range(1.5, 5.5),
      life : irandom_range(18, 42),
      life_max : 42,
      col : merge_color(choose(_k_er_col_cyan, _k_er_col_warning), c_white, random_range(0.1, 0.75))
    });
  }

  for (var _rd = 0; _rd < 8; _rd++) {
    for (var _sg = -1; _sg <= 1; _sg += 2) {
      array_push(er_lift_ridges, {
        x : lerp(60, room_width - 60, _rd / 7),
        dir : _sg,
        dist : 0,
        max_dist : random_range(100, 260) * (0.8 + _lift_pow),
        life : 24 + phase * 4,
        life_max : 24 + phase * 4,
        hot : 0.5 + _lift_pow * 0.5
      });
    }
  }

  for (var _bt = 0; _bt < 5 + phase * 2; _bt++) {
    var _bx = random_range(40, room_width - 40);
    array_push(er_lift_bolts, {
      x1 : _bx + random_range(-90, 90),
      y1 : er_lift_top_y + _k_er_lift_body_h + random_range(40, 120),
      x2 : _bx,
      y2 : er_lift_top_y + random_range(0, 16),
      life : irandom_range(8, 14),
      life_max : 14,
      bolt_id : "lift" + string(t) + "_" + string(_bt),
      hot : 0.5 + _lift_pow * 0.5
    });
  }

  array_push(er_lift_edge_flares, { x : 0, side : -1, life : 26, life_max : 26, hot : 0.6 + _lift_pow * 0.4 });
  array_push(er_lift_edge_flares, { x : room_width, side : 1, life : 26, life_max : 26, hot : 0.6 + _lift_pow * 0.4 });

  if (phase == 3) {
    er_lift_lock_flash = 1;
    for (var _lk = 0; _lk < 10; _lk++) {
      array_push(er_lift_bolts, {
        x1 : random_range(0, room_width),
        y1 : er_lift_top_y + random_range(40, 130),
        x2 : random_range(0, room_width),
        y2 : er_lift_top_y + random_range(-6, 12),
        life : 18,
        life_max : 18,
        bolt_id : "lock" + string(t) + "_" + string(_lk),
        hot : 1
      });
    }
  }
}

er_lift_hit_flash = max(0, er_lift_hit_flash - 0.075);
er_lift_core_flash = max(0, er_lift_core_flash - 0.045);
er_lift_lock_flash = max(0, er_lift_lock_flash - 0.055);
er_lift_phase_pulse = max(0, er_lift_phase_pulse - 0.06);

for (var i = array_length(er_lift_vents) - 1; i >= 0; i--) {
  er_lift_vents[i].life--;
  if (er_lift_vents[i].life <= 0) array_delete(er_lift_vents, i, 1);
}
for (var i = array_length(er_lift_plumes) - 1; i >= 0; i--) {
  var _pl = er_lift_plumes[i];
  _pl.x += _pl.vx;
  _pl.y += _pl.vy;
  _pl.vy -= 0.02;
  _pl.life--;
  if (_pl.life <= 0) array_delete(er_lift_plumes, i, 1);
}
for (var i = array_length(er_lift_sparks) - 1; i >= 0; i--) {
  var _ls = er_lift_sparks[i];
  _ls.x += _ls.vx;
  _ls.y += _ls.vy;
  _ls.vy += 0.18;
  _ls.life--;
  if (_ls.life <= 0) array_delete(er_lift_sparks, i, 1);
}
for (var i = array_length(er_lift_chunks) - 1; i >= 0; i--) {
  var _lc = er_lift_chunks[i];
  _lc.x += _lc.vx;
  _lc.y += _lc.vy;
  _lc.vy += 0.24;
  _lc.rot += _lc.spin;
  _lc.life--;
  if (_lc.life <= 0) array_delete(er_lift_chunks, i, 1);
}
for (var i = array_length(er_lift_shockwaves) - 1; i >= 0; i--) {
  var _lw = er_lift_shockwaves[i];
  var _wp = 1 - _lw.life / _lw.life_max;
  _lw.radius = lerp(_lw.radius, _lw.max_radius, 0.22 + _wp * 0.12);
  _lw.alpha *= 0.9;
  _lw.life--;
  if (_lw.life <= 0 || _lw.alpha <= 0.02) array_delete(er_lift_shockwaves, i, 1);
}
for (var i = array_length(er_lift_ridges) - 1; i >= 0; i--) {
  var _lr = er_lift_ridges[i];
  _lr.dist += lerp(7, 18, _lr.hot);
  _lr.life--;
  if (_lr.life <= 0 || _lr.dist >= _lr.max_dist) array_delete(er_lift_ridges, i, 1);
}
for (var i = array_length(er_lift_lavafalls) - 1; i >= 0; i--) {
  var _lf = er_lift_lavafalls[i];
  _lf.y += _lf.vy;
  _lf.len += 0.6;
  _lf.life--;
  if (_lf.life <= 0) array_delete(er_lift_lavafalls, i, 1);
}
for (var i = array_length(er_lift_bolts) - 1; i >= 0; i--) {
  er_lift_bolts[i].life--;
  if (er_lift_bolts[i].life <= 0) array_delete(er_lift_bolts, i, 1);
}
for (var i = array_length(er_lift_edge_flares) - 1; i >= 0; i--) {
  er_lift_edge_flares[i].life--;
  if (er_lift_edge_flares[i].life <= 0) array_delete(er_lift_edge_flares, i, 1);
}
for (var i = array_length(er_lift_despawn_cracks) - 1; i >= 0; i--) {
  var _ldc = er_lift_despawn_cracks[i];
  _ldc.delay--;
  if (_ldc.delay <= 0) _ldc.life--;
  if (_ldc.life <= 0) array_delete(er_lift_despawn_cracks, i, 1);
}

if (!_lift_should_exist && !er_lift_active) {
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
}

if (false && timeline_hit_many(2270, 2286, 2302, 2318)) {
  var spd = 15;
  var offset = random(360);

  var phase = 0;
  if (timeline_hit(2286)) phase = 1;
  if (timeline_hit(2302)) phase = 2;
  if (timeline_hit(2318)) phase = 3;
  var start_a = phase * 90;
  var end_a = start_a + 90;

  var _k_shake        = [ 10,   15,   21,   32   ];
  var _k_zoom_punch   = [ 0.07, 0.10, 0.15, 0.26 ];
  var _k_vignette     = [ 0.4,  0.52, 0.68, 0.95 ];
  var _k_aberration   = [ 0.3,  0.38, 0.5,  0.7  ];
  var _k_bloom        = [ 0.2,  0.28, 0.38, 0.55 ];
  var _k_ripple       = [ 0.35, 0.45, 0.58, 0.8  ];
  var _k_screen_flash = [ 0.18, 0.25, 0.35, 0.6  ];
  var _k_tear         = [ 0.25, 0.35, 0.48, 0.75 ];

  var _is_final_phase = (phase == 3);

  scr_bg_bass_hit();
  vignette_pulse = max(vignette_pulse, _k_vignette[phase]);
  aberration_pulse = max(aberration_pulse, _k_aberration[phase]);
  bloom_pulse = max(bloom_pulse, _k_bloom[phase]);
  global_ripple_pulse = max(global_ripple_pulse, _k_ripple[phase]);
  tear_amount = max(tear_amount, _k_tear[phase]);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_shake[phase]);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_zoom_punch[phase]);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, _k_screen_flash[phase]);
    if (_is_final_phase) {
      oCameraController.letterbox_target = 0;
    }
  }

  var _strike_ang = start_a + 45;
  var _strike_x = 400 + lengthdir_x(90, _strike_ang);
  var _strike_y = 304 + lengthdir_y(90, _strike_ang);

  array_push(sky_strikes, {
    ox : _strike_x + random_range(-60, 60), oy : -140,
    tx : _strike_x, ty : _strike_y,
    life : 22, life_max : 22,
    color : finale_lightning_hot
  });
  array_push(sky_strikes, {
    ox : _strike_x + random_range(-110, 110), oy : -170,
    tx : _strike_x + random_range(-20, 20), ty : _strike_y + random_range(-10, 10),
    life : 18, life_max : 18,
    color : finale_lightning_col
  });

  var _k_crack_count = 5 + phase * 2;
  for (var _ci = 0; _ci < _k_crack_count; _ci++) {
    array_push(finale_impact_cracks, {
      x : _strike_x, y : _strike_y,
      ang : random(360),
      len : random_range(30, 70) * (1 + phase * 0.25),
      life : 26, life_max : 26
    });
  }

  var _k_drip_count = 4 + phase * 2;
  for (var _di = 0; _di < _k_drip_count; _di++) {
    var _dang = random(360);
    array_push(finale_drip_particles, {
      x : _strike_x, y : _strike_y,
      xspeed : lengthdir_x(random_range(0.5, 2.5), _dang),
      yspeed : lengthdir_y(random_range(0.5, 2.5), _dang) - 1,
      size : random_range(2, 6),
      life : irandom_range(20, 34), life_max : 34
    });
  }

  finale_seed_alpha = 1;

  if (_is_final_phase) {
    array_push(ember_burst_rings, {delay : 0,  radius : 0, max_radius : 360, alpha : 0.9,  band : 30, color : finale_lightning_hot});
    array_push(ember_burst_rings, {delay : 5,  radius : 0, max_radius : 460, alpha : 0.6,  band : 40, color : finale_lightning_col});
    array_push(ember_burst_rings, {delay : 10, radius : 0, max_radius : 560, alpha : 0.35, band : 50, color : finale_lightning_col});
  }

  var _k_trunk_count = (phase >= 2) ? 3 : 4;
  var _k_max_gen = (phase >= 2) ? 2 : 1;

  for (var i = 0; i < _k_trunk_count; ++i) {
    var a = lerp(start_a, end_a, i / max(_k_trunk_count - 1, 1));

    for (var side = 0; side < 2; side++) {
      var _trunk_dir = a + offset + side * 180;

      if (instance_exists(oPlayer)) {
        var _to_player = point_direction(400, 304, oPlayer.x, oPlayer.y);
        var _diff = angle_difference(_trunk_dir, _to_player);
        var _danger_cone = 24;
        if (abs(_diff) < _danger_cone) {
          var _sign = (_diff >= 0) ? 1 : -1;
          _trunk_dir = _to_player + _sign * (_danger_cone + 10);
        }
      }

      with(instance_create_layer(400, 304, layer, oHalfCircleBurst)) {
        direction = _trunk_dir;
        speed = spd + random_range(-1, 1);
        _size = 10;
        spawn_shrink = 1;
        chain_mode = true;
        chain_generation = 0;
        chain_max_generation = _k_max_gen;
        chain_fork_timer = irandom_range(16, 22);
      }
    }
  }

  var _k_ground_strike_count = 3;
  var _k_gs_warn = _is_final_phase ? 26 : 45;
  for (var _gsi2 = 0; _gsi2 < _k_ground_strike_count; _gsi2++) {
    array_push(finale_ground_strikes, {
      x : random_range(100, 700), y : random_range(100, 500),
      timer : _k_gs_warn, duration : _k_gs_warn,
      struck : false, struck_timer : 0,
      radius : 60
    });
  }

  var _k_railgun_count = _is_final_phase ? 2 : 1;
  var _k_rg_warn = _is_final_phase ? 24 : 50;
  for (var _rgi = 0; _rgi < _k_railgun_count; _rgi++) {
    var _rg_px = instance_exists(oPlayer) ? oPlayer.x : 400;
    var _rg_py = instance_exists(oPlayer) ? oPlayer.y : 304;
    var _rg_ang = random(360);
    array_push(finale_railgun_beams, {
      x1 : _rg_px - lengthdir_x(1000, _rg_ang), y1 : _rg_py - lengthdir_y(1000, _rg_ang),
      x2 : _rg_px + lengthdir_x(1000, _rg_ang), y2 : _rg_py + lengthdir_y(1000, _rg_ang),
      timer : _k_rg_warn, warn_duration : _k_rg_warn, fire_duration : 5,
      state : 0, width : 22
    });
  }
}



var _er_live = (t >= _k_er_materialize_t && t <= erupt_active_until);

if (timeline_hit(_k_er_materialize_t)) {
  erupt_materialize = 0;
  erupt_pressure = 0;
  erupt_coil = 0;
  erupt_coil_index = -1;
  erupt_flash = 0;
  erupt_floor_heat = 0;
  erupt_shudder = 0;
  erupt_beat_index = 0;
  erupt_collapsing = false;
  erupt_collapse_timer = 0;
  erupt_active_until = _k_er_active_until;
  erupt_armed_cols = [];
  erupt_armed_fast = false;
  erupt_last_lock_index = -99;

  for (var i = 0; i < array_length(erupt_pillars); i++) {
    var _rp = erupt_pillars[i];
    for (var b = 0; b < array_length(_rp.bullets); b++) {
      if (instance_exists(_rp.bullets[b].inst)) instance_destroy(_rp.bullets[b].inst);
    }
  }
  for (var i = 0; i < array_length(erupt_strays); i++) {
    if (instance_exists(erupt_strays[i].inst)) instance_destroy(erupt_strays[i].inst);
  }

  erupt_pillars = [];
  erupt_strays = [];
  erupt_shards = [];
  erupt_side_bursts = [];
  erupt_side_warn_vents = [];
  erupt_gravel = [];
  erupt_ridges = [];
  erupt_scars = [];
  erupt_sparks = [];
  erupt_haze = [];
  erupt_seed_streams = [];
  erupt_lock_frames = [];
  erupt_charge_arcs = [];
  erupt_scan_sweeps = [];
  erupt_code_streams = [];
  erupt_panel_afterimages = [];
  erupt_reactor_rings = [];
  erupt_collapse_beams = [];
  erupt_lane_residue = [];
}

if (t >= _k_er_materialize_t && t < _k_cube_t_spawn && erupt_materialize < 1 && !erupt_collapsing) {
  var _mp = clamp((t - _k_er_materialize_t) / _k_er_materialize_dur, 0, 1);
  erupt_materialize = 1 - power(1 - _mp, 3);

  if (_mp < 1 && t mod 3 == 0) {
    array_push(erupt_scars, {
      cx : 400 + random_range(-300, 300) * (0.3 + _mp),
      w : random_range(30, 90),
      life : 240, life_max : 240,
      seed : random(1000),
      hot : 0.25 + _mp * 0.3
    });
  }

  if (t mod 4 == 0 && random(1) < 0.6 * _mp) {
    array_push(erupt_sparks, {
      x : random(room_width),
      y : _k_er_floor_y - random_range(2, 14),
      xspeed : random_range(-1.2, 1.2),
      yspeed : -random_range(0.5, 2),
      size : random_range(1, 2.6),
      life : irandom_range(8, 18), life_max : 18,
      color : merge_color(_k_er_col_hot, c_white, random_range(0.3, 0.85))
    });
  }

  if (t mod 5 == 0) {
    array_push(erupt_scan_sweeps, {
      x : room_width * 0.5,
      y : _k_er_floor_y + random_range(-8, 10),
      w : room_width + 160,
      vy : -random_range(2.8, 5.4) * (0.6 + _mp),
      life : _k_er_scan_life,
      life_max : _k_er_scan_life,
      hot : 0.3 + _mp * 0.55,
      color : merge_color(_k_er_col_cyan, _k_er_col_warning, _mp * 0.45),
      seed : random(1000)
    });
  }

  if (t mod 3 == 0 && random(1) < 0.35 + _mp * 0.45) {
    array_push(erupt_code_streams, {
      x : random(room_width),
      y : _k_er_floor_y + random_range(-4, 8),
      len : random_range(22, 70),
      vy : -random_range(2.0, 4.8) * (0.8 + _mp),
      w : random_range(1.2, 3.4),
      life : irandom_range(18, 34),
      life_max : 34,
      hot : 0.35 + _mp * 0.45,
      color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
      seed : random(1000)
    });
  }
}

if (_er_live && !erupt_collapsing) {
  var _coil_raw = 0;
  var _coil_idx = -1;
  var _coil_cols = [];
  var _coil_fast = false;
  var _er_count = array_length(_k_er_beats);

  for (var i = 0; i < _er_count; i++) {
    var _until = _k_er_beats[i] - t;
    var _lead = _k_er_plan[i].lead;
    if (_until > 0 && _until <= _lead) {
      var _c = 1 - (_until / _lead);
      if (_c > _coil_raw) {
        _coil_raw = _c;
        _coil_idx = i;
        _coil_cols = _k_er_plan[i].cols;
        _coil_fast = _k_er_plan[i].fast;
      }
    }
  }

  var _until_col = _k_er_collapse_t - t;
  if (_until_col > 0 && _until_col <= _k_er_collapse_lead) {
    var _cc = 1 - (_until_col / _k_er_collapse_lead);
    if (_cc > _coil_raw) {
      _coil_raw = _cc;
      _coil_idx = _er_count;
      _coil_cols = _k_er_collapse_cols;
      _coil_fast = true;
    }
  }

  var _coil_eased = 0;
  if (_coil_raw > 0) {
    _coil_eased = max(power(_coil_raw, 1.45),
                      lerp(_k_er_coil_read_floor, 1, power(_coil_raw, 1.2)));
  }

  if (_coil_idx == 0) {
    var _opener_warn = clamp((t - _k_er_materialize_t)
                           / max(_k_er_beats[0] - _k_er_materialize_t, 1), 0, 1);
    _coil_eased = max(_coil_eased,
                      lerp(_k_er_opener_coil_floor, 1, power(_opener_warn, 1.45)));
  }

  erupt_coil = _coil_eased;
  erupt_coil_index = _coil_idx;
  erupt_armed_cols = _coil_cols;
  erupt_armed_fast = _coil_fast;

  if (_coil_idx >= 0 && _coil_idx != erupt_last_lock_index && array_length(_coil_cols) > 0) {
    erupt_last_lock_index = _coil_idx;
    var _lock_hot = (_coil_idx >= _er_count) ? 1 : clamp(_coil_idx / max(_er_count - 1, 1), 0, 1);
    for (var _lk = 0; _lk < array_length(_coil_cols); _lk++) {
      var _lc = _coil_cols[_lk];
      array_push(erupt_lock_frames, {
        cx : _lc.cx,
        w : _lc.w,
        life : _k_er_lock_life,
        life_max : _k_er_lock_life,
        hot : 0.45 + _lock_hot * 0.55,
        fast : _coil_fast,
        seed : random(1000)
      });
      array_push(erupt_scan_sweeps, {
        x : _lc.cx,
        y : _k_er_floor_y + random_range(-4, 4),
        w : max(_lc.w + 84, 120),
        vy : -random_range(3.5, 6.8) * (0.8 + _lock_hot * 0.6),
        life : _k_er_scan_life,
        life_max : _k_er_scan_life,
        hot : 0.55 + _lock_hot * 0.45,
        color : _coil_fast ? _k_er_col_cyan : _k_er_col_warning,
        seed : random(1000)
      });
    }
  }
} else {
  erupt_coil = max(0, erupt_coil - 0.12);
  if (erupt_coil <= 0) {
    erupt_coil_index = -1;
    erupt_armed_cols = [];
    erupt_last_lock_index = -99;
  }
}

if (erupt_coil > 0.02 && array_length(erupt_armed_cols) > 0) {
  var _seam_n = array_length(erupt_armed_cols);

  var _seam_gravel = 1 + floor(erupt_coil * (1 + erupt_pressure * 3));
  for (var g = 0; g < _seam_gravel; g++) {
    var _sc = erupt_armed_cols[irandom(_seam_n - 1)];
    array_push(erupt_gravel, {
      x : _sc.cx + random_range(-_sc.w, _sc.w) * 0.5,
      y : _k_er_floor_y - random(4),
      yspeed : -random_range(1.6, 4.5) * (0.7 + erupt_coil * 1.6),
      size : random_range(1.4, 4),
      life : irandom_range(16, 30), life_max : 30
    });
  }

  if (t mod 2 == 0) {
    for (var s = 0; s < _seam_n; s++) {
      var _sc2 = erupt_armed_cols[s];
      array_push(erupt_haze, {
        cx : _sc2.cx,
        w : _sc2.w,
        prog : 0,
        life : 16, life_max : 16,
        hot : erupt_coil
      });
    }
  }

  if (t mod 2 == 0) {
    for (var s = 0; s < _seam_n; s++) {
      var _sc3 = erupt_armed_cols[s];
      for (var sgn = -1; sgn <= 1; sgn += 2) {
        array_push(erupt_sparks, {
          x : _sc3.cx + sgn * (_sc3.w * 0.5 + random_range(-2, 4)),
          y : _k_er_floor_y - random_range(0, 6),
          xspeed : sgn * random_range(0.6, 2.4),
          yspeed : -random_range(0.8, 3.2) * (0.5 + erupt_coil),
          size : random_range(1.2, 3),
          life : irandom_range(10, 22), life_max : 22,
          color : merge_color(_k_er_col_hot, c_white, random_range(0.4, 0.95))
        });
      }
    }
  }

  if (t mod 3 == 0) {
    for (var s = 0; s < _seam_n; s++) {
      var _sc4 = erupt_armed_cols[s];
      var _side = choose(-1, 1);
      var _rail_y = (er_lift_active && er_lift_top_y < _k_er_floor_base_y - 12)
                  ? er_lift_top_y + random_range(0, 28)
                  : _k_er_floor_y - random_range(34, 90);
      var _rail_x = clamp(_sc4.cx + _side * random_range(_sc4.w * 0.45 + 16, _sc4.w * 0.9 + 150),
                          0, room_width);

      array_push(erupt_charge_arcs, {
        x1 : _rail_x,
        y1 : _rail_y,
        x2 : _sc4.cx + random_range(-_sc4.w, _sc4.w) * 0.35,
        y2 : _k_er_floor_y - random_range(1, 8),
        life : irandom_range(8, 15),
        life_max : 15,
        hot : erupt_coil,
        color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
        off : scr_bolt_offsets(5, 8 + erupt_coil * 18)
      });
    }
  }

  if (t mod 2 == 0) {
    for (var s = 0; s < _seam_n; s++) {
      var _sc5 = erupt_armed_cols[s];
      var _stream_n = erupt_armed_fast ? 1 : 2;
      for (var _ds = 0; _ds < _stream_n; _ds++) {
        array_push(erupt_code_streams, {
          x : _sc5.cx + random_range(-_sc5.w, _sc5.w) * 0.48,
          y : _k_er_floor_y + random_range(-3, 7),
          len : random_range(30, 95) * (0.7 + erupt_coil * 0.65),
          vy : -random_range(3.0, 7.4) * (0.7 + erupt_coil),
          w : random_range(1.5, 4.2),
          life : irandom_range(14, 28),
          life_max : 28,
          hot : erupt_coil,
          color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
          seed : random(1000)
        });
      }
    }
  }

  vignette_pulse = max(vignette_pulse, 0.2 + erupt_coil * (0.32 + erupt_pressure * 0.24));
  bloom_pulse = max(bloom_pulse, erupt_coil * (0.18 + erupt_pressure * 0.22));
  global_ripple_pulse = max(global_ripple_pulse, erupt_coil * 0.12);
  aberration_pulse = max(aberration_pulse, erupt_coil * (0.14 + erupt_pressure * 0.24));

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = max(oCameraController.letterbox_target,
                                             erupt_coil * (0.45 + erupt_pressure * 0.5));
    oCameraController.shake = max(oCameraController.shake, erupt_coil * (1.6 + erupt_pressure * 3.4));
  }
}

if (_er_live && !erupt_collapsing) {
  var _grav_rate = 0.22 + erupt_pressure * 0.5 + erupt_coil * 0.9;
  if (random(1) < _grav_rate) {
    array_push(erupt_gravel, {
      x : random(room_width),
      y : _k_er_floor_y - random(3),
      yspeed : -random_range(0.7, 2.4) * (1 + erupt_pressure),
      size : random_range(1.2, 3.4),
      life : irandom_range(18, 34), life_max : 34
    });
  }

  erupt_shudder = lerp(erupt_shudder, erupt_pressure * 0.9 + erupt_coil * 3.2, 0.3);
  erupt_floor_heat = lerp(erupt_floor_heat, erupt_materialize * (0.12 + erupt_pressure * 0.5 + erupt_coil * 0.5), 0.15);
} else {
  erupt_shudder = lerp(erupt_shudder, 0, 0.2);
  erupt_floor_heat = lerp(erupt_floor_heat, 0, 0.06);
}

var _er_fire_now = false;
var _er_fire_cols = [];
var _er_fire_h = 0;
var _er_fire_rise = 0;
var _er_fire_esc = 0;
var _er_fire_fast = false;
var _er_fire_stray = 0;
var _er_fire_collapse = false;

if (_er_live && !erupt_collapsing) {
  for (var i = 0; i < array_length(_k_er_beats); i++) {
    if (last_t < _k_er_beats[i] && t >= _k_er_beats[i]) {
      erupt_beat_index = i;

      var _plan = _k_er_plan[i];
      _er_fire_now = true;
      _er_fire_cols = _plan.cols;
      _er_fire_h = _plan.slab_h;
      _er_fire_fast = _plan.fast;
      _er_fire_rise = _plan.rise * (_er_fire_fast ? _k_er_fast_rise_mult : 1);
      _er_fire_stray = _plan.stray;
      _er_fire_esc = i / max(array_length(_k_er_beats) - 1, 1);
      break;
    }
  }
}

var _er_sw_arm_t = _k_er_side_burst_t - _k_er_side_burst_warn_lead;

if (t >= _er_sw_arm_t && t < _k_er_side_burst_t && er_lift_active) {
  var _sw_p = clamp((t - _er_sw_arm_t) / max(_k_er_side_burst_warn_lead, 1), 0, 1);
  var _sw_c = max(_sw_p, _k_er_side_warn_read_floor);
  var _sw_y = er_lift_top_y + _k_er_side_burst_y_off;

  var _sw_head = lerp(_k_er_side_warn_gate_w * 0.72,
                      room_width * 0.5 - 10,
                      power(_sw_p, 0.78));

  if (t mod 2 == 0) {
    var _sw_vn = 4 + round(5 * _sw_c);
    for (var _sv = 0; _sv < _sw_vn; _sv++) {
      var _sv_side = choose(-1, 1);
      var _sv_x = (random(1) < 0.62)
                ? ((_sv_side < 0) ? random(_sw_head) : room_width - random(_sw_head))
                : random(room_width);
      scr_spawn_vent_stream(erupt_side_warn_vents,
        _sv_x, _sw_y + random_range(-3, 3),
        90 + random_range(-lerp(24, 7, _sw_c), lerp(24, 7, _sw_c)),
        _sw_c, _k_er_side_warn_vent_cols, 200);
    }
  }

  if (t mod 3 == 0) {
    var _sw_an = 1 + floor(_sw_c * 2);
    for (var _sa = 0; _sa < _sw_an; _sa++) {
      var _sa_side = choose(-1, 1);
      var _sa_x = (_sa_side < 0) ? random_range(10, _sw_head)
                                 : room_width - random_range(10, _sw_head);
      var _sa_rail = random_range(34, 92);
      array_push(erupt_charge_arcs, {
        x1 : _sa_x + _sa_side * random_range(20, 70),
        y1 : _sw_y - _sa_rail,
        x2 : _sa_x,
        y2 : _sw_y + random_range(-4, 4),
        life : irandom_range(8, 15),
        life_max : 15,
        hot : _sw_c,
        color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
        off : scr_bolt_offsets(5, 8 + _sw_c * 18)
      });
    }
  }

  vignette_pulse   = max(vignette_pulse, _sw_c * 0.2);
  bloom_pulse      = max(bloom_pulse, _sw_c * _sw_c * 0.18);
  aberration_pulse = max(aberration_pulse, _sw_c * _sw_c * 0.16);
}

scr_update_vent_streams(erupt_side_warn_vents);

if (timeline_hit(_er_sw_arm_t) && er_lift_active) {
  var _arm_y = er_lift_top_y + _k_er_side_burst_y_off;
  for (var _es = 0; _es < 2; _es++) {
    var _edir = (_es == 0) ? 1 : -1;
    var _edge_x = (_es == 0) ? 0 : room_width;
    repeat(18) {
      array_push(erupt_sparks, {
        x : _edge_x + _edir * random_range(0, 10),
        y : _arm_y + random_range(-18, 18),
        xspeed : _edir * random_range(2.5, 7.0),
        yspeed : random_range(-3.2, 2.0),
        size : random_range(2, 5.5),
        life : irandom_range(18, 30),
        life_max : 30,
        color : merge_color(choose(_k_er_col_warning, _k_er_col_cyan), c_white,
                            random_range(0.3, 0.9))
      });
    }
  }
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 3.5);
  }
}

if (timeline_hit(_k_er_side_burst_t) && er_lift_active) {
  var _side_y = er_lift_top_y + _k_er_side_burst_y_off;
  var _side_col = merge_color(_k_er_col_hot, c_white, 0.55);
  array_push(erupt_side_bursts, {
    dir : 1,
    y : _side_y,
    life : _k_er_side_burst_duration,
    life_max : _k_er_side_burst_duration,
    seed : random(1000),
    col : _side_col
  });
  array_push(erupt_side_bursts, {
    dir : -1,
    y : _side_y,
    life : _k_er_side_burst_duration,
    life_max : _k_er_side_burst_duration,
    seed : random(1000),
    col : _side_col
  });
}

for (var i = array_length(erupt_side_bursts) - 1; i >= 0; i--) {
  var _sb = erupt_side_bursts[i];
  var _age = _sb.life_max - _sb.life;
  var _sp = clamp(_age / max(_sb.life_max - 1, 1), 0, 1);
  var _sweep = 1 - power(1 - clamp(_sp * 1.45, 0, 1), 3);
  var _x0 = (_sb.dir > 0) ? 0 : room_width;
  var _x1 = _x0 + _sb.dir * room_width * _sweep;
  if (_sp > 0.08 && instance_exists(oPlayer) && !instance_exists(oGameover)) {
    if (player_meeting_line_width(_x0, _sb.y, _x1, _sb.y, _k_er_side_burst_hit_r)) {
      player_register_hazard_hit();
    }
  }
  if (t mod 2 == 0 && _sp < 0.9) {
    var _spark_x = lerp(_x0, _x1, random(1));
    array_push(erupt_sparks, {
      x : _spark_x,
      y : _sb.y + random_range(-5, 8),
      xspeed : _sb.dir * random_range(1.5, 5.0) + random_range(-1.0, 1.0),
      yspeed : -random_range(0.6, 3.4),
      size : random_range(1.4, 4.4),
      life : irandom_range(12, 24),
      life_max : 24,
      color : merge_color(_sb.col, c_white, random_range(0.15, 0.8))
    });
  }
  _sb.life--;
  if (_sb.life <= 0) array_delete(erupt_side_bursts, i, 1);
}

if (_er_fire_now) {
  var _e = _er_fire_esc;

  erupt_flash = 1;
  erupt_coil = 0;
  erupt_pressure = min(1, (erupt_beat_index + 1) / array_length(_k_er_beats));

  scr_bg_bass_hit();

  vignette_pulse = max(vignette_pulse, lerp(_k_er_vignette[0], _k_er_vignette[1], _e));
  aberration_pulse = max(aberration_pulse, lerp(_k_er_aberration[0], _k_er_aberration[1], _e));
  bloom_pulse = max(bloom_pulse, lerp(_k_er_bloom[0], _k_er_bloom[1], _e));
  global_ripple_pulse = max(global_ripple_pulse, lerp(_k_er_ripple[0], _k_er_ripple[1], _e));
  tear_amount = max(tear_amount, lerp(_k_er_tear[0], _k_er_tear[1], _e));

  if (instance_exists(oCameraController)) {
    var _shake = lerp(_k_er_shake[0], _k_er_shake[1], _e) + (_er_fire_fast ? 1.5 : 0);
    oCameraController.shake = max(oCameraController.shake, _shake);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, lerp(_k_er_zoom[0], _k_er_zoom[1], _e));
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                               lerp(_k_er_flash[0], _k_er_flash[1], _e));
    oCameraController.angle_kick += (erupt_beat_index mod 2 == 0 ? 1 : -1)
                                  * lerp(_k_er_angle_kick[0], _k_er_angle_kick[1], _e);
    oCameraController.letterbox_target = 0;
  }

  erupt_shudder = 6 + _e * 8;
}

if (timeline_hit(_k_er_collapse_t) && !erupt_collapsing) {
  bh_phase_charge = 0;
  bh_heartbeat = 0;
  bh_breakdown = 0;
  bh_drop_flash = 0;
  bh_scene_reverse = 0;
  bh_reverse_frames = 0;
  bullets_rewinding = false;
  blackhole_push_mode = false;
  bh_inversion_rings = [];
  bh_swallow_flashes = [];
  bh_ambient_arcs = [];
  bh_horizon_cracks = [];
  bh_infall_streaks = [];
  bh_kunai_bursts = [];
  bh_edge_waves = [];
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

  erupt_collapsing = true;
  erupt_collapse_timer = 0;
  erupt_flash = 1;
  erupt_pressure = 1;

  swirl_target = 0.8;
  swirl_center_x = 400;
  swirl_center_y = _k_er_floor_y - 40;
  swirl_radius_px = 110;
  swirl_strength = 10;

  _er_fire_now = true;
  _er_fire_cols = _k_er_collapse_cols;
  _er_fire_h = _k_er_collapse_slab_h;
  _er_fire_rise = _k_er_collapse_rise;
  _er_fire_fast = true;
  _er_fire_stray = 0;
  _er_fire_esc = 1;
  _er_fire_collapse = true;
  var _bh_seed_a = scr_pick_blackhole_spawn();
  var _bh_seed_b = scr_pick_blackhole_spawn(_bh_seed_a[0], _bh_seed_a[1]);
  blackhole_pending = [ _bh_seed_a, _bh_seed_b ];
  for (var i = 0; i < array_length(blackhole_pending); i++) {
    var _p = blackhole_pending[i];
    var _tele = instance_create_layer(_p[0], _p[1], layer, oBlackHoleTelegraph);
    _tele.telegraph_life = 2681 - _k_er_collapse_t;

    repeat(5) {
      array_push(erupt_seed_streams, {
        sx : clamp(_p[0] + random_range(-90, 90), 20, room_width - 20),
        sy : _k_er_floor_y - random_range(0, 20),
        tx : _p[0], ty : _p[1],
        prog : random_range(-0.25, 0),
        speed : random_range(0.022, 0.04),
        life : 70, life_max : 70,
        w : random_range(2, 5),
        bow : random_range(-70, 70)
      });
    }

    repeat(9) {
      var _floor_seed = clamp(_p[0] + random_range(-260, 260), 16, room_width - 16);
      array_push(erupt_collapse_beams, {
        sx : _floor_seed,
        sy : _k_er_floor_y + random_range(-6, 8),
        tx : _p[0] + random_range(-16, 16),
        ty : _p[1] + random_range(-16, 16),
        prog : -random_range(0, 0.28),
        speed : random_range(0.028, 0.055),
        life : 74,
        life_max : 74,
        w : random_range(2.0, 6.0),
        bow : random_range(-120, 120),
        hot : random_range(0.7, 1),
        color : choose(_k_er_col_cyan, _k_er_col_warning, c_white),
        off : scr_bolt_offsets(6, random_range(12, 34))
      });
    }

    array_push(erupt_reactor_rings, {
      cx : _p[0],
      cy : _p[1],
      rx : 16,
      ry : 6,
      rx_max : 130,
      ry_max : 46,
      life : 40,
      life_max : 40,
      hot : 1,
      color : _k_er_col_cyan
    });
  }

  for (var _cl = 0; _cl < 7; _cl++) {
    array_push(erupt_scan_sweeps, {
      x : room_width * 0.5,
      y : _k_er_floor_y - _cl * 6,
      w : room_width + 220,
      vy : -random_range(8.0, 16.0),
      life : 24 + _cl * 2,
      life_max : 24 + _cl * 2,
      hot : 1,
      color : (_cl mod 2 == 0) ? c_white : _k_er_col_cyan,
      seed : random(1000)
    });
  }

  scr_bg_bass_hit();
  vignette_pulse = max(vignette_pulse, _k_er_collapse_vignette);
  aberration_pulse = max(aberration_pulse, _k_er_collapse_aberration);
  bloom_pulse = max(bloom_pulse, _k_er_collapse_bloom);
  global_ripple_pulse = max(global_ripple_pulse, _k_er_collapse_ripple);
  tear_amount = max(tear_amount, _k_er_collapse_tear);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_er_collapse_shake);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_er_collapse_zoom);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, _k_er_collapse_flash);
    oCameraController.angle_kick += 3.5;
    oCameraController.letterbox_target = _k_bh_breakdown_letterbox;
  }

  scr_add_light(400, _k_er_floor_y - 30, c_white, 16);
  scr_floor_impact(400, _k_er_floor_y, 1.15, 1);

  for (var r = 0; r < 8; r++) {
    var _rx = 50 + r * 100;
    array_push(erupt_ridges, {
      x : _rx,
      dir : (r mod 2 == 0) ? -1 : 1,
      dist : 0,
      max_dist : random_range(220, 420),
      life : 44, life_max : 44,
      color : c_white
    });
  }

  for (var d = 0; d < 26; d++) {
    var _dang = random_range(200, 340);
    array_push(ember_spray, {
      x : random(room_width), y : _k_er_floor_y - random(10),
      xspeed : lengthdir_x(random_range(2, 8), _dang),
      yspeed : lengthdir_y(random_range(2, 8), _dang),
      size : random_range(2, 7),
      life : irandom_range(26, 52), life_max : 52,
      color : merge_color(_k_er_col_hot, c_white, random(1))
    });
  }
  for (var c = 0; c < 14; c++) {
    array_push(erupt_shards, {
      x : random(room_width), y : _k_er_floor_y - random_range(0, 30),
      xspeed : random_range(-5, 5),
      yspeed : -random_range(3, 9),
      size : random_range(6, 18),
      rot : random(360), spin : random_range(-9, 9),
      life : 46, life_max : 46,
      seed : random(1000)
    });
  }
}

if (_er_fire_now) {
  var _e2 = _er_fire_esc;

  var _fire_col = (_e2 < 0.5) ? merge_color(_k_er_col_deep, _k_er_col_molten, _e2 * 2)
                              : merge_color(_k_er_col_molten, _k_er_col_hot, (_e2 - 0.5) * 2);
  if (_er_fire_fast) _fire_col = merge_color(_fire_col, _k_er_col_white, 0.5 + _e2 * 0.4);
  if (_er_fire_collapse) _fire_col = c_white;

  var _panel_col = merge_color(_k_er_col_armor_edge, c_white, 0.18 + _e2 * 0.55);
  if (_er_fire_fast) _panel_col = merge_color(_k_er_col_cyan, c_white, 0.45 + _e2 * 0.35);
  if (_er_fire_collapse) _panel_col = c_white;

  var _hit_r = _er_fire_fast ? _k_er_spear_w * 0.5 : 16;
  var _base_size = _hit_r / 5;

  for (var c = 0; c < array_length(_er_fire_cols); c++) {
    var _col = _er_fire_cols[c];
    var _cx = _col.cx;
    var _cw = _col.w;

    var _span_x = max(0, _cw - _hit_r * 2);
    var _span_y = max(0, _er_fire_h - _hit_r * 2);
    var _nx = max(1, ceil(_span_x / 24) + 1);
    var _ny = max(3, ceil(_span_y / 24) + 1);
    var _stepx = (_nx > 1) ? _span_x / (_nx - 1) : 0;
    var _stepy = (_ny > 1) ? _span_y / (_ny - 1) : 0;

    var _bullets = [];
    for (var ix = 0; ix < _nx; ix++) {
      for (var iy = 0; iy < _ny; iy++) {
        var _bx = _cx - _cw * 0.5 + _hit_r + ix * _stepx;
        var _oy = _hit_r + iy * _stepy;

        var _b = instance_create_layer(_bx, _k_er_floor_y + _oy, "Instances", oRedOrbSquares);
        _b.speed = 0;
        _b.direction = 270;
        _b.expand_curve_rate = 0;
        _b.is_corner = false;

        _b.pop_scale = 1;
        _b.pop_target = 1;
        _b.pop_overshoot = false;
        _b.pop_flash = 0;
        _b.base_size = _base_size;
        _b.image_xscale = _base_size;
        _b.image_yscale = _base_size;

        _b.stretch_enabled = false;

        _b.glow_mult = 0.5;
        _b.hide_visual = !_er_fire_fast;
        if (_b.hide_visual) {
          _b.glow_mult = 0;
          _b.birth_heat = 0;
        }

        _b.burst_escalation = _e2;
        _b.glow_color = _fire_col;
        _b.image_blend = _fire_col;
        _b.light_color = _fire_col;

        array_push(_bullets, { inst : _b, bx : _bx, oy : _oy });
      }
    }

    var _edge = [];
    var _edge_n = _er_fire_fast ? 5 : 9;
    for (var s = 0; s <= _edge_n; s++) {
      array_push(_edge, {
        l : random(_er_fire_fast ? 2 : 5),
        r : random(_er_fire_fast ? 2 : 5)
      });
    }
    var _crown = [];
    var _crown_n = _er_fire_fast ? 3 : max(3, round(_cw / 34));
    for (var s = 0; s <= _crown_n; s++) {
      array_push(_crown, random(_er_fire_fast ? 5 : 14));
    }

    array_push(erupt_pillars, {
      cx : _cx, w : _cw, h : _er_fire_h,
      y : _k_er_floor_y,
      vy : -_er_fire_rise,
      esc : _e2,
      fast : _er_fire_fast,
      collapse : _er_fire_collapse,
      visual_pad : 0,
      heat : 1,
      seed : random(1000),
      spent : false,
      col : _panel_col,
      edge : _edge,
      crown : _crown,
      bullets : _bullets
    });

    array_push(erupt_panel_afterimages, {
      cx : _cx,
      w : _cw + (_er_fire_fast ? 22 : 44),
      h : _er_fire_h + (_er_fire_fast ? 40 : 72),
      y : _k_er_floor_y,
      vy : -_er_fire_rise * 0.72,
      life : _er_fire_fast ? 16 : 24,
      life_max : _er_fire_fast ? 16 : 24,
      fast : _er_fire_fast,
      hot : 0.55 + _e2 * 0.45,
      color : _panel_col,
      seed : random(1000)
    });

    array_push(erupt_reactor_rings, {
      cx : _cx,
      cy : _k_er_floor_y,
      rx : _cw * 0.52,
      ry : 4,
      rx_max : _cw * (_er_fire_fast ? 1.2 : 1.8) + 80 + _e2 * 110,
      ry_max : 20 + _e2 * 24,
      life : _er_fire_fast ? 18 : 28,
      life_max : _er_fire_fast ? 18 : 28,
      hot : 0.55 + _e2 * 0.45,
      color : _panel_col
    });

    array_push(erupt_lock_frames, {
      cx : _cx,
      w : _cw,
      life : _er_fire_fast ? 14 : 20,
      life_max : _er_fire_fast ? 14 : 20,
      hot : 0.75 + _e2 * 0.25,
      fast : _er_fire_fast,
      seed : random(1000)
    });

    var _scan_n = _er_fire_fast ? 1 : 2;
    for (var _sn = 0; _sn < _scan_n; _sn++) {
      array_push(erupt_scan_sweeps, {
        x : _cx,
        y : _k_er_floor_y - _sn * 10,
        w : max(_cw + 130 + _sn * 80, 160),
        vy : -random_range(6.0, 10.5) * (0.85 + _e2 * 0.5),
        life : _er_fire_fast ? 18 : 26,
        life_max : _er_fire_fast ? 18 : 26,
        hot : 0.7 + _e2 * 0.3,
        color : (_sn == 0) ? _panel_col : _k_er_col_cyan,
        seed : random(1000)
      });
    }

    var _code_n = _er_fire_fast ? 4 : 8 + floor(_e2 * 7);
    for (var _cd = 0; _cd < _code_n; _cd++) {
      array_push(erupt_code_streams, {
        x : _cx + random_range(-_cw, _cw) * 0.55,
        y : _k_er_floor_y + random_range(-4, 10),
        len : random_range(36, 130) * (0.8 + _e2 * 0.55),
        vy : -random_range(5.0, 12.0) * (_er_fire_fast ? 1.45 : 1),
        w : random_range(1.4, 5.0),
        life : irandom_range(16, 34),
        life_max : 34,
        hot : 0.75 + _e2 * 0.25,
        color : choose(_panel_col, _k_er_col_cyan, c_white),
        seed : random(1000)
      });
    }

    var _arc_n = _er_fire_fast ? 2 : 4 + floor(_e2 * 3);
    for (var _aa = 0; _aa < _arc_n; _aa++) {
      var _rail_side = choose(-1, 1);
      array_push(erupt_charge_arcs, {
        x1 : clamp(_cx + _rail_side * random_range(_cw * 0.5 + 16, _cw + 140), 0, room_width),
        y1 : _k_er_floor_y - random_range(20, 100),
        x2 : _cx + random_range(-_cw, _cw) * 0.42,
        y2 : _k_er_floor_y - random_range(2, 14),
        life : irandom_range(8, 16),
        life_max : 16,
        hot : 0.75 + _e2 * 0.25,
        color : choose(_panel_col, _k_er_col_cyan, _k_er_col_violet),
        off : scr_bolt_offsets(5, 10 + _e2 * 22)
      });
    }

    scr_add_light(_cx, _k_er_floor_y - 20, _panel_col, 5 + _e2 * 7);
    scr_floor_impact(_cx, _k_er_floor_y, 0.42 + _e2 * 0.5);

    var _ridge_n = _er_fire_fast ? 1 : 2;
    for (var rr = 0; rr < _ridge_n; rr++) {
      for (var sgn = -1; sgn <= 1; sgn += 2) {
        array_push(erupt_ridges, {
          x : _cx + sgn * _cw * 0.5,
          dir : sgn,
          dist : 0,
          max_dist : lerp(90, 230, _e2) + rr * 60,
          life : 26 + rr * 6, life_max : 26 + rr * 6,
          color : (rr == 0) ? merge_color(_panel_col, c_white, 0.5) : _panel_col
        });
      }
    }

    var _spark_n = _er_fire_fast ? 5 : (8 + floor(_e2 * 10));
    for (var sp = 0; sp < _spark_n; sp++) {
      var _sang = random_range(200, 340);
      array_push(erupt_sparks, {
        x : _cx + random_range(-_cw, _cw) * 0.5,
        y : _k_er_floor_y - random(6),
        xspeed : lengthdir_x(random_range(1.5, 5 + _e2 * 4), _sang),
        yspeed : lengthdir_y(random_range(1.5, 5 + _e2 * 4), _sang),
        size : random_range(1.5, 3.5 + _e2 * 2),
        life : irandom_range(14, 30), life_max : 30,
        color : merge_color(_panel_col, c_white, random(0.6))
      });
    }

    array_push(erupt_scars, {
      cx : _cx, w : _cw,
      life : 300, life_max : 300,
      seed : random(1000),
      hot : 0.6 + _e2 * 0.4
    });

    if (array_length(erupt_lane_residue) >= _k_er_lane_residue_max) {
      array_delete(erupt_lane_residue, 0, 1);
    }
    array_push(erupt_lane_residue, {
      cx : _cx,
      w : _cw + (_er_fire_fast ? 18 : 36),
      life : _er_fire_fast ? round(_k_er_lane_residue_life * 0.72) : _k_er_lane_residue_life,
      life_max : _er_fire_fast ? round(_k_er_lane_residue_life * 0.72) : _k_er_lane_residue_life,
      hot : 0.52 + _e2 * 0.48,
      fast : _er_fire_fast,
      seed : random(1000),
      color : _panel_col
    });

    for (var st = 0; st < _er_fire_stray; st++) {
      for (var sgn2 = -1; sgn2 <= 1; sgn2 += 2) {
        var _sx = _cx + sgn2 * (_cw * 0.5 + 6);
        if (_sx > -20 && _sx < room_width + 20) {
          var _sb = instance_create_layer(_sx, _k_er_floor_y - 14, "Instances", oRedOrbSquares);
          _sb.speed = 4.5;
          _sb.direction = (sgn2 > 0) ? 0 : 180;
          _sb.expand_curve_rate = 0;
          _sb.is_corner = false;
          _sb.stretch_enabled = true;
          _sb.base_size = 3;
          _sb.pop_scale = 1.5;
          _sb.pop_target = 1;
          _sb.pop_overshoot = false;
          _sb.image_xscale = 3;
          _sb.image_yscale = 3;
          _sb.burst_escalation = _e2;
          _sb.glow_color = _fire_col;
          _sb.image_blend = _fire_col;
          _sb.light_color = _fire_col;

          array_push(erupt_strays, { inst : _sb, life : 44, life_max : 44 });
        }
      }
    }
  }
}

if (erupt_collapsing) {
  erupt_collapse_timer++;
  var _dp = clamp(erupt_collapse_timer / _k_er_collapse_duration, 0, 1);

  vignette_pulse = max(vignette_pulse, 0.35 + _dp * 0.5);
  aberration_pulse = max(aberration_pulse, 0.2 + _dp * 0.5);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 4 + _dp * 10);
  }

  if (t mod 2 == 0) {
    array_push(erupt_shards, {
      x : random(room_width), y : _k_er_floor_y - random(6),
      xspeed : random_range(-3, 3),
      yspeed : -random_range(1, 5) * (1 - _dp * 0.5),
      size : random_range(4, 13),
      rot : random(360), spin : random_range(-7, 7),
      life : 34, life_max : 34,
      seed : random(1000)
    });
  }

  if (erupt_collapse_timer >= _k_er_collapse_duration) {
    erupt_collapsing = false;
    erupt_despawn_active = true;
    erupt_despawn_timer = 0;
    erupt_despawn_flash = 1;
    erupt_despawn_sink = 0;
    erupt_active_until = t + _k_er_despawn_duration;
    swirl_target = 0;

    erupt_despawn_sweeps = [];
    erupt_despawn_plates = [];
    erupt_despawn_threads = [];
    erupt_despawn_motes = [];

    var _seed_a_x = 270;
    var _seed_a_y = 220;
    var _seed_b_x = 530;
    var _seed_b_y = 220;
    if (array_length(blackhole_pending) > 0) {
      _seed_a_x = blackhole_pending[0][0];
      _seed_a_y = blackhole_pending[0][1];
    }
    if (array_length(blackhole_pending) > 1) {
      _seed_b_x = blackhole_pending[1][0];
      _seed_b_y = blackhole_pending[1][1];
    }

    for (var s = 0; s < _k_er_despawn_sweep_count; s++) {
      var _sf = s / max(1, _k_er_despawn_sweep_count - 1);
      array_push(erupt_despawn_sweeps, {
        x : lerp(-60, room_width + 60, _sf),
        y : _k_er_floor_y + random_range(-5, 3),
        w : random_range(80, 170),
        delay : s * 3 + irandom(3),
        life : 28 + s * 2,
        life_max : 28 + s * 2,
        dir : (s mod 2 == 0) ? -1 : 1,
        seed : random(1000),
        hot : random_range(0.55, 1)
      });
    }

    for (var p = 0; p < _k_er_despawn_plate_count; p++) {
      var _px = lerp(20, room_width - 20, p / max(1, _k_er_despawn_plate_count - 1))
              + random_range(-18, 18);
      var _side = (_px < room_width * 0.5) ? -1 : 1;
      array_push(erupt_despawn_plates, {
        x : _px,
        y : _k_er_floor_y + random_range(-2, 8),
        w : random_range(20, 56),
        h : random_range(5, 14),
        xspeed : _side * random_range(0.4, 2.2),
        yspeed : -random_range(1.2, 5.0),
        rot : random(360),
        spin : random_range(-8, 8),
        life : irandom_range(42, 66),
        life_max : 66,
        seed : random(1000),
        hot : random_range(0.35, 1)
      });
    }

    for (var th = 0; th < _k_er_despawn_thread_count; th++) {
      var _sx = random(room_width);
      var _go_left = (th mod 2 == 0);
      var _tx = _go_left ? _seed_a_x : _seed_b_x;
      var _ty = _go_left ? _seed_a_y : _seed_b_y;
      array_push(erupt_despawn_threads, {
        sx : _sx,
        sy : _k_er_floor_y + random_range(-10, 6),
        tx : _tx + random_range(-18, 18),
        ty : _ty + random_range(-14, 14),
        prog : -random_range(0, 0.32),
        speed : random_range(0.016, 0.034),
        life : 82,
        life_max : 82,
        w : random_range(1.2, 4.4),
        bow : random_range(-150, 150),
        color : merge_color(_k_er_col_hot, c_white, random_range(0.15, 0.85)),
        seed : random(1000)
      });
    }

    repeat(42) {
      var _ma = random_range(185, 355);
      array_push(erupt_despawn_motes, {
        x : random(room_width),
        y : _k_er_floor_y + random_range(-8, 12),
        xspeed : lengthdir_x(random_range(1.2, 6), _ma),
        yspeed : lengthdir_y(random_range(1.2, 6), _ma),
        size : random_range(1.2, 5.5),
        life : irandom_range(34, 72),
        life_max : 72,
        color : merge_color(_k_er_col_armor_edge, c_white, random_range(0.1, 0.75))
      });
    }
  }
}

if (erupt_despawn_active) {
  erupt_despawn_timer++;
  var _edp = clamp(erupt_despawn_timer / _k_er_despawn_duration, 0, 1);
  var _ed_in = 1 - power(1 - _edp, 3);
  var _ed_out = power(1 - _edp, 2);

  erupt_despawn_sink = lerp(erupt_despawn_sink, 46 * _ed_in, 0.22);
  erupt_floor_heat = max(erupt_floor_heat, _ed_out * 0.75);
  erupt_shudder = max(erupt_shudder, _ed_out * 5.5);
  erupt_despawn_flash = max(0, erupt_despawn_flash - 0.045);

  vignette_pulse = max(vignette_pulse, 0.18 + _ed_out * 0.28);
  bloom_pulse = max(bloom_pulse, _ed_out * 0.22);
  aberration_pulse = max(aberration_pulse, _ed_out * 0.18);
  global_ripple_pulse = max(global_ripple_pulse, _ed_out * 0.16);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 1.2 + _ed_out * 4.5);
  }

  if (erupt_despawn_timer mod 3 == 0 && _edp < 0.82) {
    repeat(2) {
      var _mx = random(room_width);
      var _ma2 = random_range(210, 330);
      array_push(erupt_despawn_motes, {
        x : _mx,
        y : _k_er_floor_y + random_range(-4, 12),
        xspeed : lengthdir_x(random_range(0.8, 4.5), _ma2),
        yspeed : lengthdir_y(random_range(0.8, 4.5), _ma2) - _edp * 1.8,
        size : random_range(1, 4.2),
        life : irandom_range(24, 54),
        life_max : 54,
        color : merge_color(_k_er_col_armor_edge, _k_er_col_cyan, random_range(0.35, 1))
      });
    }
  }

  if (erupt_despawn_timer >= _k_er_despawn_duration) {
    erupt_despawn_active = false;
    erupt_active_until = t - 1;
    erupt_floor_heat = 0;
    erupt_shudder = 0;
  }
}

for (var i = array_length(erupt_despawn_sweeps) - 1; i >= 0; i--) {
  var _sw = erupt_despawn_sweeps[i];
  _sw.delay--;
  if (_sw.delay <= 0) {
    _sw.x += _sw.dir * (2.4 + _sw.hot * 3.4);
    _sw.y += 0.55;
    _sw.w = lerp(_sw.w, 20, 0.07);
    _sw.life--;
  }
  if (_sw.life <= 0) array_delete(erupt_despawn_sweeps, i, 1);
}

for (var i = array_length(erupt_despawn_plates) - 1; i >= 0; i--) {
  var _pl = erupt_despawn_plates[i];
  _pl.x += _pl.xspeed;
  _pl.y += _pl.yspeed;
  _pl.yspeed += 0.2;
  _pl.xspeed *= 0.985;
  _pl.rot += _pl.spin;
  _pl.spin *= 0.985;
  _pl.life--;
  if (_pl.life <= 0 || _pl.y > _k_er_floor_y + 86) array_delete(erupt_despawn_plates, i, 1);
}

for (var i = array_length(erupt_despawn_threads) - 1; i >= 0; i--) {
  var _dt = erupt_despawn_threads[i];
  _dt.prog += _dt.speed;
  _dt.life--;
  if (_dt.prog >= 1 || _dt.life <= 0) array_delete(erupt_despawn_threads, i, 1);
}

for (var i = array_length(erupt_despawn_motes) - 1; i >= 0; i--) {
  var _dm = erupt_despawn_motes[i];
  _dm.x += _dm.xspeed;
  _dm.y += _dm.yspeed;
  _dm.yspeed += 0.13;
  _dm.xspeed *= 0.982;
  _dm.life--;
  if (_dm.life <= 0) array_delete(erupt_despawn_motes, i, 1);
}

for (var i = array_length(erupt_pillars) - 1; i >= 0; i--) {
  var _p2 = erupt_pillars[i];

  _p2.y += _p2.vy;
  _p2.vy += _k_er_grav;
  _p2.heat = max(0, _p2.heat - (_p2.fast ? 0.02 : 0.03));

  for (var b = 0; b < array_length(_p2.bullets); b++) {
    var _bb = _p2.bullets[b];
    if (instance_exists(_bb.inst)) {
      _bb.inst.x = _bb.bx;
      _bb.inst.y = _p2.y + _bb.oy;
    }
  }

  if (t mod 2 == 0) {
    scr_add_light(_p2.cx, _p2.y + _p2.h * 0.5, _p2.col, 1.2 + _p2.esc * 1.6 + _p2.heat * 2);
  }

  var _retire = false;

  if (_p2.fast) {
    if (_p2.y + _p2.h < -60) _retire = true;
  } else if (_p2.vy >= -1.2 && !_p2.spent) {
    _p2.spent = true;
    _retire = true;

    var _chip_n = 8 + floor(_p2.esc * 8);
    for (var s = 0; s < _chip_n; s++) {
      array_push(erupt_shards, {
        x : _p2.cx + random_range(-_p2.w, _p2.w) * 0.5,
        y : _p2.y + random(_p2.h),
        xspeed : random_range(-6, 6),
        yspeed : -random_range(1.5, 6),
        size : random_range(5, 16),
        rot : random(360), spin : random_range(-8, 8),
        life : 40, life_max : 40,
        seed : random(1000)
      });
    }
    for (var s = 0; s < 10; s++) {
      var _cang = random_range(190, 350);
      array_push(ember_spray, {
        x : _p2.cx + random_range(-_p2.w, _p2.w) * 0.5,
        y : _p2.y + random(_p2.h),
        xspeed : lengthdir_x(random_range(1, 4), _cang),
        yspeed : lengthdir_y(random_range(1, 4), _cang),
        size : random_range(2, 5),
        life : irandom_range(20, 38), life_max : 38,
        color : _p2.col
      });
    }

    scr_add_light(_p2.cx, _p2.y + _p2.h * 0.5, merge_color(_p2.col, c_white, 0.5), 3 + _p2.esc * 3);
  }

  if (_retire) {
    for (var b = 0; b < array_length(_p2.bullets); b++) {
      if (instance_exists(_p2.bullets[b].inst)) instance_destroy(_p2.bullets[b].inst);
    }
    array_delete(erupt_pillars, i, 1);
  }
}

for (var i = array_length(erupt_strays) - 1; i >= 0; i--) {
  var _st2 = erupt_strays[i];
  if (!instance_exists(_st2.inst)) {
    array_delete(erupt_strays, i, 1);
  } else {
    _st2.life--;
    var _sink = 14;
    if (_st2.life <= _sink) {
      var _sk = max(0.02, _st2.life / _sink);
      _st2.inst.image_xscale = 3 * _sk;
      _st2.inst.image_yscale = 3 * _sk;
      _st2.inst.hit_active = _sk > 0.3;
    }
    if (_st2.life <= 0 || _st2.inst.x < -30 || _st2.inst.x > room_width + 30) {
      instance_destroy(_st2.inst);
      array_delete(erupt_strays, i, 1);
    }
  }
}

erupt_flash = max(0, erupt_flash - 0.09);

for (var i = array_length(erupt_lock_frames) - 1; i >= 0; i--) {
  erupt_lock_frames[i].life--;
  if (erupt_lock_frames[i].life <= 0) array_delete(erupt_lock_frames, i, 1);
}

for (var i = array_length(erupt_charge_arcs) - 1; i >= 0; i--) {
  erupt_charge_arcs[i].life--;
  if (erupt_charge_arcs[i].life <= 0) array_delete(erupt_charge_arcs, i, 1);
}

for (var i = array_length(erupt_scan_sweeps) - 1; i >= 0; i--) {
  var _ssw = erupt_scan_sweeps[i];
  _ssw.y += _ssw.vy;
  _ssw.vy *= 0.965;
  _ssw.life--;
  if (_ssw.life <= 0 || _ssw.y < -80) array_delete(erupt_scan_sweeps, i, 1);
}

for (var i = array_length(erupt_code_streams) - 1; i >= 0; i--) {
  var _ds2 = erupt_code_streams[i];
  _ds2.y += _ds2.vy;
  _ds2.x += sin(_ds2.seed + t * 0.14) * (0.2 + _ds2.hot * 0.55);
  _ds2.vy *= 0.972;
  _ds2.life--;
  if (_ds2.life <= 0 || _ds2.y + _ds2.len < -80) array_delete(erupt_code_streams, i, 1);
}

for (var i = array_length(erupt_panel_afterimages) - 1; i >= 0; i--) {
  var _pae = erupt_panel_afterimages[i];
  _pae.y += _pae.vy;
  _pae.vy += _k_er_grav * (_pae.fast ? 0.08 : 0.18);
  _pae.life--;
  if (_pae.life <= 0 || _pae.y + _pae.h < -110) array_delete(erupt_panel_afterimages, i, 1);
}

for (var i = array_length(erupt_reactor_rings) - 1; i >= 0; i--) {
  erupt_reactor_rings[i].life--;
  if (erupt_reactor_rings[i].life <= 0) array_delete(erupt_reactor_rings, i, 1);
}

for (var i = array_length(erupt_lane_residue) - 1; i >= 0; i--) {
  var _elr = erupt_lane_residue[i];
  _elr.life--;
  if (_elr.life <= 0) array_delete(erupt_lane_residue, i, 1);
}

for (var i = array_length(erupt_collapse_beams) - 1; i >= 0; i--) {
  var _cbm = erupt_collapse_beams[i];
  _cbm.prog += _cbm.speed;
  _cbm.life--;
  if (_cbm.prog >= 1 || _cbm.life <= 0) array_delete(erupt_collapse_beams, i, 1);
}

for (var i = array_length(erupt_shards) - 1; i >= 0; i--) {
  var _sh = erupt_shards[i];
  _sh.x += _sh.xspeed;
  _sh.y += _sh.yspeed;
  _sh.yspeed += 0.11;
  _sh.xspeed *= 0.99;
  _sh.rot += _sh.spin;
  _sh.life--;
  if (_sh.life <= 0) array_delete(erupt_shards, i, 1);
}

for (var i = array_length(erupt_gravel) - 1; i >= 0; i--) {
  var _gv = erupt_gravel[i];
  _gv.y += _gv.yspeed;
  _gv.yspeed += 0.22;
  _gv.life--;
  if (_gv.y >= _k_er_floor_y) {
    _gv.y = _k_er_floor_y;
    _gv.yspeed *= -0.35;
    if (abs(_gv.yspeed) < 0.3) _gv.life = min(_gv.life, 4);
  }
  if (_gv.life <= 0) array_delete(erupt_gravel, i, 1);
}

for (var i = array_length(erupt_ridges) - 1; i >= 0; i--) {
  var _rg = erupt_ridges[i];
  _rg.dist = lerp(_rg.dist, _rg.max_dist, 0.16);
  _rg.life--;
  if (_rg.life <= 0) array_delete(erupt_ridges, i, 1);
}

for (var i = array_length(erupt_scars) - 1; i >= 0; i--) {
  erupt_scars[i].life--;
  if (erupt_scars[i].life <= 0) array_delete(erupt_scars, i, 1);
}

for (var i = array_length(erupt_sparks) - 1; i >= 0; i--) {
  var _sk2 = erupt_sparks[i];
  _sk2.x += _sk2.xspeed;
  _sk2.y += _sk2.yspeed;
  _sk2.yspeed += 0.19;
  _sk2.xspeed *= 0.98;
  _sk2.life--;
  if (_sk2.life <= 0) array_delete(erupt_sparks, i, 1);
}

for (var i = array_length(erupt_haze) - 1; i >= 0; i--) {
  var _hz = erupt_haze[i];
  _hz.prog += 0.05;
  _hz.life--;
  if (_hz.life <= 0) array_delete(erupt_haze, i, 1);
}

for (var i = array_length(erupt_seed_streams) - 1; i >= 0; i--) {
  var _cs = erupt_seed_streams[i];
  _cs.prog += _cs.speed;
  _cs.life--;
  if (_cs.prog >= 1 || _cs.life <= 0) array_delete(erupt_seed_streams, i, 1);
}

for (var i = array_length(ember_spray) - 1; i >= 0; i--) {
  var _em = ember_spray[i];
  _em.x += _em.xspeed;
  _em.y += _em.yspeed;
  _em.yspeed += 0.14;
  _em.xspeed *= 0.985;
  _em.life--;
  if (_em.life <= 0) array_delete(ember_spray, i, 1);
}

if (timeline_hit(2598) && array_length(blackhole_pending) == 0 && !instance_exists(oBlackHole)) {
  var _bh_seek_seed_a = scr_pick_blackhole_spawn();
  var _bh_seek_seed_b = scr_pick_blackhole_spawn(_bh_seek_seed_a[0], _bh_seek_seed_a[1]);
  blackhole_pending = [ _bh_seek_seed_a, _bh_seek_seed_b ];
  for (var i = 0; i < array_length(blackhole_pending); i++) {
    var _p = blackhole_pending[i];
    var _tele = instance_create_layer(_p[0], _p[1], layer, oBlackHoleTelegraph);
    _tele.telegraph_life = 2681 - 2598;
  }
}

if (t > _k_er_collapse_t && t <= 2681) {
  var _bd = clamp((t - _k_er_collapse_t) / (2681 - _k_er_collapse_t), 0, 1);
  bh_breakdown = _bd;

  var _bd_e = _bd * _bd;

  vignette_pulse = max(vignette_pulse, _bd_e * _k_bh_dark_max);
  aberration_pulse = max(aberration_pulse, _bd_e * 0.45);
  global_ripple_pulse = max(global_ripple_pulse, _bd_e * 0.22);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = max(oCameraController.letterbox_target, _k_bh_breakdown_letterbox * min(1, _bd * 2.5));
    oCameraController.shake = max(oCameraController.shake, _bd_e * 7);
  }

  if (_bd > 0.35 && t mod 6 == 0) {
    for (var i = 0; i < array_length(blackhole_pending); i++) {
      var _p2 = blackhole_pending[i];
      scr_add_light(_p2[0], _p2[1], global.lightning_color, 2 + _bd_e * 6);
      if (_bd > 0.7) scr_floor_impact(_p2[0], _p2[1], 0.2 + _bd_e * 0.4, 0);
    }
  }

  if (array_length(blackhole_pending) > 0 && _bd > 0.15) {
    var _inrush_n = 1 + floor(_bd_e * 4);
    for (var s = 0; s < _inrush_n; s++) {
      var _seed = blackhole_pending[irandom(array_length(blackhole_pending) - 1)];
      array_push(bh_infall_streaks, {
        ang : random(360),
        dist : random_range(420, 700),
        speed : random_range(6, 15) * (0.5 + _bd_e),
        tx : _seed[0], ty : _seed[1],
        len : random_range(30, 90) * (0.6 + _bd_e)
      });
    }
  }
} else if (t > 2681) {
  bh_breakdown = max(0, bh_breakdown - 0.05);
}

for (var i = array_length(bh_infall_streaks) - 1; i >= 0; i--) {
  var _is = bh_infall_streaks[i];
  _is.dist -= _is.speed;
  _is.speed *= 1.035;
  if (_is.dist <= 10) array_delete(bh_infall_streaks, i, 1);
}

if (timeline_hit(2681)) {
  for (var i = 0; i < array_length(blackhole_pending); i++) {
    scr_spawn_blackhole_safe(blackhole_pending[i]);
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 24);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.2);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.28);
    oCameraController.angle_kick += 2.6;
    oCameraController.letterbox_target = 0;
  }

  vignette_pulse = max(vignette_pulse, 0.8);
  aberration_pulse = max(aberration_pulse, 0.7);
  bloom_pulse = max(bloom_pulse, 0.5);
  global_ripple_pulse = max(global_ripple_pulse, 0.9);
  tear_amount = max(tear_amount, 0.9);

  for (var i = 0; i < array_length(blackhole_pending); i++) {
    var _p3 = blackhole_pending[i];
    array_push(bh_inversion_rings, {
      x : _p3[0], y : _p3[1],
      radius : 260, max_radius : 6,
      life : 26, life_max : 26,
      width : 12, color : c_white, hot : 1, inward : true
    });
    array_push(bh_inversion_rings, {
      x : _p3[0], y : _p3[1],
      radius : 6, max_radius : 220,
      life : 32, life_max : 32,
      width : 9, color : global.lightning_color, hot : 0.6, inward : false
    });
    for (var c = 0; c < 8; c++) {
      array_push(bh_horizon_cracks, {
        x : _p3[0], y : _p3[1],
        ang : random(360),
        len : random_range(40, 110),
        life : 30, life_max : 30,
        seed : random(1000)
      });
    }
    scr_add_light(_p3[0], _p3[1], c_white, 14);
    scr_floor_impact(_p3[0], _p3[1], 1.0);
  }

  blackhole_pending = [];
}

var _bh_rain_now = false;
var _bh_rain_i = -1;
for (var i = 0; i < array_length(bh_rain_beats); i++) {
  if (last_t < bh_rain_beats[i] && t >= bh_rain_beats[i]) {
    _bh_rain_now = true;
    _bh_rain_i = i;
    break;
  }
}

if (_bh_rain_now && !bullets_rewinding) {
  var _rain_e = _bh_rain_i / max(array_length(bh_rain_beats) - 1, 1);

  var _rain_n = max(1, round((2 + floor(_rain_e * 3.2)) * _k_bh_bullet_density));
  for (var r = 0; r < _rain_n; r++) {
    var _x = random_range(0, room_width);
    var _o = instance_create_layer(_x, -20, layer, oBlackHoleBullet);
    _o.direction = 270 + random_range(-20, 20);
    _o.speed = random_range(3, 5) * (1 + _rain_e * 0.55);
    _o.rain_escalation = _rain_e;
  }

  bh_heartbeat = max(bh_heartbeat, 0.35 + _rain_e * 0.65);
  bloom_pulse = max(bloom_pulse, 0.18 + _rain_e * 0.3);
  global_ripple_pulse = max(global_ripple_pulse, 0.12 + _rain_e * 0.28);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 2.5 + _rain_e * 7);
  }
}

if (t >= 2681 && t < 3330) {
  bh_phase_charge = clamp((t - 2681) / (3320 - 2681), 0, 1);

  var _hb_interval = max(9, round(lerp(28, 11, bh_phase_charge)));
  if (t mod _hb_interval == 0) {
    bh_heartbeat = max(bh_heartbeat, 0.2 + bh_phase_charge * 0.55);
    vignette_pulse = max(vignette_pulse, 0.14 + bh_phase_charge * 0.34);
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 1.5 + bh_phase_charge * 5);
    }
  }

  if (instance_number(oBlackHole) >= 2 && random(1) < 0.04 + bh_phase_charge * 0.16) {
    array_push(bh_ambient_arcs, {
      life : 7, life_max : 7,
      off : scr_bolt_offsets(6, 14 + bh_phase_charge * 30),
      color : blackhole_push_mode ? c_white : global.lightning_color
    });
  }
}
bh_heartbeat = max(0, bh_heartbeat - 0.055);
bh_drop_flash = max(0, bh_drop_flash - 0.07);

if (bh_heartbeat > 0) {
  vignette_pulse = max(vignette_pulse, bh_heartbeat * 0.4);
  bloom_pulse = max(bloom_pulse, bh_heartbeat * 0.3);
  aberration_pulse = max(aberration_pulse, bh_heartbeat * 0.25);
}

if (timeline_hit(2968)) {
  bullets_rewinding = true;
  bh_scene_reverse = 1;
  bh_reverse_frames = 44;
  tear_amount = max(tear_amount, 2.0);

  with(oBlackHoleBullet) {
    rewinding = true;
    rewind_frames_left = 40;
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 14);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.12);
    oCameraController.letterbox_target = 0.85;
  }
  aberration_pulse = max(aberration_pulse, 0.7);
  vignette_pulse = max(vignette_pulse, 0.5);
}

if (bh_reverse_frames > 0) {
  bh_reverse_frames--;
  var _rev_p = 1 - (bh_reverse_frames / 44);

  tear_amount = max(tear_amount, 0.9 + _rev_p * 1.4);
  aberration_pulse = max(aberration_pulse, 0.35 + _rev_p * 0.55);
  vignette_pulse = max(vignette_pulse, 0.3 + _rev_p * 0.45);
  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.85);
    oCameraController.shake = max(oCameraController.shake, 2 + _rev_p * 9);
  }

  if (bh_reverse_frames <= 0) {
    bh_scene_reverse = 0;
  }
}
if (t >= 2657 && t < 3312 && bh_scene_reverse <= 0) {
  tidal_spawn_timer += 1 + bh_phase_charge;
  if (tidal_spawn_timer >= tidal_spawn_interval) {
    tidal_spawn_timer = 0;
    if (instance_number(oBlackHole) > 0) {
      var _side = irandom(1);
      var _spawn_x = _side == 0 ? 0 : room_width;
      var _spawn_y = random_range(0, room_height);

      var _target = instance_nearest(_spawn_x, _spawn_y, oBlackHole);
      var _stream = {
        target_id : _target,
        dist : point_distance(_spawn_x, _spawn_y, _target.x, _target.y),
        angle : point_direction(_target.x, _target.y, _spawn_x, _spawn_y),
        speed : random_range(3, 5),
        length : random_range(24, 48)
      };
      array_push(tidal_streams, _stream);
    }
  }
}

if (t >= 2657 && t < 3312) {
  if (!tidal_wall_built) {
    tidal_wall_built = true;

    var _spacing = 28;
    var _count = ceil(room_height / _spacing);

    for (var i = 0; i < _count; i++) {
      var _base_y = i * _spacing + _spacing * 0.5 + random_range(-8, 8);

      var _chunk = {
        base_y : _base_y,
        size : random_range(16, 28),
        phase : random(360),
        speed : random_range(1.2, 2.2),

        rotation : random(360),
        rotation_speed : 0,
        stress : random_range(0.2, 0.8),
        spawn_delay : random_range(0, 0.35),

        verts : [],
        cracks : []
      };

      var _template = global.tidal_asteroid_templates[irandom(array_length(global.tidal_asteroid_templates) - 1)];

      for (var v = 0; v < array_length(_template); v++) {
        array_push(_chunk.verts,
                   {ang : _template[v].ang + random_range(-3, 3), rad : _template[v].rad * _chunk.size * random_range(0.9, 1.1)});
      }

      var _crack_count = irandom_range(0, floor(_chunk.size / 6));

      for (var c = 0; c < _crack_count; c++) {
        array_push(_chunk.cracks, {
          angle : random(360),
          length : random_range(_chunk.size * 0.3, _chunk.size * 0.8),
          offset : random_range(-_chunk.size * 0.3, _chunk.size * 0.3)
        });
      }

      _chunk.rotation_speed = random_range(-10, 10) / _chunk.size;

      array_push(tidal_wall_left, _chunk);

      var _chunk2 = {
        base_y : _base_y + random_range(-15, 15),
        size : random_range(16, 28),
        phase : random(360),
        speed : random_range(1.2, 2.2),

        rotation : random(360),
        rotation_speed : 0,
        stress : random_range(0.2, 0.8),
        spawn_delay : random_range(0, 0.35),

        verts : [],
        cracks : []
      };

      var _template2 = global.tidal_asteroid_templates[irandom(array_length(global.tidal_asteroid_templates) - 1)];

      for (var v = 0; v < array_length(_template2); v++) {
        array_push(
            _chunk2.verts,
            {ang : _template2[v].ang + random_range(-3, 3), rad : _template2[v].rad * _chunk2.size * random_range(0.9, 1.1)});
      }

      var _crack_count2 = irandom_range(0, floor(_chunk2.size / 6));

      for (var c = 0; c < _crack_count2; c++) {
        array_push(_chunk2.cracks, {
          angle : random(360),
          length : random_range(_chunk2.size * 0.3, _chunk2.size * 0.8),
          offset : random_range(-_chunk2.size * 0.3, _chunk2.size * 0.3)
        });
      }

      _chunk2.rotation_speed = random_range(-10, 10) / _chunk2.size;

      array_push(tidal_wall_right, _chunk2);

      var _back_chunk = {
        base_y : _chunk.base_y + random_range(-20, 20),
        size : _chunk.size * random_range(0.7, 0.9),
        phase : _chunk.phase,
        speed : _chunk.speed,

        rotation : _chunk.rotation,
        rotation_speed : _chunk.rotation_speed,

        verts : _chunk.verts,
        cracks : _chunk.cracks,
        spawn_delay : random_range(0, 0.35),

        stress : _chunk.stress
      };
      _back_chunk.base_y += random_range(-20, 20);

      array_push(tidal_wall_back_left, _back_chunk);

      var _back_chunk2 = {
        base_y : _chunk2.base_y + random_range(-20, 20),
        size : _chunk2.size * random_range(0.7, 0.9),
        phase : _chunk2.phase,
        speed : _chunk2.speed,

        rotation : _chunk2.rotation,
        rotation_speed : _chunk2.rotation_speed,

        verts : _chunk2.verts,
        cracks : _chunk2.cracks,
        spawn_delay : random_range(0, 0.35),

        stress : _chunk2.stress

      };
      _back_chunk2.base_y += random_range(-20, 20);

      array_push(tidal_wall_back_right, _back_chunk2);
    }
  }

  var _avg_escalation = 0;
  var _bh_count = instance_number(oBlackHole);

  if (_bh_count > 0) {
    for (var i = 0; i < _bh_count; i++) {
      _avg_escalation += instance_find(oBlackHole, i).escalation;
    }

    _avg_escalation /= _bh_count;
  }

  tidal_wall_escalation = max(_avg_escalation, bh_phase_charge);
  tidal_wall_progress = min(tidal_wall_progress + 0.005, 1);

  var _wall_rev = (bh_scene_reverse > 0) ? -1 : 1;
  var _spin_boost = 1 + bh_phase_charge * 1.4;

  for (var i = 0; i < array_length(tidal_wall_left); i++) {
    tidal_wall_left[i].phase += tidal_wall_left[i].speed * _wall_rev;
    tidal_wall_right[i].phase += tidal_wall_right[i].speed * _wall_rev;

    tidal_wall_left[i].rotation += tidal_wall_left[i].rotation_speed * _wall_rev * _spin_boost;
    tidal_wall_right[i].rotation += tidal_wall_right[i].rotation_speed * _wall_rev * _spin_boost;

    tidal_wall_left[i].stress = clamp(tidal_wall_left[i].stress + tidal_wall_escalation * 0.002, 0, 1);

    tidal_wall_right[i].stress = clamp(tidal_wall_right[i].stress + tidal_wall_escalation * 0.002, 0, 1);
  }

  for (var i = 0; i < array_length(tidal_wall_back_left); i++) {
    tidal_wall_back_left[i].phase += tidal_wall_back_left[i].speed * _wall_rev;
    tidal_wall_back_right[i].phase += tidal_wall_back_right[i].speed * _wall_rev;

    tidal_wall_back_left[i].rotation += tidal_wall_back_left[i].rotation_speed * _wall_rev * _spin_boost;
    tidal_wall_back_right[i].rotation += tidal_wall_back_right[i].rotation_speed * _wall_rev * _spin_boost;
  }

  if (instance_exists(oPlayer) && !instance_exists(oGameover)) {
    var _hit_tidal_wall = false;
    var _min_inset_hit = -10;
    var _max_inset_hit = 250;
    var _duration_progress_hit = clamp((t - 2657) / (3320 - 2657), 0, 1);
    _duration_progress_hit = _duration_progress_hit * _duration_progress_hit * (3 - 2 * _duration_progress_hit);
    var _combined_escalation_hit = max(tidal_wall_escalation, _duration_progress_hit);
    var _inset_range_hit = lerp(_min_inset_hit, _max_inset_hit, _combined_escalation_hit);
    var _retreat_hit = 0;

    for (var _ri_hit = 0; _ri_hit < array_length(bh_finale_beats); _ri_hit++) {
      if (t >= bh_finale_beats[_ri_hit]) _retreat_hit = (_ri_hit + 1) / array_length(bh_finale_beats);
    }

    var _wall_p_hit = tidal_wall_progress;
    _wall_p_hit = _wall_p_hit * _wall_p_hit * (3 - 2 * _wall_p_hit);
    _wall_p_hit *= (1 - _retreat_hit);

    for (var _twl = 0; _twl < array_length(tidal_wall_left); _twl++) {
      var _rock_left = tidal_wall_left[_twl];
      var _appear_left = clamp((tidal_wall_progress - _rock_left.spawn_delay) / (1 - _rock_left.spawn_delay), 0, 1);
      _appear_left = _appear_left * _appear_left * (3 - 2 * _appear_left);
      if (_appear_left <= 0.35) continue;

      var _breathe_left = (sin(degtorad(_rock_left.phase)) + 1) * 0.5;
      var _rock_left_x = lerp(-50, lerp(_min_inset_hit, _inset_range_hit, _breathe_left), _wall_p_hit);
      var _rock_left_r = max(8, _rock_left.size * 0.78);

      if (collision_circle(_rock_left_x, _rock_left.base_y, _rock_left_r, oPlayer, false, true) != noone) {
        _hit_tidal_wall = true;
        break;
      }
    }

    if (!_hit_tidal_wall) {
      for (var _twr = 0; _twr < array_length(tidal_wall_right); _twr++) {
        var _rock_right = tidal_wall_right[_twr];
        var _appear_right = clamp((tidal_wall_progress - _rock_right.spawn_delay) / (1 - _rock_right.spawn_delay), 0, 1);
        _appear_right = _appear_right * _appear_right * (3 - 2 * _appear_right);
        if (_appear_right <= 0.35) continue;

        var _breathe_right = (sin(degtorad(_rock_right.phase)) + 1) * 0.5;
        var _rock_right_x = lerp(room_width + 50, room_width - lerp(_min_inset_hit, _inset_range_hit, _breathe_right), _wall_p_hit);
        var _rock_right_r = max(8, _rock_right.size * 0.78);

        if (collision_circle(_rock_right_x, _rock_right.base_y, _rock_right_r, oPlayer, false, true) != noone) {
          _hit_tidal_wall = true;
          break;
        }
      }
    }

    if (_hit_tidal_wall) player_register_hazard_hit();
  }

  if (random(1) < 0.08 && bh_scene_reverse <= 0) {
    var _side = choose(-1, 1);

    var _dx = _side == -1 ? random_range(0, 60) : random_range(room_width - 60, room_width);
    var _dy = random_range(0, room_height);

    array_push(tidal_dust, {
      x : _dx,
      y : _dy,

      size : random_range(12, 35),

      speed : random_range(0.2, 0.8),

      angle : point_direction(_dx, _dy, room_width * 0.5, room_height * 0.5),

      life : random_range(80, 160),

      max_life : 160
    });
  }

  var _shed_n = 0;
  if (bh_scene_reverse <= 0) {
    if (random(1) < 0.12 + tidal_wall_escalation * 0.15) _shed_n = 1;

    if (bh_heartbeat > tidal_prev_heartbeat + 0.04) {
      _shed_n += 4 + floor(bh_heartbeat * 8 + bh_phase_charge * 10);
    }
  }
  tidal_prev_heartbeat = bh_heartbeat;

  for (var _sh = 0; _sh < _shed_n; _sh++) {
    var _side = choose(-1, 1);

    var _rock_array = _side == -1 ? tidal_wall_left : tidal_wall_right;

    if (array_length(_rock_array) > 0) {
      var _rock = _rock_array[irandom(array_length(_rock_array) - 1)];

      var _x = _side == -1 ? random_range(0, 40) : random_range(room_width - 40, room_width);

      var _y = _rock.base_y + random_range(-_rock.size, _rock.size);

      var _aim_x = room_width * 0.5, _aim_y = room_height * 0.5;
      if (instance_number(oBlackHole) > 0) {
        var _near = instance_nearest(_x, _y, oBlackHole);
        _aim_x = _near.x;
        _aim_y = _near.y;
      }

      array_push(tidal_debris, {
        x : _x,
        y : _y,

        speed : random_range(1, 3) * (1 + bh_phase_charge * 0.8),

        size : random_range(1, 4),

        life : random_range(40, 90),

        max_life : 90,

        angle : point_direction(_x, _y, _aim_x, _aim_y) + random_range(-25, 25)
      });
    }
  }
}

var _rev = (bh_scene_reverse > 0) ? -1 : 1;

for (var i = array_length(tidal_debris) - 1; i >= 0; i--) {
  var _d = tidal_debris[i];

  _d.speed += 0.03 * _rev;

  _d.x += lengthdir_x(_d.speed * _rev, _d.angle);
  _d.y += lengthdir_y(_d.speed * _rev, _d.angle);

  _d.life -= _rev;

  if (_d.life <= 0 || _d.life > _d.max_life + 30) {
    array_delete(tidal_debris, i, 1);
  }
}

for (var i = array_length(tidal_dust) - 1; i >= 0; i--) {
  var _d = tidal_dust[i];

  _d.x += lengthdir_x(_d.speed * _rev, _d.angle);
  _d.y += lengthdir_y(_d.speed * _rev, _d.angle);

  _d.life -= _rev;

  if (_d.life <= 0 || _d.life > _d.max_life + 30) {
    array_delete(tidal_dust, i, 1);
  }
}

for (var i = array_length(tidal_streams) - 1; i >= 0; i--) {
  var _s = tidal_streams[i];

  if (!instance_exists(_s.target_id)) {
    array_delete(tidal_streams, i, 1);
    continue;
  }

  _s.dist -= _s.speed * (1 + _s.target_id.escalation * 0.5) * _rev;

  if (_rev > 0) {
    if (_s.dist <= _s.target_id.core_radius * 1.5) array_delete(tidal_streams, i, 1);
  } else {
    if (_s.dist > room_width) array_delete(tidal_streams, i, 1);
  }
}

for (var i = array_length(bh_inversion_rings) - 1; i >= 0; i--) {
  var _ir = bh_inversion_rings[i];
  _ir.life--;
  _ir.radius = lerp(_ir.radius, _ir.max_radius, _ir.inward ? 0.18 : 0.12);
  if (_ir.life <= 0) array_delete(bh_inversion_rings, i, 1);
}
for (var i = array_length(bh_swallow_flashes) - 1; i >= 0; i--) {
  bh_swallow_flashes[i].life--;
  if (bh_swallow_flashes[i].life <= 0) array_delete(bh_swallow_flashes, i, 1);
}
for (var i = array_length(bh_ambient_arcs) - 1; i >= 0; i--) {
  bh_ambient_arcs[i].life--;
  if (bh_ambient_arcs[i].life <= 0) array_delete(bh_ambient_arcs, i, 1);
}
for (var i = array_length(bh_horizon_cracks) - 1; i >= 0; i--) {
  bh_horizon_cracks[i].life--;
  if (bh_horizon_cracks[i].life <= 0) array_delete(bh_horizon_cracks, i, 1);
}
for (var i = array_length(bh_kunai_bursts) - 1; i >= 0; i--) {
  bh_kunai_bursts[i].life--;
  if (bh_kunai_bursts[i].life <= 0) array_delete(bh_kunai_bursts, i, 1);
}
for (var i = array_length(bh_edge_waves) - 1; i >= 0; i--) {
  bh_edge_waves[i].age++;
  bh_edge_waves[i].life--;
  if (bh_edge_waves[i].life <= 0) array_delete(bh_edge_waves, i, 1);
}

bh_forge_flash = max(0, bh_forge_flash - 0.055);
bh_forge_pulse = max(0, bh_forge_pulse - 0.07);
if (t < _k_bh_forge_start_t || t > _k_bh_forge_detonate_t) {
  bh_forge_charge = max(0, bh_forge_charge - 0.08);
}

for (var i = array_length(bh_forge_arcs) - 1; i >= 0; i--) {
  bh_forge_arcs[i].life--;
  if (bh_forge_arcs[i].life <= 0) array_delete(bh_forge_arcs, i, 1);
}

for (var i = array_length(bh_forge_motes) - 1; i >= 0; i--) {
  var _fm = bh_forge_motes[i];
  _fm.ang += _fm.spin;
  _fm.dist = max(_fm.dest, _fm.dist - _fm.speed);
  _fm.speed *= 1.035;
  _fm.x = lerp(_fm.x, _fm.tx + lengthdir_x(_fm.dist, _fm.ang), 0.35);
  _fm.y = lerp(_fm.y, _fm.ty + lengthdir_y(_fm.dist, _fm.ang), 0.35);
  _fm.life--;

  if (_fm.life <= 0 || _fm.dist <= _fm.dest + 1) {
    bh_forge_flash = max(bh_forge_flash, 0.08 + _fm.hot * 0.09);
    array_delete(bh_forge_motes, i, 1);
  }
}

for (var i = array_length(bh_forge_slashes) - 1; i >= 0; i--) {
  bh_forge_slashes[i].life--;
  if (bh_forge_slashes[i].life <= 0) array_delete(bh_forge_slashes, i, 1);
}

bh_wave_gate_charge = max(0, bh_wave_gate_charge - 0.035);
bh_wave_gate_flash = max(0, bh_wave_gate_flash - 0.08);
for (var i = array_length(bh_wave_conduits) - 1; i >= 0; i--) {
  bh_wave_conduits[i].life--;
  if (bh_wave_conduits[i].life <= 0) array_delete(bh_wave_conduits, i, 1);
}
for (var i = array_length(bh_wave_sparks) - 1; i >= 0; i--) {
  var _ws = bh_wave_sparks[i];
  _ws.x = lerp(_ws.x + _ws.vx, _ws.tx, 0.12 + _ws.hot * 0.08);
  _ws.y = lerp(_ws.y + _ws.vy, _ws.ty, 0.12 + _ws.hot * 0.08);
  _ws.vx *= 0.94;
  _ws.vy *= 0.94;
  _ws.life--;
  if (_ws.life <= 0 || point_distance(_ws.x, _ws.y, _ws.tx, _ws.ty) < 10) {
    bh_wave_gate_flash = max(bh_wave_gate_flash, 0.12 + _ws.hot * 0.18);
    array_delete(bh_wave_sparks, i, 1);
  }
}

if (t >= _k_bh_forge_start_t && t < _k_bh_forge_detonate_t) {
  var _forge_p = clamp((t - _k_bh_forge_start_t) / max(1, _k_bh_forge_release_t - _k_bh_forge_start_t), 0, 1);
  bh_forge_charge = max(bh_forge_charge, _forge_p);

  bh_forge_pulse_timer--;
  var _forge_interval = max(3, round(lerp(15, 4, _forge_p)));
  if (bh_forge_pulse_timer <= 0) {
    bh_forge_pulse_timer = _forge_interval;
    bh_forge_pulse = max(bh_forge_pulse, 0.18 + _forge_p * 0.38);

    var _forge_cx = _k_bh_forge_center_x;
    var _forge_cy = _k_bh_forge_center_y;
    var _hole_count = instance_number(oBlackHole);

    if (_hole_count > 0) {
      for (var _hf = 0; _hf < _hole_count; _hf++) {
        var _hole = instance_find(oBlackHole, _hf);
        var _life = 8 + round(_forge_p * 7);
        array_push(bh_forge_arcs, {
          x1 : _hole.x, y1 : _hole.y,
          x2 : _forge_cx + random_range(-20, 20), y2 : _forge_cy + random_range(-18, 18),
          life : _life, life_max : _life,
          off : scr_bolt_offsets(6, 12 + _forge_p * 34),
          color : merge_color(global.lightning_color, c_white, 0.45 + _forge_p * 0.45),
          width : 1.6 + _forge_p * 2.6
        });

        var _mote_n = min(2 + floor(_forge_p * 3), max(0, _k_bh_forge_mote_max - array_length(bh_forge_motes)));
        for (var _mi = 0; _mi < _mote_n; _mi++) {
          var _dist = point_distance(_forge_cx, _forge_cy, _hole.x, _hole.y) + random_range(40, 150);
          array_push(bh_forge_motes, {
            x : _hole.x, y : _hole.y,
            tx : _forge_cx, ty : _forge_cy,
            ang : point_direction(_forge_cx, _forge_cy, _hole.x, _hole.y) + random_range(-35, 35),
            dist : _dist,
            dest : random_range(8, 36),
            speed : random_range(4.5, 8.0) * (1 + _forge_p * 0.8),
            spin : random_range(-3.5, 3.5),
            life : 34, life_max : 34,
            size : random_range(1.6, 4.2),
            hot : _forge_p
          });
        }
      }
    } else {
      for (var _ef = 0; _ef < 2; _ef++) {
        var _sx = (_ef == 0) ? -24 : room_width + 24;
        var _sy = random_range(96, room_height - 96);
        var _life2 = 8 + round(_forge_p * 7);
        array_push(bh_forge_arcs, {
          x1 : _sx, y1 : _sy,
          x2 : _forge_cx, y2 : _forge_cy,
          life : _life2, life_max : _life2,
          off : scr_bolt_offsets(6, 10 + _forge_p * 26),
          color : merge_color(global.lightning_color, c_white, 0.4 + _forge_p * 0.45),
          width : 1.4 + _forge_p * 2.2
        });
      }
    }

    vignette_pulse = max(vignette_pulse, (0.14 + _forge_p * 0.24) * _k_bh_forge_screen_mult);
    bloom_pulse = max(bloom_pulse, (0.04 + _forge_p * 0.12) * _k_bh_forge_screen_mult);
    aberration_pulse = max(aberration_pulse, (0.08 + _forge_p * 0.16) * _k_bh_forge_screen_mult);
    global_ripple_pulse = max(global_ripple_pulse, (0.05 + _forge_p * 0.12) * _k_bh_forge_screen_mult);

    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.25 + _forge_p * 0.55);
      oCameraController.shake = max(oCameraController.shake, 2 + _forge_p * 7);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.025 + _forge_p * 0.06);
    }
  }

  if (array_length(bh_forge_arcs) < _k_bh_forge_leak_max && random(1) < 0.06 + _forge_p * 0.18) {
    var _leak_ang = random(360);
    var _leak_out_ang = _leak_ang + random_range(-8, 8);
    var _leak_len = random_range(240, 520);
    var _leak_life = 5 + round(_forge_p * 4);
    array_push(bh_forge_arcs, {
      x1 : _k_bh_forge_center_x + lengthdir_x(24, _leak_ang),
      y1 : _k_bh_forge_center_y + lengthdir_y(24, _leak_ang),
      x2 : _k_bh_forge_center_x + lengthdir_x(_leak_len, _leak_out_ang),
      y2 : _k_bh_forge_center_y + lengthdir_y(_leak_len, _leak_out_ang),
      life : _leak_life, life_max : _leak_life,
      off : scr_bolt_offsets(5, 16 + _forge_p * 32),
      color : merge_color(make_color_rgb(255, 55, 45), c_white, 0.35 + _forge_p * 0.5),
      width : 1.3 + _forge_p * 2.0
    });
  }
}

if (timeline_hit(3012)) {
  bullets_rewinding = false;
  blackhole_push_mode = true;
  bh_scene_reverse = 0;
  bh_reverse_frames = 0;
  bh_drop_flash = 1;

  scr_bg_bass_hit();
  vignette_pulse = max(vignette_pulse, _k_bh_drop_vignette);
  aberration_pulse = max(aberration_pulse, _k_bh_drop_aberration);
  bloom_pulse = max(bloom_pulse, _k_bh_drop_bloom);
  global_ripple_pulse = max(global_ripple_pulse, _k_bh_drop_ripple);
  tear_amount = max(tear_amount, _k_bh_drop_tear);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_bh_drop_shake);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_bh_drop_zoom);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, _k_bh_drop_flash);
    oCameraController.angle_kick += _k_bh_drop_angle;
    oCameraController.letterbox_target = 0;
  }

  with (oBlackHole) {
    array_push(other.bh_inversion_rings, {
      x : x, y : y,
      radius : 300, max_radius : 4,
      life : 20, life_max : 20,
      width : 16, color : c_white, hot : 1, inward : true
    });
    for (var r = 0; r < 3; r++) {
      array_push(other.bh_inversion_rings, {
        x : x, y : y,
        radius : 6, max_radius : 260 + r * 130,
        life : 34 + r * 7, life_max : 34 + r * 7,
        width : 18 - r * 4,
        color : (r == 0) ? c_white : merge_color(c_white, global.lightning_color, 0.45 + r * 0.2),
        hot : 1 - r * 0.25, inward : false
      });
    }
    for (var c = 0; c < 14; c++) {
      array_push(other.bh_horizon_cracks, {
        x : x, y : y,
        ang : random(360),
        len : random_range(50, 150),
        life : 34, life_max : 34,
        seed : random(1000)
      });
    }

    inverted_at = other.t;
    invert_shock = 1;
    feed_charge = max(feed_charge, 1);
    flare_active = true;
    flare_life = 0;
    array_push(pulse_waves, [0, 1.0]);

    scr_add_light(x, y, c_white, 18);
    scr_floor_impact(x, y, 1.2);
  }

  with (oBlackHoleBullet) {
    direction += 180;
    speed = max(speed, 5) * 1.6;
    trail_positions = [];
    inverted_flash = 1;
  }
}

if (bh_drop_flash > 0) {
  vignette_pulse = max(vignette_pulse, bh_drop_flash * 0.75);
  bloom_pulse = max(bloom_pulse, bh_drop_flash * 0.6);
  aberration_pulse = max(aberration_pulse, bh_drop_flash * 0.7);
  global_ripple_pulse = max(global_ripple_pulse, bh_drop_flash * 0.5);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, bh_drop_flash * 12);
  }
}

var _bh_fin_i = -1;
for (var i = 0; i < array_length(bh_finale_beats); i++) {
  if (last_t < bh_finale_beats[i] && t >= bh_finale_beats[i]) {
    _bh_fin_i = i;
    break;
  }
}

if (_bh_fin_i >= 0) {
  var _fin_e = _bh_fin_i / max(array_length(bh_finale_beats) - 1, 1);
  var _fin_screen_dim = _k_bh_forge_screen_mult;
  var _kunai_burst_reps = 1;
  var _spawn_points = [];
  var _is_last = (_bh_fin_i == array_length(bh_finale_beats) - 1);

  bh_forge_flash = max(bh_forge_flash, 0.20 + _fin_e * 0.35);
  bh_forge_pulse = max(bh_forge_pulse, 0.28 + _fin_e * 0.32);
  bh_forge_charge = max(bh_forge_charge, _fin_e);

  switch (_bh_fin_i) {
    case 0:
      _spawn_points = [[room_width / 2, room_height / 2]];
      _kunai_burst_reps = 2;
      break;
    case 1:
      _spawn_points = [[room_width * 0.26, room_height * 0.35],
                       [room_width * 0.74, room_height * 0.35]];
      break;
    case 2:
      _spawn_points = [[room_width / 2, room_height * 0.62],
                       [room_width * 0.18, room_height * 0.48],
                       [room_width * 0.82, room_height * 0.48]];
      break;
    case 3:
      _spawn_points = [[room_width * 0.22, room_height],
                       [room_width / 2, room_height],
                       [room_width * 0.78, room_height]];
      break;
    case 4:
      _spawn_points = [[room_width / 2, 0], [room_width / 2, room_height]];
      break;
  }

  var _kunai_per_burst = _is_last ? 24 : max(18, round((42 + _bh_fin_i * 10) / max(1, array_length(_spawn_points))));
  var _wave_gate_y = room_height + 24;
  bh_wave_gate_charge = max(bh_wave_gate_charge, _is_last ? 1.0 : (0.16 + _fin_e * 0.46));
  if (_is_last) bh_wave_gate_flash = max(bh_wave_gate_flash, 1);

  if (_is_last) {
    for (var _rail = 0; _rail < 7; _rail++) {
      var _rt = (_rail + 0.5) / 7;
      var _rx = lerp(58, room_width - 58, _rt);
      array_push(bh_wave_conduits, {
        x1 : _k_bh_forge_center_x + lengthdir_x(28 + _rail * 3, -120 + _rail * 40),
        y1 : _k_bh_forge_center_y + lengthdir_y(18, -120 + _rail * 40),
        x2 : _rx,
        y2 : _wave_gate_y,
        life : 42, life_max : 42,
        off : scr_bolt_offsets(8, 34 + _rail * 3),
        color : merge_color(global.lightning_color, c_white, 0.52 + _fin_e * 0.3),
        width : 2.2 + _rail * 0.18,
        pulse : random(1)
      });
    }
  }

  if (!_is_last) {
    var _echo_n = 2 + _bh_fin_i;
    for (var eb = 0; eb < _echo_n; eb++) {
      var _echo_a = -165 + (330 / max(1, _echo_n - 1)) * eb + random_range(-12, 12);
      var _echo_r = random_range(120, 310) * (0.75 + _fin_e * 0.5);
      var _echo_x = clamp(_k_bh_forge_center_x + lengthdir_x(_echo_r, _echo_a), 32, room_width - 32);
      var _echo_y = clamp(_k_bh_forge_center_y + lengthdir_y(_echo_r * 0.55, _echo_a), 44, room_height - 28);
      var _echo_spike_n = 8 + _bh_fin_i * 4;
      var _echo_spikes = [];
      for (var esp = 0; esp < _echo_spike_n; esp++) {
        array_push(_echo_spikes, {
          ang : (360 / _echo_spike_n) * esp + random_range(-12, 12),
          len : random_range(70, 170) * (1 + _fin_e * 0.9),
          w : random_range(2, 5) * (1 + _fin_e * 0.5)
        });
      }
      array_push(bh_kunai_bursts, {
        x : _echo_x, y : _echo_y,
        life : 18 + _bh_fin_i * 4, life_max : 18 + _bh_fin_i * 4,
        spikes : _echo_spikes,
        power : 0.35 + _fin_e * 0.45,
        hue : _fin_e,
        edge : 0,
        band : 0
      });

      var _echo_life = 12 + _bh_fin_i * 3;
      array_push(bh_forge_arcs, {
        x1 : _k_bh_forge_center_x, y1 : _k_bh_forge_center_y,
        x2 : _echo_x, y2 : _echo_y,
        life : _echo_life,
        life_max : _echo_life,
        off : scr_bolt_offsets(6, 18 + _fin_e * 36),
        color : merge_color(make_color_rgb(255, 55, 45), c_white, 0.28 + _fin_e * 0.45),
        width : 1.6 + _fin_e * 2.2
      });

      array_push(bh_wave_conduits, {
        x1 : _echo_x, y1 : _echo_y,
        x2 : clamp(lerp(_echo_x, _k_bh_forge_center_x, 0.25), 44, room_width - 44),
        y2 : _wave_gate_y + random_range(-8, 8),
        life : 28 + _bh_fin_i * 5,
        life_max : 28 + _bh_fin_i * 5,
        off : scr_bolt_offsets(6, 18 + _fin_e * 28),
        color : merge_color(make_color_rgb(255, 45, 36), c_white, 0.25 + _fin_e * 0.4),
        width : 1.3 + _fin_e * 2,
        pulse : random(1)
      });

      for (var _wsp = 0; _wsp < 2 + _bh_fin_i; _wsp++) {
        array_push(bh_wave_sparks, {
          x : _echo_x + random_range(-18, 18),
          y : _echo_y + random_range(-18, 18),
          tx : clamp(_echo_x + random_range(-90, 90), 48, room_width - 48),
          ty : _wave_gate_y + random_range(-12, 12),
          vx : random_range(-2.5, 2.5),
          vy : random_range(1.5, 6.5),
          life : irandom_range(24, 44),
          life_max : 44,
          size : random_range(3, 7),
          hot : 0.35 + _fin_e * 0.65
        });
      }
    }
  }

  for (var p = 0; p < array_length(_spawn_points); p++) {
    var _spawn_x = _spawn_points[p][0];
    var _spawn_y = _spawn_points[p][1];

    for (var _rep = 0; _rep < _kunai_burst_reps; _rep++) {
      var _count_this_spawn = _kunai_per_burst;

      for (var i = 0; i < _count_this_spawn; i++) {
        var _slot = (_count_this_spawn > 1) ? (i / (_count_this_spawn - 1)) : 0.5;
        var _slot_mid = _slot - 0.5;
        var _motion_mode = 0;
        var _motion_life = 34 + _bh_fin_i * 3;
        var _motion_fade = 10;
        var _motion_cx = _k_bh_forge_center_x;
        var _motion_cy = _k_bh_forge_center_y;
        var _motion_angle = random(360);
        var _motion_spin = 0;
        var _motion_r0 = 0;
        var _motion_r1 = 0;
        var _motion_squash = 0.65;
        var _motion_sx = _spawn_x;
        var _motion_sy = _spawn_y;
        var _motion_c1x = _spawn_x;
        var _motion_c1y = _spawn_y;
        var _motion_tx = _spawn_x;
        var _motion_ty = _spawn_y;
        var _motion_ex = _spawn_x;
        var _motion_ey = _spawn_y;
        var _blade_x = _spawn_x;
        var _blade_y = _spawn_y;
        var _blade_dir = random(360);
        var _blade_speed = random_range(6, 10);

        if (!_is_last) {
          switch (_bh_fin_i) {
            case 0:
            {
              _motion_mode = 1;
              _motion_life = 32 + _rep * 5;
              _motion_fade = 8;
              _motion_angle = _slot * 360 + _rep * 13 + random_range(-3, 3);
              _motion_spin = ((_rep mod 2) == 0 ? 1 : -1) * random_range(390, 560);
              _motion_r0 = random_range(160, 230) + _rep * 26;
              _motion_r1 = random_range(16, 58);
              _motion_squash = 0.55;
              _blade_x = _motion_cx + lengthdir_x(_motion_r0, _motion_angle);
              _blade_y = _motion_cy + lengthdir_y(_motion_r0, _motion_angle) * _motion_squash;
              _blade_dir = _motion_angle + sign(_motion_spin) * 90;
              _blade_speed = 0;
              break;
            }

            case 1:
            {
              var _side = (_spawn_x < _k_bh_forge_center_x) ? -1 : 1;
              _motion_mode = 2;
              _motion_life = 36;
              _motion_sx = _spawn_x - _side * random_range(45, 95);
              _motion_sy = _spawn_y + _slot_mid * 150 + random_range(-10, 10);
              _motion_c1x = _k_bh_forge_center_x - _side * random_range(60, 150);
              _motion_c1y = _k_bh_forge_center_y - 120 + abs(_slot_mid) * 70;
              _motion_tx = _k_bh_forge_center_x + _side * random_range(155, 245);
              _motion_ty = _k_bh_forge_center_y + _slot_mid * 110;
              _motion_ex = _motion_tx + _side * random_range(150, 260);
              _motion_ey = _motion_ty + random_range(-45, 45);
              _blade_x = _motion_sx;
              _blade_y = _motion_sy;
              _blade_dir = point_direction(_motion_sx, _motion_sy, _motion_c1x, _motion_c1y);
              _blade_speed = 0;
              break;
            }

            case 2:
            {
              var _spoke = point_direction(_k_bh_forge_center_x, _k_bh_forge_center_y, _spawn_x, _spawn_y);
              var _weave = _slot_mid * 82;
              _motion_mode = 2;
              _motion_life = 40;
              _motion_sx = _spawn_x + lengthdir_x(random_range(30, 85), _spoke + _weave);
              _motion_sy = _spawn_y + lengthdir_y(random_range(30, 85), _spoke + _weave) * 0.6;
              _motion_c1x = _k_bh_forge_center_x + lengthdir_x(random_range(95, 190), _spoke + 90 + _slot_mid * 60);
              _motion_c1y = _k_bh_forge_center_y + lengthdir_y(random_range(95, 190), _spoke + 90 + _slot_mid * 60) * 0.55;
              _motion_tx = _k_bh_forge_center_x + lengthdir_x(random_range(30, 80), _spoke + 180 + _slot_mid * 90);
              _motion_ty = _k_bh_forge_center_y + lengthdir_y(random_range(30, 80), _spoke + 180 + _slot_mid * 90) * 0.75;
              _motion_ex = _k_bh_forge_center_x + lengthdir_x(random_range(260, 430), _spoke + 180 + _slot_mid * 70);
              _motion_ey = _k_bh_forge_center_y + lengthdir_y(random_range(260, 430), _spoke + 180 + _slot_mid * 70) * 0.65;
              _blade_x = _motion_sx;
              _blade_y = _motion_sy;
              _blade_dir = point_direction(_motion_sx, _motion_sy, _motion_c1x, _motion_c1y);
              _blade_speed = 0;
              break;
            }

            case 3:
            {
              var _floor_side = (_spawn_x - _k_bh_forge_center_x) / max(1, room_width * 0.5);
              _motion_mode = 2;
              _motion_life = 38;
              _motion_sx = _spawn_x + _slot_mid * 120;
              _motion_sy = room_height + random_range(18, 52);
              _motion_c1x = lerp(_spawn_x, _k_bh_forge_center_x, 0.45) + _slot_mid * 95;
              _motion_c1y = room_height * random_range(0.58, 0.72);
              _motion_tx = _k_bh_forge_center_x + _floor_side * random_range(170, 260) + _slot_mid * 110;
              _motion_ty = room_height * random_range(0.52, 0.66);
              _motion_ex = _motion_tx + lengthdir_x(random_range(220, 340), 270 + _slot_mid * 55);
              _motion_ey = _motion_ty + lengthdir_y(random_range(220, 340), 270 + _slot_mid * 55);
              _blade_x = _motion_sx;
              _blade_y = _motion_sy;
              _blade_dir = point_direction(_motion_sx, _motion_sy, _motion_c1x, _motion_c1y);
              _blade_speed = 0;
              break;
            }
          }
        } else {
          var _from_top = (_spawn_y <= 4);
          var _slot_step = room_width / max(1, _count_this_spawn);
          var _target_x = lerp(54, room_width - 54, _slot);
          if (_from_top) _target_x = clamp(_target_x + _slot_step * 0.5, 54, room_width - 54);
          var _start_jitter = random_range(-8, 8);

          _motion_mode = 2;
          _motion_life = 28 + round(abs(_slot_mid) * 13) + (_from_top ? 3 : 0);
          _motion_fade = 8;
          _motion_sx = clamp(_target_x + _start_jitter, 20, room_width - 20);
          _motion_sy = _from_top ? random_range(-72, -28) : room_height + random_range(38, 92);
          _motion_c1x = lerp(_motion_sx, _k_bh_forge_center_x, _from_top ? 0.45 : 0.32)
                        + sin(i * 1.7) * (34 + abs(_slot_mid) * 60);
          _motion_c1y = _from_top ? room_height * random_range(0.18, 0.34) : room_height * random_range(0.46, 0.66);
          _motion_tx = _target_x;
          _motion_ty = _wave_gate_y + sin(i * 0.9) * 9;
          _motion_ex = _target_x + lengthdir_x(90, _from_top ? 88 : 272);
          _motion_ey = _motion_ty + lengthdir_y(90, _from_top ? 88 : 272);
          _blade_x = _motion_sx;
          _blade_y = _motion_sy;
          _blade_dir = point_direction(_motion_sx, _motion_sy, _motion_c1x, _motion_c1y);
          _blade_speed = 0;
        }

        with(instance_create_layer(_blade_x, _blade_y, layer, oRedKunaiVisual)) {
          direction = _blade_dir;
          speed = _blade_speed;
          image_alpha = other._k_bh_finale_kunai_alpha;
          if (_is_last) {
            kunai_curve_mode = true;
            kunai_curve_burst_chance = 1;
            kunai_curve_band_width = 118;
            kunai_curve_spread_count = 7;
            kunai_curve_launch_speed = 26 + abs(_slot_mid) * 5;
            kunai_curve_split_y = _wave_gate_y;
            kunai_curve_decel_min = 12;
            kunai_curve_decel_max = 34;
            kunai_curve_phase_slot = i;
            kunai_curve_phase_count = _count_this_spawn;
            kunai_curve_frames = max(8, round(_motion_life * 0.76));
            kunai_curve_rate = (_spawn_y <= 4 ? -2.6 : 2.6) + _slot_mid * 3.8;
          }
          if (_motion_mode > 0) {
            finale_motion_mode = _motion_mode;
            finale_motion_life = _motion_life;
            finale_motion_fade = _motion_fade;
            finale_base_alpha = image_alpha;
            kunai_alpha_step = 0;
            finale_motion_cx = _motion_cx;
            finale_motion_cy = _motion_cy;
            finale_motion_angle = _motion_angle;
            finale_motion_spin = _motion_spin;
            finale_motion_radius = _motion_r0;
            finale_motion_radius2 = _motion_r1;
            finale_motion_squash = _motion_squash;
            finale_motion_sx = _motion_sx;
            finale_motion_sy = _motion_sy;
            finale_motion_c1x = _motion_c1x;
            finale_motion_c1y = _motion_c1y;
            finale_motion_tx = _motion_tx;
            finale_motion_ty = _motion_ty;
            finale_motion_ex = _motion_ex;
            finale_motion_ey = _motion_ey;
          }

          finale_mode = true;
          finale_tier = 1;
          finale_hue = _fin_e;
          trail_max = _is_last ? 18 : (20 + _bh_fin_i * 2);
          hit_active = false;
        }
      }
    }

    var _edge = 0;
    if (_spawn_y <= 4) _edge = 1;
    else if (_spawn_y >= room_height - 4) _edge = -1;

    var _slash_n = 2 + _bh_fin_i + ((_edge != 0) ? 3 : 0);
    for (var _sl = 0; _sl < _slash_n; _sl++) {
      var _slash_ang;
      if (_edge != 0) {
        _slash_ang = random_range(-7, 7);
      } else {
        _slash_ang = ((_bh_fin_i mod 2) == 0 ? 90 : 0) + random_range(-28, 28);
        if ((_sl mod 3) == 1) _slash_ang += 45;
        if ((_sl mod 3) == 2) _slash_ang -= 45;
      }

      var _slash_life = 18 + round(_fin_e * 14);
      array_push(bh_forge_slashes, {
        x : _spawn_x + random_range(-12, 12),
        y : _spawn_y + ((_edge == 0) ? random_range(-12, 12) : (_edge * 8)),
        ang : _slash_ang,
        len : ((_edge != 0) ? random_range(330, 620) : random_range(170, 360)) * (1 + _fin_e * 0.5),
        life : _slash_life,
        life_max : _slash_life,
        width : random_range(4, 10) * (1 + _fin_e * 0.55),
        color : merge_color(make_color_rgb(255, 45, 38), c_white, 0.35 + _fin_e * 0.5),
        hot : 0.55 + _fin_e * 0.45,
        seed : random(1000)
      });
    }

    var _forge_arc_life = 8 + round(_fin_e * 8);
    array_push(bh_forge_arcs, {
      x1 : _k_bh_forge_center_x, y1 : _k_bh_forge_center_y,
      x2 : _spawn_x, y2 : clamp(_spawn_y, 8, room_height - 8),
      life : _forge_arc_life,
      life_max : _forge_arc_life,
      off : scr_bolt_offsets(7, 22 + _fin_e * 34),
      color : merge_color(global.lightning_color, c_white, 0.55 + _fin_e * 0.4),
      width : 2.2 + _fin_e * 3.0
    });

    var _spike_n = 14 + floor(_fin_e * 16);
    if (_edge != 0) _spike_n = round(_spike_n * 1.5);

    var _spikes = [];
    for (var sp = 0; sp < _spike_n; sp++) {
      var _sa;
      if (_edge == 0) {
        _sa = (360 / _spike_n) * sp + random_range(-6, 6);
      } else {
        var _base_a = (_edge == 1) ? 90 : 270;
        _sa = _base_a - 85 + (170 / max(1, _spike_n - 1)) * sp + random_range(-4, 4);
      }
      array_push(_spikes, {
        ang : _sa,
        len : random_range(60, 150) * (1 + _fin_e * 1.1) * ((_edge != 0) ? 1.9 : 1),
        w : random_range(2, 6) * (1 + _fin_e * 0.6)
      });
    }
    array_push(bh_kunai_bursts, {
      x : _spawn_x, y : _spawn_y,
      life : 26 + _fin_e * 10, life_max : 26 + _fin_e * 10,
      spikes : _spikes,
      power : 0.7 + _fin_e * 0.6,
      hue : _fin_e,
      edge : _edge,
      band : 0
    });

    if (_edge != 0) {
      var _col_n = 36;
      var _cols = [];
      for (var ci = 0; ci < _col_n; ci++) {
        var _cx = (ci + 0.5) * (room_width / _col_n);
        var _hero = (ci mod 5 == 2);
        array_push(_cols, {
          x : _cx,
          delay : (abs(_cx - _spawn_x) / (room_width * 0.5)) * 13,
          height : random_range(75, 200) * (1 + _fin_e * 0.9) * (_hero ? 1.85 : 1),
          width : random_range(7, 22) * (_hero ? 1.4 : 1),
          jag : random_range(-16, 16),
          seed : random(1000)
        });
      }
      array_push(bh_edge_waves, {
        edge_y : _spawn_y,
        dir : (_edge == 1) ? 1 : -1,
        origin_x : _spawn_x,
        age : 0,
        life : 58, life_max : 58,
        power : 0.85 + _fin_e * 0.5,
        hue : _fin_e,
        columns : _cols
      });

      for (var sd = 0; sd < 30; sd++) {
        var _sx2 = random_range(0, room_width);
        array_push(ember_spray, {
          x : _sx2, y : _spawn_y,
          xspeed : (_sx2 - _spawn_x) * 0.012 + random_range(-2, 2),
          yspeed : _edge * random_range(3, 9),
          size : random_range(2, 6),
          life : irandom_range(26, 50), life_max : 50,
          color : merge_color(make_color_rgb(255, 70, 50), c_white, random(1))
        });
      }

      for (var fc = 0; fc < 5; fc++) {
        scr_floor_impact(room_width * (fc + 0.5) / 5, _spawn_y, (0.7 + _fin_e * 0.4) * _fin_screen_dim);
      }

      vignette_pulse = max(vignette_pulse, (0.75 + _fin_e * 0.25) * _fin_screen_dim);
      bloom_pulse = max(bloom_pulse, (0.12 + _fin_e * 0.12) * _fin_screen_dim);
      global_ripple_pulse = max(global_ripple_pulse, (0.32 + _fin_e * 0.22) * _fin_screen_dim);
      tear_amount = max(tear_amount, (0.28 + _fin_e * 0.28) * _fin_screen_dim);
      aberration_pulse = max(aberration_pulse, (0.22 + _fin_e * 0.18) * _fin_screen_dim);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 22 + _fin_e * 12);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.18 + _fin_e * 0.14);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, (0.08 + _fin_e * 0.1) * _fin_screen_dim);
        oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.7);
      }

      scr_add_light(_spawn_x, _spawn_y, c_white, (5 + _fin_e * 4) * _fin_screen_dim);
    }
  }

  scr_impact_pulse((0.12 + _fin_e * 0.08) * _fin_screen_dim, 0,
                   (0.10 + _fin_e * 0.12) * _fin_screen_dim);
  vignette_pulse = max(vignette_pulse, (0.4 + _fin_e * 0.45) * _fin_screen_dim);
  aberration_pulse = max(aberration_pulse, (0.14 + _fin_e * 0.18) * _fin_screen_dim);
  bloom_pulse = max(bloom_pulse, (0.08 + _fin_e * 0.12) * _fin_screen_dim);
  global_ripple_pulse = max(global_ripple_pulse, (0.18 + _fin_e * 0.2) * _fin_screen_dim);
  tear_amount = max(tear_amount, (0.12 + _fin_e * 0.18) * _fin_screen_dim);
  bh_heartbeat = max(bh_heartbeat, 0.5 + _fin_e * 0.5);

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 12 + _fin_e * 16);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.08 + _fin_e * 0.14);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, (0.06 + _fin_e * 0.08) * _fin_screen_dim);
    oCameraController.angle_kick += (_bh_fin_i mod 2 == 0 ? 1 : -1) * (1.2 + _fin_e * 2.4);
  }

  for (var p = 0; p < array_length(_spawn_points); p++) {
    array_push(bh_inversion_rings, {
      x : _spawn_points[p][0], y : _spawn_points[p][1],
      radius : 4, max_radius : 220 + _fin_e * 260,
      life : 26, life_max : 26,
      width : 8 + _fin_e * 10,
      color : merge_color(global.lightning_color, c_white, 0.5 + _fin_e * 0.5),
      hot : 0.6 + _fin_e * 0.4, inward : false,
      dim : _fin_screen_dim
    });
    scr_add_light(_spawn_points[p][0], _spawn_points[p][1], c_white, (3 + _fin_e * 4) * _fin_screen_dim);
    scr_floor_impact(_spawn_points[p][0], _spawn_points[p][1], (0.55 + _fin_e * 0.6) * _fin_screen_dim);
  }
}

if (timeline_hit(3253)) {
  with(oBlackHole) { despawning = true; }

  vignette_pulse = max(vignette_pulse, 0.45 * _k_bh_despawn_screen_mult);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 8);
    oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.55);
  }
}

if (timeline_hit(3330)) {
  with(oBlackHole) instance_destroy();
  bh_forge_charge = 0;
  bh_forge_flash = 0;
  bh_forge_pulse = 0;
  bh_forge_arcs = [];
  bh_forge_motes = [];
  bh_forge_slashes = [];
  bh_wave_conduits = [];
  bh_wave_sparks = [];
  bh_wave_gate_charge = 0;
  bh_wave_gate_flash = 0;
  if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0;
}

if (t >= 3312 && tidal_wall_built) {
  tidal_wall_left = [];
  tidal_wall_right = [];
  tidal_wall_back_left = [];
  tidal_wall_back_right = [];

  tidal_debris = [];
  tidal_dust = [];
  tidal_streams = [];

  tidal_wall_built = false;
  tidal_wall_progress = 0;
  tidal_wall_escalation = 0;
}


kdash_active = (t >= _k_kdash_prelude_t && t < _k_kdash_end_t);

kdash_strike_flash = max(0, kdash_strike_flash - 0.075);
kdash_chroma = lerp(kdash_chroma, 0, 0.13);
kdash_finale = max(0, kdash_finale - 0.018);

if (!kdash_active) {
  kdash_coil = max(0, kdash_coil - 0.08);
  kdash_rift = max(0, kdash_rift - 0.035);
  kdash_heartbeat = lerp(kdash_heartbeat, 0, 0.1);
  kdash_escalation = lerp(kdash_escalation, 0, 0.02);
}

if (kdash_finale > 0.01) {
  kdash_rift = max(kdash_rift, kdash_finale * 1.3);
  vignette_pulse = max(vignette_pulse, kdash_finale * 0.35);
  bloom_pulse = max(bloom_pulse, kdash_finale * 0.55);
  aberration_pulse = max(aberration_pulse, kdash_finale * kdash_finale * 0.3);
}

for (var i = array_length(kdash_impacts) - 1; i >= 0; i--) {
  var _kim = kdash_impacts[i];
  _kim.life--;
  _kim.radius = lerp(_kim.radius, _kim.max_radius, 0.24);
  if (_kim.life <= 0) array_delete(kdash_impacts, i, 1);
}

for (var i = array_length(kdash_shards) - 1; i >= 0; i--) {
  var _ksh = kdash_shards[i];
  _ksh.life--;
  _ksh.wobble *= 0.84;
  if (_ksh.life <= 0) array_delete(kdash_shards, i, 1);
}

for (var i = array_length(kdash_ghosts) - 1; i >= 0; i--) {
  var _kg = kdash_ghosts[i];
  _kg.alpha -= _kg.fade;
  _kg.hot *= 0.93;
  if (_kg.alpha <= 0) array_delete(kdash_ghosts, i, 1);
}

for (var i = array_length(kdash_arcs) - 1; i >= 0; i--) {
  kdash_arcs[i].life--;
  if (kdash_arcs[i].life <= 0) array_delete(kdash_arcs, i, 1);
}

for (var i = array_length(kdash_slashes) - 1; i >= 0; i--) {
  var _kslash = kdash_slashes[i];
  _kslash.life--;
  _kslash.spread += 0.35;
  if (_kslash.life <= 0) array_delete(kdash_slashes, i, 1);
}

for (var i = array_length(kdash_lanes) - 1; i >= 0; i--) {
  kdash_lanes[i].life--;
  if (kdash_lanes[i].life <= 0) array_delete(kdash_lanes, i, 1);
}

for (var i = array_length(kdash_sockets) - 1; i >= 0; i--) {
  var _ksoc = kdash_sockets[i];
  _ksoc.life--;
  _ksoc.recoil = max(0, _ksoc.recoil - 0.12);
  _ksoc.charge = max(0, _ksoc.charge - 0.045);
  if (_ksoc.life <= 0) array_delete(kdash_sockets, i, 1);
}

for (var i = array_length(kdash_scars) - 1; i >= 0; i--) {
  var _ksc = kdash_scars[i];
  _ksc.life--;
  _ksc.heat *= 0.94;
  if (_ksc.life <= 0) array_delete(kdash_scars, i, 1);
}

if (kdash_active) {
  kdash_escalation = clamp((t - _k_kdash_start_t) / (_k_kdash_end_t - _k_kdash_start_t), 0, 1);
  var _kd_esc = kdash_escalation;

  if (timeline_hit(_k_kdash_prelude_t)) {
    swirl_target = 0;

    kdash_rift = 1.3;
    kdash_rift_x = irandom_range(140, room_width - 140);
    kdash_rift_x_prev = kdash_rift_x;

    repeat (9) {
      var _seed = instance_create_layer(irandom_range(20, room_width - 20),
                                        irandom_range(-30, 40), "Instances", oRedKunaiDash);
      _seed.fall_speed = _k_kdash_fall_speed_start;
      _seed.speed = _seed.fall_speed;
      _seed.direction = 270;
      _seed.spawn_pop = 1;

      if (array_length(kdash_sockets) < _k_kdash_socket_cap) {
        array_push(kdash_sockets, {
          x : _seed.x,
          life : 20,
          life_max : 20,
          hot : 0.55,
          recoil : 0.5,
          charge : 0.35,
          seed : random(1000)
        });
      }
    }

    scr_impact_pulse(0.2, 0.2, 0.8, room_width / 2, 20);
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 5);
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.16);
    }
    scr_add_light(room_width / 2, 10, c_red, 5);
  }

  var _kd_next = -1;
  for (var i = 0; i < array_length(_k_kdash_beats); i++) {
    if (_k_kdash_beats[i] > t) { _kd_next = _k_kdash_beats[i]; break; }
  }
  var _kd_to_strike = (_kd_next < 0) ? 999 : (_kd_next - t);
  var _kd_coil_raw = (_kd_to_strike <= _k_kdash_coil_lead) ? (1 - _kd_to_strike / _k_kdash_coil_lead) : 0;

  kdash_coil = _kd_coil_raw * _kd_coil_raw;

  var _kd_hb_freq = lerp(0.09, 0.26, _kd_esc) + kdash_coil * 0.45;
  kdash_heartbeat_phase += _kd_hb_freq;
  kdash_heartbeat = power((sin(kdash_heartbeat_phase) + 1) * 0.5, 3) * (0.25 + _kd_esc * 0.5);

  kdash_rift = lerp(kdash_rift, 0.35 + _kd_esc * 0.45 + kdash_coil * 0.5 + kdash_heartbeat * 0.4, 0.16);
  kdash_rift_slide = min(1, kdash_rift_slide + 0.055);

  if (t mod 34 == 0) {
    kdash_rift_x_prev = lerp(kdash_rift_x_prev, kdash_rift_x, kdash_rift_slide);
    kdash_rift_x = irandom_range(120, room_width - 120);
    kdash_rift_slide = 0;
  }

  if (t mod 3 == 0 && random(1) < 0.35 + _kd_esc * 0.4 && array_length(kdash_arcs) < 40) {
    var _rx = lerp(kdash_rift_x_prev, kdash_rift_x, kdash_rift_slide) + random_range(-160, 160);
    array_push(kdash_arcs, {
      x1 : _rx, y1 : 2,
      x2 : _rx + random_range(-70, 70), y2 : random_range(10, 46),
      life : 7, life_max : 7,
      hot : 0.3 + random(0.4),
      seed : random(1000)
    });
  }

  var _kd_interval = round(lerp(_k_kdash_spawn_interval_start, _k_kdash_spawn_interval_end, _kd_esc));

  if (kdash_coil > 0.65) _kd_interval = max(2, _kd_interval + 2);

  if (t mod _kd_interval == 0) {
    var _kd_hot_x = lerp(kdash_rift_x_prev, kdash_rift_x, kdash_rift_slide);

    var _kd_spawn_x = (random(1) < 0.45)
        ? clamp(_kd_hot_x + random_range(-_k_kdash_rift_width, _k_kdash_rift_width), 8, room_width - 8)
        : irandom_range(8, room_width - 8);

    var _kd_new = instance_create_layer(_kd_spawn_x, -14, "Instances", oRedKunaiDash);
    _kd_new.fall_speed = lerp(_k_kdash_fall_speed_start, _k_kdash_fall_speed_end, _kd_esc);
    _kd_new.speed = _kd_new.fall_speed;
    _kd_new.direction = 270;
    _kd_new.spawn_pop = 1;

    if (array_length(kdash_sockets) < _k_kdash_socket_cap) {
      array_push(kdash_sockets, {
        x : _kd_spawn_x,
        life : 16,
        life_max : 16,
        hot : 0.48 + _kd_esc * 0.35,
        recoil : 0.35,
        charge : 0.24 + _kd_esc * 0.25,
        seed : random(1000)
      });
    }

    array_push(kdash_arcs, {
      x1 : _kd_spawn_x, y1 : 0,
      x2 : _kd_spawn_x + random_range(-26, 26), y2 : random_range(16, 40),
      life : 6, life_max : 6,
      hot : 0.55 + random(0.35),
      seed : random(1000)
    });
  }

  if (_kd_next >= 0 && t == _kd_next - _k_kdash_coil_lead) {
    var _kd_all = ds_list_create();
    var _kd_count = instance_number(oRedKunaiDash);
    for (var i = 0; i < _kd_count; i++) ds_list_add(_kd_all, instance_find(oRedKunaiDash, i));
    ds_list_shuffle(_kd_all);

    var _kd_pick = floor(_kd_count * lerp(0.45, 0.62, _kd_esc));

    with (oRedKunaiDash) { picked = false; telegraphing = false; }

    for (var i = 0; i < _kd_pick; i++) {
      var _k = _kd_all[| i];
      if (!instance_exists(_k)) continue;

      if (_k.y < 10 || _k.y > _k_kunai_floor_y - 40) continue;

      _k.picked = true;
      _k.telegraphing = true;
      _k.coil_seed = random(6.28);
      _k.hitch = 0;

      array_push(kdash_lanes, {
        x : _k.x,
        y0 : _k.y,
        y1 : _k_kunai_floor_y,
        life : _k_kdash_coil_lead,
        life_max : _k_kdash_coil_lead,
        hot : 0.46 + _kd_esc * 0.44,
        seed : random(1000)
      });

      if (array_length(kdash_sockets) < _k_kdash_socket_cap) {
        array_push(kdash_sockets, {
          x : _k.x,
          life : _k_kdash_coil_lead + 9,
          life_max : _k_kdash_coil_lead + 9,
          hot : 0.72 + _kd_esc * 0.28,
          recoil : 0.12,
          charge : 1,
          seed : random(1000)
        });
      }
    }

    ds_list_destroy(_kd_all);

    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, 0.16 + _kd_esc * 0.14);
    }
  }

  if (kdash_coil > 0.15 && t mod 2 == 0 && array_length(kdash_arcs) < 40) {
    var _kd_pool = [];
    with (oRedKunaiDash) { if (picked) array_push(_kd_pool, { px : x, py : y }); }

    var _kd_pn = array_length(_kd_pool);
    if (_kd_pn >= 2) {
      repeat (1 + floor(kdash_coil * 2)) {
        var _a1 = _kd_pool[irandom(_kd_pn - 1)];
        var _a2 = _kd_pool[irandom(_kd_pn - 1)];
        if (point_distance(_a1.px, _a1.py, _a2.px, _a2.py) > 230) continue;
        array_push(kdash_arcs, {
          x1 : _a1.px, y1 : _a1.py,
          x2 : _a2.px, y2 : _a2.py,
          life : 5, life_max : 5,
          hot : 0.4 + kdash_coil * 0.6,
          seed : random(1000)
        });
      }
    }
  }

  if (kdash_coil > 0.02) {
    vignette_pulse = max(vignette_pulse, kdash_coil * 0.3 + kdash_heartbeat * 0.12);
    aberration_pulse = max(aberration_pulse, kdash_coil * kdash_coil * 0.22);
    bloom_pulse = max(bloom_pulse, kdash_coil * 0.35 + kdash_heartbeat * 0.2);
  }

  var _kd_struck = false;
  for (var _bi = 0; _bi < array_length(_k_kdash_beats); _bi++) {
    if (timeline_hit(_k_kdash_beats[_bi])) {
      _kd_struck = true;
      kdash_beat_index = _bi;
      break;
    }
  }

  if (_kd_struck) {
    var _kd_bi01 = kdash_beat_index / max(array_length(_k_kdash_beats) - 1, 1);
    var _kd_speed = lerp(_k_kdash_dash_speed_start, _k_kdash_dash_speed_end, _kd_bi01);
    var _kd_last = (kdash_beat_index >= array_length(_k_kdash_beats) - 1);

    var _kd_fired = 0;
    var _kd_avg_x = 0;
    var _kd_avg_y = 0;

    with (oRedKunaiDash) {
      if (!picked) continue;

      picked = false;
      telegraphing = false;
      telegraph_pulse = 0;

      dash_speed = _kd_speed * random_range(0.92, 1.08);
      dash_time = other._k_kdash_dash_frames;
      dash_peak = dash_speed;
      hitch = 0;

      pop_scale = 1.55 + _kd_bi01 * 0.35;
      pop_target = 1;
      pop_overshoot = true;
      pop_flash = 1;
      hot = 1;

      _kd_fired++;
      _kd_avg_x += x;
      _kd_avg_y += y;

      if (array_length(other.kdash_slashes) < 60) {
        array_push(other.kdash_slashes, {
          x1 : x, y1 : y - 10,
          x2 : x, y2 : y + other._k_kdash_dash_frames * dash_speed * 0.55,
          life : 13, life_max : 13,
          hot : 0.55 + _kd_bi01 * 0.45,
          spread : 0,
          seed : random(1000)
        });
      }

      if (array_length(other.kdash_sockets) < other._k_kdash_socket_cap) {
        array_push(other.kdash_sockets, {
          x : x,
          life : 18,
          life_max : 18,
          hot : 0.9,
          recoil : 1,
          charge : 0.85,
          seed : random(1000)
        });
      }
    }

    if (_kd_fired > 0) {
      _kd_avg_x /= _kd_fired;
      _kd_avg_y /= _kd_fired;
    } else {
      _kd_avg_x = room_width / 2;
      _kd_avg_y = 200;
    }

    kunai_dash_cycle_index++;
    kdash_coil = 0;
    kdash_strike_flash = 0.75 + _kd_bi01 * 0.5;
    kdash_chroma = 1;
    kdash_rift = max(kdash_rift, 1.1 + _kd_bi01 * 0.5);

    var _kd_heavy = _kd_last ? 1.7 : 1;

    scr_impact_pulse((0.28 + _kd_bi01 * 0.3) * _kd_heavy,
                     (0.3 + _kd_bi01 * 0.35) * _kd_heavy,
                     (kdash_strike_bloom_base + _kd_bi01 * kdash_strike_bloom_scale) * _kd_heavy,
                     _kd_avg_x, _kd_avg_y);

    global_ripple_pulse = max(global_ripple_pulse, (0.35 + _kd_bi01 * 0.35) * _kd_heavy);
    tear_amount = max(tear_amount, (0.18 + _kd_bi01 * 0.3) * _kd_heavy);

    array_push(ring_shockwaves, {
      x : _kd_avg_x,
      y : _kd_avg_y,
      radius : 12,
      max_radius : (220 + _kd_bi01 * 180) * _kd_heavy,
      life : 26,
      max_life : 26,
      width : 12 + _kd_bi01 * 10,
      hot : 0.5 + _kd_bi01 * 0.4,
      vs : 1
    });

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, (7 + _kd_bi01 * 7) * _kd_heavy);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, (0.012 + _kd_bi01 * 0.016) * _kd_heavy);
      oCameraController.angle_kick += choose(-1, 1) * (0.5 + _kd_bi01 * 0.9) * _kd_heavy;
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                                (0.1 + _kd_bi01 * 0.14) * _kd_heavy);
      oCameraController.letterbox_target = _kd_last ? 0.5 : 0;
    }

    scr_add_light(_kd_avg_x, _kd_avg_y, c_red, 6 + _kd_bi01 * 5);

    if (array_length(arrow_ring_particles) < 260) {
      repeat (14 + floor(_kd_bi01 * 16)) {
        var _sa = choose(0, 180) + random_range(-38, 38);
        var _ss = random_range(3, 9 + _kd_bi01 * 6);
        array_push(arrow_ring_particles, {
          x : _kd_avg_x + random_range(-160, 160),
          y : _kd_avg_y + random_range(-90, 90),
          vx : lengthdir_x(_ss, _sa),
          vy : lengthdir_y(_ss, _sa) * 0.5,
          life : 16, max_life : 16,
          size : random_range(0.07, 0.2),
          grav : 0.16, drag : 0.94,
          hot : 0.5 + _kd_bi01 * 0.4
        });
      }
    }

    if (_kd_last) {
      kdash_finale = 1;

      repeat (3) {
        array_push(ring_shockwaves, {
          x : room_width / 2, y : 240,
          radius : 20 + random(60),
          max_radius : 520 + random(200),
          life : 34, max_life : 34,
          width : 16, hot : 0.9, vs : 1
        });
      }

      repeat (26) {
        var _fa = random(360);
        array_push(ring_embers, {
          x : room_width / 2 + lengthdir_x(random_range(20, 300), _fa),
          y : 200 + lengthdir_y(random_range(20, 140), _fa),
          vx : lengthdir_x(random_range(2, 6), _fa),
          vy : lengthdir_y(random_range(2, 6), _fa) - random_range(0.5, 2),
          life : 60 + irandom(40), max_life : 100,
          size : random_range(0.1, 0.26),
          hot : 0.7 + random(0.3)
        });
      }
    }
  }

}


jr_taut_flash = max(0, jr_taut_flash - 0.045);
jr_crack_flash = max(0, jr_crack_flash - 0.06);
jr_detonate_flash = max(0, jr_detonate_flash - 0.022);
jr_chroma = lerp(jr_chroma, 0, 0.12);
jump_rope_figure_bounce = lerp(jump_rope_figure_bounce, 0, 0.2);
jr_anchor_heat[0] = max(0, jr_anchor_heat[0] - 0.035);
jr_anchor_heat[1] = max(0, jr_anchor_heat[1] - 0.035);
jr_wing_slam = max(0, jr_wing_slam - 0.09);
jr_wing_flash = max(0, jr_wing_flash - 0.055);
jr_wing_collect_flash = max(0, jr_wing_collect_flash - 0.045);
jr_wing_prompt_timer = max(0, jr_wing_prompt_timer - 1);

if (jump_rope_finished || t < jump_rope_spawn_t) {
  jr_coil = max(0, jr_coil - 0.08);
  jr_heartbeat = lerp(jr_heartbeat, 0, 0.1);
  jump_rope_telegraph_prog = max(0, jump_rope_telegraph_prog - 0.08);
  jr_escalation = lerp(jr_escalation, 0, 0.05);
  if (t < jump_rope_spawn_t) {
    jr_wing_drop_stage = 0;
    jr_wing_y = _k_jr_wing_drop_y[0];
    jr_wing_ready = false;
    cube_wings_collected = false;
    cube_wings_collect_t = -1;
    jr_wing_prompt_timer = 0;
  }
}
push_orb_arrival_flash = max(0, push_orb_arrival_flash - 0.05);
push_orb_gap_flash = max(0, push_orb_gap_flash - 0.018);

for (var i = array_length(jump_rope_dust) - 1; i >= 0; i--) {
  var _d = jump_rope_dust[i];
  _d.x += _d.vx;
  _d.y += _d.vy;
  _d.vy += _d.grav;
  _d.vx *= 0.985;
  _d.life++;
  if (_d.life >= _d.max_life) array_delete(jump_rope_dust, i, 1);
}

for (var i = array_length(jr_ghosts) - 1; i >= 0; i--) {
  var _jg = jr_ghosts[i];
  _jg.alpha -= _jg.fade;
  _jg.hot *= 0.94;
  if (_jg.alpha <= 0) array_delete(jr_ghosts, i, 1);
}

for (var i = array_length(jr_scorches) - 1; i >= 0; i--) {
  var _jsc = jr_scorches[i];
  _jsc.life--;
  _jsc.hot *= 0.955;
  if (_jsc.life <= 0) array_delete(jr_scorches, i, 1);
}

for (var i = array_length(jr_arcs) - 1; i >= 0; i--) {
  jr_arcs[i].life--;
  if (jr_arcs[i].life <= 0) array_delete(jr_arcs, i, 1);
}

for (var i = array_length(jr_reactor_streams) - 1; i >= 0; i--) {
  var _jrs = jr_reactor_streams[i];
  _jrs.y += _jrs.vy;
  _jrs.life--;
  if (_jrs.life <= 0 || _jrs.y + _jrs.len < -80) array_delete(jr_reactor_streams, i, 1);
}

for (var i = array_length(jr_scan_sweeps) - 1; i >= 0; i--) {
  var _jss = jr_scan_sweeps[i];
  _jss.y += _jss.vy;
  _jss.life--;
  if (_jss.life <= 0 || _jss.y < -90 || _jss.y > room_height + 90) array_delete(jr_scan_sweeps, i, 1);
}

for (var i = array_length(jr_lock_frames) - 1; i >= 0; i--) {
  jr_lock_frames[i].life--;
  if (jr_lock_frames[i].life <= 0) array_delete(jr_lock_frames, i, 1);
}

for (var i = array_length(jr_shards) - 1; i >= 0; i--) {
  var _jsh = jr_shards[i];
  _jsh.x += _jsh.vx;
  _jsh.y += _jsh.vy;
  _jsh.vy += 0.28;
  _jsh.vx *= 0.985;
  _jsh.ang += _jsh.spin;
  _jsh.life--;
  if (_jsh.y > _k_jr_floor_y && _jsh.vy > 0) {
    _jsh.y = _k_jr_floor_y;
    _jsh.vy *= -0.32;
    _jsh.vx *= 0.7;
    _jsh.spin *= 0.5;
  }
  if (_jsh.life <= 0) array_delete(jr_shards, i, 1);
}

for (var i = array_length(push_waves) - 1; i >= 0; i--) {
  var _pw = push_waves[i];
  _pw.prev_y = _pw.y;
  _pw.y += _pw.speed;
  _pw.speed *= 0.985;
  _pw.life--;
  if (_pw.life <= 0 || _pw.y > room_height + 80 || _pw.y < -80) array_delete(push_waves, i, 1);
}

if (!jr_detonated && t > _k_jr_detonate_t) {
  jr_detonated = true;
}

if (t >= jump_rope_spawn_t && !jump_rope_finished) {
  var _n = array_length(jump_rope_key_times);
  var _last_beat_t = jump_rope_key_times[_n - 1];

  jr_weave = clamp((t - jump_rope_spawn_t) / _k_jr_weave_frames, 0, 1);

  if (t < _last_beat_t) {
    for (var i = 0; i < _n - 1; i++) {
      if (t >= jump_rope_key_times[i] && t < jump_rope_key_times[i + 1]) {
        var _prog = (t - jump_rope_key_times[i]) / (jump_rope_key_times[i + 1] - jump_rope_key_times[i]);
        var _k_jr_whip_strength = 0.55;
        var _eased_prog = _prog + (_k_jr_whip_strength / (2 * pi) ) * sin(2 * pi * _prog);
        jump_rope_phase = _eased_prog * 2 * pi;
        break;
      }
    }
    jump_rope_alpha = jr_weave;
  } else if (!jr_detonated) {
    var _fade_prog = clamp((t - _last_beat_t) / max(_k_jr_detonate_t - _last_beat_t, 1), 0, 1);
    jump_rope_phase = _fade_prog * 2 * pi;
    jump_rope_alpha = 1;
  } else {
    var _fade_prog = clamp((t - _k_jr_detonate_t) / _k_jr_fade_out_frames, 0, 1);
    jump_rope_phase = lerp(0, pi, _fade_prog);
    jump_rope_alpha = 1 - _fade_prog;

    if (_fade_prog >= 1) {
      for (var i = 0; i < array_length(jump_rope_bullets); i++) {
        if (instance_exists(jump_rope_bullets[i])) instance_destroy(jump_rope_bullets[i]);
      }
      jump_rope_bullets = [];
      jr_curve_pts = [];
      jump_rope_finished = true;
    }
  }

  var _jr_first = jump_rope_beats[0];
  var _jr_last = jump_rope_beats[array_length(jump_rope_beats) - 1];
  jr_escalation = clamp((t - _jr_first) / max(_jr_last - _jr_first, 1), 0, 1);

  if (!cube_wings_collected) {
    var _jr_wing_due = 0;
    for (var _wi = 0; _wi < array_length(jump_rope_beats); _wi++) {
      if (t >= jump_rope_beats[_wi]) _jr_wing_due = _wi + 1;
    }
    jr_wing_drop_stage = min(_jr_wing_due, _k_jr_wing_collect_stage);
    var _jr_wing_target_i = min(jr_wing_drop_stage, array_length(_k_jr_wing_drop_y) - 1);
    var _jr_wing_target_y = _k_jr_wing_drop_y[_jr_wing_target_i];
    var _jr_wing_lerp = 0.105 + jr_wing_slam * 0.20 + (jr_wing_drop_stage >= _k_jr_wing_collect_stage ? 0.055 : 0);
    jr_wing_y = lerp(jr_wing_y, _jr_wing_target_y, _jr_wing_lerp);
    jr_wing_ready = (jr_wing_drop_stage >= _k_jr_wing_collect_stage);
    jr_wing_x = _k_jr_wing_pickup_x + sin(t * 0.037) * (2 + jr_wing_slam * 4);
    scr_register_glow_point(jr_wing_x, jr_wing_y);
    if (jr_wing_ready) scr_register_glow_point(jr_wing_x, _k_jr_wing_pickup_y);
  }

  var _jr_next = -1;
  var _jr_next_idx = -1;
  for (var i = 0; i < array_length(jump_rope_beats); i++) {
    if (jump_rope_beats[i] > t) { _jr_next = jump_rope_beats[i]; _jr_next_idx = i; break; }
  }
  if (_jr_next < 0 && !jr_detonated && t < _k_jr_detonate_t) {
    _jr_next = _k_jr_detonate_t;
    _jr_next_idx = array_length(jump_rope_beats);
  }

  var _jr_to_crack = (_jr_next < 0) ? 999 : (_jr_next - t);
  var _jr_coil_raw = (_jr_to_crack <= _k_jr_coil_lead) ? (1 - _jr_to_crack / _k_jr_coil_lead) : 0;
  jr_coil = _jr_coil_raw * _jr_coil_raw;

  if (_jr_coil_raw > 0 && _jr_next_idx != jr_lock_index) {
    jr_lock_index = _jr_next_idx;
    if (array_length(jr_lock_frames) >= _k_jr_lock_cap) array_delete(jr_lock_frames, 0, 1);
    array_push(jr_lock_frames, {
      x1 : _k_jr_anchor_left_x,
      x2 : _k_jr_anchor_right_x,
      y1 : _k_jr_floor_y - 54,
      y2 : _k_jr_floor_y + 12,
      life : 18,
      life_max : 18,
      hot : 0.55 + clamp(_jr_next_idx / max(array_length(jump_rope_beats), 1), 0, 1) * 0.45,
      seed : random(1000)
    });
  } else if (_jr_coil_raw <= 0 && _jr_to_crack > _k_jr_coil_lead) {
    jr_lock_index = -99;
  }

  var _jr_hb_freq = lerp(0.1, 0.3, jr_escalation) + jr_coil * 0.5;
  jr_heartbeat_phase += _jr_hb_freq;
  jr_heartbeat = power((sin(jr_heartbeat_phase) + 1) * 0.5, 3) * (0.22 + jr_escalation * 0.5);

  jr_handle_spin += lerp(6, 13, jr_escalation) + jr_coil * 8;

  var _anchor_sway_y = sin(jump_rope_phase) * _k_jr_anchor_sway;
  var _anchor_swing_x = cos(jump_rope_phase) * _k_jr_anchor_swing_x;

  jump_rope_anchor_left_y = _k_jr_anchor_y + _anchor_sway_y;
  jump_rope_anchor_right_y = _k_jr_anchor_y + _anchor_sway_y;
  jump_rope_anchor_left_x = _k_jr_anchor_left_x - _anchor_swing_x;
  jump_rope_anchor_right_x = _k_jr_anchor_right_x + _anchor_swing_x;

  jump_rope_depth = cos(jump_rope_phase);
  jump_rope_mid_x = (jump_rope_anchor_left_x + jump_rope_anchor_right_x) / 2;
  jump_rope_mid_y = _k_jr_floor_y - _k_jr_amp_y * (1 - cos(jump_rope_phase));

  var _near_bottom = (jump_rope_phase < _k_jr_hazard_window) || (jump_rope_phase > 2 * pi - _k_jr_hazard_window);
  jump_rope_hazard_active = _near_bottom && (jump_rope_alpha >= 1) && !jr_detonated;

  if (jump_rope_hazard_active && instance_exists(oPlayer) && oPlayer.situated && !instance_exists(oGameover)) {
    var _jr_hit_min_x = min(jump_rope_anchor_left_x, jump_rope_anchor_right_x) - 32;
    var _jr_hit_max_x = max(jump_rope_anchor_left_x, jump_rope_anchor_right_x) + 32;

    if (oPlayer.x >= _jr_hit_min_x && oPlayer.x <= _jr_hit_max_x) {
      player_register_hazard_hit();
    }
  }

  if (jump_rope_alpha > 0.2 && instance_exists(oPlayer) && !instance_exists(oGameover)) {
    var _jr_figure_half_w = 28 * _k_jr_figure_scale;
    var _jr_figure_top = _k_jr_floor_y - 78 * _k_jr_figure_scale;
    var _jr_figure_bottom = _k_jr_floor_y + 4 * _k_jr_figure_scale;
    var _jr_figure_left_x = _k_jr_anchor_left_x - _k_jr_figure_stand_offset;
    var _jr_figure_right_x = _k_jr_anchor_right_x + _k_jr_figure_stand_offset;

    if (collision_rectangle(_jr_figure_left_x - _jr_figure_half_w, _jr_figure_top,
                            _jr_figure_left_x + _jr_figure_half_w, _jr_figure_bottom,
                            oPlayer, false, true) != noone ||
        collision_rectangle(_jr_figure_right_x - _jr_figure_half_w, _jr_figure_top,
                            _jr_figure_right_x + _jr_figure_half_w, _jr_figure_bottom,
                            oPlayer, false, true) != noone) {
      player_register_hazard_hit();
    }
  }

  var _crack_overshoot = 0;
  if (_near_bottom) {
    var _crack_phase = (jump_rope_phase < pi) ? jump_rope_phase : (jump_rope_phase - 2 * pi);
    _crack_overshoot = cos(_crack_phase / _k_jr_hazard_window * (pi / 2)) * 6;
  }
  jump_rope_mid_y += _crack_overshoot;

  var _jr_speed01 = clamp((jump_rope_depth + 1) / 2, 0, 1);
  jr_chroma = max(jr_chroma, power(_jr_speed01, 3) * (0.35 + jr_escalation * 0.5) + jr_crack_flash * 0.6);

  jr_ghost_timer++;
  if (jump_rope_alpha > 0.4 && _jr_speed01 > 0.55 && jr_ghost_timer >= _k_jr_ghost_interval) {
    jr_ghost_timer = 0;
    var _jg_pts = [];
    for (var i = 0; i < array_length(jump_rope_bullets); i += 2) {
      var _jb = jump_rope_bullets[i];
      if (instance_exists(_jb)) array_push(_jg_pts, { x : _jb.x, y : _jb.y });
    }
    if (array_length(_jg_pts) >= 3) {
      if (array_length(jr_ghosts) >= _k_jr_ghost_cap) array_delete(jr_ghosts, 0, 1);
      array_push(jr_ghosts, {
        pts : _jg_pts,
        alpha : 0.32 * jump_rope_alpha * (0.6 + jr_escalation * 0.6),
        fade : 0.028,
        hot : 0.3 + _jr_speed01 * 0.5 + jr_coil * 0.4,
        width : lerp(3, 8, _jr_speed01)
      });
    }
  }

  if (jump_rope_alpha > 0.3 && array_length(jr_arcs) < _k_jr_arc_cap &&
      (t mod 2 == 0) && array_length(jump_rope_bullets) > 4) {
    var _jr_arc_chance = 0.18 + jr_coil * 0.7 + _jr_speed01 * 0.25;
    if (random(1) < _jr_arc_chance) {
      var _bi1 = irandom(array_length(jump_rope_bullets) - 1);
      var _jb1 = jump_rope_bullets[_bi1];
      if (instance_exists(_jb1)) {
        if (jr_coil > 0.2) {
          array_push(jr_arcs, {
            x1 : _jb1.x, y1 : _jb1.y,
            x2 : jump_rope_mid_x + random_range(-90, 90), y2 : _k_jr_floor_y - random_range(0, 40),
            life : 6, life_max : 6,
            hot : 0.4 + jr_coil * 0.6,
            seed : random(1000)
          });
        } else {
          var _la = random(360);
          array_push(jr_arcs, {
            x1 : _jb1.x, y1 : _jb1.y,
            x2 : _jb1.x + lengthdir_x(random_range(20, 55), _la),
            y2 : _jb1.y + lengthdir_y(random_range(20, 55), _la),
            life : 5, life_max : 5,
            hot : 0.25 + random(0.3),
            seed : random(1000)
          });
        }
      }
    }
  }

  if (jr_coil > 0.02) {
    var _jr_span_l = lerp(_k_jr_anchor_left_x, jump_rope_mid_x, jr_coil * 0.16);
    var _jr_span_r = lerp(_k_jr_anchor_right_x, jump_rope_mid_x, jr_coil * 0.16);
    var _jr_span_w = max(1, _jr_span_r - _jr_span_l);

    if (t mod 2 == 0) {
      var _stream_count = 2 + floor(jr_coil * (3 + jr_escalation * 4));
      repeat (_stream_count) {
        if (array_length(jr_reactor_streams) >= _k_jr_stream_cap) array_delete(jr_reactor_streams, 0, 1);
        array_push(jr_reactor_streams, {
          x : random_range(_jr_span_l, _jr_span_r),
          y : _k_jr_floor_y + random_range(-3, 8),
          len : random_range(34, 118) * (0.85 + jr_coil * 0.55),
          vy : -random_range(3.2, 8.8) * (0.8 + jr_coil * 0.75),
          w : random_range(1.4, 4.3),
          life : irandom_range(14, 30),
          life_max : 30,
          hot : 0.35 + jr_coil * 0.65,
          color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet),
          seed : random(1000)
        });
      }
    }

    if (t mod 4 == 0) {
      if (array_length(jr_scan_sweeps) >= _k_jr_scan_cap) array_delete(jr_scan_sweeps, 0, 1);
      array_push(jr_scan_sweeps, {
        x : jump_rope_mid_x,
        y : _k_jr_floor_y + random_range(-5, 5),
        w : _jr_span_w + 120 + jr_coil * 90,
        vy : -random_range(4.0, 9.2) * (0.75 + jr_coil * 0.5),
        life : 22,
        life_max : 22,
        hot : 0.45 + jr_coil * 0.55,
        color : merge_color(_k_er_col_cyan, _k_er_col_warning, jr_coil * 0.35),
        seed : random(1000)
      });
    }
  }

  if (t >= _k_jr_taut_t && t < jump_rope_beats[0]) {
    var _wind = clamp((t - _k_jr_taut_t) / max(jump_rope_beats[0] - _k_jr_taut_t, 1), 0, 1);
    vignette_pulse = max(vignette_pulse, 0.1 + _wind * 0.22 + jr_heartbeat * 0.2);
    bloom_pulse = max(bloom_pulse, jr_heartbeat * 0.35);
    if (instance_exists(oCameraController)) {
      oCameraController.letterbox_target = max(oCameraController.letterbox_target, _wind * 0.28);
    }
  }

  if (jr_coil > 0.02) {
    vignette_pulse = max(vignette_pulse, jr_coil * 0.32);
    aberration_pulse = max(aberration_pulse, jr_coil * jr_coil * 0.25);
    bloom_pulse = max(bloom_pulse, jr_coil * 0.4 + jr_heartbeat * 0.2);
  }

  var _jr_cracked = false;
  var _jr_crack_i = -1;
  for (var i = 0; i < array_length(jump_rope_beats); i++) {
    if (timeline_hit(jump_rope_beats[i])) { _jr_cracked = true; _jr_crack_i = i; break; }
  }

  if (_jr_cracked) {
    if (!cube_wings_collected && _jr_crack_i >= 0) {
      jr_wing_drop_stage = min(max(jr_wing_drop_stage, _jr_crack_i + 1), _k_jr_wing_collect_stage);
      jr_wing_slam = 1;
      jr_wing_flash = 1;
      jr_wing_ready = (jr_wing_drop_stage >= _k_jr_wing_collect_stage);
    }

    jump_rope_beat_index++;
    scr_jump_rope_impact(jump_rope_mid_x, _k_jr_floor_y);
    if (t >= push_orb_spawn_t && t <= push_orb_end_t) scr_push_orb_wave();
  }

  if (!cube_wings_collected && jr_wing_ready && instance_exists(oPlayer) &&
      !oPlayer.dead && !instance_exists(oGameover)) {
    if (abs(oPlayer.x - jr_wing_x) <= _k_jr_wing_collect_w &&
        abs(oPlayer.y - jr_wing_y) <= _k_jr_wing_collect_h) {
      cube_wings_collected = true;
      cube_wings_collect_t = t;
      jr_wing_collect_flash = 1.4;
      jr_wing_flash = 1.2;
      jr_wing_prompt_timer = jr_wing_prompt_max;
      jr_wing_collect_x = jr_wing_x;
      jr_wing_collect_y = jr_wing_y;

      repeat (28) {
        var _wa = random(360);
        var _ws = random_range(2.5, 9);
        array_push(arrow_ring_particles, {
          x : jr_wing_collect_x, y : jr_wing_collect_y,
          vx : lengthdir_x(_ws, _wa),
          vy : lengthdir_y(_ws, _wa),
          life : 22, max_life : 22,
          size : random_range(0.06, 0.18),
          grav : 0.06, drag : 0.94,
          hot : 0.85
        });
      }

      array_push(ring_shockwaves, {
        x : jr_wing_collect_x, y : jr_wing_collect_y,
        radius : 8, max_radius : 150,
        life : 24, max_life : 24,
        width : 8, hot : 0.85, vs : 1
      });

      scr_add_light(jr_wing_collect_x, jr_wing_collect_y, _k_er_col_white, 8);
      scr_impact_pulse(0.18, 0.3, 0.65, jr_wing_collect_x, jr_wing_collect_y);

      with (oPlayer) {
        airjump_number = 9999999;
        airjump_index = 0;
      }

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, 6);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.014);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.12);
      }
    }
  }
  jump_rope_prev_hazard_active = jump_rope_hazard_active;

  jump_rope_telegraph_prog = max(jr_coil, 0);
}

if (timeline_hit(jump_rope_spawn_t)) {
  jr_anchor_heat[0] = 1.4;
  jr_anchor_heat[1] = 1.4;
  jr_weave = 0;
  jr_lock_index = -99;
  jr_reactor_streams = [];
  jr_scan_sweeps = [];
  jr_lock_frames = [];
  jr_wing_x = _k_jr_wing_pickup_x;
  jr_wing_y = _k_jr_wing_drop_y[0];
  jr_wing_drop_stage = 0;
  jr_wing_ready = false;
  jr_wing_slam = 0;
  jr_wing_flash = 0.8;
  jr_wing_collect_flash = 0;
  jr_wing_prompt_timer = 0;
  jr_wing_collect_x = jr_wing_x;
  jr_wing_collect_y = jr_wing_y;
  cube_wings_collected = false;
  cube_wings_collect_t = -1;

  for (var _h = 0; _h < 2; _h++) {
    var _hx = (_h == 0) ? _k_jr_anchor_left_x : _k_jr_anchor_right_x;
    repeat (14) {
      array_push(converge_motes, {
        cx : _hx, cy : _k_jr_anchor_y,
        ang : random(360),
        dist : random_range(90, 220),
        dest : random_range(4, 12),
        speed : random_range(4, 8),
        size : random_range(0.08, 0.2),
        spin : choose(-1, 1) * random_range(2, 6),
        hot : 0.5 + random(0.5),
        feed : "rope"
      });
    }

    array_push(ring_shockwaves, {
      x : _hx, y : _k_jr_anchor_y,
      radius : 4, max_radius : 90,
      life : 22, max_life : 22,
      width : 7, hot : 0.6, vs : 1
    });

    scr_add_light(_hx, _k_jr_anchor_y, _k_er_col_cyan, 4);
  }

  scr_impact_pulse(0.2, 0.15, 0.7, room_width / 2, _k_jr_anchor_y);
  if (instance_exists(oCameraController)) oCameraController.shake = max(oCameraController.shake, 4);
}

if (timeline_hit(_k_jr_taut_t)) {
  jr_taut_flash = 1.2;
  jr_weave = 1;
  jr_anchor_heat[0] = max(jr_anchor_heat[0], 1.1);
  jr_anchor_heat[1] = max(jr_anchor_heat[1], 1.1);

  scr_impact_pulse(0.34, 0.35, 1.1, jump_rope_mid_x, _k_jr_anchor_y);
  global_ripple_pulse = max(global_ripple_pulse, 0.5);
  tear_amount = max(tear_amount, 0.2);
  jr_chroma = 1;

  array_push(ring_shockwaves, {
    x : (_k_jr_anchor_left_x + _k_jr_anchor_right_x) / 2,
    y : _k_jr_anchor_y,
    radius : 8, max_radius : 380,
    life : 28, max_life : 28,
    width : 14, hot : 0.8, vs : 1
  });

  repeat (30) {
    var _tx = random_range(_k_jr_anchor_left_x, _k_jr_anchor_right_x);
    var _ta = random(360);
    var _ts = random_range(2, 7);
    array_push(arrow_ring_particles, {
      x : _tx, y : _k_jr_anchor_y + random_range(-14, 14),
      vx : lengthdir_x(_ts, _ta),
      vy : lengthdir_y(_ts, _ta),
      life : 20, max_life : 20,
      size : random_range(0.07, 0.2),
      grav : 0.12, drag : 0.94,
      hot : 0.7
    });
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 8);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.018);
    oCameraController.angle_kick += choose(-1, 1) * 1.2;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.2);
  }

  scr_add_light(jump_rope_mid_x, _k_jr_anchor_y, _k_er_col_cyan, 7);
  jump_rope_figure_bounce = 1;
}

if (timeline_hit(_k_jr_detonate_t) && !jr_detonated) {
  jr_detonated = true;
  jr_detonate_flash = 1;
  jr_chroma = 1.4;

  var _det_x = jump_rope_mid_x;
  var _det_y = _k_jr_floor_y;

  for (var i = 0; i < array_length(jump_rope_bullets); i++) {
    var _jb = jump_rope_bullets[i];
    if (!instance_exists(_jb)) continue;
    var _da = point_direction(_det_x, _det_y, _jb.x, _jb.y) + random_range(-30, 30);
    var _ds = random_range(5, 15);
    array_push(jr_shards, {
      x : _jb.x, y : _jb.y,
      vx : lengthdir_x(_ds, _da),
      vy : lengthdir_y(_ds, _da) - random_range(2, 7),
      ang : random(360),
      spin : choose(-1, 1) * random_range(4, 14),
      life : 70 + irandom(40), life_max : 110,
      hot : 0.7 + random(0.3),
      size : random_range(0.5, 1.2)
    });
  }

  scr_impact_pulse(0.85, 0.7, 2.2, _det_x, _det_y);
  scr_floor_impact(_det_x, _det_y, 1.2, 1);
  scr_floor_impact(_det_x - 240, _det_y, 0.9, 1);
  scr_floor_impact(_det_x + 240, _det_y, 0.9, 1);
  global_ripple_pulse = max(global_ripple_pulse, 1);
  tear_amount = max(tear_amount, 0.75);

  repeat (4) {
    array_push(ring_shockwaves, {
      x : _det_x + random_range(-120, 120), y : _det_y,
      radius : 10 + random(40),
      max_radius : 520 + random(280),
      life : 36, max_life : 36,
      width : 18, hot : 0.95, vs : 1
    });
  }

  array_push(ring_bursts, {
    x : _det_x, y : _det_y,
    tier : 3,
    color : merge_color(_k_er_col_cyan, c_white, 0.5),
    num : 10, offset : 0,
    life : 34,
    shockwave_radius : 0,
    shockwave_max_radius : 460,
    shockwave_alpha : 1.6,
    shockwave_alpha_start : 1.6
  });

  for (var _s = 0; _s < 7; _s++) {
    if (array_length(jr_scorches) >= _k_jr_scorch_cap) array_delete(jr_scorches, 0, 1);
    array_push(jr_scorches, {
      x : _det_x + (_s - 3) * 110 + random_range(-30, 30),
      life : 150, life_max : 150,
      w : random_range(70, 150),
      hot : 1
    });
  }

  repeat (70) {
    var _ea2 = choose(0, 180) + random_range(-70, 70);
    var _es2 = random_range(4, 16);
    array_push(arrow_ring_particles, {
      x : _det_x + random_range(-320, 320), y : _det_y,
      vx : lengthdir_x(_es2, _ea2),
      vy : -abs(lengthdir_y(_es2, _ea2)) * 1.1,
      life : 26, max_life : 26,
      size : random_range(0.08, 0.26),
      grav : 0.3, drag : 0.95,
      hot : 0.8 + random(0.2)
    });
  }

  repeat (34) {
    array_push(ring_embers, {
      x : _det_x + random_range(-340, 340), y : _det_y - random(20),
      vx : random_range(-3, 3),
      vy : random_range(-7, -2),
      life : 70 + irandom(50), max_life : 120,
      size : random_range(0.1, 0.28),
      hot : 0.7 + random(0.3)
    });
  }

  repeat (26) {
    array_push(jump_rope_dust, {
      x : _det_x + random_range(-360, 360),
      y : _det_y,
      vx : random_range(-5, 5),
      vy : random_range(-6, -1.5),
      grav : 0.14,
      life : 0, max_life : 34 + irandom(24),
      size : random_range(2, 6),
      hot : 0.6 + random(0.4)
    });
  }

  push_orb_beat_index += 3;
  array_push(push_waves, {
    y : _det_y - 40,
    prev_y : _det_y - 40,
    speed : -_k_push_wave_speed * 1.6,
    life : _k_push_wave_life,
    max_life : _k_push_wave_life,
    hot : 1,
    thickness : 26,
    color : c_white,
    seed : random(1000)
  });

  repeat (32) {
    if (array_length(jr_reactor_streams) >= _k_jr_stream_cap) array_delete(jr_reactor_streams, 0, 1);
    array_push(jr_reactor_streams, {
      x : _det_x + random_range(-360, 360),
      y : _det_y + random_range(-8, 14),
      len : random_range(70, 210),
      vy : -random_range(7.5, 18.0),
      w : random_range(2.0, 7.0),
      life : irandom_range(24, 44),
      life_max : 44,
      hot : 1,
      color : choose(_k_er_col_cyan, _k_er_col_warning, _k_er_col_violet, c_white),
      seed : random(1000)
    });
  }
  with (oPushOrb) {
    vspeed_target = 22;
    squash_timer = 1;
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 22);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.055);
    oCameraController.angle_kick += choose(-1, 1) * 3.5;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.75);
    oCameraController.letterbox_target = 0.8;
  }

  scr_add_light(_det_x, _det_y, _k_er_col_cyan, 14);
  jump_rope_figure_bounce = 1.6;
}

if (timeline_hit(jump_rope_spawn_t)) {
  jump_rope_bullets = [];

  var _ref_mid_x = (_k_jr_anchor_left_x + _k_jr_anchor_right_x) / 2;
  var _ref_mid_y = _k_jr_floor_y;

  var _s_values = [];
  var _arc_steps = 120;
  var _arc_s = array_create(_arc_steps + 1, 0);
  var _arc_len = array_create(_arc_steps + 1, 0);
  var _last_x = _k_jr_anchor_left_x;
  var _last_y = _k_jr_anchor_y;

  for (var _ai = 1; _ai <= _arc_steps; _ai++) {
    var _as = _ai / _arc_steps;
    var _ainv = 1 - _as;
    var _ax = _ainv * _ainv * _k_jr_anchor_left_x + 2 * _ainv * _as * _ref_mid_x + _as * _as * _k_jr_anchor_right_x;
    var _ay = _ainv * _ainv * _k_jr_anchor_y + 2 * _ainv * _as * _ref_mid_y + _as * _as * _k_jr_anchor_y;

    _arc_s[_ai] = _as;
    _arc_len[_ai] = _arc_len[_ai - 1] + point_distance(_last_x, _last_y, _ax, _ay);
    _last_x = _ax;
    _last_y = _ay;
  }

  var _total_len = max(_arc_len[_arc_steps], 1);
  var _seg = 1;
  for (var i = 0; i < _k_jr_bullet_count; i++) {
    var _target_len = _total_len * ((i + 1) / (_k_jr_bullet_count + 1));
    while (_seg < _arc_steps && _arc_len[_seg] < _target_len) _seg++;

    var _len0 = _arc_len[_seg - 1];
    var _len1 = _arc_len[_seg];
    var _lf = (_len1 > _len0) ? ((_target_len - _len0) / (_len1 - _len0)) : 0;
    array_push(_s_values, lerp(_arc_s[_seg - 1], _arc_s[_seg], _lf));
  }

  for (var i = 0; i < _k_jr_bullet_count; i++) {
    var _inst = instance_create_layer(0, 0, "Instances", oJumpRope);
    _inst.rope_s = _s_values[i];
    array_push(jump_rope_bullets, _inst);
  }
}

if (timeline_hit(push_orb_spawn_t)) {
  push_orb_field = [];
  push_orb_arrival_flash = 1;

  for (var i = 0; i < _k_push_orb_field_count; i++) {
    var _x = irandom_range(40, room_width - 40);

    var _y = irandom_range(-60, room_height * 0.45);

    var _inst = instance_create_layer(_x, _y, "Instances", oPushOrb);
    _inst.vspeed_current = _k_push_orb_idle_fall_speed;
    _inst.vspeed_target = _k_push_orb_idle_fall_speed;
    _inst.spawn_pop = 1;
    _inst.hot = 0.6;
    _inst.reactor_phase = random(1000);
    array_push(push_orb_field, _inst);

    if (_y > 0) {
      array_push(ring_shockwaves, {
        x : _x, y : _y,
        radius : 2, max_radius : 44,
        life : 16, max_life : 16,
        width : 5, hot : 0.5, vs : 1
      });
    }
  }
}

if (t >= transition_fade_start_t && t < transition_fade_full_t) {
  transition_black_alpha = (t - transition_fade_start_t) / (transition_fade_full_t - transition_fade_start_t);
} else if (t >= transition_fade_full_t && t < transition_reveal_t) {
  transition_black_alpha = 1;
} else if (t >= transition_reveal_t) {
  transition_black_alpha = 0;
}

if (t >= _k_transition_cleanup_start_t && t < _k_transition_cleanup_end_t) {
  with(oPushOrb) vspeed_target += 0.4;
}

if (timeline_hit(transition_reveal_t)) {
  transition_reveal_flash = 1;
}
if (transition_reveal_flash > 0) transition_reveal_flash = max(transition_reveal_flash - 0.08, 0);

if (timeline_hit(_k_dna_spawn_t)) {
  dna_active = true;
  dna_fade_active = true;
  dna_fade_start_t = t;
  dna_veil = 0;
  dna_despawn_active = false;
  dna_spawn_fully_active();
}

for (var i = array_length(dna_write_arcs) - 1; i >= 0; i--) {
  dna_write_arcs[i].life--;
  if (dna_write_arcs[i].life <= 0) array_delete(dna_write_arcs, i, 1);
}

scr_lattice_update();

if (!is_undefined(lat)) scr_lattice_clear();

dna_chain_flash = max(0, dna_chain_flash - 0.05);

for (var i = array_length(dna_cross_arcs) - 1; i >= 0; i--) {
  dna_cross_arcs[i].life--;
  if (dna_cross_arcs[i].life <= 0) array_delete(dna_cross_arcs, i, 1);
}

if (dna_fade_active) {
  var _dna_fade_p = clamp((t - dna_fade_start_t) / max(_k_dna_fade_frames, 1), 0, 1);
  dna_veil = power(_dna_fade_p, 1.35);
  if (_dna_fade_p >= 1) {
    dna_fade_active = false;
    dna_veil = 1;
  }
}

var _dna_sim_n = (dna_veil > 0.02) ? array_length(dna_structures) : 0;

for (var s = 0; s < _dna_sim_n; s++) {
  var _struct = dna_structures[s];
  var _cx = _struct.center_x;
  var _cy = _struct.center_y;

  _struct.time = dna_time_for_t(t) * _struct.dir;
  var _dna_time = _struct.time;

  for (var j = 0; j < dna_amount; j++) {
    var _dna_pos = j / (dna_amount - 1);
    var height = _dna_pos * dna_height - dna_height / 2;
    var angle = _dna_time + _dna_pos * pi * 4 + _struct.angle_offset;
    var x_offset = cos(angle) * dna_radius * _struct.mirror;
    var z_depth = sin(angle) * dna_radius;
    var visual_depth = sin(angle);
    var camera_depth = z_depth;

    var _k_dna_depth_bucket = 8;
    var _depth_front = round(-z_depth / _k_dna_depth_bucket) * _k_dna_depth_bucket;
    var _depth_back  = -_depth_front;

    var b1 = dna_structures[s].array[j];
    if (instance_exists(b1)) {
      b1.x = _cx + x_offset;
      b1.y = _cy + height + z_depth * 0.5;
      if (b1.depth != _depth_front) b1.depth = _depth_front;

      var scale1 = 1 + camera_depth / dna_radius * 0.3;
      b1.image_xscale = scale1 * b1.spawn_scale;
      b1.image_yscale = b1.image_xscale;

      b1.image_alpha = clamp(0.5 + visual_depth * 0.7, 0, 1) * dna_veil;
      if (!b1.lightning_hit) {
        b1.image_alpha *= 0.5;
      }
      b1.hit_active = visual_depth > 0.2 && b1.image_alpha > b1.hit_alpha_min && b1.spawn_scale > 0.25;
    }

    var b2 = dna_structures[s].array[j + dna_amount];
    if (instance_exists(b2)) {
      b2.x = _cx - x_offset;
      b2.y = _cy + height - z_depth * 0.5;
      if (b2.depth != _depth_back) b2.depth = _depth_back;

      var scale2 = 1 - camera_depth / dna_radius * 0.3;
      b2.image_xscale = scale2 * b2.spawn_scale;
      b2.image_yscale = b2.image_xscale;

      b2.image_alpha = clamp(0.5 - visual_depth * 0.7, 0, 1) * dna_veil;
      if (!b2.lightning_hit) {
        b2.image_alpha *= 0.5;
      }
      b2.hit_active = visual_depth < -0.2 && b2.image_alpha > b2.hit_alpha_min && b2.spawn_scale > 0.25;
    }

    if (j mod dna_rung_spacing == 0) {
      if (instance_exists(b1) && instance_exists(b2)) {
        for (var r = 0; r < rung_bullets; r++) {
          var _rung_index = dna_amount * 2 + floor(j / dna_rung_spacing) * rung_bullets + r;

          var rb = dna_structures[s].array[_rung_index];

          if (instance_exists(rb)) {
            var _rung_amount = (r + 1) / (rung_bullets + 1);

            rb.x = lerp(b1.x, b2.x, _rung_amount);
            rb.y = lerp(b1.y, b2.y, _rung_amount);
            if (rb.depth != _depth_front) rb.depth = _depth_front;
            rb.dna_z = z_depth;

            var _rung_scale = 0.5;
            rb.image_xscale = _rung_scale * rb.spawn_scale;
            rb.image_yscale = _rung_scale * rb.spawn_scale;

            var rung_visual = lerp(-visual_depth, visual_depth, _rung_amount);
            rb.image_alpha = clamp(0.5 - rung_visual * 1, 0.05, 1) * dna_veil;
            if (!rb.lightning_hit) {
              rb.image_alpha *= 0.5;
            }
            rb.hit_active = rung_visual < -0.2 && rb.image_alpha > rb.hit_alpha_min && rb.spawn_scale > 0.25;
          }
        }
      }
    }
  }
}

if (hitstop_frames > 0) {
  hitstop_frames -= 1;
  exit;
}
if timeline_hit (4000) {
  for (var _er_cleanup_p = 0; _er_cleanup_p < array_length(erupt_pillars); _er_cleanup_p++) {
    var _er_cleanup_pillar = erupt_pillars[_er_cleanup_p];
    for (var _er_cleanup_b = 0; _er_cleanup_b < array_length(_er_cleanup_pillar.bullets); _er_cleanup_b++) {
      if (instance_exists(_er_cleanup_pillar.bullets[_er_cleanup_b].inst)) {
        instance_destroy(_er_cleanup_pillar.bullets[_er_cleanup_b].inst);
      }
    }
  }
  for (var _er_cleanup_s = 0; _er_cleanup_s < array_length(erupt_strays); _er_cleanup_s++) {
    if (instance_exists(erupt_strays[_er_cleanup_s].inst)) {
      instance_destroy(erupt_strays[_er_cleanup_s].inst);
    }
  }

  erupt_materialize = 0;
  erupt_pressure = 0;
  erupt_coil = 0;
  erupt_coil_index = -1;
  erupt_flash = 0;
  erupt_floor_heat = 0;
  erupt_shudder = 0;
  erupt_beat_index = 0;
  erupt_collapsing = false;
  erupt_collapse_timer = 0;
  erupt_despawn_active = false;
  erupt_despawn_timer = 0;
  erupt_despawn_flash = 0;
  erupt_despawn_sink = 0;
  erupt_active_until = t - 1;
  erupt_armed_cols = [];
  erupt_armed_fast = false;
  erupt_last_lock_index = -99;
  erupt_pillars = [];
  erupt_strays = [];
  erupt_shards = [];
  erupt_gravel = [];
  erupt_ridges = [];
  erupt_scars = [];
  erupt_sparks = [];
  erupt_haze = [];
  erupt_seed_streams = [];
  erupt_lock_frames = [];
  erupt_charge_arcs = [];
  erupt_scan_sweeps = [];
  erupt_code_streams = [];
  erupt_panel_afterimages = [];
  erupt_reactor_rings = [];
  erupt_collapse_beams = [];
  erupt_lane_residue = [];
  erupt_despawn_sweeps = [];
  erupt_despawn_plates = [];
  erupt_despawn_threads = [];
  erupt_despawn_motes = [];
  _k_er_floor_y = _k_er_floor_base_y;

  if (instance_exists(er_lift_platform)) instance_destroy(er_lift_platform);
  er_lift_platform = noone;
  er_lift_active = false;
  er_lift_locked = false;
  er_lift_despawning = false;
  er_lift_despawn_timer = 0;
  er_lift_despawn_flash = 0;
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

  with oBlock { instance_destroy(); }
  with oPlayer {
    if (other.cube_wings_collected) {
      airjump_number = 9999999;
      airjump_index = 0;
    } else {
      airjump_number = defaults.airjump_number;
      airjump_index = min(airjump_index, airjump_number);
    }

    launching = true;
    launch_timer = 0;
    launch_time = 30;

    launch_start_y = y;
    launch_target_y = room_height / 2;
  }
  layer_set_visible("Tiles_1", false);
  with oShd_hex { instance_destroy(); }
  instance_create_layer(0, 0, "BgShader", oShd_Matrix);
}

cube_heartbeat        = max(0, cube_heartbeat - _k_cube_heartbeat_decay);
cube_heartbeat_sub    = max(0, cube_heartbeat_sub - _k_cube_heartbeat_decay * 1.7);
cube_core_flash       = max(0, cube_core_flash - 0.065);
cube_ignite_flash     = max(0, cube_ignite_flash - 0.045);
cube_detonation_flash = max(0, cube_detonation_flash - 0.044);
cube_edge_surge       = max(0, cube_edge_surge - 0.05);
cube_lock_flash       = max(0, cube_lock_flash - 0.085);
cube_strobe           = max(0, cube_strobe - 0.03);
cube_rot_surge        = (cube_rot_surge < 0.002) ? 0 : cube_rot_surge * 0.88;

if (cube_phase != "coil")     cube_coil = max(0, cube_coil - 0.05);
if (cube_phase != "overload") cube_overload = max(0, cube_overload - 0.05);

for (var _cf = 0; _cf < 6; _cf++) {
  cube_face_flash[_cf] = max(0, cube_face_flash[_cf] - 0.09);
  cube_face_heat[_cf]  = max(0, cube_face_heat[_cf] - 0.012);
}
for (var _cv = 0; _cv < 8; _cv++) {
  cube_vertex_heat[_cv] = max(0, cube_vertex_heat[_cv] - 0.04);
}

for (var _ca = array_length(cube_arcs) - 1; _ca >= 0; _ca--) {
  var _arc = cube_arcs[_ca];
  _arc.life--;
  _arc.off = scr_bolt_offsets(array_length(_arc.off), _arc.jitter);
  if (_arc.life <= 0) array_delete(cube_arcs, _ca, 1);
}

for (var _cl = array_length(cube_leaks) - 1; _cl >= 0; _cl--) {
  var _leak = cube_leaks[_cl];
  _leak.life--;
  _leak.off = scr_bolt_offsets(array_length(_leak.off), 9);
  if (_leak.life <= 0) array_delete(cube_leaks, _cl, 1);
}

for (var _cp = array_length(cube_edge_pulses) - 1; _cp >= 0; _cp--) {
  var _pul = cube_edge_pulses[_cp];
  _pul.pos += _pul.speed;
  _pul.life--;
  if (_pul.life <= 0 || _pul.pos > 1.15) array_delete(cube_edge_pulses, _cp, 1);
}

for (var _cg = array_length(cube_ghosts) - 1; _cg >= 0; _cg--) {
  cube_ghosts[_cg].alpha -= cube_ghosts[_cg].fade;
  if (cube_ghosts[_cg].alpha <= 0) array_delete(cube_ghosts, _cg, 1);
}

for (var _cs = array_length(cube_scars) - 1; _cs >= 0; _cs--) {
  cube_scars[_cs].alpha -= cube_scars[_cs].fade;
  if (cube_scars[_cs].alpha <= 0) array_delete(cube_scars, _cs, 1);
}

for (var _cc = array_length(cube_cracks) - 1; _cc >= 0; _cc--) {
  var _crk = cube_cracks[_cc];
  _crk.grow = min(1, _crk.grow + _crk.grow_speed);
  _crk.life--;
  if (_crk.life <= 0) array_delete(cube_cracks, _cc, 1);
}

for (var _cm = array_length(cube_muzzles) - 1; _cm >= 0; _cm--) {
  cube_muzzles[_cm].life--;
  if (cube_muzzles[_cm].life <= 0) array_delete(cube_muzzles, _cm, 1);
}

for (var _ci = array_length(cube_ignitions) - 1; _ci >= 0; _ci--) {
  var _ign = cube_ignitions[_ci];
  if (_ign.delay > 0) {
    _ign.delay--;
  } else {
    _ign.life--;
    if (_ign.life <= 0) array_delete(cube_ignitions, _ci, 1);
  }
}

if (cube_active || cube_despawn_active) {
  cube_section_p = clamp((t - _k_cube_t_spawn) / (_k_cube_t_despawn - _k_cube_t_spawn), 0, 1);

  if (cube_despawn_active)              cube_phase = "implode";
  else if (t >= _k_cube_t_overload)     cube_phase = "overload";
  else if (t >= _k_cube_t_salvo)        cube_phase = "salvo";
  else if (t >= _k_cube_t_coil)         cube_phase = "coil";
  else if (t >= _k_cube_t_windup)       cube_phase = "windup";
  else if (t >= _k_cube_t_idle)         cube_phase = "idle";
  else                                  cube_phase = "materialize";
} else if (cube_phase != "off") {
  if (array_length(cube_ghosts) == 0 && array_length(cube_scars) == 0 &&
      array_length(cube_arcs) == 0 && cube_detonation_flash <= 0) {
    cube_phase = "off";
    cube_section_p = 0;
  } else {
    cube_phase = "after";
  }
}

var _cube_esc = 0;
switch (cube_phase) {
  case "materialize": _cube_esc = 0.35; break;
  case "idle":        _cube_esc = lerp(0.16, 0.34, clamp((t - _k_cube_t_idle) / (_k_cube_t_windup - _k_cube_t_idle), 0, 1)); break;
  case "windup":      _cube_esc = lerp(0.34, 0.68, clamp((t - _k_cube_t_windup) / (_k_cube_t_coil - _k_cube_t_windup), 0, 1)); break;
  case "coil":        _cube_esc = lerp(0.68, 1.00, clamp((t - _k_cube_t_coil) / (_k_cube_t_salvo - _k_cube_t_coil), 0, 1)); break;
  case "salvo":       _cube_esc = lerp(0.80, 1.15, clamp((t - _k_cube_t_salvo) / (_k_cube_t_overload - _k_cube_t_salvo), 0, 1)); break;
  case "overload":    _cube_esc = lerp(1.15, 1.60, clamp((t - _k_cube_t_overload) / (_k_cube_t_despawn - _k_cube_t_overload), 0, 1)); break;
  case "implode":     _cube_esc = 1.8; break;
}

cube_charge = _cube_esc + cube_heartbeat * 0.5 + cube_coil * 0.6 + cube_overload * 0.8;

var _cube_beat = false;
var _cube_beat_i = -1;
var _cube_eighth = false;

if (cube_active) {
  for (var _cb = 0; _cb < array_length(cube_beats); _cb++) {
    if (timeline_hit(cube_beats[_cb])) {
      _cube_beat = true;
      _cube_beat_i = _cb;
      cube_beat_index = _cb;
      break;
    }
    if (timeline_hit(cube_beats[_cb] + 10)) {
      _cube_eighth = true;
      break;
    }
  }
}

cube_extend = 1;
if (cube_spawn_active) {
  cube_spawn_timer += 1;
  if (cube_spawn_timer >= cube_spawn_duration) {
    cube_spawn_active = false;
    scr_cube_vertex_sparks();
  }
  var _sp = clamp(cube_spawn_timer / cube_spawn_duration, 0, 1);
  var _c1 = 1.70158;
  var _c3 = _c1 + 1;
  cube_extend = 1 + _c3 * power(_sp - 1, 3) + _c1 * power(_sp - 1, 2);
}

if (cube_active) {
  var _core_want = (cube_phase == "materialize") ? 0 : 1;
  if (cube_despawn_active) _core_want = cube_extend;
  cube_core_extend += (_core_want - cube_core_extend) * 0.06;

  var _core_clear = 1;
  if (instance_exists(oPlayer)) {
    var _core_pd = point_distance(oPlayer.x, oPlayer.y, cube_center_x, cube_center_y);
    _core_clear = clamp((_core_pd - _k_cube_core_clear_near) /
                        (_k_cube_core_clear_far - _k_cube_core_clear_near),
                        _k_cube_core_clear_floor, 1);
  }
  cube_core_fade += (_core_clear - cube_core_fade) * 0.12;
} else {
  cube_core_extend = 0;
  cube_core_fade = 1;
}

for (var _ci2 = 0; _ci2 < array_length(cube_ignitions); _ci2++) {
  var _ig = cube_ignitions[_ci2];
  if (_ig.delay > 0 || _ig.fired) continue;
  _ig.fired = true;

  var _iv = _ig.vert;
  cube_vertex_ignited[_iv] = true;
  cube_vertex_heat[_iv] = 1.6;
  cube_core_flash = max(cube_core_flash, 0.35);
  cube_ignite_flash = max(cube_ignite_flash, 0.55);

  if (array_length(big_cube_projected) >= 8) {
    var _ivx = lerp(cube_center_x, big_cube_projected[_iv].x, cube_extend);
    var _ivy = lerp(cube_center_y, big_cube_projected[_iv].y, cube_extend);

    scr_slash_bolt(cube_center_x, cube_center_y, _ivx, _ivy, 9, 16, 1.9, 0.75);

    array_push(ring_shockwaves, {
      x : _ivx, y : _ivy, radius : 6, max_radius : 90,
      life : 16, max_life : 16, width : 9, hot : 1, vs : 1
    });

    for (var _is = 0; _is < 9; _is++) {
      var _isa = random(360);
      var _iss = random_range(2.5, 8);
      array_push(arrow_ring_particles, {
        x : _ivx, y : _ivy,
        vx : lengthdir_x(_iss, _isa), vy : lengthdir_y(_iss, _isa),
        life : 20 + irandom(12), max_life : 32,
        size : random_range(0.09, 0.24), grav : 0.05, drag : 0.94, hot : 1
      });
    }

    for (var _ie = 0; _ie < array_length(cube_edges); _ie++) {
      var _eg = cube_edges[_ie];
      if (_eg[0] != _iv && _eg[1] != _iv) continue;
      var _other = (_eg[0] == _iv) ? _eg[1] : _eg[0];
      if (!cube_vertex_ignited[_other]) continue;

      var _ox = lerp(cube_center_x, big_cube_projected[_other].x, cube_extend);
      var _oy = lerp(cube_center_y, big_cube_projected[_other].y, cube_extend);
      scr_slash_bolt(_ivx, _ivy, _ox, _oy, 8, 11, 1.4, 0.6);

      if (array_length(cube_edge_pulses) < _k_cube_edge_pulse_max) {
        array_push(cube_edge_pulses, {
          edge : _ie, pos : 0, speed : 0.09, life : 16, life_max : 16,
          hot : 1, width : 4, from_a : (_eg[0] == _iv)
        });
      }
    }
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 4.5);
  }
}

if (cube_despawn_active) {
  var _dp = clamp(cube_despawn_timer / cube_despawn_duration, 0, 1);

  if (!is_undefined(riser)) {
    scr_riser_fall_update();
    cube_center_x = riser.fall_x;
    cube_center_y = riser.fall_y;
  }

  cube_extend = 1 - (_dp * _dp * _dp);
  aberration_pulse = max(aberration_pulse, _dp * _dp * 1.45);
  vignette_pulse = max(vignette_pulse, 0.35 + _dp * 0.55);
  bloom_pulse = max(bloom_pulse, _dp * _dp * 1.4);
  cube_strobe = max(cube_strobe, 0.6 + _dp * 0.4);
  cube_edge_surge = max(cube_edge_surge, 0.5 + _dp * 0.6);

  slash_lens_x = cube_center_x;
  slash_lens_y = cube_center_y;
  slash_lens_radius = lerp(_k_cube_lens_radius, 90, _dp);
  slash_lens_strength = max(slash_lens_strength, _k_cube_lens_max * (0.6 + _dp * 0.9));

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = lerp(_k_cube_letterbox_overload, 1.0, _dp);
    oCameraController.shake = max(oCameraController.shake, 3 + _dp * 9);
  }

  if (array_length(big_cube_projected) >= 8 && array_length(cube_arcs) < _k_cube_arc_max) {
    var _in_count = 1 + floor(_dp * 3);
    for (var _ia = 0; _ia < _in_count; _ia++) {
      array_push(cube_arcs, {
        a : irandom(7), b : irandom(7), inner : true,
        life : 5, life_max : 5, jitter : 10 + _dp * 20,
        off : scr_bolt_offsets(5, 10 + _dp * 20),
        hot : 0.5 + _dp * 0.5, width : 1.3 + _dp * 1.4
      });
    }
  }

  cube_ghost_timer += 1;
  if (cube_ghost_timer >= 2 && array_length(big_cube_projected) >= 8) {
    cube_ghost_timer = 0;
    if (array_length(cube_ghosts) >= _k_cube_ghost_max) array_delete(cube_ghosts, 0, 1);
    array_push(cube_ghosts, {
      verts : big_cube_projected, extend : cube_extend,
      alpha : 0.75, fade : 0.05, hot : 0.5 + _dp * 0.5
    });
  }

  cube_despawn_timer += 1;

  if (cube_despawn_timer >= cube_despawn_duration) {
    cube_despawn_active = false;
    cube_active = false;

    if (!is_undefined(riser)) {
      cube_center_x = _k_riser_cx;
      cube_center_y = _k_riser_deck_y;
      scr_riser_land();
    }

    scr_cube_despawn_explode();
    hitstop_frames = 7;
    cube_detonation_flash = 1;
    cube_core_flash = 1.4;
    cube_strobe = 0;

    var _det_x = cube_center_x;
    var _det_y = cube_center_y;

    array_push(ring_shockwaves, {
      x : _det_x, y : _det_y, radius : 14, max_radius : 380,
      life : 22, max_life : 22, width : 26, hot : 1, vs : 1
    });
    array_push(ring_shockwaves, {
      x : _det_x, y : _det_y, radius : 20, max_radius : 720,
      life : 40, max_life : 40, width : 44, hot : 1, vs : 1
    });
    array_push(ring_shockwaves, {
      x : _det_x, y : _det_y, radius : 30, max_radius : 1150,
      life : 74, max_life : 74, width : 70, hot : 0.45, vs : 1
    });

    if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
    array_push(slash_warps, {
      x : _det_x, y : _det_y, radius : 30, max_radius : 620,
      strength : 1.5, life : 28, life_max : 28
    });
    if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
    array_push(slash_warps, {
      x : _det_x, y : _det_y, radius : 60, max_radius : 1050,
      strength : 0.75, life : 48, life_max : 48
    });

    if (array_length(big_cube_projected) >= 8) {
      for (var _de = 0; _de < array_length(cube_edges); _de++) {
        var _dedge = cube_edges[_de];
        var _dmx = (big_cube_projected[_dedge[0]].x + big_cube_projected[_dedge[1]].x) * 0.5;
        var _dmy = (big_cube_projected[_dedge[0]].y + big_cube_projected[_dedge[1]].y) * 0.5;
        var _dang = point_direction(_det_x, _det_y, _dmx, _dmy);

        array_push(ring_streaks, {
          cx : _det_x, cy : _det_y, vs : 1,
          ang : _dang, dist : random_range(10, 40), len : 90 + irandom(90),
          speed : 30, width : 3 + random(3), life : 20, max_life : 20, hot : 1
        });
        scr_slash_bolt(_det_x, _det_y,
                       _det_x + lengthdir_x(620, _dang), _det_y + lengthdir_y(620, _dang),
                       10, 26, 2.4, 0.85);
      }
    }

    for (var _dp2 = 0; _dp2 < 70; _dp2++) {
      var _dpa = random(360);
      var _dps = random_range(4, 17);
      array_push(arrow_ring_particles, {
        x : _det_x, y : _det_y,
        vx : lengthdir_x(_dps, _dpa), vy : lengthdir_y(_dps, _dpa),
        life : 26 + irandom(20), max_life : 46,
        size : random_range(0.12, 0.42), grav : 0.06, drag : 0.955, hot : 1
      });
    }
    for (var _de2 = 0; _de2 < 42; _de2++) {
      var _dea = random(360);
      var _des = random_range(3, 10);
      array_push(ring_embers, {
        x : _det_x, y : _det_y,
        vx : lengthdir_x(_des, _dea), vy : lengthdir_y(_des, _dea) - random_range(1, 4),
        life : 70 + irandom(60), max_life : 130,
        size : random_range(0.1, 0.34), hot : 1
      });
    }
    for (var _ds = 0; _ds < 40; _ds++) {
      var _dsa = random(360);
      var _dsd = random_range(30, 300);
      array_push(ring_splatter, {
        x : _det_x + lengthdir_x(_dsd, _dsa),
        y : _det_y + lengthdir_y(_dsd, _dsa),
        size : random_range(2.5, 11), drag_len : random_range(14, 60), drag_ang : _dsa,
        alpha : random_range(0.55, 1), fade : random_range(0.004, 0.010),
        hot : 0.3 + random(0.5)
      });
    }

    if (array_length(big_cube_projected) >= 8) {
      if (array_length(cube_scars) >= _k_cube_scar_max) array_delete(cube_scars, 0, 1);
      array_push(cube_scars, {
        verts : big_cube_projected, extend : 1,
        alpha : 1.0, fade : 0.008, hot : 1
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 30);
      oCameraController.screen_flash_alpha = 0.95;
      oCameraController.zoom_punch = 0.14;
      oCameraController.angle_kick = choose(-4.5, 4.5);
      oCameraController.letterbox_target = 0;
    }
    scr_impact_pulse(0.95, 9.0, 1.5, _det_x, _det_y);
    global_ripple_pulse = 0.72;
    tear_amount = 0.62;

    slash_lens_strength = 0;

    with(oCube) instance_destroy();
    with(oCubeFaceBullet) { instance_destroy(); }
    cube_face_grid_spawned = false;
    big_cube_projected = [];
    small_cube_projected = [];
    cube_face_current = -1;
    cube_face_previous = -1;
    cube_arcs = [];
    cube_leaks = [];
    cube_edge_pulses = [];
    cube_cracks = [];
    cube_muzzles = [];
    cube_ignitions = [];
    cube_coil = 0;
    cube_overload = 0;
  }
}

if (cube_active) {
  cube_echo_capture_timer += 1;
  if (cube_echo_capture_timer >= 6) {
    cube_echo_capture_timer = 0;
    array_push(cube_echo_snapshots, {verts : big_cube_projected, alpha : 1.0});
    if (array_length(cube_echo_snapshots) > 3) array_delete(cube_echo_snapshots, 0, 1);
  }

  if (cube_strobe > 0.02 && !cube_despawn_active) {
    cube_ghost_timer += 1;
    var _ghost_gap = max(2, round(lerp(_k_cube_ghost_interval * 3, _k_cube_ghost_interval, cube_strobe)));
    if (cube_ghost_timer >= _ghost_gap && array_length(big_cube_projected) >= 8) {
      cube_ghost_timer = 0;
      if (array_length(cube_ghosts) >= _k_cube_ghost_max) array_delete(cube_ghosts, 0, 1);
      array_push(cube_ghosts, {
        verts : big_cube_projected, extend : cube_extend,
        alpha : 0.35 + cube_strobe * 0.4, fade : 0.035, hot : cube_strobe
      });
    }
  }

  if (cube_seed_flash_timer > 0) cube_seed_flash_timer -= 1;

  cube_breath_timer += 1;
  var _breath = sin(cube_breath_timer * 0.03) * 0.08;
  var _beat_swell = cube_heartbeat * 0.05 + cube_heartbeat_sub * 0.025 - cube_coil * 0.06;
  cube_size = cube_size_base * (1 + _breath + _beat_swell);
  cube_edge_phase += 0.004 + cube_charge * 0.004;

  var _rot_mult = cube_shoot_phase_active ? cube_shoot_phase_slow_factor : 1;
  if (cube_phase == "coil") {
    var _coil_p = clamp((t - _k_cube_t_coil) / (_k_cube_t_salvo - _k_cube_t_coil), 0, 1);
    _rot_mult = lerp(1, 0.18, _coil_p * _coil_p);
  }
  if (cube_phase == "overload") {
    var _ov_p = clamp((t - _k_cube_t_overload) / (_k_cube_t_despawn - _k_cube_t_overload), 0, 1);
    _rot_mult = lerp(cube_shoot_phase_slow_factor, 3.2, _ov_p * _ov_p);
  }
  if (cube_despawn_active) {
    var _dp_speed = clamp(cube_despawn_timer / cube_despawn_duration, 0, 1);
    _rot_mult = lerp(1, 9, _dp_speed * _dp_speed);
  }
  _rot_mult += cube_rot_surge;

  cube_rot_speed_x = cube_rot_speed_x_normal * _rot_mult;
  cube_rot_speed_y = cube_rot_speed_y_normal * _rot_mult;

  if (!cube_spawn_active) {
    cube_rot_ease_timer = min(cube_rot_ease_timer + 1, cube_rot_ease_duration);
    var _ease_p = cube_rot_ease_timer / cube_rot_ease_duration;
    var _ease_curve = 1 - power(1 - _ease_p, 3);
    cube_rot_speed_x = cube_rot_speed_x_normal * _rot_mult * _ease_curve;
    cube_rot_speed_y = cube_rot_speed_y_normal * _rot_mult * _ease_curve;
    cube_angle_x += cube_rot_speed_x;
    cube_angle_y += cube_rot_speed_y;
  }

  var _verts = scr_cube_get_vertices(cube_size);
  big_cube_projected = [];
  for (var i = 0; i < 8; i++) {
    var _r = scr_rotate_vertex(_verts[i], cube_angle_x, cube_angle_y);
    array_push(big_cube_projected, scr_project_vertex(_r, cube_center_x, cube_center_y, cube_perspective_dist));
  }

  var _core_spin = 1 + cube_charge * 0.9 + cube_rot_surge;
  cube_core_angle_x += _k_cube_core_rot_x * _core_spin;
  cube_core_angle_y += _k_cube_core_rot_y * _core_spin;

  var _core_size = _k_cube_core_size * cube_core_extend *
                   (1 + cube_heartbeat_sub * 0.22 + cube_core_flash * 0.3 + cube_charge * 0.12);
  var _core_verts = scr_cube_get_vertices(max(1, _core_size));
  small_cube_projected = [];
  for (var i = 0; i < 8; i++) {
    var _cr = scr_rotate_vertex(_core_verts[i], cube_core_angle_x, cube_core_angle_y);
    array_push(small_cube_projected, scr_project_vertex(_cr, cube_center_x, cube_center_y, cube_perspective_dist));
  }

  cube_phase_timer += (t >= _k_cube_t_salvo) ? 0.001 : 0.002;

  var _arc_chance = lerp(_k_cube_arc_chance_idle, _k_cube_arc_chance_peak, clamp(_cube_esc, 0, 1));
  if (!cube_despawn_active && array_length(cube_arcs) < _k_cube_arc_max && random(1) < _arc_chance) {
    var _to_core = (cube_core_extend > 0.5) && (random(1) < 0.45);
    var _a = irandom(7);
    var _b = _to_core ? irandom(7) : ((_a + 1 + irandom(6)) mod 8);
    var _jit = 7 + _cube_esc * 12;

    array_push(cube_arcs, {
      a : _a, b : _b, inner : _to_core,
      life : 4 + irandom(4), life_max : 8, jitter : _jit,
      off : scr_bolt_offsets(5, _jit),
      hot : 0.25 + random(0.35) + _cube_esc * 0.25,
      width : 0.9 + random(0.7) + _cube_esc * 0.6
    });

    cube_vertex_heat[_a] = max(cube_vertex_heat[_a], 0.5);
    if (!_to_core) cube_vertex_heat[_b] = max(cube_vertex_heat[_b], 0.5);
  }

  var _leak_chance = _k_cube_leak_chance * clamp(_cube_esc - 0.3, 0, 1.4);
  if (array_length(cube_leaks) < _k_cube_leak_max && random(1) < _leak_chance) {
    var _lv = irandom(7);
    array_push(cube_leaks, {
      vert : _lv, ang : random(360),
      reach : random_range(70, 210) * (0.6 + _cube_esc * 0.7),
      life : 8 + irandom(5), life_max : 13,
      off : scr_bolt_offsets(5, 9)
    });
    cube_vertex_heat[_lv] = max(cube_vertex_heat[_lv], 0.9);
    aberration_pulse = max(aberration_pulse, 0.6);
  }

  var _ember_chance = 0.05 + _cube_esc * 0.22 + cube_overload * 0.5;
  if (array_length(big_cube_projected) >= 8 && random(1) < _ember_chance) {
    var _ev = irandom(7);
    var _evx = lerp(cube_center_x, big_cube_projected[_ev].x, cube_extend);
    var _evy = lerp(cube_center_y, big_cube_projected[_ev].y, cube_extend);
    array_push(ring_embers, {
      x : _evx, y : _evy,
      vx : random_range(-1.2, 1.2), vy : random_range(-0.6, 1.4),
      life : 44 + irandom(40), max_life : 84,
      size : random_range(0.07, 0.2), hot : 0.7 + random(0.3)
    });
  }

  vignette_pulse = max(vignette_pulse, 0.1 + _cube_esc * 0.22 + cube_coil * 0.35 + cube_overload * 0.35);
  bloom_pulse = max(bloom_pulse, cube_core_flash * 0.5 + cube_heartbeat * 0.25 + cube_ignite_flash * 0.6);

  var _k_cube_boundary_radius = cube_size_base * 1.0;
  var _k_cube_pull_strength = 0.08;
  var _k_cube_pull_max_speed = 8;

  with(oPlayer) {
    var _dist = point_distance(x, y, other.cube_center_x, other.cube_center_y);
    if (_dist > _k_cube_boundary_radius) {
      var _overshoot = _dist - _k_cube_boundary_radius;
      other.cube_boundary_push_amount = clamp(_overshoot / 40, 0, 1);
      var _pull_amount = min(_overshoot * _k_cube_pull_strength, _k_cube_pull_max_speed);
      var _pull_dir = point_direction(x, y, other.cube_center_x, other.cube_center_y);

      x += lengthdir_x(_pull_amount, _pull_dir);
      y += lengthdir_y(_pull_amount, _pull_dir);
    } else {
      other.cube_boundary_push_amount = 0;
    }
  }
}

if (cube_active && !cube_despawn_active) {
  var _thump = 0;

  if (_cube_beat) {
    _thump = 1;
  } else if (_cube_eighth && (cube_phase == "coil" || cube_phase == "overload" || cube_phase == "salvo")) {
    _thump = 0.55;
  }

  if (cube_phase == "overload" && !_cube_beat && !_cube_eighth && ((t - _k_cube_t_overload) mod 5 == 0)) {
    _thump = max(_thump, 0.3);
  }

  if (_thump > 0) {
    var _amp = _thump * (0.45 + _cube_esc * 0.85);

    if (_thump >= 1) {
      cube_heartbeat = max(cube_heartbeat, _amp);
    } else {
      cube_heartbeat_sub = max(cube_heartbeat_sub, _amp);
    }

    var _flash_amp = _amp * 0.5;
    cube_core_flash = max(cube_core_flash, _flash_amp * 0.55);
    cube_edge_surge = max(cube_edge_surge, _flash_amp * 0.8);

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_cube_beat_shake * _amp);
    }
    vignette_pulse = max(vignette_pulse, 0.12 + _amp * 0.22);
    bloom_pulse = max(bloom_pulse, _amp * 0.35);

    if (array_length(big_cube_projected) >= 8) {
      var _pulse_edges = (_thump >= 1) ? array_length(cube_edges) : (2 + irandom(3));
      for (var _pe = 0; _pe < _pulse_edges; _pe++) {
        if (array_length(cube_edge_pulses) >= _k_cube_edge_pulse_max) break;
        var _pei = (_thump >= 1) ? _pe : irandom(array_length(cube_edges) - 1);
        array_push(cube_edge_pulses, {
          edge : _pei, pos : 0, speed : 0.045 + _flash_amp * 0.05,
          life : 30, life_max : 30,
          hot : 0.4 + _flash_amp * 0.6, width : 2 + _flash_amp * 3.5,
          from_a : (irandom(1) == 0)
        });
      }
    }

    if (_thump >= 1 && _cube_esc > 0.45 && array_length(big_cube_projected) >= 8) {
      if (array_length(cube_scars) >= _k_cube_scar_max) array_delete(cube_scars, 0, 1);
      array_push(cube_scars, {
        verts : big_cube_projected, extend : cube_extend,
        alpha : 0.25 + _cube_esc * 0.3, fade : 0.012, hot : _cube_esc * 0.6
      });
    }
  }

  if (_cube_beat && (cube_phase == "windup" || cube_phase == "coil")) {
    var _mote_count = round(_k_cube_converge_per_beat * (0.6 + _cube_esc));
    for (var _mc = 0; _mc < _mote_count; _mc++) {
      array_push(converge_motes, {
        cx : cube_center_x, cy : cube_center_y,
        ang : random(360),
        dist : random_range(430, 760),
        dest : cube_size_base * random_range(0.85, 1.05),
        speed : random_range(4.5, 9) * (0.7 + _cube_esc * 0.6),
        size : random_range(0.12, 0.3),
        spin : random_range(-2.2, 2.2),
        hot : 0.4 + random(0.5),
        feed : "cube"
      });
    }
  }
}

if (cube_phase == "coil") {
  var _cp = clamp((t - _k_cube_t_coil) / (_k_cube_t_salvo - _k_cube_t_coil), 0, 1);
  cube_coil = _cp;

  slash_lens_x = cube_center_x;
  slash_lens_y = cube_center_y;
  slash_lens_radius = _k_cube_lens_radius;
  slash_lens_strength = max(slash_lens_strength, _k_cube_lens_max * _cp * _cp);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = _k_cube_letterbox_coil * _cp;
  }

  vignette_pulse = max(vignette_pulse, 0.2 + _cp * 0.45);
  cube_strobe = max(cube_strobe, _cp * 0.35);

  if (random(1) < 0.25 + _cp * 0.45) {
    var _cia = random(360);
    var _cir = cube_size_base * random_range(1.6, 2.4);
    var _cix = cube_center_x + lengthdir_x(_cir, _cia);
    var _ciy = cube_center_y + lengthdir_y(_cir, _cia);
    var _cidst = cube_size_base * random_range(0.55, 0.85);
    scr_slash_bolt(_cix, _ciy,
                   cube_center_x + lengthdir_x(_cidst, _cia + random_range(-14, 14)),
                   cube_center_y + lengthdir_y(_cidst, _cia + random_range(-14, 14)),
                   6, 13, 1.1 + _cp, 0.35 + _cp * 0.4);
  }
}

if (timeline_hit(cube_shoot_timestamps[0])) {
  cube_shoot_phase_active = true;
}
if (timeline_hit(cube_shoot_timestamps[array_length(cube_shoot_timestamps) - 1] + 40)) {
  cube_shoot_phase_active = false;
}

if (cube_active && !cube_despawn_active) {
  for (var _ts = 0; _ts < array_length(cube_shoot_timestamps); _ts++) {
    var _lead = cube_shoot_timestamps[_ts] - t;
    if (_lead > 0 && _lead <= 9) {
      var _lp = 1 - (_lead / 9);
      cube_lock_flash = max(cube_lock_flash, _lp * _lp * (0.5 + _ts / array_length(cube_shoot_timestamps)));
      break;
    }
  }
}

if (cube_active && !cube_despawn_active && cube_face_grid_enabled &&
    !cube_face_grid_spawned && t >= _k_cube_t_surface_grid_preview &&
    array_length(big_cube_projected) >= 8) {
  cube_face_grid_spawned = true;

  var _grid_life = max(24, (_k_cube_t_despawn - t) - _k_cube_grid_life_pad);
  var _grid_span = 1 - (_k_cube_grid_margin * 2);
  var _grid_step = (_k_cube_grid_size > 1) ? (_grid_span / (_k_cube_grid_size - 1)) : 0;
  var _grid_mid = floor(_k_cube_grid_size * 0.5);

  for (var f = 0; f < 6; f++) {
    cube_face_flash[f] = max(cube_face_flash[f], 0.65);
    cube_face_heat[f] = min(1.4, cube_face_heat[f] + 0.18);

    for (var _gu = 0; _gu < _k_cube_grid_size; _gu++) {
      for (var _gw = 0; _gw < _k_cube_grid_size; _gw++) {
        if (_gu == _grid_mid && _gw == _grid_mid) continue;

        var _u = _k_cube_grid_margin + _grid_step * _gu;
        var _w = _k_cube_grid_margin + _grid_step * _gw;
        var _pt = scr_face_uv_to_point(big_cube_projected, f, _u, _w);
        var _gx = lerp(cube_center_x, _pt.x, cube_extend);
        var _gy = lerp(cube_center_y, _pt.y, cube_extend);
        var _gb = instance_create_layer(_gx, _gy, layer, oCubeFaceBullet);

        _gb.bullet_mode = "grid";
        _gb.face_index = f;
        _gb.grid_u = _u;
        _gb.grid_w = _w;
        _gb.travel_duration = _grid_life;
        _gb.pop_in_duration = 10;
        _gb.spawn_delay = (abs(_gu - _grid_mid) + abs(_gw - _grid_mid)) * 2 + (f mod 2);
        _gb.grid_scale = _k_cube_grid_scale;
        _gb.grid_fade_start = _k_cube_t_surface_grid_preview;
        _gb.grid_fade_full = _k_cube_t_surface_grid;
        _gb.grid_preview_alpha = _k_cube_grid_preview_alpha;
        _gb.grid_back_alpha = _k_cube_grid_back_alpha;
        _gb.grid_front_scale = _k_cube_grid_front_scale;
        _gb.grid_dim_scale = _k_cube_grid_dim_scale;
        _gb.hit_alpha_min = 0.30;
      }
    }
  }

  cube_core_flash = max(cube_core_flash, 0.85);
  cube_edge_surge = max(cube_edge_surge, 0.75);
  cube_strobe = max(cube_strobe, 0.4);
  bloom_pulse = max(bloom_pulse, 0.55);
  scr_impact_pulse(0.22, 2.8, 0.55, cube_center_x, cube_center_y);
}

for (var i = 0; i < array_length(cube_shoot_timestamps); i++) {
  if (timeline_hit(cube_shoot_timestamps[i])) {
    var _shot_p = (array_length(cube_shoot_timestamps) > 1)
                ? (i / (array_length(cube_shoot_timestamps) - 1)) : 1;
    var _shot_pow = 0.55 + _shot_p * 0.75;

    var _face_candidates = array_create(6);
    for (var f = 0; f < 6; f++) _face_candidates[f] = [];

    with(oCube) {
      var _edge_verts = oAvoidanceController.cube_edges[edge_index];
      var _face_info = scr_get_edge_face_info(_edge_verts[0], _edge_verts[1]);

      for (var fi = 0; fi < array_length(_face_info); fi++) {
        var _info = _face_info[fi];
        array_push(_face_candidates[_info.face_index],
                   {inst : id, local_edge : _info.local_edge, reversed : _info.reversed, travel : travel});
      }
    }

    for (var f = 0; f < 6; f++) {
      var _list = _face_candidates[f];
      var _count = min(array_length(_list), oAvoidanceController.cube_max_bullets_per_face);

      for (var pick = 0; pick < _count; pick++) {
        var _remaining = array_length(_list) - pick;
        var _idx = pick + irandom(_remaining - 1);
        var _tmp = _list[pick];
        _list[pick] = _list[_idx];
        _list[_idx] = _tmp;

        var _chosen = _list[pick];

        if (cube_face_bullets_enabled) {
          var _coord = scr_edge_face_coord(_chosen.local_edge, _chosen.reversed, _chosen.travel);

          var _fb = instance_create_layer(_chosen.inst.x, _chosen.inst.y, layer, oCubeFaceBullet);
          _fb.face_index = f;
          _fb.along_axis = _coord.axis;
          _fb.along_value = _coord.value;
          _fb.fixed_axis = _coord.fixed_axis;
          _fb.fixed_start = _coord.fixed_value;
          _fb.heat = _shot_pow;
        }
      }

      if (_count > 0) {
        cube_face_flash[f] = max(cube_face_flash[f], _shot_pow);
        cube_face_heat[f] = min(1.4, cube_face_heat[f] + 0.28 * _shot_pow);

        if (array_length(cube_muzzles) < _k_cube_muzzle_max) {
          array_push(cube_muzzles, {
            face : f, life : 13, life_max : 13,
            hot : _shot_pow, spin : random(360)
          });
        }

        if (_shot_p > 0.35 && array_length(cube_cracks) < _k_cube_crack_max) {
          var _cu = random(1);
          var _cw = random(1);
          array_push(cube_cracks, {
            face : f,
            u1 : _cu, w1 : _cw,
            u2 : clamp(_cu + random_range(-0.7, 0.7), 0, 1),
            w2 : clamp(_cw + random_range(-0.7, 0.7), 0, 1),
            grow : 0, grow_speed : 0.09,
            life : 150, life_max : 150,
            hot : _shot_pow,
            off : scr_bolt_offsets(4, 5)
          });
        }
      }
    }

    if (array_length(big_cube_projected) >= 8) {
      var _bolts = 2 + round(_shot_p * 4);
      for (var _sbo = 0; _sbo < _bolts; _sbo++) {
        var _v1 = irandom(7);
        var _v2 = (_v1 + 1 + irandom(6)) mod 8;
        scr_slash_bolt(big_cube_projected[_v1].x, big_cube_projected[_v1].y,
                       big_cube_projected[_v2].x, big_cube_projected[_v2].y,
                       7, 14 + _shot_p * 14, 1.4 + _shot_p, 0.55 + _shot_p * 0.35);
      }

      for (var _vh = 0; _vh < 8; _vh++) {
        cube_vertex_heat[_vh] = max(cube_vertex_heat[_vh], _shot_pow);
      }
    }

    array_push(ring_shockwaves, {
      x : cube_center_x, y : cube_center_y,
      radius : cube_size_base * 0.55, max_radius : cube_size_base * (1.5 + _shot_p * 0.9),
      life : 20, max_life : 20, width : 14 + _shot_p * 14,
      hot : 0.6 + _shot_p * 0.4, vs : 1
    });

    if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
    array_push(slash_warps, {
      x : cube_center_x, y : cube_center_y,
      radius : cube_size_base * 0.5, max_radius : cube_size_base * 2.2,
      strength : 0.4 + _shot_p * 0.5, life : 18, life_max : 18
    });

    for (var _sp2 = 0; _sp2 < round(10 + _shot_p * 18); _sp2++) {
      var _spa2 = random(360);
      var _spd2 = cube_size_base * random_range(0.7, 1.0);
      var _spv = random_range(3, 9 + _shot_p * 6);
      array_push(arrow_ring_particles, {
        x : cube_center_x + lengthdir_x(_spd2, _spa2),
        y : cube_center_y + lengthdir_y(_spd2, _spa2),
        vx : lengthdir_x(_spv, _spa2), vy : lengthdir_y(_spv, _spa2),
        life : 18 + irandom(14), max_life : 32,
        size : random_range(0.08, 0.26), grav : 0.05, drag : 0.94,
        hot : 0.7 + _shot_p * 0.3
      });
    }

    cube_core_flash = max(cube_core_flash, (0.8 + _shot_p * 0.6) * 0.5);
    cube_edge_surge = max(cube_edge_surge, (0.9 + _shot_p * 0.5) * 0.5);
    cube_rot_surge = max(cube_rot_surge, (0.6 + _shot_p * 1.4) * 0.8);
    cube_strobe = max(cube_strobe, 0.35 + _shot_p * 0.4);
    cube_lock_flash = 0;

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_cube_salvo_shake * _shot_pow);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.025 + _shot_p * 0.045);
      oCameraController.angle_kick = ((i mod 2 == 0) ? 1 : -1) * (1.1 + _shot_p * 2.2);
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.12 + _shot_p * 0.22);
      if (i == 0) oCameraController.letterbox_target = 0;
    }

    scr_impact_pulse(0.2 + _shot_p * 0.35, 2.0 + _shot_p * 3.5, 0.35 + _shot_p * 0.6,
                     cube_center_x, cube_center_y);
    if (_shot_p > 0.6) tear_amount = max(tear_amount, 0.35 + _shot_p * 0.4);
  }
}

if (cube_phase == "overload") {
  var _op = clamp((t - _k_cube_t_overload) / (_k_cube_t_despawn - _k_cube_t_overload), 0, 1);
  cube_overload = _op;

  cube_strobe = max(cube_strobe, 0.4 + _op * 0.55);
  cube_edge_surge = max(cube_edge_surge, 0.3 + _op * 0.6);
  vignette_pulse = max(vignette_pulse, 0.35 + _op * 0.4);
  aberration_pulse = max(aberration_pulse, _op * 2.5);

  slash_lens_x = cube_center_x;
  slash_lens_y = cube_center_y;
  slash_lens_radius = lerp(_k_cube_lens_radius, _k_cube_lens_radius * 0.75, _op);
  slash_lens_strength = max(slash_lens_strength, _k_cube_lens_max * (0.5 + _op * 0.7));

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = _k_cube_letterbox_overload * _op;
    oCameraController.shake = max(oCameraController.shake, 1.5 + _op * 5);
  }

  if (array_length(cube_cracks) < _k_cube_crack_max && random(1) < 0.14 + _op * 0.4) {
    var _ocu = random(1);
    var _ocw = random(1);
    array_push(cube_cracks, {
      face : irandom(5),
      u1 : _ocu, w1 : _ocw,
      u2 : clamp(_ocu + random_range(-0.9, 0.9), 0, 1),
      w2 : clamp(_ocw + random_range(-0.9, 0.9), 0, 1),
      grow : 0, grow_speed : 0.06 + _op * 0.08,
      life : 90, life_max : 90,
      hot : 0.5 + _op * 0.5,
      off : scr_bolt_offsets(4, 6)
    });
    aberration_pulse = max(aberration_pulse, 1.2);
  }
}

for (var i = array_length(cube_echo_snapshots) - 1; i >= 0; i--) {
  cube_echo_snapshots[i].alpha -= 0.025;
  if (cube_echo_snapshots[i].alpha <= 0) array_delete(cube_echo_snapshots, i, 1);
}

var _cube_summon = timeline_hit(_k_cube_t_spawn);

if (!cube_active && !cube_despawn_active && !_cube_summon &&
    t > _k_cube_t_spawn && t < _k_cube_t_despawn) {
  _cube_summon = true;
}

if ((cube_active || cube_despawn_active) && (t < _k_cube_t_spawn || t > _k_cube_t_despawn + 120)) {
  cube_active = false;
  cube_spawn_active = false;
  cube_despawn_active = false;
  cube_face_grid_spawned = false;
  with(oCube) instance_destroy();
  with(oCubeFaceBullet) { instance_destroy(); }
  big_cube_projected = [];
  small_cube_projected = [];
  cube_arcs = [];
  cube_leaks = [];
  cube_edge_pulses = [];
  cube_cracks = [];
  cube_muzzles = [];
  cube_ignitions = [];
  cube_ghosts = [];
  cube_scars = [];
  cube_coil = 0;
  cube_overload = 0;
  slash_lens_strength = 0;
  if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0;
}

if (_cube_summon) {
  cube_seed_flash_timer = cube_seed_flash_duration;
  cube_rot_ease_timer = 0;
  hitstop_frames = 6;
  cube_active = true;
  cube_spawn_active = true;
  cube_spawn_timer = 0;
  cube_phase = "materialize";
  cube_beat_index = 0;
  cube_face_grid_spawned = false;
  cube_core_extend = 0;
  cube_ignite_flash = 1;
  cube_core_flash = 1.2;
  cube_strobe = 0.5;
  cube_heartbeat = 1;

  cube_angle_x = random(360);
  cube_angle_y = random(360);
  cube_core_angle_x = random(360);
  cube_core_angle_y = random(360);
  cube_rot_speed_x = choose(-1, 1) * random_range(0.3, 0.9) * 0.8;
  cube_rot_speed_y = choose(-1, 1) * random_range(0.3, 0.9) * 0.8;
  cube_rot_speed_x_normal = cube_rot_speed_x;
  cube_rot_speed_y_normal = cube_rot_speed_y;

  cube_arcs = [];
  cube_leaks = [];
  cube_edge_pulses = [];
  cube_cracks = [];
  cube_muzzles = [];
  cube_ghosts = [];
  cube_scars = [];
  cube_face_heat = array_create(6, 0);
  cube_face_flash = array_create(6, 0);
  cube_vertex_heat = array_create(8, 0);
  cube_vertex_ignited = array_create(8, false);

  cube_ignitions = [];
  var _ig_order = [0, 6, 3, 5, 1, 7, 2, 4];
  for (var _iq = 0; _iq < 8; _iq++) {
    array_push(cube_ignitions, {
      vert : _ig_order[_iq],
      delay : round(_iq * 3.2),
      life : 22, life_max : 22,
      fired : false
    });
  }

  var _seed_verts = scr_cube_get_vertices(cube_size_base);
  big_cube_projected = [];
  for (var i = 0; i < 8; i++) {
    var _sr = scr_rotate_vertex(_seed_verts[i], cube_angle_x, cube_angle_y);
    array_push(big_cube_projected, scr_project_vertex(_sr, cube_center_x, cube_center_y, cube_perspective_dist));
  }
  small_cube_projected = [];

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 26);
    oCameraController.screen_flash_alpha = 0.85;
    oCameraController.zoom_punch = 0.11;
    oCameraController.angle_kick = choose(-3.5, 3.5);
    oCameraController.letterbox_target = 0;
    oCameraController.cube_zoom_out_active = true;
    oCameraController.cube_zoom_out_timer = 0;
  }
  scr_impact_pulse(0.75, 6.0, 1.1, cube_center_x, cube_center_y);
  global_ripple_pulse = 1.0;
  tear_amount = max(tear_amount, 0.9);

  array_push(ring_shockwaves, {
    x : cube_center_x, y : cube_center_y, radius : 10, max_radius : 620,
    life : 44, max_life : 44, width : 40, hot : 1, vs : 1
  });
  if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
  array_push(slash_warps, {
    x : cube_center_x, y : cube_center_y, radius : 20, max_radius : 560,
    strength : 1.1, life : 26, life_max : 26
  });

  for (var _rs = 0; _rs < 26; _rs++) {
    array_push(ring_streaks, {
      cx : cube_center_x, cy : cube_center_y, vs : 1,
      ang : random(360), dist : random_range(6, 40), len : 50 + irandom(70),
      speed : 26, width : 2 + random(3), life : 16, max_life : 16, hot : 1
    });
  }

  for (var e = 0; e < array_length(cube_edges); e++) {
    for (var i = 0; i < cube_bullets_per_edge; i++) {
      var _b = instance_create_layer(cube_center_x, cube_center_y, layer, oCube);
      _b.cube_type = 0;
      _b.edge_index = e;
      _b.phase_offset = (i / cube_bullets_per_edge) * 2;
      _b.reverse_travel = (i mod 2 == 1);
    }
  }
}

if (timeline_hit(_k_cube_t_despawn)) {
  cube_despawn_active = true;
  cube_despawn_timer = 0;
  cube_shoot_phase_active = false;
  with(oCube) hit_active = false;
  with(oCubeFaceBullet) hit_active = false;
  cube_strobe = max(cube_strobe, 0.8);
  cube_core_flash = max(cube_core_flash, 1.2);
  hitstop_frames = 3;

  for (var _im = 0; _im < 40; _im++) {
    array_push(converge_motes, {
      cx : cube_center_x, cy : cube_center_y,
      ang : random(360),
      dist : cube_size_base * random_range(0.9, 1.6),
      dest : random_range(6, 40),
      speed : random_range(9, 18),
      size : random_range(0.14, 0.34),
      spin : random_range(-4, 4),
      hot : 0.6 + random(0.4),
      feed : "cube"
    });
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 12);
    oCameraController.angle_kick = choose(-2.5, 2.5);
  }
  scr_impact_pulse(0.5, 4.0, 0.7, cube_center_x, cube_center_y);
}

if (cube_phase == "after" && instance_exists(oCameraController)) {
  oCameraController.letterbox_target = 0;
}

if (t >= _k_vault_t_survey && t <= _k_vault_t_end) {
  if (is_undefined(vault)) scr_vault_begin();
  scr_vault_update();
} else if (!is_undefined(vault)) {
  scr_vault_clear();
}

if (t >= _k_riser_t_fall && t <= _k_riser_t_end) {
  if (is_undefined(riser)) scr_riser_begin();
  scr_riser_update();
} else if (!is_undefined(riser)) {
  scr_riser_clear();
}

if timeline_hit (5219) {
  instance_create_layer(0, 0, layer, oHoneycombController)
}


if (t >= _k_arc_rift_t - 8 && t <= _k_arc_window_end) {
  if (t >= _k_arc_waves[0] && t < _k_arc_fire_t) {
    arc_charge = clamp((t - _k_arc_waves[0]) / (_k_arc_fire_t - _k_arc_waves[0]), 0, 1);
  } else if (t >= _k_arc_fire_t) {
    arc_charge = max(0, arc_charge - 0.05);
  }

  if (t < _k_arc_fire_t) {
    arc_heartbeat_phase += lerp(0.05, 0.22, arc_charge);
    arc_heartbeat = power(max(0, sin(arc_heartbeat_phase)), 6) * lerp(0.2, 1, arc_charge);
  } else {
    arc_heartbeat = max(0, arc_heartbeat - 0.07);
  }

  if (t >= _k_arc_fire_t && t <= _k_orb_unwrap_end) {
    orb_heat = clamp((t - _k_arc_fire_t) / (_k_orb_unwrap_end - _k_arc_fire_t), 0, 1);
    orb_heartbeat_phase += lerp(0.07, 0.26, orb_heat);
    orb_heartbeat = power(max(0, sin(orb_heartbeat_phase)), 6) * lerp(0.25, 1, orb_heat);
  } else if (t > _k_orb_unwrap_end) {
    orb_heat = max(0, orb_heat - 0.02);
    orb_heartbeat = max(0, orb_heartbeat - 0.07);
  }

  if (t >= _k_arc_lock_t && t < _k_arc_fire_t) {
    arc_aim = clamp((t - _k_arc_lock_t) / (_k_arc_fire_t - _k_arc_lock_t), 0, 1);
  } else if (t >= _k_arc_fire_t) {
    arc_aim = max(0, arc_aim - 0.12);
  }

  arc_rift = max(0, arc_rift - 0.012);
  arc_wave_flash = max(0, arc_wave_flash - 0.045);
  arc_lock_flash = max(0, arc_lock_flash - 0.05);
  arc_fire_flash = max(0, arc_fire_flash - 0.035);
  orb_beat_flash = max(0, orb_beat_flash - 0.05);
  orb_ring_lock = max(0, orb_ring_lock - 0.045);
  orb_unwrap_flash = max(0, orb_unwrap_flash - 0.03);
  orb_final_burst = max(0, orb_final_burst - 0.022);

  if (arc_rift_built && arc_rift_open < 1) arc_rift_open = min(1, arc_rift_open + 0.075);

  for (var _awi = array_length(arc_welds) - 1; _awi >= 0; _awi--) {
    var _awd = arc_welds[_awi];
    _awd.life--;
    if (instance_exists(_awd.inst)) {
      _awd.x2 = _awd.inst.x + _awd.inst.arrow_vibe_x;
      _awd.y2 = _awd.inst.y + _awd.inst.arrow_vibe_y;
    }
    if (_awd.life <= 0) array_delete(arc_welds, _awi, 1);
  }

  for (var _asi = array_length(arc_stitch) - 1; _asi >= 0; _asi--) {
    var _ast = arc_stitch[_asi];
    _ast.life--;
    if (instance_exists(_ast.a)) {
      _ast.x1 = _ast.a.x + _ast.a.arrow_vibe_x;
      _ast.y1 = _ast.a.y + _ast.a.arrow_vibe_y;
    }
    if (instance_exists(_ast.b)) {
      _ast.x2 = _ast.b.x + _ast.b.arrow_vibe_x;
      _ast.y2 = _ast.b.y + _ast.b.arrow_vibe_y;
    }
    if (_ast.life <= 0) array_delete(arc_stitch, _asi, 1);
  }

  for (var _ami = array_length(arc_muzzles) - 1; _ami >= 0; _ami--) {
    arc_muzzles[_ami].life--;
    if (arc_muzzles[_ami].life <= 0) array_delete(arc_muzzles, _ami, 1);
  }

  var _arc_lock_p = (t >= _k_arc_lock_t)
                  ? clamp((t - _k_arc_lock_t) / max(1, _k_arc_fire_t - _k_arc_lock_t), 0, 1)
                  : 0;

  // --- blades -------------------------------------------------------------
  for (var _bi = array_length(arc_blades) - 1; _bi >= 0; _bi--) {
    var _b = arc_blades[_bi];
    _b.timer++;

    if (!_b.live && _b.timer < _b.delay) continue;
    _b.live = true;

    _b.forge = max(0, _b.forge - 0.045);

    var _sway = dsin(t * 1.9 + _b.sway_p) * _b.sway_a * (1 - _arc_lock_p);
    _b.x = _b.base_x + _sway;

    var _seam = arc_rift_y_at(_b.x);
    var _bob  = dsin(t * 2.6 + _b.sway_p * 1.3) * 2.4 * (1 - _arc_lock_p);
    _b.y = _seam + _b.hang + _bob;

    var _rest = _b.aim + dsin(t * 1.4 + _b.sway_p) * 6;
    _b.ang = lerp(_rest, _b.aim, _arc_lock_p);
    if (_arc_lock_p > 0) {
      _b.ang += random_range(-1, 1) * _arc_lock_p * 2;
    }

    if (_b.fired) {
      _b.fade = max(0, _b.fade - 0.10);
      if (_b.fade <= 0) array_delete(arc_blades, _bi, 1);
      continue;
    }

    scr_register_glow_point(_b.x, _b.y);

    if (!arc_ceiling_hit && instance_exists(oPlayer) && !oPlayer.dead) {
      if (point_distance(oPlayer.x, oPlayer.y, _b.x, _b.y) < _k_arc_blade_r) {
        player_register_hazard_hit();
      }
    }
  }

  // --- lances -------------------------------------------------------------
  var _arc_bot = arc_view_bottom();
  for (var _li2 = array_length(arc_lances) - 1; _li2 >= 0; _li2--) {
    var _ln = arc_lances[_li2];
    _ln.timer++;

    if (_ln.timer <= _k_arc_lance_live && !arc_volley_hit &&
        instance_exists(oPlayer) && !oPlayer.dead) {
      var _ux2 = lengthdir_x(1, _ln.dir);
      var _uy2 = lengthdir_y(1, _ln.dir);
      var _nx2 = lengthdir_x(1, _ln.dir - 90);
      var _ny2 = lengthdir_y(1, _ln.dir - 90);
      var _len2 = point_distance(_ln.x1, _ln.y1, _ln.x2, _ln.y2);

      var _bxs = [ oPlayer.bbox_left, oPlayer.bbox_right, oPlayer.bbox_right, oPlayer.bbox_left ];
      var _bys = [ oPlayer.bbox_top, oPlayer.bbox_top, oPlayer.bbox_bottom, oPlayer.bbox_bottom ];
      var _amin = 999999, _amax = -999999, _pmin = 999999, _pmax = -999999;

      for (var _c2 = 0; _c2 < 4; _c2++) {
        var _rx = _bxs[_c2] - _ln.x1;
        var _ry = _bys[_c2] - _ln.y1;
        var _along = _rx * _ux2 + _ry * _uy2;
        var _perp  = _rx * _nx2 + _ry * _ny2;
        _amin = min(_amin, _along); _amax = max(_amax, _along);
        _pmin = min(_pmin, _perp);  _pmax = max(_pmax, _perp);
      }

      if (!(_amax < 0 || _amin > _len2) &&
          !(_pmax < -_k_arc_lance_hit_half || _pmin > _k_arc_lance_hit_half)) {
        if (player_register_hazard_hit()) arc_volley_hit = true;
      }
    }

    if (_ln.timer >= _k_arc_lance_fade) array_delete(arc_lances, _li2, 1);
  }

  // --- shards / forge pops ------------------------------------------------
  for (var _si2 = array_length(arc_shards) - 1; _si2 >= 0; _si2--) {
    var _s = arc_shards[_si2];
    _s.x += _s.vx;
    _s.y += _s.vy;
    _s.vy += 0.34;
    _s.vx *= 0.98;
    _s.ang += _s.spin;
    _s.life--;
    if (_s.life <= 0 || _s.y > _arc_bot + 60) array_delete(arc_shards, _si2, 1);
  }

  for (var _fp = array_length(arc_forge_pops) - 1; _fp >= 0; _fp--) {
    arc_forge_pops[_fp].life--;
    if (arc_forge_pops[_fp].life <= 0) array_delete(arc_forge_pops, _fp, 1);
  }

  // --- the ceiling --------------------------------------------------------
  arc_ceiling_live = (t >= _k_arc_rift_t + 10 && t <= _k_arc_fire_t + 26);

  if (arc_ceiling_live && instance_exists(oPlayer) && !oPlayer.dead) {
    if (oPlayer.bbox_top <= arc_rift_y_at(oPlayer.x) + _k_arc_rift_kill_pad) {
      player_register_hazard_hit();
    }
  }

  if (t <= _k_arc_fire_t + 20 && (t mod 3) == 0) {
    var _vn = 1 + round(arc_charge * 2);
    for (var _v = 0; _v < _vn; _v++) {
      var _vx = random_range(_k_arc_left_x - 40, _k_arc_right_x + 40);
      scr_spawn_vent_stream(arc_vents, _vx, arc_rift_y_at(_vx) + random_range(0, 6),
                            270 + random_range(-26, 26),
                            0.35 + arc_charge * 0.65, _k_lwb_vent_cols, 64);
    }
  }
  scr_update_vent_streams(arc_vents);

  arc_fire_ripple = max(0, arc_fire_ripple - 0.045);
  arc_tear_spike  = max(0, arc_tear_spike - 0.25);

  for (var _oli = array_length(orb_leaks) - 1; _oli >= 0; _oli--) {
    orb_leaks[_oli].life--;
    if (orb_leaks[_oli].life <= 0 || !instance_exists(orb_leaks[_oli].inst)) {
      array_delete(orb_leaks, _oli, 1);
    }
  }

  for (var _ogi = array_length(orb_ghosts) - 1; _ogi >= 0; _ogi--) {
    orb_ghosts[_ogi].alpha -= 0.014;
    if (orb_ghosts[_ogi].alpha <= 0) array_delete(orb_ghosts, _ogi, 1);
  }

  for (var _uti = array_length(orb_unwrap_tracks) - 1; _uti >= 0; _uti--) {
    orb_unwrap_tracks[_uti].life--;
    if (orb_unwrap_tracks[_uti].life <= 0) array_delete(orb_unwrap_tracks, _uti, 1);
  }
  for (var _uri = array_length(orb_unwrap_residue) - 1; _uri >= 0; _uri--) {
    orb_unwrap_residue[_uri].life--;
    if (orb_unwrap_residue[_uri].life <= 0) array_delete(orb_unwrap_residue, _uri, 1);
  }
  orb_unwrap_sink_charge = max(0, orb_unwrap_sink_charge - 0.026);
  orb_unwrap_recoil      = max(0, orb_unwrap_recoil - 0.05);

  for (var _pli = array_length(orb_plates) - 1; _pli >= 0; _pli--) {
    var _pl = orb_plates[_pli];
    _pl.x += _pl.vx;
    _pl.y += _pl.vy;
    _pl.vx *= 0.976;
    _pl.vy = _pl.vy * 0.976 + 0.13;
    _pl.ang += _pl.spin;
    _pl.spin *= 0.986;
    _pl.life--;
    if (_pl.life <= 0) array_delete(orb_plates, _pli, 1);
  }

  for (var _sci = array_length(orb_scars) - 1; _sci >= 0; _sci--) {
    orb_scars[_sci].life--;
    if (orb_scars[_sci].life <= 0) array_delete(orb_scars, _sci, 1);
  }

  for (var _bri = array_length(orb_bridges) - 1; _bri >= 0; _bri--) {
    var _brg = orb_bridges[_bri];
    _brg.life--;
    if (instance_exists(_brg.a) && instance_exists(_brg.b)) {
      _brg.ax = _brg.a.x; _brg.ay = _brg.a.y;
      _brg.bx = _brg.b.x; _brg.by = _brg.b.y;
    }
    if (_brg.life <= 0) {
      if (array_length(orb_scars) < _k_orb_scar_max) {
        array_push(orb_scars, {
          kind : 2,
          x : (_brg.ax + _brg.bx) * 0.5, y : (_brg.ay + _brg.by) * 0.5,
          ang : point_direction(_brg.ax, _brg.ay, _brg.bx, _brg.by),
          len : point_distance(_brg.ax, _brg.ay, _brg.bx, _brg.by) * 0.5,
          life : 7, life_max : 7, hot : 1, aspect : 1,
          col : global.avoid_col_hot, pts : []
        });
      }
      array_delete(orb_bridges, _bri, 1);
    }
  }

  for (var _sai = 0; _sai < array_length(_k_orb_split_beats); _sai++) {
    var _arm_t = _k_orb_split_beats[_sai] - _k_orb_split_lead;
    if (timeline_hit(_arm_t)) orb_split_axis[_sai] = random(360);
    if (t >= _arm_t && t < _k_orb_split_beats[_sai]) {
      var _seam_p = clamp((t - _arm_t) / _k_orb_split_lead, 0, 1);
      var _seam_v = 0.18 + power(_seam_p, 1.45) * 0.82;
      var _seam_a = orb_split_axis[_sai];
      var _seam_o = power(_seam_p, 2.6) * 0.34;
      with (oBigRedOrb) {
        if (released) continue;
        seam_ang = _seam_a;
        seam_charge = max(seam_charge, _seam_v);
        shell_open = max(shell_open, _seam_o);
      }
      break;
    }
  }

  for (var _rli = 0; _rli < array_length(orb_rails); _rli++) {
    var _rl = orb_rails[_rli];
    if (!is_struct(_rl)) continue;
    _rl.angle += _rl.speed * _rl.dir;
    _rl.arm   = min(1, _rl.arm + 0.085);
    _rl.build = max(0, _rl.build - 0.055);
    for (var _ski = 0; _ski < array_length(_rl.sockets); _ski++) {
      var _sk = _rl.sockets[_ski];
      _sk.flash = max(0, _sk.flash - 0.05);
      if (_sk.state == 1)      _sk.fill = min(1, _sk.fill + 0.13);
      else if (_sk.state == 2) _sk.fill = max(0, _sk.fill - 0.09);
    }
  }

  orb_latch    = max(0, orb_latch - 0.010);
  orb_hub_grow = max(0, orb_hub_grow - 0.045);
  orb_feed     = max(0, orb_feed - 0.035);

  if (t > _k_orb_unwrap_end) orb_power = max(0, orb_power - 0.038);

  if (t >= _k_arc_waves[0] && t < _k_arc_fire_t && array_length(arc_blades) > 1) {
    var _stitch_gap = round(lerp(16, 4, arc_charge));
    if ((t mod _stitch_gap) == 0 && array_length(arc_stitch) < _k_arc_stitch_max) {
      var _sn = array_length(arc_blades);
      var _s0 = irandom(_sn - 2);
      var _sa = arc_blades[_s0];
      var _sb = arc_blades[_s0 + 1];
      if (_sa.live && _sb.live && !_sa.fired && !_sb.fired) {
        array_push(arc_stitch, {
          a : noone, b : noone,
          x1 : _sa.x, y1 : _sa.y, x2 : _sb.x, y2 : _sb.y,
          life : 7 + irandom(5), life_max : 12,
          off : scr_bolt_offsets(4, 6 + arc_charge * 14),
          width : 0.8 + arc_charge * 1.4
        });
      }
    }
  }

  if (t >= _k_arc_rift_t && t <= _k_orb_unwrap_end) {
    var _arc_pressure = max(arc_charge * 0.9 + arc_heartbeat * 0.4, orb_heat * 0.7 + orb_heartbeat * 0.4);
    vignette_pulse   = max(vignette_pulse, 0.14 + _arc_pressure * 0.42 + arc_fire_flash * 0.35);
    bloom_pulse      = max(bloom_pulse, arc_heartbeat * 0.4 + orb_heartbeat * 0.18 + arc_rift * 0.25);
    aberration_pulse = max(aberration_pulse, arc_aim * 0.7 + arc_fire_flash * 0.62
                                             + orb_beat_flash * orb_beat_flash * 0.85);
    global_ripple_pulse = max(global_ripple_pulse, arc_heartbeat * 0.1 + orb_heartbeat * 0.12 + arc_fire_flash * 0.28);

    tear_amount = max(tear_amount, arc_tear_spike * 0.2 + orb_final_burst * 0.8);

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake,
                                    arc_heartbeat * 3 + orb_heartbeat * 3 + arc_aim * 4);
    }

    floor_charge_target = max(floor_charge_target, 0.25 + _arc_pressure * 0.6);
  }
}

if (timeline_hit(_k_arc_rift_t)) {
  with (oRedArrowArc) instance_destroy();
  with (oRedLaser) instance_destroy();
  arrow_arc_orbs = [];
  arrow_arc_lasers = [];
  arrow_arc_wave_index = 0;
  arrow_arc_from_left = true;
  arc_welds = [];
  arc_stitch = [];
  arc_muzzles = [];

  arc_build_formation();
  arc_ceiling_live = false;
  arc_fire_ripple = 0;

  with (oBigRedOrb) instance_destroy();
  big_orb_instance = -4;
  big_orb_regions = [];
  big_orb_rings = [];
  big_orb_unwrap_index = 0;
  orb_leaks = [];
  orb_ghosts = [];
  orb_unwrap_tracks = [];
  orb_unwrap_residue = [];
  orb_unwrap_sink_charge = 0;
  orb_unwrap_recoil = 0;
  orb_beat_index = 0;
  orb_split_index = 0;
  orb_ring_index = 0;
  orb_plates = [];
  orb_scars = [];
  orb_bridges = [];
  orb_rails = [];
  orb_hub = 0;
  orb_hub_grow = 0;
  orb_latch = 0;
  orb_assembly_r = 0;
  orb_feed = 0;
  orb_power = 1;

  arc_rift_pts = [];
  for (var _rp = 0; _rp <= _k_arc_rift_segments; _rp++) {
    var _rlt = _rp / _k_arc_rift_segments;
    var _rx = lerp(-180, _k_arc_right_x + 180, _rlt);
    var _rcurve = dsin(clamp((_rx - _k_arc_left_x) / (_k_arc_right_x - _k_arc_left_x), 0, 1) * 180);
    array_push(arc_rift_pts, {
      x : _rx,
      y : lerp(_k_arc_top_y, _k_arc_bottom_y, _rcurve) - _k_arc_rift_lift + random_range(-7, 7),
      jag : random_range(-9, 9)
    });
  }
  arc_rift_built = true;
  arc_rift = 1;
  arc_rift_open = 0;

  for (var _re = 0; _re < 14; _re++) {
    var _rlt2 = random(1);
    var _rex = lerp(_k_arc_left_x, _k_arc_right_x, _rlt2);
    var _rey = lerp(_k_arc_top_y, _k_arc_bottom_y, dsin(_rlt2 * 180)) - _k_arc_rift_lift;
    array_push(ring_embers, {
      x : _rex, y : _rey,
      vx : random_range(-0.6, 0.6), vy : random_range(0.2, 1.2),
      life : 40 + irandom(40), max_life : 80,
      size : random_range(0.05, 0.12),
      hot : random_range(0.35, 0.8)
    });
  }

  scr_impact_pulse(0.24, 0.5, 0.3, room_width / 2, _k_arc_bottom_y);
  scr_add_light(room_width / 2, _k_arc_bottom_y - _k_arc_rift_lift, _k_arc_color, 6);

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0.12;
  }
}

var _arc_wave = -1;
for (var _awv = 0; _awv < array_length(_k_arc_waves); _awv++) {
  if (timeline_hit(_k_arc_waves[_awv])) { _arc_wave = _awv; break; }
}

if (_arc_wave >= 0) {
  if (!arc_rift_built) {
    arc_rift_pts = [];
    for (var _rp2 = 0; _rp2 <= _k_arc_rift_segments; _rp2++) {
      var _rlt3 = _rp2 / _k_arc_rift_segments;
      var _rx2 = lerp(-180, _k_arc_right_x + 180, _rlt3);
      var _rcurve2 = dsin(clamp((_rx2 - _k_arc_left_x) / (_k_arc_right_x - _k_arc_left_x), 0, 1) * 180);
      array_push(arc_rift_pts, {
        x : _rx2,
        y : lerp(_k_arc_top_y, _k_arc_bottom_y, _rcurve2) - _k_arc_rift_lift + random_range(-7, 7),
        jag : random_range(-9, 9)
      });
    }
    arc_rift_built = true;
    arc_rift_open = 1;
  }

  // --- forge this wave's blades ---------------------------------------------------
  var _wave_blades = [];

  var _wave_shift = random_range(-95, 95);

  for (var _pi = 0; _pi < _k_arc_count; _pi++) {
    var _lt = (_k_arc_count > 1) ? (_pi / (_k_arc_count - 1)) : 0.5;
    var _bx0 = lerp(_k_arc_left_x + 40, _k_arc_right_x - 40, _lt) + _wave_shift
             + random_range(-_k_arc_jitter_x, _k_arc_jitter_x);
    _bx0 = clamp(_bx0, _k_arc_left_x + 24, _k_arc_right_x - 24);
    var _hang0 = random_range(_k_arc_hang_min, _k_arc_hang_max);
    var _seam0 = arc_rift_y_at(_bx0);

    var _rev_i = arc_reveal_flip ? _pi : (_k_arc_count - 1 - _pi);

    var _bl = {
      base_x : _bx0,
      hang   : _hang0,
      sway_p : random(360),
      sway_a : random_range(1.5, 4.5),
      seed   : random(1000),
      wave   : _arc_wave,
      delay  : _rev_i * 3,
      timer  : 0,
      forge  : 1,
      live   : false,
      fired  : false,
      fade   : 1,
      aim    : arc_roll_aim(_bx0, _seam0 + _hang0, _arc_wave),
      ang    : 270,
      x      : _bx0,
      y      : _seam0
    };
    _bl.ang = _bl.aim;
    array_push(arc_blades, _bl);
    array_push(_wave_blades, _bl);

    array_push(arc_forge_pops, {
      x : _bx0, y : _seam0,
      life : 14, life_max : 14,
      hot : 0.6 + _arc_wave * 0.1
    });

    for (var _sp = 0; _sp < _k_arc_wave_sparks[_arc_wave]; _sp++) {
      var _spa = 270 + random_range(-95, 95);
      var _sps = random_range(1.5, 4 + _arc_wave * 1.4);
      array_push(arrow_ring_particles, {
        x : _bx0 + random_range(-8, 8), y : _seam0,
        vx : lengthdir_x(_sps, _spa), vy : lengthdir_y(_sps, _spa),
        life : 12 + irandom(16), max_life : 28,
        size : random_range(0.05, 0.1 + _arc_wave * 0.03),
        grav : 0.12, drag : 0.94, hot : random_range(0.5, 1)
      });
    }

    for (var _em = 0; _em < _k_arc_wave_embers[_arc_wave]; _em++) {
      array_push(ring_embers, {
        x : _bx0 + random_range(-14, 14), y : _seam0 + random_range(0, 6),
        vx : random_range(-0.7, 0.7), vy : random_range(0.3, 1.5),
        life : 45 + irandom(45), max_life : 90,
        size : random_range(0.05, 0.13),
        hot : random_range(0.4, 0.9)
      });
    }
  }

  for (var _wi = 0; _wi < array_length(_wave_blades); _wi++) {
    if (array_length(arc_stitch) >= _k_arc_stitch_max) break;
    var _wb0 = _wave_blades[_wi];
    array_push(arc_stitch, {
      a : noone, b : noone,
      x1 : _wb0.x, y1 : arc_rift_y_at(_wb0.x),
      x2 : _wb0.x, y2 : _wb0.y,
      life : 10 + irandom(6), life_max : 16,
      off : scr_bolt_offsets(4, 6 + _arc_wave * 4),
      width : 0.9 + _arc_wave * 0.3
    });
  }

  arc_rift = max(arc_rift, 0.7 + _arc_wave * 0.07);
  arc_rift_open = 1;
  arc_wave_flash = max(arc_wave_flash, _k_arc_wave_flash[_arc_wave] * 2.4);

  array_push(ring_shockwaves, {
    x : room_width / 2, y : _k_arc_bottom_y,
    radius : 20, max_radius : 300 + _arc_wave * 130,
    life : 20 + _arc_wave * 3, max_life : 20 + _arc_wave * 3,
    width : 12 + _arc_wave * 7, hot : 0.4 + _arc_wave * 0.12, vs : 0.34
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_arc_wave_shake[_arc_wave]);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_arc_wave_zoom[_arc_wave]);
    oCameraController.angle_kick += _k_arc_wave_tilt[_arc_wave];
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                               _k_arc_wave_flash[_arc_wave]);
    oCameraController.letterbox_target = max(oCameraController.letterbox_target,
                                             0.14 + _arc_wave * 0.075);
  }

  scr_impact_pulse(0.16 + _arc_wave * 0.06, _arc_wave * 0.18, 0.35 + _arc_wave * 0.14,
                   room_width / 2, _k_arc_bottom_y);
  scr_add_light(room_width / 2, _k_arc_bottom_y - _k_arc_rift_lift, _k_arc_color, 5 + _arc_wave);

  arc_reveal_flip = !arc_reveal_flip;
  arrow_arc_from_left = !arrow_arc_from_left;
  arrow_arc_wave_index++;
}

if (timeline_hit(_k_arc_lock_t)) {
  for (var _li = 0; _li < array_length(arc_blades); _li++) {
    var _lb = arc_blades[_li];
    if (!_lb.live) continue;
    _lb.forge = max(_lb.forge, 0.55);
    array_push(arc_forge_pops, { x : _lb.x, y : _lb.y, life : 10, life_max : 10, hot : 0.9 });
  }

  arc_lock_flash = 1;

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 6);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05);
    oCameraController.letterbox_target = 0.8;
  }

  scr_impact_pulse(0.3, 0.8, 0.4, room_width / 2, _k_arc_bottom_y);
}

if (timeline_hit(_k_arc_fire_t)) {
  var _cam_bottom = arc_view_bottom();
  var _floor_cracks = 0;
  arc_volley_hit = false;

  for (var _mi = 0; _mi < array_length(arc_blades); _mi++) {
    var _ma = arc_blades[_mi];
    if (!_ma.live) continue;

    var _aim = _ma.aim;
    var _back = (_ma.y - arc_rift_y_at(_ma.x)) / max(0.15, -dsin(_aim));
    var _ox = _ma.x - lengthdir_x(_back, _aim);
    var _oy = _ma.y - lengthdir_y(_back, _aim);
    var _reach = _k_arc_beam_len;

    array_push(arc_lances, {
      x1    : _ox,
      y1    : _oy,
      x2    : _ox + lengthdir_x(_reach, _aim),
      y2    : _oy + lengthdir_y(_reach, _aim),
      dir   : _aim,
      timer : 0,
      seed  : _ma.seed
    });

    var _lx = _ma.x;
    if (_mi mod 3 == 0) scr_laser_muzzle_burst(_ox, _oy, _aim, 1.2);

    if (array_length(arc_muzzles) < _k_arc_weld_max) {
      array_push(arc_muzzles, {
        x : _ox, y : _oy, dir : _aim,
        life : 12, life_max : 12, hot : 1
      });
    }

    _ma.fired = true;
    _ma.fade  = 1;
    for (var _sh = 0; _sh < 5; _sh++) {
      array_push(arc_shards, {
        x : _lx + random_range(-6, 6), y : _ma.y,
        vx : random_range(-3.2, 3.2), vy : random_range(1.5, 7),
        ang : random(360), spin : random_range(-14, 14),
        life : 18 + irandom(16), life_max : 34,
        scale : random_range(0.28, 0.62),
        col : choose(global.avoid_col_cyan, global.avoid_col_warning, global.avoid_col_violet)
      });
    }

    var _fall = (_cam_bottom - _oy) / max(0.15, -dsin(_aim));
    var _impact_x = _ox + lengthdir_x(_fall, _aim);

    if (_floor_cracks < 8 && _impact_x > arc_view_left() - 60 && _impact_x < arc_view_right() + 60) {
      scr_floor_impact(_impact_x, _cam_bottom, 0.95, 1, _k_arc_color);
      _floor_cracks++;

      for (var _sl = 0; _sl < 6; _sl++) {
        var _sla = choose(0, 180) + random_range(-26, 26);
        array_push(ring_splatter, {
          x : _impact_x + lengthdir_x(random_range(6, 70), _sla),
          y : _cam_bottom - random_range(0, 26),
          size : random_range(2, 8),
          drag_len : random_range(10, 40),
          drag_ang : _sla,
          alpha : random_range(0.6, 1),
          fade : random_range(0.004, 0.010),
          hot : 0.3 + random(0.4)
        });
      }
    }
  }

  arc_fire_ripple = 1;
  arc_tear_spike  = 1;
  arc_fire_flash = 1;
  arc_rift = max(arc_rift, 1);

  array_push(ring_shockwaves, {
    x : room_width / 2, y : _k_arc_bottom_y,
    radius : 24, max_radius : 700,
    life : 30, max_life : 30,
    width : 30, hot : 0.95, vs : 0.5
  });

  for (var _fs = 0; _fs < 40; _fs++) {
    array_push(ring_streaks, {
      cx : room_width / 2, cy : _k_arc_bottom_y, vs : 0.5,
      ang : random(360),
      dist : random_range(20, 120),
      len : random_range(70, 260),
      speed : random_range(12, 26),
      life : 12 + irandom(12), max_life : 24,
      width : random_range(1.2, 3.6),
      hot : random_range(0.6, 1)
    });
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 26);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.18);
    oCameraController.angle_kick += choose(-1, 1) * 3.4;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.62);
    oCameraController.letterbox_target = 0;
  }

  scr_impact_pulse(0.62, 0.8, 0.28, room_width / 2, room_height * 0.75);
  scr_bg_bass_hit();
  scr_add_light(room_width / 2, _k_arc_bottom_y, _k_arc_hot_color, 14);
}

var _orb_beat = -1;
for (var _obv = 0; _obv < array_length(_k_orb_beats); _obv++) {
  if (timeline_hit(_k_orb_beats[_obv])) { _orb_beat = _obv; break; }
}

if (_orb_beat >= 0) {
  var _top_y_min = 50;
  var _top_y_max = 250;

  orb_beat_index = _orb_beat;

  if (_orb_beat == 0 && !instance_exists(big_orb_instance)) {
    var _birth_x = room_width / 2;
    var _birth_y = _k_arc_bottom_y + 30;
    big_orb_instance = instance_create_layer(_birth_x, _birth_y, layer, oBigRedOrb);
    big_orb_instance.image_index = irandom(sprite_get_number(sRedOrb) - 1);
    big_orb_instance.birth_flash = 1;
    big_orb_instance.gather = 0;
    big_orb_instance.cell_gen = 0;
    big_orb_instance.cell_accent = global.avoid_col_cyan;

    orb_feed = 1;
    orb_next_x = _birth_x;
    orb_next_y = _birth_y;

    for (var _fd = 0; _fd < 8; _fd++) {
      if (array_length(arc_stitch) >= _k_arc_stitch_max) break;
      var _fdx = _birth_x + random_range(-190, 190);
      array_push(arc_stitch, {
        a : noone, b : noone,
        x1 : _fdx, y1 : arc_rift_y_at(_fdx),
        x2 : _birth_x + random_range(-16, 16), y2 : _birth_y + random_range(-14, 14),
        life : 16 + irandom(9), life_max : 25,
        off : scr_bolt_offsets(5, 16),
        width : 1.5 + random(1.2)
      });
    }

    scr_add_light(_birth_x, _birth_y, global.avoid_col_cyan, 8);
  }

  if (instance_exists(big_orb_instance)) {
    var _ob = big_orb_instance;

    _ob.pop_scale = 12 + _orb_beat * 1.6;
    _ob.pop_target = 3;
    _ob.beat_flash = 1;
    _ob.image_index = irandom(sprite_get_number(sRedOrb) - 1);

    // uniform 360-degree spray. Same count, same speeds, same coverage — random(360)
    for (var _oa = 0; _oa < _k_orb_beat_arrows[_orb_beat]; _oa++) {
      var _arrow = instance_create_layer(_ob.x, _ob.y, layer, oRedArrowBigOrb);
      var _adir2 = _ob.cell_spin + 30 + (_oa mod 6) * 60 + random_range(-17, 17);
      _arrow.direction = _adir2;
      _arrow.image_angle = _adir2;
      _arrow.speed = random_range(4, 9 + _orb_beat);
    }

    if (_orb_beat > 0) {
      var _dist = point_distance(_ob.x, _ob.y, orb_next_x, orb_next_y);
      var _dash_frames = _k_orb_beat_frames[_orb_beat];
      var _reach = (1 - power(0.85, _dash_frames)) / 0.15;
      _ob.dash_dir = point_direction(_ob.x, _ob.y, orb_next_x, orb_next_y);
      _ob.dash_time = _dash_frames;
      _ob.dash_speed = _dist / max(0.001, _reach);
      _ob.cell_spin_speed = choose(-1, 1) * random_range(0.5, 1.3);
    }

    var _next_beat = _orb_beat + 1;
    if (_next_beat < array_length(_k_orb_beats)) {
      var _lead_frames = _k_orb_beats[_next_beat] - _k_orb_beats[_orb_beat];
      orb_next_x = random_range(70, room_width - 70);
      orb_next_y = random_range(_top_y_min, _top_y_max);
      _ob.telegraph_x = orb_next_x;
      _ob.telegraph_y = orb_next_y;
      _ob.telegraph_timer = _lead_frames;
      _ob.telegraph_max = _lead_frames;
    } else {
      _ob.telegraph_timer = 0;
    }

    for (var _lk = 0; _lk < 3 + _orb_beat; _lk++) {
      if (array_length(orb_leaks) >= _k_orb_leak_max) array_delete(orb_leaks, 0, 1);
      array_push(orb_leaks, {
        inst : _ob,
        ang : random(360),
        reach : random_range(40, 90 + _orb_beat * 14),
        life : 8 + irandom(7), life_max : 15,
        off : scr_bolt_offsets(4, 9 + _orb_beat * 2),
        width : 1 + _orb_beat * 0.2
      });
    }

    array_push(ring_shockwaves, {
      x : _ob.x, y : _ob.y,
      radius : 14, max_radius : 170 + _orb_beat * 34,
      life : 20, max_life : 20,
      width : 14 + _orb_beat * 3, hot : 0.55 + _orb_beat * 0.05, vs : 1
    });

    for (var _os = 0; _os < _k_orb_beat_streaks[_orb_beat]; _os++) {
      array_push(ring_streaks, {
        cx : _ob.x, cy : _ob.y, vs : 1,
        ang : _ob.cell_spin + 30 + (_os mod 6) * 60 + random_range(-13, 13),
        dist : random_range(10, 40),
        len : random_range(30, 90 + _orb_beat * 14),
        speed : random_range(8, 16 + _orb_beat * 2),
        life : 10 + irandom(10), max_life : 20,
        width : random_range(0.8, 2.2),
        hot : random_range(0.35, 1)
      });
    }

    orb_beat_flash = 1;

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_orb_beat_shake[_orb_beat]);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_orb_beat_zoom[_orb_beat]);
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                                 _k_orb_beat_flash[_orb_beat]);
    }

    scr_impact_pulse(0.22 + _orb_beat * 0.045, 0.3 + _orb_beat * 0.14,
                     0.11 + _orb_beat * 0.028, _ob.x, room_height);
    scr_add_light(_ob.x, _ob.y, _k_arc_color, 4 + _orb_beat * 0.8);
  }
}

var _orb_split = -1;
for (var _osv = 0; _osv < array_length(_k_orb_split_beats); _osv++) {
  if (timeline_hit(_k_orb_split_beats[_osv])) { _orb_split = _osv; break; }
}

if (_orb_split >= 0) {
  var _region_left = 40;
  var _region_right = room_width - 40;
  var _region_top = 40;
  var _region_bottom = room_height / 2;
  var _split_amount = 2;

  orb_split_index = _orb_split;

  if (array_length(big_orb_regions) == 0 && instance_exists(big_orb_instance)) {
    big_orb_regions = [ {inst : big_orb_instance, scale : 1, arrow_count : 20} ];
  }

  var _split_fx_budget = 8;

  var _new_orbs = [];
  for (var _pi2 = 0; _pi2 < array_length(big_orb_regions); _pi2++) {
    var _parent = big_orb_regions[_pi2];
    if (!instance_exists(_parent.inst)) continue;

    var _px2 = _parent.inst.x;
    var _py2 = _parent.inst.y;
    var _new_scale = _parent.scale * 0.7;
    var _new_arrow_count = max(2, floor(_parent.arrow_count / 2));

    var _tear_axis = orb_split_axis[_orb_split] + random_range(-7, 7);
    var _style = _k_orb_split_style[_orb_split];
    var _pair = [];

    for (var _side = 0; _side < _split_amount; _side++) {
      var _throw_dir = _tear_axis + (_side * 180) + random_range(-22, 22);

      var _new_inst = instance_create_layer(_px2, _py2, layer, oBigRedOrb);
      _new_inst.image_xscale = _new_scale;
      _new_inst.image_yscale = _new_scale;
      _new_inst.base_scale = _new_scale;
      _new_inst.pop_scale = 14 * _new_scale;
      _new_inst.pop_target = 6 * _new_scale;
      _new_inst.beat_flash = 1;
      _new_inst.birth_flash = 1;
      _new_inst.image_index = irandom(sprite_get_number(sRedOrb) - 1);

      _new_inst.cell_gen        = _orb_split + 1;
      _new_inst.gather          = 0.28;
      _new_inst.seam_ang        = _tear_axis;
      _new_inst.seam_charge     = 0.35;
      _new_inst.shell_open      = 0.38;
      _new_inst.cell_spin       = _tear_axis + random_range(-30, 30);
      _new_inst.cell_spin_speed = choose(-1, 1) * random_range(0.5, 1.7);
      _new_inst.cell_accent = (_style.violet && _side == 0)
                            ? global.avoid_col_violet : global.avoid_col_cyan;

      var _throw_dist = random_range(70, 175) * (1 + _orb_split * 0.1);
      var _tx2 = clamp(_px2 + lengthdir_x(_throw_dist, _throw_dir), _region_left, _region_right);
      var _ty2 = clamp(_py2 + lengthdir_y(_throw_dist, _throw_dir), _region_top, _region_bottom);
      if (_orb_split >= 4) {
        _tx2 = lerp(_tx2, _k_orb_rail_cx, 0.22);
        _ty2 = lerp(_ty2, _k_orb_rail_cy, 0.22);
      }
      var _tdist = point_distance(_px2, _py2, _tx2, _ty2);
      var _tframes = 12;

      _new_inst.telegraph_x = _tx2;
      _new_inst.telegraph_y = _ty2;
      _new_inst.telegraph_timer = 0;
      _new_inst.dash_dir = point_direction(_px2, _py2, _tx2, _ty2);
      _new_inst.dash_time = _tframes;
      _new_inst.dash_speed = _tdist / ((1 - power(0.85, _tframes)) / 0.15);

      array_push(_pair, _new_inst);
      array_push(_new_orbs, {inst : _new_inst, scale : _new_scale, arrow_count : _new_arrow_count});
    }

    if (array_length(_pair) == 2 && array_length(orb_bridges) < _k_orb_bridge_max) {
      array_push(orb_bridges, {
        a : _pair[0], b : _pair[1],
        ax : _px2, ay : _py2, bx : _px2, by : _py2,
        life : _style.hold, life_max : _style.hold,
        off : scr_bolt_offsets(5, 8 + _orb_split * 2),
        width : _style.bridge,
        hot : 0.85
      });
    }

    if (_split_fx_budget > 0) {
    _split_fx_budget--;

    var _pr2 = 9 * abs(_parent.inst.image_xscale);

    for (var _dp = 0; _dp < _style.debris; _dp++) {
      if (array_length(orb_plates) >= _k_orb_plate_max) break;
      var _dang = _tear_axis + ((_dp mod 2 == 0) ? 0 : 180) + random_range(-36, 36);
      var _dspd = random_range(2.3, 5.0 + _orb_split * 0.45);
      array_push(orb_plates, {
        x : _px2 + lengthdir_x(_pr2 * 0.7, _dang),
        y : _py2 + lengthdir_y(_pr2 * 0.7, _dang),
        vx : lengthdir_x(_dspd, _dang), vy : lengthdir_y(_dspd, _dang),
        ang : _dang + random_range(-45, 45),
        spin : random_range(-9, 9),
        len : _pr2 * random_range(0.34, 0.66),
        w   : _pr2 * random_range(0.10, 0.20),
        life : 26 + irandom(20), life_max : 46,
        hot : random_range(0.3, 1),
        col : (_style.violet && irandom(5) == 0)
              ? global.avoid_col_violet : global.avoid_col_armor_edge
      });
    }

    for (var _sc2 = 0; _sc2 < _style.scar; _sc2++) {
      if (array_length(orb_scars) >= _k_orb_scar_max) break;
      var _scpts = [];
      for (var _sp2 = 0; _sp2 <= 5; _sp2++) array_push(_scpts, random_range(-1, 1));
      array_push(orb_scars, {
        kind : 0,
        x : _px2 + random_range(-14, 14), y : _py2 + random_range(-12, 12),
        ang : _tear_axis + random_range(-14, 14),
        len : _pr2 * random_range(1.6, 3.4),
        life : 30 + irandom(26), life_max : 56,
        hot : 0.5 + random(0.5), aspect : 1,
        col : global.avoid_col_warning, pts : _scpts
      });
    }

    if (array_length(orb_scars) < _k_orb_scar_max) {
      array_push(orb_scars, {
        kind : 1,
        x : _px2, y : _py2, ang : _tear_axis,
        len : 100 + _orb_split * 24,
        life : 18, life_max : 18,
        hot : 0.75, aspect : _style.aspect,
        col : global.avoid_col_danger, pts : []
      });
    }

    for (var _vt = 0; _vt < _style.vent; _vt++) {
      scr_spawn_vent_stream(arc_vents, _px2, _py2,
                            _tear_axis + 90 + choose(0, 180) + random_range(-28, 28),
                            0.5 + _orb_split * 0.07, _k_lwb_vent_cols, 110);
    }

    if (_style.scar >= 3) {
      for (var _em2 = 0; _em2 < 6; _em2++) {
        array_push(ring_embers, {
          x : _px2 + random_range(-18, 18), y : _py2 + random_range(-14, 14),
          vx : random_range(-1.1, 1.1), vy : random_range(-0.4, 1.4),
          life : 45 + irandom(45), max_life : 90,
          size : random_range(0.05, 0.13),
          hot : random_range(0.45, 1)
        });
      }
    }
    }

    instance_destroy(_parent.inst);
  }
  big_orb_regions = _new_orbs;

  for (var _oi2 = 0; _oi2 < array_length(big_orb_regions); _oi2++) {
    var _o = big_orb_regions[_oi2];
    if (!instance_exists(_o.inst)) continue;

    var _k_arrow_count_mult = 0.5;
    var _spawn_count = max(1, floor(_o.arrow_count * _k_arrow_count_mult));

    for (var _aa = 0; _aa < _spawn_count; _aa++) {
      var _arrow2 = instance_create_layer(_o.inst.x, _o.inst.y, layer, oRedArrowBigOrb);
      var _adir3 = random(360);
      _arrow2.direction = _adir3;
      _arrow2.image_angle = _adir3;
      _arrow2.speed = random_range(4, min(_k_orb_split_child_speed_cap, (8 + _orb_split * 0.6) * 0.8));
    }
  }

  orb_beat_flash = 1;

  var _cam_mult = (_orb_split == 3) ? 0.55 : 1;

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _k_orb_split_shake[_orb_split] * _cam_mult);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_orb_split_zoom[_orb_split] * _cam_mult);
    oCameraController.angle_kick += _k_orb_split_tilt[_orb_split] * _cam_mult;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                               _k_orb_split_flash[_orb_split] * _cam_mult);
  }

  scr_impact_pulse((0.24 + _orb_split * 0.05) * _cam_mult,
                   (0.40 + _orb_split * 0.09) * _cam_mult,
                   (0.16 + _orb_split * 0.045) * _cam_mult);
  scr_add_light(room_width / 2, room_height * 0.3, _k_arc_color, 6 + _orb_split);
}

for (var _rap = 0; _rap < 3; _rap++) {
  if (!timeline_hit(_k_orb_ring_beats[_rap * 2] - 12)) continue;

  var _live_r = [];
  for (var _lr = 0; _lr < array_length(big_orb_regions); _lr++) {
    if (instance_exists(big_orb_regions[_lr].inst)) array_push(_live_r, big_orb_regions[_lr]);
  }
  big_orb_regions = _live_r;

  var _tot_r  = array_length(big_orb_regions);
  var _rs_r   = floor(_tot_r * _k_orb_ring_share[_rap]);
  var _re_r   = (_rap == 2) ? _tot_r : floor(_tot_r * _k_orb_ring_share[_rap + 1]);
  var _size_r = max(1, _re_r - _rs_r);

  var _rad_r  = _k_orb_rail_radius[_rap];
  var _tilt_r = degtorad(random(360));
  var _dir_r  = choose(1, -1);
  var _spd_r  = random_range(1, 2.2);

  while (array_length(big_orb_rings) <= _rap) array_push(big_orb_rings, 0);
  big_orb_rings[_rap] = {
    radius : _rad_r, tilt_rad : _tilt_r, dir : _dir_r, speed : _spd_r, start_t : t
  };

  var _socks = [];
  for (var _sn = 0; _sn < _size_r; _sn++) {
    array_push(_socks, { slot : _sn, state : 0, fill : 0, flash : 0 });
  }

  while (array_length(orb_rails) <= _rap) array_push(orb_rails, 0);
  orb_rails[_rap] = {
    cx : _k_orb_rail_cx, cy : _k_orb_rail_cy,
    radius : _rad_r, tilt_rad : _tilt_r, vs : 0.4,
    dir : _dir_r, speed : _spd_r, angle : 0,
    sockets : _socks, total : _size_r,
    arm : 0, build : 1, locked : 0
  };
  orb_assembly_r = max(orb_assembly_r, _rad_r);

  scr_add_light(_k_orb_rail_cx, _k_orb_rail_cy, global.avoid_col_cyan, 4 + _rap);
}

var _orb_ring_beat = -1;
for (var _orv = 0; _orv < array_length(_k_orb_ring_beats); _orv++) {
  if (timeline_hit(_k_orb_ring_beats[_orv])) { _orb_ring_beat = _orv; break; }
}

if (_orb_ring_beat >= 0) {
  var _timestep_index = _orb_ring_beat;

  var _ring_count = 3;
  var _ring_index = floor(_timestep_index / 2);
  var _half_index = _timestep_index mod 2;

  orb_ring_index = _ring_index;

  var _live_orbs = [];
  for (var _lo = 0; _lo < array_length(big_orb_regions); _lo++) {
    if (instance_exists(big_orb_regions[_lo].inst)) {
      array_push(_live_orbs, big_orb_regions[_lo]);
    }
  }
  big_orb_regions = _live_orbs;

  var _total_orbs = array_length(big_orb_regions);
  var _ring_start = floor(_total_orbs * _k_orb_ring_share[_ring_index]);
  var _ring_end = (_ring_index == _ring_count - 1) ? _total_orbs
                : floor(_total_orbs * _k_orb_ring_share[_ring_index + 1]);
  var _ring_size = _ring_end - _ring_start;

  var _center_x = _k_orb_rail_cx;
  var _center_y = _k_orb_rail_cy;

  while (array_length(big_orb_rings) <= _ring_index) array_push(big_orb_rings, 0);
  if (!is_struct(big_orb_rings[_ring_index])) {
    big_orb_rings[_ring_index] = {
      radius : _k_orb_rail_radius[_ring_index],
      tilt_rad : degtorad(random(360)),
      dir : choose(1, -1),
      speed : random_range(1, 2.2),
      start_t : t
    };
  }
  var _ring = big_orb_rings[_ring_index];

  while (array_length(orb_rails) <= _ring_index) array_push(orb_rails, 0);
  if (!is_struct(orb_rails[_ring_index])) {
    var _socks2 = [];
    for (var _sn2 = 0; _sn2 < max(1, _ring_size); _sn2++) {
      array_push(_socks2, { slot : _sn2, state : 0, fill : 0, flash : 0 });
    }
    orb_rails[_ring_index] = {
      cx : _center_x, cy : _center_y,
      radius : _ring.radius, tilt_rad : _ring.tilt_rad, vs : 0.4,
      dir : _ring.dir, speed : _ring.speed,
      angle : _ring.speed * _ring.dir * (t - _ring.start_t),
      sockets : _socks2, total : max(1, _ring_size),
      arm : 1, build : 1, locked : 0
    };
    orb_assembly_r = max(orb_assembly_r, _ring.radius);
  }
  var _rail = orb_rails[_ring_index];
  _rail.build = 1;

  if (_ring_size > 0) {
    var _slot_start = (_half_index == 0) ? 0 : floor(_ring_size / 2);
    var _slot_end = (_half_index == 0) ? floor(_ring_size / 2) : _ring_size;

    for (var _si2 = _ring_start + _slot_start; _si2 < _ring_start + _slot_end; _si2++) {
      var _o2 = big_orb_regions[_si2];
      if (!instance_exists(_o2.inst)) continue;

      var _slot_num = _si2 - _ring_start;
      var _base_angle = (_slot_num / _ring_size) * 360;

      var _elapsed = t - _ring.start_t;
      var _rotation_offset = _ring.speed * _ring.dir * _elapsed;
      var _start_angle = _base_angle + _rotation_offset;

      var _half_span = max(1, _slot_end - _slot_start);
      var _stagger = ((_si2 - _ring_start - _slot_start) / _half_span) * 6;

      _o2.inst.transitioning = true;
      _o2.inst.trans_timer = -_stagger;
      _o2.inst.trans_duration = 12;
      _o2.inst.trans_start_x = _o2.inst.x;
      _o2.inst.trans_start_y = _o2.inst.y;
      _o2.inst.orbit_center_x = _center_x;
      _o2.inst.orbit_center_y = _center_y;
      _o2.inst.orbit_radius = _ring.radius;
      _o2.inst.orbit_tilt_rad = _ring.tilt_rad;
      _o2.inst.orbit_angle = _start_angle;
      _o2.inst.orbit_speed = _ring.speed;
      _o2.inst.orbit_dir = _ring.dir;
      _o2.inst.ring_id = _ring_index;
      _o2.inst.socket_slot = _slot_num;
      _o2.inst.lock_pulse = 1;
      _o2.inst.seam_charge = 0;
      _o2.inst.shell_open = 0;
      _o2.inst.gather = 1;

      _o2.inst.dash_time = 0;
      _o2.inst.telegraph_timer = 0;

      if (_slot_num < array_length(_rail.sockets)) {
        var _skk = _rail.sockets[_slot_num];
        _skk.state = 1;
        _skk.flash = 1;
      }
      _rail.locked = min(_rail.total, _rail.locked + 1);
    }
  }

  if (_rail.locked >= _rail.total && orb_hub < _ring_index + 1) {
    orb_hub = _ring_index + 1;
    orb_hub_grow = 1;
  }

  orb_ring_lock = 1;

  var _is_latch = (_timestep_index == array_length(_k_orb_ring_beats) - 1);
  if (_is_latch) {
    orb_latch = 1;
    with (oBigRedOrb) { lock_pulse = max(lock_pulse, 0.85); }
  } else {
    array_push(ring_shockwaves, {
      x : _center_x, y : _center_y,
      radius : max(8, _ring.radius * 0.55), max_radius : _ring.radius * 1.7,
      life : 16, max_life : 16,
      width : 8 + _ring_index * 3, hot : 0.6, vs : 0.4
    });
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake,
                                  _is_latch ? 15 : (6 + _timestep_index * 1.6));
    oCameraController.zoom_punch = max(oCameraController.zoom_punch,
                                       _is_latch ? 0.075 : (0.03 + _timestep_index * 0.009));
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha,
                                               _is_latch ? 0.30 : (0.14 + _timestep_index * 0.022));
    oCameraController.letterbox_target = 0.18 + _timestep_index * 0.09;
  }

  scr_impact_pulse(0.26 + _timestep_index * 0.045, 0.34 + _timestep_index * 0.1,
                   _is_latch ? 0.20 : 0.12, _center_x, _center_y);
  scr_add_light(_center_x, _center_y, _k_arc_hot_color, 6 + _timestep_index);
}

if (timeline_hit(_k_dna_despawn_t)) {
  dna_despawn_active = true;
  dna_despawn_start_t = t;
  dna_active = false;
  dna_fade_active = false;
}
if (dna_despawn_active) {
  var _progress = clamp((t - dna_despawn_start_t) / _k_dna_despawn_duration, 0, 1);
  var _eased = _progress * _progress * _progress;
  dna_despawn_sweep_y = lerp(_k_dna_despawn_sweep_start_y, _k_dna_despawn_sweep_end_y, _eased);

  if (_progress >= 1) dna_despawn_active = false;
}

if (t >= _k_orb_unwrap_start && t <= _k_orb_unwrap_end) {
  var _duration = _k_orb_unwrap_end - _k_orb_unwrap_start;

  var _total = array_length(big_orb_regions);
  var _uprogress = (t - _k_orb_unwrap_start) / _duration;
  var _target_released = ceil(_uprogress * _total);

  var _ucenter_x = room_width / 2;
  var _ucenter_y = 200;

  if (timeline_hit(_k_orb_unwrap_start) && instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0.85;
  }
  if (timeline_hit(_k_orb_unwrap_start)) {
    orb_unwrap_sink_charge = max(orb_unwrap_sink_charge, 0.72);
    orb_unwrap_recoil = max(orb_unwrap_recoil, 0.45);
  }

  while (big_orb_unwrap_index < _target_released && big_orb_unwrap_index < _total) {
    var _uo = big_orb_regions[big_orb_unwrap_index];
    if (instance_exists(_uo.inst)) {
      var _release_x = _uo.inst.x;
      var _release_y = _uo.inst.y;
      var _ox = (_uo.inst.orbit_radius > 0) ? _uo.inst.orbit_center_x : _ucenter_x;
      var _oy = (_uo.inst.orbit_radius > 0) ? _uo.inst.orbit_center_y : _ucenter_y;
      var _dir_out = (point_distance(_ox, _oy, _uo.inst.x, _uo.inst.y) > 1)
                     ? point_direction(_ox, _oy, _uo.inst.x, _uo.inst.y)
                     : random(360);

      if (array_length(orb_ghosts) >= _k_orb_ghost_max) array_delete(orb_ghosts, 0, 1);
      array_push(orb_ghosts, {
        x : _uo.inst.x, y : _uo.inst.y,
        scale : _uo.inst.image_xscale,
        ang : _dir_out,
        alpha : 0.85,
        hot : 0.6
      });

      var _rid = _uo.inst.ring_id;
      if (_rid >= 0 && _rid < array_length(orb_rails) && is_struct(orb_rails[_rid])) {
        var _rl2 = orb_rails[_rid];
        var _sl2 = _uo.inst.socket_slot;
        if (_sl2 >= 0 && _sl2 < array_length(_rl2.sockets)) {
          _rl2.sockets[_sl2].state = 2;
          _rl2.sockets[_sl2].flash = 1;
        }
        _rl2.locked = max(0, _rl2.locked - 1);
      }

      var _lean = 30 * _uo.inst.orbit_dir;
      var _tangent_dir = _dir_out + 90 * _uo.inst.orbit_dir;

      if (array_length(orb_unwrap_tracks) >= _k_orb_unwrap_track_max) array_delete(orb_unwrap_tracks, 0, 1);
      var _ut_dir = _dir_out + _lean;
      var _ut_sink_mix = power(clamp(_uprogress, 0, 1), 1.35);
      var _ut_reach = _k_orb_unwrap_track_len * random_range(0.78, 1.18);
      var _ut_tip_x = _release_x + lengthdir_x(_ut_reach, _ut_dir);
      var _ut_tip_y = _release_y + lengthdir_y(_ut_reach, _ut_dir);
      _ut_tip_x = lerp(_ut_tip_x, _k_mill_cx, 0.22 + _ut_sink_mix * 0.46);
      _ut_tip_y = lerp(_ut_tip_y, _k_mill_cy, 0.16 + _ut_sink_mix * 0.40);
      array_push(orb_unwrap_tracks, {
        x1 : _release_x, y1 : _release_y,
        x2 : _ut_tip_x,  y2 : _ut_tip_y,
        dir : _ut_dir,
        tangent : _tangent_dir,
        sink_x : _k_mill_cx,
        sink_y : _k_mill_cy,
        life : _k_orb_unwrap_track_life,
        life_max : _k_orb_unwrap_track_life,
        hot : random_range(0.55, 1),
        phase : random(360),
        sink : _ut_sink_mix,
        slot : _uo.inst.socket_slot,
        ring : _rid
      });

      if ((big_orb_unwrap_index mod 3) == 0 || _ut_sink_mix > 0.68) {
        if (array_length(orb_unwrap_residue) >= _k_orb_unwrap_residue_max) array_delete(orb_unwrap_residue, 0, 1);
        array_push(orb_unwrap_residue, {
          x1 : _release_x,
          y1 : _release_y,
          x2 : _ut_tip_x,
          y2 : _ut_tip_y,
          dir : _ut_dir,
          life : _k_orb_unwrap_residue_life,
          life_max : _k_orb_unwrap_residue_life,
          hot : random_range(0.4, 0.9),
          sink : _ut_sink_mix,
          phase : random(360),
          slot : _uo.inst.socket_slot
        });
      }
      orb_unwrap_sink_charge = max(orb_unwrap_sink_charge, 0.36 + _ut_sink_mix * 0.48);
      orb_unwrap_recoil = max(orb_unwrap_recoil, 0.28 + _ut_sink_mix * 0.28);

      _uo.inst.orbiting = false;
      _uo.inst.transitioning = false;
      _uo.inst.direction = _dir_out + _lean;
      _uo.inst.image_angle = _uo.inst.direction;
      _uo.inst.speed = random_range(8, 14);
      _uo.inst.released = true;
      _uo.inst.released_curl = -_lean * 0.09;
      _uo.inst.beat_flash = 1;
      _uo.inst.gather = 1;
      _uo.inst.seam_charge = 0;
      _uo.inst.shell_open = 0;
      _uo.inst.cell_spin_speed *= 2.1;

      if (array_length(orb_scars) < _k_orb_scar_max) {
        array_push(orb_scars, {
          kind : 2,
          x : _uo.inst.x, y : _uo.inst.y,
          ang : _uo.inst.direction,
          len : 16 + random(10),
          life : 7, life_max : 7, hot : 1, aspect : 1,
          col : global.avoid_col_cyan_soft, pts : []
        });
      }

      for (var _uk = 0; _uk < 4; _uk++) {
        array_push(arrow_ring_particles, {
          x : _uo.inst.x, y : _uo.inst.y,
          vx : lengthdir_x(random_range(1, 4), _dir_out + random_range(-50, 50)),
          vy : lengthdir_y(random_range(1, 4), _dir_out + random_range(-50, 50)),
          life : 10 + irandom(12), max_life : 22,
          size : random_range(0.04, 0.1),
          grav : 0.08, drag : 0.94, hot : random_range(0.5, 1)
        });
      }

      orb_unwrap_flash = max(orb_unwrap_flash, 0.5);
    }
    big_orb_unwrap_index++;
  }

  for (var _pw = 0; _pw < 2; _pw++) {
    var _pi3 = big_orb_unwrap_index + _pw;
    if (_pi3 >= _total) break;
    var _po = big_orb_regions[_pi3];
    if (!instance_exists(_po.inst)) continue;
    var _prid = _po.inst.ring_id;
    if (_prid < 0 || _prid >= array_length(orb_rails) || !is_struct(orb_rails[_prid])) continue;
    var _prl = orb_rails[_prid];
    var _psl = _po.inst.socket_slot;
    if (_psl >= 0 && _psl < array_length(_prl.sockets)) {
      _prl.sockets[_psl].flash = max(_prl.sockets[_psl].flash, 0.55 - _pw * 0.22);
    }
  }

  if (timeline_hit(_k_orb_unwrap_end)) {
    for (var _ui = big_orb_unwrap_index; _ui < _total; _ui++) {
      var _uo2 = big_orb_regions[_ui];
      if (instance_exists(_uo2.inst)) {
        var _ox2 = (_uo2.inst.orbit_radius > 0) ? _uo2.inst.orbit_center_x : _ucenter_x;
        var _oy2 = (_uo2.inst.orbit_radius > 0) ? _uo2.inst.orbit_center_y : _ucenter_y;
        var _dir_out2 = (point_distance(_ox2, _oy2, _uo2.inst.x, _uo2.inst.y) > 1)
                        ? point_direction(_ox2, _oy2, _uo2.inst.x, _uo2.inst.y)
                        : random(360);
        var _lean2 = 30 * _uo2.inst.orbit_dir;
        _uo2.inst.orbiting = false;
        _uo2.inst.transitioning = false;
        _uo2.inst.direction = _dir_out2 + _lean2;
        _uo2.inst.image_angle = _uo2.inst.direction;
        _uo2.inst.speed = random_range(8, 14);
        _uo2.inst.released = true;
        _uo2.inst.released_curl = -_lean2 * 0.09;
        _uo2.inst.gather = 1;
        _uo2.inst.seam_charge = 0;
        _uo2.inst.shell_open = 0;
      }
    }
    big_orb_unwrap_index = _total;

    orb_final_burst = 1;
    orb_unwrap_sink_charge = max(orb_unwrap_sink_charge, 1.15);
    orb_unwrap_recoil = max(orb_unwrap_recoil, 1);

    array_push(ring_shockwaves, {
      x : _ucenter_x, y : 200,
      radius : 30, max_radius : 820,
      life : 34, max_life : 34,
      width : 34, hot : 1, vs : 0.6
    });

    for (var _fb = 0; _fb < 54; _fb++) {
      array_push(ring_streaks, {
        cx : _ucenter_x, cy : 200, vs : 0.6,
        ang : random(360),
        dist : random_range(30, 180),
        len : random_range(90, 320),
        speed : random_range(14, 30),
        life : 14 + irandom(14), max_life : 28,
        width : random_range(1.4, 4),
        hot : random_range(0.6, 1)
      });
    }

    for (var _fe = 0; _fe < 26; _fe++) {
      var _fea = random(360);
      array_push(ring_embers, {
        x : _ucenter_x + lengthdir_x(random_range(20, 220), _fea),
        y : 200 + lengthdir_y(random_range(20, 130), _fea),
        vx : random_range(-2, 2), vy : random_range(-1, 2.5),
        life : 50 + irandom(50), max_life : 100,
        size : random_range(0.06, 0.15),
        hot : random_range(0.5, 1)
      });
    }

    for (var _frs = 0; _frs < 5; _frs++) {
      if (array_length(orb_unwrap_residue) >= _k_orb_unwrap_residue_max) array_delete(orb_unwrap_residue, 0, 1);
      var _roff = (_frs - 2) * 13 + random_range(-4, 4);
      array_push(orb_unwrap_residue, {
        x1 : _ucenter_x + _roff,
        y1 : 200 + random_range(-10, 10),
        x2 : _k_mill_cx + _roff * 0.24,
        y2 : _k_mill_cy + random_range(-16, 16),
        dir : 90 + random_range(-8, 8),
        life : _k_orb_unwrap_residue_life,
        life_max : _k_orb_unwrap_residue_life,
        hot : 1,
        sink : 1,
        phase : random(360),
        slot : _frs
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 28);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.2);
      oCameraController.angle_kick += choose(-1, 1) * 3.8;
      oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.6);
      oCameraController.letterbox_target = 0;
    }

    scr_impact_pulse(0.7, 1.1, 0.42, _ucenter_x, room_height * 0.7);
    scr_bg_bass_hit();
    scr_add_light(_ucenter_x, 200, _k_arc_hot_color, 14);
  }
}

if (t >= _k_mill_t_seed - 4 && t <= _k_mill_window_end) {
  if (t >= _k_mill_t_coil && t < _k_mill_t_unfold) {
    mill_charge = clamp((t - _k_mill_t_coil) / (_k_mill_t_unfold - _k_mill_t_coil), 0, 1);
  } else if (t >= _k_mill_t_unfold) {
    mill_charge = max(0, mill_charge - 0.06);
  }

  var _mhb_drive = 0;
  if (t < _k_mill_t_unfold) {
    _mhb_drive = mill_charge;
  } else if (t < _k_mill_t_overload) {
    _mhb_drive = clamp((t - _k_mill_t_unfold) / (_k_mill_t_overload - _k_mill_t_unfold), 0, 1);
  }
  if (t < _k_mill_t_overload) {
    mill_heartbeat_phase += lerp(0.05, 0.25, _mhb_drive);
    mill_heartbeat = power(max(0, sin(mill_heartbeat_phase)), 6) * lerp(0.2, 1, _mhb_drive);
  } else {
    mill_heartbeat = max(0, mill_heartbeat - 0.06);
  }

  if (t >= _k_mill_t_seed_c) {
    mill_collapse = clamp((t - _k_mill_t_seed_c) / (_k_mill_t_tear - _k_mill_t_seed_c), 0, 1);
  }

  if (t >= _k_mill_t_coil && t < _k_mill_t_unfold) {
    mill_rim = lerp(380, 96, mill_charge * mill_charge);
  } else {
    mill_rim = max(0, mill_rim - 18);
  }

  mill_blade_flash = max(0, mill_blade_flash - 0.11);
  mill_overload    = max(0, mill_overload - 0.045);
  mill_snap        = max(0, mill_snap - 0.14);
  mill_field_heat  = max(0, mill_field_heat - 0.03);
  mill_arm_glow    = max(0, mill_arm_glow - 0.011);
  mill_vortex     += 0.35 + mill_charge * 1.5 + mill_field_heat * 2.4 + mill_overload * 4;

  if (t >= _k_mill_t_unfold && t < _k_mill_t_clear && instance_exists(oPlayer)) {
    var _mcore_swap = clamp((t - _k_mill_t_overload) / max(_k_mill_t_seed_c - _k_mill_t_overload, 1), 0, 1);
    var _mcore_r = lerp(_k_mill_core_r_a, _k_mill_core_r_b, _mcore_swap);
    _mcore_r *= clamp((t - _k_mill_t_unfold) / max(_k_mill_core_arm, 1), 0, 1);
    if (collision_circle(_k_mill_cx, _k_mill_cy, _mcore_r, oPlayer, false, true) != noone) {
      player_register_hazard_hit();
    }
  }

  for (var _maw = 0; _maw < array_length(mill_arm_waves); _maw++) {
    mill_arm_waves[_maw].age++;
  }

  for (var _msi = array_length(mill_seeds) - 1; _msi >= 0; _msi--) {
    var _sd = mill_seeds[_msi];
    if (_sd.delay > 0) { _sd.delay--; continue; }

    _sd.timer++;
    var _sdp = clamp(_sd.timer / _sd.duration, 0, 1);
    var _sde = 1 - power(1 - _sdp, 2);

    var _sdpx = _sd.x, _sdpy = _sd.y;
    var _sdi = 1 - _sde;
    _sd.x = _sdi * _sdi * _sd.ox + 2 * _sdi * _sde * _sd.mx + _sde * _sde * _sd.tx;
    _sd.y = _sdi * _sdi * _sd.oy + 2 * _sdi * _sde * _sd.my + _sde * _sde * _sd.ty;

    array_push(_sd.trail, { x : _sdpx, y : _sdpy });
    if (array_length(_sd.trail) > 8) array_delete(_sd.trail, 0, 1);

    _sd.shed--;
    if (_sd.shed <= 0) {
      _sd.shed = _sd.heavy ? 2 : 6;
      var _sdang = point_direction(_sd.x, _sd.y, _sdpx, _sdpy) + random_range(-24, 24);
      array_push(arrow_ring_particles, {
        x : _sd.x, y : _sd.y,
        vx : lengthdir_x(random_range(1, 3), _sdang), vy : lengthdir_y(random_range(1, 3), _sdang),
        life : 8 + irandom(8), max_life : 16,
        size : random_range(0.03, 0.07), grav : 0.05, drag : 0.94, hot : random_range(0.4, 0.9)
      });
    }

    if (_sdp >= 1) {
      with (instance_create_layer(_sd.tx, _sd.ty, layer, oLaserOrb_Pop)) {
        base_scale = _sd.scale;
        idle_alpha_max_override = 0.26;
        materialize_duration = 8 + irandom(6);
      }
      array_push(mill_touchdowns, { x : _sd.tx, y : _sd.ty, life : 10, life_max : 10, heavy : _sd.heavy });
      array_delete(mill_seeds, _msi, 1);
    }
  }

  for (var _mt = array_length(mill_touchdowns) - 1; _mt >= 0; _mt--) {
    mill_touchdowns[_mt].life--;
    if (mill_touchdowns[_mt].life <= 0) array_delete(mill_touchdowns, _mt, 1);
  }

  if (t >= _k_mill_t_coil && t < _k_mill_t_unfold) {
    var _mmn = 1 + floor(mill_charge * 5);
    for (var _mm = 0; _mm < _mmn; _mm++) {
      array_push(mill_motes, {
        ang  : random(360),
        dist : random_range(220, 580),
        spd  : random_range(5, 11) * (0.6 + mill_charge),
        spin : random_range(-3.4, 3.4) * (0.5 + mill_charge),
        life : 70, life_max : 70,
        hot  : random_range(0.5, 1)
      });
    }
  }
  for (var _mo = array_length(mill_motes) - 1; _mo >= 0; _mo--) {
    var _mmo = mill_motes[_mo];
    _mmo.dist -= _mmo.spd;
    _mmo.ang  += _mmo.spin;
    _mmo.spd  *= 1.035;
    _mmo.life--;
    if (_mmo.dist <= _k_mill_r_in * 0.4 || _mmo.life <= 0) array_delete(mill_motes, _mo, 1);
  }

  for (var _msc = array_length(mill_scars) - 1; _msc >= 0; _msc--) {
    var _mscr = mill_scars[_msc];
    _mscr.alpha -= 0.0035;
    if (_mscr.fire_in > 0) {
      var _mscp = 1 - (_mscr.fire_in / max(_k_mill_scar_lead, 1));
      _mscr.ignite = max(_mscr.ignite, 0.35 + _mscp * 0.65);
    } else {
      _mscr.ignite = max(0, _mscr.ignite - 0.055);
    }
    _mscr.guide = max(0, _mscr.guide - 0.04);
    if (_mscr.alpha <= 0) array_delete(mill_scars, _msc, 1);
  }

  for (var _pq = array_length(mill_pop_queue) - 1; _pq >= 0; _pq--) {
    var _pqe = mill_pop_queue[_pq];
    _pqe.delay--;
    if (_pqe.delay > 0) continue;

    if (instance_exists(_pqe.inst) && !_pqe.inst.is_popped) {
      scr_pop_laser_orb(_pqe.inst);
      var _pqx = _pqe.inst.x, _pqy = _pqe.inst.y;
      var _pqout = point_direction(_k_mill_cx, _k_mill_cy, _pqx, _pqy);
      for (var _pqs = 0; _pqs < 3; _pqs++) {
        var _pqa = _pqout + random_range(-55, 55);
        var _pqv = random_range(3, 8);
        array_push(arrow_ring_particles, {
          x : _pqx, y : _pqy,
          vx : lengthdir_x(_pqv, _pqa), vy : lengthdir_y(_pqv, _pqa),
          life : 10 + irandom(12), max_life : 22,
          size : random_range(0.05, 0.13), grav : 0.12, drag : 0.93, hot : random_range(0.6, 1)
        });
      }
    }
    array_delete(mill_pop_queue, _pq, 1);
  }

  if (t >= _k_mill_t_unfold && t <= _k_mill_t_overload) {
    var _mbp = clamp((t - _k_mill_t_unfold) / (_k_mill_t_overload - _k_mill_t_unfold), 0, 1);
    var _mspin = lerp(_k_mill_spin_start, _k_mill_spin_end, power(_mbp, 1.4));

    var _mmult = 1;
    if (mill_stall > 0) {
      mill_stall--;
      _mmult = 0.09;
      if (mill_stall <= 0) mill_snap = 1;
    } else {
      _mmult = 1 + mill_snap * (_k_mill_snap_mult - 1);
    }

    var _mext = clamp((t - _k_mill_t_unfold) / 8, 0, 1);
    _mext = (1 - power(1 - _mext, 3)) * lerp(1, _k_mill_extend_end, _mbp);
    if (t >= _k_mill_t_strain) {
      var _mstr = clamp((t - _k_mill_t_strain) / max(_k_mill_t_overload - _k_mill_t_strain, 1), 0, 1);
      _mext = lerp(_mext, _k_mill_extend_burst, _mstr * _mstr);
    }

    if (instance_exists(mill_blade_a)) {
      mill_blade_a.rotate_speed = _mspin * _mmult;
      mill_blade_a.extend = _mext;
      mill_field_heat = max(mill_field_heat, mill_blade_a.beam_heat / mill_blade_a._k_beam_heat_max);
    }
    if (instance_exists(mill_blade_b)) {
      var _mextb = clamp((t - _k_mill_t_twin) / 8, 0, 1);
      mill_blade_b.rotate_speed = -_mspin * _mmult * 1.12;
      mill_blade_b.extend = (1 - power(1 - _mextb, 3)) * _mext * 0.92;
      mill_field_heat = max(mill_field_heat, mill_blade_b.beam_heat / mill_blade_b._k_beam_heat_max);
    }
  }
}

if (timeline_hit_many(_k_mill_t_seed, _k_mill_t_seed_b, _k_mill_t_feed)) {
  var _wi = 0;
  if (timeline_hit(_k_mill_t_seed_b)) _wi = 1;
  else if (timeline_hit(_k_mill_t_feed)) _wi = 2;

  var _k_wave_arms     = [        5,    5,    9 ];
  var _k_wave_per      = [        6,    5,   22 ];
  var _k_wave_twist    = [        1,    1,   -1 ];
  var _k_wave_arm_off  = [        0,   36,   20 ];
  var _k_wave_flight   = [       26,   24,   17 ];
  var _k_wave_spread   = [       14,   14,   22 ];
  var _k_wave_scale    = [        1,    1,    1 ];

  var _wa   = _k_wave_arms[_wi];
  var _wp   = _k_wave_per[_wi];
  var _wt   = _k_wave_twist[_wi];
  var _woff = _k_wave_arm_off[_wi];

  if (_wi == 0) mill_arm_base = random(360);
  mill_arm_count = _wa;
  mill_arm_sign  = _wt;
  mill_arm_glow  = max(mill_arm_glow, (_wi == 2) ? 1 : 0.7);

  var _wave = {
    base   : mill_arm_base,
    count  : _wa,
    off    : _woff,
    sign   : _wt,
    twist  : _k_mill_arm_twist,
    r_in   : _k_mill_r_in,
    rx_out : _k_mill_rx_out,
    ry_out : _k_mill_ry_out,
    fill   : _k_mill_edge_fill,
    scale  : _k_wave_scale[_wi],
    per    : _wp,
    weight : (_wi == 2) ? 1 : 0.82,
    age    : 0,
    cols   : []
  };

  for (var _wc = 0; _wc < _wa * _wp; _wc++) {
    array_push(_wave.cols, choose(global.avoid_col_cyan, global.avoid_col_warning,
                                  global.avoid_col_violet));
  }

  array_push(mill_arm_waves, _wave);

  for (var _aa = 0; _aa < _wa; _aa++) {
    for (var _as = 0; _as < _wp; _as++) {
      var _af  = (_wp <= 1) ? 1 : (_as / (_wp - 1));

      var _apt  = scr_mill_arm_point(_wave, _aa, _af, _k_mill_cx, _k_mill_cy);
      var _aang = _apt.ang;
      var _ar   = _apt.r;
      var _atx  = _apt.x;
      var _aty  = _apt.y;

      var _aoang = _aang + 26 * _wt;
      var _aox = _k_mill_cx + lengthdir_x(_ar + 430, _aoang);
      var _aoy = _k_mill_cy + lengthdir_y(_ar + 430, _aoang);
      var _amx = lerp(_aox, _atx, 0.5) + lengthdir_x(random_range(40, 120) * _wt, _aang + 90);
      var _amy = lerp(_aoy, _aty, 0.5) + lengthdir_y(random_range(40, 120) * _wt, _aang + 90);

      array_push(mill_seeds, {
        ox : _aox, oy : _aoy, mx : _amx, my : _amy, tx : _atx, ty : _aty,
        x : _aox, y : _aoy,
        timer : 0, duration : _k_wave_flight[_wi] + irandom(6),
        delay : round(_af * _k_wave_spread[_wi] + _aa * 1.5),
        trail : [], shed : irandom(3),
        scale : (_as == _wp - 1) ? 1.3 : 1,
        heavy : (_as == _wp - 1)
      });
    }
  }

  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = (_wi == 0) ? 0.55 : oCameraController.letterbox_target;
    oCameraController.shake = max(oCameraController.shake, (_wi == 2) ? 10 : 5);
  }
  scr_impact_pulse((_wi == 2) ? 0.36 : 0.2, (_wi == 2) ? 0.5 : 0.28, (_wi == 2) ? 0.5 : 0.3,
                   _k_mill_cx, _k_mill_cy);
  global_ripple_pulse = max(global_ripple_pulse, (_wi == 2) ? 0.5 : 0.25);
}

if (timeline_hit(_k_mill_t_coil)) {
  scr_start_laser_coil(_k_mill_cx, _k_mill_cy, 0, _k_mill_t_unfold - _k_mill_t_coil, 1.5, true);
  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 0.88;
  }
  vignette_pulse = max(vignette_pulse, 0.5);
  scr_add_light(_k_mill_cx, _k_mill_cy, _k_arc_color, 6);
}

if (timeline_hit(_k_mill_t_unfold)) {
  mill_blade_a = instance_create_layer(_k_mill_cx, _k_mill_cy, layer, oLaserOrbTrigger);
  with (mill_blade_a) {
    move_speed = 0;
    is_rotating = 1;
    rotate_speed = other._k_mill_spin_start;
    extend = 0;
    image_yscale = 0;
  }

  mill_blade_flash = 1;
  scr_laser_muzzle_burst(_k_mill_cx, _k_mill_cy, 0,   1.3);
  scr_laser_muzzle_burst(_k_mill_cx, _k_mill_cy, 180, 1.3);
  scr_impact_pulse(0.5, 0.85, 0.7, _k_mill_cx, _k_mill_cy);
  scr_add_light(_k_mill_cx, _k_mill_cy, _k_arc_hot_color, 11);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 16);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.14);
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.34);
  }
  global_ripple_pulse = max(global_ripple_pulse, 0.7);
  tear_amount = max(tear_amount, 0.5);
}

if (timeline_hit(_k_mill_t_twin)) {
  mill_blade_b = instance_create_layer(_k_mill_cx, _k_mill_cy, layer, oLaserOrbTrigger);
  with (mill_blade_b) {
    move_speed = 0;
    is_rotating = 1;
    rotate_speed = -other._k_mill_spin_start * 1.12;
    image_angle = 0;
    extend = 0;
    image_yscale = 0;
  }

  mill_blade_flash = 1;
  scr_laser_muzzle_burst(_k_mill_cx, _k_mill_cy, 90,  1.2);
  scr_laser_muzzle_burst(_k_mill_cx, _k_mill_cy, 270, 1.2);
  scr_impact_pulse(0.42, 0.7, 0.6, _k_mill_cx, _k_mill_cy);
  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 13);
    oCameraController.angle_kick += choose(-1, 1) * 2.4;
  }
  tear_amount = max(tear_amount, 0.45);
}

if (t >= _k_mill_t_unfold && t <= _k_mill_t_overload) {
  for (var _mci = 0; _mci < array_length(_k_mill_chop_beats); _mci++) {
    if (!timeline_hit(_k_mill_chop_beats[_mci])) continue;

    mill_stall = _k_mill_stall_frames;
    mill_blade_flash = max(mill_blade_flash, 0.8);
    mill_arm_glow = max(mill_arm_glow, 0.85);

    if (instance_exists(mill_blade_a)) {
      mill_blade_a.beam_heat = min(mill_blade_a.beam_heat + 0.7, mill_blade_a._k_beam_heat_max);
    }
    if (instance_exists(mill_blade_b)) {
      mill_blade_b.beam_heat = min(mill_blade_b.beam_heat + 0.7, mill_blade_b._k_beam_heat_max);
    }

    array_push(ring_shockwaves, {
      x : _k_mill_cx, y : _k_mill_cy,
      radius : 24, max_radius : 300 + _mci * 90,
      life : 20, max_life : 20,
      width : 18 + _mci * 5, hot : 0.8, vs : 0.82
    });

    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 8 + _mci * 3);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.06 + _mci * 0.02);
      oCameraController.angle_kick += choose(-1, 1) * (1.4 + _mci * 0.5);
    }
    scr_impact_pulse(0.3 + _mci * 0.06, 0.45 + _mci * 0.1, 0.4 + _mci * 0.08, _k_mill_cx, _k_mill_cy);
    global_ripple_pulse = max(global_ripple_pulse, 0.35 + _mci * 0.08);
    break;
  }
}

if (timeline_hit(_k_mill_t_strain)) {
  if (instance_exists(oCameraController)) {
    oCameraController.letterbox_target = 1;
  }
  vignette_pulse = max(vignette_pulse, 0.75);
  aberration_pulse = max(aberration_pulse, 0.6);
}

if (timeline_hit(_k_mill_t_overload)) {
  mill_overload = 1;
  mill_blade_flash = 1;
  mill_arm_glow = 1;

  var _fan_a = instance_exists(mill_blade_a) ? (mill_blade_a.image_angle - 90) : random(360);
  var _fan_reach = instance_exists(mill_blade_a)
                   ? (mill_blade_a._k_beam_half_length * mill_blade_a.extend)
                   : (450 * _k_mill_extend_burst);

  mill_scars = [];
  mill_gate_cyan_first = choose(true, false);
  var _k_scar_n = _k_mill_scar_count;
  if (instance_exists(oPlayer) && _k_scar_n > 0) {
    var _avoid_step = 180 / _k_scar_n;
    var _avoid_ang = point_direction(_k_mill_cx, _k_mill_cy, oPlayer.x, oPlayer.y);
    var _avoid_phase = ((_avoid_ang - _fan_a) mod _avoid_step + _avoid_step) mod _avoid_step;
    var _avoid_shift = _avoid_step * 0.5 - _avoid_phase;
    if (_avoid_shift >  _avoid_step * 0.5) _avoid_shift -= _avoid_step;
    if (_avoid_shift < -_avoid_step * 0.5) _avoid_shift += _avoid_step;
    _fan_a += _avoid_shift;
  }
  for (var _sc = 0; _sc < _k_scar_n; _sc++) {
    var _scang = _fan_a + (_sc / _k_scar_n) * 180 + random_range(-2, 2);
    array_push(mill_scars, {
      ang      : _scang,
      half_len : _fan_reach * random_range(0.86, 1.06),
      alpha    : 0.95,
      hot      : random_range(0.6, 1),
      off      : scr_bolt_offsets(5, 9),
      ignite   : 0,
      guide    : 0,
      fire_in  : -1,
      spent    : false,

      throw_sign : choose(-1, 1),

      door_a   : noone,
      door_b   : noone
    });
  }

  mill_scar_queue = [];
  var _sq_n = array_length(mill_scars);
  if (_sq_n > 0) {
    var _sq_start = irandom(_sq_n - 1);
    var _sq_dir   = choose(1, -1);
    for (var _sq = 0; _sq < _sq_n; _sq++) {
      array_push(mill_scar_queue, ((_sq_start + _sq * _sq_dir) mod _sq_n + _sq_n) mod _sq_n);
    }
  }

  with (oLaserOrbTrigger) instance_destroy();
  mill_blade_a = noone;
  mill_blade_b = noone;

  mill_pop_queue = [];
  with (oLaserOrb_Pop) {
    if (!is_popped) {
      var _od = point_distance(other._k_mill_cx, other._k_mill_cy, x, y);
      array_push(other.mill_pop_queue, {
        inst  : id,
        delay : 1 + floor(_od / other._k_mill_pop_wave_spd)
      });
    }
  }

  array_push(ring_shockwaves, {
    x : _k_mill_cx, y : _k_mill_cy,
    radius : 30, max_radius : 1000,
    life : 38, max_life : 38,
    width : 40, hot : 1, vs : 0.8
  });
  array_push(ring_shockwaves, {
    x : _k_mill_cx, y : _k_mill_cy,
    radius : 20, max_radius : 520,
    life : 22, max_life : 22,
    width : 26, hot : 1, vs : 0.8
  });

  for (var _ob = 0; _ob < 64; _ob++) {
    array_push(ring_streaks, {
      cx : _k_mill_cx, cy : _k_mill_cy, vs : 0.8,
      ang : random(360),
      dist : random_range(30, 200),
      len : random_range(110, 380),
      speed : random_range(16, 34),
      life : 14 + irandom(16), max_life : 30,
      width : random_range(1.4, 4.5),
      hot : random_range(0.6, 1)
    });
  }

  for (var _oe = 0; _oe < 34; _oe++) {
    var _oea = random(360);
    array_push(ring_embers, {
      x : _k_mill_cx + lengthdir_x(random_range(20, 260), _oea),
      y : _k_mill_cy + lengthdir_y(random_range(20, 170), _oea),
      vx : random_range(-2.5, 2.5), vy : random_range(-1.5, 3),
      life : 55 + irandom(55), max_life : 110,
      size : random_range(0.07, 0.18),
      hot : random_range(0.5, 1)
    });
  }

  if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
  array_push(slash_warps, {
    x : _k_mill_cx, y : _k_mill_cy, radius : 40, max_radius : 900,
    strength : 1.7, life : 30, life_max : 30
  });
  if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
  array_push(slash_warps, {
    x : _k_mill_cx, y : _k_mill_cy, radius : 90, max_radius : 1250,
    strength : 0.8, life : 52, life_max : 52
  });

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, 34);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.26);
    oCameraController.angle_kick += choose(-1, 1) * 4.6;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.72);
    oCameraController.letterbox_target = 0;
  }

  scr_impact_pulse(0.85, 2.6, 1.0, _k_mill_cx, _k_mill_cy);
  scr_bg_bass_hit();
  scr_add_light(_k_mill_cx, _k_mill_cy, _k_arc_hot_color, 16);
  global_ripple_pulse = max(global_ripple_pulse, 0.78);
  vignette_pulse   = max(vignette_pulse, 0.9);
  bloom_pulse      = max(bloom_pulse, 1);
  aberration_pulse = max(aberration_pulse, 0.85);
  tear_amount      = max(tear_amount, 0.72);
}

if (timeline_hit_many(_k_mill_t_overload, _k_mill_t_seed_c) && array_length(mill_scars) > 0) {
  var _dsecond = timeline_hit(_k_mill_t_seed_c);

  for (var _dsi = 0; _dsi < array_length(mill_scars); _dsi++) {
    var _dsc = mill_scars[_dsi];

    var _dperp = _dsc.ang + 90 * _dsc.throw_sign;

    for (var _dslot = (_dsecond ? 1 : 0); _dslot < _k_mill_scar_beads; _dslot += 2) {
      var _dpt = scr_mill_bead_slot(_dsc, _dslot, _k_mill_scar_beads,
                                    _k_mill_r_in + 30, _k_mill_rx_out, _k_mill_ry_out,
                                    _k_mill_bead_fill);

      var _dmid = (_k_mill_scar_beads - 1) * 0.5;
      var _dbf = abs(_dslot - _dmid) / _dmid;
      var _dpair_slot = (_dslot div 2) * 2;
      var _dpa = scr_mill_bead_slot(_dsc, _dpair_slot, _k_mill_scar_beads,
                                    _k_mill_r_in + 30, _k_mill_rx_out, _k_mill_ry_out,
                                    _k_mill_bead_fill);
      var _dpb = scr_mill_bead_slot(_dsc, _dpair_slot + 1, _k_mill_scar_beads,
                                    _k_mill_r_in + 30, _k_mill_rx_out, _k_mill_ry_out,
                                    _k_mill_bead_fill);
      var _dcx = (_dpa.x + _dpb.x) * 0.5;
      var _dcy = (_dpa.y + _dpb.y) * 0.5;
      var _dang = point_direction(_k_mill_cx, _k_mill_cy, _k_mill_cx + _dcx, _k_mill_cy + _dcy);
      var _drad = point_distance(0, 0, _dcx, _dcy);
      var _dband = floor(abs(((_dpair_slot + _dpair_slot + 1) * 0.5) - _dmid) / 2);
      var _dcyan = (((_dband mod 2) == 0) == mill_gate_cyan_first);
      var _ddir = _dcyan ? -1 : 1;
      var _dtarget_i = ((_dsi + _ddir) mod array_length(mill_scars) + array_length(mill_scars))
                       mod array_length(mill_scars);
      var _dtarget_base = mill_scars[_dtarget_i].ang;
      var _dspan = _ddir * (180 / max(_k_mill_scar_count, 1));
      var _dbest = 1000000;
      for (var _dk = -3; _dk <= 3; _dk++) {
        var _dcand = _dtarget_base + _dk * 180;
        var _ddelta = _dcand - _dang;
        if (_ddir > 0 && _ddelta > 0 && _ddelta < _dbest) {
          _dbest = _ddelta;
          _dspan = _ddelta;
        }
        if (_ddir < 0 && _ddelta < 0 && -_ddelta < _dbest) {
          _dbest = -_ddelta;
          _dspan = _ddelta;
        }
      }
      if (abs(_dspan) > 72) _dspan = _ddir * (180 / max(_k_mill_scar_count, 1));

      with (instance_create_layer(_k_mill_cx + _dpt.x,
                                  _k_mill_cy + _dpt.y,
                                  layer, oFallingRedOrb)) {
        mill_orb = true;
        mill_scar_index = _dsi;
        mill_launch_dir = _dperp;
        mill_slot = _dslot;
        mill_along = _dpt.dist;
        mill_bead_f = _dbf;
        mill_orbit_angle = point_direction(other._k_mill_cx, other._k_mill_cy, x, y);
        mill_orbit_radius = point_distance(other._k_mill_cx, other._k_mill_cy, x, y);
        mill_orbit_dir = _ddir;
        mill_gate_cyan = _dcyan;
        if (mill_gate_cyan) {
          sprite_index = sRainbowOrb;
          image_index = 0;
        } else {
          sprite_index = sRedOrb;
        }
        image_speed = 0;
        image_blend = c_white;
        image_alpha = 0.35;
      }
    }

    if (_dsecond) scr_mill_link_resting_gates(_dsi);
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake = max(oCameraController.shake, _dsecond ? 9 : 5);
  }
  if (_dsecond) scr_impact_pulse(0.3, 0.45, 0.35, _k_mill_cx, _k_mill_cy);
}

if (t >= _k_mill_t_seed_c - 2 && t <= _k_mill_t_tear) {
  var _vh = -1;
  for (var _vi = 0; _vi < array_length(_k_mill_volley_beats); _vi++) {
    if (timeline_hit(_k_mill_volley_beats[_vi] - _k_mill_scar_lead)) { _vh = _vi; break; }
  }

  if (_vh >= 0 && array_length(mill_scars) > 0) {
    var _vwant = _k_mill_volley_scars[_vh];
    var _vtargets = [];

    while (array_length(_vtargets) < _vwant && array_length(mill_scar_queue) > 0) {
      array_push(_vtargets, mill_scar_queue[0]);
      array_delete(mill_scar_queue, 0, 1);
    }

    if (array_length(_vtargets) < _vwant) {
      var _vlist = ds_list_create();
      var _vdup = false;
      for (var _vs = 0; _vs < array_length(mill_scars); _vs++) {
        if (mill_scars[_vs].spent) continue;
        _vdup = false;
        for (var _vd = 0; _vd < array_length(_vtargets); _vd++) {
          if (_vtargets[_vd] == _vs) { _vdup = true; break; }
        }
        if (!_vdup) ds_list_add(_vlist, _vs);
      }
      while (array_length(_vtargets) < _vwant && ds_list_size(_vlist) > 0) {
        var _vpick = irandom(ds_list_size(_vlist) - 1);
        array_push(_vtargets, _vlist[| _vpick]);
        ds_list_delete(_vlist, _vpick);
      }
      ds_list_destroy(_vlist);
    }

    var _vn = array_length(_vtargets);
    var _vbudget = _k_mill_volley_count[_vh];

    for (var _vp = 0; _vp < _vn; _vp++) {
      var _vidx = _vtargets[_vp];

      mill_scars[_vidx].ignite = 1;
      mill_scars[_vidx].guide = 1;
      mill_scars[_vidx].fire_in = _k_mill_scar_lead + 1;

      var _vshare = ceil(_vbudget / max(_vn - _vp, 1));
      var _vblist = ds_list_create();
      with (oFallingRedOrb) {
        if (mill_orb && mill_scar_index == _vidx && waiting_to_fall == 1
            && !telegraphing && !dissolving) {
          ds_list_add(_vblist, id);
        }
      }

      var _vtake = min(_vshare, ds_list_size(_vblist));
      var _vtaken = [];
      for (var _vb = 0; _vb < _vtake; _vb++) {
        var _vbpick = irandom(ds_list_size(_vblist) - 1);
        var _vbead = _vblist[| _vbpick];
        ds_list_delete(_vblist, _vbpick);
        array_push(_vtaken, _vbead);
        with (_vbead) {
          telegraphing = 1;
          telegraph_timer = other._k_mill_scar_lead + 1;
          telegraph_duration = max(telegraph_timer, 1);
          mill_volley = _vh;
          mill_fuse_delay = 0;
          mill_fuse_span = other._k_mill_fuse_burn;
          mill_launch_boost = 1;
          mill_orbit_armed = (_vh >= other._k_mill_orbit_from);
        }
      }
      _vbudget -= _vtake;
      ds_list_destroy(_vblist);

      if (array_length(_vtaken) > 1) {
        for (var _vsa = 1; _vsa < array_length(_vtaken); _vsa++) {
          var _vskey = _vtaken[_vsa];
          var _vsb = _vsa - 1;
          while (_vsb >= 0 && _vtaken[_vsb].mill_slot > _vskey.mill_slot) {
            _vtaken[_vsb + 1] = _vtaken[_vsb];
            _vsb--;
          }
          _vtaken[_vsb + 1] = _vskey;
        }

        for (var _vfx = 0; _vfx < array_length(_vtaken); _vfx++) {
          with (_vtaken[_vfx]) {
            var _mid = (other._k_mill_scar_beads - 1) * 0.5;
            var _from_centre = abs(mill_slot - _mid) / max(_mid, 1);
            mill_fuse_delay = round(_from_centre * other._k_mill_fuse_frames);
            mill_fuse_span = other._k_mill_fuse_burn;
            mill_launch_boost = lerp(1.08, 0.96, _from_centre);
          }
        }
      }

      if (_vh >= _k_mill_orbit_from && array_length(_vtaken) > 1) {
        for (var _ow = 0; _ow < array_length(_vtaken) - 1; _ow += 2) {
          var _oga = _vtaken[_ow];
          var _ogb = _vtaken[_ow + 1];
          var _ogang = point_direction(_k_mill_cx, _k_mill_cy,
                                       (_oga.x + _ogb.x) * 0.5,
                                       (_oga.y + _ogb.y) * 0.5);
          var _ogmid = (_k_mill_scar_beads - 1) * 0.5;
          var _ogband = floor(abs(((_oga.mill_slot + _ogb.mill_slot) * 0.5) - _ogmid) / 2);
          var _ogcyan = (((_ogband mod 2) == 0) == mill_gate_cyan_first);
          var _ogdir = _ogcyan ? -1 : 1;
          var _ogtarget_i = ((_vidx + _ogdir) mod array_length(mill_scars) + array_length(mill_scars))
                            mod array_length(mill_scars);
          var _ogtarget_base = mill_scars[_ogtarget_i].ang;
          var _ogspan = _ogdir * (180 / max(_k_mill_scar_count, 1));
          var _ogbest = 1000000;
          for (var _ogk = -3; _ogk <= 3; _ogk++) {
            var _ogcand = _ogtarget_base + _ogk * 180;
            var _ogdelta = _ogcand - _ogang;
            if (_ogdir > 0 && _ogdelta > 0 && _ogdelta < _ogbest) {
              _ogbest = _ogdelta;
              _ogspan = _ogdelta;
            }
            if (_ogdir < 0 && _ogdelta < 0 && -_ogdelta < _ogbest) {
              _ogbest = -_ogdelta;
              _ogspan = _ogdelta;
            }
          }
          if (abs(_ogspan) > 72) _ogspan = _ogdir * (180 / max(_k_mill_scar_count, 1));

          _oga.mill_link_to = _ogb;
          _oga.mill_gate_cyan = _ogcyan;
          _ogb.mill_gate_cyan = _ogcyan;
          _oga.mill_orbit_angle = _ogang;
          _ogb.mill_orbit_angle = _ogang;
          _oga.mill_orbit_start_angle = _ogang;
          _ogb.mill_orbit_start_angle = _ogang;
          _oga.mill_orbit_span = _ogspan;
          _ogb.mill_orbit_span = _ogspan;
          _oga.mill_orbit_radius = point_distance(_k_mill_cx, _k_mill_cy, _oga.x, _oga.y);
          _ogb.mill_orbit_radius = point_distance(_k_mill_cx, _k_mill_cy, _ogb.x, _ogb.y);
          _oga.mill_orbit_dir = _ogdir;
          _ogb.mill_orbit_dir = _ogdir;

          if (_ogcyan) {
            _oga.sprite_index = sRainbowOrb;
            _ogb.sprite_index = sRainbowOrb;
            _oga.image_index = 0;
            _ogb.image_index = 0;
          } else {
            _oga.sprite_index = sRedOrb;
            _ogb.sprite_index = sRedOrb;
          }
          _oga.image_speed = 0;
          _ogb.image_speed = 0;
          _oga.image_blend = c_white;
          _ogb.image_blend = c_white;

          mill_scars[_ogtarget_i].guide = 1;
        }
        mill_scars[_vidx].door_a = noone;
        mill_scars[_vidx].door_b = noone;
      }
      else if (_vh >= _k_mill_fence_from && array_length(_vtaken) > 1) {
        var _fgaps = [];
        for (var _fg = 0; _fg < array_length(_vtaken) - 1; _fg++) {
          var _fl = _vtaken[_fg];
          var _fr = _vtaken[_fg + 1];
          array_push(_fgaps, { a : _fl, b : _fr, my : (_fl.y + _fr.y) * 0.5 });
        }
        for (var _fs = 1; _fs < array_length(_fgaps); _fs++) {
          var _fskey = _fgaps[_fs];
          var _fst = _fs - 1;
          while (_fst >= 0 && _fgaps[_fst].my < _fskey.my) {
            _fgaps[_fst + 1] = _fgaps[_fst];
            _fst--;
          }
          _fgaps[_fst + 1] = _fskey;
        }

        var _fn = min(_k_mill_fence_links, array_length(_fgaps));

        var _fdoor = 0;
        var _fbest = 1000000;
        var _fband = (_k_mill_door_lo + _k_mill_door_hi) * 0.5;
        for (var _fd = 0; _fd < _fn; _fd++) {
          var _fdist = abs(_fgaps[_fd].my - _fband);
          if (_fdist < _fbest) { _fbest = _fdist; _fdoor = _fd; }
        }

        for (var _fw = 0; _fw < _fn; _fw++) {
          if (_fw == _fdoor) continue;
          var _fwa = _fgaps[_fw].a;
          _fwa.mill_link_to = _fgaps[_fw].b;
        }

        mill_scars[_vidx].door_a = _fgaps[_fdoor].a;
        mill_scars[_vidx].door_b = _fgaps[_fdoor].b;
      }

      if (_vtake == 0) mill_scars[_vidx].spent = true;
    }

    vignette_pulse = max(vignette_pulse, 0.35 + _vh * 0.08);
    scr_add_light(_k_mill_cx, _k_mill_cy, _k_arc_color, 4 + _vh);
  }
}

if (t >= _k_mill_t_seed_c && t <= _k_mill_window_end) {
  with (oFallingRedOrb) {
    if (!mill_orb || !telegraphing || dissolving) continue;

    telegraph_timer--;
    var _tgp = 1 - (telegraph_timer / max(telegraph_duration, 1));
    image_alpha = lerp(0.4, 1, _tgp);
    var _tgcol = mill_gate_cyan ? global.avoid_col_cyan : global.avoid_col_danger;
    image_blend = merge_color(_tgcol, c_white, _tgp);
    if (telegraph_timer > 0) continue;

    telegraphing = 0;
    waiting_to_fall = 0;
    trail = 1;
    image_alpha = 1;
    image_blend = c_white;
    trail_positions = [];

    speed = 0;
    vspeed = 0;
    direction = mill_launch_dir;
    if (mill_orbit_armed) {
      mill_orbiting = true;
      mill_orbit_timer = 0;
      mill_orbit_life = max(other._k_mill_orbit_life,
                            round(other._k_mill_orbit_end - other.t));
      if (mill_orbit_radius <= 0) {
        mill_orbit_angle = point_direction(other._k_mill_cx, other._k_mill_cy, x, y);
        mill_orbit_start_angle = mill_orbit_angle;
        mill_orbit_span = mill_orbit_dir * (180 / max(other._k_mill_scar_count, 1));
        mill_orbit_radius = point_distance(other._k_mill_cx, other._k_mill_cy, x, y);
      }
      gravity = 0;
      gravity_direction = mill_launch_dir;
    } else {
      var _mlaunch = mill_launch_boost;
      speed = other._k_mill_bead_speed * _mlaunch;
      gravity = other._k_mill_bead_accel * _mlaunch;
      gravity_direction = mill_launch_dir;
    }

    shockwave_active = true;
    shockwave_radius = 0;
    shockwave_max_radius = _k_shockwave_max_radius;
    shockwave_alpha = _k_shockwave_start_alpha;

    pop_flash_timer = 1;
    glowing = true;
    pop_flash_duration = _k_pop_flash_duration;

    growing = true;
    grow_timer = 0;
    _k_grow_overshoot_scale = 1.55;

    mill_wired = true;
  }
}

if (t >= _k_mill_t_seed_c && t <= _k_mill_window_end) {
  with (oFallingRedOrb) {
    if (!mill_orb || !mill_wired || dissolving) continue;
    if (mill_link_to == noone) continue;
    if (!instance_exists(mill_link_to)) { mill_link_to = noone; continue; }

    var _wo = mill_link_to;
    if (!_wo.mill_wired || _wo.dissolving) continue;

    if (player_meeting_line_width(x, y, _wo.x, _wo.y, other._k_mill_fence_w)) {
      player_register_hazard_hit();
    }
  }
}

if (t >= _k_mill_t_overload && t <= _k_mill_window_end) {
  for (var _sfi = 0; _sfi < array_length(mill_scars); _sfi++) {
    var _sfc = mill_scars[_sfi];
    if (_sfc.fire_in < 0) continue;

    _sfc.fire_in--;
    if (_sfc.fire_in > 0) continue;
    _sfc.fire_in = -1;
    _sfc.ignite = 1.4;

    for (var _sfs = 0; _sfs < 2; _sfs++) {
      var _sfd = (_sfs == 0) ? 1 : -1;
      array_push(ring_shockwaves, {
        x : _k_mill_cx + lengthdir_x(_sfc.half_len * 0.5 * _sfd, _sfc.ang),
        y : _k_mill_cy + lengthdir_y(_sfc.half_len * 0.5 * _sfd, _sfc.ang),
        radius : 16, max_radius : 260,
        life : 18, max_life : 18,
        width : 20, hot : 0.9, vs : 1
      });
    }

    for (var _sfk = 0; _sfk < 16; _sfk++) {
      var _sfa = _sfc.ang + 90 * choose(-1, 1) + random_range(-30, 30);
      var _sfp = random_range(-1, 1) * _sfc.half_len;
      array_push(ring_streaks, {
        cx : _k_mill_cx + lengthdir_x(_sfp, _sfc.ang),
        cy : _k_mill_cy + lengthdir_y(_sfp, _sfc.ang), vs : 1,
        ang : _sfa, dist : random_range(4, 40),
        len : random_range(70, 210), speed : random_range(12, 24),
        life : 12 + irandom(10), max_life : 22,
        width : random_range(1.2, 3.4), hot : random_range(0.6, 1)
      });
    }

    scr_floor_impact(clamp(_k_mill_cx + lengthdir_x(_sfc.half_len * 0.4 * choose(-1, 1), _sfc.ang),
                           20, room_width - 20), room_height, 0.3, 0);
  }
}

if (t >= _k_mill_t_wound - 2 && t <= _k_mill_t_tear) {
  var _vbh = -1;
  for (var _vbi = 0; _vbi < array_length(_k_mill_volley_beats); _vbi++) {
    if (timeline_hit(_k_mill_volley_beats[_vbi])) { _vbh = _vbi; break; }
  }

  if (_vbh >= 0) {
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, _k_mill_volley_shake[_vbh]);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05 + _vbh * 0.03);
      oCameraController.angle_kick += choose(-1, 1) * (1.6 + _vbh * 0.7);
      oCameraController.letterbox_target = 0.25 + _vbh * 0.17;
    }
    mill_arm_glow = max(mill_arm_glow, 0.3 + _vbh * 0.08);
    scr_impact_pulse(0.3 + _vbh * 0.08, 0.45 + _vbh * 0.12, 0.4 + _vbh * 0.1, _k_mill_cx, _k_mill_cy);
    scr_bg_bass_hit();
    global_ripple_pulse = max(global_ripple_pulse, 0.3 + _vbh * 0.1);
    tear_amount = max(tear_amount, 0.3 + _vbh * 0.12);
  }
}

if (timeline_hit(_k_mill_t_tear)) {
  mill_torn = true;
  mill_overload = max(mill_overload, 1);
  mill_blade_flash = 1;
  mill_arm_glow = 1;

  for (var _tsi = 0; _tsi < array_length(mill_scars); _tsi++) {
    mill_scars[_tsi].ignite = 1.8;
    mill_scars[_tsi].fire_in = -1;
    mill_scars[_tsi].spent = true;
  }

  with (oFallingRedOrb) {
    if (!mill_orb || dissolving) continue;
    if (mill_orbiting) {
      mill_orbiting = false;
      mill_wired = false;
      mill_link_to = noone;
      dissolving = true;
      hit_active = false;
      dissolve_timer = 0;
      dissolve_duration = other._k_mill_orbit_fade;
      dissolve_delay = irandom(3);
      continue;
    }
    if (waiting_to_fall == 0 && !telegraphing) continue;

    telegraphing = 0;
    waiting_to_fall = 0;
    trail = 1;
    image_alpha = 1;
    image_blend = c_white;
    trail_positions = [];

    mill_wired = false;
    mill_link_to = noone;

    speed = 0;
    vspeed = 0;
    direction = mill_launch_dir;
    speed = other._k_mill_bead_speed * 1.35;
    gravity = other._k_mill_bead_accel * 1.4;
    gravity_direction = mill_launch_dir;

    shockwave_active = true;
    shockwave_radius = 0;
    shockwave_max_radius = _k_shockwave_max_radius * 1.6;
    shockwave_alpha = _k_shockwave_start_alpha;
    pop_flash_timer = 1;
    glowing = true;
    pop_flash_duration = _k_pop_flash_duration;
    growing = true;
    grow_timer = 0;
    _k_grow_overshoot_scale = 2.2;
  }

  array_push(ring_shockwaves, {
    x : _k_mill_cx, y : _k_mill_cy,
    radius : 30, max_radius : 1100,
    life : 40, max_life : 40,
    width : 44, hot : 1, vs : 0.85
  });
  for (var _tst = 0; _tst < 70; _tst++) {
    array_push(ring_streaks, {
      cx : _k_mill_cx, cy : _k_mill_cy, vs : 0.85,
      ang : random(360), dist : random_range(20, 190),
      len : random_range(130, 420), speed : random_range(18, 38),
      life : 14 + irandom(16), max_life : 30,
      width : random_range(1.6, 5), hot : random_range(0.6, 1)
    });
  }
  if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
  array_push(slash_warps, {
    x : _k_mill_cx, y : _k_mill_cy, radius : 50, max_radius : 1300,
    strength : 1.9, life : 34, life_max : 34
  });

  if (instance_exists(oCameraController)) {
    oCameraController.cam_kick_active = true;
    oCameraController.cam_kick_timer = 0;
    oCameraController.shake = max(oCameraController.shake, 36);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.3);
    oCameraController.angle_kick += choose(-1, 1) * 5.4;
    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.8);
    oCameraController.letterbox_target = 0;
  }

  scr_impact_pulse(0.95, 2.8, 1.1, _k_mill_cx, _k_mill_cy);
  scr_bg_bass_hit();
  scr_add_light(_k_mill_cx, _k_mill_cy, _k_arc_hot_color, 18);
  global_ripple_pulse = max(global_ripple_pulse, 0.84);
  vignette_pulse   = max(vignette_pulse, 1);
  bloom_pulse      = max(bloom_pulse, 1.1);
  aberration_pulse = max(aberration_pulse, 0.82);
  tear_amount      = max(tear_amount, 0.82);

  with (oLaserOrb_Pop) if (!is_popped) instance_destroy();
  mill_seeds = [];
  mill_pop_queue = [];
  mill_arm_waves = [];
}

if (timeline_hit(_k_mill_t_clear)) {
  with (oFallingRedOrb) {
    if (mill_orb && !dissolving) {
      dissolving = true;
      hit_active = false;
      dissolve_timer = 0;
      dissolve_duration = 8;
      dissolve_delay = irandom(2);
    }
  }
  with (oLaserOrb_Pop) if (!is_popped) instance_destroy();
  if (instance_exists(oCameraController)) oCameraController.letterbox_target = 0;
}

if (t >= _k_fin_t_open - 6 && t <= _k_fin_t_cut + 60) {
  var _fin_pl_x = instance_exists(oPlayer) ? oPlayer.x : _k_fin_cx;
  var _fin_pl_y = instance_exists(oPlayer) ? oPlayer.y : _k_fin_cy;

  var _fin_lb = -1;

  fin_section_p = clamp((t - _k_fin_t_open) / max(_k_fin_t_cut - _k_fin_t_open, 1), 0, 1);

  fin_charge       = max(0, fin_charge - 0.05);
  fin_lock_flash   = max(0, fin_lock_flash - 0.085);
  fin_strike_flash = max(0, fin_strike_flash - 0.075);
  fin_impact       = max(0, fin_impact - 0.05);
  fin_chroma       = max(0, fin_chroma - 0.07);
  fin_gap_glow     = max(0, fin_gap_glow - 0.045);
  fin_core         = max(0, fin_core - 0.035);

  fin_implode = fin_breath_active ? min(1, fin_implode + 0.026) : max(0, fin_implode - 0.06);

  var _fhb = clamp(fin_section_p * 0.7 + fin_charge * 0.45 + fin_implode * 0.9, 0, 1);
  fin_heartbeat_phase += lerp(0.055, 0.33, _fhb);
  fin_heartbeat = power(max(0, sin(fin_heartbeat_phase)), 6) * lerp(0.22, 1, _fhb);

  with (oBassRingOrb) { flash = max(0, flash - 0.09); }

  fin_assembly_pulse = max(0, fin_assembly_pulse - 0.085);
  fin_assembly_sync  = max(0, fin_assembly_sync - 0.050);

  for (var _fan = 0; _fan < array_length(fin_assembly_nodes); _fan++) {
    fin_assembly_nodes[_fan].pulse = max(0, fin_assembly_nodes[_fan].pulse - 0.075);
  }

  for (var _fap = array_length(fin_assembly_packets) - 1; _fap >= 0; _fap--) {
    var _fapk = fin_assembly_packets[_fap];
    _fapk.life--;
    _fapk.ang += _fapk.spin;
    if (_fapk.life <= 0) array_delete(fin_assembly_packets, _fap, 1);
  }

  var _fa_hit = 0;
  for (var _fht = 0; _fht < array_length(_k_fin_throw_beats); _fht++) {
    if (timeline_hit(_k_fin_throw_beats[_fht])) _fa_hit = max(_fa_hit, 0.62 + _fht * 0.16);
  }
  for (var _fhs = 0; _fhs < array_length(_k_fin_spike_beats); _fhs++) {
    if (timeline_hit(_k_fin_spike_beats[_fhs])) _fa_hit = max(_fa_hit, 0.74 + _fhs * 0.16);
  }
  for (var _fhw = 0; _fhw < array_length(_k_fin_shell_beats); _fhw++) {
    if (timeline_hit(_k_fin_shell_beats[_fhw])) _fa_hit = max(_fa_hit, 0.70 + _fhw * 0.06);
  }
  for (var _fhbr = 0; _fhbr < array_length(_k_fin_breath_beats); _fhbr++) {
    if (timeline_hit(_k_fin_breath_beats[_fhbr])) _fa_hit = max(_fa_hit, 0.55 + _fhbr * 0.05);
  }

  if (_fa_hit > 0) {
    var _fa_vis_step = fin_assembly_visibility();
    fin_assembly_pulse = max(fin_assembly_pulse, min(1.4, _fa_hit));
    fin_assembly_sync  = max(fin_assembly_sync, min(1.2, _fa_hit * 0.75 + fin_section_p * 0.25));

    var _fa_node_n = array_length(fin_assembly_nodes);
    if (_fa_node_n > 0) {
      for (var _fnp = 0; _fnp < _fa_node_n; _fnp++) {
        var _fnd = fin_assembly_nodes[_fnp];
        if (fin_assembly_ring_progress(_fnd.delay) <= 0.03) continue;
        if (((_fnp + floor(t)) mod 3) == 0) {
          _fnd.pulse = max(_fnd.pulse, min(1.25, _fa_hit * (0.72 + _fa_vis_step * 0.35)));
        }
      }

      var _fa_pack_n = min(12, 3 + floor(fin_section_p * 7 + _fa_hit * 4));
      for (var _fpk = 0; _fpk < _fa_pack_n; _fpk++) {
        var _fni = (floor(t) + _fpk * 5 + floor(fin_section_p * 23)) mod _fa_node_n;
        var _fpn = fin_assembly_nodes[_fni];
        if (fin_assembly_ring_progress(_fpn.delay) <= 0.04) continue;

        var _fp_life = 18 + irandom(10) + round(_fa_hit * 4);
        var _fp_in = (random(1) < lerp(0.28, 0.78, fin_section_p));
        var _fp_from = _fp_in ? _fpn.r : (_fpn.r + random_range(80, 170));
        var _fp_to   = _fp_in ? random_range(18, 54) : _fpn.r;

        if (array_length(fin_assembly_packets) >= _k_fin_assembly_packet_max) {
          array_delete(fin_assembly_packets, 0, 1);
        }
        array_push(fin_assembly_packets, {
          ang   : _fpn.ang + random_range(-5, 5),
          r0    : _fp_from,
          r1    : _fp_to,
          life  : _fp_life,
          max_life : _fp_life,
          hot   : min(1.2, _fa_hit),
          width : random_range(0.8, 1.8),
          spin  : random_range(-0.34, 0.34)
        });
      }
    }
  }

  for (var _fg = array_length(fin_ghosts) - 1; _fg >= 0; _fg--) {
    fin_ghosts[_fg].alpha -= fin_ghosts[_fg].fade;
    if (fin_ghosts[_fg].alpha <= 0) array_delete(fin_ghosts, _fg, 1);
  }

  for (var _fm = array_length(fin_motes) - 1; _fm >= 0; _fm--) {
    var _fmo = fin_motes[_fm];
    _fmo.speed += 0.34 + fin_implode * 0.5;
    _fmo.dist  -= _fmo.speed;
    _fmo.ang   += _fmo.spin;
    if (_fmo.dist <= 5) {
      fin_core = min(fin_core + 0.045, 3);
      array_delete(fin_motes, _fm, 1);
    }
  }

  for (var _pfi = array_length(bass_ring_pierce_flashes) - 1; _pfi >= 0; _pfi--) {
    bass_ring_pierce_flashes[_pfi].life--;
    if (bass_ring_pierce_flashes[_pfi].life <= 0) array_delete(bass_ring_pierce_flashes, _pfi, 1);
  }

  if (!fin_opened && t >= _k_fin_t_open) {
    fin_opened = true;
    fin_core   = max(fin_core, 1.1);
    fin_charge = max(fin_charge, 0.45);

    array_push(ring_shockwaves, {
      x : _k_fin_cx, y : _k_fin_cy, radius : 18, max_radius : 620,
      life : 34, max_life : 34, width : 22, hot : 0.85, vs : 1
    });

    for (var _fo = 0; _fo < 4; _fo++) {
      var _foa = 45 + _fo * 90;
      array_push(ring_streaks, {
        cx : _k_fin_cx, cy : _k_fin_cy, vs : 1,
        ang : _foa, dist : 20, len : random_range(220, 360),
        speed : 26, life : 20, max_life : 20, width : 4, hot : 0.9
      });
      scr_slash_bolt(_k_fin_cx, _k_fin_cy,
                     _k_fin_cx + lengthdir_x(430, _foa), _k_fin_cy + lengthdir_y(430, _foa),
                     10, 22, 2.2, 0.6);
    }

    scr_impact_pulse(0.4, 0.9, 0.7, _k_fin_cx, _k_fin_cy);
    scr_add_light(_k_fin_cx, _k_fin_cy, _k_fin_orb_hot, 8);
    global_ripple_pulse = max(global_ripple_pulse, 0.55);
    _fin_lb = max(_fin_lb, _k_fin_lb_open);
    if (instance_exists(oCameraController)) {
      oCameraController.shake = max(oCameraController.shake, 9);
    }
  }

  while (fin_spear_index < array_length(_k_fin_throw_beats)) {
    var _sbi = fin_spear_index;
    var _sbt = _k_fin_throw_beats[_sbi];
    if (t < _sbt) break;
    if (t <= _sbt + 8) scr_start_bass_ring(_sbi);
    fin_spear_index++;
  }

  var _fin_can_hit = instance_exists(oPlayer) && !oPlayer.dead
                     && oPlayer.invincible_timer <= 0 && !instance_exists(oGameover);

  for (var _ri = array_length(bass_rings) - 1; _ri >= 0; _ri--) {
    var _ring = bass_rings[_ri];
    var _ki = _ring.idx;
    var _kx = 1.5 + _ring.idx * 1.5;
    var _lb_from = (_ki > 0) ? _k_fin_lb_after[_ki - 1] : _k_fin_lb_open;
    _ring.timer++;
    _ring.age++;

    var _rot_p = clamp(_ring.age / max(_ring.rot_f, 1), 0, 1);
    var _rot_e = 1 - power(1 - _rot_p, 3);
    _ring.rot_now = lerp(_ring.rot_start, 0, _rot_e);
    _ring.gap_now = _ring.gap_home + _ring.rot_now;

    for (var _rot_i = 0; _rot_i < array_length(_ring.orbs); _rot_i++) {
      var _rot_b = _ring.orbs[_rot_i];
      if (instance_exists(_rot_b)) _rot_b.ring_angle = _rot_b.ring_home_angle + _ring.rot_now;
    }

    if (_ring.state == "closing") {
      var _cp = clamp(_ring.timer / _ring.close_f, 0, 1);
      var _ce = 1 - power(1 - _cp, 3);

      _ring.anchor_x = lerp(_ring.anchor_x, _fin_pl_x, _k_fin_player_track[_ki]);
      _ring.anchor_y = lerp(_ring.anchor_y, _fin_pl_y, _k_fin_player_track[_ki]);

      _ring.center_x = _ring.anchor_x;
      _ring.center_y = _ring.anchor_y;
      _ring.radius   = lerp(_k_fin_r_spawn[_ki], _k_fin_r_lock[_ki], _ce);

      fin_charge   = max(fin_charge, 0.2 + _cp * 0.35);
      fin_gap_glow = max(fin_gap_glow, 0.25 + _cp * 0.5);
      _fin_lb      = max(_fin_lb, _lb_from);

      for (var _oi = 0; _oi < array_length(_ring.orbs); _oi++) {
        var _cb = _ring.orbs[_oi];
        if (!instance_exists(_cb)) continue;

        var _ctx = _ring.center_x + lengthdir_x(_ring.radius * _cb.layer_mult, _cb.ring_angle);
        var _cty = _ring.center_y + lengthdir_y(_ring.radius * _cb.layer_mult, _cb.ring_angle);

        var _fp = clamp((_ring.timer - _cb.fly_delay) / _k_fin_comet_frames, 0, 1);
        var _fe = 1 - power(1 - _fp, 3);

        var _c1 = 1.9;
        var _c3 = _c1 + 1;
        _cb.pop = clamp(1 + _c3 * power(_fp - 1, 3) + _c1 * power(_fp - 1, 2), 0.15, 1.9);

        var _cpx = _cb.x;
        var _cpy = _cb.y;
        _cb.x = lerp(_cb.fly_x, _ctx, _fe);
        _cb.y = lerp(_cb.fly_y, _cty, _fe);
        _cb.heat = _fp;

        if (!_cb.arrived && _fp >= 1) {
          _cb.arrived = true;
          _cb.flash = 1;
          array_push(bass_ring_pierce_flashes, {
            x : _cb.x, y : _cb.y, life : 9, max_life : 9, size : 0.5, hot : 1
          });
          fin_gap_glow = max(fin_gap_glow, 0.55);
          if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, 2.4);
          }
        }

        var _cd = point_distance(_cpx, _cpy, _cb.x, _cb.y);
        var _cs = clamp(_cd / _k_fin_stretch_div, 0, _k_fin_spear_stretch - 1);
        _cb.image_angle  = (_cd > 0.5) ? point_direction(_cpx, _cpy, _cb.x, _cb.y) : _cb.ring_angle;
        _cb.image_xscale = (1 + _cs) * _cb.pop;
        _cb.image_yscale = max(0.28, 1 - _cs * 0.12) * _cb.pop;
        _cb.image_alpha  = 1;
        _cb.image_blend  = merge_color(_cb.gap_edge ? _k_fin_orb_hot : _k_fin_orb_color, c_white,
                                       clamp(_cs / (_k_fin_spear_stretch - 1), 0, 1) * 0.8 + _cb.flash * 0.5);

        array_push(_cb.spear_trail, {x : _cpx, y : _cpy, w : 1 + _cs});
        if (array_length(_cb.spear_trail) > _k_fin_trail_len) array_delete(_cb.spear_trail, 0, 1);
      }

      if (_ring.timer >= _ring.close_f) {
        _ring.state  = "coil";
        _ring.timer  = 0;
        _ring.lock_x = _ring.center_x;
        _ring.lock_y = _ring.center_y;

        fin_lock_flash = 1;
        fin_charge     = max(fin_charge, 0.6);

        array_push(bass_ring_pierce_flashes, {
          x : _ring.center_x, y : _ring.center_y, life : 14, max_life : 14, size : 1.1, hot : 0.8
        });
        array_push(ring_shockwaves, {
          x : _ring.center_x, y : _ring.center_y,
          radius : _ring.radius * 1.2, max_radius : _ring.radius * 0.5,
          life : 20, max_life : 20, width : 7, hot : 0.65, vs : 1
        });

        vignette_pulse   = max(vignette_pulse, 0.3 + _kx *0.07);
        aberration_pulse = max(aberration_pulse, 0.35 + _kx *0.12);
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 7 + _kx *2);
        }
      }
    }

    else if (_ring.state == "coil") {
      var _lp = clamp(_ring.timer / _ring.coil_f, 0, 1);
      var _le = 1 - power(1 - clamp(_lp / 0.35, 0, 1), 2.4);

      _ring.center_x = _ring.lock_x;
      _ring.center_y = _ring.lock_y;
      _ring.radius   = lerp(_k_fin_r_lock[_ki], _k_fin_r_lock[_ki] + _k_fin_pullback[_ki], _le)
                     + sin(_ring.timer * 0.22) * (1.5 + _lp * 4.5);

      fin_charge   = max(fin_charge, 0.35 + _lp * 0.85);
      fin_chroma   = max(fin_chroma, _lp * (0.45 + _kx *0.16));
      fin_gap_glow = max(fin_gap_glow, 0.55 + _lp * 0.45);
      _fin_lb      = max(_fin_lb, lerp(_lb_from, _k_fin_lb_coil[_ki], _le));

      scr_update_bass_ring_orbs(_ring, _ring.radius);

      var _nb = array_length(_ring.orbs);

      var _span    = (_k_fin_spike_mode[_ki] == 0) ? 360 : 180;
      var _passes  = _k_fin_spike_rehearse[_ki];
      var _phead   = frac(power(_lp, 1.35) * _passes) * _span;
      var _pwidth  = _span * 0.06;
      for (var _pi = 0; _pi < _nb; _pi++) {
        var _pb2 = _ring.orbs[_pi];
        if (!instance_exists(_pb2)) continue;
        var _pd = abs(_pb2.spike_rel - _phead);
        if (_pd < _pwidth) {
          _pb2.flash = max(_pb2.flash, (1 - _pd / _pwidth) * (0.3 + _lp * 0.7));
        }
      }

      if (_nb > 0 && (t mod 2) == 0) {
        var _ab = _ring.orbs[irandom(_nb - 1)];
        if (instance_exists(_ab)) {
          scr_slash_bolt(_ab.x, _ab.y, _ring.center_x, _ring.center_y,
                         5, 8 + _lp * 16, 1.1 + _lp * 1.3, 0.35 + _lp * 0.5);
        }
      }

      if (_nb > 0 && random(1) < 0.08 + _lp * 0.3) {
        var _lb2 = _ring.orbs[irandom(_nb - 1)];
        if (instance_exists(_lb2)) {
          var _lka = point_direction(_ring.center_x, _ring.center_y, _lb2.x, _lb2.y)
                   + random_range(-32, 32);
          scr_slash_bolt(_lb2.x, _lb2.y,
                         _lb2.x + lengthdir_x(60 + random(90), _lka),
                         _lb2.y + lengthdir_y(60 + random(90), _lka),
                         4, 14, 0.9, 0.25);
        }
      }

      if (_ring.timer >= _ring.coil_f) {
        _ring.state = "strike";
        _ring.timer = 0;
        _ring.strike_radius = _ring.radius;

        fin_strike_flash = 1;
        fin_chroma       = max(fin_chroma, 0.7 + _kx *0.1);

        var _cg = [];
        for (var _gi = 0; _gi < array_length(_ring.orbs); _gi++) {
          var _gb = _ring.orbs[_gi];
          if (instance_exists(_gb)) array_push(_cg, {x : _gb.x, y : _gb.y});
        }
        if (array_length(_cg) > 2) array_push(ring_rim_afterglow, {pts : _cg, alpha : 1, hot : 0.8});

        var _spike_last = 0;
        for (var _oj = 0; _oj < array_length(_ring.orbs); _oj++) {
          var _ob = _ring.orbs[_oj];
          if (!instance_exists(_ob)) continue;
          _ob.stagger_delay = round(_ob.spike_rel * _k_fin_spike_rate[_ki]);
          _ob.pierced  = false;
          _ob.released = false;
          if (_ob.stagger_delay > _spike_last) _spike_last = _ob.stagger_delay;
        }

        _ring.spikes_done  = 0;
        _ring.spikes_total = 0;
        for (var _oj = 0; _oj < array_length(_ring.orbs); _oj++) {
          if (instance_exists(_ring.orbs[_oj])) _ring.spikes_total++;
        }

        _ring.conv_total = _spike_last + _ring.conv_f + 8;

        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 6 + _kx *2);
        }
      }
    }

    else if (_ring.state == "strike") {
      _ring.ghost_timer++;

      for (var _oi = 0; _oi < array_length(_ring.orbs); _oi++) {
        var _sb = _ring.orbs[_oi];
        if (!instance_exists(_sb)) continue;

        var _lt = _ring.timer - _sb.stagger_delay;
        if (_lt < 0) {
          _sb.heat = min(1, _sb.heat + 0.12);
          _sb.image_blend = merge_color(_sb.gap_edge ? _k_fin_orb_hot : _k_fin_orb_color, c_white,
                                        0.3 + 0.35 * (0.5 + 0.5 * sin(fin_heartbeat_phase * 2)));
          if (array_length(_sb.spear_trail) > 0) array_delete(_sb.spear_trail, 0, 1);
          continue;
        }

        if (!_sb.released) {
          _sb.released = true;
          _sb.flash = 1;
        }

        var _sp = clamp(_lt / _ring.conv_f, 0, 1);
        var _se = _sp * _sp * _sp;
        var _sr = lerp(_ring.strike_radius * _sb.layer_mult, 0, _se);

        var _spx = _sb.x;
        var _spy = _sb.y;
        _sb.x = _ring.center_x + lengthdir_x(_sr, _sb.ring_angle);
        _sb.y = _ring.center_y + lengthdir_y(_sr, _sb.ring_angle);

        var _sd = point_distance(_spx, _spy, _sb.x, _sb.y);
        var _ss = clamp(_sd / _k_fin_stretch_div, 0, _k_fin_spear_stretch - 1);
        _sb.image_angle  = (_sd > 0.5) ? point_direction(_spx, _spy, _sb.x, _sb.y) : _sb.ring_angle;
        _sb.image_xscale = 1 + _ss;
        _sb.image_yscale = max(0.22, 1 - _ss * 0.12);
        _sb.image_alpha  = 1;
        _sb.image_blend  = merge_color(_sb.gap_edge ? _k_fin_orb_hot : _k_fin_orb_color, c_white,
                                       clamp(_ss / (_k_fin_spear_stretch - 1), 0, 1));
        _sb.heat = 1;

        array_push(_sb.spear_trail, {x : _spx, y : _spy, w : 1 + _ss});
        if (array_length(_sb.spear_trail) > _k_fin_trail_len) array_delete(_sb.spear_trail, 0, 1);

        if (_fin_can_hit) {
          var _hb = _k_fin_hit_radius + 24;
          if (oPlayer.x >= min(_spx, _sb.x) - _hb && oPlayer.x <= max(_spx, _sb.x) + _hb &&
              oPlayer.y >= min(_spy, _sb.y) - _hb && oPlayer.y <= max(_spy, _sb.y) + _hb &&
              player_meeting_line_width(_spx, _spy, _sb.x, _sb.y, _k_fin_hit_radius)) {
            player_register_hazard_hit();
            _fin_can_hit = false;
          }
        }

        if (!_sb.pierced && _sr < 10) {
          _sb.pierced = true;
          _ring.spikes_done++;
          var _dx = _ring.center_x;
          var _dy = _ring.center_y;
          var _sp_p = _ring.spikes_done / max(_ring.spikes_total, 1);

          if (_ring.spikes_done >= _ring.spikes_total && !_ring.detonated) {
            _ring.detonated = true;

            fin_impact = max(fin_impact, 1 + _kx *0.28);
            fin_core   = max(fin_core, 1.6 + _kx *0.45);
            fin_chroma = max(fin_chroma, 0.9 + _kx *0.1);
            fin_charge = 0;

            array_push(bass_ring_pierce_flashes, {
              x : _dx, y : _dy, life : 16 + _kx *3, max_life : 16 + _kx *3,
              size : 1.5 + _kx *0.5, hot : 1
            });

            array_push(ring_shockwaves, {
              x : _dx, y : _dy, radius : 12, max_radius : 380 + _kx *190,
              life : 24, max_life : 24, width : 8 + _kx *3, hot : 1, vs : 1
            });
            array_push(ring_shockwaves, {
              x : _dx, y : _dy, radius : 26, max_radius : 700 + _kx *260,
              life : 40, max_life : 40, width : 26 + _kx *9, hot : 0.5, vs : 1
            });

            for (var _si = 0; _si < _k_fin_streaks[_ki]; _si++) {
              array_push(ring_streaks, {
                cx : _dx, cy : _dy, vs : 1,
                ang : random(360), dist : random_range(6, 60),
                len : random_range(90, 300 + _kx *90), speed : random_range(15, 30 + _kx *8),
                life : 12 + irandom(14), max_life : 26,
                width : random_range(1.4, 4.4), hot : random_range(0.55, 1)
              });
            }

            var _nang = array_length(_ring.angles);
            for (var _spi = 0; _spi < _k_fin_splatter[_ki]; _spi++) {
              var _sa = (_nang > 0) ? _ring.angles[irandom(_nang - 1)] : random(360);
              var _throw = _sa + 180 + random_range(-14, 14);
              var _sdd = random_range(4, 70 + _kx *22);
              array_push(ring_splatter, {
                x : _dx + lengthdir_x(_sdd, _throw),
                y : _dy + lengthdir_y(_sdd, _throw),
                size : random_range(2, 8 + _kx *2),
                drag_len : random_range(10, 40 + _kx *16),
                drag_ang : _throw,
                alpha : random_range(0.6, 1),
                fade : random_range(0.0035, 0.009),
                hot : 0.3 + random(0.5)
              });
            }

            for (var _ei = 0; _ei < _k_fin_embers[_ki]; _ei++) {
              var _ea = random(360);
              var _ev = random_range(2.5, 8 + _kx *1.6);
              array_push(ring_embers, {
                x : _dx + lengthdir_x(random(26), _ea),
                y : _dy + lengthdir_y(random(26), _ea),
                vx : lengthdir_x(_ev, _ea),
                vy : lengthdir_y(_ev, _ea) - random_range(0.5, 2.4),
                life : 45 + irandom(55), max_life : 100,
                size : random_range(0.1, 0.3), hot : 0.6 + random(0.4)
              });
            }

            for (var _bi = 0; _bi < _k_fin_bolts[_ki]; _bi++) {
              var _ba = random(360);
              var _br = 150 + random(260 + _kx *90);
              scr_slash_bolt(_dx, _dy,
                             _dx + lengthdir_x(_br, _ba), _dy + lengthdir_y(_br, _ba),
                             7 + irandom(5), 16 + _kx *8, 1.4 + _kx *0.35, 0.55 + _kx *0.12);
            }

            if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
            array_push(slash_warps, {
              x : _dx, y : _dy, radius : 26, max_radius : 620 + _kx *260,
              strength : 1.1 + _kx *0.3, life : 26 + _kx *4, life_max : 26 + _kx *4
            });

            if (instance_exists(oCameraController)) {
              oCameraController.shake       = max(oCameraController.shake, _k_fin_shake[_ki]);
              oCameraController.zoom_punch  = max(oCameraController.zoom_punch, _k_fin_punch[_ki]);
              oCameraController.angle_kick += fin_roll_sign * _k_fin_roll[_ki];
              oCameraController.screen_flash_alpha =
                max(oCameraController.screen_flash_alpha, _k_fin_flash[_ki]);

              if (_ki >= array_length(_k_fin_throw_beats) - 1) {
                oCameraController.cam_kick_active = true;
                oCameraController.cam_kick_timer  = 0;
              }
            }
            fin_roll_sign = -fin_roll_sign;
            _fin_lb = _k_fin_lb_after[_ki];

            scr_impact_pulse(0.55 + _kx *0.15, 1.4 + _kx *0.5, 0.9 + _kx *0.25, _dx, _dy);
            scr_bg_bass_hit();
            scr_add_light(_dx, _dy, _k_fin_orb_hot, 9 + _kx *3);
            global_ripple_pulse = max(global_ripple_pulse, 0.7 + _kx *0.16);
            tear_amount         = max(tear_amount, _k_fin_tear[_ki]);
          } else {
            var _sp_hot = 0.35 + _sp_p * 0.65;

            array_push(bass_ring_pierce_flashes, {
              x : _dx, y : _dy, life : 7 + round(_sp_p * 5), max_life : 12,
              size : 0.4 + _sp_p * 0.55, hot : _sp_hot
            });
            fin_core   = min(fin_core + 0.10 + _sp_p * 0.16, 3.2);
            fin_charge = max(fin_charge, 0.45 + _sp_p * 0.5);
            fin_chroma = max(fin_chroma, _sp_p * 0.5);

            array_push(ring_shockwaves, {
              x : _dx, y : _dy,
              radius : 6, max_radius : 40 + _sp_p * 130,
              life : 12 + round(_sp_p * 8), max_life : 20,
              width : 3 + _sp_p * 6, hot : _sp_hot, vs : 1
            });

            for (var _rs = 0; _rs < _k_fin_spike_streaks[_ki]; _rs++) {
              array_push(ring_streaks, {
                cx : _dx, cy : _dy, vs : 1,
                ang : _sb.ring_angle + random_range(-26, 26),
                dist : random_range(4, 26), len : random_range(70, 150 + _sp_p * 140),
                speed : random_range(16, 28 + _sp_p * 12), life : 8 + irandom(9), max_life : 17,
                width : random_range(1, 2.4 + _sp_p * 1.6), hot : random_range(0.5, 1)
              });
            }

            if (_sp_p > 0.45) {
              scr_slash_bolt(_dx, _dy,
                             _dx + lengthdir_x(90 + random(150 * _sp_p), _sb.ring_angle),
                             _dy + lengthdir_y(90 + random(150 * _sp_p), _sb.ring_angle),
                             5, 10 + _sp_p * 12, 0.9 + _sp_p * 0.8, 0.3 + _sp_p * 0.35);
              aberration_pulse = max(aberration_pulse, _sp_p * 0.35);
            }

            scr_add_light(_dx, _dy, _k_fin_orb_hot, 3 + _sp_p * 4);
            if (instance_exists(oCameraController)) {
              oCameraController.shake = max(oCameraController.shake,
                                            _k_fin_spike_shake[_ki] * (0.45 + _sp_p));
            }
          }
        }
      }

      if (_ring.ghost_timer >= _k_fin_ghost_every) {
        _ring.ghost_timer = 0;
        var _gp = [];
        for (var _gj = 0; _gj < array_length(_ring.orbs); _gj++) {
          var _gc = _ring.orbs[_gj];
          if (instance_exists(_gc) && _gc.released) array_push(_gp, {x : _gc.x, y : _gc.y});
        }
        if (array_length(_gp) > 2) {
          array_push(fin_ghosts, {
            pts : _gp, alpha : 0.85, fade : 0.11, hot : 0.55 + _kx *0.1, width : 2
          });
        }
      }

      if (_ring.timer >= _ring.conv_total) {
        for (var _oi = 0; _oi < array_length(_ring.orbs); _oi++) {
          if (instance_exists(_ring.orbs[_oi])) instance_destroy(_ring.orbs[_oi]);
        }
        array_delete(bass_rings, _ri, 1);
      }
    }
  }

  while (fin_shell_index < array_length(_k_fin_shell_beats)) {
    var _shi = fin_shell_index;
    var _shb = _k_fin_shell_beats[_shi] - _k_fin_shell_lead;
    var _sht = _shb - _k_fin_shell_arm[_shi] - _k_fin_shell_slam[_shi];
    if (t < _sht) break;
    if (t <= _shb) fin_start_shell(_shi);
    fin_shell_index++;
  }

  scr_update_vent_streams(fin_shell_vents);

  for (var _ss = array_length(fin_shell_sparks) - 1; _ss >= 0; _ss--) {
    var _spk = fin_shell_sparks[_ss];
    _spk.x += _spk.vx;
    _spk.y += _spk.vy;
    _spk.vx *= 0.938;
    _spk.vy *= 0.938;

    if (fin_implode > 0.01) {
      var _spa = point_direction(_spk.x, _spk.y, _k_fin_cx, _k_fin_cy);
      _spk.vx += lengthdir_x(fin_implode * 1.5, _spa);
      _spk.vy += lengthdir_y(fin_implode * 1.5, _spa);
    }

    _spk.life--;
    if (_spk.life <= 0) array_delete(fin_shell_sparks, _ss, 1);
  }

  for (var _sg = array_length(fin_shell_ghosts) - 1; _sg >= 0; _sg--) {
    fin_shell_ghosts[_sg].alpha -= _k_fin_shell_ghost_fade;
    if (fin_shell_ghosts[_sg].alpha <= 0) array_delete(fin_shell_ghosts, _sg, 1);
  }

  for (var _shq = array_length(fin_shells) - 1; _shq >= 0; _shq--) {
    var _sh = fin_shells[_shq];
    var _si = _sh.idx;
    var _sw = (_si / max(array_length(_k_fin_shell_beats) - 1, 1)) * 1.5;

    _sh.age++;
    _sh.land_flash = max(0, _sh.land_flash - 0.06);
    _sh.ring       = max(0, _sh.ring - 0.055);

    if (_sh.state == "arm") {
      _sh.timer++;
      _sh.arm_p = clamp(_sh.timer / max(_sh.arm_f, 1), 0, 1);

      var _arm_e = 1 - power(1 - _sh.arm_p, 2.2);
      _sh.rot    = lerp(_sh.rot_from, _sh.rot_to,
                        _arm_e * (_sh.arm_f / max(_sh.arm_f + _sh.slam_f, 1)));
      _sh.radius = lerp(_sh.r_out * _k_fin_shell_arm_drift, _sh.r_out, _arm_e)
                 * (1 + fin_heartbeat * 0.012);

      for (var _vi = 0; _vi < _sh.sides; _vi++) {
        if (random(1) >= _k_fin_shell_vent[_si]) continue;
        var _vw = fin_shell_wall(_sh, _vi);
        var _vf = random_range(-0.85, 0.85);
        scr_spawn_vent_stream(fin_shell_vents,
                              lerp(_vw.x1, _vw.x2, 0.5 + _vf * 0.5),
                              lerp(_vw.y1, _vw.y2, 0.5 + _vf * 0.5),
                              _vw.ang + 180 + random_range(-9, 9),
                              0.35 + _sh.arm_p * 0.5 + _sw * 0.16,
                              undefined, _k_fin_shell_vent_max);
      }

      if ((t mod 3) == 0) {
        var _aw = fin_shell_wall(_sh, irandom(_sh.sides - 1));
        var _af = random(1);
        fin_shell_spark(lerp(_aw.x1, _aw.x2, _af), lerp(_aw.y1, _aw.y2, _af),
                        _aw.ang + 180 + random_range(-22, 22),
                        random_range(1.4, 3.6), _sh.hot * 0.6);
      }

      fin_charge = max(fin_charge, 0.24 + _sh.arm_p * (0.34 + _sw * 0.16));
      fin_chroma = max(fin_chroma, _sh.arm_p * (0.18 + _sw * 0.14));
      _fin_lb    = max(_fin_lb, lerp(0.16, _k_fin_lb_fill, (_si + _sh.arm_p) / 4));

      if (_sh.timer >= _sh.arm_f) {
        _sh.state = "slam";
        _sh.timer = 0;
        _sh.slam_from = _sh.radius;
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, 3 + _sw * 2);
        }
      }
    }

    else if (_sh.state == "slam") {
      _sh.timer++;
      var _sp  = clamp(_sh.timer / max(_sh.slam_f, 1), 0, 1);
      var _se  = _sp * _sp * _sp;
      var _prev_r = _sh.radius;

      _sh.radius = lerp(_sh.slam_from, _sh.r_lock, _se);
      _sh.rot    = lerp(_sh.rot_from, _sh.rot_to,
                        (_sh.arm_f + _sh.timer) / max(_sh.arm_f + _sh.slam_f, 1));

      var _band = (_prev_r - _sh.radius) + _k_fin_shell_drag_pad;
      for (var _de = 0; _de < array_length(ring_embers); _de++) {
        var _dem = ring_embers[_de];
        var _dd  = point_distance(_dem.x, _dem.y, _k_fin_cx, _k_fin_cy);
        if (_dd > _sh.radius + _band || _dd < _sh.radius - 20) continue;
        var _da = point_direction(_dem.x, _dem.y, _k_fin_cx, _k_fin_cy);
        _dem.vx += lengthdir_x(_k_fin_shell_drag_in * _sp, _da);
        _dem.vy += lengthdir_y(_k_fin_shell_drag_in * _sp, _da);
      }

      if (_fin_can_hit) {
        for (var _hs = 0; _hs < _sh.sides && _fin_can_hit; _hs++) {
          for (var _hi = 1; _hi <= 3 && _fin_can_hit; _hi++) {
            var _hr = lerp(_prev_r, _sh.radius, _hi / 3);
            var _probe = { sides : _sh.sides, radius : _hr, rot : _sh.rot, span : _sh.span };
            var _hw = fin_shell_wall(_probe, _hs);

            if (point_distance(oPlayer.x, oPlayer.y, _hw.cx, _hw.cy) > _hw.hl + 48) continue;

            var _hspan = fin_shell_gap_span(_sh, _hw);
            for (var _hp = 0; _hp < 2 && _fin_can_hit; _hp++) {
              var _f0 = (_hp == 0) ? 0 : _hspan[1];
              var _f1 = (_hp == 0) ? _hspan[0] : 1;
              if (_f1 - _f0 < 0.001) continue;

              if (player_meeting_line_width(lerp(_hw.x1, _hw.x2, _f0), lerp(_hw.y1, _hw.y2, _f0),
                                            lerp(_hw.x1, _hw.x2, _f1), lerp(_hw.y1, _hw.y2, _f1),
                                            _k_fin_shell_hit_r)) {
                player_register_hazard_hit();
                _fin_can_hit = false;
              }
            }
          }
        }
      }

      for (var _sl = 0; _sl < _sh.sides; _sl++) {
        var _lw = fin_shell_wall(_sh, _sl);
        for (var _lk = 0; _lk < 1 + _si; _lk++) {
          var _lf = random(1);
          fin_shell_spark(lerp(_lw.x1, _lw.x2, _lf), lerp(_lw.y1, _lw.y2, _lf),
                          _lw.ang + random_range(-150, 150),
                          random_range(1.6, 4.8) * (0.6 + _sp),
                          _sh.hot);
        }
      }

      _sh.ghost_t++;
      if (_sh.ghost_t >= _k_fin_shell_ghost_every) {
        _sh.ghost_t = 0;
        array_push(fin_shell_ghosts, {
          segs  : fin_shell_segments(_sh),
          alpha : 0.7 + _sw * 0.12,
          col   : _sh.col,
          hot   : _sh.hot,
          width : 1.6 + _sw * 0.7
        });
      }

      fin_charge = max(fin_charge, 0.45 + _sp * (0.4 + _sw * 0.2));
      fin_chroma = max(fin_chroma, 0.25 + _sp * (0.35 + _sw * 0.2));
      _fin_lb    = max(_fin_lb, lerp(0.16, _k_fin_lb_fill, (_si + 1) / 4));

      if (_sh.timer >= _sh.slam_f) {
        _sh.state  = "burn";
        _sh.timer  = 0;
        _sh.radius = _sh.r_lock;
        _sh.rot    = _sh.rot_to;
        _sh.land_flash = 1;
        _sh.r_target   = _sh.r_lock;

        var _last = (_si >= array_length(_k_fin_shell_beats) - 1);

        fin_impact       = max(fin_impact, 0.45 + _sw * 0.30);
        fin_core         = max(fin_core, 0.9 + _sw * 0.6);
        fin_chroma       = max(fin_chroma, 0.5 + _sw * 0.34);
        fin_strike_flash = max(fin_strike_flash, 0.55 + _sw * 0.3);
        fin_charge       = 0;

        var _rank = 1;
        for (var _kn = array_length(fin_shells) - 1; _kn >= 0; _kn--) {
          var _ksh = fin_shells[_kn];
          if (_ksh == _sh || _ksh.state != "burn") continue;
          _ksh.r_target   = min(_ksh.r_target,
                                max(_sh.r_lock, 12) * power(_k_fin_shell_ladder, _rank));
          _ksh.ring       = 1;
          _ksh.land_flash = max(_ksh.land_flash, 0.7);
          _rank++;
        }

        for (var _pw = 0; _pw < _sh.sides; _pw++) {
          var _lw2 = fin_shell_wall(_sh, _pw);

          scr_floor_impact(_lw2.cx, _lw2.cy, 0.42 + _sw * 0.3, -1, _sh.col);
          scr_add_light(_lw2.cx, _lw2.cy, _sh.col, 5 + _sw * 4);

          scr_slash_bolt(_lw2.x1, _lw2.y1, _k_fin_cx, _k_fin_cy,
                         7 + irandom(5), 14 + _sw * 12, 1.2 + _sw * 0.7,
                         0.5 + _sw * 0.3, _sh.col);
          scr_slash_bolt(_lw2.x2, _lw2.y2, _k_fin_cx, _k_fin_cy,
                         7 + irandom(5), 14 + _sw * 12, 1.2 + _sw * 0.7,
                         0.5 + _sw * 0.3, _sh.col);

          var _nsp = ceil(_k_fin_shell_sparks[_si] / _sh.sides);
          for (var _sk = 0; _sk < _nsp; _sk++) {
            var _skf = random(1);
            fin_shell_spark(lerp(_lw2.x1, _lw2.x2, _skf), lerp(_lw2.y1, _lw2.y2, _skf),
                            _lw2.ang + 90 + choose(0, 180) + random_range(-34, 34),
                            random_range(2.5, 8 + _sw * 3), _sh.hot);
          }

          for (var _st = 0; _st < 4 + _si * 2; _st++) {
            array_push(ring_streaks, {
              cx : _lw2.cx, cy : _lw2.cy, vs : 1,
              ang : _lw2.ang + 180 + random_range(-30, 30),
              dist : random_range(-20, 24),
              len : random_range(90, 220 + _sw * 110),
              speed : random_range(14, 26 + _sw * 8),
              life : 10 + irandom(11), max_life : 21,
              width : random_range(1.2, 3.2 + _sw * 1.4),
              hot : random_range(0.5, 1), col : _sh.col
            });
          }
        }

        for (var _bz = 0; _bz < _k_fin_shell_bolts[_si]; _bz++) {
          var _bza = random(360);
          var _bzr = 160 + random(280 + _sw * 150);
          scr_slash_bolt(_k_fin_cx, _k_fin_cy,
                         _k_fin_cx + lengthdir_x(_bzr, _bza),
                         _k_fin_cy + lengthdir_y(_bzr, _bza),
                         6 + irandom(5), 16 + _sw * 10, 1.3 + _sw * 0.5,
                         0.55 + _sw * 0.2, _sh.col);
        }

        array_push(ring_shockwaves, {
          x : _k_fin_cx, y : _k_fin_cy, radius : 10,
          max_radius : _sh.r_lock + 260 + _sw * 180,
          life : 22 + _si * 3, max_life : 22 + _si * 3,
          width : 8 + _sw * 7, hot : 0.85, vs : 1, col : _sh.col
        });
        array_push(ring_shockwaves, {
          x : _k_fin_cx, y : _k_fin_cy, radius : _sh.r_out * 0.8,
          max_radius : max(12, _sh.r_lock),
          life : 30 + _si * 4, max_life : 30 + _si * 4,
          width : 18 + _sw * 12, hot : 0.45 + _sw * 0.2, vs : 1, col : _sh.col
        });

        array_push(bass_ring_pierce_flashes, {
          x : _k_fin_cx, y : _k_fin_cy,
          life : 12 + _si * 2, max_life : 12 + _si * 2,
          size : 0.7 + _sw * 0.6, hot : 0.7 + _sw * 0.2
        });

        if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
        array_push(slash_warps, {
          x : _k_fin_cx, y : _k_fin_cy,
          radius : max(20, _sh.r_lock), max_radius : 520 + _sw * 260,
          strength : 0.9 + _sw * 0.5, life : 24 + _si * 3, life_max : 24 + _si * 3
        });

        if (instance_exists(oCameraController)) {
          oCameraController.shake      = max(oCameraController.shake, _k_fin_shell_shake[_si]);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_fin_shell_punch[_si]);
          oCameraController.angle_kick += fin_roll_sign * _k_fin_shell_roll[_si];
          oCameraController.screen_flash_alpha =
            max(oCameraController.screen_flash_alpha, _k_fin_shell_flash[_si]);
        }
        fin_roll_sign = -fin_roll_sign;

        scr_impact_pulse(0.34 + _sw * 0.24, 0.8 + _sw * 0.62, 0.7 + _sw * 0.42,
                         _k_fin_cx, _k_fin_cy);
        scr_bg_bass_hit();
        scr_add_light(_k_fin_cx, _k_fin_cy, _sh.col, 8 + _sw * 5);
        global_ripple_pulse = max(global_ripple_pulse, 0.45 + _sw * 0.3);
        aberration_pulse    = max(aberration_pulse, 0.35 + _sw * 0.4);
        tear_amount         = max(tear_amount, _k_fin_shell_tear[_si]);
        _fin_lb             = max(_fin_lb, lerp(0.16, _k_fin_lb_fill, (_si + 1) / 4));

        if (_last) {
          fin_breath_active = true;

          for (var _swl = 0; _swl < array_length(fin_shells); _swl++) {
            var _wsh = fin_shells[_swl];
            _wsh.state = "swallow";
            _wsh.timer = 0;
            _wsh.land_flash = max(_wsh.land_flash, 0.85);
          }

          for (var _fm2 = 0; _fm2 < 40; _fm2++) {
            array_push(fin_motes, {
              ang   : random(360),
              dist  : 200 + random(420),
              speed : random_range(2.5, 7),
              spin  : random_range(-2.4, 2.4),
              hot   : 0.6 + random(0.4),
              size  : random_range(0.08, 0.26)
            });
          }
        }
      }
    }

    else if (_sh.state == "burn") {
      _sh.timer++;
      _sh.radius = lerp(_sh.radius, _sh.r_target, _k_fin_shell_creep);
      _sh.rot   += _k_fin_shell_drift * (1 + _si * 0.35) * ((_si mod 2) ? -1 : 1);
      _sh.burn   = max(0.22, _sh.burn - 0.0022);

      if (random(1) < 0.28 + _sh.ring * 0.5) {
        var _bw = fin_shell_wall(_sh, irandom(_sh.sides - 1));
        var _bf = random(1);
        fin_shell_spark(lerp(_bw.x1, _bw.x2, _bf), lerp(_bw.y1, _bw.y2, _bf),
                        _bw.ang + 180 + random_range(-40, 40),
                        random_range(1, 3.4), _sh.hot * 0.75);
      }

      fin_charge = max(fin_charge, 0.10 + _sh.ring * 0.45);
      fin_chroma = max(fin_chroma, _sh.ring * 0.4);
    }

    else if (_sh.state == "swallow") {
      _sh.timer++;
      _sh.radius = max(0, _sh.radius * _k_fin_shell_swallow[_si] - 2.4);
      _sh.rot   += 2.4 + _sh.timer * 0.42 + _si * 0.8;
      _sh.burn   = max(0, _sh.burn - 0.016);

      if ((t mod 2) == 0 && _sh.sides >= 3) {
        var _vw2 = fin_shell_wall(_sh, irandom(_sh.sides - 1));
        fin_shell_spark(_vw2.cx, _vw2.cy,
                        point_direction(_vw2.cx, _vw2.cy, _k_fin_cx, _k_fin_cy)
                        + random_range(-18, 18),
                        random_range(3, 7), _sh.hot);
      }

      if (_sh.radius <= 6 || _sh.burn <= 0) {
        fin_core = min(fin_core + 0.14 + _sw * 0.07, 2.4);
        array_push(bass_ring_pierce_flashes, {
          x : _k_fin_cx, y : _k_fin_cy, life : 10, max_life : 10,
          size : 0.5 + _sw * 0.35, hot : 0.8
        });
        scr_add_light(_k_fin_cx, _k_fin_cy, _sh.col, 6 + _sw * 3);
        array_delete(fin_shells, _shq, 1);
      }
    }
  }

  if (t >= _k_fin_t_breath && t < _k_fin_t_cut) {
    fin_breath_active = true;
    var _bp = clamp((t - _k_fin_t_breath) / max(_k_fin_t_cut - _k_fin_t_breath, 1), 0, 1);

    vignette_pulse = max(vignette_pulse, 0.35 + _bp * 0.62);
    bloom_pulse    = max(bloom_pulse, 0.3 + fin_core * 0.22);
    _fin_lb        = max(_fin_lb, lerp(_k_fin_lb_fill, _k_fin_breath_lb, _bp));

    var _feeding = (t < _k_fin_t_cut - _k_fin_still_frames);

    if (_feeding && array_length(fin_motes) < _k_fin_mote_max) {
      var _mrate = 1 + floor(_k_fin_mote_rate * _bp);
      for (var _mi = 0; _mi < _mrate; _mi++) {
        array_push(fin_motes, {
          ang   : random(360),
          dist  : 340 + random(420),
          speed : 1 + random(2.5),
          spin  : random_range(-1.6, 1.6),
          hot   : 0.4 + random(0.6),
          size  : random_range(0.06, 0.2)
        });
      }
    }

    var _pull = 0.5 + _bp * 2.6;
    for (var _pe = 0; _pe < array_length(ring_embers); _pe++) {
      var _pem = ring_embers[_pe];
      if (point_distance(_pem.x, _pem.y, _k_fin_cx, _k_fin_cy) < 14) continue;
      var _pa = point_direction(_pem.x, _pem.y, _k_fin_cx, _k_fin_cy);
      _pem.vx += lengthdir_x(_pull, _pa);
      _pem.vy += lengthdir_y(_pull, _pa);
      _pem.life = min(_pem.life + 1, _pem.max_life);
    }
    for (var _pp = 0; _pp < array_length(arrow_ring_particles); _pp++) {
      var _ppt = arrow_ring_particles[_pp];
      var _pa2 = point_direction(_ppt.x, _ppt.y, _k_fin_cx, _k_fin_cy);
      _ppt.vx += lengthdir_x(_pull * 0.8, _pa2);
      _ppt.vy += lengthdir_y(_pull * 0.8, _pa2);
    }

    if (_feeding && random(1) < 0.2 + _bp * 0.7) {
      var _bang = random(360);
      var _bdist = 160 + random(330);
      scr_slash_bolt(_k_fin_cx + lengthdir_x(_bdist, _bang),
                     _k_fin_cy + lengthdir_y(_bdist, _bang),
                     _k_fin_cx, _k_fin_cy,
                     5 + irandom(4), 14 + _bp * 26, 1 + _bp * 1.6, 0.4 + _bp * 0.5);
    }
  }

  while (fin_breath_index < array_length(_k_fin_breath_beats)) {
    if (t < _k_fin_breath_beats[fin_breath_index]) break;
    var _bstr = (fin_breath_index + 1) / array_length(_k_fin_breath_beats);

    fin_heartbeat = max(fin_heartbeat, _bstr);
    fin_core      = max(fin_core, 0.9 + _bstr * 1.9);
    fin_charge    = max(fin_charge, _bstr);

    array_push(ring_shockwaves, {
      x : _k_fin_cx, y : _k_fin_cy,
      radius : 520 - _bstr * 180, max_radius : 8,
      life : 26, max_life : 26, width : 6 + _bstr * 16, hot : _bstr, vs : 1
    });

    for (var _bm = 0; _bm < 8 + floor(_bstr * 18); _bm++) {
      array_push(fin_motes, {
        ang   : random(360),
        dist  : 300 + random(300),
        speed : 3 + random(4) + _bstr * 4,
        spin  : random_range(-2.4, 2.4),
        hot   : 0.6 + random(0.4),
        size  : random_range(0.08, 0.26)
      });
    }

    if (instance_exists(oCameraController)) {
      oCameraController.shake      = max(oCameraController.shake, 6 + _bstr * 20);
      oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05 + _bstr * 0.16);
    }

    scr_impact_pulse(0.3 + _bstr * 0.45, 0.5 + _bstr * 1.2, 0.5 + _bstr * 0.7, _k_fin_cx, _k_fin_cy);
    scr_add_light(_k_fin_cx, _k_fin_cy, _k_fin_orb_hot, 5 + _bstr * 9);
    global_ripple_pulse = max(global_ripple_pulse, 0.35 + _bstr * 0.5);
    aberration_pulse    = max(aberration_pulse, 0.4 + _bstr * 0.9);

    fin_breath_index++;
  }

  if (t >= _k_fin_t_cut - _k_fin_hush_lead && t < _k_fin_t_cut) {
    fin_hush = clamp((t - (_k_fin_t_cut - _k_fin_hush_lead)) / _k_fin_hush_lead, 0, 1);
    var _hu = power(fin_hush, 1.35);

    tear_amount         = min(tear_amount,         lerp(0.85, 0.05, _hu));
    global_ripple_pulse = min(global_ripple_pulse, lerp(1.00, 0.08, _hu));
    aberration_pulse    = min(aberration_pulse,    lerp(1.50, 0.22, _hu));
    bloom_pulse         = min(bloom_pulse,         lerp(1.60, 0.55, _hu));

    fin_core      = min(fin_core,      lerp(2.10, 0.55, _hu));
    fin_impact    = min(fin_impact,    lerp(1.20, 0.15, _hu));
    fin_heartbeat = min(fin_heartbeat, lerp(0.90, 0.22, _hu));
    fin_implode   = min(fin_implode,   lerp(1.00, 0.45, _hu));

    intro_dim_amount = _hu * 0.45;
    vignette_pulse   = max(vignette_pulse, 0.72 + _hu * 0.30);

    if (instance_exists(oCameraController)) {
      oCameraController.shake = min(oCameraController.shake, lerp(26, 5, _hu));
    }
  }

  if (t >= _k_fin_t_cut - _k_fin_blade_lead && t <= _k_fin_t_cut) {
    fin_blade_p = clamp((t - (_k_fin_t_cut - _k_fin_blade_lead) + 1)
                        / (_k_fin_blade_lead + 1), 0, 1);
  }
  else if (t < _k_fin_t_cut) {
    fin_blade_p = 0;
  }

  if (_fin_lb >= 0 && instance_exists(oCameraController)) {
    oCameraController.letterbox_target = _fin_lb;
  }
}

if (timeline_hit(_k_fin_t_cut) && !final_cut_triggered) {
  final_cut_triggered = true;
  final_cut_timer   = 0;
  fin_breath_active = false;
  fin_blade_p       = 1;
  fin_blade_glow    = 1;
  fin_cut_scar      = 1;
  fin_cut_jitter    = 1;

  player_set_stopped(true);
  if (instance_exists(oPlayer)) {
    oPlayer.invincible_timer = max(oPlayer.invincible_timer, room_speed * 12);
  }

  fin_motes        = [];
  fin_shell_sparks = [];
  fin_core         = 1.6;
  fin_impact       = 0.70;
  fin_chroma       = 1.0;
  fin_implode      = 0;
  fin_charge       = 0;
  fin_gap_glow     = 0;

  var _cut      = fin_cut_axis();
  var _cut_ang  = _cut.ang;
  var _cut_half = _cut.half;

  fin_cut_roll_scar();

  slash_center_x = _k_fin_cx;
  slash_center_y = _k_fin_cy;
  slash_amount   = 1;

  scr_bg_bass_hit();
  scr_impact_pulse(0.80, 2.40, 0.95, _k_fin_cx, _k_fin_cy);
  scr_add_light(_k_fin_cx, _k_fin_cy, global.avoid_col_hot, 11);

  vignette_pulse      = max(vignette_pulse, 1);
  global_ripple_pulse = max(global_ripple_pulse, 0.62);
  tear_amount         = 0.26;
  intro_dim_amount    = 0;

  array_push(ring_shockwaves, {
    x : _k_fin_cx, y : _k_fin_cy, radius : 12, max_radius : 820,
    life : 22, max_life : 22, width : 15, hot : 1, vs : 1,
    col : global.avoid_col_warning
  });

  if (array_length(slash_warps) >= _k_slash_warp_max) array_delete(slash_warps, 0, 1);
  array_push(slash_warps, {
    x : _k_fin_cx, y : _k_fin_cy,
    radius : 22, max_radius : 1250,
    strength : 1.9, life : 20, life_max : 20
  });

  for (var _fce = 0; _fce < 46; _fce++) {
    var _fcf = random_range(-0.72, 0.72);
    var _fcs = choose(-1, 1);
    array_push(ring_streaks, {
      cx : _k_fin_cx + lengthdir_x(_cut_half * _fcf, _cut_ang),
      cy : _k_fin_cy + lengthdir_y(_cut_half * _fcf, _cut_ang),
      vs : 1,
      ang   : _cut_ang + 90 * _fcs + random_range(-24, 24),
      dist  : random_range(0, 22),
      len   : random_range(70, 250),
      speed : random_range(11, 27),
      life  : 7 + irandom(11), max_life : 20,
      width : random_range(1.1, 3.4),
      hot   : random_range(0.55, 1),
      col   : choose(global.avoid_col_warning, global.avoid_col_ember,
                     global.avoid_col_hot, global.avoid_col_cyan)
    });
  }

  for (var _fcb = 0; _fcb < 7; _fcb++) {
    var _fb0 = -0.78 + _fcb * 0.24;
    var _fb1 = _fb0 + random_range(0.16, 0.34);
    scr_slash_bolt(_k_fin_cx + lengthdir_x(_cut_half * _fb0, _cut_ang),
                   _k_fin_cy + lengthdir_y(_cut_half * _fb0, _cut_ang),
                   _k_fin_cx + lengthdir_x(_cut_half * _fb1, _cut_ang),
                   _k_fin_cy + lengthdir_y(_cut_half * _fb1, _cut_ang),
                   7 + irandom(6), 16, 1.7, 0.8,
                   choose(global.avoid_col_warning, global.avoid_col_cyan,
                          global.avoid_col_hot));
  }

  if (instance_exists(oCameraController)) {
    oCameraController.shake      = max(oCameraController.shake, _k_final_cut_shake);
    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.30);
    oCameraController.screen_flash_alpha =
      max(oCameraController.screen_flash_alpha, 0.30);
    oCameraController.letterbox_target = 0;
  }
}

if (final_cut_triggered) {
  // for the warp, in case t ever stalls or the music instance dies under us.
  var _fct = t - _k_fin_t_cut;

  // --- the light dies -------------------------------------------------------
  fin_heartbeat = 0;
  fin_implode   = 0;

  if (instance_exists(oPlayer)) {
    oPlayer.invincible_timer = max(oPlayer.invincible_timer, room_speed * 4);
  }

  if (_fct > 0) {
    fin_blade_glow = max(0, fin_blade_glow - 0.22);
    fin_core       = max(0, fin_core       - 0.44);
    fin_impact     = max(0, fin_impact     - 0.18);
    fin_chroma     = max(0, fin_chroma     - 0.13);
    fin_hush       = max(0, fin_hush       - 0.12);
    fin_cut_flare  = max(0, fin_cut_flare  - 0.155);
  }

  fin_cut_flash = (_fct == 0) ? 0.80 : ((_fct == 1) ? 0.30 : ((_fct == 2) ? 0.10 : 0));

  if (_fct <= 8) {
    vignette_pulse = max(vignette_pulse, lerp(1.0, 0.35, _fct / 8));
  }

  // --- the camera reacts one frame after the cut ----------------------------
  if (!fin_cut_kicked && _fct >= 1) {
    fin_cut_kicked = true;
    if (instance_exists(oCameraController)) {
      oCameraController.angle_kick += fin_roll_sign * 8.5;
    }
  }

  slash_center_x = _k_fin_cx;
  slash_center_y = _k_fin_cy;
  if (_fct <= _k_fin_cut_veil_start + 1) slash_amount = 1;
  else                                   slash_amount = max(0, slash_amount - 0.25);

  // --- the cross-dissolve from the live composite to the frozen halves ------
  var _veil_raw = clamp((_fct - _k_fin_cut_veil_start)
                        / max(_k_fin_cut_veil_frames, 1), 0, 1);
  fin_cut_veil = _veil_raw * _veil_raw * (3 - 2 * _veil_raw);

  intro_dim_amount = (_fct >= 1) ? 0.45 * (1 - fin_cut_veil) : 0;

  if (_fct >= 3 && instance_exists(oCameraController)) {
    oCameraController.shake = min(oCameraController.shake, 3);
  }

  // --- the two halves fall out of shot --------------------------------------
  var _fly_raw = clamp((_fct - _k_fin_cut_veil_start)
                       / max(_k_fin_cut_fly_frames, 1), 0, 1);
  fin_cut_fly = power(_fly_raw, 1.75);

  fin_cut_jitter = clamp(1 - fin_cut_fly * 4, 0, 1);

  // --- the ring-out ---------------------------------------------------------
  for (var _flb = 0; _flb < array_length(_k_fin_cut_flare_beats); _flb++) {
    if (!timeline_hit(_k_fin_cut_flare_beats[_flb])) continue;
    var _flp = _k_fin_cut_flare_power[_flb];

    fin_cut_flare = max(fin_cut_flare, _flp);

    var _fl_cut = fin_cut_axis();
    for (var _fli = 0; _fli < 3 + floor(_flp * 7); _fli++) {
      scr_slash_bolt(_k_fin_cx + lengthdir_x(_fl_cut.half * random_range(-0.8, 0.8), _fl_cut.ang),
                     _k_fin_cy + lengthdir_y(_fl_cut.half * random_range(-0.8, 0.8), _fl_cut.ang),
                     _k_fin_cx + lengthdir_x(_fl_cut.half * random_range(-0.8, 0.8), _fl_cut.ang),
                     _k_fin_cy + lengthdir_y(_fl_cut.half * random_range(-0.8, 0.8), _fl_cut.ang),
                     5 + irandom(5), 12 * _flp, 1.3, 0.7,
                     choose(global.avoid_col_warning, global.avoid_col_hot));
    }

    fin_cut_push_embers(round(6 + _flp * 14), 2.0 + _flp * 5.0, false);
  }

  // --- the wound, cooling, re-lit by every aftershock ------------------------
  var _cool_raw = clamp((_fct - 2) / max(_k_fin_cut_cool_frames, 1), 0, 1);
  fin_cut_scar = max(1 - _cool_raw * 0.84, 0.30 + fin_cut_flare * 0.70);

  // --- and then dying back from both ends toward one bright bar -------------
  var _span_raw = clamp((_fct - _k_fin_cut_span_start)
                        / max(_k_fin_cut_span_frames, 1), 0, 1);
  fin_cut_span = lerp(_k_fin_cut_span_max, _k_fin_cut_span_min,
                      _span_raw * _span_raw * (3 - 2 * _span_raw));

  fin_cut_release = clamp((_fct - _k_fin_cut_release_t)
                          / max(_k_fin_cut_release_len, 1), 0, 1);

  // --- embers ---------------------------------------------------------------
  if (_fct <= 10) {
    fin_cut_push_embers((_fct == 0) ? 26 : max(1, 7 - floor(_fct * 0.5)), 1, true);
  }
  else if (_fct >= _k_fin_cut_drip_from && fin_cut_span > _k_fin_cut_span_min + 0.02
           && (_fct mod _k_fin_cut_drip_every) == 0) {
    fin_cut_push_embers(1 + irandom(1), 0.5 + fin_cut_scar * 0.5, false);
  }

  for (var _spu = array_length(final_cut_sparks) - 1; _spu >= 0; _spu--) {
    var _spk2 = final_cut_sparks[_spu];
    _spk2.x  += _spk2.vx;
    _spk2.y  += _spk2.vy;
    _spk2.vx *= 0.985;
    _spk2.vy  = _spk2.vy * 0.985 + 0.055;
    _spk2.life--;
    if (_spk2.life <= 0) array_delete(final_cut_sparks, _spu, 1);
  }

  final_cut_timer++;
}

// case and for a stalled music instance; without it a collapsed t would strand
if (final_cut_triggered && !song_end_handled &&
    (t >= _k_fin_t_end - _k_fin_seal_lead || final_cut_timer >= _k_fin_cut_timeout)) {
  song_end_handled = true;

  var _practice_run =
    variable_global_exists("avoidance_practice_active") &&
    global.avoidance_practice_active;
  var _hitcount_run =
    variable_global_exists("hitcount_mode") &&
    global.hitcount_mode;

  var _clear_room = rMainHub;

  if (!_practice_run) {
    var _prev_best = savedata_get_active("avoidance_best_hits");
    if (_prev_best < 0 || hit_count < _prev_best) {
      savedata_set_active("avoidance_best_hits", hit_count);
    }

    savedata_save("avoidance_best_hits", "time");

    _clear_room = (_hitcount_run && hit_count > 0) ? rMainHub : rEnd;
  }

  with (oFinalCutWarp) instance_destroy();
  var _fin_warp = instance_create_depth(0, 0, -15000, oFinalCutWarp);

  if (instance_exists(_fin_warp)) {
    _fin_warp.fw_target_room = _clear_room;
    _fin_warp.fw_source_room = room;
    _fin_warp.fw_span0       = clamp(fin_cut_span, 0.06, 1);
    _fin_warp.fw_scar_pts    = fin_cut_scar_pts;
    _fin_warp.fw_adopt_sparks(final_cut_sparks);
    _fin_warp.fw_push_sparks(34, 1);
  }
  else {
    player_set_stopped(false);
    if (instance_exists(oPlayer)) {
      oPlayer.invincible_timer = min(oPlayer.invincible_timer, room_speed);
      warp(_clear_room, oPlayer);
    } else {
      room_goto(_clear_room);
    }
  }
}

var _screen_fx_source_tear_cap = 0.82;
var _screen_fx_source_ripple_cap = 0.90;
var _screen_fx_source_aberration_cap = 1.25;
if (t >= 2597 && t < 3331) {
  _screen_fx_source_tear_cap = 0.95;
  _screen_fx_source_ripple_cap = 1.00;
}

tear_amount = min(tear_amount, _screen_fx_source_tear_cap);
global_ripple_pulse = min(global_ripple_pulse, _screen_fx_source_ripple_cap);
aberration_pulse = min(aberration_pulse, _screen_fx_source_aberration_cap);

if (bc_profile_active) {
  bc_profile_frame++;
  var _bc_profile_fps = fps_real;
  if (_bc_profile_fps > 0) {
    bc_profile_samples++;
    bc_profile_fps_sum += _bc_profile_fps;
    bc_profile_fps_min = min(bc_profile_fps_min, _bc_profile_fps);
  }
  else {
    bc_profile_invalid_samples++;
  }

  if (bc_profile_frame >= bc_profile_target_frames) {
    var _bc_profile_avg = bc_profile_fps_sum / max(1, bc_profile_samples);
    var _bc_profile_min = (bc_profile_samples > 0) ? bc_profile_fps_min : 0;
    var _bc_profile_surfaces_ok =
      surface_exists(scene_snapshot) &&
      surface_exists(bolt_surface) &&
      surface_exists(glow_surface);

    show_debug_message("[BC_PROFILE] end " + bc_profile_segment_name +
      " frames=" + string(bc_profile_frame) +
      " t=" + string(t) +
      " fps_min=" + string(_bc_profile_min) +
      " fps_avg=" + string(_bc_profile_avg) +
      " fps_invalid=" + string(bc_profile_invalid_samples) +
      " surfaces_ok=" + string(_bc_profile_surfaces_ok));

    global.bc_cli_profile_index++;
    bc_profile_active = false;

    if (global.bc_cli_profile_index < array_length(global.bc_cli_profile_segments)) {
      var _bc_next_segment = global.bc_cli_profile_segments[global.bc_cli_profile_index];
      global.debug_resume_t = _bc_next_segment.t;
      room_restart();
    }
    else {
      show_debug_message("[BC_PROFILE] complete");
      global.bc_cli_profile_enabled = false;
      if (global.bc_cli_profile_quit_on_complete)
        game_end();
    }
  }
}
