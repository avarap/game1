class_name DialogueInteractable
extends Interactable

@export var dialogue: DialogueData


func _on_interact(_actor: Node) -> void:
	if dialogue == null or not is_inside_tree():
		return
	var controller := get_tree().get_first_node_in_group("dialogue_controller")
	if controller != null and controller.has_method("start_dialogue"):
		controller.call("start_dialogue", dialogue)
