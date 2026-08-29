class_name PlayerController
extends CharacterBody2D

@export var max_speed: float = 220.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1500.0

@onready var interaction_area: Area2D = $InteractionArea

func _physics_process(delta: float) -> void:
    var direction := PlayerMovement.input_direction()
    velocity = PlayerMovement.next_velocity(
        velocity,
        direction,
        max_speed,
        acceleration,
        deceleration,
        delta
    )
    move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("interact"):
        _interact_with_nearest()

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
