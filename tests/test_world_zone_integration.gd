class_name TestWorldZoneIntegration
extends RefCounted

const WORLD_PATH := "res://world/world.tscn"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var packed := load(WORLD_PATH) as PackedScene
	if packed == null:
		failures.append("World scene should load for zone integration")
		return failures

	var world := packed.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(world)

	var player := world.get_node_or_null("Player") as Node2D
	var zone_manager := world.get_node_or_null("ZoneManager")
	if player == null:
		failures.append("World integration should keep a persistent Player")
	if zone_manager == null:
		failures.append("World integration should expose a local ZoneManager")
		world.free()
		return failures

	if not zone_manager.has_method("get_active_zone_id"):
		failures.append("ZoneManager should expose get_active_zone_id")
	elif zone_manager.call("get_active_zone_id") != &"cemetery":
		failures.append("World should start in the cemetery/property zone")

	if player != null:
		var original_id := player.get_instance_id()
		if not zone_manager.has_method("travel_to"):
			failures.append("ZoneManager should expose travel_to")
		else:
			var travelled := zone_manager.call("travel_to", &"forest", &"CemeteryEntrance") as bool
			if not travelled:
				failures.append("ZoneManager should travel from cemetery to forest")
			if player.get_instance_id() != original_id:
				failures.append("Zone travel should preserve the same Player instance")
			if zone_manager.call("get_active_zone_id") != &"forest":
				failures.append("ZoneManager should report forest after travel")

	world.free()
	return failures
