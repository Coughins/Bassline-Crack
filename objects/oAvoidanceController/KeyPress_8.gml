if (variable_global_exists("avoidance_practice_active") && global.avoidance_practice_active) {
  global.avoidance_practice_return_menu = true;
}

if (instance_exists(oPlayer)) {
  warp(rMainHub, oPlayer)
} else {
  room_goto(rMainHub)
}
