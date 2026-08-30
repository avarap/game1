class_name MerchantState
extends RefCounted

var merchant_id: StringName = &""
var _stock: Dictionary = {}


func _init(initial_merchant_id: StringName = &"") -> void:
	merchant_id = initial_merchant_id


func is_valid() -> bool:
	return merchant_id != &""


func get_stock(item_id: StringName) -> int:
	if item_id == &"":
		return 0
	return int(_stock.get(item_id, 0))


func set_stock(item_id: StringName, amount: int) -> bool:
	if item_id == &"" or amount < 0:
		return false
	if amount == 0:
		_stock.erase(item_id)
	else:
		_stock[item_id] = amount
	return true


func add_stock(item_id: StringName, amount: int) -> bool:
	if item_id == &"" or amount <= 0:
		return false
	_stock[item_id] = get_stock(item_id) + amount
	return true


func remove_stock(item_id: StringName, amount: int) -> bool:
	if item_id == &"" or amount <= 0 or get_stock(item_id) < amount:
		return false
	return set_stock(item_id, get_stock(item_id) - amount)


func clone_state() -> MerchantState:
	var copy := MerchantState.new(merchant_id)
	copy._stock = _stock.duplicate(true)
	return copy


func matches(other: MerchantState) -> bool:
	return other != null and merchant_id == other.merchant_id and _stock == other._stock


func apply_from(source: MerchantState) -> bool:
	if source == null or not source.is_valid() or merchant_id != source.merchant_id:
		return false
	_stock = source._stock.duplicate(true)
	return true
