varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform float u_time;
uniform float u_strength;
uniform vec2  u_texel;
uniform sampler2D u_baseTex;
uniform float u_vignette_intensity;
uniform float u_aberration_strength;
uniform float u_bloom_intensity;
uniform float u_tear_amount;
uniform float u_global_ripple;
uniform vec2 u_ring_centers[4];
uniform float u_ring_radii[4];
uniform float u_ring_strengths[4];
uniform int u_ring_count;
uniform vec2  u_swirl_centers[4];
uniform float u_swirl_radii[4];
uniform float u_swirl_strengths[4];
uniform int   u_swirl_count;
uniform float u_intro_dim;
uniform float u_slash_amount;
uniform vec2  u_slash_center;  // UV-space point the cut passes through

// ================= GLOBAL POST-FX TASTE KNOBS =================
const float BLOOM_KNEE      = 0.82;
const float BOLT_ADDBACK    = 0.45;  // how hard bolt_surface is re-added on top of the warped scene (was 0.6)
const float LOCAL_WARP      = 22.0;
const float GLOBAL_RIPPLE_WARP = 13.0; // texels of full-screen ripple before localized swirls
const float SHOCK_WARP      = 62.0;
const float SCREEN_WARP_UV  = 0.045; // cap non-vortex screen displacement before black-hole swirls
const float MAX_WARP_UV     = 0.10;  // hard ceiling on total UV displacement (was 0.15 = 15% of the screen)
const float SLASH_GLOW_GAIN = 1.10;

float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

void main()
{
vec2 tearCoord = v_vTexcoord;
    if (u_tear_amount > 0.0) {
        float bandCount = 250.0;
        float band = floor(v_vTexcoord.y * bandCount);
        float shift = (hash(band + floor(u_time * 12.0)) - 0.5) * u_tear_amount * 0.032;
        tearCoord.x += shift;
    }

    // --- diagonal sword-cut split (bottom-left -> top-right), each half drifts straight apart ---
    vec2 slashNormal = normalize(vec2(1.0, 1.0));
    vec2 toSlashCenter = tearCoord - u_slash_center;
    float slashSide = dot(toSlashCenter, slashNormal);
    float slashOffsetDist = u_slash_amount * 0.05;
    vec2 slashOffset = slashNormal * sign(slashSide) * slashOffsetDist;
    tearCoord -= slashOffset;

    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = tearCoord - center;
    float dist = length(toCenter);

    float mask = 0.0;
    for (int x = -3; x <= 3; x++) {
        for (int y = -3; y <= 3; y++) {
            vec2 offset = vec2(float(x), float(y)) * u_texel * 4.0;
            mask += texture2D(gm_BaseTexture, tearCoord + offset).a;
        }
    }
    mask /= 49.0;
    mask = clamp(mask * 3.0, 0.0, 1.0);

    float n1 = sin(tearCoord.y * 80.0 + u_time * 30.0);
    float n2 = sin(tearCoord.x * 60.0 - u_time * 25.0);
    vec2 localDistortion = vec2(n1, n2) * u_texel * LOCAL_WARP * mask * u_strength;

    float rippleWave = sin(dist * 25.0 - u_time * 15.0) * u_global_ripple;
    vec2 globalDistortion = normalize(toCenter + 0.001) * u_texel * GLOBAL_RIPPLE_WARP * rippleWave;
    localDistortion += globalDistortion;

    // --- localized ring shockwaves (capped, never affects the whole screen) ---
    vec2 shockDistortion = vec2(0.0);
    for (int i = 0; i < 4; i++) {
        if (i >= u_ring_count) break;

        vec2 toRing = tearCoord - u_ring_centers[i];
        float rdist = length(toRing);
        float band = 1.0 - clamp(abs(rdist - u_ring_radii[i]) / 0.04, 0.0, 1.0);
        band = band * band;

        vec2 dir = normalize(toRing + 0.0001);
        shockDistortion += dir * u_texel * SHOCK_WARP * band * u_ring_strengths[i];
    }
	
	localDistortion += shockDistortion;

    float _screenDistMag = length(localDistortion);
    if (_screenDistMag > SCREEN_WARP_UV) {
        localDistortion = localDistortion * (SCREEN_WARP_UV / _screenDistMag);
    }

	// --- drain/vortex swirls (multiple independent points) ---
	    for (int i = 0; i < 4; i++) {
	        if (i >= u_swirl_count) break;

	        vec2 toSwirl = tearCoord - u_swirl_centers[i];
	        float swirlDist = length(toSwirl);
	        float swirlFall = smoothstep(u_swirl_radii[i], 0.0, swirlDist);
	        float swirlAngle = u_swirl_strengths[i] * swirlFall * 2.5;
	        float sSin = sin(swirlAngle);
	        float sCos = cos(swirlAngle);
	        vec2 swirlRotated = vec2(
	            toSwirl.x * sCos - toSwirl.y * sSin,
	            toSwirl.x * sSin + toSwirl.y * sCos
	        );
	        vec2 swirlPulled = swirlRotated + normalize(toSwirl + 0.0001) * swirlFall * u_swirl_strengths[i] * 0.05;
	        localDistortion += (swirlPulled - toSwirl);
	    }

    vec2 lensAberrOffset = vec2(0.0);
    for (int i = 0; i < 4; i++) {
        if (i >= u_swirl_count) break;
        vec2 toS = tearCoord - u_swirl_centers[i];
        float sd = length(toS);
        float edgeBand = 1.0 - clamp(abs(sd - u_swirl_radii[i] * 0.7) / (u_swirl_radii[i] * 0.25), 0.0, 1.0);
        edgeBand = edgeBand * edgeBand;
        vec2 dirS = normalize(toS + 0.0001);
        lensAberrOffset += dirS * edgeBand * u_swirl_strengths[i] * u_texel * 60.0;
    }
	
    float _distMag = length(localDistortion);
    float _maxDist = MAX_WARP_UV; // easy knob: max allowed UV-space displacement
    if (_distMag > _maxDist) {
        localDistortion = localDistortion * (_maxDist / _distMag);
    }

    vec2 aberrOffset = toCenter * u_aberration_strength * 0.01 + lensAberrOffset;
    float _aberrMag = length(aberrOffset);
    float _maxAberr = 0.05;
    if (_aberrMag > _maxAberr) {
        aberrOffset = aberrOffset * (_maxAberr / _aberrMag);
    }
    float r = texture2D(u_baseTex, tearCoord + localDistortion + aberrOffset).r;
    float g = texture2D(u_baseTex, tearCoord + localDistortion).g;
    float b = texture2D(u_baseTex, tearCoord + localDistortion - aberrOffset).b;
    vec3 warped = vec3(r, g, b);

    vec3 bloom = vec3(0.0);
    float bloomSamples = 0.0;
    for (int x = -2; x <= 2; x++) {
        for (int y = -2; y <= 2; y++) {
            vec2 offset = vec2(float(x), float(y)) * u_texel * 3.0;
            vec3 samp = texture2D(u_baseTex, tearCoord + offset).rgb;
            float brightness = dot(samp, vec3(0.299, 0.587, 0.114));
            float thresholded = smoothstep(BLOOM_KNEE, 1.0, brightness);
            bloom += samp * thresholded;
            bloomSamples += 1.0;
        }
    }
    bloom /= bloomSamples;

    vec3 sceneColor = warped + bloom * u_bloom_intensity;
    float vignette = 1.0 - smoothstep(0.3, 0.8, dist) * u_vignette_intensity;
    sceneColor *= vignette;

    float slashLineDist = abs(slashSide);
    float slashGlowWidth = 0.01 + slashOffsetDist;
    float slashGlow = (1.0 - smoothstep(0.0, slashGlowWidth, slashLineDist)) * u_slash_amount;
    vec3 slashGlowColor = vec3(1.0, 0.25, 0.2) * slashGlow * SLASH_GLOW_GAIN; // hot white-red edge

    vec4 bolt = texture2D(gm_BaseTexture, tearCoord);
    vec4 result = vec4(sceneColor + slashGlowColor, 1.0) + bolt * BOLT_ADDBACK;
	
	result.rgb *= (1.0 - u_intro_dim); 
    gl_FragColor = result * v_vColour;
}
