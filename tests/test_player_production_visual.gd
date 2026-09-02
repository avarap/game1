class_name TestPlayerProductionVisual
extends RefCounted

const ACTION_SHEET := "res://art/characters/player/player_actions_64x96.png"
const DIRECTIONS := [&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"]
const STATES := [&"idle", &"walk", &"run", &"interact"]
const MINIMUM_FRAMES := {&"idle": 2, &"walk": 6, &"run": 6, &"interact": 4}


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

	for state: StringName in STATES:
		for direction: StringName in DIRECTIONS:
			_check_animation(body, state, direction, failures)

	player.free()
	return failures


static func _check_animation(
	body: AnimatedSprite2D,
	state: StringName,
	direction: StringName,
	failures: Array[String]
) -> void:
	var animation := StringName("%s_%s" % [state, direction])
	if not body.sprite_frames.has_animation(animation):
		failures.append("Missing player animation %s" % animation)
		return
	if body.sprite_frames.get_frame_count(animation) < MINIMUM_FRAMES[state]:
		failures.append(
			"Player animation %s should have at least %d authored frames"
			% [animation, MINIMUM_FRAMES[state]]
		)
		return
	for frame_index in body.sprite_frames.get_frame_count(animation):
		var texture := body.sprite_frames.get_frame_texture(animation, frame_index)
		if texture == null or texture.get_size() != Vector2(64, 96):
			failures.append("Player animation %s contains a non-64x96 frame" % animation)
			return
		if texture is not AtlasTexture:
			failures.append("Player animation %s must use authored atlas regions" % animation)
			return
		var atlas_texture := texture as AtlasTexture
		if atlas_texture.atlas == null or atlas_texture.atlas.resource_path != ACTION_SHEET:
			failures.append("Player animation %s must come from the authored action sheet" % animation)
			return
