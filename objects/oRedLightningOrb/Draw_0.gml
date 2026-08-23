event_inherited();

var _danger_col = global.avoid_col_danger;
var _accent_col = global.lightning_color;
var _body_col = (image_blend == c_white) ? _danger_col : merge_color(_danger_col, image_blend, 0.24);
var _heat = clamp(_size / 2, 0, 1);
var _core_col = merge_color(_body_col, c_white, 0.45 + _heat * 0.35);

draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale, image_yscale, image_angle, _body_col, image_alpha);

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale * 1.45, image_yscale * 1.45, image_angle,
                merge_color(_body_col, _accent_col, 0.18), image_alpha * 0.28);
draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale * 0.55, image_yscale * 0.55, image_angle,
                _core_col, image_alpha * 0.72);

var _seed_r = 3 + _size * 3.8;
draw_set_color(_core_col);
draw_set_alpha(image_alpha * (0.46 + _heat * 0.28));
draw_circle(x, y, _seed_r, false);

for (var _ei = 0; _ei < 4; _ei++) {
    var _ea = image_angle + _ei * 90 + current_time * 0.02;
    var _er1 = _seed_r * 1.5;
    var _er2 = _seed_r * (2.9 + _heat * 0.8);
    draw_set_color((_ei mod 2 == 0) ? _accent_col : c_white);
    draw_set_alpha(image_alpha * (0.14 + _heat * 0.18));
    draw_line_width(x + lengthdir_x(_er1, _ea), y + lengthdir_y(_er1, _ea),
                    x + lengthdir_x(_er2, _ea), y + lengthdir_y(_er2, _ea), 1.4 + _heat);
}

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);

if (flash_timer > 0) {
    var _t = 1 - (flash_timer / 10);
    var _radius = lerp(4, 40, _t);
    var _alpha = (flash_timer / 10);
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(_alpha);
    draw_circle(x, y, _radius, false);
    draw_set_alpha(_alpha * 0.5);
    draw_circle(x, y, _radius * 1.6, false);
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
    flash_timer -= 1;
}

if (line_life > 0) line_life -= 1;
