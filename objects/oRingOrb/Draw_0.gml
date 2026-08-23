event_inherited();

gpu_set_blendmode(bm_add);

if (has_trail) {
    var _len = array_length(trail_history);
    for (var i = 0; i < _len; ++i) {
        var _t = trail_history[i];
        var _a = (i / _len) * (0.28 + ring_tier * 0.07);
        var _ts = variable_struct_exists(_t, "stretch") ? _t.stretch : 1;
        var _td = variable_struct_exists(_t, "dir") ? _t.dir : image_angle;
        draw_sprite_ext(sprite_index, image_index, _t.x, _t.y,
                        _t.size * _ts, _t.size / max(1, sqrt(_ts)),
                        _td, ring_color, _a);
    }
}

var _draw_dir = (travel_speed > 0.05) ? travel_dir : image_angle;
var _stretch = max(1, stretch);
var _squash = 1 / max(1, sqrt(_stretch));
var _tier_hot = clamp((ring_tier - 1) / 3, 0, 1);
var _chroma = clamp((travel_speed - 4) / 16 + birth_heat * 0.55 + _tier_hot * 0.2, 0, 1);
var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _warn_col = (_ctrl != noone) ? _ctrl._k_er_col_warning : c_red;
var _cyan_col = (_ctrl != noone) ? _ctrl._k_er_col_cyan : c_aqua;

if (_chroma > 0.04) {
    var _perp = _draw_dir + 90;
    var _off = (1.5 + _chroma * 3.5) * fx_get_mult_for("eruption", "aberration");
    draw_sprite_ext(sprite_index, image_index,
                    x + lengthdir_x(_off, _perp), y + lengthdir_y(_off, _perp),
                    image_xscale * _stretch, image_yscale * _squash,
                    _draw_dir, _warn_col, image_alpha * 0.34 * _chroma);
    draw_sprite_ext(sprite_index, image_index,
                    x - lengthdir_x(_off, _perp), y - lengthdir_y(_off, _perp),
                    image_xscale * _stretch, image_yscale * _squash,
                    _draw_dir, _cyan_col, image_alpha * 0.34 * _chroma);
}

if (birth_heat > 0.02) {
    var _tail = 12 + birth_heat * (26 + ring_tier * 8);
    draw_set_color(merge_color(ring_color, c_white, 0.35 + birth_heat * 0.55));
    draw_set_alpha(image_alpha * birth_heat * 0.55);
    draw_line_width(x - lengthdir_x(_tail, _draw_dir), y - lengthdir_y(_tail, _draw_dir),
                    x, y, 2 + birth_heat * (2 + ring_tier));
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sprite_ext(sprite_index, image_index, x, y,
                image_xscale * _stretch, image_yscale * _squash,
                _draw_dir, ring_color, image_alpha);

if (use_dash && dash_state == 1) {
    var _warn_progress = dash_timer / dash_wait_duration;
    var _warn_alpha = 0.25 + 0.55 * _warn_progress;
    if (_warn_progress > 0.7) {
        _warn_alpha *= (0.6 + 0.4 * sin(dash_timer * 0.8));
    }
    var _warn_length = 220;
    var _end_x = x + lengthdir_x(_warn_length, direction);
    var _end_y = y + lengthdir_y(_warn_length, direction);

    draw_set_color(_cyan_col);

    draw_set_alpha(_warn_alpha * 0.15);
    draw_line_width(x, y, _end_x, _end_y, 10);
    draw_set_alpha(_warn_alpha * 0.25);
    draw_line_width(x, y, _end_x, _end_y, 6);

    draw_set_color(_cyan_col);
    draw_set_alpha(_warn_alpha * 0.6);
    draw_line_width(x, y, _end_x, _end_y, 2);

    var _pulse_pos = frac(dash_timer * 0.06);
    var _pulse_x = lerp(x, _end_x, _pulse_pos);
    var _pulse_y = lerp(y, _end_y, _pulse_pos);
    draw_set_color(c_white);
    draw_set_alpha(_warn_alpha);
    draw_circle(_pulse_x, _pulse_y, 4, false);

    var _arrow_size = 10;
    var _a1 = direction + 150;
    var _a2 = direction - 150;
    draw_set_color(_cyan_col);
    draw_set_alpha(_warn_alpha * 0.8);
    draw_triangle(
        _end_x, _end_y,
        _end_x + lengthdir_x(_arrow_size, _a1), _end_y + lengthdir_y(_arrow_size, _a1),
        _end_x + lengthdir_x(_arrow_size, _a2), _end_y + lengthdir_y(_arrow_size, _a2),
        false
    );

}

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);
