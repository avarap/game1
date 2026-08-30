class_name TestCemeteryFlow
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	if config == null:
		failures.append("Cemetery rating config should load for flow test")
		return failures

	var corpse_data := CorpseData.new()
	corpse_data.id = &"flow_corpse"
	corpse_data.quality = 2
	corpse_data.decay = 0.1
	corpse_data.preparation_level = 0
	corpse_data.burial_value = 2

	var corpse := CorpseState.new(corpse_data, 0.02)
	var model := CemeteryModel.new(config)
	var service := CemeteryService.new(model)

	var result := service.receive_corpse(corpse)
	if result != CemeteryService.RESULT_OK:
		failures.append("Cemetery should accept a valid corpse")
	if service.receive_corpse(corpse) != CemeteryService.RESULT_DUPLICATE_CORPSE:
		failures.append("Cemetery should reject duplicate corpse ids")

	result = service.prepare_corpse(&"flow_corpse", 2)
	if result != CemeteryService.RESULT_OK or corpse.current_preparation_level != 2:
		failures.append("Preparing a pending corpse should update instance preparation state")
	if corpse_data.preparation_level != 0:
		failures.append("Preparation should not mutate shared CorpseData")

	corpse.advance_decay(2.0)
	if absf(corpse.current_decay - 0.14) > 0.001:
		failures.append("Pending corpse decay should remain deterministic during flow")

	var grave := service.bury_corpse(&"flow_corpse")
	if grave == null or model.graves.size() != 1:
		failures.append("Burying should create exactly one grave record")
		return failures
	if service.pending_corpses.has(&"flow_corpse"):
		failures.append("Buried corpse should leave pending queue")
	if service.total_rating() != 2:
		failures.append("Fresh grave should contribute corpse burial value")

	result = service.install_headstone(0)
	if result != CemeteryService.RESULT_OK or service.total_rating() != 5:
		failures.append("Headstone should add configured rating points")

	result = service.install_fence(0)
	if result != CemeteryService.RESULT_OK or service.total_rating() != 7:
		failures.append("Fence should add configured rating points")

	result = service.add_decoration(0, 2)
	if result != CemeteryService.RESULT_OK or service.total_rating() != 9:
		failures.append("Decorations should add configured rating points")

	if service.install_headstone(5) != CemeteryService.RESULT_INVALID_GRAVE:
		failures.append("Upgrades should reject invalid grave indexes")

	var snapshot := service.snapshot()
	var cemetery_data: Dictionary = snapshot.get("cemetery", {})
	var graves: Array = cemetery_data.get("graves", [])
	if int(cemetery_data.get("rating", -1)) != 9 or graves.size() != 1:
		failures.append("Cemetery flow snapshot should preserve grave count and rating")
	var grave_snapshot: Dictionary = graves[0] if not graves.is_empty() else {}
	var corpse_snapshot: Dictionary = grave_snapshot.get("corpse", {})
	if int(corpse_snapshot.get("preparation_level", -1)) != 2:
		failures.append("Snapshot should persist prepared corpse instance state")

	return failures
