extends Node

const DEFAULT_MOVE_TOLERANCE := 18.0
const SETTLE_SPEED := 18.0
const CAPTURE_TIMEOUT_SECONDS := 25.0
const MOVEMENT_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
	&"run",
]
const STEPS: Array[Dictionary] = [
	{"kind": &"wait", "duration": 1.0, "label": "Spawn idle"},
	{"kind": &"move", "target": Vector2(544, 704), "run": false, "label": "Leave workshop apron"},
	{"kind": &"move", "target": Vector2(544, 576), "run": false, "label": "Join pilgrimage road"},
	{"kind": &"move", "target": Vector2(768, 544), "run": true, "label": "Run east"},
	{"kind": &"move", "target": Vector2(896, 448), "run": true, "label": "Climb cemetery approach"},
	{"kind": &"move", "target": Vector2(928, 352), "run": false, "label": "Enter cemetery loop"},
	{"kind": &"wait", "duration": 0.45, "label": "Show cemetery threshold"},
	{"kind": &"move", "target": Vector2(1344, 352), "run": true, "label": "Run upper cemetery loop"},
	{"kind": &"move", "target": Vector2(1344, 544), "run": false, "label": "Descend grave field"},
	{"kind": &"move", "target": Vector2(1284, 544), "run": false, "tolerance": 12.0, "label": "Approach grave upgrade"},
	{"kind": &"wait", "duration": 0.2, "label": "Face grave upgrade"},
	{"kind": &"interact", "label": "Interact with grave upgrade"},
	{"kind": &"wait", "duration": 0.7, "label": "Show grave interaction"},
	{"kind": &"move", "target": Vector2(1156, 544), "run": false, "tolerance": 12.0, "label": "Walk ceremonial aisle"},
	{"kind": &"wait", "duration": 0.2, "label": "Face grave plot"},
	{"kind": &"interact", "label": "Interact with grave plot"},
	{"kind": &"wait", "duration": 0.7, "label": "Show burial interaction"},
	{"kind": &"move", "target": Vector2(1344, 544), "run": true, "label": "Return to outer loop"},
	{"kind": &"move", "target": Vector2(1344, 736), "run": true, "label": "Run south loop"},
	{"kind": &"move", "target": Vector2(1464, 800), "run": true, "tolerance": 14.0, "label": "Approach forest exit"},
	{"kind": &"wait", "duration": 0.25, "label": "Face forest transition"},
	{"kind": &"interact", "label": "Travel to forest"},
	{"kind": &"wait", "duration": 1.5, "label": "Show forest arrival"},
]

var _player: PlayerController
var _step_index := 0
var _step_elapsed := 0.0
var _capture_elapsed := 0.0
var _interaction_count := 0
var _started := false
var _finishing := false
var _settling_move := false


func _ready() -> void:
	_release_movement_actions()
	await get_tree().physics_frame
	await get_tree().physics_frame
	_player = get_node("World/Player") as PlayerController
	if _player == null:
		push_error("Gameplay capture could not resolve production Player")
		get_tree().quit(2)
		return
	_player.interaction_started.connect(_on_interaction_started)
	_started = true
	_print_step()


func _physics_process(delta: float) -> void:
	if not _started or _finishing:
		return
	_capture_elapsed += delta
	if _capture_elapsed >= CAPTURE_TIMEOUT_SECONDS:
		push_error("Gameplay capture timed out at step %d" % _step_index)
		_finish_capture(3)
		return
	if _step_index >= STEPS.size():
		_finish_capture(0)
		return

	_step_elapsed += delta
	var step := STEPS[_step_index]
	var kind := StringName(step.get("kind", &""))
	match kind:
		&"wait":
			_release_movement_actions()
			var duration := float(step.get("duration", 0.0))
			if _step_elapsed >= duration:
				_advance_step()
		&"move":
			var target := step.get("target", _player.global_position) as Vector2
			var running := bool(step.get("run", false))
			var tolerance := float(step.get("tolerance", DEFAULT_MOVE_TOLERANCE))
			_drive_toward(target, running, tolerance)
		&"interact":
			_release_movement_actions()
			if not _trigger_interaction():
				push_error("Gameplay capture interaction failed at step %d" % _step_index)
				_finish_capture(5)
				return
			_advance_step()
		_:
			push_error("Unknown gameplay capture step kind: %s" % kind)
			_finish_capture(4)


func _drive_toward(target: Vector2, running: bool, tolerance: float) -> void:
	var offset := target - _player.global_position
	if _settling_move:
		_release_movement_actions()
		if _player.velocity.length() <= SETTLE_SPEED:
			_advance_step()
		return
	if offset.length() <= tolerance:
		_settling_move = true
		_release_movement_actions()
		return

	_release_movement_actions()
	var axis_deadzone := minf(tolerance * 0.4, 7.0)
	if offset.x < -axis_deadzone:
		Input.action_press("move_left")
	elif offset.x > axis_deadzone:
		Input.action_press("move_right")
	if offset.y < -axis_deadzone:
		Input.action_press("move_up")
	elif offset.y > axis_deadzone:
		Input.action_press("move_down")
	if running:
		Input.action_press("run")


func _trigger_interaction() -> bool:
	var before := _interaction_count
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	_player._unhandled_input(event)
	return _interaction_count > before


func _on_interaction_started(_target: Interactable) -> void:
	_interaction_count += 1


func _advance_step() -> void:
	_step_index += 1
	_step_elapsed = 0.0
	_settling_move = false
	_print_step()


func _print_step() -> void:
	if _step_index >= STEPS.size():
		print("Gameplay capture route complete")
		return
	var step := STEPS[_step_index]
	print("Gameplay capture step %02d: %s" % [_step_index + 1, String(step.get("label", ""))])


func _release_movement_actions() -> void:
	for action in MOVEMENT_ACTIONS:
		Input.action_release(action)


func _finish_capture(exit_code: int) -> void:
	if _finishing:
		return
	_finishing = true
	_release_movement_actions()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(exit_code)
