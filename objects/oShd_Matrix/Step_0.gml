var _charge = 0;
var _bloom = 0;
var _vignette = 0;
var _aberration = 0;
var _section_p = 0;

if (instance_exists(oAvoidanceController)) {
  _charge = oAvoidanceController.floor_charge;
  _bloom = oAvoidanceController.bloom_pulse;
  _vignette = oAvoidanceController.vignette_pulse;
  _aberration = oAvoidanceController.aberration_pulse;

  _section_p = clamp(
      (oAvoidanceController.t - _k_ramp_start) / (_k_ramp_end - _k_ramp_start), 0, 1);
}

matrix_charge = clamp(
    max(_charge, _bloom / _k_bloom_ref) + _section_p * _k_charge_ramp,
    0, 1);

matrix_beat = clamp(_vignette / _k_beat_ref, 0, 1);

matrix_glitch = max(
    matrix_glitch - _k_glitch_decay,
    clamp(_aberration / _k_glitch_ref, 0, 1));

var _rise = _aberration - matrix_prev_aberration;
matrix_prev_aberration = _aberration;

if (_rise > _k_hit_threshold) {
  var _power = clamp(_rise / _k_hit_ref, 0.2, 1);

  matrix_impact = max(matrix_impact, _power);

  matrix_roll = _power * _k_roll_kick * (irandom(1) * 2 - 1);

  if (array_length(matrix_shocks) >= _k_shock_max) array_delete(matrix_shocks, 0, 1);
  array_push(matrix_shocks, { r : 0, p : _power });
}

matrix_impact = max(0, matrix_impact - _k_impact_decay);
matrix_roll = lerp(matrix_roll, 0, _k_roll_decay);

for (var i = array_length(matrix_shocks) - 1; i >= 0; i--) {
  matrix_shocks[i].r += _k_shock_speed;
  matrix_shocks[i].p *= _k_shock_fade;

  if (matrix_shocks[i].r > _k_shock_range) array_delete(matrix_shocks, i, 1);
}

var _dt = min(delta_time, 33333) / 1000000;

matrix_time += _dt * (_k_walk_mult + matrix_charge * _k_walk_charge);

matrix_rain_time += _dt * (
    _k_fall_mult
    + matrix_charge * _k_fall_charge
    + matrix_beat * _k_fall_beat);

alpha = lerp(
    alpha,
    target_alpha,
    fade_speed
);
