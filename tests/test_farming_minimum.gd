class_name TestFarmingMinimum
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var crop_script := load("res://systems/farming/crop_data.gd")
	var plot_script := load("res://systems/farming/farm_plot_state.gd")
	if crop_script == null or plot_script == null:
		failures.append("Phase 8A.3 farming scripts should exist")
		return failures

	var crop: Resource = crop_script.new()
	crop.set("id", &"fodder_turnip")
	crop.set("seed_item_id", &"fodder_turnip_seed")
	crop.set("harvest_item_id", &"fodder_turnip")
	crop.set("growth_minutes", 120)
	crop.set("harvest_amount", 2)

	var seed := _item(&"fodder_turnip_seed")
	var harvest := _item(&"fodder_turnip")
	var inventory := InventoryModel.new(4)
	inventory.add_item(seed, 2)

	var plot: RefCounted = plot_script.new()
	if not bool(plot.call("plant", crop, inventory, 1, 6, 0)):
		failures.append("Planting should consume one seed on an empty plot")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Successful planting should consume exactly one seed")
	if bool(plot.call("plant", crop, inventory, 1, 6, 0)):
		failures.append("An occupied plot should reject planting")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Rejected planting must not consume a seed")

	plot.call("refresh_from_time", 1, 7, 59)
	if bool(plot.call("is_harvestable")):
		failures.append("Crop should not mature before its growth duration")
	plot.call("refresh_from_time", 1, 8, 0)
	if not bool(plot.call("is_harvestable")):
		failures.append("Crop should mature from TimeManager-compatible absolute time")

	var snapshot: Dictionary = plot.call("snapshot")
	var restored: RefCounted = plot_script.new()
	restored.call("apply_snapshot", snapshot, crop)
	if not bool(restored.call("is_harvestable")):
		failures.append("Snapshot restore should preserve harvestable state")
	if not bool(restored.call("harvest", inventory, harvest)):
		failures.append("Harvest should succeed when inventory has capacity")
	if inventory.count_item(&"fodder_turnip") != 2:
		failures.append("Harvest should grant the configured amount exactly once")
	if bool(restored.call("harvest", inventory, harvest)):
		failures.append("Harvest cannot be claimed twice")

	var jump_plot: RefCounted = plot_script.new()
	var step_plot: RefCounted = plot_script.new()
	var jump_inventory := InventoryModel.new(2)
	var step_inventory := InventoryModel.new(2)
	jump_inventory.add_item(seed, 1)
	step_inventory.add_item(seed, 1)
	jump_plot.call("plant", crop, jump_inventory, 2, 23, 30)
	step_plot.call("plant", crop, step_inventory, 2, 23, 30)
	jump_plot.call("refresh_from_time", 3, 2, 0)
	step_plot.call("refresh_from_time", 3, 0, 30)
	step_plot.call("refresh_from_time", 3, 1, 30)
	step_plot.call("refresh_from_time", 3, 2, 0)
	if jump_plot.call("snapshot") != step_plot.call("snapshot"):
		failures.append("Large time jumps and smaller refreshes should be deterministic")

	return failures


static func _item(id: StringName) -> ItemData:
	var item := ItemData.new()
	item.id = id
	item.name_key = StringName("item.%s.name" % id)
	item.description_key = StringName("item.%s.description" % id)
	item.max_stack = 20
	return item
