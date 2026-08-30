class_name TestMapVillage
extends RefCounted

const VILLAGE_MAP_PATH := "res://world/maps/village/village_map.tscn"
const REQUIRED_LAYERS := [
	"ground",
	"paths",
	"decoration_low",
	"collision",
	"objects_y_sorted",
	"foreground_occlusion",
]
const REQUIRED_MARKERS := [
	"Entrance",
	"VillageSquare",
	"MerchantSpot",
	"InteriorAccess/Workshop",
	"InteriorAccess/Inn",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(VILLAGE_MAP_PATH):
		failures.append("Village map scene should exist")
		return failures

	var scene := load(VILLAGE_MAP_PATH) as PackedScene
	if scene == null:
		failures.append("Village map scene should load")
		return failures

	var village := scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(village)

	for layer_name in REQUIRED_LAYERS:
		var layer := village.get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			failures.append("Village should expose TileMapLayer '%s'" % layer_name)

	for marker_path in REQUIRED_MARKERS:
		if village.get_node_or_null(marker_path) == null:
			failures.append("Village should expose stable marker '%s'" % marker_path)

	var region := village.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("Village should provide a NavigationRegion2D")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("Village navigation polygon should be usable")

	if village.has_method("get_world_rect"):
		var world_rect := village.get_world_rect() as Rect2
		for marker_path in REQUIRED_MARKERS:
			var marker := village.get_node_or_null(marker_path) as Node2D
			if marker != null and not world_rect.has_point(marker.position):
				failures.append("Marker '%s' should stay inside village bounds" % marker_path)
	else:
		failures.append("Village should inherit stable map bounds")

	village.free()
	return failures
