class_name EconomyController
extends Node

const RESULT_INVENTORY_FULL: StringName = &"inventory_full"

@export var merchant_data: MerchantData
@export_range(0, 1000000, 1) var starting_balance_copper: int = 500

var wallet: WalletState
var merchant: MerchantState


func _enter_tree() -> void:
	add_to_group("economy_controller")
	add_to_group("save_provider")


func _ready() -> void:
	_ensure_state()


func buy(offer_id: StringName, quantity: int, inventory: InventoryComponent) -> StringName:
	_ensure_state()
	var offer := _get_offer(offer_id)
	var validation := _validate_trade_context(offer, inventory)
	if validation != EconomyService.RESULT_OK:
		return validation

	var transaction := EconomyService.simulate_buy(wallet, merchant, offer, quantity)
	if not transaction.is_success():
		return transaction.result
	if not inventory.can_add_item(offer.item, quantity):
		return RESULT_INVENTORY_FULL
	return _commit_buy(transaction, offer, quantity, inventory)


func sell(offer_id: StringName, quantity: int, inventory: InventoryComponent) -> StringName:
	_ensure_state()
	var offer := _get_offer(offer_id)
	var validation := _validate_trade_context(offer, inventory)
	if validation != EconomyService.RESULT_OK:
		return validation

	var seller_stock := inventory.count_item(offer.item_id)
	var transaction := EconomyService.simulate_sell(wallet, merchant, offer, quantity, seller_stock)
	if not transaction.is_success():
		return transaction.result
	return _commit_sell(transaction, offer, quantity, inventory)


func get_balance_copper() -> int:
	_ensure_state()
	return wallet.balance_copper if wallet != null else 0


func get_merchant_stock(item_id: StringName) -> int:
	_ensure_state()
	return merchant.get_stock(item_id) if merchant != null else 0


func get_save_key() -> StringName:
	return &"economy"


func get_save_data() -> Dictionary:
	_ensure_state()
	if wallet == null or merchant == null or merchant_data == null:
		return {}
	var stock: Dictionary = {}
	for offer in merchant_data.offers:
		if offer != null:
			stock[str(offer.item_id)] = merchant.get_stock(offer.item_id)
	return {
		&"balance_copper": wallet.balance_copper,
		&"merchant_id": str(merchant.merchant_id),
		&"stock": stock,
	}


func apply_save_data(data: Dictionary) -> void:
	_ensure_state()
	if wallet == null or merchant == null or merchant_data == null:
		return
	var balance := int(data.get(&"balance_copper", -1))
	var saved_merchant_id := StringName(str(data.get(&"merchant_id", "")))
	var stock_value: Variant = data.get(&"stock", {})
	if balance < 0 or saved_merchant_id != merchant.merchant_id:
		return
	if typeof(stock_value) != TYPE_DICTIONARY:
		return

	var candidate := MerchantState.new(merchant.merchant_id)
	var saved_stock := stock_value as Dictionary
	for offer in merchant_data.offers:
		if offer == null:
			continue
		var amount := _saved_stock_amount(saved_stock, offer.item_id)
		if amount < 0 or not candidate.set_stock(offer.item_id, amount):
			return

	var wallet_candidate := WalletState.new(balance)
	if not wallet.apply_from(wallet_candidate):
		return
	merchant.apply_from(candidate)


func _validate_trade_context(offer: MerchantOfferData, inventory: InventoryComponent) -> StringName:
	if inventory == null or wallet == null or merchant == null:
		return EconomyService.RESULT_INVALID_STATE
	if offer == null or offer.item == null:
		return EconomyService.RESULT_INVALID_OFFER
	return EconomyService.RESULT_OK


func _commit_buy(
	transaction: EconomyTransaction,
	offer: MerchantOfferData,
	quantity: int,
	inventory: InventoryComponent
) -> StringName:
	var remainder := inventory.add_item(offer.item, quantity)
	if remainder != 0:
		_rollback_added_items(inventory, offer.item_id, quantity - remainder)
		return EconomyService.RESULT_INVALID_STATE
	if not EconomyService.apply_transaction(transaction, wallet, merchant):
		_rollback_added_items(inventory, offer.item_id, quantity)
		return EconomyService.RESULT_INVALID_STATE
	return EconomyService.RESULT_OK


func _commit_sell(
	transaction: EconomyTransaction,
	offer: MerchantOfferData,
	quantity: int,
	inventory: InventoryComponent
) -> StringName:
	var removed := inventory.remove_item(offer.item_id, quantity)
	if removed != quantity:
		_rollback_removed_items(inventory, offer.item, removed)
		return EconomyService.RESULT_INVALID_STATE
	if not EconomyService.apply_transaction(transaction, wallet, merchant):
		_rollback_removed_items(inventory, offer.item, removed)
		return EconomyService.RESULT_INVALID_STATE
	return EconomyService.RESULT_OK


func _ensure_state() -> void:
	if wallet == null:
		wallet = WalletState.new(starting_balance_copper)
	if merchant == null and merchant_data != null:
		merchant = merchant_data.create_state()


func _get_offer(offer_id: StringName) -> MerchantOfferData:
	if merchant_data == null or not merchant_data.is_valid():
		return null
	return merchant_data.get_offer(offer_id)


func _saved_stock_amount(saved_stock: Dictionary, item_id: StringName) -> int:
	if saved_stock.has(item_id):
		return int(saved_stock.get(item_id, -1))
	return int(saved_stock.get(str(item_id), -1))


func _rollback_added_items(inventory: InventoryComponent, item_id: StringName, amount: int) -> void:
	if amount > 0:
		inventory.remove_item(item_id, amount)


func _rollback_removed_items(inventory: InventoryComponent, item: ItemData, amount: int) -> void:
	if amount > 0:
		inventory.add_item(item, amount)
