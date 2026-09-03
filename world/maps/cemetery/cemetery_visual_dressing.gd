class_name CemeteryVisualDressing
extends Node

const CemeteryTerrainTileset := preload("res://world/maps/cemetery/cemetery_terrain_tileset.gd")
const TREE_TEXTURE := preload("res://art/environment/props/tree.png")
const DRY_GRASS_TEXTURE := preload("res://art/environment/cemetery/dry_grass.png")
const LEGACY_ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const TERRAIN_SOURCE := 0
const TREE_PIVOT := Vector2(32, 84)
const DRY_GRASS_PIVOT := Vector2(16, 28)
const GRAVE_PIVOT := Vector2(16, 32)
const GROUND_BASE := Vector2i(0, 0)
const PATH_BASE := Vector2i(0, 1)
const PATH_BORDER_COLOR := Color8(68, 45, 29)
const PATH_FILL_COLOR := Color8(113, 72, 41)
const PATH_DETAIL_ALPHA := 0.58
const VILLAGE_ROUTE: Array[Vector2i] = [
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
const VILLAGE_ROUTE_TILES: Array[Vector2i] = [
	Vector2i(4, 1),
	Vector2i(5, 1),
	Vector2i(3, 1),
	Vector2i(2, 1),
	Vector2i(6, 1),
	Vector2i(4, 1),
	Vector2i(1, 1),
	Vector2i(7, 1),
	Vector2i(5, 1),
	Vector2i(3, 1),
	Vector2i(6, 1),
	Vector2i(2, 1),
	Vector2i(7, 1),
	Vector2i(4, 1),
	Vector2i(1, 1),
	Vector2i(5, 1),
	Vector2i(3, 1),
]
const ROUTE_SHOULDERS: Array[Vector2i] = [
	Vector2i(23, 18),
	Vector2i(26, 16),
	Vector2i(23, 14),
	Vector2i(22, 12),
	Vector2i(25, 11),
	Vector2i(26, 9),
	Vector2i(23, 8),
	Vector2i(22, 6),
	Vector2i(25, 5),
]
const ROUTE_SHOULDER_TILES: Array[Vector2i] = [
	Vector2i(7, 1),
	Vector2i(6, 1),
	Vector2i(2, 1),
	Vector2i(5, 1),
	Vector2i(1, 1),
	Vector2i(7, 1),
	Vector2i(3, 1),
	Vector2i(6, 1),
	Vector2i(2, 1),
]
const PLAZA_CELLS: Array[Vector2i] = [
	Vector2i(23, 17),
	Vector2i(25, 17),
	Vector2i(22, 18),
	Vector2i(24, 18),
	Vector2i(26, 18),
	Vector2i(21, 19),
	Vector2i(23, 19),
	Vector2i(25, 19),
	Vector2i(27, 19),
	Vector2i(22, 20),
	Vector2i(24, 20),
	Vector2i(26, 20),
	Vector2i(23, 21),
	Vector2i(25, 21),
]
const PLAZA_TILES: Array[Vector2i] = [
	Vector2i(1, 2),
	Vector2i(6, 2),
	Vector2i(2, 2),
	Vector2i(7, 2),
	Vector2i(4, 2),
	Vector2i(6, 2),
	Vector2i(0, 2),
	Vector2i(2, 2),
	Vector2i(4, 2),
	Vector2i(1, 2),
	Vector2i(7, 2),
	Vector2i(2, 2),
	Vector2i(5, 2),
	Vector2i(4, 2),
]
const MAIN_PATH_POINTS: Array[Vector2] = [
	Vector2(360, 760),
	Vector2(470, 742),
	Vector2(565, 708),
	Vector2(650, 670),
	Vector2(735, 635),
	Vector2(820, 612),
	Vector2(910, 606),
	Vector2(1000, 620),
	Vector2(1090, 655),
	Vector2(1190, 694),
	Vector2(1320, 710),
	Vector2(1490, 702),
]
const VILLAGE_PATH_POINTS: Array[Vector2] = [
	Vector2(780, 625),
	Vector2(758, 565),
	Vector2(782, 505),
	Vector2(748, 444),
	Vector2(772, 382),
	Vector2(748, 315),
	Vector2(778, 246),
	Vector2(768, 112),
]
const CEMETERY_PATH_POINTS: Array[Vector2] = [
	Vector2(985, 616),
	Vector2(994, 535),
	Vector2(1042, 462),
	Vector2(1125, 405),
	Vector2(1220, 383),
	Vector2(1310, 410),
	Vector2(1374, 470),
	Vector2(1390, 548),
	Vector2(1350, 615),
	Vector2(1260, 655),
	Vector2(1160, 666),
	Vector2(1060, 642),
	Vector2(985, 616),
]
const GRAVE_CELLS: Array[Vector2i] = [
	Vector2i(33, 7),
	Vector2i(36, 6),
	Vector2i(39, 7),
	Vector2i(32, 10),
	Vector2i(35, 10),
	Vector2i(38, 11),
	Vector2i(41, 10),
	Vector2i(34, 13),
	Vector2i(37, 14),
	Vector2i(40, 13),
	Vector2i(34, 16),
	Vector2i(37, 17),
	Vector2i(40, 16),
]
const GRAVE_TILES: Array[Vector2i] = [
	Vector2i(0, 3),
	Vector2i(2, 3),
	Vector2i(1, 3),
	Vector2i(3, 3),
	Vector2i(0, 3),
	Vector2i(3, 3),
	Vector2i(1, 3),
	Vector2i(2, 3),
	Vector2i(3, 3),
	Vector2i(0, 3),
	Vector2i(2, 3),
	Vector2i(1, 3),
	Vector2i(3, 3),
]
const GRAVE_OFFSETS: Array[Vector2] = [
	Vector2(-7, 4),
	Vector2(6, -5),
	Vector2(10, 3),
	Vector2(-5, -6),
	Vector2(8, 5),
	Vector2(-9, 1),
	Vector2(4, -7),
	Vector2(11, 6),
	Vector2(-6, 3),
	Vector2(7, -4),
	Vector2(-10, 7),
	Vector2(5, -6),
	Vector2(9, 2),
]
const TREE_CELLS: Array[Vector2i] = [
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
const TREE_OFFSETS: Array[Vector2] = [
	Vector2(-7, 3),
	Vector2(9, -5),
	Vector2(4, 7),
	Vector2(-10, -3),
	Vector2(6, 5),
	Vector2(-5, -8),
	Vector2(11, 2),
	Vector2(-8, 6),
	Vector2(5, -4),
	Vector2(-11, 1),
	Vector2(7, 8),
	Vector2(-3, -6),
	Vector2(10, 4),
	Vector2(-6, -5),
	Vector2(8, 3),
	Vector2(-9, 7),
	Vector2(5, -7),
	Vector2(-4, 4),
]
const DRY_GRASS_CELLS: Array[Vector2i] = [
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
const DRY_GRASS_OFFSETS: Array[Vector2] = [
	Vector2(-8, 5),
	Vector2(6, -4),
	Vector2(11, 7),
	Vector2(-5, -7),
	Vector2(8, 2),
	Vector2(-10, 6),
	Vector2(4, -6),
	Vector2(9, 5),
	Vector2(-7, -3),
	Vector2(5, 8),
	Vector2(-9, 1),
	Vector2(10, -5),
	Vector2(-4, 7),
	Vector2(7, -8),
	Vector2(-11, 4),
	Vector2(6, 6),
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
	_add_organic_path_underlay(map)
	_rework_village_route(paths)
	_add_plaza_landmark(paths)
	_dress_static_props(objects, low)
	_dress_graves(objects)
	_dress_forest_resources(map)


func _apply_terrain_tileset(ground: TileMapLayer, paths: TileMapLayer) -> void:
	var ground_cells: Array[Vector2i] = ground.get_used_cells()
	var path_cells: Array[Vector2i] = paths.get_used_cells()
	var ground_coords := _capture_atlas_coords(ground, ground_cells)
	var path_coords := _capture_atlas_coords(paths, path_cells)
	var terrain_tileset: TileSet = CemeteryTerrainTileset.build()
	ground.tile_set = terrain_tileset
	paths.tile_set = terrain_tileset
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	paths.modulate.a = PATH_DETAIL_ALPHA

	for cell: Vector2i in ground_cells:
		ground.set_cell(cell, TERRAIN_SOURCE, _ground_coord(ground_coords.get(cell, GROUND_BASE)))
	for cell: Vector2i in path_cells:
		paths.set_cell(cell, TERRAIN_SOURCE, _path_coord(path_coords.get(cell, PATH_BASE)))


func _capture_atlas_coords(layer: TileMapLayer, cells: Array[Vector2i]) -> Dictionary:
	var coords := {}
	for cell: Vector2i in cells:
		coords[cell] = layer.get_cell_atlas_coords(cell)
	return coords


func _ground_coord(raw_coord: Variant) -> Vector2i:
	var coord := raw_coord as Vector2i
	return Vector2i(clampi(coord.x, 0, 7), 0)


func _path_coord(raw_coord: Variant) -> Vector2i:
	var coord := raw_coord as Vector2i
	return Vector2i(clampi(coord.x, 0, 7), 1)


func _add_organic_path_underlay(map: Node) -> void:
	if map.get_node_or_null("OrganicPathUnderlay") != null:
		return
	var underlay := Node2D.new()
	underlay.name = "OrganicPathUnderlay"
	underlay.z_index = -10
	map.add_child(underlay)
	_add_route_lines(underlay, "Main", MAIN_PATH_POINTS, 86.0, 58.0)
	_add_route_lines(underlay, "Village", VILLAGE_PATH_POINTS, 76.0, 50.0)
	_add_route_lines(underlay, "Cemetery", CEMETERY_PATH_POINTS, 80.0, 52.0)


func _add_route_lines(
	parent: Node2D,
	route_name: String,
	points: Array[Vector2],
	border_width: float,
	fill_width: float,
) -> void:
	var packed_points := PackedVector2Array(points)
	var border := Line2D.new()
	border.name = "%sBorder" % route_name
	border.points = packed_points
	border.width = border_width
	border.default_color = PATH_BORDER_COLOR
	border.antialiased = false
	parent.add_child(border)

	var fill := Line2D.new()
	fill.name = "%sFill" % route_name
	fill.points = packed_points
	fill.width = fill_width
	fill.default_color = PATH_FILL_COLOR
	fill.antialiased = false
	parent.add_child(fill)


func _rework_village_route(paths: TileMapLayer) -> void:
	for y: int in range(3, 20):
		paths.erase_cell(Vector2i(24, y))
	for index: int in range(VILLAGE_ROUTE.size()):
		paths.set_cell(VILLAGE_ROUTE[index], TERRAIN_SOURCE, VILLAGE_ROUTE_TILES[index])
	for index: int in range(ROUTE_SHOULDERS.size()):
		paths.set_cell(ROUTE_SHOULDERS[index], TERRAIN_SOURCE, ROUTE_SHOULDER_TILES[index])


func _add_plaza_landmark(paths: TileMapLayer) -> void:
	for cell: Vector2i in paths.get_used_cells():
		if paths.get_cell_atlas_coords(cell).y == 2:
			paths.erase_cell(cell)
	for index: int in range(PLAZA_CELLS.size()):
		paths.set_cell(PLAZA_CELLS[index], TERRAIN_SOURCE, PLAZA_TILES[index])


func _dress_static_props(objects: TileMapLayer, low: TileMapLayer) -> void:
	for index: int in range(TREE_CELLS.size()):
		var cell := TREE_CELLS[index]
		objects.erase_cell(cell)
		_add_sprite(
			objects,
			TREE_TEXTURE,
			objects.map_to_local(cell) + TREE_OFFSETS[index],
			TREE_PIVOT,
			"TreeVisual%02d" % index,
		)

	for index: int in range(DRY_GRASS_CELLS.size()):
		var cell := DRY_GRASS_CELLS[index]
		_add_sprite(
			low,
			DRY_GRASS_TEXTURE,
			low.map_to_local(cell) + DRY_GRASS_OFFSETS[index],
			DRY_GRASS_PIVOT,
			"DryGrassVisual%02d" % index,
		)


func _dress_graves(objects: TileMapLayer) -> void:
	for index: int in range(GRAVE_CELLS.size()):
		var cell := GRAVE_CELLS[index]
		objects.erase_cell(cell)
		_add_atlas_sprite(
			objects,
			GRAVE_TILES[index],
			objects.map_to_local(cell) + GRAVE_OFFSETS[index],
			"GraveVisual%02d" % index,
		)


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


func _add_atlas_sprite(
	parent: Node2D,
	atlas_cell: Vector2i,
	ground_position: Vector2,
	sprite_name: String,
) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = LEGACY_ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))
	_add_sprite(parent, texture, ground_position, GRAVE_PIVOT, sprite_name)


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
