class_name DialogueInteractable
extends Interactable

@export var dialogue: DialogueData


func _on_interact(_actor: Node) -> void:
	if dialogue == null or not is_inside_tree():
		return
	var controller := get_tree().get_first_node_in_group("dialogue_controller")
	if controller == null or not controller.has_method("start_dialogue"):
		return
	var context: Dictionary = {}
	var relationship_controller := get_tree().get_first_node_in_group("relationship_controller")
	if relationship_controller != null and relationship_controller.has_method("get_dialogue_context"):
		context = relationship_controller.call("get_dialogue_context")
	controller.call("start_dialogue", dialogue, context)
