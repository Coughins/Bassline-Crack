event_inherited();

is_popped = false;
materialize_timer = 0;
materialize_duration = 20 + irandom(10);
idle_pulse_phase = random(2 * pi);
pop_timer = 0;
spawn_x = x;
spawn_y = y;

laser_seed_drift_active = false;
laser_seed_drift_timer = 0;
laser_seed_drift_duration = 1;
laser_seed_drift_start_x = x;
laser_seed_drift_target_x = x;

laser_spiral_orb = false;
laser_spawn_delay = 0;

_k_idle_alpha_min = 0.05;
_k_idle_alpha_max = 0.18;
_k_idle_pulse_speed = 0.05;
_k_idle_bob_amount = 3;
_k_idle_bob_speed = 0.03;

_k_pop_grow_frames = 6;
_k_pop_shrink_frames = 18;

_k_glow_radius_base    = 24;
_k_glow_color          = c_red;

_k_pop_flash_duration       = 6;
pop_flash_timer = 0;
_k_pop_overshoot_scale = 1.5;
_k_glow_intensity_base = 0.9;
_k_pop_flash_intensity_mult = 1.8;
_k_pop_settle_frames = 10;
shrink_timer = 0;

_k_pop_flash_peak_scale = 1.8;
_k_sustained_glow_color = global.avoid_col_danger;
_k_core_flash_color = make_color_rgb(255, 255, 240);
_k_core_peak_intensity = 1.8;
_k_core_peak_scale = 1.0;

_k_spawn_flash_color = c_white;
_k_spawn_flash_peak_intensity = 1.6;
_k_spawn_flash_peak_scale = 1.6;

_k_shockwave_radius_base = 30;
_k_shockwave_speed       = 5;
_k_shockwave_alpha_start = 0.6;
_k_shockwave_color       = c_white;

shockwave_radius     = 0;
shockwave_max_radius = 0;
shockwave_alpha      = 0;
shockwave_active     = false;

trail_positions = [];
_k_edge_glow_color        = c_red;
_k_edge_glow_intensity    = 0.5;
_k_edge_glow_pulse_speed  = 0.08;
_k_edge_glow_scale        = 1.6;
_k_edge_glow_margin       = 20;
edge_glow_phase = random(2 * pi);
has_left_screen = false;
warning_suppressed = false;
_k_edge_chevron_length      = 26;
_k_edge_chevron_width       = 14;
_k_edge_chevron_tip_color   = c_white;
_k_edge_chevron_base_color  = c_red;
_k_edge_chevron_pulse_min   = 0.85;
_k_edge_chevron_pulse_max   = 1.15;
_k_edge_chevron_halo_growth = 0.35;
_k_edge_chevron_halo_alpha  = 0.22;
_k_edge_dist_max        = 2000;
_k_edge_dist_alpha_min  = 0;
_k_edge_dist_alpha_max  = 1.0;
_k_edge_dist_scale_min  = 0.7;
_k_edge_dist_scale_max  = 1.5;

gravity = 0;
gravity_direction = 0;
gravity_activated = false;
pop_persist = false;
trail_positions = [];

_k_shrapnel_count = 4;
_k_shrapnel_speed = 6;

chain_break_fired = false;

base_scale = 1;
idle_alpha_max_override = _k_idle_alpha_max;
idle_alpha_min_override = _k_idle_alpha_min;

spawn_flash_timer = 0;
spawn_flash_duration = 10;

glow_enabled = false;

laser_meteor_visual = false;
laser_meteor_spin_seed = random(360);
laser_meteor_core_phase = random(1000);

image_alpha = 0;
image_xscale = 0;
image_yscale = 0;
hit_active = false;
laser_pop_enabled = true;

deadly_while_idle = true;
