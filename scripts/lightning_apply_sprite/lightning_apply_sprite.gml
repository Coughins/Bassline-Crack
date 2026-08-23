/// @function lightning_apply_sprite()

function lightning_apply_sprite()
{
    sprite_index = sRainbowOrb;
	image_speed = 0;
    image_index = 4;

    switch (global.lightning_color)
    {
        case c_teal:    image_index = 0;  break;
        case c_blue:    image_index = 1;  break;
        case c_lime:    image_index = 2;  break;
        case c_green:   image_index = 3;  break;
        case c_aqua:    image_index = 4;  break;
        case c_orange:  image_index = 6;  break;
        case c_purple:  image_index = 7;  break;
        case c_fuchsia: image_index = 8;  break;
        case c_red:     image_index = 11; break;
        case c_yellow:  image_index = 12; break;
    }
}
