function scr_death_start(_inst) {
    if (!instance_exists(_inst)) return noone;

    var _spr = _inst.sprite_index;
    if (!sprite_exists(_spr)) _spr = sPlayerIdle;

    var _fx = instance_create_depth(_inst.x, _inst.y, global.player_blood_depth, oPlayerDeath);

    _fx.body_sprite = _spr;
    _fx.body_index  = floor(_inst.image_index);
    _fx.body_xscale = _inst.image_xscale;
    _fx.body_yscale = _inst.image_yscale;
    _fx.body_angle  = _inst.image_angle;
    _fx.death_x     = _inst.x;
    _fx.death_y     = _inst.y;

    var _vx = 0, _vy = 0;
    if (variable_instance_exists(_inst, "velocity")) {
        _vx = _inst.velocity.x;
        _vy = _inst.velocity.y;
    }
    _fx.inherit_vx = _vx;
    _fx.inherit_vy = _vy;

    _fx.death_init();
    return _fx;
}


function scr_death_clip_poly(_poly, _nx, _ny, _sign) {
    var _out = [];
    var _n = array_length(_poly);
    if (_n < 3) return _out;

    for (var i = 0; i < _n; i++) {
        var _a = _poly[i];
        var _b = _poly[(i + 1) % _n];
        var _da = (_a.x * _nx + _a.y * _ny) * _sign;
        var _db = (_b.x * _nx + _b.y * _ny) * _sign;
        var _ain = (_da >= 0);
        var _bin = (_db >= 0);

        if (_ain) array_push(_out, _a);

        if (_ain != _bin) {
            var _t = _da / (_da - _db);
            array_push(_out, {
                x : lerp(_a.x, _b.x, _t),
                y : lerp(_a.y, _b.y, _t),
                u : lerp(_a.u, _b.u, _t),
                v : lerp(_a.v, _b.v, _t)
            });
        }
    }
    return _out;
}


function scr_death_body_poly(_spr, _idx, _xs, _ys) {
    var _w  = sprite_get_width(_spr);
    var _h  = sprite_get_height(_spr);
    var _ox = sprite_get_xoffset(_spr);
    var _oy = sprite_get_yoffset(_spr);
    var _uv = sprite_get_uvs(_spr, _idx);

    var _l = _uv[4];
    var _t = _uv[5];
    var _r = _uv[4] + _w * _uv[6];
    var _b = _uv[5] + _h * _uv[7];

    var _px = [_l,     _r,     _r,     _l    ];
    var _py = [_t,     _t,     _b,     _b    ];
    var _pu = [_uv[0], _uv[2], _uv[2], _uv[0]];
    var _pv = [_uv[1], _uv[1], _uv[3], _uv[3]];

    var _poly = [];
    for (var i = 0; i < 4; i++) {
        array_push(_poly, {
            x : (_px[i] - _ox) * _xs,
            y : (_py[i] - _oy) * _ys,
            u : _pu[i],
            v : _pv[i]
        });
    }
    return _poly;
}


function scr_death_chunk_poly(_count, _min_r, _max_r) {
    var _poly = [];
    var _n = max(3, floor(_count));
    for (var i = 0; i < _n; i++) {
        var _ang = (i / _n) * 360 + random_range(-16, 16);
        var _rad = random_range(_min_r, _max_r);
        array_push(_poly, {
            x : lengthdir_x(_rad, _ang),
            y : lengthdir_y(_rad, _ang)
        });
    }
    return _poly;
}


function scr_death_draw_flat_poly(_poly, _cx, _cy, _rot, _sx, _sy, _col, _alpha) {
    var _n = array_length(_poly);
    if (_n < 3 || _alpha <= 0) exit;

    var _c = dcos(_rot);
    var _s = dsin(_rot);

    draw_primitive_begin(pr_trianglefan);
    for (var i = 0; i < _n; i++) {
        var _p = _poly[i];
        var _px = _p.x * _sx;
        var _py = _p.y * _sy;
        draw_vertex_colour(
            _cx + _px * _c + _py * _s,
            _cy - _px * _s + _py * _c,
            _col, _alpha);
    }
    draw_primitive_end();
}


function scr_death_draw_poly(_poly, _cx, _cy, _rot, _tex, _col, _alpha) {
    var _n = array_length(_poly);
    if (_n < 3 || _alpha <= 0) exit;

    var _c = dcos(_rot);
    var _s = dsin(_rot);

    draw_primitive_begin_texture(pr_trianglefan, _tex);
    for (var i = 0; i < _n; i++) {
        var _p = _poly[i];
        draw_vertex_texture_colour(
            _cx + _p.x * _c + _p.y * _s,
            _cy - _p.x * _s + _p.y * _c,
            _p.u, _p.v, _col, _alpha);
    }
    draw_primitive_end();
}


function scr_death_draw_ribbon(_nodes, _w_max, _col, _alpha) {
    var _n = array_length(_nodes);
    if (_n < 2 || _alpha <= 0) exit;

    draw_primitive_begin(pr_trianglestrip);
    for (var i = 0; i < _n; i++) {
        var _p    = _nodes[i];
        var _prev = _nodes[max(i - 1, 0)];
        var _next = _nodes[min(i + 1, _n - 1)];

        var _dir = point_direction(_prev.x, _prev.y, _next.x, _next.y);
        var _f   = i / (_n - 1);
        var _w   = _w_max * (1 - _f * 0.78) * _p.w;

        var _nx = lengthdir_x(_w, _dir + 90);
        var _ny = lengthdir_y(_w, _dir + 90);
        var _a  = _alpha * _p.a;

        draw_vertex_colour(_p.x - _nx, _p.y - _ny, _col, _a);
        draw_vertex_colour(_p.x + _nx, _p.y + _ny, _col, _a);
    }
    draw_primitive_end();
}


function scr_death_room_to_gui(_rx, _ry) {
    var _cx, _cy, _cw, _ch;

    if (instance_exists(oCameraController)) {
        _cx = oCameraController.current_cam_x;
        _cy = oCameraController.current_cam_y;
        _cw = oCameraController.current_cam_w;
        _ch = oCameraController.current_cam_h;
    } else {
        var _cam = view_camera[0];
        _cx = camera_get_view_x(_cam);
        _cy = camera_get_view_y(_cam);
        _cw = camera_get_view_width(_cam);
        _ch = camera_get_view_height(_cam);
    }

    if (_cw <= 0 || _ch <= 0) return { x : _rx, y : _ry };

    return {
        x : (_rx - _cx) / _cw * display_get_gui_width(),
        y : (_ry - _cy) / _ch * display_get_gui_height()
    };
}


function scr_death_ground_probe(_px, _py, _max_drop) {
    var _step = 4;
    for (var _d = 0; _d <= _max_drop; _d += _step) {
        if (position_meeting(_px, _py + _d, oBlock)) return _py + _d;
    }
    return undefined;
}


function scr_death_blood_colour(_heat) {
    var _h = clamp(_heat, 0, 1);
    if (_h < 0.5) {
        return merge_colour(make_colour_rgb(74, 4, 10), make_colour_rgb(196, 12, 24), _h / 0.5);
    }
    return merge_colour(make_colour_rgb(196, 12, 24), make_colour_rgb(255, 228, 226), (_h - 0.5) / 0.5);
}
