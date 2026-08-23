function debug_register_lasers()
{
	

	array_push(properties,
	{
		category:"LASER",
		name:"Master Gain",
		object:oAvoidanceController,
		variable:"laser_beam_gain",
		min_value:0,
		max_value:2.5,
		step_value:0.01,
		reset_value:1.0
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Halo Width",
		object:oAvoidanceController,
		variable:"laser_beam_w_halo",
		min_value:0,
		max_value:80,
		step_value:0.5,
		reset_value:18
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Core Width",
		object:oAvoidanceController,
		variable:"laser_beam_w_core",
		min_value:0,
		max_value:12,
		step_value:0.05,
		reset_value:2.2
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Glow Width",
		object:oAvoidanceController,
		variable:"laser_beam_w_glow",
		min_value:0,
		max_value:40,
		step_value:0.25,
		reset_value:7
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Bloom Width",
		object:oAvoidanceController,
		variable:"laser_beam_w_bloom",
		min_value:0,
		max_value:160,
		step_value:1,
		reset_value:38
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Halo Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_a_halo",
		min_value:0,
		max_value:1,
		step_value:0.01,
		reset_value:0.2
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Glow Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_a_glow",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.34
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Bloom Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_a_bloom",
		min_value:0,
		max_value:1,
		step_value:0.01,
		reset_value:0.09
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Bead Depth",
		object:oAvoidanceController,
		variable:"laser_beam_bead_depth",
		min_value:0,
		max_value:1,
		step_value:0.01,
		reset_value:0.55
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Bead Freq",
		object:oAvoidanceController,
		variable:"laser_beam_bead_freq",
		min_value:0,
		max_value:12,
		step_value:0.05,
		reset_value:3.0
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Bead Speed",
		object:oAvoidanceController,
		variable:"laser_beam_bead_speed",
		min_value:0,
		max_value:90,
		step_value:0.5,
		reset_value:22
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Helix Amount",
		object:oAvoidanceController,
		variable:"laser_beam_fil_frac",
		min_value:0,
		max_value:2.5,
		step_value:0.01,
		reset_value:0.75
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Helix Turn (px)",
		object:oAvoidanceController,
		variable:"laser_beam_fil_wave",
		min_value:40,
		max_value:600,
		step_value:2,
		reset_value:190
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Helix Width",
		object:oAvoidanceController,
		variable:"laser_beam_fil_w",
		min_value:0,
		max_value:10,
		step_value:0.05,
		reset_value:1.7
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Lead Squash",
		object:oAvoidanceController,
		variable:"laser_beam_lead_squash",
		min_value:0.05,
		max_value:3,
		step_value:0.01,
		reset_value:0.5
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Wake Stretch",
		object:oAvoidanceController,
		variable:"laser_beam_wake_stretch",
		min_value:0.05,
		max_value:8,
		step_value:0.05,
		reset_value:1.7
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Lead Rim Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_rim_a",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.55
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Wake Length",
		object:oAvoidanceController,
		variable:"laser_beam_trail_len",
		min_value:0,
		max_value:40,
		step_value:1,
		reset_value:10
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Blade Wake (deg)",
		object:oAvoidanceController,
		variable:"laser_beam_blade_arc",
		min_value:0,
		max_value:120,
		step_value:1,
		reset_value:26
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Wake Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_trail_a",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.2
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Packet Speed",
		object:oAvoidanceController,
		variable:"laser_beam_packet_speed",
		min_value:0,
		max_value:80,
		step_value:0.5,
		reset_value:26
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Packet Gap",
		object:oAvoidanceController,
		variable:"laser_beam_packet_gap",
		min_value:40,
		max_value:700,
		step_value:2,
		reset_value:240
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Packet Length",
		object:oAvoidanceController,
		variable:"laser_beam_packet_len",
		min_value:0,
		max_value:400,
		step_value:2,
		reset_value:110
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Packet Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_packet_a",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.7
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Scan Tick Alpha",
		object:oAvoidanceController,
		variable:"laser_beam_tick_a",
		min_value:0,
		max_value:1.5,
		step_value:0.01,
		reset_value:0.3
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Chromatic Split",
		object:oAvoidanceController,
		variable:"laser_beam_split",
		min_value:0,
		max_value:16,
		step_value:0.05,
		reset_value:3.0
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Glow Intensity",
		object:oAvoidanceController,
		variable:"laser_glowIntensity",
		min_value:0,
		max_value:3,
		step_value:0.01,
		reset_value:1.0
	});
	
	array_push(properties,
	{
		category:"LASER",
		name:"Glow Radius",
		object:oAvoidanceController,
		variable:"laser_glowRadius",
		min_value:0,
		max_value:120,
		step_value:0.01,
		reset_value:40.0
	});
	array_push(properties,
	{
		category:"LASER",
		name:"Glow Falloff",
		object:oAvoidanceController,
		variable:"laser_glowFalloff",
		min_value:0.1,
		max_value:4,
		step_value:0.01,
		reset_value:1.4
	});
}