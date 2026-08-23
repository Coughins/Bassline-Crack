event_inherited();

var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;
var _chroma = (_ctrl != noone) ? _ctrl.jr_chroma : 0;
var _col_armor = (_ctrl != noone) ? _ctrl._k_er_col_armor_edge : make_color_rgb(128, 214, 238);
var _col_dark = (_ctrl != noone) ? _ctrl._k_er_col_armor_dark : make_color_rgb(7, 12, 26);
var _col_cyan = (_ctrl != noone) ? _ctrl._k_er_col_cyan : make_color_rgb(88, 235, 255);
var _col_warn = (_ctrl != noone) ? _ctrl._k_er_col_warning : make_color_rgb(255, 46, 72);
var _col_white = (_ctrl != noone) ? _ctrl._k_er_col_white : c_white;

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
                    _tr.ang,
                    merge_color(_col_armor, _tr.blend, _f),
                    _a);
}

var _fall_speed = point_distance(prev_x, prev_y, x, y);
if (_fall_speed > 2.5) {
    var _fall_dir = point_direction(prev_x, prev_y, x, y);
    var _tail_len = min(_fall_speed * 2.4, 46);
    var _tx = x - lengthdir_x(_tail_len, _fall_dir);
    var _ty = y - lengthdir_y(_tail_len, _fall_dir);
    var _tail_perp = _fall_dir + 90;
    var _tail_off = 2.2 * fx_get_mult_for("jumprope", "aberration");
    var _tail_w = 3 + hot * 2.5;

    draw_set_color(_col_warn);
    draw_set_alpha(0.45 * image_alpha);
    draw_line_width(_tx + lengthdir_x(_tail_off, _tail_perp), _ty + lengthdir_y(_tail_off, _tail_perp),
                    x + lengthdir_x(_tail_off, _tail_perp), y + lengthdir_y(_tail_off, _tail_perp), _tail_w);
    draw_set_color(_col_cyan);
    draw_line_width(_tx - lengthdir_x(_tail_off, _tail_perp), _ty - lengthdir_y(_tail_off, _tail_perp),
                    x - lengthdir_x(_tail_off, _tail_perp), y - lengthdir_y(_tail_off, _tail_perp), _tail_w);
    draw_set_color(_col_white);
    draw_set_alpha(0.7 * image_alpha);
    draw_line_width(_tx, _ty, x, y, _tail_w * 0.4);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

var _fringe = clamp(_chroma * clamp(vspeed_current / 12, 0, 1), 0, 1) * 2.6 * fx_get_mult_for("jumprope", "aberration");
if (_fringe > 0.2) {
    draw_sprite_ext(sprite_index, image_index, x, y - _fringe, image_xscale, image_yscale,
                    image_angle, _col_warn, image_alpha * 0.6);
    draw_sprite_ext(sprite_index, image_index, x, y + _fringe, image_xscale, image_yscale,
                    image_angle, _col_cyan, image_alpha * 0.45);
}

gpu_set_blendmode(bm_normal);
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 1.05, image_yscale * 1.05,
                image_angle, _col_dark, image_alpha * 0.55);

gpu_set_blendmode(bm_add);
draw_self();

// ============================================================================
// OUTER CIRCLE + ROTATING LINES POSITION
// ============================================================================

var _shell_x_offset = -1; //IDK WHY THIS NEEDS -1 TO LINE UP
var _shell_y_offset = -1; //IDK WHY THIS NEEDS -1 TO LINE UP

var _shell_x = x + _shell_x_offset;
var _shell_y = y + _shell_y_offset;


var _shell_s = max(image_xscale, image_yscale);

// Radius of the circle
var _shell_r = 9.5 * _shell_s;


// ---------------------------------------------------------------------------
// OUTER CIRCLE
// ---------------------------------------------------------------------------

draw_set_color(
    merge_color(
        _col_armor,
        _col_warn,
        0.3 + hot * 0.4
    )
);

draw_set_alpha(
    image_alpha *
    (0.42 + hot * 0.4)
);

draw_circle(
    _shell_x,
    _shell_y,
    _shell_r,
    true
);


// ---------------------------------------------------------------------------
// FOUR ROTATING LINES
// ---------------------------------------------------------------------------

for (var _tick = 0; _tick < 4; _tick++)
{
    var _ta =
        shell_spin +
        _tick * 90;


    var _ix =
        _shell_x +
        lengthdir_x(
            _shell_r * 0.68,
            _ta
        );

    var _iy =
        _shell_y +
        lengthdir_y(
            _shell_r * 0.68,
            _ta
        );


    var _ox =
        _shell_x +
        lengthdir_x(
            _shell_r * 1.15,
            _ta
        );

    var _oy =
        _shell_y +
        lengthdir_y(
            _shell_r * 1.15,
            _ta
        );


    draw_line_width(
        _ix,
        _iy,
        _ox,
        _oy,
        1.8
    );
}

var _core_heat = clamp(hot * 0.85 + squash_timer * 0.65, 0, 1);
draw_set_color(merge_color(_col_warn, _col_white, _core_heat * 0.55));
draw_set_alpha(image_alpha * (0.34 + _core_heat * 0.5));
draw_circle(x, y, _shell_r * (0.34 + _core_heat * 0.1), false);
draw_set_color(_col_white);
draw_set_alpha(image_alpha * _core_heat * 0.38);
draw_line_width(x - _shell_r * 0.32, y, x + _shell_r * 0.32, y, 1.2);
draw_line_width(x, y - _shell_r * 0.32, x, y + _shell_r * 0.32, 1.2);

draw_set_color(_col_warn);
draw_set_alpha(image_alpha * (0.18 + squash_timer * 0.35));
draw_ellipse(x - _shell_r * 1.16, y - _shell_r * 0.48,
             x + _shell_r * 1.16, y + _shell_r * 0.48, true);

var _scan_y = y + sin(reactor_phase * 2.4) * _shell_r * 0.42;
draw_set_color(_col_cyan);
draw_set_alpha(image_alpha * (0.28 + hot * 0.28));
draw_line_width(x - _shell_r * 0.72, _scan_y, x + _shell_r * 0.72, _scan_y, 1.4);
draw_set_color(_col_white);
draw_set_alpha(image_alpha * hot * 0.42);
draw_line_width(x - _shell_r * 0.32, _scan_y - 2, x + _shell_r * 0.32, _scan_y - 2, 1);
draw_set_alpha(1);

if (hot > 0.05 || squash_timer > 0.05) {
    var _core = max(hot, squash_timer);
    draw_sprite_ext(sprite_index, image_index, x, y,
                    image_xscale * 0.55, image_yscale * 0.55,
                    image_angle, _col_white, _core * 0.8);
}

gpu_set_blendmode(bm_normal);
