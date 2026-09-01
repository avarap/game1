class_name TestCemeteryNavigation
extends RefCounted

const CEMETERY_MAP_PATH := "res://world/maps/cemetery/cemetery_map.tscn"
const MIN_WALKABLE_POLYGONS := 1000


static func run() -> Array[String]:
	var failures: Array[String] = []
	var packed := load(CEMETERY_MAP_PATH) as PackedScene
	if packed == null:
		failures.append("Cemetery navigation needs a loadable cemetery scene")
		return failures

	var map := packed.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	var region := map.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("Cemetery navigation region should exist")
	else:
		region.ensure_navigation_polygon()
		var polygon := region.navigation_polygon
		if polygon == null:
			failures.append("Cemetery navigation polygon should exist")
		elif polygon.get_polygon_count() < MIN_WALKABLE_POLYGONS:
			failures.append("Cemetery navigation should exclude authored collision cell by cell")

	map.free()
	return failures
