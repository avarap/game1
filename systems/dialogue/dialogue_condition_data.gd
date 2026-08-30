class_name DialogueConditionData
extends Resource

@export var flag: StringName
@export var expected_value: bool = true


func matches(context: Dictionary) -> bool:
	if flag.is_empty():
		return true
	return bool(context.get(flag, false)) == expected_value
