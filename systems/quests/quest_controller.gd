class_name QuestController
extends Node

@export var quest_data: Array[QuestData] = []

var service := QuestService.new()
var _inventory: InventoryComponent


func _enter_tree() -> void:
	add_to_group("quest_controller")
	add_to_group("save_provider")


func _ready() -> void:
	for data in quest_data:
		service.register(data)
	_resolve_inventory()
	_connect_dialogue()
	_sync_active_item_objectives()


func get_dialogue_context() -> Dictionary:
	return service.build_dialogue_context()


func get_save_key() -> StringName:
	return &"quests"


func get_save_data() -> Dictionary:
	return service.snapshot()


func apply_save_data(data: Dictionary) -> void:
	service.apply_snapshot(data)
	_sync_active_item_objectives()


func start_quest(quest_id: StringName) -> bool:
	if not service.start_quest(quest_id):
		return false
	_sync_active_item_objectives()
	return true


func turn_in_quest(quest_id: StringName) -> bool:
	if not service.complete_quest(quest_id):
		return false
	_apply_rewards(service.claim_rewards(quest_id))
	return true


func get_status(quest_id: StringName) -> StringName:
	return service.get_status(quest_id)


func is_ready(quest_id: StringName) -> bool:
	return service.is_ready(quest_id)


func get_journal_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for quest in quest_data:
		if quest == null:
			continue
		var status := service.get_status(quest.id)
		if status != QuestService.STATUS_ACTIVE and status != QuestService.STATUS_COMPLETED:
			continue
		var objectives: Array[Dictionary] = []
		for objective in quest.objectives:
			if objective == null:
				continue
			var objective_entry: Dictionary = {}
			objective_entry["id"] = objective.id
			objective_entry["current"] = service.get_progress(quest.id, objective.id)
			objective_entry["required"] = objective.required_amount
			objectives.append(objective_entry)
		var entry: Dictionary = {}
		entry["id"] = quest.id
		entry["status"] = status
		entry["title_key"] = quest.title_key
		entry["description_key"] = quest.description_key
		entry["objectives"] = objectives
		entries.append(entry)
	return entries


func _apply_rewards(rewards: Array[QuestRewardData]) -> void:
	if rewards.is_empty():
		return
	var technology := get_tree().get_first_node_in_group("technology_controller") as TechnologyController
	for reward in rewards:
		if reward == null or reward.reward_type != QuestRewardData.RewardType.TECHNOLOGY_POINTS:
			continue
		if technology != null:
			technology.add_points(reward.red_points, reward.green_points, reward.blue_points)


func _resolve_inventory() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return
	if not player.has_method("get_inventory_component"):
		return
	_inventory = player.call("get_inventory_component") as InventoryComponent
	if _inventory == null:
		return
	if _inventory.inventory_changed.is_connected(_on_inventory_changed):
		return
	_inventory.inventory_changed.connect(_on_inventory_changed)


func _connect_dialogue() -> void:
	var node := get_tree().get_first_node_in_group("dialogue_controller")
	var controller := node as DialogueController
	if controller == null:
		return
	if controller.option_committed.is_connected(_on_dialogue_option_committed):
		return
	controller.option_committed.connect(_on_dialogue_option_committed)


func _on_inventory_changed() -> void:
	_sync_active_item_objectives()


func _sync_active_item_objectives() -> void:
	if _inventory == null:
		_resolve_inventory()
	if _inventory == null:
		return
	for quest in service.get_active_quests():
		_sync_quest_item_objectives(quest)


func _sync_quest_item_objectives(quest: QuestData) -> void:
	for objective in quest.objectives:
		if objective.objective_type != QuestObjectiveData.ObjectiveType.ITEM_COUNT:
			continue
		var amount := _inventory.count_item(objective.item_id)
		service.update_item_count(objective.item_id, amount)


func _on_dialogue_option_committed(option: DialogueOptionData) -> void:
	if option == null or option.quest_id.is_empty():
		return
	match option.quest_action:
		DialogueOptionData.QuestAction.START:
			start_quest(option.quest_id)
		DialogueOptionData.QuestAction.TURN_IN:
			turn_in_quest(option.quest_id)
