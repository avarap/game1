class_name TestDialogueFoundation
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var previous_locale := TranslationServer.get_locale()
	_test_localization(failures)
	_test_conditions(failures)
	_test_dialogue_graph(failures)
	TranslationServer.set_locale(previous_locale)
	return failures


static func _test_localization(failures: Array[String]) -> void:
	if not LocalizationService.set_locale("es"):
		failures.append("Spanish should be a supported locale")
	if LocalizationService.translate_key(&"NPC_BROTHER_ALDREN_NAME") != "Hermano Aldren":
		failures.append("Spanish translation should resolve through TranslationServer")
	if not LocalizationService.set_locale("en"):
		failures.append("English should be a supported locale")
	if LocalizationService.translate_key(&"NPC_BROTHER_ALDREN_NAME") != "Brother Aldren":
		failures.append("English translation should resolve through TranslationServer")
	if LocalizationService.set_locale("fr"):
		failures.append("Unsupported locales should be rejected explicitly")


static func _test_conditions(failures: Array[String]) -> void:
	var condition := DialogueConditionData.new()
	condition.flag = &"cemetery_repaired"
	condition.expected_value = true
	if condition.matches({&"cemetery_repaired": false}):
		failures.append("Dialogue condition should reject a mismatched flag")
	if not condition.matches({&"cemetery_repaired": true}):
		failures.append("Dialogue condition should accept a matching flag")


static func _test_dialogue_graph(failures: Array[String]) -> void:
	var dialogue := load(
		"res://data/dialogues/brother_aldren/introduction.tres"
	) as DialogueData
	if dialogue == null or not dialogue.is_valid():
		failures.append("Brother Aldren dialogue should load as valid DialogueData")
		return

	var service := DialogueService.new()
	if not service.start(dialogue):
		failures.append("DialogueService should start a valid dialogue")
		return
	if service.current_node.id != &"intro":
		failures.append("Dialogue should start at its configured start node")
	if service.get_available_options().size() != 3:
		failures.append("Intro node should expose its three data-driven options")
	if not service.choose_option(&"identity"):
		failures.append("Choosing an available option should advance the dialogue")
	elif service.current_node.id != &"identity_response":
		failures.append("Dialogue option should resolve its configured next node")

	var node_before_locale_change := service.current_node.id
	LocalizationService.set_locale("es")
	LocalizationService.set_locale("en")
	if service.current_node.id != node_before_locale_change:
		failures.append("Changing language must not mutate dialogue graph state")
