function scr_honeycomb_activate_walls()
{
    for(var i = 0; i < array_length(cells); i++)
    {
        cells[i].active = true;
        cells[i].wall_alpha = 1;
    }
}