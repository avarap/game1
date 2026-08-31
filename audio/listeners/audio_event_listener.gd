extends Node

var _event_bus: Node
var _feedback_player: AudioStreamPlayer
var _funeral_stream: AudioStream = AudioLibrary.funeral_delivery()
var _cremate_stream: AudioStream = AudioLibrary.decision_cremate()
var _research_stream: AudioStream = AudioLibrary.decision_research()


func _ready() -> void:
	_feedback_player = AudioStreamPlayer.new()
	_feedback_player.name = "FeedbackPlayer"
	_feedback_player.bus = "SFX"
	_feedback_player.volume_db = -2.0
	add_child(_feedback_player)
	_connect_event_bus()


func _exit_tree() -> void:
	_disconnect_event_bus()


func _connect_event_bus() -> void:
	_event_bus = get_tree().root.get_node_or_null("EventBus")
	if _event_bus == null:
		return
	var funeral_listener := Callable(self, "_on_funeral_delivery_completed")
	var decision_listener := Callable(self, "_on_corpse_final_decision_completed")
	if (
		_event_bus.has_signal("funeral_delivery_completed")
		and not _event_bus.is_connected("funeral_delivery_completed", funeral_listener)
	):
		_event_bus.connect("funeral_delivery_completed", funeral_listener)
	if (
		_event_bus.has_signal("corpse_final_decision_completed")
		and not _event_bus.is_connected("corpse_final_decision_completed", decision_listener)
	):
		_event_bus.connect("corpse_final_decision_completed", decision_listener)


func _disconnect_event_bus() -> void:
	if _event_bus == null or not is_instance_valid(_event_bus):
		return
	var funeral_listener := Callable(self, "_on_funeral_delivery_completed")
	var decision_listener := Callable(self, "_on_corpse_final_decision_completed")
	if _event_bus.is_connected("funeral_delivery_completed", funeral_listener):
		_event_bus.disconnect("funeral_delivery_completed", funeral_listener)
	if _event_bus.is_connected("corpse_final_decision_completed", decision_listener):
		_event_bus.disconnect("corpse_final_decision_completed", decision_listener)


func _on_funeral_delivery_completed(
	_corpse_id: StringName, _logical_day: int, _reception_point: StringName
) -> void:
	_play_feedback(_funeral_stream)


func _on_corpse_final_decision_completed(
	_corpse_id: StringName,
	decision: StringName,
	_reward_red: int,
	_reward_green: int,
	_reward_blue: int
) -> void:
	var stream := _research_stream
	if decision == &"cremate":
		stream = _cremate_stream
	_play_feedback(stream)


func _play_feedback(stream: AudioStream) -> void:
	if _feedback_player == null:
		return
	_feedback_player.stream = stream
	_feedback_player.play()
