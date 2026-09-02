class_name PlayerMovement
extends RefCounted

const DIRECTION_NAMES: Array[StringName] = [
	&"e",
	&"se",
	&"s",
	&"sw",
	&"w",
	&"nw",
	&"n",
	&"ne",
]


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


static func should_use_run_state(current_velocity: Vector2, walk_speed: float) -> bool:
	return current_velocity.length() > walk_speed + 0.5


static func interaction_locked_velocity(_current_velocity: Vector2) -> Vector2:
	return Vector2.ZERO


static func direction_name(value: Vector2, fallback: StringName = &"s") -> StringName:
	if value.is_zero_approx():
		return fallback
	var angle := value.angle()
	var octant := int(round(angle / (PI / 4.0)))
	var direction_index := (octant + DIRECTION_NAMES.size()) % DIRECTION_NAMES.size()
	return DIRECTION_NAMES[direction_index]


static func direction_vector(direction_name_value: StringName) -> Vector2:
	var index := DIRECTION_NAMES.find(direction_name_value)
	if index < 0:
		return Vector2.DOWN
	return Vector2.RIGHT.rotated(float(index) * PI / 4.0).normalized()


static func interaction_score(
	origin: Vector2,
	target: Vector2,
	facing: Vector2,
	minimum_forward_dot: float = 0.15
) -> float:
	var offset := target - origin
	if offset.is_zero_approx():
		return 0.0
	var facing_normalized := facing.normalized()
	if facing_normalized.is_zero_approx():
		facing_normalized = Vector2.DOWN
	var forward_dot := facing_normalized.dot(offset.normalized())
	if forward_dot < minimum_forward_dot:
		return INF
	var distance_squared := offset.length_squared()
	return distance_squared / maxf(forward_dot, 0.01)
