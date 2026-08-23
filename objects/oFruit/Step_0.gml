event_inherited();
scr_register_glow_point(x, y);

var _scale = 1;
if (spawn_burst)
{
    spawn_timer++;

    var _p = clamp(spawn_timer / 8,0,1);

    var _s = lerp(0,1.3,_p);

    if (_p > 0.7)
    {
        _s = lerp(1.3,1,(_p-0.7)/0.3);
    }
	
	_scale *= _s;

    if (_p >= 1)
    {
        spawn_burst = false;
    }
}

if (crack_timer > 0)
{
    crack_timer--;

    var _pulse = crack_timer / 8;

	_scale *= 1 + _pulse * 0.20;
}
if (crack_flash > 0)
{
    crack_flash *= 0.8;
}
if (crack_glow > 0)
{
    crack_glow *= 0.7;
}
if (cocoon_crack_flash > 0)
{
    cocoon_crack_flash *= 0.76;
    if (cocoon_crack_flash < 0.01) cocoon_crack_flash = 0;
}
if (cocoon_rupture_flash > 0)
{
    cocoon_rupture_flash *= 0.65;
    if (cocoon_rupture_flash < 0.01) cocoon_rupture_flash = 0;
}

scr_add_light(
    x + jitter_x,
    y + jitter_y,
    merge_color(_k_unripe_color, fruit_color, base_alpha),
    (base_alpha * 0.6 + crack_glow * 1.5) * image_alpha
);

if (instance_exists(oAvoidanceController)) {
    var _ctrl = oAvoidanceController;
    var _rp = 0;
    if (_ctrl.t >= _ctrl.tree_ignite_start_t) {
        _rp = clamp((_ctrl.t - _ctrl.tree_ignite_start_t) / max(1, _ctrl.tree_max_ignite_delay), 0, 1);
    }
    ripeness = _rp;
    base_alpha = lerp(0.1, 1, _rp);
}

idle_timer += 1;
var _pulse = 0.5 + 0.5 * sin(idle_timer * 0.08);
image_alpha = base_alpha * lerp(0.85, 1, _pulse);

if (!spawn_burst && crack_flash > 0)
{
    image_alpha = min(1, image_alpha + crack_flash);

    image_blend = merge_color(
        fruit_color,
        c_white,
        crack_flash
    );

    crack_flash *= 0.65;
}
else
{
    image_blend = c_white;
}

var _idle_scale = lerp(0.98, 1.04, _pulse);
_scale *= _idle_scale;

if (instance_exists(oAvoidanceController))
{
    var _ctrl = oAvoidanceController;
	unstable = clamp((_ctrl.t - 1900) / 125, 0, 1);
    var _sap_birth = clamp((_ctrl.t - 1875) / 18, 0, 1);
    var _sap_charge = clamp((_ctrl.t - _ctrl.tree_ignite_start_t) / max(1, 2025 - _ctrl.tree_ignite_start_t), 0, 1);
    cocoon_shell_alpha = _sap_birth * lerp(0.42, 1, _sap_charge);
    cocoon_pressure = clamp(max(_sap_charge, unstable * 0.85) + crack_glow * 0.18 + cocoon_crack_flash * 0.24, 0, 1.35);

	if (_ctrl.t >= 1900)
	{
	    var _unstable = clamp((_ctrl.t - 1900) / 125, 0, 1);

	    jitter_amount = power(_unstable, 2.5) * 5;

	    jitter_x = random_range(-jitter_amount, jitter_amount);
	    jitter_y = random_range(-jitter_amount, jitter_amount);

	    jitter_angle =
	        sin((current_time * 0.02) + jitter_seed)
	        * 8
	        * _unstable;

	    jitter_scale =
	        1 + sin((current_time * 0.04) + jitter_seed)
	        * 0.03
	        * _unstable;
	}
	else
	{
	    jitter_x = 0;
	    jitter_y = 0;
	    jitter_angle = 0;
	    jitter_scale = 1;
	}
}
else
{
    cocoon_shell_alpha = max(cocoon_shell_alpha, base_alpha);
    cocoon_pressure = clamp(max(ripeness, unstable), 0, 1);
}

_scale *= jitter_scale;


if (instance_exists(oAvoidanceController))
{
    if (oAvoidanceController.t >= 2005)
    {
        image_alpha *= random_range(0.75, 1.15);
    }
}

image_xscale = _scale;
image_yscale = _scale;

hit_active = false;

if (explode_pending) {
    cocoon_rupture_flash = max(cocoon_rupture_flash, 1.15);
    explode_timer -= 1;
    if (explode_timer <= 0) {
        explode_pending = false;
        scr_fruit_explode();
    }
}
