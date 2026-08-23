var pendulum_force = oPendulumController.angular_velocity * 2;

sphere_spin_velocity += pendulum_force;

sphere_spin_velocity = clamp(sphere_spin_velocity, -0.1, 0.1);

sphere_spin_angle += sphere_spin_velocity;
sphere_spin_angle += 0.0001;

sphere_spin_velocity *= 0.9;


sphere_rotation += 0.0011;
sphere_vertical_rotation += 0.00103;


sphere_wobble += 0.05;
trail_timer++;

if (trail_timer >= 3)
{
    trail_timer = 0;

    array_insert(
        trail,
        0,
        {
            _x: x,
            _y: y
        }
    );


    if (array_length(trail) > trail_length)
    {
        array_pop(trail);
    }
}

visual_x = lerp(visual_x, x, 0.2);
visual_y = lerp(visual_y, y, 0.2);
visual_z = lerp(visual_z, target_visual_z, 0.2);
