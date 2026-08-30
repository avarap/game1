class_name TestRelationships
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_service(failures)
	_test_snapshot_round_trip(failures)
	_test_snapshot_copy_isolated(failures)
	_test_snapshot_validation(failures)
	_test_save_provider_contract(failures)
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
	var data := _make_relationship(&"brother_aldren", 5)
	var source := RelationshipService.new()
	source.register(data)
	source.change_value(&"brother_aldren", 37)
	var saved := source.snapshot()
	var restored := RelationshipService.new()
	restored.register(data)
	restored.apply_snapshot(saved)
	if restored.get_value(&"brother_aldren") != 42:
		failures.append("Relationship snapshot restore should preserve the saved value")


static func _test_snapshot_copy_isolated(failures: Array[String]) -> void:
	var data := _make_relationship(&"brother_aldren", 5)
	var service := RelationshipService.new()
	service.register(data)
	service.set_value(&"brother_aldren", 42)
	var saved := service.snapshot()
	var saved_values: Dictionary = saved.get("values", {})
	saved_values[&"brother_aldren"] = 99
	if service.get_value(&"brother_aldren") != 42:
		failures.append("Relationship snapshot should not alias live relationship state")


static func _test_snapshot_validation(failures: Array[String]) -> void:
	var data := _make_relationship(&"brother_aldren", 5)
	var service := RelationshipService.new()
	service.register(data)
	service.set_value(&"brother_aldren", 50)
	service.apply_snapshot({"values": {"brother_aldren": "invalid", "unknown_relationship": 80}})
	if service.get_value(&"brother_aldren") != 50:
		failures.append("Malformed relationship values should not overwrite valid state")
	if service.has_relationship(&"unknown_relationship"):
		failures.append("Unknown relationship IDs should be ignored during restore")
	service.apply_snapshot({"values": {"brother_aldren": 150.0}})
	if service.get_value(&"brother_aldren") != 100:
		failures.append("Restored relationship values should clamp to 100")
	service.apply_snapshot({"values": {"brother_aldren": -20.0}})
	if service.get_value(&"brother_aldren") != 0:
		failures.append("Restored relationship values should clamp to 0")


static func _test_save_provider_contract(failures: Array[String]) -> void:
	var data := _make_relationship(&"brother_aldren", 5)
	var controller := RelationshipController.new()
	controller.relationship_data.append(data)
	controller.call("_enter_tree")
	controller.call("_ready")
	if not controller.is_in_group("save_provider"):
		failures.append("RelationshipController should register as a save_provider")
		controller.free()
		return
	for method_name in [&"get_save_key", &"get_save_data", &"apply_save_data"]:
		if not controller.has_method(method_name):
			failures.append("RelationshipController should implement %s()" % method_name)
			controller.free()
			return
	if StringName(str(controller.call("get_save_key"))) != &"relationships":
		failures.append("RelationshipController save key should remain relationships")
	controller.change_relationship(&"brother_aldren", 37)
	var saved: Variant = controller.call("get_save_data")
	if typeof(saved) != TYPE_DICTIONARY:
		failures.append("RelationshipController save data should be a dictionary")
		controller.free()
		return
	var restored := RelationshipController.new()
	restored.relationship_data.append(data)
	restored.call("_ready")
	restored.call("apply_save_data", saved)
	if restored.get_relationship(&"brother_aldren") != 42:
		failures.append("RelationshipController should restore saved relationship state")
	controller.free()
	restored.free()


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
	var restored := RelationshipService.new()
	restored.register(relationship)
	restored.apply_snapshot(relationships.snapshot())
	dialogue_service.start(dialogue, restored.build_dialogue_context())
	if not _has_option(dialogue_service.get_available_options(), &"trusted_question"):
		failures.append("Restored relationship values should feed RELATIONSHIP_MIN conditions")


static func _make_relationship(id: StringName, default_value: int) -> RelationshipData:
	var data := RelationshipData.new()
	data.id = id
	data.default_value = default_value
	return data


static func _has_option(options: Array[DialogueOptionData], option_id: StringName) -> bool:
	for option in options:
		if option.id == option_id:
			return true
	return false
