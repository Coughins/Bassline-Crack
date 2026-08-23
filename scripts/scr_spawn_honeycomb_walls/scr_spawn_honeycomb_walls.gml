function scr_spawn_honeycomb_walls()
{
    var _spacing = 14;


    for (var e = 0; e < array_length(oHoneycombCylinder.hex_edges); e++)
    {
        var _edge = oHoneycombCylinder.hex_edges[e];


        var _a = oHoneycombCylinder.hex_vertices[_edge.a];
        var _b = oHoneycombCylinder.hex_vertices[_edge.b];


        var _dist = point_distance(
            _a.x,
            _a.y,
            _b.x,
            _b.y
        );


        var _count = floor(_dist / _spacing);


        var _dir = point_direction(
            _a.x,
            _a.y,
            _b.x,
            _b.y
        );


        for (var i = 0; i <= _count; i++)
        {
            var _pos = i / _count;


            var _bx = lerp(
                _a.x,
                _b.x,
                _pos
            );

            var _by = lerp(
                _a.y,
                _b.y,
                _pos
            );


            var _bullet = instance_create_layer(
                _bx,
                _by,
                "Instances",
                oHoneycombBullet
            );


            _bullet.image_angle = _dir;


            _bullet.image_alpha = 0.1;


            _bullet.honeycomb_active = false;
        }
    }
}