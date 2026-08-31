class_name MapArtTileset
extends RefCounted

const TILE_SIZE := Vector2i(32, 32)
const ATLAS_SIZE := Vector2i(8, 8)
const SOURCE_ID := 0
const COLLISION_TILE := Vector2i(7, 7)
const ATLAS_PATH := "res://art/environment/tilesets/exterior_tileset.svg"


static func build() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)

	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS_PATH) as Texture2D
	source.texture_region_size = TILE_SIZE
	for y in range(ATLAS_SIZE.y):
		for x in range(ATLAS_SIZE.x):
			source.create_tile(Vector2i(x, y))
	tile_set.add_source(source, SOURCE_ID)

	var collision_data := source.get_tile_data(COLLISION_TILE, 0)
	var collision_points := PackedVector2Array(
		[
			Vector2(-16, -16),
			Vector2(16, -16),
			Vector2(16, 16),
			Vector2(-16, 16),
		]
	)
	collision_data.add_collision_polygon(0)
	collision_data.set_collision_polygon_points(0, 0, collision_points)
	return tile_set
