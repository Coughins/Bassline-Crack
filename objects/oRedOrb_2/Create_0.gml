event_inherited();
orb_fan_mode = false;
orb_timer    = 0;
_size = 1;

orb_pincer_mode = false;
orb_pincer_curve_rate = 0;
orb_pincer_curve_frames = 0;
orb_pincer_timer = 0;

orb_pop_scale = 2.2;
orb_pop_target = 1;
orb_pop_speed = 0.15;
orb_pop_overshoot = true;
orb_pop_flash = 0;
orb_pop_color = c_red;

orb_rotate_mode = false;
orb_rotate_cx = 0;
orb_rotate_cy = 0;
orb_rotate_angle = 0;
orb_rotate_radius = 0;
orb_rotate_speed = 0.5;
orb_rotate_decay = 1;
spark_glow = false;

light_radius = 0;
bounces = false;

dying = false;
_die_timer = 0;
dying_speed_mult = 1;
dying_boosted = false;

_k_dying_ramp_frames = 75;
_k_dying_accel = 0.17;
_k_dying_accel_floor = 0.03;
_k_dying_max_speed = 26;

chain_prev_orb = noone;
chain_line_life = 0;
chain_line_life_max = 15;
chain_color = global.lightning_color;
chain_jag = 4;

lorb_floor_done = false;

chain_eligible = true;
active = false;
chain_target = noone;
chain_delay = 3;
line_target_x = 0;
line_target_y = 0;
line_life = 0;
line_life_max = 15;

grazed = false;
graze_bolt_life = 0;
graze_bolt_max = 10;

ember_cascade = 0;

ember_glow_core = false;
ember_drip = false;
ember_drip_timer = 0;
fruit_seed_visual = false;
var _fruit_seed_default_color = c_red;
if (variable_global_exists("avoid_col_ember")) _fruit_seed_default_color = global.avoid_col_ember;
if (variable_global_exists("tree_fire_color")) _fruit_seed_default_color = global.tree_fire_color;
fruit_seed_color = _fruit_seed_default_color;
fruit_seed_heat = 1;
fruit_seed_ring_power = 1.15;
fruit_seed_visual_seed = random(1000);
fruit_seed_contained = false;
fruit_seed_containment_flash = 0;
fruit_seed_release_flash = 0;
fruit_seed_launch_arm_timer = 0;

ember_ring_release = false;
ember_ring_release_delay = 0;
ember_ring_launched = false;
ember_ring_launch_timer = 0;

trail = 0
trail_history = [];
_k_trail_length = 7;
_k_trail_alpha_base = 0.75;
_k_trail_scale_falloff = 0.93;

lightning_apply_sprite();
