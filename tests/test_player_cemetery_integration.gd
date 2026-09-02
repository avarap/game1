class_name TestPlayerCemeteryIntegration
extends RefCounted

const WORLD_SCENE := preload("res://world/world.tscn")


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world := WORLD_SCENE.instantiate() as Node2D
	tree.root.add_child(world)
	await tree.process_frame
	await tree.physics_frame

	var zone_manager := world.get_node_or_null("ZoneManager") as ZoneManager
	if zone_manager == null:
		failures.append("Production world must expose ZoneManager")
		world.free()
		return failures

	var map := zone_manager.get_active_zone()
	var player := world.get_node_or_null("Player") as PlayerController
	if map == null:
		failures.append("Production world must load an initial active zone")
	if zone_manager.get_active_zone_id() != &"cemetery":
		failures.append("Production world must boot into rebuilt cemetery")
	if player == null:
		failures.append("Production world must expose PlayerController")
	if map == null or player == null:
		world.free()
		return failures

	var spawn := map.get_node_or_null("PlayerSpawn") as Marker2D
	if spawn == null:
		failures.append("Rebuilt cemetery must expose PlayerSpawn")
	elif not player.global_position.is_equal_approx(spawn.global_position):
		failures.append("ZoneManager must place Player at rebuilt cemetery PlayerSpawn")

	if not player.has_method("get_state"):
		failures.append("Integrated player must expose explicit movement states")
	if not player.has_method("get_facing_name"):
		failures.append("Integrated player must expose stable 8-direction facing")

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		failures.append("Integrated player must expose its production Camera2D")
	elif map.has_method("get_world_rect"):
		var world_rect: Rect2 = map.get_world_rect()
		if camera.limit_left != int(world_rect.position.x):
			failures.append("ZoneManager must configure camera left limit from active map bounds")
		if camera.limit_top != int(world_rect.position.y):
			failures.append("ZoneManager must configure camera top limit from active map bounds")
		if camera.limit_right != int(world_rect.end.x):
			failures.append("ZoneManager must configure camera right limit from active map bounds")
		if camera.limit_bottom != int(world_rect.end.y):
			failures.append("ZoneManager must configure camera bottom limit from active map bounds")
	else:
		failures.append("Rebuilt cemetery must expose world bounds for dynamic camera configuration")

	var collision := map.get_node_or_null("collision") as TileMapLayer
	if collision == null:
		failures.append("Rebuilt cemetery must expose collision layer")
	elif spawn != null:
		var cell := collision.local_to_map(collision.to_local(player.global_position))
		if collision.get_cell_source_id(cell) != -1:
			failures.append("Player must spawn on a physically traversable cemetery cell")

	for path in [
		"WorkshopArea/Workbench",
		"WorkshopArea/StorageChest",
		"WorkshopArea/SleepSpot",
		"CemeteryArea/CorpseDelivery",
		"CemeteryArea/PreparationTable",
		"CemeteryArea/GravePlot",
		"CemeteryArea/GraveUpgrade",
	]:
		var target := map.get_node_or_null(path) as Node2D
		if target == null:
			failures.append("Missing integrated interaction %s" % path)
			continue
		if collision != null:
			var target_cell := collision.local_to_map(collision.to_local(target.global_position))
			if collision.get_cell_source_id(target_cell) != -1:
				failures.append("Interaction %s is embedded in collision" % path)

	var sleep_spot := map.get_node_or_null("WorkshopArea/SleepSpot") as Interactable
	if sleep_spot == null:
		failures.append("Cemetery SleepSpot must be a production Interactable")
	else:
		player.set_physics_process(false)
		player.global_position = sleep_spot.global_position
		await tree.physics_frame
		await tree.physics_frame
		var overlaps := player.interaction_area.get_overlapping_areas()
		if not overlaps.has(sleep_spot):
			failures.append("Player InteractionArea must physically overlap the cemetery SleepSpot")
		else:
			var interacted_targets: Array[Interactable] = []
			player.interaction_started.connect(
				func(target: Interactable) -> void: interacted_targets.append(target)
			)
			player.velocity = Vector2(100.0, 0.0)
			var event := InputEventAction.new()
			event.action = &"interact"
			event.pressed = true
			player._unhandled_input(event)
			if player.get_state() != PlayerController.State.INTERACT:
				failures.append("Player must enter INTERACT against a real cemetery interactable")
			if not player.velocity.is_zero_approx():
				failures.append("Player must stop immediately when interacting on the real map")
			if interacted_targets.is_empty() or interacted_targets[0] != sleep_spot:
				failures.append("Player must dispatch interaction to the overlapped cemetery SleepSpot")

	world.free()
	return failures
