class_name TestWalkingPrototype
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []

	if not InputMap.has_action("run"):
		failures.append("Player controls should expose a run action")

	var player_scene := load("res://player/player.tscn") as PackedScene
	if player_scene == null:
		failures.append("Walking prototype should load player/player.tscn")
		return failures

	var player := player_scene.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
	if not player is CharacterBody2D:
		failures.append("Player scene root should be CharacterBody2D")
	else:
		var body := player.get_node_or_null("Body") as AnimatedSprite2D
		if body == null:
			failures.append("Player Body should be an AnimatedSprite2D visual")
		else:
			if body.sprite_frames == null:
				failures.append("Player Body should define SpriteFrames")
			else:
				for direction in ["n", "ne", "e", "se", "s", "sw", "w", "nw"]:
					var idle_name := StringName("idle_%s" % direction)
					var walk_name := StringName("walk_%s" % direction)
					var run_name := StringName("run_%s" % direction)
					var interact_name := StringName("interact_%s" % direction)
					if not body.sprite_frames.has_animation(idle_name):
						failures.append("Player should define %s" % idle_name)
					if not body.sprite_frames.has_animation(walk_name):
						failures.append("Player should define %s" % walk_name)
					if not body.sprite_frames.has_animation(run_name):
						failures.append("Player should define %s" % run_name)
					if not body.sprite_frames.has_animation(interact_name):
						failures.append("Player should define %s" % interact_name)
			if body.position != Vector2(0, 0):
				failures.append("Player visual pivot should remain at the feet/origin")
			if not body.has_method("set_locomotion_state"):
				failures.append("Player visual should expose idle/walk/run/interact locomotion state")
			else:
				body.call("set_locomotion_state", &"run", Vector2.DOWN)
				if body.animation != &"run_s":
					failures.append("Run state should play a dedicated directional run animation")
				body.call("set_locomotion_state", &"interact", Vector2.DOWN)
				if body.animation != &"interact_s":
					failures.append("Interact state should play a dedicated directional interaction animation")

		var interaction_area := player.get_node_or_null("InteractionArea")
		if not interaction_area is Area2D:
			failures.append("Player should expose an InteractionArea")
		if not player.has_method("get_facing_vector"):
			failures.append("Player controller should expose current facing for interactions")

		var collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collision == null or not collision.shape is CapsuleShape2D:
			failures.append("Player should preserve the capsule collision footprint")
		else:
			var capsule := collision.shape as CapsuleShape2D
			if (
				not is_equal_approx(capsule.radius, 10.0)
				or not is_equal_approx(capsule.height, 28.0)
			):
				failures.append("Player collision footprint should remain 20x28")

		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera == null:
			failures.append("Player should include a Camera2D")
		else:
			if not camera.position_smoothing_enabled:
				failures.append("Camera2D smoothing should be enabled")
			if (
				camera.limit_right <= camera.limit_left
				or camera.limit_bottom <= camera.limit_top
			):
				failures.append("Camera2D should have valid map limits")

	player.free()

	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("Walking prototype should load world/world.tscn")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	if not world.y_sort_enabled:
		failures.append("World should have Y-sort enabled")

	var world_player := world.get_node_or_null("Player")
	if not world_player is CharacterBody2D:
		failures.append("World should instance the player")

	var zone_manager := world.get_node_or_null("ZoneManager")
	var active_zone: Node = null
	if zone_manager != null and zone_manager.has_method("get_active_zone"):
		active_zone = zone_manager.call("get_active_zone") as Node
	var map_collision: TileMapLayer = null
	if active_zone != null:
		map_collision = active_zone.get_node_or_null("collision") as TileMapLayer
	if map_collision == null or map_collision.get_used_cells().is_empty():
		failures.append("Active world zone should provide tile-based collision boundaries")
	elif not map_collision.collision_enabled:
		failures.append("Active zone collision layer should have collision enabled")

	var sleep_spot: Node = null
	if active_zone != null:
		sleep_spot = active_zone.find_child("SleepSpot", true, false)
	if not sleep_spot is Interactable:
		failures.append("Active world zone should provide a functional Interactable")

	world.free()
	return failures
