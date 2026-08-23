function scr_tree_grow_homing(_nodes, _grid, _start_index, _target_x, _target_y, _start_scale) {
    var _k_wobble = 14;
    var _k_arrive_dist = 40;
    var _k_max_segments = 60;
    var _k_seg_len_floor = 18;
    var _k_seg_len_cap = 36;
    var _k_taper_per_seg = 0.985;

    var _cur_index = _start_index;
    var _cur_scale = _start_scale;

    for (var s = 0; s < _k_max_segments; s++) {
        var _cur = _nodes[_cur_index];
        if (point_distance(_cur.x, _cur.y, _target_x, _target_y) < _k_arrive_dist) break;

        var _seg_len_now = clamp(_cur_scale * 16 * 0.85, _k_seg_len_floor, _k_seg_len_cap);
        var _target_dir = point_direction(_cur.x, _cur.y, _target_x, _target_y);
        var _exempt = scr_tree_ancestor_chain(_nodes, _cur_index, TREE_SELF_EXEMPT_DIST);

        var _found = false;
        var _best_dev = 0, _best_x = 0, _best_y = 0;
        for (var _try = 0; _try < 9; _try++) {
            var _t = (_try / 8);
            var _offset = lerp(-_k_wobble * 2.5, _k_wobble * 2.5, _t) + random_range(-_k_wobble, _k_wobble);
            var _test_dir = _target_dir + _offset;
            var _nx = _cur.x + lengthdir_x(_seg_len_now, _test_dir);
            var _ny = _cur.y + lengthdir_y(_seg_len_now, _test_dir);
            if (_nx < 15 || _nx > room_width - 15 || _ny > room_height - 15 || _ny < 0) continue;
            if (scr_tree_too_close(_grid, _nodes, _nx, _ny, TREE_MIN_GAP, _exempt)) continue;
            var _dev = abs(_offset);
            if (!_found || _dev < _best_dev) {
                _found = true;
                _best_dev = _dev;
                _best_x = _nx;
                _best_y = _ny;
            }
        }

        if (!_found) {
            _best_x = clamp(_cur.x + lengthdir_x(_seg_len_now, _target_dir), 15, room_width - 15);
            _best_y = clamp(_cur.y + lengthdir_y(_seg_len_now, _target_dir), 0, room_height - 15);
        }

        _cur_scale *= _k_taper_per_seg;
        array_push(_nodes, { x: _best_x, y: _best_y, parent: _cur_index, base_scale: _cur_scale });
        var _new_index = array_length(_nodes) - 1;
        scr_tree_grid_insert(_grid, _best_x, _best_y, _new_index);
        _cur_index = _new_index;
    }

    return _cur_index;
}

function scr_tree_make_run(_nodes, _start_index, _raw_dir, _depth, _max_depth, _start_scale, _k_upward_kick, _k_photo_bias, _k_branch_taper_end, _k_min_base_scale) {
    var _node = _nodes[_start_index];
    var _dist_from_center = (_node.x - room_width / 2) / (room_width / 2);
    var _photo_direction = sign(_dist_from_center) * _k_photo_bias * abs(_dist_from_center);
    var _end_scale = max(_start_scale * _k_branch_taper_end, _k_min_base_scale);
    return {
        cur_index: _start_index,
        cur_dir: _raw_dir + _photo_direction + _k_upward_kick,
        depth: _depth,
        max_depth: _max_depth,
        start_scale: _start_scale,
        end_scale: _end_scale,
        cur_scale: _start_scale,
        segments_target: irandom_range(3, 6),
        segments_grown: 0,
        is_first_segment: (_depth == 0)
    };
}

function scr_tree_grow_canopy(_nodes, _grid, _seed_runs, _personality) {
    var _k_candidate_count  = 11;
    var _k_candidate_spread = 65;
    var _k_min_segs_for_children = 2;
    var _k_branch_taper_end = 0.85;
    var _k_min_base_scale = 0.35;
    var _k_min_grow_scale = 0.4;
    var _k_collar_bump = 1.15;
    var _k_gravity_sag = 2.5;
    var _k_upward_kick = 12;
    var _k_photo_bias = 20;
    if (_personality != undefined && is_struct(_personality)) {
        _k_gravity_sag = _personality.sag ?? _k_gravity_sag;
        _k_upward_kick = _personality.upward_kick ?? _k_upward_kick;
        _k_photo_bias = _personality.photo_bias ?? _k_photo_bias;
    }

    var _k_seg_overlap = 0.85;
    var _k_seg_len_floor = 8;
    var _k_seg_len_cap = 40;

    var _active = _seed_runs;

    while (array_length(_active) > 0) {
        var _next = [];
        for (var a = 0; a < array_length(_active); a++) {
            var _run = _active[a];
            if (_run.cur_scale < _k_min_grow_scale) continue;

            var _cur = _nodes[_run.cur_index];
            var _seg_len_now = clamp(_run.cur_scale * 16 * _k_seg_overlap, _k_seg_len_floor, _k_seg_len_cap);
            _run.cur_dir += -_k_upward_kick * 0.6 + _k_gravity_sag * (_run.segments_grown + 1);

            var _exempt = scr_tree_ancestor_chain(_nodes, _run.cur_index, TREE_SELF_EXEMPT_DIST);

            var _found = false;
            var _best_dev = 0, _best_dir = 0, _best_x = 0, _best_y = 0;
            for (var _try = 0; _try < _k_candidate_count; _try++) {
                var _t = (_k_candidate_count == 1) ? 0.5 : (_try / (_k_candidate_count - 1));
                var _offset = lerp(-_k_candidate_spread, _k_candidate_spread, _t) + random_range(-4, 4);
                var _test_dir = _run.cur_dir + _offset;
                var _nx = _cur.x + lengthdir_x(_seg_len_now, _test_dir);
                var _ny = _cur.y + lengthdir_y(_seg_len_now, _test_dir);
                if (_nx < 15 || _nx > room_width - 15 || _ny > room_height - 15 || _ny < 0) continue;
                if (scr_tree_too_close(_grid, _nodes, _nx, _ny, TREE_MIN_GAP, _exempt)) continue;

                var _dev = abs(_offset);
                if (!_found || _dev < _best_dev) {
                    _found = true;
                    _best_dev = _dev;
                    _best_dir = _test_dir;
                    _best_x = _nx;
                    _best_y = _ny;
                }
            }

            if (_found) {
                var _seg_progress = (_run.segments_target > 1) ? (_run.segments_grown / (_run.segments_target - 1)) : 1;
                _run.cur_scale = max(lerp(_run.start_scale, _run.end_scale, _seg_progress), _k_min_base_scale);
                var _collar_mult = (_run.is_first_segment) ? _k_collar_bump : 1.0;
                array_push(_nodes, { x: _best_x, y: _best_y, parent: _run.cur_index, base_scale: _run.cur_scale * _collar_mult });
                var _new_index = array_length(_nodes) - 1;
                scr_tree_grid_insert(_grid, _best_x, _best_y, _new_index);

                _run.cur_index = _new_index;
                _run.cur_dir = _best_dir;
                _run.segments_grown++;
                _run.is_first_segment = false;

                if (_run.segments_grown < _run.segments_target) {
                    array_push(_next, _run);
                    continue;
                }
            }

            if (_run.segments_grown >= _k_min_segs_for_children && _run.depth + 1 < _run.max_depth) {
                var _branch_count = irandom_range(2, 3);
                var _child_start_scale = _run.cur_scale / sqrt(_branch_count);
                var _fork_spread = random_range(30, 55);
                for (var b = 0; b < _branch_count; b++) {
                    var _tb = (_branch_count == 1) ? 0.5 : (b / (_branch_count - 1));
                    var _base_offset = lerp(-_fork_spread, _fork_spread, _tb);
                    var _jitter = random_range(-_fork_spread * 0.25, _fork_spread * 0.25);
                    var _child_raw_dir = _run.cur_dir + _base_offset + _jitter;
                    array_push(_next, scr_tree_make_run(_nodes, _run.cur_index, _child_raw_dir, _run.depth + 1, _run.max_depth, _child_start_scale, _k_upward_kick, _k_photo_bias, _k_branch_taper_end, _k_min_base_scale));
                }
            }
        }
        _active = _next;
    }
}
