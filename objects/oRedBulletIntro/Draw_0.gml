event_inherited();

var _sx = image_xscale * draw_stretch;
var _sy = image_yscale;

if (array_length(trail_history) > 0)
{
    gpu_set_blendmode(bm_add);
    for (var i = array_length(trail_history) - 1; i >= 0; i--)
    {
        var _h = trail_history[i];
        var _fade = 1 - (i / trail_length);
        var _hs = _h.sc * lerp(0.45, 1, _fade);
        draw_sprite_ext(sprite_index, image_index, _h.x, _h.y,
                        _hs * draw_stretch, _hs, _h.ang, image_blend, _fade * 0.4 * image_alpha);
    }
    gpu_set_blendmode(bm_normal);
}

if (chroma_amount > 0.02)
{
    var _chroma_amount_fx = chroma_amount * fx_get_mult_for("introshapes", "aberration");
    var _off = _chroma_amount_fx * _k_chroma_px;
    var _fa = _chroma_amount_fx * 0.55 * image_alpha;

    gpu_set_blendmode(bm_add);

    draw_sprite_ext(sprite_index, image_index,
                    x + lengthdir_x(_off, image_angle), y + lengthdir_y(_off, image_angle),
                    _sx, _sy, image_angle, c_red, _fa);

    draw_sprite_ext(sprite_index, image_index,
                    x - lengthdir_x(_off, image_angle), y - lengthdir_y(_off, image_angle),
                    _sx, _sy, image_angle, c_aqua, _fa);

    gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, image_angle, image_blend, image_alpha);
gpu_set_blendmode(bm_normal);

if (pop_flash > 0)
{
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, _sx * 1.4, _sy * 1.4, image_angle, c_white, pop_flash);
    gpu_set_blendmode(bm_normal);
}

draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, image_angle, image_blend, image_alpha);
