event_inherited();

var _life_p = clamp(timer / max(life, 1), 0, 1);
var _reform_p = reforming ? clamp(reform_timer / max(reform_duration, 1), 0, 1) : 0;
var _reform_e = reforming ? (1 - power(1 - _reform_p, 3)) : 0;
var _blood_seed = make_color_rgb(96, 8, 18);
var _sap_hot = merge_color(fruit_color, c_white, 0.3);
var _core_hot = merge_color(fruit_color, c_white, 0.68);
var _body_col = merge_color(_blood_seed, fruit_color, 0.42 + _life_p * 0.22);
_body_col = merge_color(_body_col, c_white, _reform_e * 0.42);

var _pulse = 0.5 + 0.5 * sin(current_time * 0.018 + visual_seed);
var _heat = clamp(0.35 + _life_p * 0.3 + _reform_e * 0.55 + _pulse * 0.08, 0, 1);
var _fringe = 1.6 * fx_get_mult_for("tree", "aberration");

if (post_reform) {
    gpu_set_blendmode(bm_add);

    var _ptn = array_length(trail_history);
    for (var _pi = _ptn - 2; _pi >= 0; _pi--) {
        var _pp0 = trail_history[_pi];
        var _pp1 = trail_history[_pi + 1];
        var _pf = 1 - (_pi / max(1, _ptn - 1));
        var _pa = image_alpha * _pf * 0.42;
        var _pw = lerp(1.4, 5.2, _pf);

        draw_set_color(merge_color(_blood_seed, fruit_color, _pf));
        draw_set_alpha(_pa * 0.65);
        draw_line_width(_pp0.x, _pp0.y, _pp1.x, _pp1.y, _pw);
        draw_set_color(_core_hot);
        draw_set_alpha(_pa);
        draw_line_width(_pp0.x, _pp0.y, _pp1.x, _pp1.y, max(0.9, _pw * 0.32));
    }

    gpu_set_blendmode(bm_normal);

    var _post_speed = point_distance(xprevious, yprevious, x, y);
    var _post_dir = (_post_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
    scr_draw_avoidance_fruit_seed_projectile(x, y, image_xscale, image_yscale, image_angle, image_alpha,
                                             fruit_color, fruit_seed_heat, fruit_seed_ring_power,
                                             visual_seed + sweep_angle, sprite_index, image_index,
                                             _post_dir, _post_speed);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
    exit;
}

gpu_set_blendmode(bm_add);

var _tn = array_length(trail_history);
for (var i = _tn - 2; i >= 0; i--) {
    var _p0 = trail_history[i];
    var _p1 = trail_history[i + 1];
    var _f = 1 - (i / max(1, _tn - 1));
    var _ta = image_alpha * _f * lerp(0.16, 0.5, _p0.heat);
    var _tw = lerp(1.2, 4.6, _f) * lerp(0.65, 1.15, _p0.heat);
    var _dir = point_direction(_p1.x, _p1.y, _p0.x, _p0.y);
    var _perp = _dir + 90;

    draw_set_color(merge_color(_blood_seed, fruit_color, _f));
    draw_set_alpha(_ta * 0.7);
    draw_line_width(_p0.x, _p0.y, _p1.x, _p1.y, _tw);

    draw_set_color(_core_hot);
    draw_set_alpha(_ta);
    draw_line_width(_p0.x, _p0.y, _p1.x, _p1.y, max(1, _tw * 0.34));

    draw_set_color(make_color_rgb(70, 215, 255));
    draw_set_alpha(_ta * 0.32);
    draw_line_width(_p0.x + lengthdir_x(_fringe, _perp), _p0.y + lengthdir_y(_fringe, _perp),
                    _p1.x + lengthdir_x(_fringe, _perp), _p1.y + lengthdir_y(_fringe, _perp), 1);
}

var _ring_owner = reforming ? is_center : (abs(bar_offset) < 0.01);
if (_ring_owner) {
    var _birth_ring = 1 - clamp(timer / 14, 0, 1);
    var _ring_a = max(_birth_ring * 0.65, _reform_e * 0.7) * image_alpha;
    var _ring_r = lerp(bar_half + 7 + _pulse * 2, 9, _reform_e);

    if (_ring_a > 0.02) {
        draw_set_color(fruit_color);
        draw_set_alpha(_ring_a * 0.5);
        draw_circle(anchor_x, anchor_y, _ring_r, true);

        draw_set_color(c_white);
        draw_set_alpha(_ring_a * 0.45);
        draw_circle(anchor_x, anchor_y, _ring_r * 0.72, true);

        for (var r = 0; r < 4; r++) {
            var _ra = sweep_angle + r * 90;
            draw_line_width(anchor_x + lengthdir_x(_ring_r * 0.72, _ra),
                            anchor_y + lengthdir_y(_ring_r * 0.72, _ra),
                            anchor_x + lengthdir_x(_ring_r * 1.08, _ra),
                            anchor_y + lengthdir_y(_ring_r * 1.08, _ra), 1);
        }
    }
}

if (reforming) {
    var _pull_a = image_alpha * _reform_e;
    draw_set_color(_sap_hot);
    draw_set_alpha(_pull_a * (is_center ? 0.35 : 0.75));
    draw_line_width(x, y, anchor_x, anchor_y, is_center ? 1.4 : 2.6);

    draw_set_color(c_white);
    draw_set_alpha(_pull_a * (is_center ? 0.25 : 0.6));
    draw_line_width(x, y, anchor_x, anchor_y, is_center ? 0.8 : 1.2);

    if (is_center && _reform_p > 0.35) {
        var _handoff = clamp((_reform_p - 0.35) / 0.65, 0, 1);
        var _len = lerp(14, 58, _handoff);
        var _ha = image_alpha * _handoff;

        draw_set_color(make_color_rgb(255, 34, 34));
        draw_set_alpha(_ha * 0.65);
        draw_line_width(anchor_x, anchor_y, anchor_x, anchor_y + _len, 3.4);

        draw_set_color(make_color_rgb(75, 215, 255));
        draw_set_alpha(_ha * 0.28);
        draw_line_width(anchor_x + 2, anchor_y, anchor_x + 2, anchor_y + _len * 0.85, 1.2);

        draw_set_color(c_white);
        draw_set_alpha(_ha * 0.85);
        draw_line_width(anchor_x, anchor_y, anchor_x, anchor_y + _len * 0.6, 1.1);
    }
}

gpu_set_blendmode(bm_normal);

var _fb_move_speed = point_distance(xprevious, yprevious, x, y);
var _fb_move_dir = (_fb_move_speed > 0.01) ? point_direction(xprevious, yprevious, x, y) : image_angle;
scr_draw_avoidance_fruit_seed_projectile(x, y, image_xscale, image_yscale, image_angle, image_alpha,
                                         fruit_color, _heat, 1 + _reform_e * 0.4,
                                         visual_seed + sweep_angle, sprite_index, image_index,
                                         _fb_move_dir, _fb_move_speed);

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);
