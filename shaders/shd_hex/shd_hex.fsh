varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform vec2 u_resolution;
uniform float u_intro_dim;
uniform float u_bass;

uniform sampler2D u_noise;

#define TWO_PI 6.283185


vec3 iq_color_palette(vec3 a, vec3 b, vec3 c, vec3 d, float t)
{
    return a + b * cos(TWO_PI * (c*t + d));
}


// ------------------------------------------------------------
// HEX GRID
// ------------------------------------------------------------

vec4 hexagon(vec2 p)
{
    vec2 q = vec2(
        p.x*2.0*0.5773503,
        p.y + p.x*0.5773503
    );

    vec2 pi = floor(q);
    vec2 pf = fract(q);

    float v = mod(pi.x + pi.y,3.0);

    float ca = step(1.0,v);
    float cb = step(2.0,v);

    vec2 ma = step(pf.xy,pf.yx);

    float e = dot(
        ma,
        1.0-pf.yx +
        ca*(pf.x+pf.y-1.0) +
        cb*(pf.yx-2.0*pf.xy)
    );

    p = vec2(
        q.x + floor(0.5+p.y/1.5),
        4.0*p.y/3.0
    )*0.5+0.5;

    float f = length((fract(p)-0.5)*vec2(1.0,0.85));

    return vec4(pi+ca-cb*ma,e,f);
}


// ------------------------------------------------------------
// NOISE
// ------------------------------------------------------------

float hash1(vec2 p)
{
    float n = dot(p,vec2(127.1,311.7));
    return fract(sin(n)*43758.5453);
}


float noise(vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    vec2 uv = (p.xy + vec2(37.0,17.0)*p.z) + f.xy;

    vec2 rg = texture2D(
        u_noise,
        (uv+0.5)/256.0
    ).yx;

    return mix(rg.x,rg.y,f.z);
}


// ------------------------------------------------------------
// MAIN
// ------------------------------------------------------------

void main()
{
    vec2 fragCoord = v_vTexcoord * u_resolution;

    vec2 uv = fragCoord / u_resolution;


    // -------------------------
    // UV DISTORTION
    // -------------------------

    float warp = noise(vec3(
        uv * 3.0,
        u_time * 0.12
    ));

	uv += (warp - 0.5) * (0.018 + u_bass * 0.04);


    vec2 pos = (-u_resolution + 2.0*fragCoord)
        / u_resolution.y;

	float bass_wave = sin(
	    length(pos) * 18.0 - u_time * 8.0
	);

	bass_wave *= u_bass;

	pos += normalize(pos) * bass_wave * 0.015;
    // -------------------------
    // CAMERA DRIFT
    // -------------------------

    pos.x += sin(u_time * 0.25) * 0.06;
    pos.y += cos(u_time * 0.18) * 0.04;


    float t = 0.8*(1.0-pow(uv.y,0.5));

    pos.y -= 0.5;

    pos *= 2.0-0.3*pos.y;



    // -------------------------
    // MAIN HEX LAYER
    // -------------------------

    vec2 hex_pos = pos;

    hex_pos.x += u_time * 0.025;
    hex_pos.y += sin(u_time * 0.3) * 0.04;


	float bass_scale = 1.0 + u_bass * 0.25;

	vec4 h = hexagon(
	    12.0 * hex_pos * bass_scale
	);



    // -------------------------
    // SECOND DETAIL LAYER
    // -------------------------

    vec4 h2 = hexagon(
        26.0 * (pos + vec2(0.15))
        + u_time * 0.01
    );



    // -------------------------
    // NOISE LIGHTING
    // -------------------------

    float n = noise(vec3(
        0.3*h.xy +
        vec2(u_time*0.7,0.0),
        0.0
    ));


    t += 0.2*(1.0-n);



    // -------------------------
    // COLOR
    // -------------------------

    vec3 col = 0.5 * abs(
        sin(
            hash1(h.xy)*0.4
            + 1.6
            + vec3(1.0)
        )
    );



    float edge = smoothstep(
        0.08,
        0.0,
        abs(h.z - 0.5)
    );


    float detail_edge = smoothstep(
        0.04,
        0.0,
        abs(h2.z - 0.5)
    );


    col *= edge * (1.0 + u_bass * 3.0);

    col += detail_edge * 0.15;



    // -------------------------
    // ENERGY SHADING
    // -------------------------

    col *= 1.0 + 0.5*h.z*n;


    col *= 1.0 + 0.5 *
        iq_color_palette(
            vec3(0.5),
            vec3(0.5),
            vec3(2.0,1.0,0.0),
            vec3(0.5,0.2,0.25),
            u_time*0.02
        );


    col *= 0.7 + 0.3 *
        iq_color_palette(
            vec3(0.5),
            vec3(0.5),
            vec3(0.3,1.0,1.0),
            vec3(0.0,0.25,0.25),
            uv.y-0.8-u_time*0.05
        );



    // -------------------------
    // DEPTH FOG
    // -------------------------

    float depth = length(pos);

    col *= 1.0 -
        smoothstep(
            0.8,
            2.5,
            depth
        );



    // -------------------------
    // SCREEN VIGNETTE
    // -------------------------

	float vignette = pow(
	    16.0 *
	    uv.x *
	    (1.0-uv.x) *
	    uv.y *
	    (1.0-uv.y),
	    0.8
	);

	col *= mix(1.0, vignette, 0.35);



    // -------------------------
    // HOLOGRAM SCANLINES
    // -------------------------

    float scan = sin(
        fragCoord.y * 1.8 +
        u_time * 5.0
    );

    col *= 0.96 + scan * 0.04;



    // -------------------------
    // FINAL
    // -------------------------

    col *= 0.45 + u_bass * 0.35;

    col *= (1.0-u_intro_dim);


    gl_FragColor =
        vec4(col,1.0)
        *
        v_vColour;
}