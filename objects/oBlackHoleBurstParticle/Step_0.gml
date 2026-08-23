prev_x = x;
prev_y = y;

speed *= 0.9;
life -= 1;
if (life <= 0) instance_destroy();
