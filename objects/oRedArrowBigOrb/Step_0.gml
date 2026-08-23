event_inherited();

scr_register_glow_point(x, y);

arrow_birth = max(0, arrow_birth - 0.08);

image_angle = direction + dsin(current_time * 0.004 + arrow_spin * 90) * 6 * arrow_spin;

if (
    x < -room_width ||
    x > room_width * 2 ||
    y < -room_height ||
    y > room_height * 2
)
{
    instance_destroy();
}
