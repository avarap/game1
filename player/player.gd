class_name PlayerController
extends CharacterBody2D

@export var max_speed: float = 220.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1500.0
@export_range(1.0, 2.0, 0.05) var sprint_multiplier: float = 1.45
@export var equipped_tool_id: StringName = &"axe"

@onready var interaction_area: Area2D = $InteractionArea

var _is_running := false


func _enter_tree() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	var direction := PlayerMovement.input_direction()
	_is_running = not direction.is_zero_approx() and Input.is_key_pressed(KEY_SHIFT)
	var speed_multiplier := sprint_multiplier if _is_running else 1.0
	velocity = PlayerMovement.next_velocity(
		velocity, direction, max_speed, acceleration, deceleration, delta, speed_multiplier
	)
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_interact_with_nearest()


func is_running() -> bool:
	return _is_running


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


func _interact_with_nearest() -> void:
	var candidates := interaction_area.get_overlapping_areas()
	if candidates.is_empty():
		return

	var nearest: Area2D
	var nearest_distance := INF
	for candidate in candidates:
		if candidate is Interactable:
			var distance := global_position.distance_squared_to(candidate.global_position)
			if distance < nearest_distance:
				nearest = candidate
				nearest_distance = distance

	if nearest != null:
		nearest.interact(self)
