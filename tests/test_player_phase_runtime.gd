extends SceneTree
## Exercises the real controller, not a posed sprite or a teleported player.
## The chest's hidden feedback is reported separately, not visual acceptance.

var _main: Node
var _player: PlayerController
var _probe: PostPhysicsProbe
var _input: InputDriver
var _interaction_count := 0
var _interaction: Dictionary = {}


class PostPhysicsProbe:
	extends Node

	var player: PlayerController
	var pending: Dictionary = {}
	var samples: Array[Dictionary] = []
	var failures: Array[String] = []
	var path_length := 0.0
	var collision_ticks := 0
	var previous_position := Vector2.ZERO
	var maximum_speed := 0.0

	func _physics_process(_delta: float) -> void:
		path_length += previous_position.distance_to(player.global_position)
		previous_position = player.global_position
		maximum_speed = maxf(maximum_speed, player.velocity.length())
		if player.get_slide_collision_count() > 0:
			collision_ticks += 1
		if pending.is_empty():
			return
		var body := player.player_visual
		pending["after_animation"] = String(body.animation)
		pending["after_frame"] = body.frame
		pending["after_progress"] = body.frame_progress
		pending["position_after"] = [player.global_position.x, player.global_position.y]
		pending["velocity"] = [player.velocity.x, player.velocity.y]
		if String(body.animation) != pending["target"]:
			failures.append("Input did not select %s" % pending["target"])
		if not body.is_playing():
			failures.append("Animation stopped while moving to %s" % pending["target"])
		if pending["preserve_phase"]:
			if (
				body.frame != pending["before_frame"]
				or not is_equal_approx(body.frame_progress, pending["before_progress"])
			):
				failures.append(
					"Live controller reset step phase while turning to %s" % pending["target"]
				)
		elif body.frame != 0 or not is_zero_approx(body.frame_progress):
			failures.append("Action transition did not restart %s" % pending["target"])
		samples.append(pending.duplicate(true))
		pending = {}


class InputDriver:
	extends Node

	const DIRECTIONS := [
		Vector2.RIGHT,
		Vector2(1, 1),
		Vector2.DOWN,
		Vector2(-1, 1),
		Vector2.LEFT,
		Vector2(-1, -1),
		Vector2.UP,
		Vector2(1, -1),
		Vector2.RIGHT,
	]
	const FACING := ["e", "se", "s", "sw", "w", "nw", "n", "ne", "e"]
	const MOVE_ACTIONS := [&"move_left", &"move_right", &"move_up", &"move_down"]
	const HOLD_TICKS := 19

	var player: PlayerController
	var probe: PostPhysicsProbe
	var owner_tree: SceneTree
	var tick := 0

	func _physics_process(_delta: float) -> void:
		tick += 1
		var sequence_tick := tick - 1
		if sequence_tick >= DIRECTIONS.size() * 2 * HOLD_TICKS:
			release_inputs()
			set_physics_process(false)
			owner_tree.call_deferred("_finish")
			return
		if sequence_tick % HOLD_TICKS != 0:
			return
		var segment := sequence_tick / HOLD_TICKS
		var state := &"walk" if segment < DIRECTIONS.size() else &"run"
		var direction: Vector2 = DIRECTIONS[segment % DIRECTIONS.size()]
		var body := player.player_visual
		var target := "%s_%s" % [state, FACING[segment % FACING.size()]]
		probe.pending = {
			"tick": tick,
			"target": target,
			"before_animation": String(body.animation),
			"before_frame": body.frame,
			"before_progress": body.frame_progress,
			"preserve_phase": segment != 0 and segment != DIRECTIONS.size(),
			"position_before": [player.global_position.x, player.global_position.y],
		}
		release_inputs()
		if direction.x < 0:
			Input.action_press(&"move_left")
		elif direction.x > 0:
			Input.action_press(&"move_right")
		if direction.y < 0:
			Input.action_press(&"move_up")
		elif direction.y > 0:
			Input.action_press(&"move_down")
		if state == &"run":
			Input.action_press(&"run")

	func release_inputs() -> void:
		for action in MOVE_ACTIONS:
			Input.action_release(action)
		Input.action_release(&"run")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(1280, 720)
	_main = load("res://main.tscn").instantiate()
	root.add_child(_main)
	current_scene = _main
	_player = _main.get_node("World/Player") as PlayerController
	await create_timer(0.5, true, true).timeout
	await _exercise_interaction()
	_probe = PostPhysicsProbe.new()
	_probe.player = _player
	_probe.previous_position = _player.global_position
	_probe.process_physics_priority = 100
	root.add_child(_probe)
	_input = InputDriver.new()
	_input.player = _player
	_input.probe = _probe
	_input.owner_tree = self
	_input.process_physics_priority = -100
	root.add_child(_input)


func _exercise_interaction() -> void:
	var chest := _main.find_child("StorageChest", true, false) as StorageChest
	if chest == null:
		_interaction = {"input_reached_chest": false, "reason": "StorageChest missing"}
		return
	chest.interacted.connect(_record_interaction)
	var feedback := chest.get_node("FeedbackLabel") as Label
	var before := feedback.text
	Input.action_press(&"move_down")
	await create_timer(0.2, true, true).timeout
	Input.action_release(&"move_down")
	await create_timer(0.1, true, true).timeout
	var event := InputEventAction.new()
	event.action = &"interact"
	event.pressed = true
	Input.parse_input_event(event)
	await create_timer(0.05, true, true).timeout
	var pose_seen := _player.player_visual.animation == &"interact_s"
	event = InputEventAction.new()
	event.action = &"interact"
	Input.parse_input_event(event)
	await create_timer(0.6, true, true).timeout
	_interaction = {
		"input_reached_chest": _interaction_count == 1 and feedback.text != before,
		"interaction_count": _interaction_count,
		"interaction_pose_seen": pose_seen,
		"feedback_text": feedback.text,
		"feedback_visible": feedback.is_visible_in_tree(),
	}


func _record_interaction(actor: Node) -> void:
	if actor == _player:
		_interaction_count += 1


func _finish() -> void:
	await create_timer(0.5, true, true).timeout
	if not _player.velocity.is_zero_approx():
		_probe.failures.append("Player did not decelerate to rest after releasing input")
	if _player.player_visual.animation != &"idle_e":
		_probe.failures.append("Stopping should retain east facing in idle_e")
	if _probe.path_length < 300.0:
		_probe.failures.append("Live input did not produce substantial real movement")
	if _probe.collision_ticks == 0:
		_probe.failures.append("The route did not exercise contact with an obstacle")
	if not _interaction.get("input_reached_chest", false):
		_probe.failures.append("Real interaction input did not change the chest's state")
	if not _interaction.get("interaction_pose_seen", false):
		_probe.failures.append("Successful interaction did not select the authored pose")
	var phase_checks := 0
	for sample in _probe.samples:
		if sample["preserve_phase"]:
			phase_checks += 1
	var action_checks := _probe.samples.size() - phase_checks
	if phase_checks != 16 or action_checks != 2:
		_probe.failures.append("Expected 16 live turns and 2 action starts")
	var summary := {
		"executed_commit": OS.get_environment("PLAYER_CAPTURE_SHA"),
		"runtime": Engine.get_version_info().get("string", "unknown"),
		"scene": "res://main.tscn",
		"viewport": [root.size.x, root.size.y],
		"evidence": "Real input/physics; visual acceptance requires separate video review",
		"phase_checks": phase_checks,
		"action_start_checks": action_checks,
		"path_length_px": _probe.path_length,
		"maximum_speed_px_s": _probe.maximum_speed,
		"collision_ticks": _probe.collision_ticks,
		"final_position": [_player.global_position.x, _player.global_position.y],
		"final_velocity": [_player.velocity.x, _player.velocity.y],
		"final_animation": String(_player.player_visual.animation),
		"interaction": _interaction,
		"failures": _probe.failures,
		"samples": _probe.samples,
	}
	print("[PLAYER_PHASE_RUNTIME] ", JSON.stringify(summary))
	var failed := not _probe.failures.is_empty()
	_main.free()
	_probe.free()
	_input.free()
	quit(1 if failed else 0)
