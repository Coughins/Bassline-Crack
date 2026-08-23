event_inherited();

if (is_rotating) {
    image_angle += rotate_speed;
}

if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}
array_push(trail_positions, x);
if (array_length(trail_positions) > 6) array_delete(trail_positions, 0, 1);

var len = 1300
var width = 20;
var half_len = len * 0.5;
var hit_angle = image_angle - 90;

var check_kunai = (image_alpha >= 1);

var orb_width = 20;
var kunai_width = 100;

for (var i = -orb_width * 0.5; i <= orb_width * 0.5; i += 4) {
    var ox = lengthdir_x(i, hit_angle + 90);
    var oy = lengthdir_y(i, hit_angle + 90);
    var sx = x + ox - lengthdir_x(half_len, hit_angle);
    var sy = y + oy - lengthdir_y(half_len, hit_angle);
    var ex = x + ox + lengthdir_x(half_len, hit_angle);
    var ey = y + oy + lengthdir_y(half_len, hit_angle);
    var list = ds_list_create();
    collision_line_list(sx, sy, ex, ey, oLaserOrb_Pop, false, true, list, false);
    for (var j = 0; j < ds_list_size(list); ++j) {
        with (list[| j]) {
            if (!is_popped && laser_pop_enabled) scr_pop_laser_orb(id);
        }
    }
    ds_list_destroy(list);
}

for (var i = -orb_width * 0.5; i <= orb_width * 0.5; i += 4) {
    var ox = lengthdir_x(i, hit_angle + 90);
    var oy = lengthdir_y(i, hit_angle + 90);
    var sx = x + ox - lengthdir_x(half_len, hit_angle);
    var sy = y + oy - lengthdir_y(half_len, hit_angle);
    var ex = x + ox + lengthdir_x(half_len, hit_angle);
    var ey = y + oy + lengthdir_y(half_len, hit_angle);
    var list = ds_list_create();
    collision_line_list(sx, sy, ex, ey, oRedOrb, false, true, list, false);
    for (var j = 0; j < ds_list_size(list); ++j) {
        with (list[| j]) orb_hit = true;
    }
    ds_list_destroy(list);
}

for (var i = -orb_width * 0.5; i <= orb_width * 0.5; i += 4) {
     var ox = lengthdir_x(i, hit_angle + 90);
    var oy = lengthdir_y(i, hit_angle + 90);
    var sx = x + ox - lengthdir_x(half_len, hit_angle);
    var sy = y + oy - lengthdir_y(half_len, hit_angle);
    var ex = x + ox + lengthdir_x(half_len, hit_angle);
    var ey = y + oy + lengthdir_y(half_len, hit_angle);

    var list = ds_list_create();
    collision_line_list(sx, sy, ex, ey, oRedLightningOrb, false, true, list, false);

    for (var j = 0; j < ds_list_size(list); ++j) {
        with (list[| j]) orb_hit = true;
    }

    ds_list_destroy(list);
}

if (check_kunai) {
    for (var i = -kunai_width * 0.5; i <= kunai_width * 0.5; i += 4) {
       var ox = lengthdir_x(i, hit_angle + 90);
	    var oy = lengthdir_y(i, hit_angle + 90);
	    var sx = x + ox - lengthdir_x(half_len, hit_angle);
	    var sy = y + oy - lengthdir_y(half_len, hit_angle);
	    var ex = x + ox + lengthdir_x(half_len, hit_angle);
	    var ey = y + oy + lengthdir_y(half_len, hit_angle);
        var list = ds_list_create();
        collision_line_list(sx, sy, ex, ey, oRedKunai, false, true, list, false);

        for (var j = 0; j < ds_list_size(list); ++j) {
            with (list[| j]) orb_hit = true;
        }

        ds_list_destroy(list);
    }
}

for (var i = -orb_width * 0.5; i <= orb_width * 0.5; i += 4) {
    var ox = lengthdir_x(i, hit_angle + 90);
    var oy = lengthdir_y(i, hit_angle + 90);
    var sx = x + ox - lengthdir_x(half_len, hit_angle);
    var sy = y + oy - lengthdir_y(half_len, hit_angle);
    var ex = x + ox + lengthdir_x(half_len, hit_angle);
    var ey = y + oy + lengthdir_y(half_len, hit_angle);
    var list = ds_list_create();
    collision_line_list(sx, sy, ex, ey, oRedGravityOrb, false, true, list, false);
    for (var j = 0; j < ds_list_size(list); ++j) {
        with (list[| j]) {
            if (!gravity_activated) {
		    gravity_activated = true;
		    gravity_direction = other.gravity_dir_to_apply;
		    gravity = 0.4;
		    scr_impact_pulse(0.1, 1.0, 0.15);
			}
        }
    }
    ds_list_destroy(list);
}


if explode == 1 {
	image_xscale = 6
	image_alpha = 1
	explode = 0
	get_smaller = 1
}
if get_smaller == 1 {
	image_xscale -= 0.6
	if image_xscale <= 0 {
		instance_destroy()
	}
}
