test_time += 0.05;
ribbon_time += 0.03;

bass_strength = lerp(
    bass_strength,
    0,
    0.10
);

wall_flash = lerp(
    wall_flash,
    0,
    0.15
);


points = [];


var segments = 90;


for (var i = 0; i < segments; i++)
{
    var yy =
        (room_height / (segments - 1)) * i;

    var spectrum =
        sin(i * 0.28 + test_time * 3.0) * 18
        +
        sin(i * 0.75 - test_time * 5.0) * 10
        +
        sin(i * 1.8 + test_time * 8.0) * 5;

    var body =
        sin(test_time * 0.8 + i * 0.12) * 25
        +
        sin(test_time * 1.7 + i * 0.3) * 12;

    var bass =
        sin(i * 0.35 + test_time * 4.0)
        * bass_strength
        * 90;


    var wave =
        body
        +
        spectrum
        +
        bass;


    array_push(
        points,
        {
            px : 80 + wave,
            py : yy
        }
    );
}


points =
scr_ribbon_smooth(
    points,
    4
);

if (keyboard_check_pressed(ord("B")))
{
wall_flash = 1;
bass_strength = 1;
}