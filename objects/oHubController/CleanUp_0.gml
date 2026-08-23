if (variable_instance_exists(id, "hub_collision_blocks")) {
    for (var i = array_length(hub_collision_blocks) - 1; i >= 0; i--) {
        var _block = hub_collision_blocks[i];
        if (instance_exists(_block)) {
            instance_destroy(_block);
        }
    }
}

if (variable_instance_exists(id, "hub_scene_surface") && surface_exists(hub_scene_surface)) {
    surface_free(hub_scene_surface);
}

if (variable_instance_exists(id, "hub_glow_surface") && surface_exists(hub_glow_surface)) {
    surface_free(hub_glow_surface);
}
