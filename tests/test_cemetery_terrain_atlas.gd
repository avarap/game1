class_name TestCemeteryTerrainAtlas
extends RefCounted

const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const TERRAIN_ATLAS := "res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
const LEGACY_ATLAS := "res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
const TERRAIN_SOURCE := 0


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(TERRAIN_ATLAS):
		failures.append("Cemetery should use a dedicated terrain/path atlas")

	var map := CEMETERY_SCENE.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	await tree.process_frame
	await tree.process_frame

	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if ground == null or paths == null or objects == null:
		failures.append("Cemetery terrain contract requires ground, paths and objects layers")
		map.free()
		return failures

	if ground.tile_set == null or paths.tile_set == null or objects.tile_set == null:
		failures.append("Cemetery terrain contract requires valid TileSets")
		map.free()
		return failures
	if ground.tile_set != paths.tile_set:
		failures.append("Ground and paths should share the dedicated terrain TileSet")
	if ground.tile_set == objects.tile_set:
		failures.append("Terrain TileSet must be separated from object/grave TileSet")

	_validate_source_texture(ground.tile_set, TERRAIN_ATLAS, "terrain", failures)
	_validate_source_texture(objects.tile_set, LEGACY_ATLAS, "objects", failures)

	for cell in ground.get_used_cells():
		if ground.get_cell_source_id(cell) != TERRAIN_SOURCE:
			failures.append("Ground cell should come from dedicated terrain source: %s" % cell)
			break
	for cell in paths.get_used_cells():
		if paths.get_cell_source_id(cell) != TERRAIN_SOURCE:
			failures.append("Path cell should come from dedicated terrain source: %s" % cell)
			break

	var path_variants: Dictionary = {}
	var plaza_cells := 0
	for cell in paths.get_used_cells():
		var atlas := paths.get_cell_atlas_coords(cell)
		path_variants[atlas] = true
		if atlas.y == 2:
			plaza_cells += 1
	if path_variants.size() < 8:
		failures.append("Authored paths should use at least eight edge/material variants")
	if plaza_cells < 10:
		failures.append("Cemetery route junction should expose an authored plaza landmark")

	map.free()
	return failures


static func _validate_source_texture(
	tile_set: TileSet, expected_path: String, label: String, failures: Array[String]
) -> void:
	if not tile_set.has_source(TERRAIN_SOURCE):
		failures.append("Cemetery %s TileSet should expose source 0" % label)
		return
	var source := tile_set.get_source(TERRAIN_SOURCE) as TileSetAtlasSource
	if source == null or source.texture == null:
		failures.append("Cemetery %s TileSet should expose an atlas texture" % label)
		return
	if source.texture.resource_path != expected_path:
		failures.append("Cemetery %s TileSet should use %s" % [label, expected_path])
