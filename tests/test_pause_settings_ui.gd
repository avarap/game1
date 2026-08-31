class_name TestPauseSettingsUI
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var scene := load("res://ui/settings/pause_menu.tscn") as PackedScene
	if scene == null:
		failures.append("Pause/settings scene should exist")
		return failures
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Pause/settings requires SceneTree")
		return failures
	var menu := scene.instantiate()
	tree.root.add_child(menu)
	if menu.theme == null:
		failures.append("Pause/settings should use shared UI theme")
	if not menu.has_signal(&"resume_requested"):
		failures.append("Pause/settings should emit resume intent")
	if not menu.has_signal(&"audio_volume_requested"):
		failures.append("Pause/settings should emit volume intent")
	if not menu.has_signal(&"locale_requested"):
		failures.append("Pause/settings should emit locale intent")
	if not menu.has_method("set_master_volume_percent"):
		failures.append("Pause/settings should expose display volume state")
	if not menu.has_method("get_master_volume_text"):
		failures.append("Pause/settings should expose localized volume text")
	if failures.is_empty():
		LocalizationService.set_locale("en")
		menu.call("set_master_volume_percent", 65)
		var volume_text := str(menu.call("get_master_volume_text"))
		if volume_text != "Master volume: 65%":
			failures.append("Pause/settings should localize English volume")
	menu.free()
	return failures
