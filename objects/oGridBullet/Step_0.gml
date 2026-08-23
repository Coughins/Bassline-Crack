if (!grid_spawned)
{
    grid_spawn_timer++;
    if (grid_spawn_timer >= grid_spawn_delay)
    {
        grid_spawned = true;
        visible = true;
        image_alpha = 0.1;
    }
    else
    {
        exit;
    }
}

grid_lightning_flash = 0;

if (maze_lightning_target != noone)
{
    maze_lightning_life -= 1;
    if (maze_lightning_life <= 0 || !instance_exists(maze_lightning_target))
    {
        maze_lightning_target = noone;
    }
    else if (!instance_exists(oGameover) &&
             player_meeting_line_width(x, y, maze_lightning_target.x, maze_lightning_target.y, 11))
    {
        player_register_hazard_hit();
    }
}

if (grid_activated && !pop_active)
{
    pop_active = true;
    pop_timer = 0;

    image_alpha = 1;
    image_xscale = 2.5;
    image_yscale = 2.5;

    scr_impact_pulse(
        0.15,
        1.0,
        0.1
    );
}

if (pop_active)
{
    pop_timer += 1;

    var _pop_progress = pop_timer / 15;
    image_xscale = lerp(2.5, 0, _pop_progress);
    image_yscale = lerp(2.5, 0, _pop_progress);
    image_alpha = lerp(1, 0, _pop_progress);

    if (pop_timer >= 15)
    {
        instance_destroy();
    }
}

lightning_apply_sprite();
