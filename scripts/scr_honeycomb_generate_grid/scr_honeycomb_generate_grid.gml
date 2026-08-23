function scr_honeycomb_generate_grid(_num_cols, _num_rows, _angle_step, _row_height) {
    var _points = [];
    var _total_height = (_num_rows - 1) * _row_height;
    var _start_offset = -_total_height / 2;

    for (var row = 0; row < _num_rows; row++) {

        var _col_offset = (row mod 2 == 1) ? 0.5 : 0;

        for (var col = 0; col < _num_cols; col++) {
            var _grid_col_frac = col + _col_offset;
            var _pt = {
                grid_col:    col,
                grid_row:    row,
                base_angle:  _grid_col_frac * _angle_step,
                base_height: _start_offset + row * _row_height
            };
            array_push(_points, _pt);
        }
    }
    return _points;
}
