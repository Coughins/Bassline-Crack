/// @param {real} _x1     room x of the bolt's origin
/// @param {real} _y1     room y of the bolt's origin
/// @param {real} _x2     room x of the target
/// @param {real} _y2     room y of the target
/// @param {real} _life   frames the bolt stays alive
/// @param {real} _jitter perpendicular jitter amplitude
/// @param {real} [_width] core thickness
/// @param {real} [_hot]   0 = orb colour, 1 = white-hot
/// @param {real} [_col]   optional base colour override
function scr_slash_bolt(_x1, _y1, _x2, _y2, _life, _jitter, _width = 1.2, _hot = 0.4, _col = undefined) {
  if (!instance_exists(oAvoidanceController)) return;

  with (oAvoidanceController) {
    if (array_length(slash_bolts) >= _k_slash_bolt_max) array_delete(slash_bolts, 0, 1);

    array_push(slash_bolts, {
      x1 : _x1, y1 : _y1, x2 : _x2, y2 : _y2,
      life : _life, life_max : _life,
      off : scr_bolt_offsets(5, _jitter),
      width : _width,
      hot : _hot,
      col : _col
    });
  }
}
