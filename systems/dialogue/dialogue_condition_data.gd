class_name DialogueConditionData
extends Resource

enum ConditionType { FLAG, RELATIONSHIP_MIN, HAS_ITEM, TIME_OF_DAY, QUEST_FLAG }

@export var condition_type: ConditionType = ConditionType.FLAG
@export var flag: StringName
@export var expected_value: bool = true
@export var relationship_id: StringName
@export_range(0, 100, 1) var minimum_relationship: int = 0
@export var item_id: StringName
@export_range(1, 999, 1) var minimum_item_amount: int = 1
@export_range(0, 23, 1) var start_hour: int = 0
@export_range(0, 59, 1) var start_minute: int = 0
@export_range(0, 23, 1) var end_hour: int = 0
@export_range(0, 59, 1) var end_minute: int = 0
@export var quest_flag: StringName


func matches(context: Dictionary) -> bool:
	match condition_type:
		ConditionType.RELATIONSHIP_MIN:
			return _matches_relationship(context)
		ConditionType.HAS_ITEM:
			return _matches_item(context)
		ConditionType.TIME_OF_DAY:
			return _matches_time(context)
		ConditionType.QUEST_FLAG:
			return _matches_quest_flag(context)
		_:
			return _matches_flag(context)


func _matches_relationship(context: Dictionary) -> bool:
	if relationship_id.is_empty():
		return false
	var relationships: Dictionary = context.get(&"relationships", {})
	return int(relationships.get(relationship_id, 0)) >= minimum_relationship


func _matches_item(context: Dictionary) -> bool:
	if item_id.is_empty():
		return false
	var inventory: Dictionary = context.get(&"inventory", {})
	return int(inventory.get(item_id, 0)) >= minimum_item_amount


func _matches_time(context: Dictionary) -> bool:
	if not context.has(&"hour") or not context.has(&"minute"):
		return false
	var current_total := int(context.get(&"hour", 0)) * 60 + int(context.get(&"minute", 0))
	var start_total := start_hour * 60 + start_minute
	var end_total := end_hour * 60 + end_minute
	if start_total == end_total:
		return true
	if start_total < end_total:
		return current_total >= start_total and current_total < end_total
	return current_total >= start_total or current_total < end_total


func _matches_quest_flag(context: Dictionary) -> bool:
	if quest_flag.is_empty():
		return false
	var quest_flags: Dictionary = context.get(&"quest_flags", {})
	return bool(quest_flags.get(quest_flag, false)) == expected_value


func _matches_flag(context: Dictionary) -> bool:
	if flag.is_empty():
		return true
	var flags: Dictionary = context.get(&"flags", {})
	if flags.has(flag):
		return bool(flags.get(flag, false)) == expected_value
	return bool(context.get(flag, false)) == expected_value
