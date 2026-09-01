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
const EXPECTED_POSITIONS := {
	"WorkshopArea/Workbench": Vector2(448, 704),
	"WorkshopArea/StorageChest": Vector2(512, 704),
	"WorkshopArea/SleepSpot": Vector2(384, 704),
	"CemeteryArea/CorpseDelivery": Vector2(960, 320),
	"CemeteryArea/PreparationTable": Vector2(1024, 320),
	"CemeteryArea/GravePlot": Vector2(1088, 320),
	"CemeteryArea/GraveUpgrade": Vector2(1152, 320),
}


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CEMETERY_MAP_PATH):
		failures.append("Cemetery yard map should exist")
		return failures

	var map_scene := load(CEMETERY_MAP_PATH) as PackedScene
	if map_scene == null:
		failures.append("Cemetery yard map scene should load")
		return failures

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
		return failures

	var world_rect: Rect2 = map.get_world_rect()
	if world_rect.size != Vector2(1600, 1024):
		failures.append("Cemetery world bounds should remain 1600x1024")
	for node_path in REQUIRED_INTERACTIONS:
		var interaction := map.get_node_or_null(node_path) as Node2D
		if interaction == null:
			failures.append("Cemetery map should preserve interaction '%s'" % node_path)
			continue
		if not world_rect.has_point(interaction.global_position):
			failures.append("%s should stay inside cemetery map bounds" % node_path)
		if interaction.position != EXPECTED_POSITIONS[node_path]:
			failures.append("%s should preserve its gameplay position" % node_path)
		var cell := collision.local_to_map(collision.to_local(interaction.global_position))
		if collision.get_cell_source_id(cell) != -1:
			failures.append("%s should not spawn inside tile collision" % node_path)

	for marker_path in REQUIRED_MARKERS:
		var marker := map.get_node_or_null(marker_path) as Marker2D
		if marker == null:
			failures.append("Cemetery map should expose marker '%s'" % marker_path)
			continue
		if not world_rect.has_point(marker.global_position):
			failures.append("%s should stay inside cemetery map bounds" % marker_path)
		var cell := collision.local_to_map(collision.to_local(marker.global_position))
		if collision.get_cell_source_id(cell) != -1:
			failures.append("%s should not spawn inside tile collision" % marker_path)

	if map.find_child("CemeteryController", true, false) != null:
		failures.append("Cemetery map should delegate persistent cemetery state to world shell")

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
	return failures
