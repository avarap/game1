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
const ROUTES := {
	&"cemetery":
	[
		{
			&"source": &"ForestExit",
			&"zone": &"forest",
			&"marker": &"CemeteryEntrance",
		},
		{
			&"source": &"VillageExit",
			&"zone": &"village",
			&"marker": &"Entrance",
		},
		{
			&"source": &"PlayerSpawn",
			&"zone": &"home_interior",
			&"marker": &"entry_main",
		},
		{
			&"source": &"FutureExpansion",
			&"zone": &"mine",
			&"marker": &"Entrance",
		},
	],
	&"forest":
	[
		{
			&"source": &"CemeteryExit",
			&"zone": &"cemetery",
			&"marker": &"ForestExit",
		},
	],
	&"village":
	[
		{
			&"source": &"Entrance",
			&"zone": &"cemetery",
			&"marker": &"VillageExit",
		},
		{
			&"source": &"InteriorAccess/Workshop",
			&"zone": &"village_interior",
			&"marker": &"entry_main",
		},
	],
	&"home_interior":
	[
		{
			&"source": &"EntryMarkers/exit_main",
			&"zone": &"cemetery",
			&"marker": &"PlayerSpawn",
		},
	],
	&"village_interior":
	[
		{
			&"source": &"EntryMarkers/exit_main",
			&"zone": &"village",
			&"marker": &"InteriorAccess/Workshop",
		},
	],
	&"mine":
	[
		{
			&"source": &"Exit",
			&"zone": &"cemetery",
			&"marker": &"FutureExpansion",
		},
	],
}

var _active_zone_id: StringName = &""
var _active_zone: Node2D
var _active_marker_id: StringName = &""

@onready var zone_container: Node = get_node("../ZoneContainer")
@onready var transition_container: Node2D = get_node("../TransitionContainer") as Node2D
@onready var player: Node2D = get_node("../Player") as Node2D
@onready var aldren: NPCController = get_node("../BrotherAldren") as NPCController
@onready var trade_point: Area2D = get_node("../TradePoint") as Area2D
@onready var camera: Camera2D = get_node("../Player/Camera2D") as Camera2D


func _ready() -> void:
	add_to_group("zone_manager")
	travel_to(INITIAL_ZONE, INITIAL_MARKER)


func get_active_zone_id() -> StringName:
	return _active_zone_id


func get_active_marker_id() -> StringName:
	return _active_marker_id


func get_active_zone() -> Node2D:
	return _active_zone


func travel_to(
	zone_id: StringName, marker_id: StringName, refresh_persistent_actors: bool = true
) -> bool:
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
	_active_marker_id = marker_id
	player.global_position = marker.global_position
	_configure_persistent_shell(zone_id, candidate, refresh_persistent_actors)
	_build_transitions(zone_id, candidate)
	return true


func _resolve_marker(root: Node, marker_id: StringName) -> Node2D:
	var marker_path := NodePath(String(marker_id))
	if String(marker_id).contains("/"):
		return root.get_node_or_null(marker_path) as Node2D
	return root.find_child(String(marker_id), true, false) as Node2D


func _configure_persistent_shell(
	zone_id: StringName, zone: Node2D, refresh_persistent_actors: bool
) -> void:
	_configure_aldren(zone_id, refresh_persistent_actors)
	_configure_trade_point(zone_id, zone)
	_configure_camera(zone)


func _configure_aldren(zone_id: StringName, refresh_persistent_actor: bool) -> void:
	if aldren == null:
		return
	var is_cemetery := zone_id == &"cemetery"
	aldren.visible = is_cemetery
	aldren.collision_layer = 4 if is_cemetery else 0
	aldren.process_mode = (Node.PROCESS_MODE_INHERIT if is_cemetery else Node.PROCESS_MODE_DISABLED)
	if is_cemetery and refresh_persistent_actor:
		aldren.apply_current_schedule()


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


func _build_transitions(zone_id: StringName, zone: Node2D) -> void:
	_clear_transitions()
	var routes: Array = ROUTES.get(zone_id, [])
	for route in routes:
		var source_id := StringName(route.get(&"source", &""))
		var source := _resolve_marker(zone, source_id)
		if source == null:
			continue
		var transition := ZoneTransition.new()
		transition.name = "Travel_%s" % String(source_id).replace("/", "_")
		transition.target_zone_id = StringName(route.get(&"zone", &""))
		transition.target_marker_id = StringName(route.get(&"marker", &""))
		transition.position = source.global_position
		transition.collision_layer = 2
		transition.collision_mask = 0
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = Vector2(48, 48)
		collision.shape = shape
		transition.add_child(collision)
		transition_container.add_child(transition)


func _clear_transitions() -> void:
	for child in transition_container.get_children():
		transition_container.remove_child(child)
		child.queue_free()
