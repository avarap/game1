class_name TestCemeteryRouteReadability
extends RefCounted

const CEMETERY_MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const INTERACTION_PATHS := [
	"WorkshopArea/Workbench",
	"WorkshopArea/StorageChest",
	"WorkshopArea/SleepSpot",
	"CemeteryArea/CorpseDelivery",
	"CemeteryArea/PreparationTable",
	"CemeteryArea/GravePlot",
	"CemeteryArea/GraveUpgrade",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var map_scene := load(CEMETERY_MAP_PATH) as PackedScene
	if map_scene == null:
		failures.append("Cemetery route readability requires the rebuilt cemetery map")
		return failures

	var map := map_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	var paths := map.get_node_or_null("paths") as TileMapLayer
	if paths == null:
		failures.append("Rebuilt cemetery should expose its path layer")
		map.free()
		return failures

	for node_path in INTERACTION_PATHS:
		var interaction := map.get_node_or_null(node_path) as Node2D
		if interaction == null:
			failures.append("Missing interaction '%s'" % node_path)
			continue
		if not _has_readable_path_near(paths, interaction.global_position):
			failures.append("%s should sit on or beside a readable travel path" % node_path)

	map.free()
	return failures


static func _has_readable_path_near(paths: TileMapLayer, global_position: Vector2) -> bool:
	var center := paths.local_to_map(paths.to_local(global_position))
	for y in range(center.y - 1, center.y + 2):
		for x in range(center.x - 1, center.x + 2):
			if paths.get_cell_source_id(Vector2i(x, y)) != -1:
				return true
	return false
