class_name NPCStateMachine
extends RefCounted

const IDLE: StringName = &"Idle"
const WALKING: StringName = &"Walking"
const WORKING: StringName = &"Working"
const SLEEPING: StringName = &"Sleeping"

var current_state: StringName = IDLE
var pending_state: StringName = IDLE


static func is_activity_state(state: StringName) -> bool:
	return state == IDLE or state == WORKING or state == SLEEPING


static func is_state(state: StringName) -> bool:
	return state == WALKING or is_activity_state(state)


func begin_route(destination_state: StringName, needs_movement: bool) -> void:
	pending_state = destination_state if is_activity_state(destination_state) else IDLE
	current_state = WALKING if needs_movement else pending_state


func arrive() -> void:
	current_state = pending_state


func set_activity(state: StringName) -> void:
	pending_state = state if is_activity_state(state) else IDLE
	current_state = pending_state


func snapshot() -> Dictionary:
	return {
		"current_state": str(current_state),
		"pending_state": str(pending_state),
	}


func apply_snapshot(data: Dictionary) -> void:
	var saved_pending := StringName(str(data.get("pending_state", IDLE)))
	var saved_current := StringName(str(data.get("current_state", saved_pending)))
	pending_state = saved_pending if is_activity_state(saved_pending) else IDLE
	if saved_current == WALKING:
		current_state = WALKING
		return
	if is_activity_state(saved_current):
		current_state = saved_current
		pending_state = saved_current
		return
	current_state = pending_state
