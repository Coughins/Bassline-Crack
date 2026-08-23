function scr_wall_build(_vb, _vf, _points, _width, _col, _time)
{
    var count = array_length(_points);

    if (count < 2)
        return;


    vertex_begin(_vb, _vf);


    for (var i = 0; i < count - 1; i++)
    {
        var p0 = _points[i];
        var p1 = _points[i + 1];



        var edge_wave0 =
            sin(_time * 6 + i * 0.55) * 12
            +
            sin(_time * 11 + i * 1.3) * 5;


        var edge_wave1 =
            sin(_time * 6 + (i+1) * 0.55) * 12
            +
            sin(_time * 11 + (i+1) * 1.3) * 5;



        var wobble0 =
            sin(_time * 2 + i * 0.35) * 20
            +
            sin(_time * 5 + i * 0.9) * 8;


        var wobble1 =
            sin(_time * 2 + (i+1) * 0.35) * 20
            +
            sin(_time * 5 + (i+1) * 0.9) * 8;



        var lx0 = p0.px;
        var ly0 = p0.py;

        var lx1 = p1.px;
        var ly1 = p1.py;


        var rx0 =
            p0.px + _width + wobble0 + edge_wave0;

        var ry0 =
            p0.py;


        var rx1 =
            p1.px + _width + wobble1 + edge_wave1;

        var ry1 =
            p1.py;



        var v0 = i / count;
        var v1 = (i + 1) / count;




        vertex_position_3d(_vb, lx0, ly0, 0);
        vertex_texcoord(_vb, 0, v0);
        vertex_colour(_vb, _col, 1);


        vertex_position_3d(_vb, rx1, ry1, 0);
        vertex_texcoord(_vb, 1, v1);
        vertex_colour(_vb, _col, 1);


        vertex_position_3d(_vb, rx0, ry0, 0);
        vertex_texcoord(_vb, 1, v0);
        vertex_colour(_vb, _col, 1);




        vertex_position_3d(_vb, lx0, ly0, 0);
        vertex_texcoord(_vb, 0, v0);
        vertex_colour(_vb, _col, 1);


        vertex_position_3d(_vb, lx1, ly1, 0);
        vertex_texcoord(_vb, 0, v1);
        vertex_colour(_vb, _col, 1);


        vertex_position_3d(_vb, rx1, ry1, 0);
        vertex_texcoord(_vb, 1, v1);
        vertex_colour(_vb, _col, 1);
    }


    vertex_end(_vb);
}