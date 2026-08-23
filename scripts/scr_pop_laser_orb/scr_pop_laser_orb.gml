function scr_pop_laser_orb(_orb) {
    with (_orb) {
        if (is_popped) exit;
        is_popped = true;
        pop_timer = 0;

        scr_impact_pulse(0.15, 1.0, 0.1);

        var _pop_x = x;
        var _pop_y = y;
        var _shrapnel_count = _k_shrapnel_count;
        var _shrapnel_speed = _k_shrapnel_speed;

        if (instance_exists(oAvoidanceController)) {
            with (oAvoidanceController) {
                for (var i = 0; i < _shrapnel_count; i++) {
                    var _dir = random(360);
                    var _spd = random_range(1.5, _shrapnel_speed);
                    array_push(arrow_ring_particles, {
                        x : _pop_x, y : _pop_y,
                        vx : lengthdir_x(_spd, _dir), vy : lengthdir_y(_spd, _dir),
                        life : 8 + irandom(8), max_life : 16,
                        size : random_range(0.05, 0.12),
                        grav : 0.12, drag : 0.93, hot : random_range(0.6, 1)
                    });
                }
            }
        }
    }
}
