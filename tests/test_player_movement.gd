class_name TestPlayerMovement
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []

	var accelerated := PlayerMovement.next_velocity(
		Vector2.ZERO, Vector2.RIGHT, 100.0, 50.0, 80.0, 1.0
	)
	if not accelerated.is_equal_approx(Vector2(50.0, 0.0)):
		failures.append("PlayerMovement should accelerate toward target speed")

	var capped := PlayerMovement.next_velocity(
		Vector2.ZERO, Vector2(2.0, 0.0), 100.0, 200.0, 80.0, 1.0
	)
	if not capped.is_equal_approx(Vector2(100.0, 0.0)):
		failures.append("PlayerMovement should normalize oversized input")

	var decelerated := PlayerMovement.next_velocity(
		Vector2(100.0, 0.0), Vector2.ZERO, 100.0, 50.0, 40.0, 1.0
	)
	if not decelerated.is_equal_approx(Vector2(60.0, 0.0)):
		failures.append("PlayerMovement should use deceleration when input stops")

	var movement_script := load("res://player/player_movement.gd") as GDScript
	var methods := movement_script.get_script_method_list()
	if not _has_method(methods, &"speed_for_mode"):
		failures.append("PlayerMovement should expose walk/run speed selection")
	if not _has_method(methods, &"direction_name"):
		failures.append("PlayerMovement should expose reusable 8-way orientation")

	return failures


static func _has_method(methods: Array[Dictionary], method_name: StringName) -> bool:
	for method in methods:
		if StringName(method.get("name", "")) == method_name:
			return true
	return false
