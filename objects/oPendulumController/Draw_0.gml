var ball_x = origin_x + rod_length * sin(angle);
var ball_y = origin_y + rod_length * cos(angle);

gpu_set_blendmode(bm_add);

for (var i = 0; i < rod_count; i++)
{
    var p = i / (rod_count - 1);
    var _curr_x = lerp(origin_x, ball_x, p);
    var _curr_y = lerp(origin_y, ball_y, p);
    
    var _scale = lerp(0.3, 1.2, p);

    draw_sprite_ext(
        sRedOrb,
        0,
        _curr_x,
        _curr_y,
        _scale,
        _scale,
        radtodeg(angle),
        c_white,
        fade * 0.15
    );
}

gpu_set_blendmode(bm_normal);
