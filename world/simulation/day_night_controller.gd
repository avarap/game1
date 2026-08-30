class_name DayNightController
extends CanvasModulate

var current_phase: StringName = &"night"


func _ready() -> void:
	EventBus.time_changed.connect(_on_time_changed)
	apply_time(TimeManager.hour, TimeManager.minute)


func apply_time(hour: int, minute: int) -> void:
	color = DayNightMath.color_at(hour, minute)
	current_phase = DayNightMath.phase_at(hour, minute)


func _on_time_changed(hour: int, minute: int) -> void:
	apply_time(hour, minute)
