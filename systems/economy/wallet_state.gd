class_name WalletState
extends RefCounted

var balance_copper: int = 0


func _init(initial_balance_copper: int = 0) -> void:
	if initial_balance_copper >= 0:
		balance_copper = initial_balance_copper


func can_afford(amount_copper: int) -> bool:
	return amount_copper >= 0 and balance_copper >= amount_copper


func credit(amount_copper: int) -> bool:
	if amount_copper <= 0:
		return false
	balance_copper += amount_copper
	return true


func debit(amount_copper: int) -> bool:
	if amount_copper <= 0 or not can_afford(amount_copper):
		return false
	balance_copper -= amount_copper
	return true


func clone_state() -> WalletState:
	return WalletState.new(balance_copper)


func matches(other: WalletState) -> bool:
	return other != null and balance_copper == other.balance_copper


func apply_from(source: WalletState) -> bool:
	if source == null or source.balance_copper < 0:
		return false
	balance_copper = source.balance_copper
	return true
