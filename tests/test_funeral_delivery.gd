class_name TestFuneralDelivery
extends RefCounted

const SERVICE_PATH := "res://systems/cemetery/funeral_delivery_service.gd"
const FODDER_ITEM_PATH := "res://data/items/fodder_turnip.tres"
const WRONG_FODDER_ITEM_PATH := "res://data/items/fodder_turnip_mash.tres"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(SERVICE_PATH):
		failures.append("Funeral delivery service should exist")
		return failures

	var funeral_script := load(SERVICE_PATH) as Script
	if funeral_script == null:
		failures.append("Funeral delivery service script should load")
		return failures

	_check_daily(funeral_script, failures)
	_check_real_fodder_storage_contract(funeral_script, failures)
	_check_persistence(funeral_script, failures)
	_check_progressive_unloading(funeral_script, failures)
	_check_controller_integration(failures)
	return failures


static func _check_daily(funeral_script: Script, failures: Array[String]) -> void:
	var cemetery := _new_cemetery_service()
	var storage := _new_fodder_storage()
	var funeral: Variant = funeral_script.new(cemetery, storage, 2)

	funeral.call("sync_time", 1, 17, 59)
	funeral.call("sync_time", 1, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("17:59 -> 18:00 should create one free introductory corpse")
	if storage.get_available_amount(&"fodder_turnip") != 0:
		failures.append("First funeral delivery should not consume fodder")

	funeral.call("sync_time", 1, 18, 30)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Funeral service should deliver at most once per day")

	_deposit_fodder(storage, 2)
	funeral.call("sync_time", 2, 17, 0)
	funeral.call("sync_time", 2, 20, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("17:00 -> 20:00 should create one fed delivery")
	if storage.get_available_amount(&"fodder_turnip") != 0:
		failures.append("Later delivery should consume the configured fodder amount")

	funeral.call("sync_time", 3, 17, 0)
	funeral.call("sync_time", 3, 20, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("Later delivery should require fodder")
	_deposit_fodder(storage, 2)
	funeral.call("sync_time", 3, 21, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("A missed unfed delivery should stay resolved that day")

	funeral.call("sync_time", 4, 17, 0)
	funeral.call("sync_time", 5, 6, 0)
	if cemetery.pending_corpses.size() != 3:
		failures.append("Sleeping across 18:00 should resolve one delivery")
	funeral.call("sync_time", 5, 6, 0)
	if cemetery.pending_corpses.size() != 3:
		failures.append("Wake-time resync should not duplicate a delivery")

	for corpse_id in cemetery.pending_ids():
		var corpse := cemetery.pending_corpses.get(corpse_id) as CorpseState
		if corpse == null or corpse.age_minutes != 0 or corpse.decay_percent != 0:
			failures.append("Delivered corpses should use the fresh corpse model")
			break


static func _check_real_fodder_storage_contract(
	funeral_script: Script, failures: Array[String]
) -> void:
	var cemetery := _new_cemetery_service()
	var storage := _new_fodder_storage()
	var funeral: Variant = funeral_script.new(cemetery, storage, 2)
	var wrong_fodder := load(WRONG_FODDER_ITEM_PATH) as ItemData

	funeral.call("sync_time", 20, 17, 59)
	funeral.call("sync_time", 20, 18, 0)
	storage.deposit(wrong_fodder, 4)
	funeral.call("sync_time", 21, 17, 59)
	funeral.call("sync_time", 21, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Only fodder_turnip should qualify for funeral delivery")
	if storage.get_available_amount(&"fodder_turnip_mash") != 4:
		failures.append("Non-fodder_turnip items must not be consumed")

	_deposit_fodder(storage, 1)
	funeral.call("sync_time", 22, 17, 59)
	funeral.call("sync_time", 22, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Insufficient fodder_turnip should not deliver a corpse")
	if storage.get_available_amount(&"fodder_turnip") != 1:
		failures.append("Insufficient stock must not be partially consumed")

	_deposit_fodder(storage, 2)
	funeral.call("sync_time", 23, 17, 59)
	funeral.call("sync_time", 23, 18, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("Sufficient fodder_turnip should permit the next delivery")
	if storage.get_available_amount(&"fodder_turnip") != 1:
		failures.append("Successful delivery should consume exactly two fodder_turnip")


static func _check_persistence(funeral_script: Script, failures: Array[String]) -> void:
	var cemetery := _new_cemetery_service()
	var storage := _new_fodder_storage()
	var before_save: Variant = funeral_script.new(cemetery, storage, 1)
	before_save.call("sync_time", 7, 17, 59)
	var before_snapshot: Dictionary = before_save.call("snapshot")

	var restored_before: Variant = funeral_script.new(cemetery, storage, 1)
	restored_before.call("apply_snapshot", before_snapshot)
	restored_before.call("sync_time", 7, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Save/load before 18:00 should retain the delivery")

	var after_snapshot: Dictionary = restored_before.call("snapshot")
	if int(after_snapshot.get("last_resolved_day", 0)) != 7:
		failures.append("Snapshot should persist the resolved delivery day")
	if after_snapshot.has("fodder_units"):
		failures.append("Funeral snapshot should not persist a shadow fodder counter")

	var restored_after: Variant = funeral_script.new(cemetery, storage, 1)
	restored_after.call("apply_snapshot", after_snapshot)
	restored_after.call("sync_time", 7, 18, 0)
	restored_after.call("sync_time", 7, 20, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Save/load after 18:00 should not duplicate delivery")


static func _check_progressive_unloading(funeral_script: Script, failures: Array[String]) -> void:
	var cemetery := _new_cemetery_service()
	var storage := _new_fodder_storage()
	var funeral: Variant = funeral_script.new(cemetery, storage, 1)
	var missing_api := false
	for method_name in [&"reception_point_for", &"unlock_ramp", &"is_ramp_unlocked"]:
		if not funeral.has_method(method_name):
			failures.append(
				"Funeral delivery should expose %s for progressive unloading" % method_name
			)
			missing_api = true
	if missing_api:
		return

	funeral.call("sync_time", 30, 17, 59)
	funeral.call("sync_time", 30, 18, 0)
	var first_id := cemetery.first_pending_id()
	if StringName(funeral.call("reception_point_for", first_id)) != &"roadside_dropoff":
		failures.append("Before ramp unlock, funeral corpses should use the roadside dropoff")

	if not bool(funeral.call("unlock_ramp")):
		failures.append("Ramp unlock should transition once from the initial state")
	if bool(funeral.call("unlock_ramp")):
		failures.append("Ramp unlock should be idempotent after the first transition")

	_deposit_fodder(storage, 1)
	funeral.call("sync_time", 31, 17, 59)
	funeral.call("sync_time", 31, 18, 0)
	var ids := cemetery.pending_ids()
	if ids.size() != 2:
		failures.append("Ramp unlock must not alter funeral delivery count")
		return
	var second_id := ids[1]
	if StringName(funeral.call("reception_point_for", second_id)) != &"ramp_dropoff":
		failures.append("After ramp unlock, future corpses should use the ramp dropoff")
	if StringName(funeral.call("reception_point_for", first_id)) != &"roadside_dropoff":
		failures.append("Unlocking the ramp must not move corpses delivered earlier")

	var snapshot: Dictionary = funeral.call("snapshot")
	var restored: Variant = funeral_script.new(cemetery, storage, 1)
	restored.call("apply_snapshot", snapshot)
	if not bool(restored.call("is_ramp_unlocked")):
		failures.append("Ramp unlock should persist across save/load")
	if StringName(restored.call("reception_point_for", second_id)) != &"ramp_dropoff":
		failures.append("Per-corpse reception destinations should persist across save/load")

	var legacy: Variant = funeral_script.new(cemetery, storage, 1)
	legacy.call("apply_snapshot", {"intro_delivered": true, "last_resolved_day": 31})
	if bool(legacy.call("is_ramp_unlocked")):
		failures.append("Older saves without ramp data should default to the roadside state")


static func _check_controller_integration(failures: Array[String]) -> void:
	var controller := CemeteryController.new()
	controller.initialize()
	if not controller.has_method("sync_funeral_time"):
		failures.append("Cemetery controller should drive funeral delivery from world time")
		return
	if not controller.has_method("deposit_funeral_fodder"):
		failures.append("Cemetery controller should expose the funeral fodder feeder")
		return

	controller.call("sync_funeral_time", 10, 17, 59)
	controller.call("sync_funeral_time", 10, 18, 0)
	if controller.service.pending_corpses.size() != 1:
		failures.append("Cemetery controller should route the 18:00 delivery into its service")

	controller.call("deposit_funeral_fodder", 3)
	if int(controller.call("funeral_fodder_count")) != 3:
		failures.append("Controller feeder should store real fodder_turnip items")

	var save_data := controller.get_save_data()
	if not save_data.has("funeral_delivery"):
		failures.append("Cemetery save data should include funeral delivery state")
		return
	if int(save_data.get("funeral_feeder_fodder", -1)) != 3:
		failures.append("Cemetery save data should persist dedicated feeder stock")

	var restored := CemeteryController.new()
	restored.initialize()
	restored.apply_save_data(save_data)
	if int(restored.call("funeral_fodder_count")) != 3:
		failures.append("Controller save/load should restore dedicated feeder stock")
		return
	restored.call("sync_funeral_time", 10, 20, 0)
	if restored.service.pending_corpses.size() != 1:
		failures.append("Controller save/load should not duplicate an already resolved delivery")


static func _new_fodder_storage() -> StorageNetwork:
	var inventory := InventoryModel.new(8)
	var provider := StorageProvider.new(&"funeral_feeder", inventory, &"cemetery")
	var network := StorageNetwork.new()
	network.add_provider(provider)
	return network


static func _deposit_fodder(storage: StorageNetwork, amount: int) -> void:
	var fodder := load(FODDER_ITEM_PATH) as ItemData
	storage.deposit(fodder, amount)


static func _new_cemetery_service() -> CemeteryService:
	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	return CemeteryService.new(CemeteryModel.new(config))
