function catmull_rom(p0, p1, p2, p3, t) {
    var _t2 = t*t;
    var _t3 = _t2*t;
    return 0.5 * (
        (2*p1) +
        (-p0 + p2) * t +
        (2*p0 - 5*p1 + 4*p2 - p3) * _t2 +
        (-p0 + 3*p1 - 3*p2 + p3) * _t3
    );
}