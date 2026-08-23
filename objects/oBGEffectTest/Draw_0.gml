if (test_rings)
{
    gpu_set_blendmode(bm_add);
    var _cx = room_width / 2;
    var _cy = room_height / 2;
    for (var i = 0; i < array_length(bg_rings); i++)
    {
        var _radius = bg_rings[i][0];
        var _alpha  = bg_rings[i][1];
        scr_draw_smooth_ring_mask(_cx, _cy, _radius, _alpha * 0.5, 20, c_purple);
    }
    gpu_set_blendmode(bm_normal);
}