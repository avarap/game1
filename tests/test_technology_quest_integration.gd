class_name TestTechnologyQuestIntegration
extends RefCounted

const SAVE_PATH := "user://test_technology_quest_integration.json"


static func run() -> Array[String]:
	var failures: Array[String] = []
	var quest := load("res://data/quests/aldren_first_duty.tres") as QuestData
	if quest == null:
		failures.append("Technology quest integration requires Aldren quest data")
		return failures

	var technology_reward := _find_technology_reward(quest)
	if technology_reward == null:
		failures.append("Aldren quest should define a typed technology-points reward")
		return failures
	if technology_reward.red_points != 2 or technology_reward.green_points != 1:
		failures.append("Technology reward should expose configured red/green points")
	if technology_reward.blue_points != 0 or not technology_reward.is_valid():
		failures.append("Technology reward should validate non-negative configured points")

	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	var plank := load("res://data/items/plank.tres") as ItemData
	if tree == null or world_scene == null or plank == null:
		failures.append("Technology quest integration requires world and plank data")
		return failures
	var save_manager := tree.root.get_node_or_null("SaveManager")
	if save_manager == null:
		failures.append("Technology quest integration requires SaveManager")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player") as PlayerController
	var quests := world.get_node_or_null("QuestController") as QuestController
	var technology := world.get_node_or_null("TechnologyController") as TechnologyController
	if player == null or quests == null or technology == null:
		failures.append("World should expose player, quests and technology controllers")
		_cleanup(world)
		return failures

	var inventory := player.get_inventory_component()
	var red_before := technology.get_points(TechnologyService.PointType.RED)
	var green_before := technology.get_points(TechnologyService.PointType.GREEN)
	var blue_before := technology.get_points(TechnologyService.PointType.BLUE)
	if not quests.start_quest(&"aldren_first_duty"):
		failures.append("Technology reward quest should start")
	inventory.add_item(plank, 2)
	if not quests.turn_in_quest(&"aldren_first_duty"):
		failures.append("Technology reward quest should complete")
	if technology.get_points(TechnologyService.PointType.RED) != red_before + 2:
		failures.append("Quest completion should grant configured red technology points")
	if technology.get_points(TechnologyService.PointType.GREEN) != green_before + 1:
		failures.append("Quest completion should grant configured green technology points")
	if technology.get_points(TechnologyService.PointType.BLUE) != blue_before:
		failures.append("Quest completion should preserve unconfigured blue points")

	var quest_flags: Dictionary = quests.get_dialogue_context().get(&"quest_flags", {})
	if not bool(quest_flags.get(&"completed_first_duty", false)):
		failures.append("Existing QUEST_FLAG reward must remain compatible")
	var points_after_claim := technology.get_save_data().duplicate(true)
	if not quests.service.claim_rewards(&"aldren_first_duty").is_empty():
		failures.append("Technology quest reward should remain claimable exactly once")
	if technology.get_save_data() != points_after_claim:
		failures.append("Retrying reward claim must not grant technology points again")

	if not bool(save_manager.call("save_game", SAVE_PATH)):
		failures.append("SaveManager should persist quest and technology reward state")
		_cleanup(world)
		return failures
	quests.apply_save_data({})
	technology.reset_progress_for_tests()
	var loaded: Variant = save_manager.call("load_game", SAVE_PATH)
	if typeof(loaded) != TYPE_DICTIONARY or (loaded as Dictionary).is_empty():
		failures.append("SaveManager should restore technology quest reward state")
		_cleanup(world)
		return failures
	if technology.get_save_data() != points_after_claim:
		failures.append("Save/load should restore technology points granted by quest")
	if not quests.service.claim_rewards(&"aldren_first_duty").is_empty():
		failures.append("Save/load must preserve quest reward idempotency")
	if technology.get_save_data() != points_after_claim:
		failures.append("Post-load retry must not duplicate technology points")

	_cleanup(world)
	return failures


static func _find_technology_reward(quest: QuestData) -> QuestRewardData:
	for reward in quest.rewards:
		if reward != null and reward.reward_type == QuestRewardData.RewardType.TECHNOLOGY_POINTS:
			return reward
	return null


static func _cleanup(world: Node) -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	world.free()
