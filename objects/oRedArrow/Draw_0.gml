event_inherited();


var _sx = image_xscale * draw_stretch;
var _sy = image_yscale;

if (ring_pulse > 0)
{
    var _pop_a = (ring_pulse / max(ring_pulse_duration, 1)) * 0.5;

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, _sx * 1.8, _sy * 1.8, image_angle, c_white, _pop_a);
    gpu_set_blendmode(bm_normal);
}

if (chroma_amount > 0.02)
{
    var _off = chroma_amount * _k_chroma_px;
    var _fa = chroma_amount * 0.55 * image_alpha;

    gpu_set_blendmode(bm_add);

    draw_sprite_ext(sprite_index, image_index,
                    x + lengthdir_x(_off, image_angle), y + lengthdir_y(_off, image_angle),
                    _sx, _sy, image_angle, c_red, _fa);

    draw_sprite_ext(sprite_index, image_index,
                    x - lengthdir_x(_off, image_angle), y - lengthdir_y(_off, image_angle),
                    _sx, _sy, image_angle, c_aqua, _fa);

    gpu_set_blendmode(bm_normal);
}

draw_sprite_ext(sprite_index, image_index, x, y, _sx, _sy, image_angle, image_blend, image_alpha);
