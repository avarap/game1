class_name TestPlayerProductionVisual
extends RefCounted


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
	if body.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
		failures.append("Player pixel art should use nearest filtering")
	var shadow := player.get_node_or_null("ContactShadow") as Sprite2D
	if shadow == null:
		failures.append("Player should own a contact-shadow node")
	elif shadow.z_index >= body.z_index:
		failures.append("Player contact shadow should draw below the body")

	for facing in [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]:
		_check_animation(body, StringName("idle_%s" % facing), 1, failures)
		_check_animation(body, StringName("walk_%s" % facing), 4, failures)
		_check_animation(body, StringName("run_%s" % facing), 4, failures)
		_check_animation(body, StringName("interact_%s" % facing), 3, failures)

	player.free()
	return failures


static func _check_animation(
	body: AnimatedSprite2D,
	animation: StringName,
	minimum_frames: int,
	failures: Array[String]
) -> void:
	if not body.sprite_frames.has_animation(animation):
		failures.append("Missing player animation %s" % animation)
		return
	if body.sprite_frames.get_frame_count(animation) < minimum_frames:
		failures.append(
			"Player animation %s should have at least %d frames" % [animation, minimum_frames]
		)
		return
	var texture := body.sprite_frames.get_frame_texture(animation, 0)
	if texture == null or texture.get_size() != Vector2(64, 96):
		failures.append("Player animation %s is not 64x96" % animation)
