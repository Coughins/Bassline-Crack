function scr_spawn_circle(_x, _y, _angle, _count, _speed, _obj)
{
    for (var i = 0; i < _count; i++)
    {
        var b = instance_create_layer(_x, _y, "Instances", _obj);

        b.direction = _angle + (i * (360 / _count));
        b.speed = _speed;
    }
}