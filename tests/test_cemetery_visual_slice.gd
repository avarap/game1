class_name TestCemeteryVisualSlice
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const CATALOG_PATH := "res://art/environment/cemetery/production/data/cemetery_art_catalog.tres"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CATALOG_PATH):
		failures.append("Cemetery production art catalog should exist")
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
	if ground != null and _atlas_coords(ground).size() < 4:
		failures.append("Cemetery should visibly use at least four ground variants")
	if path != null and path.get_used_cells().size() < 80:
		failures.append("Primary cemetery path should be continuous and substantial")
	for polygon in map.find_children("*", "Polygon2D", true, false):
		if (polygon as Polygon2D).visible:
			failures.append("Production cemetery should not expose placeholder Polygon2D")
	map.free()
	return failures


static func _atlas_coords(layer: TileMapLayer) -> Dictionary:
	var result := {}
	for cell in layer.get_used_cells():
		result[layer.get_cell_atlas_coords(cell)] = true
	return result
