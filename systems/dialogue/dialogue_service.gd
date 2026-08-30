class_name DialogueService
extends RefCounted

var dialogue: DialogueData
var current_node: DialogueNodeData
var context: Dictionary = {}


func start(dialogue_data: DialogueData, dialogue_context: Dictionary = {}) -> bool:
	clear()
	if dialogue_data == null or not dialogue_data.is_valid():
		return false
	dialogue = dialogue_data
	context = dialogue_context.duplicate(true)
	current_node = dialogue.find_node(dialogue.start_node_id)
	return current_node != null


func get_available_options() -> Array[DialogueOptionData]:
	if current_node == null:
		return []
	return current_node.get_available_options(context)


func choose_option(option_id: StringName) -> bool:
	for option in get_available_options():
		if option.id == option_id:
			return _go_to(option.next_node_id)
	return false


func advance() -> bool:
	if current_node == null:
		return false
	return _go_to(current_node.next_node_id)


func is_active() -> bool:
	return dialogue != null and current_node != null


func clear() -> void:
	dialogue = null
	current_node = null
	context.clear()


func _go_to(node_id: StringName) -> bool:
	if node_id.is_empty():
		clear()
		return true
	if dialogue == null:
		return false
	var next_node := dialogue.find_node(node_id)
	if next_node == null:
		return false
	current_node = next_node
	return true
