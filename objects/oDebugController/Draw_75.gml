if (!DEBUG)
    exit;

if (!debug_open)
    exit;

var xx = panel_x;
var yy = panel_y;
var ww = panel_w;
var hh = panel_h;

var bg_col = make_color_rgb(8, 12, 22);
var panel_col = make_color_rgb(16, 24, 38);
var border_col = make_color_rgb(76, 94, 128);
var accent_col = make_color_rgb(80, 220, 255);
var accent2_col = make_color_rgb(255, 160, 90);
var muted_col = make_color_rgb(110, 125, 150);
var row_col = make_color_rgb(24, 34, 50);
var row_sel_col = make_color_rgb(38, 54, 80);
var text_col = make_color_rgb(240, 245, 255);
var dim_col = make_color_rgb(160, 175, 200);

var controller = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var current_t = (instance_exists(oAvoidanceController)) ? oAvoidanceController.t : 0;

draw_set_font(fDefault);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_alpha(0.93);
draw_roundrect_colour(xx, yy, xx + ww, yy + hh, panel_col, panel_col, false);
draw_set_alpha(0.9);
draw_roundrect_colour(xx + 2, yy + 2, xx + ww - 2, yy + hh - 2, border_col, border_col, true);
draw_set_alpha(1);

draw_set_alpha(0.95);
draw_rectangle_colour(xx + 2, yy + 2, xx + ww - 2, yy + 44, make_color_rgb(18, 30, 48), make_color_rgb(18, 30, 48), make_color_rgb(18, 30, 48), make_color_rgb(18, 30, 48), false);
draw_set_alpha(1);
draw_set_color(accent_col);
draw_line_width(xx + 10, yy + 44, xx + ww - 10, yy + 44, 2);
draw_set_color(text_col);
draw_text(xx + 12, yy + 10, "DEBUG INSPECTOR");
draw_set_color(dim_col);
draw_text(xx + 12, yy + 24, "right-click reset • dbl-click type");

var tab_y0 = yy + 48;
var tab_y1 = yy + 82;
for (var i = 0; i < array_length(categories); ++i)
{
    var tab_x0 = xx + 12 + i * 92;
    var tab_x1 = tab_x0 + 76;
    var is_selected = (i == selected_category);

    draw_set_alpha(is_selected ? 1 : 0.8);
    draw_roundrect_colour(tab_x0, tab_y0, tab_x1, tab_y1, is_selected ? row_sel_col : row_col, is_selected ? row_sel_col : row_col, false);
    draw_set_alpha(1);
    draw_roundrect_colour(tab_x0, tab_y0, tab_x1, tab_y1, is_selected ? accent_col : border_col, is_selected ? accent_col : border_col, true);

    draw_set_color(is_selected ? text_col : dim_col);
    draw_set_halign(fa_center);
    draw_text((tab_x0 + tab_x1) * 0.5, tab_y0 + 7, categories[i]);
    draw_set_halign(fa_left);
}

var timeline_y = yy + 92;
var timeline_x0 = xx + 12;
var timeline_x1 = xx + ww - 12;
var timeline_w = timeline_x1 - timeline_x0;
var timeline_t = (debug_t_max > debug_t_min) ? (current_t - debug_t_min) / (debug_t_max - debug_t_min) : 0;
timeline_t = clamp(timeline_t, 0, 1);

draw_set_alpha(0.8);
draw_roundrect_colour(timeline_x0, timeline_y, timeline_x1, timeline_y + 16, make_color_rgb(22, 32, 46), make_color_rgb(22, 32, 46), false);
draw_set_alpha(1);
draw_set_color(accent_col);
draw_rectangle_colour(timeline_x0, timeline_y, timeline_x0 + timeline_w * timeline_t, timeline_y + 16, accent_col, accent_col, accent_col, accent_col, false);
draw_set_color(text_col);
draw_circle_colour(timeline_x0 + timeline_w * timeline_t, timeline_y + 8, 6, accent2_col, accent2_col, false);

var resume_t_percent = (debug_t_max > debug_t_min) ? clamp((debug_last_t - debug_t_min) / (debug_t_max - debug_t_min), 0, 1) : 0;
draw_set_color(muted_col);
draw_line_width(timeline_x0 + timeline_w * resume_t_percent, timeline_y - 4, timeline_x0 + timeline_w * resume_t_percent, timeline_y + 20, 2);

draw_set_color(dim_col);
draw_text(timeline_x0, timeline_y + 22, "T: " + string(current_t) + "   Resume: " + string(debug_last_t));

var is_attacks_tab = (selected_category == 0);

if (is_attacks_tab)
{
    var _atk_body_y = yy + 132;
    var _atk_cols = 2;
    var _atk_btn_w = floor((ww - 36) / _atk_cols);
    var _atk_btn_h = 26;
    var _atk_gap = 4;
    var _atk_footer_y = yy + hh - 34;
    var _atk_visible = floor((_atk_footer_y - _atk_body_y) / (_atk_btn_h + _atk_gap)) * _atk_cols;
    var _atk_count = array_length(attack_markers);
    var _atk_visible_count = max(min(_atk_count - attack_scroll, _atk_visible), 0);

    if (_atk_count > _atk_visible)
    {
        draw_set_color(muted_col);
        draw_set_halign(fa_right);
        draw_text(xx + ww - 16, _atk_body_y - 14, string(attack_scroll + 1) + "-" + string(attack_scroll + _atk_visible_count) + " / " + string(_atk_count));
        draw_set_halign(fa_left);
    }

    for (var _ai = attack_scroll; _ai < min(_atk_count, attack_scroll + _atk_visible); ++_ai)
    {
        var _vi = _ai - attack_scroll;
        var _col = _vi mod _atk_cols;
        var _row = floor(_vi / _atk_cols);
        var _bx = xx + 12 + _col * (_atk_btn_w + _atk_gap);
        var _by = _atk_body_y + _row * (_atk_btn_h + _atk_gap);

        var _m = attack_markers[_ai];

        draw_set_alpha(0.95);
        draw_roundrect_colour(_bx, _by, _bx + _atk_btn_w, _by + _atk_btn_h, row_col, row_col, false);
        draw_set_alpha(0.9);
        draw_roundrect_colour(_bx, _by, _bx + _atk_btn_w, _by + _atk_btn_h, _m.color, _m.color, true);
        draw_set_alpha(1);

        draw_set_color(text_col);
        draw_set_halign(fa_left);
        draw_text(_bx + 6, _by + 2, _m.name);

        draw_set_halign(fa_right);
        draw_set_color(dim_col);
        draw_text(_bx + _atk_btn_w - 6, _by + 2, "T:" + string(_m.t));
        draw_set_halign(fa_left);
    }

    if (_atk_count == 0)
    {
        draw_set_color(dim_col);
        draw_text(xx + 16, _atk_body_y + 8, "No attack markers defined.");
    }

    draw_set_color(dim_col);
    draw_text(xx + 16, _atk_footer_y + 2, "Tip: click an attack to jump to its timestamp.");
}
else
{
    var body_y = yy + 132;
    var row_h = 30;
    var label_x = xx + 16;
    var slider_x0 = xx + 170;
    var slider_x1 = xx + ww - 80;
    var value_x = xx + ww - 70;
    var count = array_length(filtered_properties);

    var max_visible_rows = max(1, floor((yy + hh - 34 - body_y) / row_h));
    var visible_count = max(min(count - scroll_offset, max_visible_rows), 0);

    if (count > max_visible_rows)
    {
        draw_set_color(muted_col);
        draw_set_halign(fa_right);
        draw_text(xx + ww - 16, body_y - 14, string(scroll_offset + 1) + "-" + string(scroll_offset + visible_count) + " / " + string(count));
        draw_set_halign(fa_left);
    }

    var active_col = make_color_rgb(120, 255, 130);
    var custom_col = accent2_col;

    for (var vi = 0; vi < visible_count; ++vi)
    {
        var i = vi + scroll_offset;
        var p = filtered_properties[i];
        var row_y = body_y + vi * row_h;
        var is_selected = (i == selected_property);

        if (variable_struct_exists(p, "is_header"))
        {
            var is_header_active = (fx_get_current_attack_key() == p.atk_key);

            var hdr_fill_col = is_selected ? row_sel_col : row_col;
            var hdr_border_col = is_header_active ? active_col : p.color;

            draw_set_alpha(0.95);
            draw_roundrect_colour(xx + 8, row_y, xx + ww - 8, row_y + row_h - 4, hdr_fill_col, hdr_fill_col, false);
            draw_set_alpha(1);
            draw_roundrect_colour(xx + 8, row_y, xx + ww - 8, row_y + row_h - 4, hdr_border_col, hdr_border_col, true);

            draw_set_alpha(0.85);
            draw_roundrect_colour(xx + 12, row_y + 5, xx + 20, row_y + row_h - 9, p.color, p.color, false);
            draw_set_alpha(1);

            draw_set_color(is_header_active ? active_col : text_col);
            draw_text(xx + 28, row_y + 7, (p.expanded ? "[-] " : "[+] ") + p.name);

            draw_set_color(muted_col);
            draw_set_halign(fa_right);
            var hdr_tag = "T:" + string(p.t) + "  (" + string(p.child_count) + ")";
            if (p.has_custom)
            {
                draw_set_color(custom_col);
                hdr_tag = "* " + hdr_tag;
            }
            draw_text(xx + ww - 16, row_y + 7, hdr_tag);
            draw_set_halign(fa_left);

            continue;
        }

        var is_dragging_this = (property_dragging && i == property_drag_index);
        var is_active = variable_struct_exists(p, "atk_key") && fx_is_row_active(p.atk_key, p.effect_key);

        var row_fill_col = (is_selected || is_dragging_this) ? row_sel_col : row_col;
        if (is_active && !is_selected && !is_dragging_this)
        {
            row_fill_col = merge_color(row_col, active_col, 0.2);
        }
        var row_border_col = is_dragging_this ? accent2_col : (is_selected ? accent_col : border_col);
        if (is_active)
        {
            row_border_col = active_col;
        }

        draw_set_alpha(0.95);
        draw_roundrect_colour(xx + 8, row_y, xx + ww - 8, row_y + row_h - 4, row_fill_col, row_fill_col, false);
        draw_set_alpha(0.9);
        draw_roundrect_colour(xx + 8, row_y, xx + ww - 8, row_y + row_h - 4, row_border_col, row_border_col, true);
        draw_set_alpha(1);

        var target_instance = p.object;
        if (is_real(target_instance) && object_exists(target_instance))
        {
            target_instance = instance_find(target_instance, 0);
        }

        var value = instance_exists(target_instance)
            ? variable_instance_get(target_instance, p.variable)
            : 0;

        var percent = (p.max_value > p.min_value) ? ((value - p.min_value) / (p.max_value - p.min_value)) : 0;
        percent = clamp(percent, 0, 1);

        var is_custom = variable_struct_exists(p, "reset_value") && (abs(value - p.reset_value) > 0.001);

        if (is_active)
        {
            draw_set_color(active_col);
            draw_circle(label_x - 6, row_y + 10, 3, false);
        }
        else if (is_custom)
        {
            draw_set_color(custom_col);
            draw_circle(label_x - 6, row_y + 10, 2.5, false);
        }

        draw_set_color(is_active ? active_col : (is_selected ? text_col : dim_col));
        draw_text(label_x, row_y + 7, p.name);

        draw_set_alpha(0.7);
        draw_roundrect_colour(slider_x0, row_y + 11, slider_x1, row_y + 15, make_color_rgb(28, 40, 60), make_color_rgb(28, 40, 60), false);
        draw_set_alpha(1);
        draw_rectangle_colour(slider_x0, row_y + 11, slider_x0 + (slider_x1 - slider_x0) * percent, row_y + 15, accent_col, accent_col, accent_col, accent_col, false);
        draw_circle_colour(slider_x0 + (slider_x1 - slider_x0) * percent, row_y + 13, 4.5, accent2_col, accent2_col, false);

        draw_set_color(is_custom ? custom_col : (is_selected ? text_col : dim_col));
        draw_text(value_x, row_y + 7, string_format(value, 1, 2) + " (" + string(p.min_value) + "-" + string(p.max_value) + ")");
    }

    if (count == 0)
    {
        draw_set_color(dim_col);
        draw_text(xx + 16, body_y + 8, "No properties in this category yet.");
    }

    draw_set_color(dim_col);
    draw_text(xx + 16, yy + hh - 24, "Drag a slider or scrub timeline with the mouse.");
}
