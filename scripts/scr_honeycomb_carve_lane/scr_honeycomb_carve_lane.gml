function scr_honeycomb_carve_lane(_cell_edges, _edges, _cols, _rows, _home_row, _start_col,
                                  _row_drift = 0, _row_band = 1.6) {
    var _k_max_consecutive_climbs = 2;
    var _k_weight_climb           = 2;
    var _k_weight_drop            = 2;
    var _k_weight_straight        = 10;
    var _k_correction_gain        = 3;
    var _k_climb_cost             = 1.0;
    var _k_drop_cost              = 0.5;
    var _k_urgency_slack          = 1.0;
    var _k_endgame_margin         = 4.0;

    var _final_target_row = clamp(round(_home_row + _row_drift), 0, _rows - 1);

    var _row = _home_row;
    var _col = _start_col;
    var _col_progress = 0;
    var _guard = 0;
    var _guard_max = _cols * 10;
    var _last_dir = -1;

    var _consecutive_climbs = 0;
    var _climb_cap_hits = 0;
    var _forced_hits = 0;

    var _path_cells = [{ row: _row, col: _col }];
    var _path_edges = [];

    while (_col_progress < _cols && _guard < _guard_max) {
        _guard++;

        var _dir = -1;

        if (_consecutive_climbs >= _k_max_consecutive_climbs) {
            var _eid_forced = _cell_edges[_row][_col][HC_DIR_LEFT];
            if (_eid_forced != -1 && !_edges[_eid_forced].is_boundary) {
                _dir = HC_DIR_LEFT;
                _climb_cap_hits++;
            }
        }

        var _remaining_col = _cols - _col_progress;
        var _remaining_row = _final_target_row - _row;

        if (_dir == -1 && _remaining_row != 0) {
            var _cost_per_step = (_remaining_row < 0) ? _k_climb_cost : _k_drop_cost;
            var _corrective_budget = abs(_remaining_row) * _cost_per_step;

            if (_corrective_budget >= _remaining_col - _k_urgency_slack) {
                var _urgent_dir = (_remaining_row < 0) ? HC_DIR_UP_LEFT : HC_DIR_DOWN_LEFT;
                var _eid_urgent = _cell_edges[_row][_col][_urgent_dir];

                if (_eid_urgent != -1 && !_edges[_eid_urgent].is_boundary) {
                    _dir = _urgent_dir;
                    _forced_hits++;
                }
            }
        }

        var _endgame = (_remaining_col <= _k_endgame_margin);

        if (_dir == -1) {
            var _dirs = [];
            var _weights = [];

            var _progress_frac = min(_col_progress / _cols, 1);
            var _target_row = _home_row + (_final_target_row - _home_row) * _progress_frac;
            var _dev = _row - _target_row;

            var _climb_allowed = (_dev > -_row_band) && !_endgame;
            var _drop_allowed  = (_dev <  _row_band) && !_endgame;

            var _climb_w = _k_weight_climb * (1 + max(0,  _dev) * _k_correction_gain);
            var _drop_w  = _k_weight_drop  * (1 + max(0, -_dev) * _k_correction_gain);

            if (_consecutive_climbs < _k_max_consecutive_climbs && _climb_allowed) {
                var _test_ul = scr_honeycomb_get_neighbor(_row, _col, HC_DIR_UP_LEFT, _cols, _rows);
                var _eid_ul = _cell_edges[_row][_col][HC_DIR_UP_LEFT];
                if (_test_ul.valid && _eid_ul != -1 && !_edges[_eid_ul].is_boundary) {
                    array_push(_dirs, HC_DIR_UP_LEFT);
                    array_push(_weights, _climb_w);
                }
            }

            if (_drop_allowed) {
                var _test_dl = scr_honeycomb_get_neighbor(_row, _col, HC_DIR_DOWN_LEFT, _cols, _rows);
                var _eid_dl = _cell_edges[_row][_col][HC_DIR_DOWN_LEFT];
                if (_test_dl.valid && _eid_dl != -1 && !_edges[_eid_dl].is_boundary) {
                    array_push(_dirs, HC_DIR_DOWN_LEFT);
                    array_push(_weights, _drop_w);
                }
            }

            var _eid_l = _cell_edges[_row][_col][HC_DIR_LEFT];
            if (_last_dir != HC_DIR_LEFT && _eid_l != -1 && !_edges[_eid_l].is_boundary) {
                array_push(_dirs, HC_DIR_LEFT);
                array_push(_weights, _k_weight_straight);
            }

            if (array_length(_dirs) == 0) {
                array_push(_dirs, HC_DIR_LEFT);
                array_push(_weights, 8);
            }

            var _total_weight = 0;
            for (var i = 0; i < array_length(_weights); i++) _total_weight += _weights[i];
            var _roll = random(_total_weight);
            _dir = _dirs[0];
            var _accum = 0;
            for (var i = 0; i < array_length(_dirs); i++) {
                _accum += _weights[i];
                if (_roll < _accum) { _dir = _dirs[i]; break; }
            }
        }

        var _eid = _cell_edges[_row][_col][_dir];
        _edges[_eid].open = true;
        _edges[_eid].is_lane = true;
        array_push(_path_edges, _eid);

        if (_dir == HC_DIR_UP_LEFT) {
            _consecutive_climbs++;
        } else {
            _consecutive_climbs = 0;
        }

        var _nb = scr_honeycomb_get_neighbor(_row, _col, _dir, _cols, _rows);
        _col_progress += (_dir == HC_DIR_LEFT) ? 1 : 0.5;
        _row = _nb.row;
        _col = _nb.col;
        _last_dir = _dir;

        array_push(_path_cells, { row: _row, col: _col });
    }

    if (_row != _final_target_row) {
        show_debug_message("HONEYCOMB: lane carve finished its lap at row " + string(_row) +
            " instead of target row " + string(_final_target_row) +
            " — guide light will run short this run. Check the urgency/endgame knobs in scr_honeycomb_carve_lane.");
    }

    return { cells: _path_cells, edge_ids: _path_edges, climb_cap_hits: _climb_cap_hits, final_row: _row };
}
