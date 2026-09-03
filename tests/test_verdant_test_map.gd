class_name TestVerdantTestMap
extends RefCounted

const PLAYER_SCENE := preload("res://player/player.tscn")
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
	var production_player := PLAYER_SCENE.instantiate() as PlayerController
	var original_frames := (
		(production_player.get_node("Body") as AnimatedSprite2D).sprite_frames.duplicate(true)
		as SpriteFrames
	)
	production_player.free()
	var map := packed.instantiate() as Node2D
	map.set("asset_directory", "user://missing_verdant_test_assets")
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(map)
	_check_map(map, failures)
	if map.get("uses_verdant_assets") != false:
		failures.append("Missing PNGs must select the fallback renderer")
	_check_walk_cycle(map, original_frames, failures)
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
	# The production controller starts facing down; position above the target instead
	# of sending movement actions to _unhandled_input(), which only handles interaction.
	player.position = harvest_tree.position + Vector2(0, -32)
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
	var art := harvest_tree.get_node("Art") as Sprite2D
	var standing_texture := art.texture
	var collider := (
		harvest_tree.find_children("*", "CollisionShape2D", false, false)[0] as CollisionShape2D
	)
	var footprint := (collider.shape as RectangleShape2D).size
	for hit in range(2):
		player._unhandled_input(event)
	await tree.create_timer(0.6).timeout
	if art.texture == standing_texture or art.get_rect().size.y * art.scale.y > 48:
		failures.append("A depleted tree must visibly become a short stump")
	if (collider.shape as RectangleShape2D).size != footprint or collider.disabled:
		failures.append("Visual depletion must retain the trunk collision footprint")
	player._unhandled_input(event)
	if player.get_inventory_component().count_item(&"wood") != 6:
		failures.append("A depleted tree must not give additional wood")
	if player.get_energy_component().current_energy != 88:
		failures.append("Visual feedback must not duplicate energy costs")


static func _check_walk_cycle(
	map: Node2D, original_frames: SpriteFrames, failures: Array[String]
) -> void:
	var production_player := PLAYER_SCENE.instantiate() as PlayerController
	var production_frames := (production_player.get_node("Body") as AnimatedSprite2D).sprite_frames
	var body := map.get_node("Objects/Player/Body") as AnimatedSprite2D
	if production_frames == body.sprite_frames:
		failures.append("Test walking must not mutate the shared production player frames")
	production_player.free()
	for direction in ["n", "ne", "e", "se", "s", "sw", "w", "nw"]:
		var animation := StringName("walk_" + direction)
		if (
			production_frames.get_frame_count(animation)
			!= original_frames.get_frame_count(animation)
		):
			failures.append("Test scene changed shared production walk frames for " + direction)
		if body.sprite_frames.get_frame_count(animation) < 6:
			failures.append("Test scene walking needs articulated frames for " + direction)
			continue
		var first := body.sprite_frames.get_frame_texture(animation, 0).get_image()
		var opposite := body.sprite_frames.get_frame_texture(animation, 4).get_image()
		if first.get_data() == opposite.get_data():
			failures.append("Opposite strides must visibly differ for " + direction)


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
	fixture.fill(Color("91633f"))
	fixture.save_png(directory.path_join("stump.png"))
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
	var paths := map.get_node("Paths") as TileMapLayer
	var path_source := (
		paths.tile_set.get_source(paths.get_cell_source_id(Vector2i(15, 11))) as TileSetAtlasSource
	)
	var path_coords := paths.get_cell_atlas_coords(Vector2i(15, 11)) * 32 + Vector2i(16, 16)
	if path_source.texture.get_image().get_pixelv(path_coords) != Color("a87d51"):
		failures.append("Local dirt must be rendered in the path atlas")
	var has_cutout_edge := false
	for cell in paths.get_used_cells():
		var region := Rect2i(paths.get_cell_atlas_coords(cell) * 32, Vector2i(32, 32))
		if path_source.texture.get_image().get_region(region).detect_alpha() == Image.ALPHA_BIT:
			has_cutout_edge = true
			break
	if not has_cutout_edge:
		failures.append("Used path edges must reveal grass beneath the curved outline")
	for prop_name in ["Tree0", "Rock0"]:
		var sprite := map.get_node("Objects/%s/Art" % prop_name) as Sprite2D
		var color := Color("203e28") if prop_name == "Tree0" else Color("676969")
		var expected_scale := Vector2(4, 4) if prop_name == "Tree0" else Vector2(2, 2)
		if sprite.texture.get_image().get_pixel(4, 4) != color or sprite.scale != expected_scale:
			failures.append("Local %s must use its PNG at the documented scale" % prop_name)
	await _check_physics_and_interaction(map, failures)
	var stump := map.get_node("Objects/HarvestTree/Art") as Sprite2D
	if stump.texture.get_image().get_pixel(4, 4) != Color("91633f"):
		failures.append("Depletion must use the local stump PNG when available")
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
