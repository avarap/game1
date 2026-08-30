class_name InventoryStack
extends RefCounted

var item: ItemData
var amount: int


func _init(p_item: ItemData, p_amount: int = 0) -> void:
	item = p_item
	amount = max(p_amount, 0)


func remaining_capacity() -> int:
	if item == null:
		return 0
	return max(item.max_stack - amount, 0)


func is_empty() -> bool:
	return amount <= 0
