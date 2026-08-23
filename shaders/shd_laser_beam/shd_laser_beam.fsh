varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_time;
uniform sampler2D u_noise;

uniform float u_speed;
uniform float u_coreWidth;
uniform float u_haloWidth;
uniform float u_noiseStrength;
uniform float u_twist;
uniform float u_brightness;
uniform float u_whiteAmount;

float getNoise(float x, float block)
{
    float n = (texture2D(u_noise, vec2(x, block)).r - 0.5) * 2.0;
    return n;
}


mat2 getRotationMatrix(float angle)
{
    float c = cos(angle);
    float s = sin(angle);
    return mat2(c, s, -s, c);
}

void main()
{
    vec2 uv;
    uv.x = (v_vTexcoord.x - 0.5) * 2.0;
    uv.y = (v_vTexcoord.y - 0.5) * 2.0;

    vec2 raySpacePosition = uv;
    float paramTime = u_time * u_speed;

    float strength = 1.0;

    // --- narrow field (ray core) ---
    vec2 nuv = raySpacePosition;
    float pixelNoiseN = getNoise(nuv.y / 4.0 - paramTime, 0.2);
    float widthModifierN = pixelNoiseN * max(u_noiseStrength, 0.0) * 0.6;
    float xDistanceN = abs(nuv.x) + abs(widthModifierN);
    float innerThickness = max(0.03, u_coreWidth * 0.8);
    float alphaN = 1.0 - clamp(xDistanceN / innerThickness, 0.0, 1.0);
    alphaN = alphaN * alphaN;

    // --- wide field (scatter halo) ---
    vec2 wuv = raySpacePosition;
    float pixelNoiseW = getNoise(
        wuv.y / 2.0 - paramTime * 3.0,
        (wuv.x - sign(wuv.x) * paramTime * 1.0 + pixelNoiseN * 0.08) * 0.6);

    float angle = pixelNoiseW * (u_twist * 1.4);
    vec2 rotationOrigin = vec2(0.0, 40.0);
    vec2 displacedWuv = getRotationMatrix(angle) * (wuv - rotationOrigin) + rotationOrigin;

    float xDistanceW = abs(displacedWuv.x);
    float haloThickness = max(0.03, u_haloWidth * 0.8);
    float alphaW = 1.0 - clamp(xDistanceW / haloThickness, 0.0, 1.0);
    alphaW = pow(alphaW, 0.6);
	

    // --- combine ---
    vec3 colW = vec3(0.660, 0.0198, 0.0198);
    vec3 colN = vec3(1.0, 1.0, 0.95);
    vec3 col = mix(colW, colN, clamp(alphaN * u_whiteAmount, 0.0, 1.0));
    col *= max(0.0, u_brightness);
    gl_FragColor = mix(vec4(0.0), vec4(col, 1.0), min(1.0, alphaN + alphaW)) * v_vColour;
}