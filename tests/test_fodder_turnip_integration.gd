class_name TestFodderTurnipIntegration
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var turnip := load("res://data/items/fodder_turnip.tres") as ItemData
	var seed := load("res://data/farming/fodder_turnip_seed.tres") as ItemData
	var merchant := load("res://data/economy/yard_supplier.tres") as MerchantData
	var recipe := load("res://data/recipes/fodder_turnip_mash.tres") as RecipeData
	if turnip == null or seed == null:
		failures.append("Fodder turnip and seed item resources should load")
		return failures
	if turnip.id != &"fodder_turnip" or seed.id != &"fodder_turnip_seed":
		failures.append("Fodder turnip resources should expose stable item IDs")
	if merchant == null or not merchant.is_valid():
		failures.append("Yard supplier should remain valid with fodder turnip offers")
		return failures
	var seed_offer := merchant.get_offer(&"yard_fodder_turnip_seed")
	var turnip_offer := merchant.get_offer(&"yard_fodder_turnip")
	if seed_offer == null or turnip_offer == null:
		failures.append("Yard supplier should buy/sell fodder turnip resources")
		return failures
	if turnip_offer.sell_price_copper <= 0 or seed_offer.buy_price_copper <= 0:
		failures.append("Fodder turnip offers should use positive fixed prices")
	if seed_offer.buy_price_copper >= turnip_offer.sell_price_copper * 2:
		failures.append("Growing turnips should be more sustainable than buying equivalent produce")

	var wallet := WalletState.new(100)
	var merchant_state := merchant.create_state()
	var buy_tx := EconomyService.simulate_buy(wallet, merchant_state, seed_offer, 1)
	if not buy_tx.is_success() or not EconomyService.apply_transaction(buy_tx, wallet, merchant_state):
		failures.append("Seed purchase should use the existing atomic economy service")
	var seller_tx := EconomyService.simulate_sell(wallet, merchant_state, turnip_offer, 1, 1)
	if not seller_tx.is_success() or not EconomyService.apply_transaction(seller_tx, wallet, merchant_state):
		failures.append("Turnip sale should use the existing atomic economy service")

	if recipe == null or not recipe.is_valid():
		failures.append("Fodder turnip cooking recipe should load and validate")
		return failures
	var inventory := InventoryModel.new(2)
	inventory.add_item(turnip, 2)
	var result := CraftingService.craft(recipe, &"workbench", inventory)
	if result != CraftingService.RESULT_OK:
		failures.append("Fodder turnip recipe should reuse the existing crafting service")
	if inventory.count_item(&"fodder_turnip") != 0:
		failures.append("Fodder turnip recipe should consume configured produce exactly once")
	return failures
