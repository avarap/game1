class_name CemeteryMap
extends TechnicalMap

const ART_SOURCE := 0
const DECORATION_SEED := 9022026
const WORKSHOP_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/building_workshop_exterior.png"
)
const ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const MAIN_SPINE := [
	Vector2i(13, 25),
	Vector2i(16, 24),
	Vector2i(20, 22),
	Vector2i(24, 20),
	Vector2i(28, 18),
	Vector2i(32, 18),
	Vector2i(36, 16),
	Vector2i(39, 16),
]
const VILLAGE_ROUTE := [
	Vector2i(25, 19),
	Vector2i(25, 15),
	Vector2i(25, 11),
	Vector2i(24, 7),
	Vector2i(25, 3),
	Vector2i(25, 1),
]
const FOREST_ROUTE := [
	Vector2i(32, 18),
	Vector2i(36, 19),
	Vector2i(40, 20),
	Vector2i(44, 21),
	Vector2i(48, 22),
]
const CEMETERY_ROUTE := [
	Vector2i(28, 18),
	Vector2i(31, 16),
	Vector2i(34, 14),
	Vector2i(37, 13),
]
const OLD_CEMETERY_ROUTE := [
	Vector2i(20, 22),
	Vector2i(17, 20),
	Vector2i(15, 17),
	Vector2i(14, 14),
	Vector2i(17, 12),
	Vector2i(20, 13),
	Vector2i(22, 16),
]
const FUTURE_ROUTE := [
	Vector2i(37, 13),
	Vector2i(41, 13),
	Vector2i(44, 10),
	Vector2i(44, 6),
	Vector2i(43, 5),
]
const OLD_GRAVES := [
	Vector2i(6, 7),
	Vector2i(9, 6),
	Vector2i(12, 8),
	Vector2i(15, 7),
	Vector2i(7, 11),
	Vector2i(10, 10),
	Vector2i(14, 12),
	Vector2i(17, 10),
	Vector2i(5, 14),
	Vector2i(9, 15),
	Vector2i(13, 14),
	Vector2i(17, 15),
]
const ACTIVE_GRAVES := [
	Vector2i(34, 8),
	Vector2i(37, 8),
	Vector2i(40, 9),
	Vector2i(43, 8),
	Vector2i(33, 11),
	Vector2i(36, 11),
	Vector2i(40, 12),
	Vector2i(44, 11),
	Vector2i(35, 14),
	Vector2i(39, 14),
	Vector2i(43, 14),
]
const TREE_CELLS := [
	Vector2i(4, 5),
	Vector2i(8, 4),
	Vector2i(14, 4),
	Vector2i(19, 6),
	Vector2i(4, 10),
	Vector2i(5, 8),
	Vector2i(18, 12),
	Vector2i(4, 18),
	Vector2i(17, 27),
	Vector2i(22, 28),
	Vector2i(31, 27),
	Vector2i(39, 27),
	Vector2i(45, 26),
	Vector2i(46, 15),
	Vector2i(40, 10),
]
const PROP_CELLS := [
	Vector2i(6, 5),
	Vector2i(11, 5),
	Vector2i(16, 5),
	Vector2i(6, 13),
	Vector2i(11, 16),
	Vector2i(19, 14),
	Vector2i(31, 7),
	Vector2i(46, 8),
	Vector2i(31, 13),
	Vector2i(46, 13),
	Vector2i(20, 27),
	Vector2i(26, 26),
	Vector2i(34, 25),
	Vector2i(42, 25),
]
const PROTECTED_CENTERS := [
	Vector2i(9, 24),
	Vector2i(15, 24),
	Vector2i(11, 26),
	Vector2i(29, 19),
	Vector2i(32, 19),
	Vector2i(36, 17),
	Vector2i(39, 17),
	Vector2i(13, 25),
	Vector2i(25, 17),
	Vector2i(48, 22),
	Vector2i(25, 2),
	Vector2i(43, 5),
]
const DECORATION_CLUSTERS := [
	Vector2i(5, 6),
	Vector2i(11, 9),
	Vector2i(17, 7),
	Vector2i(7, 16),
	Vector2i(18, 17),
	Vector2i(21, 26),
	Vector2i(31, 7),
	Vector2i(40, 7),
	Vector2i(45, 15),
	Vector2i(39, 26),
]

var _reserved_cells: Dictionary = {}
var _protected_cells: Dictionary = {}
var _obstacle_cells: Dictionary = {}


func _ready() -> void:
	_configure_layers(CemeteryArtTileset.build())
	_mark_protected_cells()
	_build_ground()
	_build_paths()
	_build_authored_objects()
	_build_low_decoration()
	_populate_collision()
	_rebuild_navigation()
	_hide_placeholders(self)
	_add_workshop_art()


func _mark_protected_cells() -> void:
	for center in PROTECTED_CENTERS:
		for offset_y in range(-1, 2):
			for offset_x in range(-1, 2):
				var cell: Vector2i = center + Vector2i(offset_x, offset_y)
				if _is_inside_map(cell):
					_protected_cells[cell] = true


func _build_ground() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var cell := Vector2i(x, y)
			var variant := _ground_variant(cell)
			ground.set_cell(cell, ART_SOURCE, Vector2i(variant, 0))


func _ground_variant(cell: Vector2i) -> int:
	if cell.x <= 21 and cell.y <= 18:
		return (cell.x + cell.y * 2) % 3
	if cell.x >= 30 and cell.y <= 17:
		return 4 + (cell.x + cell.y) % 3
	if cell.x <= 20 and cell.y >= 18:
		return 2 + (cell.x * 2 + cell.y) % 3
	return (cell.x * 3 + cell.y * 5) % 8


func _build_paths() -> void:
	for route in [
		MAIN_SPINE,
		VILLAGE_ROUTE,
		FOREST_ROUTE,
		CEMETERY_ROUTE,
		OLD_CEMETERY_ROUTE,
		FUTURE_ROUTE,
	]:
		_paint_path_polyline(route, 1)

	for y in range(23, 28):
		for x in range(9, 17):
			_set_path_cell(Vector2i(x, y))

	for y in range(17, 21):
		for x in range(27, 34):
			_set_path_cell(Vector2i(x, y))

	for y in range(16, 19):
		for x in range(34, 41):
			_set_path_cell(Vector2i(x, y))


func _paint_path_polyline(points: Array, radius: int) -> void:
	for index in range(points.size() - 1):
		_paint_path_segment(points[index], points[index + 1], radius)


func _paint_path_segment(from_cell: Vector2i, to_cell: Vector2i, radius: int) -> void:
	var delta := to_cell - from_cell
	var steps := maxi(absi(delta.x), absi(delta.y))
	for step in range(steps + 1):
		var ratio := 0.0 if steps == 0 else float(step) / float(steps)
		var center := Vector2i(
			roundi(lerpf(float(from_cell.x), float(to_cell.x), ratio)),
			roundi(lerpf(float(from_cell.y), float(to_cell.y), ratio)),
		)
		for offset_y in range(-radius, radius + 1):
			for offset_x in range(-radius, radius + 1):
				_set_path_cell(center + Vector2i(offset_x, offset_y))


func _set_path_cell(cell: Vector2i) -> void:
	if not _is_inside_map(cell):
		return
	var variant := 4 + (cell.x * 3 + cell.y) % 4
	paths.set_cell(cell, ART_SOURCE, Vector2i(variant, 1))
	_reserved_cells[cell] = true


func _build_authored_objects() -> void:
	for index in range(OLD_GRAVES.size()):
		_place_object(OLD_GRAVES[index], Vector2i(index % 4, 3), true)

	for index in range(ACTIVE_GRAVES.size()):
		var atlas_cell := Vector2i((index + 1) % 4, 3)
		_place_object(ACTIVE_GRAVES[index], atlas_cell, true)

	for index in range(TREE_CELLS.size()):
		var cell: Vector2i = TREE_CELLS[index]
		if not _place_object(cell, Vector2i(7, 3), true):
			continue
		var canopy_cell := cell + Vector2i(0, -1)
		if _can_place_scenery(canopy_cell):
			var canopy_variant := (cell.x + cell.y + index) % 8
			foreground_occlusion.set_cell(
				canopy_cell,
				ART_SOURCE,
				Vector2i(canopy_variant, 6),
			)

	for index in range(PROP_CELLS.size()):
		var atlas_cell := Vector2i(3 + index % 5, 4)
		_place_object(PROP_CELLS[index], atlas_cell, index % 2 == 0)


func _place_object(cell: Vector2i, atlas_cell: Vector2i, blocks_movement: bool) -> bool:
	if not _can_place_scenery(cell):
		return false
	objects_y_sorted.set_cell(cell, ART_SOURCE, atlas_cell)
	if blocks_movement:
		_obstacle_cells[cell] = true
	return true


func _build_low_decoration() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = DECORATION_SEED
	for center in DECORATION_CLUSTERS:
		for _attempt in range(28):
			var offset := Vector2i(
				rng.randi_range(-4, 4),
				rng.randi_range(-3, 3),
			)
			var cell: Vector2i = center + offset
			if not _can_place_low_decoration(cell):
				continue
			var atlas_cell := Vector2i(rng.randi_range(0, 7), 2)
			decoration_low.set_cell(cell, ART_SOURCE, atlas_cell)

	_fill_decoration_minimum()


func _fill_decoration_minimum() -> void:
	if decoration_low.get_used_cells().size() >= 96:
		return
	for y in range(3, 30, 2):
		for x in range(3, 48, 3):
			if decoration_low.get_used_cells().size() >= 96:
				return
			var cell := Vector2i(x, y)
			if not _can_place_low_decoration(cell):
				continue
			decoration_low.set_cell(
				cell,
				ART_SOURCE,
				Vector2i((x + y * 2) % 8, 2),
			)


func _can_place_scenery(cell: Vector2i) -> bool:
	return (
		_is_inside_map(cell)
		and not _reserved_cells.has(cell)
		and not _protected_cells.has(cell)
	)


func _can_place_low_decoration(cell: Vector2i) -> bool:
	return (
		_can_place_scenery(cell)
		and not _obstacle_cells.has(cell)
		and objects_y_sorted.get_cell_source_id(cell) == -1
	)


func _populate_collision() -> void:
	collision.clear()

	for x in range(MAP_SIZE_TILES.x):
		if x < 24 or x > 26:
			_set_collision_raw(Vector2i(x, 0))
		_set_collision_raw(Vector2i(x, MAP_SIZE_TILES.y - 1))

	for y in range(1, MAP_SIZE_TILES.y - 1):
		_set_collision_raw(Vector2i(0, y))
		if y < 21 or y > 23:
			_set_collision_raw(Vector2i(MAP_SIZE_TILES.x - 1, y))

	for y in range(18, 22):
		for x in range(6, 16):
			if y == 21 and x in [10, 11, 12]:
				continue
			_set_collision_if_free(Vector2i(x, y))

	for raw_cell in _obstacle_cells:
		_set_collision_if_free(Vector2i(raw_cell))


func _set_collision_if_free(cell: Vector2i) -> void:
	if _reserved_cells.has(cell) or _protected_cells.has(cell):
		return
	_set_collision_raw(cell)


func _set_collision_raw(cell: Vector2i) -> void:
	if _is_inside_map(cell):
		collision.set_cell(cell, ART_SOURCE, CemeteryArtTileset.COLLISION_TILE)


func _rebuild_navigation() -> void:
	var region := get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		return

	var polygon := NavigationPolygon.new()
	var vertices := PackedVector2Array()
	for y in range(MAP_SIZE_TILES.y + 1):
		for x in range(MAP_SIZE_TILES.x + 1):
			vertices.append(Vector2(x * TILE_SIZE.x, y * TILE_SIZE.y))
	polygon.vertices = vertices

	var stride := MAP_SIZE_TILES.x + 1
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var cell := Vector2i(x, y)
			if collision.get_cell_source_id(cell) != -1:
				continue
			var top_left := y * stride + x
			var top_right := top_left + 1
			var bottom_left := (y + 1) * stride + x
			var bottom_right := bottom_left + 1
			polygon.add_polygon(
				PackedInt32Array(
					[top_left, top_right, bottom_right, bottom_left],
				)
			)
	region.navigation_polygon = polygon


func _is_inside_map(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.y >= 0
		and cell.x < MAP_SIZE_TILES.x
		and cell.y < MAP_SIZE_TILES.y
	)


func _hide_placeholders(node: Node) -> void:
	for child in node.get_children():
		if child is Polygon2D:
			(child as Polygon2D).visible = false
		elif child is Label and child.name == "FeedbackLabel":
			(child as Label).visible = false
		_hide_placeholders(child)


func _add_workshop_art() -> void:
	var anchor := get_node("WorkshopArea/BuildingVisualAnchor") as Node2D
	var sprite := Sprite2D.new()
	sprite.name = "ArtVisual"
	sprite.texture = WORKSHOP_TEXTURE
	sprite.centered = false
	sprite.position = Vector2(-160, -240)
	anchor.add_child(sprite)

	var smoke := ChimneySmokeEffect.new()
	smoke.name = "ChimneySmokeEffect"
	smoke.position = Vector2(85, -220)
	anchor.add_child(smoke)

	for entry in [
		["WorkshopArea/Workbench", Vector2i(6, 3)],
		["WorkshopArea/StorageChest", Vector2i(5, 3)],
		["WorkshopArea/SleepSpot", Vector2i(3, 3)],
		["CemeteryArea/CorpseDelivery", Vector2i(6, 3)],
		["CemeteryArea/PreparationTable", Vector2i(5, 3)],
		["CemeteryArea/GravePlot", Vector2i(0, 3)],
		["CemeteryArea/GraveUpgrade", Vector2i(2, 3)],
	]:
		_add_atlas_sprite(str(entry[0]), entry[1])


func _add_atlas_sprite(node_path: String, atlas_cell: Vector2i) -> void:
	var target := get_node(node_path) as Node2D
	var texture := AtlasTexture.new()
	texture.atlas = ATLAS_TEXTURE
	texture.region = Rect2(atlas_cell * 32, Vector2i(32, 32))

	var sprite := Sprite2D.new()
	sprite.name = "ArtVisual"
	sprite.texture = texture
	sprite.centered = false
	sprite.position = Vector2(-16, -32)
	target.add_child(sprite)
