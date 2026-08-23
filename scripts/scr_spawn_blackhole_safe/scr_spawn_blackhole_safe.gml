function scr_spawn_blackhole_safe(_pos){
	var _bh = instance_create_layer(_pos[0], _pos[1], layer, oBlackHole);
	_bh.move_dir = _pos[2];
	return _bh;
}