function scr_edge_face_coord(_local_edge, _reversed, _t) {
    var _tt = _reversed ? (1 - _t) : _t;
    switch (_local_edge) {
        case 0: return { axis: "u", value: _tt, fixed_axis: "w", fixed_value: 0 };
        case 1: return { axis: "w", value: _tt, fixed_axis: "u", fixed_value: 1 };
        case 2: return { axis: "u", value: 1 - _tt, fixed_axis: "w", fixed_value: 1 };
        case 3: return { axis: "w", value: 1 - _tt, fixed_axis: "u", fixed_value: 0 };
    }
}