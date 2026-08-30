class_name TestEconomyGameplay
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	if tree == null or world_scene == null:
		failures.append("Economy gameplay test requires SceneTree and world scene")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player")
	var controller := world.get_node_or_null("EconomyController")
	if player == null or controller == null:
		failures.append("World should expose player and local EconomyController")
		world.free()
		return failures
	if not _has_economy_contract(controller):
		failures.append("EconomyController should expose trade and persistence contract")
		world.free()
		return failures

	var inventory: InventoryComponent
	if player.has_method("get_inventory_component"):
		inventory = player.call("get_inventory_component") as InventoryComponent
	if inventory == null:
		failures.append("Economy gameplay requires the player inventory")
		world.free()
		return failures

	_test_buy_and_sell(controller, inventory, failures)
	_test_inventory_full_is_atomic(world, controller, failures)
	_test_persistence(controller, inventory, failures)
	if StringName(controller.call("get_save_key")) != &"economy":
		failures.append("EconomyController should persist under the economy save key")
	if not controller.is_in_group("save_provider"):
		failures.append("EconomyController should use the generic save-provider contract")

	world.free()
	return failures


static func _has_economy_contract(controller: Node) -> bool:
	return (
		controller.has_method("buy")
		and controller.has_method("sell")
		and controller.has_method("get_balance_copper")
		and controller.has_method("get_merchant_stock")
		and controller.has_method("get_save_key")
		and controller.has_method("get_save_data")
		and controller.has_method("apply_save_data")
	)


static func _test_buy_and_sell(
	controller: Node, inventory: InventoryComponent, failures: Array[String]
) -> void:
	var balance_before := int(controller.call("get_balance_copper"))
	var stock_before := int(controller.call("get_merchant_stock", &"wood"))
	var wood_before := inventory.count_item(&"wood")
	var buy_result := StringName(controller.call("buy", &"yard_wood", 2, inventory))
	if buy_result != EconomyService.RESULT_OK:
		failures.append("Buying an available offer should succeed")
		return
	if int(controller.call("get_balance_copper")) != balance_before - 16:
		failures.append("Buying two wood should debit the exact copper price")
	if int(controller.call("get_merchant_stock", &"wood")) != stock_before - 2:
		failures.append("Buying should decrement merchant stock")
	if inventory.count_item(&"wood") != wood_before + 2:
		failures.append("Buying should add the purchased items to player inventory")

	var sell_result := StringName(controller.call("sell", &"yard_wood", 1, inventory))
	if sell_result != EconomyService.RESULT_OK:
		failures.append("Selling owned stock should succeed")
		return
	if int(controller.call("get_balance_copper")) != balance_before - 12:
		failures.append("Selling one wood should credit the configured sell price")
	if int(controller.call("get_merchant_stock", &"wood")) != stock_before - 1:
		failures.append("Selling should return the item to merchant stock")
	if inventory.count_item(&"wood") != wood_before + 1:
		failures.append("Selling should remove the sold item from player inventory")


static func _test_inventory_full_is_atomic(
	world: Node, controller: Node, failures: Array[String]
) -> void:
	var full_inventory := InventoryComponent.new()
	full_inventory.capacity_slots = 0
	world.add_child(full_inventory)
	var balance_before := int(controller.call("get_balance_copper"))
	var stock_before := int(controller.call("get_merchant_stock", &"plank"))
	var result := StringName(controller.call("buy", &"yard_plank", 1, full_inventory))
	if result != &"inventory_full":
		failures.append("Purchase without inventory capacity should report inventory_full")
	if int(controller.call("get_balance_copper")) != balance_before:
		failures.append("Rejected purchase must not debit the wallet")
	if int(controller.call("get_merchant_stock", &"plank")) != stock_before:
		failures.append("Rejected purchase must not consume merchant stock")
	if full_inventory.count_item(&"plank") != 0:
		failures.append("Rejected purchase must not add partial inventory")
	full_inventory.free()


static func _test_persistence(
	controller: Node, inventory: InventoryComponent, failures: Array[String]
) -> void:
	var snapshot: Variant = controller.call("get_save_data")
	if typeof(snapshot) != TYPE_DICTIONARY:
		failures.append("Economy save data should be a dictionary snapshot")
		return
	var balance_before := int(controller.call("get_balance_copper"))
	var stock_before := int(controller.call("get_merchant_stock", &"plank"))
	var result := StringName(controller.call("buy", &"yard_plank", 1, inventory))
	if result != EconomyService.RESULT_OK:
		failures.append("Economy persistence test requires a valid purchase")
		return
	controller.call("apply_save_data", snapshot as Dictionary)
	if int(controller.call("get_balance_copper")) != balance_before:
		failures.append("Economy snapshot should restore wallet balance")
	if int(controller.call("get_merchant_stock", &"plank")) != stock_before:
		failures.append("Economy snapshot should restore merchant stock")
