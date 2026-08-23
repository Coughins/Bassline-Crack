origin_x = room_width * 0.5;
origin_y = -250;

rod_length = 700;
rod_count = 35;

tilt_angle = pi / 4;

angle = choose(degtorad(-55), degtorad(55));
angular_velocity = 0;

gravity = 0.3;
damping = 0.9985;

fade = 0;

previous_angle = angle;

weight = instance_create_layer(0, 0, "Instances", oPendulumWeight);

t = 0
