class_name RelationshipData
extends Resource

@export var id: StringName
@export_range(0, 100, 1) var default_value: int = 0


func is_valid() -> bool:
	return not id.is_empty() and default_value >= 0 and default_value <= 100
