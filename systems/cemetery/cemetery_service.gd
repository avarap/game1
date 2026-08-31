class_name CemeteryService
extends RefCounted

const RESULT_OK := &"ok"
const RESULT_INVALID_CORPSE := &"invalid_corpse"
const RESULT_DUPLICATE_CORPSE := &"duplicate_corpse"
const RESULT_NOT_FOUND := &"not_found"
const RESULT_INVALID_GRAVE := &"invalid_grave"
const RESULT_INVALID_DECISION := &"invalid_decision"
const RESULT_ALREADY_FINALIZED := &"already_finalized"

var model: CemeteryModel
var pending_corpses: Dictionary = {}
var decision_config: CorpseDecisionConfig
var technology_service: TechnologyService
var final_decisions: Dictionary = {}


func _init(
	cemetery_model: CemeteryModel,
	decisions: CorpseDecisionConfig = null,
	technology: TechnologyService = null,
) -> void:
	model = cemetery_model
	decision_config = decisions
	technology_service = technology


func receive_corpse(corpse: CorpseState) -> StringName:
	if corpse == null or corpse.data == null or corpse.data.id == &"":
		return RESULT_INVALID_CORPSE
	if (
		pending_corpses.has(corpse.data.id)
		or final_decisions.has(corpse.data.id)
		or _find_grave_by_corpse_id(corpse.data.id) != null
	):
		return RESULT_DUPLICATE_CORPSE
	pending_corpses[corpse.data.id] = corpse
	return RESULT_OK


func prepare_corpse(corpse_id: StringName, amount: int = 1) -> StringName:
	var corpse := pending_corpses.get(corpse_id) as CorpseState
	if corpse == null:
		return RESULT_NOT_FOUND
	corpse.prepare(amount)
	return RESULT_OK


func bury_corpse(corpse_id: StringName) -> GraveRecord:
	var corpse := pending_corpses.get(corpse_id) as CorpseState
	if corpse == null or model == null:
		return null
	var grave := GraveRecord.new(corpse)
	model.add_grave(grave)
	pending_corpses.erase(corpse_id)
	return grave


func finalize_corpse(corpse_id: StringName, decision: StringName) -> StringName:
	if final_decisions.has(corpse_id):
		return RESULT_ALREADY_FINALIZED
	if decision != &"cremate" and decision != &"research":
		return RESULT_INVALID_DECISION
	var corpse := pending_corpses.get(corpse_id) as CorpseState
	if corpse == null:
		return RESULT_NOT_FOUND
	if decision_config == null or technology_service == null:
		return RESULT_INVALID_DECISION

	var reward := decision_config.reward_for(decision, corpse)
	if not technology_service.add_points(reward.x, reward.y, reward.z):
		return RESULT_INVALID_DECISION
	final_decisions[corpse_id] = decision
	pending_corpses.erase(corpse_id)
	_emit_final_decision_completed(corpse_id, decision, reward)
	return RESULT_OK


func final_decision_for(corpse_id: StringName) -> StringName:
	return StringName(str(final_decisions.get(corpse_id, "")))


func install_headstone(grave_index: int) -> StringName:
	var grave := _grave_at(grave_index)
	if grave == null:
		return RESULT_INVALID_GRAVE
	grave.has_headstone = true
	return RESULT_OK


func install_fence(grave_index: int) -> StringName:
	var grave := _grave_at(grave_index)
	if grave == null:
		return RESULT_INVALID_GRAVE
	grave.has_fence = true
	return RESULT_OK


func add_decoration(grave_index: int, amount: int = 1) -> StringName:
	var grave := _grave_at(grave_index)
	if grave == null:
		return RESULT_INVALID_GRAVE
	grave.decoration_count += maxi(amount, 0)
	return RESULT_OK


func total_rating() -> int:
	return model.total_rating() if model != null else 0


func pending_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for key in pending_corpses.keys():
		ids.append(StringName(str(key)))
	ids.sort()
	return ids


func first_pending_id() -> StringName:
	var ids := pending_ids()
	return ids[0] if not ids.is_empty() else &""


func snapshot() -> Dictionary:
	var pending: Array[Dictionary] = []
	for corpse_value in pending_corpses.values():
		var corpse := corpse_value as CorpseState
		if corpse != null:
			pending.append(corpse.snapshot())
	var finalized: Dictionary = {}
	for corpse_id in final_decisions.keys():
		finalized[str(corpse_id)] = str(final_decisions[corpse_id])
	return {
		"pending_corpses": pending,
		"cemetery": model.snapshot() if model != null else {},
		"final_decisions": finalized,
	}


static func from_snapshot(
	config: CemeteryRatingConfig,
	snapshot_data: Dictionary,
	decisions: CorpseDecisionConfig = null,
	technology: TechnologyService = null,
) -> CemeteryService:
	var cemetery_data: Dictionary = snapshot_data.get("cemetery", {})
	var restored_model := CemeteryModel.from_snapshot(config, cemetery_data)
	var restored := CemeteryService.new(restored_model, decisions, technology)
	var pending_entries: Array = snapshot_data.get("pending_corpses", [])
	for corpse_value in pending_entries:
		if typeof(corpse_value) != TYPE_DICTIONARY:
			continue
		var corpse := CorpseState.from_snapshot(corpse_value as Dictionary)
		if corpse != null and corpse.data != null and corpse.data.id != &"":
			restored.pending_corpses[corpse.data.id] = corpse
	var finalized_value: Variant = snapshot_data.get("final_decisions", {})
	if typeof(finalized_value) == TYPE_DICTIONARY:
		for corpse_id in (finalized_value as Dictionary).keys():
			var decision := StringName(str((finalized_value as Dictionary)[corpse_id]))
			if decision == &"cremate" or decision == &"research":
				restored.final_decisions[StringName(str(corpse_id))] = decision
	return restored


func _emit_final_decision_completed(
	corpse_id: StringName, decision: StringName, reward: Vector3i
) -> void:
	var bus := _event_bus()
	if bus == null:
		return
	bus.emit_signal(
		"corpse_final_decision_completed", corpse_id, decision, reward.x, reward.y, reward.z
	)


func _event_bus() -> Node:
	var loop := Engine.get_main_loop()
	if loop == null:
		return null
	var tree := loop as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("EventBus")


func _grave_at(index: int) -> GraveRecord:
	if model == null or index < 0 or index >= model.graves.size():
		return null
	return model.graves[index]


func _find_grave_by_corpse_id(corpse_id: StringName) -> GraveRecord:
	if model == null:
		return null
	for grave in model.graves:
		if grave != null and grave.corpse != null and grave.corpse.data != null:
			if grave.corpse.data.id == corpse_id:
				return grave
	return null
