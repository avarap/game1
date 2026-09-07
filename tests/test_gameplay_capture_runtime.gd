extends "res://tools/gameplay_capture/gameplay_video_runner.gd"

var _test_failures: Array[String] = []
var _test_player: PlayerController
var _test_interactions := 0


func _run() -> void:
	var game := load("res://main.tscn").instantiate() as Node2D
	root.add_child(game)
	current_scene = game
	await physics_frame
	await physics_frame
	await process_frame
	_test_player = get_first_node_in_group("player") as PlayerController
	var chest := game.find_child("StorageChest", true, false) as StorageChest
	if _test_player == null or chest == null:
		push_error("Capture regression requires the real player and rebuilt-map chest")
		quit(1)
		return

	await _check_simulation_time()
	await _check_walk_and_run()
	await _check_real_interaction(chest)
	game.queue_free()
	await process_frame
	await process_frame
	if _test_failures.is_empty():
		print("[TEST] GameplayCaptureRuntime passed: timing, movement, run, interaction, release")
		quit(0)
		return
	for failure in _test_failures:
		push_error("[TEST] %s" % failure)
	quit(1)


func _check_simulation_time() -> void:
	var before := Engine.get_physics_frames()
	await _wait_seconds(0.1)
	var frames := Engine.get_physics_frames() - before
	if frames < 5 or frames > 8:
		_test_failures.append("Capture 0.1 seconds should use 5-8 physics ticks; got %d" % frames)


func _check_walk_and_run() -> void:
	_test_player.global_position = Vector2(560, 736)
	_test_player.velocity = Vector2.ZERO
	await physics_frame
	var start := _test_player.global_position
	await _hold_action("move_right", 0.25)
	var walk_distance := _test_player.global_position.x - start.x
	if walk_distance < 35.0:
		_test_failures.append("Capture walk must move the actual CharacterBody2D")
	_test_player.global_position = start
	_test_player.velocity = Vector2.ZERO
	await physics_frame
	await _hold_actions(["move_right", "run"], 0.25)
	var run_distance := _test_player.global_position.x - start.x
	if run_distance < walk_distance + 10.0:
		_test_failures.append("Capture run must move farther than walk over the same time")
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("run"):
		_test_failures.append("Capture movement must release all held actions")


func _check_real_interaction(chest: StorageChest) -> void:
	_test_player.global_position = chest.global_position + Vector2(0, -42)
	_test_player.velocity = Vector2.ZERO
	await _hold_action("move_down", 0.05)
	await physics_frame
	await physics_frame
	chest.interacted.connect(_record_test_interaction)
	await _tap_action("interact")
	if _test_interactions != 1:
		_test_failures.append("Capture tap must dispatch one real facing-target interaction")
	var feedback := chest.get_node("FeedbackLabel") as Label
	if feedback.text != "Cofre conectado":
		_test_failures.append("Capture tap must execute the real chest's interaction effect")
	if Input.is_action_pressed("interact"):
		_test_failures.append("Capture tap must release the interaction action")


func _record_test_interaction(actor: Node) -> void:
	if actor == _test_player:
		_test_interactions += 1
