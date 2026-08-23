event_inherited();
if (!hide_visual) scr_register_glow_point(x, y);
if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}

if (stretch_enabled)
{
    stretch = lerp(stretch, 1 + point_distance(prev_x, prev_y, x, y) * 0.055, 0.3);
}
prev_x = x;
prev_y = y;
birth_heat = max(0, birth_heat - 0.055);

if (expand_curve_rate != 0)
{
    direction += expand_curve_rate;
}

if (pop_scale != pop_target)
{
    pop_scale = lerp(pop_scale, pop_target, pop_speed);
    if (pop_overshoot && abs(pop_scale - pop_target) < 0.05)
    {
        pop_scale = pop_target - 0.1;
        pop_target = 1;
        pop_overshoot = false;
    }
    image_xscale = pop_scale * base_size;
    image_yscale = pop_scale * base_size;
}

if (pop_flash > 0)
{
    pop_flash -= 0.06;
    if (pop_flash < 0) pop_flash = 0;
}

if (is_corner)
{
    var _k_trail_interval     = 1;
    var _k_trail_start_scale  = 0.25;
    var _k_trail_end_scale    = 1.0;
    var _k_trail_lifespan     = 20;
    var _k_trail_shrink_speed = 0.05;

    trail_timer++;
    if (trail_timer >= _k_trail_interval)
    {
        trail_timer = 0;

		var _k_trail_travel_range = 200;
		var _dist_traveled = point_distance(spawn_x, spawn_y, x, y);
		var _progress = clamp(_dist_traveled / _k_trail_travel_range, 0, 1);
        var _trail_scale_mult = lerp(_k_trail_start_scale, _k_trail_end_scale, _progress);
 
		var t_inst = instance_create_layer(x, y, "Instances", oRedOrbSquares_Trail);
		t_inst.sprite_index = sprite_index;
		t_inst.image_index = image_index;
		t_inst.image_xscale = image_xscale * _trail_scale_mult;
		t_inst.image_yscale = image_yscale * _trail_scale_mult;
		t_inst.image_blend = image_blend;
		t_inst.image_angle = direction;
		t_inst.trail_life = _k_trail_lifespan;
		t_inst.trail_shrink_speed = _k_trail_shrink_speed;
		t_inst.layer_id_tag = layer_id_tag;
		t_inst.light_color = light_color;
		t_inst.glow_color = glow_color;
		t_inst.burst_escalation = burst_escalation;
    }
}

if (!hide_visual) {
    scr_add_light(x, y, light_color, 0.8 + burst_escalation * 0.7 + birth_heat * 1.4);
}
