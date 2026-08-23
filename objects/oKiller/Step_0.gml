if (!instance_exists(oPlayer)) exit;

var _graze_radius = 34;
var _reset_radius = 70;

var _d = point_distance(x, y, oPlayer.x, oPlayer.y);

if (energized) {
    energized_timer += 1;

    energize_flicker = 0.75 + 0.25 * sin((energized_timer + energize_seed) * 0.9) + random_range(-0.1, 0.1);
    energize_flicker = clamp(energize_flicker, 0.5, 1.15);
    image_blend = c_white;

    for (var i = 0; i < array_length(orbit_bolts); i++) {
        orbit_bolts[i].angle += orbit_bolts[i].orbit_speed;
    }

    crackle_regen_timer -= 1;
    if (crackle_regen_timer <= 0) {
        crackle_regen_timer = irandom_range(2, 4);
        scr_generate_energize_crackle(id);
    }
} else {
    image_blend = c_white;
}

if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}