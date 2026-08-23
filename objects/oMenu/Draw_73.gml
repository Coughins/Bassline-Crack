
if (startup_notice_screen) {
	draw_menu_startup_notice(startup_notice_age, startup_notice_exit / startup_notice_exit_length);
	exit
}

if (title_screen) {
	draw_menu_title_splash(title_exit / title_exit_length);
	exit
}

draw_menu_title_background(menu_index == MENU_SUB_MAIN, menu_index, option_index, menu_flash, menu_reveal);

draw_set_font(fMenu);

var compact_menu = (menu_index == MENU_SUB_SETTINGS || menu_index == MENU_SUB_KEYBOARD || menu_index == MENU_SUB_GAMEPAD);

var drawX = 92;
var panelX = 42;
var panelW = 446;
var rowScale = compact_menu ? 0.68 : 1;
var rowSpacing = compact_menu ? 4 : 10;
var rowStep = floor(font_height * rowScale) + (compact_menu ? 15 : option_spacing);
var rowTop = compact_menu ? 116 : 124;
var rowBottom = room_height - 58;
var rowRoom = max(80, rowBottom - rowTop);

var visible_items = max(1, floor(rowRoom / rowStep));

var start_option = menu_scroll;

var end_option = min(
	option_number[menu_index],
	menu_scroll + visible_items
);


var visible_height = (end_option - start_option) * rowStep;

var drawY = rowTop + max(0, (rowRoom - visible_height) * 0.5);

var panelY = max(48, drawY - 78);
var panelH = min(room_height - panelY - 44, visible_height + 150);

draw_menu_title_menu_shell(
	panelX,
	panelY,
	panelW,
	panelH,
	menu[menu_index],
	menu_index,
	option_index,
	end_option - start_option,
	menu_reveal,
	menu_flash
);




if (menu_index == MENU_SUB_SAVE)
{
		var save_x = panelX + panelW * 0.5;
		var save_y = panelY + 122;


		var save_text = "SAVE " + string(option_index + 1);
		var deaths_text = save_value_name[0] + save_value[0];
		var time_text = save_value_name[1] + save_value[1];

		draw_menu_title_save_focus(save_x, save_y, save_text, deaths_text, time_text, menu_flash);

	return;
}





for (var i = start_option; i < end_option; i++)
{
	var selected = (i == option_index);


	draw_menu_title_menu_option(
		drawX,
		drawY,
		option[menu_index,i],
		selected,
		option_color[menu_index,i] == c_gray,
		i - start_option,
		menu_flash,
		menu_reveal,
		rowScale,
		rowSpacing,
		compact_menu ? 220 : 330
	);



	draw_set_color(c_red);
	draw_set_alpha((selected ? 1 : 0.42) * menu_reveal)

	draw_text_transformed(
		drawX - 40,
		drawY,
		"+",
		rowScale,
		rowScale,
		0
	);


	drawY += rowStep;
}



draw_set_alpha(1);
draw_set_color(c_white);




switch(menu_index)
{
	case MENU_SUB_SETTINGS:
	case MENU_SUB_KEYBOARD:
	case MENU_SUB_GAMEPAD:

		var _mapping_arr;


		switch(menu_index)
		{
			case MENU_SUB_SETTINGS:
				_mapping_arr = setting;
			break;

			case MENU_SUB_KEYBOARD:
				_mapping_arr = keyboard;
			break;

			case MENU_SUB_GAMEPAD:
				_mapping_arr = gamepad;
			break;
		}


		drawX = panelX + 318;

		drawY = rowTop + max(0, (rowRoom - visible_height) * 0.5);



		for (var i = start_option; i < end_option; i++)
		{
			draw_menu_title_menu_value(
				drawX,
				drawY,
				_mapping_arr[i],
				i == option_index,
				i - start_option,
				menu_flash,
				menu_reveal,
				rowScale,
				rowSpacing,
				126
			);


			drawY += rowStep;
		}

	break;
}



draw_set_color(c_white);
draw_set_font(fMenu);
