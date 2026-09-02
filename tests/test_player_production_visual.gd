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
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
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

	for direction: StringName in DIRECTIONS:
		for state: StringName in STATES:
			_check_animation(body, state, direction, failures)
		_check_distinct_action_frames(body, direction, failures)

	player.free()
	return failures


static func _check_animation(
	body: AnimatedSprite2D, state: StringName, direction: StringName, failures: Array[String]
) -> void:
	var animation := StringName("%s_%s" % [state, direction])
	if not body.sprite_frames.has_animation(animation):
		failures.append("Missing player animation %s" % animation)
		return
	if body.sprite_frames.get_frame_count(animation) < MINIMUM_FRAMES[state]:
		failures.append(
			(
				"Player animation %s should have at least %d authored frames"
				% [animation, MINIMUM_FRAMES[state]]
			)
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
			failures.append(
				"Player animation %s must come from the authored action sheet" % animation
			)
			return


static func _check_distinct_action_frames(
	body: AnimatedSprite2D, direction: StringName, failures: Array[String]
) -> void:
	var walk_name := StringName("walk_%s" % direction)
	var run_name := StringName("run_%s" % direction)
	var idle_name := StringName("idle_%s" % direction)
	var interact_name := StringName("interact_%s" % direction)
	if (
		not body.sprite_frames.has_animation(run_name)
		or not body.sprite_frames.has_animation(walk_name)
	):
		return
	if (
		not body.sprite_frames.has_animation(interact_name)
		or not body.sprite_frames.has_animation(idle_name)
	):
		return
	var walk_frame := body.sprite_frames.get_frame_texture(walk_name, 0) as AtlasTexture
	var run_frame := body.sprite_frames.get_frame_texture(run_name, 0) as AtlasTexture
	var idle_frame := body.sprite_frames.get_frame_texture(idle_name, 0) as AtlasTexture
	var interact_frame := body.sprite_frames.get_frame_texture(interact_name, 1) as AtlasTexture
	if walk_frame != null and run_frame != null and walk_frame.region == run_frame.region:
		failures.append("Run %s must not reuse the walk atlas region" % direction)
	if idle_frame != null and interact_frame != null and idle_frame.region == interact_frame.region:
		failures.append("Interact %s must not reuse the idle atlas region" % direction)
