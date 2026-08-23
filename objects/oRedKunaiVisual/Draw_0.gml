event_inherited();

if (!finale_mode)
{
    var _default_red = make_color_rgb(185, 18, 22);
    var _default_body = merge_color(_default_red, image_blend, 0.18);

    gpu_set_blendmode(bm_add);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, _default_body, image_alpha);
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 0.42, image_yscale * 0.92,
                    image_angle, c_white, image_alpha * 0.22);
    gpu_set_blendmode(bm_normal);
    exit;
}

var _cold = global.avoid_col_danger;
var _mid = make_color_rgb(255, 130, 70);
var _hot = make_color_rgb(255, 232, 205);
var _red_metal = make_color_rgb(185, 18, 22);
var _body = (finale_hue < 0.5) ? merge_color(_cold, _mid, finale_hue * 2)
                               : merge_color(_mid, _hot, (finale_hue - 0.5) * 2);
var _blade_body = merge_color(_red_metal, _body, 0.45 + finale_hue * 0.2);
var _core = merge_color(_body, c_white, clamp(0.45 + finale_heat * 0.55 + plant_flash * 0.5, 0, 1));
var _finale_fx_dim = 0.42;
var _finale_glow_dim = 0.28;
if (instance_exists(oAvoidanceController)) {
    _finale_fx_dim = oAvoidanceController._k_bh_finale_kunai_fx_mult;
    _finale_glow_dim = oAvoidanceController._k_bh_finale_kunai_glow_mult;
}

gpu_set_blendmode(bm_add);

if (finale_motion_mode > 0)
{
    var _birth = 1 - clamp(finale_motion_timer / 8, 0, 1);
    var _death = 1 - clamp((finale_motion_life - finale_motion_timer) / max(1, finale_motion_fade), 0, 1);
    var _sig = max(_birth, _death);

    if (_sig > 0.02)
    {
        var _sr = 10 + _sig * 24 + finale_hue * 10;
        draw_set_color(_core);
        draw_set_alpha(_sig * image_alpha * 0.45 * _finale_fx_dim);
        draw_circle(x, y, _sr, false);

        draw_set_color(c_white);
        draw_set_alpha(_sig * image_alpha * 0.55 * _finale_fx_dim);
        for (var _sg = 0; _sg < 4; _sg++)
        {
            var _sa = direction + _sg * 90 + current_time * 0.035;
            draw_line_width(x + lengthdir_x(_sr * 0.35, _sa), y + lengthdir_y(_sr * 0.35, _sa),
                            x + lengthdir_x(_sr, _sa), y + lengthdir_y(_sr, _sa), 1.4);
        }
    }
}

var _tn = array_length(trail_positions);
for (var i = 0; i < _tn - 1; i++)
{
    var _p0 = trail_positions[i];
    var _p1 = trail_positions[i + 1];
    var _ta = (i / _tn) * image_alpha;
    var _tw = 1 + (i / _tn) * (3 + stretch * 1.4);

    draw_set_color(_body);
    draw_set_alpha(_ta * 0.4 * _finale_fx_dim);
    draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], _tw * 2.6);

    draw_set_color(_core);
    draw_set_alpha(_ta * 0.75 * _finale_fx_dim);
    draw_line_width(_p0[0], _p0[1], _p1[0], _p1[1], _tw);
}

for (var i = 0; i < array_length(afterimages); i++)
{
    var _g = afterimages[i];
    var _ga = (_g.life / _g.life_max) * image_alpha * 0.4 * _finale_fx_dim;
    draw_sprite_ext(sprite_index, image_index, _g.x, _g.y, image_xscale * 1.05, image_yscale * 0.9, _g.dir, _body, _ga);
}

if (stretch > 1.2)
{
    var _perp = direction + 90;
    var _off = (stretch - 1) * 2.6;
    draw_sprite_ext(sprite_index, image_index, x + lengthdir_x(_off, _perp), y + lengthdir_y(_off, _perp),
                    image_xscale * stretch, image_yscale, image_angle, c_red, image_alpha * 0.45 * _finale_fx_dim);
    draw_sprite_ext(sprite_index, image_index, x - lengthdir_x(_off, _perp), y - lengthdir_y(_off, _perp),
                    image_xscale * stretch, image_yscale, image_angle, c_aqua, image_alpha * 0.45 * _finale_fx_dim);
}

if (finale_heat > 0.05)
{
    var _sl = 14 + finale_heat * 40;
    draw_set_color(_core);
    draw_set_alpha(finale_heat * 0.65 * image_alpha * _finale_fx_dim);
    draw_line_width(x - lengthdir_x(_sl, direction), y - lengthdir_y(_sl, direction), x, y, 2 + finale_heat * 6);
}

if (band_mode && band_fin > 0.3)
{

    var _hum = 0.82 + 0.18 * sin(current_time * 0.012 + band_slot * 0.7);
    var _fh = band_fin * _hum;
    var _fa = image_alpha * (0.5 + plant_flash * 0.5) * _finale_fx_dim;

    draw_primitive_begin(pr_trianglestrip);
    draw_vertex_color(x - 5, y - _fh, _body, 0);
    draw_vertex_color(x + 5, y - _fh, _body, 0);
    draw_vertex_color(x - 5, y, _core, _fa * 0.8);
    draw_vertex_color(x + 5, y, _core, _fa * 0.8);
    draw_vertex_color(x - 5, y + _fh, _body, 0);
    draw_vertex_color(x + 5, y + _fh, _body, 0);
    draw_primitive_end();

    draw_set_color(_core);
    draw_set_alpha(_fa * 0.9);
    draw_line_width(x, y - _fh * 0.8, x, y + _fh * 0.8, 1.6);

    if (band_planted > 0.5 && (current_time div 40 + band_slot) mod 3 == 0)
    {
        var _asegs = 3;
        var _ax = x, _ay = y - _fh;
        for (var a = 1; a <= _asegs; a++)
        {
            var _at = a / _asegs;
            var _nx2 = x + sin(arc_seed + a * 2.3 + current_time * 0.02) * 5;
            var _ny2 = lerp(y - _fh, y + _fh, _at);
            draw_set_color(c_white);
            draw_set_alpha(image_alpha * 0.75 * _finale_fx_dim);
            draw_line_width(_ax, _ay, _nx2, _ny2, 1.2);
            _ax = _nx2;
            _ay = _ny2;
        }
    }
}

if (plant_flash > 0.02)
{
    var _pf = plant_flash * plant_flash;
    draw_set_color(c_white);
    draw_set_alpha(_pf * 0.9 * _finale_fx_dim);

    draw_line_width(x - lengthdir_x(34 * _pf, direction), y - lengthdir_y(34 * _pf, direction),
                    x + lengthdir_x(34 * _pf, direction), y + lengthdir_y(34 * _pf, direction), 2.5);
    draw_line_width(x, y - 26 * _pf, x, y + 26 * _pf, 2);
    draw_set_color(_core);
    draw_set_alpha(_pf * 0.55 * _finale_fx_dim);
    draw_circle(x, y, 5 + _pf * 14, false);
}

for (var i = 0; i < array_length(embers); i++)
{
    var _e3 = embers[i];
    var _ea = _e3.life / _e3.life_max;
    draw_set_color(scr_hot_metal_color(1 - _ea));
    draw_set_alpha(_ea * image_alpha * _finale_fx_dim);
    draw_line_width(_e3.x - _e3.vx * 2.5, _e3.y - _e3.vy * 2.5, _e3.x, _e3.y, _e3.size);
}

draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * stretch, image_yscale / max(1, sqrt(stretch)),
                image_angle, merge_color(_blade_body, _core, 0.35 + finale_heat * 0.45), image_alpha);

gpu_set_blendequation(bm_eq_max);
shader_set(shd_bullet_glow);
var _uvs = sprite_get_uvs(spr_glow_blob, 0);
shader_set_uniform_f(global.u_glow_uvrect, _uvs[0], _uvs[1], _uvs[2], _uvs[3]);
shader_set_uniform_f(global.u_glow_color, color_get_red(_core) / 255, color_get_green(_core) / 255,
                     color_get_blue(_core) / 255);
shader_set_uniform_f(global.u_glow_intensity,
                     (0.75 + finale_heat * 1.1 + finale_hue * 0.4 + plant_flash * 1.4 + band_planted * 0.5) * image_alpha * _finale_glow_dim);
shader_set_uniform_f(global.u_glow_falloff, 1.35);

var _gs = 0.22 * (1 + finale_heat * 0.55 + plant_flash * 0.45);
draw_sprite_ext(spr_glow_blob, 0, x, y, _gs, _gs * (1 + band_planted * 0.9), 0, c_white, 1);
shader_reset();
gpu_set_blendequation(bm_eq_add);

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);
