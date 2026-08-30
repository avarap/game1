class_name RelationshipService
extends RefCounted

const MIN_VALUE := 0
const MAX_VALUE := 100
const CONTEXT_KEY := &"relationships"

var _values: Dictionary = {}


func register(data: RelationshipData) -> bool:
	if data == null or not data.is_valid():
		return false
	if not _values.has(data.id):
		_values[data.id] = data.default_value
	return true


func has_relationship(id: StringName) -> bool:
	return _values.has(id)


func get_value(id: StringName) -> int:
	return int(_values.get(id, MIN_VALUE))


func set_value(id: StringName, value: int) -> bool:
	if not _values.has(id):
		return false
	_values[id] = clampi(value, MIN_VALUE, MAX_VALUE)
	return true


func change_value(id: StringName, delta: int) -> bool:
	return set_value(id, get_value(id) + delta)


func build_dialogue_context() -> Dictionary:
	return {CONTEXT_KEY: _values.duplicate(true)}


func snapshot() -> Dictionary:
	return {"values": _values.duplicate(true)}


func apply_snapshot(data: Dictionary) -> void:
	var saved_values: Dictionary = data.get("values", {})
	for saved_key in saved_values:
		var id := StringName(str(saved_key))
		if not _values.has(id):
			continue
		_values[id] = clampi(int(saved_values[saved_key]), MIN_VALUE, MAX_VALUE)
