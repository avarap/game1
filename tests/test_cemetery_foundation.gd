class_name TestCemeteryFoundation
extends RefCounted

static func run() -> Array[String]:
    var failures: Array[String] = []
    var config := load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
    if config == null:
        failures.append("Cemetery rating config should load")
        return failures

    var corpse_data := CorpseData.new()
    corpse_data.id = &"test_corpse"
    corpse_data.decay = 0.10
    corpse_data.preparation_level = 1
    corpse_data.burial_value = 2

    var corpse := CorpseState.new(corpse_data, 0.05)
    var decay_after_two_hours: float = corpse.advance_decay(2.0)
    if absf(decay_after_two_hours - 0.20) > 0.001:
        failures.append("Corpse decay should advance deterministically")
    corpse.advance_decay(100.0)
    if not corpse.is_fully_decayed() or corpse.current_decay != 1.0:
        failures.append("Corpse decay should clamp at 1.0")

    var grave := GraveRecord.new(corpse)
    if grave.contribution(config) != 2:
        failures.append("Buried corpse should contribute its burial value")

    grave.has_headstone = true
    grave.has_fence = true
    grave.decoration_count = 2
    var expected_rating: int = 2 + config.headstone_points + config.fence_points + 2 * config.decoration_points
    if grave.contribution(config) != expected_rating:
        failures.append("Grave improvements should modify rating using config data")

    var cemetery := CemeteryModel.new(config)
    cemetery.add_grave(grave)
    var second_data := CorpseData.new()
    second_data.id = &"second_corpse"
    second_data.burial_value = 4
    cemetery.add_grave(GraveRecord.new(CorpseState.new(second_data, 0.0)))
    if cemetery.total_rating() != expected_rating + 4:
        failures.append("Cemetery rating should aggregate grave contributions")

    var snapshot := cemetery.snapshot()
    var serialized_graves: Array = snapshot.get("graves", [])
    if int(snapshot.get("rating", -1)) != cemetery.total_rating() or serialized_graves.size() != 2:
        failures.append("Cemetery snapshot should preserve rating and grave count")

    return failures
