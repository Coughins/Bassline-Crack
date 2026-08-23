varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec3 u_color;
uniform float u_intensity;
uniform float u_falloff;
uniform vec4 u_uvRect; // u0, v0, u1, v1

// ===== GLOBAL GLOW TASTE KNOBS =====
const float GLOW_MASTER = 0.78;
const float GLOW_TIGHTEN = 1.20;

void main()
{
    vec2 localUV = (v_vTexcoord - u_uvRect.xy) / (u_uvRect.zw - u_uvRect.xy);
    vec2 centered = localUV - vec2(0.5);
    float dist = length(centered) * 2.0;

    float glow = 1.0 - clamp(dist, 0.0, 1.0);
    glow = pow(glow, u_falloff * GLOW_TIGHTEN);

    float intensity = u_intensity * GLOW_MASTER;

    vec3 finalColor = u_color * glow * intensity;
    float alpha = glow * intensity;

    gl_FragColor = vec4(finalColor, alpha) * v_vColour.a;
}
