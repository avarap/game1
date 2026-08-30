class_name QuestRewardData
extends Resource

enum RewardType { QUEST_FLAG, TECHNOLOGY_POINTS }

@export var reward_type: RewardType = RewardType.QUEST_FLAG
@export var flag_id: StringName
@export_range(0, 9999, 1) var red_points: int = 0
@export_range(0, 9999, 1) var green_points: int = 0
@export_range(0, 9999, 1) var blue_points: int = 0


func is_valid() -> bool:
	match reward_type:
		RewardType.QUEST_FLAG:
			return not flag_id.is_empty()
		RewardType.TECHNOLOGY_POINTS:
			return red_points + green_points + blue_points > 0
	return false
