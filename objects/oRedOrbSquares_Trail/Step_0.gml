event_inherited();
scr_register_glow_point(x, y);
trail_life--;
image_xscale -= trail_shrink_speed;
image_yscale -= trail_shrink_speed;
 
if (trail_life <= 0 || image_xscale <= 0.05 || image_yscale <= 0.05)
{
    instance_destroy();
}

scr_add_light(x, y, light_color, 0.8);
