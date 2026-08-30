class_name ScheduleEntryData
extends Resource

const ALL_WEEKDAYS_MASK := 0b111111

@export_flags(
	"Día del Sol",
	"Día de la Luna",
	"Día del Hierro",
	"Día del Bosque",
	"Día del Espíritu",
	"Día del Comercio"
)
var weekday_mask: int = ALL_WEEKDAYS_MASK
@export_range(0, 23, 1) var start_hour: int = 6
@export_range(0, 59, 1) var start_minute: int = 0
@export_range(0, 23, 1) var end_hour: int = 8
@export_range(0, 59, 1) var end_minute: int = 0
@export var activity_state: StringName = NPCStateMachine.IDLE
@export var target_position: Vector2 = Vector2.ZERO


func matches(weekday_index: int, hour: int, minute: int) -> bool:
	if weekday_index < 0 or weekday_index >= 6:
		return false
	if (weekday_mask & (1 << weekday_index)) == 0:
		return false

	var current := posmod(TimeMath.to_total_minutes(hour, minute), TimeMath.MINUTES_PER_DAY)
	var start := TimeMath.to_total_minutes(start_hour, start_minute)
	var end := TimeMath.to_total_minutes(end_hour, end_minute)
	if start == end:
		return true
	if start < end:
		return current >= start and current < end
	return current >= start or current < end


func is_valid() -> bool:
	return weekday_mask > 0 and NPCStateMachine.is_activity_state(activity_state)
