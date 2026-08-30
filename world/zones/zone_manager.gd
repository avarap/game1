class_name ZoneManager
extends Node

const INITIAL_ZONE := &"cemetery"
const INITIAL_MARKER := &"PlayerSpawn"
const ZONE_SCENES := {
	&"cemetery": "res://world/maps/cemetery/cemetery_map.tscn",
	&"forest": "res://world/maps/forest/forest_map.tscn",
	&"village": "res://world/maps/village/village_map.tscn",
	&"home_interior": "res://world/maps/interiors/home_workshop.tscn",
	&"village_interior": "res://world/maps/interiors/village_building.tscn",
	&"mine": "res://world/maps/mine/mine_map.tscn",
}

var _active_zone_id: StringName = &""
var _active_zone: Node2D

@onready var zone_container: Node = get_node("../ZoneContainer")
@onready var player: Node2D = get_node("../Player") as Node2D
@onready var aldren: NPCController = get_node("../BrotherAldren") as NPCController
@onready var trade_point: Area2D = get_node("../TradePoint") as Area2D
@onready var camera: Camera2D = get_node("../Player/Camera2D") as Camera2D


func _ready() -> void:
	add_to_group("zone_manager")
	travel_to(INITIAL_ZONE, INITIAL_MARKER)


func get_active_zone_id() -> StringName:
	return _active_zone_id


func get_active_zone() -> Node2D:
	return _active_zone


func travel_to(zone_id: StringName, marker_id: StringName) -> bool:
	var scene_path := String(ZONE_SCENES.get(zone_id, ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		return false
	var packed := load(scene_path) as PackedScene
	if packed == null:
		return false
	var candidate := packed.instantiate() as Node2D
	if candidate == null:
		return false
	var marker := _resolve_marker(candidate, marker_id)
	if marker == null:
		candidate.free()
		return false

	if _active_zone != null and is_instance_valid(_active_zone):
		_active_zone.free()
	zone_container.add_child(candidate)
	_active_zone = candidate
	_active_zone_id = zone_id
	player.global_position = marker.global_position
	_configure_persistent_shell(zone_id, candidate)
	return true


func _resolve_marker(root: Node, marker_id: StringName) -> Node2D:
	var marker_path := NodePath(String(marker_id))
	if String(marker_id).contains("/"):
		return root.get_node_or_null(marker_path) as Node2D
	return root.find_child(String(marker_id), true, false) as Node2D


func _configure_persistent_shell(zone_id: StringName, zone: Node2D) -> void:
	_configure_aldren(zone_id, zone)
	_configure_trade_point(zone_id, zone)
	_configure_camera(zone)


func _configure_aldren(zone_id: StringName, zone: Node2D) -> void:
	if aldren == null:
		return
	var is_cemetery := zone_id == &"cemetery"
	aldren.visible = is_cemetery
	aldren.collision_layer = 4 if is_cemetery else 0
	aldren.process_mode = Node.PROCESS_MODE_INHERIT if is_cemetery else Node.PROCESS_MODE_DISABLED
	if not is_cemetery:
		return
	var marker := _resolve_marker(zone, &"AldrenSpawn")
	if marker != null:
		aldren.global_position = marker.global_position
	aldren.call_deferred("apply_current_schedule")


func _configure_trade_point(zone_id: StringName, zone: Node2D) -> void:
	if trade_point == null:
		return
	var is_village := zone_id == &"village"
	trade_point.visible = is_village
	trade_point.collision_layer = 2 if is_village else 0
	if not is_village:
		return
	var marker := _resolve_marker(zone, &"MerchantSpot")
	if marker != null:
		trade_point.global_position = marker.global_position


func _configure_camera(zone: Node2D) -> void:
	if camera == null or not zone.has_method("get_world_rect"):
		return
	var value: Variant = zone.call("get_world_rect")
	if typeof(value) != TYPE_RECT2:
		return
	var bounds := value as Rect2
	camera.limit_left = int(bounds.position.x)
	camera.limit_top = int(bounds.position.y)
	camera.limit_right = int(bounds.end.x)
	camera.limit_bottom = int(bounds.end.y)
