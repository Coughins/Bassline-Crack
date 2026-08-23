event_inherited();

cube_type = 0;
edge_index = 0;
travel = 0;
travel_speed = 0.01;
travel_dir = 1;
reverse_travel = false;

spawn_pop_timer = 0;
spawn_pop_duration = 12;

alpha_fade_in_timer = 0;
alpha_fade_in_duration = 120 + room_speed;
alpha_fade_out_timer = 0;
alpha_fade_out_duration = 1;
alpha_fade_out_floor = 0.1;
hit_active = false;
hit_alpha_min = 0.35;
hit_scale_min = 0.25;

vel_x = 0;
vel_y = 0;
speed_now = 0;
prev_x = x;
prev_y = y;

lightning_apply_sprite();
