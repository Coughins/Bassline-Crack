event_inherited();
scr_register_glow_point(x, y);
var _pop_scale = 1;
if (spawn_pop_timer < spawn_pop_duration)
{
    spawn_pop_timer += 1;
    var _pp = spawn_pop_timer / spawn_pop_duration;
    _pop_scale = 1 - power(1 - _pp, 3);
}

var _speed_ref = oAvoidanceController.cube_phase_timer;
var _local_t = _speed_ref + phase_offset;
var _wrapped = _local_t mod 2;
travel = abs(_wrapped - 1);
if (reverse_travel) travel = 1 - travel;

var _verts_arr = (cube_type == 0) ? oAvoidanceController.big_cube_projected : oAvoidanceController.small_cube_projected;
if (array_length(_verts_arr) < 8) {
    hit_active = false;
    exit;
}

if (oAvoidanceController.cube_despawn_active) {
    hit_active = false;
}

var _edge = oAvoidanceController.cube_edges[edge_index];
var _v1 = _verts_arr[_edge[0]];
var _v2 = _verts_arr[_edge[1]];

var _z_scale = lerp(_v1.scale, _v2.scale, travel);
image_xscale = _z_scale * _pop_scale;
image_yscale = _z_scale * _pop_scale;
image_blend = merge_color(c_gray, c_white, clamp((_z_scale - 0.6) / 0.6, 0, 1));

var _raw_x = lerp(_v1.x, _v2.x, travel);
var _raw_y = lerp(_v1.y, _v2.y, travel);

var _ext = oAvoidanceController.cube_extend;
prev_x = x;
prev_y = y;
x = lerp(oAvoidanceController.cube_center_x, _raw_x, _ext);
y = lerp(oAvoidanceController.cube_center_y, _raw_y, _ext);

var _player_clear = 1;
if (oAvoidanceController.cube_spawn_active && instance_exists(oPlayer)) {
    var _pd = point_distance(x, y, oPlayer.x, oPlayer.y);
    _player_clear = clamp((_pd - oAvoidanceController._k_cube_line_player_clear_near) /
                          max(1, oAvoidanceController._k_cube_line_player_clear_far -
                                 oAvoidanceController._k_cube_line_player_clear_near), 0, 1);
    _player_clear = _player_clear * _player_clear;
}

vel_x = x - prev_x;
vel_y = y - prev_y;
speed_now = point_distance(0, 0, vel_x, vel_y);

var _fade_alpha;
if (oAvoidanceController.cube_despawn_active)
{
    alpha_fade_out_timer += 1;
    var _fp = clamp(alpha_fade_out_timer / alpha_fade_out_duration, 0, 1);
    _fade_alpha = lerp(1, alpha_fade_out_floor, _fp);
}
else
{
    alpha_fade_in_timer += 1;
    var _fp2 = clamp(alpha_fade_in_timer / alpha_fade_in_duration, 0, 1);
    _fade_alpha = _fp2 * _fp2;
}

image_alpha = _fade_alpha * _z_scale;
hit_active = !oAvoidanceController.cube_despawn_active &&
             _player_clear >= 0.98 && image_alpha > hit_alpha_min && _z_scale > 0.9 && _pop_scale > 0.35 &&
             abs(image_xscale) > hit_scale_min && abs(image_yscale) > hit_scale_min;
