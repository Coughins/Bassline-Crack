function scr_honeycomb_get_neighbor(_row, _col, _dir, _cols, _rows) {
    var _nrow = _row;
    var _ncol = _col;
    var _odd  = (_row mod 2 == 1);

    switch (_dir) {
        case HC_DIR_RIGHT:      _ncol = _col + 1; break;
        case HC_DIR_LEFT:       _ncol = _col - 1; break;
        case HC_DIR_DOWN_RIGHT: _nrow = _row + 1; _ncol = _odd ? (_col + 1) : _col; break;
        case HC_DIR_DOWN_LEFT:  _nrow = _row + 1; _ncol = _odd ? _col : (_col - 1); break;
        case HC_DIR_UP_RIGHT:   _nrow = _row - 1; _ncol = _odd ? (_col + 1) : _col; break;
        case HC_DIR_UP_LEFT:    _nrow = _row - 1; _ncol = _odd ? _col : (_col - 1); break;
    }

    var _valid = (_nrow >= 0 && _nrow < _rows);
    _ncol = ((_ncol mod _cols) + _cols) mod _cols;

    return { row: _nrow, col: _ncol, valid: _valid };
}