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

	_cleanup(hud, previous_locale)
	return failures


static func _cleanup(hud: Node, previous_locale: StringName) -> void:
	LocalizationService.set_locale(String(previous_locale))
	hud.free()
