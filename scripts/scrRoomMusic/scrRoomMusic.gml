function bgm_get_room_music(r) {
	switch (r) {
		case rTest:
		case rTest2:
			return musEngine
			break
		case rAvoidance:
			return -2
			break
		default:	
			return -1
			break
	}
}

function bgm_get_room_music_pitch(r) {
	switch (r) {
		case rTest2:
			return 0.8
			break
		default:
			return 1.0
			break
	}
}

function bgm_get_room_music_gain(r) {
	switch (r) {
		case rTest2:
			return 0.8
			break
		default:
			return 1.0
			break
	}
}