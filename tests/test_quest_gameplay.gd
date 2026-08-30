class_name TestQuestGameplay
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var tree := Engine.get_main_loop() as SceneTree
	var world_scene := load("res://world/world.tscn") as PackedScene
	var plank := load("res://data/items/plank.tres") as ItemData
	if tree == null or world_scene == null or plank == null:
		failures.append("Quest gameplay test requires SceneTree, world and plank data")
		return failures

	var world := world_scene.instantiate()
	tree.root.add_child(world)
	var player := world.get_node_or_null("Player") as PlayerController
	var quest_controller := world.get_node_or_null("QuestController") as QuestController
	var dialogue_controller := world.get_node_or_null("DialogueLayer") as DialogueController
	var aldren := world.get_node_or_null("BrotherAldren")
	var interactable: DialogueInteractable
	if aldren != null:
		interactable = aldren.get_node_or_null("DialogueInteractable") as DialogueInteractable
	if (
		player == null
		or quest_controller == null
		or dialogue_controller == null
		or interactable == null
	):
		failures.append("World should expose player, quest controller, dialogue and Aldren")
		world.free()
		return failures

	interactable.interact(player)
	if not dialogue_controller.select_option(&"first_task"):
		failures.append("Aldren first-task dialogue option should start the quest")
	if quest_controller.get_status(&"aldren_first_duty") != QuestService.STATUS_ACTIVE:
		failures.append("Dialogue quest trigger should activate Aldren first duty")
	dialogue_controller.close_dialogue()

	var inventory := player.get_inventory_component()
	if inventory == null:
		failures.append("Player should expose inventory for quest progress")
		world.free()
		return failures
	inventory.add_item(plank, 2)
	if not quest_controller.is_ready(&"aldren_first_duty"):
		failures.append("Adding required planks should make the active quest ready")

	interactable.interact(player)
	if not dialogue_controller.select_option(&"turn_in_first_task"):
		failures.append("Ready quest should expose its Aldren turn-in option")
	if quest_controller.get_status(&"aldren_first_duty") != QuestService.STATUS_COMPLETED:
		failures.append("Turning in through dialogue should complete the quest")
	var quest_context: Dictionary = quest_controller.get_dialogue_context()
	var flags: Dictionary = quest_context.get(&"quest_flags", {})
	if not bool(flags.get(&"completed_first_duty", false)):
		failures.append("Quest completion should grant its one-time narrative reward")
	if quest_controller.get_save_key() != &"quests":
		failures.append("QuestController should persist through the generic save-provider contract")

	var snapshot := quest_controller.get_save_data()
	quest_controller.apply_save_data(snapshot)
	if quest_controller.get_status(&"aldren_first_duty") != QuestService.STATUS_COMPLETED:
		failures.append("QuestController save data should restore completed state")

	world.free()
	return failures
