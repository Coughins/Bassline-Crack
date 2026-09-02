/* ══════════════════════════════════════════════════════════════
   BASSLINE CRACK — page controller.
   One clock (T), two instruments (HEAT, DIALECT). Everything on
   the page is a function of those three. Nothing animates that
   isn't driven by one of them.
   ══════════════════════════════════════════════════════════════ */
(function () {
  'use strict';

  const $  = (s, r) => (r || document).querySelector(s);
  const $$ = (s, r) => Array.from((r || document).querySelectorAll(s));
  const clamp = (v, a, b) => v < a ? a : v > b ? b : v;
  const lerp  = (a, b, k) => a + (b - a) * k;
  const REDUCE = matchMedia('(prefers-reduced-motion: reduce)').matches;

  const SECTIONS = window.SECTIONS, RUN_END = window.RUN_END;
  const FPS = 60;
  // run-length budget: ~2px of scroll per frame of song
  const PX_PER_FRAME = 2.0, MIN_SEC_PX = 420, MAX_SEC_PX = 1750;

  /* ═══════════ 1. authored curves ═══════════
     Hand-keyed at the act boundaries so the drop and the cut land
     exactly, rather than falling out of a formula. */
  const KEYS = [
    //  t      heat  dialect  duct
    [    0,    0.04, 0.04,  0 ],
    [  682,    0.16, 0.18,  0 ],
    [ 1283,    0.24, 0.22,  0 ],
    [ 1363,    0.26, 0.24,  0 ],
    [ 1364,    0.46, 0.76,  0 ],   // THE DROP — hard step, cyan arrives
    [ 2326,    0.58, 0.78,  0 ],
    [ 2597,    0.60, 0.80,  0 ],
    [ 2620,    0.16, 0.74,  0 ],   // the breakdown: 84 frames of silence
    [ 2657,    0.72, 0.86,  0 ],
    [ 3331,    0.64, 0.86,  0 ],
    [ 4000,    0.58, 0.95,  0 ],   // arena deleted
    [ 5146,    0.70, 0.92,  0.2 ],
    [ 5219,    0.74, 0.90,  1.0 ], // the duct — honeycomb to foreground
    [ 5959,    0.80, 0.90,  1.0 ],
    [ 5960,    0.84, 0.88,  0.1 ],
    [ 7000,    0.95, 0.86,  0 ],
    [ 7291,    1.00, 0.84,  0 ],
    [ RUN_END, 1.00, 0.84,  0 ]
  ];

  function curve(t) {
    if (t <= KEYS[0][0]) return { heat: KEYS[0][1], dialect: KEYS[0][2], duct: KEYS[0][3] };
    for (let i = 1; i < KEYS.length; i++) {
      if (t <= KEYS[i][0]) {
        const a = KEYS[i - 1], b = KEYS[i];
        const span = b[0] - a[0];
        const k = span <= 1 ? 1 : (t - a[0]) / span;
        return { heat: lerp(a[1], b[1], k), dialect: lerp(a[2], b[2], k), duct: lerp(a[3], b[3], k) };
      }
    }
    const L = KEYS[KEYS.length - 1];
    return { heat: L[1], dialect: L[2], duct: L[3] };
  }

  /* ═══════════ 2. logo: tear bands + crack ═══════════ */
  function buildLogo() {
    // 34 horizontal slices cut through the letterforms —
    // mirrors draw_menu_title_crisp_logo's black tear rectangles.
    const g = $('#tear-bands');
    let d = '';
    for (let i = 0; i < 34; i++) {
      const s = i * 23;
      const onCrack = (i % 2) === 0;
      const y  = onCrack ? 118 + hash(s + 1) * 96 : 14 + hash(s + 2) * 92;
      const w  = 40 + hash(s + 3) * 210;
      const x  = -20 + hash(s + 4) * 600;
      const h  = 1.2 + hash(s + 6) * 3.0;
      // partial cuts, not solid bars — the game's slices sit at alpha .12-.37,
      // which is what makes it read as a glitch instead of black tape.
      const v = Math.round((0.14 + hash(s + 5) * 0.30) * 255);
      const grey = `rgb(${255 - v},${255 - v},${255 - v})`;
      d += `<rect x="${x.toFixed(1)}" y="${y.toFixed(1)}" width="${w.toFixed(1)}" height="${h.toFixed(1)}" fill="${grey}"/>`;
    }
    g.innerHTML = d;

    buildCrack();
  }

  /* The crack: the page is torn open, so the fractures need mass, not
     strokes. Each one is a tapered polygon that is wide at the impact and
     comes to a hairline, filled near-black so it reads as a hole, with a
     hot rim and bloom around it. Same idea as the game icon: dark plate,
     split, glowing from inside. */
  function buildCrack() {
    const CX = 160, CY = 160;

    // Jagged arm out from the epicentre. The heading is a sharp kink around
    // the base angle plus a slow lean, rather than an accumulating random
    // walk — a walk curls the fracture into an organic hook, and a crack
    // travels roughly straight while stepping hard side to side.
    function arm(ang, len, segs, jag, seed) {
      const pts = [{ x: CX, y: CY }];
      let lean = 0;
      for (let i = 1; i <= segs; i++) {
        lean += (hash(seed + i * 5.3) - 0.5) * jag * 0.30;
        const kink = (hash(seed + i * 3.1) - 0.5) * jag * 1.7;
        const a = ang + lean + kink;
        const step = (len / segs) * (0.55 + hash(seed + i * 7.7) * 0.9);
        const p = pts[i - 1];
        pts.push({ x: p.x + Math.cos(a) * step, y: p.y + Math.sin(a) * step });
      }
      return pts;
    }

    // give a polyline a body: wide at the head, tapering to a point
    function taper(pts, w0, w1) {
      const L = [], R = [], n = pts.length - 1;
      for (let i = 0; i <= n; i++) {
        const p = pts[i];
        const a = pts[Math.max(0, i - 1)], b = pts[Math.min(n, i + 1)];
        let dx = b.x - a.x, dy = b.y - a.y;
        const d = Math.hypot(dx, dy) || 1; dx /= d; dy /= d;
        const w = (w0 + (w1 - w0) * Math.pow(i / n, 0.55)) * 0.5;
        L.push([p.x - dy * w, p.y + dx * w]);
        R.push([p.x + dy * w, p.y - dx * w]);
      }
      const all = L.concat(R.reverse());
      return 'M' + all.map(p => p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join('L') + 'Z';
    }

    const line = pts => 'M' + pts.map(p => p.x.toFixed(1) + ' ' + p.y.toFixed(1)).join('L');

    const bodies = [];   // filled fracture polygons
    const hairs  = [];   // hairline continuations and fine splits
    const shards = [];   // chips knocked loose around the impact

    // Seven fractures, but two of them carry most of the damage. Even
    // weighting reads as a spider web; one dominant split reads as a hit.
    const N = 7;
    const DOMINANT = [1, 4];
    for (let i = 0; i < N; i++) {
      const seed = i * 37 + 5;
      const big  = DOMINANT.indexOf(i) >= 0;
      const ang  = (i / N) * Math.PI * 2 + (hash(seed) - 0.5) * 0.95;
      const len  = big ? 150 + hash(seed + 2) * 60 : 74 + hash(seed + 2) * 64;
      const pts  = arm(ang, len, big ? 9 : 5, big ? 0.5 : 0.72, seed);
      const w0   = big ? 34 + hash(seed + 4) * 16 : 11 + hash(seed + 4) * 9;
      bodies.push({ d: taper(pts, w0, big ? 1.4 : 0.8), w: w0 });

      // the fracture keeps going as a hairline past where it has width
      const tip  = pts[pts.length - 1];
      const tail = arm(ang + (hash(seed + 9) - 0.5) * 0.7, 34 + hash(seed + 6) * 46, 3, 0.85, seed + 21);
      hairs.push(line(tail.map(p => ({ x: p.x - CX + tip.x, y: p.y - CY + tip.y }))));

      // one or two branches, thinner, splitting off mid-arm
      const nb = 1 + (hash(seed + 11) > 0.55 ? 1 : 0);
      for (let b = 0; b < nb; b++) {
        const at = pts[2 + b];
        const ba = ang + (hash(seed + b * 13 + 3) - 0.5) * 1.9;
        const bp = arm(ba, 30 + hash(seed + b * 5) * 46, 4, 0.7, seed + b * 17 + 31)
                     .map(p => ({ x: p.x - CX + at.x, y: p.y - CY + at.y }));
        bodies.push({ d: taper(bp, (big ? 11 : 4.5) + hash(seed + b) * 5, 0.6), w: 3 });
      }
    }

    // fine radial splits, no body
    for (let i = 0; i < 11; i++) {
      const s = i * 11 + 101;
      hairs.push(line(arm((i / 11) * Math.PI * 2 + hash(s) * 0.9,
                          20 + hash(s + 3) * 40, 3, 1.0, s)));
    }

    // displaced chips near the impact
    for (let i = 0; i < 9; i++) {
      const s = i * 19 + 7;
      const a = hash(s) * Math.PI * 2;
      const r = 16 + hash(s + 1) * 46;
      const px = CX + Math.cos(a) * r, py = CY + Math.sin(a) * r;
      const sz = 2.6 + hash(s + 2) * 6.5;
      const p = [];
      const k = 3 + Math.floor(hash(s + 5) * 2);
      for (let v = 0; v < k; v++) {
        const va = (v / k) * Math.PI * 2 + hash(s + v) * 1.5;
        const vr = sz * (0.45 + hash(s + v * 3) * 0.85);
        p.push((px + Math.cos(va) * vr).toFixed(1) + ' ' + (py + Math.sin(va) * vr).toFixed(1));
      }
      shards.push('M' + p.join('L') + 'Z');
    }

    const bodyD = bodies.map(b => b.d).join(' ');
    const hairD = hairs.join(' ');

    // bloom under everything, then the hole, then the hot rim
    $('#ck-bloom').innerHTML =
      `<path d="${bodyD}" fill="#FF2A26" opacity=".26" filter="url(#ckWide)"/>` +
      `<circle cx="${CX}" cy="${CY}" r="24" fill="#FF541C" opacity=".34" filter="url(#ckWide)"/>`;
    $('#ck-glow').innerHTML =
      `<path d="${bodyD}" fill="#FF2A26" opacity=".42" filter="url(#ckSoft)"/>`;
    // the hole itself: darker than the page, so it reads as missing material
    $('#ck-void').innerHTML =
      `<path d="${bodyD}" fill="#000"/>`;
    // rim carries the heat. Thick red edge, thin hot inner line.
    $('#ck-rim').innerHTML =
      `<path d="${bodyD}" fill="none" stroke="#FF2E48" stroke-width="1.5" opacity=".98"/>` +
      `<path d="${bodyD}" fill="none" stroke="#FFD8B8" stroke-width=".55" opacity=".55"/>`;
    $('#ck-shards').innerHTML =
      shards.map((d, i) => `<path d="${d}" fill="#0A0605" stroke="#FF2A26" stroke-width=".7" opacity="${(0.5 + hash(i * 3) * 0.5).toFixed(2)}"/>`).join('');
    $('#ck-hair').innerHTML =
      `<path d="${hairD}" fill="none" stroke="#FF2A26" stroke-width=".85" opacity=".62"/>`;

    // white-hot core, with the four-point flare the game uses on impacts
    $('#ck-core').innerHTML =
      `<circle cx="${CX}" cy="${CY}" r="17" fill="#FF541C" opacity=".55" filter="url(#ckSoft)"/>` +
      `<path d="M${CX - 58} ${CY}L${CX} ${CY - 5}L${CX + 58} ${CY}L${CX} ${CY + 5}Z" fill="#FFD8B8" opacity=".55" filter="url(#ckSoft)"/>` +
      `<path d="M${CX} ${CY - 46}L${CX + 4} ${CY}L${CX} ${CY + 46}L${CX - 4} ${CY}Z" fill="#FFD8B8" opacity=".45" filter="url(#ckSoft)"/>` +
      `<circle cx="${CX}" cy="${CY}" r="5.5" fill="#fff"/>` +
      `<circle cx="${CX}" cy="${CY}" r="11" fill="#fff" opacity=".3" filter="url(#ckSoft)"/>`;
  }
  // the game's own hash, same constants (draw_menu_title_hash)
  function hash(v) { const n = Math.sin(v * 12.9898 + 78.233) * 43758.5453; return n - Math.floor(n); }

  /* ═══════════ 3. the chamfered frame ═══════════ */
  const frame = $('#frame');
  function buildFrame() {
    const fr = frame.getBoundingClientRect();
    const w = Math.round(fr.width || innerWidth), h = Math.round(fr.height || innerHeight);
    frame.setAttribute('viewBox', `0 0 ${w} ${h}`);
    const m = w < 720 ? 9 : 14, cut = w < 720 ? 12 : 19;
    const x1 = m, y1 = m, x2 = w - m, y2 = h - m;

    // segmented edges — pieces drop out, like draw_menu_title_segmented_line
    const seg = (ax, ay, bx, by, n, seed) => {
      let out = '';
      for (let i = 0; i < n; i++) {
        if ((i + seed) % 7 === 0 || (i + seed * 2) % 11 === 0) continue;
        const a = i / n, b = Math.min(1, (i + 0.72) / n);
        out += `<line x1="${(ax + (bx - ax) * a).toFixed(1)}" y1="${(ay + (by - ay) * a).toFixed(1)}"
                      x2="${(ax + (bx - ax) * b).toFixed(1)}" y2="${(ay + (by - ay) * b).toFixed(1)}"
                      stroke-width="1" opacity="${(0.55 + 0.45 * hash(i + seed)).toFixed(2)}"/>`;
      }
      return out;
    };
    $('#frame-edges').innerHTML =
      seg(x1 + cut, y1, x2 - cut, y1, 38, 0) +
      seg(x2, y1 + cut, x2, y2 - cut, 24, 4) +
      seg(x2 - cut, y2, x1 + cut, y2, 38, 9) +
      seg(x1, y2 - cut, x1, y1 + cut, 24, 13);

    // four 45° chamfers — the corners are cut, never square
    $('#frame-corners').innerHTML =
      `<line x1="${x1}" y1="${y1 + cut}" x2="${x1 + cut}" y2="${y1}" stroke-width="1.4"/>` +
      `<line x1="${x2 - cut}" y1="${y1}" x2="${x2}" y2="${y1 + cut}" stroke-width="1.4"/>` +
      `<line x1="${x2}" y1="${y2 - cut}" x2="${x2 - cut}" y2="${y2}" stroke-width="1.4"/>` +
      `<line x1="${x1 + cut}" y1="${y2}" x2="${x1}" y2="${y2 - cut}" stroke-width="1.4"/>`;

    // inset tick marks
    $('#frame-ticks').innerHTML =
      `<line x1="${x1 + 8}" y1="${y1 + cut + 42}" x2="${x1 + 8}" y2="${y1 + cut + 72}" opacity=".45"/>` +
      `<line x1="${x2 - 8}" y1="${y1 + cut + 42}" x2="${x2 - 8}" y2="${y1 + cut + 72}" opacity=".45"/>` +
      `<line x1="${x1 + 8}" y1="${y2 - cut - 72}" x2="${x1 + 8}" y2="${y2 - cut - 42}" opacity=".45"/>` +
      `<line x1="${x2 - 8}" y1="${y2 - cut - 72}" x2="${x2 - 8}" y2="${y2 - cut - 42}" opacity=".45"/>`;
  }

  /* ═══════════ 4. build the run ═══════════ */
  const host = $('#sections');
  function buildSections() {
    const frag = document.createDocumentFragment();

    SECTIONS.forEach((s, i) => {
      const end = (i + 1 < SECTIONS.length) ? SECTIONS[i + 1].t : RUN_END;

      const el = document.createElement('article');
      el.className = 'sec';
      el.id = 'sec-' + s.t;
      el.dataset.w = s.w;
      el.dataset.t = s.t;
      el.dataset.end = end;
      el.dataset.act = s.act;
      if (s.mark) el.dataset.mark = s.mark;

      // Height tracks how long the section actually lasts, so scrolling
      // advances `t` at a near-constant rate. Sizing cards by weight class
      // alone made the clock lurch wherever a long section had a short card
      // (worst case: leaving the 741-frame Duct into the next marker).
      el.style.minHeight = clamp(Math.round((end - s.t) * PX_PER_FRAME),
                                 MIN_SEC_PX, MAX_SEC_PX) + 'px';

      const media = s.loop
        ? `<video class="lp" playsinline muted loop preload="none"
                  poster="assets/loops/${s.loop}.webp" width="800" height="608"
                  aria-label="${s.name} in motion">
             <source data-src="assets/loops/${s.loop}.mp4" type="video/mp4">
           </video>`
        : `<img src="assets/sections/${s.img}.webp" alt="${s.name}" loading="lazy" width="800" height="608">`;

      const mm = String(Math.floor(s.t / FPS / 60));
      const ss = String(Math.floor((s.t / FPS) % 60)).padStart(2, '0');

      el.innerHTML = `
        <div class="sec-inner">
          <div class="sec-media">
            <div class="shot">${media}<span class="cn"></span></div>
          </div>
          <div class="sec-body">
            <div class="sec-t">
              <span class="idx">${String(i + 1).padStart(2, '0')}</span>
              <span>t${String(s.t).padStart(4, '0')} &rarr; t${String(end).padStart(4, '0')}</span>
              <span class="idx">${mm}:${ss}</span>
            </div>
            <h3 class="sec-name">${s.name}</h3>
            <p class="sec-copy">${s.copy}</p>
          </div>
        </div>`;
      frag.appendChild(el);
    });

    // after the cut: the page is severed and drains. Nothing here on
    // purpose — the silence is what makes the reboot below register.
    const drain = document.createElement('div');
    drain.className = 'drain-beat';
    drain.innerHTML = '<span aria-hidden="true"></span>';
    frag.appendChild(drain);

    host.appendChild(frag);
  }

  /* ═══════════ 5. the rail ═══════════ */
  function buildRail() {
    const ticks = $('#rail-ticks');
    let h = '';
    SECTIONS.forEach(s => {
      const pct = (s.t / RUN_END) * 100;
      const major = s.w !== 'minor';
      h += `<button class="rail-tick${major ? ' major' : ''}" data-t="${s.t}"
              style="top:${pct.toFixed(2)}%" aria-label="Jump to ${s.name}">
              <span class="lbl">${s.name}</span></button>`;
    });
    ticks.innerHTML = h;
    ticks.addEventListener('click', e => {
      const b = e.target.closest('.rail-tick'); if (!b) return;
      const el = document.getElementById('sec-' + b.dataset.t);
      if (el) el.scrollIntoView({ behavior: REDUCE ? 'auto' : 'smooth', block: 'center' });
    });
  }

  /* ═══════════ 6. FX pass (second canvas — hits, tear, the cut) ═══════════ */
  const fx = $('#fx'), fxc = fx.getContext('2d');
  let fxW = 0, fxH = 0;
  let fxCssW = 0;
  function fxResize() {
    const d = Math.min(devicePixelRatio || 1, 2);
    const r = fx.getBoundingClientRect();
    fxCssW = r.width || innerWidth;
    fxW = fx.width  = Math.round(fxCssW * d);
    fxH = fx.height = Math.round((r.height || innerHeight) * d);
  }
  const shots = [];           // {kind, born, life}
  function fire(kind, life) {
    if (REDUCE) return;
    // one of each kind at a time — stacking pulses would pin the effect at
    // its ceiling and smear the moment it exists to punctuate
    // (the scr_impact_pulse trap, applied here).
    if (shots.some(s => s.kind === kind)) return;
    shots.push({ kind, born: performance.now(), life });
  }
  function drawFX(now) {
    fxc.clearRect(0, 0, fxW, fxH);
    if (!shots.length) return;
    for (let i = shots.length - 1; i >= 0; i--) {
      const s = shots[i];
      const k = (now - s.born) / s.life;
      if (k >= 1) { shots.splice(i, 1); continue; }
      const fade = 1 - k;

      if (s.kind === 'flash') {
        fxc.fillStyle = `rgba(255,246,240,${(fade * fade * 0.62).toFixed(3)})`;
        fxc.fillRect(0, 0, fxW, fxH);
      }
      else if (s.kind === 'tear') {
        // red one way, cyan the other — the game's chromatic split
        const off = fade * fxW * 0.012;
        fxc.globalCompositeOperation = 'screen';
        for (let b = 0; b < 16; b++) {
          const y = (hash(b * 3.3 + Math.floor(s.born)) * fxH) | 0;
          const h = 4 + hash(b * 7.1) * 46;
          fxc.fillStyle = `rgba(255,42,38,${(fade * 0.30).toFixed(3)})`;
          fxc.fillRect(-off, y, fxW, h);
          fxc.fillStyle = `rgba(72,214,255,${(fade * 0.30).toFixed(3)})`;
          fxc.fillRect(off, y + 2, fxW, h);
        }
        fxc.globalCompositeOperation = 'source-over';
      }
      else if (s.kind === 'cut') {
        // "the frame is severed, not detonated" — one stroke that crosses
        // fast, then a thin scar that cools. Escalate intensity, not area.
        const dpr = fxW / Math.max(1, fxCssW);
        const ang = -0.62, cx = fxW * 0.5, cy = fxH * 0.5;
        const ext = Math.max(fxW, fxH) * 1.4;
        const grow = Math.min(1, k / 0.14);          // crosses in the first 14%
        const cool = clamp((k - 0.14) / 0.86, 0, 1);
        fxc.save();
        fxc.translate(cx, cy); fxc.rotate(ang);
        fxc.globalCompositeOperation = 'screen';

        const core = (3.2 - cool * 2.4) * dpr;       // 3.2px -> 0.8px
        const g = fxc.createLinearGradient(-ext, 0, ext, 0);
        g.addColorStop(0,   'rgba(255,255,255,0)');
        g.addColorStop(0.5, `rgba(255,255,255,${(1 - cool * 0.75).toFixed(3)})`);
        g.addColorStop(1,   'rgba(255,255,255,0)');
        fxc.fillStyle = g;
        fxc.fillRect(-ext * grow, -core / 2, ext * 2 * grow, core);

        // a narrow hot bloom that fades fast — rationed, not a wash
        const bl = core * 3.4;
        const gb = fxc.createLinearGradient(0, -bl, 0, bl);
        gb.addColorStop(0,   'rgba(255,60,40,0)');
        gb.addColorStop(0.5, `rgba(255,74,48,${(0.34 * (1 - cool)).toFixed(3)})`);
        gb.addColorStop(1,   'rgba(255,60,40,0)');
        fxc.fillStyle = gb;
        fxc.fillRect(-ext * grow, -bl, ext * 2 * grow, bl * 2);

        fxc.restore();
        fxc.globalCompositeOperation = 'source-over';
      }
    }
  }

  /* ═══════════ 7. video: one at a time, in view only ═══════════ */
  const vids = () => $$('video.lp');
  let playing = null;
  const near = new Set();   // videos currently anywhere near the viewport

  // Intersection only decides *candidacy* and triggers lazy load. Which one
  // actually plays is decided per-frame by whichever is closest to the
  // viewport centre — a ratio threshold can never be met by media taller
  // than the viewport.
  const vio = new IntersectionObserver(entries => {
    entries.forEach(en => {
      const v = en.target;
      if (en.isIntersecting) {
        near.add(v);
        const src = v.querySelector('source[data-src]');
        if (src && !src.src) { src.src = src.dataset.src; v.load(); }
      } else {
        near.delete(v);
        try { v.pause(); } catch (e) {}
        if (playing === v) playing = null;
      }
    });
  }, { rootMargin: '10% 0px 10% 0px', threshold: 0 });

  function pumpVideo() {
    if (REDUCE) return;
    let best = null, bestD = Infinity;
    const mid = innerHeight / 2;
    near.forEach(v => {
      const r = v.getBoundingClientRect();
      const d = Math.abs((r.top + r.bottom) / 2 - mid);
      if (d < bestD) { bestD = d; best = v; }
    });
    if (best !== playing) {
      if (playing) { try { playing.pause(); } catch (e) {} }
      playing = best;
      if (best) { const p = best.play(); if (p && p.catch) p.catch(() => {}); }
    } else if (best && best.paused) {
      const p = best.play(); if (p && p.catch) p.catch(() => {});
    }
  }

  /* ═══════════ 8. section entrance ═══════════ */
  const sio = new IntersectionObserver(entries => {
    entries.forEach(en => { if (en.isIntersecting) en.target.classList.add('in'); });
  }, { rootMargin: '-8% 0px -12% 0px' });

  /* ═══════════ 9. the clock ═══════════ */
  const runEl  = $('#run');
  const railEl = $('#rail');
  const railFill = $('#rail-fill'), railHead = $('#rail-head');
  const railT = $('#rail-t'), railTime = $('#rail-time');
  const railMini = $('#rail-mini'), rmFill = $('#rm-fill'),
        rmName = $('#rm-name'), rmT = $('#rm-t');
  const roFrame = $('#ro-frame'), roClock = $('#ro-clock'), roState = $('#ro-state');
  const root = document.documentElement;

  let T = 0, Tsmooth = 0, HEAT = 0, DIALECT = 0, DUCT = 0, DRAIN = 0, BEAT = 0;
  const fired = {};

  /* T is derived from the sections' real geometry, not from a linear
     fraction of the run's height — the cards are deliberately different
     heights, so a linear map would put the readout on the wrong attack.
     The number has to be true: the whole premise is that scroll is the clock. */
  let layout = [];
  function measure() {
    const top = scrollY;
    layout = $$('.sec').map(el => {
      const r = el.getBoundingClientRect();
      return { t: +el.dataset.t, end: +el.dataset.end, y0: r.top + top, y1: r.bottom + top };
    }).sort((a, b) => a.y0 - b.y0);
  }

  function scrollT() {
    if (!layout.length) return 0;
    const probe = scrollY + innerHeight * 0.5;   // viewport centre
    const first = layout[0], last = layout[layout.length - 1];

    if (probe <= first.y0) {
      // approaching the run: ease 0 -> first section's t over one viewport
      const k = clamp(1 - (first.y0 - probe) / innerHeight, 0, 1);
      return first.t * k;
    }
    if (probe >= last.y1) {
      const over = clamp((probe - last.y1) / (innerHeight * 0.8), 0, 1);
      return lerp(last.end, RUN_END, over);
    }
    for (let i = 0; i < layout.length; i++) {
      const s = layout[i];
      if (probe <= s.y1) {
        if (probe >= s.y0) {
          const k = (probe - s.y0) / Math.max(1, s.y1 - s.y0);
          return lerp(s.t, s.end, k);
        }
        // in the gap before this card (e.g. the breakdown beat)
        const prev = layout[i - 1];
        const k = (probe - prev.y1) / Math.max(1, s.y0 - prev.y1);
        return lerp(prev.end, s.t, clamp(k, 0, 1));
      }
    }
    return RUN_END;
  }

  function marks(t) {
    SECTIONS.forEach(s => {
      if (!s.mark) return;
      const key = s.mark + s.t;
      if (t >= s.t && !fired[key]) {
        fired[key] = 1;
        if (s.mark === 'drop')  { fire('flash', 170); fire('tear', 420); }
        if (s.mark === 'break') { fire('tear', 340); }
        if (s.mark === 'seal')  { fire('flash', 120); }
        if (s.mark === 'name')  { fire('flash', 110); }
        if (s.mark === 'cut')   { fire('cut', 950); fire('flash', 260); }
        BEAT = 1;
      }
      // allow a re-fire only after scrolling well back past it
      if (t < s.t - 260 && fired[key]) fired[key] = 0;
    });
  }

  let lastNow = performance.now(), vidPump = 0;
  function tick(now) {
    const dt = Math.min(0.05, (now - lastNow) / 1000); lastNow = now;

    const inRun = runEl.getBoundingClientRect().top < innerHeight * 0.6
               && runEl.getBoundingClientRect().bottom > innerHeight * 0.4;

    T = scrollT();
    Tsmooth = lerp(Tsmooth, T, REDUCE ? 1 : clamp(dt * 9, 0, 1));

    const c = curve(Tsmooth);

    // after the cut, the page drains and then reboots into the download stage
    const dlTop = $('#dl').getBoundingClientRect().top;
    // the cut drains the page, then the download stage reboots it clean
    const resolving  = dlTop < innerHeight * 0.42;
    const drainTarget = resolving ? 0 : clamp((Tsmooth - 7291) / 179, 0, 1) * 0.88;

    HEAT    = lerp(HEAT,    resolving ? 0.10 : c.heat,    clamp(dt * 5, 0, 1));
    DIALECT = lerp(DIALECT, resolving ? 0.02 : c.dialect, clamp(dt * 4, 0, 1));
    DUCT    = lerp(DUCT,    resolving ? 0 : c.duct,       clamp(dt * 3, 0, 1));
    DRAIN   = lerp(DRAIN,   drainTarget,                  clamp(dt * 6, 0, 1));
    BEAT   *= Math.pow(0.0016, dt);   // hard decay with a ceiling of 1

    marks(Tsmooth);

    // publish to CSS
    root.style.setProperty('--heat', HEAT.toFixed(3));
    root.style.setProperty('--dialect', DIALECT.toFixed(3));
    root.style.setProperty('--beat', BEAT.toFixed(3));
    // the accent crossfades red -> the avoidance danger red, and the
    // page's structural colour opens toward cyan as the dialect does
    root.style.setProperty('--accent',
      DIALECT < 0.5 ? 'var(--red)' : 'var(--danger)');

    // atmosphere uniforms
    const A = window.ATMO;
    if (A && A.ok) {
      A.time += REDUCE ? 0 : dt;
      A.heat = HEAT; A.dialect = DIALECT; A.duct = DUCT;
      A.drain = DRAIN; A.beat = BEAT;
      A.scroll = clamp((scrollY || 0) / Math.max(1, document.body.scrollHeight - innerHeight), 0, 1);
      A.draw(now);
    }

    drawFX(now);

    // rail (full) + compact rail (narrow viewports)
    const rr = runEl.getBoundingClientRect();
    const showRail = rr.top < innerHeight * 0.35 && rr.bottom > innerHeight * 0.65;
    railEl.classList.toggle('on', showRail);
    railMini.classList.toggle('on', showRail);
    const pct = (Tsmooth / RUN_END) * 100;
    rmFill.style.width = pct.toFixed(2) + '%';
    railFill.style.height = pct.toFixed(2) + '%';
    railHead.style.top = pct.toFixed(2) + '%';
    const ti = Math.round(Tsmooth);
    railT.textContent = 't' + String(ti).padStart(4, '0');
    const secs = ti / FPS;
    railTime.textContent = Math.floor(secs / 60) + ':' + String(Math.floor(secs % 60)).padStart(2, '0');
    roFrame.textContent = 't' + String(ti).padStart(4, '0') + ' / ' + RUN_END;
    roClock.textContent = 'BC--' + Math.floor(secs / 60) + ':' + String(Math.floor(secs % 60)).padStart(2, '0');
    roState.textContent = resolving ? '// SYSTEM READY'
                        : ti > 0 ? '// RUN ACTIVE' : '// SYSTEM READY';

    // act on the run wrapper drives layout drift
    let act = 1, cur = SECTIONS[0];
    for (const s of SECTIONS) if (Tsmooth >= s.t) { act = s.act; cur = s; }
    runEl.dataset.act = act;
    if (rmName.textContent !== cur.name.toUpperCase()) rmName.textContent = cur.name.toUpperCase();
    rmT.textContent = 't' + String(ti).padStart(4, '0');

    // past ticks
    $$('.rail-tick').forEach(b => b.classList.toggle('past', +b.dataset.t <= Tsmooth));

    // choose which loop plays (throttled — this reads layout)
    vidPump -= dt;
    if (vidPump <= 0) { vidPump = 0.25; pumpVideo(); }

    requestAnimationFrame(tick);
  }

  /* ═══════════ 10. audio preview ═══════════ */
  function audio() {
    const el = $('#preview');
    const btns = [$('#audio-toggle'), $('#audio-toggle-2')].filter(Boolean);
    const wave = $('#tp-wave');
    if (wave) wave.innerHTML = Array.from({ length: 34 }, () => '<i></i>').join('');
    const bars = wave ? $$('i', wave) : [];
    let raf = 0;

    function anim() {
      const t = performance.now() / 1000;
      bars.forEach((b, i) => {
        const v = Math.abs(Math.sin(i * 0.7 + t * 6)) * Math.abs(Math.sin(i * 0.2 - t * 2.2));
        b.style.height = (14 + v * 86) + '%';
        b.style.opacity = (0.35 + v * 0.6).toFixed(2);
      });
      raf = requestAnimationFrame(anim);
    }
    function set(on) {
      btns.forEach(b => b.setAttribute('aria-pressed', on ? 'true' : 'false'));
      if (on) { if (!raf && !REDUCE) anim(); }
      else { cancelAnimationFrame(raf); raf = 0; bars.forEach(b => b.style.height = '20%'); }
    }
    btns.forEach(b => b.addEventListener('click', () => {
      if (el.paused) { el.volume = 0.65; el.play().then(() => set(true)).catch(() => {}); }
      else { el.pause(); set(false); }
    }));
    el.addEventListener('pause', () => set(false));
    el.addEventListener('play',  () => set(true));
  }

  /* ═══════════ 11. boot ═══════════ */
  function boot() {
    const lines = $$('.boot-lines span');
    if (REDUCE) { document.documentElement.dataset.boot = 'done'; return; }
    if (sessionStorage.getItem('bc-booted')) {
      document.documentElement.dataset.boot = 'done'; return;
    }
    setTimeout(() => lines[0] && lines[0].classList.add('on'), 260);
    setTimeout(() => lines[1] && lines[1].classList.add('on'), 620);
    setTimeout(() => {
      document.documentElement.dataset.boot = 'done';
      try { sessionStorage.setItem('bc-booted', '1'); } catch (e) {}
    }, 1180);
    addEventListener('wheel', skip, { once: true, passive: true });
    addEventListener('touchstart', skip, { once: true, passive: true });
    function skip() { document.documentElement.dataset.boot = 'done'; }
  }

  /* ═══════════ init ═══════════ */
  buildLogo();
  buildFrame();
  buildSections();
  buildRail();
  fxResize();
  audio();
  boot();

  $$('.sec').forEach(s => sio.observe(s));
  vids().forEach(v => {
    vio.observe(v);
    // reduced motion: nothing plays on its own, so hand over the controls
    // rather than leaving a still the reader can't do anything with
    if (REDUCE) { v.controls = true; v.removeAttribute('loop'); }
  });
  measure();
  addEventListener('load', measure);
  // media finishing layout changes section heights
  $$('.sec img, .sec video').forEach(m => m.addEventListener('load', measure, { once: true }));

  let rt;
  addEventListener('resize', () => {
    clearTimeout(rt);
    rt = setTimeout(() => { buildFrame(); fxResize(); measure(); }, 140);
  }, { passive: true });

  requestAnimationFrame(tick);
})();
