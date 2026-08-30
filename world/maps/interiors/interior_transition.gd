class_name InteriorTransition
extends RefCounted

const ENTRY_MARKERS := NodePath("EntryMarkers")


static func move_body_to_marker(body: Node2D, target_root: Node, marker_id: StringName) -> bool:
	if body == null or not is_instance_valid(body) or target_root == null:
		return false
	var entries := target_root.get_node_or_null(ENTRY_MARKERS)
	if entries == null:
		return false
	var marker := entries.get_node_or_null(NodePath(String(marker_id))) as Node2D
	if marker == null:
		return false
	body.global_position = marker.global_position
	return true
