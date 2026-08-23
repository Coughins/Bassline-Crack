var _total_scale = spawn_scale * despawn_scale * breath_scale;

var _push = oAvoidanceController.blackhole_push_mode;
var _charge = oAvoidanceController.bh_phase_charge;
var _menace = max(escalation, _charge);
var _hot = feed_charge + invert_shock + oAvoidanceController.bh_heartbeat * 0.5;
var _despawn_p = despawning ? clamp(despawn_timer / max(1, despawn_duration), 0, 1) : 0;
var _despawn_dim = despawning ? lerp(0.48, oAvoidanceController._k_bh_despawn_draw_mult, _despawn_p) : 1;
var _alpha_scale = _total_scale * _despawn_dim;

var _body_col = _push ? merge_color(global.lightning_color, c_white, despawning ? 0.34 : 0.7) : global.lightning_color;
var _accent_col = _push ? merge_color(global.lightning_color, c_white, despawning ? 0.28 : 1) : c_purple;

gpu_set_blendmode(bm_add);

var _glow_r = ring_radius * _total_scale * (1 + _hot * 0.25);
var _glow_s = (_glow_r / 64) * 2;
var _glow_uvs = sprite_get_uvs(spr_glow_blob, 0);
gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
shader_set_uniform_f(global.u_glow_uvrect, _glow_uvs[0], _glow_uvs[1], _glow_uvs[2], _glow_uvs[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(_body_col) / 255, color_get_green(_body_col) / 255,
                     color_get_blue(_body_col) / 255);
shader_set_uniform_f(global.u_glow_intensity, (0.32 + _menace * 0.3 + _hot * 0.45) * _alpha_scale);
shader_set_uniform_f(global.u_glow_falloff, 2.2);
draw_sprite_ext(spr_glow_blob, 0, x, y, _glow_s, _glow_s * 0.7, 0, c_white, 1);

var _disk_blobs = 22;
shader_set_uniform_f(global.u_glow_intensity, (0.42 + _hot * 0.5) * _alpha_scale);
shader_set_uniform_f(global.u_glow_falloff, 2.2);
for (var i = 0; i < _disk_blobs; i++) {
    var _ba = disk_angle * 0.4 + i * (360 / _disk_blobs);
    var _br2 = lerp(disk_inner_radius, disk_outer_radius, 0.55) * _alpha_scale;
    draw_sprite_ext(spr_glow_blob, 0, x + lengthdir_x(_br2, _ba), y + lengthdir_y(_br2, _ba) * disk_squash, 0.4, 0.4, 0,
                    c_white, 1);
}
shader_reset();
gpu_set_blendequation(bm_eq_add);

var _segments = 16;
for (var i = 0; i < _segments; i++)
{
    if (i mod 2 == 0) continue;
    var _a1 = swirl_angle + i * (360 / _segments);
    var _a2 = swirl_angle + (i + 1) * (360 / _segments);
    if (sin(degtorad(_a1)) >= 0) continue;
    var _r = ring_radius * _alpha_scale;
    var _x1 = x + lengthdir_x(_r, _a1);
    var _y1 = y + lengthdir_y(_r, _a1) * 0.4;
    var _x2 = x + lengthdir_x(_r, _a2);
    var _y2 = y + lengthdir_y(_r, _a2) * 0.4;
    draw_set_color(_body_col);
    draw_set_alpha((0.35 + _hot * 0.2) * _alpha_scale);
    draw_line_width(_x1, _y1, _x2, _y2, 3);
}

var _segments2 = 12;
for (var i = 0; i < _segments2; i++)
{
    if (i mod 2 == 0) continue;
    var _a1 = second_ring_angle + i * (360 / _segments2);
    var _a2 = second_ring_angle + (i + 1) * (360 / _segments2);
    if (sin(degtorad(_a1)) >= 0) continue;
    var _r2 = second_ring_radius * _alpha_scale;
    var _x1 = x + lengthdir_x(_r2, _a1);
    var _y1 = y + lengthdir_y(_r2, _a1) * 0.6;
    var _x2 = x + lengthdir_x(_r2, _a2);
    var _y2 = y + lengthdir_y(_r2, _a2) * 0.6;
    draw_set_color(_accent_col);
    draw_set_alpha((0.28 + _hot * 0.2) * _alpha_scale);
    draw_line_width(_x1, _y1, _x2, _y2, 2);
}


var _disk_segments = 24;
for (var b = 0; b < disk_band_count; b++)
{
    var _bt = b / max(1, disk_band_count - 1);
    var _br = lerp(disk_inner_radius, disk_outer_radius, _bt) * _alpha_scale;
    var _balpha = lerp(0.55, 0.06, _bt) * _alpha_scale * (1 + _hot * 0.7);
    var _bcolor = merge_color(c_white, _body_col, _bt * (1 - _hot * 0.4));
    _balpha *= _despawn_dim;

    for (var i = 0; i < _disk_segments; i++)
    {
        if (i mod 2 == 0) continue;
        var _a1 = disk_angle + i * (360 / _disk_segments);
        var _a2 = disk_angle + (i + 1) * (360 / _disk_segments);
        if (sin(degtorad(_a1)) >= 0) continue;
        var _x1 = x + lengthdir_x(_br, _a1);
        var _y1 = y + lengthdir_y(_br, _a1) * disk_squash;
        var _x2 = x + lengthdir_x(_br, _a2);
        var _y2 = y + lengthdir_y(_br, _a2) * disk_squash;
        draw_set_color(_bcolor);
        draw_set_alpha(_balpha * _despawn_dim);
        draw_line_width(_x1, _y1, _x2, _y2, 3);
    }
}

for (var i = 0; i < array_length(disk_clumps); i++)
{
    var _c = disk_clumps[i];
    if (sin(degtorad(_c.angle)) >= 0) continue;
    var _cr = lerp(disk_inner_radius, disk_outer_radius, _c.radius_t) * _alpha_scale;
    var _cx = x + lengthdir_x(_cr, _c.angle);
    var _cy = y + lengthdir_y(_cr, _c.angle) * disk_squash;
    draw_set_color(c_white);
    draw_set_alpha(0.5 * _alpha_scale);
    draw_circle(_cx, _cy, 4 * _total_scale, false);
}

draw_set_color(c_white);
draw_set_alpha(0.15 * _alpha_scale);
draw_circle(x, y, core_radius * 2.2 * _total_scale, false);
draw_set_alpha(0.3 * _alpha_scale);
draw_circle(x, y, core_radius * 1.5 * _total_scale, false);

draw_set_color(global.lightning_color);
for (var i = 0; i < array_length(debris); i++) {
    var _dx = x + lengthdir_x(debris[i].radius * _total_scale, debris[i].angle);
    var _dy = y + lengthdir_y(debris[i].radius * _total_scale, debris[i].angle) * 0.4;
    draw_set_alpha(0.7 * _alpha_scale);
    draw_circle(_dx, _dy, debris[i].size * _total_scale, false);
}

draw_set_color(c_white);
var _push_mode_draw = oAvoidanceController.blackhole_push_mode;
var _trail_dir = _push_mode_draw ? -1 : 1;
for (var i = 0; i < array_length(matter_streaks); i++)
{
    var _s = matter_streaks[i];
    var _sr = _s.dist * _alpha_scale;
    var _sx1 = x + lengthdir_x(_sr, _s.angle);
    var _sy1 = y + lengthdir_y(_sr, _s.angle) * disk_squash;
    var _tail_dist = _s.dist + _trail_dir * _s.length;
    var _sr2 = _tail_dist * _alpha_scale;
    var _sx2 = x + lengthdir_x(_sr2, _s.angle);
    var _sy2 = y + lengthdir_y(_sr2, _s.angle) * disk_squash;
    var _sfade = clamp(1 - (_s.dist / (disk_outer_radius * 2.5)), 0, 1);
    draw_set_alpha(0.5 * _sfade * _alpha_scale);
    draw_line_width(_sx1, _sy1, _sx2, _sy2, 2);
}

var _haze_radius = (ring_radius * 1.1 + ring_radius * 1.6) * 0.5 * _alpha_scale;
var _haze_band   = (ring_radius * 1.6 - ring_radius * 1.1) * 0.5 * _alpha_scale;
scr_draw_smooth_ring_mask(x, y, _haze_radius, (0.12 + _hot * 0.12) * _alpha_scale, _haze_band, _body_col);

for (var i = 0; i < array_length(storm_bolts); i++)
{
    var _b = storm_bolts[i];
    scr_draw_lightning_arc(x, y, _b[2], _b[0], _b[1], _b[3], _b[4], _body_col);
}
for (var i = 0; i < array_length(field_lines); i++)
{
    var _fl = field_lines[i];
    var _flen = ring_radius * 1.8 * _fl.length_mult * _alpha_scale;
    var _segs = 8;
    var _prev_x = x, _prev_y = y;
    for (var s = 1; s <= _segs; s++)
    {
        var _t = s / _segs;
        var _r = _flen * _t;
        var _curl = field_line_curve * 40 * _t * _t;
        var _a = _fl.angle + _curl;
        var _px = x + lengthdir_x(_r, _a);
        var _py = y + lengthdir_y(_r, _a) * disk_squash;
        draw_set_color(_body_col);
        draw_set_alpha((0.25 * (1 - _t) * (1 + _menace * 0.8)) * _alpha_scale);
        draw_line_width(_prev_x, _prev_y, _px, _py, 1.5);
        _prev_x = _px;
        _prev_y = _py;
    }
}

for (var i = 0; i < array_length(pulse_waves); i++)
{
    var _radius = pulse_waves[i][0];
    var _alpha  = pulse_waves[i][1];
    draw_set_color(c_white);
    draw_set_alpha(_alpha * 0.05);
    draw_circle(x, y, _radius, true);
}

var _phase = (current_time * (0.0005 + proximity_factor * 0.0025 + escalation * 0.001)) mod 1;
var _rim_color;
if (_phase < 0.5) {
    _rim_color = merge_color(global.lightning_color, c_purple, _phase * 2);
} else {
    _rim_color = merge_color(c_purple, c_white, (_phase - 0.5) * 2);
}
draw_set_color(_rim_color);
draw_set_alpha((0.8 + proximity_factor * 0.2 + escalation * 0.2) * _alpha_scale);
draw_circle(x, y, core_radius * _total_scale + 1, true);
draw_circle(x, y, core_radius * _total_scale + 2, true);

if (proximity_factor > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(proximity_factor * 0.25 * _alpha_scale);
    draw_circle(x, y, core_radius * 3 * _total_scale, false);
}

if (jet_length > 1)
{
    var _jl = jet_length * _alpha_scale;
    var _jet_col = _push ? c_white : _body_col;
    for (var _pole = 0; _pole < 2; _pole++)
    {
        var _ja = jet_angle + _pole * 180;
        var _segs_j = 9;
        for (var s = 1; s <= _segs_j; s++)
        {
            var _jt = s / _segs_j;
            var _jr0 = _jl * ((s - 1) / _segs_j);
            var _jr1 = _jl * _jt;
            var _wob = sin(current_time * 0.004 + s * 0.9 + shimmer_seed) * 3 * _jt;
            var _jw = (2.5 + _jt * 7) * _alpha_scale;
            var _jx0 = x + lengthdir_x(_jr0, _ja) + lengthdir_x(_wob, _ja + 90);
            var _jy0 = y + lengthdir_y(_jr0, _ja) + lengthdir_y(_wob, _ja + 90);
            var _jx1 = x + lengthdir_x(_jr1, _ja) + lengthdir_x(_wob, _ja + 90);
            var _jy1 = y + lengthdir_y(_jr1, _ja) + lengthdir_y(_wob, _ja + 90);

            draw_set_color(_jet_col);
            draw_set_alpha((1 - _jt) * 0.34 * _alpha_scale);
            draw_line_width(_jx0, _jy0, _jx1, _jy1, _jw);
            draw_set_color(c_white);
            draw_set_alpha((1 - _jt) * 0.55 * _alpha_scale);
            draw_line_width(_jx0, _jy0, _jx1, _jy1, _jw * 0.3);
        }
    }
}

for (var i = 0; i < array_length(disk_sparks); i++)
{
    var _sp = disk_sparks[i];
    var _spa = _sp.life / _sp.life_max;
    var _spr = _sp.rad * _alpha_scale;
    var _spx = x + lengthdir_x(_spr, _sp.ang);
    var _spy = y + lengthdir_y(_spr, _sp.ang) * disk_squash;
    var _tail = _sp.out * 5;
    draw_set_color(scr_hot_metal_color(1 - _spa));
    draw_set_alpha(_spa * 0.85 * _alpha_scale);
    draw_line_width(_spx, _spy, x + lengthdir_x(_spr - _tail, _sp.ang),
                    y + lengthdir_y(_spr - _tail, _sp.ang) * disk_squash, _sp.size);
}

gpu_set_blendmode(bm_normal);

var _target_core_blend = oAvoidanceController.blackhole_push_mode ? 1 : 0;
core_color_blend = lerp(core_color_blend, _target_core_blend, 0.1 + invert_shock * 0.5);

var _core_color = merge_color(c_black, c_white, core_color_blend);
draw_set_color(_core_color);
draw_set_alpha(_alpha_scale);

var _shim_amp = shimmer_amplitude * (1 + _hot * 2.2 + _menace * 0.8);
var _core_r = core_radius * _total_scale * (1 + feed_charge * 0.35 + invert_shock * 0.5);
draw_primitive_begin(pr_trianglefan);
draw_vertex(x, y);
for (var i = 0; i <= shimmer_segments; i++)
{
    var _ang = (360 / shimmer_segments) * i;
    var _wobble = sin(degtorad(_ang) * 3 + current_time * 0.001 * shimmer_speed + shimmer_seed) * _shim_amp
                + sin(degtorad(_ang) * 7 - current_time * 0.0016 + shimmer_seed) * _shim_amp * 0.4 * _menace;
    var _r = _core_r + _wobble;
    draw_vertex(x + lengthdir_x(_r, _ang), y + lengthdir_y(_r, _ang));
}
draw_primitive_end();


gpu_set_blendmode(bm_add);
for (var b = 0; b < disk_band_count; b++)
{
    var _bt = b / max(1, disk_band_count - 1);
    var _br = lerp(disk_inner_radius, disk_outer_radius, _bt) * _alpha_scale;
    var _balpha = lerp(0.75, 0.1, _bt) * _total_scale * (1 + _hot * 0.7);
    var _bcolor = merge_color(c_white, _body_col, _bt * (1 - _hot * 0.4));

    for (var i = 0; i < _disk_segments; i++)
    {
        if (i mod 2 == 0) continue;
        var _a1 = disk_angle + i * (360 / _disk_segments);
        var _a2 = disk_angle + (i + 1) * (360 / _disk_segments);
        if (sin(degtorad(_a1)) < 0) continue;
        var _x1 = x + lengthdir_x(_br, _a1);
        var _y1 = y + lengthdir_y(_br, _a1) * disk_squash;
        var _x2 = x + lengthdir_x(_br, _a2);
        var _y2 = y + lengthdir_y(_br, _a2) * disk_squash;
        draw_set_color(_bcolor);
        draw_set_alpha(_balpha * _despawn_dim);
        draw_line_width(_x1, _y1, _x2, _y2, 3);
    }
}
for (var i = 0; i < array_length(disk_clumps); i++)
{
    var _c = disk_clumps[i];
    if (sin(degtorad(_c.angle)) < 0) continue;
    var _cr = lerp(disk_inner_radius, disk_outer_radius, _c.radius_t) * _alpha_scale;
    var _cx = x + lengthdir_x(_cr, _c.angle);
    var _cy = y + lengthdir_y(_cr, _c.angle) * disk_squash;
    draw_set_color(c_white);
    draw_set_alpha(0.8 * _alpha_scale);
    draw_circle(_cx, _cy, 4 * _total_scale, false);
}

if (flare_active)
{
    var _flare_p = flare_life / flare_duration;
    var _flare_alpha = (1 - _flare_p) * (1 - _flare_p);
    gpu_set_blendmode(bm_add);
    draw_set_color(c_white);
    draw_set_alpha(_flare_alpha * 0.9 * _despawn_dim);
    draw_circle(x, y, core_radius * (1.5 + _flare_p * 2) * _total_scale, false);

    var _streak_count_flare = 6;
    for (var i = 0; i < _streak_count_flare; i++)
    {
        var _sa = (360 / _streak_count_flare) * i + shimmer_seed;
        var _slen = core_radius * (3 + _flare_p * 5) * _alpha_scale;
        var _sx = x + lengthdir_x(_slen, _sa);
        var _sy = y + lengthdir_y(_slen, _sa) * disk_squash;
        draw_set_alpha(_flare_alpha * 0.5 * _despawn_dim);
        draw_line_width(x, y, _sx, _sy, 2);
    }
    gpu_set_blendmode(bm_normal);
}

if (feed_flash > 0)
{
    gpu_set_blendmode(bm_add);
    gpu_set_blendequation(bm_eq_max);
    shader_set(shd_bullet_glow);
    var _fuvs = sprite_get_uvs(spr_glow_blob, 0);
    shader_set_uniform_f(global.u_glow_uvrect, _fuvs[0], _fuvs[1], _fuvs[2], _fuvs[3]);
    shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
    shader_set_uniform_f(global.u_glow_intensity, feed_flash * 1.1 * _despawn_dim);
    shader_set_uniform_f(global.u_glow_falloff, 1.6);
    var _fs = (core_radius * (1.4 + feed_flash * 1.0) * _alpha_scale) / 64 * 2.6;
    draw_sprite_ext(spr_glow_blob, 0, x, y, _fs, _fs, 0, c_white, 1);
    shader_reset();
    gpu_set_blendequation(bm_eq_add);

    var _fa0 = feed_streak_angle - 26 - feed_flash * 30;
    var _fa1 = feed_streak_angle + 26 + feed_flash * 30;
    var _fseg = 12;
    var _fr = lerp(disk_inner_radius, disk_outer_radius, 0.5) * _alpha_scale;
    for (var s = 0; s < _fseg; s++)
    {
        var _fx1 = x + lengthdir_x(_fr, lerp(_fa0, _fa1, s / _fseg));
        var _fy1 = y + lengthdir_y(_fr, lerp(_fa0, _fa1, s / _fseg)) * disk_squash;
        var _fx2 = x + lengthdir_x(_fr, lerp(_fa0, _fa1, (s + 1) / _fseg));
        var _fy2 = y + lengthdir_y(_fr, lerp(_fa0, _fa1, (s + 1) / _fseg)) * disk_squash;
        draw_set_color(c_white);
        draw_set_alpha(feed_flash * 0.8 * _alpha_scale);
        draw_line_width(_fx1, _fy1, _fx2, _fy2, 4 + feed_flash * 5);
    }
    gpu_set_blendmode(bm_normal);
}

if (invert_shock > 0)
{
    gpu_set_blendmode(bm_add);
    var _is2 = invert_shock * invert_shock;
    var _split = invert_shock * 14 * _total_scale * fx_get_mult_for("blackholes", "aberration");

    draw_set_color(c_red);
    draw_set_alpha(_is2 * 0.55 * _despawn_dim);
    draw_circle(x - _split, y, core_radius * (2 + invert_shock * 4) * _total_scale, false);
    draw_set_color(c_aqua);
    draw_set_alpha(_is2 * 0.55 * _despawn_dim);
    draw_circle(x + _split, y, core_radius * (2 + invert_shock * 4) * _total_scale, false);

    draw_set_color(c_white);
    draw_set_alpha(_is2 * _despawn_dim);
    draw_circle(x, y, core_radius * (1.6 + invert_shock * 3.4) * _total_scale, false);
    gpu_set_blendmode(bm_normal);
}

gpu_set_blendmode(bm_add);
for (var i = 0; i < _segments; i++)
{
    if (i mod 2 == 0) continue;
    var _a1 = swirl_angle + i * (360 / _segments);
    var _a2 = swirl_angle + (i + 1) * (360 / _segments);
    if (sin(degtorad(_a1)) < 0) continue;
    var _r = ring_radius * _alpha_scale;
    var _x1 = x + lengthdir_x(_r, _a1);
    var _y1 = y + lengthdir_y(_r, _a1) * 0.4;
    var _x2 = x + lengthdir_x(_r, _a2);
    var _y2 = y + lengthdir_y(_r, _a2) * 0.4;
    draw_set_color(_body_col);
    draw_set_alpha((0.6 + _hot * 0.3) * _alpha_scale);
    draw_line_width(_x1, _y1, _x2, _y2, 3);
}
for (var i = 0; i < _segments2; i++)
{
    if (i mod 2 == 0) continue;
    var _a1 = second_ring_angle + i * (360 / _segments2);
    var _a2 = second_ring_angle + (i + 1) * (360 / _segments2);
    if (sin(degtorad(_a1)) < 0) continue;
    var _r2 = second_ring_radius * _alpha_scale;
    var _x1 = x + lengthdir_x(_r2, _a1);
    var _y1 = y + lengthdir_y(_r2, _a1) * 0.6;
    var _x2 = x + lengthdir_x(_r2, _a2);
    var _y2 = y + lengthdir_y(_r2, _a2) * 0.6;
    draw_set_color(_accent_col);
    draw_set_alpha((0.5 + _hot * 0.3) * _alpha_scale);
    draw_line_width(_x1, _y1, _x2, _y2, 2);
}
gpu_set_blendmode(bm_normal);

draw_set_alpha(1);
draw_set_color(c_white);
