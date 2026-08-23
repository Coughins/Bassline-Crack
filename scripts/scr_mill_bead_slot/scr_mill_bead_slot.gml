/// @param {struct} _scar   a record from `mill_scars`
/// @param {real} _r_in     innermost radius a bead may sit at
/// @param {real} _rx       half-width of the visible area
/// @param {real} _ry       half-height of the visible area
function scr_mill_bead_slot(_scar, _slot, _slots, _r_in, _rx, _ry, _fill) {
    var _half = _slots div 2;
    var _sign = (_slot < _half) ? -1 : 1;

    var _side_i = (_sign < 0) ? (_half - 1 - _slot) : (_slot - _half);
    var _pair_i = _side_i div 2;
    var _pair_end = _side_i mod 2;
    var _gate_len = 110;
    var _gap_len = 4;
    var _dist_abs = _r_in + _pair_i * (_gate_len + _gap_len) + _pair_end * _gate_len;
    var _dist = _dist_abs * _sign;

    return {
        dist : _dist,
        x    : lengthdir_x(_dist, _scar.ang),
        y    : lengthdir_y(_dist, _scar.ang)
    };
}

/// @param {real} _scar_index
function scr_mill_link_resting_gates(_scar_index) {
    var _gates = [];
    with (oFallingRedOrb) {
        if (mill_orb && mill_scar_index == _scar_index && waiting_to_fall == 1 && !dissolving) {
            array_push(_gates, id);
        }
    }

    for (var _s = 1; _s < array_length(_gates); _s++) {
        var _key = _gates[_s];
        var _p = _s - 1;
        while (_p >= 0 && _gates[_p].mill_slot > _key.mill_slot) {
            _gates[_p + 1] = _gates[_p];
            _p--;
        }
        _gates[_p + 1] = _key;
    }

    for (var _i = 0; _i < array_length(_gates) - 1; _i++) {
        var _a = _gates[_i];
        var _b = _gates[_i + 1];
        if ((_a.mill_slot div 2) == (_b.mill_slot div 2) && abs(_a.mill_slot - _b.mill_slot) == 1) {
            if ((_a.mill_slot mod 2) == 0) {
                _a.mill_link_to = _b;
            } else {
                _b.mill_link_to = _a;
            }
        }
    }
}
