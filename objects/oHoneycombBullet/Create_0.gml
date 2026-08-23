event_inherited();

grid_col = 0;
grid_row = 0;
honeycomb_angle  = 0;
honeycomb_height = 0;
honeycomb_depth  = 0;

spec_index = -1;

draw_x = x;
draw_y = y;
draw_scale = 1;
draw_alpha = 1;
is_open = false;
is_lane_gap = false;
is_corner = false;

ignited = false;
ignite_flash = 0;
shimmer_phase = 0;

spawn_timer = 0;
spawn_duration = 26;
spawn_complete = false;

last_pulse_id = 0;
pulse_scale = 1;

pulse_glow = 0;
pulse_glow_timer = 0;

ring_heat = 0;
prox_heat = 0;

image_blend  = c_white;
hit_active = false;
hit_alpha_min = 0.12;

despawning = false;
despawn_timer = 0;
despawn_duration = 60;

blast_active = false;
blast_dir = 0;
blast_speed = 0;
blast_spin = 0;
blast_angle = 0;

last_depth_bucket = 99999;
