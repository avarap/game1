class_name TestInventoryModel
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var wood := ItemData.new()
	wood.id = &"wood"
	wood.display_name = "Madera"
	wood.max_stack = 5

	if not wood.is_valid():
		failures.append("ItemData should be valid with id and positive max_stack")

	var inventory := InventoryModel.new(2)
	var remainder := inventory.add_item(wood, 12)
	if remainder != 2:
		failures.append("InventoryModel should return amount that does not fit")
	if inventory.count_item(&"wood") != 10:
		failures.append("InventoryModel should fill stacks up to slot capacity")
	if inventory.stacks.size() != 2:
		failures.append("InventoryModel should create the expected number of stacks")

	var removed := inventory.remove_item(&"wood", 7)
	if removed != 7 or inventory.count_item(&"wood") != 3:
		failures.append("InventoryModel should remove requested items across stacks")
	if not inventory.has_item(&"wood", 3):
		failures.append("InventoryModel should report available quantities")
	if inventory.has_item(&"wood", 4):
		failures.append("InventoryModel should reject unavailable quantities")

	inventory.clear()
	if not inventory.stacks.is_empty() or inventory.free_slots() != 2:
		failures.append("InventoryModel clear should restore all slot capacity")

	return failures
