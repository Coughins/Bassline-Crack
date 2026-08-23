function scr_honeycomb_release()
{
    rotation_active = true;

    for(var i = 0; i < array_length(cells); i++)
    {
        cells[i].core_alpha = 1;
    }
}