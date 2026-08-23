
if (!dna_mode) {
    draw_self();
    exit;
}

var _blood = global.avoid_col_blood;
var _danger = global.avoid_col_danger;
var _cyan = global.avoid_col_cyan;
var _hot = global.avoid_col_hot;
var _chain_flash = instance_exists(oAvoidanceController) ? oAvoidanceController.dna_chain_flash : 0;
var _front = clamp((dna_z / max(dna_radius, 1) + 1) * 0.5, 0, 1);
var _lit = lightning_hit ? 1 : 0;
var _strike = clamp(strike_flash, 0, 1);
var _heat = clamp(_lit * 0.32 + _strike + _chain_flash * 0.65, 0, 1);

var _body_col = merge_color(_blood, _danger, 0.42 + _front * 0.16 + _heat * 0.22);
if (dna_type == 2) {
    _body_col = merge_color(_blood, _cyan, 0.12 + _lit * 0.08 + _chain_flash * 0.08);
}
var _rim_col = merge_color(_body_col, _hot, clamp(_strike * 0.7 + _chain_flash * 0.25, 0, 1));
var _circuit_a = image_alpha * (0.16 + _lit * 0.14 + _strike * 0.35 + _chain_flash * 0.18);
var _core_a = image_alpha * (0.16 + _lit * 0.10 + _strike * 0.52 + _chain_flash * 0.28);

draw_sprite_ext(sRedOrb, 0, x, y, image_xscale * 1.08, image_yscale * 1.08,
                image_angle, merge_color(c_black, _blood, 0.55), image_alpha * 0.55);
draw_sprite_ext(sRedOrb, 0, x, y, image_xscale, image_yscale,
                image_angle, _rim_col, image_alpha * (0.72 + _heat * 0.18));
draw_sprite_ext(sprite_index, image_index, x, y, image_xscale * 0.72, image_yscale * 0.72,
                image_angle, merge_color(_cyan, c_white, _strike * 0.45), _circuit_a);

draw_set_color(merge_color(_hot, c_white, clamp(_strike + _chain_flash * 0.45, 0, 1)));
draw_set_alpha(_core_a);
draw_circle(x, y, max(1.2, image_xscale * 2.3), false);
draw_set_alpha(1);
draw_set_color(c_white);
