class_name EconomyTransaction
extends RefCounted

var result: StringName = &"invalid_state"
var wallet_before: WalletState
var merchant_before: MerchantState
var wallet_after: WalletState
var merchant_after: MerchantState


func _init(
	initial_result: StringName = &"invalid_state",
	initial_wallet_before: WalletState = null,
	initial_merchant_before: MerchantState = null,
	initial_wallet_after: WalletState = null,
	initial_merchant_after: MerchantState = null
) -> void:
	result = initial_result
	wallet_before = initial_wallet_before
	merchant_before = initial_merchant_before
	wallet_after = initial_wallet_after
	merchant_after = initial_merchant_after


func is_success() -> bool:
	return (
		result == &"ok"
		and wallet_before != null
		and merchant_before != null
		and wallet_after != null
		and merchant_after != null
	)
