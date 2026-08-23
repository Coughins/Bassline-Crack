function sprite_origin_to_right(spr_ind) {
	return sprite_get_bbox_left(spr_ind) - sprite_get_xoffset(spr_ind)
}

function sprite_origin_to_left(spr_ind) {
	return sprite_get_bbox_left(spr_ind) - sprite_get_xoffset(spr_ind)
}

function sprite_origin_to_top(spr_ind) {
	return sprite_get_bbox_top(spr_ind) - sprite_get_yoffset(spr_ind)
}

function sprite_origin_to_bottom(spr_ind) {
	return sprite_get_bbox_bottom(spr_ind) - sprite_get_yoffset(spr_ind)
}

function instance_struct(_id) {
	var
	_names = variable_instance_get_names(_id),
	_struct = {}

	for (var i = variable_instance_names_count(_id) - 1; i >= 0; i--)
		_struct[$_names[i]] = deep_copy(variable_instance_get(_id, _names[i]))

	return _struct
}

function deep_copy(ref) {
    var ref_new;

    if (is_array(ref)) {
        ref_new = array_create(array_length(ref));

        var length = array_length(ref_new);

        for (var i = 0; i < length; i++) {
            ref_new[i] = deep_copy(ref[i]);
        }

        return ref_new;
    }
    else if (is_struct(ref)) {
        var base = instanceof(ref);

        switch (base) {
            case "struct":
            case "weakref":
                ref_new = {};
                break;

            default:
                var constr = method(undefined, asset_get_index(base));
                ref_new = new constr();
        }

        var names = variable_struct_get_names(ref);
        var length = variable_struct_names_count(ref);

        for (var i = 0; i < length; i++) {
            var name = names[i];

            variable_struct_set(ref_new, name, deep_copy(variable_struct_get(ref, name)));
        }

        return ref_new;
    } else {
        return ref;
    }
}

function instance_get_center(_id) {
	return new vec2(
		_id.bbox_left + (_id.bbox_right - _id.bbox_left) / 2,
		_id.bbox_top + (_id.bbox_bottom - _id.bbox_top) / 2)
}

function f2sec(f) {
	return f / global.settings[$"framerate"]
}

function sec2f(sec) {
	return sec * global.settings[$"framerate"]
}

function fps_adjust(val) {
	return val * global.fps_adjust
}

function fps_inv_adjust(val) {
	return val / global.fps_adjust
}

function fps_adjust_2(val) {
	return val * global.fps_adjust_squared
}

function fps_inv_adjust_2(val) {
	return val / global.fps_adjust_squared
}

function camera_get_view(camera) {
	return [
		camera_get_view_x(camera),
		camera_get_view_y(camera),
		camera_get_view_width(camera),
		camera_get_view_height(camera)]
}

function block_create(xx, yy, w, h) {
	var b = instance_create_layer(xx, yy, layer, oBlock)
	instance_set_width(b, w)
	instance_set_height(b, h)
	return b
}

function move_contact_object(normal, distance, object) {
	var step = min(distance, 1)
	while (!place_meeting(x + normal.x * step, y + normal.y * step, object) && distance > 0)
	{
		distance -= step
		x += normal.x * step
		y += normal.y * step
		step = min(distance, 1)
	}
	return max(distance, 0)
}

function wrap(val, mn, mx) {
	if (val mod 1 == 0)
	{
	    while (val > mx || val < mn)
	    {
	        if (val > mx)
	            val += mn - mx - 1
	        else if (val < mn)
	            val += mx - mn + 1
	    }
	    return(val)
	}
	else
	{
	    var vOld = val + 1
	    while (val != vOld)
	    {
	        vOld = val
	        if (val < mn)
	            val = mx - (mn - val)
	        else if (val > mx)
	            val = mn + (val - mx)
	    }
	    return(val)
	}
}

function map(val, src_min, src_max, dest_min, dest_max) {
	return (val - src_min) / (src_max - src_min) * (dest_max - dest_min) + dest_min
}

function lerp_towards_point(xgoal, ygoal, spd) {
	x = lerp(x, xgoal, spd)
	y = lerp(y, ygoal, spd)
}

function approach(val, goal, amount) {
	if (val < goal)
		return min(val + amount, goal)
	else if (val > goal)
		return max(val - amount, goal)
	else
		return val
}

function snap(val, grid) {
	return floor(val / grid) * grid
}

function array_randomize(array) {
	var
	len = array_length(array),
	ind,
	temp

	for (var i = 0; i < len - 1; i++)
	{
		temp = array[@ i]
		ind = i + irandom(len - i - 2) + 1
		array[@ i] = array[@ ind]
		array[@ ind] = temp
	}
}

function array_find_max_string_width(arr) {
	var w = 0
	for (var i = array_length(arr) - 1; i >= 0; i--)
		w = max(w, string_width(arr[@i]))
	return w
}

function instance_set_width(inst, w) {
	inst.image_xscale = w / sprite_get_width(inst.sprite_index)
}

function instance_set_height(inst, h) {
	inst.image_yscale = h / sprite_get_height(inst.sprite_index)
}

function warp() {

	var
	xx = 0,
	yy = 0,
	absolute = argument_count > 6 ? argument[6] : false

	if (absolute)
	{
		xx = argument[2]
		yy = argument[3]
	}
	else
	{
		xx = argument[1].x
		yy = argument[1].y

		if (argument_count > 3)
		{
			xx += argument[2]
			yy += argument[3]
		}
	}

	var destroy = argument_count > 5 ? argument[5] : false
	var keep = argument_count > 4 ? argument[4] : true

	if (destroy)
	{
		instance_destroy(argument[1])
	}
	else if (!keep)
	{
		instance_destroy(argument[1])
		player_spawn(xx, yy)
	}
	else
	{
		argument[1].x = xx
		argument[1].y = yy
	}

	room_goto(argument[0])
}

function gamepad_button_get_any() {
	var length = 16;
	var list = array_create(length)

	list[0] = gp_face1;
	list[1] = gp_face2;
	list[2] = gp_face3;
	list[3] = gp_face4;
	list[4] = gp_padu;
	list[5] = gp_padd;
	list[6] = gp_padl;
	list[7] = gp_padr;
	list[8] = gp_stickr;
	list[9] = gp_stickl;
	list[10] = gp_select;
	list[11] = gp_start;
	list[12] = gp_shoulderr;
	list[13] = gp_shoulderrb;
	list[14] = gp_shoulderl;
	list[15] = gp_shoulderlb;

	for (var i = 0; i < length; i++)
	{
	    if (gamepad_button_check_pressed(global.gamepad_slot, list[i]))
	        return list[i];
	}

	return -1;
}

function array_get_max_string_width(arr) {
	var _maxw = 0, _w
	for (var i = array_length(arr) - 1; i >= 0; i--) {
		_w = string_width(arr[i])
		_maxw = _w > _maxw ? _w : _maxw
	}
	return _maxw
}

function tilemap_get_from_layer(layer_name) {
	return layer_tilemap_get_id(layer_get_id(tilemap_layer_name))
}
