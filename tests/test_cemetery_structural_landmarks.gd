class_name TestCemeteryStructuralLandmarks
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const GATE_TILE := Vector2i(4, 3)
const LANDMARK_CENTERS := {
	"cemetery threshold": Vector2i(29, 11),
	"village exit": Vector2i(21, 3),
}


static func run() -> Array[String]:
	var failures: Array[String] = []
	var scene := load(MAP_PATH) as PackedScene
	var map := scene.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)

	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var collision := map.get_node_or_null("collision") as TileMapLayer
	if objects == null or paths == null or collision == null:
		failures.append("Structural landmark test requires production object, path, and collision layers")
		map.free()
		return failures

	for label in LANDMARK_CENTERS:
		var center: Vector2i = LANDMARK_CENTERS[label]
		var gate_cells := _gate_cells_near(objects, center)
		if gate_cells.size() < 2:
			failures.append("%s should be framed by at least two structural gate elements" % label)
			continue
		for cell in gate_cells:
			if paths.get_cell_source_id(cell) != -1:
				failures.append("%s gate element must not paint over the travel path: %s" % [label, cell])
			if collision.get_cell_source_id(cell) != -1:
				failures.append("%s gate element must not block player traversal: %s" % [label, cell])

	map.free()
	return failures


static func _gate_cells_near(objects: TileMapLayer, center: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in objects.get_used_cells():
		if objects.get_cell_atlas_coords(cell) != GATE_TILE:
			continue
		if absi(cell.x - center.x) + absi(cell.y - center.y) <= 5:
			result.append(cell)
	return result
