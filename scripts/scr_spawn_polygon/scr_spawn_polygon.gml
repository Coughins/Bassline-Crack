
function scr_spawn_polygon(_x, _y, _angle, _edges, _per_edge, _speed, _obj)
{
    var th = degtorad(_angle);

    var xx = [];
    var yy = [];

    for (var i = 0; i < _edges; i++)
    {
        xx[i] = cos(th + ((2 * pi * i) / _edges));
        yy[i] = sin(th + ((2 * pi * i) / _edges));
    }

    xx[_edges] = xx[0];
    yy[_edges] = yy[0];

    for (var i = 0; i < _edges; i++)
    {
        var ddx = xx[i + 1] - xx[i];
        var ddy = yy[i + 1] - yy[i];

        for (var j = 0; j < _per_edge; j++)
        {
            var dx = xx[i] + (ddx * j / _per_edge);
            var dy = yy[i] + (ddy * j / _per_edge);

            var b = instance_create_layer(_x + dx, _y + dy, "Instances", _obj);

            b.direction = point_direction(0, 0, dx, dy);
            b.speed = _speed * point_distance(0, 0, dx, dy);
        }
    }
}