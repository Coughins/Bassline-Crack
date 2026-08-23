event_inherited();

gpu_set_blendmode(bm_add);

var _sx = beam_start_x;
var _sy = beam_start_y;
var _ex = beam_end_x;
var _ey = beam_end_y;
if (point_distance(_sx, _sy, _ex, _ey) < 1) {
    var _dux = lengthdir_x(1, beam_dir);
    var _duy = lengthdir_y(1, beam_dir);
    var _dlen = beam_len_max;
    var _dl = -beam_room_pad;
    var _dr = room_width + beam_room_pad;
    var _dt = -beam_room_pad;
    var _db = room_height + beam_room_pad;

    if (instance_exists(oCameraController))
    {
        if (oCameraController.current_cam_w > 1 && oCameraController.current_cam_h > 1)
        {
            _dl = oCameraController.current_cam_x - beam_room_pad;
            _dr = oCameraController.current_cam_x + oCameraController.current_cam_w + beam_room_pad;
            _dt = oCameraController.current_cam_y - beam_room_pad;
            _db = oCameraController.current_cam_y + oCameraController.current_cam_h + beam_room_pad;
        }
    }

    if (_dux > 0.0001) {
        _dlen = min(_dlen, (_dr - _sx) / _dux);
    } else if (_dux < -0.0001) {
        _dlen = min(_dlen, (_dl - _sx) / _dux);
    }

    if (_duy > 0.0001) {
        _dlen = min(_dlen, (_db - _sy) / _duy);
    } else if (_duy < -0.0001) {
        _dlen = min(_dlen, (_dt - _sy) / _duy);
    }

    _dlen = max(1, _dlen);
    _ex = _sx + _dux * _dlen;
    _ey = _sy + _duy * _dlen;
}

if (charging)
{
    var _p = clamp(charge_timer / max(charge_duration, 1), 0, 1);
    var _pulse = 0.65 + 0.35 * sin(current_time * 0.02 + beam_seed);
    var _warn_w = beam_warn_half_width * (0.55 + _p * 0.45);

    draw_set_color(global.avoid_col_warning);
    draw_set_alpha((0.16 + _p * 0.22) * _pulse);
    draw_line_width(_sx, _sy, _ex, _ey, _warn_w * 2);

    draw_set_color(global.avoid_col_cyan);
    draw_set_alpha((0.10 + _p * 0.18) * _pulse);
    draw_line_width(_sx, _sy, _ex, _ey, max(2, _warn_w * 0.5));

    draw_set_color(c_white);
    draw_set_alpha(0.42 + _p * 0.42);
    draw_line_width(_sx, _sy, _ex, _ey, 1.2 + _p * 1.5);

    for (var _pip = 0; _pip < 6; _pip++) {
        var _f = frac(_pip / 6 + current_time * 0.003 * (0.6 + _p));
        var _px = lerp(_sx, _ex, _f);
        var _py = lerp(_sy, _ey, _f);
        draw_set_alpha((0.18 + _p * 0.36) * (1 - _f * 0.25));
        draw_circle(_px, _py, 1.5 + _p * 2.2, false);
    }

    var _tick = 8 + _p * 16;
    var _tx = lengthdir_x(_tick, beam_dir + 90);
    var _ty = lengthdir_y(_tick, beam_dir + 90);
    var _bx = lengthdir_x(_tick * 1.25, beam_dir);
    var _by = lengthdir_y(_tick * 1.25, beam_dir);

    draw_set_color(merge_color(global.avoid_col_warning, c_white, 0.35 + _p * 0.35));
    draw_set_alpha(0.35 + _p * 0.45);
    draw_line_width(_ex - _tx, _ey - _ty, _ex + _tx, _ey + _ty, 2.2);
    draw_line_width(_ex - _tx, _ey - _ty, _ex - _tx - _bx, _ey - _ty - _by, 1.6);
    draw_line_width(_ex + _tx, _ey + _ty, _ex + _tx - _bx, _ey + _ty - _by, 1.6);

    draw_set_color(c_white);
    draw_set_alpha(0.32 + _p * 0.5);
    draw_circle(_ex, _ey, 3 + _p * 5, true);
}
else if (beam_live)
{
    draw_set_color(global.avoid_col_warning);
    draw_set_alpha(image_alpha * (0.38 + charge_flare * 0.18));
    draw_line_width(_sx, _sy, _ex, _ey, max(4, beam_hit_half_width * 2.2));

    draw_set_color(c_white);
    draw_set_alpha(min(1, image_alpha * (0.65 + charge_flare * 0.55)));
    draw_line_width(_sx, _sy, _ex, _ey, max(1.5, beam_hit_half_width * 0.35));
}

draw_set_alpha(1);
draw_set_color(c_white);

var _fringe = (charging ? (0.5 + charge_timer * 0.06)
                       : (charge_flare * 7 + clamp(image_xscale, 0, 5) * 0.9))
              * fx_get_mult_for("laser", "aberration");
if (_fringe > 0.2)
{
    var _perp = image_angle;
    var _fx = lengthdir_x(_fringe, _perp);
    var _fy = lengthdir_y(_fringe, _perp);

    draw_sprite_ext(sprite_index, image_index, x + _fx, y + _fy, image_xscale, image_yscale,
                    image_angle, make_color_rgb(255, 20, 20), image_alpha * 0.6);
    draw_sprite_ext(sprite_index, image_index, x - _fx, y - _fy, image_xscale, image_yscale,
                    image_angle, make_color_rgb(20, 220, 255), image_alpha * 0.6);
}

gpu_set_texrepeat(true);
shader_set(shd_laser_beam);

texture_set_stage(u_laser_noise_handle, sprite_get_texture(spr_laser_noise, 0));
shader_set_uniform_f(u_laser_time_handle, (current_time / 1000) mod 1000);
shader_set_uniform_f(u_laser_speed_handle, laser_speed);
shader_set_uniform_f(u_laser_coreWidth_handle, laser_coreWidth);
shader_set_uniform_f(u_laser_haloWidth_handle, laser_haloWidth);
shader_set_uniform_f(u_laser_noiseStrength_handle, laser_noiseStrength);
shader_set_uniform_f(u_laser_twist_handle, laser_twist);
shader_set_uniform_f(u_laser_brightness_handle, laser_brightness);
shader_set_uniform_f(u_laser_whiteAmount_handle, laser_whiteAmount);

draw_self();

shader_reset();
gpu_set_texrepeat(false);

if (charge_flare > 0.02)
{
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * (1 + charge_flare * 0.6),
                    image_yscale, image_angle, c_white, charge_flare * 0.85);
}

gpu_set_blendmode(bm_normal);
