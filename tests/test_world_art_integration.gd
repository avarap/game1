class_name TestWorldArtIntegration
extends RefCounted

const MAP_PATHS := [
	"res://world/maps/cemetery/cemetery_map.tscn",
	"res://world/maps/forest/forest_map.tscn",
	"res://world/maps/village/village_map.tscn",
	"res://world/maps/mine/mine_map.tscn",
	"res://world/maps/interiors/home_workshop.tscn",
	"res://world/maps/interiors/village_building.tscn",
]
const EXTERIOR_ATLAS := "res://art/environment/tilesets/cemetery_ground_tileset.png"
const CEMETERY_ATLAS_DIR := "res://art/environment/cemetery/production/atlas/"
const CEMETERY_TERRAIN_ATLAS := CEMETERY_ATLAS_DIR + "terrain_ground_paths_32.png"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(EXTERIOR_ATLAS):
		failures.append("Exterior atlas should exist for map integration")
		return failures
	if not ResourceLoader.exists(CEMETERY_TERRAIN_ATLAS):
		failures.append("Dedicated cemetery terrain atlas should exist for map integration")
		return failures

	for map_path in MAP_PATHS:
		_validate_map(map_path, failures)
	return failures


static func _validate_map(map_path: String, failures: Array[String]) -> void:
	if not ResourceLoader.exists(map_path):
		failures.append("Map should exist: %s" % map_path)
		return
	var scene := load(map_path) as PackedScene
	if scene == null:
		failures.append("Map should load: %s" % map_path)
		return
	var map := scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	if ground == null or ground.tile_set == null or ground.get_used_cells().is_empty():
		failures.append("Art-integrated map should keep populated ground: %s" % map_path)
	if paths == null or paths.tile_set == null or paths.get_used_cells().is_empty():
		failures.append("Art-integrated map should keep readable paths: %s" % map_path)
	if ground != null and ground.tile_set != null:
		var source := ground.tile_set.get_source(0) as TileSetAtlasSource
		if source == null or source.texture == null:
			failures.append("Map should expose atlas-backed tiles: %s" % map_path)
		var expected_atlas := (
			CEMETERY_TERRAIN_ATLAS if map_path.contains("cemetery") else EXTERIOR_ATLAS
		)
		if (
			source != null
			and source.texture != null
			and source.texture.resource_path != expected_atlas
		):
			failures.append("Map should use the approved exterior atlas: %s" % map_path)

	map.free()
