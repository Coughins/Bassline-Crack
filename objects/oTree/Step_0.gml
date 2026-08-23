event_inherited();

var _length_scale = branch_len / max(1, sprite_get_width(sprite_index));

var _glow_pulse = 0.5 + 0.5 * sin(current_time * 0.004 + glow_pulse_seed);
glow_intensity = 0.28 + _glow_pulse * 0.2;
branch_heat = 0;
branch_current = 0.12 + _glow_pulse * 0.08;
if (state == 1) {
    var _ign01 = clamp(state_timer / grow_duration, 0, 1);
    glow_intensity = lerp(0.6, 1.4, _ign01);
    branch_heat = _ign01;
    branch_current = 0.55 + _ign01 * 0.45;
} else if (state == 2) {
    var _die01 = clamp(state_timer / shrink_duration, 0, 1);
    glow_intensity = lerp(1.2, 0, _die01);
    branch_heat = 1 - _die01;
    branch_current = 0.35 * (1 - _die01);
}
if (instance_exists(oAvoidanceController)) {
    branch_heat = max(branch_heat, oAvoidanceController.tree_burn_heat * 0.75);
    branch_current = max(branch_current, oAvoidanceController.tree_burn_heat * 0.65);
    if (oAvoidanceController.t >= 1875 && oAvoidanceController.t < 2025) {
        var _crown_drive = oAvoidanceController.tree_crown_charge;
        var _feed_bias = branch_is_leaf ? 1.15 : ((branch_child_count >= 2) ? 0.95 : 0.72);
        branch_heat = max(branch_heat, _crown_drive * (0.22 + _feed_bias * 0.2));
        branch_current = max(branch_current, _crown_drive * _feed_bias);
    }
    if (oAvoidanceController.tree_network_flash > 0) {
        branch_network_flash = max(branch_network_flash, oAvoidanceController.tree_network_flash);
    }
    var _organism_tension = oAvoidanceController.tree_organism_tension;
    branch_heat = max(branch_heat, _organism_tension * 0.58);
    branch_current = max(branch_current, _organism_tension * 0.95);
    if (_organism_tension > 0.45) {
        spawn_snap = max(spawn_snap, _organism_tension * 1.8);
    }
}
branch_network_flash = max(0, branch_network_flash - 0.08);
branch_current = max(branch_current, branch_network_flash * 0.9);
scr_add_light(x, y, image_blend, glow_intensity * image_alpha);

if (!spawn_done)
{
    spawn_timer += 1;

    if (spawn_timer >= spawn_delay)
    {
        spawn_progress += 0.16;
    }

    spawn_progress = clamp(spawn_progress, 0, 1);

    var _s = lerp(0, 1.25, spawn_progress);

    if (spawn_progress > 0.8)
    {
        _s = lerp(
            1.15,
            1,
            (spawn_progress - 0.8) / 0.2
        );
    }

    image_xscale = base_scale * _s * _length_scale;
    image_yscale = base_scale * _s * _k_branch_width_ratio;

    image_alpha = spawn_progress;

	if (spawn_progress >= 1 && !spawn_done)
	{
	    spawn_done = true;
	    spawn_snap = 12;
	}
}

if (spawn_snap > 0)
{
    spawn_snap *= 0.85;
    spawn_angle_offset = random_range(-spawn_snap, spawn_snap);
}
else
{
    spawn_angle_offset = 0;
}

image_angle = branch_dir + spawn_angle_offset;


if (ignite_pending)
{
    if (ignite_delay > 0)
    {
        ignite_delay -= 1;
    }
    else
    {
        ignite_pending = false;
        state = 1;
        state_timer = 0;
    }
}

switch (state)
{
    case 1:
    {
        state_timer += 1;
        var _p = clamp(state_timer / grow_duration, 0, 1);
        image_alpha = lerp(0.1, 1, _p);
        var _scale = lerp(1, 1.5, _p) * base_scale;
        image_xscale = _scale * _length_scale;
        image_yscale = _scale * _k_branch_width_ratio;
		image_blend = merge_color(ignite_color_unlit, ignite_color_hot, _p);
		
		if (state_timer == 1) {
	        var _embers_allowed = !instance_exists(oAvoidanceController) || oAvoidanceController.t < 2025;

	        if (_embers_allowed) {
	            var _ember_count = irandom_range(2, 4);
	            for (var e = 0; e < _ember_count; e++) {
	                array_push(global.tree_embers, {
	                    x: x, y: y,
	                    xspeed: random_range(-0.6, 0.6),
	                    yspeed: random_range(-2.2, -1.0),
	                    life: 0,
	                    max_life: irandom_range(30, 50),
	                    color: ignite_color_hot
	                });
	            }

	            var _drip_count = irandom_range(1, 3);
	            for (var d = 0; d < _drip_count; d++) {
	                array_push(global.tree_embers, {
	                    x: x, y: y,
	                    xspeed: random_range(-0.3, 0.3),
	                    yspeed: random_range(1.2, 2.5),
	                    life: 0,
	                    max_life: irandom_range(20, 35),
	                    color: ignite_color_hot
	                });
	            }
	        }

	        var _crack_count = irandom_range(2, 3);
	        for (var cc = 0; cc < _crack_count; cc++) {
	            array_push(crack_points, {ang: random(360), len: random_range(6, 14)});
	        }
	    }
		
        if (state_timer >= grow_duration)
        {
            state = 2;
            state_timer = 0;
        }
        break;
    }
    case 2:
    {
        state_timer += 1;
        var _p2 = clamp(state_timer / shrink_duration, 0, 1);
        var _scale2 = lerp(1.5, 0, _p2) * base_scale;
        image_xscale = _scale2 * _length_scale;
        image_yscale = _scale2 * _k_branch_width_ratio;
        if (state_timer >= shrink_duration)
        {
            instance_destroy();
        }
        break;
    }
}

var _hit_alpha = image_alpha;
if (instance_exists(oAvoidanceController)) {
    var _ctrl = oAvoidanceController;
    if (_ctrl.storm_sphere_visibility > 0.001) {
        var _clear_radius = _ctrl._k_storm_clearing_radius;
        var _dist_to_orb = point_distance(x, y, _ctrl.storm_orb_x, _ctrl.storm_orb_y);
        if (_dist_to_orb < _clear_radius) {
            var _edge_band = 16;
            var _dim_target = _ctrl._k_storm_dim_alpha;
            if (_dist_to_orb > _clear_radius - _edge_band) {
                var _edge_t = (_clear_radius - _dist_to_orb) / _edge_band;
                _dim_target = lerp(1, _ctrl._k_storm_dim_alpha, _edge_t);
            }
            _hit_alpha *= lerp(1, _dim_target, _ctrl.storm_sphere_visibility);
        }
    }
}

hit_active = state != 0 && _hit_alpha > 0.25 && abs(image_xscale) > 0.1 && abs(image_yscale) > 0.1;
