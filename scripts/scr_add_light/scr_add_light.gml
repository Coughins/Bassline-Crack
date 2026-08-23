function scr_add_light(_x, _y, _col, _power)
{
    if (!instance_exists(oAvoidanceController))
        return;

    with (oAvoidanceController)
    {
        array_push(arena_lights,
        {
            x: _x,
            y: _y,
            r: colour_get_red(_col) / 255,
            g: colour_get_green(_col) / 255,
            b: colour_get_blue(_col) / 255,
            power: _power
        });

        if (_power >= _k_floor_epicentre_min_power && _power >= floor_epicenter_power)
        {
            floor_epicenter_power = _power;
            floor_epicenter_x = _x;
            floor_epicenter_y = _y;
            floor_epicenter_hold = _k_floor_epicentre_hold;
        }
    }
}
