extends Node

const MOVE_TOLERANCE := 16.0
const CAPTURE_TIMEOUT_SECONDS := 30.0
const MOVEMENT_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
	&"run",
]
const STEPS: Array[Dictionary] = [
	{"kind": &"wait", "duration": 1.0, "label": "Spawn idle"},
	{"kind": &"move", "target": Vector2(256, 704), "run": false, "label": "Approach workshop"},
	{"kind": &"move", "target": Vector2(256, 720), "run": false, "label": "Face sleep spot"},
	{"kind": &"wait", "duration": 0.25, "label": "Settle at workshop"},
	{"kind": &"interact", "label": "Interact with sleep spot"},
	{"kind": &"wait", "duration": 0.8, "label": "Show interaction"},
	{"kind": &"move", "target": Vector2(288, 704), "run": false, "label": "Return to yard"},
	{"kind": &"move", "target": Vector2(384, 608), "run": false, "label": "Walk pilgrimage road"},
	{"kind": &"move", "target": Vector2(544, 576), "run": true, "label": "Run east"},
	{"kind": &"move", "target": Vector2(768, 544), "run": true, "label": "Run to cemetery approach"},
	{"kind": &"move", "target": Vector2(896, 448), "run": true, "label": "Climb cemetery approach"},
	{"kind": &"move", "target": Vector2(928, 352), "run": false, "label": "Enter cemetery loop"},
	{"kind": &"wait", "duration": 0.45, "label": "Show cemetery threshold"},
	{"kind": &"move", "target": Vector2(1344, 352), "run": true, "label": "Run upper cemetery loop"},
	{"kind": &"move", "target": Vector2(1344, 544), "run": false, "label": "Descend grave field"},
	{"kind": &"move", "target": Vector2(1296, 544), "run": false, "label": "Approach grave upgrade"},
	{"kind": &"wait", "duration": 0.2, "label": "Face grave upgrade"},
	{"kind": &"interact", "label": "Interact with grave upgrade"},
	{"kind": &"wait", "duration": 0.7, "label": "Show grave interaction"},
	{"kind": &"move", "target": Vector2(1168, 544), "run": false, "label": "Walk ceremonial aisle"},
	{"kind": &"wait", "duration": 0.2, "label": "Face grave plot"},
	{"kind": &"interact", "label": "Interact with grave plot"},
	{"kind": &"wait", "duration": 0.7, "label": "Show burial interaction"},
	{"kind": &"move", "target": Vector2(1344, 544), "run": true, "label": "Return to outer loop"},
	{"kind": &"move", "target": Vector2(1344, 736), "run": true, "label": "Run south loop"},
	{"kind": &"move", "target": Vector2(1456, 800), "run": true, "label": "Approach forest exit"},
	{"kind": &"wait", "duration": 0.25, "label": "Face forest transition"},
	{"kind": &"interact", "label": "Travel to forest"},
	{"kind": &"wait", "duration": 1.5, "label": "Show forest arrival"},
]

var _player: PlayerController
var _step_index := 0
var _step_elapsed := 0.0
var _capture_elapsed := 0.0
var _started := false
var _finishing := false


func _ready() -> void:
	_release_movement_actions()
	await get_tree().physics_frame
	await get_tree().physics_frame
	_player = get_node("World/Player") as PlayerController
	if _player == null:
		push_error("Gameplay capture could not resolve production Player")
		get_tree().quit(2)
		return
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
			_drive_toward(target, running)
		&"interact":
			_release_movement_actions()
			_trigger_interaction()
			_advance_step()
		_:
			push_error("Unknown gameplay capture step kind: %s" % kind)
			_finish_capture(4)


func _drive_toward(target: Vector2, running: bool) -> void:
	var offset := target - _player.global_position
	if offset.length() <= MOVE_TOLERANCE:
		_release_movement_actions()
		_advance_step()
		return

	_release_movement_actions()
	if offset.x < -MOVE_TOLERANCE:
		Input.action_press("move_left")
	elif offset.x > MOVE_TOLERANCE:
		Input.action_press("move_right")
	if offset.y < -MOVE_TOLERANCE:
		Input.action_press("move_up")
	elif offset.y > MOVE_TOLERANCE:
		Input.action_press("move_down")
	if running:
		Input.action_press("run")


func _trigger_interaction() -> void:
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	_player._unhandled_input(event)


func _advance_step() -> void:
	_step_index += 1
	_step_elapsed = 0.0
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
