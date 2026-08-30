class_name TestFarmingMinimum
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Farming test requires a SceneTree")
		return failures
	var time_manager := tree.root.get_node_or_null("TimeManager")
	if time_manager == null:
		failures.append("Farming growth requires the TimeManager autoload")
		return failures

	var crop_script := load("res://systems/farming/crop_data.gd")
	var plot_script := load("res://systems/farming/farm_plot_state.gd")
	var seed := load("res://data/farming/fodder_turnip_seed.tres") as ItemData
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
	var original_time: Dictionary = time_manager.call("snapshot")
	time_manager.call("apply_snapshot", {"day": 1, "hour": 6, "minute": 0})

	var plot: RefCounted = plot_script.new()
	if not _plant_at_current_time(plot, crop, inventory, time_manager):
		failures.append("Planting should consume one seed on an empty plot")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Successful planting should consume exactly one seed")
	if _plant_at_current_time(plot, crop, inventory, time_manager):
		failures.append("An occupied plot should reject planting")
	if inventory.count_item(&"fodder_turnip_seed") != 1:
		failures.append("Rejected planting must not consume a seed")

	time_manager.call("add_minutes", 119)
	_refresh_from_manager(plot, time_manager)
	if bool(plot.call("is_harvestable")):
		failures.append("Crop should not mature before its growth duration")
	time_manager.call("add_minutes", 1)
	_refresh_from_manager(plot, time_manager)
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

	time_manager.call("apply_snapshot", original_time)
	return failures


static func _plant_at_current_time(
	plot: RefCounted, crop: Resource, inventory: InventoryModel, time_manager: Node
) -> bool:
	return bool(
		plot.call(
			"plant",
			crop,
			inventory,
			int(time_manager.get("day")),
			int(time_manager.get("hour")),
			int(time_manager.get("minute"))
		)
	)


static func _refresh_from_manager(plot: RefCounted, time_manager: Node) -> void:
	plot.call(
		"refresh_from_time",
		int(time_manager.get("day")),
		int(time_manager.get("hour")),
		int(time_manager.get("minute"))
	)


static func _item(id: StringName) -> ItemData:
	var item := ItemData.new()
	item.id = id
	item.display_name = String(id)
	item.description = String(id)
	item.max_stack = 20
	return item
