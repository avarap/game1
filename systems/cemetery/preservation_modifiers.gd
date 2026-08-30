class_name PreservationModifiers
extends Resource

const NEUTRAL_BP := 10000
const MINIMUM_BP := 1

@export_range(1, 10000, 1) var technology_bp: int = NEUTRAL_BP
@export_range(1, 10000, 1) var facility_bp: int = NEUTRAL_BP
@export_range(1, 10000, 1) var tool_bp: int = NEUTRAL_BP


func combined_basis_points() -> int:
	var combined := _normalized(technology_bp)
	combined = combined * _normalized(facility_bp) / NEUTRAL_BP
	combined = combined * _normalized(tool_bp) / NEUTRAL_BP
	return maxi(combined, MINIMUM_BP)


func snapshot() -> Dictionary:
	return {
		"technology_bp": _normalized(technology_bp),
		"facility_bp": _normalized(facility_bp),
		"tool_bp": _normalized(tool_bp),
	}


func duplicate_values() -> PreservationModifiers:
	var copy := PreservationModifiers.new()
	copy.technology_bp = _normalized(technology_bp)
	copy.facility_bp = _normalized(facility_bp)
	copy.tool_bp = _normalized(tool_bp)
	return copy


static func from_snapshot(data: Dictionary) -> PreservationModifiers:
	var modifiers := PreservationModifiers.new()
	modifiers.technology_bp = _normalized(int(data.get("technology_bp", NEUTRAL_BP)))
	modifiers.facility_bp = _normalized(int(data.get("facility_bp", NEUTRAL_BP)))
	modifiers.tool_bp = _normalized(int(data.get("tool_bp", NEUTRAL_BP)))
	return modifiers


static func _normalized(value: int) -> int:
	return clampi(value, MINIMUM_BP, NEUTRAL_BP)
