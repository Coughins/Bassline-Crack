// ============================================================================
// FINAL CUT WARP - GUI HANDOFF
// DRAWN AFTER THE ROOM COMPOSITE.
// ============================================================================

if (!fw_warped) {
  if (room != fw_source_room) { instance_destroy(); exit; }
} else if (fw_ph > _k_fw_seal + 2 && room != fw_target_room) {
  instance_destroy();
  exit;
}

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
if (_gw < 1) _gw = GAME_WIDTH;
if (_gh < 1) _gh = GAME_HEIGHT;
var _gs = _gw / GAME_WIDTH;

var _ax = fw_axis(_gw, _gh);
var _p  = fw_ph;

var _rout = fw_front_out(_p, _ax, _gs);
var _rin  = fw_front_in(_p, _ax, _gs);
var _vout = _rout - fw_front_out(max(_p - 1, 0), _ax, _gs);
var _vin  = _rin  - fw_front_in(max(_p - 1, 0), _ax, _gs);

var _eout = clamp(_vout * _k_fw_edge_blur, _k_fw_edge_min * _gs, _k_fw_edge_max * _gs);
_eout = min(_eout, _rout * 0.85);
var _ein = clamp(_vin * _k_fw_edge_blur, _k_fw_edge_min * _gs, _k_fw_edge_max * _gs);

var _len = lerp(max(fw_span0, 0.06) * _ax.diag * 0.5, _ax.diag * 0.78,
                power(clamp(_p / 6, 0, 1), 0.55))
         + max(0, _p - 6) * _ax.diag * 0.008;

var _seal_p = clamp(_p / _k_fw_seal, 0, 1);
var _born = clamp((_p + 1) / 3, 0, 1);

var _c_cyan  = global.avoid_col_cyan;
var _c_soft  = global.avoid_col_cyan_soft;
var _c_lead  = merge_color(_c_cyan, _c_soft, 0.55);
var _c_core  = merge_color(_c_soft, c_white, 0.45 + _seal_p * 0.45);
var _c_trail = merge_color(_c_soft, c_white, 0.70);

shader_reset();
gpu_set_blendequation(bm_eq_add);
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

var _full = (_rin > 0.5) ? 0
          : clamp((_rout - _eout - _ax.rmax) / (30 * _gs), 0, 1) * _born;
if (_full > 0.002) {
  draw_set_color(_c_cyan);
  draw_set_alpha(_full);
  draw_rectangle(0, 0, _gw, _gh, false);
}

if (_rin <= 0.5) {
  var _mid = min(_rout * 0.42, 170 * _gs);
  fw_draw_band([
    { d : -_rout,         col : c_white, a : 0 },
    { d : -_rout + _eout, col : _c_lead, a : 1 },
    { d : -_mid,          col : _c_cyan, a : 1 },
    { d :  0,             col : _c_core, a : 1 },
    { d :  _mid,          col : _c_cyan, a : 1 },
    { d :  _rout - _eout, col : _c_lead, a : 1 },
    { d :  _rout,         col : c_white, a : 0 }
  ], _ax, _len, _born);
}
else {
  var _d0 = _rin;
  var _d1 = max(_d0, _rin + _ein);
  var _d2 = max(_d1, _d1 + 130 * _gs);
  var _d3 = max(_d2, _rout - _eout);
  var _d4 = max(_d3, _rout);

  fw_draw_band([
    { d : _d0, col : _c_trail, a : 0 },
    { d : _d1, col : _c_trail, a : 1 },
    { d : _d2, col : _c_cyan,  a : 1 },
    { d : _d3, col : _c_lead,  a : 1 },
    { d : _d4, col : c_white,  a : 0 }
  ], _ax, _len, 1);

  fw_draw_band([
    { d : -_d4, col : c_white,  a : 0 },
    { d : -_d3, col : _c_lead,  a : 1 },
    { d : -_d2, col : _c_cyan,  a : 1 },
    { d : -_d1, col : _c_trail, a : 1 },
    { d : -_d0, col : _c_trail, a : 0 }
  ], _ax, _len, 1);
}

gpu_set_blendmode(bm_add);

fw_draw_front(_ax,  _rout, _len, _vout, _gs, _born);
fw_draw_front(_ax, -_rout, _len, _vout, _gs, _born);

if (_rin > 0.5) {
  var _tp = clamp(1 - (_p - (_k_fw_seal + _k_fw_hold)) / (_k_fw_open * 1.15), 0.18, 1);
  fw_draw_front(_ax,  _rin, _len, _vin, _gs, _tp);
  fw_draw_front(_ax, -_rin, _len, _vin, _gs, _tp);
}

if (_p <= _k_fw_seal + _k_fw_hold) {
  var _bx0 = _ax.cx - _ax.ux * _len, _by0 = _ax.cy - _ax.uy * _len;
  var _bx1 = _ax.cx + _ax.ux * _len, _by1 = _ax.cy + _ax.uy * _len;
  var _cb  = 0.35 + _seal_p * 0.65;

  draw_set_color(_c_soft);
  draw_set_alpha(_cb * 0.30 * _born);
  draw_line_width(_bx0, _by0, _bx1, _by1, (14 + _seal_p * 44) * _gs);

  draw_set_color(c_white);
  draw_set_alpha(_cb * 0.85 * _born);
  draw_line_width(_bx0, _by0, _bx1, _by1, (2.2 + _seal_p * 4.5) * _gs);
}

var _scar_from = _k_fw_seal + _k_fw_hold;
var _scar_n    = array_length(fw_scar_pts);
if (_p > _scar_from && _scar_n > 1) {
  var _sr = clamp((_p - _scar_from) / max(_k_fw_open + _k_fw_tail, 1), 0, 1);
  var _sa = power(1 - _sr, 1.5);

  if (_sa > 0.01) {
    var _sx0 = 0,   _sy0 = _gh;
    var _sx1 = _gw, _sy1 = 0;

    var _pp = fw_scar_pts[0];
    var _px = lerp(_sx0, _sx1, _pp.f) + _ax.nx * _pp.off * _gs;
    var _py = lerp(_sy0, _sy1, _pp.f) + _ax.ny * _pp.off * _gs;

    for (var _si = 1; _si < _scar_n; _si++) {
      var _np = fw_scar_pts[_si];
      var _nx = lerp(_sx0, _sx1, _np.f) + _ax.nx * _np.off * _gs;
      var _ny = lerp(_sy0, _sy1, _np.f) + _ax.ny * _np.off * _gs;
      var _sw = (_pp.w + _np.w) * 0.5;

      draw_set_color(_c_cyan);
      draw_set_alpha(_sa * 0.16);
      draw_line_width(_px, _py, _nx, _ny, (7 + _sa * 12) * _sw * _gs);

      draw_set_color(_c_soft);
      draw_set_alpha(_sa * 0.42);
      draw_line_width(_px, _py, _nx, _ny, (1.4 + _sa * 2.2) * _sw * _gs);

      draw_set_color(c_white);
      draw_set_alpha(_sa * _sa * 0.72);
      draw_line_width(_px, _py, _nx, _ny, 1.1 * _gs);

      _pp = _np; _px = _nx; _py = _ny;
    }
  }
}

for (var _sd = 0; _sd < array_length(fw_sparks); _sd++) {
  var _sp = fw_sparks[_sd];
  var _spa = power(clamp(_sp.life / _sp.life_max, 0, 1), 1.4);
  if (_spa <= 0.02) continue;

  var _sgx = _sp.x * _gs;
  var _sgy = _sp.y * _gs;

  draw_set_color(_sp.col);
  draw_set_alpha(_spa * 0.46);
  draw_line_width(_sgx, _sgy,
                  (_sp.x - _sp.vx * 3.0) * _gs, (_sp.y - _sp.vy * 3.0) * _gs,
                  max(1, _sp.size * _gs));

  draw_set_color(merge_color(_sp.col, c_white, 0.5 + _sp.hot * 0.5));
  draw_set_alpha(_spa * _spa * 0.9);
  draw_circle(_sgx, _sgy, max(0.7, _sp.size * 0.5 * _gs), false);
}

var _flash = clamp((5 - abs(_p - _k_fw_seal)) / 5, 0, 1);
if (_flash > 0.01) {
  draw_set_color(c_white);
  draw_set_alpha(power(_flash, 2.2) * 0.55);
  draw_rectangle(0, 0, _gw, _gh, false);
}

if (_p >= _scar_from) {
  var _wr = clamp((_p - _scar_from) / max(_k_fw_open + _k_fw_tail, 1), 0, 1);
  draw_set_color(_c_cyan);
  draw_set_alpha(power(1 - _wr, 2.2) * 0.20);
  draw_rectangle(0, 0, _gw, _gh, false);
}

draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_blendmode(bm_normal);
gpu_set_blendequation(bm_eq_add);

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
for (var _su = array_length(fw_sparks) - 1; _su >= 0; _su--) {
  var _spk = fw_sparks[_su];
  _spk.x  += _spk.vx;
  _spk.y  += _spk.vy;
  _spk.vx *= 0.972;
  _spk.vy  = _spk.vy * 0.972 + 0.045;
  _spk.life--;
  if (_spk.life <= 0) array_delete(fw_sparks, _su, 1);
}

fw_ph++;

if (fw_ph > _k_fw_life) instance_destroy();
