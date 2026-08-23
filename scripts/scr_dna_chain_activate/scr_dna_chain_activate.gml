function scr_dna_chain_activate(){
    if (active) exit;

    active = true;
    lightning_hit = true;
    state = "struck";
    hit_timer = 0;
    image_xscale = 1.5;
    image_yscale = 1.5;
    image_alpha = 1;
    chain_is_rung = false;

    scr_impact_pulse(0.4, 3.0, 0.3);

    var _structs   = oAvoidanceController.dna_structures;
    var _arr       = _structs[struct_id].array;
    var _arr_n     = array_length(_arr);
    var _dna_count = oAvoidanceController.dna_amount;

    var _next = noone;
    var _next_index = dna_index + (chain_dir * chain_step);
    var _my_dir = chain_dir;

    if (_next_index >= 0 && _next_index < _dna_count) {
        var _cand = _arr[_next_index + ((strand == 0) ? 0 : _dna_count)];
        if (instance_exists(_cand) && !_cand.active) _next = _cand;
    }

    if (_next != noone) {
        _next.chain_dir = _my_dir;
        chain_target = _next;
        line_target_x = _next.x;
        line_target_y = _next.y;
        line_life = line_life_max;
        chain_timer = chain_delay;
    }
    else {
        chain_target = noone;
    }

    if (dna_type == 0 && (dna_index mod dna_rung_spacing == 0)) {
        var _rung_id = dna_index;
        var _start_pos = (strand == 0) ? 0 : (rung_bullets - 1);
        var _dir = (strand == 0) ? 1 : -1;

        var _first_rung = noone;
        var _ri = _dna_count * 2 + floor(_rung_id / dna_rung_spacing) * rung_bullets + _start_pos;
        if (_ri >= 0 && _ri < _arr_n) {
            var _rc = _arr[_ri];
            if (instance_exists(_rc)) _first_rung = _rc;
        }

		if (_first_rung != noone && !_first_rung.rung_claimed) {
		    if (oAvoidanceController.active_dna_rung_chains < oAvoidanceController.k_max_concurrent_rung_chains) {
		        _first_rung.rung_claimed = true;
		        _first_rung.rung_dir = _dir;
		        oAvoidanceController.active_dna_rung_chains++;
		        with (_first_rung) scr_dna_chain_activate_rung();
		    } else {
		        _first_rung.rung_claimed = true;
		        array_push(oAvoidanceController.dna_rung_queue, { inst: _first_rung, dir: _dir });
		    }
		}
    }
}
