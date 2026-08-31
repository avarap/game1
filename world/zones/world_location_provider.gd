class_name WorldLocationProvider
extends Node

const SAVE_KEY := &"world_location"
const FALLBACK_ZONE := &"cemetery"
const FALLBACK_MARKER := &"PlayerSpawn"
const SAFE_MARGIN := 16.0

@onready var zone_manager: ZoneManager = get_node("../ZoneManager") as ZoneManager
@onready var player: Node2D = get_node("../Player") as Node2D


func _enter_tree() -> void:
	add_to_group("save_provider")


func get_save_key() -> StringName:
	return SAVE_KEY


func get_save_data() -> Dictionary:
	return {
		"zone_id": String(zone_manager.get_active_zone_id()),
		"marker_id": String(zone_manager.get_active_marker_id()),
		"position": {"x": player.global_position.x, "y": player.global_position.y},
	}


func apply_save_data(data: Dictionary) -> void:
	var zone_id := StringName(str(data.get("zone_id", FALLBACK_ZONE)))
	var marker_id := StringName(str(data.get("marker_id", FALLBACK_MARKER)))
	if not zone_manager.travel_to(zone_id, marker_id):
		zone_manager.travel_to(FALLBACK_ZONE, FALLBACK_MARKER)
		return
	var position_value: Variant = data.get("position", {})
	if typeof(position_value) != TYPE_DICTIONARY:
		return
	var position_data := position_value as Dictionary
	var restored := Vector2(
		float(position_data.get("x", player.global_position.x)),
		float(position_data.get("y", player.global_position.y))
	)
	player.global_position = _clamp_to_active_bounds(restored)


func _clamp_to_active_bounds(position: Vector2) -> Vector2:
	var zone := zone_manager.get_active_zone()
	if zone == null or not zone.has_method("get_world_rect"):
		return position
	var value: Variant = zone.call("get_world_rect")
	if typeof(value) != TYPE_RECT2:
		return position
	var bounds := value as Rect2
	return Vector2(
		clampf(position.x, bounds.position.x + SAFE_MARGIN, bounds.end.x - SAFE_MARGIN),
		clampf(position.y, bounds.position.y + SAFE_MARGIN, bounds.end.y - SAFE_MARGIN)
	)
