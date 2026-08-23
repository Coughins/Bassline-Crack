scr_register_glow_point(x, y);
event_inherited();
if (spawn_timer < spawn_duration)
{
    spawn_timer += 1;
    var _p = spawn_timer / spawn_duration;
    var _eased = 1 - power(1 - _p, 3);
    image_alpha = lerp(0, 0.1, _eased);
    var _scale = lerp(0, 1, _eased);
    image_xscale = _scale;
    image_yscale = _scale;
}

if (gravity_activated)
{
    array_push(trail_positions, [x, y]);
    if (array_length(trail_positions) > 10) array_delete(trail_positions, 0, 1);
}