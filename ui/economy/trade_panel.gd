class_name TradePanel
extends CanvasLayer

signal buy_requested(offer_id: StringName, quantity: int)
signal sell_requested(offer_id: StringName, quantity: int)

var economy: EconomyController
var inventory: InventoryComponent

@onready var panel: PanelContainer = $Panel
@onready var title_label: Label = $Panel/Margin/VBox/Title
@onready var balance_label: Label = $Panel/Margin/VBox/Balance
@onready var offers_container: VBoxContainer = $Panel/Margin/VBox/Offers
@onready var feedback_label: Label = $Panel/Margin/VBox/Feedback
@onready var close_button: Button = $Panel/Margin/VBox/Close


func _enter_tree() -> void:
	add_to_group("trade_panel")


func _ready() -> void:
	panel.hide()
	close_button.pressed.connect(close_trade)
	_refresh_static_text()


func open_trade(actor: Node, economy_controller: EconomyController) -> bool:
	if actor == null or economy_controller == null:
		return false
	if not actor.has_method("get_inventory_component"):
		return false
	var actor_inventory: Variant = actor.call("get_inventory_component")
	if not actor_inventory is InventoryComponent:
		return false
	economy = economy_controller
	inventory = actor_inventory as InventoryComponent
	feedback_label.text = ""
	panel.show()
	_refresh()
	return true


func close_trade() -> void:
	panel.hide()
	economy = null
	inventory = null
	feedback_label.text = ""


func is_trade_open() -> bool:
	return panel.visible


func buy_offer(offer_id: StringName, quantity: int = 1) -> StringName:
	buy_requested.emit(offer_id, quantity)
	var result := _perform_trade(true, offer_id, quantity)
	_set_feedback(result)
	_refresh()
	return result


func sell_offer(offer_id: StringName, quantity: int = 1) -> StringName:
	sell_requested.emit(offer_id, quantity)
	var result := _perform_trade(false, offer_id, quantity)
	_set_feedback(result)
	_refresh()
	return result


func get_balance_text() -> String:
	return balance_label.text


func get_feedback_text() -> String:
	return feedback_label.text


func _perform_trade(is_buy: bool, offer_id: StringName, quantity: int) -> StringName:
	if economy == null or inventory == null:
		return EconomyService.RESULT_INVALID_STATE
	if is_buy:
		return economy.buy(offer_id, quantity, inventory)
	return economy.sell(offer_id, quantity, inventory)


func _refresh() -> void:
	_refresh_static_text()
	_clear_offers()
	if economy == null or economy.merchant_data == null:
		balance_label.text = _format_money(0)
		return
	balance_label.text = _format_money(economy.get_balance_copper())
	for offer in economy.merchant_data.offers:
		if offer != null:
			_add_offer_row(offer)


func _refresh_static_text() -> void:
	if not is_node_ready():
		return
	title_label.text = LocalizationService.translate_key(&"UI_TRADE_TITLE")
	close_button.text = LocalizationService.translate_key(&"UI_TRADE_CLOSE")


func _add_offer_row(offer: MerchantOfferData) -> void:
	var row := HBoxContainer.new()
	row.name = str(offer.offer_id)
	var label := Label.new()
	var stock := economy.get_merchant_stock(offer.item_id)
	label.text = "%s | %s: %d | %s %s / %s %s" % [
		offer.item.display_name,
		LocalizationService.translate_key(&"UI_TRADE_STOCK"),
		stock,
		LocalizationService.translate_key(&"UI_TRADE_BUY"),
		_format_money(offer.buy_price_copper),
		LocalizationService.translate_key(&"UI_TRADE_SELL"),
		_format_money(offer.sell_price_copper),
	]
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	var buy_button := Button.new()
	buy_button.text = LocalizationService.translate_key(&"UI_TRADE_BUY")
	buy_button.pressed.connect(buy_offer.bind(offer.offer_id, 1))
	row.add_child(buy_button)
	var sell_button := Button.new()
	sell_button.text = LocalizationService.translate_key(&"UI_TRADE_SELL")
	sell_button.pressed.connect(sell_offer.bind(offer.offer_id, 1))
	row.add_child(sell_button)
	offers_container.add_child(row)


func _clear_offers() -> void:
	for child in offers_container.get_children():
		offers_container.remove_child(child)
		child.free()


func _set_feedback(result: StringName) -> void:
	var key := &"UI_TRADE_ERROR"
	match result:
		EconomyService.RESULT_OK:
			key = &"UI_TRADE_SUCCESS"
		EconomyService.RESULT_INSUFFICIENT_FUNDS:
			key = &"UI_TRADE_INSUFFICIENT_FUNDS"
		EconomyService.RESULT_OUT_OF_STOCK:
			key = &"UI_TRADE_OUT_OF_STOCK"
		EconomyController.RESULT_INVENTORY_FULL:
			key = &"UI_TRADE_INVENTORY_FULL"
	feedback_label.text = LocalizationService.translate_key(key)


func _format_money(amount_copper: int) -> String:
	var parts := MoneyMath.breakdown(maxi(amount_copper, 0))
	return "%dg %ds %dc" % [
		parts.get(&"gold", 0),
		parts.get(&"silver", 0),
		parts.get(&"copper", 0),
	]
