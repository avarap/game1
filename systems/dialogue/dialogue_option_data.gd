class_name DialogueOptionData
extends Resource

@export var id: StringName
@export var text_key: StringName
@export var next_node_id: StringName
@export var conditions: Array[DialogueConditionData] = []


func is_available(context: Dictionary) -> bool:
	for condition in conditions:
		if condition != null and not condition.matches(context):
			return false
	return true


func is_valid() -> bool:
	return not id.is_empty() and not text_key.is_empty()
