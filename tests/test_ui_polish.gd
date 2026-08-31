class_name TestUIPolish
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var previous_locale := LocalizationService.get_locale()
	var tree := Engine.get_main_loop() as SceneTree
	var hud_scene := load("res://ui/hud/status_hud.tscn") as PackedScene
	if tree == null:
		failures.append("UI polish requires SceneTree")
		return failures
	if hud_scene == null:
		failures.append("UI polish should provide reusable status HUD scene")
		return failures

	var hud := hud_scene.instantiate()
	tree.root.add_child(hud)
	if hud.theme == null:
		failures.append("Status HUD should use a shared UI theme")
	if not hud.has_method("set_energy") or not hud.has_method("get_energy_text"):
		failures.append("Status HUD should expose presentation-only energy API")
	if not hud.has_method("set_context_status") or not hud.has_method("get_context_text"):
		failures.append("Status HUD should expose presentation-only context API")
	if not failures.is_empty():
		_cleanup(hud, previous_locale)
		return failures

	LocalizationService.set_locale("en")
	hud.call("set_energy", 40, 100)
	var english_energy := str(hud.call("get_energy_text"))
	if not english_energy.contains("Energy") or not english_energy.contains("40 / 100"):
		failures.append("Status HUD energy should localize to English and show values")
	hud.call("set_context_status", &"UI_HUD_STATUS_READY")
	if str(hud.call("get_context_text")) != "Ready":
		failures.append("Status HUD context should localize to English")

	LocalizationService.set_locale("es")
	var spanish_energy := str(hud.call("get_energy_text"))
	if not spanish_energy.contains("Energía") or not spanish_energy.contains("40 / 100"):
		failures.append("Status HUD should refresh energy text after locale change")
	if str(hud.call("get_context_text")) != "Listo":
		failures.append("Status HUD should refresh context after locale change")

	hud.call("set_energy", -5, 0)
	if not str(hud.call("get_energy_text")).contains("0 / 1"):
		failures.append("Status HUD should clamp display values without changing gameplay state")

	failures.append_array(_test_pause_settings(tree))
	_cleanup(hud, previous_locale)
	return failures


static func _test_pause_settings(tree: SceneTree) -> Array[String]:
	var failures: Array[String] = []
	var pause_scene := load("res://ui/settings/pause_menu.tscn") as PackedScene
	if pause_scene == null:
		failures.append("UI polish should provide reusable pause/settings scene")
		return failures

	var pause_menu := pause_scene.instantiate()
	tree.root.add_child(pause_menu)
	if pause_menu.theme == null:
		failures.append("Pause/settings should use the shared UI theme")
	for signal_name in [&"resume_requested", &"audio_volume_requested", &"locale_requested"]:
		if not pause_menu.has_signal(signal_name):
			failures.append("Pause/settings should expose presentation intent signal %s" % signal_name)
	if not pause_menu.has_method("set_master_volume_percent"):
		failures.append("Pause/settings should expose presentation-only volume state")
	if not pause_menu.has_method("get_master_volume_text"):
		failures.append("Pause/settings should expose localized volume text")
	if not failures.is_empty():
		pause_menu.free()
		return failures

	LocalizationService.set_locale("en")
	pause_menu.call("set_master_volume_percent", 65)
	if str(pause_menu.call("get_master_volume_text")) != "Master volume: 65%":
		failures.append("Pause/settings volume should localize to English")
	LocalizationService.set_locale("es")
	if str(pause_menu.call("get_master_volume_text")) != "Volumen general: 65%":
		failures.append("Pause/settings volume should refresh after locale change")
	pause_menu.call("set_master_volume_percent", 150)
	if not str(pause_menu.call("get_master_volume_text")).ends_with("100%"):
		failures.append("Pause/settings should clamp displayed volume without applying audio logic")
	var resume_button := pause_menu.get_node_or_null("Panel/Margin/VBox/ResumeButton") as Button
	if resume_button == null or resume_button.focus_mode != Control.FOCUS_ALL:
		failures.append("Pause/settings primary action should be keyboard focusable")
	pause_menu.free()
	return failures


static func _cleanup(hud: Node, previous_locale: StringName) -> void:
	LocalizationService.set_locale(String(previous_locale))
	hud.free()
