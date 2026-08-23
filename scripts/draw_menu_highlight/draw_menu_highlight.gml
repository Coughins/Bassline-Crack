function draw_menu_highlight(_x, _y, _w, _h)
{
	var left_extend = 70;
	var total_width = _w + left_extend;



	var line_count = 12;

	for (var l = 0; l < line_count; l++)
	{
		var yy = _y + 3 + (l / (line_count - 1)) * (_h - 6);


		for (var i = 0; i < 80; i++)
		{
			var xx = _x - left_extend + (total_width * i / 80);

			var dist = xx - _x;

			var alpha;

			if (dist < 0)
				alpha = power(1 + (dist / left_extend), 3);
			else
				alpha = 1 - (dist / _w);


			alpha = clamp(alpha, 0, 1);


			var blocked = false;


			for (var c = 0; c < array_length(menu_cracks_middle); c++)
			{
				var crack = menu_cracks_middle[c];

				if (crack.line == l)
				{
					var crack_start = _x - left_extend + total_width * crack.pos;
					var crack_end = crack_start + total_width * crack.width;

					if (xx > crack_start && xx < crack_end)
					{
						blocked = true;
						break;
					}
				}
			}


			if (!blocked)
			{
				draw_set_alpha(alpha * 0.15);
				draw_set_color(c_red);

				draw_rectangle(
					xx,
					yy,
					xx + (total_width / 80) + 2,
					yy + 1,
					false
				);
			}
		}
	}




	for (var i = 0; i < 80; i++)
	{
		var xx = _x - left_extend + (total_width * i / 80);

		var dist = xx - _x;

		var alpha;

		if (dist < 0)
			alpha = power(1 + (dist / left_extend), 3);
		else
			alpha = 1 - (dist / _w);


		alpha = clamp(alpha, 0, 1);


		var top_blocked = false;
		var bottom_blocked = false;


		for (var c = 0; c < array_length(menu_cracks_top); c++)
		{
			var crack = menu_cracks_top[c];

			var crack_start = _x - left_extend + total_width * crack.pos;
			var crack_end = crack_start + total_width * crack.width;


			if (xx > crack_start && xx < crack_end)
			{
				top_blocked = true;
				break;
			}
		}


		for (var c = 0; c < array_length(menu_cracks_bottom); c++)
		{
			var crack = menu_cracks_bottom[c];

			var crack_start = _x - left_extend + total_width * crack.pos;
			var crack_end = crack_start + total_width * crack.width;


			if (xx > crack_start && xx < crack_end)
			{
				bottom_blocked = true;
				break;
			}
		}



		draw_set_color(c_red);


		if (!top_blocked)
		{
			draw_set_alpha(alpha * 0.9);

			draw_rectangle(
				xx,
				_y,
				xx + (total_width / 80) + 3,
				_y + 1,
				false
			);
		}


		if (!bottom_blocked)
		{
			draw_set_alpha(alpha);

			draw_rectangle(
				xx,
				_y + _h - 1,
				xx + (total_width / 80) + 3,
				_y + _h,
				false
			);
		}
	}


	draw_set_alpha(1);
	draw_set_color(c_white);
}