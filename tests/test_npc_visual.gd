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
