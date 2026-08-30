class_name TechnologyController
extends Node

@export var technology_data: Array[TechnologyData] = []
@export_range(0, 9999, 1) var starting_red_points: int = 3
@export_range(0, 9999, 1) var starting_green_points: int = 2
@export_range(0, 9999, 1) var starting_blue_points: int = 1

var service: TechnologyService


func _enter_tree() -> void:
	add_to_group("technology_controller")
	add_to_group("save_provider")


func _ready() -> void:
	_ensure_service()


func unlock(technology_id: StringName) -> StringName:
	_ensure_service()
	if service == null:
		return TechnologyService.RESULT_INVALID_STATE
	return service.unlock(technology_id)


func is_unlocked(technology_id: StringName) -> bool:
	_ensure_service()
	return service != null and service.is_unlocked(technology_id)


func is_content_unlocked(content_id: StringName) -> bool:
	_ensure_service()
	return service != null and service.is_content_unlocked(content_id)


func get_points(point_type: TechnologyService.PointType) -> int:
	_ensure_service()
	return service.get_points(point_type) if service != null else 0


func get_save_key() -> StringName:
	return &"technology"


func get_save_data() -> Dictionary:
	_ensure_service()
	return service.snapshot() if service != null else {}


func apply_save_data(data: Dictionary) -> void:
	_ensure_service()
	if service != null:
		service.apply_snapshot(data)


func reset_progress_for_tests() -> void:
	_reset_service()


func _ensure_service() -> void:
	if service == null:
		_reset_service()


func _reset_service() -> void:
	service = TechnologyService.new()
	for technology in technology_data:
		if technology != null:
			service.register(technology)
	service.set_points(starting_red_points, starting_green_points, starting_blue_points)
