extends SceneTree

const VIEWPORT_SIZE := Vector2i(1280, 720)
const WALK_SECONDS := 4.0
const RUN_SECONDS := 3.0
const PAUSE_SECONDS := 0.7

var _capture_player: CharacterBody2D
var _previous_position := Vector2.ZERO
var _walk_distance := 0.0
var _run_distance := 0.0
var _verified_interactions := 0


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
	_capture_player = player
	_previous_position = player.global_position
	physics_frame.connect(_observe_player)
	var chest := game.find_child("StorageChest", true, false) as StorageChest
	if chest == null:
		push_error("Gameplay capture requires the rebuilt map's real storage chest")
		quit(1)
		return
	chest.interacted.connect(_record_interaction)
	await _hold_action("move_down", 0.2)
	await _tap_action("interact")
	var feedback := chest.get_node("FeedbackLabel") as Label
	if _verified_interactions != 1 or feedback.text != "Cofre conectado":
		push_error("Gameplay capture did not complete its real chest interaction")
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
	var evidence := {
		"commit_sha": OS.get_environment("VISUAL_CAPTURE_SHA"),
		"walk_distance": _walk_distance,
		"run_distance": _run_distance,
		"verified_interactions": _verified_interactions,
		"interaction_target": "StorageChest",
		"interaction_effect": feedback.text,
	}
	print("[GAMEPLAY_VIDEO] evidence %s" % JSON.stringify(evidence))
	if _walk_distance < 100.0 or _run_distance < 100.0 or _verified_interactions < 1:
		push_error("Gameplay capture did not demonstrate walk, run and a real interaction")
		quit(1)
		return
	print("[GAMEPLAY_VIDEO] verified gameplay route completed")
	quit(0)


func _observe_player() -> void:
	if not is_instance_valid(_capture_player):
		return
	var distance := _capture_player.global_position.distance_to(_previous_position)
	if Input.is_action_pressed("run"):
		_run_distance += distance
	else:
		_walk_distance += distance
	_previous_position = _capture_player.global_position


func _record_interaction(actor: Node) -> void:
	if actor == _capture_player:
		_verified_interactions += 1


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
	var press := InputEventAction.new()
	press.action = action
	press.pressed = true
	press.strength = 1.0
	Input.parse_input_event(press)
	await physics_frame
	var release := InputEventAction.new()
	release.action = action
	Input.parse_input_event(release)
	await _wait_seconds(PAUSE_SECONDS)


func _wait_seconds(seconds: float) -> void:
	await create_timer(seconds, true, true).timeout
