class_name TestWorldPhase7Acceptance
extends RefCounted


static func run() -> Array[String]:
	var failures: Array[String] = []
	_append_suite("MapFoundation", TestMapFoundation.run(), failures)
	_append_suite("CemeteryMap", TestCemeteryMap.run(), failures)
	_append_suite("MapForest", TestMapForest.run(), failures)
	_append_suite("MapVillage", TestMapVillage.run(), failures)
	_append_suite("MapInteriors", TestMapInteriors.run(), failures)
	_append_suite("MapMine", TestMapMine.run(), failures)
	_append_suite("WorldZoneIntegration", TestWorldZoneIntegration.run(), failures)
	_append_suite("NPCNavigation", TestNPCNavigation.run(), failures)
	_append_suite("NPCRoutines", TestNPCRoutines.run(), failures)
	return failures


static func _append_suite(
	suite_name: String, suite_failures: Array[String], failures: Array[String]
) -> void:
	for failure in suite_failures:
		failures.append("Phase7/%s: %s" % [suite_name, failure])
