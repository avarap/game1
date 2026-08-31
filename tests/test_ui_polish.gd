class_name TestUIPolish
extends RefCounted

const CORE_PANEL_PATHS := [
	"res://ui/inventory/inventory_panel.tscn",
	"res://ui/storage/storage_panel.tscn",
	"res://ui/crafting/crafting_panel.tscn",
]


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

	_check_core_panels(tree, failures)
	failures.append_array(TestPauseSettingsUI.run())
	_cleanup(hud, previous_locale)
	return failures


static func _check_core_panels(tree: SceneTree, failures: Array[String]) -> void:
	for scene_path in CORE_PANEL_PATHS:
		var scene := load(scene_path) as PackedScene
		if scene == null:
			failures.append("Core UI should provide panel scene %s" % scene_path)
			continue
		var panel := scene.instantiate()
		tree.root.add_child(panel)
		if panel.theme == null:
			failures.append("Core UI panels should use the shared theme")
		if not panel.has_method("set_rows") or not panel.has_method("set_state"):
			failures.append("Core UI panels should expose presentation-only state APIs")
		if panel.has_method("set_rows"):
			panel.call("set_rows", [{"title": "Oak plank", "detail": "x4"}])
		if panel.has_method("get_row_count") and int(panel.call("get_row_count")) != 1:
			failures.append("Core UI panels should render supplied read-model rows")
		panel.free()

	var trade_scene := load("res://ui/economy/trade_layer.tscn") as PackedScene
	if trade_scene == null:
		failures.append("Trade panel scene should remain available")
		return
	var trade := trade_scene.instantiate()
	tree.root.add_child(trade)
	var trade_panel := trade.get_node_or_null("Panel") as Control
	if trade_panel == null or trade_panel.theme == null:
		failures.append("Trade panel should use the shared medieval UI theme")
	trade.free()


static func _cleanup(hud: Node, previous_locale: StringName) -> void:
	LocalizationService.set_locale(String(previous_locale))
	hud.free()
