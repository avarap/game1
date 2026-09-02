class_name TestCemeteryTerrainAtlas
extends RefCounted

const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const TERRAIN_ATLAS := "res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
const TERRAIN_SOURCE := 0
const OBJECT_SOURCE := 1


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(TERRAIN_ATLAS):
		failures.append("Cemetery should use a dedicated terrain/path atlas")

	var map := CEMETERY_SCENE.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if ground == null or paths == null or objects == null:
		failures.append("Cemetery terrain contract requires ground, paths and objects layers")
		map.free()
		return failures

	var tile_set := ground.tile_set
	if tile_set == null or not tile_set.has_source(TERRAIN_SOURCE):
		failures.append("Cemetery TileSet should expose terrain source 0")
	if tile_set == null or not tile_set.has_source(OBJECT_SOURCE):
		failures.append("Cemetery TileSet should keep legacy object source 1")

	for cell in ground.get_used_cells():
		if ground.get_cell_source_id(cell) != TERRAIN_SOURCE:
			failures.append("Ground cell should come from dedicated terrain source: %s" % cell)
			break
	for cell in paths.get_used_cells():
		if paths.get_cell_source_id(cell) != TERRAIN_SOURCE:
			failures.append("Path cell should come from dedicated terrain source: %s" % cell)
			break
	for cell in objects.get_used_cells():
		if objects.get_cell_source_id(cell) != OBJECT_SOURCE:
			failures.append("Object cell should stay on legacy object source: %s" % cell)
			break

	map.free()
	return failures
