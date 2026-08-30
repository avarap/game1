class_name DialogueOptionData
extends Resource

enum QuestAction { NONE, START, TURN_IN }

@export var id: StringName
@export var text_key: StringName
@export var next_node_id: StringName
@export var conditions: Array[DialogueConditionData] = []
@export var quest_action: QuestAction = QuestAction.NONE
@export var quest_id: StringName


func is_available(context: Dictionary) -> bool:
	for condition in conditions:
		if condition != null and not condition.matches(context):
			return false
	return true


func is_valid() -> bool:
	if id.is_empty() or text_key.is_empty():
		return false
	if quest_action != QuestAction.NONE and quest_id.is_empty():
		return false
	return true
