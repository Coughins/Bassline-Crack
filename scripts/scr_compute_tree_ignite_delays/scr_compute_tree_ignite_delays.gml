function scr_compute_tree_ignite_delays(_tree_data, _frames_per_hop) {
    var _nodes = _tree_data.nodes;
    var _count = array_length(_nodes);

    var _children = array_create(_count);
    for (var i = 0; i < _count; i++) _children[i] = [];
    for (var i = 0; i < _count; i++) {
        var _p = _nodes[i].parent;
        if (_p != -1) array_push(_children[_p], i);
    }

    var _dist = array_create(_count, -1);
    var _queue = [];
    array_push(_queue, _tree_data.trunk_end);
    _dist[_tree_data.trunk_end] = 0;

    var _qi = 0;
    while (_qi < array_length(_queue)) {
        var _cur = _queue[_qi];
        _qi += 1;

        var _neighbors = [];
        for (var c = 0; c < array_length(_children[_cur]); c++) {
            array_push(_neighbors, _children[_cur][c]);
        }
        var _par = _nodes[_cur].parent;
        if (_par != -1) array_push(_neighbors, _par);

        for (var n = 0; n < array_length(_neighbors); n++) {
            var _next = _neighbors[n];
            if (_dist[_next] == -1) {
                _dist[_next] = _dist[_cur] + 1;
                array_push(_queue, _next);
            }
        }
    }

    for (var i = 0; i < _count; i++) {
        _nodes[i].ignite_delay = _dist[i] * _frames_per_hop;
    }
}