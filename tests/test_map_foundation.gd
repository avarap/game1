class_name TestMapFoundation
extends RefCounted

const TECHNICAL_MAP_PATH := "res://world/maps/technical_map.tscn"
const REQUIRED_LAYERS := [
	"ground",
	"paths",
	"decoration_low",
	"collision",
	"objects_y_sorted",
	"foreground_occlusion",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_technical_map_contract(failures)
	return failures


static func _check_technical_map_contract(failures: Array[String]) -> void:
	if not ResourceLoader.exists(TECHNICAL_MAP_PATH):
		failures.append("Technical TileMapLayer map should exist")
		return

	var map_scene := load(TECHNICAL_MAP_PATH) as PackedScene
	if map_scene == null:
		failures.append("Technical map scene should load")
		return

	var map := map_scene.instantiate()
	for layer_name in REQUIRED_LAYERS:
		var layer := map.get_node_or_null(layer_name)
		if not layer is TileMapLayer:
			failures.append("Technical map should expose TileMapLayer '%s'" % layer_name)
	map.free()
