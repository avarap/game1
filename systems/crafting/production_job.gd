class_name ProductionJob
extends RefCounted

const STATE_QUEUED: StringName = &"queued"
const STATE_PROCESSING: StringName = &"processing"
const STATE_AWAITING_OUTPUT: StringName = &"awaiting_output"
const STATE_COMPLETED: StringName = &"completed"

var recipe: RecipeData
var elapsed_seconds: float = 0.0
var state: StringName = STATE_QUEUED


func _init(p_recipe: RecipeData) -> void:
	recipe = p_recipe


func progress_ratio() -> float:
	if recipe == null or recipe.duration_seconds <= 0.0:
		return 1.0
	return clampf(elapsed_seconds / recipe.duration_seconds, 0.0, 1.0)


func is_ready() -> bool:
	return recipe != null and elapsed_seconds >= recipe.duration_seconds
