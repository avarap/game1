class_name TestTechnologyFoundation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var technology := _make_technology()
	var service := TechnologyService.new()
	if not service.register(technology):
		failures.append("TechnologyService should register valid TechnologyData")
		return failures

	service.set_points(3, 2, 1)
	_test_unlock_costs(service, failures)
	_test_idempotency(service, failures)
	_test_insufficient_points(failures)
	_test_snapshot(technology, service, failures)
	return failures


static func _make_technology() -> TechnologyData:
	var technology := TechnologyData.new()
	technology.id = &"sturdy_joinery"
	technology.category = TechnologyData.Category.CONSTRUCTION
	technology.red_cost = 2
	technology.green_cost = 1
	technology.blue_cost = 0
	technology.unlock_ids = [&"recipe_reinforced_fence"]
	return technology


static func _test_unlock_costs(service: TechnologyService, failures: Array[String]) -> void:
	var result := service.unlock(&"sturdy_joinery")
	if result != TechnologyService.RESULT_OK:
		failures.append("Affordable technology should unlock")
		return
	if service.get_points(TechnologyService.PointType.RED) != 1:
		failures.append("Technology unlock should consume exact red points")
	if service.get_points(TechnologyService.PointType.GREEN) != 1:
		failures.append("Technology unlock should consume exact green points")
	if service.get_points(TechnologyService.PointType.BLUE) != 1:
		failures.append("Technology unlock should not consume unused blue points")
	if not service.is_content_unlocked(&"recipe_reinforced_fence"):
		failures.append("Technology should unlock its declared content ID")


static func _test_idempotency(service: TechnologyService, failures: Array[String]) -> void:
	var before_red := service.get_points(TechnologyService.PointType.RED)
	var before_green := service.get_points(TechnologyService.PointType.GREEN)
	var result := service.unlock(&"sturdy_joinery")
	if result != TechnologyService.RESULT_ALREADY_UNLOCKED:
		failures.append("Unlocking the same technology twice should be rejected")
	if service.get_points(TechnologyService.PointType.RED) != before_red:
		failures.append("Duplicate unlock must not consume red points twice")
	if service.get_points(TechnologyService.PointType.GREEN) != before_green:
		failures.append("Duplicate unlock must not consume green points twice")


static func _test_insufficient_points(failures: Array[String]) -> void:
	var technology := _make_technology()
	var service := TechnologyService.new()
	service.register(technology)
	service.set_points(1, 0, 9)
	var snapshot := service.snapshot()
	var result := service.unlock(&"sturdy_joinery")
	if result != TechnologyService.RESULT_INSUFFICIENT_POINTS:
		failures.append("Technology should reject unlock without required point balance")
	if service.snapshot() != snapshot:
		failures.append("Rejected technology unlock must leave state unchanged")


static func _test_snapshot(
	technology: TechnologyData, service: TechnologyService, failures: Array[String]
) -> void:
	var snapshot := service.snapshot()
	var restored := TechnologyService.new()
	restored.register(technology)
	if not restored.apply_snapshot(snapshot):
		failures.append("Technology snapshot should restore into registered service")
		return
	if not restored.is_unlocked(&"sturdy_joinery"):
		failures.append("Technology snapshot should restore unlocked technologies")
	if not restored.is_content_unlocked(&"recipe_reinforced_fence"):
		failures.append("Technology snapshot should rebuild unlocked content IDs")
	if restored.get_points(TechnologyService.PointType.RED) != 1:
		failures.append("Technology snapshot should restore remaining point balances")
