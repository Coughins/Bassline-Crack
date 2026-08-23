function debug_register_kunai()
{
	array_push(properties,
	{
		category:"KUNAI",
		name:"Trail Alpha",
		object:oAvoidanceController,
		variable:"kdash_trail_alpha",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.65
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Hot Core Alpha",
		object:oAvoidanceController,
		variable:"kdash_hotcore_alpha",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.55
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Rift Wash Intensity",
		object:oAvoidanceController,
		variable:"kdash_rift_wash_intensity",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.42
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Rift Mouth Intensity",
		object:oAvoidanceController,
		variable:"kdash_rift_mouth_intensity",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:0.85
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Blade Glow Min",
		object:oAvoidanceController,
		variable:"kdash_blade_glow_min",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.5
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Blade Glow Max",
		object:oAvoidanceController,
		variable:"kdash_blade_glow_max",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:1.75
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Strike Bloom Base",
		object:oAvoidanceController,
		variable:"kdash_strike_bloom_base",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.55
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Strike Bloom Scale",
		object:oAvoidanceController,
		variable:"kdash_strike_bloom_scale",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.6
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Telegraph Bloom Alpha",
		object:oAvoidanceController,
		variable:"kdash_telegraph_bloom_alpha",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.35
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Telegraph Band Alpha",
		object:oAvoidanceController,
		variable:"kdash_telegraph_band_alpha",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.55
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Strike Flash Mult",
		object:oAvoidanceController,
		variable:"kdash_strike_flash_mult",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:1.0
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Chroma Fringe Mult",
		object:oAvoidanceController,
		variable:"kdash_chroma_fringe_mult",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:1.0
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Body Hot Blend",
		object:oAvoidanceController,
		variable:"kdash_body_hot_blend",
		min_value:0,
		max_value:1,
		step_value:0.01,
		reset_value:0.55
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Body Alpha Mult",
		object:oAvoidanceController,
		variable:"kdash_body_alpha_mult",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:1.0
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Ghost Glow Intensity",
		object:oAvoidanceController,
		variable:"kdash_ghost_glow_intensity",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:1.1
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Slash Glow Intensity",
		object:oAvoidanceController,
		variable:"kdash_slash_glow_intensity",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:1.3
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Crater Glow Mult",
		object:oAvoidanceController,
		variable:"kdash_crater_glow_mult",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:1.0
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Shard Glow Intensity",
		object:oAvoidanceController,
		variable:"kdash_shard_glow_intensity",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.85
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Big Kunai Screen Tear",
		object:oAvoidanceController,
		variable:"big_kunai_note_tear_mult",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:1.0
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Burst Flash Mult",
		object:oAvoidanceController,
		variable:"kunai_burst_flash_mult",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.65
	});

	array_push(properties,
	{
		category:"KUNAI",
		name:"Edge Wave Mult",
		object:oAvoidanceController,
		variable:"kunai_edge_wave_mult",
		min_value:0,
		max_value:2,
		step_value:0.01,
		reset_value:0.65
	});
}
