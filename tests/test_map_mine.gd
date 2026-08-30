class_name TestMapMine
extends RefCounted

const MINE_MAP_PATH := "res://world/maps/mine/mine_map.tscn"
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
	"Exit",
	"MainCorridor",
	"SecondaryBranch",
	"SecretLandmark",
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(MINE_MAP_PATH):
		failures.append("Mine map scene should exist")
		return failures

	var packed := load(MINE_MAP_PATH) as PackedScene
	if packed == null:
		failures.append("Mine map scene should load")
		return failures

	var mine := packed.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(mine)

	for layer_name in REQUIRED_LAYERS:
		if mine.get_node_or_null(layer_name) as TileMapLayer == null:
			failures.append("Mine should expose TileMapLayer '%s'" % layer_name)

	var collision := mine.get_node_or_null("collision") as TileMapLayer
	for marker_path in REQUIRED_MARKERS:
		var marker := mine.get_node_or_null(marker_path) as Node2D
		if marker == null:
			failures.append("Mine should expose stable marker '%s'" % marker_path)
			continue
		if collision != null:
			var cell := collision.local_to_map(marker.position)
			if collision.get_cell_source_id(cell) != -1:
				failures.append("Mine marker '%s' should remain accessible" % marker_path)

	var region := mine.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("Mine should provide a NavigationRegion2D")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("Mine navigation polygon should be usable")

	var foreground := mine.get_node_or_null("foreground_occlusion") as TileMapLayer
	if foreground == null or foreground.get_used_cells().is_empty():
		failures.append("Mine should exercise foreground occlusion")

	var resources := mine.get_node_or_null("Resources")
	if resources == null or resources.get_child_count() < 2:
		failures.append("Mine should provide multiple collectible resources")
	else:
		for resource in resources.get_children():
			if resource.get_node_or_null("ResourceSourceComponent") == null:
				failures.append("Mine resources should reuse ResourceSourceComponent")

	mine.free()
	return failures
