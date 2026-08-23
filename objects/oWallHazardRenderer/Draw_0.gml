gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(left_points); i++)
{
    var p = left_points[i];

    var r = ribbon_width;

    draw_set_alpha(0.07);
    draw_circle_color(
        p.x,
        p.y,
        r,
        make_color_rgb(255,40,40),
        make_color_rgb(120,0,0),
        false
    );

    draw_set_alpha(0.03);
    draw_circle_color(
        p.x,
        p.y,
        r*1.8,
        c_red,
        c_black,
        false
    );
}

for (var i = 0; i < array_length(right_points); i++)
{
    var p = right_points[i];

    var r = ribbon_width;

    draw_set_alpha(0.07);
    draw_circle_color(
        p.x,
        p.y,
        r,
        make_color_rgb(255,40,40),
        make_color_rgb(120,0,0),
        false
    );

    draw_set_alpha(0.03);
    draw_circle_color(
        p.x,
        p.y,
        r*1.8,
        c_red,
        c_black,
        false
    );
}

draw_set_alpha(1);

gpu_set_blendmode(bm_normal);