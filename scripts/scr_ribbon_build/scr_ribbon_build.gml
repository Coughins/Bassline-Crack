function scr_ribbon_build(_vb, _vf, _pts, _width, _col, _time)
{
    var count = array_length(_pts);
	var ribbon_time = _time;
	var total = array_length(_pts);

    if (count < 2)
        return;

    vertex_begin(_vb, _vf);

	for (var i = 0; i < count - 1; i++)
	{
		var v0 = i * 0.08;
		var v1 = (i + 1) * 0.08;
        var p0 = _pts[i];
        var p1 = _pts[i + 1];

		var dx = p1.px - p0.px;
		var dy = p1.py - p0.py;

        var len = sqrt(dx * dx + dy * dy);

        if (len < 0.001)
            continue;

        dx /= len;
        dy /= len;

        var nx = -dy;
        var ny = dx;

		var wobble0 =
		    sin(ribbon_time * 2 + i * 0.35) * 6
		    +
		    sin(ribbon_time * 5 + i * 0.8) * 3;

		var wobble1 =
		    sin(ribbon_time * 2 + (i+1) * 0.35) * 6
		    +
		    sin(ribbon_time * 5 + (i+1) * 0.8) * 3;


		var edge_noise0 =
		    sin(ribbon_time * 3 + i * 0.45) * 18
		    +
		    sin(ribbon_time * 7 + i * 1.2) * 8;


		var edge_noise1 =
		    sin(ribbon_time * 3 + (i+1) * 0.45) * 18
		    +
		    sin(ribbon_time * 7 + (i+1) * 1.2) * 8;


		var width0 =
		    _width + wobble0 + edge_noise0;


		var width1 =
		    _width + wobble1 + edge_noise1;


		var ax = p0.px + nx * width0;
		var ay = p0.py + ny * width0;

		var bx = p0.px - nx * width0;
		var by = p0.py - ny * width0;

		var cx = p1.px + nx * width1;
		var cy = p1.py + ny * width1;

		var dx2 = p1.px - nx * width1;
		var dy2 = p1.py - ny * width1;

		vertex_position_3d(_vb, ax, ay, 0);
		vertex_texcoord(_vb, 0, v0);
		vertex_colour(_vb, _col, 1);

		vertex_position_3d(_vb, cx, cy, 0);
		vertex_texcoord(_vb, 0, v1);
		vertex_colour(_vb, _col, 1);

		vertex_position_3d(_vb, dx2, dy2, 0);
		vertex_texcoord(_vb, 1, v1);
		vertex_colour(_vb, _col, 1);


		vertex_position_3d(_vb, ax, ay, 0);
		vertex_texcoord(_vb, 0, v0);
		vertex_colour(_vb, _col, 1);

		vertex_position_3d(_vb, dx2, dy2, 0);
		vertex_texcoord(_vb, 1, v1);
		vertex_colour(_vb, _col, 1);

		vertex_position_3d(_vb, bx, by, 0);
		vertex_texcoord(_vb, 1, v0);
		vertex_colour(_vb, _col, 1);
    }

    vertex_end(_vb);
}