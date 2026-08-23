function scr_update_bass_ring_orbs(_ring, _radius)
{
    with (oAvoidanceController)
    {
        for (var _i = 0; _i < array_length(_ring.orbs); _i++)
        {
            var _b = _ring.orbs[_i];
            if (!instance_exists(_b)) continue;

            var _px = _b.x;
            var _py = _b.y;

            _b.x = _ring.center_x + lengthdir_x(_radius * _b.layer_mult, _b.ring_angle);
            _b.y = _ring.center_y + lengthdir_y(_radius * _b.layer_mult, _b.ring_angle);

            var _d = point_distance(_px, _py, _b.x, _b.y);
            var _s = clamp(_d / _k_fin_stretch_div, 0, _k_fin_spear_stretch - 1);

            _b.image_angle  = (_d > 0.5) ? point_direction(_px, _py, _b.x, _b.y) : _b.ring_angle;
            _b.image_xscale = 1 + _s;
            _b.image_yscale = max(0.28, 1 - _s * 0.12);
            _b.image_alpha  = 1;
            _b.heat         = 1;
            _b.image_blend  = merge_color(_b.gap_edge ? _k_fin_orb_hot : _k_fin_orb_color, c_white,
                                          clamp(_s / (_k_fin_spear_stretch - 1), 0, 1) * 0.7
                                          + _b.flash * 0.4);

            array_push(_b.spear_trail, {x : _px, y : _py, w : 1 + _s});
            if (array_length(_b.spear_trail) > _k_fin_trail_len) array_delete(_b.spear_trail, 0, 1);
        }
    }
}
