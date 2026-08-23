telegraph_life = 59;
telegraph_timer = 0;
particle_count = 10;
particle_angles = [];
rotate_speed = 8;
start_radius = 120;
current_radius = start_radius;
current_alpha = 0.15;


for (var i = 0; i < particle_count; i++) {
    array_push(particle_angles, (360 / particle_count) * i);
}

particle_prev_x = array_create(particle_count);
particle_prev_y = array_create(particle_count);
for (var i = 0; i < particle_count; i++) {
    particle_prev_x[i] = x + lengthdir_x(current_radius, particle_angles[i]);
    particle_prev_y[i] = y + lengthdir_y(current_radius, particle_angles[i]);
}

seam_angle = random(360);
seam_length = 0;
seam_max = 130;
seam_jag = [];
for (var i = 0; i < 7; i++) array_push(seam_jag, random_range(-9, 9));

void_radius = 0;
void_alpha = 0;

shock_rings = [];
shock_timer = 14;

claws = [];

chroma = 0;
