function scr_spawn_shape_spiral(){
var _count = 40;
var _cx = 400, _cy = 304;
for (var i = 0; i < _count; i++) {
    var _ang = i * 25;
    var _r = i * 12;
    var _x = _cx + lengthdir_x(_r, _ang);
    var _y = _cy + lengthdir_y(_r, _ang);
    var _o = instance_create_layer(_x, _y, layer, oRedLightningOrb);
    with (_o) scr_orb_setup_rotation(_cx, _cy);
}
}