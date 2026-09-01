class_name CemeteryMap
extends TechnicalMap

const ART_SOURCE := 0
const WORKSHOP_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/building_workshop_exterior.png"
)
const ATLAS_TEXTURE := preload(
	"res://art/environment/cemetery/production/atlas/tileset_cemetery_32.png"
)


func _ready() -> void:
	_configure_layers(CemeteryArtTileset.build())
	_populate_production_ground()
	_populate_production_paths()
	_populate_production_decor()
	_populate_production_objects()
	_populate_collision()
	_hide_placeholders(self)
	_add_workshop_art()


func _populate_production_ground() -> void:
	for y in range(MAP_SIZE_TILES.y):
		for x in range(MAP_SIZE_TILES.x):
			var variant: int = absi(x * 17 + y * 31 + x * y * 3) % 8
			ground.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(variant, 0))


func _populate_production_paths() -> void:
	for y in range(2, 31):
		var bend := 24 + int(sin(float(y) * 0.45) * 2.0)
		for x in range(bend, bend + 2):
			paths.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i((x + y) % 4, 1))
	for x in range(8, 48):
		var bend := 19 + int(sin(float(x) * 0.38))
		for y in range(bend, bend + 2):
			paths.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i(4 + (x + y) % 4, 1))
	for x in range(11, 25):
		paths.set_cell(Vector2i(x, 22), ART_SOURCE, Vector2i(4 + x % 4, 1))
	for y in range(10, 20):
		for x in range(32, 34):
			paths.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i((x + y) % 4, 1))


func _populate_production_decor() -> void:
	for y in range(2, 30):
		for x in range(2, 48):
			if (x * 11 + y * 7) % 23 == 0 and paths.get_cell_source_id(Vector2i(x, y)) == -1:
				decoration_low.set_cell(Vector2i(x, y), ART_SOURCE, Vector2i((x + y) % 8, 2))


func _populate_production_objects() -> void:
	var grave_cells := [
		Vector2i(28, 7),
		Vector2i(31, 7),
		Vector2i(34, 7),
		Vector2i(37, 7),
		Vector2i(28, 10),
		Vector2i(31, 10),
		Vector2i(34, 10),
		Vector2i(37, 10),
		Vector2i(28, 13),
		Vector2i(31, 13),
		Vector2i(34, 13),
		Vector2i(37, 13),
		Vector2i(28, 16),
		Vector2i(31, 16),
		Vector2i(34, 16),
		Vector2i(37, 16),
	]
	for index in range(grave_cells.size()):
		objects_y_sorted.set_cell(grave_cells[index], ART_SOURCE, Vector2i(index % 4, 3))
	for x in [4, 6, 9, 12, 15, 39, 42, 45, 47]:
		objects_y_sorted.set_cell(Vector2i(x, 4 + (x * 3) % 11), ART_SOURCE, Vector2i(7, 3))
	for cell in [
		Vector2i(11, 19), Vector2i(14, 18), Vector2i(17, 25), Vector2i(38, 11), Vector2i(41, 12)
	]:
		objects_y_sorted.set_cell(cell, ART_SOURCE, Vector2i(3 + (cell.x % 5), 4))
	for x in range(2, 49, 3):
		foreground_occlusion.set_cell(Vector2i(x, 1), ART_SOURCE, Vector2i(x % 8, 6))
		if x not in [23, 26]:
			foreground_occlusion.set_cell(Vector2i(x, 29), ART_SOURCE, Vector2i((x + 3) % 8, 6))
	for y in range(4, 29, 4):
		foreground_occlusion.set_cell(Vector2i(2, y), ART_SOURCE, Vector2i(y % 8, 6))
		foreground_occlusion.set_cell(Vector2i(47, y), ART_SOURCE, Vector2i((y + 2) % 8, 6))


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
