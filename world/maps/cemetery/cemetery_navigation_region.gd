class_name CemeteryNavigationRegion
extends WorldNavigationRegion

var _uses_collision_grid := false


func _ready() -> void:
	ensure_navigation_polygon()
	call_deferred("ensure_navigation_polygon")


func ensure_navigation_polygon() -> void:
	var collision := _find_collision_layer()
	if collision != null and not collision.get_used_cells().is_empty():
		if not _uses_collision_grid:
			_build_from_collision_grid(collision)
		return
	if navigation_polygon == null:
		super.ensure_navigation_polygon()


func _find_collision_layer() -> TileMapLayer:
	var parent := get_parent()
	if parent == null:
		return null
	return parent.get_node_or_null("collision") as TileMapLayer


func _build_from_collision_grid(collision: TileMapLayer) -> void:
	if collision.tile_set == null:
		return
	var used_rect := collision.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return

	var polygon := NavigationPolygon.new()
	var vertices := PackedVector2Array()
	var vertex_indices: Dictionary = {}
	var half_tile := Vector2(collision.tile_set.tile_size) * 0.5

	for y in range(used_rect.position.y, used_rect.end.y):
		for x in range(used_rect.position.x, used_rect.end.x):
			var cell := Vector2i(x, y)
			if collision.get_cell_source_id(cell) != -1:
				continue
			var center := to_local(collision.to_global(collision.map_to_local(cell)))
			var top_left := center - half_tile
			var top_right := center + Vector2(half_tile.x, -half_tile.y)
			var bottom_right := center + half_tile
			var bottom_left := center + Vector2(-half_tile.x, half_tile.y)
			var indices := PackedInt32Array(
				[
					_vertex_index(top_left, vertices, vertex_indices),
					_vertex_index(top_right, vertices, vertex_indices),
					_vertex_index(bottom_right, vertices, vertex_indices),
					_vertex_index(bottom_left, vertices, vertex_indices),
				]
			)
			polygon.add_polygon(indices)

	polygon.vertices = vertices
	navigation_polygon = polygon
	_uses_collision_grid = true


func _vertex_index(point: Vector2, vertices: PackedVector2Array, indices: Dictionary) -> int:
	if indices.has(point):
		return int(indices[point])
	var index := vertices.size()
	vertices.append(point)
	indices[point] = index
	return index
