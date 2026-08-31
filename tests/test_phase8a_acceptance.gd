class_name TestPhase8AAcceptance
extends RefCounted

const FARM_GROWTH_MINUTES := 120


class Recorder:
	extends RefCounted

	var delivery_count: int = 0
	var decision_count: int = 0

	func on_delivery(_id: StringName, _day: int, _point: StringName) -> void:
		delivery_count += 1

	func on_decision(
		_id: StringName, _decision: StringName, _red: int, _green: int, _blue: int
	) -> void:
		decision_count += 1


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Phase 8A acceptance requires a SceneTree")
		return failures
	var bus := tree.root.get_node_or_null("EventBus")
	if bus == null:
		failures.append("Phase 8A acceptance requires EventBus")
		return failures

	var world_scene := load("res://world/world.tscn") as PackedScene
	if world_scene == null:
		failures.append("Phase 8A acceptance requires the world scene")
		return failures
	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var cemetery := world.get_node_or_null("CemeteryController") as CemeteryController
	var technology := world.get_node_or_null("TechnologyController") as TechnologyController
	if cemetery == null or technology == null:
		failures.append("World should expose cemetery and technology controllers")
		world.free()
		return failures

	var recorder := Recorder.new()
	var delivery_listener := Callable(recorder, "on_delivery")
	var decision_listener := Callable(recorder, "on_decision")
	bus.connect("funeral_delivery_completed", delivery_listener)
	bus.connect("corpse_final_decision_completed", decision_listener)

	_check_seed_to_fodder(cemetery, failures)
	_check_delivery_decay_logistics_and_decision(cemetery, technology, recorder, failures)

	bus.disconnect("funeral_delivery_completed", delivery_listener)
	bus.disconnect("corpse_final_decision_completed", decision_listener)
	world.free()
	return failures


static func _check_seed_to_fodder(cemetery: CemeteryController, failures: Array[String]) -> void:
	var seed := load("res://data/farming/fodder_turnip_seed.tres") as ItemData
	var harvest_item := load("res://data/items/fodder_turnip.tres") as ItemData
	var merchant := load("res://data/economy/yard_supplier.tres") as MerchantData
	if seed == null or harvest_item == null or merchant == null:
		failures.append("Phase 8A seed, fodder and merchant data should load")
		return

	var seed_offer := merchant.get_offer(&"yard_fodder_turnip_seed")
	var wallet := WalletState.new(100)
	var merchant_state := merchant.create_state()
	var tx := EconomyService.simulate_buy(wallet, merchant_state, seed_offer, 1)
	if not tx.is_success() or not EconomyService.apply_transaction(tx, wallet, merchant_state):
		failures.append("Phase 8A should obtain fodder_turnip_seed through the economy route")
		return

	var inventory := InventoryModel.new(4)
	inventory.add_item(seed, 1)
	var crop_script := load("res://systems/farming/crop_data.gd") as Script
	var plot_script := load("res://systems/farming/farm_plot_state.gd") as Script
	if crop_script == null or plot_script == null:
		failures.append("Phase 8A farming scripts should load")
		return
	var crop: Resource = crop_script.new()
	crop.set("id", &"fodder_turnip")
	crop.set("seed_item_id", &"fodder_turnip_seed")
	crop.set("harvest_item_id", &"fodder_turnip")
	crop.set("growth_minutes", FARM_GROWTH_MINUTES)
	crop.set("harvest_amount", 2)

	var plot: RefCounted = plot_script.new()
	if not bool(plot.call("plant", crop, inventory, 1, 6, 0)):
		failures.append("Phase 8A should plant the purchased fodder seed")
		return
	var planted_snapshot: Dictionary = plot.call("snapshot")
	var restored_plot: RefCounted = plot_script.new()
	restored_plot.call("apply_snapshot", planted_snapshot, crop)
	restored_plot.call("refresh_from_time", 1, 7, 0)
	if bool(restored_plot.call("is_harvestable")):
		failures.append("Phase 8A crop should not mature after only one small step")
	restored_plot.call("refresh_from_time", 1, 8, 0)
	if not bool(restored_plot.call("is_harvestable")):
		failures.append("Phase 8A crop should mature after deterministic accumulated time")
		return
	if not bool(restored_plot.call("harvest", inventory, harvest_item)):
		failures.append("Phase 8A should harvest fodder_turnip")
		return
	if inventory.count_item(&"fodder_turnip") != 2:
		failures.append("Phase 8A harvest should grant exactly two fodder_turnip")
		return
	if bool(restored_plot.call("harvest", inventory, harvest_item)):
		failures.append("Phase 8A harvest retry must not duplicate fodder")

	var jump_inventory := InventoryModel.new(2)
	jump_inventory.add_item(seed, 1)
	var jump_plot: RefCounted = plot_script.new()
	jump_plot.call("plant", crop, jump_inventory, 2, 23, 30)
	jump_plot.call("refresh_from_time", 3, 1, 30)
	var step_inventory := InventoryModel.new(2)
	step_inventory.add_item(seed, 1)
	var step_plot: RefCounted = plot_script.new()
	step_plot.call("plant", crop, step_inventory, 2, 23, 30)
	step_plot.call("refresh_from_time", 3, 0, 30)
	step_plot.call("refresh_from_time", 3, 1, 30)
	if jump_plot.call("snapshot") != step_plot.call("snapshot"):
		failures.append("Phase 8A farming should match for large jumps and small steps")

	cemetery.deposit_funeral_fodder(inventory.count_item(&"fodder_turnip"))
	if cemetery.funeral_fodder_count() != 2:
		failures.append("Phase 8A harvested fodder should feed the funeral feeder")


static func _check_delivery_decay_logistics_and_decision(
	cemetery: CemeteryController,
	technology: TechnologyController,
	recorder: Recorder,
	failures: Array[String]
) -> void:
	cemetery.sync_funeral_time(10, 17, 59)
	var before_delivery := cemetery.get_save_data()
	cemetery.apply_save_data(before_delivery)
	cemetery.sync_funeral_time(10, 18, 0)
	if cemetery.service.pending_corpses.size() != 1:
		failures.append("Phase 8A 18:00 crossing should deliver exactly one corpse")
		return
	if recorder.delivery_count != 1:
		failures.append("Phase 8A valid delivery should emit exactly one feedback event")
		return
	cemetery.sync_funeral_time(10, 18, 0)
	cemetery.sync_funeral_time(10, 20, 0)
	if cemetery.service.pending_corpses.size() != 1 or recorder.delivery_count != 1:
		failures.append("Phase 8A delivery retries must not duplicate corpse or feedback")

	var corpse_id := cemetery.service.first_pending_id()
	var corpse := cemetery.service.pending_corpses.get(corpse_id) as CorpseState
	if corpse == null:
		failures.append("Phase 8A delivered corpse should be reachable from cemetery state")
		return
	var first_reception := cemetery.funeral_service.reception_point_for(corpse_id)
	if first_reception != FuneralDeliveryService.ROADSIDE_DROPOFF:
		failures.append("Phase 8A first corpse should use the roadside dropoff")

	var preservation_script := load("res://systems/cemetery/preservation_modifiers.gd") as Script
	var modifiers: RefCounted = preservation_script.new()
	modifiers.set("technology_bp", 8000)
	modifiers.set("facility_bp", 7500)
	corpse.call("set_preservation_modifiers", modifiers)
	var baseline_snapshot := corpse.snapshot()
	var stepped := CorpseState.from_snapshot(baseline_snapshot)
	var jumped := CorpseState.from_snapshot(baseline_snapshot)
	stepped.advance_decomposition(60)
	stepped.advance_decomposition(60)
	jumped.advance_decomposition(120)
	if stepped.age_minutes != jumped.age_minutes or stepped.decay_percent != jumped.decay_percent:
		failures.append("Phase 8A preserved decay should be deterministic for steps and jumps")
	corpse.advance_decomposition(24 * 60)
	if corpse.age_minutes != 24 * 60 or corpse.decay_percent <= 0:
		failures.append("Phase 8A corpse should age and decay while preservation remains active")

	if not cemetery.funeral_service.unlock_ramp():
		failures.append("Phase 8A logistics upgrade should unlock the ramp once")
	if cemetery.funeral_service.unlock_ramp():
		failures.append("Phase 8A logistics upgrade retry should be idempotent")
	var after_ramp := cemetery.get_save_data()
	cemetery.apply_save_data(after_ramp)
	if not cemetery.funeral_service.is_ramp_unlocked():
		failures.append("Phase 8A logistics upgrade should survive save/load")
	var restored_reception := cemetery.funeral_service.reception_point_for(corpse_id)
	if restored_reception != FuneralDeliveryService.ROADSIDE_DROPOFF:
		failures.append("Phase 8A ramp unlock must not relocate an existing corpse")

	var decisions := load("res://data/cemetery/default_final_decisions.tres") as CorpseDecisionConfig
	var expected_reward := decisions.reward_for(&"research", corpse)
	var blue_before := technology.get_points(TechnologyService.PointType.BLUE)
	var result := cemetery.service.finalize_corpse(corpse_id, &"research")
	if result != CemeteryService.RESULT_OK:
		failures.append("Phase 8A delivered corpse should support a terminal research decision")
		return
	if recorder.decision_count != 1:
		failures.append("Phase 8A terminal decision should emit exactly one feedback event")
	var blue_after := technology.get_points(TechnologyService.PointType.BLUE)
	if blue_after != blue_before + expected_reward.z:
		failures.append("Phase 8A terminal decision reward should reach world technology exactly once")

	var after_decision := cemetery.get_save_data()
	cemetery.apply_save_data(after_decision)
	var retry_result := cemetery.service.finalize_corpse(corpse_id, &"cremate")
	if retry_result != CemeteryService.RESULT_ALREADY_FINALIZED:
		failures.append("Phase 8A restored corpse decision should reject a second terminal action")
	if technology.get_points(TechnologyService.PointType.BLUE) != blue_after:
		failures.append("Phase 8A restore/retry must not duplicate technology rewards")
	if recorder.decision_count != 1:
		failures.append("Phase 8A restore/retry must not replay terminal feedback")
	cemetery.sync_funeral_time(10, 22, 0)
	if recorder.delivery_count != 1 or not cemetery.service.pending_corpses.is_empty():
		failures.append("Phase 8A restore must not replay delivery or resurrect finalized corpses")
