if (draw_alpha <= 0.004) exit;

var _s = draw_scale;

if (is_open) {
    gpu_set_blendmode(bm_add);
    var _door_col = is_lane_gap ? make_color_rgb(150, 240, 255) : make_color_rgb(90, 160, 200);
    draw_sprite_ext(sprite_index, 0, draw_x, draw_y, _s, _s, 0, _door_col, draw_alpha);
    gpu_set_blendmode(bm_normal);
    exit;
}

draw_sprite_ext(sprite_index, 0, draw_x, draw_y, _s, _s, blast_angle, image_blend, draw_alpha);

if (ignite_flash > 0.01) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, 0, draw_x, draw_y,
                    _s * (1 + ignite_flash * 1.6), _s * (1 + ignite_flash * 1.6),
                    blast_angle, c_white, ignite_flash * 0.85);
    gpu_set_blendmode(bm_normal);
}
