var _blade_red = make_color_rgb(185, 18, 22);

if (hit_flash_timer > 0) {
    hit_flash_timer--;
    var _fade = hit_flash_timer / 6;
    var _hit_flash_mult = hit_flash_strength * fx_get_mult_for("kunairain", "flash");
    draw_sprite_ext(sprite_index, image_index, x, y,
        image_xscale * (1 + 0.3 * _hit_flash_mult),
        image_yscale * (1 + 0.3 * _hit_flash_mult),
        image_angle, c_white, _fade * _hit_flash_mult);
}

if (absorb_flash > 0.01) {
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y,
        image_xscale * (1 + 0.35 * absorb_flash), image_yscale * (1 + 0.35 * absorb_flash),
        image_angle, c_white, absorb_flash * 0.8);
    gpu_set_blendmode(bm_normal);
}

var _chroma = clamp(last_boost, 0, 1) * fx_get_mult_for("kunairain", "aberration");
if (_chroma > 0.05) {
    var _coff = _chroma * _k_chroma_px;
    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index,
        x + lengthdir_x(_coff, image_angle + 90), y + lengthdir_y(_coff, image_angle + 90),
        image_xscale, image_yscale, image_angle, c_red, _chroma * 0.45);
    draw_sprite_ext(sprite_index, image_index,
        x - lengthdir_x(_coff, image_angle + 90), y - lengthdir_y(_coff, image_angle + 90),
        image_xscale, image_yscale, image_angle, c_aqua, _chroma * 0.45);
    gpu_set_blendmode(bm_normal);
}

for (var i = array_length(trail_history) - 1; i >= 0; i--) {
    var _h = trail_history[i];
    var _fade = 1 - (i / trail_length);
    var _alpha = _fade * lerp(0.12, 0.5, last_boost);
    var _trail_col = merge_color(_blade_red, c_white, _fade * lerp(0.25, 0.85, last_boost));
    draw_sprite_ext(sprite_index, image_index, _h.x, _h.y,
        image_xscale, image_yscale, _h.ang, _trail_col, _alpha);

    if (_chroma > 0.05) {
        var _hoff = _chroma * _k_chroma_px * _fade;
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(sprite_index, image_index,
            _h.x + lengthdir_x(_hoff, _h.ang + 90), _h.y + lengthdir_y(_hoff, _h.ang + 90),
            image_xscale, image_yscale, _h.ang, c_red, _alpha * 0.6);
        draw_sprite_ext(sprite_index, image_index,
            _h.x - lengthdir_x(_hoff, _h.ang + 90), _h.y - lengthdir_y(_hoff, _h.ang + 90),
            image_xscale, image_yscale, _h.ang, c_aqua, _alpha * 0.6);
        gpu_set_blendmode(bm_normal);
    }
}

gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(spark_particles); i++) {
    var _p = spark_particles[i];
    var _age = 1 - (_p.life / _p.max_life);
    var _col = scr_hot_metal_color(_age);
    if (variable_struct_exists(_p, "accent_col") && !is_undefined(_p.accent_col)) {
        _col = merge_color(_p.accent_col, _col, _age);
    }
    var _alpha = (_p.life / _p.max_life);
    var _tail_x = _p.x - _p.vx * 1.4;
    var _tail_y = _p.y - _p.vy * 1.4;

    draw_set_alpha(_alpha * 0.25);
    draw_line_width_color(_p.x, _p.y, _tail_x, _tail_y, _p.width * 3, _col, _col);

    draw_set_alpha(_alpha);
    draw_line_width_color(_p.x, _p.y, _tail_x, _tail_y, _p.width, _col, _col);
}
draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

var _body_heat = clamp(last_boost * 0.45 + absorb_flash * 0.35, 0, 0.8);
var _body_col = merge_color(_blade_red, c_white, _body_heat);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _body_col, image_alpha);

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 0.42, image_yscale * 0.92,
                image_angle, c_white, image_alpha * lerp(0.12, 0.4, clamp(last_boost + absorb_flash, 0, 1)));
gpu_set_blendmode(bm_normal);
