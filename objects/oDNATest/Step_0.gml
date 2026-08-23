event_inherited();
if (dna_mode) 
{
	if (spawn_scale < 1)
	{
		if (spawn_timer > 0)
		{
			spawn_timer--;
		}
		else
		{
			spawn_scale = 1;
		}
	}
}
if chain_target != noone {
	chain_timer -= 1;
	if chain_timer <= 0 {
		if (chain_is_rung) {
			with (chain_target) scr_dna_chain_activate_rung();
		} else {
			with (chain_target) scr_dna_chain_activate();
		}
		chain_target = noone;
	}
}

if (state == "struck") {
	hit_timer += 1;

	var _struck_duration = 10;
	var _t = clamp(hit_timer / _struck_duration, 0, 1);

	var _scale = lerp (4.0, spawn_scale, _t);
	image_xscale = _scale;
	image_yscale = _scale;

	strike_flash = 1 - power(_t, 0.55);

	if (_t >= 1) {
		state = "idle";
		strike_flash = 0;
	}

} else if (strike_flash > 0) {
	strike_flash = max(0, strike_flash - 0.08);
}




if (!dna_mode)
{
    hit_active = false;
    exit;
}

if (oAvoidanceController.dna_despawn_active && !despawning) {
    if (y >= oAvoidanceController.dna_despawn_sweep_y) {
        despawning = true;
        despawn_timer = 0;
    }
}

if (despawning) {
    hit_active = false;
    despawn_timer++;
    var _k_despawn_pop_frames = 10;
    var _prog = clamp(despawn_timer / _k_despawn_pop_frames, 0, 1);
    image_alpha = 1 - _prog;
    image_xscale = lerp(1, 1.6, _prog);
    image_yscale = image_xscale;
	
	if (despawn_timer >= _k_despawn_pop_frames) {
	    with (oDNATest) {
	        if (chain_target == other.id) chain_target = noone;
	    }
	    instance_destroy();
	}

    if (despawn_timer >= _k_despawn_pop_frames) instance_destroy();
}
