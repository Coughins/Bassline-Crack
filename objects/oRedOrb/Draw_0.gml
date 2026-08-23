event_inherited();

if (fruit_seed_visual)
{
    var _fs_speed0 = point_distance(xprevious, yprevious, x, y);
    var _fs_dir0 = (_fs_speed0 > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
    var _fs_heat0 = clamp(fruit_seed_heat + (ember_split ? 0.22 : 0), 0, 1.45);
    var _fs_ring0 = fruit_seed_ring_power;
    if (ember_split && instance_exists(oAvoidanceController)
    && oAvoidanceController.t >= 2085 && oAvoidanceController.t < 2106) {
        var _coil_seed_p = clamp((oAvoidanceController.t - 2085) / (2106 - 2085), 0, 1);
        _fs_heat0 = max(_fs_heat0, 1 + _coil_seed_p * 0.45);
        _fs_ring0 = max(_fs_ring0, 1.2 + _coil_seed_p * 0.55);
    }

    scr_draw_avoidance_fruit_seed_projectile(x, y, image_xscale, image_yscale, image_angle, image_alpha,
                                             fruit_seed_color, _fs_heat0, _fs_ring0,
                                             fruit_seed_visual_seed + t, sprite_index, image_index,
                                             _fs_dir0, _fs_speed0);
    exit;
}

if (ember_split)
{

    var _rg_speed = point_distance(xprevious, yprevious, x, y);
    var _rg_dir = (_rg_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
    var _rg_col = merge_color(make_color_rgb(255, 90, 40), c_white, 0.15);

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _rg_uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _rg_uvs[0], _rg_uvs[1], _rg_uvs[2], _rg_uvs[3]);

    shader_set_uniform_f(global.u_glow_color, 1, 0.45, 0.2);
    shader_set_uniform_f(global.u_glow_intensity, 1.1 * image_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, x, y, 0.65 * image_xscale, 0.65 * image_yscale, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.3 * image_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, x, y, 0.28 * image_xscale, 0.28 * image_yscale, 0, c_white, 1);

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);

    if (_rg_speed > 4)
    {
        var _rg_tail = min(_rg_speed * 1.6, 38);
        var _rg_tail_x = x - lengthdir_x(_rg_tail, _rg_dir);
        var _rg_tail_y = y - lengthdir_y(_rg_tail, _rg_dir);
        var _rg_perp = _rg_dir + 90;
        var _rg_off = 2;

        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha(0.3 * image_alpha);
        draw_line_width(_rg_tail_x + lengthdir_x(_rg_off, _rg_perp), _rg_tail_y + lengthdir_y(_rg_off, _rg_perp),
                        x + lengthdir_x(_rg_off, _rg_perp), y + lengthdir_y(_rg_off, _rg_perp), 4);
        draw_set_color(global.avoid_col_cyan);
        draw_line_width(_rg_tail_x - lengthdir_x(_rg_off, _rg_perp), _rg_tail_y - lengthdir_y(_rg_off, _rg_perp),
                        x - lengthdir_x(_rg_off, _rg_perp), y - lengthdir_y(_rg_off, _rg_perp), 4);

        draw_set_color(_rg_col);
        draw_set_alpha(0.4 * image_alpha);
        draw_line_width(_rg_tail_x, _rg_tail_y, x, y, 6);
        draw_set_color(c_white);
        draw_set_alpha(0.7 * image_alpha);
        draw_line_width(_rg_tail_x, _rg_tail_y, x, y, 2.5);

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }
}

if (trail)
{
    array_push(trail_history, {
        x: x, y: y,
        xscale: image_xscale, yscale: image_yscale,
        blend: image_blend
    });
    if (array_length(trail_history) > _k_trail_length)
    {
        array_delete(trail_history, 0, 1);
    }
}

if (trail)
{
    var _count = array_length(trail_history);
    gpu_set_blendmode(bm_add);
    for (var i = 0; i < _count; i++)
    {
        var _pt = trail_history[i];
        var _prog = i / max(_count - 1, 1);
        var _alpha = _k_trail_alpha_base * power(_prog, 0.5);
        var _scale_mult = power(_k_trail_scale_falloff, _count - i);

        var _hot_blend = merge_color(_pt.blend, c_white, _prog);

        draw_sprite_ext(sprite_index, image_index, _pt.x, _pt.y,
            _pt.xscale * _scale_mult, _pt.yscale * _scale_mult,
            image_angle, _hot_blend, _alpha);
    }
    gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index,image_index,x,y,image_xscale,image_yscale,image_angle,image_blend,image_alpha);
gpu_set_blendmode(bm_normal);

if (ember_split && oAvoidanceController.t >= 2085 && oAvoidanceController.t < 2106)
{
    var _chg_p = clamp((oAvoidanceController.t - 2085) / (2106 - 2085), 0, 1);
    var _chg_pulse = 0.8 + sin(current_time * 0.03 + x * 0.05) * 0.2;
    gpu_set_blendmode(bm_add);
    draw_set_color(merge_color(make_color_rgb(255, 90, 40), c_white, _chg_p));
    draw_set_alpha((0.3 + _chg_p * 0.5) * _chg_pulse);
    draw_circle(x, y, (5 + _chg_p * 6) * _chg_pulse, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
