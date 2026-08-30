class_name TestRelationships
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_service(failures)
	_test_snapshot_round_trip(failures)
	_test_dialogue_unlock(failures)
	return failures


static func _test_service(failures: Array[String]) -> void:
	var data := RelationshipData.new()
	data.id = &"brother_aldren"
	data.default_value = 5
	var service := RelationshipService.new()
	if not service.register(data):
		failures.append("RelationshipService should register valid relationship data")
		return
	if service.get_value(&"brother_aldren") != 5:
		failures.append("RelationshipService should expose the configured default value")
	service.change_value(&"brother_aldren", 200)
	if service.get_value(&"brother_aldren") != 100:
		failures.append("Relationship values should clamp to 100")
	service.change_value(&"brother_aldren", -300)
	if service.get_value(&"brother_aldren") != 0:
		failures.append("Relationship values should clamp to 0")


static func _test_snapshot_round_trip(failures: Array[String]) -> void:
	var data := RelationshipData.new()
	data.id = &"brother_aldren"
	data.default_value = 5
	var source := RelationshipService.new()
	source.register(data)
	source.change_value(&"brother_aldren", 37)
	if not source.has_method("snapshot"):
		failures.append("RelationshipService should expose snapshot()")
		return
	var saved: Variant = source.call("snapshot")
	if typeof(saved) != TYPE_DICTIONARY:
		failures.append("Relationship snapshot should be a dictionary")
		return
	var restored := RelationshipService.new()
	restored.register(data)
	if not restored.has_method("apply_snapshot"):
		failures.append("RelationshipService should expose apply_snapshot()")
		return
	restored.call("apply_snapshot", saved)
	if restored.get_value(&"brother_aldren") != 42:
		failures.append("Relationship snapshot restore should preserve the saved value")


static func _test_dialogue_unlock(failures: Array[String]) -> void:
	var relationship := load("res://data/relationships/brother_aldren.tres") as RelationshipData
	var dialogue := load("res://data/dialogues/brother_aldren/introduction.tres") as DialogueData
	if relationship == null or dialogue == null:
		failures.append("Relationship and Aldren dialogue resources should load")
		return
	var relationships := RelationshipService.new()
	relationships.register(relationship)
	var dialogue_service := DialogueService.new()
	dialogue_service.start(dialogue, relationships.build_dialogue_context())
	if _has_option(dialogue_service.get_available_options(), &"trusted_question"):
		failures.append("Trusted dialogue option should be locked below relationship threshold")
	relationships.change_value(&"brother_aldren", 10)
	dialogue_service.start(dialogue, relationships.build_dialogue_context())
	if not _has_option(dialogue_service.get_available_options(), &"trusted_question"):
		failures.append("Relationship 10 should unlock Aldren trusted dialogue content")


static func _has_option(options: Array[DialogueOptionData], option_id: StringName) -> bool:
	for option in options:
		if option.id == option_id:
			return true
	return false
