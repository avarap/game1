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


func _ready() -> void:
	if data == null:
		push_warning("NPCController requires NPCData")
		return
	_resolve_time_dependencies()
	if schedule != null and _time_manager != null:
		apply_current_schedule()
		return
	if auto_start and initial_target != Vector2.ZERO:
		call_deferred("set_destination", initial_target)


func _physics_process(_delta: float) -> void:
	if data == null or not navigation_started:
		velocity = Vector2.ZERO
		return
	if navigation_agent.is_navigation_finished():
		_stop_navigation()
		return

	var next_position := navigation_agent.get_next_path_position()
	velocity = NPCNavigationMath.velocity_toward(global_position, next_position, data.move_speed)
	move_and_slide()


func set_destination(target: Vector2) -> void:
	navigation_agent.target_position = target
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
	var entry := schedule.find_entry(weekday_index, hour, minute)
	if entry == null:
		_set_activity_state(NPCStateMachine.IDLE)
		return

	var needs_movement := not NPCNavigationMath.has_arrived(
		global_position, entry.target_position, navigation_agent.target_desired_distance
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
	return navigation_agent


func get_current_state() -> StringName:
	return state_machine.current_state


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
