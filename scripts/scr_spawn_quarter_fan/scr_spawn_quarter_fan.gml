function spawn_quarter_fan(_x, _y, _num, _spd, _offset, _bsize, _shrink, _fill) {
    for (var i = 0; i < _num; ++i) {
        var f = i / (_num - 1);
        var a = lerp(0, 90, f);

        with (instance_create_layer(_x, _y, layer, oRedOrb)) {
            direction = a + _offset;
            speed = _spd;
            _size = _bsize;
            spawn_shrink = _shrink;
        }
        with (instance_create_layer(_x, _y, layer, oRedOrb)) {
            direction = (270 - a) + _offset;
            speed = _spd;
            _size = _bsize;
            spawn_shrink = _shrink;
        }
    }

    if (_fill) {
        var step = 90 / (_num - 1);
        for (var i = 0; i < _num - 1; ++i) {
            var a = i * step + step * 0.5;
            with (instance_create_layer(_x, _y, layer, oRedOrb)) {
                direction = a + _offset;
                speed = _spd - 2;
                _size = _bsize;
                spawn_shrink = _shrink + 1;
            }
            with (instance_create_layer(_x, _y, layer, oRedOrb)) {
                direction = (270 - a) + _offset;
                speed = _spd - 2;
                _size = _bsize;
                spawn_shrink = _shrink + 1;
            }
        }
    }
}