event_inherited();

vspeed_current = 0.6;
vspeed_target = 0.6;
squash_timer = 0;
image_alpha = 0;

_k_fade_frames = 20;

prev_x = x;
prev_y = y;
trail_history = [];
_k_trail_max_points = 10;
_k_trail_speed_to_length = 1.2;

spawn_pop = 0;
hot = 0;
shove_dir = 1;
spin_kick = 0;
tumble = 0;
wobble_seed = random(6.28);
wave_seen = 0;
reactor_phase = random(1000);
shell_spin = random(360);
