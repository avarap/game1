extends SceneTree

const Manifest := preload("res://tools/visual_capture/capture_manifest.gd")
const PLAYER_SCENE := preload("res://player/player.tscn")
const SAMPLE_ROWS: Array[Dictionary] = [
	{"title": "Iron parts", "detail": "12", "enabled": true},
	{"title": "Turnip fodder", "detail": "4", "enabled": true},
	{"title": "Locked recipe", "detail": "Requires technology", "enabled": false},
]

var _output_dir := "user://visual_capture"
var _commit_sha := "unknown"
var _failures: Array[String] = []


func _initialize() -> void:
	_parse_arguments()
	call_deferred("_run")


func _run() -> void:
	var output_path := _absolute_path(_output_dir)
	var error := DirAccess.make_dir_recursive_absolute(output_path)
	if error != OK:
		push_error("Visual capture could not create output directory: %s" % output_path)
		quit(1)
		return

	var captures: Array[Dictionary] = []
	for spec in Manifest.capture_specs():
		var capture_result := await _capture_spec(spec, output_path)
		captures.append(capture_result)

	var metadata := {
		"commit_sha": _commit_sha,
		"benchmark": "docs/Screenshot_*.jpg",
		"generated_by": "tools/visual_capture/capture_runner.gd",
		"captures": captures,
	}
	var metadata_path := output_path.path_join("capture_metadata.json")
	var metadata_file := FileAccess.open(metadata_path, FileAccess.WRITE)
	if metadata_file == null:
		_failures.append("Could not write capture metadata")
	else:
		metadata_file.store_string(JSON.stringify(metadata, "\t"))
		metadata_file.close()

	if _failures.is_empty():
		print("[VISUAL_CAPTURE] wrote %d captures to %s" % [captures.size(), output_path])
		quit(0)
		return

	for failure in _failures:
		push_error("[VISUAL_CAPTURE] %s" % failure)
	quit(1)


func _capture_spec(spec: Dictionary, output_path: String) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(spec.get("size", Manifest.CAPTURE_SIZE))
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	root.add_child(viewport)

	var kind := StringName(spec.get("kind", &""))
	match kind:
		&"character":
			_build_character_capture(viewport, spec)
		&"world":
			_build_world_capture(viewport, spec)
		&"ui":
			_build_ui_capture(viewport, spec)
		_:
			_failures.append("Unknown capture kind for %s" % spec.get("id", ""))

	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame

	var image := viewport.get_texture().get_image()
	var filename := str(spec.get("filename", "capture.png"))
	var file_path := output_path.path_join(filename)
	var save_error := image.save_png(file_path)
	if save_error != OK:
		_failures.append("Could not save %s" % filename)

	var result := {
		"id": str(spec.get("id", "")),
		"file": filename,
		"commit_sha": _commit_sha,
		"scene": str(spec.get("scene", "")),
		"size": [viewport.size.x, viewport.size.y],
		"camera_zoom": _vector_to_array(Vector2(spec.get("camera_zoom", Vector2.ONE))),
	}
	viewport.queue_free()
	await process_frame
	return result


func _build_character_capture(viewport: SubViewport, spec: Dictionary) -> void:
	var stage := Node2D.new()
	viewport.add_child(stage)
	_add_lighting(stage, Color(spec.get("lighting", Color.WHITE)))
	_add_scene(stage, str(spec.get("context_scene", "")))

	var actor_scene := load(str(spec.get("scene", ""))) as PackedScene
	if actor_scene == null:
		_failures.append("Could not load actor scene for %s" % spec.get("id", ""))
		return
	var actor := actor_scene.instantiate() as CharacterBody2D
	if actor == null:
		_failures.append("Character capture scene is not CharacterBody2D")
		return
	actor.position = Vector2(spec.get("actor_position", Vector2.ZERO))
	actor.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(actor)
	_set_idle_direction(actor, StringName(spec.get("direction", &"s")))

	if StringName(spec.get("actor", &"")) == &"player":
		_configure_camera(actor, spec)
	else:
		_add_camera_rig(stage, Vector2(spec.get("camera_position", actor.position)), spec)


func _build_world_capture(viewport: SubViewport, spec: Dictionary) -> void:
	var stage := Node2D.new()
	viewport.add_child(stage)
	_add_lighting(stage, Color(spec.get("lighting", Color.WHITE)))
	_add_scene(stage, str(spec.get("scene", "")))
	_add_camera_rig(stage, Vector2(spec.get("camera_position", Vector2.ZERO)), spec)


func _build_ui_capture(viewport: SubViewport, spec: Dictionary) -> void:
	var background := ColorRect.new()
	background.color = Color(0.08, 0.075, 0.07, 1.0)
	background.position = Vector2.ZERO
	background.size = Vector2(viewport.size)
	viewport.add_child(background)

	var packed := load(str(spec.get("scene", ""))) as PackedScene
	if packed == null:
		_failures.append("Could not load UI scene for %s" % spec.get("id", ""))
		return
	var ui := packed.instantiate()
	viewport.add_child(ui)
	await process_frame

	if ui.has_method("set_rows"):
		ui.call("set_rows", SAMPLE_ROWS)
	if ui.has_method("set_state"):
		ui.call("set_state", StringName(spec.get("ui_state", &"ready")))
	if ui is Control:
		var control := ui as Control
		var minimum := control.get_combined_minimum_size()
		control.size = minimum
		control.position = (Vector2(viewport.size) - minimum) * 0.5
	elif ui is CanvasLayer:
		var panel := ui.get_node_or_null("Panel") as Control
		if panel != null:
			panel.show()


func _add_scene(parent: Node, scene_path: String) -> Node:
	var packed := load(scene_path) as PackedScene
	if packed == null:
		_failures.append("Could not load context scene %s" % scene_path)
		return null
	var instance := packed.instantiate()
	parent.add_child(instance)
	return instance


func _add_camera_rig(stage: Node2D, position: Vector2, spec: Dictionary) -> void:
	var rig := PLAYER_SCENE.instantiate() as CharacterBody2D
	rig.position = position
	rig.process_mode = Node.PROCESS_MODE_DISABLED
	stage.add_child(rig)
	var body := rig.get_node_or_null("Body") as CanvasItem
	if body != null:
		body.hide()
	_configure_camera(rig, spec)


func _configure_camera(actor: Node, spec: Dictionary) -> void:
	var camera := actor.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		_failures.append("Gameplay Camera2D missing for %s" % spec.get("id", ""))
		return
	camera.position_smoothing_enabled = false
	camera.zoom = Vector2(spec.get("camera_zoom", Manifest.CAMERA_ZOOM))
	camera.enabled = true


func _set_idle_direction(actor: Node, direction: StringName) -> void:
	var body := actor.get_node_or_null("Body") as AnimatedSprite2D
	if body == null:
		_failures.append("Character Body sprite missing")
		return
	var animation := StringName("idle_%s" % direction)
	if body.sprite_frames == null or not body.sprite_frames.has_animation(animation):
		_failures.append("Missing character animation %s" % animation)
		return
	body.play(animation)
	body.pause()


func _add_lighting(stage: Node2D, color: Color) -> void:
	var lighting := CanvasModulate.new()
	lighting.color = color
	stage.add_child(lighting)


func _parse_arguments() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="):
			_output_dir = argument.trim_prefix("--output=")
		elif argument.begins_with("--sha="):
			_commit_sha = argument.trim_prefix("--sha=")
	if _commit_sha == "unknown":
		var environment_sha := OS.get_environment("VISUAL_CAPTURE_SHA")
		if not environment_sha.is_empty():
			_commit_sha = environment_sha


func _absolute_path(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://"):
		return ProjectSettings.globalize_path(path)
	return path


func _vector_to_array(value: Vector2) -> Array[float]:
	return [value.x, value.y]
