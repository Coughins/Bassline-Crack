base_orbit_offset = 0;
orbit_angle = base_orbit_offset;

charge = 0;
charge_needed = 10;
built = false;

orbit_center_x = 400;
orbit_center_y = 200;
orbit_radius_x = 200;
orbit_radius_y = 100;
orbit_speed = 3;

image_alpha = 0;
image_xscale = 0.2;
image_yscale = 0.2;

trail_history = [];
trail_length = 8;
last_boost = 0;

deorbiting = false;
deorbit_timer = 0;
deorbit_ease_duration = 25;
deorbit_start_dir = 0;
deorbit_target_dir = 0;
deorbit_start_speed = 10;
deorbit_end_speed = 42;
current_tangent_speed = 0;
current_tangent_dir = 0;

hit_flash_timer = 0;
hit_flash_strength = 0;

absorb_kick = 0;
absorb_scale = 0;
absorb_scale_vel = 0;
absorb_flash = 0;

_k_chroma_px = 5;

spark_particles = [];
kunai_emit_timer = 0;