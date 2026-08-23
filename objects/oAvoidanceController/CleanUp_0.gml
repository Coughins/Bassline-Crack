ring_streaks = [];

riser = undefined;

// else owns it, so it has to be released with the controller.
if (surface_exists(final_cut_surface)) surface_free(final_cut_surface);
final_cut_surface = -1;
