function scr_rotate_vertex(_v, _ax, _ay) {
    var _y1 = _v.y * dcos(_ax) - _v.z * dsin(_ax);
    var _z1 = _v.y * dsin(_ax) + _v.z * dcos(_ax);
    var _x1 = _v.x;

    var _x2 = _x1 * dcos(_ay) + _z1 * dsin(_ay);
    var _z2 = -_x1 * dsin(_ay) + _z1 * dcos(_ay);
    var _y2 = _y1;

    return { x: _x2, y: _y2, z: _z2 };
}