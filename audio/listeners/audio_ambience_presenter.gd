extends Node

const INTERIOR_ZONES := [&"home_interior", &"village_interior"]

var _ambience_player: AudioStreamPlayer
var _active_zone_id: StringName = &""
var _cemetery_stream: AudioStream = AudioLibrary.cemetery_ambience()
var _interior_stream: AudioStream = AudioLibrary.interior_ambience()


func _ready() -> void:
	_ambience_player = AudioStreamPlayer.new()
	_ambience_player.name = "AmbiencePlayer"
	_ambience_player.bus = "Ambience"
	_ambience_player.volume_db = -2.0
	add_child(_ambience_player)
	apply_zone(&"cemetery")


func _process(_delta: float) -> void:
	var zone_manager := get_tree().get_first_node_in_group("zone_manager")
	if zone_manager == null or not zone_manager.has_method("get_active_zone_id"):
		return
	var zone_value: Variant = zone_manager.call("get_active_zone_id")
	apply_zone(StringName(str(zone_value)))


func apply_zone(zone_id: StringName) -> void:
	if _ambience_player == null:
		return
	if zone_id == _active_zone_id and _ambience_player.stream != null:
		return
	_active_zone_id = zone_id
	var stream := _interior_stream if zone_id in INTERIOR_ZONES else _cemetery_stream
	if _ambience_player.stream == stream and _ambience_player.playing:
		return
	_ambience_player.stream = stream
	_ambience_player.play()
