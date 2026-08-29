extends Node

const DAYS_PER_WEEK := 6

var day: int = 1
var hour: int = 6
var minute: int = 0

func add_minutes(amount: int) -> void:
    if amount <= 0:
        return

    var total := TimeMath.to_total_minutes(hour, minute) + amount
    var days_advanced := total / TimeMath.MINUTES_PER_DAY
    var normalized := TimeMath.normalize_total_minutes(total)

    hour = normalized.hour
    minute = normalized.minute

    if days_advanced > 0:
        day += days_advanced
        EventBus.day_changed.emit(day)

    EventBus.time_changed.emit(hour, minute)

func set_time(new_hour: int, new_minute: int = 0) -> void:
    var normalized := TimeMath.normalize_total_minutes(TimeMath.to_total_minutes(new_hour, new_minute))
    hour = normalized.hour
    minute = normalized.minute
    EventBus.time_changed.emit(hour, minute)
