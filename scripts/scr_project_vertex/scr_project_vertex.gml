function scr_project_vertex(_v, _cx, _cy, _dist) {
    var _factor = _dist / (_dist + _v.z);
    return { x: _cx + _v.x * _factor, y: _cy + _v.y * _factor, scale: _factor };
}