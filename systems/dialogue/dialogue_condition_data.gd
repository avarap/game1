class_name DialogueConditionData
extends Resource

enum ConditionType { FLAG, RELATIONSHIP_MIN }

@export var condition_type: ConditionType = ConditionType.FLAG
@export var flag: StringName
@export var expected_value: bool = true
@export var relationship_id: StringName
@export_range(0, 100, 1) var minimum_relationship: int = 0


func matches(context: Dictionary) -> bool:
	match condition_type:
		ConditionType.RELATIONSHIP_MIN:
			if relationship_id.is_empty():
				return false
			var relationships: Dictionary = context.get(&"relationships", {})
			return int(relationships.get(relationship_id, 0)) >= minimum_relationship
		_:
			if flag.is_empty():
				return true
			return bool(context.get(flag, false)) == expected_value
