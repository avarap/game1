class_name NPCData
extends Resource

@export var id: StringName
@export var display_name: String
@export var role: String
@export_range(10.0, 400.0, 1.0) var move_speed: float = 70.0


func is_valid() -> bool:
	return not id.is_empty() and not display_name.is_empty() and move_speed > 0.0
