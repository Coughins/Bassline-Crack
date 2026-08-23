function scr_draw_face_fill(_verts_arr, _color, _fade) {
    var _faces = scr_cube_get_faces();
    var _best_face = -1;
    var _best_scale = -1;

    for (var f = 0; f < array_length(_faces); f++) {
        var _face = _faces[f];
        var _avg = (_verts_arr[_face[0]].scale + _verts_arr[_face[1]].scale + _verts_arr[_face[2]].scale + _verts_arr[_face[3]].scale) / 4;
        if (_avg > _best_scale) {
            _best_scale = _avg;
            _best_face = f;
        }
    }

    var _face = _faces[_best_face];
    var _v0 = _verts_arr[_face[0]];
    var _v1 = _verts_arr[_face[1]];
    var _v2 = _verts_arr[_face[2]];
    var _v3 = _verts_arr[_face[3]];

    var _alpha = 0.08 * _best_scale * _fade;

    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(_v0.x, _v0.y, _color, _alpha);
    draw_vertex_color(_v1.x, _v1.y, _color, _alpha);
    draw_vertex_color(_v2.x, _v2.y, _color, _alpha);
    draw_vertex_color(_v0.x, _v0.y, _color, _alpha);
    draw_vertex_color(_v2.x, _v2.y, _color, _alpha);
    draw_vertex_color(_v3.x, _v3.y, _color, _alpha);
    draw_primitive_end();
}