event_inherited();

var _dx = x + arrow_vibe_x;
var _dy = y + arrow_vibe_y;

if (visible && !arrow_locked && !arrow_popping && instance_exists(oAvoidanceController))
{
    var _rail_p = clamp((oAvoidanceController.arc_charge - 0.70) / 0.22, 0, 1);
    if (_rail_p > 0.01)
    {
        var _ux = lengthdir_x(1, direction);
        var _uy = lengthdir_y(1, direction);
        var _ray_len = oAvoidanceController._k_arc_beam_len;
        var _bound_l = 0;
        var _bound_r = room_width;
        var _bound_t = 0;
        var _bound_b = room_height;

        if (instance_exists(oCameraController))
        {
            if (oCameraController.current_cam_w > 1 && oCameraController.current_cam_h > 1)
            {
                _bound_l = oCameraController.current_cam_x;
                _bound_r = oCameraController.current_cam_x + oCameraController.current_cam_w;
                _bound_t = oCameraController.current_cam_y;
                _bound_b = oCameraController.current_cam_y + oCameraController.current_cam_h;
            }
        }

        if (_ux > 0.0001) {
            _ray_len = min(_ray_len, (_bound_r - _dx) / _ux);
        } else if (_ux < -0.0001) {
            _ray_len = min(_ray_len, (_bound_l - _dx) / _ux);
        }

        if (_uy > 0.0001) {
            _ray_len = min(_ray_len, (_bound_b - _dy) / _uy);
        } else if (_uy < -0.0001) {
            _ray_len = min(_ray_len, (_bound_t - _dy) / _uy);
        }

        _ray_len = max(1, _ray_len);
        var _rx = _dx + _ux * _ray_len;
        var _ry = _dy + _uy * _ray_len;
        var _rail_pulse = 0.65 + 0.35 * sin(current_time * 0.018 + arrow_seed);

        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_warning);
        draw_set_alpha(_rail_p * (0.08 + _rail_p * 0.16) * _rail_pulse);
        draw_line_width(_dx, _dy, _rx, _ry, 12);

        draw_set_color(global.avoid_col_cyan);
        draw_set_alpha(_rail_p * 0.18 * _rail_pulse);
        draw_line_width(_dx, _dy, _rx, _ry, 2);

        draw_set_color(c_white);
        draw_set_alpha(_rail_p * 0.35);
        draw_line_width(_dx, _dy, _rx, _ry, 1);

        var _mark = 5 + _rail_p * 8;
        var _mx = lengthdir_x(_mark, direction + 90);
        var _my = lengthdir_y(_mark, direction + 90);
        draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.35));
        draw_set_alpha(_rail_p * 0.55);
        draw_line_width(_rx - _mx, _ry - _my, _rx + _mx, _ry + _my, 1.5);

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }
}

if (arrow_laser_mode)
{
    var _fade = 1 - (arrow_laser_timer / arrow_laser_max_frames);
    var _end_x = _dx + lengthdir_x(arrow_laser_length, direction);
    var _end_y = _dy + lengthdir_y(arrow_laser_length, direction);

    draw_set_alpha(_fade);
    draw_set_color(c_white);
    draw_line_width(_dx, _dy, _end_x, _end_y, 10);
    draw_set_color(c_red);
    draw_line_width(_dx, _dy, _end_x, _end_y, 4);
    draw_set_alpha(1);
}
else if (arrow_locked)
{
    var _lock_p = clamp(arrow_lock_timer / 20, 0, 1);
    var _split = 1.5 + _lock_p * 5;

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index,
                    _dx + lengthdir_x(_split, direction + 90), _dy + lengthdir_y(_split, direction + 90),
                    image_xscale, image_yscale, image_angle, make_color_rgb(255, 20, 20), 0.75);
    draw_sprite_ext(sprite_index, image_index,
                    _dx - lengthdir_x(_split, direction + 90), _dy - lengthdir_y(_split, direction + 90),
                    image_xscale, image_yscale, image_angle, make_color_rgb(20, 220, 255), 0.75);
    gpu_set_blendmode(bm_normal);

    draw_sprite_ext(sprite_index, image_index, _dx, _dy, image_xscale, image_yscale, image_angle,
                    merge_color(image_blend, c_white, _lock_p * 0.7), image_alpha);
}
else
{
    draw_sprite_ext(sprite_index, image_index, _dx, _dy, image_xscale, image_yscale, image_angle,
                    image_blend, image_alpha);
}
