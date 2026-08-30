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
const EXPECTED_TILE_SIZE := Vector2i(32, 32)
const EXPECTED_WORLD_RECT := Rect2(Vector2.ZERO, Vector2(1600, 1024))


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_technical_map_contract(failures)
	_check_world_integration(failures)
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
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)

	for layer_name in REQUIRED_LAYERS:
		var layer := map.get_node_or_null(layer_name) as TileMapLayer
		if layer == null:
			failures.append("Technical map should expose TileMapLayer '%s'" % layer_name)
			continue
		if layer.tile_set == null or layer.tile_set.tile_size != EXPECTED_TILE_SIZE:
			failures.append("Layer '%s' should use the 32 px tile contract" % layer_name)

	if not map.has_method("get_world_rect"):
		failures.append("Technical map should expose stable world bounds")
	elif map.get_world_rect() != EXPECTED_WORLD_RECT:
		failures.append("Technical map bounds should align to the 32 px grid")

	var ground := map.get_node("ground") as TileMapLayer
	var paths := map.get_node("paths") as TileMapLayer
	var decoration := map.get_node("decoration_low") as TileMapLayer
	var collision := map.get_node("collision") as TileMapLayer
	var objects := map.get_node("objects_y_sorted") as TileMapLayer
	var foreground := map.get_node("foreground_occlusion") as TileMapLayer

	if ground.get_used_cells().is_empty():
		failures.append("Technical map ground should contain diagnostic tiles")
	if collision.get_used_cells().is_empty():
		failures.append("Technical map collision layer should contain tile obstacles")
	if collision.tile_set == null or collision.tile_set.get_physics_layers_count() < 1:
		failures.append("Technical collision tiles should define a physics layer")
	if ground.collision_enabled or paths.collision_enabled or decoration.collision_enabled:
		failures.append("Non-collision map layers should not create physics bodies")
	if not collision.collision_enabled:
		failures.append("Collision TileMapLayer should own map physics")
	if not objects.y_sort_enabled:
		failures.append("Tall map objects should use Y-sort")
	if foreground.z_index <= objects.z_index:
		failures.append("Foreground occlusion should render above Y-sorted objects")

	map.free()


static func _check_world_integration(failures: Array[String]) -> void:
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for map integration acceptance")
		return

	var world := world_scene.instantiate()
	var technical_map := world.get_node_or_null("TechnicalMap")
	if technical_map == null:
		failures.append("World should instance the technical TileMapLayer map")
	if world.get_node_or_null("Ground") != null:
		failures.append("Legacy Polygon2D ground should be replaced by the map foundation")
	if world.get_node_or_null("Boundaries") != null:
		failures.append("Legacy boundary blockout should be replaced by tile collision")
	if world.get_node_or_null("WorkshopBlock") != null:
		failures.append("Legacy workshop collision block should be replaced by tile collision")

	var player := world.get_node_or_null("Player") as PlayerController
	if player == null:
		failures.append("World should preserve the player after map integration")
	else:
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera == null:
			failures.append("Player camera should remain available")
		elif camera.limit_right > 1600 or camera.limit_bottom > 1024:
			failures.append("Camera limits should stay inside technical map bounds")

	var region := world.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	if region == null:
		failures.append("World should preserve NavigationRegion2D")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("NavigationRegion2D should remain usable after map integration")

	world.free()
