function scr_honeycomb_carve_decorative_openings(_cell_edges, _edges, _cols, _rows, _min_openings, _lane_cells) {
    var _lane_lookup = ds_map_create();
    for (var i = 0; i < array_length(_lane_cells); i++) {
        var _lc = _lane_cells[i];
        ds_map_add(_lane_lookup, string(_lc.row) + "_" + string(_lc.col), true);
    }

    for (var row = 0; row < _rows; row++) {
        for (var col = 0; col < _cols; col++) {
            if (ds_map_exists(_lane_lookup, string(row) + "_" + string(col))) continue;

            var _existing_open = 0;
            var _candidates_far  = [];
            var _candidates_near = [];
            for (var d = 0; d < 6; d++) {
                var _eid = _cell_edges[row][col][d];
                if (_eid == -1) continue;
                if (_edges[_eid].open) {
                    _existing_open++;
                } else if (!_edges[_eid].is_boundary) {
                    var _nb = scr_honeycomb_get_neighbor(row, col, d, _cols, _rows);
                    var _touches_lane = _nb.valid &&
                        ds_map_exists(_lane_lookup, string(_nb.row) + "_" + string(_nb.col));
                    array_push(_touches_lane ? _candidates_near : _candidates_far, _eid);
                }
            }

            var _deficit = _min_openings - _existing_open;
            if (_deficit <= 0) continue;

            var _count = min(_deficit, array_length(_candidates_far));
            repeat (_count) {
                var _pick_index = irandom(array_length(_candidates_far) - 1);
                _edges[_candidates_far[_pick_index]].open = true;
                array_delete(_candidates_far, _pick_index, 1);
                _deficit--;
            }

            if (_deficit <= 0 || array_length(_candidates_near) == 0) continue;

            var _count2 = min(_deficit, array_length(_candidates_near));
            repeat (_count2) {
                var _pick_index2 = irandom(array_length(_candidates_near) - 1);
                _edges[_candidates_near[_pick_index2]].open = true;
                array_delete(_candidates_near, _pick_index2, 1);
            }
        }
    }

    ds_map_destroy(_lane_lookup);
}
