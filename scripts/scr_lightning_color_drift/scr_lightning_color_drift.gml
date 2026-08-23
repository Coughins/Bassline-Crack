function scr_lightning_color_drift(_color, _amount) {
    var _r = clamp(color_get_red(_color)   + random_range(-255, 255) * _amount, 0, 255);
    var _g = clamp(color_get_green(_color) + random_range(-255, 255) * _amount, 0, 255);
    var _b = clamp(color_get_blue(_color)  + random_range(-255, 255) * _amount, 0, 255);
    return make_color_rgb(_r, _g, _b);
}