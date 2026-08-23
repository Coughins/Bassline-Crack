// ============================================================================
// ============================================================================

var _cr = 9 * abs(image_xscale);
var _tier = scr_core_cell_tier(_cr);
var _speed_f = clamp(vel_mag / 10, 0, 1);
var _hot = max(beat_flash, birth_flash);

// --- telegraph: where this cell is going next -------------------------------
if (telegraph_timer > 0 && telegraph_max > 0)
{
    var _tp = 1 - (telegraph_timer / telegraph_max);
    var _tr = lerp(58, 30, _tp);
    var _ta = 0.62 + _tp * 0.38;
    var _tcol = merge_color(global.avoid_col_warning, c_white, _tp * 0.55);

    var _rd = point_distance(x, y, telegraph_x, telegraph_y);
    var _ra = point_direction(x, y, telegraph_x, telegraph_y);
    var _dashes = max(2, floor(_rd / 26));

    gpu_set_blendmode(bm_add);
    draw_set_color(global.avoid_col_cyan);
    for (var _d = 0; _d < _dashes; _d++)
    {
        var _d0 = (_d + 0.15) / _dashes;
        var _d1 = (_d + 0.62) / _dashes;
        draw_set_alpha(_ta * 0.42 * (0.35 + _d0 * 0.65));
        draw_line_width(x + lengthdir_x(_rd * _d0, _ra), y + lengthdir_y(_rd * _d0, _ra),
                        x + lengthdir_x(_rd * _d1, _ra), y + lengthdir_y(_rd * _d1, _ra),
                        1 + _tp * 1.6);
    }
    gpu_set_blendmode(bm_normal);

    scr_draw_lock_bracket(telegraph_x - _tr, telegraph_y - _tr * 0.72,
                          telegraph_x + _tr, telegraph_y + _tr * 0.72,
                          _tcol, 0.35 + _tp * 0.65, _ta, 13, false, 4);

    gpu_set_blendmode(bm_add);
    draw_set_color(_tcol);
    draw_set_alpha(_ta * 0.75);
    var _sr = lerp(_cr * 1.5, _cr, _tp);
    for (var _tk = 0; _tk < 4; _tk++)
    {
        var _tka = 45 + _tk * 90;
        draw_line_width(telegraph_x + lengthdir_x(_sr, _tka - 16),
                        telegraph_y + lengthdir_y(_sr, _tka - 16),
                        telegraph_x + lengthdir_x(_sr, _tka + 16),
                        telegraph_y + lengthdir_y(_sr, _tka + 16), 1.5 + _tp * 1.5);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

// --- the path it took -------------------------------------------------------
var _tn = array_length(trail_positions);
if (_tn >= 2)
{
    gpu_set_blendmode(bm_add);

    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i < _tn; i++)
    {
        var _p = trail_positions[i];
        var _u = i / (_tn - 1);
        var _pl = _p.life;
        var _w = max(0.8, _cr * (0.16 + _u * 0.66) * _pl);

        var _dirn;
        if (i < _tn - 1) {
            var _nq = trail_positions[i + 1];
            _dirn = (point_distance(_p.px, _p.py, _nq.px, _nq.py) > 0.01)
                  ? point_direction(_p.px, _p.py, _nq.px, _nq.py)
                  : vel_dir;
        } else {
            _dirn = vel_dir;
        }

        var _nx = lengthdir_x(_w, _dirn + 90), _ny = lengthdir_y(_w, _dirn + 90);
        var _ca = _pl * _pl * (0.22 + _u * 0.55);
        draw_vertex_color(_p.px + _nx, _p.py + _ny, global.avoid_col_danger, _ca);
        draw_vertex_color(_p.px - _nx, _p.py - _ny, global.avoid_col_danger, _ca);
    }
    draw_primitive_end();

    for (var i2 = _tn - 1; _tier >= 1 && i2 >= 0; i2 -= 4)
    {
        var _p2 = trail_positions[i2];
        var _pstretch = variable_struct_exists(_p2, "stretch") ? _p2.stretch : 1;
        var _pang = variable_struct_exists(_p2, "ang") ? _p2.ang : image_angle;
        var _psc = variable_struct_exists(_p2, "sc") ? _p2.sc : image_xscale;
        scr_draw_core_cell_ghost(_p2.px, _p2.py, 9 * abs(_psc), cell_spin - i2 * 9, _pang,
                                 _pstretch, _p2.life * _p2.life * 0.55, 0.4 + _hot * 0.5);
    }

    gpu_set_blendmode(bm_normal);
}

// --- containment breach ring ------------------------------------------------
if (shockwave_timer >= 0)
{
    var _swt = shockwave_timer / shockwave_max_frames;
    var _radius = lerp(20, 220, _swt) * max(0.4, image_xscale / 3);
    var _salpha = (1 - _swt) * (1 - _swt);

    gpu_set_blendmode(bm_add);
    draw_set_alpha(_salpha * 0.8);
    draw_set_color(merge_color(global.avoid_col_danger, c_white, 0.4));
    draw_circle(x, y, _radius, true);
    draw_set_alpha(_salpha * 0.35);
    draw_set_color(global.avoid_col_cyan);
    draw_circle(x, y, _radius * 0.82, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

// --- the cell ---------------------------------------------------------------
scr_draw_core_cell(x, y, _cr * (1 + _speed_f * 0.12), cell_spin, _tier,
                   clamp(0.35 + _hot * 0.5 + lock_pulse * 0.4, 0, 1),
                   clamp(max(_hot, lock_pulse), 0, 1),
                   seam_charge, seam_ang, shell_open, gather,
                   cell_accent, _speed_f * 5.5);

// --- the drag smear, only while genuinely fast ------------------------------
if (_speed_f > 0.12)
{
    gpu_set_blendmode(bm_add);
    var _tail = max(_cr * 1.2, vel_mag * 3.6);
    var _tw = _cr * 0.55;
    var _bx = x - lengthdir_x(_tail, vel_dir);
    var _by = y - lengthdir_y(_tail, vel_dir);
    var _px2 = lengthdir_x(_tw, vel_dir + 90);
    var _py2 = lengthdir_y(_tw, vel_dir + 90);

    draw_primitive_begin(pr_trianglelist);
    draw_vertex_color(x + _px2, y + _py2, global.avoid_col_danger, _speed_f * 0.55);
    draw_vertex_color(x - _px2, y - _py2, global.avoid_col_danger, _speed_f * 0.55);
    draw_vertex_color(_bx, _by, global.avoid_col_blood, 0);
    draw_primitive_end();

    draw_set_color(merge_color(global.avoid_col_hot, c_white, 0.5));
    draw_set_alpha(_speed_f * 0.7);
    draw_line_width(x, y, x - lengthdir_x(_tail * 0.72, vel_dir),
                    y - lengthdir_y(_tail * 0.72, vel_dir), max(1, _cr * 0.16));
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
