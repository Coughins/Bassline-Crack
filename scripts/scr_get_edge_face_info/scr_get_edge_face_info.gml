function scr_get_edge_face_info(_a, _b) {
    var _faces = scr_cube_get_faces();
    var _result = [];
    for (var f = 0; f < array_length(_faces); f++) {
        var _q = _faces[f];
        for (var i = 0; i < 4; i++) {
            var _qi = _q[i];
            var _qn = _q[(i + 1) mod 4];
            if (_qi == _a && _qn == _b) {
                array_push(_result, { face_index: f, local_edge: i, reversed: false });
            } else if (_qi == _b && _qn == _a) {
                array_push(_result, { face_index: f, local_edge: i, reversed: true });
            }
        }
    }
    return _result;
}