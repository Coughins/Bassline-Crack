event_inherited();

speed = 10;
direction = 270;
image_angle = direction;
image_speed = 0;
image_index = 5;
image_xscale = 0.5;
image_yscale = 0.5;

fall_speed = 10;

picked = false;
telegraphing = false;
telegraph_timer = 0;
telegraph_pulse = 0;
coil_seed = random(6.28);
hitch = 0;

dash_speed = 0;
dash_time = 0;
dash_peak = 1;
is_dashing = false;

hot = 0;
spawn_pop = 0;
hit_active = false;
ghost_timer = 0;
prev_x = x;
prev_y = y;
travel_len = 0;

trail_positions = [];

pop_scale  = 1.8;
pop_target = 1;
pop_speed  = 0.18;
pop_overshoot = true;
pop_flash = 1;
