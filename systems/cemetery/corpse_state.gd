class_name CorpseState
extends RefCounted

const MINUTES_PER_DAY := 24 * 60
const DECAY_UNITS_PER_PERCENT := MINUTES_PER_DAY
const STATE_FRESH := &"fresh"
const STATE_FADING := &"fading"
const STATE_DECOMPOSED := &"decomposed"
const STATE_ROTTEN := &"rotten"

const FIRST_DAY_RATE := 8
const SECOND_DAY_RATE := 14
const THIRD_DAY_RATE := 22
const LATE_RATE := 32

var data: CorpseData
var decay_percent: int = 0
var age_minutes: int = 0
var current_preparation_level: int = 0
var _decay_units: int = 0


func _init(corpse_data: CorpseData) -> void:
	data = corpse_data
	decay_percent = clampi(data.decay_percent if data != null else 0, 0, 100)
	_decay_units = decay_percent * DECAY_UNITS_PER_PERCENT
	current_preparation_level = maxi(data.preparation_level if data != null else 0, 0)


func advance_decomposition(minutes: int) -> int:
	var elapsed := maxi(minutes, 0)
	if elapsed == 0:
		return decay_percent

	var start_age := age_minutes
	var end_age := age_minutes + elapsed
	_decay_units += _decay_units_between(start_age, end_age)
	age_minutes = end_age
	decay_percent = clampi(_decay_units / DECAY_UNITS_PER_PERCENT, 0, 100)
	return decay_percent


func get_condition_state() -> StringName:
	if decay_percent < 25:
		return STATE_FRESH
	if decay_percent < 50:
		return STATE_FADING
	if decay_percent < 75:
		return STATE_DECOMPOSED
	return STATE_ROTTEN


func get_effective_quality() -> int:
	var penalty := 0
	match get_condition_state():
		STATE_FADING:
			penalty = 1
		STATE_DECOMPOSED:
			penalty = 2
		STATE_ROTTEN:
			penalty = 3
	return maxi((data.quality if data != null else 0) - penalty, 0)


func prepare(amount: int = 1) -> int:
	current_preparation_level += maxi(amount, 0)
	return current_preparation_level


func is_fully_decayed() -> bool:
	return decay_percent >= 100


func snapshot() -> Dictionary:
	return {
		"corpse_id": String(data.id) if data != null else "",
		"quality": data.quality if data != null else 0,
		"decay_percent": decay_percent,
		"decay_units": _decay_units,
		"age_minutes": age_minutes,
		"preparation_level": current_preparation_level,
		"burial_value": data.burial_value if data != null else 0,
	}


static func from_snapshot(snapshot_data: Dictionary) -> CorpseState:
	var corpse_id := StringName(str(snapshot_data.get("corpse_id", "")))
	if corpse_id == &"":
		return null

	var corpse_data := CorpseData.new()
	corpse_data.id = corpse_id
	corpse_data.quality = int(snapshot_data.get("quality", 0))
	corpse_data.decay_percent = clampi(int(snapshot_data.get("decay_percent", 0)), 0, 100)
	corpse_data.preparation_level = 0
	corpse_data.burial_value = int(snapshot_data.get("burial_value", 0))

	var state := CorpseState.new(corpse_data)
	state.age_minutes = maxi(int(snapshot_data.get("age_minutes", 0)), 0)
	var default_units := state.decay_percent * DECAY_UNITS_PER_PERCENT
	state._decay_units = maxi(int(snapshot_data.get("decay_units", default_units)), 0)
	state.decay_percent = clampi(state._decay_units / DECAY_UNITS_PER_PERCENT, 0, 100)
	state.current_preparation_level = maxi(int(snapshot_data.get("preparation_level", 0)), 0)
	return state


static func _decay_units_between(start_minute: int, end_minute: int) -> int:
	if end_minute <= start_minute:
		return 0

	var day_one_end := MINUTES_PER_DAY
	var day_two_end := 2 * MINUTES_PER_DAY
	var day_three_end := 3 * MINUTES_PER_DAY
	var total := 0
	total += _band_units(start_minute, end_minute, 0, day_one_end, FIRST_DAY_RATE)
	total += _band_units(start_minute, end_minute, day_one_end, day_two_end, SECOND_DAY_RATE)
	total += _band_units(start_minute, end_minute, day_two_end, day_three_end, THIRD_DAY_RATE)
	var late_start := maxi(start_minute, day_three_end)
	if end_minute > late_start:
		total += (end_minute - late_start) * LATE_RATE
	return total


static func _band_units(
	start_minute: int, end_minute: int, band_start: int, band_end: int, rate: int
) -> int:
	var overlap_start := maxi(start_minute, band_start)
	var overlap_end := mini(end_minute, band_end)
	if overlap_end <= overlap_start:
		return 0
	return (overlap_end - overlap_start) * rate
