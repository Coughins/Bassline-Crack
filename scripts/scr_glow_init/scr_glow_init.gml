function scr_glow_init(){
global.u_glow_color     = shader_get_uniform(shd_bullet_glow, "u_color");
global.u_glow_intensity = shader_get_uniform(shd_bullet_glow, "u_intensity");
global.u_glow_falloff   = shader_get_uniform(shd_bullet_glow, "u_falloff");
global.u_glow_uvrect = shader_get_uniform(shd_bullet_glow, "u_uvRect");
}