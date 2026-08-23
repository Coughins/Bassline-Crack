exit;

if (image_alpha <= 0.01) exit;

var _c = oAvoidanceController;
var _chroma = _c.jr_chroma;

gpu_set_blendmode(bm_add);

var _n = array_length(trail_history);
for (var i = 0; i < _n; i++) {
    var _tr = trail_history[i];
    var _f = (i + 1) / _n;
    var _a = _tr.alpha * _f * _f * 0.5;
    if (_a <= 0.01) continue;

    draw_sprite_ext(sprite_index, image_index, _tr.x, _tr.y,
                    _tr.scale_x * lerp(0.35, 1, _f),
                    _tr.scale_y * lerp(0.5, 1, _f),
                    _tr.angle,
                    merge_color(_c._k_er_col_armor_edge, _tr.blend, _f),
                    _a);
}

var _fringe = clamp(_chroma * clamp(spd / 9, 0, 1), 0, 1) * 3.2 * fx_get_mult_for("jumprope", "aberration");
if (_fringe > 0.2) {
    var _perp = image_angle + 90;
    var _ox = lengthdir_x(_fringe, _perp);
    var _oy = lengthdir_y(_fringe, _perp);

    draw_sprite_ext(sprite_index, image_index, x + _ox, y + _oy, image_xscale, image_yscale,
                    image_angle, _c._k_er_col_warning, image_alpha * 0.65);
    draw_sprite_ext(sprite_index, image_index, x - _ox, y - _oy, image_xscale, image_yscale,
                    image_angle, _c._k_er_col_cyan, image_alpha * 0.5);
}

draw_self();

draw_set_color(_c._k_er_col_cyan);
draw_set_alpha(image_alpha * (0.18 + hot * 0.28));
draw_circle(x, y, max(1.2, 4.5 * max(image_xscale, image_yscale)), true);
draw_set_alpha(1);

if (hot > 0.05) {
    draw_sprite_ext(sprite_index, image_index, x, y,
                    image_xscale * 0.5, image_yscale * 0.5,
                    image_angle, c_white, hot * image_alpha * 0.9);
}

gpu_set_blendmode(bm_normal);
