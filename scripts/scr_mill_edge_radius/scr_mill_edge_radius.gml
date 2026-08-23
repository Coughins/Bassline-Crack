/// @param {real} _half_w  half-width of the visible area
/// @param {real} _half_h  half-height of the visible area
/// @return {real} px from the pivot to the boundary along _ang
function scr_mill_edge_radius(_ang, _half_w, _half_h) {
    var _c = abs(dcos(_ang));
    var _s = abs(dsin(_ang));

    var _rx = (_c > 0.00001) ? (_half_w / _c) : 100000;
    var _ry = (_s > 0.00001) ? (_half_h / _s) : 100000;

    return min(_rx, _ry);
}
