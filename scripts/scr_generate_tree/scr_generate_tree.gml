function scr_generate_tree(_target_x = room_width / 2, _target_y = room_height - 40) {
    var _grid = scr_tree_grid_create(TREE_MIN_GAP);

    var _nodes = [];
    var _k_trunk_end_scale = 2.5;
    var _personality = {
        sag: random_range(1.5, 3.5),
        upward_kick: random_range(6, 18),
        photo_bias: random_range(10, 30),
        taper_exponent: random_range(1.5, 2.4),
        trunk_noise_amp: random_range(0.08, 0.25)
    };

    var _k_root_seg_len  = 24;
    var _orb_x = storm_orb_x;
    var _orb_y = storm_orb_y;
    var _wrap_radius = _k_storm_clearing_radius + 18;

    var _root_count = 3;
    var _root_base_scale = 5.2;
    var _root_wrap_scale = 3.0;
    var _anchor_root_slot = floor(_root_count / 2);

    var _climb = random_range(75, 100);

    var _root_points = array_create(_root_count);
    for (var r = 0; r < _root_count; r++) {
        var _pts = [];
        var _spread = (_root_count <= 1) ? 0 : lerp(-190, 190, r / (_root_count - 1));
        var _start_x = clamp(_orb_x + _spread + random_range(-15, 15), 30, room_width - 30);
        var _start_y = room_height - 6;
        array_push(_pts, { x: _start_x, y: _start_y, base_scale: _root_base_scale });

        var _entry_angle = point_direction(_orb_x, _orb_y, _start_x, _start_y);
        var _entry_x = _orb_x + lengthdir_x(_wrap_radius, _entry_angle);
        var _entry_y = _orb_y + lengthdir_y(_wrap_radius, _entry_angle);
        var _approach_steps = max(3, round(point_distance(_start_x, _start_y, _entry_x, _entry_y) / _k_root_seg_len));
        for (var s = 1; s <= _approach_steps; s++) {
            var _t = s / _approach_steps;
            var _ease = 1 - power(1 - _t, 2);
            array_push(_pts, {
                x: lerp(_start_x, _entry_x, _ease) + random_range(-4, 4),
                y: lerp(_start_y, _entry_y, _ease) + random_range(-4, 4),
                base_scale: lerp(_root_base_scale, _root_base_scale * 0.9, _t)
            });
        }

        var _wrap_dir = choose(-1, 1);
        var _sweep = random_range(200, 260);
        var _wrap_steps = max(6, round((_wrap_radius * 2 * pi * (_sweep / 360)) / _k_root_seg_len));
        for (var s = 1; s <= _wrap_steps; s++) {
            var _t = s / _wrap_steps;
            var _ang = _entry_angle + _wrap_dir * _sweep * _t;
            var _radius_here = _wrap_radius + sin(_t * pi) * 6;
            array_push(_pts, {
                x: _orb_x + lengthdir_x(_radius_here, _ang) + random_range(-3, 3),
                y: _orb_y + lengthdir_y(_radius_here, _ang) - _t * _climb + random_range(-3, 3),
                base_scale: lerp(_root_base_scale * 0.9, _root_wrap_scale, _t)
            });
        }

        _root_points[r] = _pts;
    }

    var _anchor_pts = _root_points[_anchor_root_slot];
    var _cur_index = -1;
    for (var pi2 = 0; pi2 < array_length(_anchor_pts); pi2++) {
        var _pt = _anchor_pts[pi2];
        array_push(_nodes, { x: _pt.x, y: _pt.y, parent: _cur_index, base_scale: _pt.base_scale });
        _cur_index = array_length(_nodes) - 1;
    }
    var _anchor_wrap_tip = _cur_index;

    var _converge_x = _orb_x;
    var _converge_y = _orb_y - _wrap_radius - _climb - 20;
    _cur_index = _anchor_wrap_tip;
    var _converge_steps = max(3, round(point_distance(_nodes[_anchor_wrap_tip].x, _nodes[_anchor_wrap_tip].y, _converge_x, _converge_y) / _k_root_seg_len));
    for (var s = 1; s <= _converge_steps; s++) {
        var _t = s / _converge_steps;
        var _cur = _nodes[_cur_index];
        var _nx = lerp(_cur.x, _converge_x, 0.4) + random_range(-3, 3);
        var _ny = lerp(_cur.y, _converge_y, 0.4) + random_range(-3, 3);
        array_push(_nodes, {
            x: _nx, y: _ny, parent: _cur_index,
            base_scale: lerp(_root_wrap_scale, _k_trunk_end_scale, _t)
        });
        _cur_index = array_length(_nodes) - 1;
    }

    var _trunk_end = _cur_index;
    var _trunk_len_final = _cur_index;

    for (var r = 0; r < _root_count; r++) {
        if (r == _anchor_root_slot) continue;
        var _pts2 = _root_points[r];
        var _graft_index = _anchor_wrap_tip;
        for (var pi3 = array_length(_pts2) - 1; pi3 >= 0; pi3--) {
            var _pt2 = _pts2[pi3];
            array_push(_nodes, { x: _pt2.x, y: _pt2.y, parent: _graft_index, base_scale: _pt2.base_scale });
            _graft_index = array_length(_nodes) - 1;
        }
    }

    var _k_branch_start_fraction = 0.45;
    var _k_branch_step_sparse = 5;
    var _k_branch_step_dense  = 2;
    var _branch_start_index = ceil(_trunk_len_final * _k_branch_start_fraction);

    var _best_origin = _branch_start_index;
    var _best_origin_dist = point_distance(_nodes[_branch_start_index].x, _nodes[_branch_start_index].y, _target_x, _target_y);
    for (var _oi = _branch_start_index + 1; _oi <= _trunk_len_final; _oi++) {
        var _od = point_distance(_nodes[_oi].x, _nodes[_oi].y, _target_x, _target_y);
        if (_od < _best_origin_dist) {
            _best_origin_dist = _od;
            _best_origin = _oi;
        }
    }

    var _seed_runs = [];

    var _homing_start_scale = 2.5;
    var _homing_tip = scr_tree_grow_homing(_nodes, _grid, _best_origin, _target_x, _target_y, _homing_start_scale);
    if (_homing_tip != _best_origin) {
        var _hc_count = 3;
        for (var _hc = 0; _hc < _hc_count; _hc++) {
            var _htb = (_hc_count == 1) ? 0.5 : (_hc / (_hc_count - 1));
            var _hdir = 270 + lerp(-90, 90, _htb) + random_range(-15, 15);
            array_push(_seed_runs, scr_tree_make_run(_nodes, _homing_tip, _hdir, 0, 4, _nodes[_homing_tip].base_scale, _personality.upward_kick, _personality.photo_bias, 0.85, 0.35));
        }
    }
    var i = _branch_start_index;
    while (i <= _trunk_len_final) {
        var _progress = (_trunk_len_final > _branch_start_index)
            ? (i - _branch_start_index) / (_trunk_len_final - _branch_start_index)
            : 1;
        var _lobe_count = (_progress < 0.6) ? irandom_range(2, 4) : irandom_range(4, 6);
        var _spread = lerp(35, 95, _progress);
        var _vigor_max_depth = floor(lerp(5, 7, _progress));
        var _lobe_start_scale = lerp(1.8, 2.6, _progress);

        for (var _bi = 0; _bi < _lobe_count; _bi++) {
            var _tb = (_lobe_count == 1) ? 0.5 : (_bi / (_lobe_count - 1));
            var _base_offset = lerp(-_spread, _spread, _tb);
            var _jitter = random_range(-_spread * 0.15, _spread * 0.15);
            var _radial_dir = 270 + _base_offset + _jitter;
            array_push(_seed_runs, scr_tree_make_run(_nodes, i, _radial_dir, 0, _vigor_max_depth, _lobe_start_scale, _personality.upward_kick, _personality.photo_bias, 0.85, 0.35));
        }

        var _step = round(lerp(_k_branch_step_sparse, _k_branch_step_dense, _progress));
        i += max(1, _step);
    }
    scr_tree_grow_canopy(_nodes, _grid, _seed_runs, _personality);

    var _children = array_create(array_length(_nodes));
    for (var j = 0; j < array_length(_nodes); j++) {
        _children[j] = [];
    }
    for (var k = 0; k < array_length(_nodes); k++) {
        var _p = _nodes[k].parent;
        if (_p != -1) {
            array_push(_children[_p], k);
        }
    }

    var _queue = [0];
    var _spawn_dist = array_create(array_length(_nodes), -1);
    _spawn_dist[0] = 0;
    var _qi = 0;
    while (_qi < array_length(_queue)) {
        var _bfs_cur = _queue[_qi];
        _qi++;
        for (var c = 0; c < array_length(_children[_bfs_cur]); c++) {
            var _child = _children[_bfs_cur][c];
            _spawn_dist[_child] = _spawn_dist[_bfs_cur] + 1;
            array_push(_queue, _child);
        }
    }
    for (var m = 0; m < array_length(_nodes); m++) {
        _nodes[m].spawn_delay = min(_spawn_dist[m] * 0.6, 14);
    }

    return { nodes: _nodes, trunk_end: _trunk_end };
}
