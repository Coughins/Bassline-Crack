function debug_set_open(open)
{
    debug_open = open;

    if (open)
    {
        panel_w = DEBUG_STRIP_W - 40;

        if (!variable_global_exists("debug_resume_panel_x"))
        {
            var w = GAME_WIDTH * global.settings[$"scale"];
            panel_x = w - panel_w - 20;
        }
    }
}

function debug_edit_property_value(index)
{
    var p = filtered_properties[index];
    var target_instance = p.object;
    if (is_real(target_instance) && object_exists(target_instance))
    {
        target_instance = instance_find(target_instance, 0);
    }

    if (!instance_exists(target_instance))
        exit;

    var current_value = variable_instance_get(target_instance, p.variable);
    var input_str = get_string("Set " + p.name + " (" + string(p.min_value) + " to " + string(p.max_value) + ")", string(current_value));

    if (input_str != "")
    {
        var new_value = clamp(real(input_str), p.min_value, p.max_value);
        variable_instance_set(target_instance, p.variable, new_value);
        debug_save_fx_property(p);
    }
}