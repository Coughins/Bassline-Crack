function scr_bg_bass_hit(){
	scr_impact_pulse(0.15, 0, 1.4);
	if (instance_exists(oAvoidanceController)) {
		oAvoidanceController.global_ripple_pulse = 0.65;
	}
}
