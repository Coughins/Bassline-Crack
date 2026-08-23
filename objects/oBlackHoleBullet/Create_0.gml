event_inherited();
hit_alpha_min = 0.35;
trail_positions = [];

position_history = [];
rewinding = false;
rewind_frames_left = 0;

_k_stutter_freeze_chance = 0.25;
_k_stutter_snap_min = 1;
_k_stutter_snap_max = 2;
_k_rgb_offset_reroll_frames = 4;
_k_rgb_offset_max = 4;

rgb_offset_x = 0;
rgb_offset_y = 0;
rgb_reroll_timer = 0;
glitch_flash_alpha = 0.1;

rain_escalation = 0;
inverted_flash = 0;

capture = 0;
capture_target = noone;

prev_x = x;
prev_y = y;
stretch = 1;

trail_max = 16;
