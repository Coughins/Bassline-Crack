if (DEBUG && global.game_playing) {

	if (input_check_pressed("debug_nodeath")) {
		global.debug_nodeath = !global.debug_nodeath
		sfx_play_sound(sndBlockChange)
	}

	if (input_check_pressed("debug_save") && instance_exists(oPlayer)) {
		savedata_save_player()
		sfx_play_sound(sndBlockChange)
	}

	if (mouse_check_button_pressed(mb_left)) {

		if (!instance_exists(oPlayer) || oPlayer.dead)
			player_respawn()

		oPlayer.x = mouse_x
		oPlayer.y = mouse_y
	}

	if (input_check_pressed("debug_warp")) {
		var r = asset_get_index(get_string("Go to room: ", ""))
		if (room_exists(r))
			room_goto(r)
	}

	if (input_check_pressed("debug_next_room")) {
		if room != room_last
			room_goto_next()
	} else if (input_check_pressed("debug_prev_room")) {
		if room != room_first
			room_goto_previous()
	}
}

hitcount_hud_pulse = max(0, hitcount_hud_pulse - 0.08)
hitcount_hud_shock = max(0, hitcount_hud_shock - 0.12)

var _hitcount_hud_active =
	room == rAvoidance &&
	global.hitcount_mode &&
	(!variable_global_exists("avoidance_practice_active") ||
	 !global.avoidance_practice_active) &&
	instance_exists(oAvoidanceController)

if (_hitcount_hud_active) {
	var _hud_hits = oAvoidanceController.hit_count
	if (hitcount_hud_last >= 0 && _hud_hits > hitcount_hud_last) {
		hitcount_hud_pulse = 1
		hitcount_hud_shock = 1
	}
	hitcount_hud_last = _hud_hits
} else {
	hitcount_hud_last = -1
	hitcount_hud_pulse = 0
	hitcount_hud_shock = 0
}

if (global.game_playing) {

	if (input_check_pressed("pause")) {
		global.game_paused = !global.game_paused

		if (global.game_paused) {
			instance_deactivate_all(true)
			instance_activate_object(oAudio)
			instance_activate_object(oInput)
			instance_activate_object(oSaveData)
		} else {
			instance_activate_all()
		}

		game_free_pause_surface()
	}

	if (!global.game_paused) {

		savedata_set_active("time", savedata_get_active("time") + f2sec(1))

		if (input_check_pressed("retry")) {
			audio_stop_all()
			savedata_save("death", "time")
			savedata_load()

			resetting_room = savedata_get("r")
		}
	}
}

if (input_check_pressed("menu"))
	game_return_to_menu()

if (input_check_pressed("quit"))
	game_end()

if (input_check_pressed("fullscreen")) {
	setting_set("fullscreen", !global.settings[$"fullscreen"])

	with oMenu event_user(1)
}

if (input_check_pressed("screenshot"))
	screen_save(string_lettersdigits(date_datetime_string(date_current_datetime())) + ".png")
