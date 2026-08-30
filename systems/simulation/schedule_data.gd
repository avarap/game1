class_name ScheduleData
extends Resource

@export var entries: Array[ScheduleEntryData] = []


func find_entry(weekday_index: int, hour: int, minute: int) -> ScheduleEntryData:
	for entry in entries:
		if entry != null and entry.matches(weekday_index, hour, minute):
			return entry
	return null


func is_valid() -> bool:
	if entries.is_empty():
		return false
	for entry in entries:
		if entry == null or not entry.is_valid():
			return false
	return true
