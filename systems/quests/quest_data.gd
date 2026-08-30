class_name QuestData
extends Resource

@export var id: StringName
@export var giver_npc_id: StringName
@export var title_key: StringName
@export var description_key: StringName
@export var objectives: Array[QuestObjectiveData] = []
@export var rewards: Array[QuestRewardData] = []
@export var dependencies: Array[StringName] = []


func is_valid() -> bool:
	if (
		id.is_empty()
		or giver_npc_id.is_empty()
		or title_key.is_empty()
		or description_key.is_empty()
	):
		return false
	if objectives.is_empty():
		return false
	for objective in objectives:
		if objective == null or not objective.is_valid():
			return false
	for reward in rewards:
		if reward == null or not reward.is_valid():
			return false
	return true
