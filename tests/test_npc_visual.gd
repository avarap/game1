class_name TestNPCVisual
extends RefCounted

const REQUIRED_DIRECTIONS: Array[StringName] = [
	&"n",
	&"ne",
	&"e",
	&"se",
	&"s",
	&"sw",
	&"w",
	&"nw",
]
const ALDREN_ATLAS_SOURCE := "res://art/characters/npcs/brother_aldren_idle_walk_64x96.png"
const PLAYER_SCENE := "res://player/player.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var scene := load("res://world/npcs/brother_aldren.tscn") as PackedScene
	if scene == null:
		failures.append("Brother Aldren scene should load")
		return failures
	var aldren := scene.instantiate() as CharacterBody2D
	if aldren == null:
		failures.append("Brother Aldren should remain a CharacterBody2D")
		return failures
	var visual := aldren.get_node_or_null("Visual") as AnimatedSprite2D
	if visual == null:
		failures.append("Brother Aldren should use AnimatedSprite2D as primary visual")
		aldren.free()
		return failures
	if visual.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST:
		failures.append("Brother Aldren pixel art should use nearest filtering")
	if visual.sprite_frames == null:
		failures.append("Brother Aldren visual should define sprite frames")
	else:
		for direction in REQUIRED_DIRECTIONS:
			for state in [&"idle", &"walk"]:
				var animation := StringName("%s_%s" % [state, direction])
				if not visual.sprite_frames.has_animation(animation):
					failures.append("Brother Aldren should define %s" % animation)
					continue
				var minimum_frames := 4 if state == &"walk" else 1
				if visual.sprite_frames.get_frame_count(animation) < minimum_frames:
					failures.append(
						(
							"Brother Aldren %s should have at least %d frames"
							% [animation, minimum_frames]
						)
					)
					continue
				var texture := visual.sprite_frames.get_frame_texture(animation, 0)
				if texture == null or texture.get_size() != Vector2(64, 96):
					failures.append("Brother Aldren %s is not native 64x96" % animation)
	if visual.offset != Vector2(0, -48):
		failures.append("Brother Aldren should keep a feet-centered 64x96 pivot")
	_compare_player_scale(visual, failures)
	var shadow := aldren.get_node_or_null("ContactShadow") as Sprite2D
	if shadow == null:
		failures.append("Brother Aldren should own a contact-shadow node")
	elif shadow.z_index >= visual.z_index:
		failures.append("Brother Aldren contact shadow should draw below the visual")
	if not FileAccess.file_exists(ALDREN_ATLAS_SOURCE):
		failures.append("Brother Aldren should use an original native raster atlas")
	if visual.get_script() == null:
		failures.append("Brother Aldren visual should use a reusable presentation script")
	if aldren.get_node_or_null("CollisionShape2D") == null:
		failures.append("Brother Aldren collision should remain independent from visual")
	if aldren.get_node_or_null("NavigationAgent2D") == null:
		failures.append("Brother Aldren navigation should remain present")
	if aldren.get_node_or_null("DialogueInteractable") == null:
		failures.append("Brother Aldren dialogue interaction should remain present")
	aldren.free()
	return failures


static func _compare_player_scale(aldren_visual: AnimatedSprite2D, failures: Array[String]) -> void:
	var player_scene := load(PLAYER_SCENE) as PackedScene
	if player_scene == null:
		failures.append("Player scene should load for NPC scale comparison")
		return
	var player := player_scene.instantiate() as CharacterBody2D
	if player == null:
		failures.append("Player should instantiate for NPC scale comparison")
		return
	var body := player.get_node_or_null("Body") as AnimatedSprite2D
	if body == null:
		failures.append("Player Body should exist for NPC scale comparison")
		player.free()
		return
	if body.has_method("_build_production_animations"):
		body.call("_build_production_animations")
	var player_texture := body.sprite_frames.get_frame_texture(&"idle_s", 0)
	var aldren_texture := aldren_visual.sprite_frames.get_frame_texture(&"idle_s", 0)
	var player_bounds := _visible_bounds(player_texture)
	var aldren_bounds := _visible_bounds(aldren_texture)
	if player_bounds.size == Vector2i.ZERO or aldren_bounds.size == Vector2i.ZERO:
		failures.append("Player and Brother Aldren idle_s frames should contain visible pixels")
		player.free()
		return
	if absi(player_bounds.size.y - aldren_bounds.size.y) > 4:
		failures.append(
			"Brother Aldren body height should match Player within 4 px (%d vs %d)"
			% [aldren_bounds.size.y, player_bounds.size.y]
		)
	if absi(player_bounds.end.y - aldren_bounds.end.y) > 2:
		failures.append(
			"Brother Aldren feet line should match Player within 2 px (%d vs %d)"
			% [aldren_bounds.end.y, player_bounds.end.y]
		)
	player.free()


static func _visible_bounds(texture: Texture2D) -> Rect2i:
	if texture == null:
		return Rect2i()
	var image := texture.get_image()
	if image == null or image.is_empty():
		return Rect2i()
	return image.get_used_rect()
