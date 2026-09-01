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

	var sprinted := PlayerMovement.next_velocity(
		Vector2.ZERO, Vector2.RIGHT, 100.0, 300.0, 80.0, 1.0, 1.5
	)
	if not sprinted.is_equal_approx(Vector2(150.0, 0.0)):
		failures.append("PlayerMovement should apply the requested speed multiplier")

	var decelerated := PlayerMovement.next_velocity(
		Vector2(100.0, 0.0), Vector2.ZERO, 100.0, 50.0, 40.0, 1.0
	)
	if not decelerated.is_equal_approx(Vector2(60.0, 0.0)):
		failures.append("PlayerMovement should use deceleration when input stops")

	return failures
