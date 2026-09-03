class_name TestCemeteryZoning
extends RefCounted

const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const WORKSHOP_RECT := Rect2i(7, 19, 13, 9)
const CEMETERY_RECT := Rect2i(30, 5, 14, 15)
const TECHNICAL_PLACEHOLDER_TILE := Vector2i(4, 3)
const GRAVE_AISLE_CELLS := [
	Vector2i(35, 7),
	Vector2i(35, 11),
	Vector2i(35, 16),
	Vector2i(39, 7),
	Vector2i(39, 14),
	Vector2i(39, 17),
	Vector2i(33, 12),
	Vector2i(37, 12),
	Vector2i(41, 12),
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var map := CEMETERY_SCENE.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if ground == null or paths == null or objects == null:
		failures.append("Cemetery zoning requires ground, path and object layers")
		map.free()
		return failures

	_check_workshop_ground(ground, failures)
	_check_cemetery_composition(objects, failures)
	_check_grave_aisles(paths, objects, failures)
	_check_forest_resources(map, failures)

	map.free()
	return failures


static func _check_workshop_ground(ground: TileMapLayer, failures: Array[String]) -> void:
	var non_base_cells := 0
	var variants: Dictionary = {}
	for y in range(WORKSHOP_RECT.position.y, WORKSHOP_RECT.end.y):
		for x in range(WORKSHOP_RECT.position.x, WORKSHOP_RECT.end.x):
			var cell := Vector2i(x, y)
			var atlas := ground.get_cell_atlas_coords(cell)
			if atlas != Vector2i(0, 0) and atlas != Vector2i(-1, -1):
				non_base_cells += 1
				variants[atlas] = true
	if non_base_cells < 28:
		failures.append("Workshop yard should read as a substantial authored soil mass")
	if variants.size() < 3:
		failures.append("Workshop yard should mix at least three intentional ground materials")


static func _check_cemetery_composition(objects: TileMapLayer, failures: Array[String]) -> void:
	for cell in objects.get_used_cells():
		if not CEMETERY_RECT.has_point(cell):
			continue
		if objects.get_cell_atlas_coords(cell) == TECHNICAL_PLACEHOLDER_TILE:
			failures.append("Cemetery composition must not expose technical boundary placeholders")
			break
	var authored_sprites := 0
	for child in objects.find_children("*", "Sprite2D", true, false):
		var sprite := child as Sprite2D
		if not sprite.visible:
			continue
		var cell := objects.local_to_map(objects.to_local(sprite.global_position))
		if CEMETERY_RECT.has_point(cell):
			authored_sprites += 1
	if authored_sprites < 12:
		failures.append("Cemetery should retain a substantial authored visual composition")


static func _check_grave_aisles(
	paths: TileMapLayer, objects: TileMapLayer, failures: Array[String]
) -> void:
	for cell in GRAVE_AISLE_CELLS:
		if paths.get_cell_source_id(cell) == -1:
			failures.append("Grave field should expose a readable internal aisle at %s" % cell)
		if objects.get_cell_source_id(cell) != -1:
			failures.append("Grave aisle should remain visually open at %s" % cell)

	var grave_count := 0
	for cell in objects.get_used_cells():
		if not CEMETERY_RECT.has_point(cell):
			continue
		var atlas := objects.get_cell_atlas_coords(cell)
		if atlas.y == 3 and atlas.x >= 0 and atlas.x <= 3:
			grave_count += 1
	for child in objects.get_children():
		if child is not Sprite2D or not child.name.begins_with("GraveVisual"):
			continue
		var grave_cell := objects.local_to_map((child as Sprite2D).position)
		if CEMETERY_RECT.has_point(grave_cell):
			grave_count += 1
	if grave_count < 12:
		failures.append("Cemetery should retain multiple grave clusters around its aisles")


static func _check_forest_resources(map: Node2D, failures: Array[String]) -> void:
	var resources := map.get_node_or_null("ForestResources") as Node2D
	if resources == null:
		failures.append("Rebuilt map should expose a dedicated ForestResources zone")
		return

	var resource_count := 0
	for child in resources.get_children():
		if child is not ResourceNode:
			continue
		resource_count += 1
		var cell := Vector2i(
			floori(child.position.x / 32.0),
			floori(child.position.y / 32.0),
		)
		if WORKSHOP_RECT.has_point(cell):
			failures.append("Forest resource must not be scattered inside workshop yard: %s" % cell)
		if CEMETERY_RECT.has_point(cell):
			failures.append(
				"Forest resource must not be scattered inside cemetery composition: %s" % cell
			)
	if resource_count < 6:
		failures.append("Forest zone should expose at least six real harvestable resource nodes")
