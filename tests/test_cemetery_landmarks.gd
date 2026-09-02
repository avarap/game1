class_name TestCemeteryLandmarks
extends RefCounted

const MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var scene := load(MAP_PATH) as PackedScene
	var map := scene.instantiate()
	(Engine.get_main_loop() as SceneTree).root.add_child(map)

	var landmarks := map.get_node_or_null("landmarks") as TileMapLayer
	if landmarks == null:
		failures.append("Rebuilt cemetery should expose a dedicated landmarks layer")
		map.free()
		return failures

	if landmarks.get_used_cells().size() < 12:
		failures.append("Landmarks layer should carry enough detail to establish visual hierarchy")

	for entry in [
		["workshop", Vector2i(9, 22), 4],
		["cemetery threshold", Vector2i(29, 11), 4],
		["village exit", Vector2i(21, 3), 4],
	]:
		var label := str(entry[0])
		var center := entry[1] as Vector2i
		var nearby := 0
		for cell in landmarks.get_used_cells():
			if absi(cell.x - center.x) + absi(cell.y - center.y) <= 4:
				nearby += 1
		if nearby < int(entry[2]):
			failures.append("%s landmark should have a readable local detail cluster" % label)

	var paths := map.get_node_or_null("paths") as TileMapLayer
	if paths != null:
		for cell in landmarks.get_used_cells():
			if paths.get_cell_source_id(cell) != -1:
				failures.append("Landmark detail must not paint over primary travel paths: %s" % cell)

	map.free()
	return failures
