function scr_draw_lightning_branch(_start_x, _start_y, _perp_dir, _pulse, _alpha, _color = global.lightning_color, _depth) {
    var _branch_dir = _perp_dir + choose(-1, 1) * 90;
    var _branch_len = random_range(10, 25) / _depth;
    var _bx = _start_x + lengthdir_x(_branch_len, _branch_dir);
    var _by = _start_y + lengthdir_y(_branch_len, _branch_dir);

    draw_set_color(_color);
    draw_set_alpha(_alpha * 0.7);
    draw_line_width(_start_x, _start_y, _bx, _by, 1 * _pulse / _depth);

    if (_depth == 1 && random(1) < 0.25) {
        scr_draw_lightning_branch(_bx, _by, _branch_dir, _pulse, _alpha, _color, 2);
    }
}