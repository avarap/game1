class_name TestCemeteryVisualSlice
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const MAP_SCRIPT_PATH := "res://world/maps/cemetery/cemetery_map.gd"
const CATALOG_PATH := (
	"res://art/environment/cemetery/production/data/" + "cemetery_art_catalog.tres"
)
const TERRAIN_ATLAS := (
	"res://art/environment/cemetery/production/atlas/" + "cemetery_terrain_hand_authored_32.png"
)
const TERRAIN_TILESET := (
	"res://art/environment/cemetery/production/data/" + "cemetery_terrain_hand_authored.tres"
)
const GROUND_ATLAS := (
	"res://art/environment/cemetery/production/atlas/" + "cemetery_ground_hand_authored_32.png"
)
const PATH_ATLAS := (
	"res://art/environment/cemetery/production/atlas/" + "cemetery_paths_hand_authored_32.png"
)
const LEGACY_ATLAS := "res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
const REMOVED_VISUAL_SCRIPTS: Array[String] = [
	"res://world/maps/cemetery/cemetery_terrain_tileset.gd",
	"res://world/maps/cemetery/cemetery_visual_dressing.gd",
	"res://world/maps/cemetery/cemetery_commercial_composition.gd",
	"res://world/maps/cemetery/cemetery_commercial_finish.gd",
	"res://world/maps/cemetery/cemetery_zoning.gd",
]
const REMOVED_VISUAL_NODES: Array[StringName] = [
	&"AuthoredZoning",
	&"AuthoredVisualDressing",
	&"CommercialCompositionPass",
	&"CommercialFinishPass",
]
const EXPECTED_TERRAIN_ATLAS_SIZE := Vector2i(512, 256)
const TERRAIN_TILE_SIZE := Vector2i(32, 32)
const EXPECTED_TERRAIN_TILE_COUNT := 128
const EXPECTED_TERRAIN_ATLAS_SHA256 := (
	"00b0f560fb9894eaf20401cd77c487a3" + "5f7e00ac2cdceda1207bb9e77687e4a4"
)
const EXPECTED_GROUND_ATLAS_SIZE := Vector2i(1600, 1024)
const EXPECTED_GROUND_ATLAS_SHA256 := (
	"2c3694b30bc0ef6aadae29e898884fba" + "fdecdbe293803d90cc3ac1ed12492ba7"
)
const EXPECTED_PATH_ATLAS_SHA256 := (
	"6a856a91a5b47158592542597a52b9d2" + "025ae61fdfbe9e0e399bcaa2bb4bca59"
)
const CEMETERY_VISUAL_RECT := Rect2i(Vector2i(30, 5), Vector2i(14, 15))
const TECHNICAL_PLACEHOLDER_TILE := Vector2i(4, 3)
const TECHNICAL_LEGACY_SPRITES: Array[Vector2i] = [
	Vector2i(0, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(4, 3),
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(CATALOG_PATH):
		failures.append("Cemetery production art catalog should exist")
	_validate_hand_authored_atlas(failures)
	_validate_continuous_ground_atlas(failures)
	_validate_transparent_path_atlas(failures)
	var scene := load(MAP_PATH) as PackedScene
	var map := scene.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)
	if map.get_world_rect().size != Vector2(1600, 1024):
		failures.append("Cemetery world bounds should remain 1600x1024")
	for layer_name in [
		"ground", "paths", "decoration_low", "objects_y_sorted", "foreground_occlusion"
	]:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null or not _has_authored_visuals(layer):
			failures.append("Production layer should be populated: %s" % layer_name)
	var ground := map.get_node_or_null("ground") as TileMapLayer
	var path := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	_validate_static_authored_map(map, failures)
	_validate_continuous_ground_mapping(ground, failures)
	_validate_transparent_path_mapping(path, failures)
	if ground != null and _atlas_coords(ground).size() < 4:
		failures.append("Cemetery should visibly use at least four ground variants")
	if path != null and path.get_used_cells().size() < 80:
		failures.append("Primary cemetery path should be continuous and substantial")
	_validate_terrain_sources(ground, path, objects, failures)
	_validate_authored_ground_clustering(ground, failures)
	_validate_authored_path_variation(path, failures)
	_validate_static_path_network(path, failures)
	_validate_grave_breakup(objects, failures)
	_validate_no_technical_placeholders(objects, failures)
	_validate_no_visible_technical_legacy_sprites(map, failures)
	for polygon in map.find_children("*", "Polygon2D", true, false):
		if (polygon as Polygon2D).visible:
			failures.append("Production cemetery should not expose placeholder Polygon2D")
	map.free()
	return failures


static func _validate_hand_authored_atlas(failures: Array[String]) -> void:
	if not FileAccess.file_exists(TERRAIN_ATLAS):
		failures.append("Hand-authored cemetery terrain atlas should exist")
		return
	if not ResourceLoader.exists(TERRAIN_TILESET):
		failures.append("Cemetery terrain should expose a static TileSet resource")
	var texture := load(TERRAIN_ATLAS) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.is_empty():
		failures.append("Hand-authored cemetery terrain atlas should load as image data")
		return
	if image.get_size() != EXPECTED_TERRAIN_ATLAS_SIZE:
		failures.append("Hand-authored cemetery terrain atlas should be 512x256")
		return
	if FileAccess.get_sha256(TERRAIN_ATLAS) != EXPECTED_TERRAIN_ATLAS_SHA256:
		failures.append("Cemetery terrain pixels should match the approved authored baseline")
	var populated_tiles := 0
	var has_partial_alpha := false
	for tile_y in range(EXPECTED_TERRAIN_ATLAS_SIZE.y / TERRAIN_TILE_SIZE.y):
		for tile_x in range(EXPECTED_TERRAIN_ATLAS_SIZE.x / TERRAIN_TILE_SIZE.x):
			var tile := image.get_region(
				Rect2i(tile_x * TERRAIN_TILE_SIZE.x, tile_y * TERRAIN_TILE_SIZE.y, 32, 32)
			)
			if not tile.get_used_rect().has_area():
				continue
			populated_tiles += 1
			for pixel_y in TERRAIN_TILE_SIZE.y:
				for pixel_x in TERRAIN_TILE_SIZE.x:
					var alpha := tile.get_pixel(pixel_x, pixel_y).a
					if alpha > 0.0 and alpha < 1.0:
						has_partial_alpha = true
	if populated_tiles != EXPECTED_TERRAIN_TILE_COUNT:
		failures.append("All 128 hand-authored terrain cells should contain pixels")
	if has_partial_alpha:
		failures.append("Hand-authored cemetery terrain should use binary alpha")
	_validate_distinct_authored_tiles(image, failures)


static func _validate_distinct_authored_tiles(image: Image, failures: Array[String]) -> void:
	for tile_y in 8:
		var row := image.get_region(Rect2i(0, tile_y * 32, 512, 32))
		for other_row_y in range(tile_y + 1, 8):
			var other_row := image.get_region(Rect2i(0, other_row_y * 32, 512, 32))
			if row.get_data() == other_row.get_data():
				failures.append("Terrain material rows must not duplicate each other")
		for tile_x in 16:
			var tile := image.get_region(Rect2i(tile_x * 32, tile_y * 32, 32, 32))
			for other_tile_x in range(tile_x + 1, 16):
				var other_tile := image.get_region(Rect2i(other_tile_x * 32, tile_y * 32, 32, 32))
				if tile.get_data() == other_tile.get_data():
					failures.append(
						"Terrain row %d should contain distinct authored cells" % tile_y
					)
					return


static func _validate_continuous_ground_atlas(failures: Array[String]) -> void:
	if not FileAccess.file_exists(GROUND_ATLAS):
		failures.append("Continuous hand-authored cemetery ground atlas should exist")
		return
	var texture := load(GROUND_ATLAS) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != EXPECTED_GROUND_ATLAS_SIZE:
		failures.append("Continuous cemetery ground atlas should cover the 1600x1024 map")
		return
	if FileAccess.get_sha256(GROUND_ATLAS) != EXPECTED_GROUND_ATLAS_SHA256:
		failures.append("Continuous cemetery ground pixels should match the reviewed baseline")


static func _validate_continuous_ground_mapping(
	ground: TileMapLayer, failures: Array[String]
) -> void:
	if ground == null or ground.tile_set == null or not ground.tile_set.has_source(1):
		failures.append("Cemetery ground should expose its full-map authored atlas source")
		return
	var source := ground.tile_set.get_source(1) as TileSetAtlasSource
	if source == null or source.texture == null or source.texture.resource_path != GROUND_ATLAS:
		failures.append("Cemetery ground source should use the continuous authored atlas")
		return
	for cell in ground.get_used_cells():
		if ground.get_cell_source_id(cell) != 1 or ground.get_cell_atlas_coords(cell) != cell:
			failures.append("Cemetery ground cells should reconstruct the continuous authored map")
			return


static func _validate_transparent_path_atlas(failures: Array[String]) -> void:
	if not FileAccess.file_exists(PATH_ATLAS):
		failures.append("Hand-authored cemetery path overlay atlas should exist")
		return
	var texture := load(PATH_ATLAS) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(512, 32):
		failures.append("Cemetery path overlay atlas should expose sixteen 32px cells")
		return
	if FileAccess.get_sha256(PATH_ATLAS) != EXPECTED_PATH_ATLAS_SHA256:
		failures.append("Cemetery path pixels should match the reviewed authored baseline")
	var transparent_pixels := 0
	var opaque_pixels := 0
	for pixel_y in image.get_height():
		for pixel_x in image.get_width():
			var alpha := image.get_pixel(pixel_x, pixel_y).a
			if alpha == 0.0:
				transparent_pixels += 1
			elif alpha == 1.0:
				opaque_pixels += 1
			else:
				failures.append("Hand-authored cemetery paths should use hard pixel alpha")
				return
	if transparent_pixels == 0 or opaque_pixels == 0:
		failures.append("Path overlay should mix transparent verge and opaque dirt pixels")


static func _validate_transparent_path_mapping(path: TileMapLayer, failures: Array[String]) -> void:
	if path == null or path.tile_set == null or not path.tile_set.has_source(2):
		failures.append("Cemetery paths should expose the transparent authored overlay source")
		return
	var source := path.tile_set.get_source(2) as TileSetAtlasSource
	if source == null or source.texture == null or source.texture.resource_path != PATH_ATLAS:
		failures.append("Cemetery path source should use the transparent authored overlay atlas")
		return
	var overlay_cells := 0
	for cell in path.get_used_cells():
		if path.get_cell_source_id(cell) == 2:
			overlay_cells += 1
	if overlay_cells < 70:
		failures.append("Primary cemetery route should use transparent hand-authored overlays")


static func _validate_static_authored_map(map: Node, failures: Array[String]) -> void:
	for node_name in REMOVED_VISUAL_NODES:
		if map.get_node_or_null(NodePath(node_name)) != null:
			failures.append("Runtime visual pass must be removed: %s" % node_name)
	for script_path in REMOVED_VISUAL_SCRIPTS:
		if FileAccess.file_exists(script_path):
			failures.append("Runtime visual composition script must be removed: %s" % script_path)
	for child in map.find_children("*", "Line2D", true, false):
		if (child as Line2D).is_visible_in_tree():
			failures.append("Production cemetery paths must be authored TileMap cells")
	var map_source := FileAccess.get_file_as_string(MAP_SCRIPT_PATH)
	if map_source.contains(".set_cell(") or map_source.contains("CemeteryArtTileset.build"):
		failures.append("Cemetery scene art should not be painted by its runtime script")


static func _has_authored_visuals(layer: TileMapLayer) -> bool:
	if not layer.get_used_cells().is_empty():
		return true
	for child in layer.find_children("*", "Sprite2D", true, false):
		if (child as Sprite2D).visible:
			return true
	return false


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


static func _validate_authored_ground_clustering(
	ground: TileMapLayer, failures: Array[String]
) -> void:
	if ground == null:
		return
	var matches := 0
	var neighbor_pairs := 0
	for cell in ground.get_used_cells():
		var atlas_coord := ground.get_cell_atlas_coords(cell)
		for neighbor in [cell + Vector2i.RIGHT, cell + Vector2i.DOWN]:
			if ground.get_cell_source_id(neighbor) < 0:
				continue
			neighbor_pairs += 1
			if ground.get_cell_atlas_coords(neighbor).y == atlas_coord.y:
				matches += 1
	if neighbor_pairs == 0:
		failures.append("Cemetery ground should expose adjacent authored terrain cells")
		return
	var coherence := float(matches) / float(neighbor_pairs)
	if coherence < 0.42:
		failures.append(
			"Ground materials should form authored terrain clusters instead of per-cell noise"
		)


static func _validate_authored_path_variation(path: TileMapLayer, failures: Array[String]) -> void:
	if path == null:
		return
	var variants := _atlas_coords(path)
	if variants.size() < 8:
		failures.append("Authored cemetery paths should use at least eight visual variants")
	var plaza_cells := 0
	for cell in path.get_used_cells():
		if path.get_cell_atlas_coords(cell).y == 6:
			plaza_cells += 1
	if plaza_cells < 10:
		failures.append("Cemetery junction should expose a substantial authored plaza landmark")


static func _validate_static_path_network(path: TileMapLayer, failures: Array[String]) -> void:
	if path == null:
		return
	var connected_cells := 0
	for cell in path.get_used_cells():
		for direction in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			if path.get_cell_source_id(cell + direction) >= 0:
				connected_cells += 1
				break
	if connected_cells < 80:
		failures.append("Static authored path cells should form substantial connected routes")


static func _validate_grave_breakup(objects: TileMapLayer, failures: Array[String]) -> void:
	if objects == null:
		return
	var grave_visuals := 0
	for child in objects.find_children("*", "Sprite2D", true, false):
		var sprite := child as Sprite2D
		var lower_name := str(sprite.name).to_lower()
		if sprite.is_visible_in_tree() and ("grave" in lower_name or "memorial" in lower_name):
			grave_visuals += 1
	if grave_visuals < 10:
		failures.append("Hand-placed grave and memorial visuals should retain readable clusters")


static func _validate_no_technical_placeholders(
	objects: TileMapLayer, failures: Array[String]
) -> void:
	if objects == null:
		return
	for cell in objects.get_used_cells():
		if (
			CEMETERY_VISUAL_RECT.has_point(cell)
			and objects.get_cell_atlas_coords(cell) == TECHNICAL_PLACEHOLDER_TILE
		):
			failures.append("Cemetery gameplay area must not expose technical placeholder tiles")
			return


static func _validate_no_visible_technical_legacy_sprites(
	map: Node, failures: Array[String]
) -> void:
	for child in map.find_children("*", "Sprite2D", true, false):
		var sprite := child as Sprite2D
		if not sprite.is_visible_in_tree():
			continue
		var atlas_texture := sprite.texture as AtlasTexture
		if atlas_texture == null or atlas_texture.atlas == null:
			continue
		if atlas_texture.atlas.resource_path != LEGACY_ATLAS:
			continue
		var atlas_cell := Vector2i(atlas_texture.region.position / 32.0)
		if atlas_cell in TECHNICAL_LEGACY_SPRITES:
			failures.append("Cemetery must not render technical legacy footprint sprites")
			return


static func _atlas_coords(layer: TileMapLayer) -> Dictionary:
	var result := {}
	for cell in layer.get_used_cells():
		result[layer.get_cell_atlas_coords(cell)] = true
	return result
