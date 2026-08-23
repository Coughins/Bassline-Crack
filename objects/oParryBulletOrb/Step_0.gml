event_inherited();
image_xscale = _size;
image_yscale = _size;

t++;

var p = instance_find(oPlayer, 0);

if (p != noone)
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

        orbiting = false;
        direction = point_direction(p.x, p.y, x, y);
        speed = max(speed, 10);
    }
}

if (orbiting)
{
    orbit_angle += orbit_speed;

    x = orbit_center_x + lengthdir_x(orbit_radius, orbit_angle);
    y = orbit_center_y + lengthdir_y(orbit_radius, orbit_angle);
}