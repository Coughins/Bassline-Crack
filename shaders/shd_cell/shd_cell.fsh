varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform vec2 u_resolution;
uniform vec2 u_mouse;

#define HASHSCALE3 vec3(443.897,441.423,437.195)
#define PI 3.14159265
#define OCTAVES 4.0

vec3 hsb2rgb(vec3 c)
{
    vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0,0.0,1.0);
    rgb = rgb*rgb*(3.0-2.0*rgb);
    return c.z*mix(vec3(1.0),rgb,c.y);
}

vec2 rotate(vec2 p,float a)
{
    return vec2(
        p.x*cos(a)-p.y*sin(a),
        p.x*sin(a)+p.y*cos(a)
    );
}

vec2 hash22(vec2 p)
{
    vec3 p3 = fract(vec3(p.xyx)*HASHSCALE3);
    p3 += dot(p3,p3.yzx+19.19);
    return fract((p3.xx+p3.yz)*p3.zy);
}

float cell(vec2 x,float t)
{
    vec2 iPos = floor(x);
    vec2 fPos = fract(x);

    float minDist = 2.0;

    for(int yy=-1; yy<=1; yy++)
    {
        for(int xx=-1; xx<=1; xx++)
        {
            vec2 neighbor = vec2(float(xx),float(yy));

            vec2 randPoint = hash22(iPos+neighbor);

            randPoint = 0.5 + sin(t + randPoint*2.0*PI)*0.5;

            vec2 diff = neighbor + randPoint - fPos;

            float dist = length(diff);

            minDist = min(dist,minDist);
        }
    }

    return minDist;
}

void main()
{
    vec2 fragCoord = v_vTexcoord * u_resolution;

    vec2 p = fragCoord / u_resolution;

    vec2 m = 1.0 - u_mouse;

    vec2 pos = vec2(
        p.x * u_resolution.x / u_resolution.y,
        p.y
    );

    pos = rotate(pos,(m.x+m.y)*0.1);

    float brightness = 0.0;

    vec2 octavePos = pos;

    for(float i=1.0;i<=OCTAVES;i++)
    {
        brightness += cell(octavePos-(m*8.0),u_time*0.5*i)/i;
        octavePos *= OCTAVES;
    }

    brightness *= brightness;

    float hue = distance(p,m)*0.2 + 0.5;

    vec3 colour = hsb2rgb(vec3(hue,0.5,brightness));
	
    gl_FragColor = vec4(colour,1.0) * v_vColour;
}