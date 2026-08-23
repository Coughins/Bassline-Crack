function scr_cube_get_vertices(_size) {
    var _v = [];
    array_push(_v, { x: -_size, y: -_size, z: -_size });
    array_push(_v, { x:  _size, y: -_size, z: -_size });
    array_push(_v, { x:  _size, y:  _size, z: -_size });
    array_push(_v, { x: -_size, y:  _size, z: -_size });
    array_push(_v, { x: -_size, y: -_size, z:  _size });
    array_push(_v, { x:  _size, y: -_size, z:  _size });
    array_push(_v, { x:  _size, y:  _size, z:  _size });
    array_push(_v, { x: -_size, y:  _size, z:  _size });
    return _v;
}