class_name TimeMath
extends RefCounted

const MINUTES_PER_HOUR := 60
const HOURS_PER_DAY := 24
const MINUTES_PER_DAY := MINUTES_PER_HOUR * HOURS_PER_DAY


static func normalize_total_minutes(total_minutes: int) -> Dictionary:
	var normalized := posmod(total_minutes, MINUTES_PER_DAY)
	return {"hour": normalized / MINUTES_PER_HOUR, "minute": normalized % MINUTES_PER_HOUR}


static func to_total_minutes(hour: int, minute: int) -> int:
	return hour * MINUTES_PER_HOUR + minute
