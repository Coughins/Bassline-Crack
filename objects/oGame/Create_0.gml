if (instance_number(object_index) > 1) {
	instance_destroy()
	exit
}

randomize()

resetting_room = ""

pause_surface = -1
pause_dim = 0.75

debug_text = "DEBUG"

#macro CONFIG_FILENAME "config.ini"
#macro CONFIG_SECTION_KEYBOARD "Keyboard"
#macro CONFIG_SECTION_GAMEPAD "Gamepad"
#macro CONFIG_SECTION_SETTINGS "Settings"
#macro CONFIG_SECTION_FX "FXTuning"
#macro CONFIG_SECTION_KUNAI "KunaiTuning"
#macro CONFIG_SECTION_LASER "LaserTuning"

#macro DEBUG false
#macro GAME_WIDTH 800
#macro GAME_HEIGHT 608
#macro FPS_BASE 50

#macro DEBUG_STRIP_W 480

global.game_playing = false
global.game_paused = false
global.game_running = false
window_set_caption("Bassline Crack")

global.gamepad_slot = 0
global.debug_nodeath = false

global.hitcount_mode = true
global.startup_notice_seen = false
global.menu_room = rMenu

hitcount_hud_last = -1
hitcount_hud_pulse = 0
hitcount_hud_shock = 0

global.avoidance_practice_active = false
global.avoidance_practice_t = 0
global.avoidance_practice_name = ""
global.avoidance_practice_return_menu = false
global.avoidance_practice_stamp_seed = 0

global.avoid_col_blood       = make_color_rgb(96, 8, 18)
global.avoid_col_danger      = make_color_rgb(255, 42, 38)
global.avoid_col_warning     = make_color_rgb(255, 46, 72)
global.avoid_col_ember       = make_color_rgb(255, 84, 28)
global.avoid_col_hot         = make_color_rgb(255, 216, 184)
global.avoid_col_cyan        = make_color_rgb(72, 214, 255)
global.avoid_col_cyan_soft   = make_color_rgb(132, 232, 255)
global.avoid_col_violet      = make_color_rgb(162, 72, 255)
global.avoid_col_armor_dark  = make_color_rgb(7, 12, 26)
global.avoid_col_armor_mid   = make_color_rgb(21, 34, 54)
global.avoid_col_armor_edge  = make_color_rgb(112, 198, 226)

global.lightning_color = global.avoid_col_cyan

global.bc_cli_profile_enabled = false
global.bc_cli_profile_quit_on_complete = false
global.bc_cli_profile_room = "avoidance"
global.bc_cli_profile_index = 0
global.bc_cli_profile_frames = 160
global.bc_cli_profile_segments = []
global.bc_cli_profile_capture_enabled = false
global.bc_cli_profile_capture_dir = "bc_profile_captures"
global.bc_cli_profile_hub_frame = 0
global.bc_cli_profile_hub_samples = 0
global.bc_cli_profile_hub_invalid_samples = 0
global.bc_cli_profile_hub_fps_sum = 0
global.bc_cli_profile_hub_fps_min = 999999
if (DEBUG) {
	var _arg_count = parameter_count()
	for (var _arg_i = 1; _arg_i <= _arg_count; _arg_i++) {
		var _arg = string_lower(parameter_string(_arg_i))
		if (_arg == "--bc-profile-avoidance") {
			global.bc_cli_profile_enabled = true
			global.bc_cli_profile_quit_on_complete = true
			global.bc_cli_profile_room = "avoidance"
		}
		else if (_arg == "--bc-profile-hub") {
			global.bc_cli_profile_enabled = true
			global.bc_cli_profile_quit_on_complete = true
			global.bc_cli_profile_room = "hub"
		}
		else if (string_pos("--bc-profile-room=", _arg) == 1) {
			global.bc_cli_profile_enabled = true
			global.bc_cli_profile_quit_on_complete = true
			global.bc_cli_profile_room = string_copy(_arg, string_length("--bc-profile-room=") + 1, string_length(_arg))
		}
		else if (_arg == "--bc-profile-captures") {
			global.bc_cli_profile_capture_enabled = true
		}
		else if (string_pos("--bc-profile-frames=", _arg) == 1) {
			var _value = real(string_copy(_arg, string_length("--bc-profile-frames=") + 1, string_length(_arg)))
			if (_value > 0)
				global.bc_cli_profile_frames = max(30, _value)
		}
	}

	if (global.bc_cli_profile_enabled && global.bc_cli_profile_room == "avoidance") {
		var _profile_frames = global.bc_cli_profile_frames
		global.bc_cli_profile_segments = [
			{name:"Tree",                t:1826, frames:_profile_frames},
			{name:"Black Holes",         t:2597, frames:_profile_frames},
			{name:"Cube",                t:4000, frames:_profile_frames},
			{name:"Honeycomb",           t:5219, frames:_profile_frames},
			{name:"Arrow Arc + Big Orb", t:5960, frames:_profile_frames},
			{name:"Final Laser + Mill",  t:6628, frames:_profile_frames},
			{name:"Final Cut",           t:7249, frames:60}
		]
	}
}

global.player_depth = -1
global.player_blood_depth = -101
global.player_blood_part = part_type_create()
global.player_blood_part_life = 150
global.player_blood_part_speed = 5
global.player_blood_part_gravity = 0.125
part_type_sprite(global.player_blood_part, sBlood, false, false, true)
part_type_direction(global.player_blood_part, 0, 360, 0, 0)

global.player_blood_part_sys = part_system_create()
part_system_depth(global.player_blood_part_sys, -101)

global.input = noone
global.audio = noone
global.savedata = noone

instance_create_layer(0, 0, layer, oInput)
instance_create_layer(0, 0, layer, oAudio)
instance_create_layer(0, 0, layer, oSaveData)

global.settings = new setting_struct()
setting_read_all()
setting_apply_all()

if (global.bc_cli_profile_enabled) {
	global.debug_nodeath = true
	global.hitcount_mode = true
	global.game_playing = true
	if (global.bc_cli_profile_capture_enabled) {
		if (!directory_exists(global.bc_cli_profile_capture_dir))
			directory_create(global.bc_cli_profile_capture_dir)
		show_debug_message("[BC_PROFILE] captures: " + global.bc_cli_profile_capture_dir)
	}
	if (global.bc_cli_profile_room == "hub") {
		show_debug_message("[BC_PROFILE] enabled: Hub for " + string(global.bc_cli_profile_frames) + " frames")
		room_goto(rMainHub)
	}
	else {
		show_debug_message("[BC_PROFILE] enabled: " + string(array_length(global.bc_cli_profile_segments)) + " avoidance segments")
		room_goto(rAvoidance)
	}
}
else {
	room_goto_next()
}
