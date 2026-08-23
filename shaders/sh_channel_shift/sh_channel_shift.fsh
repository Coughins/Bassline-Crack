varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_amount;
uniform float u_time;

float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.9898,78.233))) * 43758.5453);
}

void main()
{
    vec2 uv = clamp(v_vTexcoord, vec2(0.001), vec2(0.999));

    float line = floor(uv.y * 300.0);
    float lineNoise = rand(vec2(line, floor(u_time * 60.0)));
    float lineShift = (lineNoise - 0.5) * 0.08 * u_amount;

    float wave = sin(uv.y * 140.0 + u_time * 35.0) * 0.012 * u_amount;

    float shift = lineShift + wave;

    vec2 rUV = uv + vec2( shift + 0.02 * u_amount, 0.0);
    vec2 gUV = uv;
    vec2 bUV = uv + vec2(-shift - 0.02 * u_amount, 0.0);

    vec4 col;
    col.r = texture2D(gm_BaseTexture, clamp(rUV, vec2(0.001), vec2(0.999))).r;
    col.g = texture2D(gm_BaseTexture, gUV).g;
    col.b = texture2D(gm_BaseTexture, clamp(bUV, vec2(0.001), vec2(0.999))).b;
    col.a = texture2D(gm_BaseTexture, uv).a;


    float staticStrength = max(u_amount - 1.0, 0.0) * 0.15;

    float staticNoise = rand(
        floor(uv * vec2(640.0,360.0))
        + floor(u_time * 120.0)
    );

    col.rgb += (staticNoise - 0.5) * staticStrength;


    float flicker = 1.0 + sin(u_time * 90.0) * 0.04 * u_amount;
    col.rgb *= flicker;

    gl_FragColor = col * v_vColour;
}