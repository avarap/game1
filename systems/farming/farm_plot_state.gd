class_name FarmPlotState
extends RefCounted

const MINUTES_PER_DAY := 24 * 60

var crop: CropData
var planted_total_minutes: int = 0
var harvestable: bool = false


func plant(
	new_crop: CropData,
	inventory: InventoryModel,
	day: int,
	hour: int,
	minute: int
) -> bool:
	if crop != null or new_crop == null or not new_crop.is_valid() or inventory == null:
		return false
	if not inventory.has_item(new_crop.seed_item_id, 1):
		return false

	var removed := inventory.remove_item(new_crop.seed_item_id, 1)
	if removed != 1:
		return false

	crop = new_crop
	planted_total_minutes = _to_absolute_minutes(day, hour, minute)
	harvestable = false
	return true


func refresh_from_time(day: int, hour: int, minute: int) -> void:
	if crop == null or harvestable:
		return
	var current_total := _to_absolute_minutes(day, hour, minute)
	if current_total - planted_total_minutes >= crop.growth_minutes:
		harvestable = true


func is_harvestable() -> bool:
	return crop != null and harvestable


func harvest(inventory: InventoryModel, harvest_item: ItemData) -> bool:
	if not is_harvestable() or inventory == null or harvest_item == null:
		return false
	if harvest_item.id != crop.harvest_item_id:
		return false
	if not inventory.can_add_item(harvest_item, crop.harvest_amount):
		return false

	if inventory.add_item(harvest_item, crop.harvest_amount) != 0:
		return false
	crop = null
	planted_total_minutes = 0
	harvestable = false
	return true


func snapshot() -> Dictionary:
	return {
		"crop_id": crop.id if crop != null else StringName(),
		"planted_total_minutes": planted_total_minutes,
		"harvestable": harvestable,
	}


func apply_snapshot(data: Dictionary, crop_data: CropData) -> void:
	crop = null
	planted_total_minutes = 0
	harvestable = false
	if crop_data == null or not crop_data.is_valid():
		return
	if StringName(data.get("crop_id", StringName())) != crop_data.id:
		return

	crop = crop_data
	planted_total_minutes = maxi(int(data.get("planted_total_minutes", 0)), 0)
	harvestable = bool(data.get("harvestable", false))


static func _to_absolute_minutes(day: int, hour: int, minute: int) -> int:
	var normalized_day := maxi(day, 1)
	var day_minutes := (normalized_day - 1) * MINUTES_PER_DAY
	var minute_of_day := posmod(hour * 60 + minute, MINUTES_PER_DAY)
	return day_minutes + minute_of_day
