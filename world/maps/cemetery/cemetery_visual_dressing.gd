class_name CemeteryVisualDressing
extends Node

const CemeteryTerrainTileset := preload("res://world/maps/cemetery/cemetery_terrain_tileset.gd")
const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const TERRAIN_SOURCE := 0
const GROUND_BASE := Vector2i(0, 0)
const GROUND_VARIANTS := [
	Vector2i(1, 0),
	Vector2i(3, 0),
	Vector2i(5, 0),
	Vector2i(6, 0),
	Vector2i(7, 0),
]
const PATH_VARIANTS := [
	Vector2i(0, 1),
	Vector2i(1, 1),
	Vector2i(2, 1),
	Vector2i(3, 1),
	Vector2i(4, 1),
	Vector2i(5, 1),
	Vector2i(6, 1),
	Vector2i(7, 1),
]
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
const PATH_EDGE_CELLS := [
	Vector2i(22, 17),
	Vector2i(23, 17),
	Vector2i(26, 17),
	Vector2i(21, 18),
	Vector2i(27, 18),
	Vector2i(21, 19),
	Vector2i(27, 19),
	Vector2i(22, 20),
	Vector2i(27, 20),
	Vector2i(23, 21),
	Vector2i(26, 21),
]
const PLAZA_CELLS := [
	Vector2i(23, 17),
	Vector2i(24, 17),
	Vector2i(25, 17),
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
	Vector2i(24, 21),
]
const GROUND_BREAKUP_PATCHES := {
	Vector2i(1, 0):
	[
		Vector2i(7, 6),
		Vector2i(11, 9),
		Vector2i(14, 6),
		Vector2i(17, 11),
		Vector2i(9, 16),
		Vector2i(13, 18),
		Vector2i(18, 15),
		Vector2i(20, 7),
	],
	Vector2i(3, 0):
	[
		Vector2i(6, 11),
		Vector2i(10, 14),
		Vector2i(15, 4),
		Vector2i(19, 13),
		Vector2i(28, 6),
		Vector2i(29, 9),
		Vector2i(27, 14),
		Vector2i(45, 10),
	],
	Vector2i(5, 0):
	[
		Vector2i(31, 4),
		Vector2i(34, 6),
		Vector2i(38, 4),
		Vector2i(41, 7),
		Vector2i(30, 12),
		Vector2i(43, 13),
		Vector2i(33, 18),
		Vector2i(42, 17),
	],
	Vector2i(6, 0):
	[
		Vector2i(8, 24),
		Vector2i(12, 26),
		Vector2i(17, 25),
		Vector2i(20, 23),
		Vector2i(28, 24),
		Vector2i(32, 26),
		Vector2i(38, 24),
		Vector2i(45, 27),
	],
	Vector2i(7, 0):
	[
		Vector2i(5, 19),
		Vector2i(11, 21),
		Vector2i(16, 19),
		Vector2i(19, 26),
		Vector2i(27, 21),
		Vector2i(35, 22),
		Vector2i(40, 25),
		Vector2i(47, 23),
	],
}
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
	Vector2i(21, 16),
	Vector2i(27, 16),
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
	Vector2i(21, 17),
	Vector2i(27, 17),
	Vector2i(22, 21),
	Vector2i(26, 22),
	Vector2i(28, 8),
	Vector2i(30, 10),
	Vector2i(31, 17),
	Vector2i(42, 18),
	Vector2i(44, 20),
	Vector2i(45, 25),
]


func _ready() -> void:
	var map := get_parent()
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
	_breakup_ground_masses(ground)
	_rework_village_route(paths)
	_add_plaza_landmark(paths)
	_add_path_edges(paths)

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
	var ground_cells := ground.get_used_cells()
	var path_cells := paths.get_used_cells()
	var terrain_tileset := CemeteryTerrainTileset.build()
	ground.tile_set = terrain_tileset
	paths.tile_set = terrain_tileset
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	for cell in ground_cells:
		ground.set_cell(cell, TERRAIN_SOURCE, _ground_tile_for_cell(cell))
	for cell in path_cells:
		paths.set_cell(cell, TERRAIN_SOURCE, _path_tile_for_cell(cell))


func _ground_tile_for_cell(cell: Vector2i) -> Vector2i:
	var macro := Vector2i(floori(float(cell.x) / 5.0), floori(float(cell.y) / 4.0))
	var value := abs((macro.x * 73856093) ^ (macro.y * 19349663))
	if value % 5 != 0:
		return GROUND_BASE
	return GROUND_VARIANTS[value % GROUND_VARIANTS.size()]


func _path_tile_for_cell(cell: Vector2i) -> Vector2i:
	var value := abs((cell.x * 83492791) ^ (cell.y * 2971215073))
	return PATH_VARIANTS[value % PATH_VARIANTS.size()]


func _breakup_ground_masses(ground: TileMapLayer) -> void:
	for tile: Vector2i in GROUND_BREAKUP_PATCHES:
		for center: Vector2i in GROUND_BREAKUP_PATCHES[tile]:
			_paint_ground_cluster(ground, center, tile)


func _paint_ground_cluster(ground: TileMapLayer, center: Vector2i, tile: Vector2i) -> void:
	var offsets := [
		Vector2i.ZERO,
		Vector2i.RIGHT,
		Vector2i.DOWN,
		Vector2i(-1, 0),
	]
	var selector := abs((center.x * 31) ^ (center.y * 17))
	if selector % 2 == 0:
		offsets.append(Vector2i(0, -1))
	if selector % 3 == 0:
		offsets.append(Vector2i(1, 1))
	for offset in offsets:
		var cell := center + offset
		if ground.get_cell_source_id(cell) != -1:
			ground.set_cell(cell, TERRAIN_SOURCE, tile)


func _rework_village_route(paths: TileMapLayer) -> void:
	for y in range(3, 20):
		paths.erase_cell(Vector2i(24, y))
	for index in range(VILLAGE_ROUTE_REPLACED.size()):
		var cell: Vector2i = VILLAGE_ROUTE_REPLACED[index]
		paths.set_cell(cell, TERRAIN_SOURCE, _path_tile_for_cell(cell))
		if index % 4 == 1:
			var shoulder := cell + Vector2i.RIGHT
			paths.set_cell(shoulder, TERRAIN_SOURCE, _path_tile_for_cell(shoulder))
		elif index % 4 == 3:
			var shoulder := cell + Vector2i.LEFT
			paths.set_cell(shoulder, TERRAIN_SOURCE, _path_tile_for_cell(shoulder))


func _add_plaza_landmark(paths: TileMapLayer) -> void:
	for index in range(PLAZA_CELLS.size()):
		var cell: Vector2i = PLAZA_CELLS[index]
		var tile := Vector2i(index % 8, 2)
		paths.set_cell(cell, TERRAIN_SOURCE, tile)


func _add_path_edges(paths: TileMapLayer) -> void:
	for index in range(PATH_EDGE_CELLS.size()):
		var cell: Vector2i = PATH_EDGE_CELLS[index]
		paths.set_cell(cell, TERRAIN_SOURCE, Vector2i(index % 8, 1))


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
