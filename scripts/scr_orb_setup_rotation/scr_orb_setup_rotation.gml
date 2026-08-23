function scr_orb_setup_rotation(_cx, _cy) {
    shape_cx = _cx;
    shape_cy = _cy;
    base_radius = point_distance(shape_cx, shape_cy, x, y);
    base_angle  = point_direction(shape_cx, shape_cy, x, y);
    rotation_timer = 0;
    image_alpha = 0.1;
    hit_active = false;
    use_rotation = true;
    chain_eligible = true;
}
