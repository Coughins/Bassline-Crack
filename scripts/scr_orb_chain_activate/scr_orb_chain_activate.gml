function scr_orb_chain_activate() {
    active = true;
    image_alpha = 1;
    hit_active = true;
    scr_impact_pulse(0.4, 3.0, 0.3);

    var _nearest = noone;
    var _nearest_dist = infinity;

    with (oRedLightningOrb) {
        if (!active && id != other.id) {
            var _d = point_distance(x, y, other.x, other.y);
            if (_d < _nearest_dist) { _nearest_dist = _d; _nearest = id; }
        }
    }
    with (oRedOrb_2) {
        if (!active && chain_eligible && id != other.id) {
            var _d = point_distance(x, y, other.x, other.y);
            if (_d < _nearest_dist) { _nearest_dist = _d; _nearest = id; }
        }
    }
	with (oDNATest) {
        if (!active && chain_eligible && id != other.id) {
            var _d = point_distance(x, y, other.x, other.y);
            if (_d < _nearest_dist) { _nearest_dist = _d; _nearest = id; }
        }
    }

    if (_nearest != noone) {
        chain_target  = _nearest;
        line_target_x = _nearest.x;
        line_target_y = _nearest.y;
        line_life     = line_life_max;
        alarm[0]      = chain_delay;
    }
}
