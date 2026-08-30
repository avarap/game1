class_name DialogueInteractable
extends Interactable

@export var dialogue: DialogueData


func _on_interact(actor: Node) -> void:
	if dialogue == null or not is_inside_tree():
		return
	var controller := get_tree().get_first_node_in_group("dialogue_controller")
	if controller == null or not controller.has_method("start_dialogue"):
		return
	controller.call("start_dialogue", dialogue, _build_context(actor))


func _build_context(actor: Node) -> Dictionary:
	var context: Dictionary = {
		&"inventory": _build_inventory_context(actor),
		&"quest_flags": {},
		&"flags": {},
	}
	_merge_controller_context(context, "relationship_controller")
	_merge_controller_context(context, "quest_controller")
	var time_manager := get_node_or_null("/root/TimeManager")
	if time_manager != null:
		context[&"hour"] = int(time_manager.get("hour"))
		context[&"minute"] = int(time_manager.get("minute"))
	return context


func _merge_controller_context(context: Dictionary, group_name: String) -> void:
	var source := get_tree().get_first_node_in_group(group_name)
	if source == null or not source.has_method("get_dialogue_context"):
		return
	var source_context: Variant = source.call("get_dialogue_context")
	if typeof(source_context) != TYPE_DICTIONARY:
		return
	context.merge(source_context as Dictionary, true)


func _build_inventory_context(actor: Node) -> Dictionary:
	var counts: Dictionary = {}
	if actor == null or not actor.has_method("get_inventory_component"):
		return counts
	var inventory: Variant = actor.call("get_inventory_component")
	if inventory == null or not inventory.has_method("count_item"):
		return counts
	for item_id in _required_item_ids():
		counts[item_id] = int(inventory.call("count_item", item_id))
	return counts


func _required_item_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for node in dialogue.nodes:
		if node == null:
			continue
		for option in node.options:
			if option == null:
				continue
			for condition in option.conditions:
				if (
					condition != null
					and condition.condition_type == DialogueConditionData.ConditionType.HAS_ITEM
					and not condition.item_id.is_empty()
					and not result.has(condition.item_id)
				):
					result.append(condition.item_id)
	return result
