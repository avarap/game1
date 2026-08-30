class_name EconomyService
extends RefCounted

const RESULT_OK: StringName = &"ok"
const RESULT_INVALID_STATE: StringName = &"invalid_state"
const RESULT_INVALID_OFFER: StringName = &"invalid_offer"
const RESULT_INVALID_AMOUNT: StringName = &"invalid_amount"
const RESULT_INSUFFICIENT_FUNDS: StringName = &"insufficient_funds"
const RESULT_OUT_OF_STOCK: StringName = &"out_of_stock"


static func get_buy_total(offer: MerchantOfferData, quantity: int) -> int:
	if offer == null or not offer.is_valid() or quantity <= 0:
		return MoneyMath.INVALID_AMOUNT
	return offer.buy_price_copper * quantity


static func get_sell_total(offer: MerchantOfferData, quantity: int) -> int:
	if offer == null or not offer.is_valid() or quantity <= 0:
		return MoneyMath.INVALID_AMOUNT
	return offer.sell_price_copper * quantity


static func simulate_buy(
	wallet: WalletState, merchant: MerchantState, offer: MerchantOfferData, quantity: int
) -> EconomyTransaction:
	var validation := _validate_common(wallet, merchant, offer, quantity)
	if validation != RESULT_OK:
		return _failure(validation)
	var total := get_buy_total(offer, quantity)
	if total == MoneyMath.INVALID_AMOUNT:
		return _failure(RESULT_INVALID_AMOUNT)
	if not wallet.can_afford(total):
		return _failure(RESULT_INSUFFICIENT_FUNDS)
	if merchant.get_stock(offer.item_id) < quantity:
		return _failure(RESULT_OUT_OF_STOCK)

	var wallet_before := wallet.clone_state()
	var merchant_before := merchant.clone_state()
	var wallet_after := wallet_before.clone_state()
	var merchant_after := merchant_before.clone_state()
	if not wallet_after.debit(total):
		return _failure(RESULT_INVALID_STATE)
	if not merchant_after.remove_stock(offer.item_id, quantity):
		return _failure(RESULT_INVALID_STATE)
	return EconomyTransaction.new(
		RESULT_OK, wallet_before, merchant_before, wallet_after, merchant_after
	)


static func simulate_sell(
	wallet: WalletState, merchant: MerchantState, offer: MerchantOfferData, quantity: int
) -> EconomyTransaction:
	var validation := _validate_common(wallet, merchant, offer, quantity)
	if validation != RESULT_OK:
		return _failure(validation)
	var total := get_sell_total(offer, quantity)
	if total == MoneyMath.INVALID_AMOUNT:
		return _failure(RESULT_INVALID_AMOUNT)

	var wallet_before := wallet.clone_state()
	var merchant_before := merchant.clone_state()
	var wallet_after := wallet_before.clone_state()
	var merchant_after := merchant_before.clone_state()
	if not wallet_after.credit(total):
		return _failure(RESULT_INVALID_STATE)
	if not merchant_after.add_stock(offer.item_id, quantity):
		return _failure(RESULT_INVALID_STATE)
	return EconomyTransaction.new(
		RESULT_OK, wallet_before, merchant_before, wallet_after, merchant_after
	)


static func apply_transaction(
	transaction: EconomyTransaction, wallet: WalletState, merchant: MerchantState
) -> bool:
	if transaction == null or not transaction.is_success():
		return false
	if wallet == null or merchant == null:
		return false
	if not transaction.wallet_before.matches(wallet):
		return false
	if not transaction.merchant_before.matches(merchant):
		return false

	var wallet_candidate := wallet.clone_state()
	var merchant_candidate := merchant.clone_state()
	if not wallet_candidate.apply_from(transaction.wallet_after):
		return false
	if not merchant_candidate.apply_from(transaction.merchant_after):
		return false
	if not wallet.apply_from(wallet_candidate):
		return false
	return merchant.apply_from(merchant_candidate)


static func _validate_common(
	wallet: WalletState, merchant: MerchantState, offer: MerchantOfferData, quantity: int
) -> StringName:
	if wallet == null or merchant == null or not merchant.is_valid():
		return RESULT_INVALID_STATE
	if offer == null or not offer.is_valid():
		return RESULT_INVALID_OFFER
	if quantity <= 0:
		return RESULT_INVALID_AMOUNT
	return RESULT_OK


static func _failure(result: StringName) -> EconomyTransaction:
	return EconomyTransaction.new(result)
