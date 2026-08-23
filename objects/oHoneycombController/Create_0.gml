// ============================================================================
// THE DUCT
// SECTION TIMING AND SEEK REPLAY LIVE IN scripts/scr_duct.
// ============================================================================

rows = 20;
cols = 13;
hex_radius = 100;

edge_segments = 3;
depth_offset  = 18;
depth_offset_base = depth_offset;
scale_min = 0.30;
scale_max = 1.0;
alpha_min = 0.12;
alpha_max = 1.0;
_k_hc_rotation_speed_base = 0.00605798;
_k_hc_rotation_speed_gain = 0.000123323;
_k_hc_rotation_kick_min   = 0.00346170;
_k_hc_rotation_kick_max   = 0.01384681;
rotation_speed = _k_hc_rotation_speed_base;


_k_duct_axis_x = 400;
_k_duct_axis_y = 304;

_k_duct_t_rest    = 5780;                       // last bass beat; 64 frames of
_k_duct_stretch_t = [5304, 5429, 5553, 5676];   // beats 1 / 7 / 13 / 19
_k_duct_seam_t    = 5960;                       // _k_arc_rift_t: the next
_k_duct_seam_y    = 60;

_k_duct_casing_gap  = 150;
_k_duct_flange_step = 336;
_k_duct_rung_step   = 58;    // casing rungs
_k_duct_marker_step = 450;   // bulkhead segment plates

_k_duct_chase_start     = 880;
_k_duct_chase_beat_end  = 432;
_k_duct_chase_rest_end  = 356;
_k_duct_chase_coil_end  = 300;
_k_duct_chase_hit       = 168;
_k_duct_light_reach_min = 380;
_k_duct_light_reach_max = 700;

_k_duct_open_alpha      = 0.62;
_k_duct_open_alpha_coil = 0.95;

// ---------------------------------------------------------------------------
// THE CELL DOORS.
_k_duct_door_warn  = 8;     // frames of red warning before a leaf moves
_k_duct_door_shut  = 9;     // frames of travel; it accelerates into the stop
_k_duct_door_lock  = 18;    // frames for the sealed cell to go dark
_k_duct_door_clear = 44;    // px from the opening the player must be before a
_k_duct_door_max   = 18;
_k_duct_cell_grip  = 0.60;

_k_duct_panel_inset = 0.855;

_k_duct_vent_max = 40;
_k_duct_grit_max = 46;
_k_duct_svent_max = 30;

open_alpha = _k_duct_open_alpha;

center_x = 400;
center_y = 304;
move_dir = (choose(1,2));

cylinder_rotation = 0;
rotation_ease = 0;
scroll_ease = 0;

bass_pulse = false;
pulse_scale = 1;
bass_pulse_id = 0;

_k_hc_t_spawn     = 5219;
_k_hc_t_live      = 5314;
_k_hc_t_kill      = 5314;
_k_hc_t_coil      = 5844;
_k_hc_t_detonate  = 5964;
_k_hc_rotation_ease_frames = 30;
_k_hc_scroll_ease_frames   = 150;

var _topo = scr_honeycomb_build_topology(cols, rows, hex_radius);
var _vertices    = _topo.vertices;
var _edges       = _topo.edges;
var _cell_edges  = _topo.cell_edges;
var _total_width = _topo.total_width;

radius = _total_width / (2 * pi);
radius_base = radius;

var _wall_h_scale = ceil(room_height / 32) + 2;
hc_wall_left = instance_create_layer(center_x - radius_base - 32, -32, layer, oBlock);
hc_wall_left.image_xscale = 1;
hc_wall_left.image_yscale = _wall_h_scale;
hc_wall_right = instance_create_layer(center_x + radius_base, -32, layer, oBlock);
hc_wall_right.image_xscale = 1;
hc_wall_right.image_yscale = _wall_h_scale;

home_row = rows div 2;

var _angle_step  = (2 * pi) / cols;
var _row_offset  = (home_row mod 2 == 1) ? 0.5 : 0;
home_col = round((pi / 2) / _angle_step - _row_offset);
home_col = ((home_col mod cols) + cols) mod cols;

home_rotation_offset = (pi / 2) - (home_col + _row_offset) * _angle_step;
cylinder_rotation = home_rotation_offset;

var _hc_section_frames = _k_hc_t_detonate - _k_hc_t_live;
var _hc_scroll_px = (_hc_section_frames - _k_hc_scroll_ease_frames * 0.5) * ((move_dir == 1) ? 1 : -1);
var _hc_row_height = hex_radius * 1.5;
lane_row_drift = -_hc_scroll_px / _hc_row_height;
lane_row_band  = 1.6;

lane_route = scr_honeycomb_carve_lane(_cell_edges, _edges, cols, rows, home_row, home_col,
                                      lane_row_drift, lane_row_band);

decorative_min_openings = 1;
scr_honeycomb_carve_decorative_openings(_cell_edges, _edges, cols, rows, decorative_min_openings,
                                        lane_route.cells);

var _home_has_rightward_opening = false;
var _rightward_dirs = [HC_DIR_LEFT, HC_DIR_UP_LEFT, HC_DIR_DOWN_LEFT];
for (var i = 0; i < 3; i++) {
    var _eid = _cell_edges[home_row][home_col][_rightward_dirs[i]];
    if (_eid != -1 && _edges[_eid].open) { _home_has_rightward_opening = true; break; }
}
if (!_home_has_rightward_opening) {
    show_debug_message("HONEYCOMB BUG: home hex (" + string(home_row) + "," + string(home_col) + ") has no rightward opening after carve_lane. Check home_col calculation.");
}

edges = _edges;
cell_edges = _cell_edges;
total_width = _total_width;

for (var i = 0; i < array_length(edges); i++) {
    var _pe = edges[i];
    var _paw = ((_pe.ax mod _total_width) + _total_width) mod _total_width;
    var _pbw = ((_pe.bx mod _total_width) + _total_width) mod _total_width;
    _pe.ang_a = (_paw / _total_width) * (2 * pi);
    _pe.ang_b = (_pbw / _total_width) * (2 * pi);

    _pe.door_s    = 0;    // 0 OPEN  1 WARN  2 CLOSING  3 LOCKED
    _pe.door_p    = 0;
    _pe.door_t    = 0;    // frames in the current state
    _pe.door_f    = 0;    // the slam flash, decays
    _pe.door_lead = false;
    _pe.ca        = -1;
    _pe.cb        = -1;
}

var _max_flat_y = 0;
for (var i = 0; i < array_length(_vertices); i++) {
    _max_flat_y = max(_max_flat_y, _vertices[i].flat_y);
}
var _height_offset = -_max_flat_y * 0.5;

_height_offset += -depth_offset_base - (home_row * hex_radius * 1.5 + _height_offset);

height_offset = _height_offset;

bullet_specs = [];

for (var i = 0; i < array_length(_vertices); i++) {
    var _v = _vertices[i];
    var _base_angle = (_v.flat_x / _total_width) * (2 * pi);
    var _height = _v.flat_y + _height_offset;
    array_push(bullet_specs, {
        angle: _base_angle, height: _height,
        is_open: false, is_lane: false, is_corner: true,
        edge_id: -1, seen: false,
        live: false, hit_active: false, already_hit_player: false,
        draw_x: 0, draw_y: 0, x: 0, y: 0,
        draw_scale: 1, draw_alpha: 0, image_alpha: 0,
        honeycomb_depth: 0,
        ignited: false, ignite_flash: 0, shimmer_phase: 0,
        spawn_timer: 0, spawn_duration: 26, spawn_complete: false,
        last_pulse_id: 0, pulse_scale: 1, pulse_glow: 0, pulse_glow_timer: 0,
        ring_heat: 0, prox_heat: 0, chase_heat: 0,
        despawning: false, despawn_timer: 0, despawn_duration: 44,
        blast_active: false, blast_dir: 0, blast_speed: 0, blast_spin: 0,
        blast_angle: 0
    });
}

for (var i = 0; i < array_length(_edges); i++) {
    var _e = _edges[i];
    for (var s = 1; s < edge_segments; s++) {
        var _t = s / edge_segments;
        var _fx = lerp(_e.ax, _e.bx, _t);
        var _fy = lerp(_e.ay, _e.by, _t);
        var _base_angle = (_fx / _total_width) * (2 * pi);
        var _height = _fy + _height_offset;
        array_push(bullet_specs, {
            angle: _base_angle, height: _height,
            is_open: _e.open, is_lane: _e.is_lane, is_corner: false,
            edge_id: i, seen: false,
            live: false, hit_active: false, already_hit_player: false,
            draw_x: 0, draw_y: 0, x: 0, y: 0,
            draw_scale: 1, draw_alpha: 0, image_alpha: 0,
            honeycomb_depth: 0,
            ignited: false, ignite_flash: 0, shimmer_phase: 0,
            spawn_timer: 0, spawn_duration: 26, spawn_complete: false,
            last_pulse_id: 0, pulse_scale: 1, pulse_glow: 0, pulse_glow_timer: 0,
            ring_heat: 0, prox_heat: 0, chase_heat: 0,
            despawning: false, despawn_timer: 0, despawn_duration: 44,
            blast_active: false, blast_dir: 0, blast_speed: 0, blast_spin: 0,
            blast_angle: 0
        });
    }
}

array_sort(bullet_specs, function(a, b) { return a.height - b.height; });

for (var i = 0; i < array_length(bullet_specs); i++) {
    var _eid2 = bullet_specs[i].edge_id;
    if (_eid2 != -1) array_push(edges[_eid2].specs, i);
}

spec_count = array_length(bullet_specs);

spec_lo = 0;
spec_hi = 0;
window_initialised = false;
cull_margin = 150;
cull_hysteresis = 90;
spawn_budget_per_frame = 44;
live_bullet_count = 0;
hc_active_count = 0;
hc_hit_radius = 5.0;

hc_phase = "materialize";

materialize_h = -100000;
materialize_p = 0;
hc_scan_arcs = [];

hc_pulse_rings = [];
_k_hc_max_pulse_rings = 4;
_k_hc_pulse_width = 190;
_k_hc_pulse_speed = 26;
bass_beat_total = 0;
bass_escalation = 0;

hc_coil = 0;
hc_coil_arcs = [];
_k_hc_coil_arc_id = 0;
hc_heartbeat = 0;
hc_heartbeat_phase = 0;

hc_detonated = false;
hc_detonate_flash = 0;
hc_shock_rings = [];

hc_rotation_kick = 0;
hc_wall_heat = 0;

var _corner_deg = [-30, 30, 90, 150, 210, 270];
var _w = sqrt(3) * hex_radius;
var _h = hex_radius * 1.5;
var _home_row_offset = (home_row mod 2 == 1) ? (_w * 0.5) : 0;
var _home_cx = home_col * _w + _home_row_offset;
var _home_cy = home_row * _h;

home_corner_angle  = array_create(6);
home_corner_height = array_create(6);

for (var i = 0; i < 6; i++) {
    var _rad = degtorad(_corner_deg[i]);
    var _px = _home_cx + cos(_rad) * hex_radius;
    var _py = _home_cy + sin(_rad) * hex_radius;

    var _wrapped_x = ((_px mod _total_width) + _total_width) mod _total_width;
    home_corner_angle[i]  = (_wrapped_x / _total_width) * (2 * pi);
    home_corner_height[i] = _py + _height_offset;
}

lane_nodes = [];
for (var i = 0; i < array_length(lane_route.cells); i++) {
    var _c = lane_route.cells[i];
    var _lrow_offset = (_c.row mod 2 == 1) ? (_w * 0.5) : 0;
    var _lcx = _c.col * _w + _lrow_offset;
    var _lcy = _c.row * _h;
    var _lwrapped = ((_lcx mod _total_width) + _total_width) mod _total_width;
    array_push(lane_nodes, {
        angle:  (_lwrapped / _total_width) * (2 * pi),
        height: _lcy + _height_offset
    });
}
lane_guide_index = 0;
lane_guide_pulse = 0;
lane_guide_visible = false;

depth = 1;

bass_times = [
    5304,
    5327,
    5348,
    5368,
    5388,
    5409,
    5429,
    5449,
    5469,
    5490,
    5509,
    5532,
    5553,
    5575,
    5597,
    5617,
    5642,
    5657,
    5676,
    5696,
    5715,
    5739,
    5759,
    5780,
	5964
];

bass_beat_total = max(1, array_length(bass_times) - 1);

bass_index = 0;
bass_pulse_id = 0;
bass_flash = 0;


duct_flow = (move_dir == 1) ? 1 : -1;

duct_stretch = 0;
duct_hush    = 0;
duct_gap     = _k_duct_chase_start;
duct_light   = 0;
duct_lurch   = 0;
duct_lamp    = 0;
duct_lamp_h  = 0;
duct_seam    = 0;

duct_out   = 1;   // the shaft clears with the sleeve after the blowout

duct_vents  = [];
duct_svents = [];
duct_grit   = [];

var _edge_slots = array_length(edges);
vis_n  = 0;
vis_e  = array_create(_edge_slots, 0);
vis_x1 = array_create(_edge_slots, 0);
vis_y1 = array_create(_edge_slots, 0);
vis_x2 = array_create(_edge_slots, 0);
vis_y2 = array_create(_edge_slots, 0);
vis_f  = array_create(_edge_slots, 0);

hc_cell_now  = -1;
hc_cell_prev = -1;
hc_cell_seen = 0;

duct_doors  = [];
duct_locks  = [];
duct_sealed = [];
duct_slam   = 0;
duct_lock_flash = 0;

var _cell_w = sqrt(3) * hex_radius;
var _cell_h = hex_radius * 1.5;
var _cell_deg = [-30, 30, 90, 150, 210, 270];

var _lane_cells = ds_map_create();
for (var i = 0; i < array_length(lane_route.cells); i++) {
    var _lrc = lane_route.cells[i];
    ds_map_add(_lane_cells, string(_lrc.row) + "_" + string(_lrc.col), true);
}

// 2000-entry spec table on that same frame.
cells   = [];
cell_ca = array_create(rows * cols * 6, 0);
cell_ch = array_create(rows * cols * 6, 0);

for (var row = 0; row < rows; row++) {
    var _crow_off = (row mod 2 == 1) ? (_cell_w * 0.5) : 0;

    for (var col = 0; col < cols; col++) {
        var _ccx = col * _cell_w + _crow_off;
        var _ccy = row * _cell_h;
        var _cwrap = ((_ccx mod total_width) + total_width) mod total_width;
        var _base = array_length(cells) * 6;

        for (var k = 0; k < 6; k++) {
            var _crad = degtorad(_cell_deg[k]);
            var _cpx  = _ccx + cos(_crad) * hex_radius;
            var _cpy  = _ccy + sin(_crad) * hex_radius;
            var _cpw  = ((_cpx mod total_width) + total_width) mod total_width;
            cell_ca[_base + k] = (_cpw / total_width) * (2 * pi);
            cell_ch[_base + k] = _cpy + height_offset;
        }

        array_push(cells, {
            angle   : (_cwrap / total_width) * (2 * pi),
            height  : _ccy + height_offset,
            base    : _base,
            is_lane : ds_map_exists(_lane_cells, string(row) + "_" + string(col)),
            row     : row,
            col     : col,
            flat_x  : _ccx,
            flat_y  : _ccy,
            lock    : 0,             // 0..1 sealed-and-dark
            locking : false,
            lamp    : 0
        });
    }
}
ds_map_destroy(_lane_cells);

cell_eid = array_create(rows * cols * 6, -1);

for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
        var _ci = row * cols + col;
        for (var d = 0; d < 6; d++) {
            var _eid = cell_edges[row][col][d];
            cell_eid[_ci * 6 + d] = _eid;
            if (_eid == -1) continue;

            var _ew = edges[_eid];
            if (_ew.ca == -1)                    _ew.ca = _ci;
            else if (_ew.cb == -1 && _ew.ca != _ci) _ew.cb = _ci;
        }
    }
}

duct_seam_pts = [];
for (var i = 0; i <= 20; i++) {
    var _su = i / 20;
    var _sx = lerp(-70, room_width + 70, _su);
    var _sc = dsin(clamp((_sx - 0) / room_width, 0, 1) * 180);
    array_push(duct_seam_pts, {
        x   : _sx,
        y   : lerp(50, 150, _sc) - 34,
        jag : random_range(-1, 1)
    });
}

home_height = home_row * hex_radius * 1.5 + height_offset;

// ---------------------------------------------------------------------------
// THE DNA HELICES ARE DELETED FOR THE DURATION OF THE SECTION.
// instance_deactivate_all(true) followed by instance_activate_all(), so
// ---------------------------------------------------------------------------
with (oDNATest) visible = false;
if (instance_exists(oAvoidanceController)) oAvoidanceController.dna_veil = 0;
