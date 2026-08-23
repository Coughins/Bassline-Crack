function scr_get_face_random_point(_verts_arr, _face_index) {
    var _faces = scr_cube_get_faces();
    var _face = _faces[_face_index];

    var _v0 = _verts_arr[_face[0]];
    var _v1 = _verts_arr[_face[1]];
    var _v2 = _verts_arr[_face[2]];
    var _v3 = _verts_arr[_face[3]];

    var _u = random(1);
    var _w = random(1);

    var _top_x = lerp(_v0.x, _v1.x, _u);
    var _top_y = lerp(_v0.y, _v1.y, _u);
    var _bot_x = lerp(_v3.x, _v2.x, _u);
    var _bot_y = lerp(_v3.y, _v2.y, _u);

    var _px = lerp(_top_x, _bot_x, _w);
    var _py = lerp(_top_y, _bot_y, _w);

    var _avg_scale = (_v0.scale + _v1.scale + _v2.scale + _v3.scale) / 4;

    return { x: _px, y: _py, scale: _avg_scale };
}