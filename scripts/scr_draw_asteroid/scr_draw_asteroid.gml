/// @param {real}  _y      draw y
/// @param {real}  _scale  camera scale
/// @param {real}  _color  base albedo of the rock
function scr_draw_asteroid(_x, _y, _rock, _scale, _color, _lights = [], _heat = 0, _flash = 0)
{
    var _verts = _rock.verts;
    var _count = array_length(_verts);
    var _light_n = array_length(_lights);

    var _fb_x = 0, _fb_y = 0;
    if (_light_n == 0)
    {
        _fb_x = 400 - _x;
        _fb_y = 304 - _y;
        var _fb_len = point_distance(0, 0, _fb_x, _fb_y);
        if (_fb_len > 0)
        {
            _fb_x /= _fb_len;
            _fb_y /= _fb_len;
        }
    }

    var _vx = array_create(_count, 0);
    var _vy = array_create(_count, 0);
    var _vlit = array_create(_count, 0);
    var _vcol = array_create(_count, _color);

    var _dark = make_color_rgb(35, 35, 40);

    for (var i = 0; i < _count; i++)
    {
        var _v = _verts[i];
        var _xx = _x + lengthdir_x(_v.rad * _scale, _v.ang + _rock.rotation);
        var _yy = _y + lengthdir_y(_v.rad * _scale, _v.ang + _rock.rotation);
        _vx[i] = _xx;
        _vy[i] = _yy;

        var _nx = _xx - _x;
        var _ny = _yy - _y;
        var _nlen = point_distance(0, 0, _nx, _ny);
        if (_nlen > 0)
        {
            _nx /= _nlen;
            _ny /= _nlen;
        }

        var _brightness = 0;
        var _tint = _color;

        if (_light_n == 0)
        {
            _brightness = (_nx * _fb_x + _ny * _fb_y) * 0.5 + 0.5;
        }
        else
        {
            var _best = 0;
            for (var l = 0; l < _light_n; l++)
            {
                var _lt = _lights[l];
                var _lx = _lt.x - _xx;
                var _ly = _lt.y - _yy;
                var _ld = max(1, point_distance(0, 0, _lx, _ly));
                _lx /= _ld;
                _ly /= _ld;

                var _atten = _lt.power * (520 * _scale) / (_ld + 220 * _scale);
                var _diff = max(0, _nx * _lx + _ny * _ly) * _atten;

                _brightness += _diff;
                if (_diff > _best)
                {
                    _best = _diff;
                    _tint = _lt.col;
                }
            }
            _brightness = clamp(_brightness * 0.5 + 0.25, 0, 1.4);
        }

        _brightness = clamp(_brightness, 0.28, 1.4);

        var _face = merge_color(_dark, _color, min(1, _brightness));
        if (_light_n > 0) _face = merge_color(_face, _tint, clamp(_brightness - 0.55, 0, 1) * 0.55);
        if (_flash > 0) _face = merge_color(_face, c_white, _flash * 0.85);

        _vlit[i] = clamp(_brightness, 0, 1.4);
        _vcol[i] = _face;
    }

    draw_primitive_begin(pr_trianglefan);
    draw_vertex_color(_x, _y, merge_color(_dark, _color, 0.55 + _flash * 0.45), 1);
    for (var i = 0; i < _count; i++)
    {
        draw_vertex_color(_vx[i], _vy[i], _vcol[i], 1);
    }
    draw_vertex_color(_vx[0], _vy[0], _vcol[0], 1);
    draw_primitive_end();

    if (_light_n > 0 || _flash > 0)
    {
        gpu_set_blendmode(bm_add);
        for (var i = 0; i < _count; i++)
        {
            var _j = (i + 1) mod _count;
            var _rim = clamp((max(_vlit[i], _vlit[_j]) - 0.55) / 0.75, 0, 1);
            _rim = max(_rim, _flash);
            if (_rim <= 0.02) continue;

            var _rim_col = (_light_n > 0) ? _vcol[i] : c_white;
            draw_set_color(merge_color(_rim_col, c_white, 0.45 + _flash * 0.55));
            draw_set_alpha(_rim * _rim * (0.55 + _flash * 0.45));
            draw_line_width(_vx[i], _vy[i], _vx[_j], _vy[_j], max(1, 1.6 * _scale));
        }
        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
    }

    var _stress = clamp(_rock.stress + _heat, 0, 1);
    var _crack_col = merge_color(make_color_rgb(15, 15, 18), global.lightning_color, _stress);
    if (_stress > 0.55) _crack_col = merge_color(_crack_col, scr_hot_metal_color(1 - _stress), (_stress - 0.55) / 0.45);
    if (_flash > 0) _crack_col = merge_color(_crack_col, c_white, _flash);

    draw_set_color(_crack_col);
    draw_set_alpha(0.65 + _stress * 0.35);

    for (var i = 0; i < array_length(_rock.cracks); i++)
    {
        var _cr = _rock.cracks[i];

        var _sx = _x + lengthdir_x(_cr.offset * _scale, _cr.angle + _rock.rotation);
        var _sy = _y + lengthdir_y(_cr.offset * _scale, _cr.angle + _rock.rotation);

        var _ex = _sx + lengthdir_x(_cr.length * _scale, _cr.angle + _rock.rotation);
        var _ey = _sy + lengthdir_y(_cr.length * _scale, _cr.angle + _rock.rotation);

        draw_line_width(_sx, _sy, _ex, _ey, max(1, _scale));
    }

    if (_stress > 0.6 || _flash > 0)
    {
        gpu_set_blendmode(bm_add);
        draw_set_color(merge_color(_crack_col, c_white, 0.5));
        draw_set_alpha(((_stress - 0.6) / 0.4) * 0.5 + _flash * 0.6);
        for (var i = 0; i < array_length(_rock.cracks); i++)
        {
            var _cr2 = _rock.cracks[i];
            var _sx2 = _x + lengthdir_x(_cr2.offset * _scale, _cr2.angle + _rock.rotation);
            var _sy2 = _y + lengthdir_y(_cr2.offset * _scale, _cr2.angle + _rock.rotation);
            var _ex2 = _sx2 + lengthdir_x(_cr2.length * _scale, _cr2.angle + _rock.rotation);
            var _ey2 = _sy2 + lengthdir_y(_cr2.length * _scale, _cr2.angle + _rock.rotation);
            draw_line_width(_sx2, _sy2, _ex2, _ey2, max(1, 2.6 * _scale));
        }
        gpu_set_blendmode(bm_normal);
    }

    draw_set_alpha(1);
}
