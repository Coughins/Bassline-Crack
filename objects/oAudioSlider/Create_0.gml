_k_track_x = 300;
_k_track_y = 500;
_k_track_width = 200;
_k_track_height = 8;
_k_handle_radius = 12;
_k_preview_interval = room_speed;
_k_title_text = "Master Volume";
_k_title_y_offset = 30;

track_color = c_dkgray;
fill_color = c_white;
handle_color = c_white;

dragging = false;
preview_timer = 0;

ini_open("settings.ini");
volume = ini_read_real("audio", "master_volume", 1);
ini_close();

audio_master_gain(volume);

handle_x = _k_track_x + (volume * _k_track_width);

depth = 1