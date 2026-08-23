function scr_honeycomb_add_vertex(_x, _y, _angle)
{
    for (var i = 0; i < array_length(hex_vertices); i++)
    {
        if (point_distance(
            hex_vertices[i].x,
            hex_vertices[i].y,
            _x,
            _y
        ) < 5)
        {
            return i;
        }
    }


    var _id = array_length(hex_vertices);

    array_push(hex_vertices,
    {
        x:_x,
        y:_y,
        angle:_angle
    });


    return _id;
}
