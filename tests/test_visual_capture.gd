class_name TestVisualCapture
extends RefCounted

const MANIFEST_PATH := "res://tools/visual_capture/capture_manifest.gd"
const RUNNER_PATH := "res://tools/visual_capture/capture_runner.gd"
const SHELL_PATH := "res://tools/visual_capture/run_capture.sh"
const EXPECTED_SIZE := Vector2i(1280, 720)
const EXPECTED_ZOOM := Vector2(1.5, 1.5)
const EXPECTED_PLAYER_POSITION := Vector2(416, 800)
const EXPECTED_ALDREN_POSITION := Vector2(800, 544)
const EXPECTED_CEMETERY_CAMERA := Vector2(800, 560)
const EXPECTED_WORKSHOP_CAMERA := Vector2(416, 704)
const REQUIRED_IDS: Array[StringName] = [
	&"player_n",
	&"player_ne",
	&"player_e",
	&"player_se",
	&"player_s",
	&"player_sw",
	&"player_w",
	&"player_nw",
	&"aldren_n",
	&"aldren_ne",
	&"aldren_e",
	&"aldren_se",
	&"aldren_s",
	&"aldren_sw",
	&"aldren_w",
	&"aldren_nw",
	&"cemetery_day",
	&"cemetery_night",
	&"cemetery_architecture_props",
	&"village_architecture",
	&"ui_inventory",
	&"ui_storage",
	&"ui_crafting",
	&"ui_trade",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_capture_tool_exists(failures)
	if not failures.is_empty():
		return failures

	var runner_script := load(RUNNER_PATH) as Script
	if runner_script == null or not runner_script.can_instantiate():
		failures.append("Visual capture runner should be a loadable executable Godot script")

	var manifest_script := load(MANIFEST_PATH) as Script
	var manifest: Variant = manifest_script.new()
	var specs: Array = manifest.call("capture_specs")
	_check_specs(specs, failures)
	_check_cemetery_framing(specs, failures)
	_check_real_player_camera(failures)
	_check_character_visual_resolution(failures)
	return failures


static func _check_capture_tool_exists(failures: Array[String]) -> void:
	if not ResourceLoader.exists(MANIFEST_PATH):
		failures.append("Visual capture manifest should exist")
	if not ResourceLoader.exists(RUNNER_PATH):
		failures.append("Visual capture runner should exist")
	if not FileAccess.file_exists(SHELL_PATH):
		failures.append("Visual capture local command should exist")


static func _check_specs(specs: Array, failures: Array[String]) -> void:
	var by_id: Dictionary = {}
	for raw_spec in specs:
		var spec := raw_spec as Dictionary
		var capture_id := StringName(str(spec.get("id", "")))
		if capture_id == &"":
			failures.append("Every visual capture spec should have a stable id")
			continue
		if by_id.has(capture_id):
			failures.append("Visual capture ids should be unique: %s" % capture_id)
		by_id[capture_id] = spec
		if Vector2i(spec.get("size", Vector2i.ZERO)) != EXPECTED_SIZE:
			failures.append("%s should capture at 1280x720" % capture_id)
		if Vector2(spec.get("camera_zoom", Vector2.ZERO)) != EXPECTED_ZOOM:
			failures.append("%s should use the real 1.5x gameplay zoom" % capture_id)
		var scene_path := str(spec.get("scene", ""))
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			failures.append("%s should reference a loadable real scene" % capture_id)
		var filename := str(spec.get("filename", ""))
		if filename.is_empty() or not filename.ends_with(".png"):
			failures.append("%s should define a deterministic PNG filename" % capture_id)

	for required_id in REQUIRED_IDS:
		if not by_id.has(required_id):
			failures.append("Visual capture manifest missing required view %s" % required_id)


static func _check_cemetery_framing(specs: Array, failures: Array[String]) -> void:
	var by_id: Dictionary = {}
	for raw_spec in specs:
		var spec := raw_spec as Dictionary
		by_id[StringName(str(spec.get("id", "")))] = spec

	for direction in VisualCaptureManifest.DIRECTIONS:
		var player_id := StringName("player_%s" % direction)
		var player_spec := by_id.get(player_id, {}) as Dictionary
		if Vector2(player_spec.get("actor_position", Vector2.ZERO)) != EXPECTED_PLAYER_POSITION:
			failures.append("%s should frame the rebuilt workshop spawn" % player_id)

		var aldren_id := StringName("aldren_%s" % direction)
		var aldren_spec := by_id.get(aldren_id, {}) as Dictionary
		if Vector2(aldren_spec.get("actor_position", Vector2.ZERO)) != EXPECTED_ALDREN_POSITION:
			failures.append("%s should frame Aldren on the rebuilt processional route" % aldren_id)

	for capture_id in [&"cemetery_day", &"cemetery_night"]:
		var world_spec := by_id.get(capture_id, {}) as Dictionary
		if Vector2(world_spec.get("camera_position", Vector2.ZERO)) != EXPECTED_CEMETERY_CAMERA:
			failures.append("%s should frame the rebuilt cemetery spine" % capture_id)

	var workshop_spec := by_id.get(&"cemetery_architecture_props", {}) as Dictionary
	if Vector2(workshop_spec.get("camera_position", Vector2.ZERO)) != EXPECTED_WORKSHOP_CAMERA:
		failures.append("Cemetery architecture capture should frame the rebuilt workshop refuge")


static func _check_real_player_camera(failures: Array[String]) -> void:
	var player_scene := load("res://player/player.tscn") as PackedScene
	if player_scene == null:
		failures.append("Player scene should load for camera contract validation")
		return
	var player := player_scene.instantiate()
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		failures.append("Player scene should expose the gameplay Camera2D")
	elif camera.zoom != EXPECTED_ZOOM:
		failures.append("Capture zoom should track the real player Camera2D zoom")
	player.free()


static func _check_character_visual_resolution(failures: Array[String]) -> void:
	var source := FileAccess.get_file_as_string(RUNNER_PATH)
	if source.find('get_node_or_null("Body")') == -1:
		failures.append("Capture runner should resolve player Body visuals")
	if source.find('get_node_or_null("Visual")') == -1:
		failures.append("Capture runner should resolve NPC Visual visuals")
