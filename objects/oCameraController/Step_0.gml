var _shake_x = 0;
var _shake_y = 0;
if (shake > 0)
{
    var _shake_mag = shake * fx_get_mult("shake");
    _shake_x = random_range(-_shake_mag, _shake_mag);
    _shake_y = random_range(-_shake_mag, _shake_mag);
    shake *= 0.85;
    if (shake < 0.1) shake = 0;
}

if (final_zoom_step_index < array_length(_k_final_zoom_steps) && oAvoidanceController.t >= _k_final_zoom_steps[final_zoom_step_index])
{
    final_zoom_engaged = true;
    final_zoom_active = true;
    final_zoom_timer = 0;
    final_zoom_from = zoom;
    final_zoom_to = _k_final_zoom_targets[final_zoom_step_index];
    final_zoom_len = _k_final_zoom_durations[final_zoom_step_index];
    final_angle_from = current_cam_angle;
    final_angle_target = _k_final_cam_angles[final_zoom_step_index];
    final_zoom_step_index++;
}

if (!final_zoom_engaged && !cube_zoom_out_active && !cube_zoom_out_holding &&
    instance_exists(oAvoidanceController) &&
    oAvoidanceController.t > oAvoidanceController._k_cube_t_spawn)
{
    cube_zoom_out_holding = true;
}

if (cam_kick_active)
{
    cam_kick_timer++;
    if (cam_kick_timer <= cam_kick_pull_time)
    {
        var _t = cam_kick_timer / cam_kick_pull_time;
        var _eased = 1 - power(1 - _t, 3);
        cam_offset_x = lerp(0, cam_kick_pull_distance, _eased);
    }
    else if (cam_kick_timer <= cam_kick_pull_time + cam_kick_return_time)
    {
        var _t = (cam_kick_timer - cam_kick_pull_time) / cam_kick_return_time;
        var _eased = 1 - power(1 - _t, 3);
        cam_offset_x = lerp(cam_kick_pull_distance, 0, _eased);
        if (_t >= 1)
        {
            cam_offset_x = 0;
            cam_kick_active = false;
        }
    }
}
else
{
    cam_offset_x = 0;
}

if (oAvoidanceController.t < 48)
{
    var _ip = clamp(oAvoidanceController.t / 48, 0, 1);

    var _ieased = _ip * _ip * _ip * (_ip * (_ip * 6 - 15) + 10);

    zoom = lerp(_k_intro_zoom_start, 1.0, _ieased);
	current_cam_angle = lerp(_k_intro_tilt_start, 0, _ieased);
}
else if (final_zoom_engaged)
{
    if (final_zoom_active)
    {
        final_zoom_timer++;
        var _fp = clamp(final_zoom_timer / max(final_zoom_len, 1), 0, 1);
        var _feased = 1 - power(1 - _fp, 3);
        zoom = lerp(final_zoom_from, final_zoom_to, _feased);
        current_cam_angle = lerp(final_angle_from, final_angle_target, _feased);

        if (_fp >= 1)
        {
            zoom = final_zoom_to;
            current_cam_angle = final_angle_target;
            final_zoom_active = false;
        }
    }
    else
    {
        zoom = final_zoom_to;
        current_cam_angle = final_angle_target;
    }
}
else if (slash_zoom_active)
{
    slash_zoom_timer++;

    var _slash_duration = (slash_zoom_phase == "out") ? _k_slash_zoom_out_duration : _k_slash_zoom_in_duration;
    var _slash_p = clamp(slash_zoom_timer / _slash_duration, 0, 1);
    var _slash_eased = 1 - power(1 - _slash_p, 3);

    zoom = lerp(slash_zoom_from, slash_zoom_to, _slash_eased);

    if (_slash_p >= 1)
    {
        zoom = slash_zoom_to;

        if (slash_zoom_phase == "in")
        {
            slash_zoom_active = false;
        }
    }
}
else if (cube_zoom_out_active)
{
    cube_zoom_out_timer += 1;
    cube_zoom_out_timer += 1;
    var _p = clamp(cube_zoom_out_timer / cube_zoom_out_duration, 0, 1);
    var _eased = 1 - power(1 - _p, 3);
    zoom = lerp(1.0, cube_zoom_target, _eased);

    if (cube_zoom_out_timer >= cube_zoom_out_duration)
    {
        cube_zoom_out_active = false;
        cube_zoom_out_holding = true; 
    }
}
else if (cube_zoom_out_holding) 
{
    zoom = cube_zoom_target;
}
else
{
    zoom = 1;
}

zoom_punch *= 0.8;
if (zoom_punch < 0.002) zoom_punch = 0;
zoom *= (1 - clamp(zoom_punch * fx_get_mult("zoom"), 0, 1));

letterbox_amount += (letterbox_target - letterbox_amount) * 0.1;
if (abs(letterbox_amount - letterbox_target) < 0.002) letterbox_amount = letterbox_target;

current_cam_w = base_view_w * zoom;
current_cam_h = base_view_h * zoom;
camera_set_view_size(cam, current_cam_w, current_cam_h);

var _center_x = base_view_w / 2;
var _center_y = base_view_h / 2;

if (final_zoom_engaged && instance_exists(oPlayer))
{
    _center_x = lerp(oPlayer.x, base_view_w / 2, final_focus_mix);
    _center_y = lerp(oPlayer.y, base_view_h / 2, final_focus_mix);
}
current_cam_x = (_center_x - current_cam_w / 2) + _shake_x + cam_offset_x;
current_cam_y = (_center_y - current_cam_h / 2) + _shake_y;
camera_set_view_pos(cam, current_cam_x, current_cam_y);

angle_kick = lerp(angle_kick, 0, _k_angle_kick_decay);
if (abs(angle_kick) < 0.01) angle_kick = 0;

camera_set_view_angle(cam, current_cam_angle + angle_kick * fx_get_mult("tilt"));
