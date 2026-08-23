var _k_flash_ceiling = 0.55;
var _k_flash_decay   = 0.10;

if (screen_flash_alpha > 0)
{
    draw_set_alpha(clamp(screen_flash_alpha * fx_get_mult("flash"), 0, _k_flash_ceiling));
    draw_set_color(c_white);
    draw_rectangle(0, 0, window_get_width(), window_get_height(), false);
    draw_set_alpha(1);
    screen_flash_alpha -= _k_flash_decay;
    if (screen_flash_alpha < 0) screen_flash_alpha = 0;
}

if (letterbox_amount > 0.001)
{
    var _bar_h = letterbox_amount * fx_get_mult("letterbox") * (window_get_height() * 0.11);
    draw_set_color(c_black);
    draw_set_alpha(1);
    draw_rectangle(0, 0, window_get_width(), _bar_h, false);
    draw_rectangle(0, window_get_height() - _bar_h, window_get_width(), window_get_height(), false);
}
