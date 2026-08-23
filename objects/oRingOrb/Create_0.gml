event_inherited();

direction = 0;
speed = 0;
_size = 1;

base_size = 1;
pop_size = 3;
spawn_pop_timer = 0;
spawn_pop_duration = 12;

spiral_spin = 0;
spiral_spin_target = 0;
spiral_ease_timer = 0;
spiral_ease_duration = 30;

slow_near_player = 0;
slow_radius = 200;
slow_speed = 5;
normal_speed = speed;

ring_tier = 1;
ring_color = c_red;

use_dash = false;
dash_state = 0;
dash_timer = 0;
dash_travel_speed = 0;
dash_travel_duration = 25;
dash_wait_duration = 20;
dash_speed = 0;

has_trail = false;
trail_history = [];
trail_max_length = 8;

prev_x = x;
prev_y = y;
travel_dir = direction;
travel_speed = 0;
stretch = 1;
birth_heat = 1;
