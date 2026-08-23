function scr_honeycomb_build_topology(_cols, _rows, _hex_radius) {
    var _corner_deg = [-30, 30, 90, 150, 210, 270];
    var _edge_dir   = [HC_DIR_RIGHT, HC_DIR_DOWN_RIGHT, HC_DIR_DOWN_LEFT, HC_DIR_LEFT, HC_DIR_UP_LEFT, HC_DIR_UP_RIGHT];
    var _opposite   = [HC_DIR_LEFT, HC_DIR_UP_LEFT, HC_DIR_UP_RIGHT, HC_DIR_RIGHT, HC_DIR_DOWN_RIGHT, HC_DIR_DOWN_LEFT];

    var _w = sqrt(3) * _hex_radius;
    var _h = _hex_radius * 1.5;
    var _total_width = _cols * _w;

    var _vertex_map = ds_map_create();
    var _vertices = [];
    var _edges = [];

    var _cell_edges = array_create(_rows);
    for (var row = 0; row < _rows; row++) {
        _cell_edges[row] = array_create(_cols);
        for (var col = 0; col < _cols; col++) {
            _cell_edges[row][col] = array_create(6, -1);
        }
    }

    for (var row = 0; row < _rows; row++) {
        var _row_offset = (row mod 2 == 1) ? (_w * 0.5) : 0;

        for (var col = 0; col < _cols; col++) {
            var _cx = col * _w + _row_offset;
            var _cy = row * _h;

            var _corner_x = array_create(6);
            var _corner_y = array_create(6);
            var _corner_vid = array_create(6);

            for (var i = 0; i < 6; i++) {
                var _rad = degtorad(_corner_deg[i]);
                var _px = _cx + cos(_rad) * _hex_radius;
                var _py = _cy + sin(_rad) * _hex_radius;
                _corner_x[i] = _px;
                _corner_y[i] = _py;

                var _wrapped_x = ((_px mod _total_width) + _total_width) mod _total_width;
                var _key = string(round(_wrapped_x * 100)) + "_" + string(round(_py * 100));

                var _vid;
                if (ds_map_exists(_vertex_map, _key)) {
                    _vid = _vertex_map[? _key];
                } else {
                    _vid = array_length(_vertices);
                    array_push(_vertices, { flat_x: _wrapped_x, flat_y: _py });
                    ds_map_add(_vertex_map, _key, _vid);
                }
                _corner_vid[i] = _vid;
            }

            for (var i = 0; i < 6; i++) {
                var _dir = _edge_dir[i];
                if (_cell_edges[row][col][_dir] != -1) continue;

                var _j = (i + 1) mod 6;
                var _eid = array_length(_edges);
                array_push(_edges, {
                    va: _corner_vid[i], vb: _corner_vid[_j],
                    ax: _corner_x[i], ay: _corner_y[i],
                    bx: _corner_x[_j], by: _corner_y[_j],
                    open: false,
                    is_boundary: false,
                    is_lane: false,
                    specs: []
                });
                _cell_edges[row][col][_dir] = _eid;

                var _nb = scr_honeycomb_get_neighbor(row, col, _dir, _cols, _rows);
                if (_nb.valid) {
                    _cell_edges[_nb.row][_nb.col][_opposite[i]] = _eid;
                } else {
                    _edges[_eid].is_boundary = true;
                }
            }
        }
    }

    ds_map_destroy(_vertex_map);

    return { vertices: _vertices, edges: _edges, cell_edges: _cell_edges, total_width: _total_width };
}