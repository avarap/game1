class_name CorpseState
extends RefCounted

var data: CorpseData
var current_decay: float = 0.0
var decay_rate_per_hour: float = 0.01

func _init(corpse_data: CorpseData, rate_per_hour: float = 0.01) -> void:
    data = corpse_data
    decay_rate_per_hour = maxf(rate_per_hour, 0.0)
    current_decay = clampf(data.decay if data != null else 0.0, 0.0, 1.0)

func advance_decay(hours: float) -> float:
    if hours <= 0.0 or current_decay >= 1.0:
        return current_decay
    current_decay = clampf(current_decay + decay_rate_per_hour * hours, 0.0, 1.0)
    return current_decay

func is_fully_decayed() -> bool:
    return current_decay >= 1.0

func snapshot() -> Dictionary:
    return {
        "corpse_id": String(data.id) if data != null else "",
        "current_decay": current_decay,
        "decay_rate_per_hour": decay_rate_per_hour,
        "preparation_level": data.preparation_level if data != null else 0,
        "burial_value": data.burial_value if data != null else 0,
    }
