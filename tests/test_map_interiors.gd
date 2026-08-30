class_name TestMapInteriors
extends RefCounted

const HOME_INTERIOR_PATH := "res://world/maps/interiors/home_workshop.tscn"
const VILLAGE_INTERIOR_PATH := "res://world/maps/interiors/village_building.tscn"
const TRANSITION_PATH := "res://world/maps/interiors/interior_transition.gd"
const REQUIRED_LAYERS := [
	"ground",
	"paths",
	"decoration_low",
	"collision",
	"objects_y_sorted",
	"foreground_occlusion",
]
const REQUIRED_MARKERS := [
	"EntryMarkers/entry_main",
	"EntryMarkers/exit_main",
	"SafeSpawn",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	for scene_path in [HOME_INTERIOR_PATH, VILLAGE_INTERIOR_PATH]:
		_validate_interior(scene_path, failures)
	_validate_transition(failures)
	return failures


static func _validate_interior(scene_path: String, failures: Array[String]) -> void:
	if not ResourceLoader.exists(scene_path):
		failures.append("Interior scene should exist: %s" % scene_path)
		return

	var packed := load(scene_path) as PackedScene
	if packed == null:
		failures.append("Interior scene should load: %s" % scene_path)
		return

	var interior := packed.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(interior)

	for layer_name in REQUIRED_LAYERS:
		if interior.get_node_or_null(layer_name) as TileMapLayer == null:
			failures.append("Interior should expose TileMapLayer '%s'" % layer_name)

	var collision := interior.get_node_or_null("collision") as TileMapLayer
	for marker_path in REQUIRED_MARKERS:
		var marker := interior.get_node_or_null(marker_path) as Node2D
		if marker == null:
			failures.append("Interior should expose stable marker '%s'" % marker_path)
			continue
		if collision != null:
			var cell := collision.local_to_map(marker.position)
			if collision.get_cell_source_id(cell) != -1:
				var message := "Interior marker '%s' should be collision-free" % marker_path
				failures.append(message)

	if not interior.has_method("get_world_rect"):
		failures.append("Interior should expose stable camera bounds")
	else:
		var bounds := interior.get_world_rect() as Rect2
		for marker_path in REQUIRED_MARKERS:
			var marker := interior.get_node_or_null(marker_path) as Node2D
			if marker != null and not bounds.has_point(marker.position):
				var message := "Interior marker '%s' should stay inside camera bounds" % marker_path
				failures.append(message)

	interior.free()


static func _validate_transition(failures: Array[String]) -> void:
	if not ResourceLoader.exists(TRANSITION_PATH):
		failures.append("Reusable interior transition should exist")
		return
	var home_exists := ResourceLoader.exists(HOME_INTERIOR_PATH)
	var village_exists := ResourceLoader.exists(VILLAGE_INTERIOR_PATH)
	if not home_exists or not village_exists:
		return

	var transition_script := load(TRANSITION_PATH) as Script
	var transition := Callable(transition_script, "move_body_to_marker")
	var home := (load(HOME_INTERIOR_PATH) as PackedScene).instantiate()
	var village := (load(VILLAGE_INTERIOR_PATH) as PackedScene).instantiate()
	var player := Node2D.new()
	player.name = "TransitionTestPlayer"
	player.set_meta("state_token", "preserved")
	var original_id := player.get_instance_id()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(home)
	tree.root.add_child(village)
	tree.root.add_child(player)

	var moved_home := transition.call(player, home, &"entry_main") as bool
	var home_marker := home.get_node("EntryMarkers/entry_main") as Node2D
	if not moved_home or player.global_position != home_marker.global_position:
		failures.append("Transition should move the existing player to a stable entry marker")

	var moved_village := transition.call(player, village, &"exit_main") as bool
	var village_marker := village.get_node("EntryMarkers/exit_main") as Node2D
	if not moved_village or player.global_position != village_marker.global_position:
		failures.append("Transition should support safe exit markers across interior scenes")
	var same_player := player.get_instance_id() == original_id
	var state_preserved := player.get_meta("state_token") == "preserved"
	if not same_player or not state_preserved:
		failures.append("Transition should preserve the same player instance and state")

	player.free()
	home.free()
	village.free()
