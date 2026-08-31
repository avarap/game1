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

	_check_animation(body, &"idle_n", failures)
	_check_animation(body, &"walk_n", failures)
	_check_animation(body, &"idle_ne", failures)
	_check_animation(body, &"walk_ne", failures)
	_check_animation(body, &"idle_e", failures)
	_check_animation(body, &"walk_e", failures)
	_check_animation(body, &"idle_se", failures)
	_check_animation(body, &"walk_se", failures)
	_check_animation(body, &"idle_s", failures)
	_check_animation(body, &"walk_s", failures)
	_check_animation(body, &"idle_sw", failures)
	_check_animation(body, &"walk_sw", failures)
	_check_animation(body, &"idle_w", failures)
	_check_animation(body, &"walk_w", failures)
	_check_animation(body, &"idle_nw", failures)
	_check_animation(body, &"walk_nw", failures)

	player.free()
	return failures


static func _check_animation(
	body: AnimatedSprite2D, animation: StringName, failures: Array[String]
) -> void:
	if not body.sprite_frames.has_animation(animation):
		failures.append("Missing player animation %s" % animation)
		return
	if body.sprite_frames.get_frame_count(animation) < 1:
		failures.append("Player animation %s has no frames" % animation)
		return
	var texture := body.sprite_frames.get_frame_texture(animation, 0)
	if texture == null or texture.get_size() != Vector2(64, 96):
		failures.append("Player animation %s is not 64x96" % animation)
