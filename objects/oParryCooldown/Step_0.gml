if instance_exists(oPlayer) {
	x = oPlayer.x - 10;
	y = oPlayer.y;


	image_speed = 0;

	visible = (oPlayer.parry_cooldown > 0);

	var progress = clamp(
	    1 - (oPlayer.parry_cooldown / oPlayer.parry_failed_cooldown),
	    0,
	    1
	);

	image_index = floor(progress * (image_number - 1));	
}