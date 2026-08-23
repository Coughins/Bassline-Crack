vb_ribbon = -1;
vb_ribbon_glow = -1;
vf_ribbon = -1;

vertex_format_begin();

vertex_format_add_position_3d();
vertex_format_add_texcoord();
vertex_format_add_colour();

vf_ribbon = vertex_format_end();

vb_ribbon = vertex_create_buffer();

vb_ribbon_glow = vertex_create_buffer();

points = [];

test_time = 0;
ribbon_time = 0;

bass_strength = 0;
wall_flash = 0;

u_ribbon_time =
shader_get_uniform(
    shd_ribbon_plasma,
    "u_time"
);

u_wall_flash =
shader_get_uniform(
    shd_ribbon_plasma,
    "u_flash"
);