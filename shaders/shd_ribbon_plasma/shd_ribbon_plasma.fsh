varying vec2 v_uv;
varying vec4 v_colour;

uniform float u_time;
uniform float u_flash;


void main()
{
    vec2 uv = v_uv;


    float flow =
        sin(uv.y * 0.7 + u_time * 2.0)
        +
        sin(uv.y * 1.8 - u_time * 3.0);


    float detail =
        sin(uv.x * 12.0 + uv.y * 3.0 + u_time * 4.0);


    float edge =
        1.0 - abs(fract(uv.x) * 2.0 - 1.0);

    edge = pow(edge, 0.6);


    float energy =
        clamp(
            edge
            + flow * 0.08
            + detail * 0.04,
            0.0,
            1.0
        );


    vec3 dark =
        vec3(0.03,0.0,0.0);


    vec3 red =
        vec3(1.0,0.03,0.01);


    vec3 col =
        mix(
            dark,
            red,
            energy
        );

	col += vec3(1.0,0.3,0.1) * u_flash;
	
    gl_FragColor =
        vec4(col,0.9)
        * v_colour;
}