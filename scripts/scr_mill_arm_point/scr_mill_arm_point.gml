/// @param {real} _arm   which arm of that wave, 0 .. _w.count-1
/// @param {real} _cx    pivot x
/// @param {real} _cy    pivot y
/// @return {struct} {x, y, ang, r}
function scr_mill_arm_point(_w, _arm, _f, _cx, _cy) {
    var _est = lerp(_w.r_in, (_w.rx_out + _w.ry_out) * 0.5, _f);
    var _ang = _w.base + _arm * (360 / _w.count) + _w.off + _est * _w.twist * _w.sign;
    var _r   = lerp(_w.r_in,
                    scr_mill_edge_radius(_ang, _w.rx_out, _w.ry_out) * _w.fill * _w.scale,
                    _f);

    return {
        x   : _cx + lengthdir_x(_r, _ang),
        y   : _cy + lengthdir_y(_r, _ang),
        ang : _ang,
        r   : _r
    };
}
