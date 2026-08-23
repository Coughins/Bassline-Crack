if (DEBUG && global.game_playing) {
	var _mode_text = debug_text +
		(global.debug_nodeath ? "  [DEL] NODEATH" : "")

	if (room == rMainHub) {
		_mode_text += "  [H] " + (global.hitcount_mode ? "HITS" : "LETHAL")
	}

	draw_set_color(c_red)
	draw_set_font(0)
	draw_text(4, GAME_HEIGHT - string_height("W") - 4, _mode_text)
	draw_set_color(c_white)
}

if (room == rMainHub) {
	var _best_hits = savedata_get_active("avoidance_best_hits")
	var _best_hits_text = "BEST HITS: " + ((_best_hits < 0) ? "-" : string(_best_hits))

	draw_set_color(c_white)
	draw_set_halign(fa_right)
	draw_set_valign(fa_top)
	draw_text(GAME_WIDTH - 4, 4, _best_hits_text)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}

if (global.game_paused && surface_exists(pause_surface)) {
	draw_surface_ext(pause_surface, 0, 0, 1, 1, 0, c_white, 1)
}
