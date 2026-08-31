class_name TechnicalMap
extends Node2D

const TILE_SIZE := Vector2i(32, 32)
const MAP_SIZE_TILES := Vector2i(50, 32)
const SOURCE_ID := 0
const COLLISION_TILE := Vector2i(7, 7)

@export var visual_ground_tile := Vector2i(0, 0)
@export var visual_path_tile := Vector2i(0, 1)
@export var visual_decoration_tile := Vector2i(0, 6)
@export var visual_object_tile := Vector2i(2, 6)
@export var visual_foreground_tile := Vector2i(5, 7)

@onready var ground: TileMapLayer = $ground
@onready var paths: TileMapLayer = $paths
@onready var decoration_low: TileMapLayer = $decoration_low
@onready var collision: TileMapLayer = $collision
@onready var objects_y_sorted: TileMapLayer = $objects_y_sorted
@onready var foreground_occlusion: TileMapLayer = $foreground_occlusion


func _ready() -> void:
	_apply_named_palette()
	var art_tileset := MapArtTileset.build()
	_configure_layers(art_tileset)
	_populate_ground()
	_populate_diagnostics()
	_populate_collision()
	MapArtPresenter.apply(self)


func get_world_rect() -> Rect2:
	return Rect2(
		Vector2.ZERO,
		Vector2(MAP_SIZE_TILES.x * TILE_SIZE.x, MAP_SIZE_TILES.y * TILE_SIZE.y),
	)


func _apply_named_palette() -> void:
	match name:
		"CemeteryMap":
			visual_ground_tile = Vector2i(0, 2)
			visual_path_tile = Vector2i(3, 2)
			visual_decoration_tile = Vector2i(6, 6)
			visual_object_tile = Vector2i(2, 6)
			visual_foreground_tile = Vector2i(5, 7)
		"MineMap":
			visual_ground_tile = Vector2i(1, 7)
			visual_path_tile = Vector2i(2, 2)
			visual_decoration_tile = Vector2i(4, 6)
			visual_object_tile = Vector2i(5, 6)
			visual_foreground_tile = Vector2i(6, 7)
		"HomeWorkshop", "VillageBuilding":
			visual_ground_tile = Vector2i(1, 4)
			visual_path_tile = Vector2i(2, 4)
			visual_decoration_tile = Vector2i(4, 6)
			visual_object_tile = Vector2i(6, 6)
			visual_foreground_tile = Vector2i(7, 7)


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
			ground.set_cell(Vector2i(x, y), SOURCE_ID, visual_ground_tile)


func _populate_diagnostics() -> void:
	for x in range(16, 35):
		paths.set_cell(Vector2i(x, 19), SOURCE_ID, visual_path_tile)
	for x in range(18, 34, 3):
		decoration_low.set_cell(Vector2i(x, 10), SOURCE_ID, visual_decoration_tile)
	objects_y_sorted.set_cell(Vector2i(19, 9), SOURCE_ID, visual_object_tile)
	foreground_occlusion.set_cell(Vector2i(19, 8), SOURCE_ID, visual_foreground_tile)


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
