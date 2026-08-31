class_name TestCorpseFinalDecisions
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	var decisions := (
		load("res://data/cemetery/default_final_decisions.tres") as CorpseDecisionConfig
	)
	if config == null or decisions == null:
		failures.append("Cemetery final-decision data should load")
		return failures

	var technology := TechnologyService.new()
	var service := CemeteryService.new(CemeteryModel.new(config), decisions, technology)

	var cremated := _corpse(&"cremate_once", 3, 10, 2)
	service.receive_corpse(cremated)
	if service.finalize_corpse(&"cremate_once", &"cremate") != CemeteryService.RESULT_OK:
		failures.append("Cremation should finalize a pending corpse")
	if service.pending_corpses.has(&"cremate_once"):
		failures.append("Cremation should consume the pending corpse")
	if (
		service.finalize_corpse(&"cremate_once", &"cremate")
		!= CemeteryService.RESULT_ALREADY_FINALIZED
	):
		failures.append("Retrying cremation should be idempotently rejected")
	if technology.get_points(TechnologyService.PointType.RED) != decisions.cremate_red_points:
		failures.append("Cremation reward should be granted exactly once")

	var researched := _corpse(&"research_once", 4, 20, 3)
	var expected_research_reward := decisions.reward_for(&"research", researched)
	service.receive_corpse(researched)
	if service.finalize_corpse(&"research_once", &"research") != CemeteryService.RESULT_OK:
		failures.append("Research should finalize a pending corpse")
	if (
		technology.get_points(TechnologyService.PointType.BLUE)
		!= expected_research_reward.z
	):
		failures.append("Research should grant its data-driven differentiated reward")
	var blue_before_retry := technology.get_points(TechnologyService.PointType.BLUE)
	if (
		service.finalize_corpse(&"research_once", &"cremate")
		!= CemeteryService.RESULT_ALREADY_FINALIZED
	):
		failures.append("A corpse should reject a second incompatible final decision")
	if technology.get_points(TechnologyService.PointType.BLUE) != blue_before_retry:
		failures.append("Rejected final-decision retry must not duplicate research reward")

	var prepared := _corpse(&"prepare_then_bury", 2, 0, 2)
	service.receive_corpse(prepared)
	if service.prepare_corpse(&"prepare_then_bury", 1) != CemeteryService.RESULT_OK:
		failures.append("Existing preparation should remain available")
	if service.bury_corpse(&"prepare_then_bury") == null:
		failures.append("Existing burial should remain available")

	var snapshot := service.snapshot()
	var restored_technology := TechnologyService.new()
	var restored := CemeteryService.from_snapshot(
		config,
		snapshot,
		decisions,
		restored_technology,
	)
	if restored.final_decision_for(&"cremate_once") != &"cremate":
		failures.append("Save/load should preserve cremation final decision")
	if restored.final_decision_for(&"research_once") != &"research":
		failures.append("Save/load should preserve research final decision")
	var red_before := restored_technology.get_points(TechnologyService.PointType.RED)
	if (
		restored.finalize_corpse(&"cremate_once", &"cremate")
		!= CemeteryService.RESULT_ALREADY_FINALIZED
	):
		failures.append("Restored final decisions should remain idempotent")
	if restored_technology.get_points(TechnologyService.PointType.RED) != red_before:
		failures.append("Save/load retry must not duplicate rewards")

	return failures


static func _corpse(id: StringName, quality: int, decay: int, burial_value: int) -> CorpseState:
	var data := CorpseData.new()
	data.id = id
	data.quality = quality
	data.decay_percent = decay
	data.burial_value = burial_value
	return CorpseState.new(data)
