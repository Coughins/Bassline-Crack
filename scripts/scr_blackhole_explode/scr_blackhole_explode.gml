function scr_blackhole_explode(){
	var _px = x, _py = y;
	var _push = oAvoidanceController.blackhole_push_mode;
	var _blast_dim = oAvoidanceController._k_bh_detonation_draw_mult;
	var _particle_dim = oAvoidanceController._k_bh_detonation_particle_mult;
	var _col = _push ? merge_color(global.lightning_color, c_white, 0.38) : global.lightning_color;

	var _count = 26;
	for (var i = 0; i < _count; i++)
	{
	    var _dir = (360 / _count) * i + random_range(-14, 14);
	    var _p = instance_create_layer(_px, _py, layer, oBlackHoleBurstParticle);
	    _p.direction = _dir;
	    _p.speed = random_range(4, 11);
	    _p.image_alpha = 0.56;
	    _p.fx_dim = _particle_dim;
	}

	if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 18);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.12);
	    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.11);
	    oCameraController.angle_kick += choose(-1, 1) * 2.2;
	    oCameraController.letterbox_target = 0;
	}

	scr_impact_pulse(0.08, 0, 0.12, _px, _py);
	scr_impact_pulse(0.32, 1.35, 0.24, _px, _py);
	oAvoidanceController.global_ripple_pulse = max(oAvoidanceController.global_ripple_pulse, 0.24);
	oAvoidanceController.tear_amount = max(oAvoidanceController.tear_amount, 0.32);

	scr_add_light(_px, _py, _col, 5);
	scr_floor_impact(_px, _py, 0.25, 1);

	array_push(oAvoidanceController.bh_inversion_rings, {
	    x : _px, y : _py,
	    radius : 220, max_radius : 4,
	    life : 16, life_max : 16,
	    width : 16, color : _col, hot : 0.65, inward : true,
	    dim : _blast_dim
	});
	for (var r = 0; r < 3; r++) {
	    array_push(oAvoidanceController.bh_inversion_rings, {
	        x : _px, y : _py,
	        radius : 4, max_radius : 260 + r * 120,
	        life : 28 + r * 7, life_max : 28 + r * 7,
	        width : 16 - r * 3,
	        color : merge_color(_col, c_white, 0.18 + r * 0.08),
	        hot : 0.55 - r * 0.1, inward : false,
	        dim : _blast_dim
	    });
	}

	for (var c = 0; c < 12; c++) {
	    array_push(oAvoidanceController.bh_horizon_cracks, {
	        x : _px, y : _py,
	        ang : random(360),
	        len : random_range(55, 150),
	        life : 24, life_max : 24,
	        seed : random(1000)
	    });
	}

	for (var d = 0; d < 20; d++) {
	    var _dang = random(360);
	    array_push(oAvoidanceController.ember_spray, {
	        x : _px, y : _py,
	        xspeed : lengthdir_x(random_range(2.5, 10), _dang),
	        yspeed : lengthdir_y(random_range(2.5, 10), _dang) - 1.2,
	        size : random_range(2, 6),
	        life : irandom_range(30, 60), life_max : 60,
	        color : merge_color(_col, c_white, random(0.35))
	    });
	}
}
