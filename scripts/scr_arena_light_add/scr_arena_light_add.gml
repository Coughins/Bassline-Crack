function scr_arena_light_add(_x,_y,_r,_g,_b,_power)
{
    if (!instance_exists(oAvoidanceController))
        return;

    with (oAvoidanceController)
    {
        array_push(
            arena_lights,
            {
                x:_x,
                y:_y,
                r:_r,
                g:_g,
                b:_b,
                power:_power
            }
        );

        if (_power >= _k_floor_epicentre_min_power && _power >= floor_epicenter_power)
        {
            floor_epicenter_power = _power;
            floor_epicenter_x = _x;
            floor_epicenter_y = _y;
            floor_epicenter_hold = _k_floor_epicentre_hold;
        }
    }
}
