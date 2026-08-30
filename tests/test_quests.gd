class_name TestQuests
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	var quest := load("res://data/quests/aldren_first_duty.tres") as QuestData
	if quest == null or not quest.is_valid():
		failures.append("First Aldren quest should load as valid QuestData")
		return failures

	var service := QuestService.new()
	if not service.register(quest):
		failures.append("QuestService should register valid quest data")
		return failures
	if service.get_status(quest.id) != QuestService.STATUS_UNAVAILABLE:
		failures.append("Registered quest should start unavailable")
	if not service.start_quest(quest.id):
		failures.append("Quest should transition from unavailable to active")
	if service.start_quest(quest.id):
		failures.append("Active quest should not be startable twice")

	service.update_item_count(&"plank", 1)
	if service.is_ready(quest.id):
		failures.append("Quest should not be ready before all required items exist")
	service.update_item_count(&"plank", 2)
	if not service.is_ready(quest.id):
		failures.append("Quest should become ready when item objective is satisfied")
	if service.get_progress(quest.id, &"prepare_planks") != 2:
		failures.append("Quest progress should track the bounded item count")
	if not service.complete_quest(quest.id):
		failures.append("Ready quest should transition to completed")
	if service.complete_quest(quest.id):
		failures.append("Completed quest should not complete twice")

	var first_rewards := service.claim_rewards(quest.id)
	var second_rewards := service.claim_rewards(quest.id)
	if first_rewards.size() != 2 or not second_rewards.is_empty():
		failures.append("All quest rewards should be claimable exactly once")
	var context: Dictionary = service.build_dialogue_context()
	var flags: Dictionary = context.get(&"quest_flags", {})
	if not bool(flags.get(&"completed_first_duty", false)):
		failures.append("QUEST_FLAG reward should remain compatible with additional reward types")

	var restored := QuestService.new()
	restored.register(quest)
	restored.apply_snapshot(service.snapshot())
	if restored.get_status(quest.id) != QuestService.STATUS_COMPLETED:
		failures.append("Quest snapshot should restore completed state")
	if not restored.claim_rewards(quest.id).is_empty():
		failures.append("Restored reward claim should remain idempotent")

	_test_journal_read_model(quest, failures)
	_test_journal_presentation(quest, failures)
	return failures


static func _test_journal_read_model(quest: QuestData, failures: Array[String]) -> void:
	var controller := QuestController.new()
	controller.quest_data.append(quest)
	controller.service.register(quest)
	controller.service.start_quest(quest.id)
	controller.service.update_item_count(&"plank", 1)

	if not controller.has_method("get_journal_entries"):
		failures.append("QuestController should expose read-only journal entries")
		controller.free()
		return

	var active_entries: Array = controller.call("get_journal_entries")
	if active_entries.size() != 1:
		failures.append("Journal should expose one active quest")
		controller.free()
		return
	var active_entry: Dictionary = active_entries[0]
	if active_entry.get("id") != quest.id:
		failures.append("Journal entry should preserve the quest id")
	if active_entry.get("status") != QuestService.STATUS_ACTIVE:
		failures.append("Journal entry should distinguish an active quest")
	if active_entry.get("title_key") != quest.title_key:
		failures.append("Journal entry should expose the localized title key")
	if active_entry.get("description_key") != quest.description_key:
		failures.append("Journal entry should expose the localized description key")
	var active_objectives: Array = active_entry.get("objectives", [])
	if active_objectives.size() != 1:
		failures.append("Journal entry should expose quest objectives")
	else:
		var active_objective: Dictionary = active_objectives[0]
		if active_objective.get("id") != &"prepare_planks":
			failures.append("Journal objective should preserve the objective id")
		if int(active_objective.get("current", -1)) != 1:
			failures.append("Journal objective should expose current progress")
		if int(active_objective.get("required", -1)) != 2:
			failures.append("Journal objective should expose required progress")

	controller.service.update_item_count(&"plank", 2)
	controller.service.complete_quest(quest.id)
	var completed_entries: Array = controller.call("get_journal_entries")
	if completed_entries.size() != 1:
		failures.append("Journal should retain completed quests")
		controller.free()
		return
	var completed_entry: Dictionary = completed_entries[0]
	if completed_entry.get("status") != QuestService.STATUS_COMPLETED:
		failures.append("Journal entry should distinguish a completed quest")
	var completed_objectives: Array = completed_entry.get("objectives", [])
	if completed_objectives.is_empty() or int(completed_objectives[0].get("current", -1)) != 2:
		failures.append("Completed journal entry should preserve final objective progress")

	var previous_locale := String(LocalizationService.get_locale())
	var before_locale_change: Dictionary = completed_entry.duplicate(true)
	LocalizationService.set_locale("es")
	var after_locale_entries: Array = controller.call("get_journal_entries")
	LocalizationService.set_locale(previous_locale)
	if after_locale_entries.is_empty():
		failures.append("Journal entries should remain available after a locale change")
		controller.free()
		return
	var after_locale_change: Dictionary = after_locale_entries[0]
	if before_locale_change.get("id") != after_locale_change.get("id"):
		failures.append("Changing locale should not alter quest ids")
	if before_locale_change.get("objectives") != after_locale_change.get("objectives"):
		failures.append("Changing locale should not alter quest progress")
	controller.free()


static func _test_journal_presentation(quest: QuestData, failures: Array[String]) -> void:
	var previous_locale := String(LocalizationService.get_locale())
	LocalizationService.set_locale("en")
	var english_title := LocalizationService.translate_key(&"UI_QUEST_JOURNAL_TITLE")
	LocalizationService.set_locale("es")
	var spanish_title := LocalizationService.translate_key(&"UI_QUEST_JOURNAL_TITLE")
	LocalizationService.set_locale(previous_locale)
	if english_title == spanish_title:
		failures.append("Quest journal generic UI labels should support English and Spanish")

	var journal_path := "res://ui/quests/quest_journal.gd"
	if not ResourceLoader.exists(journal_path):
		failures.append("Quest journal UI script should exist")
		return
	var journal_script := load(journal_path) as GDScript
	if journal_script == null:
		failures.append("Quest journal UI script should load")
		return
	var journal: Node = journal_script.new()
	if not journal.has_method("build_sections"):
		failures.append("Quest journal UI should expose a pure presentation builder")
		journal.free()
		return

	var entries: Array[Dictionary] = [
		{
			"id": &"active_quest",
			"status": QuestService.STATUS_ACTIVE,
			"title_key": quest.title_key,
			"description_key": quest.description_key,
			"objectives": [{"id": &"prepare_planks", "current": 1, "required": 2}],
		},
		{
			"id": &"completed_quest",
			"status": QuestService.STATUS_COMPLETED,
			"title_key": quest.title_key,
			"description_key": quest.description_key,
			"objectives": [{"id": &"prepare_planks", "current": 2, "required": 2}],
		},
	]
	LocalizationService.set_locale("en")
	var english_sections: Dictionary = journal.call("build_sections", entries)
	LocalizationService.set_locale("es")
	var spanish_sections: Dictionary = journal.call("build_sections", entries)
	LocalizationService.set_locale(previous_locale)

	var english_active: Array = english_sections.get("active", [])
	var english_completed: Array = english_sections.get("completed", [])
	var spanish_active: Array = spanish_sections.get("active", [])
	if english_active.size() != 1 or english_completed.size() != 1:
		failures.append("Quest journal should separate active and completed quests")
	elif spanish_active.is_empty():
		failures.append("Quest journal should rebuild sections after a locale change")
	else:
		var english_entry: Dictionary = english_active[0]
		var spanish_entry: Dictionary = spanish_active[0]
		if english_entry.get("title") == spanish_entry.get("title"):
			failures.append("Quest journal should localize quest titles when locale changes")
		if english_entry.get("description") == spanish_entry.get("description"):
			failures.append("Quest journal should localize descriptions when locale changes")
		if english_entry.get("id") != spanish_entry.get("id"):
			failures.append("Presentation localization should not alter quest ids")
		if english_entry.get("objectives") != spanish_entry.get("objectives"):
			failures.append("Presentation localization should not alter quest progress")
	journal.free()
