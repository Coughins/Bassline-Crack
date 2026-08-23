function scr_start_orbit_ring(_idx)
{
    var _ring = undefined;

    with (oAvoidanceController)
    {
        var _px = instance_exists(oPlayer) ? oPlayer.x : _k_fin_cx;
        var _py = instance_exists(oPlayer) ? oPlayer.y : _k_fin_cy;

        var _cx = lerp(_px, _k_fin_cx, _k_fin_orbit_mix[_idx]);
        var _cy = lerp(_py, _k_fin_cy, _k_fin_orbit_mix[_idx]);
        var _r  = _k_fin_orbit_r_out[_idx];
        var _n  = _k_fin_orbit_count[_idx];

        _ring = {
            idx         : _idx,
            state       : "rush_in",
            timer       : 0,
            orbs        : [],
            center_x    : _cx,
            center_y    : _cy,
            rot         : random(360),
            radius      : _r,
            prev_radius : _r
        };

        for (var _i = 0; _i < _n; _i++)
        {
            var _slot = _i * (360 / _n);
            var _ang  = _slot + _ring.rot;
            var _ox   = _cx + lengthdir_x(_r, _ang);
            var _oy   = _cy + lengthdir_y(_r, _ang);

            var _b = instance_create_layer(_ox, _oy, "Instances", oBassRingOrb);
            _b.ring_angle  = _slot;
            _b.layer_mult  = 1;
            _b.arrived     = true;
            _b.spear_trail = [];
            array_push(_ring.orbs, _b);
        }

        array_push(orbit_rings, _ring);
        fin_charge = max(fin_charge, 0.25);
    }

    return _ring;
}
