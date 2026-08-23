

function scr_lattice_spawn(_strike_index) {

    var _k_cell        = [96,   83  ];
    var _k_radius      = [330,  385 ];
    var _k_jitter      = [0.11, 0.17];
    var _k_grow        = [19,   15  ];
    var _k_cond        = [1,    1   ];
    var _k_loop        = [1,    1   ];
    var _k_step        = [2.8,  2.5 ];
    var _k_cross       = [4,    4   ];
    var _k_hold        = [5,    5   ];
    var _k_anchor_node = [false, true];
    var _k_inward      = [false, true];
    var _k_cool        = [12,   30  ];
    var _k_hit_rad     = [10,   10  ];

    var _k_surge_cap   = [26,   34  ];

    var _k_void_hole   = [0,    1   ];

    var _i = clamp(_strike_index, 0, 1);

    lat = undefined;

    var _cell   = _k_cell[_i];
    var _radius = _k_radius[_i];

    var _hx = _k_vault_cx;
    var _hy = _k_vault_cy;
    var _hole_r = _k_void_hole[_i] ? _k_vault_lattice_hole_r : 0;

    var _px = 400, _py = 304;
    if (instance_exists(oPlayer)) { _px = oPlayer.x; _py = oPlayer.y; }

    var _ox = _px, _oy = _py;
    if (_k_anchor_node[_i]) {
        _ox = _px - dcos(30) * _cell;
        _oy = _py + dsin(30) * _cell;
    }

    var _vx1 = -200, _vy1 = -170, _vx2 = room_width + 200, _vy2 = room_height + 170;
    if (instance_exists(oCameraController)) {
        _vx1 = oCameraController.current_cam_x - 30;
        _vy1 = oCameraController.current_cam_y - 30;
        _vx2 = _vx1 + oCameraController.current_cam_w + 60;
        _vy2 = _vy1 + oCameraController.current_cam_h + 60;
    }

    var _nodes = [];
    var _edges = [];
    var _cells = [];
    var _nmap = ds_map_create();
    var _emap = ds_map_create();

    var _hex_dir = [[1,0],[1,-1],[0,-1],[-1,0],[-1,1],[0,1]];
    var _span = ceil(_radius / (_cell * 1.5)) + 2;

    for (var _r = -_span; _r <= _span; _r++) {
        for (var _q = -_span; _q <= _span; _q++) {
            var _ccx = _ox + _cell * sqrt(3) * (_q + _r * 0.5);
            var _ccy = _oy + _cell * 1.5 * _r;

            if (point_distance(_ccx, _ccy, _ox, _oy) > _radius) continue;
            if (_ccx < _vx1 - _cell || _ccx > _vx2 + _cell) continue;
            if (_ccy < _vy1 - _cell || _ccy > _vy2 + _cell) continue;
            if (_hole_r > 0 && point_distance(_ccx, _ccy, _hx, _hy) < _hole_r) continue;

            var _corner = array_create(6, 0);

            for (var _k = 0; _k < 6; _k++) {
                var _cang = 30 + _k * 60;
                var _vx = _ccx + dcos(_cang) * _cell;
                var _vy = _ccy - dsin(_cang) * _cell;

                var _d1 = _hex_dir[_k];
                var _d2 = _hex_dir[(_k + 1) mod 6];
                var _own_r = _r,              _own_q = _q,              _own_k = _k;
                var _alt1_r = _r + _d1[1],    _alt1_q = _q + _d1[0],    _alt1_k = (_k + 2) mod 6;
                var _alt2_r = _r + _d2[1],    _alt2_q = _q + _d2[0],    _alt2_k = (_k + 4) mod 6;

                var _cr = _own_r, _cq = _own_q, _ck = _own_k;
                if (_alt1_r < _cr || (_alt1_r == _cr && (_alt1_q < _cq || (_alt1_q == _cq && _alt1_k < _ck)))) {
                    _cr = _alt1_r; _cq = _alt1_q; _ck = _alt1_k;
                }
                if (_alt2_r < _cr || (_alt2_r == _cr && (_alt2_q < _cq || (_alt2_q == _cq && _alt2_k < _ck)))) {
                    _cr = _alt2_r; _cq = _alt2_q; _ck = _alt2_k;
                }
                var _key = string(_cr) + "," + string(_cq) + "," + string(_ck);
                var _ni;
                if (ds_map_exists(_nmap, _key)) {
                    _ni = _nmap[? _key];
                } else {
                    _ni = array_length(_nodes);
                    array_push(_nodes, {
                        bx : _vx, by : _vy,
                        x  : _vx, y  : _vy,
                        ph : random(360),
                        d  : point_distance(_vx, _vy, _ox, _oy),
                        born : 0,
                        nbr : [], eid : [],
                        arr : -1,
                        lit : 0,
                        kx : 0, ky : 0,
                        kox : 0, koy : 0
                    });
                    ds_map_add(_nmap, _key, _ni);
                }
                _corner[_k] = _ni;
            }

            for (var _k = 0; _k < 6; _k++) {
                var _a = _corner[_k];
                var _b = _corner[(_k + 1) mod 6];
                if (_a == _b) continue;

                var _ekey = string(min(_a, _b)) + "-" + string(max(_a, _b));
                if (ds_map_exists(_emap, _ekey)) continue;

                var _ei = array_length(_edges);
                ds_map_add(_emap, _ekey, _ei);

                var _na = _nodes[_a];
                var _nb = _nodes[_b];

                array_push(_edges, {
                    a : _a, b : _b,
                    fa : _a, fb : _b,
                    gd : point_distance((_na.bx + _nb.bx) * 0.5, (_na.by + _nb.by) * 0.5, _ox, _oy),
                    grow  : 0,
                    cond  : false,
                    order : 0,
                    rev   : 1,
                    state : 0,
                    live  : 0,
                    head  : 0,
                    hot   : 0,
                    off   : scr_bolt_offsets(2, _cell * 0.09)
                });

                array_push(_na.nbr, _b); array_push(_na.eid, _ei);
                array_push(_nb.nbr, _a); array_push(_nb.eid, _ei);
            }

            array_push(_cells, { cx : _ccx, cy : _ccy, n : _corner, heat : 0 });
        }
    }

    ds_map_destroy(_nmap);
    ds_map_destroy(_emap);

    var _jit = _k_jitter[_i] * _cell;
    for (var _n = 0; _n < array_length(_nodes); _n++) {
        var _nd = _nodes[_n];
        _nd.bx += random_range(-_jit, _jit);
        _nd.by += random_range(-_jit, _jit);
        _nd.x = _nd.bx;
        _nd.y = _nd.by;
        _nd.d = point_distance(_nd.bx, _nd.by, _ox, _oy);
    }

    if (_hole_r > 0) {
        var _bend = _hole_r + _cell * 1.15;
        for (var _n = 0; _n < array_length(_nodes); _n++) {
            var _nb = _nodes[_n];
            var _hd = point_distance(_nb.bx, _nb.by, _hx, _hy);
            if (_hd > _bend || _hd < 1) continue;

            var _pd = point_direction(_hx, _hy, _nb.bx, _nb.by);
            var _pw = (_bend - _hd) * 0.34;
            _nb.bx += lengthdir_x(_pw, _pd);
            _nb.by += lengthdir_y(_pw, _pd);
            _nb.x = _nb.bx;
            _nb.y = _nb.by;
            _nb.d = point_distance(_nb.bx, _nb.by, _ox, _oy);
        }
    }

    lat = {
        strike : _i,
        void_x : _hx, void_y : _hy, void_r : _hole_r,
        ax : _ox, ay : _oy,
        px : _px, py : _py,
        radius : _radius,
        cell : _cell,
        nodes : _nodes,
        edges : _edges,
        cells : _cells,
        entry : [],
        arcs  : [],

        k_cond : _k_cond[_i], k_loop : _k_loop[_i], k_step : _k_step[_i],
        k_cross : _k_cross[_i], k_hold : _k_hold[_i], k_inward : _k_inward[_i],
        k_hit : _k_hit_rad[_i], k_surge_cap : _k_surge_cap[_i],

        phase : "grow",
        age : 0,
        grow_t : 0, grow_len : _k_grow[_i], grow_front : 0,
        coil : 0, coil_t : 0, coil_len : 1,
        reveal : 0,
        surge_t : 0, surge_len : 1, order_max : 1,
        cool_t : 0, cool_len : _k_cool[_i],
        wire : 1,
        flash : 0,
        tremble : 0,
        hop_pool : 0
    };

    array_push(ring_shockwaves, {
        x : _px, y : _py, radius : 6, max_radius : _radius * 0.9,
        life : _k_grow[_i] + 6, max_life : _k_grow[_i] + 6,
        width : 4, hot : 0.35, vs : 1
    });

    scr_impact_pulse(0.12 + _i * 0.03, 0.35, 0.18, _px, _py);
}


function scr_lattice_arm(_coil_frames) {
    if (is_undefined(lat)) exit;
    var _L = lat;

    _L.phase = "coil";
    _L.coil_t = 0;
    _L.coil_len = max(1, _coil_frames);
    _L.coil = 0;
    _L.reveal = 0;

    _L.grow_front = _L.radius + _L.cell;
    for (var _e = 0; _e < array_length(_L.edges); _e++) _L.edges[_e].grow = 1;
    for (var _n = 0; _n < array_length(_L.nodes); _n++) _L.nodes[_n].born = 1;

    scr_lattice_wire_river(_L);
}


function scr_lattice_wire_river(_L) {
    var _nc = array_length(_L.nodes);
    var _ec = array_length(_L.edges);
    if (_nc == 0 || _ec == 0) return;

    for (var _n = 0; _n < _nc; _n++) _L.nodes[_n].arr = -1;
    for (var _e = 0; _e < _ec; _e++) {
        var _ed = _L.edges[_e];
        _ed.cond = false; _ed.order = 0; _ed.state = 0;
        _ed.live = 0; _ed.head = 0; _ed.hot = 0;
    }

    var _entry = [];

    if (!_L.k_inward) {
        var _best = 0, _bestd = 999999;
        for (var _n = 0; _n < _nc; _n++) {
            if (_L.nodes[_n].d < _bestd) { _bestd = _L.nodes[_n].d; _best = _n; }
        }
        array_push(_entry, _best);
    } else {
        var _base = random(360);
        for (var _k = 0; _k < 3; _k++) {
            var _want = _base + _k * 120;
            var _best = -1, _bestscore = -999999;
            for (var _n = 0; _n < _nc; _n++) {
                var _nd = _L.nodes[_n];
                var _al = dcos(angle_difference(point_direction(_L.ax, _L.ay, _nd.bx, _nd.by), _want));
                var _score = _nd.d * max(0, _al);
                if (_score > _bestscore) { _bestscore = _score; _best = _n; }
            }
            if (_best >= 0) {
                var _dup = false;
                for (var _d2 = 0; _d2 < array_length(_entry); _d2++) {
                    if (_entry[_d2] == _best) _dup = true;
                }
                if (!_dup) array_push(_entry, _best);
            }
        }
        if (array_length(_entry) == 0) array_push(_entry, 0);
    }

    _L.entry = _entry;

    var _queue = [];
    for (var _k = 0; _k < array_length(_entry); _k++) {
        _L.nodes[_entry[_k]].arr = 0;
        array_push(_queue, _entry[_k]);
    }

    var _order_max = 1;
    var _qh = 0;

    while (_qh < array_length(_queue)) {
        var _ni = _queue[_qh++];
        var _nd = _L.nodes[_ni];

        var _links = [];
        for (var _k = 0; _k < array_length(_nd.eid); _k++) array_push(_links, _nd.eid[_k]);
        for (var _k = array_length(_links) - 1; _k > 0; _k--) {
            var _j = irandom(_k);
            var _tmp = _links[_k]; _links[_k] = _links[_j]; _links[_j] = _tmp;
        }

        for (var _k = 0; _k < array_length(_links); _k++) {
            var _ei = _links[_k];
            var _ed = _L.edges[_ei];
            var _oi = (_ed.a == _ni) ? _ed.b : _ed.a;
            var _on = _L.nodes[_oi];

            var _hop = _nd.arr + _L.k_step * random_range(0.82, 1.30);

            if (_on.arr >= 0) {
                if (!_ed.cond && random(1) < _L.k_loop) {
                    _ed.cond = true;
                    _ed.fa = _ni; _ed.fb = _oi;
                    _ed.order = _hop;
                    if (_hop > _order_max) _order_max = _hop;
                }
                continue;
            }

            if (random(1) > _L.k_cond) continue;

            _ed.cond = true;
            _ed.fa = _ni; _ed.fb = _oi;
            _ed.order = _hop;
            _on.arr = _hop;
            if (_hop > _order_max) _order_max = _hop;
            array_push(_queue, _oi);
        }
    }

    if (_order_max > _L.k_surge_cap) {
        var _scale = _L.k_surge_cap / _order_max;
        _order_max = 0;
        for (var _e = 0; _e < _ec; _e++) {
            var _ed3 = _L.edges[_e];
            if (!_ed3.cond) continue;
            _ed3.order *= _scale;
            if (_ed3.order > _order_max) _order_max = _ed3.order;
        }
        _order_max = max(1, _order_max);
    }

    for (var _e = 0; _e < _ec; _e++) {
        var _ed2 = _L.edges[_e];
        _ed2.rev = _ed2.cond ? clamp(_ed2.order / _order_max, 0, 1) : 1;
    }

    _L.order_max = _order_max;
    _L.surge_len = _order_max + _L.k_cross + _L.k_hold + 3;
}


function scr_lattice_strike() {
    if (is_undefined(lat)) exit;
    lat.phase = "surge";
    lat.surge_t = 0;
    lat.flash = 1;
    lat.coil = 0;
    lat.tremble = 1;
}


function scr_lattice_clear() {
    lat = undefined;
}


function scr_lattice_update() {
    if (is_undefined(lat)) exit;

    var _L = lat;
    _L.age++;
    _L.flash = max(0, _L.flash - 0.07);
    _L.tremble = max(0, _L.tremble - 0.035);

    var _nc = array_length(_L.nodes);
    var _ec = array_length(_L.edges);
    var _col_boost = 0;

    if (_L.phase == "grow") {
        _L.grow_t++;
        var _gp = clamp(_L.grow_t / _L.grow_len, 0, 1);
        _L.grow_front = (1 - power(1 - _gp, 2.6)) * (_L.radius + _L.cell * 0.8);

        vignette_pulse = max(vignette_pulse, 0.10 * (1 - _gp));
        bloom_pulse    = max(bloom_pulse, 0.10 * (1 - _gp));

        if (_L.grow_t >= _L.grow_len) {
            _L.phase = "hum";
            _L.grow_front = _L.radius + _L.cell;
        }
    }

    if (_L.phase == "grow" || _L.phase == "hum") {
        var _front = _L.grow_front;
        var _band  = _L.cell * 1.5;
        for (var _e = 0; _e < _ec; _e++) {
            var _ed = _L.edges[_e];
            if (_ed.grow >= 1) continue;
            _ed.grow = clamp((_front - _ed.gd + _band * 0.5) / _band, 0, 1);
        }
        for (var _n = 0; _n < _nc; _n++) {
            var _nd = _L.nodes[_n];
            if (_nd.born >= 1) continue;
            _nd.born = clamp((_front - _nd.d) / (_L.cell * 0.7), 0, 1);
        }
    }

    if (_L.phase == "coil") {
        _L.coil_t++;
        var _cp = clamp(_L.coil_t / _L.coil_len, 0, 1);
        _L.coil = power(_cp, 1.4);
        _L.reveal = clamp(_cp * 1.15, 0, 1);

        if (array_length(_L.entry) > 0 && irandom(100) < 22 + _L.coil * 55) {
            if (array_length(_L.arcs) >= 22) array_delete(_L.arcs, 0, 1);
            array_push(_L.arcs, {
                n : _L.entry[irandom(array_length(_L.entry) - 1)],
                ang : random(360),
                reach : random_range(120, 300) * lerp(1.25, 0.6, _L.coil),
                life : irandom_range(6, 12), life_max : 12,
                off : scr_bolt_offsets(3, 12 + _L.coil * 18)
            });
        }

        if (_L.coil_t mod 2 == 0) {
            for (var _k = 0; _k < array_length(_L.entry); _k++) {
                var _en = _L.nodes[_L.entry[_k]];
                array_push(converge_motes, {
                    cx : _en.bx, cy : _en.by,
                    ang : random(360), dist : random_range(70, 210), dest : 5,
                    speed : random_range(8, 15 + _L.coil * 12), size : random_range(0.08, 0.2),
                    spin : random_range(-8, 8), hot : 0.35 + _L.coil * 0.65,
                    feed : ""
                });
            }
        }

        vignette_pulse      = max(vignette_pulse, 0.12 + _L.coil * 0.32);
        aberration_pulse    = max(aberration_pulse, _L.coil * 0.7);
        bloom_pulse         = max(bloom_pulse, _L.coil * 0.24);
        global_ripple_pulse = max(global_ripple_pulse, _L.coil * 0.07);

        if (instance_exists(oCameraController)) {
            oCameraController.letterbox_target = max(oCameraController.letterbox_target, _L.coil * 0.8);
            oCameraController.shake = max(oCameraController.shake, _L.coil * 3.2);
        }
    }

    for (var _a = array_length(_L.arcs) - 1; _a >= 0; _a--) {
        _L.arcs[_a].life--;
        if (_L.arcs[_a].life <= 0) array_delete(_L.arcs, _a, 1);
    }

    if (_L.phase == "surge") {
        _L.surge_t++;

        var _live_max = _L.k_cross + _L.k_hold;

        for (var _e = 0; _e < _ec; _e++) {
            var _ed = _L.edges[_e];
            if (!_ed.cond || _ed.state != 0) continue;
            if (_L.surge_t < _ed.order) continue;

            _ed.state = 1;
            _ed.live = _live_max;
            _ed.head = 0;

            var _na = _L.nodes[_ed.fa];
            var _nb = _L.nodes[_ed.fb];
            _na.lit = 1;
            _nb.lit = max(_nb.lit, 0.85);

            var _kd = point_direction(_L.ax, _L.ay, _nb.bx, _nb.by);
            _nb.kx += lengthdir_x(1.7, _kd) * (_L.k_inward ? -1 : 1);
            _nb.ky += lengthdir_y(1.7, _kd) * (_L.k_inward ? -1 : 1);

            _col_boost += 0.02;
        }

        for (var _c = 0; _c < array_length(_L.cells); _c++) {
            var _cl = _L.cells[_c];
            var _lit = 0;
            for (var _k = 0; _k < 6; _k++) {
                var _nn = _L.nodes[_cl.n[_k]];
                if (_nn.lit > _lit) _lit = _nn.lit;
            }
            _cl.heat = max(_cl.heat * 0.88, _lit);
        }

        vignette_pulse   = max(vignette_pulse, 0.18 + _L.strike * 0.08);
        aberration_pulse = max(aberration_pulse, 0.45 + _L.strike * 0.2);
        bloom_pulse      = max(bloom_pulse, 0.26 + _L.strike * 0.12);

        if (_L.surge_t >= _L.surge_len) {
            _L.phase = "cool";
            _L.cool_t = 0;
        }
    }

    if (_L.phase == "cool") {
        _L.cool_t++;
        var _kp = clamp(_L.cool_t / _L.cool_len, 0, 1);
        _L.wire = power(1 - _kp, 1.6);

        for (var _n = 0; _n < _nc; _n++) {
            var _nd3 = _L.nodes[_n];
            var _dd = point_direction(_L.ax, _L.ay, _nd3.bx, _nd3.by);
            _nd3.kx += lengthdir_x(0.06, _dd);
            _nd3.ky += lengthdir_y(0.06, _dd) + 0.05;
        }

        if (_L.cool_t >= _L.cool_len) { lat = undefined; exit; }
    }

    for (var _e = 0; _e < _ec; _e++) {
        var _ed = _L.edges[_e];
        if (_ed.state == 1) {
            _ed.head = min(1, _ed.head + 1 / _L.k_cross);
            _ed.live--;
            if (_ed.live <= 0) { _ed.state = 2; _ed.hot = 1; }
        } else if (_ed.state == 2) {
            _ed.hot = max(0, _ed.hot - 0.028);
        }
    }

    var _wob = (_L.phase == "cool") ? 0.6 : (0.8 + _L.coil * 1.6 + _L.tremble * 2.2);
    for (var _n = 0; _n < _nc; _n++) {
        var _nd2 = _L.nodes[_n];
        _nd2.kox += _nd2.kx;
        _nd2.koy += _nd2.ky;
        _nd2.kx *= 0.84;
        _nd2.ky *= 0.84;
        _nd2.kox *= (_L.phase == "cool") ? 0.99 : 0.86;
        _nd2.koy *= (_L.phase == "cool") ? 0.99 : 0.86;

        _nd2.ph += 1.9;
        _nd2.x = _nd2.bx + dcos(_nd2.ph) * _wob + _nd2.kox;
        _nd2.y = _nd2.by - dsin(_nd2.ph * 0.7) * _wob + _nd2.koy;

        _nd2.lit = max(0, _nd2.lit - 0.055);
    }

    _L.hop_pool += _col_boost;
    if (_L.hop_pool > 0 && (_L.surge_t mod 3) == 0) {
        var _hp = _L.hop_pool;
        _L.hop_pool = 0;
        scr_impact_pulse(min(0.3, _hp * 1.1), min(1.1, _hp * 3.4), min(0.4, _hp * 1.3),
                         _L.px, _L.py);
        if (instance_exists(oCameraController)) {
            oCameraController.shake = max(oCameraController.shake, min(5, _hp * 11));
        }
    }

    if (_L.phase == "surge" && instance_exists(oPlayer) && !instance_exists(oGameover)) {
        var _plx = oPlayer.x;
        var _ply = oPlayer.y;
        var _pad = _L.k_hit + 34;

        for (var _e = 0; _e < _ec; _e++) {
            var _ed = _L.edges[_e];
            if (_ed.state != 1) continue;

            var _na = _L.nodes[_ed.fa];
            var _nb = _L.nodes[_ed.fb];
            var _hx = lerp(_na.x, _nb.x, _ed.head);
            var _hy = lerp(_na.y, _nb.y, _ed.head);

            if (_plx < min(_na.x, _hx) - _pad || _plx > max(_na.x, _hx) + _pad) continue;
            if (_ply < min(_na.y, _hy) - _pad || _ply > max(_na.y, _hy) + _pad) continue;

            if (player_meeting_line_width(_na.x, _na.y, _hx, _hy, _L.k_hit)) {
                player_register_hazard_hit();
                break;
            }
        }
    }
}


function scr_lattice_strike_payoff(_strike_index) {
    var _k_flash        = [0.34, 0.5];
    var _k_shake        = [9,    14];
    var _k_zoom_punch   = [0.08, 0.13];
    var _k_tilt         = [1.8, -2.6];
    var _k_tear         = [0.55, 0.9];
    var _k_ripple       = [0.45, 0.7];

    var _i = clamp(_strike_index, 0, 1);

    tear_amount = max(tear_amount, _k_tear[_i]);
    global_ripple_pulse = max(global_ripple_pulse, _k_ripple[_i]);

    var _ex = is_undefined(lat) ? 400 : lat.px;
    var _ey = is_undefined(lat) ? 304 : lat.py;

    scr_impact_pulse(0.42 + _i * 0.16, 1.5 + _i * 0.6, 0.6 + _i * 0.3, _ex, _ey);

    if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, _k_shake[_i]);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_zoom_punch[_i]);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, _k_flash[_i]);
        oCameraController.angle_kick = _k_tilt[_i];
        oCameraController.letterbox_target = 0;
    }
}
