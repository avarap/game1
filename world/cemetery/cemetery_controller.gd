class_name CemeteryController
extends Node

@export var rating_config: CemeteryRatingConfig

var service: CemeteryService


func _enter_tree() -> void:
	add_to_group("cemetery_controller")


func _ready() -> void:
	initialize()
	add_to_group("save_provider")


func initialize() -> void:
	if rating_config == null:
		rating_config = load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	if service == null:
		service = CemeteryService.new(CemeteryModel.new(rating_config))


func get_save_key() -> StringName:
	return &"cemetery"


func get_save_data() -> Dictionary:
	initialize()
	return service.snapshot()


func apply_save_data(data: Dictionary) -> void:
	initialize()
	service = CemeteryService.from_snapshot(rating_config, data)


func receive_demo_corpse() -> StringName:
	initialize()
	var data := CorpseData.new()
	data.id = &"demo_corpse_001"
	data.quality = 2
	data.decay_percent = 5
	data.preparation_level = 0
	data.burial_value = 2
	return service.receive_corpse(CorpseState.new(data))


func prepare_first_pending() -> StringName:
	initialize()
	var corpse_id := service.first_pending_id()
	if corpse_id == &"":
		return CemeteryService.RESULT_NOT_FOUND
	return service.prepare_corpse(corpse_id, 1)


func bury_first_pending() -> StringName:
	initialize()
	var corpse_id := service.first_pending_id()
	if corpse_id == &"":
		return CemeteryService.RESULT_NOT_FOUND
	var grave := service.bury_corpse(corpse_id)
	return CemeteryService.RESULT_OK if grave != null else CemeteryService.RESULT_NOT_FOUND


func upgrade_first_grave() -> StringName:
	initialize()
	if service.model == null or service.model.graves.is_empty():
		return CemeteryService.RESULT_INVALID_GRAVE
	var grave := service.model.graves[0]
	if not grave.has_headstone:
		return service.install_headstone(0)
	if not grave.has_fence:
		return service.install_fence(0)
	return service.add_decoration(0, 1)


func total_rating() -> int:
	initialize()
	return service.total_rating()
