extends PanelContainer

const ALDREN_ID := &"brother_aldren"
const TEST_QUEST_ID := &"aldren_first_duty"
const WOOD_ITEM: ItemData = preload("res://data/items/wood.tres")
const PLANK_ITEM: ItemData = preload("res://data/items/plank.tres")

@onready var status: Label = $Margin/VBox/Status
@onready var add_wood_button: Button = $Margin/VBox/InventoryButtons/AddWood
@onready var add_planks_button: Button = $Margin/VBox/InventoryButtons/AddPlanks
@onready var relationship_down_button: Button = $Margin/VBox/RelationshipButtons/RelationshipDown
@onready var relationship_up_button: Button = $Margin/VBox/RelationshipButtons/RelationshipUp
@onready var start_quest_button: Button = $Margin/VBox/QuestButtons/StartQuest
@onready var turn_in_quest_button: Button = $Margin/VBox/QuestButtons/TurnInQuest
@onready var advance_hour_button: Button = $Margin/VBox/AdvanceHour
@onready var save_button: Button = $Margin/VBox/Save


func _ready() -> void:
	visible = false
	add_wood_button.pressed.connect(_on_add_wood_pressed)
	add_planks_button.pressed.connect(_on_add_planks_pressed)
	relationship_down_button.pressed.connect(_on_relationship_down_pressed)
	relationship_up_button.pressed.connect(_on_relationship_up_pressed)
	start_quest_button.pressed.connect(_on_start_quest_pressed)
	turn_in_quest_button.pressed.connect(_on_turn_in_quest_pressed)
	advance_hour_button.pressed.connect(_on_advance_hour_pressed)
	save_button.pressed.connect(_on_save_pressed)
	EventBus.time_changed.connect(_refresh_status)
	EventBus.bootstrap_ready.connect(_refresh_status)
	_refresh_status()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("debug_panel"):
		visible = not visible
		if visible:
			_refresh_status()
		get_viewport().set_input_as_handled()


func _on_add_wood_pressed() -> void:
	_add_known_item(WOOD_ITEM, 1)


func _on_add_planks_pressed() -> void:
	_add_known_item(PLANK_ITEM, 2)


func _on_relationship_down_pressed() -> void:
	_change_aldren_relationship(-5)


func _on_relationship_up_pressed() -> void:
	_change_aldren_relationship(5)


func _on_start_quest_pressed() -> void:
	var controller := _get_quest_controller()
	if controller == null:
		return
	controller.start_quest(TEST_QUEST_ID)
	_refresh_status()


func _on_turn_in_quest_pressed() -> void:
	var controller := _get_quest_controller()
	if controller == null:
		return
	if controller.is_ready(TEST_QUEST_ID):
		controller.turn_in_quest(TEST_QUEST_ID)
	_refresh_status()


func _on_advance_hour_pressed() -> void:
	TimeManager.add_minutes(60)


func _on_save_pressed() -> void:
	SaveManager.save_game()
	_refresh_status()


func _add_known_item(item: ItemData, amount: int) -> void:
	var inventory := _get_inventory()
	if inventory == null:
		return
	inventory.add_item(item, amount)
	_refresh_status()


func _change_aldren_relationship(delta: int) -> void:
	var controller := _get_relationship_controller()
	if controller == null:
		return
	controller.change_relationship(ALDREN_ID, delta)
	_refresh_status()


func _get_inventory() -> InventoryComponent:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not player.has_method("get_inventory_component"):
		return null
	return player.call("get_inventory_component") as InventoryComponent


func _get_quest_controller() -> QuestController:
	return get_tree().get_first_node_in_group("quest_controller") as QuestController


func _get_relationship_controller() -> RelationshipController:
	return (
		get_tree().get_first_node_in_group("relationship_controller") as RelationshipController
	)


func _refresh_status(_arg1 = null, _arg2 = null) -> void:
	var inventory := _get_inventory()
	var inventory_text := "N/D"
	if inventory != null:
		inventory_text = "madera %d | tablones %d" % [
			inventory.count_item(WOOD_ITEM.id), inventory.count_item(PLANK_ITEM.id)
		]

	var relationship_controller := _get_relationship_controller()
	var relationship_text := "N/D"
	if relationship_controller != null:
		relationship_text = str(relationship_controller.get_relationship(ALDREN_ID))

	var quest_controller := _get_quest_controller()
	var quest_text := "N/D"
	if quest_controller != null:
		var quest_status := quest_controller.get_status(TEST_QUEST_ID)
		var ready_text := " | lista" if quest_controller.is_ready(TEST_QUEST_ID) else ""
		quest_text = "%s%s" % [quest_status, ready_text]

	status.text = (
		"Bootstrap: %s\nDía %d — %02d:%02d\nFPS: %d\nInventario: %s\nAldren: %s\nQuest: %s"
		% [
			"OK" if GameManager.is_bootstrap_ready else "pendiente",
			TimeManager.day,
			TimeManager.hour,
			TimeManager.minute,
			Engine.get_frames_per_second(),
			inventory_text,
			relationship_text,
			quest_text,
		]
	)
