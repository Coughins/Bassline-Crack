///@func game_is_resetting_room()
function game_is_resetting_room() {
	return oGame.resetting_room != ""
}

///@func game_get_resetting_room()
function game_get_resetting_room() {
	return oGame.resetting_room
}

///@func game_free_pause_surface()
function game_free_pause_surface() {
	with (oGame) {
		if (surface_exists(pause_surface))
			surface_free(pause_surface)

		pause_surface = -1
	}
}

///@func game_return_to_menu()
function game_return_to_menu() {
	if (global.game_running) {
		savedata_save("time")
		savedata_save("death")
		savedata_write()
	}
	
	instance_destroy(oPlayer)
	
	global.game_running = false
	global.game_playing = false
	global.game_paused = false
	
	game_free_pause_surface()
	
	room_goto(global.menu_room)
}

///@func bc_profile_should_capture_frame(frame, total_frames)
function bc_profile_should_capture_frame(_frame, _total_frames) {
	var _early = min(8, max(1, _total_frames - 2))
	var _mid = max(1, round(_total_frames * 0.5))
	var _late = max(1, _total_frames - 2)

	return _frame == _early || _frame == _mid || _frame == _late
}

///@func bc_profile_capture_frame(prefix, frame)
function bc_profile_capture_frame(_prefix, _frame) {
	if (!DEBUG)
		return

	if (!variable_global_exists("bc_cli_profile_capture_enabled") || !global.bc_cli_profile_capture_enabled)
		return

	var _dir = global.bc_cli_profile_capture_dir
	if (!directory_exists(_dir))
		directory_create(_dir)

	var _frame_text = string(_frame)
	repeat (max(0, 4 - string_length(_frame_text))) {
		_frame_text = "0" + _frame_text
	}

	var _file = _dir + "/" + _prefix + "_f" + _frame_text + ".png"
	screen_save(_file)
	show_debug_message("[BC_PROFILE] capture " + _file)
}
