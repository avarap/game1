class_name GraveRecord
extends RefCounted

var corpse: CorpseState
var has_headstone: bool = false
var has_fence: bool = false
var decoration_count: int = 0


func _init(corpse_state: CorpseState = null) -> void:
	corpse = corpse_state


func contribution(config: CemeteryRatingConfig) -> int:
	var total: int = 0
	if corpse != null and corpse.data != null:
		total += corpse.data.burial_value
	if config == null:
		return total
	if has_headstone:
		total += config.headstone_points
	if has_fence:
		total += config.fence_points
	total += maxi(decoration_count, 0) * config.decoration_points
	return total


func snapshot(config: CemeteryRatingConfig) -> Dictionary:
	return {
		"corpse": corpse.snapshot() if corpse != null else {},
		"has_headstone": has_headstone,
		"has_fence": has_fence,
		"decoration_count": decoration_count,
		"rating": contribution(config),
	}


static func from_snapshot(snapshot_data: Dictionary) -> GraveRecord:
	var corpse_data: Dictionary = snapshot_data.get("corpse", {})
	var corpse_state := CorpseState.from_snapshot(corpse_data)
	if corpse_state == null:
		return null

	var grave := GraveRecord.new(corpse_state)
	grave.has_headstone = bool(snapshot_data.get("has_headstone", false))
	grave.has_fence = bool(snapshot_data.get("has_fence", false))
	grave.decoration_count = maxi(int(snapshot_data.get("decoration_count", 0)), 0)
	return grave
