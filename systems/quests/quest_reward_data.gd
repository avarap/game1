class_name QuestRewardData
extends Resource

enum RewardType { QUEST_FLAG }

@export var reward_type: RewardType = RewardType.QUEST_FLAG
@export var flag_id: StringName


func is_valid() -> bool:
	match reward_type:
		RewardType.QUEST_FLAG:
			return not flag_id.is_empty()
	return false
