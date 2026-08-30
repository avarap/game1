class_name TestCorpsePreservation
extends RefCounted

const DAY_MINUTES := 24 * 60
const NEUTRAL_BP := 10000


static func run() -> Array[String]:
	var failures: Array[String] = []
	var neutral := _make_corpse()
	if not neutral.has_method("set_preservation_modifiers"):
		failures.append("CorpseState should accept typed preservation modifiers")
		return failures

	var modifiers_script := load("res://systems/cemetery/preservation_modifiers.gd")
	if modifiers_script == null:
		failures.append("PreservationModifiers script should exist")
		return failures

	var neutral_modifiers: RefCounted = modifiers_script.new()
	neutral.call("set_preservation_modifiers", neutral_modifiers)
	neutral.advance_decomposition(DAY_MINUTES)
	if neutral.decay_percent != 8:
		failures.append("Neutral preservation should keep the base decomposition rate")

	var technology_only := _make_corpse()
	var tech_modifiers: RefCounted = modifiers_script.new()
	tech_modifiers.set("technology_bp", 7500)
	technology_only.call("set_preservation_modifiers", tech_modifiers)
	technology_only.advance_decomposition(DAY_MINUTES)
	if technology_only.decay_percent >= neutral.decay_percent:
		failures.append("Preservation technology should reduce decomposition")

	var combined := _make_corpse()
	var combined_modifiers: RefCounted = modifiers_script.new()
	combined_modifiers.set("technology_bp", 8000)
	combined_modifiers.set("facility_bp", 7500)
	combined_modifiers.set("tool_bp", 9000)
	combined.call("set_preservation_modifiers", combined_modifiers)
	combined.advance_decomposition(DAY_MINUTES)
	if combined.decay_percent >= technology_only.decay_percent:
		failures.append("Combined preservation sources should compose multiplicatively")

	var no_rewind := _make_corpse()
	var fractional_modifiers: RefCounted = modifiers_script.new()
	fractional_modifiers.set("technology_bp", 3333)
	no_rewind.call("set_preservation_modifiers", fractional_modifiers)
	no_rewind.advance_decomposition(1)
	var decay_before := no_rewind.decay_percent
	var age_before := no_rewind.age_minutes
	var remainder_before := int(no_rewind.snapshot().get("preservation_remainder", 0))
	no_rewind.call("set_preservation_modifiers", combined_modifiers)
	var remainder_after := int(no_rewind.snapshot().get("preservation_remainder", 0))
	if no_rewind.decay_percent != decay_before or no_rewind.age_minutes != age_before:
		failures.append("Changing preservation should never rewind corpse state")
	if remainder_before <= 0 or remainder_after != remainder_before:
		failures.append("Changing preservation should preserve fractional decomposition progress")

	var one_jump := _make_corpse()
	var many_steps := _make_corpse()
	one_jump.call("set_preservation_modifiers", combined_modifiers)
	many_steps.call("set_preservation_modifiers", combined_modifiers)
	one_jump.advance_decomposition(80 * 60)
	for _hour in range(80):
		many_steps.advance_decomposition(60)
	if one_jump.decay_percent != many_steps.decay_percent:
		failures.append("Preserved decomposition should remain deterministic across time steps")

	var snapshot := one_jump.snapshot()
	var preservation: Dictionary = snapshot.get("preservation", {})
	if int(preservation.get("technology_bp", -1)) != 8000:
		failures.append("Corpse snapshot should persist technology preservation")
	if int(preservation.get("facility_bp", -1)) != 7500:
		failures.append("Corpse snapshot should persist facility preservation")
	if int(preservation.get("tool_bp", -1)) != 9000:
		failures.append("Corpse snapshot should persist tool preservation")

	var restored := CorpseState.from_snapshot(snapshot)
	if restored == null:
		failures.append("Preserved corpse snapshot should restore")
	elif restored.snapshot().get("preservation", {}) != preservation:
		failures.append("Preservation modifiers should survive corpse round trip")

	return failures


static func _make_corpse() -> CorpseState:
	var data := CorpseData.new()
	data.id = &"preservation_test"
	data.quality = 8
	data.burial_value = 4
	return CorpseState.new(data)
