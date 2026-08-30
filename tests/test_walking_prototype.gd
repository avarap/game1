class_name TestWalkingPrototype
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []

	var player_scene := load("res://player/player.tscn") as PackedScene
	if player_scene == null:
		failures.append("Walking prototype should load player/player.tscn")
		return failures

	var player := player_scene.instantiate()
	if not player is CharacterBody2D:
		failures.append("Player scene root should be CharacterBody2D")
	else:
		var interaction_area := player.get_node_or_null("InteractionArea")
		if not interaction_area is Area2D:
			failures.append("Player should expose an InteractionArea")

		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera == null:
			failures.append("Player should include a Camera2D")
		else:
			if not camera.position_smoothing_enabled:
				failures.append("Camera2D smoothing should be enabled")
			if camera.limit_right <= camera.limit_left or camera.limit_bottom <= camera.limit_top:
				failures.append("Camera2D should have valid map limits")

	player.free()

	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("Walking prototype should load world/world.tscn")
		return failures

	var world := world_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(world)
	if not world.y_sort_enabled:
		failures.append("World should have Y-sort enabled")

	var world_player := world.get_node_or_null("Player")
	if not world_player is CharacterBody2D:
		failures.append("World should instance the player")

	var map_collision := world.get_node_or_null("TechnicalMap/collision") as TileMapLayer
	if map_collision == null or map_collision.get_used_cells().is_empty():
		failures.append("World should provide tile-based collision boundaries")
	elif not map_collision.collision_enabled:
		failures.append("World map collision layer should have collision enabled")

	var debug_sign := world.get_node_or_null("DebugSign")
	if not debug_sign is Interactable:
		failures.append("World should provide at least one functional Interactable")

	world.free()
	return failures
