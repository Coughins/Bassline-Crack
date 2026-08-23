fade = min(fade + 1/60,1);


previous_angle = angle;

var acceleration =
-(gravity / rod_length) * sin(angle);

angular_velocity += acceleration;

angular_velocity *= damping;

angle += angular_velocity;


var ball_x = origin_x + rod_length * sin(angle) * cos(tilt_angle);
var ball_y = origin_y + rod_length * cos(angle);
var ball_z = rod_length * sin(angle) * sin(tilt_angle);


if (instance_exists(weight))
{
    weight.x = ball_x;
    weight.y = ball_y;
    weight.target_visual_z = ball_z;
    weight.image_alpha = fade;
}




if (
t == 3668 ||
t == 3709 ||
t == 3751 ||
t == 3790 ||
t == 3832 ||
t == 3852 ||
t == 3872 ||
t == 3892)
{
    angular_velocity += sign(angular_velocity) * 0.010;
}

t++;
