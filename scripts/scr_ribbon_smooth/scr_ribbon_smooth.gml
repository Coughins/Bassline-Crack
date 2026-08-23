function scr_ribbon_smooth(_points, _steps)
{
    var result = [];

    var count = array_length(_points);

    if (count < 4)
        return _points;


    for (var i = 0; i < count - 1; i++)
    {
        var p0 = _points[max(0, i-1)];
        var p1 = _points[i];
        var p2 = _points[min(count-1, i+1)];
        var p3 = _points[min(count-1, i+2)];


        for (var j = 0; j < _steps; j++)
        {
            var t = j / _steps;
            var t2 = t * t;
            var t3 = t2 * t;


            var px =
                0.5 *
                (
                    (2 * p1.px)
                    +
                    (-p0.px + p2.px) * t
                    +
                    (2*p0.px - 5*p1.px + 4*p2.px - p3.px) * t2
                    +
                    (-p0.px + 3*p1.px - 3*p2.px + p3.px) * t3
                );


            var py =
                0.5 *
                (
                    (2 * p1.py)
                    +
                    (-p0.py + p2.py) * t
                    +
                    (2*p0.py - 5*p1.py + 4*p2.py - p3.py) * t2
                    +
                    (-p0.py + 3*p1.py - 3*p2.py + p3.py) * t3
                );


            array_push(result,
            {
                px : px,
                py : py
            });
        }
    }


    array_push(result, _points[count-1]);

    return result;
}