class_name TestCorpseDecomposition
extends RefCounted

const MINUTES_PER_HOUR := 60


static func run() -> Array[String]:
	var failures: Array[String] = []
	var corpse := _make_corpse(8)
	if not corpse.has_method("advance_decomposition"):
		failures.append("CorpseState should expose minute-based accelerating decomposition")
		return failures
	if not corpse.has_method("get_condition_state"):
		failures.append("CorpseState should expose a readable decomposition state")
		return failures
	if not corpse.has_method("get_effective_quality"):
		failures.append("CorpseState should expose quality after decomposition penalties")
		return failures

	if int(corpse.get("decay_percent")) != 0 or int(corpse.get("age_minutes")) != 0:
		failures.append("Fresh corpse should start at integer zero decay and age")

	corpse.call("advance_decomposition", 24 * MINUTES_PER_HOUR)
	var first_day_decay := int(corpse.get("decay_percent"))
	corpse.call("advance_decomposition", 24 * MINUTES_PER_HOUR)
	var second_day_total := int(corpse.get("decay_percent"))
	var second_day_delta := second_day_total - first_day_decay
	corpse.call("advance_decomposition", 24 * MINUTES_PER_HOUR)
	var third_day_total := int(corpse.get("decay_percent"))
	var third_day_delta := third_day_total - second_day_total
	corpse.call("advance_decomposition", 24 * MINUTES_PER_HOUR)
	var fourth_day_total := int(corpse.get("decay_percent"))
	var fourth_day_delta := fourth_day_total - third_day_total
	var first_acceleration := first_day_decay < second_day_delta
	var second_acceleration := second_day_delta < third_day_delta
	var third_acceleration := third_day_delta < fourth_day_delta
	if not first_acceleration or not second_acceleration or not third_acceleration:
		failures.append("Corpse decomposition should accelerate across successive age bands")

	var one_jump := _make_corpse(8)
	var many_steps := _make_corpse(8)
	one_jump.call("advance_decomposition", 80 * MINUTES_PER_HOUR)
	for _hour in range(80):
		many_steps.call("advance_decomposition", MINUTES_PER_HOUR)
	if int(one_jump.get("decay_percent")) != int(many_steps.get("decay_percent")):
		failures.append("Large time jumps should match equivalent smaller decomposition steps")
	if int(one_jump.get("age_minutes")) != 80 * MINUTES_PER_HOUR:
		failures.append("Corpse age should persist as integer in-game minutes")

	var thresholds := _make_corpse(8)
	thresholds.set("decay_percent", 24)
	if StringName(thresholds.call("get_condition_state")) != &"fresh":
		failures.append("Decay 0-24 should be Fresh")
	thresholds.set("decay_percent", 25)
	if StringName(thresholds.call("get_condition_state")) != &"fading":
		failures.append("Decay 25-49 should be Fading")
	thresholds.set("decay_percent", 50)
	if StringName(thresholds.call("get_condition_state")) != &"decomposed":
		failures.append("Decay 50-74 should be Decomposed")
	thresholds.set("decay_percent", 75)
	if StringName(thresholds.call("get_condition_state")) != &"rotten":
		failures.append("Decay 75-100 should be Rotten")

	thresholds.set("decay_percent", 0)
	var fresh_quality := int(thresholds.call("get_effective_quality"))
	thresholds.set("decay_percent", 75)
	var rotten_quality := int(thresholds.call("get_effective_quality"))
	if rotten_quality >= fresh_quality:
		failures.append("Crossing decomposition thresholds should reduce effective corpse quality")

	var snapshot: Dictionary = one_jump.call("snapshot")
	if typeof(snapshot.get("decay_percent")) != TYPE_INT:
		failures.append("Corpse snapshot should store decay as an integer percentage")
	if typeof(snapshot.get("age_minutes")) != TYPE_INT:
		failures.append("Corpse snapshot should store age as integer minutes")
	if snapshot.has("current_decay") or snapshot.has("decay_rate_per_hour"):
		failures.append("New corpse snapshots should not retain the legacy float decay contract")

	var restored := CorpseState.from_snapshot(snapshot)
	if restored == null:
		failures.append("Integer corpse snapshot should restore")
	else:
		var same_decay := restored.decay_percent == one_jump.decay_percent
		var same_age := restored.age_minutes == one_jump.age_minutes
		if not same_decay or not same_age:
			failures.append("Corpse snapshot should preserve integer decay and age")

	return failures


static func _make_corpse(quality: int) -> CorpseState:
	var data := CorpseData.new()
	data.id = StringName("decomposition_%d" % quality)
	data.quality = quality
	data.burial_value = quality
	return CorpseState.new(data)
