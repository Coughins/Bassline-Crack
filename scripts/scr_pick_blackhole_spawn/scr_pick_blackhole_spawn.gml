function scr_pick_blackhole_spawn(_avoid_x = undefined, _avoid_y = undefined){
	var _has_ctl = instance_exists(oAvoidanceController);
	var _min_x = _has_ctl ? oAvoidanceController._k_bh_spawn_min_x : 110;
	var _max_x = _has_ctl ? oAvoidanceController._k_bh_spawn_max_x : room_width - 110;
	var _min_y = _has_ctl ? oAvoidanceController._k_bh_spawn_min_y : 72;
	var _max_y = _has_ctl ? oAvoidanceController._k_bh_spawn_max_y : room_height * 0.36;
	var _player_safe = _has_ctl ? oAvoidanceController._k_bh_spawn_player_safe_dist : 300;
	var _pair_safe = _has_ctl ? oAvoidanceController._k_bh_spawn_pair_safe_dist : 260;

	var _best_x = room_width / 2;
	var _best_y = (_min_y + _max_y) * 0.5;
	var _best_score = -1000000;

	for (var attempt = 0; attempt < 36; attempt++) {
		var _x = random_range(_min_x, _max_x);
		var _y = random_range(_min_y, _max_y);
		var _score = random(16);

		if (instance_exists(oPlayer)) {
			var _pd = point_distance(_x, _y, oPlayer.x, oPlayer.y);
			_score += min(_pd, _player_safe) * 0.7;
			if (_pd < _player_safe) _score -= (_player_safe - _pd) * 2.5;
		}

		if (!is_undefined(_avoid_x) && !is_undefined(_avoid_y)) {
			var _ad = point_distance(_x, _y, _avoid_x, _avoid_y);
			_score += min(_ad, _pair_safe) * 0.55;
			if (_ad < _pair_safe) _score -= (_pair_safe - _ad) * 2.0;
		}

		_score += (1 - ((_y - _min_y) / max(1, _max_y - _min_y))) * 34;

		if (_score > _best_score) {
			_best_score = _score;
			_best_x = _x;
			_best_y = _y;
		}
	}

	var _dist_left   = _best_x;
	var _dist_right  = room_width - _best_x;
	var _dist_top    = _best_y;
	var _dist_bottom = room_height - _best_y;
	var _min_dist = min(_dist_left, _dist_right, _dist_top, _dist_bottom);

	var _edge_dir;
	if (_min_dist == _dist_left) _edge_dir = 180;
	else if (_min_dist == _dist_right) _edge_dir = 0;
	else if (_min_dist == _dist_top) _edge_dir = 90;
	else _edge_dir = 270;

	var _dir;
	do {
		_dir = random(360);
	} until (abs(angle_difference(_dir, _edge_dir)) > 90);

	return [_best_x, _best_y, _dir];
}
