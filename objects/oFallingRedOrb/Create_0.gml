event_inherited();

orb_fan_mode = false;
orb_timer    = 0;

t = 0
_size = 1
tag = 0
trail = 0
intro_circle = 0
shoot_out = 0
circle_count = 0
rotate = 0
start_orbit = 0
spawn_shrink = 0
spawn_slowdown = 0
shrink_destroy = 0
orb_hit = false
waiting_to_fall = 0
is_curving = false
curve_amount = 0
ghost_explosion = 0

speed_up = false
speed_up_max = 0
speed_up_amount = 0

circleNumber = 0
bulletNumber = 0
deltaDir = 0
delta = 0

center_x = 0
center_y = 0
radius = 0
angle = 0
orbit_speed = 0

orbiting = false
orbit_angle = 0
orbit_radius_x = 0
orbit_radius_y = 0
orbit_center_x = 0
orbit_center_y = 0

slow_near_player = 0;
slow_radius = 120;
slow_speed = 2;
normal_speed = speed;

spiral_spin = 0;

waiting_to_fall = 1;
telegraphing = 0;
telegraph_timer = 0;
telegraph_duration = 0;
idle_pulse_offset = random(1000);

trail = 0;
gravity = 0;
gravity_direction = 270;
speed = 0;
vspeed = 0;
hit_active = false;

shockwave_active = false;
shockwave_radius = 0;
shockwave_max_radius = 0;
shockwave_alpha = 0;

pop_flash_timer = 0;
pop_flash_duration = 0;
glowing = false;

growing = false;
grow_timer = 0;
_k_grow_overshoot_scale = 1.5;
_k_grow_frames = 6;
_k_grow_settle_frames = 10;

wind_drift = 0;
trail_positions = [];
is_hailstone = false;
_k_trail_length = 10;

mill_orb = false;
mill_scar_index = -1;
mill_launch_dir = 0;
mill_bead_f = 0;

mill_slot = -1;
mill_along = 0;
mill_volley = -1;
mill_link_to = noone;
mill_wired = false;
mill_fuse_delay = 0;
mill_fuse_span = 1;
mill_launch_boost = 1;
mill_gate_cyan = false;
mill_orbit_armed = false;
mill_orbiting = false;
mill_orbit_angle = 0;
mill_orbit_start_angle = 0;
mill_orbit_span = 0;
mill_orbit_radius = 0;
mill_orbit_dir = 1;
mill_orbit_timer = 0;
mill_orbit_life = 0;

dissolving = false;
dissolve_timer = 0;
dissolve_prog = 0;
dissolve_duration = 10;
dissolve_delay = 0;

rain_orb       = false;
tether_ax      = 0;
tether_ay      = 0;
tether_seed    = 0;
tether_state   = 0;
tether_charge  = 0;
tether_heavy   = false;
armed_beat     = -1;
drip_fuse      = -1;
arm_flash      = 0;
socket_heat    = 0;
rain_material_spin = 0;
rain_core_phase    = 0;

knock_vx       = 0;
knock_vy       = 0;
spin_rate      = 0;

strike_hold    = 0;
strike_squash  = 0;
strike_grav    = 0;
