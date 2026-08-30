class_name DialogueNodeData
extends Resource

@export var id: StringName
@export var speaker_id: StringName
@export var speaker_name_key: StringName
@export var text_key: StringName
@export var next_node_id: StringName
@export var options: Array[DialogueOptionData] = []


func get_available_options(context: Dictionary) -> Array[DialogueOptionData]:
	var result: Array[DialogueOptionData] = []
	for option in options:
		if option != null and option.is_available(context):
			result.append(option)
	return result


func is_valid() -> bool:
	if id.is_empty() or text_key.is_empty():
		return false
	for option in options:
		if option == null or not option.is_valid():
			return false
	return true
