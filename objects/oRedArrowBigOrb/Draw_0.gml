event_inherited();

var _f = clamp(speed / 12, 0, 1);

gpu_set_blendmode(bm_add);

if (_f > 0.15)
{
    var _split = _f * 3.5;
    var _sx = lengthdir_x(_split, direction + 90);
    var _sy = lengthdir_y(_split, direction + 90);

    draw_sprite_ext(sprite_index, image_index, x + _sx, y + _sy, image_xscale * (1 + _f * 1.5),
                    image_yscale, direction, make_color_rgb(255, 20, 20), 0.5 * _f);
    draw_sprite_ext(sprite_index, image_index, x - _sx, y - _sy, image_xscale * (1 + _f * 1.5),
                    image_yscale, direction, make_color_rgb(20, 220, 255), 0.5 * _f);
}

if (arrow_birth > 0.02)
{
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * (1 + arrow_birth),
                    image_yscale * (1 + arrow_birth), image_angle, c_white, arrow_birth * 0.6);
}

gpu_set_blendmode(bm_normal);

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * (1 + _f * 1.5), image_yscale,
                image_angle, merge_color(image_blend, c_white, arrow_birth * 0.7), image_alpha);
