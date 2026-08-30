class_name CorpseState
extends RefCounted

var data: CorpseData
var current_decay: float = 0.0
var decay_rate_per_hour: float = 0.01
var current_preparation_level: int = 0


func _init(corpse_data: CorpseData, rate_per_hour: float = 0.01) -> void:
	data = corpse_data
	decay_rate_per_hour = maxf(rate_per_hour, 0.0)
	current_decay = clampf(data.decay if data != null else 0.0, 0.0, 1.0)
	current_preparation_level = maxi(data.preparation_level if data != null else 0, 0)


func advance_decay(hours: float) -> float:
	if hours <= 0.0 or current_decay >= 1.0:
		return current_decay
	current_decay = clampf(current_decay + decay_rate_per_hour * hours, 0.0, 1.0)
	return current_decay


func prepare(amount: int = 1) -> int:
	current_preparation_level += maxi(amount, 0)
	return current_preparation_level


func is_fully_decayed() -> bool:
	return current_decay >= 1.0


func snapshot() -> Dictionary:
	return {
		"corpse_id": String(data.id) if data != null else "",
		"quality": data.quality if data != null else 0,
		"current_decay": current_decay,
		"decay_rate_per_hour": decay_rate_per_hour,
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
	corpse_data.decay = clampf(float(snapshot_data.get("current_decay", 0.0)), 0.0, 1.0)
	corpse_data.preparation_level = 0
	corpse_data.burial_value = int(snapshot_data.get("burial_value", 0))

	var state := CorpseState.new(corpse_data, float(snapshot_data.get("decay_rate_per_hour", 0.01)))
	state.current_decay = corpse_data.decay
	state.current_preparation_level = maxi(int(snapshot_data.get("preparation_level", 0)), 0)
	return state
