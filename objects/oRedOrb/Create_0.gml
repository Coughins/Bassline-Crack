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
ember_split = false

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

materialize_frames = 0;
materialize_timer = 0;
fruit_seed_visual = false;
var _fruit_seed_default_color = c_red;
if (variable_global_exists("avoid_col_ember")) _fruit_seed_default_color = global.avoid_col_ember;
if (variable_global_exists("tree_fire_color")) _fruit_seed_default_color = global.tree_fire_color;
fruit_seed_color = _fruit_seed_default_color;
fruit_seed_heat = 1;
fruit_seed_ring_power = 1.15;
fruit_seed_visual_seed = random(1000);

trail_history = [];
_k_trail_length = 7;
_k_trail_alpha_base = 0.75;
_k_trail_scale_falloff = 0.93;
