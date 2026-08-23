function scr_energize_bullet(target, _color = global.lightning_color) {
    target.energized = true;
    target.energized_timer = 0;
    target.energize_color = _color;

    target.orbit_bolts = [];
    var _num_orbits = 3;
    for (var i = 0; i < _num_orbits; i++) {
        array_push(target.orbit_bolts, {
            angle: random(360),
            orbit_speed: choose(-1, 1) * random_range(6, 10),
            radius_mult: random_range(0.9, 1.3),
            tilt: random_range(0.35, 0.55)
        });
    }
}