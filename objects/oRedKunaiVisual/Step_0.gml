scr_register_glow_point(x, y);
event_inherited();
if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}

image_angle = direction

image_alpha -= kunai_alpha_step;

if (image_alpha <= 0)
{
    image_alpha = 0;
    instance_destroy();
}

if (finale_motion_mode > 0)
{
    finale_motion_timer++;

    var _life = max(1, finale_motion_life);
    var _p = clamp(finale_motion_timer / _life, 0, 1);
    var _e = _p * _p * (3 - 2 * _p);
    var _old_x = x;
    var _old_y = y;

    switch (finale_motion_mode)
    {
        case 1:
        {
            var _r = lerp(finale_motion_radius, finale_motion_radius2, _e);
            var _ang = finale_motion_angle + finale_motion_spin * (_e + sin(_p * 3.14159) * 0.22);
            x = finale_motion_cx + lengthdir_x(_r, _ang);
            y = finale_motion_cy + lengthdir_y(_r, _ang) * finale_motion_squash;
            plant_flash = max(plant_flash, max(0, 1 - abs(_p - 0.82) / 0.05) * 0.7);
            break;
        }

        case 2:
        {
            if (_p < 0.76)
            {
                var _q = _p / 0.76;
                var _qe = _q * _q * (3 - 2 * _q);
                var _iq = 1 - _qe;
                x = _iq * _iq * finale_motion_sx + 2 * _iq * _qe * finale_motion_c1x + _qe * _qe * finale_motion_tx;
                y = _iq * _iq * finale_motion_sy + 2 * _iq * _qe * finale_motion_c1y + _qe * _qe * finale_motion_ty;
            }
            else
            {
                var _q2 = (_p - 0.76) / 0.24;
                var _q2e = _q2 * _q2;
                x = lerp(finale_motion_tx, finale_motion_ex, _q2e);
                y = lerp(finale_motion_ty, finale_motion_ey, _q2e);
            }
            plant_flash = max(plant_flash, max(0, 1 - abs(_p - 0.76) / 0.045));
            break;
        }
    }

    var _motion_speed = point_distance(_old_x, _old_y, x, y);
    if (_motion_speed > 0.1) {
        direction = point_direction(_old_x, _old_y, x, y);
        image_angle = direction;
    }

    var _fade_in = clamp(finale_motion_timer / 6, 0, 1);
    var _fade_out = clamp((_life - finale_motion_timer) / max(1, finale_motion_fade), 0, 1);
    image_alpha = finale_base_alpha * min(_fade_in, _fade_out);

    if (finale_motion_timer >= finale_motion_life) {
        instance_destroy();
    }
}

if (finale_mode)
{
    var _moved = point_distance(prev_x, prev_y, x, y);
    stretch = lerp(stretch, 1 + _moved * 0.11, 0.4);

    if (_moved > 0.5) {
        array_push(trail_positions, [x, y, direction]);
        if (array_length(trail_positions) > trail_max) array_delete(trail_positions, 0, 1);
    } else if (!frozen_trail) {
        frozen_trail = true;
    }

    prev_x = x;
    prev_y = y;

    finale_heat = max(0, finale_heat - 0.07);
    plant_flash = max(0, plant_flash - 0.09);

    if (band_mode)
    {
        var _at_rest = (speed <= 0.05);
        if (_at_rest && band_planted <= 0) plant_flash = 1;
        band_planted = _at_rest ? min(1, band_planted + 0.16) : max(0, band_planted - 0.2);

        var _fin_target = band_planted * (11 + finale_hue * 5) * (1 + plant_flash * 1.5);
        band_fin += (_fin_target - band_fin) * 0.3;

        if (band_planted > 0.4 && random(1) < 0.1 + plant_flash * 0.5)
        {
            array_push(embers, {
                x : x + random_range(-9, 9) * stretch,
                y : y + random_range(-4, 4),
                vx : random_range(-0.7, 0.7),
                vy : random_range(0.3, 1.6),
                life : irandom_range(16, 34), life_max : 34,
                size : random_range(1, 2.6)
            });
        }
    }

    for (var _em = array_length(embers) - 1; _em >= 0; _em--)
    {
        var _e2 = embers[_em];
        _e2.x += _e2.vx;
        _e2.y += _e2.vy;
        _e2.vy += 0.07;
        _e2.life--;
        if (_e2.life <= 0) array_delete(embers, _em, 1);
    }

    afterimage_timer++;
    if (afterimage_timer >= 3 && _moved > 2)
    {
        afterimage_timer = 0;
        array_push(afterimages, {x : x, y : y, dir : direction, life : 12, life_max : 12});
        if (array_length(afterimages) > (band_mode ? 4 : 5)) array_delete(afterimages, 0, 1);
    }

    for (var _ai = array_length(afterimages) - 1; _ai >= 0; _ai--)
    {
        afterimages[_ai].life--;
        if (afterimages[_ai].life <= 0) array_delete(afterimages, _ai, 1);
    }

    var _lights_this_blade = band_mode ? (band_slot == 7) : (finale_heat > 0.3);
    if (_lights_this_blade) {
      var _lit = max(finale_heat, plant_flash, band_planted * 0.45);
      var _light_mult = instance_exists(oAvoidanceController) ? oAvoidanceController._k_bh_finale_kunai_light_mult : 0.35;
      scr_add_light(x, y, merge_color(c_red, c_white, finale_hue * 0.6 + _lit * 0.4),
                    (1.2 + _lit * 1.2 + finale_hue * 0.5) * _light_mult);
    }
}

if (kunai_curve_mode)
{
    kunai_curve_timer++;
    direction += kunai_curve_rate;

    if (kunai_curve_timer >= kunai_curve_frames)
    {
        var _burst_chance = kunai_curve_burst_chance;

        if (random(1) < _burst_chance)
        {
            var _band_width   = kunai_curve_band_width;
            var _spread_count = kunai_curve_spread_count;
            var _launch_speed = kunai_curve_launch_speed;
            var _split_y = is_undefined(kunai_curve_split_y) ? y : kunai_curve_split_y;

            var _near_top = (_split_y < room_height / 2);

            if (finale_mode && instance_exists(oAvoidanceController)) {
                var _slash_y = _near_top ? (_split_y + _band_width * 0.5) : (_split_y - _band_width * 0.5);
                array_push(oAvoidanceController.bh_kunai_bursts, {
                    x : x, y : _slash_y,
                    life : 22, life_max : 22,
                    spikes : [],
                    power : 0.9,
                    hue : finale_hue,
                    edge : 0,
                    band : _band_width * 0.5
                });
            }

            var _dirs = [0, 180];
            for (var d = 0; d < 2; d++)
            {
                for (var j = 0; j < _spread_count; j++)
                {
                    var _lt  = (_spread_count > 1) ? (j / (_spread_count - 1)) : 0.5;
                    var _off = _near_top ? lerp(0, _band_width, _lt) : lerp(-_band_width, 0, _lt);

                    with (instance_create_layer(x, _split_y + _off, layer, oRedKunaiVisual))
                    {
                        direction   = _dirs[d];
                        speed       = _launch_speed;
                        image_alpha = other.image_alpha;

                        kunai_decel_mode   = true;
                        var _phase_den = max(1, other.kunai_curve_phase_count - 1);
                        var _phase = other.kunai_curve_phase_slot / _phase_den;
                        var _front = abs(_phase - 0.5) * 2;
                        var _jfront = abs(_lt - 0.5) * 2;
                        kunai_decel_frames = round(lerp(other.kunai_curve_decel_min, other.kunai_curve_decel_max,
                                                        clamp(_front * 0.72 + _jfront * 0.28, 0, 1)));
                        kunai_decel_step   = _launch_speed / max(1, kunai_decel_frames);

                        finale_mode = other.finale_mode;
                        finale_tier = 1;
                        finale_hue  = other.finale_hue;
                        trail_max   = 18;
                        band_mode   = true;
                        band_slot   = j;
                        hit_active  = true;
                        kunai_fade_frames = 39;
                        kunai_alpha_step  = 1 / kunai_fade_frames;
                    }
                }
            }
        }

        instance_destroy();
    }
}

if (kunai_decel_mode)
{
    kunai_decel_timer++;
    if (kunai_decel_timer >= kunai_decel_frames)
    {
        speed = 0;
        kunai_decel_mode = false;
    }
    else
    {
        speed -= kunai_decel_step;
        if (speed < 0) speed = 0;
    }
}

hit_active = image_alpha > 0.35 && abs(image_xscale) > 0.25 && abs(image_yscale) > 0.25;
if (finale_mode) hit_active = band_mode && hit_active;
