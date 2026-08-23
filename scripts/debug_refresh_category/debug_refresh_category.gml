function debug_switch_category(_new_index)
{

    if (selected_category >= 0 && selected_category < array_length(scroll_offset_by_category))
    {
        scroll_offset_by_category[selected_category] = scroll_offset;
    }

    selected_category = _new_index;
    debug_refresh_category();
}

function debug_build_fx_rows()
{
    var _rows = [];

    for (var i = 0; i < array_length(attack_markers); ++i)
    {
        var _atk = attack_markers[i];
        var _is_expanded = variable_struct_exists(fx_expanded, _atk.key) && fx_expanded[$ _atk.key];

        var _children = [];
        var _has_custom = false;

        for (var j = 0; j < array_length(properties); ++j)
        {
            var _p = properties[j];
            if (_p.category != "FX" || !variable_struct_exists(_p, "atk_key") || _p.atk_key != _atk.key)
                continue;

            array_push(_children, _p);

            if (instance_exists(_p.object) && abs(variable_instance_get(_p.object, _p.variable) - _p.reset_value) > 0.001)
            {
                _has_custom = true;
            }
        }

        array_push(_rows, {
            is_header:true,
            atk_key:_atk.key,
            name:_atk.name,
            color:_atk.color,
            t:_atk.t,
            expanded:_is_expanded,
            child_count:array_length(_children),
            has_custom:_has_custom
        });

        if (_is_expanded)
        {
            for (var k = 0; k < array_length(_children); ++k)
            {
                array_push(_rows, _children[k]);
            }
        }
    }

    return _rows;
}

function debug_toggle_fx_group(_atk_key)
{
    var _cur = variable_struct_exists(fx_expanded, _atk_key) && fx_expanded[$ _atk_key];
    fx_expanded[$ _atk_key] = !_cur;
    debug_refresh_category();
}

function debug_refresh_category()
{
    filtered_properties = [];

    var cat = categories[selected_category];

    if (cat == "FX")
    {
        filtered_properties = debug_build_fx_rows();
    }
    else
    {
        for (var i = 0; i < array_length(properties); ++i)
        {
            if (properties[i].category == cat)
            {
                array_push(
                    filtered_properties,
                    properties[i]
                );
            }
        }
    }

    if (array_length(filtered_properties) > 0)
    {
        selected_property = clamp(
            selected_property,
            0,
            array_length(filtered_properties) - 1
        );
    }
    else
    {
        selected_property = -1;
    }

    if (selected_category >= 0 && selected_category < array_length(scroll_offset_by_category))
    {
        scroll_offset = scroll_offset_by_category[selected_category];
    }
}
