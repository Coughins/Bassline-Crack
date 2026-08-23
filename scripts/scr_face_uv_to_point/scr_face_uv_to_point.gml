function scr_face_uv_to_point(_verts_arr, _face_index, _u, _w) {
    var _faces = scr_cube_get_faces();
    var _face = _faces[_face_index];
    var _v0 = _verts_arr[_face[0]];
    var _v1 = _verts_arr[_face[1]];
    var _v2 = _verts_arr[_face[2]];
    var _v3 = _verts_arr[_face[3]];

    var _top_x = lerp(_v0.x, _v1.x, _u);
    var _top_y = lerp(_v0.y, _v1.y, _u);
    var _bot_x = lerp(_v3.x, _v2.x, _u);
    var _bot_y = lerp(_v3.y, _v2.y, _u);

    var _px = lerp(_top_x, _bot_x, _w);
    var _py = lerp(_top_y, _bot_y, _w);
    var _scale = lerp(lerp(_v0.scale, _v1.scale, _u), lerp(_v3.scale, _v2.scale, _u), _w);

    return { x: _px, y: _py, scale: _scale };
}