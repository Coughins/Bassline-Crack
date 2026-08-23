function scr_impact_pulse(_vignette, _aberration, _bloom, _floor_x = undefined, _floor_y = undefined) {
	if (instance_exists(oAvoidanceController)) {
	    oAvoidanceController.vignette_pulse   = max(oAvoidanceController.vignette_pulse, _vignette);
	    oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, _aberration);
	    oAvoidanceController.bloom_pulse      = max(oAvoidanceController.bloom_pulse, _bloom);

	    var _floor_power = clamp(_vignette * 1.6 + _bloom * 0.15, 0, 1.2);

	    if (_floor_power >= 0.12) {
	        var _fx = is_undefined(_floor_x) ? oAvoidanceController.floor_epicenter_x : _floor_x;
	        var _fy = is_undefined(_floor_y) ? oAvoidanceController.floor_epicenter_y : _floor_y;
	        scr_floor_impact(_fx, _fy, _floor_power);
	    }
	}
}
