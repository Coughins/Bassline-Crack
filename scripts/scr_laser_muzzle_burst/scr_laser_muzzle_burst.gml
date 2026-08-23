function scr_laser_muzzle_burst(_x, _y, _dir, _power = 1) {
  if (!instance_exists(oAvoidanceController)) return;

  var _p = clamp(_power, 0.2, 2);

  with (oAvoidanceController) {
    array_push(ring_shockwaves, {
      x : _x, y : _y,
      radius : 8, max_radius : 120 + _p * 150,
      life : round(16 + _p * 8), max_life : round(16 + _p * 8),
      width : 14 + _p * 18, hot : 0.6 + _p * 0.3, vs : 1
    });

    var _cone = round(10 + _p * 12);
    for (var _i = 0; _i < _cone; _i++) {
      array_push(ring_streaks, {
        cx : _x, cy : _y, vs : 1,
        ang : _dir + random_range(-34, 34),
        dist : random_range(10, 55),
        len : random_range(40, 60 + _p * 110),
        speed : random_range(11, 16 + _p * 12),
        life : 10 + irandom(10), max_life : 20,
        width : random_range(1, 1.4 + _p * 2),
        hot : random_range(0.55, 1)
      });
    }

    var _kick = round(12 + _p * 16);
    for (var _i = 0; _i < _kick; _i++) {
      var _ang = _dir + 180 + random_range(-62, 62);
      var _spd = random_range(1.5, 3 + _p * 5);
      array_push(arrow_ring_particles, {
        x : _x, y : _y,
        vx : lengthdir_x(_spd, _ang), vy : lengthdir_y(_spd, _ang),
        life : 11 + irandom(14), max_life : 25,
        size : random_range(0.06, 0.1 + _p * 0.14),
        grav : 0.13, drag : 0.93, hot : random_range(0.6, 1)
      });
    }
  }

  scr_add_light(_x, _y, merge_color(c_red, c_white, 0.35), 0.8 + _p * 0.8);
}
