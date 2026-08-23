function scr_honeycomb_spawn()
{
    var _spacing_x = cell_radius * 1.75;
    var _spacing_y = cell_radius * 1.5;

    var _start_x = 100;
    var _start_y = 80;


    for (var yy = 0; yy < cell_count_y; yy++)
    {
        for (var xx = 0; xx < cell_count_x; xx++)
        {
            var _cx = _start_x + xx * _spacing_x;

            if (yy mod 2 == 1)
                _cx += cell_radius * 0.85;


            var _cy = _start_y + yy * _spacing_y;


            var _cell = 
            {
                x:_cx,
                y:_cy,

                active:false,

                rotation:0,

                core_alpha:core_alpha,
                wall_alpha:wall_alpha,

                spawn_scale:0.1,
                spawn_alpha:0,

                bullets:[]
            };


            array_push(cells,_cell);
        }
    }
}