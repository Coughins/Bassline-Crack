function scr_draw_intro_traces() {
    var _k_trace_width_bleed = 26;
    var _k_trace_width_glow = 10;
    var _k_trace_width_core = 3;
	var _k_trace_base_color = global.lightning_color;
    var _k_trace_hot_color  = c_white;

    gpu_set_blendmode(bm_add);

    var _n = array_length(intro_ring_bullets);
    for (var i = 0; i < _n; i++)
    {
        var _a = intro_ring_bullets[i];
        if (!instance_exists(_a) || !_a.revealed) continue;

        var _next_i = i + 1;
        if (_next_i >= _n || intro_ring_bullets[_next_i].shape_id != _a.shape_id)
        {
            var _first_i = i;
            while (_first_i > 0 && intro_ring_bullets[_first_i - 1].shape_id == _a.shape_id) _first_i--;
            _next_i = _first_i;
            if (_next_i == i) continue;
        }

        var _b = intro_ring_bullets[_next_i];
        if (!instance_exists(_b) || !_b.revealed) continue;

        var _heat = max(_a.pop_flash, _b.pop_flash);
        var _col = merge_color(_k_trace_base_color, _k_trace_hot_color, _heat);

        draw_set_color(_col);
        draw_set_alpha((0.06 + _heat * 0.14));
        draw_line_width(_a.x, _a.y, _b.x, _b.y, _k_trace_width_bleed);
        draw_set_alpha(0.25 + _heat * 0.4);
        draw_line_width(_a.x, _a.y, _b.x, _b.y, _k_trace_width_glow);
        draw_set_color(merge_color(_col, c_white, 0.5));
        draw_set_alpha(0.6 + _heat * 0.4);
        draw_line_width(_a.x, _a.y, _b.x, _b.y, _k_trace_width_core);
    }

    var _nx = array_length(intro_x_bullets);
    for (var i = 0; i < _nx; i++)
    {
        var _a = intro_x_bullets[i];
        if (!instance_exists(_a) || !_a.revealed) continue;

        var _heat = _a.pop_flash;
        var _col = merge_color(_k_trace_base_color, _k_trace_hot_color, _heat);

        if (_a.trace_order == 1)
        {
            draw_set_color(_col);
            draw_set_alpha(0.05 + _heat * 0.14);
            draw_line_width(_a.intro_cx, _a.intro_cy, _a.x, _a.y, _k_trace_width_bleed);
            draw_set_alpha(0.2 + _heat * 0.4);
            draw_line_width(_a.intro_cx, _a.intro_cy, _a.x, _a.y, _k_trace_width_glow);
            draw_set_color(merge_color(_col, c_white, 0.5));
            draw_set_alpha(0.6 + _heat * 0.4);
            draw_line_width(_a.intro_cx, _a.intro_cy, _a.x, _a.y, _k_trace_width_core);
        }
        else
        {
            var _prev = intro_x_bullets[i - 1];
            if (instance_exists(_prev) && _prev.trace_group == _a.trace_group && _prev.revealed)
            {
                draw_set_color(_col);
                draw_set_alpha(0.06 + _heat * 0.14);
                draw_line_width(_prev.x, _prev.y, _a.x, _a.y, _k_trace_width_bleed);
                draw_set_alpha(0.25 + _heat * 0.4);
                draw_line_width(_prev.x, _prev.y, _a.x, _a.y, _k_trace_width_glow);
                draw_set_color(merge_color(_col, c_white, 0.5));
                draw_set_alpha(0.6 + _heat * 0.4);
                draw_line_width(_prev.x, _prev.y, _a.x, _a.y, _k_trace_width_core);
            }
        }

        var _k_tick_len = 14;
        var _next = (i + 1 < _nx) ? intro_x_bullets[i + 1] : noone;
        var _is_tip = (!instance_exists(_next) || _next.trace_group != _a.trace_group);
        if (_is_tip)
        {
            var _perp = _a.intro_angle + 90;
            var _tx1 = _a.x + lengthdir_x(_k_tick_len * 0.5, _perp);
            var _ty1 = _a.y + lengthdir_y(_k_tick_len * 0.5, _perp);
            var _tx2 = _a.x - lengthdir_x(_k_tick_len * 0.5, _perp);
            var _ty2 = _a.y - lengthdir_y(_k_tick_len * 0.5, _perp);
            draw_set_alpha(0.6 + _heat * 0.4);
            draw_set_color(_col);
            draw_line_width(_tx1, _ty1, _tx2, _ty2, _k_trace_width_core);
        }
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}