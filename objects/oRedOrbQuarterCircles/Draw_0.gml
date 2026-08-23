event_inherited();

gpu_set_blendmode(bm_add);

if (circle_id == 1) {
  draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle,
                  merge_color(image_blend, make_color_rgb(188, 255, 255), 0.85), image_alpha);
} else {
  draw_self();
}

gpu_set_blendmode(bm_normal);
