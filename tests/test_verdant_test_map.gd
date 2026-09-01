class_name TestVerdantTestMap
extends RefCounted

const MAP_PATH := "res://world/maps/verdant_test/verdant_test_map.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(MAP_PATH):
		failures.append("Verdant A/B scene must load without any external assets")
		return failures
	var packed := load(MAP_PATH) as PackedScene
	if packed == null:
		failures.append("Verdant A/B scene must be a PackedScene")
		return failures
	var map := packed.instantiate() as Node2D
	map.set("asset_directory", "user://missing_verdant_test_assets")
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	_check_map(map, failures)
	if map.get("uses_verdant_assets") != false:
		failures.append("Missing PNGs must select the fallback renderer")
	await _check_physics_and_interaction(map, failures)
	map.free()
	await _check_local_pngs(packed, failures)
	return failures


static func _check_map(map: Node2D, failures: Array[String]) -> void:
	for required in ["Ground", "Paths", "Objects", "PlayerSpawn"]:
		if map.get_node_or_null(required) == null:
			failures.append("Verdant map requires %s" % required)
	var ground := map.get_node_or_null("Ground") as TileMapLayer
	if ground == null or ground.get_used_cells().size() != 600:
		failures.append("Verdant ground must cover 30 by 20 logical cells")
	var paths := map.get_node_or_null("Paths") as TileMapLayer
	if paths == null or paths.get_used_cells().size() < 80:
		failures.append("Verdant map needs a readable connected path")
	elif not _paths_are_connected(paths):
		failures.append("Both clearings and the workshop approach must connect to the lane")
	var player := map.get_node_or_null("Objects/Player") as PlayerController
	if player == null or player.scene_file_path != "res://player/player.tscn":
		failures.append("Verdant map must reuse the real player scene")
	elif player.get_inventory_component() == null or player.get_energy_component() == null:
		failures.append("Verdant player must retain gameplay components")
	elif player.position != (map.get_node("PlayerSpawn") as Marker2D).position:
		failures.append("Verdant player must start at PlayerSpawn")
	if ProjectSettings.get_setting("application/run/main_scene") != "res://main.tscn":
		failures.append("Verdant A/B test must not replace the main scene")
	if ground != null and ground.tile_set.tile_size != Vector2i(32, 32):
		failures.append("Verdant must preserve the 32 px logical grid")
	var objects := map.get_node("Objects") as Node2D
	if not objects.y_sort_enabled:
		failures.append("Props and the real player must share Y-sort")
	if player != null:
		var camera := player.get_node("Camera2D") as Camera2D
		if camera.zoom != Vector2(1.5, 1.5):
			failures.append("A/B map must retain gameplay camera zoom")
		if camera.limit_right != 960 or camera.limit_bottom != 640:
			failures.append("Camera must be bounded to the test map")


static func _paths_are_connected(paths: TileMapLayer) -> bool:
	var remaining := {}
	for cell in paths.get_used_cells():
		remaining[cell] = true
	var pending: Array[Vector2i] = [Vector2i(15, 11)]
	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()
		if not remaining.has(cell):
			continue
		remaining.erase(cell)
		for step in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
			pending.append(cell + step)
	return remaining.is_empty()


static func _check_physics_and_interaction(map: Node2D, failures: Array[String]) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var player := map.get_node("Objects/Player") as PlayerController
	player.set_physics_process(false)
	await tree.physics_frame
	await tree.physics_frame
	var spawn := player.position
	if player.test_move(player.global_transform, Vector2(64, 0)):
		failures.append("Player spawn and the main path must be clear")
	player.move_and_collide(Vector2(64, 0))
	if not player.position.is_equal_approx(spawn + Vector2(64, 0)):
		failures.append("Real player must be able to walk along the path")
	for obstacle_name in ["Tree0", "Rock0", "Workshop"]:
		var obstacle := map.get_node("Objects/" + obstacle_name) as StaticBody2D
		player.position = obstacle.position + Vector2(0, 64)
		var hit := player.move_and_collide(Vector2(0, -96))
		if hit == null or hit.get_collider() != obstacle:
			failures.append("Player must collide with %s footprint" % obstacle_name)
	player.position = Vector2(48, 368)
	if not player.test_move(player.global_transform, Vector2(-96, 0)):
		failures.append("World boundary must prevent leaving the test map")
	var harvest_tree := map.get_node("Objects/HarvestTree") as Node2D
	player.position = harvest_tree.position + Vector2(0, 32)
	await tree.physics_frame
	await tree.physics_frame
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	player._unhandled_input(event)
	if player.get_inventory_component().count_item(&"wood") != 2:
		failures.append("Real player interaction must harvest wood in the test map")
	if player.get_energy_component().current_energy != 96:
		failures.append("Harvest must use the real energy component")


static func _check_local_pngs(packed: PackedScene, failures: Array[String]) -> void:
	# Raw generated PNGs exercise loading without Godot import sidecars or licensed art.
	var directory := "user://verdant_fixture_%d" % Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	var fixture := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	fixture.fill(Color("365a39"))
	fixture.save_png(directory.path_join("grass_0.png"))
	var tree := Engine.get_main_loop() as SceneTree
	var map := packed.instantiate() as Node2D
	map.set("asset_directory", directory)
	tree.root.add_child(map)
	_check_map(map, failures)
	if map.get("uses_verdant_assets") != true:
		failures.append("A local loose grass PNG must activate Verdant rendering")
	var ground := map.get_node("Ground") as TileMapLayer
	var source := ground.tile_set.get_source(0) as TileSetAtlasSource
	if source.texture.get_image().get_pixel(4, 4) != Color("365a39"):
		failures.append("Ground must actually sample the local PNG")
	map.free()
	fixture.fill(Color("a87d51"))
	fixture.save_png(directory.path_join("dirt_0.png"))
	fixture.fill(Color("687b42"))
	fixture.save_png(directory.path_join("grass_1.png"))
	fixture.fill(Color("676969"))
	fixture.save_png(directory.path_join("rock.png"))
	fixture = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	fixture.fill(Color("203e28"))
	fixture.save_png(directory.path_join("tree.png"))
	map = packed.instantiate() as Node2D
	map.set("asset_directory", directory)
	tree.root.add_child(map)
	ground = map.get_node("Ground") as TileMapLayer
	source = ground.tile_set.get_source(0) as TileSetAtlasSource
	var atlas := source.texture.get_image()
	if atlas.get_pixel(36, 4) != Color("687b42"):
		failures.append("Local grass variants must retain their own pixels")
	if atlas.get_pixel(16, 48) != Color("a87d51"):
		failures.append("Local dirt must be rendered in the path atlas")
	if atlas.get_pixel(0, 32).a != 0.0:
		failures.append("Exposed dirt edges must reveal the grass beneath")
	for prop_name in ["Tree0", "Rock0"]:
		var sprite := map.get_node("Objects/%s/Art" % prop_name) as Sprite2D
		var color := Color("203e28") if prop_name == "Tree0" else Color("676969")
		if sprite.texture.get_image().get_pixel(4, 4) != color or sprite.scale != Vector2(2, 2):
			failures.append("Local %s must use its PNG at nearest 2x scale" % prop_name)
	await _check_physics_and_interaction(map, failures)
	map.free()
	map = packed.instantiate() as Node2D
	map.set("asset_directory", directory)
	map.set("use_local_assets", false)
	tree.root.add_child(map)
	if map.get("uses_verdant_assets") != false:
		failures.append("A/B fallback override must work even when local PNGs exist")
	map.free()
	# Malformed content and wrong dimensions should remain playable fallbacks.
	fixture = Image.create(8, 8, false, Image.FORMAT_RGBA8)
	fixture.save_png(directory.path_join("grass_0.png"))
	for invalid in [false, true]:
		if invalid:
			var file := FileAccess.open(directory.path_join("grass_0.png"), FileAccess.WRITE)
			file.store_string("not a PNG")
			file.close()
		map = packed.instantiate() as Node2D
		map.set("asset_directory", directory)
		tree.root.add_child(map)
		if map.get("uses_verdant_assets") != false:
			failures.append("Invalid local PNG must select a playable fallback")
		_check_map(map, failures)
		map.free()
	for filename in DirAccess.get_files_at(directory):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(directory.path_join(filename)))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(directory))
