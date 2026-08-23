
visible = true;
x = GAME_WIDTH / 2
y = GAME_HEIGHT / 2
depth = -100000

time = 0
offset = 0
reveal_length = 30
prompt_delay = 18
overlay_seed = irandom(1000000)

scan_rows = []
for (var i = 0; i < 9; i++) {
	array_push(scan_rows, {
		y : random_range(0.10, 0.90),
		w : random_range(72, 240),
		speed : random_range(8, 26),
		alpha : random_range(0.08, 0.22)
	})
}

rupture_ticks = []
for (var i = 0; i < 18; i++) {
	array_push(rupture_ticks, {
		u : random_range(-0.78, 0.78),
		len : random_range(18, 92),
		side : choose(-1, 1),
		heat : random_range(0.35, 1),
		delay : irandom_range(0, 26)
	})
}
