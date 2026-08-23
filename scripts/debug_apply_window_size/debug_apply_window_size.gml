function debug_apply_window_size()
{
    var w = GAME_WIDTH * global.settings[$"scale"];
    var h = GAME_HEIGHT * global.settings[$"scale"];

    if (global.settings[$"fullscreen"])
    {
        window_set_fullscreen(true);
    }
    else
    {
        window_set_size(w, h);
    }

    display_set_gui_size(w, h);
}

///@func scr_apply_game_viewport()
function scr_apply_game_viewport()
{
    application_surface_draw_enable(false);

    var w = GAME_WIDTH * global.settings[$"scale"];
    var h = GAME_HEIGHT * global.settings[$"scale"];

    display_set_gui_size(w, h);
    draw_surface_stretched(application_surface, 0, 0, w, h);
}