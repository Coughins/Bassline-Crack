function savedata_struct() constructor {
	x = 0
	y = 0
	r = "rMainHub"
	death = 0
	time = 0
	item = 0
	gravity_direction = 0
	seed = random_get_seed()
	facing = 1
	skin = ""
	weapon = "oGun"
	avoidance_best_hits = -1
}

function savedata_load() {

	global.savedata.save_active = deep_copy(global.savedata.save)

	savedata_start_game(true)
}

function savedata_set_defaults() {
	global.savedata.save = deep_copy(global.savedata.save_default)
	global.savedata.save_active = deep_copy(global.savedata.save_default)

	savedata_set_both("seed", random_get_seed())
}

function savedata_new_game() {

	savedata_set_defaults()

	savedata_start_game(false)
}

function savedata_read() {

	var savename = savedata_get_savename()

	if (file_exists(savename)) {
		var
		f = file_text_open_read(savename),
		struct = json_parse(file_text_read_string(f))

		for (var i = array_length(global.savedata.save_key) - 1; i >= 0; i--)
			if struct[$global.savedata.save_key[i]] == undefined
				global.savedata.save[$global.savedata.save_key[i]] = global.savedata.save_default[$global.savedata.save_key[i]]
			else
				global.savedata.save[$global.savedata.save_key[i]] = struct[$global.savedata.save_key[i]]

		delete struct

		if (global.savedata.save.r == "rAvoidance") {
			global.savedata.save.r = global.savedata.save_default.r
			global.savedata.save.x = global.savedata.save_default.x
			global.savedata.save.y = global.savedata.save_default.y
			global.savedata.save.facing = global.savedata.save_default.facing
			global.savedata.save.gravity_direction = global.savedata.save_default.gravity_direction
		}

		file_text_close(f)

		global.savedata.save_is_read = true

		return true
	}

	return false
}

function savedata_save() {

	if argument_count > 0
		for (i = 0; i < argument_count; i++)
			savedata_set(argument[i], savedata_get_active(argument[i]))
	else
		global.savedata.save = deep_copy(global.savedata.save_active)



	savedata_write()
}

function savedata_set_slot(slot) {
	global.savedata.save_index = slot
}

function savedata_get_slot() {
	return global.savedata.save_index
}

function savedata_start_game(spawn_player) {

	if (spawn_player)
		player_respawn()

	var r = asset_get_index(savedata_get_active("r"))

	if (room == r)
		room_restart()
	else
		room_goto(r)

	global.game_playing = true
}

function savedata_write() {

	var f = file_text_open_write(savedata_get_savename())

	file_text_write_string(f, json_stringify(global.savedata.save))

	file_text_close(f)
}

function savedata_get_savename() {
	return global.savedata.save_prefix + string(global.savedata.save_index) + global.savedata.save_suffix
}

function savedata_exists() {
	return file_exists(savedata_get_savename())
}

function savedata_is_read() {
	return global.savedata.save_is_read
}

function savedata_set_index(save_index) {
	if (global.savedata.save_index != save_index) {
		global.savedata.save_is_read = false
		global.savedata.save_index = save_index
	}
}

function savedata_get_index() {
	return global.savedata.save_index
}

function savedata_get(key) {
	return global.savedata.save[$key]
}

function savedata_set(key, val) {
	global.savedata.save[$key] = val
}

function savedata_get_active(key) {
	return global.savedata.save_active[$key]
}

function savedata_set_active(key, val) {
	global.savedata.save_active[$key] = val
}

function savedata_set_both(key, val) {
	savedata_set(key, val)
	savedata_set_active(key, val)
}

function savedata_save_player() {
	savedata_set_active("x", oPlayer.x)
	savedata_set_active("y", oPlayer.y)
	savedata_set_active("r", room_get_name(room))
	savedata_set_active("gravity_direction", oPlayer.gravity_direction)
	savedata_set_active("facing", oPlayer.facing)
	savedata_set_active("weapon", object_get_name(oPlayer.weapon_object))
	savedata_save()
}
