event_inherited();

if (fruit_seed_visual)
{
    var _fs_speed1 = point_distance(xprevious, yprevious, x, y);
    var _fs_dir1 = (_fs_speed1 > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
    var _seed_contained = fruit_seed_contained && !ember_ring_launched;
    var _fs_draw_color = fruit_seed_color;
    var _fs_cocoon_shift = 0;
    var _fs_shell_r = 0;
    var _fs_shell_col = c_white;
    var _fs_shell_deep = global.avoid_col_armor_mid;
    var _fs_heat1 = clamp(fruit_seed_heat + (dying ? 0.25 : 0) + (ember_ring_launched ? 0.25 : 0), 0, 1.55);
    var _fs_ring1 = fruit_seed_ring_power;
    if (dying) _fs_ring1 = max(_fs_ring1, 1.35);
    if (orb_rotate_mode) _fs_ring1 = max(_fs_ring1, 1.25);
    if (ember_ring_release || ember_ring_launched) _fs_ring1 = max(_fs_ring1, 1.5);
    if (_seed_contained) {
        _fs_cocoon_shift = 1;
        _fs_draw_color = merge_color(global.avoid_col_cyan_soft, c_white, 0.18);
        _fs_heat1 = clamp(0.44 + fruit_seed_containment_flash * 0.08 + fruit_seed_release_flash * 0.2, 0, 0.84);
        _fs_ring1 = max(_fs_ring1, 2.18);

        var _shell_scale = max(abs(image_xscale), abs(image_yscale));
        var _shell_pulse = 0.5 + 0.5 * sin(current_time * 0.026 + fruit_seed_visual_seed);
        var _shell_hot = clamp(0.35 + fruit_seed_containment_flash * 0.42 + fruit_seed_release_flash * 0.5, 0, 1.25);
        var _shell_r = (14.5 + _fs_ring1 * 3.8 + _shell_pulse * 2.2 + _shell_hot * 4.4) * _shell_scale;
        var _shell_col = merge_color(global.avoid_col_cyan_soft, c_white, clamp(0.12 + _shell_hot * 0.16, 0, 0.38));
        var _shell_deep = merge_color(global.avoid_col_armor_mid, global.avoid_col_cyan, 0.78);
        var _rim_col = merge_color(global.avoid_col_cyan_soft, c_white, clamp(fruit_seed_release_flash * 0.45, 0, 0.7));
        _fs_shell_r = _shell_r;
        _fs_shell_col = _shell_col;
        _fs_shell_deep = _shell_deep;

        gpu_set_blendmode(bm_add);
        draw_set_color(_shell_deep);
        draw_set_alpha(image_alpha * (0.16 + _shell_hot * 0.08));
        draw_circle_color(x, y, _shell_r * 1.18, _shell_col, _shell_deep, false);
        draw_set_color(_shell_col);
        draw_set_alpha(image_alpha * (0.18 + _shell_hot * 0.09));
        draw_circle(x, y, _shell_r * 1.26, true);

        for (var _sbi = 0; _sbi < 2; _sbi++) {
            var _rot = fruit_seed_visual_seed + current_time * (0.05 + _sbi * 0.018) * ((_sbi == 0) ? 1 : -1);
            var _last_x = 0;
            var _last_y = 0;
            var _has_last = false;
            for (var _ssi = 0; _ssi <= 8; _ssi++) {
                var _sa = -112 + _ssi * 28;
                var _lx = lengthdir_x(_shell_r * (0.82 + _sbi * 0.08), _sa);
                var _ly = lengthdir_y(_shell_r * (0.26 + _sbi * 0.16), _sa);
                var _px = x + _lx * dcos(_rot) - _ly * dsin(_rot);
                var _py = y + _lx * dsin(_rot) + _ly * dcos(_rot);
                if (_has_last) {
                    draw_set_color(_shell_col);
                    draw_set_alpha(image_alpha * (0.18 + _shell_hot * 0.08));
                    draw_line_width(_last_x, _last_y, _px, _py, 1.7);
                    draw_set_color(c_white);
                    draw_set_alpha(image_alpha * (0.10 + fruit_seed_release_flash * 0.12));
                    draw_line_width(_last_x, _last_y, _px, _py, 0.65);
                }
                _last_x = _px;
                _last_y = _py;
                _has_last = true;
            }
        }

        draw_set_color(_shell_col);
        draw_set_alpha(image_alpha * (0.48 + _shell_hot * 0.2));
        draw_circle(x, y, _shell_r, true);
        draw_set_color(_rim_col);
        draw_set_alpha(image_alpha * (0.34 + fruit_seed_release_flash * 0.42));
        draw_circle(x, y, _shell_r * 0.84, true);

        if (ember_ring_release) {
            for (var _cki = 0; _cki < 4; _cki++) {
                var _ca = fruit_seed_visual_seed + _cki * 91 + sin(current_time * 0.03 + _cki) * 4;
                var _r0 = _shell_r * 0.44;
                var _r1 = _shell_r * lerp(0.66, 1.02, clamp(fruit_seed_release_flash, 0, 1));
                draw_set_color(global.avoid_col_cyan_soft);
                draw_set_alpha(image_alpha * (0.25 + fruit_seed_release_flash * 0.35));
                draw_line_width(x + lengthdir_x(_r0, _ca), y + lengthdir_y(_r0, _ca),
                                x + lengthdir_x(_r1, _ca + 12), y + lengthdir_y(_r1, _ca + 12), 1.25);
                draw_set_color(c_white);
                draw_set_alpha(image_alpha * fruit_seed_release_flash * 0.45);
                draw_line_width(x + lengthdir_x(_r0, _ca), y + lengthdir_y(_r0, _ca),
                                x + lengthdir_x(_r1, _ca + 12), y + lengthdir_y(_r1, _ca + 12), 0.6);
            }
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    scr_draw_avoidance_fruit_seed_projectile(x, y, image_xscale, image_yscale, image_angle, image_alpha,
                                             _fs_draw_color, _fs_heat1, _fs_ring1,
                                             fruit_seed_visual_seed + orb_timer, sprite_index, image_index,
                                             _fs_dir1, _fs_speed1, _fs_cocoon_shift);

    if (_seed_contained) {
        gpu_set_blendmode(bm_add);
        draw_set_color(_fs_shell_col);
        draw_set_alpha(image_alpha * (0.28 + fruit_seed_containment_flash * 0.12));
        draw_circle(x, y, _fs_shell_r * 1.08, true);
        draw_set_color(c_white);
        draw_set_alpha(image_alpha * (0.22 + fruit_seed_release_flash * 0.28));
        draw_circle(x, y, _fs_shell_r * 0.52, true);
        draw_set_color(_fs_shell_deep);
        draw_set_alpha(image_alpha * 0.2);
        draw_circle(x, y, _fs_shell_r * 0.72, true);
        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    if (fruit_seed_release_flash > 0.02 && !_seed_contained) {
        gpu_set_blendmode(bm_add);
        draw_set_color(c_white);
        draw_set_alpha(image_alpha * fruit_seed_release_flash * 0.55);
        draw_circle(x, y, 18 * max(abs(image_xscale), abs(image_yscale)) * (1 + (1 - fruit_seed_release_flash) * 0.6), true);
        draw_set_color(global.avoid_col_cyan_soft);
        draw_set_alpha(image_alpha * fruit_seed_release_flash * 0.28);
        draw_circle(x, y, 25 * max(abs(image_xscale), abs(image_yscale)), true);
        draw_set_alpha(1);
        draw_set_color(c_white);
        gpu_set_blendmode(bm_normal);
    }

    if (chain_line_life > 0) chain_line_life -= 1;
    if (line_life > 0) line_life -= 1;
    if (graze_bolt_life > 0) graze_bolt_life -= 1;
    exit;
}

if (ember_glow_core)
{
    var _eg_speed = point_distance(xprevious, yprevious, x, y);
    var _eg_dir = (_eg_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
    var _eg_col = merge_color(make_color_rgb(255, 90, 40), c_white, 0.15);

    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _eg_uvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _eg_uvs[0], _eg_uvs[1], _eg_uvs[2], _eg_uvs[3]);

    shader_set_uniform_f(global.u_glow_color, 1, 0.45, 0.2);
    shader_set_uniform_f(global.u_glow_intensity, 1.3 * image_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    draw_sprite_ext(spr_glow_blob, 0, x, y, 0.8 * image_xscale, 0.8 * image_yscale, 0, c_white, 1);

    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, 1.6 * image_alpha);
    shader_set_uniform_f(global.u_glow_falloff, 2.2);
    draw_sprite_ext(spr_glow_blob, 0, x, y, 0.35 * image_xscale, 0.35 * image_yscale, 0, c_white, 1);

    shader_reset();
    gpu_set_blendequation(bm_eq_add);
    gpu_set_blendmode(bm_normal);

    if (_eg_speed > 4)
    {
        var _eg_tail = min(_eg_speed * 1.8, 46);
        var _eg_tail_x = x - lengthdir_x(_eg_tail, _eg_dir);
        var _eg_tail_y = y - lengthdir_y(_eg_tail, _eg_dir);
        var _eg_perp = _eg_dir + 90;
        var _eg_off = 2.5 * fx_get_mult("aberration");

        gpu_set_blendmode(bm_add);
        draw_set_color(global.avoid_col_danger);
        draw_set_alpha(0.4 * image_alpha);
        draw_line_width(_eg_tail_x + lengthdir_x(_eg_off, _eg_perp), _eg_tail_y + lengthdir_y(_eg_off, _eg_perp),
                        x + lengthdir_x(_eg_off, _eg_perp), y + lengthdir_y(_eg_off, _eg_perp), 5);
        draw_set_color(global.avoid_col_cyan);
        draw_line_width(_eg_tail_x - lengthdir_x(_eg_off, _eg_perp), _eg_tail_y - lengthdir_y(_eg_off, _eg_perp),
                        x - lengthdir_x(_eg_off, _eg_perp), y - lengthdir_y(_eg_off, _eg_perp), 5);

        draw_set_color(_eg_col);
        draw_set_alpha(0.5 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, x, y, 9);
        draw_set_color(c_white);
        draw_set_alpha(0.8 * image_alpha);
        draw_line_width(_eg_tail_x, _eg_tail_y, x, y, 3);

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

if (spark_glow)
{
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.3, image_yscale * 1.3, image_angle, c_white, 0.5);
    gpu_set_blendmode(bm_normal);
}
draw_self();

if (chain_line_life > 0) chain_line_life -= 1;
if (line_life > 0) line_life -= 1;
if (graze_bolt_life > 0) graze_bolt_life -= 1;
