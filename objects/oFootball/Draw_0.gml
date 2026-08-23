var sx = image_xscale * (1 + squash);
var sy = image_yscale * (1 - squash);

draw_sprite_ext(
    sprite_index,
    image_index,
    x,
    y,
    sx,
    sy,
    image_angle,
    c_white,
    image_alpha
);