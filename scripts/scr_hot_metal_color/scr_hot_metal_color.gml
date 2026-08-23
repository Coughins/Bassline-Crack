function scr_hot_metal_color(_age) {
    _age = clamp(_age, 0, 1);
    if (_age < 0.25) {
        return merge_colour(c_white, c_yellow, _age / 0.25);
    } else if (_age < 0.55) {
        return merge_colour(c_yellow, c_orange, (_age - 0.25) / 0.3);
    } else if (_age < 0.85) {
        return merge_colour(c_orange, c_red, (_age - 0.55) / 0.3);
    } else {
        return merge_colour(c_red, c_black, (_age - 0.85) / 0.15);
    }
}
