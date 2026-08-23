if (startup_notice_screen) {
	startup_notice_age++

	if (startup_notice_exit <= 0 && (keyboard_check_pressed(vk_shift) || input_check_pressed("jump"))) {
		audio_play_sound(sConfirm, 1, false)
		startup_notice_exit = 1
	}

	if (startup_notice_exit > 0) {
		startup_notice_exit++

		if (startup_notice_exit >= startup_notice_exit_length) {
			startup_notice_screen = false
			startup_notice_exit = 0
			title_age = 0
			title_exit = 0
			title_input_wait_release = keyboard_check(vk_shift) || input_check("jump")
		}
	}

	exit
}

if (title_screen) {
	title_age++

	if (title_input_wait_release) {
		if (!keyboard_check(vk_shift) && !input_check("jump"))
			title_input_wait_release = false
	}
	else if (title_exit <= 0 && (keyboard_check_pressed(vk_shift) || input_check_pressed("jump"))) {
		audio_play_sound(sConfirm, 1, false)
		title_exit = 1
	}

	if (title_exit > 0) {
		title_exit++
		menu_flash = max(menu_flash, title_exit / title_exit_length)

		if (title_exit >= title_exit_length) {
			title_screen = false
			title_exit = 0
			menu_age = 0
			menu_reveal = 0
			menu_flash = 1.2
			menu_index = MENU_SUB_MAIN
			option_index = 0
		}
	}

	exit
}

menu_age++
menu_reveal = min(1, menu_reveal + 1 / 26)
menu_flash = max(0, menu_flash - 0.045)

if (button_changing != -1) {
	
	button_changing_countdown -= f2sec(1)
	
	if button_changing_countdown <= 0 {
		button_changing = -1
	}
	
	if (button_changing == INPUT_DEVICE.KEYBOARD && keyboard_lastkey != 0) {
		button_changing = -1
		
		input_mapping_change(keyboard_mapping[option_index], keyboard_lastkey, INPUT_DEVICE.KEYBOARD)
		get_keyboard_button_strings()
		
		var buttonWidth
		buttonWidth = string_length(keyboard[option_index]) * font_width
		keyboard_width_max = keyboard_width_max < buttonWidth ? buttonWidth : keyboard_width_max
	} else if (button_changing == INPUT_DEVICE.GAMEPAD && gamepad_button_get_any()) {
		button_changing = -1
		
		input_mapping_change(gamepad_mapping[option_index], gamepad_button_get_any(), INPUT_DEVICE.GAMEPAD)
		get_gamepad_button_strings()
		
		var buttonWidth
		buttonWidth = string_length(gamepad[option_index]) * font_width
		gamepad_width_max = gamepad_width_max < buttonWidth ? buttonWidth : gamepad_width_max
	}
} else {

	var buttonUp, buttonDown
	buttonUp = input_check_pressed("up")
	buttonDown = input_check_pressed("down")
	
	if (buttonUp || buttonDown) {

		var old_option = option_index;

		option_index = option_index + buttonDown - buttonUp
		
		if (option_index < 0) {
			option_index = option_number[menu_index] - 1
		} else if (option_index >= option_number[menu_index]) {
			option_index = 0
		}
		
		if (old_option != option_index)
		{
			audio_play_sound(sMenu, 1, false);
			menu_flash = max(menu_flash, 0.46)
		}
		
		var compact_menu = (menu_index == MENU_SUB_SETTINGS || menu_index == MENU_SUB_KEYBOARD || menu_index == MENU_SUB_GAMEPAD)
		var row_scale = compact_menu ? 0.68 : 1
		var row_step = floor(font_height * row_scale) + (compact_menu ? 15 : option_spacing)
		var row_top = compact_menu ? 116 : 124
		var row_bottom = room_height - 58
		var visible_items = max(1, floor(max(80, row_bottom - row_top) / row_step))

		if (option_number[menu_index] > visible_items)
		{
			var max_scroll = option_number[menu_index] - visible_items;

			menu_scroll = clamp(
				option_index - floor(visible_items / 2),
				0,
				max_scroll
			);
		}
		else
		{
			menu_scroll = 0;
		}
		
		if (menu_index == MENU_SUB_SAVE) {
			savedata_set_index(option_index)
			savedata_read()
			event_user(0)
		}
	}
	
		if (input_check_pressed("jump")) {

			if (!(menu_index == MENU_SUB_MAIN && option_index == 4))
			{
				audio_play_sound(sConfirm, 1, false);
				menu_flash = max(menu_flash, 0.95)
			}

			switch (menu_index) {
			case MENU_SUB_MAIN:
			switch (option_index) {
				case 0:
				menu_index = MENU_SUB_SAVE
				option_index = 0
				savedata_read()
				event_user(0)
				break

				case 1:
				menu_index = MENU_SUB_SETTINGS
				option_index = 0
				break

				case 2:
				menu_index = MENU_SUB_KEYBOARD
				option_index = 0
				break

				case 3:
				menu_index = MENU_SUB_GAMEPAD
				option_index = 0
				break

				case 4:
				game_end()
				break
			}
			break
			
			case MENU_SUB_SAVE:
			savedata_set_index(option_index)
			
			var saveExists = savedata_exists()
			
			menu_index = MENU_SUB_START
			option_index = saveExists ? 0 : 1
			option_color[MENU_SUB_START,0] = saveExists ? c_white : c_gray
			break
			
			case MENU_SUB_START:
			switch (option_index) {
				case 0:
				if (savedata_exists())
					savedata_load()
				break

				case 1:
				if (!savedata_exists()) {
					savedata_new_game()
				} else {
					menu_index = MENU_SUB_OVERWRITE
					option_index = 0
				}
				break
			}
			break
			
			case MENU_SUB_OVERWRITE:
			switch (option_index) {
				case 0:
				menu_index = MENU_SUB_START
				option_index = 0
				break

				case 1:
				savedata_new_game()
				break
			}
			break
			
			case MENU_SUB_SETTINGS:
			switch (option_index) {
				case 0:
				setting_set("fullscreen", !setting_get("fullscreen"))
				break

				case 1:
				setting_set("smoothing", !setting_get("smoothing"))
				break

				case 4:
				setting_set("vsync", !setting_get("vsync"))
				break

				case 5:
				setting_set_defaults()
				break
			}
			
			event_user(1)
			
			break
			
			case MENU_SUB_KEYBOARD:
			switch (option_index) {
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				button_changing = INPUT_DEVICE.KEYBOARD
				button_changing_countdown = button_changing_length
				keyboard_lastkey = 0
				break
				
				case 10:
				input_set_defaults(INPUT_DEVICE.KEYBOARD)
				get_keyboard_button_strings()
				break
			}
			break
			
			case MENU_SUB_GAMEPAD:
			switch (option_index) {
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
				button_changing = INPUT_DEVICE.GAMEPAD
				button_changing_countdown = button_changing_length
				break
				
				case 10:
				input_set_defaults(INPUT_DEVICE.GAMEPAD)
				get_gamepad_button_strings()
				break
			}
		}
	}
	
if (input_check_pressed("shoot")) {

	switch (menu_index) {

		case MENU_SUB_SAVE:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_MAIN;
			option_index = 0;

			break;


		case MENU_SUB_START:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_SAVE;
			option_index = savedata_get_index();

			break;


		case MENU_SUB_OVERWRITE:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_START;
			option_index = 0;

			break;


		case MENU_SUB_SETTINGS:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_MAIN;
			setting_write_all();
			option_index = 1;

			break;


		case MENU_SUB_KEYBOARD:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_MAIN;
			input_mappings_save(INPUT_DEVICE.KEYBOARD);
			option_index = 2;

			break;


		case MENU_SUB_GAMEPAD:

			audio_play_sound(sBack, 1, false);
			menu_flash = max(menu_flash, 0.68)

			menu_index = MENU_SUB_MAIN;
			input_mappings_save(INPUT_DEVICE.GAMEPAD);
			option_index = 3;

			break;
	}
}
	
	var buttonLeft, buttonRight
	buttonRight = input_check_pressed("right")
	buttonLeft = input_check_pressed("left")
	
	if (buttonLeft || buttonRight) {
		menu_flash = max(menu_flash, 0.34)

		if (menu_index == MENU_SUB_SETTINGS) {
			switch (option_index) {
				case 2:
				setting_set("music_volume", setting_get("music_volume") + setting_music_change * (buttonRight - buttonLeft))
				setting[2] = string(setting_get("music_volume"))
				break

				case 3:
				setting_set("effect_volume", setting_get("effect_volume") + setting_sound_change * (buttonRight - buttonLeft))
				setting[3] = string(setting_get("effect_volume"))
				break
			}
		} else if (menu_index == MENU_SUB_GAMEPAD) {
			if (option_index == 11) {
				global.gamepad_slot = wrap(global.gamepad_slot + buttonRight - buttonLeft, 0, 11)
				gamepad[11] = string(global.gamepad_slot)
			}
		}
	}
}
