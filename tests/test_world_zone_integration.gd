class_name TestWorldZoneIntegration
extends RefCounted

const WORLD_PATH := "res://world/world.tscn"
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
		world.free()
		return failures

	var ids := _capture_persistent_ids(world, failures)
	if zone_manager.call("get_active_zone_id") != &"cemetery":
		failures.append("World should start in the cemetery/property zone")
	if world.get_node_or_null("TechnicalMap") != null:
		failures.append("Persistent world shell should not retain the legacy TechnicalMap")
	if tree.get_nodes_in_group("cemetery_controller").size() != 1:
		failures.append("World integration should expose exactly one cemetery controller")
	_assert_zone_shell_state(world, &"cemetery", failures)

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

	world.free()
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
