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
const ALDREN_ATLAS_SOURCE := "res://art/characters/npcs/brother_aldren_idle_walk.svg"
const DISTINCT_ROW_IDS: Array[String] = [
	"row_n",
	"row_ne",
	"row_e",
	"row_se",
	"row_s",
	"row_sw",
	"row_w",
	"row_nw",
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
	_check_distinct_direction_source_rows(failures)
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


static func _check_distinct_direction_source_rows(failures: Array[String]) -> void:
	if not FileAccess.file_exists(ALDREN_ATLAS_SOURCE):
		failures.append("Brother Aldren atlas source should exist")
		return
	var source := FileAccess.get_file_as_string(ALDREN_ATLAS_SOURCE)
	for row_id in DISTINCT_ROW_IDS:
		if source.find('id="%s"' % row_id) == -1:
			failures.append("Brother Aldren atlas should define distinct %s artwork" % row_id)
		if source.find('href="#%s"' % row_id) == -1:
			failures.append("Brother Aldren atlas should render distinct %s artwork" % row_id)
