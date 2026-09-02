class_name PlayerController
extends CharacterBody2D

@export var max_speed: float = 220.0
@export var run_speed_multiplier: float = 1.45
@export var acceleration: float = 1200.0
@export var deceleration: float = 1500.0
@export var interaction_pose_duration: float = 0.18
@export var equipped_tool_id: StringName = &"axe"

var _facing_vector := Vector2.DOWN
var _interaction_pose_remaining := 0.0

@onready var interaction_area: Area2D = $InteractionArea
@onready var player_visual: PlayerVisual = $Body


func _enter_tree() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	_interaction_pose_remaining = maxf(_interaction_pose_remaining - delta, 0.0)
	var interaction_locked := _interaction_pose_remaining > 0.0
	var input_direction := PlayerMovement.input_direction()
	var movement_direction := Vector2.ZERO if interaction_locked else input_direction
	if not movement_direction.is_zero_approx():
		_facing_vector = movement_direction.normalized()

	var running := Input.is_action_pressed("run") and not movement_direction.is_zero_approx()
	var target_speed := PlayerMovement.speed_for_mode(max_speed, run_speed_multiplier, running)
	velocity = PlayerMovement.next_velocity(
		velocity, movement_direction, target_speed, acceleration, deceleration, delta
	)
	move_and_slide()

	var state := &"interact" if interaction_locked else &"idle"
	if not interaction_locked and not movement_direction.is_zero_approx():
		state = &"run" if running else &"walk"
	player_visual.set_locomotion_state(state, _facing_vector)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _interact_with_best_facing_target():
		_interaction_pose_remaining = interaction_pose_duration
		player_visual.set_locomotion_state(&"interact", _facing_vector)


func get_facing_vector() -> Vector2:
	return _facing_vector


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


func _interact_with_best_facing_target() -> bool:
	var candidates := interaction_area.get_overlapping_areas()
	if candidates.is_empty():
		return false

	var best_target: Interactable
	var best_score := INF
	for candidate in candidates:
		if candidate is not Interactable:
			continue
		var score := PlayerMovement.interaction_score(
			global_position, _facing_vector, candidate.global_position
		)
		if score < best_score:
			best_target = candidate as Interactable
			best_score = score

	if best_target == null:
		return false
	best_target.interact(self)
	return true
