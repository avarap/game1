class_name TestRPGAcceptance
extends RefCounted

const SAVE_PATH := "user://test_rpg_acceptance.json"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	var plank := load("res://data/items/plank.tres") as ItemData
	var dialogue := load("res://data/dialogues/brother_aldren/introduction.tres") as DialogueData
	if tree == null or world_scene == null or plank == null or dialogue == null:
		failures.append("RPG acceptance requires SceneTree and canonical RPG data")
		return failures

	var save_manager := tree.root.get_node_or_null("SaveManager")
	if save_manager == null:
		failures.append("RPG acceptance requires the SaveManager autoload")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player") as PlayerController
	var relationships := world.get_node_or_null("RelationshipController") as RelationshipController
	var quests := world.get_node_or_null("QuestController") as QuestController
	var economy := world.get_node_or_null("EconomyController")
	var technology := world.get_node_or_null("TechnologyController") as TechnologyController
	if (
		player == null
		or relationships == null
		or quests == null
		or economy == null
		or technology == null
	):
		failures.append("World should expose all RPG controllers for acceptance")
		_cleanup(world)
		return failures

	var inventory := player.get_inventory_component()
	if inventory == null:
		failures.append("RPG acceptance requires player inventory")
		_cleanup(world)
		return failures

	var low_trust_options := _available_option_ids(dialogue, relationships.get_dialogue_context())
	if low_trust_options.has(&"trusted_question"):
		failures.append("Relationship-gated dialogue should start locked")
	relationships.change_relationship(&"brother_aldren", 12)
	var trusted_options := _available_option_ids(dialogue, relationships.get_dialogue_context())
	if not trusted_options.has(&"trusted_question"):
		failures.append("Relationship change should unlock trusted dialogue content")

	var red_before_quest := technology.get_points(TechnologyService.PointType.RED)
	var green_before_quest := technology.get_points(TechnologyService.PointType.GREEN)
	if not quests.start_quest(&"aldren_first_duty"):
		failures.append("Acceptance quest should start from its controller")
	inventory.add_item(plank, 2)
	if not quests.turn_in_quest(&"aldren_first_duty"):
		failures.append("Acceptance quest should complete after meeting its objective")
	if technology.get_points(TechnologyService.PointType.RED) != red_before_quest + 2:
		failures.append("Acceptance quest should grant its configured red technology points")
	if technology.get_points(TechnologyService.PointType.GREEN) != green_before_quest + 1:
		failures.append("Acceptance quest should grant its configured green technology points")
	var quest_flags: Dictionary = quests.get_dialogue_context().get(&"quest_flags", {})
	if not bool(quest_flags.get(&"completed_first_duty", false)):
		failures.append("Acceptance quest should grant its QUEST_FLAG reward")
	var reward_state := technology.get_save_data().duplicate(true)
	if not quests.service.claim_rewards(&"aldren_first_duty").is_empty():
		failures.append("Acceptance quest rewards should be claimable exactly once")
	if technology.get_save_data() != reward_state:
		failures.append("Retrying quest rewards must not duplicate technology points")

	var balance_before_trade := int(economy.call("get_balance_copper"))
	var stock_before_trade := int(economy.call("get_merchant_stock", &"wood"))
	var wood_before_trade := inventory.count_item(&"wood")
	var buy_result := StringName(economy.call("buy", &"yard_wood", 2, inventory))
	if buy_result != EconomyService.RESULT_OK:
		failures.append("Acceptance economy purchase should succeed")
	var sell_result := StringName(economy.call("sell", &"yard_wood", 1, inventory))
	if sell_result != EconomyService.RESULT_OK:
		failures.append("Acceptance economy sale should succeed")
	if int(economy.call("get_balance_copper")) != balance_before_trade - 12:
		failures.append("Acceptance buy plus sell should apply the exact net copper delta")
	if int(economy.call("get_merchant_stock", &"wood")) != stock_before_trade - 1:
		failures.append("Acceptance buy plus sell should preserve exact merchant stock")
	if inventory.count_item(&"wood") != wood_before_trade + 1:
		failures.append("Acceptance buy plus sell should preserve exact inventory delta")

	var red_before_unlock := technology.get_points(TechnologyService.PointType.RED)
	var green_before_unlock := technology.get_points(TechnologyService.PointType.GREEN)
	var unlock_result := technology.unlock(&"sturdy_joinery")
	if unlock_result != TechnologyService.RESULT_OK:
		failures.append("Acceptance technology unlock should succeed")
	if technology.get_points(TechnologyService.PointType.RED) != red_before_unlock - 2:
		failures.append("Acceptance technology unlock should consume two red points")
	if technology.get_points(TechnologyService.PointType.GREEN) != green_before_unlock - 1:
		failures.append("Acceptance technology unlock should consume one green point")
	if not technology.is_content_unlocked(&"recipe_reinforced_fence"):
		failures.append("Acceptance technology should expose its unlocked content")
	if not failures.is_empty():
		_cleanup(world)
		return failures

	var expected_relationship := relationships.get_relationship(&"brother_aldren")
	var expected_balance := int(economy.call("get_balance_copper"))
	var expected_stock := int(economy.call("get_merchant_stock", &"wood"))
	var expected_red := technology.get_points(TechnologyService.PointType.RED)
	var expected_green := technology.get_points(TechnologyService.PointType.GREEN)
	if not bool(save_manager.call("save_game", SAVE_PATH)):
		failures.append("SaveManager should persist the integrated RPG state")
		_cleanup(world)
		return failures

	world.free()
	var restored_world := world_scene.instantiate()
	tree.root.add_child(restored_world)
	var restored_relationships := (
		restored_world.get_node_or_null("RelationshipController") as RelationshipController
	)
	var restored_quests := restored_world.get_node_or_null("QuestController") as QuestController
	var restored_economy := restored_world.get_node_or_null("EconomyController")
	var restored_technology := (
		restored_world.get_node_or_null("TechnologyController") as TechnologyController
	)
	if (
		restored_relationships == null
		or restored_quests == null
		or restored_economy == null
		or restored_technology == null
	):
		failures.append("Reconstructed world should expose all persisted RPG providers")
		_cleanup(restored_world)
		return failures

	var loaded: Variant = save_manager.call("load_game", SAVE_PATH)
	if typeof(loaded) != TYPE_DICTIONARY:
		failures.append("SaveManager should load a dictionary payload")
		_cleanup(restored_world)
		return failures
	var payload := loaded as Dictionary
	if payload.is_empty():
		failures.append("SaveManager should load the integrated RPG save")
		_cleanup(restored_world)
		return failures

	var saved_world: Dictionary = payload.get("world", {})
	for key in ["relationships", "quests", "economy", "technology"]:
		if not saved_world.has(key):
			failures.append("Integrated save should include RPG provider: %s" % key)
	if restored_relationships.get_relationship(&"brother_aldren") != expected_relationship:
		failures.append("Relationship state should survive reconstructed save/load")
	if restored_quests.get_status(&"aldren_first_duty") != QuestService.STATUS_COMPLETED:
		failures.append("Quest completion should survive reconstructed save/load")
	var restored_flags: Dictionary = restored_quests.get_dialogue_context().get(&"quest_flags", {})
	if not bool(restored_flags.get(&"completed_first_duty", false)):
		failures.append("Quest reward flags should survive reconstructed save/load")
	if not restored_quests.service.claim_rewards(&"aldren_first_duty").is_empty():
		failures.append("Quest rewards must remain idempotent after reconstructed load")
	if int(restored_economy.call("get_balance_copper")) != expected_balance:
		failures.append("Wallet balance should survive reconstructed save/load")
	if int(restored_economy.call("get_merchant_stock", &"wood")) != expected_stock:
		failures.append("Merchant stock should survive reconstructed save/load")
	if not restored_technology.is_unlocked(&"sturdy_joinery"):
		failures.append("Technology unlock should survive reconstructed save/load")
	if not restored_technology.is_content_unlocked(&"recipe_reinforced_fence"):
		failures.append("Technology content unlock should survive reconstructed save/load")
	if restored_technology.get_points(TechnologyService.PointType.RED) != expected_red:
		failures.append("Red technology points should survive reconstructed save/load")
	if restored_technology.get_points(TechnologyService.PointType.GREEN) != expected_green:
		failures.append("Green technology points should survive reconstructed save/load")
	var points_before_retry := restored_technology.get_points(TechnologyService.PointType.RED)
	if restored_technology.unlock(&"sturdy_joinery") != TechnologyService.RESULT_ALREADY_UNLOCKED:
		failures.append("Unlocked technology should reject a duplicate unlock after load")
	if restored_technology.get_points(TechnologyService.PointType.RED) != points_before_retry:
		failures.append("Duplicate technology unlock must not consume points after load")

	_cleanup(restored_world)
	return failures


static func _available_option_ids(dialogue: DialogueData, context: Dictionary) -> Array[StringName]:
	var service := DialogueService.new()
	var ids: Array[StringName] = []
	if not service.start(dialogue, context):
		return ids
	for option in service.get_available_options():
		ids.append(option.id)
	return ids


static func _cleanup(world: Node) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	world.free()
