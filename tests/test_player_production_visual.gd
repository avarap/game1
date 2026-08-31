class_name TestPlayerProductionVisual
extends RefCounted


const EXPECTED_FRAME_SIZE := Vector2i(64, 96)


static func run() -> Array[String]:
	var failures: Array[String] = []
	var packed := load("res://player/player.tscn") as PackedScene
	if packed == null:
		failures.append("Production player scene should load")
		return failures

	var player := packed.instantiate()
	var body := player.get_node_or_null("Body") as AnimatedSprite2D
	if body == null or body.sprite_frames == null:
		failures.append("Production player should expose Body frames")
		player.free()
		return failures

	if body.offset != Vector2(0, -48):
		failures.append("64x96 player should keep feet pivot at y=0")

	for direction_value in "n,ne,e,se,s,sw,w,nw".split(","):
		var direction := StringName(direction_value)
		for state in [&"idle", &"walk"]:
			var animation := StringName("%s_%s" % [state, direction])
			if not body.sprite_frames.has_animation(animation):
				failures.append("Missing player animation %s" % animation)
				continue
			if body.sprite_frames.get_frame_count(animation) < 1:
				failures.append("Player animation %s has no frames" % animation)
				continue
			var texture := body.sprite_frames.get_frame_texture(animation, 0)
			if texture == null or texture.get_size() != Vector2(EXPECTED_FRAME_SIZE):
				failures.append("Player animation %s is not 64x96" % animation)

	player.free()
	return failures
