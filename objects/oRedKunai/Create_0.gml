event_inherited();
t = 0
orb_hit = false

vsp = 0;
is_thrown = false;
hsp = 0;
thrown_gravity = 0.225;
thrown_hsp_damping = 0.985;
dash_speed = 0;
dash_dir = 270;
dash_time = 0;

spawn_timer = 0;
spawn_duration = 10;
image_alpha = 0;
image_xscale = 0.2;
image_yscale = 0.2;
hit_active = false;

trail_history = [];
trail_length = 7;
trail_speed_threshold = 8;
draw_heat_seed = random(1000);

impacts_floor = false;
rain_forged = true;
rain_source_x = x;
rain_source_seed = 0;

is_feeder = false;
state = "normal";
exit_x = 0;
exit_y = 0;
curve_ctrl_x = 0;
curve_ctrl_y = 0;
return_timer = 0;
return_duration = 45;
target_big_kunai = noone;
locked_direction = false;
target_scale = 1;
