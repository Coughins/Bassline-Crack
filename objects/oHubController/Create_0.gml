hub_scene_surface = -1;
hub_glow_surface = -1;
hub_collision_blocks = [];
hub_collision_specs = [];
hub_collision_ready = false;

if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

application_surface_draw_enable(false);

hub_end_mode = (room == rEnd);

audio_stop_all();
audio_play_sound(sSkyPuzzle, 1, true, hub_end_mode ? 0.18 : 0.22);

global.game_playing = !hub_end_mode;
global.game_running = !hub_end_mode;
global.hub_orbit_angle = 0;

with (oWarp) {
    visible = false;
    x = -4096;
    y = -4096;
}

with (oFootball) {
    visible = false;
    x = -4096;
    y = -4096;
}

hub_time = 0;
hub_seed = random(1000);
hub_spawn_applied = false;

hub_floor_y = 536;
hub_spawn_x = hub_end_mode ? 176 : 128;
hub_spawn_y = hub_floor_y - sprite_origin_to_bottom(sPlayerIdle);

hub_gate_x = hub_end_mode ? GAME_WIDTH * 0.5 : 642;
hub_gate_y = hub_end_mode ? 366 : 450;
hub_gate_rx = hub_end_mode ? 102 : 58;
hub_gate_ry = hub_end_mode ? 118 : 100;

hub_warp_room = asset_get_index("rAvoidanceRoom");
if (hub_warp_room == -1) hub_warp_room = rAvoidance;
hub_warping = false;
hub_warp_timer = 0;
var _fin_cut_arrival = variable_global_exists("fin_cut_arrival") && global.fin_cut_arrival;
global.fin_cut_arrival = false;

hub_warp_flash = (_fin_cut_arrival && hub_end_mode) ? 0.92 : (hub_end_mode ? 0.32 : 0);
hub_gate_charge = hub_end_mode ? 0.82 : 0;
hub_gate_touch_frames = 0;

if (!variable_global_exists("avoidance_practice_active")) global.avoidance_practice_active = false;
if (!variable_global_exists("avoidance_practice_t")) global.avoidance_practice_t = 0;
if (!variable_global_exists("avoidance_practice_name")) global.avoidance_practice_name = "";
if (!variable_global_exists("avoidance_practice_return_menu")) global.avoidance_practice_return_menu = false;
if (!variable_global_exists("debug_restart_t")) global.debug_restart_t = 0;
if (!variable_global_exists("debug_resume_t")) global.debug_resume_t = 0;

var _practice_return_menu = global.avoidance_practice_return_menu;
var _practice_return_t = global.avoidance_practice_t;
var _practice_return_name = global.avoidance_practice_name;

if (global.avoidance_practice_active) {
    global.avoidance_practice_active = false;
    global.avoidance_practice_t = 0;
    global.avoidance_practice_name = "";
    global.debug_restart_t = 0;
    global.debug_resume_t = 0;
}

hub_practice_x = 304;
hub_practice_y = hub_floor_y - 26;
hub_practice_rx = 102;
hub_practice_ry = 78;
if (_practice_return_menu && !hub_end_mode) {
    hub_spawn_x = hub_practice_x;
    hub_warp_flash = 0.12;
}
hub_practice_near = false;
hub_practice_menu_open = _practice_return_menu && !hub_end_mode;
hub_practice_selected = 0;
hub_practice_scroll = 0;
hub_practice_flash = 0;
hub_practice_menu_flash = 0;
hub_practice_markers = [
  {name:"Steel Downpour",           t:378,  color:c_orange},
  {name:"Chain Lightning",          t:1189, color:c_yellow},
  {name:"Laser Gauntlet",           t:1364, color:c_blue},
  {name:"Meteor Tether",            t:1691, color:c_red},
  {name:"The Ripening",             t:1826, color:c_lime},
  {name:"Eruption",                 t:2270, color:c_yellow},
  {name:"Black Holes",              t:2597, color:c_maroon},
  {name:"Dashing Kunai",            t:3331, color:c_orange},
  {name:"The Jumprope",             t:3560, color:c_aqua},
  {name:"The Cube",                 t:4000, color:c_red},
  {name:"The Vault",                t:4990, color:c_lime},
  {name:"Honeycomb",                t:5219, color:c_teal},
  {name:"The Blind Arc + Mitosis",  t:5960, color:c_purple},
  {name:"The Mill + Last Rites",    t:6628, color:c_yellow}
];

if (hub_practice_menu_open) {
    hub_practice_flash = 1;
    hub_practice_menu_flash = 1;

    for (var _i = 0; _i < array_length(hub_practice_markers); _i++) {
        var _marker = hub_practice_markers[_i];
        if (_marker.t == _practice_return_t || _marker.name == _practice_return_name) {
            hub_practice_selected = _i;
            break;
        }
    }

    var _practice_visible = 11;
    if (hub_practice_selected >= _practice_visible) {
        hub_practice_scroll = hub_practice_selected - _practice_visible + 1;
    }
}
global.avoidance_practice_return_menu = false;

hub_start_practice = function(_marker) {
    global.avoidance_practice_active = true;
    global.avoidance_practice_t = _marker.t;
    global.avoidance_practice_name = _marker.name;
    global.debug_restart_t = 0;
    global.debug_resume_t = _marker.t;

    audio_play_sound(sConfirm, 1, false, 0.85);
    hub_push_ring(hub_practice_x, hub_practice_y - 18, 12, 7.4, 28, hub_col_white, 1.2);
    hub_push_ring(hub_practice_x, hub_practice_y - 18, 34, 6.2, 34, hub_col_cyan, 0.9);

    if (instance_exists(oPlayer)) {
        player_set_frozen(false);
        warp(rAvoidance, oPlayer, 0, 0, true);
    }
}

hub_end_reveal = 0;
hub_end_clear_time = savedata_get("time");
if (hub_end_clear_time <= 0) hub_end_clear_time = savedata_get_active("time");
hub_end_clear_time_text = time_to_string(hub_end_clear_time);

hub_minor_pulse = 0;
hub_major_pulse = 0;
hub_gate_pulse = 0;
hub_ripple_pulse = 0;
hub_bloom_pulse = 0;
hub_aberration_pulse = 0;
hub_tear_pulse = 0;

hub_col_void = make_color_rgb(1, 3, 10);
hub_col_back = make_color_rgb(5, 10, 24);
hub_col_deep = make_color_rgb(9, 15, 31);
hub_col_panel_dark = make_color_rgb(8, 13, 27);
hub_col_panel_mid = make_color_rgb(19, 31, 51);
hub_col_panel_hi = make_color_rgb(64, 99, 126);
hub_col_edge = make_color_rgb(128, 214, 238);
hub_col_cyan = make_color_rgb(88, 235, 255);
hub_col_white = make_color_rgb(246, 254, 255);
hub_col_warning = make_color_rgb(255, 46, 72);
hub_col_violet = make_color_rgb(178, 82, 255);
hub_col_blood = make_color_rgb(120, 10, 48);

hub_collision_specs = [
    { x : -64, y : 0, w : 64, h : GAME_HEIGHT, tag : "left_wall" },
    { x : GAME_WIDTH, y : 0, w : 64, h : GAME_HEIGHT, tag : "right_wall" },
    { x : 0, y : -64, w : GAME_WIDTH, h : 64, tag : "ceiling" },
    { x : 0, y : hub_floor_y, w : GAME_WIDTH, h : GAME_HEIGHT - hub_floor_y + 96, tag : "main_deck" }
];

hub_clear_collision = function() {
    for (var i = array_length(hub_collision_blocks) - 1; i >= 0; i--) {
        var _block = hub_collision_blocks[i];
        if (instance_exists(_block)) {
            instance_destroy(_block);
        }
    }

    hub_collision_blocks = [];
    hub_collision_ready = false;
}

hub_collision_add = function(_spec) {
    var _block = block_create(_spec.x, _spec.y, _spec.w, _spec.h);
    _block.visible = false;
    _block.hub_owned = true;
    _block.hub_owned_by = id;
    _block.hub_collision_tag = _spec.tag;
    _block.image_alpha = 0;
    array_push(hub_collision_blocks, _block);
    return _block;
}

hub_build_collision = function() {
    hub_clear_collision();

    with (oBlock) {
        if (!variable_instance_exists(id, "hub_owned_by") || hub_owned_by != other.id) {
            instance_destroy();
        }
    }

    for (var i = 0; i < array_length(hub_collision_specs); i++) {
        hub_collision_add(hub_collision_specs[i]);
    }

    hub_collision_ready = true;
}

hub_collision_intact = function() {
    if (array_length(hub_collision_blocks) != array_length(hub_collision_specs)) return false;

    for (var i = 0; i < array_length(hub_collision_blocks); i++) {
        if (!instance_exists(hub_collision_blocks[i])) return false;
    }

    return true;
}

hub_build_collision();

hub_stars = [];
for (var i = 0; i < 96; i++) {
    array_push(hub_stars, {
        x : random(GAME_WIDTH),
        y : random_range(8, 330),
        z : random_range(0.35, 1),
        seed : random(1000),
        color : choose(hub_col_cyan, hub_col_edge, hub_col_warning, hub_col_white)
    });
}

hub_towers = [];
for (var i = 0; i < 14; i++) {
    var _side = (i < 7) ? -1 : 1;
    var _slot = i mod 7;
    var _x = (_side < 0)
        ? lerp(-48, 250, _slot / 6)
        : lerp(550, 848, _slot / 6);

    array_push(hub_towers, {
        x : _x,
        w : random_range(30, 62),
        h : random_range(128, 300),
        lean : _side * random_range(8, 24),
        seed : random(1000),
        side : _side
    });
}

hub_deck_panels = [];
for (var i = 0; i < 19; i++) {
    var _x = -88 + i * 54;
    array_push(hub_deck_panels, {
        x : _x,
        w : random_range(42, 72),
        h : random_range(44, 88),
        step : i,
        seed : random(1000),
        light : (i mod 5 == 0)
    });
}

hub_rail_nodes = [];
for (var i = 0; i < 18; i++) {
    var _f = i / 17;
    array_push(hub_rail_nodes, {
        x : lerp(42, GAME_WIDTH - 42, _f),
        y : hub_floor_y - 23 + sin(i * 1.7) * 4,
        seed : random(1000),
        hot : (i mod 4 == 0)
    });
}

hub_motes = [];
for (var i = 0; i < 76; i++) {
    array_push(hub_motes, {
        x : random(GAME_WIDTH),
        y : random_range(90, hub_floor_y - 34),
        vx : random_range(-0.18, 0.18),
        vy : random_range(-0.26, -0.04),
        size : random_range(0.7, 2.2),
        seed : random(1000),
        color : choose(hub_col_cyan, hub_col_edge, hub_col_warning, hub_col_violet)
    });
}

hub_sparks = [];
hub_bolts = [];
hub_rings = [];
hub_streams = [];

hub_ring_centers = array_create(8, 0);
hub_ring_radii = array_create(4, 0);
hub_ring_strengths = array_create(4, 0);
hub_swirl_centers = array_create(8, 0);
hub_swirl_radii = array_create(4, 0);
hub_swirl_strengths = array_create(4, 0);

hub_u_time = shader_get_uniform(shd_lightning_distort, "u_time");
hub_u_strength = shader_get_uniform(shd_lightning_distort, "u_strength");
hub_u_texel = shader_get_uniform(shd_lightning_distort, "u_texel");
hub_u_base_tex = shader_get_sampler_index(shd_lightning_distort, "u_baseTex");
hub_u_vignette = shader_get_uniform(shd_lightning_distort, "u_vignette_intensity");
hub_u_aberration = shader_get_uniform(shd_lightning_distort, "u_aberration_strength");
hub_u_bloom = shader_get_uniform(shd_lightning_distort, "u_bloom_intensity");
hub_u_tear = shader_get_uniform(shd_lightning_distort, "u_tear_amount");
hub_u_ripple = shader_get_uniform(shd_lightning_distort, "u_global_ripple");
hub_u_ring_centers = shader_get_uniform(shd_lightning_distort, "u_ring_centers");
hub_u_ring_radii = shader_get_uniform(shd_lightning_distort, "u_ring_radii");
hub_u_ring_strengths = shader_get_uniform(shd_lightning_distort, "u_ring_strengths");
hub_u_ring_count = shader_get_uniform(shd_lightning_distort, "u_ring_count");
hub_u_swirl_centers = shader_get_uniform(shd_lightning_distort, "u_swirl_centers");
hub_u_swirl_radii = shader_get_uniform(shd_lightning_distort, "u_swirl_radii");
hub_u_swirl_strengths = shader_get_uniform(shd_lightning_distort, "u_swirl_strengths");
hub_u_swirl_count = shader_get_uniform(shd_lightning_distort, "u_swirl_count");
hub_u_intro_dim = shader_get_uniform(shd_lightning_distort, "u_intro_dim");
hub_u_slash_amount = shader_get_uniform(shd_lightning_distort, "u_slash_amount");
hub_u_slash_center = shader_get_uniform(shd_lightning_distort, "u_slash_center");

hub_push_ring = function(_x, _y, _radius, _speed, _life, _color, _strength) {
    if (array_length(hub_rings) > 18) array_delete(hub_rings, 0, 1);
    array_push(hub_rings, {
        x : _x,
        y : _y,
        radius : _radius,
        speed : _speed,
        life : _life,
        life_max : _life,
        color : _color,
        strength : _strength,
        seed : random(1000)
    });
}

hub_push_spark = function(_x, _y, _ang, _speed, _life, _size, _color) {
    if (array_length(hub_sparks) > 150) array_delete(hub_sparks, 0, 1);
    array_push(hub_sparks, {
        x : _x,
        y : _y,
        vx : lengthdir_x(_speed, _ang),
        vy : lengthdir_y(_speed, _ang),
        life : _life,
        life_max : _life,
        size : _size,
        color : _color,
        seed : random(1000)
    });
}

hub_push_bolt = function(_x1, _y1, _x2, _y2, _life, _segments, _color, _width) {
    if (array_length(hub_bolts) > 34) array_delete(hub_bolts, 0, 1);
    array_push(hub_bolts, {
        x1 : _x1,
        y1 : _y1,
        x2 : _x2,
        y2 : _y2,
        life : _life,
        life_max : _life,
        segments : _segments,
        color : _color,
        width : _width,
        seed : random(1000)
    });
}

hub_push_stream = function(_x, _y, _len, _vy, _life, _width, _color) {
    if (array_length(hub_streams) > 90) array_delete(hub_streams, 0, 1);
    array_push(hub_streams, {
        x : _x,
        y : _y,
        len : _len,
        vy : _vy,
        life : _life,
        life_max : _life,
        width : _width,
        color : _color,
        seed : random(1000)
    });
}

hub_draw_bolt = function(_bolt, _alpha_mult) {
    var _a = clamp(_bolt.life / max(_bolt.life_max, 1), 0, 1) * _alpha_mult;
    if (_a <= 0) return;

    var _seg = max(2, _bolt.segments);
    var _dir = point_direction(_bolt.x1, _bolt.y1, _bolt.x2, _bolt.y2);
    var _perp = _dir + 90;
    var _px = _bolt.x1;
    var _py = _bolt.y1;

    gpu_set_blendmode(bm_add);
    for (var i = 1; i <= _seg; i++) {
        var _f = i / _seg;
        var _tx = lerp(_bolt.x1, _bolt.x2, _f);
        var _ty = lerp(_bolt.y1, _bolt.y2, _f);
        if (i < _seg) {
            var _j = sin(_bolt.seed + i * 7.31 + hub_time * 0.81) * (8 + _bolt.width * 3)
                   + sin(_bolt.seed * 0.33 + i * 13.7 + hub_time * 0.43) * 5;
            _tx += lengthdir_x(_j, _perp);
            _ty += lengthdir_y(_j, _perp);
        }

        var _taper = 1 - abs(_f - 0.5) * 1.15;
        _taper = clamp(_taper, 0.22, 1);
        draw_set_color(_bolt.color);
        draw_set_alpha(_a * 0.15);
        draw_line_width(_px, _py, _tx, _ty, _bolt.width * 6 * _taper);
        draw_set_alpha(_a * 0.55);
        draw_line_width(_px, _py, _tx, _ty, _bolt.width * 2.1 * _taper);
        draw_set_color(hub_col_white);
        draw_set_alpha(_a * 0.82);
        draw_line_width(_px, _py, _tx, _ty, max(1, _bolt.width * 0.48) * _taper);

        _px = _tx;
        _py = _ty;
    }
    draw_set_alpha(1);
    draw_set_color(c_white);
    gpu_set_blendmode(bm_normal);
}
