event_inherited();
var _prev_x = x, _prev_y = y;

if (spawn_delay > 0) {
    spawn_delay--;
    image_alpha = 0;
    hit_active = false;
    vel_x = 0;
    vel_y = 0;
    speed_now = 0;
    exit;
}

if (array_length(oAvoidanceController.big_cube_projected) < 8) {
    image_alpha = 0;
    hit_active = false;
    vel_x = 0;
    vel_y = 0;
    speed_now = 0;
    exit;
}

travel_timer += 1;
var _p = clamp(travel_timer / max(1, travel_duration), 0, 1);

var _u, _w;
if (bullet_mode == "grid") {
    _u = grid_u;
    _w = grid_w;
} else {
    var _fixed_current = lerp(fixed_start, 1 - fixed_start, _p);

    if (along_axis == "u") { _u = along_value; _w = _fixed_current; }
    else { _w = along_value; _u = _fixed_current; }
}

var _pt = scr_face_uv_to_point(oAvoidanceController.big_cube_projected, face_index, _u, _w);

var _ext = oAvoidanceController.cube_extend;
x = lerp(oAvoidanceController.cube_center_x, _pt.x, _ext);
y = lerp(oAvoidanceController.cube_center_y, _pt.y, _ext);

var _dist = oAvoidanceController.cube_perspective_dist;
var _size = oAvoidanceController.cube_size;
var _near_scale = _dist / (_dist - _size);
var _far_scale  = _dist / (_dist + _size);

var _depth_t = clamp((_pt.scale - _far_scale) / (_near_scale - _far_scale), 0, 1);
var _depth_eased = power(_depth_t, 1.8);

var _pop = 1;
if (pop_in_timer < pop_in_duration)
{
    pop_in_timer += 1;
    var _pp = pop_in_timer / pop_in_duration;
    _pop = 1 - power(1 - _pp, 3);
}

var _fade_out = 1;
var _fade_window = 8;
if (travel_timer > travel_duration - _fade_window)
{
    _fade_out = clamp((travel_duration - travel_timer) / _fade_window, 0, 1);
}

if (bullet_mode == "grid") {
    var _grid_p = clamp((oAvoidanceController.t - grid_fade_start) /
                        max(1, grid_fade_full - grid_fade_start), 0, 1);
    var _grid_alpha = (oAvoidanceController.t >= grid_fade_full)
                    ? 1
                    : lerp(0, grid_preview_alpha, _grid_p);
    var _grid_depth_p = clamp((_pt.scale - grid_dim_scale) /
                              max(0.001, grid_front_scale - grid_dim_scale), 0, 1);
    var _grid_depth_alpha = lerp(grid_back_alpha, 1, _grid_depth_p);
    var _grid_front_live = _pt.scale >= grid_front_scale;

    image_xscale = _pt.scale * _pop * grid_scale;
    image_yscale = _pt.scale * _pop * grid_scale;
    image_alpha = _grid_alpha * _grid_depth_alpha * _pop * _fade_out;
    hit_active = oAvoidanceController.t >= grid_fade_full &&
                 _grid_front_live && image_alpha > hit_alpha_min &&
                 _pop > 0.7 && _fade_out > 0.4;
} else {
    image_xscale = _pt.scale * _pop;
    image_yscale = _pt.scale * _pop;
    image_alpha = lerp(0.06, 1, _depth_eased) * _pop * _fade_out;
    hit_active = image_alpha > hit_alpha_min && _pop > 0.5 && _fade_out > 0.35;
}

if (travel_timer > 1) {
    image_angle = point_direction(_prev_x, _prev_y, x, y);
}

vel_x = x - _prev_x;
vel_y = y - _prev_y;
speed_now = point_distance(0, 0, vel_x, vel_y);

if (bullet_mode == "grid") {
    vel_x = 0;
    vel_y = 0;
    speed_now = 0;
} else {
    if (image_alpha > 0.05) scr_register_glow_point(x, y);

    array_push(trail, { x : x, y : y });
    if (array_length(trail) > _k_trail_len) array_delete(trail, 0, 1);
}

if (travel_timer >= travel_duration) {
    instance_destroy();
}
