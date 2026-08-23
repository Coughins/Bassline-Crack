var _p = telegraph_timer / telegraph_life;

if (void_alpha > 0)
{
    draw_set_color(c_black);
    draw_set_alpha(void_alpha * 0.85);
    draw_circle(x, y, void_radius, false);

    draw_set_alpha(void_alpha * 0.4);
    draw_circle(x, y, void_radius * 1.5, false);
    draw_set_alpha(1);
}

gpu_set_blendmode(bm_add);

for (var i = 0; i < array_length(shock_rings); i++)
{
    var _sr = shock_rings[i];
    var _sa = _sr.life / _sr.life_max;
    draw_set_color(global.lightning_color);
    draw_set_alpha(_sa * 0.5);
    draw_circle(x, y, _sr.r, true);
    draw_set_color(c_white);
    draw_set_alpha(_sa * 0.25);
    draw_circle(x, y, _sr.r - 1, true);
}

for (var i = 0; i < array_length(claws); i++)
{
    var _cw = claws[i];
    var _ca = _cw.life / _cw.life_max;
    var _segs = 4;
    var _px = x, _py = y;
    for (var s = 1; s <= _segs; s++)
    {
        var _ct = s / _segs;
        var _jit = (s == _segs) ? 0 : sin(_cw.seed + s * 2.4) * 7 * _ct;
        var _nx = x + lengthdir_x(_cw.len * _ct, _cw.ang) + lengthdir_x(_jit, _cw.ang + 90);
        var _ny = y + lengthdir_y(_cw.len * _ct, _cw.ang) + lengthdir_y(_jit, _cw.ang + 90);
        draw_set_color(global.lightning_color);
        draw_set_alpha(_ca * 0.45 * (1 - _ct * 0.6));
        draw_line_width(_px, _py, _nx, _ny, 3);
        draw_set_color(c_white);
        draw_set_alpha(_ca * 0.7 * (1 - _ct * 0.6));
        draw_line_width(_px, _py, _nx, _ny, 1);
        _px = _nx;
        _py = _ny;
    }
}

for (var i = 0; i < particle_count; i++) {
    var _px2 = x + lengthdir_x(current_radius, particle_angles[i]);
    var _py2 = y + lengthdir_y(current_radius, particle_angles[i]);

    draw_set_color(global.lightning_color);
    draw_set_alpha(current_alpha * 0.55);
    draw_line_width(particle_prev_x[i], particle_prev_y[i], _px2, _py2, 5);
    draw_set_color(c_white);
    draw_set_alpha(current_alpha);
    draw_line_width(particle_prev_x[i], particle_prev_y[i], _px2, _py2, 2);
    draw_circle(_px2, _py2, 3, false);
}

if (seam_length > 1)
{
    var _joints = array_length(seam_jag);
    var _perp = seam_angle + 90;

    for (var _pass = 0; _pass < 3; _pass++)
    {
        var _off = 0;
        var _col = c_white;
        var _w = 2.5;
        var _a = current_alpha;
        if (_pass == 0) { _off = -chroma; _col = c_red;   _w = 4; _a = current_alpha * 0.6; }
        if (_pass == 1) { _off =  chroma; _col = c_aqua;  _w = 4; _a = current_alpha * 0.6; }

        draw_set_color(_col);
        draw_set_alpha(_a);

        var _sx0 = x - lengthdir_x(seam_length, seam_angle) + lengthdir_x(_off, _perp);
        var _sy0 = y - lengthdir_y(seam_length, seam_angle) + lengthdir_y(_off, _perp);
        var _prevx = _sx0, _prevy = _sy0;

        for (var j = 0; j <= _joints; j++)
        {
            var _jt = (j + 1) / (_joints + 1);
            var _jx = lerp(-seam_length, seam_length, _jt);
            var _jo = (j < _joints) ? seam_jag[j] : 0;
            var _nx2 = x + lengthdir_x(_jx, seam_angle) + lengthdir_x(_jo + _off, _perp);
            var _ny2 = y + lengthdir_y(_jx, seam_angle) + lengthdir_y(_jo + _off, _perp);

            var _taper = 1 - abs(_jt * 2 - 1);
            draw_line_width(_prevx, _prevy, _nx2, _ny2, max(0.5, _w * (0.35 + _taper)));
            _prevx = _nx2;
            _prevy = _ny2;
        }
    }
}

gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color, 1, 1, 1);
shader_set_uniform_f(global.u_glow_intensity, 0.4 + _p * _p * 1.6);
shader_set_uniform_f(global.u_glow_falloff, 1.5);
var _hs = 0.25 + _p * _p * 0.7 + sin(telegraph_timer * 0.6) * 0.04;
draw_sprite_ext(spr_glow_blob, 0, x, y, _hs, _hs, 0, c_white, 1);
shader_reset();
gpu_set_blendequation(bm_eq_add);

draw_set_color(c_white);
draw_set_alpha(current_alpha * 0.35);
draw_circle(x, y, 6 + sin(telegraph_timer * 20) * 3, false);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
