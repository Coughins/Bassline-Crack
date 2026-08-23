var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

if (!dragging && mouse_check_button_pressed(mb_left))
{
    if (point_distance(_mx, _my, handle_x, _k_track_y) <= _k_handle_radius + 4)
    {
        dragging = true;
    }
}

if (dragging && mouse_check_button_released(mb_left))
{
    dragging = false;
    ini_open("settings.ini");
    ini_write_real("audio", "master_volume", volume);
    ini_close();
}

if (dragging)
{
    handle_x = clamp(_mx, _k_track_x, _k_track_x + _k_track_width);
    volume = (handle_x - _k_track_x) / _k_track_width;
    audio_master_gain(volume);
}

preview_timer++;
if (preview_timer >= _k_preview_interval)
{
    preview_timer = 0;
    audio_play_sound(sndPlayerShoot, 10, false);
}