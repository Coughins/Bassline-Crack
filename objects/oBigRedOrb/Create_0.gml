event_inherited();
pop_scale = 1;
pop_target = 1;
pop_speed = 0.2;
pop_shrinking = false;

squash_x = 1;
squash_y = 1;

dash_speed = 0;
dash_dir = 0;
dash_time = 0;
is_dashing = false;

trail_positions = [];
pop_trail_active = false;

shockwave_timer = -1;
shockwave_max_frames = 20;

telegraph_x = 0;
telegraph_y = 0;
telegraph_timer = 0;
telegraph_max = 20;

speed = 0;
image_speed = 0;

orbiting        = false;
orbit_center_x  = 0;
orbit_center_y  = 0;
orbit_radius    = 0;
orbit_squash    = 0.4;
orbit_tilt_rad  = 0;
orbit_angle     = 0;
orbit_speed     = 1.5;
orbit_dir       = 1;

transitioning    = false;
trans_timer      = 0;
trans_duration   = 20;
trans_start_x    = 0;
trans_start_y    = 0;

base_scale = 1;
beat_flash = 0;
birth_flash = 0;
released = false;
ring_id = -1;

prev_x = x;
prev_y = y;
vel_x = 0;
vel_y = 0;
vel_mag = 0;
vel_dir = 0;

_k_orb_trail_max = 16;

cell_gen        = 0;
cell_spin       = random(360);
cell_spin_speed = choose(-1, 1) * random_range(0.35, 0.9);
cell_accent     = global.avoid_col_cyan;

seam_charge = 0;      // rupture axis heating up before a split beat
seam_ang    = 0;
shell_open  = 0;
gather      = 1;

released_curl = 0;
socket_slot   = -1;
lock_pulse    = 0;    // socket latch flash
