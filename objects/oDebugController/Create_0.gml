debug_open = false;

debug_last_t = 0;
if (variable_global_exists("debug_resume_t"))
{
    debug_last_t = global.debug_resume_t;
}
panel_x = 30;
panel_y = 30;
panel_w = 470;
panel_h = 540;
panel_dragging = false;
panel_drag_offset_x = 0;
panel_drag_offset_y = 0;
selected_category = 0;
selected_property = 0;
scroll_offset = 0;
categories = ["ATTACKS", "LASER", "LIGHTNING", "FX", "KUNAI"];
scroll_offset_by_category = array_create(array_length(categories), 0);
properties = [];
filtered_properties = [];
fx_expanded = {};
property_dragging = false;
property_drag_index = -1;
timeline_dragging = false;
debug_t_min = 0;
debug_t_max = 6500;
last_value_click_time = -1000;
last_value_click_index = -1;

if (variable_global_exists("debug_resume_open"))
{
    debug_open = global.debug_resume_open;
}
if (variable_global_exists("debug_resume_panel_x"))
{
    panel_x = global.debug_resume_panel_x;
}
if (variable_global_exists("debug_resume_panel_y"))
{
    panel_y = global.debug_resume_panel_y;
}
if (variable_global_exists("debug_resume_category"))
{
    selected_category = global.debug_resume_category;
}
if (variable_global_exists("debug_resume_scroll_by_category"))
{
    scroll_offset_by_category = global.debug_resume_scroll_by_category;
    if (selected_category >= 0 && selected_category < array_length(scroll_offset_by_category))
    {
        scroll_offset = scroll_offset_by_category[selected_category];
    }
}
if (variable_global_exists("debug_resume_attack_scroll"))
{
    attack_scroll = global.debug_resume_attack_scroll;
}
if (variable_global_exists("debug_resume_selected_property"))
{
    selected_property = global.debug_resume_selected_property;
}
if (variable_global_exists("debug_resume_fx_expanded"))
{
    fx_expanded = global.debug_resume_fx_expanded;
}

attack_scroll = 0;
attack_markers =
[
    {name:"Intro Fade-In",        t:0,     color:c_gray,   key:"intro",
        exclude:["flash","bloom","tear","ripple","zoom","shake","tilt"]},
    {name:"Arrow Ring",           t:1,     color:c_red,    key:"arrowring"},
    {name:"Intro Shapes",         t:292,   color:c_red,    key:"introshapes"},
    {name:"Kunai Rain + Big Kunai", t:378, color:c_orange, key:"kunairain"},
    {name:"Quarter Circles",      t:682,   color:c_teal,   key:"quartercircles"},
    {name:"The Stamp",            t:995,   color:c_orange, key:"stamp"},
    {name:"Lightning Orbs",       t:1189,  color:c_yellow, key:"lightningorbs"},
    {name:"Bassline Text",        t:1283,  color:c_aqua,   key:"basslinetext", exclude:["tilt"]},
    {name:"Laser Attacks",        t:1364,  color:c_blue,   key:"laser",        exclude:["tilt"]},
    {name:"Falling Red Orbs",     t:1691,  color:c_red,    key:"fallingredorbs", exclude:["letterbox","tilt"]},
    {name:"Tree",                 t:1826,  color:c_lime,   key:"tree",         exclude:["tilt"]},
    {name:"Red Orbs + Embers",    t:2025,  color:c_red,    key:"redorbsembers", exclude:["flash","tear","tilt"]},
    {name:"Half Circle Bursts",   t:2270,  color:c_purple, key:"halfcircle",   exclude:["tilt"]},
    {name:"Eruption",             t:2326,  color:c_yellow, key:"eruption"},
    {name:"Black Holes",          t:2597,  color:c_maroon, key:"blackholes"},
    {name:"Dashing Kunai",        t:3331,  color:c_orange, key:"dashingkunai"},
    {name:"Jump Rope+Push Orbs",  t:3560,  color:c_aqua,   key:"jumprope"},
    {name:"Cube",                 t:4000,  color:c_red,    key:"cube"},
    {name:"DNA + The Lattice",    t:4990,  color:c_lime,   key:"dnagrid",      exclude:["tear","tilt"]},
    {name:"The Vault",            t:5146,  color:c_yellow, key:"vault"},
    {name:"The Duct",             t:5219,  color:c_teal,   key:"honeycomb"},
    {name:"Arrow Arc+Big Orb",    t:5960,  color:c_purple, key:"arrowarc"},
    {name:"Final Laser+Falling",  t:6628,  color:c_yellow, key:"finallaser"},
    {name:"Bass+Orbit Rings",     t:7000,  color:c_white,  key:"orbitrings"},
    {name:"Final Cut",            t:7291,  color:c_white,  key:"finalcut"}
];

debug_register_lasers();
debug_register_fx();
debug_register_kunai();
debug_refresh_category();