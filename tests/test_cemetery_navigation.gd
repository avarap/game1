class_name TestCemeteryNavigation
extends RefCounted

const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")
const WALKABLE_POINTS := [
	Vector2(480, 736),
	Vector2(768, 608),
	Vector2(1088, 512),
	Vector2(1376, 704),
	Vector2(768, 128),
]
const BLOCKED_CELLS := [
	Vector2i(8, 17),
	Vector2i(29, 8),
	Vector2i(44, 10),
	Vector2i(19, 5),
]


static func run() -> Array[String]:
	var failures: Array[String] = []
	var map := CEMETERY_SCENE.instantiate() as Node2D
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	var region := map.get_node_or_null("NavigationRegion") as NavigationRegion2D
	if region == null:
		failures.append("Cemetery should expose a navigation region")
		map.free()
		return failures
	if region.has_method("ensure_navigation_polygon"):
		region.call("ensure_navigation_polygon")
	var polygon := region.navigation_polygon
	if polygon == null or polygon.get_polygon_count() == 0:
		failures.append("Cemetery navigation should contain walkable polygons")
		map.free()
		return failures

	for point in WALKABLE_POINTS:
		if not _navigation_contains_point(region, polygon, point):
			failures.append("Navigation should include authored route point %s" % point)

	var collision := map.get_node_or_null("collision") as TileMapLayer
	if collision == null:
		failures.append("Cemetery navigation contract requires collision layer")
	else:
		for cell in BLOCKED_CELLS:
			var point := collision.to_global(collision.map_to_local(cell))
			if _navigation_contains_point(region, polygon, point):
				failures.append("Navigation should exclude collision cell %s" % cell)

	map.free()
	return failures


static func _navigation_contains_point(
	region: NavigationRegion2D,
	polygon: NavigationPolygon,
	world_point: Vector2,
) -> bool:
	var local_point := region.to_local(world_point)
	var vertices := polygon.vertices
	for polygon_index in range(polygon.get_polygon_count()):
		var indices := polygon.get_polygon(polygon_index)
		var points := PackedVector2Array()
		for vertex_index in indices:
			points.append(vertices[vertex_index])
		if Geometry2D.is_point_in_polygon(local_point, points):
			return true
	return false
