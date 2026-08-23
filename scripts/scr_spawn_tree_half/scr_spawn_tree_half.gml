function scr_spawn_tree_half(_tree_data, _start_idx, _end_idx) {
    var _nodes = _tree_data.nodes;
    var _child_counts = array_create(array_length(_nodes), 0);
    for (var _ci = 0; _ci < array_length(_nodes); _ci++) {
        var _parent_i = _nodes[_ci].parent;
        if (_parent_i >= 0 && _parent_i < array_length(_child_counts)) {
            _child_counts[_parent_i]++;
        }
    }

    for (var i = _start_idx; i < _end_idx; i++) {
        if (i >= array_length(_nodes)) break;
        var _node = _nodes[i];
        var _inst = instance_create_layer(_node.x, _node.y, layer, oTree);
		_inst.image_alpha = 0;
		_inst.spawn_delay = _node.spawn_delay;
		var _base_scale = variable_struct_exists(_node, "base_scale") ? _node.base_scale : 1;
		_inst.base_scale = _base_scale;
		_inst.image_xscale = _base_scale;
		_inst.image_yscale = _base_scale;
		_inst.node_index = i;
		_inst.branch_child_count = _child_counts[i];
		_inst.branch_is_leaf = (_child_counts[i] <= 0);
		_inst.branch_role = (_base_scale >= 4) ? 2 : ((_base_scale >= 2.35) ? 1 : 0);
		_inst.branch_spur_count = (_base_scale >= 4) ? 5 : ((_base_scale >= 2.35) ? 4 : 2);

		if (_node.parent != -1 && _node.parent < array_length(_nodes)) {
		    var _pnode = _nodes[_node.parent];
		    _inst.branch_dir = point_direction(_node.x, _node.y, _pnode.x, _pnode.y);
		    _inst.branch_len = point_distance(_node.x, _node.y, _pnode.x, _pnode.y);
		    _inst.branch_parent_x = _pnode.x;
		    _inst.branch_parent_y = _pnode.y;
		    _inst.branch_parent_scale = variable_struct_exists(_pnode, "base_scale") ? _pnode.base_scale : _base_scale;
		} else {
		    _inst.branch_dir = 90;
		    _inst.branch_len = sprite_get_width(_inst.sprite_index);
		    _inst.branch_parent_x = _node.x;
		    _inst.branch_parent_y = _node.y + sprite_get_width(_inst.sprite_index);
		    _inst.branch_parent_scale = _base_scale;
		}

		_node.inst = _inst;
    }
}
