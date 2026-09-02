/* The run, as authored. `t` values are the game's own debug markers
   (objects/oDebugController/Create_0.gml). end = next marker's t.
   act:  1 establishing | 2 escalation | 3 transformation | 4 finale
   w:    weight class — "major" gets a red bracket + full media, "minor" gets cyan + a beat
   Frame timings verified against a live capture of the shipped release
   (t = 0 at 24.75s into the take; Final Cut lands at 146.3s). */
window.SECTIONS = [
  { t:0,    name:"Intro Fade-In",        act:1, w:"minor", img:"01_intro",
    copy:"The arena resolves out of black. Sixty frames of nothing, which is itself the warning." },
  { t:1,    name:"Arrow Ring",           act:1, w:"major", img:"02_arrow_ring",
    copy:"A ring of red arrows turns around the room and fires on the heavy bass hits." },
  { t:292,  name:"Intro Shapes",         act:1, w:"minor", img:"03_intro_shapes",
    copy:"Circle, square, X. The geometry assembles, orbits, then throws itself outward." },
  { t:378,  name:"Kunai Rain",           act:1, w:"major", img:"04_kunai_rain",
    copy:"Blades fall in sheets, then in fans of four on the heavy beats." },
  { t:682,  name:"Quarter Circles",      act:1, w:"hero",  loop:"quarter_circles",
    copy:"Two counter-rotating wheels — red against cyan — on a honeycomb that answers the bass." },
  { t:995,  name:"The Stamp",            act:1, w:"major", img:"06_the_stamp",
    copy:"Two walls close on the middle and you have to get there." },
  { t:1189, name:"Lightning Orbs",       act:1, w:"minor", img:"07_lightning_orbs",
    copy:"Not a moving light — a chain of strikes that hands off along the wall." },
  { t:1283, name:"Bassline Text",        act:1, w:"major", img:"08_bassline_text", mark:"name",
    copy:"The game says its own name, and the lattice underneath it goes molten." },

  { t:1364, name:"Laser Attacks",        act:2, w:"major", img:"09_laser_attacks", mark:"drop",
    copy:"The drop. Every muzzle brackets its corridor a full beat before it fires." },
  { t:1691, name:"Falling Red Orbs",     act:2, w:"minor", img:"10_falling_red_orbs",
    copy:"Gravity turns over. What was above you is now on its way down." },
  { t:1826, name:"Tree",                 act:2, w:"major", img:"11_tree",
    copy:"Something grows, ripens, cracks along three pulses, and is set on fire." },
  { t:2025, name:"Red Orbs + Embers",    act:2, w:"minor", img:"12_red_orbs_embers",
    copy:"Three implosions, each pulling the embers tighter than the last." },
  { t:2270, name:"Half Circle Bursts",   act:2, w:"minor", img:"13_half_circle",
    copy:"Four arcs on four beats. The shortest thing in the run." },
  { t:2326, name:"Eruption",             act:2, w:"hero",  loop:"eruption",
    copy:"The floor claims its full lethal width on the first frame of warning, holds, then goes incandescent. Red bracket for a heavy beat, cyan for a fast one — the colour is the weight class." },
  { t:2597, name:"Black Holes",          act:2, w:"hero",  loop:"blackholes", mark:"rest",
    copy:"Eighty-four frames of musical silence, and then two singularities that bend everything on screen." },
  { t:3331, name:"Dashing Kunai",        act:2, w:"minor", img:"16_dashing_kunai",
    copy:"Blades that stop, aim, and cross the whole room inside a single frame." },
  { t:3560, name:"Jump Rope + Push Orbs",act:2, w:"minor", img:"17_jump_rope",
    copy:"A rope of light sweeps the floor while the field leans you off your line." },

  { t:4000, name:"Cube",                 act:3, w:"hero",  loop:"cube", mark:"break",
    copy:"The floor and the walls are deleted. From here to the end you never land — and the jumps stop being rationed." },
  { t:4990, name:"DNA + The Lattice",    act:3, w:"minor", img:"19_dna_lattice",
    copy:"Two helices and a grid that answers in lightning." },
  { t:5146, name:"The Vault",            act:3, w:"major", img:"20_the_vault", mark:"seal",
    copy:"The centre becomes a hexagon and the rest of the world becomes the machine that built it. Stay inside. The wall is shown winning." },
  { t:5219, name:"The Duct",             act:3, w:"hero",  loop:"duct",
    copy:"A chase down a service shaft of that same machine — the cell unfolded into a cylinder, every seam hot, every junction lit." },

  { t:5960, name:"Arrow Arc + Big Orb",  act:4, w:"major", img:"22_arrow_arc",
    copy:"A containment cell that keeps rupturing, then builds itself a rig out of what's left." },
  { t:6628, name:"Final Laser + Falling",act:4, w:"minor", img:"23_final_laser",
    copy:"Red machine, cyan cutting edge. The mill comes down." },
  { t:7000, name:"Bass + Orbit Rings",   act:4, w:"major", img:"24_bass_orbit_rings",
    copy:"Everything still standing arrives at once, on the beat." },
  { t:7291, name:"Final Cut",            act:4, w:"hero",  loop:"finalcut", mark:"cut",
    copy:"The frame is severed, not detonated." }
];
window.RUN_END = 7470;
