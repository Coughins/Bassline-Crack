if (!DEBUG)
    exit;

panel_h = clamp(display_get_gui_height() - panel_y - 20, 300, 2000);

if (keyboard_check(vk_control))
{
    if (keyboard_check_pressed(vk_right))
    {
        var _next_category = selected_category + 1;
        if (_next_category >= array_length(categories))
            _next_category = 0;
        debug_switch_category(_next_category);
    }

    if (keyboard_check_pressed(vk_left))
    {
        var _prev_category = selected_category - 1;
        if (_prev_category < 0)
            _prev_category = array_length(categories) - 1;
        debug_switch_category(_prev_category);
    }
}

if (keyboard_check_pressed(vk_f1))
{
    debug_set_open(!debug_open);
}

if (keyboard_check_pressed(ord("R")))
{
    if (selected_category >= 0 && selected_category < array_length(scroll_offset_by_category))
    {
        scroll_offset_by_category[selected_category] = scroll_offset;
    }

    global.debug_resume_t = debug_last_t;
    global.debug_resume_open = debug_open;
    global.debug_resume_panel_x = panel_x;
    global.debug_resume_panel_y = panel_y;
    global.debug_resume_category = selected_category;
    global.debug_resume_scroll_by_category = scroll_offset_by_category;
    global.debug_resume_attack_scroll = attack_scroll;
    global.debug_resume_selected_property = selected_property;
    global.debug_resume_fx_expanded = fx_expanded;
    room_restart();
}

if (!debug_open)
    exit;

var count = array_length(filtered_properties);

var kb_nav_moved = false;

if (keyboard_check_pressed(vk_down) && count > 0)
{
    selected_property++;
    kb_nav_moved = true;
}
if (keyboard_check_pressed(vk_up) && count > 0)
{
    selected_property--;
    kb_nav_moved = true;
}

if (count > 0)
{
    selected_property = clamp(selected_property, 0, count - 1);
}
else
{
    selected_property = -1;
}

if (!keyboard_check(vk_control) && count > 0 && selected_property >= 0
    && !variable_struct_exists(filtered_properties[selected_property], "is_header"))
{
    var _nudge = 0;
    if (keyboard_check_pressed(vk_right)) _nudge = 0.01;
    if (keyboard_check_pressed(vk_left)) _nudge = -0.01;

    if (_nudge != 0)
    {
        var _nudge_p = filtered_properties[selected_property];
        var _nudge_target = _nudge_p.object;
        if (is_real(_nudge_target) && object_exists(_nudge_target))
        {
            _nudge_target = instance_find(_nudge_target, 0);
        }

        if (instance_exists(_nudge_target))
        {
            var _nudge_value = clamp(
                variable_instance_get(_nudge_target, _nudge_p.variable) + _nudge,
                _nudge_p.min_value,
                _nudge_p.max_value
            );
            variable_instance_set(_nudge_target, _nudge_p.variable, _nudge_value);
            debug_save_fx_property(_nudge_p);
        }
    }
}

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var header_h = 44;
var body_y = panel_y + 132;
var row_h = 30;

var max_visible_rows = max(1, floor((panel_y + panel_h - 34 - body_y) / row_h));

if (count > max_visible_rows)
{
    scroll_offset = clamp(scroll_offset, 0, count - max_visible_rows);
}
else
{
    scroll_offset = 0;
}

if (kb_nav_moved && selected_property >= 0)
{
    if (selected_property < scroll_offset)
        scroll_offset = selected_property;
    if (selected_property >= scroll_offset + max_visible_rows)
        scroll_offset = selected_property - max_visible_rows + 1;
}

var body_bottom = body_y + max_visible_rows * row_h;

if (point_in_rectangle(mx, my, panel_x + 12, body_y, panel_x + panel_w - 12, body_bottom))
{
    if (mouse_wheel_up() && count > 0)
    {
        scroll_offset = clamp(scroll_offset - 1, 0, max(0, count - max_visible_rows));
    }
    if (mouse_wheel_down() && count > 0)
    {
        scroll_offset = clamp(scroll_offset + 1, 0, max(0, count - max_visible_rows));
    }
}

if (selected_category == 0)
{
    var _atk_body_y = panel_y + 132;
    var _atk_footer_y = panel_y + panel_h - 34;
    if (point_in_rectangle(mx, my, panel_x + 12, _atk_body_y, panel_x + panel_w - 12, _atk_footer_y))
    {
        var _atk_cols = 2;
        var _atk_btn_h = 26;
        var _atk_gap = 4;
        var _atk_visible = floor((_atk_footer_y - _atk_body_y) / (_atk_btn_h + _atk_gap)) * _atk_cols;
        var _atk_max = max(0, array_length(attack_markers) - _atk_visible);
        if (mouse_wheel_up() && _atk_max > 0)
            attack_scroll = clamp(attack_scroll - 1, 0, _atk_max);
        if (mouse_wheel_down() && _atk_max > 0)
            attack_scroll = clamp(attack_scroll + 1, 0, _atk_max);
    }
}

if (mouse_check_button_pressed(mb_left))
{
    if (point_in_rectangle(mx, my, panel_x, panel_y, panel_x + panel_w, panel_y + header_h))
    {
        panel_dragging = true;
        panel_drag_offset_x = mx - panel_x;
        panel_drag_offset_y = my - panel_y;
		
    }
    else
    {
        var tab_row_y0 = panel_y + 48;
        var tab_row_y1 = panel_y + 78;
        if (point_in_rectangle(mx, my, panel_x + 12, tab_row_y0, panel_x + panel_w - 12, tab_row_y1))
        {
            for (var i = 0; i < array_length(categories); ++i)
            {
                var tab_x0 = panel_x + 12 + i * 92;
                var tab_x1 = tab_x0 + 76;
                if (point_in_rectangle(mx, my, tab_x0, tab_row_y0, tab_x1, tab_row_y1))
                {
                    debug_switch_category(i);
                    break;
                }
            }
        }
        else
        {
            var timeline_y0 = panel_y + 84;
            var timeline_y1 = panel_y + 110;
            if (point_in_rectangle(mx, my, panel_x + 12, timeline_y0, panel_x + panel_w - 12, timeline_y1))
            {
                timeline_dragging = true;
            }
            else
            {
                var value_col_x0 = panel_x + panel_w - 80;
                var value_col_x1 = panel_x + panel_w - 8;

                for (var i = scroll_offset; i < min(count, scroll_offset + max_visible_rows); ++i)
                {
                    var row_y0 = body_y + (i - scroll_offset) * row_h;
                    var row_y1 = row_y0 + row_h;
                    if (point_in_rectangle(mx, my, panel_x + 12, row_y0, panel_x + panel_w - 12, row_y1))
                    {
                        selected_property = i;

                        if (variable_struct_exists(filtered_properties[i], "is_header"))
                        {
                            debug_toggle_fx_group(filtered_properties[i].atk_key);
                        }
                        else if (point_in_rectangle(mx, my, value_col_x0, row_y0, value_col_x1, row_y1))
                        {
                            var _now = current_time;
                            if (i == last_value_click_index && (_now - last_value_click_time) < 350)
                            {
                                debug_edit_property_value(i);
                                last_value_click_index = -1;
                                last_value_click_time = -1000;
                            }
                            else
                            {
                                last_value_click_index = i;
                                last_value_click_time = _now;
                            }
                        }
                        else
                        {
                            property_dragging = true;
                            property_drag_index = i;
                        }
                        break;
                    }
                }
            }
        }
    }
}

if (mouse_check_button_pressed(mb_left) && selected_category == 0)
{
    var _atk_body_y = panel_y + 132;
    var _atk_cols = 2;
    var _atk_btn_w = floor((panel_w - 36) / _atk_cols);
    var _atk_btn_h = 26;
    var _atk_gap = 4;
    var _atk_footer_y = panel_y + panel_h - 34;
    var _atk_visible = floor((_atk_footer_y - _atk_body_y) / (_atk_btn_h + _atk_gap)) * _atk_cols;

    for (var i = attack_scroll; i < min(array_length(attack_markers), attack_scroll + _atk_visible); ++i)
    {
        var _vi = i - attack_scroll;
        var _col = _vi mod _atk_cols;
        var _row = floor(_vi / _atk_cols);
        var _bx = panel_x + 12 + _col * (_atk_btn_w + _atk_gap);
        var _by = _atk_body_y + _row * (_atk_btn_h + _atk_gap);

        if (point_in_rectangle(mx, my, _bx, _by, _bx + _atk_btn_w, _by + _atk_btn_h))
        {
            var _t = attack_markers[i].t;
            debug_last_t = _t;
            if (instance_exists(oAvoidanceController))
            {
                with (oAvoidanceController) set_t(_t);
            }

            fx_expanded = {};
            fx_expanded[$ attack_markers[i].key] = true;

            var _fx_cat_index = -1;
            for (var _c = 0; _c < array_length(categories); ++_c)
            {
                if (categories[_c] == "FX") { _fx_cat_index = _c; break; }
            }

            if (_fx_cat_index >= 0 && _fx_cat_index < array_length(scroll_offset_by_category))
            {
                var _fx_rows = debug_build_fx_rows();
                var _header_row_index = 0;
                for (var _r = 0; _r < array_length(_fx_rows); ++_r)
                {
                    if (variable_struct_exists(_fx_rows[_r], "is_header") && _fx_rows[_r].atk_key == attack_markers[i].key)
                    {
                        _header_row_index = _r;
                        break;
                    }
                }
                scroll_offset_by_category[_fx_cat_index] = _header_row_index;
            }
            break;
        }
    }
}

if (mouse_check_button_released(mb_left))
{
    if (property_dragging && property_drag_index >= 0 && property_drag_index < array_length(filtered_properties))
    {
        debug_save_fx_property(filtered_properties[property_drag_index]);
    }
    panel_dragging = false;
    property_dragging = false;
    property_drag_index = -1;
    timeline_dragging = false;
}

if (selected_category == 0 && instance_exists(oAvoidanceController))
{
    var _atk_cols = 2;
    var _atk_btn_w = floor((panel_w - 36) / _atk_cols);
    var _atk_btn_h = 26;
    var _atk_gap = 4;
    var _atk_footer_y = panel_y + panel_h - 34;
    var _atk_visible = floor((_atk_footer_y - (panel_y + 132)) / (_atk_btn_h + _atk_gap));

    if (keyboard_check_pressed(ord("1"))) { attack_scroll = 0; }
    else if (keyboard_check_pressed(ord("2"))) { attack_scroll = _atk_cols; }
    else if (keyboard_check_pressed(ord("3"))) { attack_scroll = _atk_cols * 2; }
    else if (keyboard_check_pressed(ord("4"))) { attack_scroll = _atk_cols * 3; }
    else if (keyboard_check_pressed(ord("5"))) { attack_scroll = _atk_cols * 4; }
    else if (keyboard_check_pressed(ord("6"))) { attack_scroll = _atk_cols * 5; }
    else if (keyboard_check_pressed(ord("7"))) { attack_scroll = _atk_cols * 6; }
    else if (keyboard_check_pressed(ord("8"))) { attack_scroll = _atk_cols * 7; }
    else if (keyboard_check_pressed(ord("9"))) { attack_scroll = _atk_cols * 8; }
}

if (mouse_check_button_released(mb_left))
{
    panel_dragging = false;
    property_dragging = false;
    property_drag_index = -1;
    timeline_dragging = false;
}

if (panel_dragging)
{
	panel_x = clamp(mx - panel_drag_offset_x, 8, display_get_gui_width() - panel_w - 8);
	panel_y = clamp(my - panel_drag_offset_y, 8, display_get_gui_height() - panel_h - 8);
}

if (property_dragging && count > 0 && property_drag_index >= 0 && property_drag_index < count)
{
    var drag_p = filtered_properties[property_drag_index];
	var slider_x0 = panel_x + 170;
	var slider_x1 = panel_x + panel_w - 80;
    var percent = clamp((mx - slider_x0) / max(1, slider_x1 - slider_x0), 0, 1);
    var value = lerp(drag_p.min_value, drag_p.max_value, percent);

    var target_instance = drag_p.object;
    if (is_real(target_instance) && object_exists(target_instance))
    {
        target_instance = instance_find(target_instance, 0);
    }

    if (instance_exists(target_instance))
    {
        variable_instance_set(target_instance, drag_p.variable, value);
    }
}

if (timeline_dragging)
{
    var timeline_x0 = panel_x + 18;
    var timeline_x1 = panel_x + panel_w - 18;
    var percent = clamp((mx - timeline_x0) / max(1, timeline_x1 - timeline_x0), 0, 1);
    var target_t = round(lerp(debug_t_min, debug_t_max, percent));

    if (instance_exists(oAvoidanceController))
    {
        debug_last_t = target_t;
        with (oAvoidanceController)
        {
            set_t(target_t);
        }
    }
}

if (mouse_check_button_pressed(mb_right) && count > 0 && selected_property >= 0
    && !variable_struct_exists(filtered_properties[selected_property], "is_header"))
{
    var reset_p = filtered_properties[selected_property];
    var reset_target = reset_p.object;
    if (is_real(reset_target) && object_exists(reset_target))
    {
        reset_target = instance_find(reset_target, 0);
    }

    if (instance_exists(reset_target))
    {
        variable_instance_set(reset_target, reset_p.variable, reset_p.reset_value);
        debug_save_fx_property(reset_p);
    }
}
