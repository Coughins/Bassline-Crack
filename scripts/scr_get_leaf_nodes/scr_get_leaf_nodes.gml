function scr_get_leaf_nodes(_tree_data) {
    var _nodes = _tree_data.nodes;
    var _count = array_length(_nodes);
    var _is_parent = array_create(_count, false);
    for (var i = 0; i < _count; i++) {
        var _p = _nodes[i].parent;
        if (_p != -1) _is_parent[_p] = true;
    }
    var _leaves = [];
    for (var i = 0; i < _count; i++) {
        if (!_is_parent[i]) array_push(_leaves, i);
    }
    return _leaves;
}