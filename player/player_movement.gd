class_name PlayerMovement
extends RefCounted


static func input_direction() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


static func next_velocity(
	current_velocity: Vector2,
	direction: Vector2,
	max_speed: float,
	acceleration: float,
	deceleration: float,
	delta: float
) -> Vector2:
	var normalized_direction := direction.limit_length(1.0)
	var target := normalized_direction * max_speed
	var rate := acceleration if not normalized_direction.is_zero_approx() else deceleration
	return current_velocity.move_toward(target, rate * delta)
