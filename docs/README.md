# Bassline Crack — site

Static site for GitHub Pages. No build step.

## Publishing

Repo **Settings → Pages → Source: Deploy from a branch → `master` / `/docs`**.
It goes live at `https://coughins.github.io/Bassline-Crack/`.

## Structure

| file | what it does |
|---|---|
| `index.html` | markup |
| `styles.css` | design system; palette lifted from the game's own source |
| `sections.js` | the 25-attack timeline data (`t` values are the game's debug markers) |
| `atmosphere.js` | one WebGL layer — honeycomb / dust / grid / vignette. Hex field ported from `shaders/shd_hex` |
| `app.js` | scroll clock (`T`), authored `HEAT` / `DIALECT` curves, one-shot events, FX pass |

## Assets

- `assets/loops/` — six hero loops, captured from the shipped release at native 800x608 / 60fps
- `assets/sections/` — 25 section stills, one per debug marker
- `assets/audio/` — 15s preview of "Bassline Crack" by GETTY, used with permission
- `assets/ui/` — title screen, menu, startup notice
- `assets/icons/` — game icon

Capture timings were taken from one continuous run; `t = 0` sits at 24.75s in that
take, and the Final Cut lands at 146.3s. Do not re-derive them from the
`Final_Avoidance_ReAudit` filenames — those labels drift (the capture profiler runs
the music ahead of the step count).

## Editing the timeline

`sections.js` is the single source. `t` must stay in sync with
`objects/oDebugController/Create_0.gml`'s `attack_markers`. `w` sets the weight
class: `hero` (full bleed + video), `major` (red bracket), `minor` (cyan bracket).
