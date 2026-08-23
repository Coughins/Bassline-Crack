function scr_fruit_explode(){
	var _px = x, _py = y;
	var _half = 20;
	var _start_angle = random(360);
    var _burst_fruit_color = fruit_color;
	var _bullet = noone;
	
	_bullet = instance_create_layer(_px, _py, layer, oFruitBullet);
	_bullet.anchor_x = _px;
	_bullet.anchor_y = _py;
	_bullet.bar_offset = -_half;
	_bullet.sweep_angle = _start_angle;
	_bullet.fruit_color = fruit_color;

	_bullet = instance_create_layer(_px, _py, layer, oFruitBullet);
	_bullet.anchor_x = _px;
	_bullet.anchor_y = _py;
	_bullet.bar_offset = 0;
	_bullet.sweep_angle = _start_angle;
	_bullet.fruit_color = fruit_color;

	_bullet = instance_create_layer(_px, _py, layer, oFruitBullet);
	_bullet.anchor_x = _px;
	_bullet.anchor_y = _py;
	_bullet.bar_offset = _half;
	_bullet.sweep_angle = _start_angle;
	_bullet.fruit_color = fruit_color;

	if (instance_exists(oAvoidanceController)) {
	    with (oAvoidanceController) {
            var _cocoon_shard_col = merge_color(global.avoid_col_cyan, _burst_fruit_color, 0.48);
	        array_push(fruit_bursts, { x: _px, y: _py, timer: 0, duration: 18, color: _cocoon_shard_col });
	        array_push(fruit_shockwaves, { x: _px, y: _py, radius: 0, max_radius: 70, alpha: 0.8, color: _cocoon_shard_col });

	        var _streak_count = 8;
	        for (var s = 0; s < _streak_count; s++) {
	            array_push(fruit_streaks, {
	                x: _px, y: _py,
	                angle: (360 / _streak_count) * s + random_range(-10, 10),
	                len: 0, max_len: random_range(20, 40),
	                timer: 0, duration: 12,
                    color: (s mod 2 == 0) ? _cocoon_shard_col : merge_color(global.avoid_col_cyan_soft, c_white, 0.25),
                    fringe: true
	            });
	        }


	        vignette_pulse = max(vignette_pulse, 0.5);
	        aberration_pulse = max(aberration_pulse, 0.3);
	        global_ripple_pulse = max(global_ripple_pulse, 0.6);
	    }
	}

	if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 4);
	}
	instance_destroy();
}
