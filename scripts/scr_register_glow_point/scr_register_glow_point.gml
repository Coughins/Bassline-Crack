function scr_register_glow_point(_x, _y) {
    if (!instance_exists(oBackgroundPlasma)) return;
    if (oBackgroundPlasma.glow_point_count >= oBackgroundPlasma._k_max_glow_points) return;

    var _i = oBackgroundPlasma.glow_point_count;
    oBackgroundPlasma.glow_points[_i*2]     = _x;
    oBackgroundPlasma.glow_points[_i*2 + 1] = _y;
    oBackgroundPlasma.glow_point_count++;
}