function scr_quarter_despawn_burst(_x, _y, _id)
{
    var _count = 2;

    for (var i = 0; i < _count; i++)
    {
        var _dir = random(360);
        var _spd = random_range(5, 10);

        var _orb = instance_create_layer(
            _x,
            _y,
            layer,
            oRedOrbQuarterCircles
        );

        _orb.direction = _dir;
        _orb.speed = _spd;

        _orb._size = 0.4;
        _orb.image_xscale = 0.4;
        _orb.image_yscale = 0.4;

        _orb.image_alpha = 0.8;

        _orb.circle_id = _id;

        if (_id == 1)
        {
            _orb.sprite_index = sBlueOrb;
        }

        _orb.qc_fragment = true;
        _orb.qc_fragment_timer = 12;
    }
}