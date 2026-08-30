class_name MoneyMath
extends RefCounted

const INVALID_AMOUNT: int = -1
const COPPER_PER_SILVER: int = 100
const SILVER_PER_GOLD: int = 100
const COPPER_PER_GOLD: int = COPPER_PER_SILVER * SILVER_PER_GOLD


static func to_copper(gold: int, silver: int, copper: int) -> int:
	if gold < 0 or silver < 0 or copper < 0:
		return INVALID_AMOUNT
	return gold * COPPER_PER_GOLD + silver * COPPER_PER_SILVER + copper


static func breakdown(amount_copper: int) -> Dictionary:
	if amount_copper < 0:
		return {}
	var gold: int = amount_copper / COPPER_PER_GOLD
	var remaining: int = amount_copper % COPPER_PER_GOLD
	var silver: int = remaining / COPPER_PER_SILVER
	var copper: int = remaining % COPPER_PER_SILVER
	return {&"gold": gold, &"silver": silver, &"copper": copper}
