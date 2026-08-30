class_name MerchantOfferData
extends Resource

@export var offer_id: StringName = &""
@export var item_id: StringName = &""
@export var buy_price_copper: int = 0
@export var sell_price_copper: int = 0


func is_valid() -> bool:
	return (
		offer_id != &""
		and item_id != &""
		and buy_price_copper > 0
		and sell_price_copper > 0
	)
