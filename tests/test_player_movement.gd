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

	var diagonal := PlayerMovement.next_velocity(
		Vector2.ZERO, Vector2(1.0, 1.0), 100.0, 1000.0, 80.0, 1.0
	)
	if not is_equal_approx(diagonal.length(), 100.0):
		failures.append("Diagonal movement should not be faster than cardinal movement")

	var decelerated := PlayerMovement.next_velocity(
		Vector2(100.0, 0.0), Vector2.ZERO, 100.0, 50.0, 40.0, 1.0
	)
	if not decelerated.is_equal_approx(Vector2(60.0, 0.0)):
		failures.append("PlayerMovement should use deceleration when input stops")

	var reversed := PlayerMovement.next_velocity(
		Vector2(100.0, 0.0), Vector2.LEFT, 100.0, 50.0, 80.0, 1.0
	)
	if reversed.x > 0.0:
		failures.append("PlayerMovement should cancel opposite momentum within one strong turn step")

	var interaction_stopped := PlayerMovement.interaction_locked_velocity(Vector2(100.0, 35.0))
	if not interaction_stopped.is_zero_approx():
		failures.append("Interaction lock should stop player movement immediately")

	if PlayerMovement.direction_name(Vector2.RIGHT) != &"e":
		failures.append("Facing should resolve east")
	if PlayerMovement.direction_name(Vector2(1.0, 1.0)) != &"se":
		failures.append("Facing should resolve southeast")
	if PlayerMovement.direction_name(Vector2(-1.0, -1.0)) != &"nw":
		failures.append("Facing should resolve northwest")

	var forward_score := PlayerMovement.interaction_score(
		Vector2.ZERO, Vector2(20.0, 0.0), Vector2.RIGHT, 0.15
	)
	var rear_score := PlayerMovement.interaction_score(
		Vector2.ZERO, Vector2(-10.0, 0.0), Vector2.RIGHT, 0.15
	)
	if not forward_score < INF:
		failures.append("Interactables in front of the player should be selectable")
	if rear_score != INF:
		failures.append("Interactables behind the player should not steal interaction focus")

	if not PlayerMovement.should_use_run_state(Vector2(120.0, 0.0), 100.0):
		failures.append("Run animation should persist while physical speed remains above walk speed")
	if PlayerMovement.should_use_run_state(Vector2(100.0, 0.0), 100.0):
		failures.append("Run animation should stop once physical speed reaches walk speed")

	var packed := load("res://player/player.tscn") as PackedScene
	if packed == null:
		failures.append("Production player scene should load for movement-state regression test")
		return failures
	var player := packed.instantiate() as PlayerController
	if player == null:
		failures.append("Production player scene should instantiate PlayerController")
		return failures
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(player)
	player.velocity = Vector2(60.0, 0.0)
	player._physics_process(0.0)
	if player.get_state() != PlayerController.State.WALK:
		failures.append("Player should stay in WALK while physical deceleration still has velocity")

	player.velocity = Vector2.ZERO
	Input.action_press("move_right")
	Input.action_press("run")
	player._physics_process(1.0 / 60.0)
	Input.action_release("run")
	Input.action_release("move_right")
	if player.velocity.length() >= player.max_speed:
		failures.append("Sprint acceleration regression setup should remain below walk speed")
	if player.get_state() != PlayerController.State.WALK:
		failures.append("Sprint should stay in WALK until physical speed reaches the run threshold")
	player.free()

	return failures
