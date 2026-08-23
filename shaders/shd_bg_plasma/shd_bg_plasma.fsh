varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform float u_intensity;
uniform float u_noise_scale;
uniform vec2  u_scroll_speed;
uniform vec3  u_color_low;
uniform vec3  u_color_high;
uniform float u_base_brightness;

#define MAX_GLOW_POINTS 150
uniform float u_glow_points[MAX_GLOW_POINTS * 2]; // flat: x0,y0,x1,y1,...
uniform float u_darken_radius;
uniform float u_darken_strength;

float plasma(vec2 uv, float t) {
    float v = 0.0;
    v += sin(uv.x * u_noise_scale + t);
    v += sin(uv.y * u_noise_scale * 1.3 - t * 0.7);
    v += sin((uv.x + uv.y) * u_noise_scale * 0.6 + t * 1.2);
    v += sin(length(uv - 0.5) * u_noise_scale * 1.6 - t * 0.5);
    return v * 0.25;
}

void main() {
    vec2 uv = v_vTexcoord + u_scroll_speed * u_time;
    float n = plasma(uv, u_time) * 0.5 + 0.5;

    float brightness = u_base_brightness + n * (0.15 + u_intensity * u_intensity * 0.6);

    float darken = 0.0;
	for (int i = 0; i < MAX_GLOW_POINTS; i++) {
	    vec2 pt = vec2(u_glow_points[i*2], u_glow_points[i*2 + 1]);
	    float d = distance(v_vTexcoord, pt);
        float falloff = 1.0 - smoothstep(0.0, u_darken_radius, d);
        darken = max(darken, falloff);
    }
    brightness *= (1.0 - darken * u_darken_strength);

    vec3 col = mix(u_color_low, u_color_high, n) * brightness;
    gl_FragColor = vec4(col, 1.0);
}