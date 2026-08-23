function scr_generate_energize_crackle(target_id){
	var _inst = target_id;
	var _num_sparks = irandom_range(2, 4);
	var _radius = _inst.sprite_width * 0.6;
	var _points = [];

	for (var i = 0; i < _num_sparks; i++) {
	    var _angle = random(360);
	    var _len = random_range(_radius * 0.5, _radius * 1.3);
	    var _ex = lengthdir_x(_len, _angle);
	    var _ey = lengthdir_y(_len, _angle);
	    var _mx = lerp(0, _ex, 0.5) + random_range(-4, 4);
	    var _my = lerp(0, _ey, 0.5) + random_range(-4, 4);

	    array_push(_points, { sx: 0, sy: 0, mx: _mx, my: _my, ex: _ex, ey: _ey });
	}

	_inst.crackle_points = _points;
}