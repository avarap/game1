class_name TestFeedbackHooks
extends RefCounted


class Recorder:
	extends RefCounted

	var delivery_count: int = 0
	var decision_count: int = 0
	var last_delivery_id: StringName = &""
	var last_delivery_day: int = 0
	var last_reception_point: StringName = &""
	var last_decision: StringName = &""
	var last_reward: Vector3i = Vector3i.ZERO

	func on_delivery(id: StringName, day: int, point: StringName) -> void:
		delivery_count += 1
		last_delivery_id = id
		last_delivery_day = day
		last_reception_point = point

	func on_decision(
		_id: StringName, decision: StringName, red: int, green: int, blue: int
	) -> void:
		decision_count += 1
		last_decision = decision
		last_reward = Vector3i(red, green, blue)


static func run() -> Array[String]:
	var failures: Array[String] = []
	_check_funeral_delivery_events(failures)
	_check_corpse_decision_events(failures)
	return failures


static func _check_funeral_delivery_events(failures: Array[String]) -> void:
	var bus := _event_bus()
	if bus == null or not bus.has_signal("funeral_delivery_completed"):
		failures.append("EventBus should expose funeral_delivery_completed")
		return

	var recorder := Recorder.new()
	var listener := Callable(recorder, "on_delivery")
	bus.connect("funeral_delivery_completed", listener)
	var cemetery := _new_cemetery_service()
	var storage := _new_storage()
	var funeral := FuneralDeliveryService.new(cemetery, storage, 1)

	funeral.sync_time(1, 17, 59)
	funeral.sync_time(1, 18, 0)
	if recorder.delivery_count != 1:
		failures.append("A valid funeral delivery should emit exactly one event")
	if recorder.last_delivery_id == &"":
		failures.append("Funeral delivery event should expose the corpse ID")
	if recorder.last_delivery_day != 1:
		failures.append("Funeral delivery event should expose its logical day")
	var expected_point := FuneralDeliveryService.ROADSIDE_DROPOFF
	if recorder.last_reception_point != expected_point:
		failures.append("Funeral delivery event should expose its reception point")

	funeral.sync_time(1, 18, 0)
	funeral.sync_time(1, 20, 0)
	if recorder.delivery_count != 1:
		failures.append("Delivery retry must not emit a duplicate success event")

	var snapshot := funeral.snapshot()
	var restored := FuneralDeliveryService.new(cemetery, storage, 1)
	restored.apply_snapshot(snapshot)
	restored.sync_time(1, 20, 0)
	if recorder.delivery_count != 1:
		failures.append("Restore must not replay completed-delivery events")

	bus.disconnect("funeral_delivery_completed", listener)
	var silent_cemetery := _new_cemetery_service()
	var silent_storage := _new_storage()
	var silent_funeral := FuneralDeliveryService.new(silent_cemetery, silent_storage, 1)
	silent_funeral.sync_time(40, 17, 59)
	silent_funeral.sync_time(40, 18, 0)
	if silent_cemetery.pending_corpses.size() != 1:
		failures.append("Funeral delivery should work with zero listeners")


static func _check_corpse_decision_events(failures: Array[String]) -> void:
	var bus := _event_bus()
	if bus == null or not bus.has_signal("corpse_final_decision_completed"):
		failures.append("EventBus should expose corpse_final_decision_completed")
		return

	var recorder := Recorder.new()
	var listener := Callable(recorder, "on_decision")
	bus.connect("corpse_final_decision_completed", listener)
	var config := _rating_config()
	var choices := _decision_config()
	var service := _new_decision_service(config, choices)

	var cremated := _corpse(&"feedback_cremate", 3)
	service.receive_corpse(cremated)
	service.finalize_corpse(cremated.data.id, &"cremate")
	if recorder.decision_count != 1:
		failures.append("Valid cremate should emit exactly one decision event")
	if recorder.last_decision != &"cremate":
		failures.append("Cremate event should expose the terminal decision")
	var cremate_reward := choices.reward_for(&"cremate", cremated)
	if recorder.last_reward != cremate_reward:
		failures.append("Cremate event should expose the committed reward")

	service.finalize_corpse(cremated.data.id, &"cremate")
	if recorder.decision_count != 1:
		failures.append("Cremate retry must not emit duplicate success feedback")

	var researched := _corpse(&"feedback_research", 4)
	service.receive_corpse(researched)
	service.finalize_corpse(researched.data.id, &"research")
	if recorder.decision_count != 2:
		failures.append("Valid research should emit exactly one decision event")
	if recorder.last_decision != &"research":
		failures.append("Research event should expose the terminal decision")
	var research_reward := choices.reward_for(&"research", researched)
	if recorder.last_reward != research_reward:
		failures.append("Research event should expose the committed reward")

	service.finalize_corpse(researched.data.id, &"cremate")
	if recorder.decision_count != 2:
		failures.append("Second terminal decision must not emit success feedback")

	var snapshot := service.snapshot()
	CemeteryService.from_snapshot(config, snapshot, choices, TechnologyService.new())
	if recorder.decision_count != 2:
		failures.append("Restore must not replay terminal-decision events")

	bus.disconnect("corpse_final_decision_completed", listener)
	var silent_service := _new_decision_service(config, choices)
	var silent_corpse := _corpse(&"feedback_no_listener", 2)
	silent_service.receive_corpse(silent_corpse)
	var result := silent_service.finalize_corpse(silent_corpse.data.id, &"research")
	if result != CemeteryService.RESULT_OK:
		failures.append("Corpse decisions should work with zero listeners")


static func _event_bus() -> Node:
	var loop := Engine.get_main_loop()
	if loop == null:
		return null
	var tree := loop as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("EventBus")


static func _new_cemetery_service() -> CemeteryService:
	return CemeteryService.new(CemeteryModel.new(_rating_config()))


static func _new_decision_service(
	config: CemeteryRatingConfig, choices: CorpseDecisionConfig
) -> CemeteryService:
	var model := CemeteryModel.new(config)
	var technology := TechnologyService.new()
	return CemeteryService.new(model, choices, technology)


static func _rating_config() -> CemeteryRatingConfig:
	return load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig


static func _decision_config() -> CorpseDecisionConfig:
	return load("res://data/cemetery/default_final_decisions.tres") as CorpseDecisionConfig


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
