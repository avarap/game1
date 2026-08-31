class_name CemeteryController
extends Node

const FODDER_ITEM_PATH := "res://data/items/fodder_turnip.tres"
const FUNERAL_FEEDER_ID := &"funeral_feeder"
const FUNERAL_FEEDER_SCOPE := &"cemetery"

@export var rating_config: CemeteryRatingConfig

var service: CemeteryService
var funeral_service: FuneralDeliveryService
var funeral_storage: StorageNetwork
var funeral_feeder_inventory: InventoryModel


func _enter_tree() -> void:
	add_to_group("cemetery_controller")


func _ready() -> void:
	initialize()
	add_to_group("save_provider")


func _process(_delta: float) -> void:
	var time_manager := get_node_or_null("/root/TimeManager")
	if time_manager == null:
		return
	sync_funeral_time(
		int(time_manager.get("day")), int(time_manager.get("hour")), int(time_manager.get("minute"))
	)


func initialize() -> void:
	if rating_config == null:
		rating_config = load("res://data/cemetery/default_rating.tres") as CemeteryRatingConfig
	if service == null:
		service = CemeteryService.new(CemeteryModel.new(rating_config))
	if funeral_storage == null:
		_reset_funeral_storage()
	if funeral_service == null:
		funeral_service = FuneralDeliveryService.new(service, funeral_storage)


func get_save_key() -> StringName:
	return &"cemetery"


func get_save_data() -> Dictionary:
	initialize()
	var data := service.snapshot()
	data["funeral_delivery"] = funeral_service.snapshot()
	data["funeral_feeder_fodder"] = funeral_fodder_count()
	return data


func apply_save_data(data: Dictionary) -> void:
	initialize()
	service = CemeteryService.from_snapshot(rating_config, data)
	_reset_funeral_storage(int(data.get("funeral_feeder_fodder", 0)))
	funeral_service = FuneralDeliveryService.new(service, funeral_storage)
	var funeral_data: Dictionary = data.get("funeral_delivery", {})
	if not funeral_data.is_empty():
		funeral_service.apply_snapshot(funeral_data)


func sync_funeral_time(day: int, hour: int, minute: int = 0) -> void:
	initialize()
	funeral_service.sync_time(day, hour, minute)


func deposit_funeral_fodder(amount: int) -> void:
	initialize()
	if amount <= 0:
		return
	var fodder := load(FODDER_ITEM_PATH) as ItemData
	funeral_storage.deposit(fodder, amount)


func funeral_fodder_count() -> int:
	initialize()
	return funeral_storage.get_available_amount(FuneralDeliveryService.FODDER_ITEM_ID)


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


func _reset_funeral_storage(fodder_amount: int = 0) -> void:
	funeral_feeder_inventory = InventoryModel.new(8)
	funeral_storage = StorageNetwork.new()
	funeral_storage.add_provider(
		StorageProvider.new(FUNERAL_FEEDER_ID, funeral_feeder_inventory, FUNERAL_FEEDER_SCOPE)
	)
	if fodder_amount <= 0:
		return
	var fodder := load(FODDER_ITEM_PATH) as ItemData
	funeral_storage.deposit(fodder, fodder_amount)
