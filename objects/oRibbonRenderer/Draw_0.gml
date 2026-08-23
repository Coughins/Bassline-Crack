scr_wall_build(
    vb_ribbon_glow,
    vf_ribbon,
    points,
    105,
    c_red,
    ribbon_time
);

scr_wall_build(
    vb_ribbon,
    vf_ribbon,
    points,
    80,
    c_red,
    ribbon_time
);

gpu_set_blendmode(bm_add);

draw_set_alpha(0.22);

shader_set(shd_ribbon_plasma);

shader_set_uniform_f(
    u_ribbon_time,
    ribbon_time
);

shader_set_uniform_f(
    u_wall_flash,
    wall_flash
);

vertex_submit(
    vb_ribbon_glow,
    pr_trianglelist,
    -1
);

shader_reset();

draw_set_alpha(1);

shader_set(shd_ribbon_plasma);

shader_set_uniform_f(
    u_ribbon_time,
    ribbon_time
);

shader_set_uniform_f(
    u_wall_flash,
    wall_flash
);

vertex_submit(
    vb_ribbon,
    pr_trianglelist,
    -1
);

shader_reset();

for (var i = 0; i < array_length(points); i += 6)
{
    scr_add_light(
        points[i].px,
        points[i].py,
        c_red,
        0.7 + wall_flash * 0.8
    );
}

draw_set_alpha(1);

gpu_set_blendmode(bm_normal);