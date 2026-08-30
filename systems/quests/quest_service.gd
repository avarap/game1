class_name QuestService
extends RefCounted

const STATUS_UNAVAILABLE: StringName = &"unavailable"
const STATUS_ACTIVE: StringName = &"active"
const STATUS_COMPLETED: StringName = &"completed"

var _definitions: Dictionary = {}
var _states: Dictionary = {}
var _flags: Dictionary = {}


func register(data: QuestData) -> bool:
	if data == null or not data.is_valid():
		return false
	var key := str(data.id)
	_definitions[key] = data
	if not _states.has(key):
		_states[key] = _default_state(data)
	return true


func start_quest(quest_id: StringName) -> bool:
	var key := str(quest_id)
	if not _states.has(key) or not _dependencies_completed(key):
		return false
	var state: Dictionary = _states[key]
	if StringName(str(state.get("status", STATUS_UNAVAILABLE))) != STATUS_UNAVAILABLE:
		return false
	state["status"] = STATUS_ACTIVE
	_states[key] = state
	return true


func update_item_count(item_id: StringName, amount: int) -> void:
	for key in _definitions:
		var state: Dictionary = _states.get(key, {})
		if StringName(str(state.get("status", STATUS_UNAVAILABLE))) != STATUS_ACTIVE:
			continue
		var data: QuestData = _definitions[key]
		var progress: Dictionary = state.get("progress", {})
		for objective in data.objectives:
			if objective.objective_type != QuestObjectiveData.ObjectiveType.ITEM_COUNT:
				continue
			if objective.item_id != item_id:
				continue
			progress[str(objective.id)] = clampi(amount, 0, objective.required_amount)
		state["progress"] = progress
		_states[key] = state


func is_ready(quest_id: StringName) -> bool:
	var key := str(quest_id)
	if not _definitions.has(key) or not _states.has(key):
		return false
	var state: Dictionary = _states[key]
	if StringName(str(state.get("status", STATUS_UNAVAILABLE))) != STATUS_ACTIVE:
		return false
	var progress: Dictionary = state.get("progress", {})
	var data: QuestData = _definitions[key]
	for objective in data.objectives:
		if int(progress.get(str(objective.id), 0)) < objective.required_amount:
			return false
	return true


func complete_quest(quest_id: StringName) -> bool:
	if not is_ready(quest_id):
		return false
	var key := str(quest_id)
	var state: Dictionary = _states[key]
	state["status"] = STATUS_COMPLETED
	_states[key] = state
	return true


func claim_rewards(quest_id: StringName) -> Array[QuestRewardData]:
	var result: Array[QuestRewardData] = []
	var key := str(quest_id)
	if not _definitions.has(key) or not _states.has(key):
		return result
	var state: Dictionary = _states[key]
	if StringName(str(state.get("status", STATUS_UNAVAILABLE))) != STATUS_COMPLETED:
		return result
	if bool(state.get("reward_claimed", false)):
		return result
	var data: QuestData = _definitions[key]
	for reward in data.rewards:
		if reward == null:
			continue
		result.append(reward)
		if reward.reward_type == QuestRewardData.RewardType.QUEST_FLAG:
			_flags[reward.flag_id] = true
	state["reward_claimed"] = true
	_states[key] = state
	return result


func get_status(quest_id: StringName) -> StringName:
	var state: Dictionary = _states.get(str(quest_id), {})
	return StringName(str(state.get("status", STATUS_UNAVAILABLE)))


func get_progress(quest_id: StringName, objective_id: StringName) -> int:
	var state: Dictionary = _states.get(str(quest_id), {})
	var progress: Dictionary = state.get("progress", {})
	return int(progress.get(str(objective_id), 0))


func get_active_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for key in _definitions:
		if get_status(StringName(key)) == STATUS_ACTIVE:
			result.append(_definitions[key] as QuestData)
	return result


func build_dialogue_context() -> Dictionary:
	var quest_flags: Dictionary = _flags.duplicate(true)
	for key in _states:
		var quest_id := StringName(key)
		var status := get_status(quest_id)
		quest_flags[StringName("quest_%s_started" % key)] = status != STATUS_UNAVAILABLE
		quest_flags[StringName("quest_%s_active" % key)] = status == STATUS_ACTIVE
		quest_flags[StringName("quest_%s_ready" % key)] = is_ready(quest_id)
		quest_flags[StringName("quest_%s_completed" % key)] = status == STATUS_COMPLETED
	return {&"quest_flags": quest_flags}


func snapshot() -> Dictionary:
	return {"states": _states.duplicate(true), "flags": _flags.duplicate(true)}


func apply_snapshot(data: Dictionary) -> void:
	for key in _definitions:
		_states[key] = _default_state(_definitions[key] as QuestData)
	var saved_states: Dictionary = data.get("states", {})
	for saved_key in saved_states:
		var key := str(saved_key)
		if not _states.has(key):
			continue
		var saved_state: Variant = saved_states[saved_key]
		if typeof(saved_state) == TYPE_DICTIONARY:
			_states[key] = (saved_state as Dictionary).duplicate(true)
	_flags.clear()
	var saved_flags: Dictionary = data.get("flags", {})
	for flag_key in saved_flags:
		_flags[StringName(str(flag_key))] = bool(saved_flags[flag_key])


func _default_state(data: QuestData) -> Dictionary:
	var progress: Dictionary = {}
	for objective in data.objectives:
		progress[str(objective.id)] = 0
	return {"status": STATUS_UNAVAILABLE, "progress": progress, "reward_claimed": false}


func _dependencies_completed(key: String) -> bool:
	var data: QuestData = _definitions.get(key)
	if data == null:
		return false
	for dependency in data.dependencies:
		if get_status(dependency) != STATUS_COMPLETED:
			return false
	return true
