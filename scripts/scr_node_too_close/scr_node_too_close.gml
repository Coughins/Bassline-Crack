#macro TREE_MIN_GAP 24
#macro TREE_SELF_EXEMPT_DIST 30

function scr_tree_grid_create(_cell_size) {
    var _cols = ceil(room_width / _cell_size) + 1;
    var _rows = ceil(room_height / _cell_size) + 1;
    var _cells = array_create(_cols);
    for (var cx = 0; cx < _cols; cx++) {
        _cells[cx] = array_create(_rows);
        for (var cy = 0; cy < _rows; cy++) {
            _cells[cx][cy] = [];
        }
    }
    return { cell_size: _cell_size, cols: _cols, rows: _rows, cells: _cells };
}

function scr_tree_grid_insert(_grid, _x, _y, _node_index) {
    var _cx = clamp(floor(_x / _grid.cell_size), 0, _grid.cols - 1);
    var _cy = clamp(floor(_y / _grid.cell_size), 0, _grid.rows - 1);
    array_push(_grid.cells[_cx][_cy], _node_index);
}

function scr_tree_too_close(_grid, _nodes, _x, _y, _min_dist, _exempt) {
    var _cx = clamp(floor(_x / _grid.cell_size), 0, _grid.cols - 1);
    var _cy = clamp(floor(_y / _grid.cell_size), 0, _grid.rows - 1);
    var _x0 = max(0, _cx - 1), _x1 = min(_grid.cols - 1, _cx + 1);
    var _y0 = max(0, _cy - 1), _y1 = min(_grid.rows - 1, _cy + 1);
    for (var ix = _x0; ix <= _x1; ix++) {
        for (var iy = _y0; iy <= _y1; iy++) {
            var _bucket = _grid.cells[ix][iy];
            for (var b = 0; b < array_length(_bucket); b++) {
                var _idx = _bucket[b];
                var _skip = false;
                for (var e = 0; e < array_length(_exempt); e++) {
                    if (_exempt[e] == _idx) { _skip = true; break; }
                }
                if (!_skip && point_distance(_nodes[_idx].x, _nodes[_idx].y, _x, _y) < _min_dist) {
                    return true;
                }
            }
        }
    }
    return false;
}

function scr_tree_ancestor_chain(_nodes, _start_index, _max_dist) {
    var _list = [_start_index];
    var _cur = _start_index;
    var _acc = 0;
    while (true) {
        var _p = _nodes[_cur].parent;
        if (_p == -1) break;
        _acc += point_distance(_nodes[_cur].x, _nodes[_cur].y, _nodes[_p].x, _nodes[_p].y);
        if (_acc > _max_dist) break;
        array_push(_list, _p);
        _cur = _p;
    }
    return _list;
}
