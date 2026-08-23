varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_baseTex;
uniform vec2 u_resolution;
uniform vec2 u_centers[4];
uniform float u_radii[4];
uniform float u_strengths[4];
uniform int u_count;

void main()
{
    vec2 screen_pos = v_vTexcoord * u_resolution;
    vec2 total_offset = vec2(0.0);

    float ring_width = 26.0;
    float max_distort = 14.0;

    for (int i = 0; i < 4; i++)
    {
        if (i >= u_count) break;

        vec2 center = u_centers[i];
        float radius = u_radii[i];
        float strength = u_strengths[i];

        float dist = distance(screen_pos, center);
        float band = 1.0 - clamp(abs(dist - radius) / ring_width, 0.0, 1.0);
        band = band * band;

        vec2 dir = (dist > 0.001) ? normalize(screen_pos - center) : vec2(0.0);
        total_offset += dir * band * strength * max_distort;
    }

    vec2 offset_uv = total_offset / u_resolution;
    gl_FragColor = texture2D(u_baseTex, v_vTexcoord + offset_uv) * v_vColour;
}