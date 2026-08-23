if (instance_exists(oDNATest) && dna_veil > 0.06) {

  gpu_set_blendmode(bm_add);

  with (oDNATest) {
    if (strike_flash <= 0.01) continue;
    var _sf_scale = image_xscale * (1 + strike_flash * 0.5);
    draw_sprite_ext(sprite_index, image_index, x, y, _sf_scale, _sf_scale, image_angle,
                    c_white, strike_flash * 0.9);
  }

  with (oDNATest) {
    if (line_life <= 0) continue;

    line_life--;
    if (chain_target != noone) {
      line_target_x = chain_target.x;
      line_target_y = chain_target.y;
    }
    scr_draw_lightning_bolt(line_target_x, line_target_y, line_life, line_life_max, 6, true,
                            merge_color(global.avoid_col_danger, global.avoid_col_cyan, 0.24),
                            0.08, 8, "", 3, false);
  }

  gpu_set_blendmode(bm_normal);
  draw_set_alpha(1);
  draw_set_color(c_white);
}

scr_riser_draw_rails();

scr_vault_draw_shell();

scr_duct_draw_rails();
