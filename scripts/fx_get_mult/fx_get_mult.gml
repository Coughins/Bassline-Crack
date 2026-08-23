function fx_get_mult_for(_attack_key, _effect_key)
{
    if (!instance_exists(oDebugController)) return 1;

    var _var_name = "fx_" + _attack_key + "_" + _effect_key;
    if (!variable_instance_exists(oDebugController, _var_name)) return 1;
    return variable_instance_get(oDebugController, _var_name);
}

function fx_get_current_attack_key()
{
    if (!instance_exists(oDebugController)) return "";
    if (!instance_exists(oAvoidanceController)) return "";

    var _t = oAvoidanceController.t;
    var _markers = oDebugController.attack_markers;
    var _count = array_length(_markers);
    if (_count == 0) return "";

    var _atk_key = _markers[0].key;
    for (var i = 1; i < _count; i++)
    {
        if (_markers[i].t > _t) break;
        _atk_key = _markers[i].key;
    }

    return _atk_key;
}

function fx_get_mult(_effect_key)
{
    var _atk_key = fx_get_current_attack_key();
    if (_atk_key == "") return 1;
    return fx_get_mult_for(_atk_key, _effect_key);
}

function fx_get_effect_raw(_effect_key)
{
    if (!instance_exists(oCameraController)) return 0;

    switch (_effect_key)
    {
        case "flash":     return oCameraController.screen_flash_alpha;
        case "zoom":      return oCameraController.zoom_punch;
        case "shake":     return oCameraController.shake;
        case "tilt":      return abs(oCameraController.angle_kick);
        case "letterbox": return oCameraController.letterbox_amount;
    }

    if (!instance_exists(oAvoidanceController)) return 0;

    switch (_effect_key)
    {
        case "vignette":   return oAvoidanceController.vignette_pulse;
        case "aberration": return oAvoidanceController.aberration_pulse;
        case "bloom":      return oAvoidanceController.bloom_pulse;
        case "tear":       return oAvoidanceController.tear_amount;
        case "ripple":     return oAvoidanceController.global_ripple_pulse;
    }

    return 0;
}

function fx_is_row_active(_attack_key, _effect_key)
{
    if (fx_get_current_attack_key() != _attack_key) return false;
    return fx_get_effect_raw(_effect_key) > 0.01;
}
