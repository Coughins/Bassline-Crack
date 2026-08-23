bg_timer += 1;
if (bg_timer >= bg_trigger_interval)
{
    bg_timer = 0;

    if (test_rings) {
        array_push(bg_rings, [0, 1.0]);
    }
    if (test_bloom) {
        scr_impact_pulse(0.15, 0, 1.4);
    }
    if (test_ripple && instance_exists(oAvoidanceController)) {
        oAvoidanceController.global_ripple_pulse = 0.7;
    }
}

for (var i = array_length(bg_rings) - 1; i >= 0; i--)
{
    bg_rings[i][0] += 8;
    bg_rings[i][1] -= 0.02;
    if (bg_rings[i][1] <= 0) array_delete(bg_rings, i, 1);
}