class_name TestSimulationAcceptance
extends RefCounted

const SAVE_PATH := "user://phase5_simulation_test.json"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var main_loop := Engine.get_main_loop() as SceneTree
	if main_loop == null:
		failures.append("SceneTree should exist for simulation acceptance")
		return failures

	var root := main_loop.root
	var save_manager := root.get_node_or_null("SaveManager")
	var time_manager := root.get_node_or_null("TimeManager")
	if save_manager == null or time_manager == null:
		failures.append("Simulation acceptance requires SaveManager and TimeManager")
		return failures

	var original_value: Variant = time_manager.call("snapshot")
	var original_time: Dictionary = (
		original_value if typeof(original_value) == TYPE_DICTIONARY else {}
	)
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for simulation acceptance")
		return failures

	var world := world_scene.instantiate()
	root.add_child(world)
	var aldren := world.get_node_or_null("BrotherAldren") as NPCController
	var day_night := world.get_node_or_null("DayNightCycle") as DayNightController
	var sleep_spot := world.get_node_or_null("SleepSpot") as SleepSpot
	var player := world.get_node_or_null("Player")
	if aldren == null or day_night == null or sleep_spot == null or player == null:
		failures.append("World should expose all Phase 5 simulation actors")
		_cleanup(world, time_manager, original_time)
		return failures

	var energy := player.call("get_energy_component") as EnergyComponent
	if energy == null:
		failures.append("Player should expose energy for the sleep flow")
		_cleanup(world, time_manager, original_time)
		return failures

	time_manager.call("set_day", 1)
	aldren.global_position = Vector2(1180, 650)
	time_manager.call("set_time", 9, 0)
	if aldren.get_current_state() != NPCStateMachine.WALKING:
		failures.append("Aldren should follow the work schedule at 09:00")
	if aldren.state_machine.pending_state != NPCStateMachine.WORKING:
		failures.append("Aldren should keep Working pending while walking")
	if day_night.current_phase != DayNightMath.phase_at(9, 0):
		failures.append("Day/night controller should follow TimeManager signals")

	var save_result: Variant = save_manager.call("save_game", SAVE_PATH)
	if not bool(save_result):
		failures.append("SaveManager should save world providers during Phase 5")
		_cleanup(world, time_manager, original_time)
		return failures

	var payload_value: Variant = save_manager.call("load_game", SAVE_PATH, false)
	var payload: Dictionary = payload_value if typeof(payload_value) == TYPE_DICTIONARY else {}
	var world_data: Dictionary = payload.get("world", {})
	if not world_data.has("npc:brother_aldren"):
		failures.append("Save payload should contain Aldren under a stable NPC key")

	aldren.global_position = Vector2(300, 300)
	aldren.state_machine.set_activity(NPCStateMachine.IDLE)
	aldren.navigation_started = false
	var load_result: Variant = save_manager.call("load_game", SAVE_PATH, true)
	if typeof(load_result) != TYPE_DICTIONARY:
		failures.append("SaveManager should load the Phase 5 payload")
	if not aldren.global_position.is_equal_approx(Vector2(1180, 650)):
		failures.append("NPC load should restore position")
	if aldren.get_current_state() != NPCStateMachine.WALKING:
		failures.append("NPC load should restore Walking state")
	if aldren.state_machine.pending_state != NPCStateMachine.WORKING:
		failures.append("NPC load should restore the pending activity")
	if not aldren.navigation_started:
		failures.append("NPC load should resume an in-progress route")
	var agent := aldren.get_navigation_agent()
	if agent == null or not agent.target_position.is_equal_approx(Vector2(1280, 650)):
		failures.append("NPC load should restore the navigation target")

	time_manager.call("set_time", 23, 0)
	if aldren.get_current_state() != NPCStateMachine.WALKING:
		failures.append("Future time changes should govern the restored NPC")
	if aldren.state_machine.pending_state != NPCStateMachine.SLEEPING:
		failures.append("Night schedule should set Sleeping as pending state")
	if day_night.current_phase != &"night":
		failures.append("World should enter the night visual phase at 23:00")

	energy.current_energy = 10
	sleep_spot.interact(player)
	if int(time_manager.get("day")) != 2:
		failures.append("Sleeping should advance the simulation to the next day")
	if int(time_manager.get("hour")) != 6 or int(time_manager.get("minute")) != 0:
		failures.append("Sleeping should wake the player at 06:00")
	if energy.current_energy != energy.max_energy:
		failures.append("Sleeping should restore player energy")
	if aldren.get_current_state() != NPCStateMachine.IDLE:
		failures.append("NPC routine should update after the sleep time jump")
	if day_night.current_phase != &"dawn":
		failures.append("Day/night cycle should update after sleeping")

	_cleanup(world, time_manager, original_time)
	return failures


static func _cleanup(world: Node, time_manager: Node, original_time: Dictionary) -> void:
	if world.get_parent() != null:
		world.get_parent().remove_child(world)
	world.free()
	if not original_time.is_empty():
		time_manager.call("apply_snapshot", original_time)
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
