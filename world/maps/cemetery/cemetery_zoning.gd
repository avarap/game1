class_name CemeteryZoning
extends Node

const ART_SOURCE := 0
const FENCE_TILE := Vector2i(4, 3)
const AISLE_TILE := Vector2i(1, 1)
const WORKSHOP_SOIL_CELLS := {
	Vector2i(1, 0):
	[
		Vector2i(8, 20),
		Vector2i(9, 20),
		Vector2i(10, 20),
		Vector2i(11, 20),
		Vector2i(12, 20),
		Vector2i(13, 20),
		Vector2i(14, 20),
		Vector2i(15, 20),
		Vector2i(16, 20),
		Vector2i(17, 20),
		Vector2i(18, 20),
		Vector2i(8, 21),
		Vector2i(9, 21),
		Vector2i(10, 21),
		Vector2i(16, 21),
		Vector2i(17, 21),
		Vector2i(18, 21),
		Vector2i(8, 26),
		Vector2i(9, 26),
		Vector2i(17, 26),
		Vector2i(18, 26),
	],
	Vector2i(2, 0):
	[
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
		Vector2i(13, 23),
		Vector2i(14, 23),
		Vector2i(15, 23),
		Vector2i(16, 23),
		Vector2i(17, 23),
		Vector2i(9, 24),
		Vector2i(10, 24),
		Vector2i(11, 24),
		Vector2i(12, 24),
		Vector2i(13, 24),
		Vector2i(14, 24),
		Vector2i(15, 24),
		Vector2i(16, 24),
		Vector2i(17, 24),
	],
	Vector2i(5, 0):
	[
		Vector2i(8, 22),
		Vector2i(17, 22),
		Vector2i(8, 23),
		Vector2i(18, 23),
		Vector2i(8, 24),
		Vector2i(18, 24),
		Vector2i(9, 25),
		Vector2i(10, 25),
		Vector2i(11, 25),
		Vector2i(12, 25),
		Vector2i(13, 25),
		Vector2i(14, 25),
		Vector2i(15, 25),
		Vector2i(16, 25),
		Vector2i(17, 25),
	],
}
const CEMETERY_FENCE_CELLS := [
	Vector2i(30, 5),
	Vector2i(31, 5),
	Vector2i(32, 5),
	Vector2i(33, 5),
	Vector2i(34, 5),
	Vector2i(35, 5),
	Vector2i(36, 5),
	Vector2i(37, 5),
	Vector2i(38, 5),
	Vector2i(39, 5),
	Vector2i(40, 5),
	Vector2i(41, 5),
	Vector2i(42, 5),
	Vector2i(43, 5),
	Vector2i(30, 6),
	Vector2i(43, 6),
	Vector2i(30, 7),
	Vector2i(43, 7),
	Vector2i(30, 8),
	Vector2i(43, 8),
	Vector2i(30, 9),
	Vector2i(43, 9),
	Vector2i(30, 10),
	Vector2i(43, 10),
	Vector2i(30, 11),
	Vector2i(43, 11),
	Vector2i(30, 12),
	Vector2i(43, 12),
	Vector2i(30, 13),
	Vector2i(43, 13),
	Vector2i(30, 14),
	Vector2i(43, 14),
	Vector2i(30, 15),
	Vector2i(43, 15),
	Vector2i(43, 16),
	Vector2i(30, 17),
	Vector2i(43, 17),
	Vector2i(30, 18),
	Vector2i(43, 18),
	Vector2i(30, 19),
	Vector2i(31, 19),
	Vector2i(32, 19),
	Vector2i(33, 19),
	Vector2i(34, 19),
	Vector2i(35, 19),
	Vector2i(36, 19),
	Vector2i(37, 19),
	Vector2i(38, 19),
	Vector2i(40, 19),
	Vector2i(41, 19),
	Vector2i(42, 19),
	Vector2i(43, 19),
]
const CEMETERY_GATE_GAPS := [
	Vector2i(30, 16),
	Vector2i(39, 19),
]
const GRAVE_AISLE_CELLS := [
	Vector2i(35, 6),
	Vector2i(35, 7),
	Vector2i(35, 8),
	Vector2i(35, 9),
	Vector2i(35, 10),
	Vector2i(35, 11),
	Vector2i(35, 12),
	Vector2i(35, 13),
	Vector2i(35, 14),
	Vector2i(35, 15),
	Vector2i(35, 16),
	Vector2i(35, 17),
	Vector2i(35, 18),
	Vector2i(39, 6),
	Vector2i(39, 7),
	Vector2i(39, 8),
	Vector2i(39, 9),
	Vector2i(39, 10),
	Vector2i(39, 11),
	Vector2i(39, 12),
	Vector2i(39, 13),
	Vector2i(39, 14),
	Vector2i(39, 15),
	Vector2i(39, 16),
	Vector2i(39, 17),
	Vector2i(39, 18),
	Vector2i(31, 12),
	Vector2i(32, 12),
	Vector2i(33, 12),
	Vector2i(34, 12),
	Vector2i(36, 12),
	Vector2i(37, 12),
	Vector2i(38, 12),
	Vector2i(40, 12),
	Vector2i(41, 12),
	Vector2i(42, 12),
]
const RELOCATED_GRAVES := {
	Vector2i(32, 7): Vector2i(1, 3),
	Vector2i(37, 7): Vector2i(2, 3),
	Vector2i(41, 7): Vector2i(3, 3),
	Vector2i(32, 15): Vector2i(0, 3),
	Vector2i(37, 15): Vector2i(2, 3),
	Vector2i(41, 15): Vector2i(1, 3),
}


func _ready() -> void:
	var map := get_parent()
	if map == null:
		return
	map.ready.connect(_apply_zoning.bind(map), CONNECT_ONE_SHOT)


func _apply_zoning(map: Node) -> void:
	var ground := map.get_node_or_null("ground") as TileMapLayer
	var paths := map.get_node_or_null("paths") as TileMapLayer
	var objects := map.get_node_or_null("objects_y_sorted") as TileMapLayer
	if ground == null or paths == null or objects == null:
		return

	for atlas_cell in WORKSHOP_SOIL_CELLS:
		_paint_cells(ground, WORKSHOP_SOIL_CELLS[atlas_cell], atlas_cell)

	for gate_gap in CEMETERY_GATE_GAPS:
		objects.erase_cell(gate_gap)
	for aisle_cell in GRAVE_AISLE_CELLS:
		objects.erase_cell(aisle_cell)
		paths.set_cell(aisle_cell, ART_SOURCE, AISLE_TILE)

	_paint_cells(objects, CEMETERY_FENCE_CELLS, FENCE_TILE)
	for grave_cell in RELOCATED_GRAVES:
		objects.set_cell(grave_cell, ART_SOURCE, RELOCATED_GRAVES[grave_cell])


func _paint_cells(layer: TileMapLayer, cells: Array, atlas_cell: Vector2i) -> void:
	for raw_cell in cells:
		layer.set_cell(raw_cell as Vector2i, ART_SOURCE, atlas_cell)
