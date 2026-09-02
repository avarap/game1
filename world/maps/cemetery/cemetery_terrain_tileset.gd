class_name CemeteryTerrainTileset
extends RefCounted

const TILE_SIZE := Vector2i(32, 32)
const SOURCE_ID := 0
const ATLAS_PATH := "res://art/environment/cemetery/production/atlas/terrain_ground_paths_32.png"
const ATLAS_GRID := Vector2i(8, 3)


static func build() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	var source := TileSetAtlasSource.new()
	source.texture = load(ATLAS_PATH) as Texture2D
	source.texture_region_size = TILE_SIZE
	for y in range(ATLAS_GRID.y):
		for x in range(ATLAS_GRID.x):
			source.create_tile(Vector2i(x, y))
	tile_set.add_source(source, SOURCE_ID)
	return tile_set
