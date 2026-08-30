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
	if first_rewards.size() != 1 or not second_rewards.is_empty():
		failures.append("Quest rewards should be claimable exactly once")
	var context: Dictionary = service.build_dialogue_context()
	var flags: Dictionary = context.get(&"quest_flags", {})
	if not bool(flags.get(&"completed_first_duty", false)):
		failures.append("Quest reward flag should be granted on first claim")

	var restored := QuestService.new()
	restored.register(quest)
	restored.apply_snapshot(service.snapshot())
	if restored.get_status(quest.id) != QuestService.STATUS_COMPLETED:
		failures.append("Quest snapshot should restore completed state")
	if not restored.claim_rewards(quest.id).is_empty():
		failures.append("Restored reward claim should remain idempotent")
	return failures
