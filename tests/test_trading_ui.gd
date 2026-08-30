class_name TestTradingUI
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var previous_locale := LocalizationService.get_locale()
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	if tree == null or world_scene == null:
		failures.append("Trading UI requires SceneTree and world scene")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player")
	var economy := world.get_node_or_null("EconomyController")
	var trade_layer := world.get_node_or_null("TradeLayer")
	var trade_point := world.get_node_or_null("TradePoint")
	if player == null or economy == null:
		failures.append("Trading UI requires player and economy controller")
		_cleanup(world, previous_locale)
		return failures
	if trade_layer == null or not trade_layer.has_method("open_trade"):
		failures.append("World should expose reusable TradeLayer UI")
	if trade_point == null or not trade_point.has_method("interact"):
		failures.append("World should expose reusable TradePoint interactable")
	if not failures.is_empty():
		_cleanup(world, previous_locale)
		return failures

	LocalizationService.set_locale("en")
	if str(trade_point.get("prompt")) != "Trade":
		failures.append("Trade interaction prompt should localize to English")
	LocalizationService.set_locale("es")
	if str(trade_point.get("prompt")) != "Comerciar":
		failures.append("Trade interaction prompt should localize to Spanish")

	trade_point.call("interact", player)
	if not bool(trade_layer.call("is_trade_open")):
		failures.append("Interacting with TradePoint should open trade UI")

	var initial_balance := int(economy.call("get_balance_copper"))
	var initial_stock := int(economy.call("get_merchant_stock", &"wood"))
	var inventory: Variant = player.call("get_inventory_component")
	var initial_player_wood := int(inventory.call("count_item", &"wood"))
	var buy_result := StringName(trade_layer.call("buy_offer", &"yard_wood", 1))
	if buy_result != EconomyService.RESULT_OK:
		failures.append("Trading UI buy intent should use successful atomic economy API")
	if int(economy.call("get_balance_copper")) != initial_balance - 8:
		failures.append("Trading UI should reflect wallet after purchase")
	if int(economy.call("get_merchant_stock", &"wood")) != initial_stock - 1:
		failures.append("Trading UI should reflect merchant stock after purchase")
	if int(inventory.call("count_item", &"wood")) != initial_player_wood + 1:
		failures.append("Trading UI should reflect inventory after purchase")

	var sell_result := StringName(trade_layer.call("sell_offer", &"yard_wood", 1))
	if sell_result != EconomyService.RESULT_OK:
		failures.append("Trading UI sell intent should use successful atomic economy API")
	if int(economy.call("get_balance_copper")) != initial_balance - 4:
		failures.append("Trading UI should reflect wallet after sale")
	if int(economy.call("get_merchant_stock", &"wood")) != initial_stock:
		failures.append("Trading UI should reflect stock after sale")
	if int(inventory.call("count_item", &"wood")) != initial_player_wood:
		failures.append("Trading UI should reflect inventory after sale")

	var balance_before_invalid := int(economy.call("get_balance_copper"))
	var stock_before_invalid := int(economy.call("get_merchant_stock", &"wood"))
	var invalid_result := StringName(trade_layer.call("sell_offer", &"yard_wood", 999))
	if invalid_result == EconomyService.RESULT_OK:
		failures.append("Trading UI should surface rejected operations")
	if int(economy.call("get_balance_copper")) != balance_before_invalid:
		failures.append("Rejected UI trade must not change wallet")
	if int(economy.call("get_merchant_stock", &"wood")) != stock_before_invalid:
		failures.append("Rejected UI trade must not change merchant stock")

	var balance_text := str(trade_layer.call("get_balance_text"))
	if balance_text.is_empty() or not balance_text.contains("c"):
		failures.append("Trading UI should expose formatted copper/silver/gold balance")
	var feedback_text := str(trade_layer.call("get_feedback_text"))
	if feedback_text.is_empty():
		failures.append("Trading UI should expose localized rejection feedback")

	trade_layer.call("close_trade")
	if bool(trade_layer.call("is_trade_open")):
		failures.append("Trading UI should close cleanly")

	_cleanup(world, previous_locale)
	return failures


static func _cleanup(world: Node, previous_locale: StringName) -> void:
	LocalizationService.set_locale(String(previous_locale))
	world.free()
