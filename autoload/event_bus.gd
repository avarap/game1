extends Node

signal bootstrap_ready
signal day_changed(day: int)
signal time_changed(hour: int, minute: int)
signal save_completed(path: String)
signal load_completed(path: String)
signal debug_message(message: String)
signal funeral_delivery_completed(
	corpse_id: StringName, logical_day: int, reception_point: StringName
)
signal corpse_final_decision_completed(
	corpse_id: StringName,
	decision: StringName,
	reward_red: int,
	reward_green: int,
	reward_blue: int,
)
