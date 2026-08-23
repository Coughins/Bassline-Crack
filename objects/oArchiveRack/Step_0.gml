if
  true {
    var _rack_n = array_length(_k_rack_beats);

    var _rack_fired = 0;
    for (var _rb = 0; _rb < _rack_n; _rb++) {
      if (t >= _k_rack_beats[_rb]) _rack_fired++;
    }

    var _rack_next_i = _rack_fired;
    var _rack_has_next = (_rack_next_i < _rack_n);
    var _rack_next_t = _rack_has_next ? _k_rack_beats[_rack_next_i] : _k_rack_t_blowout;
    var _rack_prev_t = (_rack_fired > 0) ? _k_rack_beats[_rack_fired - 1] : _k_rack_t_arm;

    rack_live = (t >= _k_rack_t_arm - 2 && t <= _k_rack_t_clear);
    rack_armed = (t >= _k_rack_t_arm && t < _k_rack_t_blowout);
    rack_dead = (t >= _k_rack_t_blowout);

    if (_rack_fired > 0) {
      var _rack_win = _k_rack_plan[_rack_fired - 1];
      rack_win_lo = _rack_win.lo;
      rack_win_hi = _rack_win.hi;
    } else {
      rack_win_lo = 0;
      rack_win_hi = _k_rack_lanes - 1;
    }

    if (t < _k_rack_t_blowout) {
      rack_half = rack_corridor_at(t);
    } else {
      rack_half = lerp(rack_half, _k_rack_reach, 0.12);
    }
    rack_half_ext = rack_corridor_ext(rack_half);

    rack_slam_flash = max(0, rack_slam_flash - 0.075);
    rack_beat_flash = max(0, rack_beat_flash - 0.055);
    rack_chroma = lerp(rack_chroma, 0, 0.11);

    if (rack_live && !rack_dead) {
      var _rack_prog = clamp((t - _k_rack_t_arm) / max(1, _k_rack_t_blowout - _k_rack_t_arm), 0, 1);
      rack_amb = lerp(rack_amb, 0.35 + _rack_prog * 0.85, 0.09);
      rack_heat = lerp(rack_heat, _rack_prog, 0.06);
      rack_rail = lerp(rack_rail, 1, 0.14);
      rack_readout = lerp(rack_readout, 1, 0.12);
    } else {
      rack_amb = max(0, rack_amb - 0.02);
      rack_heat = max(0, rack_heat - 0.012);
      rack_readout = max(0, rack_readout - 0.06);
      if (!rack_live) rack_rail = max(0, rack_rail - 0.05);
    }

    if (rack_live && !rack_dead) {
      var _rack_hb_rate = 0.16 + rack_heat * 0.22;
      rack_hb_phase += _rack_hb_rate;
      rack_hb = (0.5 + 0.5 * sin(rack_hb_phase)) * (0.25 + rack_heat * 0.75);
    } else {
      rack_hb = lerp(rack_hb, 0, 0.12);
    }

    if (rack_live && !rack_dead && _rack_has_next) {
      var _rack_span = max(1, _rack_next_t - _rack_prev_t);
      var _rack_raw = clamp((t - _rack_prev_t) / _rack_span, 0, 1);
      rack_coil = max(_k_rack_read_floor, power(_rack_raw, _k_rack_coil_ease));
    } else {
      rack_coil = max(0, rack_coil - 0.07);
    }

    var _rack_next_win_lo = rack_win_lo;
    var _rack_next_win_hi = rack_win_hi;
    var _rack_next_fast = false;
    if (_rack_has_next) {
      var _rack_nw = _k_rack_plan[_rack_next_i];
      _rack_next_win_lo = _rack_nw.lo;
      _rack_next_win_hi = _rack_nw.hi;
      _rack_next_fast = _rack_nw.fast;
    }

    for (var _li = 0; _li < _k_rack_lanes; _li++) {
      var _ln = rack_lanes[_li];
      var _open_now = (_li >= rack_win_lo && _li <= rack_win_hi);
      var _open_next = (_li >= _rack_next_win_lo && _li <= _rack_next_win_hi);

      if (rack_dead || t < _k_rack_t_arm) {
        _ln.target = 0;
      } else {
        _ln.target = _open_now ? rack_half_ext : 1;
      }

      var _closing = (rack_armed && _rack_has_next && _open_now && !_open_next);
      var _arm_target = _closing ? rack_coil : 0;
      _ln.arm = lerp(_ln.arm, _arm_target, _closing ? 0.35 : 0.16);

      _ln.flash = max(0, _ln.flash - 0.09);

      var _heat_target = max(_ln.ext * (0.35 + rack_heat * 0.5), _ln.arm);
      _ln.heat = lerp(_ln.heat, _heat_target, 0.2);
    }

    var _rack_slammed = false;
    var _rack_slam_fast = false;
    for (var _sb = 0; _sb < _rack_n; _sb++) {
      if (timeline_hit(_k_rack_beats[_sb])) {
        _rack_slammed = true;
        _rack_slam_fast = _k_rack_plan[_sb].fast;
        break;
      }
    }

    if (_rack_slammed) {
      rack_slam_flash = max(rack_slam_flash, _rack_slam_fast ? 0.62 : 1);
      rack_beat_flash = max(rack_beat_flash, _rack_slam_fast ? 0.5 : 1);
      rack_chroma = max(rack_chroma, _rack_slam_fast ? 0.35 : 0.85);
      rack_rail_heat[0] = min(1.6, rack_rail_heat[0] + (_rack_slam_fast ? 0.35 : 0.7));
      rack_rail_heat[1] = min(1.6, rack_rail_heat[1] + (_rack_slam_fast ? 0.35 : 0.7));

      var _slam_col = _rack_slam_fast ? _k_rack_col_fast : _k_rack_col_heavy;

      for (var _li2 = 0; _li2 < _k_rack_lanes; _li2++) {
        var _ln2 = rack_lanes[_li2];
        var _barred = !(_li2 >= rack_win_lo && _li2 <= rack_win_hi);

        if (!_barred) {
          _ln2.flash = max(_ln2.flash, _rack_slam_fast ? 0.75 : 0.45);
          for (var _osd = -1; _osd <= 1; _osd += 2) {
            var _otip = rack_tine_tip(_osd, _ln2.ext);
            var _oby = rack_lane_cy(_li2);
            for (var _os = 0; _os < 3; _os++) {
              if (array_length(rack_sparks) >= _k_rack_spark_cap) break;
              var _oa = (_osd < 0 ? 0 : 180) + random_range(-52, 52);
              var _ov = random_range(1.6, 4.2);
              array_push(rack_sparks, {
                x : _otip, y : _oby + random_range(-16, 16),
                vx : lengthdir_x(_ov, _oa), vy : lengthdir_y(_ov, _oa),
                life : irandom_range(8, 16), life_max : 16,
                size : random_range(0.9, 2.1),
                hot : random_range(0.4, 0.9),
                color : global.avoid_col_cyan
              });
            }
            scr_spawn_vent_stream(rack_vents, _otip, _oby, (_osd < 0) ? 180 : 0,
                                  0.3 + rack_heat * 0.4, _k_rack_vent_cols, _k_rack_vent_cap);
          }
          continue;
        }

        _ln2.ext = min(1, _ln2.ext + _k_rack_snap);
        _ln2.flash = 1;
        _ln2.arm = 0;

        var _band_c = rack_lane_cy(_li2);

        for (var _sd = -1; _sd <= 1; _sd += 2) {
          var _tipx = rack_tine_tip(_sd, _ln2.ext);

          if (array_length(rack_tips) < 40) {
            array_push(rack_tips, {
              x : _tipx, y : _band_c,
              life : _rack_slam_fast ? 9 : 14,
              life_max : _rack_slam_fast ? 9 : 14,
              hot : _rack_slam_fast ? 0.55 : 1,
              color : _slam_col,
              side : _sd
            });
          }

          var _spark_n = _rack_slam_fast ? 5 : 9;
          for (var _sp2 = 0; _sp2 < _spark_n; _sp2++) {
            if (array_length(rack_sparks) >= _k_rack_spark_cap) break;
            var _sa2 = 90 + _sd * -90 + random_range(-64, 64);
            var _ss2 = random_range(2.2, 6.5 + rack_heat * 3);
            array_push(rack_sparks, {
              x : _tipx, y : _band_c + random_range(-30, 30),
              vx : lengthdir_x(_ss2, _sa2),
              vy : lengthdir_y(_ss2, _sa2) - random_range(0, 1.4),
              life : irandom_range(11, 24),
              life_max : 24,
              size : random_range(1.1, 2.8),
              hot : random_range(0.45, 1),
              color : (_sp2 mod 3 == 0) ? c_white : _slam_col
            });
          }

          var _vent_n = _rack_slam_fast ? 1 : 2;
          for (var _vn = 0; _vn < _vent_n; _vn++) {
            scr_spawn_vent_stream(rack_vents,
                                  _tipx - _sd * random_range(10, 120),
                                  _band_c + random_range(-26, 26),
                                  (_sd < 0) ? 180 : 0,
                                  0.35 + rack_heat * 0.6,
                                  _k_rack_vent_cols, _k_rack_vent_cap);
          }
        }

        array_push(rack_lock_frames, {
          lane : _li2,
          life : _k_rack_lock_life,
          life_max : _k_rack_lock_life,
          fast : _rack_slam_fast,
          hot : _rack_slam_fast ? 0.55 : 0.9,
          seed : random(1000)
        });

        for (var _sd2 = -1; _sd2 <= 1; _sd2 += 2) {
          if (array_length(rack_scars) >= 26) break;
          array_push(rack_scars, {
            x : (_sd2 < 0) ? _k_rack_wall_l : _k_rack_wall_r,
            y : _band_c,
            side : _sd2,
            life : 150,
            life_max : 150,
            h : random_range(18, 34),
            color : _slam_col,
            seed : random(1000)
          });
        }
      }

      var _arc_n = _rack_slam_fast ? 2 : 4;
      for (var _an = 0; _an < _arc_n; _an++) {
        if (array_length(rack_arcs) >= 22) break;
        var _al = irandom_range(0, _k_rack_lanes - 1);
        if (_al >= rack_win_lo && _al <= rack_win_hi) continue;
        var _ay = rack_lane_cy(_al) + random_range(-22, 22);
        var _ax0 = _k_rack_wall_l + random_range(0, 140);
        var _ax1 = _k_rack_wall_r - random_range(0, 140);
        array_push(rack_arcs, {
          x1 : _ax0, y1 : _ay,
          x2 : _ax1, y2 : _ay + random_range(-14, 14),
          life : irandom_range(5, 11),
          life_max : 11,
          hot : _rack_slam_fast ? 0.45 : 0.85,
          color : choose(global.avoid_col_cyan, _slam_col, global.avoid_col_violet),
          off : scr_bolt_offsets(6, 12 + rack_heat * 16)
        });
      }

      var _chip_n = _rack_slam_fast ? 3 : 7;
      for (var _cn = 0; _cn < _chip_n; _cn++) {
        if (array_length(rack_shards) >= _k_rack_shard_cap) break;
        var _cs2 = choose(-1, 1);
        array_push(rack_shards, {
          x : (_cs2 < 0) ? _k_rack_wall_l + random_range(0, _k_rack_rail_w)
                         : _k_rack_wall_r - random_range(0, _k_rack_rail_w),
          y : random_range(_k_rack_top_y, _k_rack_floor_y),
          vx : -_cs2 * random_range(1.4, 4.2),
          vy : random_range(-2.6, 1.2),
          size : random_range(3, 8.5),
          rot : random(360),
          spin : random_range(-11, 11),
          life : irandom_range(28, 52),
          life_max : 52,
          color : choose(_k_rack_col_rail, _k_rack_col_rail_edge, _slam_col),
          hot : random_range(0.3, 0.9)
        });
      }

      if (!_rack_slam_fast) {
        scr_impact_pulse(0.14, 0.26, 0.22, _k_rack_mid_x,
                         (rack_win_top(rack_win_hi) + rack_win_bot(rack_win_lo)) * 0.5);
        if (instance_exists(oCameraController)) {
          oCameraController.shake = max(oCameraController.shake, _k_rack_shake_heavy);
          oCameraController.zoom_punch = max(oCameraController.zoom_punch, _k_rack_zoom_heavy);
          oCameraController.screen_flash_alpha =
            max(oCameraController.screen_flash_alpha, _k_rack_flash_heavy);
        }
        scr_floor_impact(_k_rack_mid_x, _k_rack_floor_y, 0.45 + rack_heat * 0.5, -1, _slam_col);
      } else {
        scr_impact_pulse(0.06, 0.14, 0.1);
      }

      scr_add_light(_k_rack_wall_l, (rack_win_top(rack_win_hi) + rack_win_bot(rack_win_lo)) * 0.5,
                    _slam_col, 2.4 + rack_heat * 2);
      scr_add_light(_k_rack_wall_r, (rack_win_top(rack_win_hi) + rack_win_bot(rack_win_lo)) * 0.5,
                    _slam_col, 2.4 + rack_heat * 2);
    }

    if (timeline_hit(_k_rack_t_arm)) {
      rack_rail = 0;
      rack_amb = 0.2;
      rack_heat = 0;
      rack_dead = false;
      rack_blowout = 0;
      rack_lock_frames = [];
      rack_vents = [];
      rack_sparks = [];
      rack_shards = [];
      rack_scars = [];
      rack_arcs = [];
      rack_tips = [];
      rack_rail_heat[0] = 0;
      rack_rail_heat[1] = 0;

      for (var _mi = 0; _mi < _k_rack_lanes; _mi++) {
        rack_lanes[_mi].ext = 0;
        rack_lanes[_mi].target = 0;
        rack_lanes[_mi].heat = 0;
        rack_lanes[_mi].flash = 0;
        rack_lanes[_mi].arm = 0;
      }

      for (var _mm = 0; _mm < 34; _mm++) {
        var _mside = (_mm mod 2 == 0) ? _k_rack_wall_l : _k_rack_wall_r;
        array_push(converge_motes, {
          cx : _mside,
          cy : random_range(_k_rack_top_y + 30, _k_rack_floor_y - 30),
          ang : random(360),
          dist : random_range(120, 330),
          dest : random_range(4, 26),
          speed : random_range(9, 17),
          size : random_range(0.16, 0.46),
          spin : random_range(-5, 5),
          hot : random_range(0.2, 0.7),
          feed : "rack"
        });
      }

      if (instance_exists(oCameraController)) {
        oCameraController.letterbox_target = _k_rack_letterbox;
      }
      scr_impact_pulse(0.2, 0.2, 0.25);
    }

    if (timeline_hit(_k_rack_t_blowout)) {
      rack_blowout = 1;
      rack_slam_flash = 1.4;
      rack_chroma = 1.2;
      rack_rail_heat[0] = 1.6;
      rack_rail_heat[1] = 1.6;

      for (var _bl = 0; _bl < _k_rack_lanes; _bl++) {
        rack_lanes[_bl].flash = 1;
        rack_lanes[_bl].arm = 0;
      }

      for (var _bs = 0; _bs < 70; _bs++) {
        if (array_length(rack_sparks) >= _k_rack_spark_cap) break;
        var _bside = choose(-1, 1);
        var _bsp = random_range(3.5, 11);
        var _bang = (_bside < 0 ? 0 : 180) + random_range(-72, 72);
        array_push(rack_sparks, {
          x : (_bside < 0) ? _k_rack_wall_l : _k_rack_wall_r,
          y : random_range(_k_rack_top_y, _k_rack_floor_y),
          vx : lengthdir_x(_bsp, _bang),
          vy : lengthdir_y(_bsp, _bang),
          life : irandom_range(18, 40),
          life_max : 40,
          size : random_range(1.2, 3.4),
          hot : random_range(0.5, 1),
          color : choose(c_white, global.avoid_col_warning, global.avoid_col_cyan)
        });
      }

      for (var _bc = 0; _bc < 34; _bc++) {
        if (array_length(rack_shards) >= _k_rack_shard_cap) break;
        var _bcs = choose(-1, 1);
        array_push(rack_shards, {
          x : (_bcs < 0) ? _k_rack_wall_l : _k_rack_wall_r,
          y : random_range(_k_rack_top_y, _k_rack_floor_y),
          vx : -_bcs * random_range(2.5, 7),
          vy : random_range(-4, 2),
          size : random_range(4, 13),
          rot : random(360),
          spin : random_range(-16, 16),
          life : irandom_range(34, 66),
          life_max : 66,
          color : choose(_k_rack_col_rail, _k_rack_col_rail_edge, global.avoid_col_warning),
          hot : random_range(0.4, 1)
        });
      }

      for (var _bv = 0; _bv < 22; _bv++) {
        var _bvs = choose(-1, 1);
        scr_spawn_vent_stream(rack_vents,
                              (_bvs < 0) ? _k_rack_wall_l : _k_rack_wall_r,
                              random_range(_k_rack_top_y, _k_rack_floor_y),
                              (_bvs < 0) ? 0 : 180,
                              0.85, _k_rack_vent_cols, _k_rack_vent_cap);
      }

      scr_impact_pulse(0.5, 0.8, 0.6, _k_rack_mid_x, 288);
      tear_amount = max(tear_amount, 0.85);
      global_ripple_pulse = max(global_ripple_pulse, 0.8);

      if (instance_exists(oCameraController)) {
        oCameraController.shake = max(oCameraController.shake, _k_rack_shake_blowout);
        oCameraController.zoom_punch = max(oCameraController.zoom_punch, 0.11);
        oCameraController.screen_flash_alpha = max(oCameraController.screen_flash_alpha, 0.2);
        oCameraController.letterbox_target = 0;
      }
    }

    if (rack_blowout > 0) rack_blowout = max(0, rack_blowout - 0.016);

    for (var _ti = 0; _ti < _k_rack_lanes; _ti++) {
      var _tn = rack_lanes[_ti];
      var _rate = (_tn.target > _tn.ext) ? _k_rack_close_rate : _k_rack_open_rate;
      _tn.ext = lerp(_tn.ext, _tn.target, _rate);
      if (_tn.ext < 0.002) _tn.ext = 0;
      if (_tn.ext > 0.998) _tn.ext = 1;
    }

    if (rack_armed && !rack_dead && instance_exists(oPlayer)) {
      for (var _ci = 0; _ci < _k_rack_lanes; _ci++) {
        var _cn = rack_lanes[_ci];
        if (_cn.ext <= _k_rack_lethal_ext) continue;

        var _cy0 = rack_band_y0(_ci);
        var _cy1 = rack_band_y1(_ci);
        var _lx = rack_tine_tip(-1, _cn.ext);
        var _rx = rack_tine_tip(1, _cn.ext);

        if (collision_rectangle(_k_rack_wall_l, _cy0, _lx, _cy1, oPlayer, false, true) != noone ||
            collision_rectangle(_rx, _cy0, _k_rack_wall_r, _cy1, oPlayer, false, true) != noone) {
          player_register_hazard_hit();
          break;
        }
      }
    }

    if (rack_live && !rack_dead) {
      rack_rail_heat[0] = max(rack_rail_heat[0] * 0.92, rack_coil * 0.4 * rack_amb);
      rack_rail_heat[1] = max(rack_rail_heat[1] * 0.92, rack_coil * 0.4 * rack_amb);

      if (rack_coil > 0.35 && (t mod 2 == 0)) {
        var _rv_side = choose(-1, 1);
        scr_spawn_vent_stream(rack_vents,
                              (_rv_side < 0) ? _k_rack_wall_l + 4 : _k_rack_wall_r - 4,
                              random_range(_k_rack_top_y + 12, _k_rack_floor_y - 12),
                              (_rv_side < 0) ? 0 : 180,
                              rack_coil * 0.7, _k_rack_vent_cols, _k_rack_vent_cap);
      }

      if (rack_coil > 0.55 && irandom(3) == 0 && array_length(rack_arcs) < 22) {
        for (var _ai = 0; _ai < _k_rack_lanes; _ai++) {
          if (rack_lanes[_ai].arm < 0.4) continue;
          var _aiy = rack_lane_cy(_ai);
          var _aix = random_range(_k_rack_wall_l, _k_rack_wall_r - 150);
          array_push(rack_arcs, {
            x1 : _aix, y1 : _aiy + random_range(-16, 16),
            x2 : _aix + random_range(70, 150), y2 : _aiy + random_range(-16, 16),
            life : irandom_range(4, 8),
            life_max : 8,
            hot : 0.4 + rack_coil * 0.5,
            color : _rack_next_fast ? global.avoid_col_cyan : global.avoid_col_warning,
            off : scr_bolt_offsets(5, 9)
          });
          break;
        }
      }
    }

    scr_update_vent_streams(rack_vents);

    for (var _pi = array_length(rack_lock_frames) - 1; _pi >= 0; _pi--) {
      rack_lock_frames[_pi].life--;
      if (rack_lock_frames[_pi].life <= 0) array_delete(rack_lock_frames, _pi, 1);
    }

    for (var _pi2 = array_length(rack_tips) - 1; _pi2 >= 0; _pi2--) {
      rack_tips[_pi2].life--;
      if (rack_tips[_pi2].life <= 0) array_delete(rack_tips, _pi2, 1);
    }

    for (var _pi3 = array_length(rack_arcs) - 1; _pi3 >= 0; _pi3--) {
      rack_arcs[_pi3].life--;
      if (rack_arcs[_pi3].life <= 0) array_delete(rack_arcs, _pi3, 1);
    }

    for (var _pi4 = array_length(rack_sparks) - 1; _pi4 >= 0; _pi4--) {
      var _sk = rack_sparks[_pi4];
      _sk.x += _sk.vx;
      _sk.y += _sk.vy;
      _sk.vx *= 0.94;
      _sk.vy = _sk.vy * 0.94 + 0.16;
      _sk.life--;
      if (_sk.life <= 0) array_delete(rack_sparks, _pi4, 1);
    }

    for (var _pi5 = array_length(rack_shards) - 1; _pi5 >= 0; _pi5--) {
      var _sh2 = rack_shards[_pi5];
      _sh2.x += _sh2.vx;
      _sh2.y += _sh2.vy;
      _sh2.vx *= 0.985;
      _sh2.vy = _sh2.vy * 0.985 + 0.19;
      _sh2.rot += _sh2.spin;
      _sh2.spin *= 0.98;
      _sh2.life--;
      if (_sh2.life <= 0 || _sh2.y > _k_rack_floor_y + 40) array_delete(rack_shards, _pi5, 1);
    }

    for (var _pi6 = array_length(rack_scars) - 1; _pi6 >= 0; _pi6--) {
      rack_scars[_pi6].life--;
      if (rack_scars[_pi6].life <= 0) array_delete(rack_scars, _pi6, 1);
    }

    if (timeline_hit(_k_rack_t_clear)) {
      rack_lock_frames = [];
      rack_arcs = [];
      rack_tips = [];
      rack_live = false;
      rack_armed = false;
      for (var _cl = 0; _cl < _k_rack_lanes; _cl++) {
        rack_lanes[_cl].ext = 0;
        rack_lanes[_cl].target = 0;
        rack_lanes[_cl].heat = 0;
        rack_lanes[_cl].arm = 0;
      }
    }
  }
