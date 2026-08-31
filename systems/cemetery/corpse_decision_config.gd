class_name CorpseDecisionConfig
extends Resource

@export var cremate_red_points: int = 1
@export var cremate_green_points: int = 0
@export var cremate_blue_points: int = 0
@export var research_red_points: int = 0
@export var research_green_points: int = 0
@export var research_blue_points: int = 2


func reward_for(decision: StringName, corpse: CorpseState) -> Vector3i:
	var quality_bonus := 0
	if corpse != null:
		quality_bonus = maxi(corpse.get_effective_quality() - 1, 0)
	match decision:
		&"cremate":
			return Vector3i(cremate_red_points, cremate_green_points, cremate_blue_points)
		&"research":
			return Vector3i(
				research_red_points, research_green_points, research_blue_points + quality_bonus
			)
	return Vector3i.ZERO
