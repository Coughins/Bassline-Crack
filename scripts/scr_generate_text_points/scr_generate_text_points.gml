function scr_generate_text_points(_text, _cx, _cy, _font, _spacing)
{
    var _points = [];
    draw_set_font(_font);
    var _w = string_width(_text);
    var _h = string_height(_text);
    var _pad = 10;
    var _surf_w = _w + _pad * 2;
    var _surf_h = _h + _pad * 2;

	var _surf = surface_create(_surf_w, _surf_h);
	surface_set_target(_surf);
	draw_clear_alpha(c_black, 0);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	var _k_wingdings_chance = 0.01;

	var _use_font = (random(1) < _k_wingdings_chance) ? fWingDings : fAvoidance;
	draw_set_font(_use_font);
	draw_text(_pad, _pad, _text);

	surface_reset_target();

    var _buffer = buffer_create(_surf_w * _surf_h * 4, buffer_fixed, 1);
    buffer_get_surface(_buffer, _surf, 0);

    for (var _sx = 0; _sx < _surf_w; _sx += _spacing)
    {
        for (var _sy = 0; _sy < _surf_h; _sy += _spacing)
        {
            var _offset = (_sy * _surf_w + _sx) * 4;
            var _alpha = buffer_peek(_buffer, _offset + 3, buffer_u8);

            if (_alpha > 128)
            {
array_push(_points, {
				    x: _cx - (_w / 2) + (_sx - _pad),
				    y: _cy - (_h / 2) + (_sy - _pad),
				    dist: 0,
				    reveal_t: 0,
				    revealed: false,
					color_start_t: 0,
				    alpha: 0,
				    glow_intensity: 0,
				    color_progress: 0,
					vx: 0,
				    vy: 0,
				    smear_norm: 0,
				    explode_delay: 0,
				    explode_triggered: false,
				    pending_vx: 0,
				    pending_vy: 0
				});
            }
        }
    }

	buffer_delete(_buffer);
    surface_free(_surf);

    var _min_y = infinity;
    var _max_y = -infinity;
    for (var i = 0; i < array_length(_points); i++)
    {
        _min_y = min(_min_y, _points[i].y);
        _max_y = max(_max_y, _points[i].y);
    }
    var _y_range = max(_max_y - _min_y, 1);
    for (var i = 0; i < array_length(_points); i++)
    {
        _points[i].smear_norm = ((_points[i].y - _min_y) / _y_range) * 2 - 1;
    }

    return _points;
}