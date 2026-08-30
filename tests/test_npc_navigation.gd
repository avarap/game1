class_name TestNPCNavigation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_npc_data(failures)
	_check_navigation_math(failures)
	_check_world_integration(failures)
	return failures


static func _check_npc_data(failures: Array[String]) -> void:
	var data := load("res://data/npcs/brother_aldren.tres") as NPCData
	if data == null:
		failures.append("Brother Aldren NPCData should load")
		return
	if not data.is_valid():
		failures.append("Brother Aldren NPCData should be valid")
	if data.id != &"brother_aldren":
		failures.append("Brother Aldren should expose a stable data id")
	if data.role != "Sacerdote excéntrico":
		failures.append("Brother Aldren should keep his data-driven role")


static func _check_navigation_math(failures: Array[String]) -> void:
	var velocity := NPCNavigationMath.velocity_toward(Vector2.ZERO, Vector2(3, 4), 10.0)
	if not velocity.is_equal_approx(Vector2(6, 8)):
		failures.append("NPC navigation velocity should preserve requested speed")
	if NPCNavigationMath.velocity_toward(Vector2.ZERO, Vector2.ZERO, 10.0) != Vector2.ZERO:
		failures.append("NPC navigation should stop when no direction remains")
	if not NPCNavigationMath.has_arrived(Vector2(10, 10), Vector2(12, 10), 2.0):
		failures.append("NPC arrival should respect destination tolerance")


static func _check_world_integration(failures: Array[String]) -> void:
	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("World scene should load for NPC navigation acceptance")
		return

	var world := world_scene.instantiate()
	var region := world.get_node_or_null("NavigationRegion") as WorldNavigationRegion
	var npc := world.get_node_or_null("BrotherAldren") as NPCController
	if region == null:
		failures.append("World should expose a local navigation region")
	else:
		region.ensure_navigation_polygon()
		if region.navigation_polygon == null:
			failures.append("World navigation region should provide navigation geometry")
	if npc == null:
		failures.append("World should contain Brother Aldren as the first NPC")
	else:
		if npc.data == null or npc.data.id != &"brother_aldren":
			failures.append("Brother Aldren scene should use NPCData")
		if npc.get_node_or_null("NavigationAgent2D") as NavigationAgent2D == null:
			failures.append("Brother Aldren should own a NavigationAgent2D")
		if npc.initial_target == Vector2.ZERO:
			failures.append("Brother Aldren should have an explicit navigation target")

	world.free()
