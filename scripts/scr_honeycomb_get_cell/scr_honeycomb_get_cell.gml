function scr_honeycomb_get_cell(_col, _row)
{
    if (_col < 0 || _col >= cols)
        return -1;

    if (_row < 0 || _row >= rows)
        return -1;


    return (_row * cols) + _col;
}