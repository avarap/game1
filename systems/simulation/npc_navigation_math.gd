class_name NPCNavigationMath
extends RefCounted


static func velocity_toward(current: Vector2, next_position: Vector2, speed: float) -> Vector2:
	var offset := next_position - current
	if offset.length_squared() <= 0.0001 or speed <= 0.0:
		return Vector2.ZERO
	return offset.normalized() * speed


static func has_arrived(current: Vector2, target: Vector2, tolerance: float) -> bool:
	return current.distance_to(target) <= maxf(tolerance, 0.0)
