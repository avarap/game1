class_name TestEconomyFoundation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_money_math(failures)
	_test_wallet_invariants(failures)
	_test_offer_and_stock_validation(failures)
	_test_buy_simulation_and_apply(failures)
	_test_buy_failures_are_atomic(failures)
	_test_sell_simulation_and_apply(failures)
	_test_stale_transaction_is_rejected(failures)
	return failures


static func _test_money_math(failures: Array[String]) -> void:
	if MoneyMath.to_copper(1, 2, 3) != 10203:
		failures.append("MoneyMath should convert gold, silver and copper deterministically")
	var parts := MoneyMath.breakdown(10203)
	if parts.get(&"gold", -1) != 1 or parts.get(&"silver", -1) != 2:
		failures.append("MoneyMath should split gold and silver deterministically")
	if parts.get(&"copper", -1) != 3:
		failures.append("MoneyMath should preserve the copper remainder")
	if MoneyMath.to_copper(-1, 0, 0) != MoneyMath.INVALID_AMOUNT:
		failures.append("MoneyMath should reject negative denominations")
	if not MoneyMath.breakdown(-1).is_empty():
		failures.append("MoneyMath should reject negative balances")


static func _test_wallet_invariants(failures: Array[String]) -> void:
	var wallet := WalletState.new(250)
	if not wallet.can_afford(250) or wallet.can_afford(251):
		failures.append("Wallet affordability should use integer copper balances")
	if not wallet.credit(50) or wallet.balance_copper != 300:
		failures.append("Wallet credit should add positive copper amounts")
	if not wallet.debit(100) or wallet.balance_copper != 200:
		failures.append("Wallet debit should subtract available copper amounts")
	var before := wallet.balance_copper
	if wallet.debit(201) or wallet.balance_copper != before:
		failures.append("Wallet debit without funds must not mutate balance")
	if wallet.credit(0) or wallet.debit(-1) or wallet.balance_copper != before:
		failures.append("Invalid wallet operations must not mutate balance")


static func _test_offer_and_stock_validation(failures: Array[String]) -> void:
	var offer := _make_offer(120, 60)
	if not offer.is_valid():
		failures.append("Merchant offer with stable IDs and integer prices should be valid")
	var invalid := _make_offer(-1, 60)
	if invalid.is_valid():
		failures.append("Merchant offer should reject negative prices")
	invalid = _make_offer(120, 60)
	invalid.offer_id = &""
	if invalid.is_valid():
		failures.append("Merchant offer should require a stable offer ID")

	var merchant := MerchantState.new(&"aldren_shop")
	if not merchant.set_stock(&"wood", 2):
		failures.append("Merchant stock should accept non-negative quantities")
	if not merchant.remove_stock(&"wood", 1) or merchant.get_stock(&"wood") != 1:
		failures.append("Merchant stock should decrement available items")
	if merchant.remove_stock(&"wood", 2) or merchant.get_stock(&"wood") != 1:
		failures.append("Merchant stock must not go negative")
	if not merchant.add_stock(&"wood", 3) or merchant.get_stock(&"wood") != 4:
		failures.append("Merchant stock should increment valid quantities")
	if merchant.add_stock(&"wood", 0) or merchant.get_stock(&"wood") != 4:
		failures.append("Invalid stock operations must not mutate merchant state")


static func _test_buy_simulation_and_apply(failures: Array[String]) -> void:
	var wallet := WalletState.new(500)
	var merchant := MerchantState.new(&"aldren_shop")
	merchant.set_stock(&"wood", 4)
	var offer := _make_offer(120, 60)
	var transaction := EconomyService.simulate_buy(wallet, merchant, offer, 2)
	if transaction.result != EconomyService.RESULT_OK:
		failures.append("Valid purchase should simulate successfully")
		return
	if wallet.balance_copper != 500 or merchant.get_stock(&"wood") != 4:
		failures.append("Purchase simulation must not mutate live state")
	if transaction.wallet_after.balance_copper != 260:
		failures.append("Purchase simulation should debit the exact integer price")
	if transaction.merchant_after.get_stock(&"wood") != 2:
		failures.append("Purchase simulation should reserve merchant stock")
	if not EconomyService.apply_transaction(transaction, wallet, merchant):
		failures.append("Valid simulated purchase should apply")
	if wallet.balance_copper != 260 or merchant.get_stock(&"wood") != 2:
		failures.append("Applied purchase should update balance and stock together")
	if EconomyService.apply_transaction(transaction, wallet, merchant):
		failures.append("Applied transaction should not be reusable against changed state")


static func _test_buy_failures_are_atomic(failures: Array[String]) -> void:
	var offer := _make_offer(120, 60)
	var poor_wallet := WalletState.new(100)
	var stocked := MerchantState.new(&"aldren_shop")
	stocked.set_stock(&"wood", 4)
	var transaction := EconomyService.simulate_buy(poor_wallet, stocked, offer, 1)
	if transaction.result != EconomyService.RESULT_INSUFFICIENT_FUNDS:
		failures.append("Purchase without funds should report insufficient funds")
	if poor_wallet.balance_copper != 100 or stocked.get_stock(&"wood") != 4:
		failures.append("Purchase without funds must not mutate state")

	var wallet := WalletState.new(500)
	var empty := MerchantState.new(&"aldren_shop")
	empty.set_stock(&"wood", 1)
	transaction = EconomyService.simulate_buy(wallet, empty, offer, 2)
	if transaction.result != EconomyService.RESULT_OUT_OF_STOCK:
		failures.append("Purchase without enough stock should report out of stock")
	if wallet.balance_copper != 500 or empty.get_stock(&"wood") != 1:
		failures.append("Purchase without stock must not mutate state")

	transaction = EconomyService.simulate_buy(wallet, empty, offer, 0)
	if transaction.result != EconomyService.RESULT_INVALID_AMOUNT:
		failures.append("Purchase should reject zero quantity")
	if wallet.balance_copper != 500 or empty.get_stock(&"wood") != 1:
		failures.append("Invalid purchase quantity must not mutate state")


static func _test_sell_simulation_and_apply(failures: Array[String]) -> void:
	var wallet := WalletState.new(10)
	var merchant := MerchantState.new(&"aldren_shop")
	merchant.set_stock(&"wood", 1)
	var offer := _make_offer(120, 60)
	var transaction := EconomyService.simulate_sell(wallet, merchant, offer, 3)
	if transaction.result != EconomyService.RESULT_OK:
		failures.append("Valid sale should simulate successfully")
		return
	if wallet.balance_copper != 10 or merchant.get_stock(&"wood") != 1:
		failures.append("Sale simulation must not mutate live state")
	if transaction.wallet_after.balance_copper != 190:
		failures.append("Sale simulation should credit the exact integer price")
	if transaction.merchant_after.get_stock(&"wood") != 4:
		failures.append("Sale simulation should add merchant stock")
	if not EconomyService.apply_transaction(transaction, wallet, merchant):
		failures.append("Valid simulated sale should apply")
	if wallet.balance_copper != 190 or merchant.get_stock(&"wood") != 4:
		failures.append("Applied sale should update balance and stock together")


static func _test_stale_transaction_is_rejected(failures: Array[String]) -> void:
	var wallet := WalletState.new(500)
	var merchant := MerchantState.new(&"aldren_shop")
	merchant.set_stock(&"wood", 4)
	var transaction := EconomyService.simulate_buy(wallet, merchant, _make_offer(120, 60), 1)
	wallet.credit(1)
	if EconomyService.apply_transaction(transaction, wallet, merchant):
		failures.append("Transaction should reject a wallet changed after simulation")
	if wallet.balance_copper != 501 or merchant.get_stock(&"wood") != 4:
		failures.append("Rejected stale transaction must not mutate either state")


static func _make_offer(buy_price: int, sell_price: int) -> MerchantOfferData:
	var offer := MerchantOfferData.new()
	offer.offer_id = &"aldren_wood"
	offer.item_id = &"wood"
	offer.buy_price_copper = buy_price
	offer.sell_price_copper = sell_price
	return offer
