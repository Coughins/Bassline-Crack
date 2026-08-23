event_inherited();
time++

if (explode_timer > 0)
{
    explode_timer--;

    if (explode_timer == 0)
    {
        explode = 1;
    }
}

if explode == 1 {
	charging = false;
	beam_live = true;
	charge_flare = 1;
	image_xscale = beam_strike_scale
	image_alpha = 1
	explode = 0
	get_smaller = 1

}
if get_smaller == 1 {
	image_xscale -= beam_shrink_step

	if image_xscale <= 0 {
		instance_destroy()
		exit
	}
}

if (instance_exists(source_arrow) && (charging || get_smaller == 1 || charge_flare > 0))
{
    beam_start_x = source_arrow.x + source_arrow.arrow_vibe_x;
    beam_start_y = source_arrow.y + source_arrow.arrow_vibe_y;
}

if (charging)
{
    beam_live = false;

    charge_timer++;
    var _p = clamp(charge_timer / max(charge_duration, 1), 0, 1);

    image_xscale = lerp(0.24, 0.08, _p * _p);
    image_alpha = 0.68 + _p * 0.32;

    scr_register_glow_point(beam_start_x, beam_start_y);
}

var _ux = lengthdir_x(1, beam_dir);
var _uy = lengthdir_y(1, beam_dir);
var _ray_len = beam_len_max;
var _bound_l = -beam_room_pad;
var _bound_r = room_width + beam_room_pad;
var _bound_t = -beam_room_pad;
var _bound_b = room_height + beam_room_pad;

if (instance_exists(oCameraController))
{
    if (oCameraController.current_cam_w > 1 && oCameraController.current_cam_h > 1)
    {
        _bound_l = oCameraController.current_cam_x - beam_room_pad;
        _bound_r = oCameraController.current_cam_x + oCameraController.current_cam_w + beam_room_pad;
        _bound_t = oCameraController.current_cam_y - beam_room_pad;
        _bound_b = oCameraController.current_cam_y + oCameraController.current_cam_h + beam_room_pad;
    }
}

if (_ux > 0.0001) {
    _ray_len = min(_ray_len, (_bound_r - beam_start_x) / _ux);
} else if (_ux < -0.0001) {
    _ray_len = min(_ray_len, (_bound_l - beam_start_x) / _ux);
}

if (_uy > 0.0001) {
    _ray_len = min(_ray_len, (_bound_b - beam_start_y) / _uy);
} else if (_uy < -0.0001) {
    _ray_len = min(_ray_len, (_bound_t - beam_start_y) / _uy);
}

beam_len = max(1, _ray_len);
beam_end_x = beam_start_x + _ux * beam_len;
beam_end_y = beam_start_y + _uy * beam_len;

x = beam_start_x + _ux * beam_len * 0.5;
y = beam_start_y + _uy * beam_len * 0.5;
image_angle = beam_dir - 90;
image_yscale = beam_len / max(1, sprite_get_height(sprite_index));

beam_hit_half_width = min(beam_hit_half_width_max, max(1.5, image_xscale * 4));

if (beam_live && !already_hit_player && instance_exists(oPlayer) && image_alpha > hit_alpha_min)
{
    var _px = lengthdir_x(1, beam_dir + 90);
    var _py = lengthdir_y(1, beam_dir + 90);
    var _hw = beam_hit_half_width;

    var _bcx1 = beam_start_x + _px * _hw;
    var _bcy1 = beam_start_y + _py * _hw;
    var _bcx2 = beam_start_x - _px * _hw;
    var _bcy2 = beam_start_y - _py * _hw;
    var _bcx3 = beam_end_x - _px * _hw;
    var _bcy3 = beam_end_y - _py * _hw;
    var _bcx4 = beam_end_x + _px * _hw;
    var _bcy4 = beam_end_y + _py * _hw;

    var _bminx = min(min(_bcx1, _bcx2), min(_bcx3, _bcx4));
    var _bmaxx = max(max(_bcx1, _bcx2), max(_bcx3, _bcx4));
    var _bminy = min(min(_bcy1, _bcy2), min(_bcy3, _bcy4));
    var _bmaxy = max(max(_bcy1, _bcy2), max(_bcy3, _bcy4));

    var _hit = !(_bmaxx < oPlayer.bbox_left || _bminx > oPlayer.bbox_right ||
                 _bmaxy < oPlayer.bbox_top  || _bminy > oPlayer.bbox_bottom);

    if (_hit)
    {
        var _p1 = (oPlayer.bbox_left  - beam_start_x) * _ux + (oPlayer.bbox_top    - beam_start_y) * _uy;
        var _p2 = (oPlayer.bbox_right - beam_start_x) * _ux + (oPlayer.bbox_top    - beam_start_y) * _uy;
        var _p3 = (oPlayer.bbox_right - beam_start_x) * _ux + (oPlayer.bbox_bottom - beam_start_y) * _uy;
        var _p4 = (oPlayer.bbox_left  - beam_start_x) * _ux + (oPlayer.bbox_bottom - beam_start_y) * _uy;
        var _pmin = min(min(_p1, _p2), min(_p3, _p4));
        var _pmax = max(max(_p1, _p2), max(_p3, _p4));

        _hit = !(_pmax < 0 || _pmin > beam_len);
    }

    if (_hit)
    {
        var _q1 = (oPlayer.bbox_left  - beam_start_x) * _px + (oPlayer.bbox_top    - beam_start_y) * _py;
        var _q2 = (oPlayer.bbox_right - beam_start_x) * _px + (oPlayer.bbox_top    - beam_start_y) * _py;
        var _q3 = (oPlayer.bbox_right - beam_start_x) * _px + (oPlayer.bbox_bottom - beam_start_y) * _py;
        var _q4 = (oPlayer.bbox_left  - beam_start_x) * _px + (oPlayer.bbox_bottom - beam_start_y) * _py;
        var _qmin = min(min(_q1, _q2), min(_q3, _q4));
        var _qmax = max(max(_q1, _q2), max(_q3, _q4));

        _hit = !(_qmax < -_hw || _qmin > _hw);
    }

    if (_hit && player_register_hazard_hit()) already_hit_player = true;
}

charge_flare = max(0, charge_flare - 0.12);
