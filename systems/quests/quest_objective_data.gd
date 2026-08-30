class_name QuestObjectiveData
extends Resource

enum ObjectiveType { ITEM_COUNT }

@export var id: StringName
@export var objective_type: ObjectiveType = ObjectiveType.ITEM_COUNT
@export var item_id: StringName
@export_range(1, 999, 1) var required_amount: int = 1


func is_valid() -> bool:
	if id.is_empty():
		return false
	match objective_type:
		ObjectiveType.ITEM_COUNT:
			return not item_id.is_empty() and required_amount > 0
	return false
