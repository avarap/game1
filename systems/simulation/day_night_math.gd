class_name DayNightMath
extends RefCounted

const MINUTES_PER_DAY := 1440
const DAWN_MINUTE := 6 * 60
const NOON_MINUTE := 12 * 60
const DUSK_MINUTE := 18 * 60
const NIGHT_MINUTE := 22 * 60

const DAWN_COLOR: Color = Color(0.82, 0.72, 0.62, 1.0)
const NOON_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)
const DUSK_COLOR: Color = Color(0.78, 0.56, 0.48, 1.0)
const NIGHT_COLOR: Color = Color(0.32, 0.36, 0.52, 1.0)


static func color_at(hour: int, minute: int) -> Color:
	var total := _normalized_minutes(hour, minute)
	var factor: float
	if total < DAWN_MINUTE:
		var dawn_next := DAWN_MINUTE + MINUTES_PER_DAY
		factor = _segment_factor(total + MINUTES_PER_DAY, NIGHT_MINUTE, dawn_next)
		return NIGHT_COLOR.lerp(DAWN_COLOR, factor)
	if total < NOON_MINUTE:
		factor = _segment_factor(total, DAWN_MINUTE, NOON_MINUTE)
		return DAWN_COLOR.lerp(NOON_COLOR, factor)
	if total < DUSK_MINUTE:
		factor = _segment_factor(total, NOON_MINUTE, DUSK_MINUTE)
		return NOON_COLOR.lerp(DUSK_COLOR, factor)
	if total < NIGHT_MINUTE:
		factor = _segment_factor(total, DUSK_MINUTE, NIGHT_MINUTE)
		return DUSK_COLOR.lerp(NIGHT_COLOR, factor)
	var dawn_next := DAWN_MINUTE + MINUTES_PER_DAY
	factor = _segment_factor(total, NIGHT_MINUTE, dawn_next)
	return NIGHT_COLOR.lerp(DAWN_COLOR, factor)


static func phase_at(hour: int, minute: int) -> StringName:
	var total := _normalized_minutes(hour, minute)
	if total >= DAWN_MINUTE and total < NOON_MINUTE:
		return &"dawn"
	if total >= NOON_MINUTE and total < DUSK_MINUTE:
		return &"day"
	if total >= DUSK_MINUTE and total < NIGHT_MINUTE:
		return &"dusk"
	return &"night"


static func _normalized_minutes(hour: int, minute: int) -> int:
	return posmod((hour * 60) + minute, MINUTES_PER_DAY)


static func _segment_factor(value: int, start_value: int, end_value: int) -> float:
	if end_value <= start_value:
		return 0.0
	return clampf(float(value - start_value) / float(end_value - start_value), 0.0, 1.0)
