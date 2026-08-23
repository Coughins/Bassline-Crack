

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

for (var i = 0; i < array_length(floor_smears); i++) {
    var _sm = floor_smears[i];
    draw_set_alpha(_sm.alpha);
    draw_set_colour(scr_death_blood_colour(_sm.heat));
    draw_line_width(_sm.x1, _sm.y1, _sm.x2, _sm.y2, _sm.w);

    draw_set_alpha(_sm.alpha * 0.65);
    draw_set_colour(scr_death_blood_colour(0));
    draw_line_width(_sm.x1, _sm.y1, _sm.x2, _sm.y2, max(1, _sm.w * 0.38));
}
draw_set_alpha(1);

for (var i = 0; i < array_length(decals); i++) {
    var _dc = decals[i];
    draw_set_alpha(_dc.alpha);
    draw_set_colour(scr_death_blood_colour(_dc.heat));
    draw_ellipse(_dc.x - _dc.rx, _dc.y - _dc.ry,
                 _dc.x + _dc.rx, _dc.y + _dc.ry, false);

    draw_set_alpha(_dc.alpha * 0.75);
    draw_set_colour(scr_death_blood_colour(0));
    draw_ellipse(_dc.x - _dc.rx * 0.55, _dc.y - _dc.ry * 0.55,
                 _dc.x + _dc.rx * 0.55, _dc.y + _dc.ry * 0.55, false);
}
draw_set_alpha(1);

for (var r = 0; r < array_length(ribbons); r++) {
    var _rb = ribbons[r];
    scr_death_draw_ribbon(_rb.nodes, _rb.width * 1.35, scr_death_blood_colour(0.05), 0.95);
    scr_death_draw_ribbon(_rb.nodes, _rb.width * 0.55, scr_death_blood_colour(0.55), 0.9);
}

for (var i = 0; i < array_length(droplets); i++) {
    var _d = droplets[i];
    var _a = clamp(_d.life / _d.life_max, 0, 1);

    if (_d.landed) {
        draw_set_alpha(_a * 0.9);
        draw_set_colour(scr_death_blood_colour(0.1));
        draw_ellipse(_d.x - _d.size * 1.4, _d.y - _d.size * 0.5,
                     _d.x + _d.size * 1.4, _d.y + _d.size * 0.5, false);
    } else {
        var _sp  = point_distance(0, 0, _d.vx, _d.vy);
        var _dir = point_direction(0, 0, _d.vx, _d.vy);
        var _len = _d.size * (1 + _sp * 0.55);
        var _tx  = _d.x + lengthdir_x(_len, _dir);
        var _ty  = _d.y + lengthdir_y(_len, _dir);

        draw_set_alpha(_a);
        draw_set_colour(scr_death_blood_colour(0.35));
        draw_line_width(_d.x, _d.y, _tx, _ty, max(1, _d.size));
    }
}
draw_set_alpha(1);

for (var i = 0; i < array_length(chunks); i++) {
    var _ch = chunks[i];
    var _f = clamp(_ch.life / _ch.life_max, 0, 1);
    var _a = min(1, _f * 1.8);
    var _ys = _ch.landed ? 0.42 : 0.92;
    var _col = scr_death_blood_colour(_ch.heat * (0.35 + _f * 0.65));

    scr_death_draw_flat_poly(_ch.poly, _ch.x, _ch.y, _ch.rot,
        _ch.size, _ch.size * _ys, _col, _a);

    scr_death_draw_flat_poly(_ch.poly, _ch.x, _ch.y, _ch.rot,
        _ch.size * 0.52, _ch.size * _ys * 0.52, scr_death_blood_colour(0), _a * 0.72);
}

gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(splinters); i++) {
    var _spn = splinters[i];
    var _f = clamp(_spn.life / _spn.life_max, 0, 1);
    var _len = _spn.len * (0.55 + _f * 0.55);
    var _tx = _spn.x + lengthdir_x(_len, _spn.ang);
    var _ty = _spn.y + lengthdir_y(_len, _spn.ang);

    draw_set_alpha(_f * 0.72);
    draw_set_colour(scr_death_blood_colour(_spn.heat));
    draw_line_width(_spn.x, _spn.y, _tx, _ty, _spn.w * 2.6);

    draw_set_alpha(_f);
    draw_set_colour(c_white);
    draw_line_width(_spn.x, _spn.y, _tx, _ty, max(1, _spn.w * 0.55));
}
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

if (!body_split) {

    gpu_set_blendmode(bm_add);
    for (var i = 0; i < array_length(motes); i++) {
        var _m  = motes[i];
        var _mx = death_x + lengthdir_x(_m.dist, _m.ang);
        var _my = death_y + lengthdir_y(_m.dist, _m.ang);
        var _ma = clamp(1 - _m.dist / 250, 0, 1) * overload;

        var _dir = point_direction(_mx, _my, death_x, death_y);
        var _tl  = 6 + _m.speed * 4;

        draw_set_alpha(_ma * 0.85);
        draw_set_colour(merge_colour(scr_death_blood_colour(0.6), c_white, _m.hot * 0.5));
        draw_line_width(_mx, _my,
            _mx + lengthdir_x(_tl, _dir), _my + lengthdir_y(_tl, _dir),
            max(1, _m.size));
    }
    gpu_set_blendmode(bm_normal);

    for (var i = 0; i < array_length(arcs); i++) {
        var _ac = arcs[i];
        var _f  = clamp(_ac.life / _ac.life_max, 0, 1);
        var _col = merge_colour(scr_death_blood_colour(0.85), c_white, _ac.hot);

        var _segs = 5;
        var _px = _ac.x1, _py = _ac.y1;
        var _jit = 7 * _f;

        gpu_set_blendmode(bm_add);
        for (var s = 1; s <= _segs; s++) {
            var _st = s / _segs;
            var _nx = lerp(_ac.x1, _ac.x2, _st) + random_range(-_jit, _jit);
            var _ny = lerp(_ac.y1, _ac.y2, _st) + random_range(-_jit, _jit);
            if (s == _segs) { _nx = _ac.x2; _ny = _ac.y2; }

            draw_set_alpha(_f * 0.35);
            draw_set_colour(_col);
            draw_line_width(_px, _py, _nx, _ny, 3.5);

            draw_set_alpha(_f);
            draw_set_colour(c_white);
            draw_line_width(_px, _py, _nx, _ny, 1);

            _px = _nx; _py = _ny;
        }
        gpu_set_blendmode(bm_normal);
    }
    draw_set_alpha(1);

    var _sx = death_x + random_range(-body_shake, body_shake);
    var _sy = death_y + random_range(-body_shake, body_shake);

    draw_sprite_ext(body_sprite, body_index, _sx, _sy,
        body_xscale, body_yscale, body_angle, c_white, 1);

    if (body_white > 0.02) {
        gpu_set_blendmode(bm_add);
        draw_sprite_ext(body_sprite, body_index, _sx, _sy,
            body_xscale, body_yscale, body_angle,
            merge_colour(scr_death_blood_colour(0.8), c_white, body_white), body_white);

        var _rim = body_white * 0.5;
        if (_rim > 0.03) {
            for (var o = 0; o < 4; o++) {
                var _ox = lengthdir_x(1 + body_white * 1.6, o * 90);
                var _oy = lengthdir_y(1 + body_white * 1.6, o * 90);
                draw_sprite_ext(body_sprite, body_index, _sx + _ox, _sy + _oy,
                    body_xscale, body_yscale, body_angle, c_white, _rim * 0.4);
            }
        }
        gpu_set_blendmode(bm_normal);
    }
}

if (body_split) {
    var _tex = sprite_get_texture(body_sprite, body_index);
    var _halves = [half_a, half_b];

    for (var h = 0; h < 2; h++) {
        var _p = _halves[h];
        if (is_undefined(_p)) continue;

        scr_death_draw_poly(_p.poly, _p.cx, _p.cy, _p.rot, _tex, c_white, 1);

        if (cut_flash > 0.01) {
            gpu_set_blendmode(bm_add);
            scr_death_draw_poly(_p.poly, _p.cx, _p.cy, _p.rot, _tex,
                merge_colour(scr_death_blood_colour(0.7), c_white, cut_flash), cut_flash * 0.8);
            gpu_set_blendmode(bm_normal);
        }
    }
}

gpu_set_blendmode(bm_add);
for (var i = 0; i < array_length(embers); i++) {
    var _e = embers[i];
    var _f = clamp(_e.life / _e.life_max, 0, 1);
    var _dir = point_direction(0, 0, _e.vx, _e.vy);
    var _len = _e.size * (1 + point_distance(0, 0, _e.vx, _e.vy) * 0.7);

    draw_set_alpha(_f);
    draw_set_colour(merge_colour(scr_death_blood_colour(0.5), c_white, _f * 0.6));
    draw_line_width(_e.x, _e.y,
        _e.x + lengthdir_x(_len, _dir), _e.y + lengthdir_y(_len, _dir),
        max(1, _e.size * _f));
}
gpu_set_blendmode(bm_normal);

draw_set_alpha(1);
draw_set_colour(c_white);
