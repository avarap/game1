class_name TestTechnologyGameplay
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	if tree == null or world_scene == null:
		failures.append("Technology gameplay test requires SceneTree and world scene")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var controller := world.get_node_or_null("TechnologyController")
	if controller == null:
		failures.append("World should expose local TechnologyController")
		world.free()
		return failures
	if not _has_contract(controller):
		failures.append("TechnologyController should expose unlock and persistence contract")
		world.free()
		return failures

	_test_unlock(controller, failures)
	_test_persistence(controller, failures)
	if StringName(controller.call("get_save_key")) != &"technology":
		failures.append("TechnologyController should persist under technology save key")
	if not controller.is_in_group("save_provider"):
		failures.append("TechnologyController should use generic save-provider contract")

	world.free()
	return failures


static func _has_contract(controller: Node) -> bool:
	return (
		controller.has_method("unlock")
		and controller.has_method("is_unlocked")
		and controller.has_method("is_content_unlocked")
		and controller.has_method("get_points")
		and controller.has_method("get_save_key")
		and controller.has_method("get_save_data")
		and controller.has_method("apply_save_data")
	)


static func _test_unlock(controller: Node, failures: Array[String]) -> void:
	if int(controller.call("get_points", TechnologyService.PointType.RED)) != 3:
		failures.append("World technology controller should start with three red points")
	if int(controller.call("get_points", TechnologyService.PointType.GREEN)) != 2:
		failures.append("World technology controller should start with two green points")
	if int(controller.call("get_points", TechnologyService.PointType.BLUE)) != 1:
		failures.append("World technology controller should start with one blue point")

	var result := StringName(controller.call("unlock", &"sturdy_joinery"))
	if result != TechnologyService.RESULT_OK:
		failures.append("World technology should unlock when points are available")
		return
	if not bool(controller.call("is_unlocked", &"sturdy_joinery")):
		failures.append("TechnologyController should expose unlocked technology state")
	if not bool(controller.call("is_content_unlocked", &"recipe_reinforced_fence")):
		failures.append("TechnologyController should expose unlocked content IDs")
	if int(controller.call("get_points", TechnologyService.PointType.RED)) != 1:
		failures.append("World technology unlock should consume red points")
	if int(controller.call("get_points", TechnologyService.PointType.GREEN)) != 1:
		failures.append("World technology unlock should consume green points")


static func _test_persistence(controller: Node, failures: Array[String]) -> void:
	var snapshot: Variant = controller.call("get_save_data")
	if typeof(snapshot) != TYPE_DICTIONARY:
		failures.append("TechnologyController save data should be a dictionary")
		return
	controller.call("reset_progress_for_tests")
	if bool(controller.call("is_unlocked", &"sturdy_joinery")):
		failures.append("Technology test reset should clear unlocked state")
	controller.call("apply_save_data", snapshot as Dictionary)
	if not bool(controller.call("is_unlocked", &"sturdy_joinery")):
		failures.append("Technology snapshot should restore unlocked technology")
	if not bool(controller.call("is_content_unlocked", &"recipe_reinforced_fence")):
		failures.append("Technology snapshot should restore unlocked content")
	if int(controller.call("get_points", TechnologyService.PointType.RED)) != 1:
		failures.append("Technology snapshot should restore remaining red points")
