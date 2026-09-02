class_name CemeteryMap
extends TechnicalMap

const ART_SOURCE := 0
const GATE_TILE := Vector2i(4, 3)
const WORKSHOP_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/building_workshop_exterior.png"
)
const ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)

const GRAVE_CELLS := [
	Vector2i(31, 10),
	Vector2i(34, 10),
	Vector2i(37, 10),
	Vector2i(40, 10),
	Vector2i(31, 13),
	Vector2i(34, 13),
	Vector2i(37, 13),
	Vector2i(40, 13),
	Vector2i(31, 16),
	Vector2i(34, 16),
	Vector2i(37, 16),
	Vector2i(40, 16),
	Vector2i(31, 19),
	Vector2i(34, 19),
	Vector2i(37, 19),
	Vector2i(40, 19),
]
const STRUCTURAL_GATE_CELLS := [
	Vector2i(27, 8),
	Vector2i(31, 8),
	Vector2i(18, 2),
	Vector2i(24, 2),
]


func _ready() -> void:
	_configure_layers(CemeteryArtTileset.build())
	_populate_rebuilt_ground()
	_populate_rebuilt_paths()
	_populate_rebuilt_decor()
	_populate_rebuilt_objects()
	_populate_rebuilt_collision()
	_hide_placeholders(self)
	_add_workshop_art()


func _populate_rebuilt_ground() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var district_bias := 0
			if x > 27 and y < 22:
				district_bias = 2
			elif x < 16 and y > 16:
				district_bias = 5
			var variant: int = absi(x * 13 + y * 29 + x * y + district_bias) % 8
			ground.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(variant, 0))


func _populate_rebuilt_paths() -> void:
	# The rebuilt yard is organized around a looping pilgrimage road rather than
	# the previous orthogonal cross. Wide connectors keep character movement legible.
	_paint_path_polyline(
		[
			Vector2i(9, 22),
			Vector2i(12, 19),
			Vector2i(17, 18),
			Vector2i(21, 14),
			Vector2i(21, 3),
		],
		2,
	)
	_paint_path_polyline(
		[
			Vector2i(17, 18),
			Vector2i(24, 17),
			Vector2i(28, 14),
			Vector2i(29, 11),
			Vector2i(42, 8),
			Vector2i(43, 5),
		],
		2,
	)
	_paint_path_polyline(
		[
			Vector2i(24, 17),
			Vector2i(28, 20),
			Vector2i(36, 22),
			Vector2i(42, 23),
			Vector2i(47, 25),
		],
		2,
	)
	_paint_path_polyline(
		[
			Vector2i(28, 11),
			Vector2i(42, 11),
			Vector2i(42, 20),
			Vector2i(28, 20),
			Vector2i(28, 11),
		],
		1,
	)
	# A narrow ceremonial aisle links the two grave interactions without turning
	# the grave field into another broad road or obscuring the plot rhythm.
	_paint_path_polyline([Vector2i(34, 17), Vector2i(40, 17)], 0)
	_paint_path_polyline(
		[
			Vector2i(7, 22),
			Vector2i(7, 25),
			Vector2i(13, 25),
			Vector2i(15, 22),
		],
		1,
	)


func _paint_path_polyline(points: Array[Vector2i], half_width: int) -> void:
	for index in range(points.size() - 1):
		_paint_path_segment(points[index], points[index + 1], half_width)


func _paint_path_segment(start: Vector2i, finish: Vector2i, half_width: int) -> void:
	var cursor := start
	_paint_path_disc(cursor, half_width)
	while cursor != finish:
		var delta := finish - cursor
		if absi(delta.x) >= absi(delta.y) and delta.x != 0:
			cursor.x += signi(delta.x)
		elif delta.y != 0:
			cursor.y += signi(delta.y)
		_paint_path_disc(cursor, half_width)


func _paint_path_disc(center: Vector2i, half_width: int) -> void:
	for y in range(center.y - half_width, center.y + half_width + 1):
		for x in range(center.x - half_width, center.x + half_width + 1):
			if x <= 0 or y <= 0 or x >= MAP_SIZE_TILES.x - 1 or y >= MAP_SIZE_TILES.y - 1:
				continue
			var distance: int = absi(x - center.x) + absi(y - center.y)
			if distance > half_width + 1:
				continue
			var variant := (x * 3 + y * 5) % 8
			paths.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(variant, 1))


func _populate_rebuilt_decor() -> void:
	for y in range(2, MAP_SIZE_TILES.y - 2):
		for x in range(2, MAP_SIZE_TILES.x - 2):
			var cell := Vector2i(x, y)
			if paths.get_cell_source_id(cell) != -1:
				continue
			var score := absi(x * 19 + y * 11 + x * y * 3)
			if score % 17 == 0:
				decoration_low.set_cell(cell, ART_SOURCE, Vector2i(score % 8, 2))

	# Denser ground detail around the workshop clearing and cemetery threshold.
	for cell in [
		Vector2i(5, 23),
		Vector2i(6, 26),
		Vector2i(11, 27),
		Vector2i(14, 24),
		Vector2i(26, 13),
		Vector2i(27, 16),
		Vector2i(44, 13),
		Vector2i(44, 18),
	]:
		decoration_low.set_cell(cell, ART_SOURCE, Vector2i((cell.x + cell.y) % 8, 2))


func _populate_rebuilt_objects() -> void:
	for index in range(GRAVE_CELLS.size()):
		objects_y_sorted.set_cell(GRAVE_CELLS[index], ART_SOURCE, Vector2i(index % 4, 3))

	# Reused production gate art provides vertical silhouettes at the two critical
	# route transitions while deliberately leaving the travel cells collision-free.
	for cell in STRUCTURAL_GATE_CELLS:
		objects_y_sorted.set_cell(cell, ART_SOURCE, GATE_TILE)

	var tree_cells := [
		Vector2i(3, 4),
		Vector2i(7, 3),
		Vector2i(12, 5),
		Vector2i(16, 3),
		Vector2i(25, 3),
		Vector2i(46, 4),
		Vector2i(46, 9),
		Vector2i(46, 16),
		Vector2i(45, 21),
		Vector2i(44, 27),
		Vector2i(36, 28),
		Vector2i(29, 27),
		Vector2i(21, 28),
		Vector2i(15, 29),
		Vector2i(5, 28),
		Vector2i(3, 20),
		Vector2i(4, 12),
	]
	for cell in tree_cells:
		objects_y_sorted.set_cell(cell, ART_SOURCE, Vector2i(7, 3))

	for cell in [
		Vector2i(18, 12),
		Vector2i(24, 12),
		Vector2i(26, 22),
		Vector2i(32, 24),
		Vector2i(39, 25),
		Vector2i(43, 7),
		Vector2i(44, 11),
		Vector2i(44, 20),
	]:
		objects_y_sorted.set_cell(cell, ART_SOURCE, Vector2i(3 + cell.x % 5, 4))

	# Foreground framing creates depth without hiding the critical travel lanes.
	for x in range(2, MAP_SIZE_TILES.x - 2, 3):
		foreground_occlusion.set_cell(Vector2i(x, 1), ART_SOURCE, Vector2i(x % 8, 6))
		foreground_occlusion.set_cell(
			Vector2i(x, MAP_SIZE_TILES.y - 2), ART_SOURCE, Vector2i((x + 3) % 8, 6)
		)
	for y in range(5, MAP_SIZE_TILES.y - 3, 4):
		foreground_occlusion.set_cell(Vector2i(2, y), ART_SOURCE, Vector2i(y % 8, 6))
		foreground_occlusion.set_cell(
			Vector2i(MAP_SIZE_TILES.x - 3, y), ART_SOURCE, Vector2i((y + 2) % 8, 6)
		)


func _populate_rebuilt_collision() -> void:
	# Hard world boundary.
	for x in range(MAP_SIZE_TILES.x):
		_set_collision(Vector2i(x, 0))
		_set_collision(Vector2i(x, MAP_SIZE_TILES.y - 1))
	for y in range(1, MAP_SIZE_TILES.y - 1):
		_set_collision(Vector2i(0, y))
		_set_collision(Vector2i(MAP_SIZE_TILES.x - 1, y))

	# Workshop building footprint: interactions remain in the open apron below it.
	for y in range(15, 21):
		for x in range(4, 14):
			_set_collision(Vector2i(x, y))

	# Grave plots are physical obstacles, separated by readable walking aisles.
	for grave_cell in GRAVE_CELLS:
		_set_collision(grave_cell)

	# Tree/stone masses shape the perimeter while leaving the pilgrimage loop open.
	for cell in [
		Vector2i(3, 4),
		Vector2i(7, 3),
		Vector2i(12, 5),
		Vector2i(16, 3),
		Vector2i(25, 3),
		Vector2i(46, 4),
		Vector2i(46, 9),
		Vector2i(46, 16),
		Vector2i(45, 21),
		Vector2i(44, 27),
		Vector2i(36, 28),
		Vector2i(29, 27),
		Vector2i(21, 28),
		Vector2i(15, 29),
		Vector2i(5, 28),
		Vector2i(3, 20),
		Vector2i(4, 12),
		Vector2i(18, 12),
		Vector2i(24, 12),
		Vector2i(26, 22),
		Vector2i(32, 24),
		Vector2i(39, 25),
		Vector2i(44, 11),
		Vector2i(44, 20),
	]:
		_set_collision(cell)


func _set_collision(cell: Vector2i) -> void:
	collision.set_cell(cell, ART_SOURCE, COLLISION_TILE)


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
