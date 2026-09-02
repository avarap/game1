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
	"WorkshopArea/Workbench": Vector2(320, 768),
	"WorkshopArea/StorageChest": Vector2(384, 768),
	"WorkshopArea/SleepSpot": Vector2(256, 768),
	"CemeteryArea/CorpseDelivery": Vector2(1088, 416),
	"CemeteryArea/PreparationTable": Vector2(1152, 416),
	"CemeteryArea/GravePlot": Vector2(1120, 544),
	"CemeteryArea/GraveUpgrade": Vector2(1248, 544),
}
const EXPECTED_MARKER_POSITIONS := {
	"PlayerSpawn": Vector2(288, 704),
	"AldrenSpawn": Vector2(864, 480),
	"ForestExit": Vector2(1504, 800),
	"VillageExit": Vector2(672, 96),
	"FutureExpansion": Vector2(1376, 160),
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
		if interaction.position != EXPECTED_POSITIONS[node_path]:
			failures.append("%s should use the rebuilt map position" % node_path)
		_assert_open_cell(collision, interaction.global_position, node_path, failures)

	for marker_path in REQUIRED_MARKERS:
		var marker := map.get_node_or_null(marker_path) as Marker2D
		if marker == null:
			failures.append("Cemetery map should expose marker '%s'" % marker_path)
			continue
		if marker.position != EXPECTED_MARKER_POSITIONS[marker_path]:
			failures.append("%s should use the rebuilt map position" % marker_path)
		_assert_open_cell(collision, marker.global_position, marker_path, failures)

	var player_spawn := map.get_node("PlayerSpawn") as Marker2D
	for destination_path in [
		"WorkshopArea/Workbench",
		"CemeteryArea/PreparationTable",
		"VillageExit",
		"ForestExit",
		"FutureExpansion",
	]:
		var destination := map.get_node(destination_path) as Node2D
		var has_route := _has_collision_free_route(
			collision, player_spawn.global_position, destination.global_position
		)
		if not has_route:
			failures.append("PlayerSpawn should have a traversable route to %s" % destination_path)

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
	if paths == null or paths.get_used_cells().size() < 150:
		failures.append("Rebuilt cemetery should contain a substantial readable path network")

	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if objects == null or objects.get_used_cells().size() < 35:
		failures.append("Rebuilt cemetery should contain enough landmarks and environmental objects")

	map.free()
	return failures


static func _assert_open_cell(
	collision: TileMapLayer, global_position: Vector2, label: String, failures: Array[String]
) -> void:
	var cell := collision.local_to_map(collision.to_local(global_position))
	if collision.get_cell_source_id(cell) != -1:
		failures.append("%s should not spawn inside tile collision" % label)


static func _has_collision_free_route(
	collision: TileMapLayer, start_position: Vector2, end_position: Vector2
) -> bool:
	var start := collision.local_to_map(collision.to_local(start_position))
	var target := collision.local_to_map(collision.to_local(end_position))
	var frontier: Array[Vector2i] = [start]
	var visited := {start: true}
	var directions := [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	while not frontier.is_empty():
		var current: Vector2i = frontier.pop_front()
		if current == target:
			return true
		for direction in directions:
			var next_cell: Vector2i = current + direction
			if visited.has(next_cell):
				continue
			if next_cell.x <= 0 or next_cell.y <= 0 or next_cell.x >= 49 or next_cell.y >= 31:
				continue
			if collision.get_cell_source_id(next_cell) != -1:
				continue
			visited[next_cell] = true
			frontier.append(next_cell)
	return false
