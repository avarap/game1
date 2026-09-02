class_name CemeteryVisualDressing
extends Node

const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const TERRAIN_SOURCE := 0
const VILLAGE_ROUTE_REPLACED := [
	Vector2i(24, 19),
	Vector2i(24, 18),
	Vector2i(25, 17),
	Vector2i(25, 16),
	Vector2i(24, 15),
	Vector2i(24, 14),
	Vector2i(23, 13),
	Vector2i(23, 12),
	Vector2i(24, 11),
	Vector2i(25, 10),
	Vector2i(25, 9),
	Vector2i(24, 8),
	Vector2i(23, 7),
	Vector2i(23, 6),
	Vector2i(24, 5),
	Vector2i(25, 4),
	Vector2i(24, 3),
]
const PLAZA_CELLS := [
	Vector2i(22, 18),
	Vector2i(23, 18),
	Vector2i(24, 18),
	Vector2i(25, 18),
	Vector2i(26, 18),
	Vector2i(22, 19),
	Vector2i(23, 19),
	Vector2i(24, 19),
	Vector2i(25, 19),
	Vector2i(26, 19),
	Vector2i(23, 20),
	Vector2i(24, 20),
	Vector2i(25, 20),
	Vector2i(26, 20),
]
const PLAZA_TILES := [
	Vector2i(0, 2),
	Vector2i(1, 2),
	Vector2i(2, 2),
	Vector2i(3, 2),
	Vector2i(4, 2),
	Vector2i(5, 2),
	Vector2i(6, 2),
	Vector2i(7, 2),
	Vector2i(1, 2),
	Vector2i(4, 2),
	Vector2i(6, 2),
	Vector2i(2, 2),
	Vector2i(5, 2),
	Vector2i(7, 2),
]
const TREE_CELLS := [
	Vector2i(5, 5),
	Vector2i(8, 7),
	Vector2i(12, 5),
	Vector2i(15, 8),
	Vector2i(5, 13),
	Vector2i(8, 17),
	Vector2i(12, 15),
	Vector2i(16, 12),
	Vector2i(5, 24),
	Vector2i(8, 27),
	Vector2i(12, 28),
	Vector2i(17, 27),
	Vector2i(43, 5),
	Vector2i(46, 8),
	Vector2i(45, 14),
	Vector2i(46, 27),
]
const DRY_GRASS_CELLS := [
	Vector2i(6, 20),
	Vector2i(8, 21),
	Vector2i(10, 20),
	Vector2i(13, 20),
	Vector2i(16, 21),
	Vector2i(18, 23),
	Vector2i(28, 8),
	Vector2i(30, 10),
	Vector2i(31, 17),
	Vector2i(42, 18),
	Vector2i(44, 20),
	Vector2i(45, 25),
]


func _ready() -> void:
	call_deferred("_apply_dressing")


func _apply_dressing() -> void:
	var map := get_parent()
	if map == null:
		return
	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	if ground == null or paths == null or objects == null or low == null:
		return

	_apply_terrain_tileset(ground, paths)
	_rework_village_route(paths)
	_add_plaza_landmark(paths)

	for index in range(TREE_CELLS.size()):
		var cell: Vector2i = TREE_CELLS[index]
		objects.erase_cell(cell)
		_add_sprite(
			objects,
			TREE_TEXTURE,
			objects.map_to_local(cell),
			TREE_PIVOT,
			"TreeVisual%02d" % index,
		)

	for index in range(DRY_GRASS_CELLS.size()):
		var cell: Vector2i = DRY_GRASS_CELLS[index]
		_add_sprite(
			low,
			DRY_GRASS_TEXTURE,
			low.map_to_local(cell),
			DRY_GRASS_PIVOT,
			"DryGrassVisual%02d" % index,
		)

	_dress_forest_resources(map)


func _apply_terrain_tileset(ground: TileMapLayer, paths: TileMapLayer) -> void:
	var terrain_tileset := CemeteryTerrainTileset.build()
	ground.tile_set = terrain_tileset
	paths.tile_set = terrain_tileset
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func _rework_village_route(paths: TileMapLayer) -> void:
	for y in range(3, 20):
		paths.erase_cell(Vector2i(24, y))
	for index in range(VILLAGE_ROUTE_REPLACED.size()):
		var cell: Vector2i = VILLAGE_ROUTE_REPLACED[index]
		var tile := Vector2i(index % 4, 1)
		paths.set_cell(cell, TERRAIN_SOURCE, tile)


func _add_plaza_landmark(paths: TileMapLayer) -> void:
	for index in range(PLAZA_CELLS.size()):
		paths.set_cell(PLAZA_CELLS[index], TERRAIN_SOURCE, PLAZA_TILES[index])


func _dress_forest_resources(map: Node) -> void:
	var resources := map.get_node_or_null("ForestResources") as Node2D
	if resources == null:
		return
	for child in resources.get_children():
		if child is not ResourceNode:
			continue
		var resource := child as ResourceNode
		if resource.get_node_or_null("ArtVisual") != null:
			continue
		var sprite := Sprite2D.new()
		sprite.name = "ArtVisual"
		sprite.texture = TREE_TEXTURE
		sprite.centered = false
		sprite.position = -TREE_PIVOT
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		resource.add_child(sprite)


func _add_sprite(
	parent: Node2D,
	texture: Texture2D,
	ground_position: Vector2,
	pivot: Vector2,
	sprite_name: String,
) -> void:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = ground_position - pivot
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
