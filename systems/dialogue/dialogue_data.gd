class_name DialogueData
extends Resource

@export var id: StringName
@export var start_node_id: StringName
@export var nodes: Array[DialogueNodeData] = []


func find_node(node_id: StringName) -> DialogueNodeData:
	for node in nodes:
		if node != null and node.id == node_id:
			return node
	return null


func is_valid() -> bool:
	if id.is_empty() or start_node_id.is_empty() or nodes.is_empty():
		return false
	var seen_ids: Dictionary = {}
	for node in nodes:
		if node == null or not node.is_valid() or seen_ids.has(node.id):
			return false
		seen_ids[node.id] = true
	return find_node(start_node_id) != null
