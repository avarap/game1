class_name TestRPGAcceptance
extends RefCounted

const SAVE_PATH := "user://test_rpg_acceptance.json"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	var plank := load("res://data/items/plank.tres") as ItemData
	if tree == null or world_scene == null or plank == null:
		failures.append("RPG acceptance requires SceneTree, world and plank data")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player") as PlayerController
	var relationships := world.get_node_or_null("RelationshipController") as RelationshipController
	var quests := world.get_node_or_null("QuestController") as QuestController
	var economy := world.get_node_or_null("EconomyController")
	var technology := world.get_node_or_null("TechnologyController") as TechnologyController
	if player == null or relationships == null or quests == null or economy == null or technology == null:
		failures.append("World should expose all RPG controllers for acceptance")
		world.free()
		return failures

	var inventory := player.get_inventory_component()
	if inventory == null:
		failures.append("RPG acceptance requires player inventory")
		world.free()
		return failures

	relationships.change_relationship(&"brother_aldren", 12)
	if not quests.start_quest(&"aldren_first_duty"):
		failures.append("Acceptance quest should start from its controller")
	inventory.add_item(plank, 2)
	if not quests.turn_in_quest(&"aldren_first_duty"):
		failures.append("Acceptance quest should complete after meeting its objective")
	var buy_result := StringName(economy.call("buy", &"yard_wood", 1, inventory))
	if buy_result != EconomyService.RESULT_OK:
		failures.append("Acceptance economy purchase should succeed")
	var unlock_result := technology.unlock(&"sturdy_joinery")
	if unlock_result != TechnologyService.RESULT_OK:
		failures.append("Acceptance technology unlock should succeed")
	if not failures.is_empty():
		_cleanup(world)
		return failures

	var expected_relationship := relationships.get_relationship(&"brother_aldren")
	var expected_balance := int(economy.call("get_balance_copper"))
	var expected_stock := int(economy.call("get_merchant_stock", &"wood"))
	var expected_red := technology.get_points(TechnologyService.PointType.RED)
	var expected_green := technology.get_points(TechnologyService.PointType.GREEN)
	if not SaveManager.save_game(SAVE_PATH):
		failures.append("SaveManager should persist the integrated RPG state")
		_cleanup(world)
		return failures

	relationships.change_relationship(&"brother_aldren", -100)
	quests.apply_save_data({})
	economy.call("buy", &"yard_wood", 1, inventory)
	technology.reset_progress_for_tests()
	var payload := SaveManager.load_game(SAVE_PATH)
	if payload.is_empty():
		failures.append("SaveManager should load the integrated RPG save")
		_cleanup(world)
		return failures

	var saved_world: Dictionary = payload.get("world", {})
	for key in ["relationships", "quests", "economy", "technology"]:
		if not saved_world.has(key):
			failures.append("Integrated save should include RPG provider: %s" % key)
	if relationships.get_relationship(&"brother_aldren") != expected_relationship:
		failures.append("Relationship state should survive integrated save/load")
	if quests.get_status(&"aldren_first_duty") != QuestService.STATUS_COMPLETED:
		failures.append("Quest completion should survive integrated save/load")
	var quest_flags: Dictionary = quests.get_dialogue_context().get(&"quest_flags", {})
	if not bool(quest_flags.get(&"completed_first_duty", false)):
		failures.append("Quest reward flags should survive integrated save/load")
	if not quests.service.claim_rewards(&"aldren_first_duty").is_empty():
		failures.append("Quest rewards must remain idempotent after save/load")
	if int(economy.call("get_balance_copper")) != expected_balance:
		failures.append("Wallet balance should survive integrated save/load")
	if int(economy.call("get_merchant_stock", &"wood")) != expected_stock:
		failures.append("Merchant stock should survive integrated save/load")
	if not technology.is_unlocked(&"sturdy_joinery"):
		failures.append("Technology unlock should survive integrated save/load")
	if not technology.is_content_unlocked(&"recipe_reinforced_fence"):
		failures.append("Technology content unlock should survive integrated save/load")
	if technology.get_points(TechnologyService.PointType.RED) != expected_red:
		failures.append("Red technology points should survive integrated save/load")
	if technology.get_points(TechnologyService.PointType.GREEN) != expected_green:
		failures.append("Green technology points should survive integrated save/load")
	var points_before_retry := technology.get_points(TechnologyService.PointType.RED)
	if technology.unlock(&"sturdy_joinery") != TechnologyService.RESULT_ALREADY_UNLOCKED:
		failures.append("Unlocked technology should reject a duplicate unlock after load")
	if technology.get_points(TechnologyService.PointType.RED) != points_before_retry:
		failures.append("Duplicate technology unlock must not consume points after load")

	_cleanup(world)
	return failures


static func _cleanup(world: Node) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	world.free()
