class_name TestFeedbackHooks
extends RefCounted


class Recorder:
	extends RefCounted

	var deliveries: Array[Dictionary] = []
	var decisions: Array[Dictionary] = []

	func on_delivery(corpse_id: StringName, logical_day: int, reception_point: StringName) -> void:
		deliveries.append(
			{
				"corpse_id": corpse_id,
				"logical_day": logical_day,
				"reception_point": reception_point,
			}
		)

	func on_decision(
		corpse_id: StringName,
		decision: StringName,
		red: int,
		green: int,
		blue: int,
	) -> void:
		decisions.append(
			{
				"corpse_id": corpse_id,
				"decision": decision,
				"reward": Vector3i(red, green, blue),
			}
		)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_funeral_delivery_events(failures)
	_check_corpse_decision_events(failures)
	return failures


static func _check_funeral_delivery_events(failures: Array[String]) -> void:
	if not EventBus.has_signal("funeral_delivery_completed"):
		failures.append("EventBus should expose funeral_delivery_completed")
		return

	var recorder := Recorder.new()
	var listener := Callable(recorder, "on_delivery")
	EventBus.connect("funeral_delivery_completed", listener)

	var cemetery := _new_cemetery_service()
	var storage := _new_storage()
	var funeral := FuneralDeliveryService.new(cemetery, storage, 1)
	funeral.sync_time(1, 17, 59)
	funeral.sync_time(1, 18, 0)
	if recorder.deliveries.size() != 1:
		failures.append("A valid funeral delivery should emit exactly one event")
	elif (
		recorder.deliveries[0].logical_day != 1
		or recorder.deliveries[0].corpse_id == &""
		or recorder.deliveries[0].reception_point
		!= FuneralDeliveryService.ROADSIDE_DROPOFF
	):
		failures.append("Funeral delivery event should expose stable structured state")

	funeral.sync_time(1, 18, 0)
	funeral.sync_time(1, 20, 0)
	if recorder.deliveries.size() != 1:
		failures.append("Delivery retry/resync must not emit a duplicate success event")

	var snapshot := funeral.snapshot()
	var restored := FuneralDeliveryService.new(cemetery, storage, 1)
	restored.apply_snapshot(snapshot)
	restored.sync_time(1, 20, 0)
	if recorder.deliveries.size() != 1:
		failures.append("Restoring funeral state must not replay completed-delivery events")

	EventBus.disconnect("funeral_delivery_completed", listener)
	var silent_cemetery := _new_cemetery_service()
	var silent_funeral := FuneralDeliveryService.new(
		silent_cemetery,
		_new_storage(),
		1,
	)
	silent_funeral.sync_time(40, 17, 59)
	silent_funeral.sync_time(40, 18, 0)
	if silent_cemetery.pending_corpses.size() != 1:
		failures.append("Funeral delivery should remain functional with zero listeners")


static func _check_corpse_decision_events(failures: Array[String]) -> void:
	if not EventBus.has_signal("corpse_final_decision_completed"):
		failures.append("EventBus should expose corpse_final_decision_completed")
		return

	var recorder := Recorder.new()
	var listener := Callable(recorder, "on_decision")
	EventBus.connect("corpse_final_decision_completed", listener)

	var config := _rating_config()
	var decision_config := (
		load("res://data/cemetery/default_final_decisions.tres") as CorpseDecisionConfig
	)
	var technology := TechnologyService.new()
	var service := CemeteryService.new(
		CemeteryModel.new(config),
		decision_config,
		technology,
	)

	var cremated := _corpse(&"feedback_cremate", 3)
	service.receive_corpse(cremated)
	if service.finalize_corpse(cremated.data.id, &"cremate") != CemeteryService.RESULT_OK:
		failures.append("Cremate setup should succeed")
	if recorder.decisions.size() != 1 or recorder.decisions[0].decision != &"cremate":
		failures.append("Valid cremate should emit exactly one terminal-decision event")
	elif recorder.decisions[0].reward != decision_config.reward_for(&"cremate", cremated):
		failures.append("Cremate event reward should match committed data-driven reward")

	service.finalize_corpse(cremated.data.id, &"cremate")
	if recorder.decisions.size() != 1:
		failures.append("Cremate retry must not emit a duplicate success event")

	var researched := _corpse(&"feedback_research", 4)
	service.receive_corpse(researched)
	if service.finalize_corpse(researched.data.id, &"research") != CemeteryService.RESULT_OK:
		failures.append("Research setup should succeed")
	if recorder.decisions.size() != 2 or recorder.decisions[1].decision != &"research":
		failures.append("Valid research should emit exactly one terminal-decision event")
	elif recorder.decisions[1].reward != decision_config.reward_for(&"research", researched):
		failures.append("Research event reward should match committed data-driven reward")

	service.finalize_corpse(researched.data.id, &"cremate")
	if recorder.decisions.size() != 2:
		failures.append("Second incompatible terminal decision must not emit success feedback")

	var snapshot := service.snapshot()
	CemeteryService.from_snapshot(
		config,
		snapshot,
		decision_config,
		TechnologyService.new(),
	)
	if recorder.decisions.size() != 2:
		failures.append("Restoring final decisions must not replay terminal-decision events")

	EventBus.disconnect("corpse_final_decision_completed", listener)
	var silent_service := CemeteryService.new(
		CemeteryModel.new(config),
		decision_config,
		TechnologyService.new(),
	)
	var silent_corpse := _corpse(&"feedback_no_listener", 2)
	silent_service.receive_corpse(silent_corpse)
	if (
		silent_service.finalize_corpse(silent_corpse.data.id, &"research")
		!= CemeteryService.RESULT_OK
	):
		failures.append("Terminal corpse decisions should work with zero listeners")


static func _new_cemetery_service() -> CemeteryService:
	return CemeteryService.new(CemeteryModel.new(_rating_config()))


static func _rating_config() -> CemeteryRatingConfig:
	return load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig


static func _new_storage() -> StorageNetwork:
	var inventory := InventoryModel.new(4)
	var provider := StorageProvider.new(&"feedback_hooks", inventory, &"cemetery")
	var network := StorageNetwork.new()
	network.add_provider(provider)
	return network


static func _corpse(id: StringName, quality: int) -> CorpseState:
	var data := CorpseData.new()
	data.id = id
	data.quality = quality
	data.burial_value = 2
	return CorpseState.new(data)
