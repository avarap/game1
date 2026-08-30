class_name TestFarmingMinimum
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var crop_script := load("res://systems/farming/crop_data.gd")
	var plot_script := load("res://systems/farming/farm_plot_state.gd")
	var seed: ItemData = load("res://data/farming/fodder_turnip_seed.tres")
	if crop_script == null or plot_script == null:
		failures.append("Phase 8A.3 farming scripts should exist")
		return failures
	if seed == null or seed.id != &"fodder_turnip_seed" or not seed.is_valid():
		failures.append("Fodder turnip seed should exist as a stable valid item resource")
		return failures

	var crop: Resource = crop_script.new()
	crop.set("id", &"fodder_turnip")
	crop.set("seed_item_id", &"fodder_turnip_seed")
	crop.set("harvest_item_id", &"fodder_turnip")
	crop.set("growth_minutes", 120)
	crop.set("harvest_amount", 2)

	var harvest := _item(&"fodder_turnip")
	var inventory := InventoryModel.new(4)
	inventory.add_item(seed, 2)
	var original_time := TimeManager.snapshot()
	TimeManager.set_day(1)
	TimeManager.set_time(6, 0)

	var plot: RefCounted = plot_script.new()
	if not bool(
		plot.call(
			"plant", crop, inventory, TimeManager.day, TimeManager.hour, TimeManager.minute
		)
	):
		failures.append("Planting should consume one seed on an empty plot")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Successful planting should consume exactly one seed")
	if bool(
		plot.call(
			"plant", crop, inventory, TimeManager.day, TimeManager.hour, TimeManager.minute
		)
	):
		failures.append("An occupied plot should reject planting")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Rejected planting must not consume a seed")

	TimeManager.add_minutes(119)
	plot.call("refresh_from_time", TimeManager.day, TimeManager.hour, TimeManager.minute)
	if bool(plot.call("is_harvestable")):
		failures.append("Crop should not mature before its growth duration")
	TimeManager.add_minutes(1)
	plot.call("refresh_from_time", TimeManager.day, TimeManager.hour, TimeManager.minute)
	if not bool(plot.call("is_harvestable")):
		failures.append("Crop should mature from TimeManager time")

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

	TimeManager.apply_snapshot(original_time)
	return failures


static func _item(id: StringName) -> ItemData:
	var item := ItemData.new()
	item.id = id
	item.display_name = String(id)
	item.description = String(id)
	item.max_stack = 20
	return item
