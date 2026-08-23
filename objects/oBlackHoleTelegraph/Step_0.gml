telegraph_timer += 1;

for (var i = 0; i < particle_count; i++) {
    particle_prev_x[i] = x + lengthdir_x(current_radius, particle_angles[i]);
    particle_prev_y[i] = y + lengthdir_y(current_radius, particle_angles[i]);
}

for (var i = 0; i < particle_count; i++) {
    particle_angles[i] += rotate_speed;
}

var _progress = telegraph_timer / telegraph_life;

if (_progress < 0.8)
{
    var _p2 = _progress / 0.8;
    current_radius = lerp(start_radius, start_radius * 0.25, _p2);
    current_alpha  = lerp(0.15, 0.6, _p2);
    chroma = lerp(chroma, _p2 * 2, 0.15);
}
else
{
    var _p3 = (_progress - 0.8) / 0.2;
    var _eased = _p3 * _p3 * _p3;
    current_radius = lerp(start_radius * 0.25, 0, _eased);
    current_alpha  = lerp(0.6, 1.0, _eased);
    chroma = lerp(2, 16, _eased);

    if (telegraph_timer mod 2 == 0) {
        for (var i = 0; i < array_length(seam_jag); i++) seam_jag[i] = random_range(-9 - _eased * 22, 9 + _eased * 22);
    }
}

var _seam_e = _progress * _progress;
seam_length = lerp(0, seam_max, _seam_e) * (1 + max(0, _progress - 0.8) * 5);

void_radius = lerp(0, 46, _seam_e);
void_alpha = _seam_e * 0.8;

shock_timer -= 1;
if (shock_timer <= 0) {
    array_push(shock_rings, { r: 4, max_r: 90 + _progress * 150, life: 22, life_max: 22, w: 2 + _progress * 5 });
    shock_timer = max(3, round(lerp(14, 4, _progress)));

    var _claw_n = 1 + floor(_progress * 3);
    for (var c = 0; c < _claw_n; c++) {
        array_push(claws, {
            ang: random(360),
            len: random_range(30, 60 + _progress * 90),
            life: 16, life_max: 16,
            seed: random(1000)
        });
    }

    scr_floor_impact(x, y, 0.15 + _progress * 0.45, 0);
}
for (var i = array_length(shock_rings) - 1; i >= 0; i--) {
    var _sr = shock_rings[i];
    _sr.r = lerp(_sr.r, _sr.max_r, 0.13);
    _sr.life--;
    if (_sr.life <= 0) array_delete(shock_rings, i, 1);
}
for (var i = array_length(claws) - 1; i >= 0; i--) {
    claws[i].life--;
    if (claws[i].life <= 0) array_delete(claws, i, 1);
}

scr_register_glow_point(x, y);
scr_add_light(x, y, global.lightning_color, 1 + _seam_e * 5);

if (telegraph_timer >= telegraph_life) {
    instance_destroy();
}