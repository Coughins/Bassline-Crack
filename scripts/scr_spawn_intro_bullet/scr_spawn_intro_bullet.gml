function scr_spawn_intro_bullet(_cx, _cy, _angle, _radius, _target_array, _reveal_delay, _shape_id, _trace_order, _trace_group) {
    var _px = _cx + lengthdir_x(_radius, _angle);
    var _py = _cy + lengthdir_y(_radius, _angle);

    var _b = instance_create_layer(_cx, _cy, layer, oRedBulletIntro);
    _b.intro_cx = _cx;
    _b.intro_cy = _cy;
    _b.intro_angle = _angle;
    _b.intro_radius = _radius;
    _b.x = _px;
    _b.y = _py;
    _b.reveal_delay = _reveal_delay;
    _b.shape_id = _shape_id;
    _b.trace_order = _trace_order;
    _b.trace_group = _trace_group;

    array_push(_target_array, _b);
    return _b;
}