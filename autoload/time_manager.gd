extends Node

const DAYS_PER_WEEK := 6
const DEFAULT_WAKE_HOUR := 6
const DEFAULT_WAKE_MINUTE := 0

var day: int = 1
var hour: int = 6
var minute: int = 0


func add_minutes(amount: int) -> void:
	if amount <= 0:
		return

	var total := TimeMath.to_total_minutes(hour, minute) + amount
	var days_advanced: int = total / TimeMath.MINUTES_PER_DAY
	var normalized := TimeMath.normalize_total_minutes(total)

	hour = normalized.hour
	minute = normalized.minute

	if days_advanced > 0:
		day += days_advanced
		EventBus.day_changed.emit(day)

	EventBus.time_changed.emit(hour, minute)


func set_time(new_hour: int, new_minute: int = 0) -> void:
	var normalized := TimeMath.normalize_total_minutes(
		TimeMath.to_total_minutes(new_hour, new_minute)
	)
	hour = normalized.hour
	minute = normalized.minute
	EventBus.time_changed.emit(hour, minute)


func set_day(new_day: int) -> void:
	var normalized_day := maxi(new_day, 1)
	if normalized_day == day:
		return
	day = normalized_day
	EventBus.day_changed.emit(day)


func advance_to_next_day(
	wake_hour: int = DEFAULT_WAKE_HOUR, wake_minute: int = DEFAULT_WAKE_MINUTE
) -> void:
	day += 1
	var normalized := TimeMath.normalize_total_minutes(
		TimeMath.to_total_minutes(wake_hour, wake_minute)
	)
	hour = normalized.hour
	minute = normalized.minute
	EventBus.day_changed.emit(day)
	EventBus.time_changed.emit(hour, minute)


func get_weekday_index() -> int:
	return posmod(day - 1, DAYS_PER_WEEK)


func get_weekday_name() -> String:
	match get_weekday_index():
		0:
			return "Día del Sol"
		1:
			return "Día de la Luna"
		2:
			return "Día del Hierro"
		3:
			return "Día del Bosque"
		4:
			return "Día del Espíritu"
		5:
			return "Día del Comercio"
		_:
			return ""


func snapshot() -> Dictionary:
	return {
		"day": day,
		"hour": hour,
		"minute": minute,
	}


func apply_snapshot(data: Dictionary) -> void:
	day = maxi(int(data.get("day", 1)), 1)
	var normalized := TimeMath.normalize_total_minutes(
		TimeMath.to_total_minutes(int(data.get("hour", 6)), int(data.get("minute", 0)))
	)
	hour = normalized.hour
	minute = normalized.minute
	EventBus.day_changed.emit(day)
	EventBus.time_changed.emit(hour, minute)
