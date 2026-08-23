function scr_dna_chain_activate_rung(){
    if (active) exit;

    active = true;
    lightning_hit = true;
    state = "struck";
    hit_timer = 0;
    image_xscale = 1.5;
    image_yscale = 1.5;
    image_alpha = 1;
    chain_is_rung = true;

    scr_impact_pulse(0.4, 3.0, 0.3);

    var _next = noone;
    var _next_pos = rung_position + rung_dir;
    var _my_dir = rung_dir;

    if (_next_pos >= 0 && _next_pos < rung_bullets) {
        var _structs = oAvoidanceController.dna_structures;
        var _arr     = _structs[struct_id].array;
        var _ri = oAvoidanceController.dna_amount * 2
                  + floor(rung_id / dna_rung_spacing) * rung_bullets + _next_pos;
        if (_ri >= 0 && _ri < array_length(_arr)) {
            var _cand = _arr[_ri];
            if (instance_exists(_cand)) _next = _cand;
        }
    }

    if (_next != noone) {
        _next.rung_claimed = true;
        _next.rung_dir = _my_dir;
        chain_target = _next;
        line_target_x = _next.x;
        line_target_y = _next.y;
        line_life = line_life_max;
        chain_timer = chain_delay;
    }
    else {
        chain_target = noone;
		oAvoidanceController.active_dna_rung_chains--;
    }
}
