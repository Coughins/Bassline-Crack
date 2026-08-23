function scr_get_orbit_boost(_t) {
    var _hits = [623, 643, 662, 681];
    var _peak_speeds = [11, 15, 20, 26];
    var _base_speeds = [3, 5, 8, 12];
    var _starting_base = 3;
    var _ramp = 10;

    var _min_dist = _ramp + 1;
    var _nearest_peak = _starting_base;
    var _current_base = _starting_base;

    for (var i = 0; i < array_length(_hits); i++) {
        if (_t >= _hits[i]) {
            _current_base = _base_speeds[i];
        }
        var _d = abs(_t - _hits[i]);
        if (_d < _min_dist) {
            _min_dist = _d;
            _nearest_peak = _peak_speeds[i];
        }
    }

    var _boost_t = clamp(1 - (_min_dist / _ramp), 0, 1);
    var _eased_boost = _boost_t * _boost_t * (3 - 2 * _boost_t);

    return {
        eased_boost: _eased_boost,
        orbit_speed: lerp(_current_base, _nearest_peak, _eased_boost)
    };
}