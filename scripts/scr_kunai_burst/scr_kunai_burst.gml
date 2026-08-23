function scr_kunai_burst(_x, _y, _count, _target) {
    var _offset = random(360);
    for (var i = 0; i < _count; i++) {
        with instance_create_layer(_x, _y, layer, oRedKunai) {
            is_feeder = true;
            state = "flying_out";
            direction = point_direction(x, y, oPlayer.x, oPlayer.y) + (360 / _count * i) + 36
            speed = 20;
            image_alpha = 1;
            target_big_kunai = _target;
        }
    }
}