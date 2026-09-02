class_name TestCemeteryVisualSlice
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const CATALOG_PATH := "res://art/environment/cemetery/production/data/cemetery_art_catalog.tres"
const TERRAIN_ATLAS := "res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
const LEGACY_ATLAS := "res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CATALOG_PATH):
		failures.append("Cemetery production art catalog should exist")
	if not ResourceLoader.exists(TERRAIN_ATLAS):
		failures.append("Cemetery should expose a dedicated terrain/path atlas")
	var scene := load(MAP_PATH) as PackedScene
	var map := scene.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)
	if map.get_world_rect().size != Vector2(1600, 1024):
		failures.append("Cemetery world bounds should remain 1600x1024")
	for layer_name in [
		"ground", "paths", "decoration_low", "objects_y_sorted", "foreground_occlusion"
	]:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or layer.get_used_cells().is_empty():
			failures.append("Production layer should be populated: %s" % layer_name)
	var ground := map.get_node_or_null("ground") as TileMapLayer
	var path := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if ground != null and _atlas_coords(ground).size() < 4:
		failures.append("Cemetery should visibly use at least four ground variants")
	if path != null and path.get_used_cells().size() < 80:
		failures.append("Primary cemetery path should be continuous and substantial")
	_validate_terrain_sources(ground, path, objects, failures)
	_validate_authored_path_variation(path, failures)
	for polygon in map.find_children("*", "Polygon2D", true, false):
		if (polygon as Polygon2D).visible:
			failures.append("Production cemetery should not expose placeholder Polygon2D")
	map.free()
	return failures


static func _validate_terrain_sources(
	ground: TileMapLayer, path: TileMapLayer, objects: TileMapLayer, failures: Array[String]
) -> void:
	if ground == null or path == null or objects == null:
		return
	if ground.tile_set == path.tile_set and ground.tile_set != objects.tile_set:
		_validate_source_texture(ground.tile_set, TERRAIN_ATLAS, "terrain", failures)
		_validate_source_texture(objects.tile_set, LEGACY_ATLAS, "objects", failures)
		return
	failures.append("Terrain/path TileSet should be separated from graves and props")


static func _validate_source_texture(
	tile_set: TileSet, expected_path: String, label: String, failures: Array[String]
) -> void:
	if tile_set == null or not tile_set.has_source(0):
		failures.append("Cemetery %s TileSet should expose source 0" % label)
		return
	var source := tile_set.get_source(0) as TileSetAtlasSource
	if source == null or source.texture == null or source.texture.resource_path != expected_path:
		failures.append("Cemetery %s TileSet should use %s" % [label, expected_path])


static func _validate_authored_path_variation(path: TileMapLayer, failures: Array[String]) -> void:
	if path == null:
		return
	var variants := _atlas_coords(path)
	if variants.size() < 8:
		failures.append("Authored cemetery paths should use at least eight visual variants")
	var plaza_cells := 0
	for cell in path.get_used_cells():
		if path.get_cell_atlas_coords(cell).y == 2:
			plaza_cells += 1
	if plaza_cells < 10:
		failures.append("Cemetery junction should expose a substantial authored plaza landmark")


static func _atlas_coords(layer: TileMapLayer) -> Dictionary:
	var result := {}
	for cell in layer.get_used_cells():
		result[layer.get_cell_atlas_coords(cell)] = true
	return result
