function scr_get_lightning_rgb()
{
    return [
        color_get_red(global.lightning_color) / 255,
        color_get_green(global.lightning_color) / 255,
        color_get_blue(global.lightning_color) / 255
    ];
}