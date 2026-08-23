shader_time += delta_time * 0.000001;

glitch_timer--;

if (glitch_timer <= 0)
{

    target_glitch = random_range(0.05, 0.18);

    glitch_timer = irandom_range(room_speed*2, room_speed*5);
}

var idle_glitch = 0.015 + sin(shader_time * 0.8) * 0.01;
var menu_boost = 0;

if (room == rMenu && instance_exists(oMenu))
{
	var _menu = instance_find(oMenu, 0);
	var _menu_flash = variable_instance_exists(_menu, "menu_flash") ? _menu.menu_flash : 0;
	var _title_exit = 0;

	if (variable_instance_exists(_menu, "title_exit") && variable_instance_exists(_menu, "title_exit_length"))
	{
		_title_exit = _menu.title_exit_length > 0 ? _menu.title_exit / _menu.title_exit_length : 0;
	}

	if (variable_instance_exists(_menu, "title_screen") && _menu.title_screen)
	{
		menu_boost = 0.035 + power(max(0, sin(shader_time * 2.4)), 9) * 0.10;
	}

	menu_boost = max(menu_boost, _menu_flash * 0.28);
	menu_boost = max(menu_boost, power(clamp(_title_exit, 0, 1), 0.55) * 1.35);
}

target_glitch = max(target_glitch * 0.80, idle_glitch);
target_glitch = max(target_glitch, menu_boost);

glitch_amount = lerp(glitch_amount, target_glitch, 0.08);

screen_offset = 0;

if (screen_shake_timer > 0)
{
    screen_shake_timer--;

    screen_offset = irandom_range(-8, 8);
}
else
{
    screen_offset = 0;

    if (glitch_amount > 1 && random(1) < 0.08)
    {
        screen_shake_timer = irandom_range(2, 5);
    }
}
