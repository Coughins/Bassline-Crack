event_inherited();



scr_register_glow_point(x, y);

if (orb_fan_mode)
{
    orb_timer++;

    switch (orb_state)
    {
        case 0:
            if (orb_timer >= orb_spawn_delay)
            {
                orb_state       = 1;
                speed           = orb_init_speed;
                orb_decel_step  = orb_init_speed / orb_decel_frames;
                orb_decel_timer = 0;
            }
            break;

        case 1:
            orb_decel_timer++;
            if (orb_decel_timer >= orb_decel_frames)
            {
                speed     = 0;
                orb_state = 2;
            }
            else
            {
                speed -= orb_decel_step;
                if (speed < 0) speed = 0;
            }
            break;

        case 2:
            if (orb_timer >= orb_fire_delay)
            {
                direction = orb_direction;
                speed     = orb_fire_speed;
                orb_state = 3;
            }
            break;

        case 3:
            break;
    }
}


if (orb_pincer_mode)
{
    if (orb_pincer_timer < orb_pincer_curve_frames)
    {
        direction   += orb_pincer_curve_rate;
        image_angle = direction;
        orb_pincer_timer++;
    }
}

if (orb_pop_scale != orb_pop_target)
{
    orb_pop_scale = lerp(orb_pop_scale, orb_pop_target, orb_pop_speed);

    if (orb_pop_overshoot && abs(orb_pop_scale - orb_pop_target) < 0.05)
    {
        orb_pop_scale = orb_pop_target - 0.08;
        orb_pop_target = 1;
        orb_pop_overshoot = false;
    }

    image_xscale = orb_pop_scale;
    image_yscale = orb_pop_scale;
}

if (orb_pop_flash > 0)
{
    orb_pop_flash -= 0.07;
    if (orb_pop_flash < 0) orb_pop_flash = 0;
}
if (fruit_seed_containment_flash > 0)
{
    fruit_seed_containment_flash *= 0.82;
    if (fruit_seed_containment_flash < 0.01) fruit_seed_containment_flash = 0;
}
if (fruit_seed_release_flash > 0)
{
    fruit_seed_release_flash *= 0.72;
    if (fruit_seed_release_flash < 0.01) fruit_seed_release_flash = 0;
}
if (fruit_seed_launch_arm_timer > 0)
{
    fruit_seed_launch_arm_timer--;
}

if (orb_rotate_mode)
{
    orb_rotate_angle += orb_rotate_speed;
    orb_rotate_speed *= orb_rotate_decay;

    if (abs(orb_rotate_speed) < 0.05)
    {
        orb_rotate_speed = 0;
        orb_rotate_mode = false;
    }

    x = orb_rotate_cx + lengthdir_x(orb_rotate_radius, orb_rotate_angle);
    y = orb_rotate_cy + lengthdir_y(orb_rotate_radius, orb_rotate_angle);
}

if (ember_ring_release && !ember_ring_launched)
{
    fruit_seed_containment_flash = max(fruit_seed_containment_flash, 0.25);
    ember_ring_release_delay -= 1;
    if (ember_ring_release_delay <= 0)
    {
        ember_ring_launched = true;
        ember_ring_launch_timer = 0;
        orb_rotate_mode = false;
        fruit_seed_contained = false;
        fruit_seed_release_flash = max(fruit_seed_release_flash, 1);
        fruit_seed_launch_arm_timer = 5;
        hit_active = false;

        var _radial_dir = point_direction(400, 304, x, y);
        var _spin_sign = (orb_rotate_speed >= 0) ? 1 : -1;
        var _tangent_dir = _radial_dir + 90 * _spin_sign;
        var _vx = lengthdir_x(1, _radial_dir) + lengthdir_x(0.7, _tangent_dir);
        var _vy = lengthdir_y(1, _radial_dir) + lengthdir_y(0.7, _tangent_dir);
        var _launch_dir = point_direction(0, 0, _vx, _vy);

        if (instance_exists(oPlayer))
        {
            var _to_player = point_direction(x, y, oPlayer.x, oPlayer.y);
            var _diff = angle_difference(_launch_dir, _to_player);
            var _danger_cone = 30;
            if (abs(_diff) < _danger_cone)
            {
                var _sign = (_diff >= 0) ? 1 : -1;
                _launch_dir = _to_player + _sign * (_danger_cone + 14);
            }
        }

        direction = _launch_dir;
        speed = random_range(14, 22);

        image_blend = c_white;
        orb_pop_scale = 2.4;
        orb_pop_target = 1.0;
        orb_pop_overshoot = true;
        orb_pop_flash = 1;
    }
}

if (ember_ring_launched)
{
    ember_ring_launch_timer += 1;
    var _burn_p = clamp(ember_ring_launch_timer / 20, 0, 1);
    image_alpha = 1 - _burn_p;
    var _burn_scale = lerp(1, 0.15, _burn_p);
    image_xscale *= _burn_scale;
    image_yscale *= _burn_scale;

    if (ember_ring_launch_timer >= 20)
    {
        instance_destroy();
    }
}
if (bounces)
{
    if (place_meeting(x + lengthdir_x(speed, direction), y, oBlock))
    {
        direction = 180 - direction;
    }
    if (place_meeting(x, y + lengthdir_y(speed, direction), oBlock))
    {
        direction = -direction;
    }
}

if (dying)
{
    var _dir_to_center = point_direction(x, y, 400, 304);
    direction = _dir_to_center;

    _die_timer += 1;
    var _die_ramp = clamp(_die_timer / _k_dying_ramp_frames, 0, 1);
    var _die_accel = _k_dying_accel
                   * (_k_dying_accel_floor + (1 - _k_dying_accel_floor) * _die_ramp * _die_ramp);
    speed = min(speed + _die_accel * dying_speed_mult, _k_dying_max_speed);

    var _dist = point_distance(x, y, 400, 304);
    var _shrink = clamp((_dist - 20) / 200, 0, 1);
    image_xscale = _shrink;
    image_yscale = _shrink;

    light_radius = lerp(light_radius, 220, 0.15);
    image_blend = c_white;

    if (_dist < 20)
    {
        instance_destroy();
    }
}

if (ember_drip)
{
    ember_drip_timer -= 1;
    if (ember_drip_timer <= 0 && speed > 3)
    {
        ember_drip_timer = irandom_range(3, 6);
        var _peel_ang = direction + 180 + random_range(-35, 35);
        var _drip_contained = fruit_seed_visual && ember_glow_core && fruit_seed_contained && !ember_ring_launched;
        var _drip_col = _drip_contained ? merge_color(global.avoid_col_cyan_soft, c_white, 0.18)
                                        : make_color_rgb(255, 90, 40);
        var _drip_hot_col = _drip_contained ? c_white : make_color_rgb(255, 190, 110);
        array_push(oAvoidanceController.ember_drip_particles, {
            x : x,
            y : y,
            xspeed : lengthdir_x(random_range(0.5, 2), _peel_ang),
            yspeed : lengthdir_y(random_range(0.5, 2), _peel_ang) - 1,
            size : random_range(2, 5),
            life : irandom_range(18, 30),
            life_max : 30,
            color : _drip_col,
            hot_color : _drip_hot_col
        });
    }
}

var _speed_stretch = clamp(vspeed / 15, 0, 0.6);
image_yscale *= 1 + _speed_stretch;
image_xscale *= 1 - _speed_stretch * 0.3;

scr_add_light(x, y, global.lightning_color, 1.0);

if (fruit_seed_visual && ember_glow_core)
{
    if (fruit_seed_contained && !ember_ring_launched)
    {
        hit_active = false;
    }
    else if (ember_ring_launched)
    {
        hit_active = fruit_seed_launch_arm_timer <= 0
                  && image_alpha > 0.25
                  && abs(image_xscale) > 0.2
                  && abs(image_yscale) > 0.2;
    }
}
