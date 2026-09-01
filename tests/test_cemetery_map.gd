class_name TestCemeteryMap
extends RefCounted

const PLAYER_SCENE := preload("res://player/player.tscn")
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
const ROUTE_TARGETS := [
	"WorkshopArea/Workbench",
	"WorkshopArea/StorageChest",
	"WorkshopArea/SleepSpot",
	"CemeteryArea/CorpseDelivery",
	"CemeteryArea/PreparationTable",
	"CemeteryArea/GravePlot",
	"CemeteryArea/GraveUpgrade",
	"ForestExit",
	"VillageExit",
	"FutureExpansion",
]
const EXPECTED_TILE_SIZE := Vector2i(32, 32)
const EXPECTED_POSITIONS := {
	"WorkshopArea/Workbench": Vector2(288, 768),
	"WorkshopArea/StorageChest": Vector2(480, 768),
	"WorkshopArea/SleepSpot": Vector2(352, 832),
	"CemeteryArea/CorpseDelivery": Vector2(928, 608),
	"CemeteryArea/PreparationTable": Vector2(1024, 608),
	"CemeteryArea/GravePlot": Vector2(1152, 544),
	"CemeteryArea/GraveUpgrade": Vector2(1248, 544),
}
const EXPECTED_MARKERS := {
	"PlayerSpawn": Vector2(416, 800),
	"AldrenSpawn": Vector2(800, 544),
	"ForestExit": Vector2(1536, 704),
	"VillageExit": Vector2(800, 64),
	"FutureExpansion": Vector2(1376, 160),
}
const OBSOLETE_POSITIONS := {
	"WorkshopArea/Workbench": Vector2(448, 704),
	"WorkshopArea/StorageChest": Vector2(512, 704),
	"WorkshopArea/SleepSpot": Vector2(384, 704),
	"CemeteryArea/CorpseDelivery": Vector2(960, 320),
	"CemeteryArea/PreparationTable": Vector2(1024, 320),
	"CemeteryArea/GravePlot": Vector2(1088, 320),
	"CemeteryArea/GraveUpgrade": Vector2(1152, 320),
}
const REPRESENTATIVE_OBSTACLE_CELLS := [
	Vector2i(7, 20),
	Vector2i(12, 19),
	Vector2i(5, 8),
	Vector2i(40, 10),
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
			failures.append("%s should use the rebuilt-map position" % node_path)
		if interaction.position == OBSOLETE_POSITIONS[node_path]:
			failures.append("%s should not retain the obsolete map position" % node_path)
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
		if marker.position != EXPECTED_MARKERS[marker_path]:
			failures.append("%s should use the rebuilt-map position" % marker_path)
		var cell := collision.local_to_map(collision.to_local(marker.global_position))
		if collision.get_cell_source_id(cell) != -1:
			failures.append("%s should not spawn inside tile collision" % marker_path)

	var spawn := map.get_node("PlayerSpawn") as Marker2D
	var spawn_cell := collision.local_to_map(collision.to_local(spawn.global_position))
	for target_path in ROUTE_TARGETS:
		var target := map.get_node_or_null(target_path) as Node2D
		if target == null:
			continue
		var target_cell := collision.local_to_map(collision.to_local(target.global_position))
		if not _can_reach(collision, spawn_cell, target_cell):
			failures.append("PlayerSpawn should have a collision-free route to %s" % target_path)

	var paths := map.get_node_or_null("paths") as TileMapLayer
	var decoration_low := map.get_node_or_null("decoration_low") as TileMapLayer
	var objects_y_sorted := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if paths == null or paths.get_used_cells().size() < 120:
		failures.append("Cemetery needs a substantial authored path network")
	if decoration_low == null or decoration_low.get_used_cells().size() < 80:
		failures.append("Cemetery needs dense low decoration")
	if objects_y_sorted == null or objects_y_sorted.get_used_cells().size() < 30:
		failures.append("Cemetery needs enough authored graves and tall props")

	for cell in REPRESENTATIVE_OBSTACLE_CELLS:
		if collision.get_cell_source_id(cell) == -1:
			failures.append("Expected authored obstacle collision at %s" % cell)

	if map.find_child("CemeteryController", true, false) != null:
		failures.append("Cemetery map should delegate persistent cemetery state to world shell")

	var region := map.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("Cemetery map should expose NavigationRegion2D")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("Cemetery navigation polygon should be available")

	await _check_real_player_physics(map, collision, failures)
	map.free()
	return failures


static func _can_reach(collision: TileMapLayer, start: Vector2i, goal: Vector2i) -> bool:
	var pending: Array[Vector2i] = [start]
	var visited := {}
	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()
		if cell == goal:
			return true
		if visited.has(cell):
			continue
		if cell.x < 0 or cell.y < 0 or cell.x >= 50 or cell.y >= 32:
			continue
		if collision.get_cell_source_id(cell) != -1:
			continue
		visited[cell] = true
		for step in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			pending.append(cell + step)
	return false


static func _check_real_player_physics(
	map: Node2D, collision: TileMapLayer, failures: Array[String]
) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var player := PLAYER_SCENE.instantiate() as PlayerController
	map.add_child(player)
	player.set_physics_process(false)
	player.position = (map.get_node("PlayerSpawn") as Marker2D).position
	await tree.physics_frame
	await tree.physics_frame

	var start := player.position
	var hit := player.move_and_collide(Vector2(64, 0))
	if hit != null or not player.position.is_equal_approx(start + Vector2(64, 0)):
		failures.append("Real player must move freely across the workshop apron")

	var obstacle_center := collision.map_to_local(Vector2i(7, 20))
	player.position = obstacle_center + Vector2(0, 64)
	await tree.physics_frame
	hit = player.move_and_collide(Vector2(0, -96))
	if hit == null:
		failures.append("Real player must collide with authored scenery footprints")

	player.queue_free()
