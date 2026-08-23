varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_intensity;
uniform vec2  u_texel;

void main()
{
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);

    vec4 glow = vec4(0.0);
    float total = 0.0;
    for (int x = -4; x <= 4; x++)
    {
        for (int y = -4; y <= 4; y++)
        {
            vec2 offset = vec2(float(x), float(y)) * u_texel * 3.0;
            float weight = 1.0 / (1.0 + float(x*x + y*y) * 0.5);
            glow += texture2D(gm_BaseTexture, v_vTexcoord + offset) * weight;
            total += weight;
        }
    }
    glow /= total;

    float flicker = 0.7 + 0.3 * sin(u_time * 90.0) * sin(u_time * 47.0 + v_vTexcoord.y * 20.0);

    float brightness = glow.a;
    vec3 core   = vec3(1.0, 1.0, 1.0);
    vec3 mid    = vec3(1.0, 0.95, 0.4);
    vec3 edge   = vec3(0.6, 0.2, 1.0);
    vec3 rampColor = mix(edge, mid, clamp(brightness * 2.0, 0.0, 1.0));
    rampColor = mix(rampColor, core, clamp(brightness * 4.0 - 1.0, 0.0, 1.0));

    vec2 aberration = vec2(u_texel.x * 3.0, 0.0);
    float glowR = texture2D(gm_BaseTexture, v_vTexcoord + aberration).a;
    float glowB = texture2D(gm_BaseTexture, v_vTexcoord - aberration).a;

    vec3 finalGlow = rampColor * glow.a * u_intensity * flicker * 3.0;
    finalGlow.r += glowR * u_intensity * 0.5;
    finalGlow.b += glowB * u_intensity * 0.5;

    vec3 finalColor = col.rgb + finalGlow;
    float finalAlpha = clamp(col.a + glow.a * u_intensity * flicker, 0.0, 1.0);

    gl_FragColor = vec4(finalColor, finalAlpha) * v_vColour;
}