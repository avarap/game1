class_name CemeteryArtTileset
extends RefCounted

const TILE_SIZE := Vector2i(32, 32)
const SOURCE_ID := 0
const COLLISION_TILE := Vector2i(7, 7)
const ATLAS_PATH := "res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"


static func build() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)
	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS_PATH) as Texture2D
	source.texture_region_size = TILE_SIZE
	for y in range(16):
		for x in range(16):
			source.create_tile(Vector2i(x, y))
	tile_set.add_source(source, SOURCE_ID)
	var data := source.get_tile_data(COLLISION_TILE, 0)
	data.add_collision_polygon(0)
	(
		data
		. set_collision_polygon_points(
			0,
			0,
			PackedVector2Array(
				[Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)]
			),
		)
	)
	return tile_set
