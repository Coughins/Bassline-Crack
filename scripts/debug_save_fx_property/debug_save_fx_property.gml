function debug_save_fx_property(_p)
{
	var _section = "";
	if (_p.category == "FX") { _section = CONFIG_SECTION_FX; }
	if (_p.category == "KUNAI") { _section = CONFIG_SECTION_KUNAI; }
	if (_p.category == "LASER") { _section = CONFIG_SECTION_LASER; }
	if (_section == "") exit;

	var _target_instance = _p.object;
	if (is_real(_target_instance) && object_exists(_target_instance))
	{
		_target_instance = instance_find(_target_instance, 0);
	}
	if (!instance_exists(_target_instance)) exit;

	var _value = variable_instance_get(_target_instance, _p.variable);

	ini_open(CONFIG_FILENAME);
	ini_write_real(_section, _p.variable, _value);
	ini_close();
}
