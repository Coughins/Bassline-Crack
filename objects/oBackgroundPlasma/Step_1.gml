var _cam = view_camera[0];
_view_x = camera_get_view_x(_cam);
_view_y = camera_get_view_y(_cam);
_view_w = camera_get_view_width(_cam);
_view_h = camera_get_view_height(_cam);

glow_point_count = 0;
for (var i = 0; i < _k_max_glow_points; i++) {
    glow_points[i*2]     = -10;
    glow_points[i*2 + 1] = -10;
}