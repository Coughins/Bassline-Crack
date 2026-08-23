event_inherited();
ignite_pending = false;
ignite_delay = 0;
state = 0;
state_timer = 0;
grow_duration = 8;
shrink_duration = 14;
base_scale = 1;

ignite_color_unlit = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, 0.58);
ignite_color_hot   = merge_color(global.tree_fire_color, global.avoid_col_danger, 0.22);
image_blend = ignite_color_unlit;

branch_dir = 90;
branch_len = 8;
branch_parent_x = x;
branch_parent_y = y + 8;
branch_parent_scale = 1;
node_index = -1;
glow_pulse_seed = random(1000);
vein_seed = random(1000);
bark_seed = random(1000);
_k_branch_width_ratio = 0.62;
glow_intensity = 0;
branch_heat = 0;
branch_current = 0;
branch_network_flash = 0;
branch_child_count = 0;
branch_is_leaf = false;
branch_role = 0;
branch_spur_count = 0;

spawn_state = true;
spawn_timer = 0;
spawn_duration = 10;
spawn_scale = 0;
spawn_done = false;
spawn_progress = 0;
spawn_delay = 0;

spawn_snap = 0;
spawn_angle_offset = 0;

crack_points = [];
