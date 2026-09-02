class_name TestPlayerCemeteryIntegration
extends RefCounted

const PLAYER_SCENE := preload("res://player/player.tscn")
const CEMETERY_SCENE := preload("res://world/maps/cemetery/cemetery_map.tscn")


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var map := CEMETERY_SCENE.instantiate()
	var player := PLAYER_SCENE.instantiate() as PlayerController
	tree.root.add_child(map)
	tree.root.add_child(player)

	var spawn := map.get_node_or_null("PlayerSpawn") as Marker2D
	if spawn == null:
		failures.append("Rebuilt cemetery must expose PlayerSpawn")
	else:
		player.global_position = spawn.global_position

	if not player.has_method("get_state"):
		failures.append("Integrated player must expose explicit movement states")
	if not player.has_method("get_facing_name"):
		failures.append("Integrated player must expose stable 8-direction facing")

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

	player.free()
	map.free()
	return failures
