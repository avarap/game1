class_name ZoneManager
extends Node

const INITIAL_ZONE := &"cemetery"
const INITIAL_MARKER := &"PlayerSpawn"
const ZONE_SCENES := {
	&"cemetery": "res://world/maps/cemetery/cemetery_map.tscn",
	&"forest": "res://world/maps/forest/forest_map.tscn",
}

@onready var zone_container: Node = get_node("../ZoneContainer")
@onready var player: Node2D = get_node("../Player") as Node2D

var _active_zone_id: StringName = &""
var _active_zone: Node2D


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
	var marker := candidate.find_child(String(marker_id), true, false) as Node2D
	if marker == null:
		candidate.free()
		return false

	if _active_zone != null and is_instance_valid(_active_zone):
		_active_zone.free()
	zone_container.add_child(candidate)
	_active_zone = candidate
	_active_zone_id = zone_id
	player.global_position = marker.global_position
	return true
