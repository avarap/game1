class_name TestDialogueConditions
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_test_item_condition(failures)
	_test_time_condition(failures)
	_test_quest_flag_condition(failures)
	_test_aldren_night_option(failures)
	return failures


static func _test_item_condition(failures: Array[String]) -> void:
	var condition := DialogueConditionData.new()
	condition.condition_type = DialogueConditionData.ConditionType.HAS_ITEM
	condition.item_id = &"merchant_ring"
	condition.minimum_item_amount = 1
	if condition.matches({&"inventory": {&"merchant_ring": 0}}):
		failures.append("HAS_ITEM should reject missing inventory items")
	if not condition.matches({&"inventory": {&"merchant_ring": 1}}):
		failures.append("HAS_ITEM should accept the required inventory amount")


static func _test_time_condition(failures: Array[String]) -> void:
	var condition := DialogueConditionData.new()
	condition.condition_type = DialogueConditionData.ConditionType.TIME_OF_DAY
	condition.start_hour = 22
	condition.end_hour = 6
	if not condition.matches({&"hour": 23, &"minute": 0}):
		failures.append("TIME_OF_DAY should support a nighttime range")
	if not condition.matches({&"hour": 5, &"minute": 59}):
		failures.append("TIME_OF_DAY should support ranges that cross midnight")
	if condition.matches({&"hour": 6, &"minute": 0}):
		failures.append("TIME_OF_DAY should use an exclusive end boundary")
	if condition.matches({&"hour": 12, &"minute": 0}):
		failures.append("TIME_OF_DAY should reject times outside its range")


static func _test_quest_flag_condition(failures: Array[String]) -> void:
	var condition := DialogueConditionData.new()
	condition.condition_type = DialogueConditionData.ConditionType.QUEST_FLAG
	condition.quest_flag = &"elvira_discovered"
	if condition.matches({&"quest_flags": {&"elvira_discovered": false}}):
		failures.append("QUEST_FLAG should reject a false narrative flag")
	if not condition.matches({&"quest_flags": {&"elvira_discovered": true}}):
		failures.append("QUEST_FLAG should accept a matching narrative flag")


static func _test_aldren_night_option(failures: Array[String]) -> void:
	var dialogue := load("res://data/dialogues/brother_aldren/introduction.tres") as DialogueData
	if dialogue == null:
		failures.append("Aldren introduction should load for conditional dialogue tests")
		return
	var service := DialogueService.new()
	var context := {
		&"hour": 23,
		&"minute": 0,
		&"relationships": {&"brother_aldren": 0},
	}
	if not service.start(dialogue, context):
		failures.append("Aldren introduction should start with nighttime context")
		return
	var option_ids: Array[StringName] = []
	for option in service.get_available_options():
		option_ids.append(option.id)
	if not option_ids.has(&"night_warning"):
		failures.append("Aldren nighttime option should unlock between 22:00 and 06:00")
	if option_ids.has(&"trusted_question"):
		failures.append("Relationship-gated option should remain locked at relationship 0")
