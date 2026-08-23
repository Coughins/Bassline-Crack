var p = instance_find(oPlayer, 0);

if (can_parry &&
    !returning &&
    return_delay <= 0 &&
    p != noone)
{
    if (p.parry_timer > 0 &&
        point_distance(x, y, p.x, p.y) < 40)
    {
        if (!p.parry_success)
        {
            p.parry_success = true;

            audio_play_sound(sParry, 1, false, 1.5);
            instance_create_layer(x, y, layer, oParryEffect);
        }

        can_parry = false;

        return_delay = 20;

        direction = point_direction(p.x, p.y, x, y);
        speed = knockback_speed;
    }
}


if (!returning && return_delay > 0)
{
    return_delay--;

    if (return_delay <= 0)
    {
        speed = 0;
        returning = true;

        return_velocity_x = 0;
        return_velocity_y = 0;
    }

    exit;
}


if (returning)
{
    var target_angle = global.hub_orbit_angle + return_offset;

    var target_x = orbit_center_x + lengthdir_x(orbit_radius, target_angle);
    var target_y = orbit_center_y + lengthdir_y(orbit_radius, target_angle);

    var dx = target_x - x;
    var dy = target_y - y;

    return_velocity_x += dx * 0.08;
    return_velocity_y += dy * 0.08;

    return_velocity_x *= 0.92;
    return_velocity_y *= 0.92;

    x += return_velocity_x;
    y += return_velocity_y;


if (point_distance(x, y, target_x, target_y) < 8)
{
    return_settle_timer++;

    if (return_settle_timer >= 60)
    {
        x = target_x;
        y = target_y;

        return_velocity_x = 0;
        return_velocity_y = 0;

        returning = false;
        can_parry = true;

        return_settle_timer = 0;
    }
}
else
{
    return_settle_timer = 0;
}

    exit;
}


var angle = global.hub_orbit_angle + return_offset;

x = orbit_center_x + lengthdir_x(orbit_radius, angle);
y = orbit_center_y + lengthdir_y(orbit_radius, angle);