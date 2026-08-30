class_name NPCController
extends CharacterBody2D

signal destination_reached
signal state_changed(state: StringName)

@export var data: NPCData
@export var schedule: ScheduleData
@export var initial_target: Vector2 = Vector2.ZERO
@export var auto_start: bool = true

var navigation_started: bool = false
var state_machine := NPCStateMachine.new()
var _time_manager: Node
var _event_bus: Node

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _enter_tree() -> void:
	if data != null and not data.id.is_empty():
		add_to_group("save_provider")
	_resolve_time_dependencies()


func _ready() -> void:
	if data == null:
		push_warning("NPCController requires NPCData")
		return
	if schedule != null and _time_manager != null:
		apply_current_schedule()
		return
	if auto_start and initial_target != Vector2.ZERO:
		call_deferred("set_destination", initial_target)


func _physics_process(_delta: float) -> void:
	var agent := get_navigation_agent()
	if data == null or not navigation_started or agent == null:
		velocity = Vector2.ZERO
		return
	if agent.is_navigation_finished():
		_stop_navigation()
		return

	var next_position := agent.get_next_path_position()
	velocity = NPCNavigationMath.velocity_toward(global_position, next_position, data.move_speed)
	move_and_slide()


func set_destination(target: Vector2) -> void:
	var agent := get_navigation_agent()
	if agent == null:
		navigation_started = false
		return
	agent.target_position = target
	navigation_started = true


func apply_current_schedule() -> void:
	if schedule == null or _time_manager == null:
		return
	var weekday_index := int(_time_manager.call("get_weekday_index"))
	var hour := int(_time_manager.get("hour"))
	var minute := int(_time_manager.get("minute"))
	apply_schedule(weekday_index, hour, minute)


func apply_schedule(weekday_index: int, hour: int, minute: int) -> void:
	if schedule == null:
		return
	var agent := get_navigation_agent()
	if agent == null:
		return
	var entry := schedule.find_entry(weekday_index, hour, minute)
	if entry == null:
		_set_activity_state(NPCStateMachine.IDLE)
		return

	var needs_movement := not NPCNavigationMath.has_arrived(
		global_position, entry.target_position, agent.target_desired_distance
	)
	var previous_state := state_machine.current_state
	state_machine.begin_route(entry.activity_state, needs_movement)
	if needs_movement:
		set_destination(entry.target_position)
	else:
		navigation_started = false
		velocity = Vector2.ZERO
	_emit_state_change(previous_state)


func get_navigation_agent() -> NavigationAgent2D:
	if navigation_agent != null:
		return navigation_agent
	return get_node_or_null("NavigationAgent2D") as NavigationAgent2D


func get_current_state() -> StringName:
	return state_machine.current_state


func get_save_key() -> String:
	if data == null or data.id.is_empty():
		return "npc:unknown"
	return "npc:%s" % str(data.id)


func get_save_data() -> Dictionary:
	var npc_id: String = ""
	if data != null:
		npc_id = str(data.id)
	var result := {
		"id": npc_id,
		"position": _vector_to_data(global_position),
		"current_state": str(state_machine.current_state),
		"pending_state": str(state_machine.pending_state),
		"navigation_started": navigation_started,
	}
	var agent := get_navigation_agent()
	if navigation_started and agent != null:
		result["target_position"] = _vector_to_data(agent.target_position)
	return result


func apply_save_data(save_data: Dictionary) -> void:
	if data == null:
		return
	var saved_id := StringName(str(save_data.get("id", "")))
	if saved_id != data.id:
		return

	var position_value: Variant = save_data.get("position", {})
	var position_data: Dictionary = (
		position_value if typeof(position_value) == TYPE_DICTIONARY else {}
	)
	if not position_data.is_empty():
		global_position = _vector_from_data(position_data)

	var previous_state := state_machine.current_state
	state_machine.apply_snapshot(save_data)
	navigation_started = false
	velocity = Vector2.ZERO

	var target_value: Variant = save_data.get("target_position", {})
	var target_data: Dictionary = target_value if typeof(target_value) == TYPE_DICTIONARY else {}
	var should_resume_navigation := (
		state_machine.current_state == NPCStateMachine.WALKING
		and bool(save_data.get("navigation_started", false))
		and not target_data.is_empty()
	)
	if should_resume_navigation:
		set_destination(_vector_from_data(target_data))
		if not navigation_started:
			state_machine.arrive()
	elif state_machine.current_state == NPCStateMachine.WALKING:
		state_machine.arrive()

	_emit_state_change(previous_state)


func _resolve_time_dependencies() -> void:
	_time_manager = get_node_or_null("/root/TimeManager")
	_event_bus = get_node_or_null("/root/EventBus")
	if _event_bus == null:
		return
	if not _event_bus.is_connected("time_changed", Callable(self, "_on_time_changed")):
		_event_bus.connect("time_changed", Callable(self, "_on_time_changed"))
	if not _event_bus.is_connected("day_changed", Callable(self, "_on_day_changed")):
		_event_bus.connect("day_changed", Callable(self, "_on_day_changed"))


func _on_time_changed(_hour: int, _minute: int) -> void:
	apply_current_schedule()


func _on_day_changed(_day: int) -> void:
	apply_current_schedule()


func _set_activity_state(state: StringName) -> void:
	var previous_state := state_machine.current_state
	state_machine.set_activity(state)
	navigation_started = false
	velocity = Vector2.ZERO
	_emit_state_change(previous_state)


func _stop_navigation() -> void:
	if not navigation_started:
		return
	var previous_state := state_machine.current_state
	navigation_started = false
	velocity = Vector2.ZERO
	state_machine.arrive()
	_emit_state_change(previous_state)
	destination_reached.emit()


func _emit_state_change(previous_state: StringName) -> void:
	if previous_state != state_machine.current_state:
		state_changed.emit(state_machine.current_state)


func _vector_to_data(value: Vector2) -> Dictionary:
	return {"x": value.x, "y": value.y}


func _vector_from_data(value: Dictionary) -> Vector2:
	return Vector2(float(value.get("x", 0.0)), float(value.get("y", 0.0)))
