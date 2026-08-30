extends SceneTree


func _initialize() -> void:
	call_deferred("_run_all_tests")


func _run_all_tests() -> void:
	var failures: Array[String] = []
	_run_suite("TimeMath", TestTimeMath.run(), failures)
	_run_suite("SimulationTime", TestSimulationTime.run(), failures)
	_run_suite("DayNightCycle", TestDayNightCycle.run(), failures)
	_run_suite("NPCNavigation", TestNPCNavigation.run(), failures)
	_run_suite("NPCRoutines", TestNPCRoutines.run(), failures)
	_run_suite("SimulationAcceptance", TestSimulationAcceptance.run(), failures)
	_run_suite("DialogueFoundation", TestDialogueFoundation.run(), failures)
	_run_suite("DialogueGameplay", TestDialogueGameplay.run(), failures)
	_run_suite("DialogueConditions", TestDialogueConditions.run(), failures)
	_run_suite("Relationships", TestRelationships.run(), failures)
	_run_suite("Quests", TestQuests.run(), failures)
	_run_suite("QuestGameplay", TestQuestGameplay.run(), failures)
	_run_suite("RPGAcceptance", TestRPGAcceptance.run(), failures)
	_run_suite("PlayerMovement", TestPlayerMovement.run(), failures)
	_run_suite("WalkingPrototype", TestWalkingPrototype.run(), failures)
	_run_suite("InventoryModel", TestInventoryModel.run(), failures)
	_run_suite("ItemsFoundation", TestItemsFoundation.run(), failures)
	_run_suite("ResourceLoop", TestResourceLoop.run(), failures)
	_run_suite("CraftingFoundation", TestCraftingFoundation.run(), failures)
	_run_suite("StorageNetwork", TestStorageNetwork.run(), failures)
	_run_suite("ProductionQueue", TestProductionQueue.run(), failures)
	_run_suite("CemeteryFoundation", TestCemeteryFoundation.run(), failures)
	_run_suite("CemeteryFlow", TestCemeteryFlow.run(), failures)
	_run_suite("CemeteryPersistence", TestCemeteryPersistence.run(), failures)
	_run_suite("CemeteryGameplay", TestCemeteryGameplay.run(), failures)
	_run_suite("EconomyFoundation", TestEconomyFoundation.run(), failures)
	_run_suite("EconomyGameplay", TestEconomyGameplay.run(), failures)
	_run_suite("TechnologyFoundation", TestTechnologyFoundation.run(), failures)
	_run_suite("TechnologyGameplay", TestTechnologyGameplay.run(), failures)

	if failures.is_empty():
		print("[TEST] All core tests passed")
		quit(0)
		return

	for failure in failures:
		push_error("[TEST] %s" % failure)
	quit(1)


func _run_suite(name: String, suite_failures: Array[String], failures: Array[String]) -> void:
	print("[TEST] %s complete (%d failures)" % [name, suite_failures.size()])
	failures.append_array(suite_failures)
