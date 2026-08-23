// ============================================================================
// END STEP
// ============================================================================
if (!is_undefined(riser) && riser.tether > 0.001 &&
    instance_exists(oPlayer) && !oPlayer.dead && !instance_exists(oGameover)) {

  var _auth = clamp(riser.tether, 0, 1);
  var _tx   = riser.tether_x;
  var _ty   = riser.tether_y;

  with (oPlayer) {
    x = lerp(x, _tx, _auth);
    y = lerp(y, _ty, _auth);
    velocity.x = lerp(velocity.x, 0, _auth);
    velocity.y = lerp(velocity.y, 0, _auth);
  }
}
