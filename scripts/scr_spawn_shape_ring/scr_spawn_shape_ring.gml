function scr_spawn_shape_ring(){
var _count = 30;
var _radius = 300;
var _cx = 400, _cy = 304;
for (var i = 0; i < _count; i++) {
    var _ang = i * (360 / _count);
    var _x = _cx + lengthdir_x(_radius, _ang);
    var _y = _cy + lengthdir_y(_radius, _ang);
    var _o = instance_create_layer(_x, _y, layer, oRedLightningOrb);
    with (_o) scr_orb_setup_rotation(_cx, _cy);
}
}