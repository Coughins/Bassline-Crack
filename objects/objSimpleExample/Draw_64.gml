bktglitch_activate();

bktglitch_config_preset(BktGlitchPreset.B);

bktglitch_set_jumbleness(0.5);
bktglitch_set_jumble_speed(2.5);
bktglitch_set_jumble_resolution(random_range(0.2, 0.4));
bktglitch_set_jumble_shift(random_range(0.2, 0.4));
bktglitch_set_channel_shift(0.01);
bktglitch_set_channel_dispersion(.05);

bktglitch_set_intensity(0.025 + bounceIntensity);

draw_surface(application_surface, 0, 0);

bktglitch_deactivate();