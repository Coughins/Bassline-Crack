function debug_register_fx()
{
	var _effects =
	[
		{key:"flash",     label:"Screen Flash"},
		{key:"vignette",  label:"Vignette"},
		{key:"aberration",label:"Chromatic Aberration"},
		{key:"bloom",     label:"Bloom"},
		{key:"tear",      label:"Screen Tear"},
		{key:"ripple",    label:"Ripple Distort"},
		{key:"zoom",      label:"Zoom Punch"},
		{key:"shake",     label:"Screenshake"},
		{key:"tilt",      label:"Tilt Kick"},
		{key:"letterbox", label:"Letterbox"}
	];

	ini_open(CONFIG_FILENAME);

	for (var i = 0; i < array_length(attack_markers); ++i)
	{
		var _atk = attack_markers[i];
		var _has_exclude = variable_struct_exists(_atk, "exclude");

		for (var j = 0; j < array_length(_effects); ++j)
		{
			var _eff = _effects[j];

			if (_has_exclude)
			{
				var _skip = false;
				for (var k = 0; k < array_length(_atk.exclude); ++k)
				{
					if (_atk.exclude[k] == _eff.key)
					{
						_skip = true;
						break;
					}
				}
				if (_skip) continue;
			}

			var _var_name = "fx_" + _atk.key + "_" + _eff.key;
			var _saved_value = ini_read_real(CONFIG_SECTION_FX, _var_name, 1.0);

			variable_instance_set(id, _var_name, _saved_value);

			array_push(properties,
			{
				category:"FX",
				name:_atk.name + " / " + _eff.label,
				object:id,
				variable:_var_name,
				min_value:0,
				max_value:5,
				step_value:0.01,
				reset_value:1.0,
				atk_key:_atk.key,
				effect_key:_eff.key
			});
		}
	}

	var _ring_extra =
	[
		{key:"band",   label:"Ambient / Perimeter Band"},
		{key:"sector", label:"Ambient / Safe Sector"}
	];

	for (var i = 0; i < array_length(_ring_extra); ++i)
	{
		var _eff = _ring_extra[i];
		var _var_name = "fx_arrowring_" + _eff.key;
		var _saved_value = ini_read_real(CONFIG_SECTION_FX, _var_name, 1.0);

		variable_instance_set(id, _var_name, _saved_value);

		array_push(properties,
		{
			category:"FX",
			name:"Arrow Ring / " + _eff.label,
			object:id,
			variable:_var_name,
			min_value:0,
			max_value:3,
			step_value:0.05,
			reset_value:1.0,
			atk_key:"arrowring",
			effect_key:_eff.key
		});
	}

	var _quarter_extra =
	[
		{key:"sweep",   label:"Ambient / Rotor Sweeps"},
		{key:"readout", label:"Ambient / Safe Sector"},
		{key:"rim",     label:"Ambient / Rim Reaction"}
	];

	for (var i = 0; i < array_length(_quarter_extra); ++i)
	{
		var _eff = _quarter_extra[i];
		var _var_name = "fx_quartercircles_" + _eff.key;
		var _saved_value = ini_read_real(CONFIG_SECTION_FX, _var_name, 1.0);

		variable_instance_set(id, _var_name, _saved_value);

		array_push(properties,
		{
			category:"FX",
			name:"Quarter Circles / " + _eff.label,
			object:id,
			variable:_var_name,
			min_value:0,
			max_value:3,
			step_value:0.05,
			reset_value:1.0,
			atk_key:"quartercircles",
			effect_key:_eff.key
		});
	}


	var _lorb_extra =
	[
		{key:"front",   label:"Ambient / Storm Front"},
		{key:"readout", label:"Ambient / Column Readout"},
		{key:"floor",   label:"Ambient / Floor Damage"}
	];

	for (var i = 0; i < array_length(_lorb_extra); ++i)
	{
		var _eff = _lorb_extra[i];
		var _var_name = "fx_lightningorbs_" + _eff.key;
		var _saved_value = ini_read_real(CONFIG_SECTION_FX, _var_name, 1.0);

		variable_instance_set(id, _var_name, _saved_value);

		array_push(properties,
		{
			category:"FX",
			name:"Lightning Orbs / " + _eff.label,
			object:id,
			variable:_var_name,
			min_value:0,
			max_value:3,
			step_value:0.05,
			reset_value:1.0,
			atk_key:"lightningorbs",
			effect_key:_eff.key
		});
	}

	ini_close();
}
