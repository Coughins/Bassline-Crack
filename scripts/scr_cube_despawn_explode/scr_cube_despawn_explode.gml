function scr_cube_despawn_explode(){
	var _k_streaks       = 54;
	var _k_inner_streaks = 22;
	var _k_flash_count   = 3;

	for (var i = 0; i < _k_streaks; i++)
	{
	    var _dir = (360 / _k_streaks) * i + random_range(-14, 14);
	    var _p = instance_create_layer(cube_center_x, cube_center_y, layer, oCubeStreakParticle);
	    _p.direction = _dir;
	    _p.speed = random_range(11, 24);
	    _p.streak_length = random_range(45, 95);
	    _p.hot = 1;
	}

	for (var i = 0; i < _k_inner_streaks; i++)
	{
	    var _dir2 = random(360);
	    var _p2 = instance_create_layer(cube_center_x, cube_center_y, layer, oCubeStreakParticle);
	    _p2.direction = _dir2;
	    _p2.speed = random_range(4, 10);
	    _p2.streak_length = random_range(18, 40);
	    _p2.life = 40;
	    _p2.life_max = 40;
	    _p2.hot = 0.7;
	}

	for (var i = 0; i < _k_flash_count; i++)
	{
	    var _fx = (i == 0) ? cube_center_x : cube_center_x + random_range(-34, 34);
	    var _fy = (i == 0) ? cube_center_y : cube_center_y + random_range(-34, 34);
	    instance_create_layer(_fx, _fy, layer, oQuarterExplodeFlash);
	}

	if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 26);
	    oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.9);
	}
	scr_impact_pulse(0.9, 8.0, 1.4, cube_center_x, cube_center_y);
	tear_amount = max(tear_amount, 1.2);
}
