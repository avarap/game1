class_name ZoneTransition
extends Interactable

@export var target_zone_id: StringName
@export var target_marker_id: StringName


func _ready() -> void:
	prompt = "Travel"


func _on_interact(_actor: Node) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var managers := tree.get_nodes_in_group("zone_manager")
	if managers.is_empty():
		return
	var manager := managers[0]
	if manager.has_method("travel_to"):
		manager.call("travel_to", target_zone_id, target_marker_id)
