var _c = oAvoidanceController;
var _s = rope_s;
var _inv = 1 - _s;

var _target_x = _inv*_inv*_c.jump_rope_anchor_left_x + 2*_inv*_s*_c.jump_rope_mid_x + _s*_s*_c.jump_rope_anchor_right_x;
var _target_y = _inv*_inv*_c.jump_rope_anchor_left_y + 2*_inv*_s*_c.jump_rope_mid_y + _s*_s*_c.jump_rope_anchor_right_y;

var _tension = (_c.jump_rope_depth + 1) / 2;
_tension = power(_tension, 0.6);

var _sag = lerp(35, 0, _tension);

var _sag_shape = sin(_s * pi);
_target_y += _sag * _sag_shape;

var _lag = lerp(_k_jr_follow_lag * 1.5, _k_jr_follow_lag * 0.6, 1 - abs(_s - 0.5)*2);
if (_c.jump_rope_hazard_active) _lag = 1;
x = lerp(x, _target_x, clamp(_lag, 0.05, 1));
y = lerp(y, _target_y, clamp(_lag, 0.05, 1));

weave_u = 1 - abs(_s - 0.5) * 2;
var _weave_band = 0.22;
weave_reveal = clamp((_c.jr_weave - weave_u) / _weave_band + 1, 0, 1);

if (!weave_popped && weave_reveal >= 1) {
    weave_popped = true;
    core_scale = 2.2;
}
core_scale = lerp(core_scale, 1, 0.2);

image_alpha = _c.jump_rope_alpha * weave_reveal;

var _depth01 = (_c.jump_rope_depth + 1) / 2;

hot = lerp(hot, clamp(power(_depth01, 2) * 0.55 + _c.jr_coil * 0.6 + _c.jr_crack_flash, 0, 1), 0.25);

collidable = _c.jump_rope_hazard_active;

var _spd = point_distance(prev_x, prev_y, x, y);
spd = _spd;
var _dir = point_direction(prev_x, prev_y, x, y);

image_angle = _dir;

var _base = lerp(0.5, 1.6, _depth01) * core_scale * lerp(0.3, 1, weave_reveal);

var _stretch = clamp(_spd / 6, 0, 1);
image_xscale = _base * (1 + _stretch * 0.6);
image_yscale = _base * (1 - _stretch * 0.25);

var _rope_base_col = merge_color(_c._k_er_col_armor_edge, _c._k_er_col_cyan, _depth01);
var _rope_warn = clamp(_c.jr_heartbeat * 0.35 + _c.jr_coil * 0.5 + _c.jr_crack_flash * 0.6, 0, 1);
image_blend = merge_color(merge_color(_rope_base_col, _c._k_er_col_warning, _rope_warn * 0.35),
                          _c._k_er_col_white, hot * 0.68);

if (_spd > _k_trail_speed_threshold) {
    array_push(trail_history, {
        x: prev_x, y: prev_y,
        angle: image_angle,
        scale_x: image_xscale, scale_y: image_yscale,
        blend: image_blend,
        alpha: image_alpha,
        hot: hot
    });
    if (array_length(trail_history) > _k_trail_max_points) array_delete(trail_history, 0, 1);
} else if (array_length(trail_history) > 0) {
    array_delete(trail_history, 0, 1);
}

if (image_alpha > 0.05) scr_register_glow_point(x, y);

prev_x = x;
prev_y = y;
