class_name PlayerController
extends CharacterBody2D

enum State {
	IDLE,
	WALK,
	RUN,
	INTERACT,
}

signal state_changed(state: State)
signal interaction_started(target: Interactable)

@export var max_speed: float = 220.0
@export var run_speed_multiplier: float = 1.45
@export var acceleration: float = 1200.0
@export var deceleration: float = 1500.0
@export_range(-1.0, 1.0, 0.05) var interaction_forward_dot: float = 0.15
@export_range(0.0, 1.0, 0.01) var interaction_lock_seconds: float = 0.16
@export var equipped_tool_id: StringName = &"axe"

@onready var interaction_area: Area2D = $InteractionArea

var _state: State = State.IDLE
var _facing: StringName = &"s"
var _interaction_lock_remaining: float = 0.0


func _enter_tree() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if _interaction_lock_remaining > 0.0:
		_interaction_lock_remaining = maxf(_interaction_lock_remaining - delta, 0.0)
		velocity = PlayerMovement.interaction_locked_velocity(velocity)
		move_and_slide()
		if _interaction_lock_remaining <= 0.0:
			_set_state(State.IDLE)
		return

	var direction := PlayerMovement.input_direction()
	if not direction.is_zero_approx():
		_facing = PlayerMovement.direction_name(direction, _facing)

	var running := not direction.is_zero_approx() and Input.is_action_pressed("run")
	var target_speed := max_speed * (run_speed_multiplier if running else 1.0)
	velocity = PlayerMovement.next_velocity(
		velocity, direction, target_speed, acceleration, deceleration, delta
	)
	move_and_slide()

	if direction.is_zero_approx():
		_set_state(State.IDLE)
	elif running:
		_set_state(State.RUN)
	else:
		_set_state(State.WALK)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _interaction_lock_remaining <= 0.0:
		_interact_with_facing_target()


func get_state() -> State:
	return _state


func get_facing_name() -> StringName:
	return _facing


func get_facing_vector() -> Vector2:
	return PlayerMovement.direction_vector(_facing)


func get_equipped_tool_id() -> StringName:
	return equipped_tool_id


func get_inventory_component() -> InventoryComponent:
	for child in get_children():
		if child is InventoryComponent:
			return child as InventoryComponent
	return null


func get_energy_component() -> EnergyComponent:
	for child in get_children():
		if child is EnergyComponent:
			return child as EnergyComponent
	return null


func _set_state(next_state: State) -> void:
	if _state == next_state:
		return
	_state = next_state
	state_changed.emit(_state)


func _interact_with_facing_target() -> void:
	var nearest := _find_facing_interactable()
	if nearest == null:
		return
	velocity = PlayerMovement.interaction_locked_velocity(velocity)
	_set_state(State.INTERACT)
	_interaction_lock_remaining = interaction_lock_seconds
	interaction_started.emit(nearest)
	nearest.interact(self)


func _find_facing_interactable() -> Interactable:
	var best: Interactable
	var best_score := INF
	var facing := get_facing_vector()
	for candidate in interaction_area.get_overlapping_areas():
		if candidate is not Interactable:
			continue
		var interactable := candidate as Interactable
		var score := PlayerMovement.interaction_score(
			global_position,
			interactable.global_position,
			facing,
			interaction_forward_dot
		)
		if score < best_score:
			best = interactable
			best_score = score
	return best
