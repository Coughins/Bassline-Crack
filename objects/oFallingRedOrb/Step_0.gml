event_inherited();

scr_register_glow_point(x, y);

image_xscale = _size
image_yscale = _size

t++

if speed_up == true {
	if speed < speed_up_max {
		speed += speed_up_amount
	}
}

if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}

var _scale_mult = 1;
if (growing) {
    grow_timer++;
    if (grow_timer <= _k_grow_frames) {
        var _p = grow_timer / _k_grow_frames;
        _scale_mult = lerp(1, _k_grow_overshoot_scale, _p);
    } else if (grow_timer <= _k_grow_frames + _k_grow_settle_frames) {
        var _p2 = (grow_timer - _k_grow_frames) / _k_grow_settle_frames;
        _scale_mult = lerp(_k_grow_overshoot_scale, 1, _p2);
    } else {
        growing = false;
    }
}
if (rain_orb && strike_hold > 0) {
	strike_hold--;
	gravity = 0;
	vspeed = 0;
	speed = 0;
	if (strike_hold <= 0) {
		gravity = strike_grav;
		gravity_direction = 270;
	}
}
else if (rain_orb && strike_squash > 0) {
	strike_squash = max(0, strike_squash - 0.14);
}

if (rain_orb && strike_hold <= 0 && (knock_vx != 0 || knock_vy != 0)) {
	x += knock_vx;
	y += knock_vy;
	knock_vx *= 0.86;
	knock_vy *= 0.86;
	if (abs(knock_vx) < 0.01) knock_vx = 0;
	if (abs(knock_vy) < 0.01) knock_vy = 0;
}

if (rain_orb && strike_squash > 0) {
	image_xscale = _size * _scale_mult * (1 + strike_squash * 0.38);
	image_yscale = _size * _scale_mult * (1 - strike_squash * 0.46);
}
else {
	image_xscale = _size * _scale_mult
	image_yscale = _size * _scale_mult
}

if (rain_orb && spin_rate != 0) {
	image_angle += spin_rate;
	spin_rate *= 0.97;
	if (abs(spin_rate) < 0.02) spin_rate = 0;
}

if (rain_orb && socket_heat > 0) socket_heat = max(0, socket_heat - 0.05);
if (rain_orb && arm_flash > 0) arm_flash = max(0, arm_flash - 0.07);

if (glowing) {
	scr_add_light(x, y, c_red, 1);
}
