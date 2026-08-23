shake = 0;
cam = view_camera[0];
screen_flash_alpha = 0;
cam_offset_x = 0;
cam_kick_active = false;
cam_kick_timer = 0;
cam_kick_pull_time = 10;
cam_kick_return_time = 25;
cam_kick_pull_distance = -40;

zoom = 1;
zoom_kick_active = false;
zoom_kick_timer = 0;
zoom_kick_pull_time = 0;
zoom_kick_return_time = 10;
zoom_kick_amount = 0.98;

base_view_w = camera_get_view_width(cam);
base_view_h = camera_get_view_height(cam);

cube_zoom_out_active = false;
cube_zoom_out_timer = 0;
cube_zoom_out_duration = 90;
cube_zoom_target = 1.4;
cube_zoom_out_holding = false;
slash_zoom_active = false;
slash_zoom_phase = "out";
slash_zoom_timer = 0;
slash_zoom_from = 1;
slash_zoom_to = 1;
_k_slash_zoom_target = 1.8;
_k_slash_zoom_out_duration = 100;
_k_slash_zoom_in_duration = 12;

current_cam_x = 0
current_cam_y = 0
current_cam_h = 0
current_cam_w = 0

final_zoom_engaged = false;
final_zoom_active = false;
final_zoom_timer = 0;
final_zoom_from = 1;
final_zoom_to = 1;
final_zoom_len = 15;
final_zoom_step_index = 0;

current_cam_angle = 0;
final_angle_from = 0;
final_angle_target = 0;

_k_final_zoom_steps   = [7124, 7144, 7163, 7186, 7207];
_k_final_zoom_targets = [1.15, 1.02, 0.92, 0.80, 0.56];
_k_final_zoom_durations = [10, 10, 10, 12, 84];
_k_final_cam_angles = [3.5, -4, 5.5, -6.5, -2.5];

final_focus_mix = 1;

_k_intro_zoom_start = 0.55;
_k_intro_tilt_start = -3;

zoom_punch = 0;

angle_kick = 0;
_k_angle_kick_decay = 0.16;

letterbox_amount = 0;
letterbox_target = 0;