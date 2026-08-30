class_name MerchantData
extends Resource

@export var merchant_id: StringName = &""
@export var offers: Array[MerchantOfferData] = []
@export var starting_stock: Dictionary = {}


func is_valid() -> bool:
	if merchant_id == &"" or offers.is_empty():
		return false
	var offer_ids: Dictionary = {}
	for offer in offers:
		if not _is_offer_valid(offer):
			return false
		if offer_ids.has(offer.offer_id):
			return false
		offer_ids[offer.offer_id] = true
	return true


func get_offer(offer_id: StringName) -> MerchantOfferData:
	for offer in offers:
		if offer != null and offer.offer_id == offer_id:
			return offer
	return null


func create_state() -> MerchantState:
	if not is_valid():
		return null
	var state := MerchantState.new(merchant_id)
	for offer in offers:
		var amount := _get_starting_stock(offer.item_id)
		if not state.set_stock(offer.item_id, amount):
			return null
	return state


func _is_offer_valid(offer: MerchantOfferData) -> bool:
	if offer == null or not offer.is_valid() or offer.item == null:
		return false
	if offer.item.id != offer.item_id:
		return false
	return _get_starting_stock(offer.item_id) >= 0


func _get_starting_stock(item_id: StringName) -> int:
	if starting_stock.has(item_id):
		return int(starting_stock.get(item_id, -1))
	return int(starting_stock.get(str(item_id), 0))
