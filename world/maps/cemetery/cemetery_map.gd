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
	Vector2i(13, 23),
	Vector2i(14, 23),
	Vector2i(15, 23),
	Vector2i(16, 23),
	Vector2i(17, 22),
	Vector2i(18, 22),
	Vector2i(19, 22),
	Vector2i(20, 21),
	Vector2i(21, 21),
	Vector2i(22, 20),
	Vector2i(23, 20),
	Vector2i(24, 19),
	Vector2i(25, 19),
	Vector2i(26, 18),
	Vector2i(27, 18),
	Vector2i(28, 17),
	Vector2i(29, 17),
	Vector2i(30, 16),
	Vector2i(31, 16),
	Vector2i(32, 15),
	Vector2i(33, 15),
	Vector2i(34, 15),
	Vector2i(35, 16),
	Vector2i(36, 17),
	Vector2i(37, 18),
	Vector2i(38, 19),
	Vector2i(39, 20),
	Vector2i(40, 21),
	Vector2i(41, 22),
	Vector2i(42, 22),
	Vector2i(43, 22),
	Vector2i(44, 22),
	Vector2i(45, 22),
	Vector2i(46, 22),
]

const MAIN_ROUTE_SHOULDERS := [
	Vector2i(13, 24),
	Vector2i(14, 24),
	Vector2i(16, 24),
	Vector2i(17, 23),
	Vector2i(19, 23),
	Vector2i(20, 22),
	Vector2i(23, 21),
	Vector2i(24, 20),
	Vector2i(27, 19),
	Vector2i(28, 18),
	Vector2i(30, 17),
	Vector2i(32, 16),
	Vector2i(34, 16),
	Vector2i(36, 18),
	Vector2i(39, 21),
	Vector2i(41, 23),
	Vector2i(42, 23),
	Vector2i(44, 23),
	Vector2i(46, 23),
]

const VILLAGE_ROUTE := [
	Vector2i(24, 19),
	Vector2i(24, 18),
	Vector2i(24, 17),
	Vector2i(24, 16),
	Vector2i(24, 15),
	Vector2i(24, 14),
	Vector2i(24, 13),
	Vector2i(24, 12),
	Vector2i(24, 11),
	Vector2i(24, 10),
	Vector2i(24, 9),
	Vector2i(24, 8),
	Vector2i(24, 7),
	Vector2i(24, 6),
	Vector2i(24, 5),
	Vector2i(24, 4),
	Vector2i(24, 3),
]

const VILLAGE_ROUTE_EDGES := [
	Vector2i(23, 17),
	Vector2i(25, 15),
	Vector2i(23, 13),
	Vector2i(25, 10),
	Vector2i(23, 8),
	Vector2i(25, 6),
	Vector2i(23, 4),
]

const CEMETERY_LOOP := [
	Vector2i(31, 16),
	Vector2i(31, 15),
	Vector2i(31, 14),
	Vector2i(31, 13),
	Vector2i(32, 12),
	Vector2i(33, 11),
	Vector2i(34, 10),
	Vector2i(35, 9),
	Vector2i(36, 8),
	Vector2i(37, 8),
	Vector2i(38, 9),
	Vector2i(39, 10),
	Vector2i(40, 11),
	Vector2i(41, 12),
	Vector2i(42, 13),
	Vector2i(42, 14),
	Vector2i(42, 15),
	Vector2i(41, 16),
	Vector2i(40, 17),
	Vector2i(39, 18),
]

const CEMETERY_LOOP_SHOULDERS := [
	Vector2i(30, 15),
	Vector2i(30, 13),
	Vector2i(32, 13),
	Vector2i(33, 12),
	Vector2i(35, 10),
	Vector2i(37, 9),
	Vector2i(39, 9),
	Vector2i(40, 10),
	Vector2i(42, 12),
	Vector2i(43, 14),
	Vector2i(41, 15),
	Vector2i(40, 18),
]

const WORKSHOP_APRON := [
	Vector2i(9, 22),
	Vector2i(10, 22),
	Vector2i(11, 22),
	Vector2i(12, 22),
	Vector2i(13, 22),
	Vector2i(14, 22),
	Vector2i(15, 22),
	Vector2i(16, 22),
	Vector2i(9, 23),
	Vector2i(10, 23),
	Vector2i(11, 23),
	Vector2i(12, 23),
	Vector2i(17, 23),
	Vector2i(9, 24),
	Vector2i(10, 24),
	Vector2i(11, 24),
	Vector2i(12, 24),
	Vector2i(13, 24),
	Vector2i(15, 24),
	Vector2i(16, 24),
	Vector2i(17, 24),
	Vector2i(10, 25),
	Vector2i(11, 25),
	Vector2i(12, 25),
	Vector2i(14, 25),
	Vector2i(15, 25),
	Vector2i(16, 25),
]

const CEMETERY_WORN_PATCHES := [
	Vector2i(32, 11),
	Vector2i(34, 11),
	Vector2i(36, 10),
	Vector2i(38, 10),
	Vector2i(40, 12),
	Vector2i(33, 13),
	Vector2i(35, 13),
	Vector2i(38, 13),
	Vector2i(41, 14),
	Vector2i(32, 15),
	Vector2i(36, 15),
	Vector2i(39, 16),
	Vector2i(41, 17),
	Vector2i(37, 18),
]

const PATH_BREAKUP_CELLS := [
	Vector2i(15, 23),
	Vector2i(18, 22),
	Vector2i(22, 20),
	Vector2i(26, 18),
	Vector2i(30, 16),
	Vector2i(35, 16),
	Vector2i(38, 19),
	Vector2i(43, 22),
	Vector2i(24, 12),
	Vector2i(24, 7),
	Vector2i(34, 10),
	Vector2i(39, 10),
]

# Explicit 50x32 authored terrain mask. Each character selects one of the eight
# production atlas variants in row 0. The broad masses follow the intended
# forest/workshop/cemetery/wetland zoning without runtime noise or periodic math.
const GROUND_VARIANT_ROWS := [
	"00000000000000066666666666666660000000000000000000",
	"03333333333333366666666666000666000000000000000000",
	"03336663333333333366660000000066600005555555500000",
	"06666666333333333366660000000055555555555566650000",
	"06666666633333333336660000000005333333333366666660",
	"06666666663333333366600000000055333333333366666660",
	"03666666663333333066600000000555333355333366666660",
	"03666666633000000066666600005553355555533366666660",
	"03666666630000000066666666665553355555553366666660",
	"03333666330000000006666666665553335555553336666660",
	"03333300330000000006666666665553335555533333666650",
	"00330000300000000006666077777222333355333333365550",
	"00330000030000000007777777222222233333333335555550",
	"00300000033330000777777777222222223333333355555550",
	"00030000333333000777777772222222223333333355555550",
	"00000003333330000777777772222222253333333355555550",
	"00000000000001111777777777772222555533333555555550",
	"00000777111111111777777777777777555555333555555550",
	"00777777111111111177777777777777777550044445555540",
	"00777777111111222277777777777777777700004444554440",
	"00777777722222222277777777777777777770000444444440",
	"07777777722222222277777777700777777777000044444440",
	"07777777222222222227777770000777777770000044444440",
	"00777772222222222222777100000077777770444444444440",
	"00117722222222222222111110000077777744444444444440",
	"00111222222222222211111111000000000044444444444440",
	"00011122222222222211111111100000000444444444444440",
	"00011112222222222211111111000000000444444444444440",
	"00001111222222222211111111000000000044444444444440",
	"00001111111111111111111110000000000004444444444440",
	"00000111111111000000000000000000004444444444444440",
	"00000000000000000000000000000000000000000000000000",
]

const GRAVE_CELLS := [
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

const GRAVE_TILES := [
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

const LOW_DECOR_CELLS := [
	Vector2i(10, 10),
	Vector2i(13, 11),
	Vector2i(17, 9),
	Vector2i(20, 12),
	Vector2i(7, 20),
	Vector2i(10, 21),
	Vector2i(17, 19),
	Vector2i(20, 24),
	Vector2i(28, 7),
	Vector2i(29, 11),
	Vector2i(30, 14),
	Vector2i(44, 10),
	Vector2i(44, 17),
	Vector2i(27, 25),
	Vector2i(31, 27),
	Vector2i(37, 26),
]

const LOW_DECOR_TILES := [
	Vector2i(0, 2),
	Vector2i(3, 2),
	Vector2i(1, 2),
	Vector2i(6, 2),
	Vector2i(2, 2),
	Vector2i(5, 2),
	Vector2i(7, 2),
	Vector2i(1, 2),
	Vector2i(4, 2),
	Vector2i(0, 2),
	Vector2i(6, 2),
	Vector2i(3, 2),
	Vector2i(7, 2),
	Vector2i(2, 2),
	Vector2i(5, 2),
	Vector2i(1, 2),
]

const BOULDER_CELLS := [
	Vector2i(7, 10),
	Vector2i(28, 11),
	Vector2i(43, 19),
]
const TIMBER_CELLS := [
	Vector2i(14, 17),
	Vector2i(19, 27),
]
const BRAMBLE_CELLS := [
	Vector2i(29, 15),
]

const FOREGROUND_VARIANT_0 := [
	Vector2i(4, 3),
	Vector2i(31, 3),
	Vector2i(9, 30),
]
const FOREGROUND_VARIANT_2 := [
	Vector2i(8, 2),
	Vector2i(43, 3),
	Vector2i(32, 30),
]
const FOREGROUND_VARIANT_4 := [
	Vector2i(13, 3),
	Vector2i(47, 5),
	Vector2i(39, 29),
]
const FOREGROUND_VARIANT_6 := [
	Vector2i(18, 2),
	Vector2i(37, 2),
	Vector2i(4, 29),
	Vector2i(46, 28),
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
	for y in range(GROUND_VARIANT_ROWS.size()):
		var authored_row: String = GROUND_VARIANT_ROWS[y]
		for x in range(authored_row.length()):
			var atlas_x := authored_row.substr(x, 1).to_int()
			ground.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(atlas_x, 0))


func _populate_authored_paths() -> void:
	_paint_cells(paths, MAIN_ROUTE, MAIN_PATH_TILE)
	_paint_cells(paths, MAIN_ROUTE_SHOULDERS, MAIN_PATH_TILE + Vector2i(1, 0))
	_paint_cells(paths, VILLAGE_ROUTE, SIDE_PATH_TILE)
	_paint_cells(paths, VILLAGE_ROUTE_EDGES, SIDE_PATH_TILE + Vector2i(1, 0))
	_paint_cells(paths, CEMETERY_LOOP, SIDE_PATH_TILE)
	_paint_cells(paths, CEMETERY_LOOP_SHOULDERS, SIDE_PATH_TILE + Vector2i(1, 0))
	_paint_cells(paths, WORKSHOP_APRON, WORN_PATH_TILE)
	_paint_cells(paths, CEMETERY_WORN_PATCHES, WORN_PATH_TILE + Vector2i(1, 0))
	_paint_cells(paths, PATH_BREAKUP_CELLS, Vector2i(3, 1))


func _populate_authored_decor() -> void:
	for index in range(LOW_DECOR_CELLS.size()):
		var cell: Vector2i = LOW_DECOR_CELLS[index]
		decoration_low.set_cell(cell, ART_SOURCE, LOW_DECOR_TILES[index])
	_paint_cells(
		decoration_low,
		[
			Vector2i(10, 23),
			Vector2i(11, 24),
			Vector2i(12, 24),
			Vector2i(31, 12),
			Vector2i(35, 12),
			Vector2i(39, 12),
			Vector2i(41, 15),
		],
		Vector2i(5, 2),
	)


func _populate_authored_objects() -> void:
	for index in range(GRAVE_CELLS.size()):
		objects_y_sorted.set_cell(GRAVE_CELLS[index], ART_SOURCE, GRAVE_TILES[index])
	_paint_cells(objects_y_sorted, TREE_CELLS, Vector2i(7, 3))
	_paint_cells(objects_y_sorted, BOULDER_CELLS, Vector2i(3, 4))
	_paint_cells(objects_y_sorted, TIMBER_CELLS, Vector2i(5, 4))
	_paint_cells(objects_y_sorted, BRAMBLE_CELLS, Vector2i(7, 4))
	_paint_cells(foreground_occlusion, FOREGROUND_VARIANT_0, Vector2i(0, 6))
	_paint_cells(foreground_occlusion, FOREGROUND_VARIANT_2, Vector2i(2, 6))
	_paint_cells(foreground_occlusion, FOREGROUND_VARIANT_4, Vector2i(4, 6))
	_paint_cells(foreground_occlusion, FOREGROUND_VARIANT_6, Vector2i(6, 6))


func _populate_authored_collision() -> void:
	for x in range(MAP_SIZE_TILES.x):
		collision.set_cell(Vector2i(x, 0), ART_SOURCE, COLLISION_CELL)
		collision.set_cell(Vector2i(x, MAP_SIZE_TILES.y - 1), ART_SOURCE, COLLISION_CELL)
	for y in range(1, MAP_SIZE_TILES.y - 1):
		collision.set_cell(Vector2i(0, y), ART_SOURCE, COLLISION_CELL)
		collision.set_cell(Vector2i(MAP_SIZE_TILES.x - 1, y), ART_SOURCE, COLLISION_CELL)

	_paint_collision_rect(Rect2i(8, 17, 9, 4))
	_paint_collision_rect(Rect2i(28, 5, 3, 8))
	_paint_collision_rect(Rect2i(43, 7, 3, 9))
	_paint_collision_rect(Rect2i(18, 4, 4, 3))
	_paint_collision_rect(Rect2i(27, 2, 3, 4))


func _paint_cells(layer: TileMapLayer, cells: Array, tile: Vector2i) -> void:
	for raw_cell in cells:
		var cell: Vector2i = raw_cell
		layer.set_cell(cell, ART_SOURCE, tile)


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
