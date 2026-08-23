var _col_r = _k_orb_glow_color[0];
var _col_g = _k_orb_glow_color[1];
var _col_b = _k_orb_glow_color[2];
var _col = make_color_rgb(_col_r * 255, _col_g * 255, _col_b * 255);

gpu_set_blendmode(bm_add);
gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);

var _k_ring_points = 20;
for (var ri = 0; ri < array_length(materialize_rings); ri++)
{
    var _r = materialize_rings[ri];
    shader_set_uniform_f(global.u_glow_color, _col_r, _col_g, _col_b);
    shader_set_uniform_f(global.u_glow_intensity, _r.alpha * 1.1);
    shader_set_uniform_f(global.u_glow_falloff, 2.0);
    for (var i = 0; i < _k_ring_points; i++)
    {
        var _ang = i * (360 / _k_ring_points);
        var _px = x + lengthdir_x(_r.radius, _ang);
        var _py = y + lengthdir_y(_r.radius, _ang);
        draw_sprite_ext(spr_glow_blob, 0, _px, _py, 0.4, 0.4, 0, c_white, 1);
    }
}

shader_set_uniform_f(global.u_glow_falloff, 1.6);
for (var si = 0; si < array_length(materialize_sparks); si++)
{
    var _s = materialize_sparks[si];
    shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.5), lerp(_col_b, 1, 0.5));
    shader_set_uniform_f(global.u_glow_intensity, _s.alpha * 1.4);
    draw_sprite_ext(spr_glow_blob, 0, _s.x, _s.y, 0.3, 0.3, 0, c_white, 1);
}

if (array_length(windup_afterglow_points) > 0)
{
    shader_set_uniform_f(global.u_glow_falloff, 2.4);
    for (var wpi = 0; wpi < array_length(windup_afterglow_points); wpi++)
    {
        var _wp = windup_afterglow_points[wpi];
        if (_wp.alpha <= 0) continue;
        shader_set_uniform_f(global.u_glow_color, _col_r, _col_g, _col_b);
        shader_set_uniform_f(global.u_glow_intensity, _wp.alpha * 0.7);
        draw_sprite_ext(spr_glow_blob, 0, _wp.x, _wp.y, 0.28, 0.28, 0, c_white, 1);
    }
}

if (array_length(swing_afterimages) > 0)
{
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    for (var sai = 0; sai < array_length(swing_afterimages); sai++)
    {
        var _sa = swing_afterimages[sai];
        shader_set_uniform_f(global.u_glow_color, _col_r, _col_g, _col_b);
        shader_set_uniform_f(global.u_glow_intensity, _sa.alpha * 1.1);
        draw_sprite_ext(spr_glow_blob, 0, _sa.x, _sa.y, 0.55, 0.55, 0, c_white, 1);

        shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
        shader_set_uniform_f(global.u_glow_intensity, _sa.alpha * 1.3);
        shader_set_uniform_f(global.u_glow_falloff, 2.4);
        draw_sprite_ext(spr_glow_blob, 0, _sa.x, _sa.y, 0.25, 0.25, 0, c_white, 1);
        shader_set_uniform_f(global.u_glow_falloff, 1.8);
    }
}

if (phase == "windup" || phase == "coil")
{
    var _n = array_length(trail_positions);
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    for (var ti = 0; ti < _n; ti++)
    {
        var _p = trail_positions[ti];
        var _age = ti / max(_n - 1, 1);
        shader_set_uniform_f(global.u_glow_color, _col_r, _col_g, _col_b);
        shader_set_uniform_f(global.u_glow_intensity, _age * _age * 0.5 * 1.5);
        draw_sprite_ext(spr_glow_blob, 0, _p.x, _p.y, lerp(0.15, 0.55, _age), lerp(0.15, 0.55, _age), 0, c_white, 1);
    }
}
else if (phase == "swing")
{
    var _n = array_length(trail_positions);
    shader_set_uniform_f(global.u_glow_falloff, 1.3);
    for (var ti = 0; ti < _n; ti++)
    {
        var _p = trail_positions[ti];
        var _age = ti / max(_n - 1, 1);
        shader_set_uniform_f(global.u_glow_color, lerp(_col_r, 1, 1 - _age), lerp(_col_g, 1, 1 - _age), lerp(_col_b, 1, 1 - _age));
        shader_set_uniform_f(global.u_glow_intensity, _age * _age * 0.9 * 1.5);
        draw_sprite_ext(spr_glow_blob, 0, _p.x, _p.y, lerp(0.25, 0.9, _age), lerp(0.25, 0.9, _age), 0, c_white, 1);
    }
}

if (phase == "windup")
{
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    for (var omi = 0; omi < array_length(windup_orbit_motes); omi++)
    {
        var _om = windup_orbit_motes[omi];
        var _ox = x + lengthdir_x(_k_windup_orbit_radius, _om.ang);
        var _oy = y + lengthdir_y(_k_windup_orbit_radius, _om.ang);
        shader_set_uniform_f(global.u_glow_color, lerp(_col_r, 1, 0.3), lerp(_col_g, 1, 0.3), lerp(_col_b, 1, 0.3));
        shader_set_uniform_f(global.u_glow_intensity, 1.1);
        draw_sprite_ext(spr_glow_blob, 0, _ox, _oy, 0.22, 0.22, 0, c_white, 1);
    }
}

if (array_length(orb_embers) > 0)
{
    shader_set_uniform_f(global.u_glow_falloff, 1.7);
    for (var wei = 0; wei < array_length(orb_embers); wei++)
    {
        var _we = orb_embers[wei];
        shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.4), lerp(_col_b, 1, 0.4));
        shader_set_uniform_f(global.u_glow_intensity, _we.alpha * 1.3);
        draw_sprite_ext(spr_glow_blob, 0, _we.x, _we.y, 0.22, 0.22, 0, c_white, 1);
    }
}

if (phase == "coil")
{
    shader_set_uniform_f(global.u_glow_falloff, 1.4);
    for (var mi = 0; mi < array_length(coil_motes); mi++)
    {
        var _m = coil_motes[mi];
        var _mx = x + lengthdir_x(_m.radius, _m.ang);
        var _my = y + lengthdir_y(_m.radius, _m.ang);
        var _mote_hot = 1 - clamp(_m.radius / _k_coil_mote_radius_max, 0, 1);
        shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, _mote_hot), lerp(_col_b, 1, _mote_hot));
        shader_set_uniform_f(global.u_glow_intensity, lerp(0.5, 1.6, _mote_hot));
        draw_sprite_ext(spr_glow_blob, 0, _mx, _my, 0.18, 0.18, 0, c_white, 1);
    }
}

if (array_length(satellites) > 0)
{
    for (var sti = 0; sti < array_length(satellites); sti++)
    {
        var _sat = satellites[sti];
        var _sx2 = x + lengthdir_x(_sat.radius, _sat.ang);
        var _sy2 = y + lengthdir_y(_sat.radius, _sat.ang);

        if (_sat.alive)
        {
            shader_set_uniform_f(global.u_glow_falloff, 1.7);
            for (var tsi = 1; tsi <= 5; tsi++)
            {
                var _ta = _sat.ang - tsi * 7;
                var _tx2 = x + lengthdir_x(_sat.radius, _ta);
                var _ty2 = y + lengthdir_y(_sat.radius, _ta);
                var _tf = 1 - (tsi / 6);
                shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.3), lerp(_col_b, 1, 0.3));
                shader_set_uniform_f(global.u_glow_intensity, _tf * 0.7);
                draw_sprite_ext(spr_glow_blob, 0, _tx2, _ty2, 0.13 * _tf, 0.13 * _tf, 0, c_white, 1);
            }

            shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.45), lerp(_col_b, 1, 0.45));
            shader_set_uniform_f(global.u_glow_intensity, 1.5);
            shader_set_uniform_f(global.u_glow_falloff, 1.5);
            draw_sprite_ext(spr_glow_blob, 0, _sx2, _sy2, 0.34, 0.34, 0, c_white, 1);
        }

        if (_sat.consume_flash > 0.01)
        {
            shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
            shader_set_uniform_f(global.u_glow_intensity, _sat.consume_flash * 2.4);
            shader_set_uniform_f(global.u_glow_falloff, 1.3);
            var _cf = lerp(1.6, 0.2, 1 - _sat.consume_flash);
            draw_sprite_ext(spr_glow_blob, 0, _sx2, _sy2, _cf, _cf, 0, c_white, 1);
        }
    }
}

if (array_length(shell_shards) > 0)
{
    shader_set_uniform_f(global.u_glow_falloff, 1.8);
    for (var ssi = 0; ssi < array_length(shell_shards); ssi++)
    {
        var _ss = shell_shards[ssi];
        shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.2), lerp(_col_b, 1, 0.2));
        shader_set_uniform_f(global.u_glow_intensity, _ss.alpha * 0.9);
        draw_sprite_ext(spr_glow_blob, 0, _ss.x, _ss.y, 0.2 * _ss.alpha, 0.2 * _ss.alpha, 0, c_white, 1);
    }
}

var _core_pulse = 1 + sin(current_time * 0.02) * 0.08;
var _charge_boost = core_charge;
var _cflash = core_flash;

var _vib = _k_core_vibrate_max * clamp(_charge_boost, 0, 1) * clamp(_charge_boost, 0, 1);
var _cx2 = x + random_range(-_vib, _vib);
var _cy2 = y + random_range(-_vib, _vib);

shader_set_uniform_f(global.u_glow_color, _col_r, _col_g * 0.6, _col_b * 0.55);
shader_set_uniform_f(global.u_glow_intensity, (0.7 + _charge_boost * 0.8 + _cflash * 0.6) * alpha);
shader_set_uniform_f(global.u_glow_falloff, 2.1);
var _wash_s = (1.5 + _charge_boost * 1.1 + _cflash * 0.8) * scale * _core_pulse;
draw_sprite_ext(spr_glow_blob, 0, _cx2, _cy2, _wash_s, _wash_s * 0.85, 0, c_white, 1);

shader_set_uniform_f(global.u_glow_color, _col_r, _col_g, _col_b);
shader_set_uniform_f(global.u_glow_intensity, (1.3 + _charge_boost * 1.2 + _cflash) * alpha);
shader_set_uniform_f(global.u_glow_falloff, 1.6);
var _body_s = (0.9 + _charge_boost * 0.5 + _cflash * 0.4) * scale * _core_pulse;
draw_sprite_ext(spr_glow_blob, 0, _cx2, _cy2, _body_s, _body_s, 0, c_white, 1);

if (_charge_boost > 0.02)
{
    var _rim_r = lerp(46, 11, clamp(_charge_boost, 0, 1)) * scale;
    var _rim_pts = 22;
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, (0.5 + _charge_boost * 1.1) * alpha);
    shader_set_uniform_f(global.u_glow_falloff, 2.6);
    for (var rpi = 0; rpi < _rim_pts; rpi++)
    {
        var _rpa = rpi * (360 / _rim_pts) + current_time * 0.02;
        draw_sprite_ext(spr_glow_blob, 0, _cx2 + lengthdir_x(_rim_r, _rpa), _cy2 + lengthdir_y(_rim_r, _rpa),
                        0.12, 0.12, 0, c_white, 1);
    }
}

shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
shader_set_uniform_f(global.u_glow_intensity, (1.6 + _charge_boost * 1.4 + _cflash * 1.6) * alpha);
shader_set_uniform_f(global.u_glow_falloff, 2.2);
var _hot_s = (0.4 + _charge_boost * 0.35 + _cflash * 0.5) * scale * _core_pulse;
draw_sprite_ext(spr_glow_blob, 0, _cx2, _cy2, _hot_s, _hot_s, 0, c_white, 1);

if (phase == "impact")
{
    shader_set_uniform_f(global.u_glow_color, 1, lerp(_col_g, 1, 0.6), lerp(_col_b, 1, 0.6));
    shader_set_uniform_f(global.u_glow_intensity, alpha * 2.2);
    shader_set_uniform_f(global.u_glow_falloff, 1.3);
    draw_sprite_ext(spr_glow_blob, 0, x, y, scale, scale, 0, c_white, 1);
}

shader_reset();
gpu_set_blendequation(bm_eq_add);
gpu_set_blendmode(bm_normal);

if (array_length(shell_rings) > 0 && !shell_shatter_done && alpha > 0.02)
{
    var _shell_crush_mult = lerp(1, _k_shell_crush, clamp(core_charge, 0, 1));
    var _shell_col = merge_color(_col, c_white, clamp(core_charge, 0, 1) * 0.6 + core_flash * 0.3);

    gpu_set_blendmode(bm_add);

    for (var shi = 0; shi < array_length(shell_rings); shi++)
    {
        var _sr = shell_rings[shi];
        if (_sr.assemble <= 0.01) continue;

        var _ring_crush = lerp(1, _shell_crush_mult, 0.55 + shi * 0.22);
        var _rr = _sr.radius * _ring_crush * scale;

        var _scatter = (1 - _sr.assemble) * 130;
        var _ring_a = _sr.assemble * alpha * (0.55 + clamp(core_charge, 0, 1) * 0.45);

        var _prev_vx = 0, _prev_vy = 0;
        for (var vi = 0; vi <= _sr.sides; vi++)
        {
            var _va = _sr.rot + (360 / _sr.sides) * vi;
            var _vr = _rr + _scatter;
            var _vx = x + lengthdir_x(_vr, _va);
            var _vy = y + lengthdir_y(_vr, _va);

            if (vi > 0)
            {
                draw_set_color(_shell_col);
                draw_set_alpha(_ring_a * 0.22);
                draw_line_width(_prev_vx, _prev_vy, _vx, _vy, 7 - shi);
                draw_set_alpha(_ring_a * 0.85);
                draw_line_width(_prev_vx, _prev_vy, _vx, _vy, 2);
                draw_set_color(c_white);
                draw_set_alpha(_ring_a);
                draw_line_width(_prev_vx, _prev_vy, _vx, _vy, 0.9);
            }

            _prev_vx = _vx;
            _prev_vy = _vy;
        }

        if (shi == 0 && core_charge > 0.05)
        {
            draw_set_color(merge_color(_shell_col, c_white, 0.4));
            for (var spi = 0; spi < _sr.sides; spi++)
            {
                var _spa = _sr.rot + (360 / _sr.sides) * spi;
                var _spx = x + lengthdir_x(_rr, _spa);
                var _spy = y + lengthdir_y(_rr, _spa);
                var _spf = 0.5 + 0.5 * sin(current_time * 0.02 + spi * 1.3);
                draw_set_alpha(_ring_a * core_charge * _spf * 0.7);
                draw_line_width(x, y, _spx, _spy, 1.5);
            }
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

if (array_length(shell_shards) > 0)
{
    gpu_set_blendmode(bm_add);
    for (var ssi = 0; ssi < array_length(shell_shards); ssi++)
    {
        var _ss = shell_shards[ssi];
        var _sl = _ss.len * _ss.alpha;
        var _sx3 = _ss.x + lengthdir_x(_sl, _ss.ang);
        var _sy3 = _ss.y + lengthdir_y(_sl, _ss.ang);
        var _ex3 = _ss.x - lengthdir_x(_sl, _ss.ang);
        var _ey3 = _ss.y - lengthdir_y(_sl, _ss.ang);

        draw_set_color(_col);
        draw_set_alpha(_ss.alpha * 0.35);
        draw_line_width(_ex3, _ey3, _sx3, _sy3, 5);
        draw_set_color(c_white);
        draw_set_alpha(_ss.alpha);
        draw_line_width(_ex3, _ey3, _sx3, _sy3, 1.4);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

if (array_length(orb_shocks) > 0)
{
    gpu_set_blendmode(bm_add);
    for (var osi = 0; osi < array_length(orb_shocks); osi++)
    {
        var _os = orb_shocks[osi];
        var _oa = _os.life / _os.life_max;
        scr_draw_smooth_ring_mask(x, y, _os.radius, _oa * _oa * 0.85, _os.width * _oa,
                                  merge_color(_col, c_white, _os.hot));
        draw_set_color(c_white);
        draw_set_alpha(_oa * _oa * 0.6);
        draw_circle(x, y, _os.radius, true);
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}

if (phase == "windup")
{
    for (var wai = 0; wai < array_length(windup_arcs); wai++)
    {
        var _wa = windup_arcs[wai];
        var _wx = x + lengthdir_x(_k_windup_arc_reach, _wa.ang);
        var _wy = y + lengthdir_y(_k_windup_arc_reach, _wa.ang);
        scr_draw_lightning_bolt(_wx, _wy, _wa.life, _wa.life_max, 4, false, _col, 0.05, 4, "w" + string(wai), 1);
    }
}

if (phase == "coil")
{
    var _coil_p = clamp((oAvoidanceController.t - _k_t_coil_start) / (_k_t_swing_start - _k_t_coil_start), 0, 1);
    var _ring_color = merge_color(_col, c_white, _coil_p * 0.5);

    var _ring_r = lerp(_k_coil_ring_radius_start, _k_coil_ring_radius_end, _coil_p);
    scr_draw_lightning_arc(x, y, _ring_r, 0, 360, 1, 1, _ring_color);
    scr_draw_lightning_arc(x, y, _ring_r * 0.72, 180, 540, 1, 1, _ring_color);

    for (var ai = 0; ai < array_length(coil_arcs); ai++)
    {
        var _a = coil_arcs[ai];
        var _ox = x + lengthdir_x(_k_coil_arc_outer_radius, _a.ang);
        var _oy = y + lengthdir_y(_k_coil_arc_outer_radius, _a.ang);
        scr_draw_lightning_bolt(_ox, _oy, _a.life, _a.life_max, 5, false, _ring_color, 0.05, 5, string(ai), 1);
    }

    for (var pui = 0; pui < array_length(coil_pulses); pui++)
    {
        var _p = coil_pulses[pui];
        scr_draw_smooth_ring_mask(x, y, _p.radius, _p.alpha, 8, _ring_color);
    }

    if (array_length(coil_leak_arcs) > 0)
    {
        var _orig_x = x, _orig_y = y;
        for (var lai = 0; lai < array_length(coil_leak_arcs); lai++)
        {
            var _la = coil_leak_arcs[lai];
            x = _orig_x + lengthdir_x(_ring_r, _la.ang);
            y = _orig_y + lengthdir_y(_ring_r, _la.ang);
            var _lx = _orig_x + lengthdir_x(_k_coil_leak_reach, _la.ang);
            var _ly = _orig_y + lengthdir_y(_k_coil_leak_reach, _la.ang);
            scr_draw_lightning_bolt(_lx, _ly, _la.life, _la.life_max, 5, true, merge_color(_ring_color, c_white, 0.2), 0.1, 6,
                                    "leak" + string(lai), 1);
        }
        x = _orig_x;
        y = _orig_y;
    }
}

if (phase == "impact")
{
    var _impact_p_ring = clamp((oAvoidanceController.t - _k_t_swing_end) / (_k_t_impact_end - _k_t_swing_end), 0, 1);
    var _impact_color = merge_color(_col, c_white, 0.4);

    for (var iai = 0; iai < array_length(impact_arcs); iai++)
    {
        var _ia = impact_arcs[iai];
        var _ix = x + lengthdir_x(_k_impact_arc_reach, _ia.ang);
        var _iy = y + lengthdir_y(_k_impact_arc_reach, _ia.ang);
        scr_draw_lightning_bolt(_ix, _iy, _ia.life, _ia.life_max, 6, true, _impact_color, 0.08, 6, "imp" + string(iai), 1);
    }

    gpu_set_blendmode(bm_add);
    scr_draw_smooth_ring_mask(x, y, _impact_p_ring * 260, (1 - _impact_p_ring) * 0.8, 30, _impact_color);
    scr_draw_smooth_ring_mask(x, y, max(0, _impact_p_ring * 260 - 60), (1 - _impact_p_ring) * 0.5, 18, c_white);
    scr_draw_smooth_ring_mask(x, y, _impact_p_ring * 400, (1 - _impact_p_ring) * 0.4, 40, _impact_color);
    gpu_set_blendmode(bm_normal);
}

if (phase == "swing")
{
    var _speed = point_distance(xprevious, yprevious, x, y);
    var _dir = point_direction(xprevious, yprevious, x, y);
    var _lookahead = _speed * _k_swing_lookahead_mult;
    var _tail_len = max(_speed * _k_swing_tail_mult, 20);

    var _tip_x = x + lengthdir_x(_lookahead, _dir);
    var _tip_y = y + lengthdir_y(_lookahead, _dir);
    var _tail_x = x - lengthdir_x(_tail_len, _dir);
    var _tail_y = y - lengthdir_y(_tail_len, _dir);

    var _perp = _dir + 90;
    var _fringe_off = 3.5;

    gpu_set_blendmode(bm_add);

    var _rn = array_length(trail_positions);
    if (_rn >= 3)
    {
        for (var _side = -1; _side <= 1; _side += 2)
        {
            draw_primitive_begin(pr_trianglestrip);
            for (var ri2 = 0; ri2 < _rn; ri2++)
            {
                var _pp = trail_positions[ri2];
                var _age2 = ri2 / (_rn - 1);
                var _seg_dir = (ri2 < _rn - 1)
                             ? point_direction(_pp.x, _pp.y, trail_positions[ri2 + 1].x, trail_positions[ri2 + 1].y)
                             : point_direction(trail_positions[ri2 - 1].x, trail_positions[ri2 - 1].y, _pp.x, _pp.y);
                var _np = _seg_dir + 90 * _side;

                var _w = lerp(_k_ribbon_width_tail, _k_ribbon_width_head, power(_age2, 1.6));

                draw_vertex_color(_pp.x, _pp.y, merge_color(_col, c_white, 0.35), _age2 * _age2 * 0.75);
                draw_vertex_color(_pp.x + lengthdir_x(_w, _np), _pp.y + lengthdir_y(_w, _np), _col, 0);
            }
            draw_primitive_end();
        }

        draw_primitive_begin(pr_trianglestrip);
        for (var ri3 = 0; ri3 < _rn; ri3++)
        {
            var _pp2 = trail_positions[ri3];
            var _age3 = ri3 / (_rn - 1);
            var _seg_dir2 = (ri3 < _rn - 1)
                          ? point_direction(_pp2.x, _pp2.y, trail_positions[ri3 + 1].x, trail_positions[ri3 + 1].y)
                          : point_direction(trail_positions[ri3 - 1].x, trail_positions[ri3 - 1].y, _pp2.x, _pp2.y);
            var _np2 = _seg_dir2 + 90;
            var _w2 = lerp(0.5, _k_ribbon_width_head * 0.3, power(_age3, 1.4));

            draw_vertex_color(_pp2.x + lengthdir_x(_w2, _np2), _pp2.y + lengthdir_y(_w2, _np2), c_white, _age3 * 0.9);
            draw_vertex_color(_pp2.x - lengthdir_x(_w2, _np2), _pp2.y - lengthdir_y(_w2, _np2), c_white, _age3 * 0.9);
        }
        draw_primitive_end();

        for (var _cs = 0; _cs < 2; _cs++)
        {
            var _cside = (_cs == 0) ? 1 : -1;
            var _ccol = (_cs == 0) ? global.avoid_col_danger : global.avoid_col_cyan;

            draw_primitive_begin(pr_trianglestrip);
            for (var ri4 = 0; ri4 < _rn; ri4++)
            {
                var _pp3 = trail_positions[ri4];
                var _age4 = ri4 / (_rn - 1);
                var _seg_dir3 = (ri4 < _rn - 1)
                              ? point_direction(_pp3.x, _pp3.y, trail_positions[ri4 + 1].x, trail_positions[ri4 + 1].y)
                              : point_direction(trail_positions[ri4 - 1].x, trail_positions[ri4 - 1].y, _pp3.x, _pp3.y);
                var _np3 = _seg_dir3 + 90 * _cside;
                var _base = lerp(0.5, _k_ribbon_width_head * 0.32, power(_age4, 1.4));

                draw_vertex_color(_pp3.x + lengthdir_x(_base, _np3), _pp3.y + lengthdir_y(_base, _np3), _ccol, 0);
                draw_vertex_color(_pp3.x + lengthdir_x(_base + _k_ribbon_fringe, _np3),
                                  _pp3.y + lengthdir_y(_base + _k_ribbon_fringe, _np3), _ccol, _age4 * 0.7);
            }
            draw_primitive_end();
        }
    }

    draw_set_color(global.avoid_col_danger);
    draw_set_alpha(0.45);
    draw_line_width(_tail_x + lengthdir_x(_fringe_off, _perp), _tail_y + lengthdir_y(_fringe_off, _perp),
                    _tip_x + lengthdir_x(_fringe_off, _perp), _tip_y + lengthdir_y(_fringe_off, _perp), 9);
    draw_set_color(global.avoid_col_cyan);
    draw_line_width(_tail_x - lengthdir_x(_fringe_off, _perp), _tail_y - lengthdir_y(_fringe_off, _perp),
                    _tip_x - lengthdir_x(_fringe_off, _perp), _tip_y - lengthdir_y(_fringe_off, _perp), 9);

    draw_set_color(merge_color(_col, c_white, 0.2));
    draw_set_alpha(0.35);
    draw_line_width(_tail_x, _tail_y, _tip_x, _tip_y, 28);
    draw_set_alpha(0.7);
    draw_line_width(_tail_x, _tail_y, _tip_x, _tip_y, 13);
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_line_width(_tail_x, _tail_y, _tip_x, _tip_y, 4);

    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
