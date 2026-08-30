class_name TechnologyService
extends RefCounted

enum PointType { RED, GREEN, BLUE }

const RESULT_OK: StringName = &"ok"
const RESULT_INVALID_STATE: StringName = &"invalid_state"
const RESULT_INVALID_TECHNOLOGY: StringName = &"invalid_technology"
const RESULT_ALREADY_UNLOCKED: StringName = &"already_unlocked"
const RESULT_INSUFFICIENT_POINTS: StringName = &"insufficient_points"

var _technologies: Dictionary = {}
var _points: Dictionary = {
	PointType.RED: 0,
	PointType.GREEN: 0,
	PointType.BLUE: 0,
}
var _unlocked_technologies: Dictionary = {}
var _unlocked_content: Dictionary = {}


func register(technology: TechnologyData) -> bool:
	if technology == null or not technology.is_valid():
		return false
	if _technologies.has(technology.id):
		return false
	_technologies[technology.id] = technology
	return true


func set_points(red: int, green: int, blue: int) -> bool:
	if red < 0 or green < 0 or blue < 0:
		return false
	_points[PointType.RED] = red
	_points[PointType.GREEN] = green
	_points[PointType.BLUE] = blue
	return true


func get_points(point_type: PointType) -> int:
	return int(_points.get(point_type, 0))


func unlock(technology_id: StringName) -> StringName:
	var technology := _get_technology(technology_id)
	if technology == null:
		return RESULT_INVALID_TECHNOLOGY
	if is_unlocked(technology_id):
		return RESULT_ALREADY_UNLOCKED
	if not _can_afford(technology):
		return RESULT_INSUFFICIENT_POINTS

	_points[PointType.RED] = get_points(PointType.RED) - technology.red_cost
	_points[PointType.GREEN] = get_points(PointType.GREEN) - technology.green_cost
	_points[PointType.BLUE] = get_points(PointType.BLUE) - technology.blue_cost
	_unlocked_technologies[technology.id] = true
	for content_id in technology.unlock_ids:
		_unlocked_content[content_id] = true
	return RESULT_OK


func is_unlocked(technology_id: StringName) -> bool:
	return bool(_unlocked_technologies.get(technology_id, false))


func is_content_unlocked(content_id: StringName) -> bool:
	return bool(_unlocked_content.get(content_id, false))


func snapshot() -> Dictionary:
	var unlocked_ids: Array[String] = []
	for technology_id in _unlocked_technologies.keys():
		unlocked_ids.append(str(technology_id))
	unlocked_ids.sort()
	return {
		&"points": {
			&"red": get_points(PointType.RED),
			&"green": get_points(PointType.GREEN),
			&"blue": get_points(PointType.BLUE),
		},
		&"unlocked": unlocked_ids,
	}


func apply_snapshot(data: Dictionary) -> bool:
	var points_value: Variant = data.get(&"points", {})
	var unlocked_value: Variant = data.get(&"unlocked", [])
	if typeof(points_value) != TYPE_DICTIONARY or typeof(unlocked_value) != TYPE_ARRAY:
		return false

	var points := points_value as Dictionary
	var red := int(points.get(&"red", -1))
	var green := int(points.get(&"green", -1))
	var blue := int(points.get(&"blue", -1))
	if red < 0 or green < 0 or blue < 0:
		return false

	var candidate_unlocked: Dictionary = {}
	var candidate_content: Dictionary = {}
	for value in unlocked_value as Array:
		var technology_id := StringName(str(value))
		var technology := _get_technology(technology_id)
		if technology == null:
			return false
		candidate_unlocked[technology_id] = true
		for content_id in technology.unlock_ids:
			candidate_content[content_id] = true

	set_points(red, green, blue)
	_unlocked_technologies = candidate_unlocked
	_unlocked_content = candidate_content
	return true


func _get_technology(technology_id: StringName) -> TechnologyData:
	return _technologies.get(technology_id) as TechnologyData


func _can_afford(technology: TechnologyData) -> bool:
	return (
		get_points(PointType.RED) >= technology.red_cost
		and get_points(PointType.GREEN) >= technology.green_cost
		and get_points(PointType.BLUE) >= technology.blue_cost
	)
