class_name CemeteryMap
extends TechnicalMap

const ART_SOURCE := 0
const WORKSHOP_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/building_workshop_exterior.png"
)
const ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const MAIN_PATH_TILE := Vector2i(4, 1)
const SIDE_PATH_TILE := Vector2i(1, 1)
const WORN_PATH_TILE := Vector2i(6, 1)
const COLLISION_CELL := Vector2i(7, 7)

const MAIN_ROUTE := [
	Vector2i(13, 23), Vector2i(14, 23), Vector2i(15, 23), Vector2i(16, 23),
	Vector2i(17, 22), Vector2i(18, 22), Vector2i(19, 22), Vector2i(20, 21),
	Vector2i(21, 21), Vector2i(22, 20), Vector2i(23, 20), Vector2i(24, 19),
	Vector2i(25, 19), Vector2i(26, 18), Vector2i(27, 18), Vector2i(28, 17),
	Vector2i(29, 17), Vector2i(30, 16), Vector2i(31, 16), Vector2i(32, 15),
	Vector2i(33, 15), Vector2i(34, 15), Vector2i(35, 16), Vector2i(36, 17),
	Vector2i(37, 18), Vector2i(38, 19), Vector2i(39, 20), Vector2i(40, 21),
	Vector2i(41, 22), Vector2i(42, 22), Vector2i(43, 22), Vector2i(44, 22),
	Vector2i(45, 22), Vector2i(46, 22),
]

const VILLAGE_ROUTE := [
	Vector2i(24, 19), Vector2i(24, 18), Vector2i(24, 17), Vector2i(24, 16),
	Vector2i(24, 15), Vector2i(24, 14), Vector2i(24, 13), Vector2i(24, 12),
	Vector2i(24, 11), Vector2i(24, 10), Vector2i(24, 9), Vector2i(24, 8),
	Vector2i(24, 7), Vector2i(24, 6), Vector2i(24, 5), Vector2i(24, 4),
	Vector2i(24, 3),
]

const CEMETERY_LOOP := [
	Vector2i(31, 16), Vector2i(31, 15), Vector2i(31, 14), Vector2i(31, 13),
	Vector2i(32, 12), Vector2i(33, 11), Vector2i(34, 10), Vector2i(35, 9),
	Vector2i(36, 8), Vector2i(37, 8), Vector2i(38, 9), Vector2i(39, 10),
	Vector2i(40, 11), Vector2i(41, 12), Vector2i(42, 13), Vector2i(42, 14),
	Vector2i(42, 15), Vector2i(41, 16), Vector2i(40, 17), Vector2i(39, 18),
]

const GRAVE_CELLS := [
	Vector2i(33, 7), Vector2i(36, 6), Vector2i(39, 7),
	Vector2i(32, 10), Vector2i(35, 10), Vector2i(38, 11), Vector2i(41, 10),
	Vector2i(34, 13), Vector2i(37, 14), Vector2i(40, 13),
	Vector2i(34, 16), Vector2i(37, 17), Vector2i(40, 16),
]

const TREE_CELLS := [
	Vector2i(5, 5), Vector2i(8, 7), Vector2i(12, 5), Vector2i(15, 8),
	Vector2i(5, 13), Vector2i(8, 17), Vector2i(12, 15), Vector2i(16, 12),
	Vector2i(5, 24), Vector2i(8, 27), Vector2i(12, 28), Vector2i(17, 27),
	Vector2i(43, 5), Vector2i(46, 8), Vector2i(45, 14), Vector2i(46, 27),
]

const LOW_DECOR_CELLS := [
	Vector2i(10, 10), Vector2i(13, 11), Vector2i(17, 9), Vector2i(20, 12),
	Vector2i(7, 20), Vector2i(10, 21), Vector2i(17, 19), Vector2i(20, 24),
	Vector2i(28, 7), Vector2i(29, 11), Vector2i(30, 14), Vector2i(44, 10),
	Vector2i(44, 17), Vector2i(27, 25), Vector2i(31, 27), Vector2i(37, 26),
]


func _ready() -> void:
	_configure_layers(CemeteryArtTileset.build())
	_populate_authored_ground()
	_populate_authored_paths()
	_populate_authored_decor()
	_populate_authored_objects()
	_populate_authored_collision()
	_hide_placeholders(self)
	_add_workshop_art()


func _populate_authored_ground() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var variant := 0
			if x < 20:
				variant = (x + y * 2) % 3
			elif y < 18:
				variant = 3 + ((x + y) % 3)
			else:
				variant = 6 + ((x * 2 + y) % 2)
			ground.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(variant, 0))


func _populate_authored_paths() -> void:
	_paint_route(MAIN_ROUTE, MAIN_PATH_TILE, true)
	_paint_route(VILLAGE_ROUTE, SIDE_PATH_TILE, false)
	_paint_route(CEMETERY_LOOP, SIDE_PATH_TILE, true)
	_paint_patch(Rect2i(9, 21, 9, 5), WORN_PATH_TILE)
	_paint_patch(Rect2i(31, 9, 12, 9), WORN_PATH_TILE, true)


func _populate_authored_decor() -> void:
	for index in range(LOW_DECOR_CELLS.size()):
		var cell: Vector2i = LOW_DECOR_CELLS[index]
		decoration_low.set_cell(cell, ART_SOURCE, Vector2i(index % 8, 2))
	for cell in [
		Vector2i(10, 23), Vector2i(11, 24), Vector2i(12, 24),
		Vector2i(31, 12), Vector2i(35, 12), Vector2i(39, 12), Vector2i(41, 15),
	]:
		decoration_low.set_cell(cell, ART_SOURCE, Vector2i(5, 2))


func _populate_authored_objects() -> void:
	for index in range(GRAVE_CELLS.size()):
		objects_y_sorted.set_cell(GRAVE_CELLS[index], ART_SOURCE, Vector2i(index % 4, 3))
	for cell in TREE_CELLS:
		objects_y_sorted.set_cell(cell, ART_SOURCE, Vector2i(7, 3))
	for cell in [
		Vector2i(7, 10), Vector2i(14, 17), Vector2i(19, 27),
		Vector2i(28, 11), Vector2i(29, 15), Vector2i(43, 19),
	]:
		objects_y_sorted.set_cell(cell, ART_SOURCE, Vector2i(3 + (cell.x % 5), 4))
	for cell in [
		Vector2i(4, 3), Vector2i(8, 2), Vector2i(13, 3), Vector2i(18, 2),
		Vector2i(31, 3), Vector2i(37, 2), Vector2i(43, 3), Vector2i(47, 5),
		Vector2i(4, 29), Vector2i(9, 30), Vector2i(16, 29), Vector2i(32, 30),
		Vector2i(39, 29), Vector2i(46, 28),
	]:
		foreground_occlusion.set_cell(cell, ART_SOURCE, Vector2i((cell.x + cell.y) % 8, 6))


func _populate_authored_collision() -> void:
	# World perimeter keeps camera/player safely inside the playable rectangle.
	for x in range(MAP_SIZE_TILES.x):
		collision.set_cell(Vector2i(x, 0), ART_SOURCE, COLLISION_CELL)
		collision.set_cell(Vector2i(x, MAP_SIZE_TILES.y - 1), ART_SOURCE, COLLISION_CELL)
	for y in range(1, MAP_SIZE_TILES.y - 1):
		collision.set_cell(Vector2i(0, y), ART_SOURCE, COLLISION_CELL)
		collision.set_cell(Vector2i(MAP_SIZE_TILES.x - 1, y), ART_SOURCE, COLLISION_CELL)

	# Workshop footprint: authored around its façade, leaving the south apron open.
	_paint_collision_rect(Rect2i(8, 17, 9, 4))
	# Old family crypt and retaining wall break the cemetery into readable sub-spaces.
	_paint_collision_rect(Rect2i(28, 5, 3, 8))
	_paint_collision_rect(Rect2i(43, 7, 3, 9))
	# Northern grove creates a soft funnel toward the village route.
	_paint_collision_rect(Rect2i(18, 4, 4, 3))
	_paint_collision_rect(Rect2i(27, 2, 3, 4))


func _paint_route(cells: Array, tile: Vector2i, widen: bool) -> void:
	for cell in cells:
		var route_cell: Vector2i = cell
		paths.set_cell(route_cell, ART_SOURCE, tile)
		if widen:
			var shoulder: Vector2i = route_cell + Vector2i(0, 1)
			if shoulder.y < MAP_SIZE_TILES.y - 1:
				paths.set_cell(shoulder, ART_SOURCE, tile + Vector2i(1, 0))


func _paint_patch(rect: Rect2i, tile: Vector2i, sparse := false) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if sparse and (x + y) % 4 == 0:
				continue
			paths.set_cell(Vector2i(x, y), ART_SOURCE, tile + Vector2i((x + y) % 2, 0))


func _paint_collision_rect(rect: Rect2i) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			collision.set_cell(Vector2i(x, y), ART_SOURCE, COLLISION_CELL)


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
