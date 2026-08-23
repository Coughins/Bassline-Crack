gpu_set_blendmode(bm_add);

var _draw_dir = (travel_speed > 0.05) ? travel_dir : image_angle;
var _stretch = 1 + clamp(travel_speed * 0.035 + max(0, ring_tier - 1) * 0.06, 0, 0.75);
var _squash = 1 / max(1, sqrt(_stretch));
var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _warn_col = (_ctrl != noone) ? _ctrl._k_er_col_warning : c_red;
var _cyan_col = (_ctrl != noone) ? _ctrl._k_er_col_cyan : c_aqua;

if (birth_heat > 0.02 || travel_speed > 5) {
    var _chroma = clamp(birth_heat * 0.45 + (travel_speed - 5) / 18, 0, 0.75);
    var _perp = _draw_dir + 90;
    var _off = (1.0 + _chroma * 2.5) * fx_get_mult_for("eruption", "aberration");
    draw_sprite_ext(sprite_index, image_index,
                    x + lengthdir_x(_off, _perp), y + lengthdir_y(_off, _perp),
                    image_xscale * _stretch, image_yscale * _squash,
                    _draw_dir, _warn_col, image_alpha * 0.22 * _chroma);
    draw_sprite_ext(sprite_index, image_index,
                    x - lengthdir_x(_off, _perp), y - lengthdir_y(_off, _perp),
                    image_xscale * _stretch, image_yscale * _squash,
                    _draw_dir, _cyan_col, image_alpha * 0.22 * _chroma);
}

draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale * _stretch, image_yscale * _squash,
                _draw_dir, merge_color(ring_color, c_white, birth_heat * 0.22), image_alpha * 0.7);
gpu_set_blendmode(bm_normal);
