class_name TestMapForest
extends RefCounted

const FOREST_MAP_PATH := "res://world/maps/forest/forest_map.tscn"
const REQUIRED_LAYERS := [
	"ground",
	"paths",
	"decoration_low",
	"collision",
	"objects_y_sorted",
	"foreground_occlusion",
]
const EXPECTED_TILE_SIZE := Vector2i(32, 32)
const MIN_RESOURCE_NODES := 6
const MIN_PATH_CELLS := 32


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_scene_contract(failures)
	return failures


static func _check_scene_contract(failures: Array[String]) -> void:
	if not ResourceLoader.exists(FOREST_MAP_PATH):
		failures.append("Forest map scene should exist")
		return

	var map_scene := load(FOREST_MAP_PATH) as PackedScene
	if map_scene == null:
		failures.append("Forest map scene should load")
		return

	var map := map_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	for layer_name in REQUIRED_LAYERS:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			failures.append("Forest map should expose TileMapLayer '%s'" % layer_name)
			continue
		if layer.tile_set == null or layer.tile_set.tile_size != EXPECTED_TILE_SIZE:
			failures.append("Forest layer '%s' should use the 32 px tile contract" % layer_name)

	var paths := map.get_node_or_null("paths") as TileMapLayer
	if paths != null and paths.get_used_cells().size() < MIN_PATH_CELLS:
		failures.append("Forest should contain readable primary and secondary paths")

	var collision := map.get_node_or_null("collision") as TileMapLayer
	if collision != null and collision.get_used_cells().is_empty():
		failures.append("Forest should contain collision boundaries and obstacles")

	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if objects != null and not objects.y_sort_enabled:
		failures.append("Forest tall vegetation should use Y-sort")

	var navigation := map.get_node_or_null("NavigationRegion") as NavigationRegion2D
	if navigation == null or navigation.navigation_polygon == null:
		failures.append("Forest should expose a usable NavigationRegion2D")
	elif navigation.navigation_polygon.get_polygon_count() < 1:
		failures.append("Forest navigation should contain at least one walkable polygon")

	var entrance := map.get_node_or_null("Markers/CemeteryEntrance") as Marker2D
	var exit := map.get_node_or_null("Markers/CemeteryExit") as Marker2D
	if entrance == null or exit == null:
		failures.append("Forest should expose clear cemetery entrance and exit markers")
	elif entrance.position == exit.position:
		failures.append("Forest entrance and exit markers should define distinct safe points")

	if map.get_node_or_null("Markers/SecretClearing") == null:
		failures.append("Forest should reserve a marker for a future secret interaction")

	var resources := map.get_node_or_null("Resources")
	if resources == null or resources.get_child_count() < MIN_RESOURCE_NODES:
		failures.append("Forest should contain a useful density of reusable resource nodes")
	else:
		for resource_node in resources.get_children():
			if resource_node.get_node_or_null("ResourceSourceComponent") == null:
				failures.append("Forest resources should reuse ResourceSourceComponent")
				break

	map.free()
