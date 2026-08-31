class_name TestFeedbackHooks
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_funeral_delivery_events(failures)
	_check_corpse_decision_events(failures)
	return failures


static func _check_funeral_delivery_events(failures: Array[String]) -> void:
	if not EventBus.has_signal("funeral_delivery_completed"):
		failures.append("EventBus should expose funeral_delivery_completed")
		return

	var events: Array[Dictionary] = []
	var listener := func(corpse_id, logical_day, reception_point):
		events.append(
			{
				"corpse_id": StringName(corpse_id),
				"logical_day": int(logical_day),
				"reception_point": StringName(reception_point),
			}
		)
	EventBus.connect("funeral_delivery_completed", listener)

	var cemetery := _new_cemetery_service()
	var storage := _new_storage()
	var funeral := FuneralDeliveryService.new(cemetery, storage, 1)
	funeral.sync_time(1, 17, 59)
	funeral.sync_time(1, 18, 0)
	if events.size() != 1:
		failures.append("A valid funeral delivery should emit exactly one event")
	elif (
		events[0].logical_day != 1
		or events[0].corpse_id == &""
		or events[0].reception_point != FuneralDeliveryService.ROADSIDE_DROPOFF
	):
		failures.append("Funeral delivery event should expose stable structured state")

	funeral.sync_time(1, 18, 0)
	funeral.sync_time(1, 20, 0)
	if events.size() != 1:
		failures.append("Delivery retry/resync must not emit a duplicate success event")

	var snapshot := funeral.snapshot()
	var restored := FuneralDeliveryService.new(cemetery, storage, 1)
	restored.apply_snapshot(snapshot)
	restored.sync_time(1, 20, 0)
	if events.size() != 1:
		failures.append("Restoring funeral state must not replay completed-delivery events")

	EventBus.disconnect("funeral_delivery_completed", listener)
	var no_listener_cemetery := _new_cemetery_service()
	var no_listener_funeral := FuneralDeliveryService.new(no_listener_cemetery, _new_storage(), 1)
	no_listener_funeral.sync_time(40, 17, 59)
	no_listener_funeral.sync_time(40, 18, 0)
	if no_listener_cemetery.pending_corpses.size() != 1:
		failures.append("Funeral delivery should remain functional with zero listeners")


static func _check_corpse_decision_events(failures: Array[String]) -> void:
	if not EventBus.has_signal("corpse_final_decision_completed"):
		failures.append("EventBus should expose corpse_final_decision_completed")
		return

	var events: Array[Dictionary] = []
	var listener := func(corpse_id, decision, red, green, blue):
		events.append(
			{
				"corpse_id": StringName(corpse_id),
				"decision": StringName(decision),
				"reward": Vector3i(int(red), int(green), int(blue)),
			}
		)
	EventBus.connect("corpse_final_decision_completed", listener)

	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	var decisions := (
		load("res://data/cemetery/default_final_decisions.tres") as CorpseDecisionConfig
	)
	var technology := TechnologyService.new()
	var service := CemeteryService.new(CemeteryModel.new(config), decisions, technology)

	var cremated := _corpse(&"feedback_cremate", 3)
	service.receive_corpse(cremated)
	if service.finalize_corpse(cremated.data.id, &"cremate") != CemeteryService.RESULT_OK:
		failures.append("Cremate setup should succeed")
	if events.size() != 1 or events[0].decision != &"cremate":
		failures.append("Valid cremate should emit exactly one terminal-decision event")
	elif events[0].reward != decisions.reward_for(&"cremate", cremated):
		failures.append("Cremate event reward should match committed data-driven reward")

	service.finalize_corpse(cremated.data.id, &"cremate")
	if events.size() != 1:
		failures.append("Cremate retry must not emit a duplicate success event")

	var researched := _corpse(&"feedback_research", 4)
	service.receive_corpse(researched)
	if service.finalize_corpse(researched.data.id, &"research") != CemeteryService.RESULT_OK:
		failures.append("Research setup should succeed")
	if events.size() != 2 or events[1].decision != &"research":
		failures.append("Valid research should emit exactly one terminal-decision event")
	elif events[1].reward != decisions.reward_for(&"research", researched):
		failures.append("Research event reward should match committed data-driven reward")

	service.finalize_corpse(researched.data.id, &"cremate")
	if events.size() != 2:
		failures.append("Second incompatible terminal decision must not emit success feedback")

	var snapshot := service.snapshot()
	CemeteryService.from_snapshot(config, snapshot, decisions, TechnologyService.new())
	if events.size() != 2:
		failures.append("Restoring final decisions must not replay terminal-decision events")

	EventBus.disconnect("corpse_final_decision_completed", listener)
	var silent_service := CemeteryService.new(
		CemeteryModel.new(config), decisions, TechnologyService.new()
	)
	var silent_corpse := _corpse(&"feedback_no_listener", 2)
	silent_service.receive_corpse(silent_corpse)
	if (
		silent_service.finalize_corpse(silent_corpse.data.id, &"research")
		!= CemeteryService.RESULT_OK
	):
		failures.append("Terminal corpse decisions should work with zero listeners")


static func _new_cemetery_service() -> CemeteryService:
	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	return CemeteryService.new(CemeteryModel.new(config))


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
