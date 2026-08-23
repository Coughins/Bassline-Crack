event_inherited();

if (gravity_activated && array_length(trail_positions) > 0)
{
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < array_length(trail_positions); i++)
    {
        var _pos = trail_positions[i];
        var _alpha = (i / array_length(trail_positions)) * 0.5;
        draw_sprite_ext(sprite_index, image_index, _pos[0], _pos[1], image_xscale, image_yscale, image_angle, image_blend, _alpha);
    }
    gpu_set_blendmode(bm_normal);
}

draw_self();