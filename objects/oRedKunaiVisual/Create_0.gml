event_inherited();
kunai_fade_frames = 40;
kunai_alpha_step  = 1 / kunai_fade_frames;
image_alpha = 1;
hit_active = true;

kunai_curve_mode  = false;
kunai_curve_frames = 20;
kunai_curve_rate   = 360 / kunai_curve_frames;
kunai_curve_timer  = 0;
kunai_curve_burst_chance = 0.15;
kunai_curve_band_width = 100;
kunai_curve_spread_count = 15;
kunai_curve_launch_speed = 24;
kunai_curve_split_y = undefined;
kunai_curve_decel_min = 0;
kunai_curve_decel_max = 30;
kunai_curve_phase_slot = 0;
kunai_curve_phase_count = 1;

kunai_decel_mode = false;
kunai_decel_timer = 0;
kunai_decel_frames = 0;
kunai_decel_step = 0;

finale_mode = false;
finale_tier = 1;
finale_heat = 1;
finale_hue = 0;

finale_motion_mode = 0;
finale_motion_timer = 0;
finale_motion_life = 34;
finale_motion_fade = 10;
finale_base_alpha = 1;
finale_motion_cx = x;
finale_motion_cy = y;
finale_motion_angle = 0;
finale_motion_spin = 0;
finale_motion_radius = 0;
finale_motion_radius2 = 0;
finale_motion_squash = 0.65;
finale_motion_sx = x;
finale_motion_sy = y;
finale_motion_c1x = x;
finale_motion_c1y = y;
finale_motion_tx = x;
finale_motion_ty = y;
finale_motion_ex = x;
finale_motion_ey = y;

trail_positions = [];
trail_max = 14;

prev_x = x;
prev_y = y;
stretch = 1;

afterimages = [];
afterimage_timer = 0;

band_mode = false;
band_slot = 0;
band_planted = 0;
plant_flash = 0;
band_fin = 0;
embers = [];
arc_seed = random(1000);
frozen_trail = false;
