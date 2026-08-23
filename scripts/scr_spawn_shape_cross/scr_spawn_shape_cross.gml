function scr_spawn_shape_cross(){
    var _len = 300;
    var _step = 80;
    var _cx = 400, _cy = 304;
    for (var i = -_len; i <= _len; i += _step) {
        var _o1 = instance_create_layer(_cx + i, _cy + i, layer, oRedLightningOrb);
        with (_o1) scr_orb_setup_rotation(_cx, _cy);
        var _o2 = instance_create_layer(_cx + i, _cy - i, layer, oRedLightningOrb);
        with (_o2) scr_orb_setup_rotation(_cx, _cy);
    }
}