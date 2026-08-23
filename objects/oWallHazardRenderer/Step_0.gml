noise_timer += 0.05;

left_points = [];

with (oWave)
{
    if (origin_side == 0)
    {
        array_push(other.left_points,
        {
            x : x,
            y : y,
            h : hsp
        });
    }
}

right_points = [];

with (oWave)
{
    if (origin_side == 1)
    {
        array_push(other.right_points,
        {
            x : x,
            y : y,
            h : hsp
        });
    }
}