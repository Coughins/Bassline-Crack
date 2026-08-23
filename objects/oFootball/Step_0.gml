vsp += grav;

if (place_meeting(x, y + vsp, oBlock))
{
    var _sv = sign(vsp);
    if (_sv == 0) _sv = 1;

    while (!place_meeting(x, y + _sv, oBlock))
    {
        y += _sv;
    }

    if (abs(vsp) < 1)
    {
        vsp = 0;
    }
    else
    {
        vsp *= -bounce;

        squash_target = min(abs(vsp) * 0.03, 0.18);
    }
}
else
{
    y += vsp;
}

if (place_meeting(x + hsp, y, oBlock))
{
    var _sh = sign(hsp);
    if (_sh == 0) _sh = 1;

    while (!place_meeting(x + _sh, y, oBlock))
    {
        x += _sh;
    }
    hsp *= -bounce;
}
else
{
    x += hsp;
}

var on_ground = place_meeting(x, y + 1, oBlock);
hsp *= on_ground ? ground_friction : air_friction;

if (abs(hsp) < 0.05) hsp = 0;
if (abs(vsp) < 0.05) vsp = 0;

hsp = clamp(hsp, -max_spd, max_spd);
vsp = clamp(vsp, -max_spd, max_spd);

var p = instance_find(oPlayer, 0);
if (p != noone)
{
    if (p.parry_timer > 0 &&
        point_distance(x, y, p.x, p.y) < 40 &&
        !p.parry_success)
    {
        p.parry_success = true;
        audio_play_sound(sParry, 1, false, 1.5);
        instance_create_layer(x, y, layer, oParryEffect);

        var input_x = keyboard_check(vk_right) - keyboard_check(vk_left);
        var input_y = keyboard_check(vk_down) - keyboard_check(vk_up);

        var final_x, final_y;

        if (input_x != 0 || input_y != 0)
        {
            var in_len = point_distance(0, 0, input_x, input_y);
            final_x = input_x / in_len;
            final_y = input_y / in_len;
        }
        else
        {
            var away_dir = point_direction(p.x, p.y, x, y);
            final_x = lengthdir_x(1, away_dir);
            final_y = lengthdir_y(1, away_dir);
        }

        hsp = final_x * parry_power;
        vsp = final_y * parry_power;

        roll_velocity += random_range(-4, 4);
    }
}

squash = lerp(squash, squash_target, 0.18);
squash_target = lerp(squash_target, 0, 0.18);

var move_speed = point_distance(0, 0, hsp, vsp);
var target_spin = move_speed * 0.16;
if (hsp < 0)
    target_spin = -target_spin;

roll_velocity += (target_spin - roll_velocity) * 0.05;

roll_velocity *= 0.995;

roll_frame += roll_velocity;

var _frame_count = sprite_get_number(sprite_index);
roll_frame = (roll_frame + _frame_count) mod _frame_count;

image_index = floor(roll_frame * 0.5) * 2;

var target_angle = clamp(hsp * 1.5, -5, 5);

target_angle += sin(roll_frame * 0.4) * min(abs(roll_velocity) * 0.2, 1.5);

image_angle = lerp(image_angle, target_angle, 0.12);
