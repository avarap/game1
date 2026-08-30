class_name DayNightController
extends CanvasModulate

var current_phase: StringName = &"night"
var _event_bus: Node
var _time_manager: Node


func _enter_tree() -> void:
	_event_bus = get_node_or_null("/root/EventBus")
	_time_manager = get_node_or_null("/root/TimeManager")
	if _event_bus != null and _event_bus.has_signal("time_changed"):
		var callback := Callable(self, "_on_time_changed")
		if not _event_bus.is_connected("time_changed", callback):
			_event_bus.connect("time_changed", callback)
	_apply_current_time()


func _ready() -> void:
	_apply_current_time()


func apply_time(hour: int, minute: int) -> void:
	color = DayNightMath.color_at(hour, minute)
	current_phase = DayNightMath.phase_at(hour, minute)


func _on_time_changed(hour: int, minute: int) -> void:
	apply_time(hour, minute)


func _apply_current_time() -> void:
	if _time_manager == null:
		_time_manager = get_node_or_null("/root/TimeManager")
	if _time_manager != null:
		apply_time(int(_time_manager.get("hour")), int(_time_manager.get("minute")))
