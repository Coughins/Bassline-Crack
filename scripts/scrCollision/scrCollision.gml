///@func block_align(step, dist, [max_check])
///@arg {vec2} step - movement per check
///@arg {real} [max_check] - maximum loops
function block_align() {
    var _step = argument[0]
    var _count = argument_count == 2 ? argument[1] : 16
    while !place_meeting(x + _step.x, y + _step.y, oBlock) && _count-- {
        x += _step.x
        y += _step.y
    }
}

///@func block_protrude(step, dist, [max_check])
///@arg {vec2} step - movement per check
///@arg {real} [max_check] - maximum loops
function block_protrude() {
    var _step = argument[0]
    var _count = argument_count == 2 ? argument[1] : 16
    while place_meeting(x, y, oBlock) && _count-- {
        x += _step.x
        y += _step.y
    }
}

function killer_can_hit_player(_killer) {
    if (!instance_exists(_killer)) return false;

    if (variable_instance_exists(_killer, "already_hit_player") && _killer.already_hit_player) {
        return false;
    }

    if (variable_instance_exists(_killer, "hit_active") && !_killer.hit_active) {
        return false;
    }

    if (variable_instance_exists(_killer, "collidable") && !_killer.collidable) {
        return false;
    }

    if (!_killer.visible) return false;

    var _alpha_min = variable_instance_exists(_killer, "hit_alpha_min") ? _killer.hit_alpha_min : 0.05;
    if (_killer.image_alpha <= _alpha_min) return false;

    var _scale_min = variable_instance_exists(_killer, "hit_scale_min") ? _killer.hit_scale_min : 0.05;
    if (abs(_killer.image_xscale) <= _scale_min || abs(_killer.image_yscale) <= _scale_min) {
        return false;
    }

    return true;
}

function player_meeting_killer() {
    if (scr_honeycomb_player_meeting(x, y)) return true;

    var _killers = ds_list_create();
    var _count = instance_place_list(x, y, oKiller, _killers, false);
    var _hit = false;

    for (var i = 0; i < _count; i++) {
        var _k = _killers[| i];
        if (killer_can_hit_player(_k)) {
            _k.already_hit_player = true;
            _hit = true;
            break;
        }
    }

    ds_list_destroy(_killers);
    return _hit;
}

///@func player_register_hazard_hit()
function player_register_hazard_hit() {
    if (!instance_exists(oPlayer)) return false;
    if (oPlayer.dead) return false;
    if (oPlayer.invincible_timer > 0) return false;

    sfx_play_sound(oPlayer.death_sound);

    var _hitcount_active =
        global.hitcount_mode &&
        (!variable_global_exists("avoidance_practice_active") ||
         !global.avoidance_practice_active);

    if (!_hitcount_active) {
        player_kill(oPlayer);
        return true;
    }

    oPlayer.invincible_timer = room_speed;
    if (instance_exists(oAvoidanceController)) oAvoidanceController.hit_count++;
    return true;
}

function player_meeting_line_width(_x1, _y1, _x2, _y2, _radius) {
    if (!instance_exists(oPlayer)) return false;
    if (collision_line(_x1, _y1, _x2, _y2, oPlayer, false, true) != noone) return true;

    var _dist = point_distance(_x1, _y1, _x2, _y2);
    var _step = max(1, _radius);
    var _steps = max(1, ceil(_dist / _step));

    for (var i = 0; i <= _steps; i++) {
        var _u = i / _steps;
        var _sx = lerp(_x1, _x2, _u);
        var _sy = lerp(_y1, _y2, _u);
        if (collision_circle(_sx, _sy, _radius, oPlayer, false, true) != noone) {
            return true;
        }
    }

    return false;
}
