extends SceneTree

const MAIN_SCENE := preload("res://main.tscn")
const FPS := 30


func _initialize() -> void:
	call_deferred("_record_gameplay")


func _record_gameplay() -> void:
	var main := MAIN_SCENE.instantiate()
	root.add_child(main)

	# Let autoloads, the world scene and the initial zone settle before moving.
	await _wait_frames(FPS * 2)

	# A deterministic loop around the current starting area. These are the same
	# input actions a player uses; the capture runner does not teleport or alter
	# gameplay state to make the game look better than it currently does.
	await _hold_action(&"move_right", 70)
	await _wait_frames(20)
	await _hold_action(&"move_up", 55)
	await _wait_frames(20)
	await _hold_action(&"move_left", 65)
	await _wait_frames(20)
	await _hold_action(&"move_down", 45)
	await _wait_frames(FPS)

	# Exercise UI input through real InputEventAction dispatch. If the current
	# runtime does not expose a panel for an action, the capture simply shows the
	# unchanged game instead of manufacturing a fake UI state.
	await _tap_event_action(&"inventory")
	await _wait_frames(FPS * 2)
	await _tap_event_action(&"inventory")
	await _wait_frames(FPS)

	await _tap_event_action(&"debug_panel")
	await _wait_frames(FPS * 2)
	await _tap_event_action(&"debug_panel")
	await _wait_frames(FPS)

	_release_movement()
	print("[GAMEPLAY_CAPTURE] completed deterministic current-main sequence")
	quit(0)


func _hold_action(action: StringName, frame_count: int) -> void:
	Input.action_press(action)
	await _wait_frames(frame_count)
	Input.action_release(action)
	await _wait_frames(2)


func _tap_event_action(action: StringName) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action
	pressed.pressed = true
	Input.parse_input_event(pressed)
	await _wait_frames(2)

	var released := InputEventAction.new()
	released.action = action
	released.pressed = false
	Input.parse_input_event(released)
	await _wait_frames(2)


func _wait_frames(frame_count: int) -> void:
	for _frame in range(frame_count):
		await process_frame


func _release_movement() -> void:
	for action in [&"move_up", &"move_down", &"move_left", &"move_right"]:
		Input.action_release(action)
