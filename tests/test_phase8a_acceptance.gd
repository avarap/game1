class_name TestPhase8AAcceptance
extends RefCounted

const FARM_GROWTH_MINUTES := 120
const DECISIONS_PATH := "res://data/cemetery/default_final_decisions.tres"
const PRESERVATION_PATH := "res://systems/cemetery/preservation_modifiers.gd"


class Recorder:
	extends RefCounted

	var deliveries: int = 0
	var decisions: int = 0

	func on_delivery(_id: StringName, _day: int, _point: StringName) -> void:
		deliveries += 1

	func on_decision(_id: StringName, _d: StringName, _r: int, _g: int, _b: int) -> void:
		decisions += 1


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		failures.append("Phase 8A requires a SceneTree")
		return failures
	var bus := tree.root.get_node_or_null("EventBus")
	if bus == null:
		failures.append("Phase 8A requires EventBus")
		return failures

	var packed := load("res://world/world.tscn") as PackedScene
	if packed == null:
		failures.append("Phase 8A requires the world scene")
		return failures
	var world := packed.instantiate()
	tree.root.add_child(world)
	var cemetery := world.get_node_or_null("CemeteryController") as CemeteryController
	var tech := world.get_node_or_null("TechnologyController") as TechnologyController
	if cemetery == null or tech == null:
		failures.append("World must expose cemetery and technology")
		world.free()
		return failures

	var recorder := Recorder.new()
	var delivery_cb := Callable(recorder, "on_delivery")
	var decision_cb := Callable(recorder, "on_decision")
	bus.connect("funeral_delivery_completed", delivery_cb)
	bus.connect("corpse_final_decision_completed", decision_cb)

	_check_farming(cemetery, failures)
	_check_funeral(cemetery, tech, recorder, failures)

	bus.disconnect("funeral_delivery_completed", delivery_cb)
	bus.disconnect("corpse_final_decision_completed", decision_cb)
	world.free()
	return failures


static func _check_farming(cemetery: CemeteryController, failures: Array[String]) -> void:
	var seed := load("res://data/farming/fodder_turnip_seed.tres") as ItemData
	var fodder := load("res://data/items/fodder_turnip.tres") as ItemData
	var merchant := load("res://data/economy/yard_supplier.tres") as MerchantData
	if seed == null or fodder == null or merchant == null:
		failures.append("Phase 8A farming data must load")
		return

	var offer := merchant.get_offer(&"yard_fodder_turnip_seed")
	var wallet := WalletState.new(100)
	var merchant_state := merchant.create_state()
	var tx := EconomyService.simulate_buy(wallet, merchant_state, offer, 1)
	var bought := EconomyService.apply_transaction(tx, wallet, merchant_state)
	if not tx.is_success() or not bought:
		failures.append("Phase 8A must buy the fodder seed")
		return

	var inventory := InventoryModel.new(4)
	inventory.add_item(seed, 1)
	var crop_script := load("res://systems/farming/crop_data.gd") as Script
	var plot_script := load("res://systems/farming/farm_plot_state.gd") as Script
	if crop_script == null or plot_script == null:
		failures.append("Phase 8A farming scripts must load")
		return
	var crop: Resource = crop_script.new()
	crop.set("id", &"fodder_turnip")
	crop.set("seed_item_id", &"fodder_turnip_seed")
	crop.set("harvest_item_id", &"fodder_turnip")
	crop.set("growth_minutes", FARM_GROWTH_MINUTES)
	crop.set("harvest_amount", 2)

	var plot: RefCounted = plot_script.new()
	if not bool(plot.call("plant", crop, inventory, 1, 6, 0)):
		failures.append("Phase 8A must plant the purchased seed")
		return
	var planted: Dictionary = plot.call("snapshot")
	var restored: RefCounted = plot_script.new()
	restored.call("apply_snapshot", planted, crop)
	restored.call("refresh_from_time", 1, 7, 0)
	if bool(restored.call("is_harvestable")):
		failures.append("Crop must not mature after one small step")
	restored.call("refresh_from_time", 1, 8, 0)
	if not bool(restored.call("is_harvestable")):
		failures.append("Crop must mature after deterministic elapsed time")
		return
	if not bool(restored.call("harvest", inventory, fodder)):
		failures.append("Phase 8A must harvest fodder_turnip")
		return
	if inventory.count_item(&"fodder_turnip") != 2:
		failures.append("Harvest must grant exactly two fodder_turnip")
		return
	if bool(restored.call("harvest", inventory, fodder)):
		failures.append("Harvest retry must not duplicate fodder")

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
		failures.append("Farm steps and large jumps must match")

	var harvested := inventory.count_item(&"fodder_turnip")
	cemetery.deposit_funeral_fodder(harvested)
	if cemetery.funeral_fodder_count() != 2:
		failures.append("Harvested fodder must reach the funeral feeder")


static func _check_funeral(
	cemetery: CemeteryController,
	tech: TechnologyController,
	recorder: Recorder,
	failures: Array[String]
) -> void:
	cemetery.sync_funeral_time(10, 17, 59)
	var pre_delivery := cemetery.get_save_data()
	cemetery.apply_save_data(pre_delivery)
	cemetery.sync_funeral_time(10, 18, 0)
	if cemetery.service.pending_corpses.size() != 1:
		failures.append("18:00 must deliver exactly one corpse")
		return
	if recorder.deliveries != 1:
		failures.append("Delivery must emit exactly one feedback event")
		return
	cemetery.sync_funeral_time(10, 18, 0)
	cemetery.sync_funeral_time(10, 20, 0)
	var first_retry_ok := cemetery.service.pending_corpses.size() == 1
	first_retry_ok = first_retry_ok and recorder.deliveries == 1
	if not first_retry_ok:
		failures.append("Delivery retry must not duplicate state or feedback")

	var corpse_id := cemetery.service.first_pending_id()
	var corpse := cemetery.service.pending_corpses.get(corpse_id) as CorpseState
	if corpse == null:
		failures.append("Delivered corpse must remain reachable")
		return
	var first_point := cemetery.funeral_service.reception_point_for(corpse_id)
	if first_point != FuneralDeliveryService.ROADSIDE_DROPOFF:
		failures.append("First corpse must use roadside dropoff")

	var preservation_script := load(PRESERVATION_PATH) as Script
	var modifiers: RefCounted = preservation_script.new()
	modifiers.set("technology_bp", 8000)
	modifiers.set("facility_bp", 7500)
	corpse.call("set_preservation_modifiers", modifiers)
	var baseline := corpse.snapshot()
	var stepped := CorpseState.from_snapshot(baseline)
	var jumped := CorpseState.from_snapshot(baseline)
	stepped.advance_decomposition(60)
	stepped.advance_decomposition(60)
	jumped.advance_decomposition(120)
	var same_age := stepped.age_minutes == jumped.age_minutes
	var same_decay := stepped.decay_percent == jumped.decay_percent
	if not same_age or not same_decay:
		failures.append("Preserved decay must match for steps and jumps")
	corpse.advance_decomposition(24 * 60)
	if corpse.age_minutes != 24 * 60 or corpse.decay_percent <= 0:
		failures.append("Corpse must age and decay with preservation active")

	if not cemetery.funeral_service.unlock_ramp():
		failures.append("Logistics ramp must unlock once")
	if cemetery.funeral_service.unlock_ramp():
		failures.append("Logistics ramp retry must be idempotent")
	var post_ramp := cemetery.get_save_data()
	cemetery.apply_save_data(post_ramp)
	if not cemetery.funeral_service.is_ramp_unlocked():
		failures.append("Logistics ramp must survive save/load")
	var restored_point := cemetery.funeral_service.reception_point_for(corpse_id)
	if restored_point != FuneralDeliveryService.ROADSIDE_DROPOFF:
		failures.append("Ramp unlock must not relocate an existing corpse")

	var fodder_before := cemetery.funeral_fodder_count()
	var fodder_cost := cemetery.funeral_service.fodder_cost
	cemetery.sync_funeral_time(11, 17, 59)
	cemetery.sync_funeral_time(11, 18, 0)
	var second_delivery_ok := cemetery.service.pending_corpses.size() == 2
	second_delivery_ok = second_delivery_ok and recorder.deliveries == 2
	if not second_delivery_ok:
		failures.append("Upgraded next-day delivery must occur exactly once")
		return
	if cemetery.funeral_fodder_count() != fodder_before - fodder_cost:
		failures.append("Regular delivery must consume configured fodder")
	var second_id := _other_pending_id(cemetery.service, corpse_id)
	if second_id == &"":
		failures.append("Upgraded delivery must create a distinct corpse")
		return
	var second_point := cemetery.funeral_service.reception_point_for(second_id)
	if second_point != FuneralDeliveryService.RAMP_DROPOFF:
		failures.append("Future corpses must use ramp dropoff")
	cemetery.sync_funeral_time(11, 18, 0)
	cemetery.sync_funeral_time(11, 22, 0)
	var second_retry_ok := cemetery.service.pending_corpses.size() == 2
	second_retry_ok = second_retry_ok and recorder.deliveries == 2
	if not second_retry_ok:
		failures.append("Upgraded delivery retry must not duplicate")

	var pre_decision := cemetery.get_save_data()
	cemetery.apply_save_data(pre_decision)
	var restore_ok := recorder.deliveries == 2
	restore_ok = restore_ok and cemetery.service.pending_corpses.size() == 2
	if not restore_ok:
		failures.append("Restore must not replay successful delivery")
	var restored := cemetery.service.pending_corpses.get(corpse_id) as CorpseState
	var choices := load(DECISIONS_PATH) as CorpseDecisionConfig
	var reward := choices.reward_for(&"research", restored)
	var blue_before := tech.get_points(TechnologyService.PointType.BLUE)
	var result := cemetery.service.finalize_corpse(corpse_id, &"research")
	if result != CemeteryService.RESULT_OK:
		failures.append("Delivered corpse must support research decision")
		return
	if recorder.decisions != 1:
		failures.append("Terminal decision must emit exactly one feedback event")
	var blue_after := tech.get_points(TechnologyService.PointType.BLUE)
	if blue_after != blue_before + reward.z:
		failures.append("Decision reward must reach world technology once")

	var post_decision := cemetery.get_save_data()
	cemetery.apply_save_data(post_decision)
	var retry := cemetery.service.finalize_corpse(corpse_id, &"cremate")
	if retry != CemeteryService.RESULT_ALREADY_FINALIZED:
		failures.append("Second terminal decision must be rejected")
	if tech.get_points(TechnologyService.PointType.BLUE) != blue_after:
		failures.append("Restore/retry must not duplicate technology reward")
	if recorder.decisions != 1:
		failures.append("Restore/retry must not replay terminal feedback")
	cemetery.sync_funeral_time(11, 23, 0)
	var final_count_ok := cemetery.service.pending_corpses.size() == 1
	var final_delivery_ok := recorder.deliveries == 2
	if not final_count_ok or not final_delivery_ok:
		failures.append("Restore must not replay or resurrect finalized corpse")
	if cemetery.service.pending_corpses.has(corpse_id):
		failures.append("Finalized corpse must remain absent after restore")
	if not cemetery.service.pending_corpses.has(second_id):
		failures.append("Unrelated pending corpse must survive restore")


static func _other_pending_id(service: CemeteryService, excluded: StringName) -> StringName:
	for pending_id in service.pending_ids():
		if pending_id != excluded:
			return pending_id
	return &""
