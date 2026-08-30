class_name TestWorldZones
extends RefCounted

const FOREST_ENTRY := Vector2(2050.0, 500.0)
const HOMESTEAD_ENTRY := Vector2(1450.0, 500.0)


static func run() -> Array[String]:
	var failures: Array[String] = []
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World zones should load world/world.tscn")
		return failures

	var world := world_scene.instantiate()
	_check_zone_layers(world, "Homestead", failures)
	_check_zone_layers(world, "ForestEdge", failures)
	_check_transitions(world, failures)
	world.free()
	return failures


static func _check_zone_layers(world: Node, zone_name: String, failures: Array[String]) -> void:
	var zone := world.get_node_or_null("Zones/%s" % zone_name)
	if not zone is Node2D:
		failures.append("World should expose %s as a zone" % zone_name)
		return

	for layer_name in ["Ground", "Terrain", "Decoration", "Collision", "Foreground", "Navigation"]:
		if not zone.get_node_or_null(layer_name) is TileMapLayer:
			failures.append("%s should expose %s as TileMapLayer" % [zone_name, layer_name])


static func _check_transitions(world: Node, failures: Array[String]) -> void:
	var player := world.get_node_or_null("Player") as CharacterBody2D
	var forest_gate := world.get_node_or_null("Zones/Homestead/ForestGate")
	var homestead_gate := world.get_node_or_null("Zones/ForestEdge/HomesteadGate")
	if player == null:
		failures.append("World zones require the existing player")
		return
	if not forest_gate is Interactable or not homestead_gate is Interactable:
		failures.append("World zones should provide reversible Interactable transitions")
		return

	forest_gate.interact(player)
	if player.global_position != FOREST_ENTRY:
		failures.append("Forest transition should place the player at the forest entry")

	homestead_gate.interact(player)
	if player.global_position != HOMESTEAD_ENTRY:
		failures.append("Return transition should place the player at the homestead entry")
