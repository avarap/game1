extends "res://tools/gameplay_capture/gameplay_video_runner.gd"

var _game: Node2D
var _player: PlayerController
var _zones: ZoneManager
var _status: Label
var _failures: Array[String] = []
var _stage := "Inicio"
var _save_path := ""


func _run() -> void:
	_save_path = "user://test_zone_save_%d.json" % OS.get_process_id()
	_create_capture_status()
	await _open_game()
	await _show_stage("Entrar al interior con interact")
	await _tap_action("interact")
	_expect(_zones.get_active_zone_id() == &"home_interior", "Input must enter home interior")
	if not _failures.is_empty():
		_finish()
		return
	_expect(
		_player.global_position.distance_to(Vector2(320, 800)) < 1.0,
		"Interior transition must place the player at the authored entry"
	)
	var inventory := _player.get_inventory_component()
	_expect(
		inventory.add_item(load("res://data/items/wood.tres") as ItemData, 7) == 0,
		"Fixture must add seven wood"
	)
	_expect(_player.get_energy_component().spend(37), "Fixture must spend 37 energy")
	await _show_stage("Fixture de prueba: 7 maderas, energia 63/100")
	var entry_position := _player.global_position
	await _hold_action("move_right", 0.45)
	await _hold_action("move_up", 0.55)
	_expect(
		_player.global_position.distance_to(entry_position) > 100.0,
		"Real input must move away from the entry before saving"
	)
	var before := _snapshot()
	var saved_position := _player.global_position
	var previous_player_id := _player.get_instance_id()
	var saves := root.get_node("SaveManager")
	_expect(bool(saves.call("save_game", _save_path)), "SaveManager must write the test save")
	await _show_stage("Guardado en interior, lejos del punto de entrada")
	_game.free()
	await _open_game()
	_expect(
		_player.get_instance_id() != previous_player_id, "Reload must use a new player instance"
	)
	_expect(_zones.get_active_zone_id() == &"cemetery", "New scene must start in cemetery")
	_expect(
		_player.get_inventory_component().count_item(&"wood") == 0, "New inventory must be empty"
	)
	_expect(_player.get_energy_component().current_energy == 100, "New energy must start at 100")
	await _show_stage("Partida recreada: estado inicial antes de cargar")
	var payload: Dictionary = saves.call("load_game", _save_path)
	_expect(not payload.is_empty(), "SaveManager must load the saved payload")
	await _wait_seconds(0.2)
	var after := _snapshot()
	_expect(after["zone"] == "home_interior", "Load must restore home interior")
	_expect(after["marker"] == "entry_main", "Load must restore the entry marker contract")
	_expect(
		_player.global_position.distance_to(saved_position) < 0.5,
		"Load must restore the walked-to position, not the spawn"
	)
	_expect(after["wood"] == 7, "Load must restore seven wood after changing zones")
	_expect(after["energy"] == 63, "Load must restore 63 energy after changing zones")
	var aldren := _game.get_node("World/BrotherAldren") as NPCController
	_expect(not aldren.visible, "Aldren must remain hidden outside cemetery after loading")
	var camera := _player.get_node("Camera2D") as Camera2D
	_expect(
		camera.limit_right == 1600 and camera.limit_bottom == 1024,
		"Load must restore interior camera bounds"
	)
	await _show_stage("Carga aplicada: mismo interior, posicion e inventario")
	await _hold_action("move_down", 0.4)
	_expect(
		_player.global_position.distance_to(saved_position) > 60.0,
		"Player must still move after load"
	)
	await _tap_action("interact")
	_expect(_zones.get_active_zone_id() == &"cemetery", "Real input must leave the loaded interior")
	_expect(aldren.visible, "Aldren must reappear when returning to cemetery")
	await _show_stage("Regreso al cementerio con interact")
	print(
		(
			"[ZONE_SAVE] evidence %s"
			% (
				JSON
				. stringify(
					{
						"commit_sha": OS.get_environment("VISUAL_CAPTURE_SHA"),
						"before": before,
						"after": after,
						"final": _snapshot(),
						"new_player_instance": _player.get_instance_id() != previous_player_id,
						"failures": _failures,
					}
				)
			)
		)
	)
	_finish()


func _open_game() -> void:
	_game = load("res://main.tscn").instantiate() as Node2D
	root.add_child(_game)
	current_scene = _game
	_player = _game.get_node("World/Player") as PlayerController
	_zones = _game.get_node("World/ZoneManager") as ZoneManager
	await physics_frame
	await physics_frame
	await process_frame


func _snapshot() -> Dictionary:
	return {
		"zone": String(_zones.get_active_zone_id()),
		"marker": String(_zones.get_active_marker_id()),
		"position": [_player.global_position.x, _player.global_position.y],
		"wood": _player.get_inventory_component().count_item(&"wood"),
		"energy": _player.get_energy_component().current_energy,
	}


func _create_capture_status() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 110
	root.add_child(layer)
	var panel := Panel.new()
	panel.position = Vector2(16, 76)
	panel.size = Vector2(740, 122)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(panel)
	_status = Label.new()
	_status.position = Vector2(12, 8)
	_status.add_theme_font_size_override("font_size", 18)
	panel.add_child(_status)
	process_frame.connect(_update_capture_status)


func _update_capture_status() -> void:
	if not is_instance_valid(_player):
		return
	var state := _snapshot()
	_status.text = (
		(
			"VALIDACION AUTOMATIZADA - no es UI del juego\n%s\nZona: %s  Posicion: %.1f, %.1f\n"
			% [_stage, state["zone"], state["position"][0], state["position"][1]]
		)
		+ "Madera: %d  Energia: %d  Fallos: %d" % [state["wood"], state["energy"], _failures.size()]
	)


func _show_stage(stage: String) -> void:
	_stage = stage
	print("[ZONE_SAVE] %s %s" % [stage, JSON.stringify(_snapshot())])
	await _wait_seconds(1.2)


func _expect(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
		push_error("[ZONE_SAVE] %s" % message)


func _finish() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right", "run", "interact"]:
		Input.action_release(action)
	if FileAccess.file_exists(_save_path):
		_expect(
			DirAccess.remove_absolute(ProjectSettings.globalize_path(_save_path)) == OK,
			"Test must remove its isolated save"
		)
	if is_instance_valid(_game):
		_game.queue_free()
	print("[TEST] ZoneSaveRuntime complete (%d failures)" % _failures.size())
	quit(0 if _failures.is_empty() else 1)
