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


static func speed_for_mode(base_speed: float, run_multiplier: float, running: bool) -> float:
	return base_speed * run_multiplier if running else base_speed


static func direction_name(value: Vector2) -> StringName:
	if value.is_zero_approx():
		return &"s"
	var angle := value.angle()
	var octant := int(round(angle / (PI / 4.0)))
	var direction_index := (octant + DIRECTION_NAMES.size()) % DIRECTION_NAMES.size()
	return DIRECTION_NAMES[direction_index]


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
