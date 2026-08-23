function scr_spawn_shape_star(){
var _points = 5;
var _outer_r = 400;
var _inner_r = 160;
var _cx = 400, _cy = 304;
for (var i = 0; i < _points * 2; i++) {
    var _r = (i mod 2 == 0) ? _outer_r : _inner_r;
    var _ang = i * (360 / (_points * 2));
    var _x = _cx + lengthdir_x(_r, _ang);
    var _y = _cy + lengthdir_y(_r, _ang);
    var _o = instance_create_layer(_x, _y, layer, oRedLightningOrb);
    with (_o) scr_orb_setup_rotation(_cx, _cy);
}
}