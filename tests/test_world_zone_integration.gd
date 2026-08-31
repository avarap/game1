class_name TestWorldZoneIntegration
extends RefCounted

const WORLD_PATH := "res://world/world.tscn"
const SAVE_PATH := "user://test_world_zone_integration.json"
const ROUTE := [
	[&"forest", &"CemeteryEntrance"],
	[&"cemetery", &"ForestExit"],
	[&"village", &"Entrance"],
	[&"village_interior", &"entry_main"],
	[&"village", &"InteriorAccess/Workshop"],
	[&"mine", &"Entrance"],
	[&"cemetery", &"FutureExpansion"],
	[&"home_interior", &"entry_main"],
	[&"cemetery", &"PlayerSpawn"],
]
const PERSISTENT_NODES := [
	"Player",
	"RelationshipController",
	"QuestController",
	"EconomyController",
	"TechnologyController",
	"CemeteryController",
	"BrotherAldren",
]
const EXPECTED_TRANSITION_TARGETS := {
	&"cemetery": [&"forest", &"village", &"home_interior", &"mine"],
	&"forest": [&"cemetery"],
	&"village": [&"cemetery", &"village_interior"],
	&"home_interior": [&"cemetery"],
	&"village_interior": [&"village"],
	&"mine": [&"cemetery"],
}


static func run() -> Array[String]:
	var failures: Array[String] = []
	var packed := load(WORLD_PATH) as PackedScene
	if packed == null:
		failures.append("World scene should load for zone integration")
		return failures

	var world := packed.instantiate()
	var tree := Engine.get_main_loop() as SceneTree
	tree.root.add_child(world)
	var zone_manager := world.get_node_or_null("ZoneManager")
	if zone_manager == null:
		failures.append("World integration should expose a local ZoneManager")
		_cleanup(world)
		return failures

	var ids := _capture_persistent_ids(world, failures)
	if zone_manager.call("get_active_zone_id") != &"cemetery":
		failures.append("World should start in the cemetery/property zone")
	if world.get_node_or_null("TechnicalMap") != null:
		failures.append("Persistent world shell should not retain the legacy TechnicalMap")
	if tree.get_nodes_in_group("cemetery_controller").size() != 1:
		failures.append("World integration should expose exactly one cemetery controller")
	_assert_zone_shell_state(world, &"cemetery", failures)
	_assert_zone_transitions(world, &"cemetery", failures)
	_assert_zone_content(zone_manager.call("get_active_zone") as Node, &"cemetery", failures)

	for destination in ROUTE:
		var zone_id := destination[0] as StringName
		var marker_id := destination[1] as StringName
		var travelled := zone_manager.call("travel_to", zone_id, marker_id) as bool
		if not travelled:
			failures.append("World should travel to %s/%s" % [zone_id, marker_id])
			continue
		if zone_manager.call("get_active_zone_id") != zone_id:
			failures.append("ZoneManager should report active zone %s" % zone_id)
		_assert_persistent_ids(world, ids, failures)
		_assert_zone_shell_state(world, zone_id, failures)
		_assert_zone_transitions(world, zone_id, failures)
		_assert_zone_content(zone_manager.call("get_active_zone") as Node, zone_id, failures)

	var player := world.get_node_or_null("Player") as Node2D
	if player != null:
		var zone_before := zone_manager.call("get_active_zone_id") as StringName
		var position_before := player.global_position
		var invalid := zone_manager.call("travel_to", &"missing_zone", &"missing") as bool
		if invalid:
			failures.append("Invalid travel should be rejected")
		if zone_manager.call("get_active_zone_id") != zone_before:
			failures.append("Invalid travel should preserve active zone")
		if player.global_position != position_before:
			failures.append("Invalid travel should preserve Player position")

	_check_location_persistence(world, zone_manager, failures)
	_check_aldren_cemetery_restore(world, zone_manager, failures)
	_cleanup(world)
	return failures


static func _capture_persistent_ids(world: Node, failures: Array[String]) -> Dictionary:
	var result: Dictionary = {}
	for node_name in PERSISTENT_NODES:
		var node := world.get_node_or_null(node_name)
		if node == null:
			failures.append("Persistent world shell should expose %s" % node_name)
			continue
		result[node_name] = node.get_instance_id()
	return result


static func _assert_persistent_ids(world: Node, ids: Dictionary, failures: Array[String]) -> void:
	for node_name in ids:
		var node := world.get_node_or_null(node_name)
		if node == null or node.get_instance_id() != ids[node_name]:
			failures.append("Zone travel should preserve persistent node %s" % node_name)


static func _assert_zone_shell_state(
	world: Node, zone_id: StringName, failures: Array[String]
) -> void:
	var zone_container := world.get_node_or_null("ZoneContainer")
	if zone_container == null or zone_container.get_child_count() != 1:
		failures.append("ZoneContainer should own exactly one active zone")
	var aldren := world.get_node_or_null("BrotherAldren") as CanvasItem
	if aldren != null and aldren.visible != (zone_id == &"cemetery"):
		failures.append("Brother Aldren visibility should follow the cemetery zone")
	var trade_point := world.get_node_or_null("TradePoint") as CanvasItem
	if trade_point != null and trade_point.visible != (zone_id == &"village"):
		failures.append("TradePoint visibility should follow the village zone")
	var player := world.get_node_or_null("Player") as Node2D
	var active_zone := world.get_node("ZoneManager").call("get_active_zone") as Node2D
	if player != null and active_zone != null and active_zone.has_method("get_world_rect"):
		var bounds := active_zone.call("get_world_rect") as Rect2
		var camera := player.get_node_or_null("Camera2D") as Camera2D
		if camera == null:
			failures.append("Persistent Player should keep its camera")
		elif camera.limit_right != int(bounds.end.x) or camera.limit_bottom != int(bounds.end.y):
			failures.append("Camera bounds should follow active zone %s" % zone_id)


static func _assert_zone_transitions(
	world: Node, zone_id: StringName, failures: Array[String]
) -> void:
	var container := world.get_node_or_null("TransitionContainer")
	if container == null:
		failures.append("World should expose a persistent TransitionContainer")
		return
	var actual_targets: Array[StringName] = []
	for child in container.get_children():
		if not child.has_method("interact"):
			failures.append("Every zone transition should be interactable")
			continue
		actual_targets.append(StringName(child.get("target_zone_id")))
	var expected: Array = EXPECTED_TRANSITION_TARGETS.get(zone_id, [])
	if actual_targets.size() != expected.size():
		failures.append("Zone %s should expose %d travel transitions" % [zone_id, expected.size()])
	for target in expected:
		if not actual_targets.has(target):
			failures.append("Zone %s should expose travel to %s" % [zone_id, target])


static func _assert_zone_content(
	active_zone: Node, zone_id: StringName, failures: Array[String]
) -> void:
	if active_zone == null:
		failures.append("Active zone %s should exist" % zone_id)
		return
	match zone_id:
		&"cemetery":
			if active_zone.find_child("Workbench", true, false) == null:
				failures.append("Cemetery/property should keep the workshop reachable")
		&"forest":
			var resources := active_zone.get_node_or_null("Resources")
			if resources == null or resources.get_child_count() == 0:
				failures.append("Forest route should expose reachable reusable resources")
			if active_zone.get_node_or_null("Markers/SecretClearing") == null:
				failures.append("Forest should expose its secondary secret clearing marker")
		&"village":
			if active_zone.find_child("MerchantSpot", true, false) == null:
				failures.append("Village route should expose the commercial marker")
		&"village_interior", &"home_interior":
			if active_zone.find_child("exit_main", true, false) == null:
				failures.append("Interior route should expose a deterministic exit marker")
		&"mine":
			if active_zone.find_child("SecretLandmark", true, false) == null:
				failures.append("Mine route should expose its secondary secret landmark")


static func _check_location_persistence(
	world: Node, zone_manager: Node, failures: Array[String]
) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var save_manager := tree.root.get_node_or_null("SaveManager")
	var player := world.get_node_or_null("Player") as Node2D
	if save_manager == null or player == null:
		failures.append("World location persistence requires SaveManager and Player")
		return
	if not zone_manager.call("travel_to", &"mine", &"SecretLandmark"):
		failures.append("Persistence setup should travel to mine secret landmark")
		return
	player.global_position = Vector2(960, 704)
	var expected_position := player.global_position
	if not bool(save_manager.call("save_game", SAVE_PATH)):
		failures.append("SaveManager should persist world location")
		return
	var payload: Variant = save_manager.call("load_game", SAVE_PATH, false)
	if typeof(payload) != TYPE_DICTIONARY:
		failures.append("World location save should load as a dictionary")
		return
	var world_data: Dictionary = (payload as Dictionary).get("world", {})
	if not world_data.has("world_location"):
		failures.append("Integrated save should contain world_location provider")
	zone_manager.call("travel_to", &"cemetery", &"PlayerSpawn")
	var loaded: Variant = save_manager.call("load_game", SAVE_PATH, true)
	if typeof(loaded) != TYPE_DICTIONARY:
		failures.append("World location load should return save payload")
	if zone_manager.call("get_active_zone_id") != &"mine":
		failures.append("Save/load should restore the active mine zone")
	if not player.global_position.is_equal_approx(expected_position):
		failures.append("Save/load should restore a valid Player world position")


static func _check_aldren_cemetery_restore(
	world: Node, zone_manager: Node, failures: Array[String]
) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var save_manager := tree.root.get_node_or_null("SaveManager")
	var time_manager := tree.root.get_node_or_null("TimeManager")
	var aldren := world.get_node_or_null("BrotherAldren") as NPCController
	if save_manager == null or time_manager == null or aldren == null:
		failures.append("Aldren cemetery persistence requires SaveManager, TimeManager and NPC")
		return
	if not zone_manager.call("travel_to", &"cemetery", &"PlayerSpawn"):
		failures.append("Aldren persistence setup should enter cemetery")
		return

	time_manager.call("set_time", 10, 0)
	var expected_position := Vector2(1096, 696)
	aldren.global_position = expected_position
	aldren.state_machine.set_activity(&"Sleeping")
	aldren.navigation_started = false
	aldren.velocity = Vector2.ZERO
	var expected_state := aldren.get_current_state()

	if not bool(save_manager.call("save_game", SAVE_PATH)):
		failures.append("SaveManager should persist Aldren cemetery state")
		return
	var payload: Variant = save_manager.call("load_game", SAVE_PATH, false)
	if typeof(payload) != TYPE_DICTIONARY:
		failures.append("Aldren cemetery save should load as a dictionary")
		return
	var world_data: Dictionary = (payload as Dictionary).get("world", {})
	if not world_data.has("npc:brother_aldren"):
		failures.append("Integrated save should contain Brother Aldren provider")

	zone_manager.call("travel_to", &"forest", &"CemeteryEntrance")
	zone_manager.call("travel_to", &"cemetery", &"ForestExit")
	aldren.global_position = Vector2(1216, 640)
	aldren.apply_current_schedule()
	if aldren.global_position.is_equal_approx(expected_position):
		failures.append("Regression setup should move Aldren away from persisted position")
	if aldren.get_current_state() == expected_state:
		failures.append("Regression setup should replace Aldren persisted routine state")

	var loaded: Variant = save_manager.call("load_game", SAVE_PATH, true)
	if typeof(loaded) != TYPE_DICTIONARY:
		failures.append("Aldren cemetery load should return save payload")
	if zone_manager.call("get_active_zone_id") != &"cemetery":
		failures.append("Save/load should restore the cemetery zone")
	if not aldren.global_position.is_equal_approx(expected_position):
		failures.append("Save/load should preserve Aldren persisted cemetery position")
	if aldren.get_current_state() != expected_state:
		failures.append("Save/load should preserve Aldren persisted routine state")


static func _cleanup(world: Node) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	world.free()
