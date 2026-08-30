class_name TechnicalMap
extends Node2D

const TILE_SIZE := Vector2i(32, 32)
const MAP_SIZE_TILES := Vector2i(50, 32)
const SOURCE_ID := 0
const GROUND_TILE := Vector2i(0, 0)
const PATH_TILE := Vector2i(1, 0)
const COLLISION_TILE := Vector2i(2, 0)
const OBJECT_TILE := Vector2i(3, 0)
const FOREGROUND_TILE := Vector2i(4, 0)

@onready var ground: TileMapLayer = $ground
@onready var paths: TileMapLayer = $paths
@onready var decoration_low: TileMapLayer = $decoration_low
@onready var collision: TileMapLayer = $collision
@onready var objects_y_sorted: TileMapLayer = $objects_y_sorted
@onready var foreground_occlusion: TileMapLayer = $foreground_occlusion


func _ready() -> void:
	var technical_tileset := _build_technical_tileset()
	_configure_layers(technical_tileset)
	_populate_ground()
	_populate_diagnostics()
	_populate_collision()


func get_world_rect() -> Rect2:
	return Rect2(
		Vector2.ZERO,
		Vector2(MAP_SIZE_TILES.x * TILE_SIZE.x, MAP_SIZE_TILES.y * TILE_SIZE.y),
	)


func _build_technical_tileset() -> TileSet:
	var tile_set := TileSet.new()
	tile_set.tile_size = TILE_SIZE
	tile_set.add_physics_layer()
	tile_set.set_physics_layer_collision_layer(0, 1)
	tile_set.set_physics_layer_collision_mask(0, 1)

	var image := Image.create(TILE_SIZE.x * 5, TILE_SIZE.y, false, Image.FORMAT_RGBA8)
	_fill_tile(image, 0, Color("344536"))
	_fill_tile(image, 1, Color("715845"))
	_fill_tile(image, 2, Color("9a5140"))
	_fill_tile(image, 3, Color("566b45"))
	_fill_tile(image, 4, Color("303947"))

	var source := TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(image)
	source.texture_region_size = TILE_SIZE
	for atlas_x in range(5):
		source.create_tile(Vector2i(atlas_x, 0))
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


func _configure_layers(tile_set: TileSet) -> void:
	for layer in [
		ground,
		paths,
		decoration_low,
		collision,
		objects_y_sorted,
		foreground_occlusion,
	]:
		layer.tile_set = tile_set
	ground.collision_enabled = false
	paths.collision_enabled = false
	decoration_low.collision_enabled = false
	objects_y_sorted.collision_enabled = false
	foreground_occlusion.collision_enabled = false
	collision.collision_enabled = true


func _populate_ground() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			ground.set_cell(Vector2i(x, y), SOURCE_ID, GROUND_TILE)


func _populate_diagnostics() -> void:
	for x in range(16, 35):
		paths.set_cell(Vector2i(x, 19), SOURCE_ID, PATH_TILE)
	for x in range(18, 34, 3):
		decoration_low.set_cell(Vector2i(x, 10), SOURCE_ID, OBJECT_TILE)
	objects_y_sorted.set_cell(Vector2i(19, 9), SOURCE_ID, OBJECT_TILE)
	foreground_occlusion.set_cell(Vector2i(19, 8), SOURCE_ID, FOREGROUND_TILE)


func _populate_collision() -> void:
	for x in range(MAP_SIZE_TILES.x):
		collision.set_cell(Vector2i(x, 0), SOURCE_ID, COLLISION_TILE)
		collision.set_cell(Vector2i(x, MAP_SIZE_TILES.y - 1), SOURCE_ID, COLLISION_TILE)
	for y in range(1, MAP_SIZE_TILES.y - 1):
		collision.set_cell(Vector2i(0, y), SOURCE_ID, COLLISION_TILE)
		collision.set_cell(Vector2i(MAP_SIZE_TILES.x - 1, y), SOURCE_ID, COLLISION_TILE)

	for y in range(13, 16):
		for x in range(23, 29):
			collision.set_cell(Vector2i(x, y), SOURCE_ID, COLLISION_TILE)


func _fill_tile(image: Image, atlas_x: int, color: Color) -> void:
	image.fill_rect(Rect2i(atlas_x * TILE_SIZE.x, 0, TILE_SIZE.x, TILE_SIZE.y), color)
