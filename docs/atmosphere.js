/* ══════════════════════════════════════════════════════════════
   ATMOSPHERE — one WebGL layer: honeycomb, dust, floor grid,
   vignette, chromatic offset. The hex distance field is ported
   from the game's own shaders/shd_hex/shd_hex.fsh (IQ hex grid).
   ══════════════════════════════════════════════════════════════ */
(function () {
  'use strict';

  const VERT = `
attribute vec2 a;
void main(){ gl_Position = vec4(a,0.0,1.0); }`;

  const FRAG = `
precision highp float;

uniform vec2  u_res;
uniform float u_time;
uniform float u_heat;      // 0..1 intensity
uniform float u_dialect;   // 0 = red only, 1 = red + cyan
uniform float u_scroll;    // page progress 0..1
uniform float u_beat;      // 0..1 one-shot pulse
uniform float u_duct;      // 0..1 honeycomb comes to the foreground
uniform float u_drain;     // 0..1 everything fades out (the cut)

#define TAU 6.283185

/* --- the game's hash, same constants as draw_menu_title_hash --- */
float hash(float n){ float s = sin(n*12.9898+78.233)*43758.5453; return fract(s); }
float hash2(vec2 p){ return fract(sin(dot(p,vec2(12.9898,78.233)))*43758.5453); }

/* --- IQ hex grid, lifted from shd_hex.fsh --- */
vec4 hexagon(vec2 p){
  vec2 q = vec2(p.x*2.0*0.5773503, p.y + p.x*0.5773503);
  vec2 pi = floor(q);
  vec2 pf = fract(q);
  float v  = mod(pi.x+pi.y, 3.0);
  float ca = step(1.0, v);
  float cb = step(2.0, v);
  vec2  ma = step(pf.xy, pf.yx);
  float e = dot(ma, 1.0-pf.yx + ca*(pf.x+pf.y-1.0) + cb*(pf.yx-2.0*pf.xy));
  p = vec2(q.x + floor(0.5+p.y/1.5), 4.0*p.y/3.0)*0.5+0.5;
  float f = length((fract(p)-0.5)*vec2(1.0,0.85));
  return vec4(pi+ca-cb*ma, e, f);
}

/* palette — the game's own values */
const vec3 C_RED    = vec3(1.000, 0.086, 0.071);
const vec3 C_DEEP   = vec3(0.337, 0.024, 0.016);
const vec3 C_CYAN   = vec3(0.282, 0.839, 1.000);
const vec3 C_EMBER  = vec3(1.000, 0.329, 0.110);
const vec3 C_ARMOR  = vec3(0.027, 0.047, 0.102);

void main(){
  vec2 uv  = gl_FragCoord.xy / u_res;
  vec2 p   = (gl_FragCoord.xy - 0.5*u_res) / u_res.y;
  float t  = u_time;

  vec3 col = vec3(0.0);

  /* ── ground: near-black. Brightness reads relative to what is
        behind it, so the backing stays dark and the chrome carries
        the colour (MAKING_IT_LOOK_GOOD §6). ── */
  vec3 ground = mix(vec3(0.0185,0.0100,0.0090), C_ARMOR*0.60, u_dialect);
  col += ground;

  /* ── perspective floor grid — a hint, not a surface ── */
  float gridAmt = (1.0 - u_dialect) * 0.5;
  if(gridAmt > 0.01){
    float below = max(0.0, -0.04 - p.y);
    float persp = 1.0 / (below*6.0 + 0.30);
    float gx = abs(fract(p.x*persp*0.75 + 0.5)-0.5);
    float gz = abs(fract(below*persp*1.30 - t*0.04 + 0.5)-0.5);
    float g  = smoothstep(0.44,0.5,1.0-gx)*0.7 + smoothstep(0.44,0.5,1.0-gz);
    /* fade out well before the bottom of the screen so it never washes */
    g *= step(0.001, below) * exp(-below*7.0) * smoothstep(0.0,0.05,below);
    col += C_RED * g * gridAmt * 0.055;
  }

  /* ── honeycomb ──────────────────────────────────────────────── */
  float scale = mix(5.2, 2.35, u_duct);
  vec2  hp    = p * scale;
  hp.y += t * mix(0.035, 0.30, u_duct) + u_scroll * 1.6;
  hp.x += sin(t*0.11)*0.05;

  vec4  h    = hexagon(hp);
  float edge = 1.0 - smoothstep(0.0, mix(0.075, 0.135, u_duct), h.z);
  float cell = hash2(h.xy);

  /* per-cell shimmer: vary from a small set rather than one flat tint */
  float pulse = 0.5 + 0.5*sin(t*1.7 + cell*TAU*3.0);
  float lit   = pulse * (0.35 + 0.65*u_heat);

  /* seams read red, junction nodes read cyan once the dialect opens */
  vec3 seam = mix(C_DEEP*1.5, C_RED, 0.35 + 0.65*u_heat);
  seam = mix(seam, C_EMBER, u_heat*0.35*step(0.62, cell));
  vec3 node = C_CYAN;

  float nodeAmt = u_dialect * smoothstep(0.55,0.95,1.0-h.w) * (0.4+0.6*pulse);

  float hexA = mix(0.022, 0.26, u_duct) + u_heat*0.055;
  col += seam * edge * hexA * (0.55 + lit*0.8);
  col += node * edge * nodeAmt * mix(0.035, 0.30, u_duct);

  /* cell interiors get a faint fill in the duct so it reads as a sleeve */
  col += mix(C_ARMOR, C_CYAN*0.35, 0.25) * (1.0-edge) * u_duct * 0.09 * (0.6+0.4*pulse);

  /* ── dust: 175 motes, like draw_menu_title_dust ── */
  for(int i=0;i<26;i++){
    float fi = float(i);
    float sx = hash(fi*3.1)      ;
    float sy = hash(fi*7.7+2.0)  ;
    vec2 dp = vec2(
      fract(sx + sin(t*0.05 + fi)*0.02) ,
      fract(sy - t*(0.004 + hash(fi)*0.010))
    );
    vec2 d = (dp - uv) * vec2(u_res.x/u_res.y, 1.0);
    float m = 1.0 - smoothstep(0.0, 0.0055, length(d));
    vec3 dc = mix(C_RED, C_CYAN, step(0.72, hash(fi*11.3)) * u_dialect);
    col += dc * m * (0.30 + 0.35*u_heat);
  }

  /* ── beat pulse: a rationed white lift, never a wash ── */
  col += vec3(1.0,0.92,0.86) * u_beat * 0.05 * (1.0 - smoothstep(0.0,0.9,length(p)));

  /* ── vignette (closes as heat rises) ── */
  float vig = 1.0 - smoothstep(0.30, 1.15 - u_heat*0.30, length(p*vec2(1.05,1.0)));
  col *= 0.16 + 0.84*vig;

  /* ── scanlines ── */
  col *= 1.0 - 0.035*step(0.5, fract(gl_FragCoord.y*0.5));

  /* ── the cut drains everything ── */
  col *= (1.0 - u_drain);

  gl_FragColor = vec4(col, 1.0);
}`;

  const cvs = document.getElementById('atmosphere');
  const reduce = matchMedia('(prefers-reduced-motion: reduce)').matches;

  let gl = null;
  try {
    gl = cvs.getContext('webgl', { alpha: false, antialias: false, depth: false, powerPreference: 'high-performance' })
      || cvs.getContext('experimental-webgl', { alpha: false });
  } catch (e) { gl = null; }

  // Public handle — app.js writes these every frame.
  const A = window.ATMO = {
    ok: !!gl,
    time: 0, heat: 0, dialect: 0, scroll: 0, beat: 0, duct: 0, drain: 0,
    quality: 1
  };

  if (!gl) {
    // CSS fallback: static ground that still respects the dialect.
    cvs.style.background =
      'radial-gradient(120% 80% at 50% 8%, #1a0b09 0%, #0A0605 62%, #050303 100%)';
    return;
  }

  function sh(type, src) {
    const s = gl.createShader(type);
    gl.shaderSource(s, src); gl.compileShader(s);
    if (!gl.getShaderParameter(s, gl.COMPILE_STATUS)) {
      console.warn('shader', gl.getShaderInfoLog(s)); return null;
    }
    return s;
  }
  const vs = sh(gl.VERTEX_SHADER, VERT), fs = sh(gl.FRAGMENT_SHADER, FRAG);
  if (!vs || !fs) { A.ok = false; return; }

  const prog = gl.createProgram();
  gl.attachShader(prog, vs); gl.attachShader(prog, fs); gl.linkProgram(prog);
  if (!gl.getProgramParameter(prog, gl.LINK_STATUS)) { A.ok = false; return; }
  gl.useProgram(prog);

  const buf = gl.createBuffer();
  gl.bindBuffer(gl.ARRAY_BUFFER, buf);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1,-1, 3,-1, -1,3]), gl.STATIC_DRAW);
  const loc = gl.getAttribLocation(prog, 'a');
  gl.enableVertexAttribArray(loc);
  gl.vertexAttribPointer(loc, 2, gl.FLOAT, false, 0, 0);

  const U = {};
  ['u_res','u_time','u_heat','u_dialect','u_scroll','u_beat','u_duct','u_drain']
    .forEach(n => U[n] = gl.getUniformLocation(prog, n));

  let W = 0, H = 0;
  function resize() {
    const dpr = Math.min(devicePixelRatio || 1, 2) * A.quality;
    // measure the element, not the window — they disagree on mobile
    const r = cvs.getBoundingClientRect();
    const w = Math.max(1, Math.round((r.width  || innerWidth)  * dpr));
    const h = Math.max(1, Math.round((r.height || innerHeight) * dpr));
    if (w === W && h === H) return;
    W = w; H = h; cvs.width = w; cvs.height = h;
    gl.viewport(0, 0, w, h);
  }
  addEventListener('resize', resize, { passive: true });
  resize();

  /* adaptive quality: if we can't hold budget, drop resolution once */
  let slow = 0, dropped = false, last = performance.now();

  function draw(now) {
    const dt = now - last; last = now;
    if (!dropped && dt > 30) { if (++slow > 45) { A.quality = 0.7; dropped = true; W = 0; resize(); } }
    else if (dt < 22) slow = Math.max(0, slow - 1);

    resize();
    gl.uniform2f(U.u_res, W, H);
    gl.uniform1f(U.u_time, A.time);
    gl.uniform1f(U.u_heat, A.heat);
    gl.uniform1f(U.u_dialect, A.dialect);
    gl.uniform1f(U.u_scroll, A.scroll);
    gl.uniform1f(U.u_beat, A.beat);
    gl.uniform1f(U.u_duct, A.duct);
    gl.uniform1f(U.u_drain, A.drain);
    gl.drawArrays(gl.TRIANGLES, 0, 3);
  }

  A.draw = draw;

  // Reduced motion: render one static frame per state change instead of animating.
  A.static = reduce;
  if (reduce) {
    A.redraw = () => { A.time = 8.0; draw(performance.now()); };
  }
})();
