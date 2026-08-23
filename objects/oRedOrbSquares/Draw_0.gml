if (hide_visual) exit;

if (is_corner && stretch > 1.15)
{
    var _perp = direction + 90;
    var _off = ((stretch - 1) * 2.2 + burst_escalation * 1.2) * fx_get_mult_for("eruption", "aberration");
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index,
                    x + lengthdir_x(_off, _perp), y + lengthdir_y(_off, _perp),
                    image_xscale * stretch, image_yscale, image_angle, c_red, 0.4);
    draw_sprite_ext(sprite_index, image_index,
                    x - lengthdir_x(_off, _perp), y - lengthdir_y(_off, _perp),
                    image_xscale * stretch, image_yscale, image_angle, c_aqua, 0.4);
    gpu_set_blendmode(bm_normal);
}

if (pop_flash > 0 || birth_heat > 0)
{
    gpu_set_blendmode(bm_add);
    var _flash = max(pop_flash, birth_heat * 0.7);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.3 * stretch, image_yscale * 1.3, image_angle,
                    c_white, _flash);

    if (birth_heat > 0.1)
    {
        var _tl = 10 + birth_heat * 22 + burst_escalation * 10;
        draw_set_color(merge_color(glow_color, c_white, birth_heat));
        draw_set_alpha(birth_heat * 0.55);
        draw_line_width(x - lengthdir_x(_tl, direction), y - lengthdir_y(_tl, direction), x, y,
                        2 + birth_heat * (is_corner ? 5 : 2.5));
        draw_set_alpha(1);
    }
    gpu_set_blendmode(bm_normal);
}

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * stretch, image_yscale / max(1, sqrt(stretch)),
                direction, image_blend, image_alpha);
