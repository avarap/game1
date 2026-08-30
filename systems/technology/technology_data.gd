class_name TechnologyData
extends Resource

enum Category {
	CONSTRUCTION,
	AGRICULTURE,
	METALLURGY,
	THEOLOGY,
	NATURE,
	ALCHEMY,
	RESEARCH,
}

@export var id: StringName
@export var category: Category = Category.CONSTRUCTION
@export_range(0, 9999, 1) var red_cost: int = 0
@export_range(0, 9999, 1) var green_cost: int = 0
@export_range(0, 9999, 1) var blue_cost: int = 0
@export var unlock_ids: Array[StringName] = []


func is_valid() -> bool:
	if id.is_empty():
		return false
	if red_cost < 0 or green_cost < 0 or blue_cost < 0:
		return false
	for unlock_id in unlock_ids:
		if unlock_id.is_empty():
			return false
	return true
