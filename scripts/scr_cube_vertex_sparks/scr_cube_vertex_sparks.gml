function scr_cube_vertex_sparks(){
	var _k_burst_per_vertex = 4;
	var _k_sparks_per_vertex = 7;

	if (array_length(big_cube_projected) < 8) return;

	for (var i = 0; i < 8; i++)
	{
	    var _v = big_cube_projected[i];

	    for (var s = 0; s < _k_burst_per_vertex; s++)
	    {
	        var _dir = random(360);
	        var _p = instance_create_layer(_v.x, _v.y, layer, oBlackHoleBurstParticle);
	        _p.direction = _dir;
	        _p.speed = random_range(2, 5);
	    }

	    for (var s = 0; s < _k_sparks_per_vertex; s++)
	    {
	        var _sa = random(360);
	        var _ss = random_range(2, 7);
	        array_push(arrow_ring_particles, {
	            x : _v.x, y : _v.y,
	            vx : lengthdir_x(_ss, _sa), vy : lengthdir_y(_ss, _sa),
	            life : 18 + irandom(12), max_life : 30,
	            size : random_range(0.08, 0.22), grav : 0.05, drag : 0.94, hot : 1
	        });
	    }

	    array_push(ring_shockwaves, {
	        x : _v.x, y : _v.y, radius : 4, max_radius : 62,
	        life : 14, max_life : 14, width : 7, hot : 1, vs : 1
	    });

	    cube_vertex_heat[i] = max(cube_vertex_heat[i], 1.2);
	}

	cube_edge_surge = max(cube_edge_surge, 1.0);
	cube_core_flash = max(cube_core_flash, 0.9);
	cube_heartbeat = max(cube_heartbeat, 0.9);

	if (instance_exists(oCameraController)) {
	    oCameraController.shake = max(oCameraController.shake, 10);
	    oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.05);
	}
	scr_impact_pulse(0.35, 3.0, 0.6, cube_center_x, cube_center_y);
}
