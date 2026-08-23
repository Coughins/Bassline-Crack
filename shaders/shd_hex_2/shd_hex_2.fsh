varying vec2 v_vTexcoord;
varying vec4 v_vColour;

// ============================================================================
// ============================================================================

// --- timing / global envelopes ---
uniform float u_time;    // song time in seconds (t / room_speed) — beat-locked, NOT wall clock
uniform float u_intro_dim;
uniform float u_bass;
uniform float u_beat;
uniform float u_charge;
uniform vec2 u_resolution;

// --- camera / framing ---
uniform float u_quad_scale;
uniform float u_floor_zoom;   // camera zoom -> floor scale
uniform vec2 u_floor_offset;  // camera pan/shake -> floor offset
uniform float u_spin;         // grid roll kick, radians

// --- reactive systems ---
uniform float u_bass_waves[8];
uniform float u_bass_wave_count;

uniform float u_impact_wave_radius;  // negative = inactive
uniform vec3 u_impact_wave_color;

uniform vec4 u_quakes[6];  // xy = epicentre, z = radius, w = power
uniform float u_quake_count;

uniform vec4 u_scar_a[8];
uniform vec4 u_scar_b[8];    // x = age01, y = heat, z = seed, w = width
uniform vec4 u_scar_c[8];
uniform vec3 u_scar_col[8];
uniform float u_scar_count;

uniform vec2 u_focus;
uniform float u_focus_amt;

// --- actors ---
uniform vec2 u_player_pos;
uniform float u_player_glow;

uniform vec2 u_shadow_pos[32];
uniform float u_shadow_count;

uniform float u_light_pos_flat[256];
uniform vec3 u_light_color[128];
uniform float u_light_power[128];
uniform float u_light_count;

// ============================================================================
// HELPERS
// ============================================================================

float hash21(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }

vec4 hexagon(vec2 p) {
  vec2 q = vec2(p.x * 1.1547, p.y + p.x * 0.57735);
  vec2 pf = fract(q);
  vec2 cell = floor(q);
  float v = mod(cell.x + cell.y, 3.0);

  float ca = step(1.0, v);
  float cb = step(2.0, v);
  vec2 ma = step(pf.xy, pf.yx);

  float e = dot(
      ma, 1.0 - pf.yx + ca * (pf.x + pf.y - 1.0) + cb * (pf.yx - 2.0 * pf.xy));

  p = (vec2(q.x + floor(0.5 + p.y / 1.5), 4.0 * p.y / 3.0)) * 0.5 + 0.5;

  float f = length((fract(p) - 0.5) * vec2(1.0, 0.85));

  return vec4(cell + ca - cb * ma, e, f);
}

float hex_layer(vec2 p, float scale, float speed, float alpha) {
  p.x += u_time * speed;
  vec4 h = hexagon(p * scale);
  return smoothstep(0.10, 0.0, h.z) * alpha;
}

float shadow_blob(vec2 p, vec2 s, float size) {
  float d = length(p - s);
  return 1.0 - smoothstep(size, size * 2.0, d);
}

vec2 fracture(vec2 p, vec2 o, float ang, float half_len, float width, float seed) {
  vec2 d = vec2(cos(ang), sin(ang));
  vec2 rel = p - o;
  vec2 lp = vec2(dot(rel, d), dot(rel, vec2(-d.y, d.x)));

  float along = clamp(lp.x, -half_len, half_len);
  float wob = sin(along * 23.0 + seed) * 0.030 + sin(along * 61.0 + seed * 2.3) * 0.011;

  float dist = length(vec2(lp.x - along, lp.y - wob));
  float taper = smoothstep(half_len, half_len * 0.55, abs(lp.x));

  float core = smoothstep(width, width * 0.15, dist) * taper;
  float halo = smoothstep(width * 7.0, 0.0, dist) * taper;

  return vec2(core, halo);
}

void main() {
  vec2 frag = v_vTexcoord * u_resolution;

  vec2 spos = ((-u_resolution + 2.0 * frag) / u_resolution.y) * u_quad_scale;

  vec2 fpos = spos * u_floor_zoom + u_floor_offset;

  float sr = sin(u_spin);
  float cr = cos(u_spin);
  fpos = vec2(fpos.x * cr - fpos.y * sr, fpos.x * sr + fpos.y * cr);

  float beat_kick = u_beat * u_beat;
  float breathe = sin(u_time * (0.5 + u_charge * 3.0)) * (0.005 + u_charge * 0.014);
  fpos *= 1.0 + breathe + u_bass * 0.04 + beat_kick * 0.022 * (0.35 + u_charge);

  float perspective = 1.0 / max(1.0 + fpos.y * 0.20, 0.25);
  fpos *= perspective;

  float shock_dist = length(fpos);
  vec2 radial = fpos / (shock_dist + 1e-4);

  vec2 buckle = vec2(0.0);
  float lift = 0.0;       // quake-driven
  float beat_lift = 0.0;  // bass-ring-driven
  float scorch = 0.0;

  float shockwave = 0.0;
  float shock_glow = 0.0;
  float wake = 0.0;

  for (int i = 0; i < 8; i++) {
    if (float(i) >= u_bass_wave_count) break;

    float r = u_bass_waves[i];
    float ring = shock_dist - r;
    float d = abs(ring);

    shockwave += smoothstep(0.12, 0.0, d);
    shock_glow += smoothstep(0.30, 0.0, d);
    wake += smoothstep(0.80, 0.0, abs(ring + 0.25));

    float fade = 1.0 - clamp(r / 3.0, 0.0, 1.0);
    float prof = exp(-ring * ring * 26.0) * fade;

    buckle += radial * prof * 0.035 * (0.5 + u_bass);
    beat_lift += prof * (0.45 + 0.85 * u_bass);
  }

  for (int i = 0; i < 6; i++) {
    if (float(i) >= u_quake_count) break;

    vec4 q = u_quakes[i];
    vec2 qd = fpos - q.xy;
    float qdist = length(qd) + 1e-4;
    float ring = qdist - q.z;

    float prof = exp(-ring * ring * 14.0) * q.w;

    buckle += (qd / qdist) * prof * 0.10;
    lift += prof * 1.7;
    scorch += smoothstep(0.0, -0.55, ring) * q.w * smoothstep(1.7, 0.25, q.z);
  }

  shockwave = min(shockwave, 1.0);
  shock_glow = min(shock_glow, 1.0);
  wake = min(wake, 1.0);

  fpos += buckle;

  float haze_amt = 0.004 + u_bass * 0.02 + u_charge * 0.012 + min(lift + beat_lift, 2.0) * 0.008;

  float warp1 = sin(fpos.x * 8.0 + u_time * 2.0);
  float warp2 = cos(fpos.y * 7.0 - u_time * 1.7);
  float warp3 = sin((fpos.x + fpos.y) * 12.0 + u_time * 3.5);

  fpos += vec2(warp1 + warp3, warp2 - warp3) * haze_amt;

  // --------------------------------------------------------------------------
  // PLATE GEOMETRY
  // --------------------------------------------------------------------------
  vec4 base_hex = hexagon(fpos * 6.0);
  vec2 cell = base_hex.xy;
  float cell_rand = hash21(cell);

  float line = 0.0;
  line += hex_layer(fpos, 6.0, 0.01, 0.45);
  line += hex_layer(fpos + vec2(0.3, 0.2), 18.0, -0.02, 0.18);
  line += hex_layer(fpos - vec2(0.4, -0.5), 40.0, 0.04, 0.05);

  float top = pow(1.0 - base_hex.z, 8.0);
  float side = pow(1.0 - base_hex.z, 2.0) - top;

  top *= mix(0.7, 1.0, cell_rand);

  float cracks = smoothstep(0.18, 0.0, base_hex.z);
  float edge_light =
      smoothstep(0.15, 0.0, base_hex.z) - smoothstep(0.03, 0.0, base_hex.z);

  float plate_rand = 0.40 + 1.20 * cell_rand;
  float molten_kick = min(lift * plate_rand, 3.0);
  float beat_plate = min(beat_lift * plate_rand, 2.0);
  float tile_kick = min(molten_kick + beat_plate, 3.0);

  vec2 pull_target = mix(u_player_pos, u_focus, clamp(u_focus_amt, 0.0, 1.0));
  vec2 to_target = pull_target - spos;
  vec2 pull_dir = to_target / (length(to_target) + 1e-4);

  float player_pull = dot(normalize(cell + 1e-4), pull_dir) * 0.5 + 0.5;

  float flow_speed = 4.0 + u_charge * 9.0;
  float inward = length(spos - pull_target) * (7.0 * clamp(u_focus_amt, 0.0, 1.0));

  float river_flow =
      sin(cell.x * 2.0 + cell.y * 3.0 + u_time * flow_speed + player_pull * 25.0 - inward);
  river_flow = pow(river_flow * 0.5 + 0.5, 3.0);

  float power_flow = sin(cell.x * 4.0 + cell.y * 2.0 - u_time * (2.0 + u_charge * 4.0));
  power_flow = pow(power_flow * 0.5 + 0.5, 6.0);

  float chase = fract(cell.x * 0.11 + cell.y * 0.07 - u_time * (0.35 + u_charge * 1.1));
  float chase_lit = smoothstep(0.05, 0.0, chase) * cracks;

  float crack_core = 0.0;
  vec3 crack_light = vec3(0.0);

  for (int i = 0; i < 8; i++) {
    if (float(i) >= u_scar_count) break;

    vec4 a = u_scar_a[i];
    vec4 b = u_scar_b[i];
    vec4 c = u_scar_c[i];

    float grow = smoothstep(0.0, 0.10, b.x);
    float hl = max(a.w * grow, 0.004);

    vec2 m = fracture(fpos, a.xy, a.z, hl, b.w, b.z);

    vec2 borigin = a.xy + vec2(cos(a.z), sin(a.z)) * hl * c.y;
    vec2 mb = fracture(fpos, borigin, a.z + c.x, hl * 0.45, b.w * 0.75, b.z + 17.0);

    float core = max(m.x, mb.x);
    float halo = max(m.y, mb.y);

    float flicker = 0.75 + 0.25 * sin(u_time * 26.0 + b.z * 12.0);

    crack_core = max(crack_core, core);
    crack_light += u_scar_col[i] * halo * b.y * flicker * (0.35 + 0.9 * core);
  }

  float river_mask = smoothstep(0.4, 0.8, river_flow) * cracks;

  vec3 local_light = vec3(0.0);
  vec3 rim_light = vec3(0.0);
  vec3 reflection = vec3(0.0);

  for (int i = 0; i < 128; i++) {
    if (float(i) >= u_light_count) break;

    vec2 lp = vec2(u_light_pos_flat[i * 2], u_light_pos_flat[i * 2 + 1]);
    vec3 lc = u_light_color[i];
    float lpow = u_light_power[i];

    vec2 ld = spos - lp;
    float d = length(ld);

    float falloff = 1.0 - smoothstep(0.0, 0.6, d);
    falloff *= falloff;

    local_light += lc * falloff * lpow * mix(0.15, 1.0, river_mask) * 0.25;
    local_light += lc * falloff * lpow * top * 0.12;
    rim_light += lc * falloff * lpow * 0.10;

    float down = ld.y;
    float col_w = max(0.0, 1.0 - abs(ld.x) * (9.0 - 3.0 * u_bass));
    float col_l = max(0.0, 1.0 - down * 2.2);
    float col_f = col_w * col_w * col_l * col_l * step(0.0, down);
    float shimmer = 0.55 + 0.45 * sin(down * 34.0 - u_time * 5.0 + lp.x * 11.0);

    reflection += lc * col_f * shimmer * lpow * 0.085 * smoothstep(0.0, 0.10, down);
  }

  local_light = clamp(local_light, 0.0, 1.4);
  rim_light = clamp(rim_light, 0.0, 1.0);
  reflection = clamp(reflection, 0.0, 1.2);

  // --------------------------------------------------------------------------
  // SHADOWS
  // --------------------------------------------------------------------------
  float shadows = shadow_blob(spos, u_player_pos, 0.075);

  vec2 pd = spos - u_player_pos;
  shadows += exp(-abs(pd.x) * 8.0) * exp(-max(pd.y, 0.0) * 5.0) * step(0.0, pd.y) * 0.5;

  for (int i = 0; i < 32; i++) {
    if (float(i) >= u_shadow_count) break;
    shadows += shadow_blob(spos, u_shadow_pos[i], 0.03);
  }

  vec3 impact_wave = vec3(0.0);
  if (u_impact_wave_radius >= 0.0) {
    float fr = 0.012;
    impact_wave.r = smoothstep(0.18, 0.0, abs(shock_dist * (1.0 + fr) - u_impact_wave_radius));
    impact_wave.g = smoothstep(0.18, 0.0, abs(shock_dist - u_impact_wave_radius));
    impact_wave.b = smoothstep(0.18, 0.0, abs(shock_dist * (1.0 - fr) - u_impact_wave_radius));
  }

  // ==========================================================================
  // COLOUR
  // ==========================================================================
  vec3 molten = vec3(1.00, 0.30, 0.09);
  vec3 steel_hot = vec3(0.12, 0.16, 0.20);

  vec3 col = vec3(0.0002, 0.0003, 0.0005);

  col -= vec3(0.08) * shadows;

  // PLATE FACES
  col += vec3(0.010, 0.011, 0.012) * top * (1.0 + tile_kick * 1.3);
  col -= vec3(0.055) * side * (1.0 + tile_kick * 0.5);

  float ao = pow(1.0 - cracks, 2.5);
  col -= vec3(0.40, 0.40, 0.40) * ao;

  col += vec3(0.055, 0.06, 0.065) * edge_light;
  col += rim_light * edge_light * 0.9;

  // METALLIC SPECULAR
  float specular = pow(max(top, 0.0), 12.0) * (0.35 + 0.65 * river_flow);
  col += vec3(0.08, 0.085, 0.09) * specular;

  // HEX STRUCTURE
  col += vec3(0.010, 0.012, 0.014) * line;

  // ENERGY RIVERS
  col += vec3(0.05, 0.06, 0.075) * river_flow * cracks * (1.0 + u_charge * 1.2);
  col += vec3(0.025, 0.03, 0.035) * power_flow * cracks;

  float river_glow = smoothstep(0.65, 1.0, river_flow) * cracks;
  col += steel_hot * river_glow * (1.0 + u_bass * 8.0 + u_charge * 6.0);

  col += vec3(0.16, 0.26, 0.40) * chase_lit * (0.18 + u_charge * 0.7);

  // BASS SHOCKWAVES
  col += vec3(0.16, 0.18, 0.2) * shockwave * cracks;
  col += vec3(0.04, 0.045, 0.05) * shockwave * top;

  col += vec3(0.42, 0.62, 0.95) * beat_plate * (edge_light * 0.30 + cracks * 0.13);
  col += molten * molten_kick * (edge_light * 0.55 + cracks * 0.22);
  col += molten * scorch * cracks * 0.30;

  col += u_impact_wave_color * impact_wave * cracks * 1.6;

  // WAVE TRAIL
  col += vec3(0.035) * wake * cracks;

  // SOFT GLOW
  col += vec3(0.02, 0.025, 0.03) * shock_glow * cracks;

  // DAMAGED PLATES
  float damaged = step(0.94, cell_rand);
  col -= damaged * 0.012;

  // DUST
  float dust = fract(sin(dot(floor(fpos * 80.0), vec2(12.3, 45.6))) * 43758.5);
  col += vec3(0.05) * dust * max(shock_glow, min(tile_kick, 1.0));

  // PLAYER PRESENCE
  float pglow = exp(-length(pd) * 9.0) * u_player_glow;
  col += vec3(0.10, 0.14, 0.20) * pglow * (0.35 + 0.65 * cracks);

  col += local_light;

  col = mix(col, vec3(0.0), clamp(crack_core * 0.85, 0.0, 1.0));
  col += crack_light;

  float fog = 1.0 - smoothstep(0.5, 2.0, length(spos));
  col *= fog;

  col *= 0.70;
  col = max(col, 0.0);

  reflection *= fog * 0.70 * (0.35 + 0.65 * (1.0 - cracks));
  col += reflection;

  col = col / (1.0 + col * 0.35);

  // GRAIN
  float noise = fract(sin(dot(fpos, vec2(12.9898, 78.233))) * 43758.5453);
  col += vec3(noise - 0.5) * 0.004;

  // INTRO DIM
  col *= 1.0 - u_intro_dim;

  gl_FragColor = vec4(col, 1.0) * v_vColour;
}
