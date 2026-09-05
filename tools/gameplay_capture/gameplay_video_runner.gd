extends SceneTree

const VIEWPORT_SIZE := Vector2i(1280, 720)
const WALK_SECONDS := 4.0
const RUN_SECONDS := 3.0
const PAUSE_SECONDS := 0.7

func _initialize() -> void:
	root.size = VIEWPORT_SIZE
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("Gameplay capture could not load main.tscn")
		quit(1)
		return
	var game := packed.instantiate()
	root.add_child(game)
	current_scene = game
	await process_frame
	await process_frame
	var player := get_first_node_in_group("player") as CharacterBody2D
	if player == null:
		push_error("Gameplay capture could not find the real player")
		quit(1)
		return
	await _hold_action("move_right", WALK_SECONDS)
	await _hold_actions(["move_down", "run"], RUN_SECONDS)
	await _hold_action("move_left", WALK_SECONDS)
	await _hold_actions(["move_up", "run"], RUN_SECONDS)
	await _hold_action("move_right", 2.5)
	await _tap_action("interact")
	await _wait_seconds(1.5)
	await _hold_action("move_down", 2.5)
	await _hold_actions(["move_right", "run"], RUN_SECONDS)
	await _hold_action("move_up", 2.5)
	await _tap_action("interact")
	await _wait_seconds(2.0)
	print("[GAMEPLAY_VIDEO] completed deterministic gameplay route")
	quit(0)

func _hold_action(action: StringName, seconds: float) -> void:
	Input.action_press(action)
	await _wait_seconds(seconds)
	Input.action_release(action)
	await _wait_seconds(PAUSE_SECONDS)

func _hold_actions(actions: Array[String], seconds: float) -> void:
	for action in actions:
		Input.action_press(action)
	await _wait_seconds(seconds)
	for action in actions:
		Input.action_release(action)
	await _wait_seconds(PAUSE_SECONDS)

func _tap_action(action: StringName) -> void:
	Input.action_press(action)
	await process_frame
	Input.action_release(action)
	await _wait_seconds(PAUSE_SECONDS)

func _wait_seconds(seconds: float) -> void:
	var elapsed := 0.0
	while elapsed < seconds:
		await process_frame
		elapsed += 1.0 / 60.0
