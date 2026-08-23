function scr_quarter_spawn_shockwave(_x, _y) {
    var _k_shockwave_start_radius = 10;
    var _k_shockwave_max_radius   = 220;
    var _k_shockwave_speed        = 8;

    array_push(oAvoidanceController.quarter_shockwaves, {
        x: _x,
        y: _y,
        radius: _k_shockwave_start_radius,
        max_radius: _k_shockwave_max_radius,
        alpha: 1,
        speed: _k_shockwave_speed
    });
}