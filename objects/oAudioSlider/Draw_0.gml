draw_set_color(track_color);
draw_rectangle(_k_track_x, _k_track_y - _k_track_height / 2, _k_track_x + _k_track_width, _k_track_y + _k_track_height / 2, false);

draw_set_color(fill_color);
draw_rectangle(_k_track_x, _k_track_y - _k_track_height / 2, handle_x, _k_track_y + _k_track_height / 2, false);

draw_set_color(handle_color);
draw_circle(handle_x, _k_track_y, _k_handle_radius, false);

draw_set_color(c_white);

draw_set_font(fntValue)
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(_k_track_x + _k_track_width / 2, _k_track_y - _k_title_y_offset, _k_title_text);

draw_set_halign(fa_left);
draw_set_valign(fa_middle);
draw_text(_k_track_x + _k_track_width + 20, _k_track_y, string(round(volume * 100)) + "%");

draw_set_halign(fa_left);
draw_set_valign(fa_top);