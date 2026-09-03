class_name CemeteryVisualDressing
extends Node

const CemeteryTerrainTileset := preload("res://world/maps/cemetery/cemetery_terrain_tileset.gd")
const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")

const TERRAIN_SOURCE := 0
const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const GROUND_BASE := Vector2i(0, 0)
const GROUND_VARIANTS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(2, 0),
	Vector2i(3, 0),
	Vector2i(4, 0),
	Vector2i(5, 0),
	Vector2i(6, 0),
	Vector2i(7, 0),
]
const PATH_VARIANTS: Array[Vector2i] = [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
	Vector2i(4, 1),
	Vector2i(5, 1),
	Vector2i(6, 1),
	Vector2i(7, 1),
]
const VILLAGE_ROUTE: Array[Vector2i] = [
	Vector2i(24, 19), Vector2i(24, 18), Vector2i(25, 17), Vector2i(25, 16),
	Vector2i(24, 15), Vector2i(24, 14), Vector2i(23, 13), Vector2i(23, 12),
	Vector2i(24, 11), Vector2i(25, 10), Vector2i(25, 9), Vector2i(24, 8),
	Vector2i(23, 7), Vector2i(23, 6), Vector2i(24, 5), Vector2i(25, 4),
	Vector2i(24, 3),
]
const ROUTE_SHOULDERS: Array[Vector2i] = [
	Vector2i(23, 18), Vector2i(26, 16), Vector2i(23, 14), Vector2i(22, 12),
	Vector2i(25, 11), Vector2i(26, 9), Vector2i(23, 8), Vector2i(22, 6),
	Vector2i(25, 5),
]
const PLAZA_CELLS: Array[Vector2i] = [
	Vector2i(23, 17), Vector2i(24, 17), Vector2i(25, 17),
	Vector2i(22, 18), Vector2i(23, 18), Vector2i(24, 18), Vector2i(25, 18), Vector2i(26, 18),
	Vector2i(22, 19), Vector2i(23, 19), Vector2i(24, 19), Vector2i(25, 19), Vector2i(26, 19),
	Vector2i(23, 20), Vector2i(24, 20), Vector2i(25, 20), Vector2i(24, 21),
]
const TREE_CELLS: Array[Vector2i] = [
	Vector2i(5, 5), Vector2i(8, 7), Vector2i(12, 5), Vector2i(15, 8),
	Vector2i(5, 13), Vector2i(8, 17), Vector2i(12, 15), Vector2i(16, 12),
	Vector2i(5, 24), Vector2i(8, 27), Vector2i(12, 28), Vector2i(17, 27),
	Vector2i(21, 16), Vector2i(27, 16), Vector2i(43, 5), Vector2i(46, 8),
	Vector2i(45, 14), Vector2i(46, 27),
]
const DRY_GRASS_CELLS: Array[Vector2i] = [
	Vector2i(6, 20), Vector2i(8, 21), Vector2i(10, 20), Vector2i(13, 20),
	Vector2i(16, 21), Vector2i(18, 23), Vector2i(21, 17), Vector2i(27, 17),
	Vector2i(22, 21), Vector2i(26, 22), Vector2i(28, 8), Vector2i(30, 10),
	Vector2i(31, 17), Vector2i(42, 18), Vector2i(44, 20), Vector2i(45, 25),
]


func _ready() -> void:
	var map: Node = get_parent()
	if map == null:
		return
	map.ready.connect(_apply_dressing.bind(map), CONNECT_ONE_SHOT)


func _apply_dressing(map: Node) -> void:
	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var low := map.get_node_or_null("decoration_low") as TileMapLayer
	if ground == null or paths == null or objects == null or low == null:
		return
	_apply_terrain_tileset(ground, paths)
	_rework_village_route(paths)
	_add_plaza_landmark(paths)
	_dress_static_props(objects, low)
	_dress_forest_resources(map)


func _apply_terrain_tileset(ground: TileMapLayer, paths: TileMapLayer) -> void:
	var ground_cells: Array[Vector2i] = ground.get_used_cells()
	var path_cells: Array[Vector2i] = paths.get_used_cells()
	var terrain_tileset: TileSet = CemeteryTerrainTileset.build()
	ground.tile_set = terrain_tileset
	paths.tile_set = terrain_tileset
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for cell: Vector2i in ground_cells:
		ground.set_cell(cell, TERRAIN_SOURCE, _ground_tile_for_cell(cell))
	for cell: Vector2i in path_cells:
		paths.set_cell(cell, TERRAIN_SOURCE, _path_tile_for_cell(cell))


func _ground_tile_for_cell(cell: Vector2i) -> Vector2i:
	var value: int = abs((cell.x * 73856093) ^ (cell.y * 19349663))
	if value % 10 < 3:
		return GROUND_BASE
	var variant_index: int = value % GROUND_VARIANTS.size()
	return GROUND_VARIANTS[variant_index]


func _path_tile_for_cell(cell: Vector2i) -> Vector2i:
	var value: int = abs((cell.x * 83492791) ^ (cell.y * 2971215073))
	var variant_index: int = value % PATH_VARIANTS.size()
	return PATH_VARIANTS[variant_index]


func _rework_village_route(paths: TileMapLayer) -> void:
	for y: int in range(3, 20):
		paths.erase_cell(Vector2i(24, y))
	for cell: Vector2i in VILLAGE_ROUTE:
		paths.set_cell(cell, TERRAIN_SOURCE, _path_tile_for_cell(cell))
	for cell: Vector2i in ROUTE_SHOULDERS:
		paths.set_cell(cell, TERRAIN_SOURCE, _path_tile_for_cell(cell))


func _add_plaza_landmark(paths: TileMapLayer) -> void:
	var index := 0
	for cell: Vector2i in PLAZA_CELLS:
		paths.set_cell(cell, TERRAIN_SOURCE, Vector2i(index % 8, 2))
		index += 1


func _dress_static_props(objects: TileMapLayer, low: TileMapLayer) -> void:
	var index := 0
	for cell: Vector2i in TREE_CELLS:
		objects.erase_cell(cell)
		_add_sprite(objects, TREE_TEXTURE, objects.map_to_local(cell), TREE_PIVOT, "TreeVisual%02d" % index)
		index += 1
	index = 0
	for cell: Vector2i in DRY_GRASS_CELLS:
		_add_sprite(low, DRY_GRASS_TEXTURE, low.map_to_local(cell), DRY_GRASS_PIVOT, "DryGrassVisual%02d" % index)
		index += 1


func _dress_forest_resources(map: Node) -> void:
	var resources := map.get_node_or_null("ForestResources") as Node2D
	if resources == null:
		return
	for child: Node in resources.get_children():
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


func _add_sprite(parent: Node2D, texture: Texture2D, ground_position: Vector2, pivot: Vector2, sprite_name: String) -> void:
	var sprite := Sprite2D.new()
	sprite.name = sprite_name
	sprite.texture = texture
	sprite.centered = false
	sprite.position = ground_position - pivot
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
