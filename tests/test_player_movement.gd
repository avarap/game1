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

	if not PlayerMovement.has_method("speed_for_mode"):
		failures.append("PlayerMovement should expose walk/run speed selection")
	else:
		var walk_speed: float = PlayerMovement.call("speed_for_mode", 220.0, 1.45, false)
		var run_speed: float = PlayerMovement.call("speed_for_mode", 220.0, 1.45, true)
		if not is_equal_approx(walk_speed, 220.0):
			failures.append("Walk mode should preserve base movement speed")
		if not is_equal_approx(run_speed, 319.0):
			failures.append("Run mode should apply the configured speed multiplier")

	if not PlayerMovement.has_method("direction_name"):
		failures.append("PlayerMovement should expose reusable eight-direction orientation")
	else:
		var samples := {
			Vector2.UP: &"n",
			Vector2(1.0, -1.0): &"ne",
			Vector2.RIGHT: &"e",
			Vector2(1.0, 1.0): &"se",
			Vector2.DOWN: &"s",
			Vector2(-1.0, 1.0): &"sw",
			Vector2.LEFT: &"w",
			Vector2(-1.0, -1.0): &"nw",
		}
		for direction: Vector2 in samples:
			var actual: StringName = PlayerMovement.call("direction_name", direction)
			if actual != samples[direction]:
				failures.append("Player orientation should resolve %s as %s" % [direction, samples[direction]])

	return failures
