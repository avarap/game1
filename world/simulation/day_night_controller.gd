class_name DayNightController
extends CanvasModulate

var current_phase: StringName = &"night"


func _ready() -> void:
	var tree := get_tree()
	var event_bus := tree.root.get_node_or_null("EventBus")
	if event_bus != null and event_bus.has_signal("time_changed"):
		event_bus.connect(&"time_changed", Callable(self, "_on_time_changed"))

	var time_manager := tree.root.get_node_or_null("TimeManager")
	if time_manager != null:
		apply_time(int(time_manager.get("hour")), int(time_manager.get("minute")))


func apply_time(hour: int, minute: int) -> void:
	color = DayNightMath.color_at(hour, minute)
	current_phase = DayNightMath.phase_at(hour, minute)


func _on_time_changed(hour: int, minute: int) -> void:
	apply_time(hour, minute)
