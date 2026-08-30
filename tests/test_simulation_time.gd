class_name TestSimulationTime
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Simulation time test requires a SceneTree")
		return failures

	var time_manager := tree.root.get_node_or_null("TimeManager")
	var save_manager := tree.root.get_node_or_null("SaveManager")
	if time_manager == null or save_manager == null:
		failures.append("TimeManager and SaveManager autoloads should exist")
		return failures

	var original_time: Dictionary = time_manager.call("snapshot")

	time_manager.call("apply_snapshot", {"day": 1, "hour": 6, "minute": 0})
	if str(time_manager.call("get_weekday_name")) != "Día del Sol":
		failures.append("Day 1 should be Día del Sol")

	time_manager.call("apply_snapshot", {"day": 6, "hour": 23, "minute": 50})
	if str(time_manager.call("get_weekday_name")) != "Día del Comercio":
		failures.append("Day 6 should be Día del Comercio")
	time_manager.call("add_minutes", 20)
	if (
		int(time_manager.get("day")) != 7
		or int(time_manager.get("hour")) != 0
		or int(time_manager.get("minute")) != 10
	):
		failures.append("TimeManager should advance the day when minutes cross midnight")
	if str(time_manager.call("get_weekday_name")) != "Día del Sol":
		failures.append("Weekday should wrap after the six-day week")

	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("Simulation test should load world/world.tscn")
		time_manager.call("apply_snapshot", original_time)
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player")
	var zone_manager := world.get_node_or_null("ZoneManager")
	var active_zone: Node = null
	if zone_manager != null:
		active_zone = zone_manager.call("get_active_zone") as Node
	var sleep_spot: Node = null
	if active_zone != null:
		sleep_spot = active_zone.find_child("SleepSpot", true, false)
	var energy: EnergyComponent = null
	if player != null:
		energy = player.get_node_or_null("EnergyComponent") as EnergyComponent

	if not sleep_spot is SleepSpot:
		failures.append("Active cemetery zone should expose a SleepSpot interactable")
	if energy == null:
		failures.append("Player should expose EnergyComponent for sleep recovery")
	else:
		energy.spend(73)
		time_manager.call("apply_snapshot", {"day": 3, "hour": 22, "minute": 30})
		if sleep_spot is SleepSpot:
			sleep_spot.interact(player)
			if (
				int(time_manager.get("day")) != 4
				or int(time_manager.get("hour")) != 6
				or int(time_manager.get("minute")) != 0
			):
				failures.append("Sleeping should advance to the next day at 06:00")
			if energy.current_energy != energy.max_energy:
				failures.append("Sleeping should fully restore player energy")

	tree.root.remove_child(world)
	world.free()

	var save_path := "user://test_simulation_time.json"
	time_manager.call("apply_snapshot", {"day": 9, "hour": 21, "minute": 45})
	if not bool(save_manager.call("save_game", save_path, {"test": {"ok": true}})):
		failures.append("SaveManager should persist TimeManager snapshot")
	else:
		time_manager.call("apply_snapshot", {"day": 1, "hour": 6, "minute": 0})
		save_manager.call("load_game", save_path, false)
		if (
			int(time_manager.get("day")) != 9
			or int(time_manager.get("hour")) != 21
			or int(time_manager.get("minute")) != 45
		):
			failures.append("SaveManager should restore TimeManager snapshot")
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))

	time_manager.call("apply_snapshot", original_time)
	return failures
