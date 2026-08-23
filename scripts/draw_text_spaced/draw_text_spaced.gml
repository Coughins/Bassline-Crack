function draw_text_spaced(_x, _y, _text, _spacing, _xscale, _yscale)
{
	var xx = _x;

	for (var i = 1; i <= string_length(_text); i++)
	{
		var char = string_char_at(_text, i);

		draw_text_transformed(xx, _y, char, _xscale, _yscale, 0);

		xx += string_width(char) * _xscale + _spacing;
	}
}