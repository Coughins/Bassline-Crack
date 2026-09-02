/* The run, as authored. `t` values are the game's own debug markers
   (objects/oDebugController/Create_0.gml). end = next marker's t.
   act:  1 establishing | 2 escalation | 3 transformation | 4 finale
   w:    weight class. "hero" gets full bleed and video, "major" a red
         bracket, "minor" a cyan one.
   Frame timings verified against a live capture of the shipped release
   (t = 0 at 24.75s into the take; Final Cut lands at 146.3s). */
window.SECTIONS = [
  { t:1,    name:"Arrow Ring",           act:1, w:"major", img:"02_arrow_ring",
    copy:"A ring of red arrows turns around the room and fires fast the whole way. On the heavy bass hits it sends missiles out instead." },
  { t:378,  name:"Kunai Rain",           act:1, w:"major", img:"04_kunai_rain",
    copy:"Blades fall in sheets, then in fans of four on the heavy beats." },
  { t:682,  name:"Quarter Circles",      act:1, w:"hero",  loop:"quarter_circles",
    copy:"Two counter-rotating wheels, red against cyan." },
  { t:995,  name:"The Stamp",            act:1, w:"major", img:"06_the_stamp",
    copy:"Two walls close on the middle. You have to reach the safe room before they meet." },
  { t:1364, name:"Laser Attacks",        act:2, w:"major", img:"09_laser_attacks", mark:"drop",
    copy:"The drop. The laser passes over the orbs and switches them on, and every orb it touches turns lethal." },
  { t:1691, name:"Falling Red Orbs",     act:2, w:"minor", img:"10_falling_red_orbs",
    copy:"Gravity turns over. The bass knocks orbs off the wall and they come down at you." },
  { t:2025, name:"Embers",               act:2, w:"minor", img:"12_red_orbs_embers",
    copy:"Three implosions, each one pulling the embers tighter than the last." },
  { t:2326, name:"Eruption",             act:2, w:"hero",  loop:"eruption",
    copy:"The floor rises. Red bracket for a heavy beat, cyan for a fast one. The colour tells you which one is coming." },
  { t:2597, name:"Black Holes",          act:2, w:"hero",  loop:"blackholes",
    copy:"Eighty-four frames of musical silence, then two singularities that bend everything on screen." },
  { t:3331, name:"Dashing Kunai",        act:2, w:"minor", img:"16_dashing_kunai",
    copy:"Kunai fill the room and travel down the whole time. On every beat a random half of them dash." },
  { t:3560, name:"Jump Rope + Push Orbs",act:2, w:"minor", img:"17_jump_rope",
    copy:"A rope of light sweeps the floor while the field leans you off your line." },

  { t:4000, name:"Cube",                 act:3, w:"hero",  loop:"cube", mark:"break",
    copy:"The floor and the walls are deleted. From here to the end you never land, and the jumps stop being rationed." },
  { t:5146, name:"The Vault",            act:3, w:"major", img:"20_the_vault", mark:"seal",
    copy:"The centre becomes a hexagon and the rest of the world becomes the machine that built it. Stay inside. The wall is shown winning." },
  { t:5219, name:"The Duct",             act:3, w:"hero",  loop:"duct",
    copy:"A chase down a service shaft of that same machine. The cell unfolded into a cylinder, every seam hot, every junction lit." },

  { t:5960, name:"Arrow Arc + Mitosis", act:4, w:"major", img:"22_arrow_arc",
    copy:"A containment cell that keeps rupturing, then builds itself a rig out of what is left." },
  { t:6628, name:"The Mill",             act:4, w:"minor", img:"23_final_laser",
    copy:"Red machine, cyan cutting edge." },
  { t:7291, name:"Final Cut",            act:4, w:"hero",  loop:"finalcut", mark:"cut",
    copy:"One stroke crosses the screen and the frame comes apart." }
];
window.RUN_END = 7470;
