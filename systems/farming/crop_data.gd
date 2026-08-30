class_name CropData
extends Resource

@export var id: StringName
@export var seed_item_id: StringName
@export var harvest_item_id: StringName
@export_range(1, 10080, 1) var growth_minutes: int = 1440
@export_range(1, 99, 1) var harvest_amount: int = 1


func is_valid() -> bool:
	return (
		not id.is_empty()
		and not seed_item_id.is_empty()
		and not harvest_item_id.is_empty()
		and growth_minutes > 0
		and harvest_amount > 0
	)
