class_name TestCemeteryMap
extends RefCounted

const CEMETERY_MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const REQUIRED_LAYERS := [
	"ground",
	"paths",
	"decoration_low",
	"collision",
	"objects_y_sorted",
	"foreground_occlusion",
]
const REQUIRED_INTERACTIONS := [
	"WorkshopArea/Workbench",
	"WorkshopArea/StorageChest",
	"WorkshopArea/SleepSpot",
	"CemeteryArea/CorpseDelivery",
	"CemeteryArea/PreparationTable",
	"CemeteryArea/GravePlot",
	"CemeteryArea/GraveUpgrade",
]
const REQUIRED_MARKERS := [
	"PlayerSpawn",
	"AldrenSpawn",
	"ForestExit",
	"VillageExit",
	"FutureExpansion",
]
const EXPECTED_TILE_SIZE := Vector2i(32, 32)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_scene_contract(failures)
	return failures


static func _check_scene_contract(failures: Array[String]) -> void:
	if not ResourceLoader.exists(CEMETERY_MAP_PATH):
		failures.append("Cemetery yard map should exist")
		return

	var map_scene := load(CEMETERY_MAP_PATH) as PackedScene
	if map_scene == null:
		failures.append("Cemetery yard map scene should load")
		return

	var map := map_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	for layer_name in REQUIRED_LAYERS:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			failures.append("Cemetery map should expose TileMapLayer '%s'" % layer_name)
			continue
		if layer.tile_set == null or layer.tile_set.tile_size != EXPECTED_TILE_SIZE:
			failures.append("Cemetery layer '%s' should use 32 px tiles" % layer_name)

	var collision := map.get_node_or_null("collision") as TileMapLayer
	if collision == null:
		map.free()
		return

	for node_path in REQUIRED_INTERACTIONS:
		var interaction := map.get_node_or_null(node_path) as Node2D
		if interaction == null:
			failures.append("Cemetery map should preserve interaction '%s'" % node_path)
			continue
		_check_accessible_position(map, collision, interaction, node_path, failures)

	for marker_path in REQUIRED_MARKERS:
		var marker := map.get_node_or_null(marker_path) as Marker2D
		if marker == null:
			failures.append("Cemetery map should expose marker '%s'" % marker_path)
			continue
		_check_accessible_position(map, collision, marker, marker_path, failures)

	var controller := map.get_node_or_null("CemeteryArea/CemeteryController") as CemeteryController
	if controller == null:
		failures.append("Cemetery map should preserve CemeteryController")

	var region := map.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("Cemetery map should expose NavigationRegion2D")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("Cemetery navigation polygon should be available")

	var paths := map.get_node_or_null("paths") as TileMapLayer
	if paths == null or paths.get_used_cells().is_empty():
		failures.append("Cemetery map should contain readable paths")

	map.free()


static func _check_accessible_position(
	map: Node2D,
	collision: TileMapLayer,
	node: Node2D,
	label: String,
	failures: Array[String]
) -> void:
	if map.has_method("get_world_rect") and not map.get_world_rect().has_point(node.global_position):
		failures.append("%s should stay inside cemetery map bounds" % label)
		return
	var cell := collision.local_to_map(collision.to_local(node.global_position))
	if collision.get_cell_source_id(cell) != -1:
		failures.append("%s should not spawn inside tile collision" % label)
