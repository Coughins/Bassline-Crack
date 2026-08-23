function scr_floor_impact(_x, _y, _power, _crack = -1, _color = undefined) {
  if (!instance_exists(oAvoidanceController)) return;

  var _pow = clamp(_power, 0, 2);

  with (oAvoidanceController) {
    var _merged = false;

    if (floor_quake_last_t == t && array_length(floor_quakes) > 0) {
      var _last = floor_quakes[array_length(floor_quakes) - 1];
      _last.power = max(_last.power, _pow);
      _merged = true;
    }

    if (!_merged) {
      if (array_length(floor_quakes) >= _k_floor_quake_max) array_delete(floor_quakes, 0, 1);

      array_push(floor_quakes, {
        x : _x,
        y : _y,
        radius : 0.02,
        speed : _k_floor_quake_speed * (0.75 + _pow * 0.5),
        power : _pow,
        life : _k_floor_quake_life,
        max_life : _k_floor_quake_life
      });

      floor_quake_last_t = t;
    }

    floor_beat = max(floor_beat, min(1, _pow));
    floor_spin = clamp(floor_spin + choose(-1, 1) * _pow * 1.6, -_k_floor_spin_max, _k_floor_spin_max);

    var _want_crack = (_crack < 0) ? (_pow >= _k_floor_scar_threshold) : (_crack > 0.5);

    if (_want_crack) {
      if (array_length(floor_scars) >= _k_floor_scar_max) array_delete(floor_scars, 0, 1);

      array_push(floor_scars, {
        x : _x,
        y : _y,
        angle : random(360),
        span : (70 + _pow * 180) * random_range(0.8, 1.3),
        width : 2.2 + _pow * 2.6,
        heat : min(1.4, 0.55 + _pow),
        cool : 1 / (26 + _pow * 40),
        color : is_undefined(_color) ? _k_floor_molten : _color,
        seed : random(100),
        branch_angle : choose(-1, 1) * random_range(28, 76),
        branch_offset : random_range(-0.55, 0.55),
        age : 0,
        life : _k_floor_scar_life * (0.7 + _pow * 0.5)
      });
    }
  }
}
