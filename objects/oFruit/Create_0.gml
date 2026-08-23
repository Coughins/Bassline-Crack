event_inherited();
image_alpha = 0.1;
base_alpha = 0.1;

ripeness = 0;
hit_active = false;
idle_timer = random(1000);
fruit_color = global.tree_fire_color;
explode_pending = false;
explode_timer = 0;

jitter_amount = 0;
jitter_x = 0;
jitter_y = 0;
jitter_angle = 0;
jitter_scale = 1;
jitter_seed = random(1000);
unstable = 0;

spawn_burst = false;
spawn_timer = 0;
spawn_scale = 0;
crack_timer = 0;
crack_flash = 0;
crack_glow = 0;
anchor_x = x;
anchor_y = y;
anchor_index = -1;
crown_x = x;
crown_y = y;
orbit_phase = random(360);
sap_tether_seed = random(1000);
cocoon_seed = random(1000);
cocoon_glint_seed = random(1000);
cocoon_shell_alpha = 0;
cocoon_pressure = 0;
cocoon_crack_flash = 0;
cocoon_rupture_flash = 0;
cocoon_cracks = [];
for (var cci = 0; cci < 6; cci++) {
    array_push(cocoon_cracks, {
        ang : random(360),
        inner : random_range(0.42, 0.76),
        len : random_range(7, 15),
        bend : random_range(-22, 22),
        split : random_range(-35, 35)
    });
}

_k_unripe_color = make_color_rgb(70, 15, 15);
stress_cracks = [];
