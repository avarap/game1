class_name TestIsoverseTestMap
extends RefCounted

const MAP_PATH := "res://world/maps/isoverse_test/isoverse_test_map.tscn"
const SCRIPT_PATH := "res://world/maps/isoverse_test/isoverse_test_map.gd"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(MAP_PATH):
		failures.append("Isoverse test map scene should exist")
		return failures
	if not ResourceLoader.exists(SCRIPT_PATH):
		failures.append("Isoverse test map script should exist")
		return failures

	var scene := load(MAP_PATH) as PackedScene
	if scene == null:
		failures.append("Isoverse test map scene should load")
		return failures

	var map := scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	if not map.has_method("get_map_size"):
		failures.append("Isoverse test map should expose get_map_size")
	elif map.get_map_size() != Vector2i(30, 20):
		failures.append("Isoverse test map should be 30x20 cells")

	for node_name in ["Ground", "Paths", "Objects", "PlayerSpawn"]:
		if map.get_node_or_null(node_name) == null:
			failures.append("Isoverse test map should expose '%s'" % node_name)

	if map.has_method("get_atlas_region"):
		if map.get_atlas_region("tree") != Rect2i(96, 65, 32, 76):
			failures.append("Tree atlas region should match Isoverse Free sheet")
		if map.get_atlas_region("rock") != Rect2i(131, 68, 25, 25):
			failures.append("Rock atlas region should match Isoverse Free sheet")
		if map.get_atlas_region("building_west") != Rect2i(199, 1, 130, 127):
			failures.append("West building atlas region should match Isoverse Free sheet")
		if map.get_atlas_region("building_east") != Rect2i(343, 1, 130, 127):
			failures.append("East building atlas region should match Isoverse Free sheet")
	else:
		failures.append("Isoverse test map should expose atlas regions")

	if map.has_method("uses_external_art") and map.uses_external_art():
		failures.append("CI map should fall back cleanly when external Isoverse art is absent")

	map.free()
	return failures
