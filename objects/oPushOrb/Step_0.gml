event_inherited();

var _ctrl = instance_exists(oAvoidanceController) ? oAvoidanceController : noone;

prev_x = x;
prev_y = y;

if (spawn_pop > 0) {
    spawn_pop = max(0, spawn_pop - 0.1);
    image_alpha = 1 - spawn_pop;
} else if (_ctrl != noone && _ctrl.t >= _ctrl._k_transition_cleanup_start_t) {
    image_alpha = lerp(image_alpha, 0, 0.08);
} else {
    image_alpha = min(image_alpha + 1 / _k_fade_frames, 1);
}

if (wave_seen > 0) wave_seen--;

if (_ctrl != noone) {
    var _waves = _ctrl.push_waves;
    for (var i = 0; i < array_length(_waves); i++) {
        var _w = _waves[i];
        if (!variable_struct_exists(_w, "prev_y")) continue;

        var _crossed = (_w.prev_y >= y && _w.y <= y) || (_w.prev_y <= y && _w.y >= y);
        if (!_crossed || wave_seen > 0) continue;

        wave_seen = 8;
        squash_timer = 1;
        hot = 1;
        vspeed_current = max(vspeed_current, vspeed_target * 0.85);
        spin_kick = random_range(6, 18) * choose(-1, 1);
        x += random_range(-3, 3);
    }
}

vspeed_current = lerp(vspeed_current, vspeed_target, 0.18);
y += vspeed_current;

x += sin(wobble_seed + current_time * 0.0012) * 0.35;

if (_ctrl != noone) {
    vspeed_target = lerp(vspeed_target, _ctrl._k_push_orb_idle_fall_speed, _ctrl._k_push_orb_decay_rate);
}

if (squash_timer > 0) squash_timer = max(squash_timer - 0.07, 0);
hot = max(0, hot - 0.03);

tumble += spin_kick;
spin_kick *= 0.9;
image_angle = tumble;
reactor_phase += 0.045 + clamp(vspeed_current / 18, 0, 1) * 0.055 + hot * 0.035;
shell_spin += spin_kick * 0.35 + 1.2 + hot * 3;

var _speed01 = clamp(vspeed_current / 16, 0, 1);
var _pop = spawn_pop > 0 ? (1 + spawn_pop * 0.8) : 1;

image_yscale = (1 + squash_timer * 0.55 + _speed01 * 0.5) * _pop;
image_xscale = (1 - squash_timer * 0.22 - _speed01 * 0.18) * _pop;

var _cold_col = (_ctrl != noone) ? _ctrl._k_er_col_armor_edge : make_color_rgb(128, 214, 238);
var _warn_col = (_ctrl != noone) ? _ctrl._k_er_col_warning : make_color_rgb(255, 46, 72);
var _white_col = (_ctrl != noone) ? _ctrl._k_er_col_white : c_white;
image_blend = merge_color(merge_color(_cold_col, _warn_col, clamp(hot * 0.42 + squash_timer * 0.35, 0, 1)),
                          _white_col, clamp(hot * 0.62 + squash_timer * 0.5, 0, 1));

if (_ctrl != noone) scr_register_glow_point(x, y);

if (_ctrl != noone && y > _ctrl._k_jr_floor_y && vspeed_current > 6) {
    with (_ctrl) {
        repeat (3) {
            var _sa = choose(0, 180) + random_range(-40, 40);
            var _ss = random_range(2, 5);
            array_push(arrow_ring_particles, {
                x : other.x, y : _k_jr_floor_y,
                vx : lengthdir_x(_ss, _sa),
                vy : -abs(lengthdir_y(_ss, _sa)) * 0.7,
                life : 12, max_life : 12,
                size : random_range(0.05, 0.14),
                grav : 0.24, drag : 0.94,
                hot : 0.45
            });
        }
        scr_floor_impact(other.x, _k_jr_floor_y, 0.14, 0);
    }
    scr_add_light(x, _ctrl._k_jr_floor_y, _ctrl._k_er_col_cyan, 1.5);
    instance_destroy();
    exit;
}

if (y > room_height + 40 ||
    (_ctrl != noone && _ctrl.t > _ctrl.push_orb_end_t + 120)) {
    instance_destroy();
    exit;
}

var _spd = point_distance(prev_x, prev_y, x, y);

array_push(trail_history, {
    x : prev_x, y : prev_y,
    scale_x : image_xscale, scale_y : image_yscale,
    blend : image_blend, alpha : image_alpha,
    ang : image_angle
});

var _dynamic_max = clamp(round(_spd * _k_trail_speed_to_length), 0, _k_trail_max_points);
while (array_length(trail_history) > _dynamic_max) {
    array_delete(trail_history, 0, 1);
}
