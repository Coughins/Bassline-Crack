t = 0;

_k_p0_contact  = 2;
_k_p1_overload = 20;
_k_p2_cut      = 24;
_k_p3_bleed    = 68;
_k_p4_scar     = 108;
_k_gameover_at = 84;

_k_cut_angle = 45;
cut_angle    = _k_cut_angle;
cut_nx       =  dsin(cut_angle);
cut_ny       =  dcos(cut_angle);

_k_arc_rate_max     = 3.8;
_k_arc_reach        = 230;
_k_ribbon_count     = 11;
_k_ribbon_nodes     = 32;
_k_ribbon_emit_len  = 42;
_k_ribbon_speed     = 11.8;
_k_ribbon_gravity   = 0.46;
_k_droplet_gravity  = 0.38;
_k_decal_max        = 210;
_k_seam_drip_count  = 40;
_k_ground_search    = 260;
_k_shrapnel_count   = 68;
_k_splinter_count   = 54;
_k_spray_count      = 150;
_k_screen_splats    = 34;
_k_aftershock_len   = 54;
_k_chunk_gravity    = 0.50;

_k_blade_travel     = 22;
_k_blade_launch     = _k_p2_cut - _k_blade_travel / 2;
_k_split_start      = _k_blade_launch + _k_blade_travel;

_k_band_half        = 170;
_k_band_core        = 36;
_k_blade_head_w     = 260;
_k_blade_streak     = 720;
_k_blade_bloom      = 280;
_k_blade_edge_frac  = 0.54;
_k_blade_dim        = 0.80;

_k_whiteout_hold    = 3;
_k_whiteout_fade    = 9;

_k_split_slam       = 3.4;
_k_split_slam_hold  = 12;
_k_split_jitter     = 0.90;
_k_split_drift_to   = 5.2;

_k_wound_fade       = 0.017;

_k_prestrike_a      = 6;
_k_prestrike_b      = 11;

body_sprite = sPlayerIdle;
body_index  = 0;
body_xscale = 1;
body_yscale = 1;
body_angle  = 0;
death_x     = x;
death_y     = y;
inherit_vx  = 0;
inherit_vy  = 0;

half_a = undefined;
half_b = undefined;
body_split = false;

arcs      = [];
motes     = [];
ribbons   = [];
droplets  = [];
decals    = [];
chunks    = [];
splinters = [];
floor_smears = [];
seam_drips = [];
embers    = [];
cut_strikes = [];
seam_embers = [];
screen_splats = [];

overload      = 0;
body_white    = 0;
body_shake    = 0;
cut_preview   = 0;
cut_flash     = 0;
blade_t       = 0;
blade_glow    = 0;
whiteout      = 0;
whiteout_t    = 0;
redout        = 0;
death_aftershock = 0;
shock_rings   = [];
wound         = 0;
screen_split  = 0;
seam_heat     = 1;
ground_y      = undefined;
has_controller = false;
has_camera     = false;
prestrike_a_done = false;
prestrike_b_done = false;


function death_add_strike(_ang, _off, _life, _w) {
    array_push(cut_strikes, {
        ang : _ang,
        off : _off,
        life : _life, life_max : _life,
        w : _w
    });

    if (has_camera) {
        oCameraController.shake              = max(oCameraController.shake, 9);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.30);
    }
    if (has_controller) {
        oAvoidanceController.hitstop_frames = max(oAvoidanceController.hitstop_frames, 2);
        oAvoidanceController.aberration_pulse = max(oAvoidanceController.aberration_pulse, 1.2);
    }
}


function death_init() {
    x = death_x;
    y = death_y;

    has_controller = instance_exists(oAvoidanceController);
    has_camera     = instance_exists(oCameraController);

    ground_y = scr_death_ground_probe(death_x, death_y, _k_ground_search);

    var _perp = cut_angle + 90;
    for (var i = 0; i < _k_ribbon_count; i++) {
        var _side = (i % 2 == 0) ? 1 : -1;
        var _spread = random_range(-38, 38);
        array_push(ribbons, {
            nodes     : [],
            jet_ang   : _perp + (_side * 90) + _spread,
            speed     : _k_ribbon_speed * random_range(0.72, 1.25),
            emit_left : _k_ribbon_emit_len * random_range(0.6, 1.0),
            width     : random_range(2.6, 5.2),
            hot       : 1
        });
    }

    for (var i = 0; i < 26; i++) {
        array_push(motes, {
            ang   : random(360),
            dist  : random_range(70, 230),
            speed : random_range(1.4, 3.6),
            size  : random_range(0.5, 1.5),
            hot   : random_range(0.4, 1)
        });
    }

    for (var i = 0; i < _k_seam_drip_count; i++) {
        array_push(seam_drips, {
            u      : random_range(-0.55, 0.55),
            len    : 0,
            target : random_range(26, 150),
            speed  : random_range(1.1, 3.4),
            w      : random_range(1.4, 4.2),
            delay  : irandom_range(0, 22),
            alpha  : random_range(0.55, 1)
        });
    }

    if (has_camera) {
        oCameraController.shake            = max(oCameraController.shake, 7);
        oCameraController.zoom_punch       = max(oCameraController.zoom_punch, 0.055);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.32);
        oCameraController.letterbox_target = 1;
    }
    if (has_controller) {
        oAvoidanceController.hitstop_frames = max(oAvoidanceController.hitstop_frames, 5);
    }
}


function death_add_decal(_px, _py, _r) {
    if (array_length(decals) < _k_decal_max) {
        array_push(decals, {
            x : _px, y : _py,
            rx : _r * random_range(0.9, 1.6),
            ry : _r * random_range(0.22, 0.42),
            ang : random(360),
            alpha : random_range(0.55, 0.95),
            heat : random_range(0.0, 0.25)
        });

        repeat (irandom_range(1, 3)) {
            array_push(droplets, {
                x : _px, y : _py - 2,
                vx : random_range(-1.8, 1.8),
                vy : random_range(-2.6, -0.6),
                life : 34, life_max : 34,
                size : random_range(0.4, 1.1),
                landed : false
            });
        }
    }
}
