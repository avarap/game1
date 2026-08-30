class_name TestNPCRoutines
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_schedule_data(failures)
	_check_state_machine(failures)
	_check_world_npc_schedule(failures)
	return failures


static func _check_schedule_data(failures: Array[String]) -> void:
	var schedule := load("res://data/npcs/brother_aldren_schedule.tres") as ScheduleData
	if schedule == null or not schedule.is_valid():
		failures.append("Aldren schedule should load as valid ScheduleData")
		return

	_check_state_at(schedule, 0, 7, NPCStateMachine.IDLE, failures)
	_check_state_at(schedule, 0, 9, NPCStateMachine.WORKING, failures)
	_check_state_at(schedule, 0, 19, NPCStateMachine.IDLE, failures)
	_check_state_at(schedule, 0, 23, NPCStateMachine.SLEEPING, failures)
	_check_state_at(schedule, 0, 2, NPCStateMachine.SLEEPING, failures)


static func _check_state_at(
	schedule: ScheduleData,
	weekday_index: int,
	hour: int,
	expected: StringName,
	failures: Array[String]
) -> void:
	var entry := schedule.find_entry(weekday_index, hour, 0)
	if entry == null or entry.activity_state != expected:
		failures.append("Schedule should resolve %s at %02d:00" % [expected, hour])


static func _check_state_machine(failures: Array[String]) -> void:
	var machine := NPCStateMachine.new()
	machine.begin_route(NPCStateMachine.WORKING, true)
	if machine.current_state != NPCStateMachine.WALKING:
		failures.append("NPC should enter Walking while moving to a scheduled activity")
	machine.arrive()
	if machine.current_state != NPCStateMachine.WORKING:
		failures.append("NPC should enter Working after reaching its work destination")

	machine.begin_route(NPCStateMachine.SLEEPING, false)
	if machine.current_state != NPCStateMachine.SLEEPING:
		failures.append("NPC should enter Sleeping immediately when already at destination")


static func _check_world_npc_schedule(failures: Array[String]) -> void:
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for NPC routine acceptance")
		return
	var world := world_scene.instantiate()
	var aldren := world.get_node_or_null("BrotherAldren") as NPCController
	if aldren == null:
		failures.append("World should contain BrotherAldren as NPCController")
		world.free()
		return
	if aldren.schedule == null:
		failures.append("BrotherAldren should expose data-driven ScheduleData")
		world.free()
		return

	aldren.apply_schedule(0, 9, 0)
	if aldren.get_current_state() != NPCStateMachine.WALKING:
		failures.append("Aldren should walk toward his work destination at 09:00")
	if not aldren.get_navigation_agent().target_position.is_equal_approx(Vector2(1280, 650)):
		failures.append("Aldren work routine should target the configured work position")

	world.free()
