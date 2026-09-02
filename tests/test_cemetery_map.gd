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
	"WorkshopArea/Workbench": Vector2(416, 800),
	"WorkshopArea/StorageChest": Vector2(480, 800),
	"WorkshopArea/SleepSpot": Vector2(320, 800),
	"CemeteryArea/CorpseDelivery": Vector2(1040, 544),
	"CemeteryArea/PreparationTable": Vector2(1104, 512),
	"CemeteryArea/GravePlot": Vector2(1216, 448),
	"CemeteryArea/GraveUpgrade": Vector2(1280, 512),
}
const EXPECTED_MARKER_POSITIONS := {
	"PlayerSpawn": Vector2(480, 736),
	"AldrenSpawn": Vector2(1184, 640),
	"ForestExit": Vector2(1504, 704),
	"VillageExit": Vector2(768, 96),
	"FutureExpansion": Vector2(1344, 160),
}
const REQUIRED_ROUTE_CELLS := [
	Vector2i(13, 23),
	Vector2i(24, 19),
	Vector2i(24, 3),
	Vector2i(31, 16),
	Vector2i(36, 8),
	Vector2i(42, 14),
	Vector2i(46, 22),
]
const REQUIRED_COLLISION_CELLS := [
	Vector2i(8, 17),
	Vector2i(16, 20),
	Vector2i(28, 5),
	Vector2i(30, 12),
	Vector2i(43, 7),
	Vector2i(45, 15),
]


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
			failures.append("%s should use the rebuilt gameplay position" % node_path)
		var cell := collision.local_to_map(collision.to_local(interaction.global_position))
		if collision.get_cell_source_id(cell) != -1:
			failures.append("%s should not spawn inside tile collision" % node_path)

	for marker_path in REQUIRED_MARKERS:
		var marker := map.get_node_or_null(marker_path) as Marker2D
		if marker == null:
			failures.append("Cemetery map should expose marker '%s'" % marker_path)
			continue
		if marker.position != EXPECTED_MARKER_POSITIONS[marker_path]:
			failures.append("%s should use the rebuilt landmark position" % marker_path)
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
	else:
		for cell in REQUIRED_ROUTE_CELLS:
			if paths.get_cell_source_id(cell) == -1:
				failures.append("Authored route should include cell %s" % cell)

	for cell in REQUIRED_COLLISION_CELLS:
		if collision.get_cell_source_id(cell) == -1:
			failures.append("Authored structural collision should include cell %s" % cell)

	var graves := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if graves == null or graves.get_used_cells().size() < 20:
		failures.append("Cemetery composition should contain authored graves, trees and props")

	map.free()
	return failures
