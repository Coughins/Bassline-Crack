function scr_draw_lightning_bolt(_target_x, _target_y, _life, _life_max, _segments, _branch, _color = global.lightning_color, _double_strike_chance = 0.08, _jitter_amount = 8, _bolt_id = "", _settle_frames = 3, _manage_blend = true)
{
	var _k_bleed_width   = 30;
	var _k_outer_width   = 7;
	var _k_mid_width     = 1.5;
	var _k_core_width    = 0.9;
	var _k_taper_curve   = 2.3;
	var _k_tip_width     = 0.15;
	var _k_color_drift   = 0.1;
	var _k_shake_mult    = 0.6;
	var _k_taper_aggression = 2;
	
    if (_life <= 0) return;

    oAvoidanceController.lightning_bloom_boost += (_life / _life_max) * 0.6;

    var _is_spawn_frame = (_life >= _life_max - 1);
    var _capture_imprint = _is_spawn_frame;
    var _imprint_points = [];

    if (_is_spawn_frame && instance_exists(oCameraController)) {
        var _shake_amt = clamp(_segments * _k_shake_mult, 1, 10);
        oCameraController.shake = max(oCameraController.shake, _shake_amt);
    }

    var _snap_var = "_bolt_snap_" + _bolt_id;
    var _in_settle = (_life_max - _life) < _settle_frames;

    if (_is_spawn_frame) {
        var _frozen = array_create(_segments, 0);
        for (var fs = 0; fs < _segments; fs++) {
            _frozen[fs] = random_range(-_jitter_amount, _jitter_amount);
        }
        variable_instance_set(id, _snap_var, _frozen);
    }

    var _alpha = _life / _life_max;
    var _pulse = 1.0 + sin(current_time * 0.15 + x * 0.1) * 0.35;
    var _perp_dir = point_direction(x, y, _target_x, _target_y) + 90;
    var _dx = (_target_x - x) / _segments;
    var _dy = (_target_y - y) / _segments;
    if (_manage_blend) gpu_set_blendmode(bm_add);
    var _do_double = (random(1) < _double_strike_chance);
    for (var pass = 0; pass < (_do_double ? 2 : 1); pass++) {
        var _pass_alpha_mult = (pass == 0) ? 1 : 0.35;
        var _pass_offset = (pass == 0) ? 0 : random_range(-4, 4);
        var _px = x, _py = y;
        if (pass == 0 && _capture_imprint) array_push(_imprint_points, { ix: _px, iy: _py, w: 1 });

        for (var s = 1; s <= _segments; s++) {
    var _tx = x + _dx * s;
    var _ty = y + _dy * s;
    if (s < _segments) {
        var _j;
        if (_in_settle && pass == 0 && variable_instance_exists(id, _snap_var)) {
            var _frozen_arr = variable_instance_get(id, _snap_var);
            _j = _frozen_arr[s - 1] + _pass_offset;
        } else {
            _j = random_range(-_jitter_amount, _jitter_amount) + _pass_offset;
        }
        _tx += lengthdir_x(_j, _perp_dir);
        _ty += lengthdir_y(_j, _perp_dir);
    }
    var _taper = lerp(_k_taper_curve, 0.8, s / _segments);

    var _seg_t = s / _segments;
    var _end_taper = (s == 1 || s == _segments) ? _k_tip_width : power(lerp(0.5, 1, 1 - abs(_seg_t - 0.5) * 2), _k_taper_aggression);
    _end_taper = clamp(_end_taper, 0.15, 1);

    var _seg_color = scr_lightning_color_drift(_color, _k_color_drift);

    draw_set_color(_seg_color);
    draw_set_alpha(_alpha * 0.12 * _pass_alpha_mult);
    draw_line_width(_px, _py, _tx, _ty, _k_bleed_width * _pulse * _taper * _end_taper);

    draw_set_alpha(_alpha * 0.4 * _pass_alpha_mult);
    draw_line_width(_px, _py, _tx, _ty, _k_outer_width * _pulse * _taper * _end_taper);
    draw_set_alpha(_alpha * _pass_alpha_mult);
    draw_line_width(_px, _py, _tx, _ty, _k_mid_width * _pulse * _taper * _end_taper);

    draw_set_color(merge_color(_seg_color, c_white, 0.35));
    draw_set_alpha(_alpha * 0.8 * _pass_alpha_mult);
    draw_line_width(_px, _py, _tx, _ty, _k_core_width * _pulse * _taper * _end_taper);

    if (_branch && s mod 2 == 0) {
        scr_draw_lightning_branch(_tx, _ty, _perp_dir, _pulse, _alpha * _pass_alpha_mult, _color, 1);
    }

    if (pass == 0 && _capture_imprint) array_push(_imprint_points, { ix: _tx, iy: _ty, w: _end_taper });

    _px = _tx;
    _py = _ty;
}
    }

	if (_capture_imprint && array_length(_imprint_points) > 0) {

	    var _k_max_imprints = 30;

	    if (array_length(oAvoidanceController.lightning_imprints) >= _k_max_imprints) {
	        array_delete(oAvoidanceController.lightning_imprints, 0, 1);
	    }

	    array_push(oAvoidanceController.lightning_imprints, {
	        points: _imprint_points,
	        life: 60,
	        life_max: 60,
	        col: _color
	    });
	}

	var _k_burst_size = 16;
	var _k_burst_dur  = 0.35;
	
	var _life_frac = 1 - _alpha;
	if (_life_frac < _k_burst_dur) {
	    var _burst_alpha = (1 - _life_frac / _k_burst_dur) * 0.9;
	    draw_set_color(merge_color(_color, c_white, 0.35));
	    draw_set_alpha(_burst_alpha);
	    draw_circle(_target_x, _target_y, _k_burst_size * _pulse, false);
	    draw_set_color(_color);
	    draw_set_alpha(_burst_alpha * 0.7);
	    draw_circle(_target_x, _target_y, _k_burst_size * 2 * _pulse, false);
	}
    if (_manage_blend) gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    draw_set_color(c_white);
}