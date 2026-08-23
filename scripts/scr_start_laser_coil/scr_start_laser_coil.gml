function scr_start_laser_coil(_x, _y, _dir, _frames, _power = 1, _centered = false) {
  if (!instance_exists(oAvoidanceController)) return;

  with (oAvoidanceController) {
    laser_coil_active = true;
    laser_coil_x = _x;
    laser_coil_y = _y;
    laser_coil_dir = _dir;
    laser_coil_centered = _centered;
    laser_coil_t = 0;
    laser_coil_len = max(_frames, 1);
    laser_coil_power = _power;
    laser_coil_pulse_timer = 0;
    laser_coil_arcs = [];
    laser_coil_leaks = [];
    laser_coil_pulses = [];
  }
}
