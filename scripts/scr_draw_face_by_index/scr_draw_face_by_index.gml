function scr_draw_face_by_index(_verts_arr, _color, _face_index, _alpha_mult) {
    var _faces = scr_cube_get_faces();
    var _face = _faces[_face_index];

    var _v0 = _verts_arr[_face[0]];
    var _v1 = _verts_arr[_face[1]];
    var _v2 = _verts_arr[_face[2]];
    var _v3 = _verts_arr[_face[3]];

    var _avg_scale = (_v0.scale + _v1.scale + _v2.scale + _v3.scale) / 4;
    var _alpha = 0.08 * _avg_scale * _alpha_mult;

    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(_v0.x, _v0.y, _color, _alpha);
    draw_vertex_color(_v1.x, _v1.y, _color, _alpha);
    draw_vertex_color(_v2.x, _v2.y, _color, _alpha);
    draw_vertex_color(_v0.x, _v0.y, _color, _alpha);
    draw_vertex_color(_v2.x, _v2.y, _color, _alpha);
    draw_vertex_color(_v3.x, _v3.y, _color, _alpha);
    draw_primitive_end();
}