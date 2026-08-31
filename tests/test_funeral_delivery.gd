class_name TestFuneralDelivery
extends RefCounted

const SERVICE_PATH := "res://systems/cemetery/funeral_delivery_service.gd"


static func run() -> Array[String]:
	var failures: Array[String] = []
	if not ResourceLoader.exists(SERVICE_PATH):
		failures.append("Funeral delivery service should exist")
		return failures

	var funeral_script := load(SERVICE_PATH) as Script
	if funeral_script == null:
		failures.append("Funeral delivery service script should load")
		return failures

	_check_daily_delivery_contract(funeral_script, failures)
	_check_save_load_contract(funeral_script, failures)
	return failures


static func _check_daily_delivery_contract(funeral_script: Script, failures: Array[String]) -> void:
	var cemetery := _new_cemetery_service()
	var funeral: Variant = funeral_script.new(cemetery, 2)

	funeral.call("sync_time", 1, 17, 59)
	funeral.call("sync_time", 1, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("17:59 -> 18:00 should create exactly one free introductory corpse")
	if int(funeral.call("fodder_count")) != 0:
		failures.append("First funeral delivery should not consume fodder")

	funeral.call("sync_time", 1, 18, 30)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Funeral service should deliver at most once per logical day")

	funeral.call("deposit_fodder", 2)
	funeral.call("sync_time", 2, 17, 0)
	funeral.call("sync_time", 2, 20, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("17:00 -> 20:00 should create exactly one later delivery when fed")
	if int(funeral.call("fodder_count")) != 0:
		failures.append("Later funeral delivery should consume exactly the configured fodder amount")

	funeral.call("sync_time", 3, 17, 0)
	funeral.call("sync_time", 3, 20, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("Later funeral delivery should not create a corpse without fodder")
	funeral.call("deposit_fodder", 2)
	funeral.call("sync_time", 3, 21, 0)
	if cemetery.pending_corpses.size() != 2:
		failures.append("A missed unfed delivery should stay resolved for that logical day")

	funeral.call("sync_time", 4, 17, 0)
	funeral.call("sync_time", 5, 6, 0)
	if cemetery.pending_corpses.size() != 3:
		failures.append("Sleeping across 18:00 should resolve exactly one scheduled delivery")
	funeral.call("sync_time", 5, 6, 0)
	if cemetery.pending_corpses.size() != 3:
		failures.append("Repeated wake-time synchronization should not duplicate a delivery")

	var ids := cemetery.pending_ids()
	if ids.size() != ids.duplicate().size():
		failures.append("Funeral deliveries should use unique corpse identifiers")
	for corpse_id in ids:
		var corpse := cemetery.pending_corpses.get(corpse_id) as CorpseState
		if corpse == null or corpse.age_minutes != 0 or corpse.decay_percent != 0:
			failures.append("Delivered corpses should enter the existing deterministic corpse model fresh")
			break


static func _check_save_load_contract(funeral_script: Script, failures: Array[String]) -> void:
	var cemetery := _new_cemetery_service()
	var before_save: Variant = funeral_script.new(cemetery, 1)
	before_save.call("sync_time", 7, 17, 59)
	var pre_delivery_snapshot: Dictionary = before_save.call("snapshot")

	var restored_before: Variant = funeral_script.new(cemetery, 1)
	restored_before.call("apply_snapshot", pre_delivery_snapshot)
	restored_before.call("sync_time", 7, 18, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Save/load before 18:00 should not lose the pending scheduled delivery")

	var post_delivery_snapshot: Dictionary = restored_before.call("snapshot")
	if int(post_delivery_snapshot.get("last_resolved_day", 0)) != 7:
		failures.append("Funeral snapshot should persist the logical day already resolved")

	var restored_after: Variant = funeral_script.new(cemetery, 1)
	restored_after.call("apply_snapshot", post_delivery_snapshot)
	restored_after.call("sync_time", 7, 18, 0)
	restored_after.call("sync_time", 7, 20, 0)
	if cemetery.pending_corpses.size() != 1:
		failures.append("Save/load after 18:00 should not duplicate an already resolved delivery")


static func _new_cemetery_service() -> CemeteryService:
	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	return CemeteryService.new(CemeteryModel.new(config))
