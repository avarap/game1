class_name WorldNavigationRegion
extends NavigationRegion2D

const NAVIGATION_MARGIN := 48.0
const WORLD_SIZE := Vector2(1600.0, 1000.0)


func _ready() -> void:
	ensure_navigation_polygon()


func ensure_navigation_polygon() -> void:
	if navigation_polygon != null:
		return

	var polygon := NavigationPolygon.new()
	polygon.vertices = PackedVector2Array(
		[
			Vector2(NAVIGATION_MARGIN, NAVIGATION_MARGIN),
			Vector2(WORLD_SIZE.x - NAVIGATION_MARGIN, NAVIGATION_MARGIN),
			Vector2(WORLD_SIZE.x - NAVIGATION_MARGIN, WORLD_SIZE.y - NAVIGATION_MARGIN),
			Vector2(NAVIGATION_MARGIN, WORLD_SIZE.y - NAVIGATION_MARGIN),
		]
	)
	polygon.add_polygon(PackedInt32Array([0, 1, 2, 3]))
	navigation_polygon = polygon
