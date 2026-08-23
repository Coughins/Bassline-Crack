event_inherited();
dna_mode = false;

dna_type = 0;
dna_side = 0;
dna_index = 0;

rung_id = 0;
rung_position = 0;

dna_radius = 60;

spawn_scale = 0;
spawn_timer = 0;
spawn_duration = 0;

image_alpha = 1;
image_xscale = 1;
image_yscale = 1;

dna_z = 0;
hit_active = false;
hit_alpha_min = 0.12;

lightning_hit = false;
orb_hit = false;

strand = 0;
active = false;
chain_target = noone;
line_target_x = 0;
line_target_y = 0;
line_life = 0;
line_life_max = 15;
rung_claimed = false;
rung_dir = 1;
chain_is_rung = false;
dna_rung_spacing = 1;
state = "waiting";
hit_timer = 0;
strike_flash = 0;
chain_timer = 1;
chain_dir = 1;
chain_step = 2;
chain_delay = 2;

despawning = false;
despawn_timer = 0;

lightning_apply_sprite();
